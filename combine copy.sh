#!/bin/bash


function get_title(){
    title=` echo $1 | cut -d"." -f 1 `            #usage get_title x.csv 
    echo $title                                   #output x

}
function addheader(){
    header_name=$(get_title $1)
    while read -r line; do
    arr=`echo $line | cut -d"," -f 1`
    if [ $arr == "Roll-Number" ]; then
        echo "$line,$header_name" >> temp.csv
    else
        echo $line >> temp.csv
    fi
    done < $2     #usage x.csv main.csv
    mv temp.csv $2                                                                                                                #output heading x in main
}                                                                                                                       

function enter_data(){
    row=$1
    column=$2
    data=$3
    awk -v row=$1 -v column=$2 -v data=$data 'BEGIN {FS=","; OFS=","} {if(NR==row){$column=data};print}' $4 >> temp.csv 
    mv temp.csv $4
}
function find_roll(){
    local check=$1
    local row=1
    while read -r line; do                              
    local rollno=`echo $line |cut -d"," -f 1`
    if [ $rollno == $check ]; then
        echo $row
    else 
    row=$((row+1))
    fi
    done < $2
    }
function find_column() {
    local check="$1"
    local column=1
    local input_file="$2"

    awk -v check="$check" 'BEGIN {FS=","; found=0}
        NR==1 {
            for (i = 1; i <= NF; i++) {
                if ($i == check) {
                    print i
                    found=1
                    exit
                }
            }
            if (found == 0) {
                print 0
                exit 1
            }
        }' "$input_file"
 }
function combinefile(){
    main_file=$1
    marks_file=$2
   header=$(get_title $marks_file)
   if [ $(find_column $header $main_file) -eq 0 ]; then
	  addheader $marks_file $main_file
   fi 
 
    roll_no=(`tail -n +2 $main_file | cut -d',' -f 1 | tr '[:lower:]' '[:upper:]'`)
   # echo ${roll_no[@]}

    present_roll=(`tail -n +2 $marks_file | cut -d',' -f 1 | tr '[:lower:]' '[:upper:]'`)
   
    declare -A student_marks
    declare -A student_name

    for roll in ${present_roll[@]}; do
    student_name[$roll]=`grep -Ei "$roll" $marks_file | cut -d"," -f 2`
    done

    for roll in ${present_roll[@]}; do
    student_marks[$roll]=`grep -Ei "$roll" $marks_file | cut -d"," -f 3`
    done
    
    for roll in ${present_roll[@]}; do
    if ! [[ " ${roll_no[@]} " =~ " $roll " ]]; then
    local quiz=$(find_column $header $main_file)
    echo "$roll,${student_name[$roll]}" >> $main_file
    local row=$(find_roll $roll $main_file)
    for i in $(seq 3 $quiz);do
    if [ $i -ne $(find_column "Total" $main_file) ]; then
    enter_data $row $i "a" $main_file
    else
	enter_data $row $i 0 $main_file
    fi
    done
    enter_data $row $quiz ${student_marks[$roll]} $main_file

    else
    local quiz=$(find_column $header $main_file)
    local row=$(find_roll $roll $main_file)
    enter_data $row $quiz "${student_marks[$roll]}" $main_file
    fi
    done
    for roll in ${roll_no[@]}; do
    if ! [[ " ${present_roll[@]} " =~ " $roll " ]]; then
    local quiz=$(find_column $header $main_file)
    local row=$(find_roll $roll $main_file)
    enter_data $row $quiz "a" $main_file
    fi
    done
    if [ $(find_column Total $main_file) -ne 0 ]; then
        #echo 1
        total=$(find_column "Total" $main_file)
        #echo $total
        awk -v total=$total 'BEGIN {FS=","; OFS=","}
        {if(NR==1)
            {temp=$total; $total=$(total+1); $(total+1)=temp; print}
        else 
            if($total != "a")   
            {temp=$total; $total=$(total+1); $(total+1)=temp+$total; print}
            else
            {temp=$total; $total=$(total+1); $(total+1)=temp; print}
            }' $main_file > temp.csv 
        mv temp.csv $main_file
    fi
}

if [ "$1" == "Total" ]; then
awk 'BEGIN{FS=","; OFS=","}
    {
        if(NR==1)
        {
            print $0, "Total"
        }
        else
        {
            sum=0;
            for(i=3;i<=NF;i++)
            {
                if($i != "a")
                sum+=$i
            }
            print $0, sum 
        }


    }' main.csv > temp.csv
    mv temp.csv main.csv
fi

if [ $# -eq 0 ]; then
    if [ ! -f "main.csv" ]; then
        directory=(`ls | grep -E "*.csv$"`)
    echo "Roll-Number,Name" > main.csv
    for file in ${directory[@]}; do
        combinefile main.csv $file
    done
    else
    precombined=(`awk 'BEGIN{FS=","; OFS=" "}{if(NR==1)
        for(i=3;i<=NF;i++)
        {
            if ($i != "Total")
            print $i
        }
    }' main.csv`)
        
        #echo ${precombined[@]}
        currentdir=(`ls | grep -E "*.csv" |cut -d"." -f 1 | sed /main/d`)
        #echo ${currentdir[@]}
        for file in ${currentdir[@]}; do
            if [[ ! " ${precombined[@]} " =~ " $file " ]];then
            combinefile main.csv "$file.csv"
            else
                continue
            fi
        done  

    fi
fi
#combinefile main.csv quiz2.csv


#addmarks main.csv quiz1.csv

