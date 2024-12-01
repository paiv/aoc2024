// gcc -O2 -Wall day17.c -o day17 && ./day17 < day17.in
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
            image->buf[image->base + image->buf[image->ip + 3]] = value;
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
        fprintf(stderr, "%04llX: %lld %03lld\n", image->ip, op, ins / 100);
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


static void
explore_grid(char* data, int datasize, char grid[gridsizey][gridsizex]) {
    static word code[0x10000];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    struct ivm_pipe pipe[2] = {}, *pin = &pipe[0], *pout = &pipe[1];
    word chr;
    int px = 0, py = 0;
    for (;;) {
        int res = ivm_run(&program, pin, pout);

        while (ivm_pipe_count(pout) >= 1) {
            ivm_pipe_read(pout, &chr);
            #if IVM_TRACE
            fputc(chr, stderr);
            #endif
            if (chr == '\n') {
                px = 0;
                py += 1;
            }
            else {
                if (px < 0 || px >= gridsizex || py < 0 || py >= gridsizey) {
                    fprintf(stderr, "outside of grid at %d,%d\n", px, py);
                    abort();
                }
                grid[py][px++] = chr;
            }
        }

        if (res == IvmRet_halt) { break; }
    }
}


static word
solve1(char* data, int datasize) {
    char grid[gridsizey][gridsizex];
    memset(grid, '.', sizeof(grid));
    explore_grid(data, datasize, grid);
    word ans = 0;
    for (size_t y = 1; y + 1 < gridsizey; ++y) {
        for (size_t x = 1; x + 1 < gridsizex; ++x) {
            if (grid[y][x] == '#' && grid[y-1][x] == '#' && grid[y+1][x] == '#' &&
                grid[y][x-1] == '#' && grid[y][x+1] == '#') {
                ans += y * x;
            }
        }
    }
    return ans;
}


static word
solve2(char* data, int datasize) {
    static word code[0x10000];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    program.buf[0] = 2;
    struct ivm_pipe pipe[2] = {}, *pin = &pipe[0], *pout = &pipe[1];
    word chr;
    char instr[] = "A,B,A,C,B,A,C,B,A,C\n"
        "L,12,L,12,L,6,L,6\n"
        "R,8,R,4,L,12\n"
        "L,12,L,6,R,12,R,8\n"
        "n\n";
    FILE* fin = fmemopen(instr, sizeof(instr), "r");
    for (;;) {
        int res = ivm_run(&program, pin, pout);

        while (ivm_pipe_count(pout) >= 1) {
            ivm_pipe_read(pout, &chr);
            if (chr > 255) {
                return chr;
            }
            #if IVM_TRACE
            fputc(chr, stderr);
            #endif
        }

        if (res == IvmRet_in) {
            int c = fgetc(fin);
            if (c == EOF) { break; }
            #if IVM_TRACE
            fputc(c, stderr);
            #endif
            ivm_pipe_write(pin, c);
        }

        if (res == IvmRet_halt) { break; }
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

