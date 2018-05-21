#!/bin/bash

# Description: Script that generate an archive of a selected directory
# Authors: /
# Version: 1.0

set -e

# Parameters:
mainDir="./$1"

# Temp. Body & Header creation
echo -n '' > .body
echo -n '' > .header

# Parameters checkin'
if [ $# -gt 1 ]; then
	echo "USAGE='$0 <DIRECTORY to archive>'"
	echo "Put no arguments if you want the script to create a test folder directly in your current directory"
	exit 1
fi
	
# Test Directory Generation
if [ $# -eq 0 ]; then
	$1=`pwd`/Exemple
	mkdir Exemple
	mkdir Exemple/Test
	mkdir Exemple/Test/A Exemple/Test/B
	touch toto1.txt toto2.txt
	mkdir Exemple/Test/A/A1 Exemple/Test/A/A2 Exemple/Test/A/A3
	touch Exemple/Test/A/toto3.txt
	touch Exemple/Test/A/A1/toto4.txt
	echo "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor." > Example/Test/B/bar.txt
	echo "log - Test directories successfully created in the `pwd` folder"
fi

#Check if selected directory exist and is a directory
if [ ! -d $1 ]; then
	echo "The selected directory does not exist/is not a directory"
	echo "Please try again"
	exit 1
fi

function recursive()
{
	count=$2;
	sedProof=$(echo $3 | sed -e 's/\//\\&/g')
	echo "directory $1" | sed -e "s/$sedProof//" >> .header
	dirs=''
	for file in $(ls -a -I . -I .. $1); do
		echo -n $file $(ls -dl $1/$file | awk '{print $1}') $(du -s $1/$file | awk '{print $1}') >> .header
		if [ -d $1/$file ]; then
			dirs="$dirs $file"
			echo >> .header
		else
			fileLength=$(wc -l $1/$file | awk '{print $1}')
			echo " $count $fileLength" >> .header
			count=$(($count+$fileLength))
			cat $1/$file >> .body
		fi
	done
	echo @ >> .header
	for file in $dirs; do
		recursive $(echo $1/$file $count | sed 's/\/\//\//g') $3
	done
}

outFile=$mainDir

while [ "${outFile: -1}" = "/" ]; do
	outFile=${outFile:0:$((${#outFile}-1))}
done

outFile=$(sed 's/^.*\/\([^/]*\)$/\1/g' <<< $outFile)

origin=$(echo $mainDir | sed "s/^\(.*\)$outFile.*$/\1/")

recursive $mainDir 1 $origin

echo -e "3:$(($(wc -l .header | awk '{print $1}')+3))\n" > $outFile.arch

cat .header >> $outFile.arch
cat .body >> $outFile.arch

rm .body .header

echo "log - archive $outfile.arch successfully generated"
#Checking
echo "Archive in the current directory:"
ls | grep '.arch'

exit 0