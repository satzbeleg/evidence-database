#!/bin/bash 

# Host Server's Port Settings
export DBAUTH_HOSTPORT=55014
export DBAPPL_HOSTPORT=55015
export PGADMIN_HOSTPORT=55016

# Postgres Settings
export DBAPPL_PASSWORD=password1234
export DBAUTH_PASSWORD=password1234
# Persistent Storage
#rm -rf tmp
mkdir -p tmp/{data_evidence,data_userdb}
export DBAPPL_PERSISTENT=./tmp/data_evidence
export DBAUTH_PERSISTENT=./tmp/data_userdb

# PgAdmin Settings
export PGADMIN_EMAIL=test@mail.com
export PGADMIN_PASSWORD=password1234
