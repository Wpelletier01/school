
# -------------------------------------------------------------------------------------------------
# Declaration
#
# Const
TRUE=1
FALSE=0
WHITESPACE="                                   "
#
# Script State 
VERBOSE=$FALSE
DEBUG=$FALSE
HOME_DIR="/home"
USER_FILE=""
DESTINATION="/mnt/sauvegarde"
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

print_log() { echo -e "$1" >&2 }

save_log() { echo -e "$1" >> "sauvegarde.log" }

fmt_log() { echo "$( date +'[ %y/%m/%d | %H:%M:%S ]') [ $1 ] $2" }


log_status() {

    log=$( fmt_log "${GREEN}Status${NO_COLOR}" "${@}" )

    print_log $log
    save_log

}

log_info() {

    log=$( fmt_log "${GREEN}Info${NO_COLOR}" "  ${@}" )

    i
    

}

log_trace() {

    if [ "$DEBUG" == "$TRUE" ]
    then
        print_log "${BLUE}Trace${NO_COLOR}" " ${@}"
    fi

}

log_debug() {
    
    if [ "$DEBUG" == "$TRUE" && "$VERBOSE" == "$TRUE" ]
    then

        print_log "${CYAN}Debug${NO_COLOR}" " $@" "$TRUE"
    
    elif [ "$"]


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
        -v, --verbose           affiche dans le terminal les logs
        -t, --trace             active la prise en charge des trace log il seront afficher dans le terminal
                                si -v est passer et sera dans le fichier sauvegarde.log
        -d, --debug             active la prise en charge des debug log il seront afficher dans le terminal
                                si -v est passer et sera dans le fichier sauvegarde.log
        -u, --users             fichier avec les nom d'utilisateur a faire la sauvegarde
        -f, --home-directory    specifier un emplacement different ou les dossiers
                                home des employees se trouve
    "


}

get_file_size() {

    size=$( stat -c %s "$1" )

    echo $size

}



validate_script_args() {

    
    while (($#));
    do

        case "$1" in

            "-h" | "--help")
                print_help
                exit 0;;

            "-d" | "--debug-mode")
                DEBUG=$TRUE
                log_trace "script validation start"
                log_debug "debug log enable";;
            
            "-v" | "--verbose")
                VERBOSE=$TRUE;;

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


    if [ "$USER_FILE" == "" ]
    then
        log_fatal "vous n'avez pas passer de fichier contenant les nom d'utilisateur. voir dev.sh -h pour plus d'info"

    elif [ ! -e "$USER_FILE" ]
    then 

        log_fatal "le fichier des nom d'utilisateur n'existe pas, assurer vous que son chemin soit valide"

    fi 

    log_trace "la validation des arguments du script est finit"

}


get_all_path() {
    
    log_trace "commence a ramasser tout les chemin possible dans le home dossier ${@}"

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
   

    log_info "stat dossier: $1
    ${WHITESPACE} - nombre de dossier: $(( ${#directory[@]} - 1 ))
    ${WHITESPACE} - nombre de fichier: ${#files[@]}"

    echo "${paths[@]}"

}


save_dir() {


    log_trace "commencer la sauvegarde des dossiers et fichiers"
    
    paths=$2
    name=$1
    
    userdir="$HOME_DIR/$name"

    if [ ! -e $userdir ]
    then

        log_error "le dossier de l'utilisateur n'existe pas, aucune sauvegarde sera fait"

    else 
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

        tar -cf $save_dest >/dev/null 2>&1

        for path in ${paths[@]}
        do 

            relativePath=${path#${userdir}}

            if [ ! -z "$relativePath" ]
            then 

                if [ -d $path ]
                then

                    if tar --directory=$userdir -rf $save_dest "${relativePath:1}" >/dev/null 2>&1; then

                        log_info "transfert du dossier: '$path' reussie"
                        dSuccess=$(( dSuccess + 1 ))

                    else 

                        log_error "tranfert du dossier: '$path' echoue"
                        dFailure=$(( dFailure + 1 ))

                    fi 


                elif [ -f $path ]
                then

                    if tar -C $userdir -rf $save_dest "${relativePath:1}" >/dev/null 2>&1; then 

                        log_info "transfert du fichier: '$path' reussie"
                        fSuccess=$(( fSuccess + 1 ))

                    else

                        log_info "transfert du dossier: '$path' a echoue"
                        fFailure=$(( fFailure + 1 ))

                    fi 
                fi
            fi

        done

        log_info "copie du contenu du dossier: '$userdir' finis
        stats:
            - fichier -> $fSuccess reussie, $fFailure echouer
            - dossier -> $dSuccess reussie, $dFailure echouer"

        log_info "taille de l'achive avant la compression: $( get_file_size $save_dest )"

        if ! gzip -9 $save_dest >/dev/null 2>&1;
        then 

            log_error "la compression de l'archive '$save_dest' a echoue"
            log_warn  "l'archive '$save_dest 'ne sera pas compresser"

        else 
            log_info "taille de l'archive apres la compression: $( get_file_size $save_dest.gz )"

        fi



    fi 



    log_trace "sauvegarde de l'utilisateur $name finit"

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

        mkdir $DESTINATION

    fi 

    validate_script_args $@

    
    while read -r line;
    do
        log_debug "utilisateur: '$line'"

        if ! id "$line" >/dev/null 2>&1;
        then
            
            log_warn "l'utilisateur '$line' n'existe pas, il sera passe"
        
        else

            paths=$( get_all_path "$HOME_DIR/$line" )

            save_dir "$line" "${paths[@]}"


        fi 

    done < "$USER_FILE"

    log_status "execution finit"

}



main $@