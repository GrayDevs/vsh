#!/bin/bash

archive="./Archive/test.arch"
fichier=$(echo $1 | cut -d. -f1)

courant=$(cat rep.txt | head -1 | sed 's/\/$//g')

contenu=""

function nettoyage (){ 
	rm /tmp/.header 
	rm /tmp/.body
}

#séparation des 2 parties

ligne1=$(head -1 $archive)
debut_header=${ligne1%:*}
debut_body=${ligne1#*:}
fin_header=$(($debut_body -1))

#Création de fichier temporaires contenant chacun leur parties respective
sed -n "$debut_header,$fin_header p" $archive >> /tmp/.header
sed -n "$debut_body,$ p" $archive >> /tmp/.body

trap nettoyage EXIT #on prepare le nettoyage en cas d'erreur


function listefich (){
	touch test.txt
	ligne=$(grep -n '^directory '$courant'' $archive | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$courant'' rep.txt | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f$n)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $archive | head -$((fin-1)) | tail -$((nbligne))) > test.txt
	
	
}


listefich $archive $courant 
flag=0
for word in $(cat test.txt)
do
	
	if [ "$word" = "$fichier" ]; then 
	
		flag=1
	fi
done

if [ $flag -eq 1 ]; then
	lignefichier=$(grep '^'$fichier'' $archive)
	debut=$(echo $lignefichier | awk '{print $4}')
	finfich=$(echo $lignefichier | awk '{print $5}')
	finfich=$(($debut+$finfich-1))
	sed -n "$debut,$finfich p" /tmp/.body
else
	echo "le fichier n'existe pas dans ce dossier"
fi
