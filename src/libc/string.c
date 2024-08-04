#include "include/string.h"
#include "include/stdint.h"

void *memset(void *ptr, char val, uint32_t count)
{
    char *tmp = (char*)ptr;
    
    for(uint32_t i = 0; i < count; i++) {*tmp++ = val;}
    return ptr;
}