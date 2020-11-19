#include "user/user.h"

int main()
{
	asm(
	".intel_syntax noprefix;"
	"	mov eax, 0xc0ffe;"
	"	mov ebx, 1;"
	".loop: add ebx, 2;"
	"	jmp .loop;"
	".att_syntax;"
	);
}
