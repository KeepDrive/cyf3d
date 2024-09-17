#!/bin/sh

tag=$1

case $tag in
  release|debug) echo Building with $tag tag;;
  *) echo Unknown build tag; exit 1;;
esac

mkdir -p build/$tag
rm -r build/$tag
cp -r cyf3d build/$tag

preprocess() {
  args="--silent"
  if [ "$tag" == "release" ]; then
    args="$args --release"
  fi
  while read fileName; do
    outputPath="build/$tag/$(echo $fileName | cut -c 7-)"
    touch $outputPath
    lua LuaPreprocess/preprocess-cl.lua $args -o $fileName $outputPath
  done
}

find cyf3d -type f -name "*.lua" | preprocess
