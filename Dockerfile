FROM postgres:13

COPY dbauth/setup/000-install.sql          /docker-entrypoint-initdb.d/0000-install.sql
COPY dbauth/setup/011-auth-email.sql       /docker-entrypoint-initdb.d/0011-auth-email.sql
COPY dbauth/setup/012-auth-verify.sql      /docker-entrypoint-initdb.d/0012-auth-verify.sql
COPY dbauth/setup/013-auth-linkedoauth.sql /docker-entrypoint-initdb.d/0013-auth-linkedoauth.sql

COPY dbappl/setup/000-install.sql                        /docker-entrypoint-initdb.d/1000-install.sql
COPY dbappl/setup/020-evidence-user_settings.sql         /docker-entrypoint-initdb.d/1020-evidence-user_settings.sql
COPY dbappl/setup/021-evidence-example_items.sql         /docker-entrypoint-initdb.d/1021-evidence-example_items.sql
COPY dbappl/setup/023-evidence-evaluated.sql             /docker-entrypoint-initdb.d/1023-evidence-evaluated.sql
COPY dbappl/setup/024-evidence-interactivity-deleted.sql /docker-entrypoint-initdb.d/1024-evidence-interactivity-deleted.sql
COPY dbappl/setup/030-zdlstore-sentence_buffer.sql       /docker-entrypoint-initdb.d/1030-zdlstore-sentence_buffer.sql
COPY dbappl/setup/031-zdlstore-feature_vectors.sql       /docker-entrypoint-initdb.d/1031-zdlstore-feature_vectors.sql

