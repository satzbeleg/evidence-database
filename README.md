# Postgres Databases for EVIDENCE project
Three services are configured:
- [x] `dbauth`: A Postgres DB to manage only data required for the authentication process (e.g. Recovery E-Mail, user passwords, Google ID for OAuth, etc.). 
    - The DB does **not** user settings associated with specific applications (i.e. it's considered application data). 
    - The UUID4 `user_id` is exposed to other applications, i.e. application could store the UUID4. The UUID4 `user_id` will then serve as *pseudonym* (Art. 4 Nr. 5 DSGVO).
- [x] `dbappl`: A Citus/Postgres DB to manage application data. 
    - The application DB does **not** store any *direct personal information* (Art. ??? DSGVO). Only the UUID4 `user_id` is stored as *pseudonym* (Art. 4 Nr. 5 DSGVO).
- [x] `pgadmin`: An UI to manage Postgres databases.


## Start the docker container
The file `docker-compose.yml` contains an **configuration example** how to deploy the REST API as docker container. It is recommended to add this repository as git submodule to an deployment repository with a central Docker Compose configuration that suits your needs. 

```bash
# load environment variables
set -a
source example.env.sh

# start containers
docker compose -p evidence \
    -f network.yml -f dbappl.yml -f dbauth.yml -f pgadmin.yml up --build

# add workers to citus db
docker-compose -p evidence scale worker=2
```

## Insert Demo Data
The demonstration data is not inserted during setup.
Please run the following commands.

```sh
psql --host=127.0.0.1 --port=55014 --username=postgres -f dbauth/demo/019-auth.sql
psql --host=127.0.0.1 --port=55015 --username=postgres -f dbappl/demo/029-evidence.sql
```



2. Öffne das pgAdmin Dashboard im Browser [localhost:8889](http://localhost:8889/)

3. Klicke auf "Add New Server". Die IP Adresse des Postgres Container wird benötigt als "Host name/address", welche wie folgt ermittelt werden kann:

```
contid=$(docker container ls | grep citus | awk '{print $1}')
docker inspect ${contid} | grep IPAddress
```

4. Logge Dich vom Host aus in die Datenbank ein

```bash
psql --host=127.0.0.1 --port=55015 --username=postgres
```

oder lasse das SQL Installationsskript laufen 

```bash
cd psql-setup
psql --host=127.0.0.1 --port=55015 --username=postgres -f install.sql
cd ..
```

## User Management
Im Schema `auth.` wurde eine rudimentäre passwort-basierte Authentifizierung mit den folgenden Befehlen implementiert.

- Neuen Account manuell erstellen: `SELECT auth.add_user('newusername', 'secretpw');`  
- Account valideren: `SELECT auth.validate_user('newusername', 'secretpw');` (True wenn Login korrekt; In FastAPI kann der Login dann abbrechen, wenn False)
- Status des Accounts abfragen: `SELECT auth.is_active_user('newusername');` (True wenn aktiv; In FastAPI kann der Login dann abbrechen, wenn False)


## Login via pgAdmin
pgAdmin ist innerhalb des Docker network `evidence-backend-network` erreichbar.

- Login: 
    - username: `test@mail.com`
    - password: `password1234`
- Database:
    - host: `172.20.253.5`
    - post: `5432`
    - username: `postgres`
    - password: `password1234`


## Backup and Recovery
In order to avoid the common version conflict problem, 
it is recommended to `pg_dump` within the deployed container.

Backup
```sh
suffix=$(date +"%Y-%m-%dT%H-%M")
#container_name=database_evidence-database_1
container_name=evidence-database_master
docker exec -i ${container_name} \
    pg_dump postgres --username=postgres \
    | gzip -9 > "postgres-${suffix}.sql.gz"
```

Recovery
```sh
gunzip -c "postgres-${suffix}.sql.gz" | docker exec -i ${container_name} \
    psql --username=postgres -d postgres 
```


## Export BWS evaluations

```sh
SELECT * FROM evidence.evaluated_bestworst LIMIT 5;
SELECT * FROM evidence.example_items LIMIT 5;
SELECT * FROM evidence.sentences_cache LIMIT 5;
SELECT * FROM evidence.score_history LIMIT 5;
```
