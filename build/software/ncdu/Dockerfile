FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    tar xvf *; \
    apt update; apt install -y ncurses-dev; \
    cd */; \
        LDFLAGS="-static" \
            ./configure; \
            make -j$(nproc --all); \
        strip ncdu; \
        cp ncdu /out/; \
    rm -Rf $WORKDIR/*