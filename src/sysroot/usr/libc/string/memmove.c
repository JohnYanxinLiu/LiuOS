#include <string.h>
#include <stdint.h>

void *memmove(void *dst, const void *src, size_t n)
{
    unsigned char *dstPtr = (unsigned char *)dst;
    unsigned char *srcPtr = (unsigned char *)src;

    if ((uint32_t)src < (uint32_t)dst)
    {
        for (size_t i = n; i > 0; i--)
        {
            dstPtr[i] = srcPtr[i];
        }
    } else 
    {
        for (size_t i = 0; i < n; )
        {
            dstPtr[i] = srcPtr[i];
        }
    }
    return dst;
}