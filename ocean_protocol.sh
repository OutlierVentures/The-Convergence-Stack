#!/bin/bash

git clone https://github.com/oceanprotocol/barge.git
cd barge
./start_ocean.sh --local-nile-node --no-pleuston --no-aquarius --no-brizo &
