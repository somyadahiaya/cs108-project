#!/bin/bash

#-------- point to the commit version we are persent in --------#

if ! [ -f gitrepo.txt ]; then
    echo "Git Repository Not Initalised"
else                                                                    
    while read -r line; do 
    remote_repo=$line
    done < gitrepo.txt

    sed  -i -E 's/(.*):<--HEAD$/\1/' $remote_repo/.git_log
    sed -i 's/'$1'/'$1':<--HEAD/' $remote_repo/.git_log
fi