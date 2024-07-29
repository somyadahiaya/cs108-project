import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

main= pd.read_csv('main.csv', header=0,index_col="Roll-Number")

headers=list(main.columns)
headers.remove("Name")
rollno=input("Enter the Roll-Number of student:").upper()

student=list(main.loc[rollno,headers])

student=[0 if item == "a" else int(item) for item in student]

x=headers
y=np.array(student)

plt.xlabel(main.loc[rollno,"Name"],fontsize=16)
plt.ylabel("marks",fontsize=16)
plt.bar(x,y)
plt.show()
