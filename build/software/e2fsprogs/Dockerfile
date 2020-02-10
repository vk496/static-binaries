FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    BINS=( e2fsck/e2fsck misc/badblocks misc/blkid misc/chattr misc/dumpe2fs misc/e2freefrag misc/e2fuzz misc/e2image misc/e2initrd_helper misc/e2undo misc/e4crypt misc/e4defrag misc/filefrag misc/fsck misc/logsave misc/lsattr misc/mke2fs misc/mklost+found misc/tune2fs misc/uuidd misc/uuidgen resize/resize2fs debugfs/debugfs ); \
    tar xvf *; \
    cd */; \
        LDFLAGS="-static" \
            ./configure; \
            make -j$(nproc --all); \
        for f in ${BINS[@]}; do \
            strip $f; \
            cp $f /out/; \
        done; \
    rm -Rf $WORKDIR/*