#!/bin/sh

cd /var/www/wordpress

# Télécharger WordPress
echo "Téléchargement de WordPress..."
wget -O wordpress.tar.gz https://wordpress.org/latest.tar.gz	# '-O' spécifie le nom de fichier de sortie (Output filename)
tar -xzf wordpress.tar.gz --strip-components=1					# Une extraction crée un répertoire contenant les fichiers extraits. L'option '--strip..' supprime ce répertoire et les fichiers se trouvent sur le répertoire courant
rm wordpress.tar.gz
echo "WordPress téléchargé."

# 'ln' crée des liens entre fichiers. '-s' lien symbolique (symlink ou soft link) par opposition au lien physique (hard link). Un lien symbolique est un fichier spécial qui contient le chemin d'accès à un autre fichier ou répertoire (la cible).
# '-f' force la création, écrase le lien existant s'il y en a un. '/usr/bin/php82' le fichier source. '/usr/bin/php' le lien de destination.
# Chaque fois qu'un script ou une commande essaie d'exécuter php (par exemple, /usr/bin/php), il pointe en réalité vers l'exécutable php82.
ln -sf /usr/bin/php82 /usr/bin/php

# Télécharger WP-CLI (WordPress Command Line Interface) un outil en ligne de commande officiel pour configurer automatiquement WordPress sans interface web
echo "Installation de WP-CLI..."
wget -O wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp    # Déplace et renomme le fichier en /usr/local/bin/wp, qui est un chemin inclus dans $PATH. Cela permet d’appeler wp directement depuis n’importe où.


MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(cat /run/secrets/mysql_password)}
WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-$(cat /run/secrets/wp_admin_password)}
WP_USER_PASSWORD=${WP_USER_PASSWORD:-$(cat /run/secrets/wp_user_password)}

REQUIRED_VARS="WP_ADMIN_PASSWORD WP_USER_PASSWORD MYSQL_PASSWORD"
for var in $REQUIRED_VARS; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo "Erreur : le secret $var n'est pas défini."
        exit 1
    fi
done

# 'wp config create' crée le fichier wp-config.php, nécessaire pour connecter wordpress à mariaDB
# --dbhost=mariadb:3306 spécifie que la base de données est accessible via un hôte nommé mariadb sur son port 3306.
# Par défaut, WP-CLI refuse de s'exécuter en tant que root par mesure de sécurité. Dans un Dockerfile, les commandes RUN sont exécutées par défaut en tant que root pendant la phase de construction de l'image. L'option '--allow-root' permet à WP-CLI de s'exécuter sous root.
echo "Configuration de WordPress..."
wp config create \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$MYSQL_PASSWORD \
    --dbhost=mariadb:3306 \
    --allow-root

# Installe WordPress et crée le compte administrateur
echo "Installation de WordPress..."
wp core install \
    --url="gebuqaj.42.fr" \
    --title="Inception 42" \
    --admin_user=$WP_ADMIN_USER \
    --admin_password=$WP_ADMIN_PASSWORD \
    --admin_email=$WP_ADMIN_EMAIL \
    --allow-root

# Crée un utilisateur supplémentaire
echo "Création de l'utilisateur WordPress..."
wp user create $WP_USER $WP_USER_EMAIL \
    --user_pass=$WP_USER_PASSWORD \
    --allow-root

# Tous les fichiers WordPress appartiennent maintenant à l'utilisateur et groupe nobody. C'est une pratique de sécurité courante dans les conteneurs Docker pour que le serveur web ne s'exécute pas avec les privilèges de l'utilisateur root. L'utilisateur nobody a généralement des privilèges très limités. (Principe du moindre privilège).
chown -R nobody:nobody /var/www/wordpress
# Le fichier de configuration de php-fpm indique 'user = nobody' et 'group = nobody', spécifiant que PHP-FMP va s'exécuter sous 'nobody', un compte système spécial qui possède des privilèges très limités.

# premier chiffre 7; permissions pour le propriétaire du fichier, 7 = lecture (4) + écriture (2) + exécution (1)". deuxieme chiffre 5; permissions pour le groupe, lecture (4) + écriture (1). troisième 5; permissions pour les autres/public.
# 'nobody', qui exécute php-fpm, qui doit avoir accès aux fichiers, a besoin de tous les droits. Nginx, exécuté sous l'utilisateur 'nginx' de son conteneur et compris comme utilisateur public par le conteneur 'wordpress', a besoin des droits de lecture pour servir mes fichiers .html. Il a aussi besoin des droits d'exécution pour traverser les dossiers parents. Je pourrais donner moins de droits au groupe et au public, mais j'ai la flemme d'écrire une ligne de plus. Par contre j'ai pas la flemme d'écrire que je la flemme ahahah. Wallah j'en ai marre de ce projet.
chmod -R 755 /var/www/wordpress

echo "Configuration de WordPress terminée."
