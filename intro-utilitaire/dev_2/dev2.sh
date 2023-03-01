
# -------------------------------------------------------------------------------------------------
# Déclaration
#
# Constante
TRUE=1
FALSE=0
WHITESPACE="                                   "
#
# Propriété du script
LOG_FILE="sauvegarde.log"
VERBOSE=$FALSE
HOME_DIR="/home"
USER_FILE=""
SAVE_DIR="/mnt/sauvegarde"
#
# ASCII Couleur
RED='\033[0;31m'
GREEN='\x1b[32m'
CYAN='\x1b[36m'
YELLOW='\x1b[33m'
NO_COLOR='\033[0m'
BLUE='\x1b[34m'
#
#
# -------------------------------------------------------------------------------------------------
# Fonction pour le logging
#

# affiche au terminal le log passé 
print_log() { 
    
    # -e pour que les valeur des couleurs asccii soit interpreté (visible)
    echo -e "$1" >&2 

}

# ajoute le log passé a la fin 
save_log() { 
    

    ( echo "$1" >> "$LOG_FILE" ) 2>/dev/null

}

# ajoute ensemble l'heure-date avec le type de log et son message
# $1 -> type de log
# $2 -> message
#
# exemple:
#       [ 23/02/28 | 20:14:17 ] [ Info ]   transfert du dossier: '/foo/bar/' reussie
#       
fmt_log() {

    echo "$( date +'[ %y/%m/%d | %H:%M:%S ]') [ $1 ] $2" 
    
}

# créer un log de type status avec le message passée
log_status() {

    # avec la valeur de couleur ascii pour le terminal
    log=$( fmt_log "${GREEN}Status${NO_COLOR}" "${@}" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "Status" "${@}" )
    # log de type status sont toujours afficher à l'écran
    print_log "$log"
    # enregistre au fichier des log
    save_log "$slog"

}

# créer un log de type info avec le message passée
log_info() {

    # avec la valeur de couleur ascii pour le terminal
    log=$( fmt_log "${GREEN}Info${NO_COLOR}" "  ${@}" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "Info" "  ${@}" )
    # regarde si le mode verbose a été activé pour afficher le log
    if [ "$VERBOSE" == "$TRUE" ]
    then
        
        print_log "$log" 

    fi 
    # enregistre au fichier des log
    save_log "$slog"
    
}

# créer un log de type trace avec le message passée
log_trace() {

    # avec la valeur de couleur ascii pour le terminal
    log=$( fmt_log "${BLUE}Trace${NO_COLOR}" " ${@}" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "Trace" " ${@}" )
    # regarde si le mode verbose a été activé pour afficher le log
    if [ "$VERBOSE" == "$TRUE" ]
    then
        
        print_log "$log" 

    fi 
    # enregistre au fichier des log
    save_log "$slog"

}

# créer un log de type debug avec le message passée
log_debug() {
    
    # avec la valeur de couleur ascii pour le terminal
    log=$( fmt_log "${CYAN}Debug${NO_COLOR}" " $@" "$TRUE" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "Debug" " $@" "$TRUE" )
    # regarde si le mode verbose a été activé pour afficher le log
    if [ "$VERBOSE" == "$TRUE" ]
    then

        print_log "$log"

    fi 
    # enregistre au fichier des log
    save_log "$slog"

}

# créer un log de type warn avec le message passée
log_warn() {

    # avec la valeur de couleur ascii pour le terminal
    log=$( fmt_log "${YELLOW}Warn${NO_COLOR}" "  ${@}" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "Warn" "  ${@}" )
    # log de type warn sont toujours afficher à l'écran
    print_log "$log"
    # enregistre au fichier des log
    save_log "$slog"

}

# créer un log de type error avec le message passée
log_error() {

    log=$( fmt_log "${RED}Error${NO_COLOR}" " ${@}" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "Error" " ${@}" )
    # log de type error sont toujours afficher à l'écran
    print_log "$log"
    # enregistre au fichier des log
    save_log "$slog"

}

# créer un log de type fatal avec le message passée
log_fatal() {

    # avec la valeur de couleur ascii pour le terminal
    log=$( fmt_log "${RED}FATAL${NO_COLOR}" " ${@}" )
    # sans la valeur de couleur ascci pour le fichier
    slog=$( fmt_log "FATAL" " ${@}" )
    # log de type fatal sont toujours afficher à l'écran
    print_log "$log"
    save_log "$slog"
    
    exit -1

}

#
#
# -------------------------------------------------------------------------------------------------
# utilité
#

# affiche le mode d'emploi du script
print_help() {


    echo "
    Usage: dev2.sh [OPTION]

        -h, --help              affiche se message
        -v, --verbose           affiche les debug et trace logs dans le terminal
        -u, --users             fichier avec les nom d'utilisateur à faire la sauvegarde
        -f, --home-directory    specifier un emplacement different ou les dossiers
                                home des employées se trouve
    "


}

# retourne la taille du fichier passé 
get_file_size() {

    echo $( stat -c %s "$1" )

}


