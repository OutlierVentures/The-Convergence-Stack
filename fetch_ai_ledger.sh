#!/bin/bash

onred='\033[41m'
ongreen='\033[42m'
onyellow='\033[43m'
endcolor="\033[0m"

# Handle errors
set -e
error_report() {
    echo -e "${onred}Error: failed on line $1.$endcolor"
}
trap 'error_report $LINENO' ERR

echo -e "${onyellow}Installing Fetch ledger...$endcolor"
git clone https://github.com/fetchai/ledger.git
cd ledger
./scripts/quickstart.sh

echo -e "${ongreen}Fetch ledger installed. Booting...$endcolor"
cd build/apps/constellation
./constellation -bootstrap -network alpha
