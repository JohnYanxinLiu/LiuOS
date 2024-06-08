#include <string.h>

size_t strlen(const char *s)
{
    size_t len = 0;
    size_t i = 0;
    while(s[i] != '\0'){
        len++;
    }
    return len;
}