#!/bin/bash
# -------------------------COMBINE------------------------------#

#  FUNCTION TO GET NAME OF FILE #

function get_title(){
    title=` echo $1 | cut -d"." -f 1 `            #usage get_title x.csv 
    echo $title                                   #output x

}

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


# FUNCTION TO FIND ROW WITH PARTICULAR DATA #

function find_row(){
    local check=$1
    local row=1
    while read -r line; do                                      # usage data filename
    local rollno=`echo $line |cut -d"," -f 1`                   # returns row no if data else return empty string
    if [ $rollno == $check ]; then
        echo $row
    else 
    row=$((row+1))
    fi
    done < $2
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

#COMBINES MAIN FILE AND GIVEN SINGLE MARKS FILE#

function combinefile(){             #usage combine_file main.csv marks.csv
    main_file=$1
    marks_file=$2                                                               #adding column for exam if not present
   header=$(get_title $marks_file)
   if [ $(find_column $header $main_file) -eq 0 ]; then
    enter_data 1 0 $header $main_file
   fi 
 
    main_rollno=(`tail -n +2 $main_file | cut -d',' -f 1 | tr '[:lower:]' '[:upper:]'`)   #array of rollno present in main.csv

    present_roll=(`tail -n +2 $marks_file | cut -d',' -f 1 | tr '[:lower:]' '[:upper:]'`) #array of rollno present in marks.csv
   
    declare -A student_marks
    declare -A student_name

    for roll in ${present_roll[@]}; do                                      #associative array of key:rollno value:name 
    student_name[$roll]=`grep -Ei "$roll" $marks_file | cut -d"," -f 2`     #for rollno in marks.csv
    done

    for roll in ${present_roll[@]}; do                                      #associative array of key:rollno value:marks 
    student_marks[$roll]=`grep -Ei "$roll" $marks_file | cut -d"," -f 3`    #for rollno in marks.csv
    done
    
    for roll in ${present_roll[@]}; do
        if ! [[ " ${main_rollno[@]} " =~ " $roll " ]]; then                  #CASE 1
            echo "$roll,${student_name[$roll]}" >> $main_file                #if student present in marks.csv and not in main.csv
            local quiz=$(find_column $header $main_file)
            local row=$(find_row $roll $main_file)
            for i in $(seq 3 $quiz);do
                if [ $i -ne $(find_column "Total" $main_file) ]; then       #it means student was absent in all exams entered in main.csv
                enter_data $row $i "a" $main_file                           #before that so a in all remaining column except if 
                else                                                        #there was total column then it will be 0 for that
	            enter_data $row $i "0" $main_file
                 fi
             done
            enter_data $row $quiz "${student_marks[$roll]}" $main_file

        else                                                                #CASE 2
            local quiz=$(find_column $header $main_file)                    #if student present in both marks.csv and main.csv then enter data
            local row=$(find_row $roll $main_file)                          #in the cell 
            enter_data $row $quiz "${student_marks[$roll]}" $main_file
        fi
    done


    for roll in ${main_rollno[@]}; do                                       #CASE 3 
        if ! [[ " ${present_roll[@]} " =~ " $roll " ]]; then                #if student present in main.csv and not in marks.csv
            local quiz=$(find_column $header $main_file)                    #then enter a
            local row=$(find_row $roll $main_file)
            enter_data $row $quiz "a" $main_file
        fi
    done


    if [ $(find_column Total $main_file) -ne 0 ]; then                     #TO HANDLE THE CASE IF TOTAL WAS CALLED BEFORE
        total=$(find_column "Total" $main_file)                            #the previous commands will append the marks next to total column
        awk -v total=$total 'BEGIN {FS=","; OFS=","}                       #this will swap the total and the new column while adding the marks
        {if(NR==1)                                                         #to the total
            {temp=$total; $total=$(total+1); $(total+1)=temp; print}
        else 
            {temp=$total; $total=$(total+1); $(total+1)=temp+$total; print}
            }' $main_file > temp.csv 
        mv temp.csv $main_file
    fi
}

#end of functon combine_file#


    if [ ! -f "main.csv" ]; then
        directory=(`ls | grep -E "*.csv$"`)                         #if combine called for first time create main.csv add rollno and name  
        echo "Roll-Number,Name" > main.csv                              #column
        for file in ${directory[@]}; do
        combinefile main.csv $file
        done
    else
    precombined=(`awk 'BEGIN{FS=","; OFS=" "}{if(NR==1)
                        for(i=3;i<=NF;i++)                                    #else only combine those files those who are not            
                        {                                                     #combined
                            if ($i != "Total")
                            print $i
                        }
                     }' main.csv`)
        
        currentdir=(`ls | grep -E "*.csv" |cut -d"." -f 1 | sed /main/d`)
        for file in ${currentdir[@]}; do
            if [[ ! " ${precombined[@]} " =~ " $file " ]];then
            combinefile main.csv "$file.csv"
            else
                continue
            fi
        done  

    fi

