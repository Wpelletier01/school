



test="test.txt"
link="the_link.txt"

if [ -f $link ]
then 

    echo "its not a broken symlink"
else 

    echo "its a broken symlink"

fi  