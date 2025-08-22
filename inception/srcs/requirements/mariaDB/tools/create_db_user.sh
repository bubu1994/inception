#!/bin/sh

mysqld > /dev/null 2>&1 & 		# /dev/null est un fichier spécial qui supprime tout ce qu'on y écrit. 2>&1 envoie 2 (stderr) vers le même endroit que 1 (stdout)

# Attendre que le serveur mariaDB soit démarré avec un ping pour ensuite créer l'utilisateur et la base de données
echo "Attente du démarrage de MariaDB..."
until mysqladmin ping > /dev/null 2>&1; do			# renvoie 0 (succès) si le serveur répond. Si le serveur n'est pas prêt, la commande renvoie 1 et attend 1 seconde.
    sleep 1
done
echo "MariaDB a démarré."

# Définit la variable si elle n'est pas définie.
MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(cat /run/secrets/mysql_password)}		# lecture du secret et stockage dans une variable d'environnement. Une fois le script terminé, la variable est effacée de la mémoire et ne sera pas enregistrée dans l'image.

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysqladmin -u root shutdown
