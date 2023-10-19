#!/bin/sh

echo "cyf3d optionally uses stylua to format non-minified builds. You have to have it installed if you want to use it."
read -r -p "Format code? [y/N] " response

case "$response" in
  [yY][eE][sS]|[yY]) echo "Using stylua to format code";;
  *) exit 0;;
esac
stylua $@
