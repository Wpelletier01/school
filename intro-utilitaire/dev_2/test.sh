

root="filesys/ptremblay"
  
exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo $LIST | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
}


l=" filesys/ptremblay/5YUX8OISCO "

f=$( exists_in_list "$l" " "  "filesys/ptremblay/5YUX8OISCO" )


echo "$f"
