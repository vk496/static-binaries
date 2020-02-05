ARG TAG=x86_64
FROM buildsystem:$TAG


##############################
ENV nano_VERSION="4.7"
##############################
ARG VERSION=$nano_VERSION

ENV SOURCE="https://www.nano-editor.org/dist/v4/nano-$VERSION.tar.xz"

RUN curl -LO $SOURCE
RUN tar xJvf nano-${VERSION}.tar.xz

RUN set -e; \
    cd nano-${VERSION}; \
    autoreconf -vis; \
    LDFLAGS="-static" \
        ./configure; \
        make -j$(nproc --all); \
    mkdir -p /out; \
    strip src/nano; \
    cp src/nano /out/