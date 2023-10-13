#!/bin/sh

preprocessorPath=$1
tag=$2

preprocessorOpts=""
case "$tag" in
  release|minified) echo Building with $tag tag; preprocessorOpts="--release";;
  debug) echo Building with debug tag;;
  *) echo Unknown build tag; exit 1;;
esac

mkdir -p build/$tag
rm -r build/$tag
cp -r cyf3d build/$tag

unprocessedFiles=$(find build/$tag -type f -name "*.lua2p")

lua $preprocessorPath/preprocess-cl.lua $preprocessorOpts $unprocessedFiles
rm $unprocessedFiles