# s'assure que tout les argument passées au script sont valide et bien utilisé
validate_script_args() {
    
    # s'assure qu'au moin un argument est passée au script
    if [ $# -lt 1 ]
    then

        log_warn "aucun argument passer au script"
        
        print_help

        exit 0

    fi

    
    while (($#));
    do

        case "$1" in
            # affiche le mode d'emploie
            "-h" | "--help")
                print_help
                exit 0;;
            # active le mode verbose            
            "-v" | "--verbose")
                VERBOSE=$TRUE;;
            # assigne le fichier qui contient le nom des utilisateurs
            "-u" | "--users")
                # passe au prochain argument pour capture le chemin du fichier
                shift 
                # regarde que le fichier existe
                if [ ! -e "$1" ]
                then

                    log_fatal "fichier ou dossier: $1 n'existe pas"
                   
                fi 

                USER_FILE="$1";;
            # assigne un dossier home différent que /home
            "-f" | "--home-directory")
                # passe au prochain argument pour capture le chemin du fichier
                shift
                # regarde que le chemin est vers un dossier et existe
                if [ -d "$1" ] && [ -e "$1" ]
                then 
                    HOME_DIR=$1
                else 
                    log_fatal "chemin invalide: $1 assurer de passer un chemin vers un dossier existant"
                    
                fi;;
            # tout autre parametre invalide passé
            *) 
                log_fatal "invalide argument: '$1' dev.sh -h pour voir les arguments supporté";;


        esac 


        # avance au prochain parametre
        shift

    done 


    # s'assure qu'un fichier contenant les noms des utilisateurs existe
    if [ "$USER_FILE" == "" ]
    then

        log_fatal "vous n'avez pas passé de fichier contenant les noms d'utilisateurs. voir dev.sh -h pour plus d'info"

    fi 

    log_trace "la validation des arguments du script est finit"

}

