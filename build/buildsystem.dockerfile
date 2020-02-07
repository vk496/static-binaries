FROM debian:buster


# Install build tools

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update   &&  \
    apt-get install -yy  \
        automake            \
        build-essential     \
        curl                \
        git                 \
        pkg-config          \
        autopoint           \
        libncurses-dev

RUN apt-get update   &&  \
    apt-get install -yy  \
        musl-tools file

ENV CC_MUSL=/usr/bin/musl-gcc



ENV WORKDIR=/build
# Create prefix
WORKDIR /mlibs
WORKDIR $WORKDIR

SHELL ["/bin/bash", "-c"]

RUN LIBS=(\
        https://github.com/lz4/lz4/archive/v1.9.2.tar.gz \
        https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.gz \
        http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz \
        https://www.zlib.net/zlib-1.2.11.tar.xz \
        https://tukaani.org/xz/xz-5.2.4.tar.xz \
    ); \
    set -e; \
    for i in ${LIBS[@]}; do \
        curl -LO $i; \
        tar xvf *; \
        cd */; \
            CC="$CC_MUSL" ./configure --prefix=/mlibs || NO_CONFIGURE_ARG="PREFIX=/mlibs"; \
            CC="$CC_MUSL" make -j$(nproc --all); \
            make install $NO_CONFIGURE_ARG; \
            unset NO_CONFIGURE_ARG; \
        cd $WORKDIR; rm -Rf $WORKDIR/*; \
    done

# Always will be a empty dir
RUN mkdir /out

############################
ENV CFLAGS_MUSL="-I/mlibs/include/ -I/mlibs/usr/local/include/"
ENV LDLAGS_MUSL="-L/mlibs/lib/ -L/mlibs/usr/local/lib/"