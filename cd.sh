#!/bin/bash

courant="Exemple/Test/A"
archive="./Archive/test.arch"
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
if [ $# -eq 0 ];then
	courant=$(cat rep.txt | head -1 | sed 's/\/$//g')
else 
	cible=$1
fi
if [ "$cible" = ".." ]; then
	courant=$(echo $courant | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
elif [ "$cible" = "/" ];then
	courant=$(cat rep.txt | head -1 | sed 's/\/$//g')
else
	flag=0
	while read ligne 
	do	
		if [ "$ligne" = "$cible" ];then
			flag=1
		fi
	done < rep.txt

	if [ $flag -eq 1 ];then
		courant="$cible"
		#echo $courant
	fi

	if [ $flag -eq 0 ];then
		listefich $archive $courant 
		for word in $(cat test.txt);do
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

echo $courant
