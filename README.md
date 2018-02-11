Note: Assurez vous que la BD roule avant d’executer kubectl run -f deploy.yaml.

Creation des JAR:

Dans chaque sous-dossier, executer ./mvnw clean package. Le jar se retrouvera dans le dossier "target".

DB Setup:
docker run --detach --env="MYSQL_ROOT_PASSWORD=password" --publish 6033:3306 mysql

docker exec -it <NOM_DU_CONTAINER> bash

mysql -ppassword

create database db_example;
create user 'springuser' identified by ‘password’;
grant all on db_example.* to 'springuser';

exit;
exit

Une fois que c'est fait, il faut rouler l'application pour creer le schema. Ceci peut etre fait avec 'kubectl run -f deploy.yaml.'

Ensuite, utilisez votre outil de preference pour ajouter des utilisateurs à la BD.