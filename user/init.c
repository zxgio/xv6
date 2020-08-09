// init: The initial user-level program

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

char *argv[] = { "sh", 0 };

int main(void)
{
	int pid, wpid;
	const char *const console = "console";

	if (open(console, O_RDONLY) < 0) {
		mknod(console, 1, 1);
		open(console, O_RDONLY);
	}
	open(console, O_RDWR); // stdout
	dup(1); // stderr

	for (;;) {
		printf(1, "\n"
			"-----------------------------------------\n"
			"xv6 SETI built on " __DATE__ " at " __TIME__ "\n"
			"-----------------------------------------\n"
			"\ninit: starting sh\n");
		pid = fork();
		if (pid < 0) {
			printf(1, "init: fork failed\n");
			exit();
		}
		if (pid == 0) {
			exec("sh", argv);
			printf(1, "init: exec sh failed\n");
			exit();
		}
		while ((wpid = wait()) >= 0 && wpid != pid)
			printf(1, "zombie!\n");
	}
}
