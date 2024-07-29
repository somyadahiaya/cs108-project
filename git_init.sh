#!/bin/bash

if ! [ -d "$1" ]; then
    mkdir "$1"
    echo "------ Initialising Git Repository $1 ------"
    cd $1
    echo > .git_log
else
    echo "-------- Repository already initialised ---------"
fi

echo "$1" > gitrepo.txt