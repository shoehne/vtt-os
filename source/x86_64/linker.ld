ENTRY (start)

SECTIONS {

    . = 0x100000;

    .multiboot_header {
        KEEP(*(.multiboot_header))
    }

    .text {
        *(.text)
    }

    .bss {
        *(.bss)
    }
}
