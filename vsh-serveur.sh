#! /bin/bash

# Description: Ce script implémente un serveur.
# Le script doit être invoqué avec l'argument :
# PORT   le port sur lequel le serveur attend ses clients

set -e

# Vérification du nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) PORT"
    exit -1
fi

# Variables Globales
PORT="$1"

####FONCTIONS

# La fonction nettoyage détruit le tube $FIFO
function nettoyage() { rm -f "$FIFO"; }

# la fonction accept-loop lance un serveur netcat sur le port donné,
# les informations reçue sont alors envoyé dans le tube ainsi qu'à la fonction 
# interaction ci-dessous
function accept-loop() {
    while true; do #boucle infinie
        #echo "bonjour" | netcat -l -p 8080 #envoi affiche bonjour au utilisateur se connectant au serveur sur le port 8080
	    interaction < "$FIFO" | netcat -l -p -k "$PORT" > "$FIFO" #listen, port and keep
    done
}

# La fonction interaction lit les commandes du client sur l'entrée standard
# et envoie les réponses sur sa sortie standard.
function interaction() {

    local cmd args #déclaration de variables locales

    echo -e "############################### VSH SERVER ###############################\n"

    while true; do #boucle infinie
	    read cmd args || exit -1 #demande à l'utilisateur de saisir les valeurs pour cmd et args
	    funct="commande-$cmd"
	    if [ "$(type -t $funct)" = "function" ]; then #si la funct existe et est une fonction
	        $funct $args #on l'exécute
	    else
	       commande-non-comprise $funct $args #renvoie le message d'erreur
	    fi
    done
}

# Les fonctions implémentant les différentes commandes du serveur

# Modes basique :
function commande-browse(){
    #...
}

function commande-list() {
    #...
}

function commande-extract() {
    #...
}

# Autres fonctions
function commande-non-comprise() {
   echo "Le serveur ne peut pas interpréter cette commande"
   echo "Type help to print the different command"
}

function commande-help() {
    cat vsh-help.txt; echo ""
}

function command-exit() {
    #kill -9 process PID
}

#### PROCESS

# Déclaration du tube ($$ -> PID du script)
FIFO="/tmp/$USER-fifo-$$"

# Il faut détruire le tube quand le serveur termine pour éviter de
# polluer /tmp. On utilise pour cela une instruction trap pour être sur de
# nettoyer méme si le serveur est interrompu par un signal.
trap nettoyage EXIT

# on crée le tube nommé FIFO
[ -e "$FIFO" ] || mkfifo "$FIFO"

# On accepte et traite les connexions
accept-loop