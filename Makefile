SRC_DIR=src
BUILD_DIR=build


ASM=i686-elf-as
CC=i686-elf-gcc

QEMU=qemu-system-i386


OBJS:=foo.o bar.o

#Constructor Objects
CRTI_OBJ=crti.o
CRTBEGIN_OBJ:=$(shell $(CC) $(CFLAGS) -print-file-name=crtbegin.o)
CRTEND_OBJ:=$(shell $(CC) $(CFLAGS) -print-file-name=crtend.o)
CRTN_OBJ=crtn.o
 
OBJ_LINK_LIST:=$(CRTI_OBJ) $(CRTBEGIN_OBJ) $(OBJS) $(CRTEND_OBJ) $(CRTN_OBJ)
INTERNAL_OBJS:=$(CRTI_OBJ) $(OBJS) $(CRTN_OBJ)

OS_IMG=$(BUILD_DIR)/liuos.iso



all: $(OS_IMG)

BOOT_OBJ=$(BUILD_DIR)/boot.o
$(BOOT_OBJ): $(SRC_DIR)/boot.s
	$(ASM) $(SRC_DIR)/boot.s -o $(BUILD_DIR)/boot.o


KERNEL_OBJ=$(BUILD_DIR)/liuos.bin
$(KERNEL_OBJ): $(SRC_DIR)/kernel.c $(BOOT_OBJ)
	$(CC) $(SRC_DIR)/kernel.c -c -o $(BUILD_DIR)/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	$(CC) -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/liuos.bin -ffreestanding -O2 -nostdlib $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o -lgcc


ISO_DIR=$(BUILD_DIR)/isodir
$(OS_IMG): $(KERNEL_OBJ)
	mkdir -p $(ISO_DIR)/boot/grub
	mv $(KERNEL_OBJ) $(ISO_DIR)/boot/liuos.bin
	cp $(SRC_DIR)/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(BUILD_DIR)/liuos.iso $(ISO_DIR)



run:
	$(QEMU) -cdrom $(BUILD_DIR)/liuos.iso


clean:
	rm -rf $(BUILD_DIR)/*

