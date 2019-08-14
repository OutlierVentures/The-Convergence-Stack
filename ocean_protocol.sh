#!/bin/bash

onred='\033[41m'
ongreen='\033[42m'
onyellow='\033[43m'
endcolor='\033[0m'

docker info &> /dev/null || (echo -e "${onred}Error: Docker is not running.$endcolor" && exit 1)

# Handle errors
set -e
error_report() {
    echo -e "${onred}Error: start_nodes.sh failed on line $1.$endcolor"
}
trap 'error_report $LINENO' ERR

# Script functions
get_latest() {
    if [ ! -d $2 ]; then
        git clone https://github.com/$1/$2.git --recursive
        cd $2
    else
        cd $2
        git pull
    fi
    cd ..
}

echo -e "${onyellow}Installing Ocean Protocol node...$endcolor"
get_latest oceanprotocol barge

echo -e "${onyellow}Starting Ocean Protocol node...$endcolor"
cd ../barge
./start_ocean.sh --latest --no-pleuston --no-brizo --local-pacific-node --force-pull &> /dev/null &

while [ "$id" != "" ]; do
    id=$(docker container ls | grep ocean_ | awk '{print $1}')
    sleep 1
done

echo -e "${ongreen}Ocean Protocol node is running.$endcolor"
