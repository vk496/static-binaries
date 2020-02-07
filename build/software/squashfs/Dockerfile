FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xvf *; \
    export OLD_DIR=$(pwd); \
    cd */squashfs-tools/; \
        CC="$CC_MUSL" CFLAGS="$CFLAGS_MUSL" LDFLAGS="$LDLAGS_MUSL -static" \
            make -j$(nproc --all) \
                GZIP_SUPPORT=1 \
                XZ_SUPPORT=1 \
                LZO_SUPPORT=1 \
                LZMA_XZ_SUPPORT=1 \
                LZ4_SUPPORT=1 \
                ZSTD_SUPPORT=1 \
                XATTR_SUPPORT=1; \
        mkdir -p /out; \
        strip mksquashfs unsquashfs; \
        cp mksquashfs unsquashfs /out/; \
    cd $OLD_DIR; \
    rm -Rf *