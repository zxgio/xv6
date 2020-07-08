FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

#dependencies
RUN apt update && apt install -y build-essential gcc-multilib libsdl1.2-dev libtool-bin libglib2.0-dev libz-dev libpixman-1-dev git cscope ctags wget

# qemu
RUN apt install -y qemu-system

# gdb
RUN apt install -y gdb

ADD ./ /xv6-src
WORKDIR /xv6-src

RUN make

