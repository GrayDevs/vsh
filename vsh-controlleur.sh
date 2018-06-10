#!/bin/bash

# NE PAS EXECUTER CE FICHIER

# Description: Script qui effectue tout les controlles nécessaires à la commande vsh, 
# utilisé pour ne pas surcharger les autres scripts et centraliser les vérifications.

#### FONCTIONS

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
	elif [[ ($1 == '-b' || $1 == '--browse' || $1 == '--extract') && $# -ne 4 ]]; then
		echo 'Invalid number of arguments. (type --help) 2'
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
		fi
		if [[ $(tr '.' ' ' <<< "$1" | wc -w) -ne 4 ]]; then
	    		printf "Le paramètre '$1' ne ressemble pas à une adresse IP.\n"
	    		exit 1
		fi
	#printf "IP format respected\n"
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