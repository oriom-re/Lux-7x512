#!/bin/bash

set -e


nasm -f bin src/learn.asm -o src/learn.bin
hexedit src/learn.bin