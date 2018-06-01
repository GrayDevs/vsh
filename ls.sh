#!/bin/bash


archive="./Archive/test.arch"
#on récupère le répertoire passé en argument
repertoire=$(echo $1 | sed 's/\/$//g')
#on récupère une liste des répertoire de l'archive qui nous sera utile pour les autres commandes
grep '^directory' ./Archive/test.arch | sed 's/directory //g' > rep.txt

#On récupère le numéro de la ligne correspondant au répertoire à lister
ligne=$(grep -n '^directory '$repertoire'' $archive | head -1 | cut -d: -f1)
#on récupère les numéro de ligne ne contenant que des @ qui délimite les répertoire dans le header
lignedel=$(grep -n '^@$' $archive | cut -d: -f1)
lignedel=$(echo $lignedel | sed 's/ /:/g')

#on récupère la position du répertoire dans la liste de tout les repertoire
n=$(grep -n '^'$repertoire'' rep.txt | head -1 | cut -d: -f1)
#on déduit la dernière ligne en récupérent le numéro de la ligne du @ correspondant au répertoire à lister
fin=$(echo $lignedel | cut -d: -f$n)

#on calcul ensuite le nombre de ligne à afficher
nbligne=$(($fin-$ligne-1))
#on récupère ces lignes dans l'archive et on les affiche
cat $archive | head -$(($fin-1)) | tail -$nbligne

