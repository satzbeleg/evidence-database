-- Rebuild indices
-- CALL auth.rebuild_indices();
DROP PROCEDURE IF EXISTS auth.rebuild_indices;

CREATE OR REPLACE PROCEDURE auth.rebuild_indices()
AS $$
DECLARE
BEGIN
    -- 011-auth-email.sql
    DROP INDEX IF EXISTS auth."uk_emails_1" ;
    DROP INDEX IF EXISTS auth."bt_emails_2" ;
    DROP INDEX IF EXISTS auth."brn_emails_3" ;
    CREATE UNIQUE INDEX "uk_emails_1" ON auth.emails USING BTREE (email) ;
    CREATE INDEX "bt_emails_2" ON auth.emails USING BTREE (email, hashed_password) ;
    CREATE INDEX "brn_emails_3" ON auth.emails USING BRIN (created_at) ;
    -- 012-auth-verify.sql
    DROP INDEX IF EXISTS auth."brn_verify_1" ;
    CREATE INDEX "brn_verify_1" ON auth.verify USING BRIN (created_at) ;
    -- 013-auth-linkedoauth.sql
    DROP INDEX IF EXISTS auth."uk_linkedoauth_1" ;
    DROP INDEX IF EXISTS auth."uk_linkedoauth_2" ;
    DROP INDEX IF EXISTS auth."bt_linkedoauth_3" ;
    CREATE UNIQUE INDEX "uk_linkedoauth_1" ON auth.linkedoauth USING BTREE (user_id, provider_name) ;
    CREATE UNIQUE INDEX "uk_linkedoauth_2" ON auth.linkedoauth USING BTREE (provider_name, account_id) ;
    CREATE INDEX "bt_linkedoauth_3" ON auth.linkedoauth USING BTREE (user_id);
END;
$$
LANGUAGE plpgsql
;
