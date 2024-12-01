// gcc -O2 -Wall day15.c -o day15 && ./day15 < day15.in
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>


#define IVM_TRACE 1
#define IVM_BUFSIZE 100

#define gridsizex 50
#define gridsizey 50

typedef long long word;


struct ivm_image {
    size_t size;
    word* buf;
    off_t ip;
    word base;
};


struct ivm_pipe {
    off_t r, w;
    word buf[IVM_BUFSIZE];
};


static inline size_t
ivm_pipe_count(struct ivm_pipe* pipe) {
    if (pipe->w >= pipe->r) {
        return pipe->w - pipe->r;
    }
    return pipe->w + (sizeof(pipe->buf)/sizeof(pipe->buf[0])) - pipe->r;
}


static inline int
ivm_pipe_read(struct ivm_pipe* pipe, word* value) {
    if (pipe->r == pipe->w) {
        return 0;
    }
    *value = pipe->buf[pipe->r];
    pipe->r = (pipe->r + 1) % (sizeof(pipe->buf)/sizeof(pipe->buf[0]));
    return 1;
}


static inline int
ivm_pipe_peek(struct ivm_pipe* pipe, word* value) {
    if (pipe->r == pipe->w) {
        return 0;
    }
    *value = pipe->buf[pipe->r];
    return 1;
}


static inline void
ivm_pipe_write(struct ivm_pipe* pipe, word value) {
    off_t q = (pipe->w + 1) % (sizeof(pipe->buf)/sizeof(pipe->buf[0]));
    if (q == pipe->r) {
        abort();
    }
    pipe->buf[pipe->w] = value;
    pipe->w = q;
}


static size_t
ivm_load_image(struct ivm_image* image, char* data, size_t datasize) {
    size_t N = datasize / 2;
    char* p = data, *q;
    char* end = data + datasize;
    for (int i = 0; p < end; ++i) {
        q = NULL;
        errno = 0;
        word x = strtoll(p, &q, 10);
        if (errno != 0) {
            perror("strtoll");
            abort();
        }
        p = q + 1;
        image->buf[i] = x;
        N = i + 1;
    }
    image->size = N;
    image->ip = 0;
    return N;
}


static inline word
arg0(struct ivm_image* image) {
    return image->buf[image->ip];
}


static inline word
arg1(struct ivm_image* image) {
    word mode = image->buf[image->ip];
    mode = mode / 100 % 10;
    switch (mode) {
        case 0: return image->buf[image->buf[image->ip + 1]];
        case 1: return image->buf[image->ip + 1];
        case 2: return image->buf[image->base + image->buf[image->ip + 1]];
        default:
            fprintf(stderr, "unhandled arg mode %lld\n", mode);
            abort();
    }
}

static inline word
arg2(struct ivm_image* image) {
    word mode = image->buf[image->ip];
    mode = mode / 1000 % 10;
    switch (mode) {
        case 0: return image->buf[image->buf[image->ip + 2]];
        case 1: return image->buf[image->ip + 2];
        case 2: return image->buf[image->base + image->buf[image->ip + 2]];
        default:
            fprintf(stderr, "unhandled arg mode %lld\n", mode);
            abort();
    }
}


static inline word
arg3(struct ivm_image* image) {
    word mode = image->buf[image->ip];
    mode = mode / 10000 % 10;
    switch (mode) {
        case 0: return image->buf[image->buf[image->ip + 3]];
        case 1: return image->buf[image->ip + 3];
        case 2: return image->buf[image->base + image->buf[image->ip + 3]];
        default:
            fprintf(stderr, "unhandled arg mode %lld\n", mode);
            abort();
    }
}


static inline void
arg1s(struct ivm_image* image, word value) {
    word mode = image->buf[image->ip];
    mode = mode / 100 % 10;
    switch (mode) {
        case 0:
            image->buf[image->buf[image->ip + 1]] = value;
            break;
        case 1:
            fprintf(stderr, "assigning to imm %lld\n", image->buf[image->ip + 1]);
            abort();
        case 2:
            image->buf[image->base + image->buf[image->ip + 1]] = value;
            break;
        default:
            fprintf(stderr, "unhandled arg mode %lld\n", mode);
            abort();
    }
}


