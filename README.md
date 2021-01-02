# psql-evidence-database
Postgres Database for EVIDENCE project

## Getting Started -- Lokal entwickeln
1. Starte die Container

```bash
docker network create --driver bridge \
    --subnet=172.20.253.0/28 \
    --ip-range=172.20.253.8/29 \
    evidence-backend-network

docker-compose up --build
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
