#! /usr/bin/env bash

cd ..

shopt -s extglob
rm -Rfv !("makefile"|".git"|".blog"|".gitignore") 2> /dev/null
shopt -u extglob

cd ./.blog