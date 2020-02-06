FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xJvf *; \
    export OLD_DIR=$(pwd); \
    cd *; \
        autoreconf -vis; \
        LDFLAGS="-static" \
            ./configure; \
            make -j$(nproc --all); \
        mkdir -p /out; \
        strip src/nano; \
        cp src/nano /out/; \
    cd $OLD_DIR; \
    rm -Rf *