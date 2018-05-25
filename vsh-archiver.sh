#!/bin/bash

# Description: Script that generate an archive of a selected directory
# Authors: /
# Version: 1.0

set -euo pipefail

## Parameters checkin'
if [ $# -gt 1 ]; then
	echo "USAGE='$0 <DIRECTORY to archive>'"
	echo "Put no arguments if you want the script to create a test folder directly in your current directory"
	exit 1
elif [ $# -eq 1 ] && [ "$1" = "." ]; then
	set "../$(basename `pwd`)"
fi

#### FONCTIONS
function Check-Exemple() {
	if [ -e Exemple ]; then
		echo "An Exemple directory already exist"
		exit 1
	elif [ -e Exemple.arch ]; then
		echo "An Exemple.arch file already exist"
		exit 1
	fi
}

# Exemple structure-tree generation
function Exemple-tree-generation() {
	mkdir Exemple
	mkdir Exemple/Test
	mkdir Exemple/Test/A Exemple/Test/B
	echo "#toto1.txt" > Exemple/Test/A/toto1.txt 
	echo "#toto2.txt" > Exemple/Test/A/toto2.txt
	mkdir Exemple/Test/A/A1 Exemple/Test/A/A2 Exemple/Test/A/A3
	echo "#toto3.txt" > Exemple/Test/A/toto3.txt
	echo "#toto4.txt" >  Exemple/Test/A/A1/toto4.txt
	echo -e "#bar.txt\nLorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor." > Exemple/Test/B/bar.txt
	echo "log - Test directories successfully created in the `pwd` folder"
}

# fonction récursive qui parcours l'arborescence et génère les parties header et body
function recursive() {
	count=$2;
	sedProof=$(echo $3 | sed -e 's/\//\\&/g')
	echo "directory $1" | sed -e "s/$sedProof//" >> /tmp/.header
	dirs=''
	for file in $(ls -a -I . -I .. $1); do
		#ls -ld donne des informations sur le dossier lui meme
		#du -b, disk usage of the set of FILEs, recursively, in byte
		echo -n $file $(ls -dl $1/$file | awk '{print $1}') $(du -bs $1/$file | awk '{print $1}') >> /tmp/.header
		if [ -d $1/$file ]; then
			dirs="$dirs $file"
			echo >> /tmp/.header
		else
			fileLength=$(wc -l $1/$file | awk '{print $1}')
			echo " $count $fileLength" >> /tmp/.header
			count=$(($count+$fileLength))
			cat $1/$file >> /tmp/.body
		fi
	done
	echo @ >> /tmp/.header
	for file in $dirs; do
		recursive $(echo $1/$file $count | sed 's/\/\//\//g') $3
	done
}

#suppression des fichiers temporaires
function nettoyage() {
	rm /tmp/.body /tmp/.header
}

#### PROCESS

# Commande par défaut, génère une arborescence de test si possible
if [ $# -eq 0 ]; then
	Check-Exemple
	Exemple-tree-generation
	set "Exemple"
fi

## Variables
mainDir="./$1"
outFile=$mainDir
# Temp. Body & Header creation
echo -n '' > /tmp/.body
echo -n '' > /tmp/.header


# Check if selected directory exist and is a directory
if [ ! -d $1 ]; then
	echo "The selected directory does not exist/is not a directory"
	echo "Please try again"
	exit 1
fi

while [ "${outFile: -1}" = "/" ]; do
	outFile=${outFile:0:$((${#outFile}-1))}
done

outFile=$(sed 's/^.*\/\([^/]*\)$/\1/g' <<< $outFile)

origin=$(echo $mainDir | sed "s/^\(.*\)$outFile.*$/\1/")

recursive $mainDir 1 $origin

echo -e "3:$(($(wc -l /tmp/.header | awk '{print $1}')+3))\n" > $outFile.arch

# on place le contenu des fichiers temporaire dans notre archive
cat /tmp/.header >> $outFile.arch 
cat /tmp/.body >> $outFile.arch

trap nettoyage EXIT
echo "log - archive $outFile.arch successfully generated"

#Check process
echo "Archive in the current directory:"
ls | grep '.arch$'

exit 0