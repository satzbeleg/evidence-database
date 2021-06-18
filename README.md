# Postgres Datenbanken für das EVIDENCE-Projekt

## Überblick
Es sind zwei Datenbankensysteme und ein Verwaltungsdienst hier konfiguriert.

- [x] `dbauth`: Eine Postgres Datenbank für den Authentifizierungsprozess (z.B. E-Mail für die Kontowiederherstellung, Passwörter, Google ID für OAuth). 
    - In der `dbauth` Datenbanken werden **keine** Benutzereinstellung einer Anwendungen gespeichert (d.h. diese werden als Anwendungsdaten betrachtet). 
    - Die UUID4 `user_id` wird an externe Anwendungen übermittelt, welche diese als *Pseudonym* (Art. 4 Nr. 5 DSGVO) extern speichern können. 
- [x] `dbappl`: Eine Citus/Postgres Datenbank, um Anwendungsdaten zu speichern.
    - Die Anwendungsdatenbank speichert **keine** *direkten personenbezogenen Daten* (Art. ??? DSGVO). Lediglich die UUID4 `user_id` wird als *Pseudonym* (Art. 4 Nr. 5 DSGVO) gespeichert.
- [x] `pgadmin`: Eine Benutzeroberfläche zur Verwaltung der Postgres Datenbanken.


## Starte die Docker Container
Die `*.yml` Dateien enthalten die Container Konfigurationen der o.g. Dienste.
Die Datei `example.env.sh` enthält beispielhaft Umgebungsvariablen, die je nach Betriebsszenario anzupassen sind.

```bash
# load environment variables
set -a
#rm -rf tmp
source example.env.sh

# start containers
docker compose -p evidence \
    -f network.yml -f dbappl.yml -f dbauth.yml -f pgadmin.yml up --build

# add workers to citus db
docker-compose -p evidence scale worker=2
```

(Bitte betrachte Umgebungsvariablen in `example.env.sh`, da diese in den nachfolgenden Erläuterung wieder auftauchen.)


## Füge Demo Daten ein
In `dbauth.yml` und `dbappl.yml` werden SQL Tabellen, Funktionen und Trigger installiert falls diese nicht existieren. Bereits vorhanden Daten (Persistent Data) werden dadurch nicht überschrieben oder aus Versehen gelöscht.

Zu Demonstrationszwecken können in die leere Datenbank ein paar Spielzeugdaten eingespielt werden:

```sh
psql --host=127.0.0.1 --port=55014 --username=postgres -f dbauth/demo/019-auth.sql
psql --host=127.0.0.1 --port=55015 --username=postgres -f dbappl/demo/029-evidence.sql
```


## pgAdmin einrichten
- Öffne das pgAdmin Dashboard im Browser [localhost:55016](http://localhost:55016/)
- Siehe `example.env.sh` für die Loginangaben
- Klicke auf "Add New Server". Die IP Adresse des Citus `manager` Container wird benötigt (172.20.253.4).


## Backup und Wiederherstellung
Das *Backup* sollte im Datenbank-Container durchgeführt werden, 
d.h. `pg_dump` wird im Container ausgeführt und die Daten zum Host weitergeleitet.
Der Grund ist, dass das Program `pg_dump` auf dem Host nicht zwingend dieselbe Hauptversion wie die Postgres Datenbank im Container haben muss.

```sh
suffix=$(date +"%Y-%m-%dT%H-%M")
#container_name=database_evidence-database_1
container_name=evidence-database_master
docker exec -i ${container_name} \
    pg_dump postgres --username=postgres \
    | gzip -9 > "postgres-${suffix}.sql.gz"
```

Zur *Wiederherstellung* wird das Archiv vom Host in den Datenbankcontainer weitergeleitet, 
und im Container von `psql` als Input benutzt.

```sh
gunzip -c "postgres-${suffix}.sql.gz" | docker exec -i ${container_name} \
    psql --username=postgres -d postgres 
```

