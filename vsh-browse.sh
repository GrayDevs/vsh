#!/bin/bash

# Description:

set -euo pipefail
#set -x #Uncommon this line for debug purpose

# Vérification nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: '$0 --browse <@SERVEUR> <PORT> <nom_archive.arch>'"
    exit 1
fi

# Variable(s)
export ARCHIVE="Archives/$1"
export CURRENT=$(sed -n '3p' $ARCHIVE | awk '{print $2}' | sed 's/\/$//g')

#### FONCTION

# La fonction control effectue les vérifications sur les parametres
# $1    commande
# $2    argument
function control() {
    # stockage du nombre d'argument
    local nb_arg=$#
    cmd=$(echo $1 | awk '{print $1}')
    if [ $nb_arg -gt 2 ]; then
        cmd="erreur"
    elif [ $nb_arg -ne 1 ] && ([ "$cmd" == "pwd" ] || [ "$cmd" == "help" ] || [ "$cmd" == "exit" ]); then
        cmd="erreur"    
    elif [ $nb_arg -ne 2 ] && ([ "$cmd" == "cat" ] || [ "$cmd" == "cd" ] || [ "$cmd" == "rm" ]); then
        cmd="erreur"
    fi
}

#### PROCESS
is_running="TRUE"

while [ "$is_running" == "TRUE" ]; do
    printf "vsh:/> "
    read cmd arg
    # si l'utilisateur à simplement appuyé sur "entrez"
    if [ "$cmd" == "" ]; then
        cmd="erreur"
    else
        #Controle des paramètres
        control $cmd $arg
        
        #Lancement des commandes
        case "$cmd" in
            "pwd")
                printf "$CURRENT\n"
                ;;
            "ls")
                ./ls.sh $arg
                ;;
            "cat")
                echo "cat "
                ./cat.sh $arg
                ;;
            "cd")
                echo 
                ./cd.sh $arg
                ;;
            "rm")
                echo "rm"
                ./rm.sh
                ;; 
            "help")
                printf "Commandes possibles : pwd ; ls <directory> ; cd <directory> ;\n cat <file_name> ; rm <file_name> ; exit\n"
                ;;
            "exit")
                is_running="FALSE"
                ;;
            *)
                printf "Incorrect option (type help for more informations)\n"
        esac
    fi
done

exit 0