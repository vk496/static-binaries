FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xvf *; \
    cd */; \
        LDFLAGS="-static" \
            make 7za 7zr sfx -j$(nproc --all); \
        strip bin/7za bin/7zr bin/7zCon.sfx; \
        cp bin/7za bin/7zr bin/7zCon.sfx /out/; \
    rm -Rf $WORKDIR/*