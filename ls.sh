#!/bin/bash

# Description: affiche le contenu du répertoire 
# $1    REPERTOIRE (dont le contenu est à lister)

set -euo pipefail

# On récupère une liste des répertoire de l'archive qui nous sera utile pour les autres commandes
grep '^directory' $ARCHIVE | sed 's/directory //g' > rep.txt
touch liste.txt

if [ $# -eq 1 ]; then
	# On récupère le répertoire passé en argument
	REPERTOIRE=$(echo $1 | sed 's/\/$//g') # supprime l'éventuelle / enfin de ligne
	test=$(echo $REPERTOIRE | awk -F/ '{print $1}') # récupère les ./ et ../ éventuelles
	
	if [ "$test" = "." ]; then # si ls . ou ls ./...
	    if [ "$REPERTOIRE" = "." ]; then # si ls .
	       REPERTOIRE="$CURRENT"
        else # si ls ./...
			cible=$(echo $REPERTOIRE | sed 's/^.\/\(.*\)$/\1/g')
			REPERTOIRE="$CURRENT/$cible"
		fi
	elif [ "$test" = ".." ]; then # si ls .. ou ls ../...
		pere=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')

		#
		if [ "$REPERTOIRE" = ".." ]; then
			REPERTOIRE="$pere"
		else
			cible=$(echo $REPERTOIRE | sed 's/^\.\.\/\(.*\)$/\1/g')
			REPERTOIRE="$pere/$cible"
		fi

	else 
		REPERTOIRE="$CURRENT/$test"
	fi
elif [ $# -eq 0 ]; then
	REPERTOIRE="$CURRENT"
else 
	echo "il faut 0 ou 1 argument qui sera le répertoire à lister"
fi

# On récupère le numéro de la ligne correspondant au répertoire à lister
ligne=$(grep -n '^directory '$REPERTOIRE'' $ARCHIVE | head -1 | cut -d: -f1)

# On récupère les numéro de ligne ne contenant que des @ qui délimite les répertoire dans le header
lignedel=$(grep -n '^@$' $ARCHIVE | cut -d: -f1)
lignedel=$(echo $lignedel | sed 's/ /:/g')

# On récupère la position du répertoire dans la liste de tout les REPERTOIRE
n=$(grep -n '^'$REPERTOIRE'' rep.txt | head -1 | cut -d: -f1)
# On déduit la dernière ligne en récupérent le numéro de la ligne du @ correspondant au répertoire à lister
fin=$(echo $lignedel | cut -d: -f$n)

# On calcul ensuite le nombre de ligne à afficher
nbligne=$(($fin-$ligne-1))
# On récupère ces lignes dans l'archive et on les affiche

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

rm /tmp/liste.txt
rm /tmp/listerep.txt

exit 0