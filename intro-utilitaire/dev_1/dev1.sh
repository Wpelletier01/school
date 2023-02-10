# /bin/bash


# CONST
TRUE=1
FALSE=0


log() {
    printf '%s\n' "$@" >> devoir_1.log
}


main() {  

  # s'assure qu'un seul argument est passé
  if [ $# -le 0 -o $# -ge 2 ] 
  then
    echo "Vous avez besoin de passé un fichier seulement en argument"
    exit -1 
  fi
  
  # s'assure que le fichier passé existe 
  if [ ! -e $1 ] 
  then 
  
    echo "le fichier passé en argument n'existe pas"
    exit -1
  fi 
  
  
  nb_lines=$(cat $1 | wc -l)
 
  
  log "$nb_lines user(s) a créer"

  for (( i=0; i <= $nb_lines; i++ ))
  do 
     
    # capture une ligne
    line=$( tail -n +$i $1 | head -n 1 )
    
    # remplace les espaces blancs par un crochet pour delimiter un nom de l'autre 
    fline=$( echo $line | tr " " "-" ) 
    
    # crée un array en « splitant » en deux le string a l'aide du separateur « - »
    IFS="-" read -r -a filter_line <<< "$fline"
    
    # créé un username a l'aide de argument passé
    username=$( get_valid_username "${filter_line[@]}" )
    
    # créé un nouveau utilisateur sans un group et un home directory
    useradd -N -M $username
    
    if [[ " $( get_existing_user ) " =~ " ${nuser} " ]] 
    then 
      log "user $username a ete creer avec succes"
    else 
      log "something wrong occured while creating user '$username'"

    fi 
   

  done   

} 

  


get_existing_user() {

  
  list_user=$( cut -d: -f1 /etc/passwd ) 
  
  echo ${list_user[@]}


}



# créer un nom d'utilisateur avec le prenom et nom passés en parametre 
get_valid_username() {

    
  valid=$FALSE

  first="$1"
  last="$2"


  for (( i= 0; i < ${#first} ; i++ ));
  do
    
    username=$( echo "${first:0:$i+1}$last" |  tr '[:upper:]' '[:lower:]' )
    
    log "essaie username: $username"


    if [[ " $( get_existing_user )  " =~ " ${username} " ]] 
    then 
      
      log "$username existe deja"
      
    else 

      log "$username peut etre utiliser!"
      valid=$TRUE

      break
    fi 

  done
  #
  #
  # La prochaine condition est la pour les cas où aucun username est en utilisant une sous-partie
  # du prenom. Dans ses cas, le nom et le prenom sera concaniser et on ajoutera un numero à la fin 
  # du username 
  #
  #
  if [ "$valid" == "$FALSE" ]
  then
    x=0
    
    username="$first$last"

    while [ "$valid" == "$FALSE" ]
    do 
    
      nuser="$username$x"
      


      if [[ " $( get_existing_user ) " =~ " ${nuser} " ]]  
      then
        
        log "$nuser existe deja"
      else 
        
        log "$nuser peut etre utiliser"
        
        # on veux pas que la valeur 0 soit ajouter a la fin
        if [ '$x' != "0" ] 
        then 
          
          username="$nuser"

        fi 
 
        break

      fi

      x=$(( x + 1 ))

    done 
  fi

   
  echo $username

}




test() {
  
  rm devoir_1.log

  
  
  
  

}


rm devoir_1.log

main $@
