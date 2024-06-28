ASM=nasm
CC=gcc
LD=ld

SRC_DIR=src/
BUILD_DIR=build/

QEMU=qemu-system-i386

OS_IMG=$(BUILD_DIR)/LiuOS.iso

KERNEL_OBJ=$(BUILD_DIR)/kernel.o
BOOT_OBJ=$(BUILD_DIR)/boot.o

all: clean $(OS_IMG)

$(OS_IMG): $(KERNEL_OBJ)
	rm -rf $(BUILD_DIR)/Liu
	cp -r Liu $(BUILD_DIR)
	$(LD) -m elf_i386 -T linker.ld -o $(BUILD_DIR)/Liu/boot/kernel $(BOOT_OBJ) $(KERNEL_OBJ)
	grub-mkrescue -o $(OS_IMG) $(BUILD_DIR)/Liu

$(KERNEL_OBJ): $(BOOT_OBJ) kernel.c
	$(CC) -m32 -fno-stack-protector -fno-builtin -c kernel.c -o $(KERNEL_OBJ)

$(BOOT_OBJ): boot.s
	$(ASM) -f elf32 boot.s -o $(BOOT_OBJ)

clean:
	rm -rf $(BUILD_DIR)/*

run:
	$(QEMU) $(OS_IMG)