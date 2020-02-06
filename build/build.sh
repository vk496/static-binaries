#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR_MAIN=$DIR/..
DIR_BIN=$DIR_MAIN/bin


ARCH_BUILD=(x86_64 aarch64)

if [[ $(docker version -f '{{.Server.Experimental}}') != "true" ]]; then
    >&2 echo "Error. Docker experimental features must be enabled"
    exit 1
fi

#TODO: Simplify this two functions

function darch() {
    case "$1" in
    x86_64)     echo "linux/amd64" ;;
    x86)        echo "linux/386" ;; 
    aarch64)    echo "linux/arm64/v8" ;; 
    *)          echo "unknown!"; exit 1 ;;
    esac
}

function osarch() {
    case "$1" in
    linux/amd64)        echo "x86_64" ;;
    linux/386)          echo "x86" ;; 
    linux/arm64/v8)     echo "aarch64" ;; 
    *)                  echo "unknown!"; exit 1 ;;
    esac
}

function join_by {
    # IFS=,; shift;
    # shift
    local i=0
    for arch in $*; do
        if [[ $i -eq 0 ]]; then
            echo -n $(darch $arch)
        else
            echo -n ,$(darch $arch)
        fi
        
        let i=$i+1
    done
    
}

function simple_join_by {
    # IFS=,; shift;
    # shift
    local i=0
    for arch in $*; do
        if [[ $i -eq 0 ]]; then
            echo -n $arch
        else
            echo -n ,$arch
        fi
        
        let i=$i+1
    done
    
}



# Setup local Registry for multi-arch images. Allow to fail if already running
set +e
docker run -d -p 5000:5000 --name registry-vk496 registry:2

# Setup multiarch stuff
docker buildx create --driver-opt network=host --name buildsystem --use
set -e


docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx inspect --bootstrap



### The Builder
DOCKER_BUILDSYSTEM="localhost:5000/buildsystem"
docker buildx build --pull -t $DOCKER_BUILDSYSTEM --output=type=registry,registry.insecure=true --platform $(join_by ${ARCH_BUILD[@]}) -f $DIR/buildsystem.dockerfile $DIR
####


cat $DIR_MAIN/README.md | sed -n '/# Software list/,/# Build/{/# Software list/b;/# Build/b;p}' | sed '/^[[:space:]]*$/d' | tail -n+3 | \
while read line; do
    name=$(echo $line | cut -d\| -f2 | awk '{print $1}')
    version=$(echo $line | cut -d\| -f3 | awk '{print $1}')
    bin_sample=$(echo $line | cut -d\| -f4 | awk '{print $1}' | cut -d, -f1)
    url=$(echo $line | cut -d\| -f5 | awk '{print $1}' | cut -d, -f1 | cut -d\( -f2 | rev | cut -d\) -f2 | rev | sed "s/\${VERSION}/$version/g")

    NEED_BUILD=()

    for arch in ${ARCH_BUILD[@]}; do
        mkdir -p $DIR_BIN/linux/$arch
        darch=$(darch $arch)

        if [[ ! -f $DIR_BIN/linux/$arch/$name ]]; then
            # If this binary doesn't exist, we must build
            NEED_BUILD+=($darch)
        else
            # args=$(cat $d/info | grep ${bin_name}_VERSION | cut -d\" -f2- | rev | cut -d\" -f2- | rev)
            args=$(cat $DIR/software/$name/info | grep ${name}_VERSION | cut -d\" -f2- | rev | cut -d\" -f2- | rev)

            if [[ "$(docker images -q $DOCKER_BUILDSYSTEM 2> /dev/null)" != "" ]]; then
                docker rmi $DOCKER_BUILDSYSTEM
            fi

            current_version=$(docker run --platform $darch -v $DIR_BIN/linux/$arch/$bin_sample:/test/$bin_sample --rm $DOCKER_BUILDSYSTEM bash -c "/test/$bin_sample $args" | tr -d '\r')
            if [[ $current_version != $version ]]; then
                NEED_BUILD+=($darch)
            fi
        fi
    done

    exit

    if [[ ${#NEED_BUILD[@]} -ne 0 ]]; then
        dname="vk496-$name"
        echo "BUILD $name for ${NEED_BUILD[@]}"

        ( cd $DIR/software/$name; docker buildx build --pull -t localhost:5000/$dname --output=type=registry,registry.insecure=true --platform $(simple_join_by ${NEED_BUILD[@]}) --build-arg SOURCE=$url . )


        for darch in ${NEED_BUILD[@]}; do
            arch=$(osarch $darch)

            # To make sure to fit the arch, we remove any old image
            if [[ "$(docker images -q localhost:5000/$dname 2> /dev/null)" != "" ]]; then
                docker rmi localhost:5000/$dname
            fi
            

            # Output binary to dir
            id=$(docker create --platform $darch localhost:5000/$dname)
            docker cp $id:/out - | tar -C $DIR_BIN/linux/$arch/ --strip-components 1 -xvf -
            docker rm -v $id
        done
    fi

done
