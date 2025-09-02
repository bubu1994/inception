FROM alpine:3.20
# utilise Alpine 3.20 comme image de base

RUN apk update && apk add --no-cache nginx
# RUN exécute les commandes à la construction de l'image.
# 'apk update' met à jour les packages disponibles
# normalement 'apk add' télécharge un index du paquet (comme une minidatabase). '--no-cache' dit à apk de ne pas le télécharger pour ne pas alourdir l'image (le but de 'alpine' étant d'être minimaliste)

RUN apk add openssl
# installe openssl;  Bibliothèque logicielle open source qui implémente les protocoles SSL (Secure Sockets Layer) et TLS (Transport Layer Security)

RUN mkdir -p /etc/nginx/ssl
# crée un dossier où seront stockés le certificat et la clef.

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=ssd/CN=gebuqaj.42.fr/UID=prout"
# openssl								CLI pour interagir avec la bibliothèque SSL
# req									sous-commande utilisée pour la gestion des requête de certificat (CRS) ou génération de certificats auto-signés
# -x509									au lieu d'une demande de signature de certificat, crée directement un certificat auto-signé. Signé par sa propre clé privée, plutôt que par une CA tierce. Ces certificats sont souvent utilisés pour des tests ou des environnements internes où la validation par une CA n'est pas nécessaire. Déconseillé pour la production.
# -nodes								"no DES encryption". La clé privée générée (inception.key) ne sera pas protégée par un mot de passe. Cela peut être pratique pour les serveurs qui doivent redémarrer automatiquement sans intervention humaine pour entrer une phrase de passe, mais c'est moins sécurisé. Si quelqu'un obtient l'accès à ce fichier de clé privée, il peut l'utiliser sans entrave.
# -out /etc/nginx/ssl/inception.crt		Spécifie le chemin et le nom du fichier où le certificat généré sera sauvegardé
# -keyout /etc/nginx/ssl/inception.key	Spécifie le chemin et le nom du fichier où la clé privée générée sera sauvegardée
# -subj "..."							remplit les champs du certificat. Ces champs sont intégrés au certificat et servent à identifier le serveur auprès des clients (navigateurs, API, etc.). Tous les champs, sauf CN, n'ont qu'un rôle informatif. CN (Common Name) est le nom de domaine auquel le certificat s'applique. C'est le nom que les clients utilisent pour accéder au serveur.

# CSR (Certificate Signing Request) est un fichier (généralement au format texte) qui contient des informations nécessaires pour demander un certificat numérique auprès d’une autorité de certification (CA, Certificate Authority).
# Un CSR contient typiquement: Le nom de domaine concerné (Common Name ou CN), Le nom de l’organisation, Le pays, La clé publique associée, Éventuellement des SAN (Subject Alternative Names) pour des domaines supplémentaires, Et il est signé avec la clé privée correspondante (mais la clé privée ne fait pas partie du CSR)
# Le CSR est ensuite envoyé à l’autorité de certification, qui vérifie les informations et émet un certificat signé si tout est conforme.

RUN rm /etc/nginx/http.d/default.conf
# Supprime ce fichier, qui écoute sur le port 80 en http. En fait, ça ne sert à rien puisque je ne mapperai pas ce port sur ma machine. Le port 80 du conteneur sera inaccessible depuis l'extérieur.

COPY conf/mynginx.conf /etc/nginx/http.d/
# copie le fichier 'mynginx.conf' dans le dossier du conteneur '/etc/nginx/http.d/'. 

COPY mes_pages/ /var/www/wordpress
# copie le contenu du dossier 'mes_pages/' dans '/var/www/wordpress' (le dossier est créé s'il n'existe pas). 'COPY ./mes_pages /var/www/' sans le slash → copierait le dossier lui-même

CMD ["nginx", "-g", "daemon off;"]
# CMD définit la commande lancée au démarrage du conteneur. 
# Si je ne définis pas CMD, mon image héritera de la commande de l'image de base. Ici, alpine 3.20 lance "/bin/sh".
# Dans un conteneur, le premier processus lancé est PID1. Tant que PID1 est actif, le conteneur tourne. Si PID1 se termine, le conteneur s'arrête automatiquement. En sortant du shell (qui est le PID1 du conteneur) d'alpine, je stoppe le conteneur.
# la commande 'nginx' lance Nginx en mode daemon. Un processus daemon se détache du terminal qui l'a lancé pour s'exécuter en arrière-plan et continue à tourner sans interaction directe. 
# Par défaut, Nginx lance un processus maître (PID1), il fork un processus fils/worker qui devient le vrai serveur. Le processus maître se termine (par défaut). PID1 meurt, Docker arrête le conteneur et le process enfant aussi.
# '-g' fournit une directive de configuration globale. 'daemon off;' empêche nginx de se mettre en arrière-plan. PID1 reste vivant, le conteneur ne s'arrête pas.
# au lieu d'ajouter cette option à CMD, on peut aussi indiquer la directive 'daemon off;' dans mynginx.conf

# fonctionnement interne de nginx: 1.Processus maître: lit les fichiers de configuration, ouvre les ports, crée des workers, supervise leur état. 2.Processus worker(s): gèrent les requêtes http, effectuent le vrai travail(accepter les connexions, lire les fichiers, répondre aux clients,...) webserv ?

