#!/bin/sh
if [ $# -eq 1 ]; then
  sed -i '/--DEBUG/d' $1
elif [ $# -eq 2 ]; then
  sed '/--DEBUG/d' $1 >> $2
else
  echo "Too many/not enough arguments" >&2
  exit 1;
fi
