#!/bin/bash
filename="/etc/postinstall/symlinks_broken.txt"

# verify if the file exist
if [ ! -f $filename ]; then
	echo "Cannot find file with broken symlinks: $filename"
	exit -1
fi

# read the content of the file
# cannot invoke attrib within the read loop
# somehow the loop breaks after the first invocation of attrib
i=0
while read -r line
do
    array[ $i ]=$line
    (( i++ ))    
done < "$filename"

# set DOS SYSTEM flag on the symlink files
rootfolder=$(/bin/cygpath --windows /)
echo "Root folder -> $rootfolder"
for path in "${array[@]}"
do
  echo "Fixing symlink -> $path"
  winpath=$(/bin/cygpath --windows "$path")
  normpath=${winpath//\\//}
  cmd /c "attrib" "+s" "$normpath"
done