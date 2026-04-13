/* Prism - aarch64 CPU operations */

#pragma once

static inline void cpu_halt(void) {
    __asm__ volatile("wfe");
}

static inline void cpu_disable_interrupts(void) {
    __asm__ volatile("msr daifset, #0xf");
}

static inline void cpu_enable_interrupts(void) {
    __asm__ volatile("msr daifclr, #0xf");
}