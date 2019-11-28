docker build -t xv6 .
docker run --name xv6 --rm -it xv6 qemu-system-i386 -drive file=fs.img,index=1,media=disk,format=raw -drive file=xv6.img,index=0,media=disk,format=raw -smp 1 -m 256 -nographic

