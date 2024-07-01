#!/bin/sh

set -e

if [ -d solutions/build ]; then
    echo "Cannot tar, build directory exists."
    exit 1
fi

tar cvf solutions.tar solutions/
gzip solutions.tar

