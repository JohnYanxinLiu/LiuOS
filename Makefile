# PATH="$$HOME/opt/cross/bin"
ASM=$(PATH)/i686-elf-as
CC=$(PATH)/i686-elf-gcc
# G++=$(PATH)/i686-elf-g++
QEMU=qemu-system-i386

SRC_DIR=src
BUILD_DIR=build

ISO_DIR=$(BUILD_DIR)/isodir
OS_IMG=$(BUILD_DIR)/liuos.iso
KERNEL_OBJ=$(BUILD_DIR)/liuos.bin
BOOT_OBJ=$(BUILD_DIR)/boot.o

$(OS_IMG): $(KERNEL_OBJ)
	mkdir -p $(ISO_DIR)/boot/grub
	mv $(KERNEL_OBJ) $(ISO_DIR)/boot/liuos.bin
	cp $(SRC_DIR)/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o liuos.iso isodir	

$(KERNEL_OBJ): $(SRC_DIR)/kernel.c $(BOOT_OBJ)
	$(CC) $(SRC_DIR)/kernel.c -c -o $(BUILD_DIR)/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	$(CC) -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/liuos.bin -ffreestanding -O2 -nostdlib $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o -lgcc
# Rule to compile c++ kernel
# $(G++) -c $(SRC_DIR)/kernel.c++ -o $(BUILD_DIR)/kernel.o -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

$(BOOT_OBJ): $(SRC_DIR)/boot.s
	$(ASM) $(SRC_DIR)/boot.s -o $(BUILD_DIR)/boot.o

clean:

	rm -rf $(BUILD_DIR)/*

run:
	$(QEMU) -cdrom $(BUILD_DIR)/liuos.iso
