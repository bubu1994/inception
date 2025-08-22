#!/bin/sh

echo "Démarrage du conteneur WordPress..." 
echo "Attente de la disponibilité de MariaDB..."

MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(cat /run/secrets/mysql_password)}

# Se connecte et exécute une requête SQL. '-h mariadb' se connecte à l'hôte/conteneur nommé 'mariadb'. '-e' (execute statement) fournit une requête SQL directement en ligne de commande, sans ouvrir le client mariadb. 'SELECT 1' retourne 1.
# Si "1" est bien renvoyé, c'est qu'une connexion a été établi avec succès.
until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" > /dev/null 2>&1; do
    echo "MariaDB n'est pas encore prêt. Attente..."
    sleep 5
done
echo "MariaDB est disponible."

if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "WordPress n'est pas installé. Lancement de l'installation..."
    /setup_wp.sh
else
    echo "WordPress est déjà installé."
fi

echo "Démarrage de PHP-FPM..."

# -F force le mode 'foreground' (premier plan)
exec php-fpm82 -F