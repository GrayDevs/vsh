#!/bin/bash

# AJOUTER GESTION LIEN SYMBOLIQUE

# Description:  créer dans le répertoire courant toute l'arborescence de répertoires et les fichiers contenus dans l'archive nom_archive.
# On part du principe que le format de l'archive est correct
# Parameters:
# $1    nom_archive

set -euo pipefail
#set -x #Uncommon this line for debug purpose

# Vérification nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: '$0 <nom_archive.arch>'"
    exit 1
fi

# Variable(s)
ARCHIVE="Archives/$1"
LOG="vsh.log"

#### FONCTION

function nettoyage() { rm /tmp/.header /tmp/.body ; }

# La fonction set_permission permet de modifier les permissions d'un fichier
# $1    chemin_fichier
# $2    permissions
function set_permission(){
    local permissions=$2 #on doit set une variable locale pour pouvoir effectuer la substitution 
    chmod u=${permissions:1:3} $1
    chmod g=${permissions:4:3} $1
    chmod o=${permissions:7:3} $1
}

# La fonction get_content récupère le contenu d'un fichier
# $1    file_name               Non-used
# $2    permission              Non-used
# $3    weigth                  Non-used
# $4    file_beginning_line
# $5    number_of_line
function get_content() {
    local first_line=$4
    local size=$(($4 + $5 - 1))
    if [ $5 -gt 0 ]; then
        sed -n "$4,$size p" /tmp/.body >> $path$1
    fi
}

#### PROCESS

# Vérification de l'existence de l'archive
if [ ! -e "$ARCHIVE" ]; then
    printf "L'archive que vous avez spécifié n'existe pas sur le serveur\n"
    printf "Tapez 'vsh --list' pour avoir la liste des archives présentes sur le serveur\n"
    exit 1
fi

# Quelques variable pour pouvoir séparer les 2 parties
ligne1=$(head -1 $ARCHIVE) #3:25
debut_header=${ligne1%:*} #3
debut_body=${ligne1#*:} #25
fin_header=$(($debut_body - 1)) #24

# Création de fichiers temporaires contenant chacun leur partie respective
sed -n "$debut_header,$fin_header p" $ARCHIVE > /tmp/.header
sed -n "$debut_body,$ p" $ARCHIVE > /tmp/.body

trap nettoyage EXIT #on prépare le nettoyage en cas d'erreur

#init
path=$(basename `pwd`)/
printf "#Extraction de $1 | `date` \n" >> $LOG
printf "Opération en cours, veuillez patienter \n"

# Création de l'arborescence et modification des permissions
while read line; do
    #"directory <path>"
    if [ "$(echo $line | grep '^directory')" != "" ]; then
        path=$(echo $line | awk '{print $2}') #on set le path
        if [ "${path: -1}" != "/" ]; then
            path="$path/" 
        fi
        mkdir -vp $path >> $LOG #création dossier du path (-p => make parent directories as needed)
    #inside directory
    else
        file_name=$(echo $line | awk '{print $1}')
        file_path=$path$file_name
        permissions=$(echo $line | awk '{print $2}')
        #directory_name permissions weigth
        if [ "$(echo $line | egrep '[d][-rwx]{9}')" != "" ]; then
            mkdir -vp $file_path  >> $LOG #création des sous-répertoires
        #file_name permissions weigth first_line number_of_line
        elif [ "$(echo $line | egrep '[-][-rwx]{9}')" != "" ]; then
            touch $file_path #création des fichiers
            printf "touch: created/updated file '$file_name'\n"  >> $LOG
            get_content $(echo $line) #Récupération du contenu
        fi
        set_permission $file_path $permissions #ajout des permissions
    fi
    printf "#"
done <<< $(cat /tmp/.header | grep '[^@]')

printf "\rvsh (extract): Structure tree successfully generated\n"
printf "Operation successfull\n" >> $LOG

exit 0