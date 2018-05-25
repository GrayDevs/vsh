#!/bin/bash

# Description:

set -euo pipefail
#set -x #Uncommon this line for debug purpose

# Vérification nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: '$0 <nom_archive.arch>'"
    exit 1
fi

# Variable(s)
ARCHIVE="Archives/$1"

#### FONCTION

# La fonction control effectue les vérifications sur les parametres
# $1    ligne contenant les commandes rentrée par l'utilisateur
function control() { 
    # stockage du nombre d'argument
    local nb_arg=$(echo $1 | wc -w)
    arg_1=$(echo $line | awk '{print $1}')
    if [ $nb_arg -gt 2 ]; then
        arg_1="erreur"
    elif [ $nb_arg -ne 1 ] && ([ "$arg_1" == "pwd" ] || [ "$arg_1" == "ls" ] || [ "$arg_1" == "help" ] || [ "$arg_1" == "exit" ]); then
        arg_1="erreur"    
    elif [ $nb_arg -ne 2 ] && ([ "$arg_1" == "cat" ] || [ "$arg_1" == "cd" ] || [ "$arg_1" == "rm" ]); then
        arg_1="erreur"    
    fi
}

#### PROCESS
is_running="TRUE"

while [ "$is_running" == "TRUE" ]; do
    printf "vsh:> "
    read line

    # si l'utilisateur à simplement appuyé sur "entrez"
    if [ "$line" == "" ]; then
        arg_1="erreur"
    else
        #Controle des paramètres
        control $line
        #Lancement des commandes
        case "$arg_1" in
            "pwd")
                echo "pwd"
                #Lancer vsh-pwd.sh
                ;;
            "ls")
                echo "ls $2"
                #Lancer vsh-pwd.sh
                ;;
            "cat")
                echo "cat "
                #...
                ;;
            "cd")
                echo "cd $2"
                #...
                ;;
            "rm")
                echo "rm $2"
                #...
                ;; 
            "help")
                printf "Commandes possibles : pwd ; ls ; cd <directory> ;\n cat <file_name> ; rm <file_name> ; exit\n"
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


