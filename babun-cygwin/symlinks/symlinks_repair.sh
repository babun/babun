#!/bin/bash
filename="/etc/postinstall/symlinks_broken.txt"

# verify if the file exist
echo "Fixing broken symlinks"
if [ ! -f $filename ]; then
	echo "Cannot find file with broken links: $filename"
	exit -1
fi

# read the content of the file
# cannot invoke attrib within the read loop
# somehow the loop breaks after the first invocation of attrib
i=0
while read -r line
do
    echo "<- $line"
    path=$(cygpath --windows "$line")
    slashpath=${path//\\//}
    array[ $i ]=$slashpath
    (( i++ ))    
done < "$filename"

# set DOS SYSTEM flag on the symlink files
for path in "${array[@]}"
do
  echo "-> $path"
  cmd /c "attrib" "+s" "$path"
done
