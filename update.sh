#!/bin/bash
# FUNCTION TO ENTER DATA IN GIVEN ROW AND COLUMN #

function enter_data(){
    row=$1
    column=$2
    data=$3
    awk -v row=$1 -v column="$2" -v data=$data 'BEGIN {FS=","; OFS=","} {if(NR==row) {if(column==0) $(NF+1)=data;
                                                                                        else $column=data;}
                                                                         print}' $4 >> temp.csv
    mv temp.csv $4
}                                                  #usage rowno columnno data filename[csv]
                                                               # to enter data in new column put column no =0

# FUNCTION TO GET DATA FROM CELL#

function get_data(){
    row=$1
    column=$2
    file=$3
    awk -v row=$1 -v column="$2" 'BEGIN {FS=","; OFS=","} {if(NR==row) {print $column}}' $file

}

# FUNCTION TO FIND ROW WITH PARTICULAR DATA #

function find_row(){
    local check=$1
    local row=1
    while read -r line; do                                      # usage data filename
    local rollno=`echo $line |cut -d"," -f 1 | tr '[:lower:]' '[:upper:]'`                   # returns row no if data else return empty string
    if [ $rollno == $check ]; then
        echo $row
    else 
    row=$((row+1))
    fi
    done < "$2"
    }



#FUNCTION TO FIND COLUMN HEADING WITH  PARTICULAR DATA #

function find_column() {
    local check="$1"                                        #USAGE DATA FILENAME
    local column=1                                          #returns column if data else 0
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



read -p "Enter the rollno of student :" rollno
rollno=`echo $rollno | tr '[:lower:]' '[:upper:]'`
echo $rollno
if [ "$(find_row $rollno "main.csv" )" == "" ]; then 
    echo "ERROR: the given rollno does not exist"
else
    row=$(find_row $rollno main.csv)
    read -p "Enter the student name:" name
    echo "$name"
    if ! [[ "$name" == "$(get_data $row 2 main.csv)" ]]; then
        echo "ERROR: name does not match with roll number"
        echo "$(get_data $row 2 main.csv)"
    else
        read -p "Enter the exam name:" exam
        if [ $(find_column $exam main.csv) -eq 0 ]; then
            echo "ERROR: there is no $exam in main.csv"
        else
            column=$(find_column $exam main.csv)
            read -p "Enter the marks:" marks
            previous_marks=$(get_data $row $column main.csv)

            enter_data $row $column $marks main.csv    
            total_column=$(find_column "Total" main.csv)
            #entering data in exam and total column if it exsts#
            if ! [[ "$previous_marks" == "a" ]]; then 
                if ! [[ "$total_column" == "0" ]]; then
                    previous_total=$(get_data $row $total_column main.csv)
                    new_total=$(( $previous_total+$marks-$previous_marks ))
                    enter_data $row $total_column $new_total main.csv
                fi
                ex_row=$(find_row $rollno $exam.csv)                                                        
                enter_data $ex_row 3 $marks $exam.csv
                    #CASE when student was absent before and gave the exam later# 
            else

                if ! [[ "$total_column" == "0" ]]; then
                    previous_total=$(get_data $row $total_column main.csv)
                    new_total=$(( $previous_total+$marks-$previous_marks ))
                    enter_data $row $total_column $new_total main.csv
                fi
                    enter_data $row $total_column $new_total main.csv
                    echo "$rollno,$name,$marks" >> $exam.csv
        
            fi
        fi        
    fi    
fi



