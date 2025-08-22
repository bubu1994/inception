FROM alpine:3.20

COPY ./conf/my_mariadb_conf.cnf /etc/my.cnf.d/
COPY ./tools/create_db_user.sh /
COPY ./tools/init_maria.sh /

# Installe MariaDB et le client && rend les scripts exécutables.
RUN apk update && apk add --no-cache mariadb mariadb-client && \
    chmod +x ./create_db_user.sh ./init_maria.sh

# Crée le répertoire qui contiendra le socket && le groupe 'mysql' et l'utilisateur 'mysql' deviennent propriétaires du dossier pour qu'ils aient les droits
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# EXPOSE sert de documentation, d'intention. ne publie pas le port 3306. Mapper le port lors du 'docker run' ou dans le docker-compose.
EXPOSE 3306

ENTRYPOINT ["./init_maria.sh"]