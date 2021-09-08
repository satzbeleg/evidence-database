
-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------

--  n.a.


-- -----------------------------------------------------------------------
-- (B) TABLE 
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
evidence.evaluated_bestworst (
    set_id      uuid NOT NULL
  , user_id     uuid NOT NULL
  , ui_name     text NOT NULL
  -- data
  , lemmata           text[] DEFAULT NULL
  , event_history     jsonb NOT NULL
  , state_sentid_map  jsonb NOT NULL
  -- tracking data
  , tracking_data     jsonb DEFAULT NULL
  -- documentation
  , created_at     timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by     text NOT NULL default CURRENT_USER
  , PRIMARY KEY(set_id)
);

-- search by: user_id, ui_name, lemmata
CREATE INDEX CONCURRENTLY "bt_evaluated_bestworst_1" 
  ON evidence.evaluated_bestworst USING BTREE (user_id)
; -- for "="

CREATE INDEX CONCURRENTLY "bt_evaluated_bestworst_2" 
  ON evidence.evaluated_bestworst USING BTREE (ui_name)
; -- for "="

CREATE INDEX CONCURRENTLY "gin_evaluated_bestworst_3" 
  ON evidence.evaluated_bestworst USING GIN (lemmata array_ops)
;

CREATE INDEX CONCURRENTLY "gin_evaluated_bestworst_4" 
  ON evidence.evaluated_bestworst USING GIN (event_history jsonb_path_ops)
  WHERE event_history IS NOT NULL
;
CREATE INDEX CONCURRENTLY "gin_evaluated_bestworst_5" 
  ON evidence.evaluated_bestworst USING GIN (state_sentid_map jsonb_path_ops)
  WHERE state_sentid_map IS NOT NULL
;
CREATE INDEX CONCURRENTLY "gin_evaluated_bestworst_6" 
  ON evidence.evaluated_bestworst USING GIN (tracking_data jsonb_path_ops)
  WHERE tracking_data IS NOT NULL
;


-- Kommentare
COMMENT ON COLUMN evidence.evaluated_bestworst.set_id IS 
  'UUID4 of the example set (Satzgruppe). It is the primary key but generated externally by Evidence REST API.'
;
COMMENT ON COLUMN evidence.evaluated_bestworst.user_id IS 
  'Unique user_id from an authentification database. Currently the app uses `auth.users.user_id` what is planned to be replaced by an DWDS Auth API.'
;
COMMENT ON COLUMN evidence.evaluated_bestworst.ui_name IS 
  'Refers to Vue3 View component of the Evidence WebApp.'
;
COMMENT ON COLUMN evidence.evaluated_bestworst.lemmata IS 
  'Array of lemmata that characterize all sentence examples (Satzbelege) of the example set (Satzgruppe).'
;
COMMENT ON COLUMN evidence.evaluated_bestworst.event_history IS 
  'Array of all events tracked in the Evidence Web App while evaluating this example set.'
;
COMMENT ON COLUMN evidence.evaluated_bestworst.state_sentid_map IS 
  'Maps the UI states (e.g. states 0,1,2, or 3) with the SentenceIDs.'
;



-- -----------------------------------------------------------------------
-- (C) TRIGGERS 
-- -----------------------------------------------------------------------

-- n.a.


-- -----------------------------------------------------------------------
-- (D) FUNCTIONS 
-- -----------------------------------------------------------------------

-- n.a.
