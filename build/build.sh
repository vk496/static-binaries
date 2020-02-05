#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR_BIN=$DIR/../bin

ARCH_BUILD=(x86_64 aarch64)

function darch() {
    case "$1" in
    x86_64)     echo "linux/amd64" ;;
    x86)        echo "linux/386" ;; 
    aarch64)    echo "linux/arm64/v8" ;; 
    *)          echo "unknown!"; exit 1 ;;
    esac
}

for arch in ${ARCH_BUILD[@]}; do

    ### The Builder
    docker build --pull --build-arg BUILDPLATFORM=$(darch $arch) -t buildsystem:$arch -f $DIR/buildsystem.dockerfile $DIR
    ####

    for d in $(find $DIR/software -mindepth 1 -maxdepth 1 -type d); do
        software=$(basename $d)

        NEED_BUILD=0

        for bin_entry in "$(cat $d/Dockerfile |  grep "_VERSION=")"; do
            bin_name=$(echo $bin_entry | cut -d_ -f1 | awk '{ print $2}')
            bin_version=$(echo $bin_entry| cut -d\" -f2- | cut -d\" -f1)

            if [[ ! -f $DIR_BIN/linux/$arch/$bin_name ]]; then
                # If this binary doesn't exist, we must build
                NEED_BUILD=1
                continue
            else
                args=$(cat $d/info | grep ${bin_name}_VERSION | cut -d\" -f2- | rev | cut -d\" -f2- | rev)
                current_version="$(docker run -v $DIR_BIN/linux/$arch/$bin_name:/test/$bin_name --rm -it buildsystem bash -c "/test/$bin_name $args" | tr -d '\r')"

                if [[ $current_version != $bin_version ]]; then
                    NEED_BUILD=1
                fi
            fi
        done


        if [[ $NEED_BUILD -eq 1 ]]; then
            echo "BUILD $software for $arch"
            ( cd $d; docker build -t $software:$arch --build-arg TAG=$arch .)


            # Output binary to dir
            id=$(docker create $software:$arch)
            docker cp $id:/out - | tar -C $DIR_BIN/linux/$arch/ --strip-components 1 -xvf -
            docker rm -v $id
        fi
    done


done