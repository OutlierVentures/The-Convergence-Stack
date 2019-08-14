#!/bin/bash

onred='\033[41m'
ongreen='\033[42m'
onyellow='\033[43m'
endcolor='\033[0m'

docker info &> /dev/null || (echo -e "${onred}Error: Docker is not running.$endcolor" && exit 1)

# Handle errors
set -e
error_report() {
    echo -e "${onred}Error: get_nodes.sh failed on line $1.$endcolor"
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

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    sudo apt-get update
    sudo apt-get install -y build-essential python3
    bazel version || echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list && \
                     curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add - && \
                     sudo apt-get update && \
                     sudo apt-get install bazel
elif [[ "$OSTYPE" == "darwin"* ]]; then
    xcode-select --version || xcode-select --install
    brew --version || yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    python3 --version || brew install python
    if brew ls --versions bazel >/dev/null; then
        if [[ $(brew outdated bazel) ]]; then
            HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade bazelbuild/tap/bazel
        fi
    else
        brew tap bazelbuild/tap
        HOMEBREW_NO_AUTO_UPDATE=1 brew install bazelbuild/tap/bazel
    fi
fi

get_latest fetchai oef-search-pluto
get_latest fetchai oef-mt-core
cd oef-mt-core
bazel build mt-core/main/src/cpp:app

cd oef-search-pluto
python3 scripts/launch.py -c ./scripts/launch_config.json --background &> /dev/null
cd ../oef-mt-core
bazel run mt-core/main/src/cpp:app -- --config_file `pwd`/mt-core/main/src/cpp/config.json &> /dev/null &

echo -e "${ongreen}Fetch.AI OEF node is running.$endcolor"
