# Prism

Prism is an experimental, modern POSIX-like operating system built for resource constrained i386, x64, aarch64, riscv64, and PowerPC architectures.

This OS is experimental and not stable, functionality across broad swaths of hardware is not ensured. The project is implemented in C with some portions of the code written in Assembly (which is required to support multiple architectures) where needed. Contributions in languages like Rust or C++ will likely not be accepted into this project at the time.

## The Kernel

The Prism kernel (sometimes just called the Kernel or PKernel) is a monolithic, generic C kernel, based heavily off of existing OSdev projects, which I've listed here:
 - [cavOS by MalwarePad](https://github.com/malwarepad/cavOS)
 - [LemonOS by the LemonOS Project](https://github.com/LemonOSProject/LemonOS)
 - [SerenityOS by Andreas Kling + Many More](https://github.com/SerenityOS/serenity)

Serenity by far is my largest inspiration, as it captures a specific vibe and aesthetic that I've been drawn to since the Windows XP days. Much like Serenity, this is a personal love letter to past UI/UX with a POSIX core. This kernel isn't going to be perfectly POSIX compliant, most of the heavy lifting is already being done in Linux, this kernel is just... working off of its syscall interfaces and general ABI for software porting.

## UI / UX

The design language of this project once again follows Serenity in heart. The end of the Windows 9x days, possibly early Windows XP (without its iconic Luna theme), just with my own personal flair and tiny changes.

## Building

> [!TIP]
> Unfinished for now.