#!/bin/sh

set -e

if [ -d tutorial/build ]; then
    echo "Cannot tar, build directory exists."
    exit 1
fi

tar cvf tutorial.tar tutorial/
gzip tutorial.tar

