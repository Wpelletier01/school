

# Const
TRUE=1
FALSE=0
# 


root="filesys/ptremblay"
  
files=()
directory=($root)
  
finish=$FALSE
i=0 

while [ "$finish" != "$TRUE" ]
do 
  
  if [ $i -ge ${#directory[@]} ]
  then
    
    echo "hey"
    finish=$TRUE
  
  else 

    found=$FALSE
    
    echo "${directory[i]}"
    dirlist=(${directory[$i]}/*)
    

    for ((x=0;x<=${#dirlist[@]};x++))
    do
      
      entry=${dirlist[$x]}
      
      if [ ! -z $entry ]
      then 
        if [ -d $entry ] && [[ ! " ${directory[*]} " =~ " ${entry} " ]] 
        then
        
          found=$TRUE
          echo "found dir: $entry"
          directory+=("$entry")


        elif [ -f $entry ] && [[ ! " ${files[*]} " =~ " ${entry} " ]] 
        then 

          found=$TRUE
          echo "found file: $entry"
          files+=("$entry")
      
        fi
      fi 
    done 
    
    if [ "$found" != "$TRUE" ]
    then
      echo "oh no"
      i=$(( i + 1 ))
    fi 
    

  fi 

done 


nbf=$(( ${#directory[@]} - 1 ))

echo "nb dir:$nbf"
echo "nb file:${#files[@]}"  

