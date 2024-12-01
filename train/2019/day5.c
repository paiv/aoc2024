// gcc -O2 -Wall day5.c -o day5 && ./day5 < day5.in
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>


#define IVM_TRACE 0
#define IVM_BUFSIZE 100


typedef long word;


struct ivm_image {
    size_t size;
    word* buf;
    off_t ip;
};


struct ivm_stream {
    off_t pos;
    size_t size;
    word buf[IVM_BUFSIZE];
};


static inline word
ivm_stream_read(struct ivm_stream* stream) {
    if (stream->pos < stream->size) {
        return stream->buf[stream->pos++];
    }
    abort();
}


static inline void
ivm_stream_write(struct ivm_stream* stream, word value) {
    if (stream->pos + 1 < stream->size) {
        stream->buf[stream->pos++] = value;
    }
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
            fprintf(stderr, "unhandled arg mode %ld\n", mode);
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
            fprintf(stderr, "unhandled arg mode %ld\n", mode);
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
            fprintf(stderr, "unhandled arg mode %ld\n", mode);
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
            fprintf(stderr, "assigning to imm %ld\n", image->buf[image->ip + 1]);
            abort();
        default:
            fprintf(stderr, "unhandled arg mode %ld\n", mode);
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
            fprintf(stderr, "assigning to imm %ld\n", image->buf[image->ip + 3]);
            abort();
        default:
            fprintf(stderr, "unhandled arg mode %ld\n", mode);
            abort();
    }
}


static word
ivm_run(struct ivm_image* image, word a) {
    size_t N = image->size;
    struct ivm_stream sin = (struct ivm_stream) {.size = 1, .buf = {a}, .pos = 0};
    struct ivm_stream son = (struct ivm_stream) {.size = IVM_BUFSIZE, .pos = 0};

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
            case 3:
                arg1s(image, ivm_stream_read(&sin));
                image->ip += 2;
                break;
            case 4:
                #if IVM_TRACE
                fprintf(stderr, "%ld\n", arg1(image));
                #endif
                ivm_stream_write(&son, arg1(image));
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
            default:
                fprintf(stderr, "unhandled op %ld\n", op);
                abort();
        }
    }
    if (son.pos > 0) {
        return son.buf[son.pos - 1];
    }
    return -1;
}


static word
solve1(char* data, int datasize) {
    word buf[datasize / 2];
    struct ivm_image image = (struct ivm_image) {.buf = buf};
    ivm_load_image(&image, data, datasize);
    return ivm_run(&image, 1);
}


static word
solve2(char* data, int datasize) {
    word buf[datasize / 2];
    struct ivm_image image = (struct ivm_image) {.buf = buf};
    ivm_load_image(&image, data, datasize);
    return ivm_run(&image, 5);
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
    printf("part1: %ld\n", ans);
    ans = solve2(data, datasize);
    printf("part2: %ld\n", ans);
    return 0;
}

