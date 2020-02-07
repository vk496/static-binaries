FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xvf *; \
    cd */; \
        autoreconf -vis; \
        LDFLAGS="-static" \
            ./configure; \
            make -j$(nproc --all); \
        strip src/nano; \
        cp src/nano /out/; \
    rm -Rf $WORKDIR/*