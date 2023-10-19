#!/bin/sh

minify(){
  cd minifier
  while [[ $# -ne 0 ]]; do
    lua CommandLineMinify.lua ../$1 ../${1}_min
    mv -f ../${1}_min ../$1
    shift
  done
  cd ..
}

if [[ ! -d minifier ]]; then
  mkdir minifier
fi

if [[ -f minifier/CommandLineMinify.lua ]]; then
  minify $@
  exit 0
fi

echo "cyf3d uses LuaMinify to minify code and is required for building with the minified tag."
read -r -p "Clone LuaMinify automatically? [y/N] " response

case "$response" in
  [yY][eE][sS]|[yY]) echo "Using git to clone LuaMinify";;
  *) echo "You can manually clone https://github.com/stravant/LuaMinify into the \"minifier\" directory"; exit 1;;
esac

git clone https://github.com/stravant/LuaMinify.git minifier

echo "Cloning complete. Resuming build."
minify $@
