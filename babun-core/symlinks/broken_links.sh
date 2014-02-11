#!/bin/bash
filename="$1"

echo "Fixing broken symlinks"


i=0
while read -r line
do
    echo "<- $line"
    path=$(cygpath --windows "$line")
    slashpath=${path//\\//}
    array[ $i ]=$slashpath
    (( i++ ))    
done < "$filename"


for path in "${array[@]}"
do
  echo "-> $path"
  cmd /c "attrib" "+s" "$path"
done
