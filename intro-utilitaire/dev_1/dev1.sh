# /bin/bash
#
# CONST
TRUE=1
FALSE=0
#
# le script
main() {  

  # s'assure que le script est executer avec les privileges sudo 
  if [ $( is_root ) != "$TRUE" ]
  then
  
    echo "Vous devez executer le script en tant que root"
    exit -1

  fi 
  

  # s'assure qu'un seul argument est passé
  if [ $# -le 0 -o $# -ge 2 ] 
  then
    echo "Vous avez besoin de passé un fichier minimun en argument"
    echo "Example: dev1.sh [nom du fichier]"
    exit -1 
  fi
  
  # s'assure que le fichier passé existe 
  if [ ! -e $1 ] 
  then 
  
    echo "Le fichier passé en argument n'existe pas"
    echo "Assurez-vous que le fichier se retrouve dans le meme dossier sinon entrer le chemin complet"
    exit -1
  fi 
  
  
  nb_lines=$(cat $1 | wc -l)
 
  
  log "$nb_lines utilisateur(s) à créer"

  for (( i=0; i <= $nb_lines; i++ ))
  do 
    
    log "<----------------------------------"

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
    
    if [[ " $( get_existing_user ) " =~ " ${username} " ]] 
    then 
      log "Utilisateur '$username' à été creé avec succes"
    else 
      log "Incapable de creer l'utilisateur '$username'"

    fi 
   
  done   

}
#
# s'assure que le fichier log existe avent d'essayer de le detruire
clear_log() {
  
  if [ -e devoir_1.log ]
  then
    
    rm devoir_1.log 

  fi 
  
}
#
# ajoute le log passer a  la fin du fichier
log() {

    printf '%s\n' "$@" >> devoir_1.log

}
#
# regarde si le script est executer en tant que root user 
is_root() {

  if [ "$EUID" == "0" ]
  then
    echo "$TRUE"
  else 
    echo "$FALSE"
  fi 

}
#
# retourne tout les utilisateurs présent dans la machine
get_existing_user() {

  
  list_user=$( cut -d: -f1 /etc/passwd ) 
  
  echo ${list_user[@]}

}
#
# créer un nom d'utilisateur avec le prenom et nom passés en parametre 
get_valid_username() {

    
  valid=$FALSE

  first="$1"
  last="$2"


  for (( i= 0; i < ${#first} ; i++ ));
  do
    
    username=$( echo "${first:0:$i+1}$last" |  tr '[:upper:]' '[:lower:]' )
    
    log "Essaie le nom d'utilisteur: $username"


    if [[ " $( get_existing_user )  " =~ " ${username} " ]] 
    then 
      
      log "Un utilisateur avec le nom $username existe déja"
      
    else 

      log "$username peut être utilisé!"
      valid=$TRUE

      break
    fi 

  done
  

  # La prochaine condition est la pour les cas où aucun nom d'utilisateur est disponible 
  # en utilisant une sous-partie du prenom. Dans ses cas, le nom et le prenom sera concaniser et on
  # ajoutera un numero à la fin du utilisteur  
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
        
        log "Un utilisateur avec le nom $nuser existe déja"
      else 
        
        log "le nom d'utilisateur $nuser peut être utilisé"
        
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

  # retourne le nom d'utilisateur  
  echo $username

}
#
#
# Ceci sera executer

clear_log 

main $@
