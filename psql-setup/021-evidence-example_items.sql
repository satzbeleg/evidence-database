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

-- DROP DOMAIN IF EXISTS auth.username_t;
CREATE DOMAIN evidence.score_t AS double precision
  CHECK ( value >= 0.0 AND value <= 1.0 )
;



-- -----------------------------------------------------------------------
-- (B1) TABLE evidence.example_items
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
evidence.example_items (
    item_id     uuid DEFAULT uuid_generate_v4()
  -- immutable fields (data for unique key)
  , sentence_id uuid NOT NULL
  , lemma       text NOT NULL
  , context     jsonb NOT NULL
  -- mutable fields
  , score       evidence.score_t DEFAULT NULL
  , PRIMARY KEY(item_id)
);

-- keys
CREATE UNIQUE INDEX CONCURRENTLY "uk_example_items_1" 
  ON evidence.example_items USING BTREE (sentence_id, lemma, context)
;

-- search by: sentence_id, lemma, context
CREATE INDEX CONCURRENTLY "bt_example_items_2" 
  ON evidence.example_items USING BTREE (sentence_id)
; -- for "="

CREATE INDEX CONCURRENTLY "bt_example_items_3" 
  ON evidence.example_items USING BTREE (lemma)
; -- for "="

CREATE INDEX CONCURRENTLY "gin_example_items_4" 
  ON evidence.example_items USING GIN (context jsonb_path_ops)
;


-- Kommentare
COMMENT ON COLUMN evidence.example_items.item_id IS 
  'Internal primary key (UUID4) of the table for SQL purposes (e.g. join, foreign key).'
;
COMMENT ON COLUMN evidence.example_items.sentence_id IS 
  'The SentenceID from the SentenceStore API, that relates to the score.'
;
COMMENT ON COLUMN evidence.example_items.lemma IS 
  'Array with lemmata (usually just 1 lemma) that relate to the score'
;
COMMENT ON COLUMN evidence.example_items.context IS 
  'An JSON object with further information that are shown to the users in the UI that in turn might effect the evaluation and thus the score.'
;
COMMENT ON COLUMN evidence.example_items.score IS 
  'A floating number between 0.0 and 1.0'
;


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
  , CONSTRAINT fk_score_history_2 FOREIGN KEY(item_id)
      REFERENCES evidence.example_items(item_id) ON DELETE CASCADE
);

-- keys
CREATE UNIQUE INDEX CONCURRENTLY "uk_score_history_1" 
  ON evidence.score_history USING BTREE (item_id, score, created_at, model_info)
;



-- -----------------------------------------------------------------------
-- (C) TRIGGERS 
-- -----------------------------------------------------------------------

-- n.a.


-- -----------------------------------------------------------------------
-- (D) FUNCTIONS 
--  - upsert a new tuple[lemma, sentId, ctx] (evidence.upsert_example_item)
--  - upsert an example item with score (evidence.upsert_scored_example_item)
--  - Utility function: Add wildcards to each text array element (evidence.add_wildcards_to_text_array_element)
--  - Query by lemmata for random sampling (evidence.query_by_lemmata)
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
    lemma text,
    context jsonb
  )
  RETURNS uuid AS
$$
DECLARE
  new_item_id uuid;
BEGIN
  INSERT INTO evidence.example_items(sentence_id, lemma, context) 
       VALUES (sentence_id::uuid, lemma::text, context::jsonb)
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
    lemma text, 
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
       VALUES (sentence_id::uuid, lemma::text, context::jsonb, score::double precision)
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
-- UTILITY FUNCTION TO ADD SQL WILDCARDS
-- - Add wildcards to each text array element
-- 
-- EXAMPLE
-- -------
--    SELECT evidence.add_wildcard_to_text_array_element('{"hello", "world"}');
-- 
-- DROP FUNCTION IF EXISTS evidence.add_wildcards_to_text_array_element;
CREATE OR REPLACE FUNCTION evidence.add_wildcards_to_text_array_element(arr text[])
  RETURNS text[] AS
$$
BEGIN
  RETURN (select array_agg(tbWild.key)::text[] 
            from (select '%' || unnest(arr::text[]) || '%' as "key") tbWild);
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- UPDATE SCORES FOR A SENTENCE ID
--  - it's a unique tuple of (lemma/keyword, sentence_id, context)
-- 
-- Example:
-- -------
--    SELECT evidence.update_scores(
--      'kasdjflk', 0.777, '{"model": "evidence", "version": "0.1.0"}'::jsonb)
-- 
-- DROP FUNCTION IF EXISTS evidence.update_scores;
CREATE OR REPLACE FUNCTION evidence.update_scores(
    sent_id uuid, 
    score_val double precision, 
    model_info jsonb
  )
  RETURNS void AS
$$
BEGIN
  -- update
  UPDATE evidence.example_items
    SET score=score_val::double precision
  WHERE sentence_id=sent_id::uuid
  ;
  -- log in score history
  INSERT INTO evidence.score_history(item_id, score, model_info)
    SELECT item_id::uuid, score::double precision, model_info::jsonb
      FROM evidence.example_items
    WHERE sentence_id=sent_id::uuid
  ;
END;
$$ 
LANGUAGE plpgsql
;


-- 
-- Query by lemmata for random sampling (pl.)
-- 
-- EXAMPLE
-- -------
--    SELECT * FROM evidence.query_by_lemmata('{impeachment,Nixon}'::text[], NULL, NULL);
--    SELECT * FROM evidence.query_by_lemmata('{impeachment}'::text[], NULL, NULL);
--    SELECT * FROM evidence.query_by_lemmata('{impeachment}'::text[], 5, 3);
--    SELECT * FROM evidence.query_by_lemmata('{impeachment}'::text[], 5, 3) ORDER BY RANDOM() LIMIT 4;
--    SELECT * FROM evidence.query_by_lemmata('{}'::text[], 5, 3);
-- 
-- DROP FUNCTION IF EXISTS evidence.query_by_lemmata;
CREATE OR REPLACE FUNCTION evidence.query_by_lemmata(
    searchlemmata text[],
    n_examples int,
    n_offset int
  )
  RETURNS TABLE (
    sentence_id uuid,
    lemmata text[],
    context jsonb,
    score double precision
  ) AS
$$
BEGIN
  RETURN QUERY 
    SELECT tb2.sentence_id
         , tb2.lemmata
         , tb2.context[1]
         , tb2.score
    FROM (
        SELECT tb1.sentence_id
            , ARRAY_AGG(tb1.lemma) as "lemmata"
            , ARRAY_AGG(tb1.context) as "context"
            , AVG(tb1.score) as "score"
            , COUNT(tb1.sentence_id) as "count"
        FROM (
            SELECT tb0.sentence_id , tb0.context, tb0.lemma, tb0.score
            FROM evidence.example_items tb0
            WHERE (
              CASE
                WHEN array_length(searchlemmata::text[], 1) IS NULL THEN true
                ELSE tb0.lemma = ANY(searchlemmata::text[])
                -- ELSE tb0.lemma LIKE ANY(evidence.add_wildcards_to_text_array_element(
                --         searchlemmata::text[]))
              END)
            ORDER BY tb0.sentence_id, tb0.lemma
        ) tb1
        GROUP BY tb1.sentence_id
    ) tb2
    WHERE (
      CASE
        WHEN array_length(searchlemmata::text[], 1) IS NULL THEN true
        ELSE tb2.count = array_length(searchlemmata::text[], 1)
      END)
    ORDER BY tb2.score DESC
    LIMIT n_examples 
    OFFSET n_offset
    ;
END;
$$ 
LANGUAGE plpgsql
;
