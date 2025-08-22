#!/bin/sh

# Vérifie que toutes les variables d'environnement et le secret 'mysql_password' sont définies
REQUIRED_VARS="MYSQL_DATABASE MYSQL_USER WP_ADMIN_USER WP_ADMIN_EMAIL WP_USER WP_USER_EMAIL MYSQL_PASSWORD"
MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(cat /run/secrets/mysql_password 2>/dev/null || echo "")}     # Redirige les messages d'erreur sur nulle part OU echo "". 

for var in $REQUIRED_VARS; do
    if [ -z "$(eval echo \$$var)" ]; then
        echo "Erreur : la variable d'environnement ou le secret $var n'est pas défini."
        exit 1
    fi
done

# Vérifie si le répertoire de données initial et les tables systèmes sont absentes. Si elles sont là, c'est qu'un premier 'mysql_install_db ...' a déjà été fait.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Base de données non initialisée. Lancement de la configuration initiale..."
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    # Exécute le script qui crée une db et un user.
    /create_db_user.sh
else
    echo "Base de données déjà initialisée. Saut de la configuration."
fi

echo "Démarrage de MariaDB en premier plan..."

# 'exec' remplace le processus (le script actuel) courant par le processus 'mysqld'. mysqld devient PID1
exec mysqld
