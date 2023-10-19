#!/bin/sh

version="1.21.0"

preprocess()
{
  lua preprocessor/preprocess-cl.lua "$@"
}

if [[ ! -d preprocessor ]]; then
  mkdir preprocessor
fi

if [[ -f preprocessor/preprocess-cl.lua ]]; then
  preprocess $@
  exit 0
fi

echo "cyf3d uses LuaPreprocess as a code generator and is required for building."
read -r -p "Download LuaPreprocess automatically? [y/N] " response

case "$response" in
  [yY][eE][sS]|[yY]) echo "Using wget to download LuaPreprocess files v.$version";;
  *) echo "You can manually download preprocess.lua and preprocess-cl.lua and place them into the \"preprocessor\" directory"; exit 1;;
esac

wget -O preprocessor/preprocess-cl.lua https://github.com/ReFreezed/LuaPreprocess/releases/download/$version/preprocess-cl.lua
wget -O preprocessor/preprocess.lua https://github.com/ReFreezed/LuaPreprocess/releases/download/$version/preprocess.lua

echo "Download complete. Resuming build."

preprocess $@
