[![Join the chat at https://gitter.im/satzbeleg/community](https://badges.gitter.im/satzbeleg/community.svg)](https://gitter.im/satzbeleg/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# EVIDENCE project - Postgres Databases


## Purpose
The databases store application data and authorization data in Postgres databases. The can be accessed via the [REST API](https://github.com/satzbeleg/evidence-restapi), and thus indirectly, the [Web App](https://github.com/satzbeleg/evidence-app).
The database containers are only reachable within the Docker network.


## Installation
Please follow the instruction of the [deployment repository](https://github.com/satzbeleg/evidence-deploy).


## Configuration
The repository contains configurations of two databases.

- `dbauth/`: 
    - A Postgres database `auth` for the authentication process (e.g. email for account recovery, passwords, Google ID for OAuth).
    - External applications only receive the `user_id`, which are random UUID4 strings, and thus represent *pseudonyms* according to Art. 4 No. 5 DSGVO (i.e. the `user_id` can be stored permanently in external applications because these are pseudonymized by design).
    - It is also a datbase `userdata` included to store user settings.
- `dbeval/`: 
    - A Cassandra database to store the examples to evaluate and evaluation results
    - The database does **not** store permanently *direkte personenbezogenen Daten* (DSGVO). Otherwise further functionalities have to be implemented (e.g. deletion requests of direct personal data).
    - The database can store **temporarily** *direkte personenbezogenen Daten* (DSGVO) for sole purpose of a non-commercial research project, e.g. user surveys with the informed consent that provided data can be published under CC-* license.
    - The application stores `user_id` permanently as *Pseudonym* (Art. 4 Nr. 5 DSGVO).

## Demo Data 1: `./dbeval/demo1/`

```sh
cd $EVIDENCE_DEPLOY 
cat database/dbauth/demo/test-user.sql | docker exec -i evidence_dbauth psql -U evidence -d evidence
cat database/dbeval/demo/999-toy-data1.cql | docker exec -i evidence_dbeval cqlsh 
```

## Demo Data 2: `./dbeval/demo2/`
(1) The folder contains `./dbauth/demo/*.dvc` files to download JSON data files from the ZDL SSH backend.
Please install a python virtual env with DVC for SSH, and pull the JSON files from the backend.

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install 'dvc[ssh]'
dvc pull -r zdl
deactivate  # important!
rm -rf .venv  # not needed anymore
```

(2) The following headwords with sentence examples are available: 

- ADJ: blau, hell, regimefeindlich, schnell, technisch, witzig
- NOUN: Gradient, Insel, Internet, Regen, Käse, Wüste
- VERB: digitalisieren, fließen, pflegen, schmelzen, turnen, ziehen


(3) Start Feature Extraction pipeline `evidence-features`

Please install [evidence-features](github.com/satzbeleg/evidence-features) in the parent folder

```sh
cd ../
pip install git+ssh://git@github.com/satzbeleg/evidence-features.git features
cd features
# follow the instructions in ../features/README.md (install .venv, download models)
```

(4) Process text data and insert into `dbeval` database

```sh
cd ./database
source ../features/.venv/bin/activate
export MODELFOLDER="../features/models"
python ./dbeval/demo2/preprocess.py
# check also how to fetch the data
# ./dbeval/demo2/fetch-examples.py
```


## Appendix

### Support
Please [open an issue](https://github.com/satzbeleg/evidence-database/issues/new) for support.

### Contributing
Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/satzbeleg/evidence-database/compare/).
You are asked to sign the CLA on your first pull request.

