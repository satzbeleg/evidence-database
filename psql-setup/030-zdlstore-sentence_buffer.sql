-- 
-- Buffer/Cache with raw sentences
-- 
-- Requirements:
-- -------------
--    - it's assumed that the `sentence_id` was generated by the SentenceStore, 
--        and the raw text data is retrieved from the SentenceSTore API
--    - DON'T use this TABLE nor the FUNCTION inside this database!
--    - Call `zdlstore.get_sentence_text()` only within the Evidence REST API
--        to mimic the SentenceStore API as a temporary solution!
-- 
-- Overview:
-- ---------
--    (A) Required Types => DON'T SPECIFY ANY!
--    (B) Table 
--    (C) Triggers  => DON'T SPECIFY ANY!
--    (D) Other Functions 
-- 


-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------

--  n.a.


-- -----------------------------------------------------------------------
-- (B) TABLE 
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
zdlstore.sentences_cache (
    sentence_id     uuid NOT NULL
  , sentence_text   text NOT NULL
  , annotation      jsonb DEFAULT NULL
  , PRIMARY KEY(sentence_id)
);

-- key
CREATE UNIQUE INDEX CONCURRENTLY "uk_sentences_cache_1" 
  ON zdlstore.sentences_cache USING BTREE (digest(sentence_text, 'sha512'::text))
;

-- search by: (sentence_id), sentence_text
CREATE INDEX CONCURRENTLY "gin_sentences_cache_2" 
  ON zdlstore.sentences_cache USING GIN (sentence_text gin_trgm_ops)
; -- for LIKE, ILIKE, ~ and ~* regex

CREATE INDEX CONCURRENTLY "bt_sentences_cache_3" 
  ON zdlstore.sentences_cache USING BTREE (sentence_text)
; -- for "="

CREATE INDEX CONCURRENTLY "gin_sentences_cache_4" 
  ON zdlstore.sentences_cache USING GIN (annotation jsonb_path_ops)
  WHERE annotation IS NOT NULL 
;



-- -----------------------------------------------------------------------
-- (C) TRIGGERS 
-- -----------------------------------------------------------------------

-- n.a.


-- -----------------------------------------------------------------------
-- (D) FUNCTIONS 
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION zdlstore.get_sentence_text(sent_id uuid)
  RETURNS text AS
$$
BEGIN
  RETURN (SELECT sentence_text FROM zdlstore.sentences_cache WHERE sentence_id=sent_id);
END;
$$ 
LANGUAGE plpgsql
;
