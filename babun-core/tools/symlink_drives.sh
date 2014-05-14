#!/bin/bash

for d in /*
do
	if [[ "${#d}" -eq "2" ]]; then
		rm $d
	fi
done

for d in /cygdrive/*
do
	dirname=$(basename $d)
	ln -s "$d" "/$dirname"
done
