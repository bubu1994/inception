FROM alpine:3.20

# Installation des dépendances nécessaires
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-fileinfo \
    php82-phar \
    wget \
    mysql-client

# Création du répertoire où seront les fichiers wordpress
RUN mkdir -p /var/www/wordpress

# Dans le fichier 'www.conf' on remplace la ligne 'listen = 127.0.0.1:9000' par 'listen = 0.0.0.0:9000'
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php82/php-fpm.d/www.conf
# Le fichier de configuration par défaut de php-fpm contient 'listen = 127.0.0.1'.
# Avec 'listen = 127.0.0.1', php-fpm n'écoute que sur l'interface de bouclage, il accepterait seulement les connexions des processus s'exécutant dans le même conteneur
# 0.0.0.0 indique à php-fpm d'écouter sur toutes les interfaces réseau disponibles, afin qu'il soit accessible par nginx.

# La directive cgi.fix_pathinfo traite une vulnérabilité de sécurité potentielle dans la façon dont PHP traite les URL lorsqu'il est exécuté via FastCGI (utilisé par PHP-FPM)
RUN echo "cgi.fix_pathinfo=0" >> /etc/php82/php.ini
# Lorsque cgi.fix_pathinfo est défini sur 1 (sa valeur par défaut), PHP tente de "corriger" les chemins de fichiers si un fichier demandé n'est pas trouvé exactement. Par exemple, si vous demandez exemple.com/foo.php/bar, et que foo.php existe, PHP pourrait quand même exécuter foo.php et interpréter /bar comme des informations de chemin. Ce comportement peut être exploité par des attaquants pour exécuter du code malveillant en ajoutant /.php ou similaire à une image téléchargée ou à un autre fichier non PHP.
# En définissant cgi.fix_pathinfo=0, vous indiquez explicitement à PHP de n'exécuter le fichier que si le chemin exact correspond. Si exemple.com/foo.php/bar est demandé, et que foo.php est le script visé, PHP ne l'exécutera pas si bar ne fait pas partie du chemin d'accès réel au fichier. Cela rend votre application PHP plus sécurisée en empêchant l'exécution de scripts non intentionnels.

COPY ./tools/setup_wp.sh /setup_wp.sh
COPY ./tools/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /setup_wp.sh /docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/docker-entrypoint.sh"]
