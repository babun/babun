#!/bin/bash
filename="$1"

echo "Fixing broken symlinks"

while read -r line
do
    path=$(cygpath --windows "$line")
    slashpath=${path//\\//}
    echo "attrib +s '$slashpath'"
    bash --login "attrib +s $slashpath"
done < "$filename"
