#include "asm.h"
#include "memlayout.h"
#include "mmu.h"

# Start the first CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

.intel_syntax noprefix

.code16                       # Assemble for 16-bit mode
.globl start
start:
  cli                         # BIOS enabled interrupts; disable

  # Zero data segment registers DS, ES, and SS.
  xor ax,ax             # Set ax to zero
  mov ax,ds             # -> Data Segment
  mov ax,es             # -> Extra Segment
  mov ax,ss             # -> Stack Segment

  # Physical address line A20 is tied to zero so that the first PCs
  # with 2 MB would run software that assumed 1 MB.  Undo that.
seta20.1:
  in al, 0x64                     # Wait for not busy
  test al, 2
  jnz     seta20.1

  mov al, offset 0xd1             # 0xd1 -> port 0x64
  outb 0x64, al

seta20.2:
  in al, 0x64                     # Wait for not busy
  test al, 2
  jnz     seta20.2

  mov al, offset 0xdf             # 0xdf -> port 0x60
  out 0x60, al

  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  lgdt    gdtdesc
  mov eax, cr0
  or eax, offset CR0_PE
  mov cr0, eax

  # Complete the transition to 32-bit protected mode by using a long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
  jmp far ptr (SEG_KCODE<<3) : start32

.code32  # Tell assembler to generate 32-bit code now.
start32:
  # Set up the protected-mode data segment registers
  mov ax, offset (SEG_KDATA<<3)   # Our data segment selector
  mov ds, ax                      # -> DS: Data Segment
  mov es, ax                      # -> ES: Extra Segment
  mov ss, ax                      # -> SS: Stack Segment
  mov ax, offset 0                # Zero segments not ready for use
  mov fs, ax                      # -> FS
  mov gs, ax                      # -> GS

  # Set up the stack pointer and call into C.
  mov esp, offset start
  call bootmain

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp     spin

# Bootstrap GDT
.p2align 3                                # force 8 byte alignment
gdt:
  SEG_NULLASM                             # null seg
  SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
  SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg

gdtdesc:
  .word   (gdtdesc - gdt - 1)             # sizeof(gdt) - 1
  .long   gdt                             # address gdt
