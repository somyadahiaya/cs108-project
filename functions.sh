
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

# FUNCTION TO GET DATA FROM CELL#

 
function get_data(){
    row=$1
    column=$2
    file=$3
    awk -v row=$1 -v column="$2" 'BEGIN {FS=","; OFS=","} {if(NR==row) {print $column}}' $file

}