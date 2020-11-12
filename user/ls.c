#include "user/user.h"
#include "kernel/fs.h"

char *fmtname(char *path)
{
	static char buf[DIRSIZ + 1];
	char *p;

	// Find first character after last slash.
	for (p = path + strlen(path); p >= path && *p != '/'; p--)
		;
	p++;

	// Return blank-padded name.
	if (strlen(p) >= DIRSIZ)
		return p;
	memmove(buf, p, strlen(p));
	memset(buf + strlen(p), ' ', DIRSIZ - strlen(p));
	return buf;
}

char f_type(int type)
{
	switch(type) {
	case T_DEV: return 'c';
	case T_DIR: return 'd';
	case T_FILE: return '-';
	}
	return '?';
}

void ls(char *path)
{
	char buf[512], *p;
	int fd;
	struct dirent de;
	struct stat st;

	if ((fd = open(path, 0)) < 0) {
		printf(2, "ls: cannot open %s\n", path);
		return;
	}

	if (fstat(fd, &st) < 0) {
		printf(2, "ls: cannot stat %s\n", path);
		close(fd);
		return;
	}

	switch (st.type) {
	case T_FILE:
		printf(1, "%c %s %d (inode: %d)\n", f_type(st.type), fmtname(path), st.size, st.ino);
		break;

	case T_DIR:
		if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
			printf(1, "ls: path too long\n");
			break;
		}
		strcpy(buf, path);
		p = buf + strlen(buf);
		*p++ = '/';
		while (read(fd, &de, sizeof(de)) == sizeof(de)) {
			if (de.inum == 0)
				continue;
			memmove(p, de.name, DIRSIZ);
			p[DIRSIZ] = 0;
			if (stat(buf, &st) < 0) {
				printf(1, "ls: cannot stat %s\n", buf);
				continue;
			}
			printf(1, "%c %s %d (inode: %d)\n", f_type(st.type), fmtname(buf), st.size, st.ino);
		}
		break;
	}
	close(fd);
}

int main(int argc, char *argv[])
{
	int i;

	if (argc < 2) {
		ls(".");
		exit();
	}
	for (i = 1; i < argc; i++)
		ls(argv[i]);
	exit();
}
