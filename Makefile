#
# Prism Makefile
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

############ Compiler Selection ############

ifeq ($(ARCH), aarch64)
    CC      = aarch64-linux-gnu-gcc
    AS      = aarch64-linux-gnu-as
    LD      = aarch64-linux-gnu-ld
    OBJCOPY = aarch64-linux-gnu-objcopy
    QEMU    = qemu-system-aarch64
    QEMU_FLAGS = -M virt -cpu cortex-a53 -m 256M -serial stdio
else ifeq ($(ARCH), x86_64)
    CC      = x86_64-linux-gnu-gcc
    AS      = x86_64-linux-gnu-as
    LD      = x86_64-linux-gnu-ld
    OBJCOPY = x86_64-linux-gnu-objcopy
    QEMU    = qemu-system-x86_64
    QEMU_FLAGS = -m 256M -serial stdio
else ifeq ($(ARCH), x86)
    CC      = gcc -m32
    AS      = as --32
    LD      = ld -m elf_i386
    OBJCOPY = objcopy
    QEMU    = qemu-system-i386
    QEMU_FLAGS = -m 256M -serial stdio
else ifeq ($(ARCH), riscv64)
    CC      = riscv64-linux-gnu-gcc
    AS      = riscv64-linux-gnu-as
    LD      = riscv64-linux-gnu-ld
    OBJCOPY = riscv64-linux-gnu-objcopy
    QEMU    = qemu-system-riscv64
    QEMU_FLAGS = -M virt -m 256M -serial stdio
else ifeq ($(ARCH), powerpc)
    CC      = powerpc-unknown-linux-gnu-gcc
    AS      = powerpc-unknown-linux-gnu-as
    LD      = powerpc-unknown-linux-gnu-ld
    OBJCOPY = powerpc-unknown-linux-gnu-objcopy
    QEMU    = qemu-system-ppc
    QEMU_FLAGS = -M mac99 -m 256M -serial stdio
else
    $(error Unsupported ARCH: $(ARCH). See Makefile for supported targets.)
endif

############ Compiler flags ############

CFLAGS_COMMON := \
	-ffreestanding -fno-stack-protector -fno-pie -fno-pic \
	-fno-omit-frame-pointer -fno-builtin -fno-common \
	-nostdinc -std=gnu11 -Wall -Wextra -Wshadow -Wcast-align \
	-Wpointer-arith -Wwrite-strings -Wreduncant-decls -Wnested-externs \
	-Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations \
	-Werror=implicit-function-declaration -Werror=return-type \
	-Werror=implicit-int -Werror=incompatible-pointer-types \

# Per CPU arch flags -- since registers vary and you know, other stuff
ifeq ($(ARCH), aarch64)
	CFLAGS_ARCH := -mno-neon
else ifeq ($(ARCH), x86_64)
	CFLAGS_ARCH := -mno-sse -mno-sse2 -mno-mmx -mno-3dnow -mno-avx -mno-avx2
else ifeq ($(ARCH), x86)
	CFLAGS_ARCH := -mno-sse -mno-sse2 -mno-mmx -mno-3dnow -march=i686
else ifeq ($(ARCH), riscv64)
	CFLAGS_ARCH := -mno-relax -march=rv64imac -mabi=lp64
else ifeq ($(ARCH), powerpc)
	CFLAGS_ARGS := -mno-altivec -mno-vsx -msoft-float
endif

############ Sources and automagical source finding ############

SRCS := $(shell find prism/kernel prism/arch/$(ARCH) prism/drivers \
            -name "*.c")
ASMS := $(shell find prism/arch/$(ARCH) \
            -name "*.S")
OBJS := $(SRCS:.c=.o) $(ASMS:.S=.o)