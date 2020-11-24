#include "user/user.h"

void foo()
{
	asm(
	".intel_syntax noprefix;"
	"	push 0x11111111;"
	"	push 0x22222222;"
	"	push 0x33333333;"
	"	mov eax, 0xc0ffe;"
	"	mov ebx, 1;"
	".loop: add ebx, 2;"
	"	jmp .loop;"
	".att_syntax;"
	);

}

int main()
{
	foo();
}
