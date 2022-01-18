[![Join the chat at https://gitter.im/satzbeleg/community](https://badges.gitter.im/satzbeleg/community.svg)](https://gitter.im/satzbeleg/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# EVIDENCE project - Postgres Databases


## Purpose
The databases store application data and authorization data in Postgres databases. The can be accessed via the [REST API](https://github.com/satzbeleg/evidence-restapi), and thus indirectly, the [Web App](https://github.com/satzbeleg/evidence-app).


## Installation
Please follow the instruction of the [deployment repository](https://github.com/satzbeleg/evidence-deploy).


## Configurated Containers
The repository contains the docker configuration of two database systems and a UI-based database administration tool.

- `dbauth.yml`: 
    - A Postgres database for the authentication process (e.g. email for account recovery, passwords, Google ID for OAuth).
    - `dbauth` does **not** store *application data* such as user settings! 
    - External applications only receive the `user_id`, which are random UUID4 strings, and thus represent *pseudonyms* according to Art. 4 No. 5 DSGVO (i.e. the `user_id` can be stored permanently in external applications because these are pseudonymized by design).
- `dbappl.yml`: 
    - A Citus/Postgres database to store application data.
    - The application database does **not** store permanently *direkte personenbezogenen Daten* (DSGVO). Otherwise further functionalities have to be implemented (e.g. deletion requests of direct personal data).
    - The application database can store **temporarily** *direkte personenbezogenen Daten* (DSGVO) for sole purpose of a non-commercial research project, e.g. user surveys with the informed consent that provided data can be published under CC-* license.
    - The application stores `user_id` permanently as *Pseudonym* (Art. 4 Nr. 5 DSGVO).
- `pgadmin.yml`: 
    - A user interface to manage the Postgres databases.


## Local Development
1. [Build Docker Containers](#build-docker-containers)
2. [Import Demo Data](#import-demo-data)
3. [Setup pgAdmin](#setup-pgadmin)
4. [Backup and Recovery](#backup-and-recovery)

### Build Docker Containers
The `* .yml` files contain the container configurations of the services mentioned above.
The file `defaults.env.sh` contains exemplary environment variables that have to be adjusted depending on the deployment scenario.

```bash
# delete persistent storage locations
rm -rf tmp

# load environment variables
set -a
source defaults.env.sh
# source specific.env.sh

# start containers
# - WARNING: Don't use the `docker compose` because it cannot process `ipv4_address`!
docker-compose -p evidence \
    -f network.yml -f dbauth.yml -f dbappl.yml -f pgadmin.yml up --build

# add workers to citus db
docker-compose -p evidence -f network.yml -f dbappl.yml scale worker=3
```


### Import Demo Data
In `dbauth.yml` and` dbappl.yml` SQL tables, functions and triggers are installed if they do not exist. Existing data (persistent data) will not be overwritten or accidentally deleted.

A few toy data can be imported into the empty database for demonstration purposes:

```sh
psql --host=127.0.0.1 --port=55014 --username=postgres -f dbauth/demo/test-user-for-app-demo.sql
psql --host=127.0.0.1 --port=55015 --username=postgres -f dbappl/demo/toy-data-for-app-demo.sql

# or
cat dbauth/demo/test-user-for-app-demo.sql | docker exec -i evidence-dbauth psql --username=postgres
cat dbappl/demo/toy-data-for-app-demo.sql | docker exec -i evidence-dbappl_master psql --username=postgres
```


### Setup pgAdmin
- Open the pgAdmin dashboard in the browser, e.g. [localhost:55016](http://localhost:55016/)
- Check `defaults.env.sh` for the login credentials
- Click on "Add New Server". The IP address of the Citus `manager` container is required (172.20.253.4).


### Backup and Recovery
The *backup* should be carried out in the database container, i.e. `pg_dump` is executed in the container and the data is forwarded to the host.
The reason is that the program `pg_dump` on the host might not have to have the same major version as the Postgres database in the container.

```sh
suffix=$(date +"%Y-%m-%dT%H-%M")
container_name=evidence-database_master
docker exec -i ${container_name} \
    pg_dump postgres --username=postgres \
    | gzip -9 > "postgres-${suffix}.sql.gz"
```

For *recovery*, the archive is forwarded from the host to the database container,
and used as input in the container of `psql`.

```sh
gunzip -c "postgres-${suffix}.sql.gz" | docker exec -i ${container_name} \
    psql --username=postgres -d postgres 
```


## Appendix

### Support
Please [open an issue](https://github.com/satzbeleg/evidence-database/issues/new) for support.

### Contributing
Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/satzbeleg/evidence-database/compare/).

