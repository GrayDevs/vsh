#!/bin/bash

# Description: affiche le contenu du répertoire 
# $1    REPERTOIRE (dont le contenu est à lister)
# Ce script utilise les fichiers suivants :
# /tmp/rep.txt
# /tmp/liste.txt
# /tmp/listerep.txt

set -euo pipefail

# Création des fichiers nécessaire au script
touch /tmp/liste.txt
touch /tmp/listerep.txt

##########################################
#### FUNCTION

function nettoyage() {
	rm /tmp/liste.txt
	rm /tmp/listerep.txt
}

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

#La fonction afficher permet d'afficher le contenu d'un répertoire
function afficher() {
	# On récupère le numéro de la ligne correspondant au répertoire à lister
	ligne=$(grep -n '^directory '$repertoire'' $ARCHIVE | head -1 | cut -d: -f1)

	# On récupère les numéro de ligne ne contenant que des @ qui délimite les répertoire dans le header
	lignedel=$(grep -n '^@$' $ARCHIVE | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')

	# On récupère la position du répertoire dans la liste de tout les repertoires
	n=$(grep -n '^'$repertoire'' /tmp/rep.txt | head -1 | cut -d: -f1)
	# On déduit la dernière ligne en récupérent le numéro de la ligne du @ correspondant au répertoire à lister
	fin=$(echo $lignedel | cut -d: -f$n)

	# On calcul ensuite le nombre de ligne à afficher
	nbligne=$(($fin-$ligne-1))
	if [ $nbligne -eq 0 ];then
		echo "le repertoire demandé est vide"
	else
		# On récupère ces lignes dans l'archive et on les affiches
		cat $ARCHIVE | head -$(($fin-1)) | tail -$nbligne >> /tmp/liste.txt  
		touch /tmp/listerep.txt
		repl=""
		while read ligne 
		do
			first=$(echo $ligne | awk '{print $2}' | cut -c 4)
			second=$(echo $ligne | awk '{print $2}' | cut -c 1)
			if [ "$second" = "d" ]; then
				repl=$(echo $ligne | awk '{print $1}')
				echo "$repl/" >> /tmp/listerep.txt
			elif [ "$first" = "x" ]; then
				repl=$(echo $ligne | awk '{print $1}')
				echo "$repl*" >> /tmp/listerep.txt
			else
				repl=$(echo $ligne | awk '{print $1}')
				echo $repl >> /tmp/listerep.txt
			fi
		done < /tmp/liste.txt
		cat /tmp/listerep.txt
	fi
}

# La fonction testrep() test si un répertoire existe
# $1	repertoire
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
		repertoire=$testrep
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
			repertoire="$CURRENT/$testrep"
		#sinon, dossier non trouvé
		elif [ $flag -eq 0 ]; then
			# Vérifie si le répertoire entré est un fichier
			liste_fich $ARCHIVE $CURRENT
			for word in $(cat /tmp/test.txt); do
				if [ "$word" = "$testrep" ]; then
					flag=1
				fi
			done
			testrep=$(echo $testrep | sed "s%^$RACINE%%g")
			if [ $flag -eq 1 ]; then
				printf "ls: $testrep: Not a directory\n"
			else 
				printf "ls: $testrep: No such file or directory\n"
			fi
			exit 0 # On quitte
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
		repertoire="$RACINE"
	else
		repertoire="$rep"
	fi
}

##########################################
#### PROCESS

trap nettoyage EXIT

if [ $# -eq 0 ]; then
	repertoire="$CURRENT"
elif [ $# -eq 1 ]; then
	# On récupère le répertoire passé en argument
	repertoire=$1
	#repertoire=$(echo $1 | sed 's/\/$//g') # supprime l'éventuelle / enfin de ligne
	#si "ls /" (retour à la racine) 
	if [ "$repertoire" = "/" ]; then
			repertoire="$RACINE"
	#si "cd ." (on ne change rien)
	elif [ "$repertoire" = "." ]; then
		repertoire="$CURRENT"	
	else
		#si l'argument commence par ./ , on échappe le ./, sinon on ne fait rien
		repertoire=${repertoire#./*}
		# récupère le nom du répertoire ou le champs précédant un éventuelle / 
		test=$(echo $repertoire | awk -F/ '{print $1}') # (./, ../, etc)
		#si l'argument commence par /, on passe en chemin absolue
		if [ "${repertoire:0:1}" = "/" ]; then
			repertoire=$RACINE$repertoire
		elif [ "$test" = ".." ]; then # si ls .. ou ls ../...
			go_backward $repertoire $CURRENT
		else 
			repertoire="$CURRENT/$1"
		fi
	fi
else 
	echo "il faut 0 ou 1 argument qui sera le répertoire à lister"
	exit 0
fi

# si on n'est pas certain que le répertoire cible existe
if [ "$repertoire" != "$CURRENT" ] && [ "$repertoire" != "$RACINE" ]; then
	test_rep $(echo $repertoire | sed 's/\/$//g') # appel de la fonction de vérification
fi
afficher #on affiche le résultat

exit 0