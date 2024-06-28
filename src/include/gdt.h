
#include "stdint.h"


//Offsets for descriptor fields in segment descriptor
#define SEGMENT_UPPER_BASE_OFFSET 56
#define SEGMENT_FLAGS_OFFSET 52
#define SEGMENT_UPPER_LIMIT_OFFSET 48
#define SEGMENT_ACCESS_BYTE_OFFSET 40
#define SEGMENT_MID_BASE_OFFSET 32
#define SEGMENT_LOW_BASE_OFFSET 16
#define SEGMENT_LOW_LIMIT_OFFSET 0


//Offsets for the bit position that larger fields are broken up by 
#define UPPER_BASE_BIT_POS 24
#define MID_BASE_BIT_POS 16
#define LOW_BASE_BIT_POS 0
#define UPPER_LIMIT_BIT_POS 16
#define LOW_LIMIT_BIT_POS 0


//Bit masks for fields
#define UPPER_BASE_MASK 0xFF
#define FLAGS_MASK 0xF
#define UPPER_LIMIT_MASK 0xF
#define ACCESS_BYTE_MASK 0xFF
#define MID_BASE_MASK 0xF
#define LOW_BASE_MASK 0xFFFF
#define LOW_LIMIT_MASK 0xFFFF


//Access Byte Masks
#define PRESENT_MASK                1 << 7 // Is the memory segment valid? (always set to 1)
#define PRIVILEDGE_LEVEL_MASK       3 << 6 // CPU Priviledge level, 0 (kernel) is highest, 3 (user application) is lowest
#define TYPE_MASK                   1 << 4 // If 0, it is a system segment. If 1, it defines a code or data segment (beginning will always be 1)
#define EXECUTABLE_MASK             1 << 3 // If 0, it cannot be executed (defines a data segment), If 1, it defines a code segment which can be executed (cannot be written to)
#define DIRECTION_CONFORMING_MASK   1 << 2 // If 0, grows up, if 1, grows down. (we will always be going up, so clear to 0)
#define RW_MASK                     1 << 1 // For code segment, Readable bit, if 1, read is allowed, write is snever allowed | For data segments, writeable bit, if 0, write access is not allowed, if 1, write access is allowed, read access is always allowed.
#define ACCESSED_MASK               1      // Checks if the segment has been accessed.


//Flag Masks
#define GRANULARITY_MASK    1 << 3 // if 0, limit is in 1 byte blocks, if 1, limit is in 4KiB blocks
#define SIZE_MASK           1 << 2 // if 0, 16-bit protected mode, if 1, 32-bit protected mode.(always 1 since we're in 32-bit)
#define LONG_MODE_MASK      1 << 1 // If 1, it defines a 64-bit code segment. For any other type of segment, it should be 0.


typedef uint64_t gdt_entry;

struct gdt_ptr{
    uint16_t limit;
    unsigned int base;
}__attribute__((packed));

void init_gdt();

void set_gdt_gate
(
    uint32_t num, 
    uint32_t base, 
    uint32_t limit,
    uint8_t access,
    uint8_t gran
);



