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
global Start
Start:
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

    call CheckCpuid

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
    call KernelMain

    cli

.hang:  
    hlt
    jmp .hang

global kernel_main
KernelMain:
    ; Print 'OK' to VGA text buffer
    mov dword [0xb8000], 0x2f4b2f4f
    ret

; Check if CPUID is supported
%include "../source/x86_64/eflags.asm" 
CheckCpuid:
    pushfd ; Push the flags register onto the stack
    pop eax ; Pop the flags register into the eax register which is a 32-bit subregister
            ; of the rax 64-bit general purpose register

    ; The mov instruction copies a value from one memory register into another.
    ; The flags register stored in the eax register is copied into the ecx register for 
    ; comparison with the flipped value in eax (flipping the value of the 21st bit by
    ; XOR with Eflags.cpu_id).
    mov ecx, eax
    xor eax, Eflags.cpu_id

    ; Push eax back onto the stack, pop the value pushed onto the stack into the flags
    ; register. Then load the flags register into the stack again and store the topmost 
    ; stack entry in the eax register again. To restore the flags register to its original 
    ; state (we only want to check if the CPUID bit is flippable but don't want to 
    ; actually store its flipped value in the flags register) the value in the ecx register
    ; (the original value of the CPUID bit in the flags register) gets pushed onto the 
    ; stack and then the stack entry gets popped into the flags register again. After that 
    ; the values in ecx and eax can be compared and if they're equal we know that CPUID is not
    ; supported on the current system.
    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd

    cmp eax, ecx
    je .no_cpu_id
    ret
.no_cpu_id:
    mov byte al, "C"
    jmp Error

Error:
    ; Print "ERR: X" where X is the "error byte" stored in al
    mov dword [0xb8000], 0x04520445
    mov dword [0xb8004], 0x044f0452
    mov dword [0xb8008], 0x04300452
    mov word [0xb800b], 0x0020
    mov byte [0xb800c], al
    hlt
