FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xvf *; \
    cd */; \
        CC="$CC_MUSL" CFLAGS="$CFLAGS_MUSL" LDFLAGS="$LDLAGS_MUSL -static" \
            ./configure --with-ssl=openssl --with-libssl-prefix=$LIBS_MUSL; \
            make -j$(nproc --all); \
        strip src/wget; \
        cp src/wget /out/; \
    rm -Rf $WORKDIR/*