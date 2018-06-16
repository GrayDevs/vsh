#!/bin/bash

# Description : Script permettant le changement de répertoire (navigation dans une archive)
# Ce script utilise les fichiers suivants :
# /tmp/rep.txt
# /tmp/test.txt

set -euo pipefail

##########################################
#### FONCTION

# La fonction liste_fichier() permet de lister les fichier d'une répertoire
# $1	ARCHIVE
# $2	REPERTOIRE
function liste_fich() {
	local arch=$1
	local rep=$2
	local fichier="/tmp/rep.txt"

	local ligne=$(grep -n '^directory '$rep'' $arch | head -1 | cut -d: -f1)
	local lignedel=$(grep -n '^@$' $arch | cut -d: -f1)
	local lignedel=$(echo $lignedel | sed 's/ /:/g')
	local n=$(grep -n '^'$rep'' $fichier | head -1 | cut -d: -f1)
	local fin=$(echo $lignedel | cut -d: -f$n)
	local nbligne=$(($fin-$ligne-1))
	echo $(cat $arch | head -$((fin-1)) | tail -$((nbligne))) > /tmp/test.txt
	#cat $arch | head -$((fin-1)) | tail -$((nbligne)) | awk '{print $1}' > /tmp/test.txt
}

# La fonction testrep() test si un répertoire existe
# $1	REPERTOIRE
function test_rep() {

	local flag=0 #flag détermine si le répertoire est en chemin absolue ou non
	local testrep=$(echo $1 | sed 's/\/$//g') # on échappe l'éventuelle / en fin de répertoire

	# test si le répertoire demandé correspond à un des répertoires existant dans l'archive
	# Utilisé en cas de chemin absolue
	while read ligne; do
		if [ "$ligne" = "$testrep" ]; then
			flag=1
		fi
	done < /tmp/rep.txt

	# si chemin absolue et dossier existant
	if [ $flag -eq 1 ]; then
		CURRENT=$testrep
	# si chemin relatif (ou absolue mais dossier inexistant)
	elif [ $flag -eq 0 ]; then
		# meme test que précédemment
		while read ligne; do
			if [ "$CURRENT/$testrep" = "$ligne" ]; then
				flag=1 
			fi
		done < /tmp/rep.txt

		#si le dossier est trouvé
		if [ $flag -eq 1 ]; then
			CURRENT="$CURRENT/$testrep"
		#sinon, dossier non trouvé
		elif [ $flag -eq 0 ]; then

			liste_fich $ARCHIVE $CURRENT

#			if [ -z  /tmp/test.txt ]; then
#				echo "le répertoire est vide, il n'y a pas de sous répertoire possible"
#				exit 1
#			fi

			# Vérifie si le répertoire entré est un fichier
			for word in $(cat /tmp/test.txt); do
				if [ "$word" = "$testrep" ]; then
					flag=1
				fi
			done
			testrep=$(echo $testrep | sed "s%^$RACINE%%g")
			if [ $flag -eq 1 ]; then
				printf "cd: $testrep: Not a directory\n"
			else 
				printf "cd: $testrep: No such file or directory\n"
			fi
			
		fi
	fi
}

# go_backward permet de gérer le retour en arrière via les ../
# $1 	repertoire
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
		CURRENT=$RACINE
	else
		test_rep $rep #appel de la fonction test_rep()
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

		local repertoire=$1 #cd <repertoire>

		#si "cd /" (retour à la racine) 
		if [ "$repertoire" = "/" ]; then
			CURRENT=$RACINE
		#si "cd ." (on ne change rien)
		elif [ "$repertoire" = "." ]; then
			printf ""
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
				if [ "$repertoire" = ".." ] || [ "$repertoire" = "../" ]; then
					#si cd .. à la racine, on reste à la racine
					if [ "$CURRENT" = "$RACINE" ]; then
						CURRENT=$CURRENT
					# sinon, on remonte dans l'arborescence (on supprime ce qu'il y a après le dernière /)
					else
						CURRENT=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
					fi
				else #sinon ("cd ../<...>")
					go_backward $repertoire $CURRENT
				fi
			#sinon
			else
				test_rep $repertoire #appel de la fonction test_rep()
			fi
		fi
	else # Nombre d'argument > 1
		echo "il y a trop d'arguments"
	fi

}

##########################################
##### PROCESS
change_directory $arg