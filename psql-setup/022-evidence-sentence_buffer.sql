
-- 
-- Buffer/Cache with raw sentences
-- 
CREATE TABLE IF NOT EXISTS 
evidence.sentences_cache (
    sentence_id     uuid NOT NULL
  , sentence_text   text NOT NULL
  , PRIMARY KEY(sentence_id)
);

