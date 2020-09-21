# psql-evidence-database
Postgres Database for EVIDENCE project

## Getting Started -- Lokal entwickeln
1. Starte die Container

```bash
docker-compose up
```

2. Öffne das pgAdmin Dashboard im Browser [localhost:8889](http://localhost:8889/)

3. Klicke auf "Add New Server". Die IP Addresse des Postgres Container wird benötigt als "Host name/address", welche wie folgt ermittelt werden kann:

```
contid=$(docker container ls | grep citus | awk '{print $1}')
docker inspect ${contid} | grep IPAddress
```

4. Logge Dich in die Datenbank ein

```bash
psql --host=127.0.0.1 --port=5432 --username=postgres
```

oder lasse das SQL Installationsskript laufen 

```bash
cd psql-setup
psql --host=127.0.0.1 --port=5432 --username=postgres -f install.sql
cd ..
```

