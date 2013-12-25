#!/bin/bash -f
x=$(/bin/cygpath.exe $(/bin/dirname.exe $0))
echo $x
/bin/cp.exe -r $x/src/* ~/
