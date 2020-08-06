#include "mmu.h"

.intel_syntax noprefix

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  push ds
  push es
  push fs
  push gs
  pusha

  # Set up data segments.
  mov ax, offset (SEG_KDATA<<3)
  mov ds, ax
  mov es, ax

  # Call trap(tf), where tf=%esp
  push esp
  call trap
  add esp, 4

  # Return falls through to trapret...
.globl trapret
trapret:
  popa
  pop gs
  pop fs
  pop es
  pop ds
  add esp, 8 # trapno and errcode
  iret
