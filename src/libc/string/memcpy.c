#include <string.h>
#include <stdint.h>
#include <stdlib.h>

void *memcpy(void *dst, const void *src, size_t n)
{
    if (((uint32_t)dst - (uint32_t)src) < n || ((uint32_t)src - (uint32_t)dst) < n) {
        abort();
    }

    return memmove(dst, src, n);
}