// gcc -O2 -Wall day7.c -o day7 && ./day7 < day7.in
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
        word x = strtol(p, &q, 10);
        if (errno != 0) {
            perror("strtol");
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
                return IvmRet_io;
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
            default:
                fprintf(stderr, "unhandled op %lld\n", op);
                abort();
        }
    }
    return IvmRet_halt;
}


static word
run_amp(struct ivm_image amp[5], word phase[5], int max_cycles) {
    struct ivm_pipe pipe[5] = {};
    for (size_t i = 0; i < 5; ++i) {
        ivm_pipe_write(&pipe[i], phase[i]);
    }
    word ans = 0;
    ivm_pipe_write(&pipe[0], 0);
    int halted = 0;
    for (size_t t = 0; halted == 0 && t < max_cycles; ++t) {
        for (size_t i = 0; i < 5; ++i) {
            struct ivm_pipe* pin = &pipe[i];
            struct ivm_pipe* pout = &pipe[(i + 1) % 5];
            int res = ivm_run(&amp[i], pin, pout);
            if (res == IvmRet_halt) {
                halted = 1;
            }
        }
        ivm_pipe_peek(&pipe[0], &ans);
    }
    return ans;
}


static void
setup_amp(struct ivm_image amp[5], word* bufs, struct ivm_image* program) {
    for (size_t i = 0; i < 5; ++i) {
        word* buf = &bufs[i * program->size];
        memcpy(buf, program->buf, program->size * sizeof(word));
        amp[i] = (struct ivm_image) {.size = program->size, .buf = buf, .ip = 0};
    }
}


static word
solve_(char* data, int datasize, word phase[5], int max_cycles) {
    word code[datasize / 2];
    struct ivm_image program = (struct ivm_image) {.buf = code};
    ivm_load_image(&program, data, datasize);
    word bufs[5][program.size] = {};
    struct ivm_image amp[5];

    int c[5] = {0};
    setup_amp(amp, (word*) bufs, &program);
    word ans = run_amp(amp, phase, max_cycles);
    for (size_t k = 1; k < 5; ) {
        if (c[k] < k) {
            size_t j = (k & 1) ? c[k] : 0;
            word t = phase[j];
            phase[j] = phase[k];
            phase[k] = t;
            c[k] += 1;
            k = 1;
            setup_amp(amp, (word*) bufs, &program);
            word x = run_amp(amp, phase, max_cycles);
            if (x > ans) {
                ans = x;
            }
        }
        else {
            c[k] = 0;
            k += 1;
        }
    }
    return ans;
}


static word
solve1(char* data, int datasize) {
    word phase[5] = {0, 1, 2, 3, 4};
    return solve_(data, datasize, phase, 1);
}


static word
solve2(char* data, int datasize) {
    word phase[5] = {5, 6, 7, 8, 9};
    return solve_(data, datasize, phase, 0x7fffffff);
}


static void
run_tests() {
    char t1[] = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0";
    word q1 = solve1(t1, sizeof(t1));
    if (q1 != 43210) { abort(); }
    char t2[] = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5";
    word q2 = solve2(t2, sizeof(t2));
    if (q2 != 139629729) { abort(); }
}


int main() {
    run_tests();
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
    if (ans == 24414060) { abort(); }
    ans = solve2(data, datasize);
    printf("part2: %lld\n", ans);
    return 0;
}

