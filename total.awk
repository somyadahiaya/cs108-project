BEGIN{FS=","; OFS=","}
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


    }