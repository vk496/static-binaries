FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xvf *; \
    cd */; \
        CC="$CC_MUSL" CFLAGS="$CFLAGS_MUSL" LDFLAGS="$LDLAGS_MUSL -static" \
            ./configure; \
            make -j$(nproc --all); \
        strip src/file; \
        cp src/file /out/; \
    rm -Rf $WORKDIR/*