#!/bin/bash

archive="./Archive/test.arch"
#repertoire=$(echo $1 | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
#fichier=$(echo $1 | sed 's/\(.*\)\/\([A-Z a-z 0-9]*\)$/\2/g')
courant=$(cat rep.txt | head -1 | sed 's/\/$//g')
cible=$1


#séparation des parties

ligne1=$(head -1 $archive)
debut_header=${ligne1%:*}
debut_body=${ligne1#*:}
fin_header=$(($debut_body-1))

function listefich (){
	
	archivef=$1
	courantf=$2
	
	rm test.txt
	touch test.txt
	
	ligne=$(grep -n '^directory '$courantf'' $archivef | head -1 | cut -d: -f1)
	
	lignedel=$(grep -n '^@$' $archivef | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$courantf'' rep.txt | head -1 | cut -d: -f1)
	
	fin=$(echo $lignedel | cut -d: -f$n)
	
	nbligne=$(($fin-$ligne-1))
	
	echo $(cat $archivef | head -$((fin-1)) | tail -$((nbligne)) | awk '{print $1}') >test.txt
	
	
}

function supligne() {
	archivetest=$1
	fichierf=$2
	#on récupere le numéro de ligne du fichier dans l'archive
	nb=$(grep -n '^'$fichierf'' $archivetest | cut -d: -f1)
	
	#on récupere la ligne des information sur le fichier
	lignefichier=$(grep '^'$fichierf'' $archivetest)
	
	#on extrait la ligne du debut du fichier dans le body
	debutfich=$(echo $lignefichier | awk '{print $4}')

	#on recupère le nombre de lignes qui correspondent au fichier
	finfich=$(echo $lignefichier | awk '{print $5}')
	if [ $finfich -eq 0 ];then
		sed ''$nb's/.*//g' $archivetest > archive.arch
		cp archive.arch ./Archive/test.arch
	else
		
		finfich=$(($debutfich+finfich-1))
		debutrm=$((fin_header+debutfich))
		finrm=$((fin_header+finfich))
		
		#on remplace les ligne par des lignes vide
		sed -e ''$debutrm','$finrm's/.*//g' -e ''$nb's/.*//g' $archivetest > archive.arch
		cp archive.arch ./Archive/test.arch
	fi
}

function suprep() {
	
	archiverep=$1
	suprepertoire=$2
	suprepertoire2=$(echo $2 | sed 's/\//\\\//g')
	previous=$(echo $2 | sed 's/\(.*\)\/\([A-Z a-z 0-9]*\)$/\2/g')
	nbr=$(grep -n '^'$previous'' $archiverep | cut -d: -f1)
	
	listefich $archiverep $suprepertoire
	flagsup=0	
	if [ -s $(cat test.txt) ];then	
		echo "le repertoire est vide"
		sed 's/^directory '$suprepertoire2'$//g' $archiverep > archive.arch
		cp archive.arch ./Archive/test.arch
	else

		for word in $(cat test.txt)
		do
			supr="$suprepertoire/$word"
			supr2=$(echo $supr | sed 's/\//\\\//g')
			while read line
			do
				if [ "$supr" = "$line" ];then
					flagsup=1 		
				fi

			done < rep.txt

			if [ $flagsup -eq 1 ];then
				suprep $archiverep $supr
				sed -e 's/^directory '$supr2'$//g' > archive.arch
				cp archive .arch ./Archive/test.arch				
			else
				supligne $archiverep $word
			fi
		done
		sed -e 's/^directory '$suprepertoire2'$//g' -e ''$nbr's/.*//g' $archiverep > archive.arch
		cp archive.arch ./Archive/test.arch


	fi


}
#test si le fichier cible est un repertoire
flag=0
while read ligne
do
	if [ "$ligne" = "$cible" ];then
		flag=1	
	fi
done < rep.txt

#si c'est un fichier
if [ $flag -eq 0 ]; then
	#on sépare le fichier cible et son répertoire (s'il n'y a que le fichier de préciser, $repertoire=$fichier
	repertoire=$(echo $1 | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
	fichier=$(echo $1 | sed 's/\(.*\)\/\([A-Z a-z 0-9]*\)$/\2/g')
	listefich $archive $courant 
	flag2=0
	#on test si le fichier est dans le répertoire courant
	for word in $(cat test.txt);do
	
		if [ "$word" = "$fichier" ];then 
			flag2=1
		fi
	done
	#on supprime le fichier 
	if [ $flag2 -eq 1 ]; then
		echo "le fichier est dans le répertoire courant"
		supligne $archive $fichier

	fi
	#sinon on va tester si le répertoire est connu dans l'arboressence
	if [ $flag2 -eq 0 ]; then
		while read ligne
		do
			if [ "$ligne" = "$repertoire" ]; then
				flag2=1
			fi
		done < rep.txt
		#s'il est connu on va supprimer le fichier sinon on affiche un message d'erreur
		if [ $flag2 -eq 1 ]; then
			couranttest=$courant
			courant=$repertoire
			supligne $archive $fichier
			courant=$couranttest
		else
			echo "le fichier n'existe pas"
		fi

	fi
fi

#si le fichier cible est un répertoire
if [ $flag -eq 1 ];then
	suprep $archive $cible
fi
