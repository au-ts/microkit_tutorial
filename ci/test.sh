#!/bin/bash

set -e

SDK_PATH=$1

# @ivanv: allow testing for a specific part?

[[ -z $SDK_PATH ]] && echo "usage: test.sh [PATH TO SDK]" && exit 1
[[ ! -d $SDK_PATH ]] && echo "The path to the SDK provided does not exist: '$SDK_PATH'" && exit 1

rm -rf part1_solution
rm -rf part2_solution

cp -r tutorial part1_solution
cd part1_solution
patch < ../patches/part1.patch
../ci/part1.exp $SDK_PATH
cd ..

cp -r part1_solution part2_solution
cd part2_solution
patch < ../patches/part2.patch
../ci/part2.exp $SDK_PATH
