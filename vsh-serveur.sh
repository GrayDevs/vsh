#! /bin/bash

# Description: Ce script implémente un serveur.
# Le script doit être invoqué avec l'argument :
# PORT   le port sur lequel le serveur attend ses clients

set -euo pipefail

# Vérification du nombre de paramètres
if [ $# -ne 1 ]; then
    echo "Usage: $(basename $0) PORT"
    exit -1
fi

# Variable
PORT="$1"
ARCHIVE="./Archives"
#color
RED='\033[1;31m'
YELLOW='\033[0;36m'
GREY='\033[1;30m'
NC='\033[0m' # No Color

#### FONCTIONS

# La fonction nettoyage détruit le tube $FIFO
function nettoyage() { rm -f "$FIFO"; }

# la fonction accept-loop lance un serveur netcat sur le port donné,
# les informations reçue sont alors envoyé dans le tube ainsi qu'à la fonction 
# interaction ci-dessous
function accept-loop() {
    while true; do #boucle infinie
        printf "log - Connexion aux serveur\n" >> vsh.log
        interaction < "$FIFO" | netcat -q 0 -l -p  "$PORT" > "$FIFO" #listen and port
    done
}

# La fonction interaction lit les commandes du client sur l'entrée standard
# et envoie les réponses sur sa sortie standard.
function interaction() {
    local cmd args #déclaration de variables locales
    
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

# $args     FICHIER_ARCHIVE
function commande-browse() {
    ./vsh-browse.sh "$1"
    exit 0
}

# Liste les différentes archives présentes sur le serveur
function commande-list() {
    printf "${GREY}#Liste des archives présentes sur le serveur :${NC}\n"
    if [ "ls $ARCHIVE" == "" ]; then
        echo "Il n'y a pas d'archive sur le serveur"
        echo "--add nom_archive pour en ajouter une"
        echo "--init pour ajouter une archive de test généré automatiquement"
    else
        printf "${YELLOW}Nom_archive\tModifié_le\tTaille${NC}\n"
        ls -l $ARCHIVE | grep '.arch$' | awk '{print $9 "\t" $6"-"$7"-"$8 "\t" $5}' # | sort -df
        #stat --printf="%n\t%y\t%s\n" $ARCHIVE | sort -t $'\t' -k 2
    fi
    exit 0
}

# $args     FICHIER_ARCHIVE
function commande-extract() {
    echo "Vous souhaitez extraire l'archive $args" #existance de l'archive à vérifier
    ./vsh-extract.sh $args
    exit 0
}

# Autres fonctions
function commande-add() {
    printf "Ajout de l'archive $args au serveur\n"
    local nom_archive=$(echo $args | sed 's/\..*$//g')
    nc -q 0 -lp 60000 > $ARCHIVE/$nom_archive.arch
    echo "$nom_archive successfully transfered - press enter"
    exit 0
}

function commande-delete() {
    printf "Vous souhaitez supprimer l'archive $args\n" #existance de l'archive à vérifier
    printf "${RED}ATTENTION${NC}: Cette action est irréversible\n"
    printf "Voulez-vous continuer (y/n) ? "
    local answ; read answ
    
    if [ "$answ" == "y" ]; then
        rm -f $ARCHIVE/$args
        printf "$args successfully removed - "
    fi
    printf "press enter"
    exit 0
}

function commande-init() {
    printf "Initialisation du serveur avec une archive test\n"
    ./test-gen.sh $args
    exit 0
}

function commande-non-comprise() {
   echo "Le serveur ne peut pas interpréter cette commande"
   echo "Try 'vsh --help' for more information."
   exit 0
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

exit 0