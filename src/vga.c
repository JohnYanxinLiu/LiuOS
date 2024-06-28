#include "include/vga.h"



uint16_t column = 0;
uint16_t line = 0;
uint16_t* const vga = (uint16_t* const) 0xB8000; //Address where video memory is stored.
const uint16_t defaultColor = (COLOR8_LIGHT_GREY << 8) | (COLOR8_BLACK << 12);
uint16_t currentColor = defaultColor;


void Reset()
{
    line = 0;
    column = 0;
    currentColor = defaultColor;
    for (uint16_t y = 0; y < height; y++)
    {
        for (uint16_t x = 0; x < width; x++)
        {
            vga[y * width + x] = ' ' | defaultColor;
        }
    }
}

void scrollUp()
{
    for (uint16_t y = 1; y < height; y++)
    {
        for (uint16_t x = 0; x < width; x++)
        {
            vga[(y - 1) * width + x] = vga[y * width + x];
        }
    }

    uint16_t y = height - 1;
    for (uint16_t x = 0; x < width; x++)
    {
        vga[y * width + x] = currentColor;
    }

    column = 0;
}

void newLine()
{
    if(line < height -1)
    {
        line++;
    }
    else 
    {
        scrollUp();
    }

    column = 0;
}


void print(const char* s)
{
    while(*s)
    {
        switch(*s)
        {
            case '\n':
                newLine();
                break;
            case '\r':
                column = 0;
                break;
            case '\t':
                if (column == width)
                {
                    newLine();
                }
                
                uint16_t tabLen = 4 - (column % 4);
                if (tabLen + column > width - 1)
                {
                    tabLen = width - 1 - column;
                }
                while (tabLen != 0)
                {
                    vga[line * width + column] = ' ' | defaultColor;
                    column++;
                    tabLen--;
                }
                break;
            default:
                if (column == width)
                {
                    newLine();
                }

                vga[line * width + (column++)] = *s | currentColor;
                break;
        }
        s++;
    }
}
