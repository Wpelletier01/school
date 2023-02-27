


# Color Value
#
RED='\033[0;31m'
GREEN='\x1b[32m'
CYAN='\x1b[36m'
YELLOW='\x1b[33m'
NO_COLOR='\033[0m'





validate_type() {

    case "$1" in 

    "Info" | "info")

        echo "Info";;

    "Status" | "status")
        echo "${GREEN}Status${NO_COLOR}";;
    
    "Debug" | "debug" )
        echo "${CYAN}Debug${NO_COLOR}";;

    "Error" | "error" )
        echo "${RED}Error${NO_COLOR}";;
    
    "Warn" | "warn" )
        echo "${YELLOW}Warn${NO_COLOR}";;
    
    *)
        echo "Invalid log type: $1" >&2
        exit -1;;

    esac

}
#



fmt_log() {

    type=$( validate_type $1 )

    echo -e $( date +"[ %y/%m/%d | %H:%M:%S ]" ) [ $type ] $2



}


fmt_log "error" "this is a error" 






