// gcc -O2 -Wall day23.c -o day23 && ./day23 < day23.in
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>


#define IVM_TRACE 0
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
            #if IVM_TRACE
            { word i = image->buf[image->ip + 1];
            if (i < 0 || i >= image->size) {
                fprintf(stderr, "%lld is outside of addressable memory %zu\n", i, image->size);
                abort(); }
            // else { fprintf(stderr, "%06llx: %lld\n", i, value); }
            }
            #endif
            image->buf[image->buf[image->ip + 1]] = value;
            break;
        case 1:
            fprintf(stderr, "assigning to imm %lld\n", image->buf[image->ip + 1]);
            abort();
        case 2:
            #if IVM_TRACE
            { word i = image->base + image->buf[image->ip + 1];
            if (i < 0 || i >= image->size) {
                fprintf(stderr, "%lld is outside of addressable memory %zu\n", i, image->size);
                abort(); }
            // else { fprintf(stderr, "%06llx: %lld\n", i, value); }
            }
            #endif
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
            #if IVM_TRACE
            { word i = image->buf[image->ip + 3];
            if (i < 0 || i >= image->size) {
                fprintf(stderr, "%lld is outside of addressable memory %zu\n", i, image->size);
                abort(); }
            // else { fprintf(stderr, "%06llx: %lld\n", i, value); }
            }
            #endif
            image->buf[image->buf[image->ip + 3]] = value;
            break;
        case 1:
            fprintf(stderr, "assigning to imm %lld\n", image->buf[image->ip + 3]);
            abort();
        case 2:
            #if IVM_TRACE
            { word i = image->base + image->buf[image->ip + 3];
            if (i < 0 || i >= image->size) {
                fprintf(stderr, "%lld is outside of addressable memory %zu\n", i, image->size);
                abort(); }
            // else { fprintf(stderr, "%06llx: %lld\n", i, value); }
            }
            #endif
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


static word
run_nic(struct ivm_image* program, int part) {
    static word code[50][0x1000];
    struct ivm_image workers[50];
    struct ivm_pipe pipes[50][2] = {};
    for (size_t id = 0; id < 50; ++id) {
        workers[id] = (struct ivm_image) {.buf = code[id], .size = 0x1000, .ip = 0};
        memcpy(code[id], program->buf, program->size * sizeof(word));
        ivm_pipe_write(&pipes[id][0], id);
    }
    word natx = -1, naty = -1, seen = -1;
    int idle = 0;
    for (size_t id = 0; ; id = (id + 1) % 50) {
        if (id == 0) {
            idle = 1;
        }
        struct ivm_pipe *pin = &pipes[id][0], *pout = &pipes[id][1];
        if (ivm_pipe_count(pin) > 1) {
            idle = 0;
        }
        for (;;) {
            int res = ivm_run(&workers[id], pin, pout);

            if (ivm_pipe_count(pout) >= 3) {
                word to = -1, x = 0, y = 0;
                ivm_pipe_read(pout, &to);
                ivm_pipe_read(pout, &x);
                ivm_pipe_read(pout, &y);
                #if IVM_TRACE
                fprintf(stderr, "write to nic %lld: %lld, %lld\n", to, x, y);
                #endif
                if (to == 255) {
                    if (part == 1) { return y; }
                    natx = x;
                    naty = y;
                }
                if (to >= 0 && to < 50) {
                    struct ivm_pipe *pto = &pipes[to][0];
                    ivm_pipe_write(pto, x);
                    ivm_pipe_write(pto, y);
                }
            }

            if (res == IvmRet_in) {
                #if IVM_TRACE
                fprintf(stderr, "write to nic %ld: -1\n", id);
                #endif
                ivm_pipe_write(pin, -1);
                break;
            }

            if (res == IvmRet_halt) { break; }
        }
        if (id == 49 && natx != -1) {
            if (idle != 0) {
                #if IVM_TRACE
                fprintf(stderr, "write to nic %d: nat %lld, %lld\n", 0, natx, naty);
                #endif
                struct ivm_pipe *pin = &pipes[0][0];
                ivm_pipe_write(pin, natx);
                ivm_pipe_write(pin, naty);
                if (seen == naty) {
                    return seen;
                }
                seen = naty;
            }
        }
    }
    return -1;
}


static word
solve1(char* data, int datasize) {
    word code[0x1000];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    word ans = run_nic(&program, 1);
    return ans;
}


static word
solve2(char* data, int datasize) {
    word code[0x1000];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    word ans = run_nic(&program, 2);
    return ans;
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

