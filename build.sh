#!/bin/sh

if [[ $# -eq 0 ]]; then
  echo "Build tag required [debug/release/minified]"
  exit 1
fi

tag=$1
shift
format=maybe

preprocessorOpts=""

while [[ $# -ne 0 ]]; do
  case "$1" in
    --format) format=true;;
    --noformat) format=false;;
    --preprocessdebug) preprocessorOpts="${preprocessorOpts} --debug";;
    *) echo unknown option $1;;
  esac
  shift
done

case "$tag" in
  release|minified) echo Building with $tag tag; preprocessorOpts="${preprocessorOpts} --release";;
  debug) echo Building with debug tag;;
  *) echo Unknown build tag; exit 1;;
esac

mkdir -p build/$tag
if [[ "$(ls -A build/$tag)" ]]; then
  rm -r build/$tag/*
fi
cp -r cyf3d build/$tag

unprocessedFiles=$(find build/$tag -type f -name "*.lua2p")

./preprocess.sh $preprocessorOpts $unprocessedFiles
rm $unprocessedFiles

if [[ $tag = "minified" ]]; then
  ./minify.sh $(find build/$tag -type f -name "*.lua" ! -name '*.meta.lua')
  exit 0
fi
if [[ $format = maybe ]]; then
  ./format.sh $(find build/$tag -type f -name "*.lua" ! -name '*.meta.lua')
elif [[ $format = true ]]; then
  stylua $(find build/$tag -type f -name "*.lua" ! -name '*.meta.lua')
fi
