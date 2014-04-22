#!/bin/bash
#set -e -f -o pipefail -> don't use it
filename="/etc/postinstall/symlinks_broken.txt"

# verify if the file exist
if [ ! -f $filename ]; then
	echo "Cannot find file with broken symlinks: $filename"
	exit -1
fi

# read the content of the file
# cannot invoke attrib within the first read loop
# somehow the loop breaks after the first invocation of attrib
i=0
while read -r line
do
    array[ $i ]=$line
    (( i++ ))    
done < "$filename"

# set DOS SYSTEM flag on the symlink files
winroot=$(/bin/cygpath --windows /)
echo "Root folder -> $winroot"
for path in "${array[@]}"
do
  echo "Fixing symlink -> $path"
  winpath=$(/bin/cygpath --windows "$path")
  normpath=${winpath//\\//}
  cmd /c "attrib" "+s" "$normpath"
done