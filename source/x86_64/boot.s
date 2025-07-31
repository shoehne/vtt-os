.set ALIGN, 1<<0 /* align loaded modules on page boundaries */
.set MEMINFO 1<<1 /* provide memory map */
.set FLAGS, ALIGN | MEMINFO */ Multiboot 'flag' field */
.set MAGIC, 0x1BADB002 /* Weirdly enough a magic number makes sense here 
                        to let the bootloader find the header */
.set CHECKSUM, -(MAGIC + FLAGS) /* Checksum of MAGIC & FLAGS, to prove we are multiboot */
