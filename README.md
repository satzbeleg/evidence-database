# EVIDENCE project - Postgres Database for Authentification (dbauth)

## Purpose
The databases store application data and authorization data in Postgres databases. 
The can be accessed via the [REST API](https://github.com/satzbeleg/evidence-restapi), 
and thus indirectly, the [Web App](https://github.com/satzbeleg/evidence-app).
The database containers are only reachable within the Docker network.

## Installation
Please follow the instruction of the [deployment repository](https://github.com/satzbeleg/evidence-deploy).

## Inject Data

```sh
cd $EVIDENCE_DEPLOY 
cat database/dbauth/demo/test-user.sql | docker exec -i evidence_dbauth psql -U evidence -d evidence
```

## Appendix

### Support
Please [open an issue](https://github.com/satzbeleg/evidence-database/issues/new) for support.

### Contributing
Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/satzbeleg/evidence-database/compare/).
You are asked to sign the CLA on your first pull request.

