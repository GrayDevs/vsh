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
export ARCHIVE="Archives/$1"
export CURRENT=$(sed -n '3p' Archives/test.arch | awk '{print $2}')

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

        echo "###########TEST#########"
        echo "commande : "$cmd #Test
        echo "argument : "$arg #Test
        echo "########################"
        
        #Lancement des commandes
        case "$cmd" in
            "pwd")
                echo "pwd"
                #Lancer vsh-pwd.sh
                ;;
            "ls")
                #Lancer vsh-pwd.sh
                if [ $# -eq 1 ]; then
                    arg=$CURRENT
                fi
                ./ls.sh $arg
                ;;
            "cat")
                echo "cat "
                #...
                ;;
            "cd")
                echo "cd"
                #...
                ;;
            "rm")
                echo "rm"
                #...
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
