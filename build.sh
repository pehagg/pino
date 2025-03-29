#!/bin/sh
mkdir -p bin
odin build cmd/compiler -out:bin/compiler
odin build cmd/emulator -out:bin/emulator
