# Initial process execs /init.
# This code runs in user space.

#include "syscall.h"
#include "traps.h"

.intel_syntax noprefix

# exec(init, argv)
.globl start
start:
  push offset argv
  push offset init
  push 0  // where caller pc would be
  mov eax, SYS_exec
  int T_SYSCALL

# for(;;) exit();
exit:
  mov eax, SYS_exit
  int T_SYSCALL
  jmp exit

# char init[] = "/init\0";
init:
  .string "/init\0"

# char *argv[] = { init, 0 };
.p2align 2
argv:
  .long init
  .long 0
