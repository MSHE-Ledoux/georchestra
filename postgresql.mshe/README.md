Construire l'image

    docker build -t "mshe/database" .

Lancer le conteneur, en lui donnant un nom

    docker run -d --name mshe_database_1 mshe/database

Se connecter sur le conteneur

    docker exec -it mshe_database_1 bash

Arrêter le conteneur

    docker rm -f mshe_database_1

