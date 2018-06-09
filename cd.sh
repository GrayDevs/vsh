#!/bin/bash

courant="Exemple/Test/A"
ARCHIVE="./Archive/test2.arch"


# On récupère une liste des répertoire de l'archive qui nous sera utile pour les autres commandes
grep '^directory' $ARCHIVE | sed 's/directory //g' > rep.txt
touch liste.txt
#grep '^directory' $ARCHIVE | awk '{print $2}' > rep.txt

function listefich() 
{
	arch=$1
	rep=$2
	rm test.txt
	touch test.txt
	ligne=$(grep -n '^drirectory '$rep'' $arch | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $arch | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')

	n=$(grep -n '^'$rep'$' rep.txt | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f$n)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $1 | head -$((fin-1)) | tail -$((nbligne))) > test.txt

}

function testrep()
{
	testrep=$1
	flag2=0
	while read ligne
	do
		if [ "$ligne" = "$testrep" ];then
			flag2=1
		fi
	done < rep.txt
	if [ $flag2 -eq 1 ];then
		courant=$testrep
	else 
		echo "le répertoire n'existe pas"				
	fi

}

if [ $# -eq 0 ];then
	courant=$(cat rep.txt | head -1 | sed 's/\/$//g')

elif [ $# -eq 1 ];then
	repertoire=$1


	if [ "$repertoire" = "/" ];then
		courant=$(cat rep.txt | head -1 | sed 's/\/$//g')
	fi

	test=$(echo $repertoire | awk -F/ '{print $1}')
	
	if [ "$test" = ".." ]; then
		if [ "$repertoire" = ".." ];then
		
			courant=$(echo $courant | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')

		else 
			cible=$(echo $repertoire | sed 's/^\.\.\/\(.*\)$/\1/g')
			pere=$(echo $courant | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
			rep="$pere/$cible"
			testrep $rep
		fi
			
			
	elif [ "$test" = "." ];then
		if [ "$repertoire" = "." ];then
			echo "préciser un sous répertoire apres le . "
		else 
		
			cible=$(echo $repertoire | sed 's/^.\/\(.*\)$/\1/g')
			rep="$courant/$cible"
			testrep $rep
		fi
	
	else
		flag=0
		testrep $cible
		if [ $flag -eq 0 ];then
			listefich $archive $courant 
			if [ -z $(cat test.txt) ];then
				echo "le répertoire est vide"
				exit 1
			fi
			for word in $(cat test.txt)
			do
				if [ "$word" = "$cible" ];then
					while read ligne
					do
						if [ "$ligne" = "$courant/$cible" ];then
							flag=1
						fi
				
					done < rep.txt
				fi
			done
			if [ $flag -eq 1 ];then
				courant="$courant/$cible"
			else
				echo "ce n'est pas un sous répertoire"
			fi

		fi
	fi
else 
	echo "il y a trop d'arguments" 
fi

rm rep.txt
echo $courant
