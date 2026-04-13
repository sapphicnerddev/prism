#
# Prism Makefile
#
# Linker files live in $(shell pwd)/source/arch/(cpu_arch)/linker.ld
#

############ Config Flags ############

# The arch will determine the compilers used and what qemu target to use
# for emulation. Arm64 (AKA: aarch64) is the default, the listed arches are
# supported, everything else is untested and likely will NOT COMPILE.
# - aarch64
# - riscv64
# - x86_64
# - powerpc
# - x86
#
# Note that x86 will use your builtin compiler with -m32, assuming you're on
# standard x86_64 hardware. If not... this Makefile may need edits.
ARCH ?= aarch64

# Don't ever touch this unless you want to break everything.
SRC_ROOT := $(shell pwd)/source

############ Compiler Selection ############

ifeq ($(ARCH), aarch64)
    CC      = aarch64-linux-gnu-gcc
    AS      = aarch64-linux-gnu-as
    LD      = aarch64-linux-gnu-ld
    OBJCOPY = aarch64-linux-gnu-objcopy
    QEMU    = qemu-system-aarch64
    QEMU_FLAGS = -M virt -cpu cortex-a53 -m 256M -serial stdio -display gtk \
                -bios /usr/share/edk2/aarch64/QEMU_EFI.fd -device virtio-gpu
else ifeq ($(ARCH), x86_64)
    CC      = x86_64-linux-gnu-gcc
    AS      = x86_64-linux-gnu-as
    LD      = x86_64-linux-gnu-ld
    OBJCOPY = x86_64-linux-gnu-objcopy
    QEMU    = qemu-system-x86_64
    QEMU_FLAGS = -m 256M -serial stdio -display gtk -device virtio-gpu
else ifeq ($(ARCH), x86)
    CC      = gcc -m32
    AS      = as --32
    LD      = ld -m elf_i386
    OBJCOPY = objcopy
    QEMU    = qemu-system-i386
    QEMU_FLAGS = -m 256M -serial stdio -display gtk -device virtio-gpu
else ifeq ($(ARCH), riscv64)
    CC      = riscv64-linux-gnu-gcc
    AS      = riscv64-linux-gnu-as
    LD      = riscv64-linux-gnu-ld
    OBJCOPY = riscv64-linux-gnu-objcopy
    QEMU    = qemu-system-riscv64
    QEMU_FLAGS = -M virt -m 256M -serial stdio -display gtk -device virtio-gpu
else ifeq ($(ARCH), powerpc)
    CC      = powerpc-unknown-linux-gnu-gcc
    AS      = powerpc-unknown-linux-gnu-as
    LD      = powerpc-unknown-linux-gnu-ld
    OBJCOPY = powerpc-unknown-linux-gnu-objcopy
    QEMU    = qemu-system-ppc
    QEMU_FLAGS = -M mac99 -m 256M -serial stdio -display gtk -device virtio-gpu
else
    $(error Unsupported ARCH: $(ARCH). See Makefile for supported targets.)
endif

############ Compiler flags ############

# Intentionally quite lengthy, specific and pedantic because this is a kernel.
# A kernel and OS shouldn't really break, especially in production. So these
# flags were chosen for the explicit purpose of nuking most bugs from orbit
# before they even see the CI processes on GitHub.
CFLAGS_COMMON := \
	-ffreestanding -fno-stack-protector -fno-pie -fno-pic \
	-fno-omit-frame-pointer -fno-builtin -fno-common \
	-nostdinc -std=gnu11 -Wall -Wextra -Wshadow -Wcast-align \
	-Wpointer-arith -Wwrite-strings -Wredundant-decls -Wnested-externs \
	-Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations \
	-Werror=implicit-function-declaration -Werror=return-type \
	-Werror=implicit-int -Werror=incompatible-pointer-types \

# Per CPU arch flags -- since registers vary and you know, other stuff
ifeq ($(ARCH), aarch64)
	CFLAGS_ARCH := -mgeneral-regs-only
else ifeq ($(ARCH), x86_64)
	CFLAGS_ARCH := -mno-sse -mno-sse2 -mno-mmx -mno-3dnow -mno-avx -mno-avx2
else ifeq ($(ARCH), x86)
	CFLAGS_ARCH := -mno-sse -mno-sse2 -mno-mmx -mno-3dnow -march=i686
else ifeq ($(ARCH), riscv64)
	CFLAGS_ARCH := -mno-relax -march=rv64imac -mabi=lp64
else ifeq ($(ARCH), powerpc)
	CFLAGS_ARCH := -mno-altivec -mno-vsx -msoft-float
endif

############ Sources and automagical source finding ############

SRCS := $(shell find $(SRC_ROOT)/kernel $(SRC_ROOT)/arch/$(ARCH) $(SRC_ROOT)/drivers \
            -name "*.c")
ASMS := $(shell find $(SRC_ROOT)/arch/$(ARCH) \
            -name "*.S")
OBJS := $(SRCS:.c=.o) $(ASMS:.S=.o)

INCLUDES := \
    -I$(SRC_ROOT)/include \
    -I$(SRC_ROOT)/arch/$(ARCH)/include \
    -Ilimine/include

############ Targets ############

KERNEL = prism-$(ARCH).elf

all: $(KERNEL)

$(KERNEL): $(OBJS)
	$(LD) $(LDFLAGS) -T $(SRC_ROOT)/arch/$(ARCH)/linker.ld -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS_COMMON) $(CFLAGS_ARCH) $(INCLUDES) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS_COMMON) $(CFLAGS_ARCH) $(INCLUDES) -c $< -o $@

clean:
	find $(SRC_ROOT) -name "*.o" -delete
	rm -f $(KERNEL)
	rm -f *.iso
	rm -rf iso_root

############ Image ISO and running qemu ############

IMAGE = prism-$(ARCH)-unstable.iso

image: $(KERNEL)
	mkdir -p iso_root/boot/limine
	cp $(KERNEL) iso_root/boot/
	printf 'timeout: 3\n\n/Prism ($(ARCH))\n\tprotocol: limine\n\tkernel_path: boot():/boot/prism-$(ARCH).elf\n' \
		> iso_root/boot/limine/limine.conf
	cp limine/limine-bios.sys limine/limine-bios-cd.bin \
       limine/limine-uefi-cd.bin iso_root/boot/limine/
	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 \
        -boot-info-table --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        iso_root -o $(IMAGE)
	./limine/limine bios-install $(IMAGE)
	rm -rf iso_root

run: image
	$(QEMU) $(QEMU_FLAGS) -cdrom $(IMAGE)