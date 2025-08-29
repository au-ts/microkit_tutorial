#!/bin/bash

# There are a couple artificats that must be packaged
# up seperately and put on a server, specifically the tutorial
# and solutions tarballs. This script just does that
# automatically and puts it in a directory 'dist/'.

set -e

rm -rf dist
mkdir dist

# Don't want to ship the build directory
rm -rf tutorial/build
rm -rf solutions/build

cd dist

tar cvf tutorial.tar ../tutorial/
gzip tutorial.tar

tar cvf solutions.tar ../solutions/
gzip solutions.tar
