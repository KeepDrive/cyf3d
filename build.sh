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
  while read fileName; do
    ./preprocess.sh $fileName
  done
}

if [ $tag = "release" ]; then
  find build/$tag -type f -name "*.lua" | preprocess
fi
