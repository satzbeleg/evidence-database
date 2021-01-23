

-- keep it generic
-- internal evaluated_id (not the same as set_id in WebApp/RestAPI)
-- username text
-- ui_name text
-- set_id  UUID4  (created by WebApp/RestAPI)
-- event_history JSONB
-- state_sentid  JSONB
-- checkout_data JSONB


CREATE TABLE IF NOT EXISTS 
evidence.evaluated_bestworst (
    set_id      uuid NOT NULL
  , username    text NOT NULL
  , ui_name     text NOT NULL
  -- data
  , lemmata             text[] DEFAULT NULL
  , event_history       jsonb NOT NULL
  , state_sentid_map    jsonb NOT NULL
  -- documentation
  , created_at     timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by     text NOT NULL default CURRENT_USER
  , PRIMARY KEY(set_id)
);

-- search by: username, ui_name, lemmata
CREATE INDEX CONCURRENTLY "bt_evaluated_bestworst_1" 
  ON evidence.evaluated_bestworst USING BTREE (username)
; -- for "="

CREATE INDEX CONCURRENTLY "bt_evaluated_bestworst_2" 
  ON evidence.evaluated_bestworst USING BTREE (ui_name)
; -- for "="

CREATE INDEX CONCURRENTLY "gin_evaluated_bestworst_3" 
  ON evidence.evaluated_bestworst USING GIN (lemmata)
;
