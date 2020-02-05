ARG BUILDPLATFORM=linux/amd64
FROM --platform=$BUILDPLATFORM debian:buster


# Install build tools

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update   &&  \
    apt-get install -yy  \
        automake            \
        build-essential     \
        curl                \
        git                 \
        pkg-config          \
        autopoint           \
        libncurses-dev