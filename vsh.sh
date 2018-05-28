#!/bin/bash

## VSH Script ##
# UTT | LO14 | Projet Linux 2018
# Author: Aurelien PERROT & Antoine PINON
# @see www.github.com
# Version: 0.0

# Source file (source: executes the content of the file passed as argument)
source vsh-controlleur.sh

set -euo pipefail
#set -x for verbose/debugging purpose
#@see  https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

#### PROCESS

#Vérification du nombre de paramètre
if [ $# -eq 0 ]; then
    echo "USAGE: $0 --help"
    exit 1
fi

#Appel de la fonction check_args du controlleur
check_args "$@"

#Lance les commandes
# $1    COMMANDE
# $2    ADRESSE_SERVEUR
# $3    PORT
# $4    NOM_ARCHIVE
case $1 in
    "-a" | "--add")
        #add @server port nom_archive
        nc $2 $3 <<< "add"
        ;;
    "-b" | "--browse")
        #browse @server port nom_archive
        nc $2 $3 <<< "browse $4"
        ;;
    "-d" | "--delete")
        #delete @server port nom_archive
        nc $2 $3 <<< "delete $4"
        ;;
    "--extract")
        #extract @server port nom_archive
        nc $2 $3 <<< "extract $4" 
        ;;
    "-l" | "--list")
        nc $2 $3 <<< "list"
        ;;
    *)
        printf "Incorrect option (--help)\n"
        exit 1
        ;;
esac

exit 0
