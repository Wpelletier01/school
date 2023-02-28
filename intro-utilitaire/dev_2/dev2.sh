
# -------------------------------------------------------------------------------------------------
# Declaration
#
# Const
TRUE=1
FALSE=0
WHITESPACE="                                   "
#
# Script State 
DEBUG_MODE=$FALSE
HOME_DIR="/home"
USER_FILE=""
DESTINATION="/mnt/sauvegarde"
SCRIPT_LOCATION=""
#
# Color Value
RED='\033[0;31m'
GREEN='\x1b[32m'
CYAN='\x1b[36m'
YELLOW='\x1b[33m'
NO_COLOR='\033[0m'
BLUE='\x1b[34m'
#
#
# -------------------------------------------------------------------------------------------------
# Loggin
#

print_log() {

    echo -e "$( date +'[ %y/%m/%d | %H:%M:%S ]') [ $1 ] $2 " >&2

}


log_status() {

    print_log "${GREEN}Status${NO_COLOR}" "${@}"

}

log_info() {

    print_log "${GREEN}Info${NO_COLOR}" "  ${@}"

}

log_trace() {

    if [ "$DEBUG_MODE" == "$TRUE" ]
    then
        print_log "${BLUE}Trace${NO_COLOR}" " ${@}"
    fi

}

log_debug() {
    
    if [ "$DEBUG_MODE" == "$TRUE" ]
    then
        print_log "${CYAN}Debug${NO_COLOR}" " $@"
    fi 

}


log_warn() {

    print_log "${YELLOW}Warn${NO_COLOR}" "  ${@}"

}

log_error() {

    print_log "${RED}Error${NO_COLOR}" " ${@}"
    

}

log_fatal() {

    print_log "${RED}FATAL${NO_COLOR}" " ${@}"
    exit -1

}



#
#
# -------------------------------------------------------------------------------------------------
# utils
#

print_help() {


    echo "
    
    Usage: dev2.sh [OPTION]

        -h, --help              affiche se message
        -d, --debug-mode        active l'afichage des debug log
        -u, --users             fichier avec les nom d'utilisateur a faire la
                                sauvegarde
        -f, --home-directory    specifier un emplacement different ou les dossiers
                                home des employees se trouve
        
    "


}


validate_script_args() {

    
    while (($#));
    do

        case "$1" in

            "-h" | "--help")
                print_help
                exit 0;;

            "-d" | "--debug-mode")
                DEBUG_MODE=$TRUE
                log_trace "script validation start"
                log_debug "debug log enable";;

            "-u" | "--users")

                shift 

                if [ ! -e "$1" ]
                then

                    log_fatal "fichier ou dossier: $1 n'existe pas"
                   
                fi 

                USER_FILE="$1";;
            
            "-f" | "--home-directory")

                shift

                if [ ! -d "$1" ]
                then 
                    log_fatal "chemin invalide: $1 assurer de passer un chemin vers un dossier existant"
                else 
        
                    HOME_DIR=$1

                fi;;

            *) 
                log_fatal "invalide argument: '$1' dev.sh -h pour voir les arguments supporter";;


        esac 

        shift

    done 

    log_trace "finit la validation des arguments"

}


get_all_path() {
    
    log_trace "commencer a ramasser tout les chemin possible dans le home dossier ${@}"

    files=()
    directory=("$@")
    
    finish=$FALSE
    i=0 

    while [ "$finish" != "$TRUE" ]
    do 
    
        if [ $i -ge ${#directory[@]} ]
        then
        
            log_trace "tout les dossiers et sous dossiers ont ete visiter"
        
            finish=$TRUE
    
        else 

            found=$FALSE

            log_debug "dossier actuelle: ${directory[i]}"

            dirlist=(${directory[$i]}/*)

            for ((x=0;x<=${#dirlist[@]};x++))
            do

                entry=${dirlist[$x]}

                if [ ! -z $entry ]
                then 
                    if [ -d $entry ] && [[ ! " ${directory[*]} " =~ " ${entry} " ]] 
                    then

                        found=$TRUE
                        log_debug "dossier trouvé: $entry"
                        directory+=("$entry")


                    elif [ -f $entry ] && [[ ! " ${files[*]} " =~ " ${entry} " ]] 
                    then 

                        found=$TRUE
                        log_debug "fichier trouvé: $entry"
                        files+=("$entry")

                    fi
                fi 
            done 

            if [ "$found" != "$TRUE" ]
            then
          
                log_debug "collecter tout le contenu du dossier: ${directory[i]}"
                i=$(( i + 1 ))

            fi 


        fi 

    done 

    paths=( "${directory[@]}" "${files[@]}" )
   

    log_info "dossier: $1\n${WHITESPACE}   nombre de dossier: $(( ${#directory[@]} - 1 ))\n${WHITESPACE}   nombre de fichier: ${#files[@]}"

    echo "${paths[@]}"

}


save_dir() {


    log_trace "commencer la sauvegarde des dossiers et fichiers"
    
    paths=$2
    name=$1
    root="$HOME_DIR/$name"

    fSuccess=0
    fFailure=0
    dSuccess=0
    dFailure=0

    destination="$DESTINATION/$1" 
    
    if [ ! -e $destination ]
    then 

        log_debug "premiere sauvegarde pour $name"
        mkdir -p $destination

    fi 

    save_dest=$destination/$( date +"save-%y-%m-%d.tar" )
    
    touch $save_dest

    for path in ${paths[@]}
    do 

        rpath=${path#${root}}
    

        if [ ! -z "$rpath" ]
        then 

            if [ -d $path ]
            then

                if tar --directory=$root -rf $save_dest "${rpath:1}" >& /dev/null; then

                    log_info "transfert du dossier: '$path' reussie"
                    dSuccess=$(( dSuccess + 1 ))

                else 

                    log_error "tranfert du dossier: '$path' echoue"
                    dFailure=$(( dFailure + 1 ))

                fi 


            elif [ -f $path ]
            then

                if tar -C $root -rf $save_dest "${rpath:1}"; then 

                    log_info "transfert du dossier: '$path' reussie"
                    fSuccess=$(( fSuccess + 1 ))

                else

                    log_info "transfert du dossier: '$path' a echoue"
                    fFailure=$(( fFailure + 1 ))

                fi 
            fi
        fi

    done 


}



#
#
# -------------------------------------------------------------------------------------------------
# Le script
# 

main() {

    log_status "start"

    if [ "$EUID" != "0" ]
    then
        log_fatal "le script n'a pas ete executer par root"

    fi 


    if [ $# -lt 1 ]
    then

        log_warn "aucun argument passer au script"
        
        print_help

        exit 0

    fi

    if [ ! -d $DESTINATION ]
    then

        log_debug "destination n'existe pas, il sera creer"

    fi 


    validate_script_args $@

    paths=$( get_all_path "/home/workspace/ptremblay" )
    
    save_dir "ptremblay" "${paths[@]}"

    log_status "finish"

}



main $@