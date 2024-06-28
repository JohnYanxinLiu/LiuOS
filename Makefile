ASM=nasm
CC=gcc
LD=ld

SRC_DIR=src
BUILD_DIR=build
GRUB_FILES_DIR=LiuOS

QEMU=qemu-system-i386

OS_IMG=$(BUILD_DIR)/LiuOS.iso

KERNEL_OBJ=$(BUILD_DIR)/kernel.o
VGA_OBJ=$(BUILD_DIR)/vga.o
BOOT_OBJ=$(BUILD_DIR)/boot.o

all: clean $(OS_IMG)

$(OS_IMG): $(KERNEL_OBJ) $(VGA_OBJ) $(BOOT_OBJ)
	rm -rf $(BUILD_DIR)/$(GRUB_FILES_DIR)
	cp -r $(SRC_DIR)/$(GRUB_FILES_DIR) $(BUILD_DIR)
	$(LD) -m elf_i386 -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/$(GRUB_FILES_DIR)/boot/kernel $(BOOT_OBJ) $(KERNEL_OBJ) $(VGA_OBJ)
	grub-mkrescue -o $(OS_IMG) $(BUILD_DIR)/$(GRUB_FILES_DIR)

$(KERNEL_OBJ): $(SRC_DIR)/kernel.c
	$(CC) -m32 -fno-stack-protector -fno-builtin -c $(SRC_DIR)/kernel.c -o $(KERNEL_OBJ)

$(VGA_OBJ): $(SRC_DIR)/vga.c
	$(CC) -m32 -fno-stack-protector -fno-builtin -c $(SRC_DIR)/vga.c -o $(VGA_OBJ)

$(BOOT_OBJ): $(SRC_DIR)/boot.s
	$(ASM) -f elf32 $(SRC_DIR)/boot.s -o $(BOOT_OBJ)

clean:
	rm -rf $(BUILD_DIR)/*

run:
	$(QEMU) $(OS_IMG)