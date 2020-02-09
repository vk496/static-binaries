FROM localhost:5000/buildsystem

ARG SOURCE

RUN curl -LO $SOURCE

RUN set -ex; \
    apt update; apt install -y lzip; \
    tar xvf *; \
    cd */; \
            ./configure \
                LDFLAGS="-static"; \
            make -j$(nproc --all); \
        strip ddrescue ddrescuelog; \
        cp ddrescue ddrescuelog /out/; \
    rm -Rf $WORKDIR/*