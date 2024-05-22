#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef uint8_t bool;
#define true  1
#define false 2


typedef struct{
    
    //bpb
    uint8_t  jump_instruction[3];
    uint8_t  bpb_oem[8];
    uint16_t bytes_per_sector;
    uint8_t  sectors_per_cluster;
    uint16_t reserved_clusters;
    uint8_t  fat_count;
    uint16_t dirs;
    uint16_t sectors;
    uint8_t  media_descriptor;
    uint16_t sectors_per_fat;
    uint16_t sectors_per_track;
    uint16_t sides;
    uint32_t hidden_sectors;
    uint32_t large_sector_count;

    // ebr
    uint8_t  drive_number;
    uint8_t  windows_nt_flags;
    uint8_t  signature;
    uint8_t  volume_id[4];
    uint8_t  volume_label[11];
    uint8_t  sys_id_str[8];

} __attribute__((packed)) BootSector;

#define FILE_NAME_LENGTH 11

typedef struct 
{
    uint8_t name[FILE_NAME_LENGTH];
    uint8_t attributes;
    uint16_t _reserved;
    uint16_t creation_time;
    uint16_t creation_date;
    uint16_t last_access_date;
    uint16_t _ignored;
    uint16_t last_write_time;
    uint16_t last_write_date;
    uint16_t first_cluster_low;
    uint32_t size;                 //in bytes
} __attribute__((packed)) DirectoryEntry;




BootSector g_BootSector;
uint8_t* g_Fat = NULL;
DirectoryEntry* g_rootDirectory = NULL;

bool readBootSector(FILE *disk)
{
    return fread(&g_BootSector, sizeof(g_BootSector), 1, disk) > 0;
}


bool readSectors(FILE* disk, uint32_t lba, uint32_t count, void* bufferOut)
{
    bool success = true;
    success = success && (fseek(disk, lba * g_BootSector.bytes_per_sector, SEEK_SET) == 0);
    success = success && (fread(bufferOut, g_BootSector.bytes_per_sector, count, disk) == count);
    return success;
}

bool readFat(FILE* disk)
{
    g_Fat = (uint8_t*) malloc(g_BootSector.sectors_per_fat * g_BootSector.bytes_per_sector);
    return readSectors(disk, g_BootSector.reserved_clusters, g_BootSector.sectors_per_fat, g_Fat);
}

bool readRootDir(FILE* disk)
{
    uint32_t lba = g_BootSector.reserved_clusters + g_BootSector.fat_count * g_BootSector.sectors_per_fat;
    uint32_t size = sizeof(DirectoryEntry) * g_BootSector.dirs;
    uint32_t sectors = (size / g_BootSector.bytes_per_sector);
    
    if (size % g_BootSector.bytes_per_sector > 0)
        sectors++;
    
    g_rootDirectory = (DirectoryEntry*) malloc(sectors * g_BootSector.bytes_per_sector);

    return readSectors(disk, lba, sectors, g_rootDirectory);
}

DirectoryEntry *findFile (const char *file_name){
    
    for (uint32_t i = 0; i < g_BootSector.dirs; i++)
    {
        if (memcmp(file_name, g_rootDirectory[i].name, FILE_NAME_LENGTH) == 0) 
        {
            return &g_rootDirectory[i]; 
        }
    }
    return NULL;

}


int main(int argc, char **argv)
{
    if (argc < 3)
    {
        printf("Syntax: %s <disk image> <file name>\n", argv[0]);
        return -1;
    }

    FILE *disk = fopen(argv[1], "rb");
    if (!disk) 
    {
        fprintf(stderr, "Cannot open disk image %s", argv[1]);
        return -1;
    }

    if (!readBootSector(disk))
    {
        fprintf(stderr, "Could not read boot sector!\n");
        return -2;
    }

    if(!readFat(disk))
    {
        fprintf(stderr, "Could not read FAT!\n");
        free(g_Fat);
        return -3;
    }

    if(!readRootDir(disk))
    {
        fprintf(stderr, "Could not read dirs!\n");
        free(g_Fat);
        free(g_rootDirectory);
        return -4;
    }

    DirectoryEntry* file_entry = findFile(argv[2]);
    if (file_entry == NULL)
    {
        fprintf(stderr, "Could not find fiile %s!\n", argv[2]);
        free(g_Fat);
        free(g_rootDirectory);
        return -5;
    }

    fprintf(stderr, "Success! Found %s!\n", argv[2]);
    free (g_Fat);
    free(g_rootDirectory);
    return 0;
}