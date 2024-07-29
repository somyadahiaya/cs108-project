#!/bin/bash
if ! [ -f gitrepo.txt ]; then
    echo "Git Repository Not Initalised"
else
    while read -r line; do 
    remote_repo=$line
    done < gitrepo.txt
    cat $remote_repo/.git_log
fi