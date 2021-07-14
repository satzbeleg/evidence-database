-- 
-- Precomputed feature vectors
-- 
-- - The JSONB field `feature_vectors` can store any form of data structure,
--    e.g. a Matrix of any dimension, SpaCy3 outpus, CoNLL-U JSON, etc.
-- - The `model_info` field should contain all information to reproduce the
--    data from the original text data.
-- - It's a 1:N table, i.e. for 1 sentence_id there are N possible feature
--     vector representations possible depending on `model_info`
-- - Mit Hinblick auf die Migration nach CQL muss model_info ein flat dictionary
--     sein (d.h. keine Verschachtelung!)
-- 
-- Example: BERT Representation
-- ----------------------------
-- feature_vectors = [
--     [0.797, 0.106, 0.789, 0.649, 0.870, ...],
--     [0.746, 0.095, 0.099, 0.894, 0.713, ...],
--     ...
-- ]
-- model_info = {
--     "package": "sentence-transformers", 
--     "version": "1.2.0",
--     "model_name": "distiluse-base-multilingual-cased-v1",
--     "dimension": 512,
--     "seqlen": 256,
--     "padding": "post",
--     "truncation": "post"
-- }
--


-- -----------------------------------------------------------------------
-- (B) TABLE 
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
zdlstore.feature_vectors (
    feature_vector_id  uuid DEFAULT uuid_generate_v4()
  -- Unique Key
  , sentence_id     uuid NOT NULL
  , model_info      jsonb NOT NULL
  -- data
  , feature_vectors  real[] NOT NULL
  -- documentation
  , created_at     timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by     text NOT NULL default CURRENT_USER
  , PRIMARY KEY(feature_vector_id)
);


-- key
CREATE UNIQUE INDEX CONCURRENTLY "uk_feature_vector_1" 
  ON zdlstore.feature_vectors USING BTREE (sentence_id, model_info)
;

-- search by: sentence_id
CREATE INDEX CONCURRENTLY "bt_feature_vector_2" 
  ON zdlstore.feature_vectors USING BTREE (sentence_id)
; -- for "="
