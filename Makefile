# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)
QEMUGDB = -gdb tcp::$(GDBPORT)

# If the makefile can't find QEMU, specify its path here
# QEMU = qemu-system-i386

# Try to infer the correct QEMU
ifndef QEMU
QEMU = $(shell if which qemu > /dev/null; \
	then echo qemu; exit; \
	elif which qemu-system-i386 > /dev/null; \
	then echo qemu-system-i386; exit; \
	elif which qemu-system-x86_64 > /dev/null; \
	then echo qemu-system-x86_64; exit; \
	else \
	qemu=/Applications/Q.app/Contents/MacOS/i386-softmmu.app/Contents/MacOS/i386-softmmu; \
	if test -x $$qemu; then echo $$qemu; exit; fi; fi; \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "*** or have you tried setting the QEMU variable in Makefile?" 1>&2; \
	echo "***" 1>&2; exit 1)
endif

ifndef CPUS
CPUS := 1
endif

CC = gcc
AS = gas
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -Og -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer -I.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
ASFLAGS = -m32 -gdwarf-2 -Wa,-divide -I.
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1) -z noseparate-code # FreeBSD ld wants ``elf_i386_fbsd''

# Disable PIE when possible
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]no-pie'),)
CFLAGS += -fno-pie -no-pie
endif
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]nopie'),)
CFLAGS += -fno-pie -nopie
endif
# Disable control-flow protection when possible
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep fcf-protection),)
CFLAGS += -fcf-protection=none
endif

K=kernel
U=user

KERNEL_OBJS = \
	$K/bio.o\
	$K/console.o\
	$K/exec.o\
	$K/file.o\
	$K/fs.o\
	$K/ide.o\
	$K/ioapic.o\
	$K/kalloc.o\
	$K/kbd.o\
	$K/lapic.o\
	$K/log.o\
	$K/main.o\
	$K/mp.o\
	$K/picirq.o\
	$K/pipe.o\
	$K/proc.o\
	$K/sleeplock.o\
	$K/spinlock.o\
	$K/string.o\
	$K/swtch.o\
	$K/syscall.o\
	$K/sysfile.o\
	$K/sysproc.o\
	$K/trapasm.o\
	$K/trap.o\
	$K/uart.o\
	$K/vectors.o\
	$K/vm.o

UPROGS = \
	$U/_cat\
	$U/_crash \
	$U/_echo\
	$U/_forktest\
	$U/_grep\
	$U/_init\
	$U/_kill\
	$U/_ln\
	$U/_ls\
	$U/_mkdir\
	$U/_poweroff\
	$U/_rm\
	$U/_sh\
	$U/_stressfs\
	$U/_usertests\
	$U/_wc\
	$U/_zombie

all: fs.img xv6.img xv6memfs.img cscope.out

