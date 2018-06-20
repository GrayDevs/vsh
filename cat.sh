#!/bin/bash

# Description
# Ce script utilise les fichiers suivants :
# /tmp/rep.txt
# /tmp/test.txt

set -euo pipefail

##########################################
#### FONCTION

function nettoyage (){ 
	rm /tmp/.header 
	rm /tmp/.body
}

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

# go_backward permet de gérer le retour en arrière via les ../
# $1 	fichier
# $2	CURRENT
function go_backward() {
	local cible="$1"
	local pere="$2"

	while [  "$(echo $cible | grep '^\.\.')" != "" ]; do
		cible=$(echo $cible | sed 's/^\.\.\(.*\)$/\1/g' | sed 's/^\///g')
		if [ "$pere" != "$RACINE" ]; then
			pere=$(echo $pere | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
		fi
	done
	
	rep=$(echo $pere/$cible | sed 's/\/$//g') #on normalise le répertoire désiré
	if [ "$rep" = "$RACINE" ]; then
		fichier="$RACINE"
	else
		fichier="$rep"
	fi
}

##########################################
##### PROCESS

fichier=$1
fichier=${fichier#./*}
test=$(echo $1 | awk -F/ '{print $1}')

#si l'argument commence par /, on passe en chemin absolue
if [ "${fichier:0:1}" = "/" ]; then
	fichier=$RACINE$fichier
elif [ "$test" = ".." ]; then # si cat .. ou cat ../...
	go_backward $fichier $CURRENT
else 
	fichier="$CURRENT/$fichier"
fi

#séparation des 2 parties
ligne1=$(head -1 $ARCHIVE)
debut_header=${ligne1%:*}
debut_body=${ligne1#*:}
fin_header=$(($debut_body -1))

#Création de fichier temporaires contenant chacun leur parties respective
sed -n "$debut_header,$fin_header p" $ARCHIVE >> /tmp/.header
sed -n "$debut_body,$ p" $ARCHIVE >> /tmp/.body
trap nettoyage EXIT #on prepare le nettoyage en cas d'erreur

listefich $ARCHIVE $CURRENT 
flag=0
for word in $(cat /tmp/test.txt); do
	if [ "$word" = "$fichier" ]; then 
		flag=1
	fi
done

if [ $flag -eq 1 ]; then
	lignefichier=$(grep '^'$fichier'' $ARCHIVE)
	testrep=$(echo $lignefichier | awk '{print $2}' | cut -c1)
	if [ "$testrep" = "d" ];then
		echo "la cible est un répertoire"
		exit 0
		echo bonjour
	else
		debut=$(echo $lignefichier | awk '{print $4}')
		finfich=$(echo $lignefichier | awk '{print $5}')
		if [ "$finfich" = "0" ];then
			echo "le fichier est vide"
		else
			finfich=$(($debut+$finfich-1))
			sed -n "$debut,$finfich p" /tmp/.body
		fi
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
			exit 0
		else
			debut=$(echo $lignefichier | awk '{print $4}')
			finfich=$(echo $lignefichier | awk '{print $5}')
			if [ "$finfich" = "0" ]; then
				echo "le fichier est vide"
			else
				finfich=$(($debut+$finfich-1))
				sed -n "$debut,$finfich p" /tmp/.body
			fi
		fi
	else 
		echo "le fichier n'existe pas"
	fi
fi


