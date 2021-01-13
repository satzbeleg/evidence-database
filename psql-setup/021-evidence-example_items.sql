-- 
-- Table with preloaded example items
-- 
-- Requirements:
-- -------------
--    - it's assumed that the `sentence_id` was generated by the SentenceStore, 
--        and matches `sentence.register.sentence_id`.
--        We DON'T store the raw sentence here!
-- 
-- Overview:
-- ---------
--    (A) Required Types
--    (B1) Table evidence.example_items
--    (B2) Table evidence.score_history (Previous scores)
--    (C) Triggers
--    (D) Other Functions 
-- 


-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------

--  n.a.


-- -----------------------------------------------------------------------
-- (B1) TABLE evidence.example_items
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
evidence.example_items (
    item_id     uuid DEFAULT uuid_generate_v4()
  , sentence_id uuid NOT NULL
  , lemma       citext NOT NULL
  , context     jsonb NOT NULL
  , score       double precision DEFAULT NULL
  , PRIMARY KEY(item_id)
  , CONSTRAINT uk_example_items_1 
      UNIQUE(sentence_id, lemma, context)
);

-- comments
-- internal ID
-- sentID=internal ID Default NULL
-- sentence text
-- scores Default 0
-- lemmata : Array text[] default NULL


-- -----------------------------------------------------------------------
-- (B2) TABLE evidence.score_history (Previous scores)
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
evidence.score_history (
    history_id  uuid DEFAULT uuid_generate_v4()
  , item_id     uuid NOT NULL
  , score       double precision NOT NULL
  , created_at  timestamp NOT NULL default CURRENT_TIMESTAMP
  , model_info  jsonb NOT NULL
  , PRIMARY KEY(history_id)
  , CONSTRAINT uk_score_history_1 
      UNIQUE(item_id, score, created_at, model_info)
  , CONSTRAINT fk_score_history_2 FOREIGN KEY(item_id)
      REFERENCES evidence.example_items(item_id) ON DELETE CASCADE
);



-- -----------------------------------------------------------------------
-- (C) TRIGGERS 
-- -----------------------------------------------------------------------

-- n.a.


-- -----------------------------------------------------------------------
-- (D) FUNCTIONS 
--  - upsert a new tuple[lemma, sentId, ctx] (evidence.upsert_example_item)
--  - upsert an example item with score (evidence.upsert_scored_example_item)
-- -----------------------------------------------------------------------

-- 
-- UPSERT EXAMPLE ITEM 
--  - it's a unique tuple of (lemma/keyword, sentence_id, context)
-- 
-- EXAMPLE:
-- --------
--    SELECT evidence.upsert_example_item(
--      'someuuid-lksdklf', 'Bank', '{"homograph": "Kreditinstitut"}');
-- 
-- DROP FUNCTION IF EXISTS evidence.upsert_example_item;
CREATE OR REPLACE FUNCTION evidence.upsert_example_item(
    sentence_id uuid, 
    lemma citext,
    context jsonb
  )
  RETURNS uuid AS
$$
DECLARE
  new_item_id uuid;
BEGIN
  INSERT INTO evidence.example_items(sentence_id, lemma, context) 
       VALUES (sentence_id::uuid, lemma::citext, context::jsonb)
  ON CONFLICT DO NOTHING
  RETURNING item_id INTO new_item_id
  ;
  RETURN new_item_id;
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- UPSERT EXAMPLE ITEM WITH CURRENT SCORE
--  - it's a unique tuple of (lemma/keyword, sentence_id, context)
-- 
-- Example:
-- -------
--    SELECT evidence.upsert_scored_example_item(
--      'kasdjflk', 'Hausschild', '{"prev_sentid": "ddsafjkds"}'::jsonb,
--      0.777, '{"model": "evidence-model", "version": "v0.2"}'::jsonb)
-- 
-- DROP FUNCTION IF EXISTS evidence.upsert_scored_example_item;
CREATE OR REPLACE FUNCTION evidence.upsert_scored_example_item(
    sentence_id uuid, 
    lemma citext, 
    context jsonb,
    score double precision, 
    model_info jsonb
  )
  RETURNS uuid AS
$$
DECLARE
  new_item_id uuid;
BEGIN
  -- upsert 
  INSERT INTO evidence.example_items(sentence_id, lemma, context, score) 
       VALUES (sentence_id::uuid, lemma::citext, context::jsonb, score::double precision)
  ON CONFLICT ON CONSTRAINT uk_example_items_1 DO 
       UPDATE SET score = EXCLUDED.score
  RETURNING item_id INTO new_item_id
  ;
  -- log in score history
  INSERT INTO evidence.score_history(item_id, score, model_info)
       VALUES (new_item_id::uuid, score::double precision, model_info::jsonb)
  ;
  RETURN new_item_id;
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- sentence as text
-- lemma as text
-- score as double
-- 


