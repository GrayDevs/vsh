#!/bin/bash

archive="./Archive/test.arch"
fichier=$(echo $1 | cut -d. -f1)

courant=$(cat rep.txt | head -1 | sed 's/\/$//g')

contenu=""

#on créer une fonction qui va venir supprimer nos fichiers temporaires 
function nettoyage (){ 
	rm /tmp/.header 
	rm /tmp/.body
}

#séparation des 2 parties, body et header
ligne1=$(head -1 $archive)
debut_header=${ligne1%:*}
debut_body=${ligne1#*:}
fin_header=$(($debut_body -1))

#Création de fichier temporaires contenant chacun leur parties respective
sed -n "$debut_header,$fin_header p" $archive >> /tmp/.header
sed -n "$debut_body,$ p" $archive >> /tmp/.body

trap nettoyage EXIT #on prepare le nettoyage en cas d'erreur

#on créer une fonction qui va venir lister le contenu d'un répertoire (fonction tirer de la commande ls)
function listefich (){
	rm contenu.txt
	touch contenu.txt
	ligne=$(grep -n '^directory '$courant'' $archive | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$courant'' rep.txt | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f$n)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $archive | head -$((fin-1)) | tail -$((nbligne)) | awk '{print $0}' ) > contenu.txt
	
	
}

#on liste les fichier du repertoire
listefich $archive $courant 
flag=0
#on test si le fichier à afficher est dans le répertoire courant 
for word in $(cat contenu.txt)
do
	
	if [ "$word" = "$fichier" ]; then 
	
		flag=1
	fi
done
#si le fichier est dans le répertoire alors
if [ $flag -eq 1 ]; then
	#on récupère la ligne du correspondant au fichier dans le header de l'archive
	lignefichier=$(grep '^'$fichier'' $archive)
	#on récupère le numéro de ligne du début de fichier (dans le body)
	debut=$(echo $lignefichier | awk '{print $4}')
	#on récupère le nombre de lignes que contient le fichier
	finfich=$(echo $lignefichier | awk '{print $5}')
	#on calcul le numéro de ligne de fin du fichier (dans le body)
	finfich=$(($debut+$finfich-1))
	#on affiche les lignes correspondantes
	sed -n "$debut,$finfich p" /tmp/.body
#Si le fichier n'existe pas alors	
else
	echo "le fichier n'existe pas dans ce dossier"
fi
