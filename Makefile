ASM=nasm

SRC_DIR=src
BUILD_DIR=build

QEMU=qemu-system-i386

FLOPPY_IMG=$(BUILD_DIR)/main_floppy.img

$(FLOPPY_IMG): $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(FLOPPY_IMG)
	truncate -s 1440k $(FLOPPY_IMG)


$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin


clean:
	rm -f $(BUILD_DIR)/*


run:
	$(QEMU) -fda $(FLOPPY_IMG)
