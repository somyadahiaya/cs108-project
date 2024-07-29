#!/bin/bash
if ! [ -f gitrepo.txt ]; then
    echo "Git Repository Not Initalised"
else
    while read -r line; do 
    remote_repo=$line
    done < gitrepo.txt

    
if [[ $1 =~ [0-9]+ ]]; then
    match=(`cut -d':' -f 2 $remote_repo/.git_log | grep -E "^$1"`)
    if [ ${#match[@]} -gt 1 ]; then
        echo "CONFLICT: ${#match[@]} commits with same prefix"
        echo ${match[@]}
    elif [ ${#match[@]} -eq 0 ]; then
        echo "ERROR: commit id does not exist"
    else
        echo "WARNING: the commit history of given commit will be lost"
        read -p "Do you wish to continue?[y/n]:" ans
        if [ $ans == 'y' ]; then
   #-------------------------------------to check if commit is in head state-------------------------#         
            check_head=`grep -E "${match[0]}" $remote_repo/.git_log | cut -d':' -f 3`
            if ! [ "$check_head" == "<--HEAD" ]; then
                echo "Removing commit"
                sed -i '/'${match[0]}'/d' $remote_repo/.git_log 
                rm -r $remote_repo/$match
            else
                echo "ERROR: cannot remove given commit as it is in head state"
            fi 
        elif [ $ans == 'n' ]; then
            echo "Command Terminated"     
        fi
    fi    
elif [ $1 == "-m" ]; then
    message=` echo $2 | sed 's/ /\ /g' `
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
         echo "WARNING: the commit history of given will be lost"
        read -p "Do you wish to continue?[y/n]:" ans
        if [ $ans == 'y' ]; then
            check_head=`grep -E "${match[0]}" $remote_repo/.git_log | cut -d':' -f 3`
            if ! [ "$check_head" == "<--HEAD" ]; then
                echo "Removing commit"
                sed -i '/'${match[0]}'/d' $remote_repo/.git_log 
                rm -r $remote_repo/$match
            else
                echo "ERROR: cannot remove given commit as it is in head state"
            fi 
        elif [ $ans == 'n' ]; then
            echo "Command Terminated"     
        fi   
    fi 
    

fi

fi