#!/bin/bash

git clone https://github.com/fetchai/oef-core.git
cd oef-core
./oef-core-image/scripts/docker-build-img.sh
./oef-core-image/scripts/docker-run.sh -d -p 3333:3333 -- &
