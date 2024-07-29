#!/bin/bash
source colours.sh
source functions.sh

# TO GET MARKS OF A GIVEN STUDENT#

read -p "Enter student rollno:" rollno
if [ "$(find_row $rollno "main.csv" )" == "" ]; then 
    echo "ERROR: the given rollno does not exist"
else    
rollno=`echo $rollno | tr '[:lower:]' '[:upper:]'`

exams=(`awk 'BEGIN{FS=","; OFS=" "}
        NR==1{
                for (i = 3; i <= NF; i++) 
                {
                    printf "%s ", $i
                }
                printf "\n"
                }' main.csv`)

row=$(find_row $rollno main.csv)

name="$(get_data $row 2 main.csv)"

echo -e "${Red}NAME:${Clear} ${Cyan}"$name"${Clear}"
echo -e "${Red}ROLL-NO:${Clear} ${Cyan}"$rollno"${Clear}"

echo -e "${BBlue}EXAM${Clear},${BGreen}MARKS${Clear}" >> temp.csv



for quiz in ${exams[@]};do
    column=$(find_column "$quiz" main.csv)
    marks=$(get_data $row $column main.csv)
    if ! [[ "$quiz" == "Total" ]]; then
        if ! [[ $marks == "a" ]]; then
            echo "$quiz,$marks" >> temp.csv
        else
            echo -e "$quiz,${Red}$marks${Clear}" >> temp.csv
        fi    
    else
        echo -e "${On_Green}$quiz,$marks${Clear}" >> temp.csv
    fi         
done

column -t -s"," temp.csv

rm temp.csv

fi