static inline void
arg3s(struct ivm_image* image, word value) {
    word mode = image->buf[image->ip];
    mode = mode / 10000 % 10;
    switch (mode) {
        case 0:
            image->buf[image->buf[image->ip + 3]] = value;
            break;
        case 1:
            fprintf(stderr, "assigning to imm %lld\n", image->buf[image->ip + 3]);
            abort();
        case 2:
            image->buf[image-> base + image->buf[image->ip + 3]] = value;
            break;
        default:
            fprintf(stderr, "unhandled arg mode %lld\n", mode);
            abort();
    }
}


enum {
    IvmRet_out,
    IvmRet_in,
    IvmRet_halt,
};


static int
ivm_run(struct ivm_image* image, struct ivm_pipe* pin, struct ivm_pipe* pout) {
    size_t N = image->size;
    for (; image->ip < N; ) {
        word ins = arg0(image);
        word op = ins % 100;

        #if IVM_TRACE > 5
        fprintf(stderr, "%04llX: %ld %03lld\n", image->ip, op, ins / 100);
        for (size_t o = image->ip, j = 0; j < 4; ++j, ++o) {
            fprintf(stderr, " %lld", image->buf[o]);
        }
        fprintf(stderr, "\n");
        #endif

        if (op == 99) {
            break;
        }
        switch (op) {
            case 1:
                arg3s(image,
                    arg1(image) + arg2(image)
                );
                image->ip += 4;
                break;
            case 2:
                arg3s(image,
                    arg1(image) * arg2(image)
                );
                image->ip += 4;
                break;
            case 3: {
                word value;
                if (ivm_pipe_read(pin, &value) == 0) {
                    return IvmRet_in;
                }
                arg1s(image, value);
                image->ip += 2;
                break;
            }
            case 4:
                ivm_pipe_write(pout, arg1(image));
                image->ip += 2;
                return IvmRet_out;
            case 5:
                if (arg1(image) != 0) {
                    image->ip = arg2(image);
                }
                else {
                    image->ip += 3;
                }
                break;
            case 6:
                if (arg1(image) == 0) {
                    image->ip = arg2(image);
                }
                else {
                    image->ip += 3;
                }
                break;
            case 7:
                arg3s(image, arg1(image) < arg2(image) ? 1 : 0);
                image->ip += 4;
                break;
            case 8:
                arg3s(image, arg1(image) == arg2(image) ? 1 : 0);
                image->ip += 4;
                break;
            case 9:
                image->base += arg1(image);
                image->ip += 2;
                break;
            default:
                fprintf(stderr, "unhandled op %lld\n", op);
                abort();
        }
    }
    return IvmRet_halt;
}


static inline void
frame_sync(float fps) {
    float r = 1 / fps;
    time_t s = r;
    long n = (r - s) * 1e9;
    struct timespec t = {.tv_sec = s, .tv_nsec = n};
    nanosleep(&t, NULL);
}


struct grid_s {
    size_t width, height;
    char* data;
};


struct search_path {
    int posx, posy;
    int len;
    char start;
};


static struct search_path
plan_step(struct grid_s* grid, word goalx, word goaly, word posx, word posy) {
    #define frsize 4000
    static struct search_path fringe[frsize];
    static char visited[gridsizey][gridsizex];
    memset(visited, 0, sizeof(visited));
    visited[posy][posx] = 1;
    size_t fringe_size = 0;
    word px = posx, py = posy - 1;
    if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
        if (grid->data[py * grid->width + px] != '#') {
            fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = 1, .len = 1};
        }
    }
    px = posx, py = posy + 1;
    if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
        if (grid->data[py * grid->width + px] != '#') {
            fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = 2, .len = 1};
        }
    }
    px = posx - 1, py = posy;
    if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
        if (grid->data[py * grid->width + px] != '#') {
            fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = 3, .len = 1};
        }
    }
    px = posx + 1, py = posy;
    if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
        if (grid->data[py * grid->width + px] != '#') {
            fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = 4, .len = 1};
        }
    }
    for (size_t fri = 0; fri < fringe_size; ++fri) {
        struct search_path* p = &fringe[fri];
        if (p->posx == goalx && p->posy == goaly) {
            return *p;
        }
        if (visited[p->posy][p->posx] != 0) { continue; }
        visited[p->posy][p->posx] = 1;
        if (fringe_size + 4 >= frsize) {
            fprintf(stderr, "out of fringe at %zu (%zu)\n", fringe_size, fri);
            abort();
        }
        word px = p->posx, py = p->posy - 1;
        if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
            if (visited[py][px] == 0 && grid->data[py * grid->width + px] != '#') {
                fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = p->start, .len = p->len+1};
            }
        }
        px = p->posx, py = p->posy + 1;
        if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
            if (visited[py][px] == 0 && grid->data[py * grid->width + px] != '#') {
                fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = p->start, .len = p->len+1};
            }
        }
        px = p->posx - 1, py = p->posy;
        if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
            if (visited[py][px] == 0 && grid->data[py * grid->width + px] != '#') {
                fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = p->start, .len = p->len+1};
            }
        }
        px = p->posx + 1, py = p->posy;
        if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
            if (visited[py][px] == 0 && grid->data[py * grid->width + px] != '#') {
                fringe[fringe_size++] = (struct search_path) {.posx = px, .posy = py, .start = p->start, .len = p->len+1};
            }
        }
    }
    return (struct search_path) {};
}


