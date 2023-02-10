


FILE="/home/user/homework/intro-utilitaire/dev_1/list_utilisateur.txt"

TEST_LINE=( "Micheline", "Gauthier" )




username_exist() {


  usernames=$( cut -d: -f1 /etc/passwd )

  if [[ " ${usernames[@]} " =~ " ${1} " ]]
  then
    echo "$TRUE"
  fi 
  
  echo "$FALSE"

}




first_names="${TEST_LINE[0]}"
  
  valid=$FALSE 
  
  for i in "${#first_names[@]}"
  do
    
    username="${first_names:0:$i}${TEST_LINE[1]}"

    if [ "$(username_exist $username )" == "$FALSE" ]
    then 
      
      valid=$TRUE
      echo "$username"
      
      break 

    fi 

  done 
  
  if [ $valid -eq $FALSE ]
  then

    x=0
  
    username="$first_names${TEST_LINE[1]}"


    while [ "$valid" == "0" ]
    do 
    
      nuser="$username$x"
    
      if [ $( username_exist $username ) -eq $FALSE ]
      then
        echo "$nuser"
        break
      fi

      x=$(( x + 1 ))

    done 
  fi



line="Marie       Gauthier"


f=$( tail -n +9 $FILE | head -n 1 )

l=$( echo $f | tr " " "-"  )


echo $l

IFS="-" read -r -a filter_line <<< "$l"



echo "${#filter_line[@]}"








