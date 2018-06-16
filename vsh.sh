#!/bin/bash

## VSH Script ##
# UTT | LO14 | Projet Linux 2018
# Author: Aurelien PERROT & Antoine PINON
# @see www.github.com
# Version: 0.0

set -euo pipefail
#set -x for verbose/debugging purpose
#@see  https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

################################################################
#### FUNCTION

# La fonction respond permet de maintenir la connexion serveur pour envoyer les commandes du mode vsh
# $1    cmd
# $2    arg
function respond() {
    echo $1 $2
    cat
}

# Les fonctions qui suivent effectuent tout les contrôles nécessaires à la commande vsh

# Vérifie les arguments saisies
# $1	Option (mode)
# $2	IP du serveur (nom_serveur)
# $3	Port sur lequel le serveur écoute
# $4	Nom de l'archive séléctionnée (nom_archive)
function check_args() {
	check_args_number "$@"
	check_args_syntax "$@"
	# check_server "$@"
	# echo "log - le server est actif sur le port séléctionné" #Test
}

# Vérifie que le nombre d'argument entré est cohérant
function check_args_number() {
	# check options
	if [ $1 == '-h' ] || [ $1 == '-?' ] || [ $1 == '--help' ]; then
	    cat vsh-help.txt; echo ""
		exit 0
	elif ([ $1 == '-l' ] || [ $1 == '--list' ]) && [ $# -ne 3 ]; then
		echo 'Invalid number of arguments. (type --help)'
		exit 1
	elif [[ ($1 == '-b' || $1 == '--browse' || $1 == '--extract' || $1 == '-a' || $1 == '--add') && $# -ne 4 ]]; then
		echo 'Invalid number of arguments. (type --help)'
		exit 1
	fi
}

# Vérifie la syntaxe des paramètres
function check_args_syntax() {
	if [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
		check_ip "$2"
		check_port "$3"
	elif [[ $1 == '-b' || $1 == '--browse' || $1 == '-e' || $1 == '--extract' ]]; then
		check_ip "$2"
		check_port "$3"
	fi
}

# Vérifie le format de l'adresse IP
# $1	Adresse IP du serveur (nom_serveur)
check_ip() {
	if [ "$1" != "localhost" ]; then
		if [[ $(grep -o '\.' <<< "$1" | wc -l) -ne 3 ]]; then
	    		printf "Le paramètre '$1' ne ressemble pas à une adresse IP.\n"
	    		exit 1
		elif [[ $(tr '.' ' ' <<< "$1" | wc -w) -ne 4 ]]; then
	    		printf "Le paramètre '$1' ne ressemble pas à une adresse IP.\n"
	    		exit 1
		fi
	fi
}

# Vérifie le format du numéro de port
# $1	numero de port
check_port() {
	if ! [[ $1 =~ ^[0-9]+$ ]] || ([[ $1 =~ ^[0-9]+$ ]] && [ "$1" -gt 65536 ]) ; then
		printf "Le paramètre PORT:'$1' est erroné, veuillez entrer un numéro de port valide (<65536).\n"
		printf "L'utilisation des ports 1337 ou 8080 est recommandé\n"
		exit 1
	fi
	#printf "PORT format respected\n"
}

# Vérifie que le serveur demandé est joignable
# check_server() {
#	if [ ]; then
#		echo "Could not access to the server $1:$2"
#		exit 1
#	fi
# }

################################################################
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
        nc $2 $3 <<< "add $4" &
        nc -q 0 localhost 60000 < $4
        ;;
    "-b" | "--browse")
        #browse @server port nom_archive
        respond "browse" $4 | nc $2 $3
        ;;
    "-d" | "--delete")
        #delete @server port nom_archive
        respond "delete" $4 | nc $2 $3
        ;;
    "--extract")
        #extract @server port nom_archive
        nc $2 $3 <<< "extract $4" 
        ;;
    "-g" | "--generate")
        ./vsh-archiver.sh $2
        ;;
    "-i" | "--init")
        if [ $# -eq 3 ]; then
            nc $2 $3 <<< "init"
        else
            nc $2 $3 <<< "init $4"
        fi
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