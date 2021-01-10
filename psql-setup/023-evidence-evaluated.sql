

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
  , PRIMARY KEY(set_id)
);

