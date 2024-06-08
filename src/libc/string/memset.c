#include <string.h>
#include <stdint.h>

void *memset(void* buf, int c, size_t n)
{
    unsigned char *b = (unsigned char*)buf;

    for (size_t i = 0; i < n; i++)
        b[i] = (unsigned char)c;

    return buf;
}