cscope.out: $(wildcard *.[ch])
	cscope -q -b -k -R $K/*.[ch]
	@echo -e 'You might want to:\nexport CSCOPE_DB=$$(pwd)/cscope.out'

# run in emulators
QEMUOPTS = -drive file=fs.img,index=1,media=disk,format=raw -drive file=xv6.img,index=0,media=disk,format=raw -smp $(CPUS) -m 64 $(QEMUEXTRA)

qemu-nox: fs.img xv6.img
	$(QEMU) -nographic $(QEMUOPTS)

qemu-memfs: xv6memfs.img
	$(QEMU) -nographic -drive file=xv6memfs.img,index=0,media=disk,format=raw -smp $(CPUS) -m 64

.gdbinit: .gdbinit.tmpl
	sed "s/localhost:1234/localhost:$(GDBPORT)/" < $^ > $@

qemu-nox-gdb: fs.img xv6.img .gdbinit
	@echo "*** Now run 'gdb'." 1>&2
	$(QEMU) -nographic $(QEMUOPTS) -S $(QEMUGDB)

xv6.img: $K/bootblock $K/kernel
	dd if=/dev/zero of=xv6.img count=512 # 256 k = 512 blocks of 512 bytes
	dd if=$K/bootblock of=xv6.img conv=notrunc
	dd if=$K/kernel of=xv6.img seek=1 conv=notrunc

xv6memfs.img: $K/bootblock $K/kernelmemfs
	dd if=/dev/zero of=xv6memfs.img count=512
	dd if=$K/bootblock of=xv6memfs.img conv=notrunc
	dd if=$K/kernelmemfs of=xv6memfs.img seek=1 conv=notrunc

$K/bootblock: $K/bootasm.S $K/bootmain.c
	$(CC) $(CFLAGS) -O0 -o $K/bootmain.o -fno-pic -O -nostdinc -I$K -c $K/bootmain.c
	$(CC) $(CFLAGS) -o $K/bootasm.o -fno-pic -nostdinc -I$K -c $K/bootasm.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $K/bootblock.o $K/bootasm.o $K/bootmain.o
	$(OBJDUMP) -M intel -S $K/bootblock.o > $K/bootblock.asm
	$(OBJCOPY) -S -O binary -j .text $K/bootblock.o $K/bootblock
	utils/sign.pl $K/bootblock

$K/entryother: $K/entryother.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I$K -o $K/entryother.o -c $K/entryother.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7000 -o $K/bootblockother.o $K/entryother.o
	$(OBJCOPY) -S -O binary -j .text $K/bootblockother.o $K/entryother
	$(OBJDUMP) -M intel -S $K/bootblockother.o > $K/entryother.asm

$K/initcode: $K/initcode.S
	$(CC) $(CFLAGS) -nostdinc -I. -c $K/initcode.S -o $K/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x1000 -o $K/initcode.out $K/initcode.o
	$(OBJCOPY) -S -O binary $K/initcode.out $K/initcode
	$(OBJDUMP) -M intel -S $K/initcode.o > $K/initcode.asm

$K/kernel: $(KERNEL_OBJS) $K/entry.o $K/entryother $K/initcode $K/kernel.ld
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $K/kernel $K/entry.o $(KERNEL_OBJS) -b binary $K/initcode $K/entryother
	$(OBJDUMP) -M intel -S $K/kernel > $K/kernel.asm
	$(OBJDUMP) -M intel -t $K/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $K/kernel.sym

# kernelmemfs is a copy of kernel that maintains the
# disk image in memory instead of writing to a disk.
# This is not so useful for testing persistent storage or
# exploring disk buffering implementations, but it is
# great for testing the kernel on real hardware without
# needing a scratch disk.
MEMFSOBJS = $(filter-out $K/ide.o,$(KERNEL_OBJS)) $K/memide.o
$K/kernelmemfs: $(MEMFSOBJS) $K/entry.o $K/entryother $K/initcode $K/kernel.ld fs.img
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $K/kernelmemfs $K/entry.o  $(MEMFSOBJS) -b binary $K/initcode $K/entryother fs.img
	$(OBJDUMP) -M intel -S $K/kernelmemfs > $K/kernelmemfs.asm
	$(OBJDUMP) -M intel -t $K/kernelmemfs | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $K/kernelmemfs.sym

$K/vectors.S: utils/vectors.pl
	utils/vectors.pl > $K/vectors.S

ULIB = $U/ulib.o $U/usys.o $U/printf.o $U/umalloc.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0x1000 -o $@ $^
	$(OBJDUMP) -M intel -S $@ > $*.asm
	$(OBJDUMP) -M intel -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

# forktest has less library code linked in - needs to be small
# in order to be able to max out the proc table.
$U/_forktest: $U/forktest.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0x1000 -o $U/_forktest $U/forktest.o $U/ulib.o $U/usys.o
	$(OBJDUMP) -M intel -S $U/_forktest > $U/forktest.asm

utils/mkfs: utils/mkfs.c $K/fs.h
	$(CC) -Werror -Wall -I. -o utils/mkfs utils/mkfs.c

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

fs.img: utils/mkfs $U/README $(UPROGS)
	utils/mkfs fs.img $U/README $(UPROGS)

# include (automagically generated) dependency files if present
-include $K/*.d $U/*.d

clean:
	rm -f cscope.out cscope.in.out cscope.po.out core \
	*.o *.d *.asm *.sym \
	$K/*.o $K/*.d $K/*.asm $K/*.sym \
	$U/*.o $U/*.d $U/*.asm $U/*.sym \
	$K/vectors.S $K/bootblock $K/entryother \
	$K/initcode $K/initcode.out $K/kernel xv6.img fs.img $K/kernelmemfs \
	xv6memfs.img utils/mkfs .gdbinit \
	$(UPROGS)

.PHONY: clean qemu-nox qemu-nox-gdb
