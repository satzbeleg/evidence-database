# psql-evidence-database
Postgres Database for EVIDENCE project

## Getting Started -- Lokal entwickeln
1. Starte die Container

```bash
# Host Server's Port Settings
export DATABASE_HOST_PORT=55015
export PGADMIN_HOST_PORT=55016

# Postgres Settings
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=password1234

# PgAdmin Settings
export PGADMIN_EMAIL=test@mail.com
export PGADMIN_PASSWORD=password1234

docker compose up --build
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
