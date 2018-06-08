#!/bin/bash

#description: affiche le contenu du répertoire
# Parameters: 
# $1    REPERTOIRE (dont le contenu est à lister)

ARCHIVE="./Archive/test2.arch"
# On récupère une liste des répertoire de l'archive qui nous sera utile pour les autres commandes
grep '^directory' $ARCHIVE | sed 's/directory //g' > rep.txt
CURRENT=$(cat rep.txt | head -2 | tail -1)

set -euo pipefail

touch liste.txt
# VARIABLES

if [ $# -eq 1 ];then
	# On récupère le répertoire passé en argument
	REPERTOIRE=$(echo $1 | sed 's/\/$//g')
	test=$(echo $REPERTOIRE | awk -F/ '{print $1}')
	if [ "$test" = "." ]; then
	       if [ "$REPERTOIRE" = "." ];then
		       REPERTOIRE="$CURRENT"
	       else
			cible=$(echo $REPERTOIRE | sed 's/^.\/\(.*\)$/\1/g')
			REPERTOIRE="$CURRENT/$cible"
		fi
	elif [ "$test" = ".." ];then
		pere=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')

		if [ "$REPERTOIRE" = ".." ];then
			REPERTOIRE="$pere"
		else
			cible=$(echo $REPERTOIRE | sed 's/^\.\.\/\(.*\)$/\1/g')
			REPERTOIRE="$pere/$cible"
		fi
	else 
		REPERTOIRE="$CURRENT/$test"
	fi
elif [ $# -eq 0 ];then
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

cat $ARCHIVE | head -$(($fin-1)) | tail -$nbligne >> liste.txt  
touch listerep.txt
repl=""
while read ligne 
do
	first=$(echo $ligne | awk '{print $2}' | cut -c 4)
	second=$(echo $ligne | awk '{print $2}' | cut -c 1)
	if [ "$second" = "d" ]; then
		repl=$(echo $ligne | awk '{print $1}')
		echo "$repl/" >> listerep.txt
	elif [ "$first" = "x" ]; then
		repl=$(echo $ligne | awk '{print $1}')
		echo "$repl*" >> listerep.txt
	else
		repl=$(echo $ligne | awk '{print $1}')
		echo $repl >> listerep.txt
	fi
done < liste.txt

cat listerep.txt

rm liste.txt
rm listerep.txt

export CURRENT="Exemple/Test/"

exit 0