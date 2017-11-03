# ge@sync / geOrchestra

[ge@sync](https://github.com/MSHE-Ledoux/geosync) permet la publication automatique sur geOrchestra de données déposées et partagées sur OwnCloud.

georchestra-geosync est un fork du projet [geOrchestra](https://github.com/georchestra/georchestra), dans lequel 3 conteneurs Docker sont modifiés :

- ### ldap.mshe

Intégration des données d'un annuaire Active Directory pour gérer les utilisateurs, utilisation du démon saslauth pour que l'annuaire LDAP de geOrchestra interroge l'AD pour authentifier les utilisateurs.

- ### postgresql.mshe

Création des bases de données nécessaires à ge@sync ; création de l'utilisateur geosync ; 
modification de pg_hba.conf pour permettre les accès aux bases de données depuis les réseaux locaux.

- ### geoserver/webapp/src/docker.mshe

Création des espaces de travail des utilisateurs georchestra-ouvert et georchestra-restreint

## Création d'un nouveau conteneur : geosync

- ### geosync

Il contient les homes des utilisateurs virtuels georchestra-ouvert et georchestra-restreints, dans lesquels seront synchronisées les données en provenance de OwnCloud.

Le code de geosync est installé dans /usr/local/geosync/bin.

Les logs sont accessibles depuis les répertoires des utilisateurs virtuels.

Un cron est démarré dès le lancement du conteneur.

## lancement

docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.geosync-prod.yml up --build -d

