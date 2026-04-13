#include <arch/aarch64/cpu.h>

void _kernel_start(void) {
    for(;;) cpu_halt();
}