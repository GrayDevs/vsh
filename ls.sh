#!/bin/bash

archive=$1
repertoire=$(echo $2 | sed 's/\/$//g')
grep '^directory' ./Archive/test.arch | sed 's/directory //g'
ligne=$(grep -n '^directory '$repertoire'' $archive | head -1 | cut -d: -f1)
#echo $ligne

lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
lignedel=$(echo $lignedel | sed 's/ /:/g')
n=$(grep -n '^'$repertoire'' rep.txt | head -1 | cut -d: -f1)
#echo $n
fin=$(echo $lignedel | cut -d: -f$n)
#echo $fin

#echo $lignedel
nbligne=$(($fin-$ligne-1))
#echo $nbligne
cat $1 | head -$(($fin-1)) | tail -$nbligne

