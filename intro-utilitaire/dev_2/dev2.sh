

# Const
#
TRUE=1
FALSE=0
#
#
# Script State
# 
DEBUG_MODE=$FALSE
HOME_DIR="/home/"
#
# 
# 

print_help() {

    


}


validate_script_args() {

    cpt=0

    for arg in "$@";
    do

        case "$arg" in
            "-h" | "--help")


            "-d" | "--debug-mode")
                DEBUG_MODE=$TRUE;;
            



        esac 



    done 


}