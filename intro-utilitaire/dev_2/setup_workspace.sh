

if [ "$EUID" != "0" ]
then

  echo "run as a root"
  exit -1

fi 



if [ ! -e /home/workspace ]
then 

  
  echo "create workspace"
  mkdir /home/workspace
  

fi


while read -r line 
do 
  
  if [ ! -z $line ] 
  then 
    useradd $line -d /home/workspace/$line 
  fi 

done < username.txt





















