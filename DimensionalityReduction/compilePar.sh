#!/bin/bash

ghc -o bin/$1 $1.hs -O2 -threaded -eventlog -rtsopts
rm $1.hi $1.o
