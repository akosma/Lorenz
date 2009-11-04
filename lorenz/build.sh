#!/usr/bin/env sh

# This script compiles the lorenz source code,
# which generates 10000 (x, y, z) pairs representing
# the Lorenz attractor on a 3D space.

gcc lorenz.c -o lorenz
./lorenz > ../Classes/Views/values.inc
rm lorenz
