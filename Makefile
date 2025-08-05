# Cross Compiler
CC := x86_64-elf-gcc

# Paths
PREMAKE_DIR := build
ISO_DIR := iso
ISO_BOOT := $(ISO_DIR)/boot
ISO_GRUB := $(ISO_BOOT)/grub
ISO_IMAGE := $(ISO_DIR)/vtt-os.iso

# Kernel Binaries
DEBUG_AMD64_BIN := ./bin/debug-x86_64/Vtt-Kernel-x86_64.bin
RELEASE_AMD64_BIN := ./bin/release-x86_64/Vtt-Kernel-x86_64.bin

# Build targets
# Default
all: debug-amd64

# Debug x86_64
debug-amd64: $(DEBUG_AMD64_BIN)
	@mkdir -p $(ISO_GRUB)
	@cp $(DEBUG_AMD64_BIN) $(ISO_BOOT)/kernel.bin
	#@cp $(ISO_GRUB)/grub.cfg $(ISO_GRUB)/grub.cfg
	@grub-mkrescue -o $(ISO_IMAGE) $(ISO_DIR)

# Release x86_64
release-amd64: $(RELEASE_AMD64_BIN)
	@mkdir -p $(ISO_GRUB)
	@cp $(RELEASE_AMD64_BIN) $(ISO_BOOT)/kernel.bin
	#@cp $(ISO_GRUB)/grub.cfg $(ISO_GRUB)/grub.cfg
	@grub-mkrescue -o $(ISO_IMAGE) $(ISO_DIR)

# Build Kernel Binaries
# Debug x86_64
$(DEBUG_AMD64_BIN):
	@$(MAKE) -C $(PREMAKE_DIR) config=debug CC=$(CC)

# Release x86_64
$(RELEASE_AMD64_BIN):
	@$(MAKE) -C $(PREMAKE_DIR) config=release CC=$(CC)

# Run QEMU
run-debug-amd64: debug-amd64
	@qemu-system-x86_64 -cdrom $(ISO_IMAGE)

run-release-amd64: release-amd64
	@qemu-system-x86_64 -cdrom $(ISO_IMAGE)

# Clean
clean:
	@$(MAKE) -C $(PREMAKE_DIR) clean
	@rm -rf $(ISO_DIR)/boot/kernel.bin $(ISO_IMAGE)
	@echo Cleaning build artifacts
	@if exist build (rmdir /s /q build)
