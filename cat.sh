#!/bin/bash

archive="./Archive/test.arch"
fichier=$1 
test=$(echo $1 | awk -F/ '{print $1}')
courant=$(cat rep.txt | head -2 | tail -1 | sed 's/\/$//g')

if [ "$test" = "." ];then
	cible=$(echo $fichier | sed 's/^.\/\(.*\)$/\1/g')
	fichier="$courant/$cible"
elif [ "$test" = ".." ];then
	courant=$(echo $courant | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
	cible=$(echo $fichier | sed 's/^\.\.\/\(.*\)$/\1/g')
	fichier="$courant/$cible"
fi

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
	
	rep=$2
	ligne=$(grep -n '^directory '$rep'' $archive | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$rep'' rep.txt | head -1 | cut -d: -f1)
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
	testrep=$(echo $lignefichier | awk '{print $2}' | cut -c1)
	if [ "$testrep" = "d" ];then
		echo "la cible est un répertoire"
		exit 1
	else
		debut=$(echo $lignefichier | awk '{print $4}')
		finfich=$(echo $lignefichier | awk '{print $5}')
		finfich=$(($debut+$finfich-1))
		sed -n "$debut,$finfich p" /tmp/.body
	fi
fi

if [ $flag -eq 0 ]; then
	repertoire=$(echo $fichier | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
	fichier=$(echo $fichier | sed 's/\(.*\)\/\([A-Z a-z 0-9]*\)$/\2/g')
	listefich $archive $repertoire
	for word in $(cat test.txt)
	do
		if [ "$word" = "$fichier" ];then
			flag=1
		fi
	done
	if [ $flag -eq 1 ];then
		lignefichier=$(grep '^'$fichier'' $archive)
		testrep=$(echo $lignefichier | awk '{print $2}' | cut -c1)
		if [ "$testrep" = "d" ];then
			echo "la cible est un répertoire"
			exit 1
		else
			debut=$(echo $lignefichier | awk '{print $4}')
			finfich=$(echo $lignefichier | awk '{print $5}')
			finfich=$(($debut+$finfich-1))
			sed -n "$debut,$finfich p" /tmp/.body
		fi
	else 
		echo "le fichier n'existe pas"
	fi
fi


