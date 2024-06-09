SRC_DIR=src
BUILD_DIR=build


AS=i686-liuos-as
CC=i686-liuos-gcc
AR=i686-liuos-ar

QEMU=qemu-system-i686

OBJS:=foo.o bar.o

#Constructor Objects
CRTI_OBJ=crti.o
CRTBEGIN_OBJ:=$(shell $(CC) $(CFLAGS) -print-file-name=crtbegin.o)
CRTEND_OBJ:=$(shell $(CC) $(CFLAGS) -print-file-name=crtend.o)
CRTN_OBJ=crtn.o
 
OBJ_LINK_LIST:=$(CRTI_OBJ) $(CRTBEGIN_OBJ) $(OBJS) $(CRTEND_OBJ) $(CRTN_OBJ)
INTERNAL_OBJS:=$(CRTI_OBJ) $(OBJS) $(CRTN_OBJ)

OS_IMG=$(BUILD_DIR)/liuos.iso
LIBC_A=$(BUILD_DIR)/libc.a


LIBC_DIR=sysroot/usr/libc

LIBC_SRC_FILES:=$(wildcard $(SRC_DIR)/$(LIBC_DIR)/**/*.c)

LIBC_OBJS:=$(patsubst $(SRC_DIR)/$(LIBC_DIR)/%.c,$(BUILD_DIR)/libc/%.o,$(LIBC_SRC_FILES))


all: $(OS_IMG) $(LIBC_A)


$(LIBC_A): $(LIBC_OBJS)
	$(AS) $(SRC_DIR)/constructors/crt0.s -o $(BUILD_DIR)/crt0.o
	$(AR) rcs $(LIBC_A) $(LIBC_OBJS) $(BUILD_DIR)/crt0.o

# Rule to compile each source file into object files
$(BUILD_DIR)/libc/%.o: $(SRC_DIR)/$(LIBC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@


BOOT_OBJ=$(BUILD_DIR)/boot.o
$(BOOT_OBJ): $(SRC_DIR)/boot/boot.s
	$(AS) $(SRC_DIR)/boot/boot.s -o $(BUILD_DIR)/boot.o

KERNEL_OBJ=$(BUILD_DIR)/liuos.bin
$(KERNEL_OBJ):  $(BOOT_OBJ) $(SRC_DIR)/kernel/kernel.c
	$(CC) $(SRC_DIR)/kernel/kernel.c -c -o $(BUILD_DIR)/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	$(CC) -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/liuos.bin -ffreestanding -O2 -nostdlib $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o

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

