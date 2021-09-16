FROM alpine:latest as build
RUN apk update
RUN apk add build-base
RUN apk add bison
RUN apk add flex flex-dev
RUN apk add gmp-dev
RUN apk add mpc1-dev
RUN apk add mpfr-dev
RUN apk add texinfo
RUN apk add cloog
RUN apk add isl-dev
RUN apk add curl

RUN curl http://mirror.us-midwest-1.nexcess.net/gnu/binutils/binutils-2.36.tar.gz --location --output binutils-2.36.tar.gz
RUN tar -xf /binutils-2.36.tar.gz
RUN rm binutils-2.36.tar.gz

ENV PREFIX=/root/opt/cross
ENV TARGET=x86_64-elf
ENV PATH="$PREFIX/bin:$PATH"

RUN mkdir /build-binutils
WORKDIR /build-binutils
RUN ../binutils-2.36/configure --target=${TARGET} --prefix=${PREFIX} --with-sysroot --disable-nls --disable-werror
RUN make
RUN make install

WORKDIR /
RUN curl https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.gz --location --output gcc-10.3.0.tar.gz
RUN tar -xf gcc-10.3.0.tar.gz
RUN rm gcc-10.3.0.tar.gz

RUN mkdir /build-gcc
WORKDIR /build-gcc
RUN ../gcc-10.3.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
RUN make all-gcc
RUN make all-target-libgcc
RUN make install-gcc
RUN make install-target-libgcc

FROM alpine:latest as dist
RUN apk update
RUN apk add make
COPY --from=build /root/opt/cross /usr/local
