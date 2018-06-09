#!/bin/bash

# Description :
# Ce script utilise les fichiers suivants :
# /tmp/rep.txt
# /tmp/test.txt

set -euo pipefail

#### FONCTION

# La fonction liste_fichier() permet de lister les fichier d'une répertoire
# $1	ARCHIVE
# $2	REPERTOIRE
function listefich() 
{
	arch=$1
	rep=$2

	touch /tmp/test.txt
	ligne=$(grep -n '^directory '$rep'' $arch | head -1 | cut -d: -f1)

	lignedel=$(grep -n '^@$' $arch | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$rep'$' /tmp/rep.txt | head -1 | cut -d: -f1)

	fin=$(echo $lignedel | cut -d: -f$n)

	nbligne=$(($fin-$ligne-1))
	echo $(cat $arch | head -$((fin-1)) | tail -$((nbligne))) > /tmp/test.txt

}

# La fonction testrep() test si un répertoire existe
# $1	REPERTOIRE
function test_rep() {

	flag=0
	testrep=$1
	while read ligne; do
		if [ "$ligne" = "$testrep" ];then
			flag=1
		fi
	done < /tmp/rep.txt
	
	if [ $flag -eq 1 ];then
		CURRENT=$testrep
		
	elif [ $flag -eq 0 ];then
		listefich $ARCHIVE $CURRENT
		if [ -z  /tmp/test.txt ];then
			echo "le répertoire est vide il n'y a pas de sous répertoire possible"
			exit 1
		fi
		
		for word in $(cat /tmp/test.txt); do
			if [ "$word" = "$repertoire" ];then

				while read ligne; do
					if [ "$ligne" = "$CURRENT/$repertoire" ];then
						flag=1
					fi
				done < /tmp/rep.txt

			fi
		done
			
		if [ $flag -eq 1 ];then
			CURRENT="$CURRENT/$repertoire"
		else
			echo "ce n'est pas un sous répertoire"
		fi

	fi
}

# La fonction change_directory effectue le changement de répertoire
# $1	REPERTOIRE
function change_directory() {
	# On récupère une liste des répertoire de l'archive qui nous sera utile pour les autres commandes
	grep '^directory' $ARCHIVE | sed 's/directory //g' > /tmp/rep.txt
	
	#grep '^directory' $ARCHIVE | awk '{print $2}' > /tmp/rep.txt

	# Actions selon le nombre d'arguments

	# si "cd" (retour à la racine)
	if [ $# -eq 0 ]; then 
		CURRENT=$RACINE

	#si "cd <>" (1 argument)
	elif [ $# -eq 1 ]; then

		repertoire=$1 #cd <repertoire>

		#si "cd /" (retour à la racine)
		if [ "$repertoire" = "/" ]; then 
			CURRENT=$RACINE
		else
			# récupère le nom du répertoire ou le champs précédant un éventuelle / 
			test=$(echo $repertoire | awk -F/ '{print $1}')

			#si "cd ..[/<...>]"
			if [ "$test" = ".." ]; then
				#si "cd ..", on remonte dans l'arborescence
				if [ "$repertoire" = ".." ]; then
					CURRENT=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
				else #sinon ("cd ../<...>")
					cible=$(echo $repertoire | sed 's/^\.\.\/\(.*\)$/\1/g')
					pere=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
					rep="$pere/$cible"
					test_rep $rep #appel de la fonction test_rep()
				fi
			#si "cd .[/<...>]"
			elif [ "$test" = "." ]; then
				#si "cd ./<...>"
				if [ "$repertoire" != "." ]; then
					cible=$(echo $repertoire | sed 's/^.\/\(.*\)$/\1/g')
					rep="$CURRENT/$cible"
					test_rep $rep
				fi
			#sinon
			else
				test_rep $repertoire
			fi
		fi
	else # Nombre d'argument > 1
		echo "il y a trop d'arguments" 
	fi

	rm /tmp/rep.txt #nettoyage
	echo "CURRENT : $CURRENT"
}

##### PROCESS
change_directory $arg
