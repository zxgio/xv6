#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
	char *buf = (char *)(argc - 1);
	buf[0] = 'a';
	exit();
}
