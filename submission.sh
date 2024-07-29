#TO HANDLE TOTAL COMMAND#

if [ "$1" == "total" ]; then
if [ -f main.csv ];then
    awk -f total.awk main.csv > temp.csv
    mv temp.csv main.csv
else 
    echo "ERROR: main file does not exist"    
fi
fi
#TO HANDLE COMBINE COMMAND#

if [ "$1" == "combine" ]; then
    ./combine.sh
fi

#TO HANDLE UPLOAD COMMAND#

if [ "$1" == "upload" ]; then
    path=$2
    filename=$(basename "$path")
    cp $path $filename
fi

#GIT INIT#

if [ "$1" == "git_init" ]; then
    ./git_init.sh "$2"
fi    

#GIT COMMIT#

if [ "$1" == "git_commit" ]; then
    ./git_commit.sh "$2" "$3"
fi

#GIT CHECKOUT#

if [ "$1" == "git_checkout" ]; then

    ./git_checkout.sh "$2" "$3"
fi

#GIT REVERT#

if [ "$1" == "git_revert" ]; then
    ./git_revert.sh "$2" "$3"
fi

#GIT LOG#

if [ "$1" == "git_log" ]; then
    ./git_log.sh 
fi

#UPDATE#

if [ "$1" == "update" ]; then
    ./update.sh 
fi

#STUDENT GRAPH#

if [ "$1" == "performance" ]; then
    python3 performance.py
fi    

#GET MARKS#


if [ "$1" == "get_marks" ]; then
    ./get_marks.sh
fi

#EXAM STATISTICS#


if [ "$1" == "statistics" ]; then
    python3 stats.py
fi