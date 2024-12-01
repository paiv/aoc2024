// gcc -O2 -Wall day11.c -o day11 && ./day11 < day11.in
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>


#define IVM_TRACE 0
#define IVM_BUFSIZE 100


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
    IvmRet_io,
    IvmRet_halt,
};


static int
ivm_run(struct ivm_image* image, struct ivm_pipe* pin, struct ivm_pipe* pout) {
    size_t N = image->size;
    for (; image->ip < N; ) {
        word ins = arg0(image);
        word op = ins % 100;

        #if IVM_TRACE > 5
        fprintf(stderr, "%04llX: %ld %03ld\n", image->ip, op, ins / 100);
        for (size_t o = image->ip, j = 0; j < 4; ++j, ++o) {
            fprintf(stderr, " %ld", image->buf[o]);
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
                    return IvmRet_io;
                }
                arg1s(image, value);
                image->ip += 2;
                break;
            }
            case 4:
                #if IVM_TRACE
                fprintf(stderr, "%lld\n", arg1(image));
                #endif
                ivm_pipe_write(pout, arg1(image));
                image->ip += 2;
                break;
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


static word
solve_(char* data, int datasize, int seed) {
    word code[datasize / 2];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    struct ivm_pipe pipe[2] = {}, *pin = &pipe[0], *pout = &pipe[1];
    size_t gridsize = 100;
    char grid[gridsize][gridsize] = {};
    char visited[gridsize][gridsize] = {};
    word posx=gridsize/2, posy=gridsize/2, dirx=0, diry=-1;
    word color, turn;
    grid[posy][posx] = seed;
    for (;;) {
        color = grid[posy][posx];
        ivm_pipe_write(pin, color);
        int res = ivm_run(&program, pin, pout);
        if (res == IvmRet_halt) { break; }
        res = ivm_pipe_read(pout, &color);
        if (res != 1) { abort(); }
        grid[posy][posx] = color;
        visited[posy][posx] = 1;
        res = ivm_pipe_read(pout, &turn);
        if (res != 1) { abort(); }
        switch (turn) {
            case 0:
                if (dirx != 0) {
                    diry = -dirx;
                    dirx = 0;
                }
                else {
                    dirx = diry;
                    diry = 0;
                }
                break;
            case 1:
                if (dirx != 0) {
                    diry = dirx;
                    dirx = 0;
                }
                else {
                    dirx = -diry;
                    diry = 0;
                }
                break;
            default:
                abort();
        }
        word nx = posx + dirx;
        word ny = posy + diry;
        if (nx < 0 || nx >= gridsize || ny < 0 || ny >= gridsize) {
            fprintf(stderr, "outside of grid bounds at %lld,%lld\n", nx, ny);
            abort();
        }
        posx = nx;
        posy = ny;
    }
    word ans = 0;
    for (size_t y = 0; y < gridsize; ++y) {
        for (size_t x = 0; x < gridsize; ++x) {
            ans += visited[y][x];
            fprintf(stderr, "%c", grid[y][x] ? '#' : '.');
        }
        fprintf(stderr, "\n");
    }
    return ans;
}


static word
solve1(char* data, int datasize) {
    return solve_(data, datasize, 0);
}


static word
solve2(char* data, int datasize) {
    return solve_(data, datasize, 1);
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

