#include "user/user.h"

int main()
{
	asm(
	".intel_syntax noprefix;"
	"	mov eax, 0xbadc0de;"
	"	xor ebx, ebx;"
	".loop: add ebx, 2;"
	"	jmp .loop;"
	".att_syntax;"
	);
}
