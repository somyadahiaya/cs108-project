#!/bin/bash
if ! [ -f gitrepo.txt ]; then
    echo "Git Repository Not Initalised"
else
    while read -r line; do 
    remote_repo=$line
    done < gitrepo.txt
fi

if [[ $1 =~ [0-9]+ ]]; then
    match=(`cut -d':' -f 2 $remote_repo/.git_log | grep -E "^$1"`)
    if [ ${#match[@]} -gt 1 ]; then
        echo "CONFLICT: ${#match[@]} commits with same prefix"
        echo ${match[@]}
    elif [ ${#match[@]} -eq 0 ]; then
        echo "ERROR: commit id does not exist"
    else
        echo "WARNING: if current changes are not committed they will be lost"
        read -p "Do you wish to continue?[y/n]:" ans
        if [ $ans == 'y' ]; then
            echo "Checking out to ${match[0]}"
            ./git_head.sh ${match[0]}
            rm *.csv 2>/dev/null
            cp -r $remote_repo/${match[0]}/*.csv .
        elif [ $ans == 'n' ]; then
            echo "Command Terminated"     
        fi
    fi    
elif [ $1 == "-m" ]; then
    message="$2"

     match=(`awk -v message="$message" 'BEGIN{FS=":"; OFS=","}
        {
            if($1==message)
            print $2
        }' $remote_repo/.git_log`)
    
     if [ ${#match[@]} -gt 1 ]; then
        echo "CONFLICT: ${#match[@]} commits with same message"
        echo ${match[@]}
    elif [ ${#match[@]} -eq 0 ]; then
        echo "ERROR: commit message does not exist"
    else
         echo "WARNING: if current changes are not committed they will be lost"
        read -p "Do you wish to continue?[y/n]:" ans
        if [ $ans == 'y' ]; then
            echo "Checking out to ${match[0]}"
            ./git_head.sh ${match[0]}
            rm *.csv 2>/dev/null
            cp -r $remote_repo/${match[0]}/*.csv .
        elif [ $ans == 'n' ]; then
            echo "Command Terminated"     
        fi   
    fi 
    

fi

