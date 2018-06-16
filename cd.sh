#!/bin/bash

# Description : Script permettant le changement de répertoire (navigation dans une archive)
# Ce script utilise les fichiers suivants :
# /tmp/rep.txt
# /tmp/test.txt

set -euo pipefail

#### FONCTION

# La fonction liste_fichier() permet de lister les fichier d'une répertoire
# $1	ARCHIVE
# $2	REPERTOIRE
function liste_fich() {
	arch=$1
	rep=$2
	fichier="/tmp/rep.txt"

	touch /tmp/test.txt
	ligne=$(grep -n '^directory '$rep'' $arch | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $arch | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	n=$(grep -n '^'$rep'' $fichier | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f$n)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $arch | head -$((fin-1)) | tail -$((nbligne))) > /tmp/test.txt

}

# La fonction testrep() test si un répertoire existe
# $1	REPERTOIRE
function test_rep() {

	local flag=0
	local testrep=$1

	echo "debug 1 : $testrep"

	# test si le répertoire demandé correspond à un des répertoires existant dans l'archive
	# Utilisé en cas de chemin absolue
	while read ligne; do
		if [ "$ligne" = "$testrep" ];then
			flag=1
		fi
	done < /tmp/rep.txt
	echo "debug 2 : flag - $flag"


	if [ $flag -eq 1 ];then
		CURRENT=$testrep
	
	elif [ $flag -eq 0 ];then
		
		while read ligne; do
			if [ "$CURRENT/$testrep" = "$ligne" ]; then
				flag=1
			fi
		done < /tmp/rep.txt

		if [ $flag -eq 1 ]; then
			CURRENT="$CURRENT/$testrep"
		elif [ $flag -eq 0 ];then
			liste_fich $ARCHIVE $CURRENT
			if [ -z  /tmp/test.txt ];then
				echo "le répertoire est vide il n'y a pas de sous répertoire possible"
				exit 1
			fi

			for word in $(cat /tmp/test.txt); do
				if [ "$word" = "$testrep" ];then

					while read ligne; do
						if [ "$ligne" = "$CURRENT/$testrep" ];then
							flag=1
						fi
					done < /tmp/rep.txt

				fi
			done

		fi
	fi
}

# La fonction change_directory effectue le changement de répertoire
# $1	REPERTOIRE
function change_directory() {

	# Actions selon le nombre d'arguments
	# si "cd" (retour à la racine)
	if [ $# -eq 0 ]; then 
		CURRENT=$RACINE

	#si "cd <>" (1 argument)
	elif [ $# -eq 1 ]; then

		repertoire=$1 #cd <repertoire>

		#si "cd /" (retour à la racine)
		if [ "$repertoire" = "/" ] || [ "$repertoire" = "." ]; then 
			CURRENT=$RACINE
		else

			#si l'argument commence par ./ , on échappe le ./, sinon on ne fait rien
			repertoire=${repertoire#./*}

			#si l'argument commence par /, on passe en chemin absolue
			if [ "${repertoire:0:1}" = "/" ]; then
				repertoire=$RACINE$repertoire
			fi

			# récupère le nom du répertoire ou le champs précédant un éventuelle / 
			test=$(echo $repertoire | awk -F/ '{print $1}')

			#si "cd ..[/<...>]"
			if [ "$test" = ".." ]; then
				#si "cd ..", on remonte dans l'arborescence
				if [ "$repertoire" = ".." ]; then
					if [ "$CURRENT" = "$RACINE" ];then
						CURRENT=$CURRENT
					else
						CURRENT=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
					fi
				else #sinon ("cd ../<...>")
					cible=$(echo $repertoire | sed 's/^\.\.\/\(.*\)$/\1/g')
					pere=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
					rep="$pere/$cible"
					test_rep $rep #appel de la fonction test_rep()
				fi
			#sinon
			else
				echo "debug 0 : $repertoire, envoie dans testrep"
				test_rep $repertoire #appel de la fonction test_rep()
			fi
		fi
	else # Nombre d'argument > 1
		echo "il y a trop d'arguments" 
	fi

}

##### PROCESS
change_directory $arg