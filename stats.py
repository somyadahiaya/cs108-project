import numpy as np
import csv
import pandas as pd

#reading csv file

main= pd.read_csv('main.csv',index_col="Roll-Number")

headers=list(main.columns)
# headers.remove("Roll-Number")
headers.remove("Name")

average=[]
median=[]
std_dev=[]
highest=[]
present=[]
absent=[]

for exam in headers:
    marks=(main[exam].tolist())              #get marks of exam
    filter=[ True if element != 'a' else False for element in marks ]           #filter present and absent
    marks=[int(item) if item != "a" else 0 for item in marks]                   #0 for absent
    marks=np.array(marks)                                                       #np aray so can use filter
    marks=marks[filter]                                                         #marks of only present students
    filter=tuple(filter)                                                        

    average.append(np.mean(marks))
    median.append(np.median(marks))
    std_dev.append(np.std(marks))
    highest.append(np.max(marks))
    present.append(int(filter.count(True)))
    absent.append(int(filter.count(False)))
output=pd.DataFrame({'AVERAGE': average, 'MEDIAN': median,'STANDARD-DEVIATION':std_dev, 'HIGHEST':highest, 'PRESENT':present,'ABSENT':absent,}, index=headers)

exam=input("Enter exam name to get statistics:")

df=output.loc[exam]
print()
print(df)
