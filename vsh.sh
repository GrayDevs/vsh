#!/bin/bash

## VSH Script ##
# UTT | LO14 | Projet Linux 2018
# Author: Aurelien PERROT & Antoine PINON
# @see www.github.com
# Version: 0.0

# Source file (source: executes the content of the file passed as argument)
source vsh-controlleur.sh

set -e

#### PROCESS

#Vérification du nombre de paramètre
if [ $# -eq 0 ]; then
    echo "USAGE: $0 --help"
    exit 1
fi

#Appel de la fonction check_args du controlleur
check_args "$@"

#Lance les commandes
case $1 in
    "-b" | "--browse")
        echo "browse @server port nom_archive"
        #...
        ;;
    "-e" | "--extract")
        echo "extract @server port nom_archive"
        #...
        ;;
    "-l" | "--list")
        echo "list @server port"
        #...
        ;;
    *)
        echo "Incorrect option (--help)"
        exit 1
        ;;
esac

exit 0
