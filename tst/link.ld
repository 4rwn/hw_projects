OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  RAM (rw) : ORIGIN = 0x00000000, LENGTH = 4K

  ROM (rx)  : ORIGIN = 0x10000000, LENGTH = 1K
}

_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  .inputs 0x00000000 : 
  {
    KEEP(*(.inputs))
  } > RAM

  .data : { *(.data*) }   > RAM
  .bss  : { *(.bss*)  }   > RAM

  .text   : { *(.text*)   } > ROM
  .rodata : { *(.rodata*) } > ROM
}
