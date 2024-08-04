ASM=nasm
CC=gcc
CC_FLAGS=-m32 -fno-stack-protector -fno-builtin -c
DEBUG_FLAGS= -g 
LD=ld

SRC_DIR=src
BUILD_DIR=build
GRUB_FILES_DIR=LiuOS

QEMU=qemu-system-i386

OS_IMG=$(BUILD_DIR)/LiuOS.iso

KERNEL_OBJ=kernel.o
VGA_OBJ=vga.o
GDT_OBJ=gdt.o
IDT_OBJ=idt.o
DRV_OBJ=drivers.o

GDTS_OBJ=gdts.o
IDTS_OBJ=idts.o
BOOT_OBJ=boot.o

STRING_OBJ=string.o

all: clean $(OS_IMG)
KERNEL_SRC_LIST=$(SRC_DIR)/kernel.c $(SRC_DIR)/vga.c $(SRC_DIR)/gdt.c $(SRC_DIR)/ldt.c $(SRC_DIR)/libc/string.c
OBJ_LIST= $(BUILD_DIR)/$(BOOT_OBJ) $(BUILD_DIR)/$(KERNEL_OBJ) $(BUILD_DIR)/$(VGA_OBJ) $(BUILD_DIR)/$(GDT_OBJ) $(BUILD_DIR)/$(GDTS_OBJ) $(BUILD_DIR)/$(IDT_OBJ) $(BUILD_DIR)/$(IDTS_OBJ) $(BUILD_DIR)/$(STRING_OBJ) $(BUILD_DIR)/$(DRV_OBJ)

$(OS_IMG): kernel_objs boot_objs
	rm -rf $(BUILD_DIR)/$(GRUB_FILES_DIR)
	cp -r $(SRC_DIR)/$(GRUB_FILES_DIR) $(BUILD_DIR)
	$(LD) -m elf_i386 -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/$(GRUB_FILES_DIR)/boot/kernel $(OBJ_LIST)
	grub-mkrescue -o $(OS_IMG) $(BUILD_DIR)/$(GRUB_FILES_DIR)

kernel_objs: $(SRC_DIR)/kernel.c $(SRC_DIR)/vga.c $(SRC_DIR)/gdt.c
	$(CC) $(CC_FLAGS) $(SRC_DIR)/kernel.c -o $(BUILD_DIR)/$(KERNEL_OBJ)
	$(CC) $(CC_FLAGS) $(SRC_DIR)/vga.c -o $(BUILD_DIR)/$(VGA_OBJ)
	$(CC) $(CC_FLAGS) $(SRC_DIR)/gdt.c -o $(BUILD_DIR)/$(GDT_OBJ)
	$(CC) $(CC_FLAGS) $(SRC_DIR)/idt.c -o $(BUILD_DIR)/$(IDT_OBJ)
	$(CC) $(CC_FLAGS) $(SRC_DIR)/libc/string.c -o $(BUILD_DIR)/$(STRING_OBJ)
	$(CC) $(CC_FLAGS) $(SRC_DIR)/drivers.c -o $(BUILD_DIR)/$(DRV_OBJ)

boot_objs: $(SRC_DIR)/boot.s $(SRC_DIR)/gdt.s
	$(ASM) -f elf32 $(SRC_DIR)/boot.s -o $(BUILD_DIR)/$(BOOT_OBJ)
	$(ASM) -f elf32 $(SRC_DIR)/gdt.s -o $(BUILD_DIR)/$(GDTS_OBJ)
	$(ASM) -f elf32 $(SRC_DIR)/idt.s -o $(BUILD_DIR)/$(IDTS_OBJ)


clean:
	rm -rf $(BUILD_DIR)/*

run:
	$(QEMU) $(OS_IMG)


debug: CC_FLAGS += $(DEBUG_FLAGS)
debug: all

run_debug:
	$(QEMU) -s -S $(OS_IMG)