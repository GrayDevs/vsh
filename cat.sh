#!/bin/bash

# Description
# Ce script utilise les fichiers suivants :
# /tmp/rep.txt
# /tmp/test.txt

set -euo pipefail

fichier=$1 
test=$(echo $1 | awk -F/ '{print $1}')
grep '^directory' $ARCHIVE | sed 's/directory //g' > /tmp/rep.txt


if [ "$test" = "." ];then
	cible=$(echo $fichier | sed 's/^.\/\(.*\)$/\1/g')
	fichier="$CURRENT/$cible"
elif [ "$test" = ".." ];then
	CURRENT=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
	cible=$(echo $fichier | sed 's/^\.\.\/\(.*\)$/\1/g')
	fichier="$CURRENT/$cible"
fi

function nettoyage (){ 
	rm /tmp/.header 
	rm /tmp/.body
}

#séparation des 2 parties

ligne1=$(head -1 $ARCHIVE)
debut_header=${ligne1%:*}
debut_body=${ligne1#*:}
fin_header=$(($debut_body -1))

#Création de fichier temporaires contenant chacun leur parties respective
sed -n "$debut_header,$fin_header p" $ARCHIVE >> /tmp/.header
sed -n "$debut_body,$ p" $ARCHIVE >> /tmp/.body

trap nettoyage EXIT #on prepare le nettoyage en cas d'erreur


function listefich (){
	touch /tmp/test.txt
	
	rep=$2
	ligne=$(grep -n '^directory '$rep'' $ARCHIVE | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $ARCHIVE | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$rep'' /tmp/rep.txt | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f$n)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $ARCHIVE | head -$((fin-1)) | tail -$((nbligne))) > /tmp/test.txt
}


listefich $ARCHIVE $CURRENT 
flag=0
for word in $(cat /tmp/test.txt)
do
	
	if [ "$word" = "$fichier" ]; then 
	
		flag=1
	fi
done

if [ $flag -eq 1 ]; then
	lignefichier=$(grep '^'$fichier'' $ARCHIVE)
	testrep=$(echo $lignefichier | awk '{print $2}' | cut -c1)
	if [ "$testrep" = "d" ];then
		echo "la cible est un répertoire"
		exit 1
	else
		debut=$(echo $lignefichier | awk '{print $4}')
		finfich=$(echo $lignefichier | awk '{print $5}')
		finfich=$(($debut+$finfich-1))
		sed -n "$debut,$finfich p" /tmp/.body
	fi
fi

if [ $flag -eq 0 ]; then
	repertoire=$(echo $fichier | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
	fichier=$(echo $fichier | sed 's/\(.*\)\/\([A-Z a-z 0-9]*\)$/\2/g')
	listefich $ARCHIVE $repertoire
	for word in $(cat /tmp/test.txt)
	do
		if [ "$word" = "$fichier" ];then
			flag=1
		fi
	done
	if [ $flag -eq 1 ];then
		lignefichier=$(grep '^'$fichier'' $ARCHIVE)
		testrep=$(echo $lignefichier | awk '{print $2}' | cut -c1)
		if [ "$testrep" = "d" ];then
			echo "la cible est un répertoire"
		else
			debut=$(echo $lignefichier | awk '{print $4}')
			finfich=$(echo $lignefichier | awk '{print $5}')
			finfich=$(($debut+$finfich-1))
			sed -n "$debut,$finfich p" /tmp/.body
		fi
	else 
		echo "le fichier n'existe pas"
	fi
fi


