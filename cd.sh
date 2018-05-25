#!/bin/bash

courant=$(cat rep.txt | head -1 | sed 's/\/$//g')
cible=$1
#echo $cible
archive="./Archive/test.arch"

function listefich() 
{
	touch test.txt
	ligne=$(grep -n '^drirectory '$courant'' $archive | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')

	n=$(grep -n '^'$courant'$' rep.txt | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f1)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $1 | head -$((fin-1)) | tail -$((nbligne))) > test.txt

}

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
		echo "ce n'est pas un répertoire"
	fi

fi

echo $courant
