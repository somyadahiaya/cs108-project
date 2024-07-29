#!/bin/bash
if ! [ -f gitrepo.txt ]; then
    echo "Git Repository Not Initalised"
else
    while read -r line; do 
    remote_repo=$line
    done < gitrepo.txt
#---- $remote_repo ---- repo path #
previous_id=`awk 'BEGIN{FS=":"}{if($3=="<--HEAD")print $2}' $remote_repo/.git_log`
previous_message=`awk 'BEGIN{FS=":"}{if($3=="<--HEAD")print $1}' $remote_repo/.git_log`

min=1000000000000000 
max=9999999999999999
current_id=`shuf -i $min-$max -n 1`

current_message=`echo $2 | sed 's/ /\ /g' `
echo "$current_message:$current_id"  >> "$remote_repo/.git_log" 
mkdir "$remote_repo/$current_id"
cp *.csv "$remote_repo/$current_id"
./git_head.sh $current_id

if  [ "$previous_id" == "" ]; then
        echo "First Commit"
        ls $remote_repo/$current_id
        echo "were added"
else

#-----------DIFFERENCE BETWEEN PREVIOUS AND CURRENT COMMIT-------------#
previous_files=(`ls $remote_repo/$previous_id`)
current_files=(`ls $remote_repo/$current_id`)

added_files=()
modified_files=()

for files in ${current_files[@]}; do
    if [[ ! " ${previous_files[@]} " =~ " $files " ]];then
        added_files+=("$files")

    else
        difference=`diff -q $remote_repo/$current_id/$files $remote_repo/$previous_id/$files`
        if ! [ "$difference" == "" ]; then
            modified_files+=("$files")
        fi    
    fi
done

echo "Difference in last commit and $current_message:$current_id"
if ! [ ${#added_files[@]} -eq 0 ]; then
    echo "new files added in current commit:"
    echo ${added_files[@]}
else
    echo "no new files added"
fi
echo "----------------------"

if ! [ ${#modified_files[@]} -eq 0 ]; then
    echo "modified files in current commit:"
    echo ${modified_files[@]}
else
    echo "no files modified"
fi

fi

fi