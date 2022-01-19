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
    - A Postgres database for the authentication process (e.g. email for account recovery, passwords, Google ID for OAuth).
    - `dbauth` does **not** store *application data* such as user settings! 
    - External applications only receive the `user_id`, which are random UUID4 strings, and thus represent *pseudonyms* according to Art. 4 No. 5 DSGVO (i.e. the `user_id` can be stored permanently in external applications because these are pseudonymized by design).
- `dbappl/`: 
    - A Postgres database to store application data.
    - The application database does **not** store permanently *direkte personenbezogenen Daten* (DSGVO). Otherwise further functionalities have to be implemented (e.g. deletion requests of direct personal data).
    - The application database can store **temporarily** *direkte personenbezogenen Daten* (DSGVO) for sole purpose of a non-commercial research project, e.g. user surveys with the informed consent that provided data can be published under CC-* license.
    - The application stores `user_id` permanently as *Pseudonym* (Art. 4 Nr. 5 DSGVO).

## Appendix

### Support
Please [open an issue](https://github.com/satzbeleg/evidence-database/issues/new) for support.

### Contributing
Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/satzbeleg/evidence-database/compare/).

