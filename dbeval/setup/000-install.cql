
-- DROP KEYSPACE IF EXISTS evidence;
CREATE KEYSPACE IF NOT EXISTS evidence
WITH REPLICATION = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
};


-- 
-- EVIDENCE.EXAMPLES
-- Dataset with preprocessed training examples
-- - One `example_id` refers to a tuple (headword, sentence_text)
-- - Preprocessed embeddings are stored as 8-bit integer vectors,
--   e.g., boolean hashed embeddings, count data up to +127.
-- - It is only possible read ALL examples for a given headword
--   (i.e. `... WHERE headword=?;` because it is the partition key).
-- - It is NOT possible to update specific examples. You must
--   download the whole partition (i.e. all examples per headword),
--   delete the partition, and insert it as a new parition again.
-- 
-- DROP TABLE IF EXISTS evidence.examples
CREATE TABLE IF NOT EXISTS 
evidence.examples (
    example_id    UUID   -- or `item_id`
  , sentence_text TEXT
  , headword      TEXT
  -- embedding data for model training
  , features1  frozen<list<TINYINT>>
  , features2  frozen<list<TINYINT>>
  -- UI info
  , spans   frozen<list<frozen<list<SMALLINT>>>>
  -- meta info
  , sentence_id TEXT  -- e.g. FoliaID
  , license     TEXT
  , initial_score FLOAT
  -- WHERE clause
  , PRIMARY KEY (headword, sentence_text)
);


-- 
-- EVIDENCE.EVALUATED_BESTWORST
-- Store
-- 
-- DROP TABLE IF EXISTS evidence.evaluated_bestworst
-- CREATE TABLE IF NOT EXISTS 
-- evidence.evaluated_bestworst (
--     set_id  UUID
--   , user_id UUID
--   , ui_name TEXT
--   -- data
--   , headword          TEXT
--   , event_history     jsonb NOT NULL
--   , state_sentid_map  jsonb NOT NULL
--   -- tracking data
--   , tracking_data     jsonb DEFAULT NULL
--   -- documentation
--   , created_at     timestamp NOT NULL default CURRENT_TIMESTAMP
--   , created_by     text NOT NULL default CURRENT_USER
--   -- WHERE clause
--   , PRIMARY KEY(headword)
-- );


-- 
-- EVIDENCE.INTERACTIVITY_CONVERGENCE
-- - Compare convergence of model scores vs training scores
-- - Exclude previously shown sentences (Cannot be reset)
-- 
-- CREATE TABLE IF NOT EXISTS 
-- evidence.interactivity_convergence (
--     episode_id  uuid DEFAULT uuid_generate_v4() 
--   -- recorded episode
--   , training_score_history  real[] NOT NULL
--   , model_score_history     real[] NOT NULL
--   , displayed               boolean[] NOT NULL
--   -- documentation
--   , user_id       uuid NOT NULL
--   , sentence_id   uuid NOT NULL
--   , created_at    timestamp NOT NULL default CURRENT_TIMESTAMP
--   , created_by    text NOT NULL default CURRENT_USER
--   , PRIMARY KEY(episode_id)
-- );

