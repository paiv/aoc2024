// gcc -O2 -Wall day2.c -o day2 && ./day2 < day2.in
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>


static size_t
load_image(long* image, char* data, size_t datasize) {
    size_t N = datasize / 2;
    char* p = data, *q;
    char* end = data + datasize;
    for (int i = 0; p < end; ++i) {
        q = NULL;
        errno = 0;
        long x = strtol(p, &q, 10);
        if (errno != 0) {
            perror("strtol");
            abort();
        }
        p = q + 1;
        image[i] = x;
        N = i + 1;
    }
    return N;
}


static long
vm_run(long* image, size_t N, long a, long b) {
    image[1] = a;
    image[2] = b;

    for (size_t i = 0; i < N; i += 4) {
        long op = image[i];
        if (op == 99) {
            break;
        }
        if (i + 3 >= N) {
            break;
        }
        long x = image[i + 1];
        long y = image[i + 2];
        long z = image[i + 3];
        if (x < 0 || x >= N) { abort(); }
        if (y < 0 || y >= N) { abort(); }
        if (z < 0 || z >= N) { abort(); }
        switch (op) {
            case 1:
                image[z] = image[x] + image[y];
                break;
            case 2:
                image[z] = image[x] * image[y];
                break;
            default:
                fprintf(stderr, "unhandled op %ld\n", op);
                abort();
        }
    }
    return image[0];
}


static long
solve1(char* data, int datasize) {
    long image[datasize / 2];
    size_t N = load_image(image, data, datasize);
    return vm_run(image, N, 12, 2);
}


static long
solve2(char* data, int datasize) {
    long image[datasize / 2];
    size_t N = load_image(image, data, datasize);
    long goal = 19690720;
    long mem[N];
    for (long y = 0; y < 100; ++y) {
        for (long x = 0; x < 100; ++x) {
            memcpy(mem, image, sizeof(mem));
            long ans = vm_run(mem, N, x, y);
            if (ans == goal) {
                return x * 100 + y;
            }
        }
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
    long ans = solve1(data, datasize);
    printf("part1: %ld\n", ans);
    ans = solve2(data, datasize);
    printf("part2: %ld\n", ans);
    return 0;
}