struct plan_s {
    size_t id;
    word goalx, goaly;
};


static struct plan_s
plan_for_cell(struct grid_s* grid, word posx, word posy, word cellx, word celly) {
    char t = grid->data[celly * grid->width + cellx];
    if (t == ' ') {
        struct search_path path = plan_step(grid, cellx, celly, posx, posy);
        if (path.start != 0) {
            return (struct plan_s) {.id = 1, .goalx = cellx, .goaly = celly};
        }
    }
    return (struct plan_s) {};
}


static struct plan_s
plan_next(struct grid_s* grid, word posx, word posy) {
    word px = posx, py = posy;
    word dx = 1, dy = 0;
    for (word inc = 1; ;) {
        int oob = 1;
        for (word w = 0; w < inc; ++w) {
            px += dx;
            py += dy;
            if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
                oob = 0;
                struct plan_s plan = plan_for_cell(grid, posx, posy, px, py);
                if (plan.id != 0) { return plan; }
            }
        }
        dx = 0;
        dy = 1;
        for (word w = 0; w < inc; ++w) {
            px += dx;
            py += dy;
            if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
                oob = 0;
                struct plan_s plan = plan_for_cell(grid, posx, posy, px, py);
                if (plan.id != 0) { return plan; }
            }
        }
        dx = -1;
        dy = 0;
        inc += 1;
        for (word w = 0; w < inc; ++w) {
            px += dx;
            py += dy;
            if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
                oob = 0;
                struct plan_s plan = plan_for_cell(grid, posx, posy, px, py);
                if (plan.id != 0) { return plan; }
            }
        }
        dx = 0;
        dy = -1;
        for (word w = 0; w < inc; ++w) {
            px += dx;
            py += dy;
            if (px >= 0 && px < grid->width && py >= 0 && py < grid->height) {
                oob = 0;
                struct plan_s plan = plan_for_cell(grid, posx, posy, px, py);
                if (plan.id != 0) { return plan; }
            }
        }
        dx = 1;
        dy = 0;
        inc += 1;
        if (oob) { break; }
    }
    return (struct plan_s) {};
}


static void
dump_grid(struct grid_s* grid, word posx, word posy) {
    // fprintf(stderr, "\x1b[%uA\x1b[%uD", gridsizey, gridsizex);
    size_t stride = grid->width;
    for (size_t y = 0; y < grid->height; ++y) {
        for (size_t x = 0; x < grid->width; ++x) {
            if (x == posx && y == posy) {
                fprintf(stderr, "D");
            }
            else {
                fprintf(stderr, "%c", grid->data[y * stride + x]);
            }
        }
        fprintf(stderr, "\n");
    }
}


