#!/bin/bash

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
	echo "log - arguments valides : $@"
	check_server "$@"
	echo "log - le server est actif sur le port séléctionné"
}

# Vérifie que le nombre d'argument entré est cohérant
function check_args_number() {
	# check options
	if [ $1 == '-h' ] || [ $1 == '-?' ] || [ $1 == '--help' ]; then
	    cat vsh-help.txt; echo ""
		exit 0
	elif ([ $1 == '-l' ] || [ $1 == '--list' ]) && [ $# -ne 3]; then
		echo 'Invalid number of arguments. (type --help)'
		exit 1
	elif [[ ($1 == '-b' || $1 == '--browse' || $1 == '-e' || $1 == '--extract') && $# -ne 4 ]]; then
		echo 'Invalid number of arguments. (type --help)'
		exit 1
	else
		echo 'Invalid input (type --help)'
		exit 1
	fi
}

# Vérifie la syntaxe des paramètres
function check_args_syntax() {
	if [[ $1 == '-list' ]]; then
		check_ip "$2"
		check_port "$3"
	elif [[ $1 == '-b' || $1 == '--browse' || $1 == '-e' || $1 == '--extract' ]]; then
		check_ip "$2"
		check_port "$3"
		check_archive "$4"
	fi

}

# Vérifie que l'archive demandé existe sur le serveur
function check_archive() {
	if [ -e $4 ]; then
#		...
	else
		echo "L'archive demandé n'existe pas."
		echo "Utilisez vsh --list pour avoir la liste des archives disponibles sur le serveur."
		exit 1
	fi
}

# Vérifie le format de l'adresse IP
# $1	Adresse IP du serveur (nom_serveur)
check_ip() {
	if ! [[ $1 == 'localhost' ]]; then
		if [[ $(grep -o '\.' <<< "$1" | wc -l) -ne 3 ]]; then
	    		echo "Parameter '$1' does not look like an IP address."
	    		exit 1
		fi
		if [[ $(tr '.' ' ' <<< "$1" | wc -w) -ne 4 ]]; then
	    		echo "Parameter '$1' does not look like an IP address."
	    		exit 1
		fi
		local -i octet
		for octet in $(tr '.' ' ' <<< "$1"); do
	    		if ! [[ $octet =~ ^[0-9]+$ ]]; then
				echo "Parameter '$1' does not look like an IP address."
				exit 1
	    		fi
		done
		for octet in $(tr '.' ' ' <<< "$1"); do
	    		if [[ $octet -lt 0 || $octet -gt 255 ]]; then
				echo "Parameter '$1' does not look like an IP address (octet '$octet' is not in range 0-255)."
				exit 1
	    		fi
		done
	fi
}

# Vérifie le format du numéro de port
# $1	numero de port
check_port() {
	if ! [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -lt 65536 ] ; then #[[ ... =~ ... ]] => regex matching
		echo "Le paramètre '$1' est erroné, veuillez entrer un numéro de port valide (<65536)."
		echo "L'utilisation des ports 1337 ou 8080 est recommandé"
		exit 1
	fi
}

# Vérifie que le serveur demandé est joignable
check_server() {
	if [ ... ]; then
		echo "Could not access to the server $1:$2"
		exit 1
	fi
}