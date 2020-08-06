# Context switch
#
#   void swtch(struct context **old, struct context *new);
#
# Save the current registers on the stack, creating
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.intel_syntax noprefix
.globl swtch
swtch:
  mov eax, [esp+4]
  mov edx, [esp+8]

  # Save old callee-saved registers
  push ebp
  push ebx
  push esi
  push edi

  # Switch stacks
  mov [eax], esp
  mov esp, edx

  # Load new callee-saved registers
  pop edi
  pop esi
  pop ebx
  pop ebp
  ret
