; Declare the Multiboot2 header to mark this code as a kernel with the section directive. 
; The long/doubleword values are all magic numbers documented in the Multiboot Standard. 
; The bootloader (e.g. GRUB) will search for this signature in the first 32 KiB of a kernel
; file. It is aligned at a 8-byte/64-bit boundary (the next byte allocation in memory 
; divisible by 8).
section .multiboot_header
align 8
header_start:
    dd 0xe85250d6 ; magic number defining multiboot2
    dd 0 ; architecture (0 = i386 => 32-bit)
    dd header_end - header_start ; header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; Checksum

    ; End tag (type = 0, flags = 0, size = 8)
    dw 0
    dw 0
    dw 8
header_end:

; The kernel has to provide a stack and the value of the stack pointer register (rps on 
; 64-bit and esp on 32-bit systems).
; Define a .bss section which is allocated but not yet initialised memory. The section is
; aligned at a 16-byte boundary.
; Create a symbol at the bottom of the stack, allocating 16384 bytes (16 KiB) and then 
; create a symbol at the top. On x86 the stack grows downwards.
; The stack must be 16-byte aligned according to the System V ABI standard and extensions.
; The Compiler will assume that the stack is properly aligned and failure to do so will
; result in undefined behaviour.
section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

; The linker script specifies _start as the entry point to the kernel and the bootloader
; will jump to this position once the kernel is loaded. Returning from this function
; doesn't make sense because at this point the bootloader is gone
; The .text section contains executable assembly code (in this case the _start function).
; With the .global (.globl) directive we tell the linker that _start is globally visible.
; The .type directive specifies the type of a symbol (_start), prefixed with '@'. Possible
; types are:
; - function
; - object: indicates a data object (e.g. a variable)
; - notype: indicates the symbol has no specific type
section .text
global start
start:
    ; The bootloader loaded into 32-bit protected mode on a x86 machine. Interrupts are disabled.
    ; Paging is disabled and the processor is as defined in the Multiboot standard. The kernel now
    ; is in full control of the CPU and is only able to make use of hardware features and any code
    ; it provides as part of itself. There is no printf function (unless the kernel provides its
    ; own <stdio.h> and a printf implementation. There are no security restrictions, no safeguards
    ; and no debugging mechanisms. The kernel has absolute and complete power over the machine.

    ; Setting up a stack requires the setting of the esp register (rsp on 64-bit) and have it point
    ; to the top of the stack (stack on x86 grows downwards). This has to be done in assembly 
    ; because languages such as C cannot function without a stack.
    ; The mov operator moves a source to a destination (AT&T syntax, Intel syntax does it the 
    ; opposite way). The source is prefixed with '$' and the destination with '%'.
    mov rsp, stack_top

    ; This is a good place to initialise crucial processor state before the high-level kernel
    ; is entered. As of this point the processor is not fully initialised yet: Features such
    ; as floating point instructions and instruction set extensions are not available yet. The
    ; GDT should be loaded and paging should be enabled here. C++ features such as global 
    ; constructors and exceptions will require runtime support to work as well

    ; Enter the high-level kernel. The ABI requires the stack 16-byte aligned at the time of
    ; the call instruction (which afterwards pushes the return pointer of size 4 bytes). 
    ; Originally the stack was 16-byte aligned above and a multiple of 16-bytes have been 
    ; pushed to the stack since (0 bytes so far). The alignment has thus been preserved the 
    ; call is well defined.
    call kernel_main

    cli

.hang:  
    hlt
    jmp .hang

global kernel_main
kernel_main:
    ; Print 'OK' to VGA text buffer
    mov dword [0xb8000], 0x2f4b2f4f
    ret
