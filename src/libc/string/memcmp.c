#include <string.h>

int memcmp(const void *s1, const void *s2, size_t n)
{
    unsigned char *s1Ptr = (unsigned char *)s1;
    unsigned char *s2Ptr = (unsigned char *)s2;

    for (size_t i = 0; i < n; i++)
    {
        if (s1Ptr[i] < s2Ptr[2])
        {
            return -1;
        } 
        else if (s1Ptr[i] > s2Ptr[2])
        {
            return 1;
        }
    }

    return 0;

}