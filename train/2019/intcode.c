// gcc -O2 -Wall -Werror -fpic -shared -o libintcode.so intcode.c
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


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
    size_t N = (sizeof(pipe->buf)/sizeof(pipe->buf[0]));
    off_t q = (pipe->w + 1) % N;
    if (q == pipe->r) {
        fprintf(stderr, "pipe buffer overflow at %zu\n", N);
        abort();
    }
    pipe->buf[pipe->w] = value;
    pipe->w = q;
}


static size_t
ivm_load_image(struct ivm_image* image, char* data, size_t datasize) {
    size_t bufsize = image->size;
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
        if (i >= bufsize) {
            fprintf(stderr, "out of program memory at %d\n", i);
            abort();
        }
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


struct ic_state_s;

typedef struct ic_state_s* ic_state;

struct ic_state_s {
    struct ivm_image image;
    struct ivm_pipe pin, pout;
    word code[0x10000];
};


enum ic_ret {
    IcRet_ok,
    IcRet_out,
    IcRet_in,
    IcRet_halt,
};


extern ic_state
ic_create_state() {
    ic_state s = malloc(sizeof(struct ic_state_s));
    return s;
}


extern void
ic_delete_state(ic_state state) {
    free(state);
}


extern int
ic_state_init_data(ic_state state, const char* data, size_t datasize) {
    size_t bufsize = sizeof(state->code) / sizeof(state->code[0]);
    state->image = (struct ivm_image) {.buf = state->code, .size = bufsize};
    ivm_load_image(&state->image, (char*) data, datasize);
    state->image.size = bufsize;
    return IcRet_ok;
}


extern int
ic_interact(ic_state state, const char* input, char* output) {
    if (input != NULL) {
        for (const char* p = input; *p != '\0'; ++p) {
            ivm_pipe_write(&state->pin, *p);
        }
    }
    if (ivm_pipe_count(&state->pout) >= 1) {
        word chr = 0;
        ivm_pipe_read(&state->pout, &chr);
        if (output != NULL) {
            *output = chr;
        }
        return IcRet_out;
    }
    for (;;) {
        int res = ivm_run(&state->image, &state->pin, &state->pout);

        if (res == IvmRet_in) {
            return IcRet_in;
        }

        if (res == IvmRet_halt) {
            return IcRet_halt;
        }

        if (ivm_pipe_count(&state->pout) >= 1) {
            word chr = 0;
            ivm_pipe_read(&state->pout, &chr);
            if (output != NULL) {
                *output = chr;
            }
            return IcRet_out;
        }
    }
}