static void
explore_grid(char* data, int datasize, char grid[gridsizey][gridsizex], int startx, int starty, int* o2x, int* o2y) {
    word code[datasize / 2];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    struct ivm_pipe pipe[2] = {}, *pin = &pipe[0], *pout = &pipe[1];
    struct grid_s pgrid = {.width = gridsizex, .height = gridsizey, .data = (char*) grid};
    word posx=startx, posy=starty, tile=0, step=1;
    struct plan_s plan = {};
    for (;;) {
        int res = ivm_run(&program, pin, pout);
        if (res == IvmRet_halt) { break; }

        if (ivm_pipe_count(pout) >= 1) {
            res = ivm_pipe_read(pout, &tile);
            word tx = posx, ty = posy;
            switch (step) {
                case 1: ty -= 1; break;
                case 2: ty += 1; break;
                case 3: tx -= 1; break;
                case 4: tx += 1; break;
            }
            if (tx < 0 || tx >= gridsizex || ty < 0 || ty >= gridsizey) {
                fprintf(stderr, "outside of grid bounds at %lld,%lld\n", tx, ty);
                abort();
            }
            grid[ty][tx] = "#.O"[tile];
            if (tile != 0) {
                posx = tx;
                posy = ty;
                if (plan.goalx == posx && plan.goaly == posy) {
                    plan.id = 0;
                }
            }
            else {
                plan.id = 0;
            }
            if (tile == 2) {
                *o2x = posx;
                *o2y = posy;
            }
            #if IVM_TRACE > 2
            dump_grid(&pgrid, posx, posy);
            frame_sync(30);
            #endif
        }

        if (res == IvmRet_in) {
            if (plan.id == 0) {
                plan = plan_next(&pgrid, posx, posy);
            }
            struct search_path path = plan_step(&pgrid, plan.goalx, plan.goaly, posx, posy);
            step = path.start;
            ivm_pipe_write(pin, step);
        }
    }
    #if IVM_TRACE
    dump_grid(&pgrid, startx, starty);
    #endif
}


static word
solve1(char* data, int datasize) {
    char grid[gridsizey][gridsizex] = {};
    struct grid_s pgrid = {.width = gridsizex, .height = gridsizey, .data = (char*) grid};
    memset(grid, ' ', sizeof(grid));
    word startx=gridsizex/2, starty=gridsizey/2;
    int o2x=0, o2y=0;
    explore_grid(data, datasize, grid, startx, starty, &o2x, &o2y);
    struct search_path path = plan_step(&pgrid, o2x, o2y, startx, starty);
    return path.len;
}


static word
solve2(char* data, int datasize) {
    char grid[gridsizey][gridsizex] = {};
    memset(grid, ' ', sizeof(grid));
    word startx=gridsizex/2, starty=gridsizey/2;
    int o2x=0, o2y=0;
    explore_grid(data, datasize, grid, startx, starty, &o2x, &o2y);
    char visited1[gridsizey][gridsizex] = {};
    char visited2[gridsizey][gridsizex] = {};
    visited1[o2y][o2x] = 1;
    visited2[o2y][o2x] = 1;
    for (size_t t = 0; ; ++t) {
        int filled = 1;
        for (size_t y = 0; y < gridsizey; ++y) {
            for (size_t x = 0; x < gridsizex; ++x) {
                if (visited1[y][x] != 0) {
                    if (grid[y-1][x] == '.' && visited2[y-1][x] == 0) {
                        visited2[y-1][x] = 1;
                        filled = 0;
                    }
                    if (grid[y+1][x] == '.' && visited2[y+1][x] == 0) {
                        visited2[y+1][x] = 1;
                        filled = 0;
                    }
                    if (grid[y][x-1] == '.' && visited2[y][x-1] == 0) {
                        visited2[y][x-1] = 1;
                        filled = 0;
                    }
                    if (grid[y][x+1] == '.' && visited2[y][x+1] == 0) {
                        visited2[y][x+1] = 1;
                        filled = 0;
                    }
                }
            }
        }
        if (filled != 0) {
            return t;
        }
        memcpy(visited1, visited2, sizeof(visited1));
    }
    return -1;
}


int main() {
    int fd = STDIN_FILENO;
    struct stat st;
    int err = fstat(fd, &st);
    if (err == -1) {
        perror("fstat");
        return 1;
    }
    off_t datasize = st.st_size;
    char* data = mmap(NULL, datasize, PROT_READ, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        perror("mmap");
        return 1;
    }
    word ans = solve1(data, datasize);
    printf("part1: %lld\n", ans);
    ans = solve2(data, datasize);
    printf("part2: %lld\n", ans);
    return 0;
}

