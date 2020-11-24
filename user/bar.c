#include "user/user.h"

void bar()
{
	asm(
	".intel_syntax noprefix;"
	"	push 0xaaaaaaaa;"
	"	push 0xaaaaaaaa;"
	"	push 0xaaaaaaaa;"
	"	mov eax, 0xbadc0de;"
	"	xor ebx, ebx;"
	".loop: add ebx, 2;"
	"	jmp .loop;"
	".att_syntax;"
	);
}

int main()
{
	bar();
}