# capture tout les chemins possible dans le dossier passé 
get_all_path() {
    
    log_trace "commence à ramasser tout les chemin possible dans le home dossier ${@}"

    
    files=()
    directory=("$@")
    
    finish=$FALSE
    i=0 

    while [ "$finish" != "$TRUE" ]
    do 
        
        if [ $i -ge ${#directory[@]} ]
        then
        
            log_trace "tout les dossiers et sous dossiers ont été visités"
        
            finish=$TRUE
    
        else 

            found=$FALSE

            log_debug "dossier actuelle: ${directory[i]}"

            # capture tout le contenu du dossier actuelle dans la liste
            dirlist=(${directory[$i]}/*)

            for ((x=0;x<=${#dirlist[@]};x++))
            do

                entry=${dirlist[$x]}
                
                
                if [ ! -z $entry ]
                then 
                    # si l'entré pointe vers un dossier et qu'il n'a pas déja été ajouté
                    if [ -d $entry ] && [[ ! " ${directory[*]} " =~ " ${entry} " ]] 
                    then

                        found=$TRUE
                        log_debug "dossier trouvé: $entry"
                        # ajoute le dossier à la fin des autres pour etre visité 
                        # plus tard
                        directory+=("$entry")

                    # si l'entré pointe vers un fichier et qu'il n'a pas déja été ajouté
                    elif [ -f $entry ] && [[ ! " ${files[*]} " =~ " ${entry} " ]] 
                    then 

                        found=$TRUE
                        log_debug "fichier trouvé: $entry"
                        files+=("$entry")

                    # si l'entré pointe vers un lien symbolique et qu'il n'a pas déja été ajouté 
                    elif [ -h $entry ] && [[ ! " ${files[*]} " =~ " ${entry} " ]]
                    then

                        found=$TRUE
                        log_debug "lien symbolique trouvé: $entry"
                        files+=("$entry")

                    fi
                fi 

            done 

            # si la valeur '$found' n'a pas été changé, sa veux dire que tout les élément du 
            # dossier présent ont été ajouté et donc on peut passé au prochain dossier  
            if [ "$found" != "$TRUE" ]
            then
          
                log_debug "collecter tout le contenu du dossier: ${directory[i]}"
                i=$(( i + 1 ))

            fi 
        fi 

    done 

    # met les chemins des dossiers et fichiers enssemble
    paths=( "${directory[@]}" "${files[@]}" )
   

    log_info "stat dossier: $1
    ${WHITESPACE} - nombre de dossier(s): $(( ${#directory[@]} - 1 ))
    ${WHITESPACE} - nombre de fichier(s): ${#files[@]}"

    echo "${paths[@]}"

}

# créer une sauvegarde tar compresser avec tout les chemin passé
# $1 -> liste de chemins à copier
# $2 -> nom de l'utilisateur à qui le dossier appartient 
save_dir() {

    log_trace "commence la sauvegarde des dossiers et fichiers de: $1"
    
    paths=$2
    name=$1
    userdir="$HOME_DIR/$name"
    
    # s'assure que le dossier de l'utilisateur existe
    if [ ! -e $userdir ]
    then

        log_error "le dossier de l'utilisateur n'existe pas, aucune sauvegarde sera fait"

    else 

        # compteur dans le but d'affichage
        fSuccess=0
        fFailure=0
        dSuccess=0
        dFailure=0


        destination="$SAVE_DIR/$1" 

        # s'assure que la destination de la sauvegarde existe
        if [ ! -e $destination ]
        then 

            log_debug "première sauvegarde pour $name"
            mkdir -p $destination

        fi 

        save_dest=$destination/$( date +"save-%y-%m-%d.tar" )
        # cré un archive tar avec le nom de la date du jour 
        tar -cf $save_dest >/dev/null 2>&1

        for path in ${paths[@]}
        do 

            relativePath=${path#${userdir}}

            if [ ! -z "$relativePath" ]
            then 
                # pour les chemin pointant un dossier
                if [ -d $path ]
                then
                    # copie le dossier vers l'archive sans le dossier root du chemin
                    # exemple: /home/bob/chemin/vers/dossier/ sera /chemin/vers/dossier/
                    if tar --directory=$userdir -rf $save_dest "${relativePath:1}" >/dev/null 2>&1; then

                        log_info "transfert du dossier: '$path' à réussie"
                        dSuccess=$(( dSuccess + 1 ))

                    else 

                        log_error "tranfert du dossier: '$path' à echoué"
                        dFailure=$(( dFailure + 1 ))

                    fi 
                # pour les chemin pointant un fichier
                elif [ -f $path ]
                then
                    # copie le fichier vers l'archive sans le dossier root du chemin
                    # exemple: /home/bob/chemin/vers/fichier/ sera /chemin/vers/fichier/
                    if tar -C $userdir -rf $save_dest "${relativePath:1}" >/dev/null 2>&1; then 

                        log_info "transfert du fichier: '$path' réussie"
                        fSuccess=$(( fSuccess + 1 ))

                    else

                        log_info "transfert du dossier: '$path' à échoué"
                        fFailure=$(( fFailure + 1 ))

                    fi 
                # pour les chemin pointant un lien symbolique
                elif [ -h $path ]
                then
                    # s'assure qu'il ne s'agit pas d'un lien brisée
                    if [ -e $path ]
                    then    

                        log_debug "'$path' est un valide lien symbolique"

                        # copie le lien symbolique vers l'archive sans le dossier root du chemin
                        # exemple: /home/bob/chemin/vers/lien/ sera /chemin/vers/lien/
                        if tar -C $userdir -rf $save_dest "${relativePath:1}" >/dev/null 2>&1;
                        then     
                            log_info "transfert du lien symbolique: $path à réussi"

                            fSuccess=$(( fSuccess + 1))

                        else

                            log_info "transfert du lien symbolique: $path à echoué"

                            fFailure$(( fFailure + 1 ))

                        fi 

                    else 

                        log_error "'$path' est un invalide lien symbolique. il va etre ignoré"
                        fFailure=$(( fFailure + 1 ))
                    
                    fi     
                fi
            fi

        done

        log_info "copie du contenu du dossier: '$userdir' finis
        stats:
            - fichier -> $fSuccess réussie, $fFailure échoué
            - dossier -> $dSuccess réussie, $dFailure échoué"

        log_info "la taille de l'achive: $( get_file_size $save_dest )"

        # compresse l'archive tar
        if ! gzip -9 $save_dest >/dev/null 2>&1;
        then 

            log_error "la compression de l'archive '$save_dest' a echoue"
            log_warn  "l'archive '$save_dest 'ne sera pas compresser"

        else 
            log_info "la taille de l'archive compressé: $( get_file_size $save_dest.gz )"

        fi
    fi 

    log_trace "sauvegarde de l'utilisateur $name à finit"

}

#
#
# -------------------------------------------------------------------------------------------------
# Le script
# 

main() {

    log_status "commence"

    # s'assure que le script est executé par root
    if [ "$EUID" != "0" ]
    then

        log_fatal "le script n'a pas été executer par root"

    fi 

    
    # suprime le fichier avec les logs si existe déja
    if [ -e "$LOG_FILE" ]
    then

        rm $LOG_FILE
      
    fi 

    # crée le fichier des logs
    touch $LOG_FILE

    # s'assure que le dossier des sauvegarde existe
    if [ ! -d $SAVE_DIR ]
    then

        log_debug "la destination des sauvegarde n'existe pas, il sera creer"

        mkdir $SAVE_DIR

    fi 

    # valide les argument passé au script
    validate_script_args $@

    # regarde chaque ligne du fichier avec le nom des utilisateur
    while read -r line;
    do

        log_debug "traitement de l'utilisateur: '$line' à commencée"
        
        # s'assure que l'utilisateur existe
        if ! id "$line" >/dev/null 2>&1;
        then
            
            log_warn "l'utilisateur '$line' n'existe pas, il sera ignoré"
        
        else

            # capture tout les chemins possible de son dossier
            paths=$( get_all_path "$HOME_DIR/$line" )
            # créé une archive compressé
            save_dir "$line" "${paths[@]}"


        fi 

    done < "$USER_FILE"

    log_status "execution terminé"

}


# se qui serra exécuté
main $@


