#!/bin/bash

archive="./Archive/test.arch"
fichier=$(echo $1 | cut -d. -f1)
listerep="./rep.txt"
courant=$(cat rep.txt | head -1 | sed 's/\/$//g')
contenu=""
function listefich (){
	touch test.txt
	ligne=$(grep -n '^directory '$courant'' $archive | head -1 | cut -d: -f1)
	lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
	lignedel=$(echo $lignedel | sed 's/ /:/g')
	
	n=$(grep -n '^'$courant'$' rep.txt | head -1 | cut -d: -f1)
	fin=$(echo $lignedel | cut -d: -f1)
	nbligne=$(($fin-$ligne-1))
	echo $(cat $1 | head -$((fin-1)) | tail -$((nbligne))) >test.txt
	
	
}


listefich $archive $courant 
flag=0
for word in $(cat test.txt);do
	
	if [ "$word" = "$fichier" ];then 
	
		#cat /home/parallels/projet/$courant$fichier
		flag=1
	fi
done
if [ $flag -eq 1 ]; then
	cat /home/parallels/projet/$courant/$fichier
else
	echo "le fichier n'existe pas dans ce dossier"
fi




