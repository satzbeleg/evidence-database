-- Rebuild indices
-- CALL evidence.rebuild_indices();
DROP PROCEDURE IF EXISTS evidence.rebuild_indices;

CREATE OR REPLACE PROCEDURE evidence.rebuild_indices()
AS $$
DECLARE
BEGIN
    -- 020-evidence-user_settings.sql
    DROP INDEX IF EXISTS evidence."uk_user_settings_1" ;
    DROP INDEX IF EXISTS evidence."gin_user_settings_2" ;
    CREATE UNIQUE INDEX "uk_user_settings_1" ON evidence.user_settings USING BTREE (user_id) ;
    CREATE INDEX "gin_user_settings_2" ON evidence.user_settings USING GIN (settings jsonb_path_ops) ;
    -- 021-evidence-example_items.sql
    DROP INDEX IF EXISTS evidence."uk_example_items_1" ;
    DROP INDEX IF EXISTS evidence."bt_example_items_2" ;
    DROP INDEX IF EXISTS evidence."bt_example_items_3" ;
    DROP INDEX IF EXISTS evidence."gin_example_items_4" ;
    CREATE UNIQUE INDEX "uk_example_items_1"  ON evidence.example_items USING BTREE (sentence_id, lemma, context) ;
    CREATE INDEX "bt_example_items_2" ON evidence.example_items USING BTREE (sentence_id) ;
    CREATE INDEX "bt_example_items_3" ON evidence.example_items USING BTREE (lemma) ;
    CREATE INDEX "gin_example_items_4" ON evidence.example_items USING GIN (context jsonb_path_ops) ;
    -- table 2
    DROP INDEX IF EXISTS evidence."uk_score_history_1" ;
    CREATE UNIQUE INDEX "uk_score_history_1" ON evidence.score_history USING BTREE (item_id, score, created_at, model_info) ;
    -- 023-evidence-evaluated.sql
    DROP INDEX IF EXISTS evidence."bt_evaluated_bestworst_1" ;
    DROP INDEX IF EXISTS evidence."bt_evaluated_bestworst_2" ;
    DROP INDEX IF EXISTS evidence."gin_evaluated_bestworst_3" ;
    DROP INDEX IF EXISTS evidence."gin_evaluated_bestworst_4" ;
    DROP INDEX IF EXISTS evidence."gin_evaluated_bestworst_5" ;
    DROP INDEX IF EXISTS evidence."gin_evaluated_bestworst_6" ;
    CREATE INDEX "bt_evaluated_bestworst_1" ON evidence.evaluated_bestworst USING BTREE (user_id) ;
    CREATE INDEX "bt_evaluated_bestworst_2" ON evidence.evaluated_bestworst USING BTREE (ui_name) ;
    CREATE INDEX "gin_evaluated_bestworst_3" ON evidence.evaluated_bestworst USING GIN (lemmata array_ops) ;
    CREATE INDEX "gin_evaluated_bestworst_4" ON evidence.evaluated_bestworst USING GIN (event_history jsonb_path_ops) WHERE event_history IS NOT NULL ;
    CREATE INDEX "gin_evaluated_bestworst_5" ON evidence.evaluated_bestworst USING GIN (state_sentid_map jsonb_path_ops) WHERE state_sentid_map IS NOT NULL ;
    CREATE INDEX "gin_evaluated_bestworst_6" ON evidence.evaluated_bestworst USING GIN (tracking_data jsonb_path_ops) WHERE tracking_data IS NOT NULL ;
    -- 024-evidence-interactivity-deleted.sql
    DROP INDEX IF EXISTS evidence."uk_interactivity_deleted_episodes_1" ;
    DROP INDEX IF EXISTS evidence."bt_interactivity_deleted_episodes_2" ;
    DROP INDEX IF EXISTS evidence."bt_interactivity_deleted_episodes_3" ;
    CREATE UNIQUE INDEX "uk_interactivity_deleted_episodes_1" ON evidence.interactivity_deleted_episodes USING BTREE (user_id, sentence_id, created_at) ;
    CREATE INDEX "bt_interactivity_deleted_episodes_2" ON evidence.interactivity_deleted_episodes USING BTREE (user_id) ;
    CREATE INDEX "bt_interactivity_deleted_episodes_3" ON evidence.interactivity_deleted_episodes USING BTREE (sentence_id) ;
END;
$$
LANGUAGE plpgsql
;

-- Rebuild indices
-- CALL zdlstore.rebuild_indices();
DROP PROCEDURE IF EXISTS zdlstore.rebuild_indices;

CREATE OR REPLACE PROCEDURE zdlstore.rebuild_indices()
AS $$
DECLARE
BEGIN
    -- 030-zdlstore-sentence_buffer.sql
    DROP INDEX IF EXISTS zdlstore."uk_sentences_cache_1" ;
    DROP INDEX IF EXISTS zdlstore."gin_sentences_cache_2" ;
    DROP INDEX IF EXISTS zdlstore."bt_sentences_cache_3" ;
    DROP INDEX IF EXISTS zdlstore."gin_sentences_cache_4" ;
    CREATE UNIQUE INDEX "uk_sentences_cache_1" ON zdlstore.sentences_cache USING BTREE (digest(sentence_text, 'sha512'::text)) ;
    CREATE INDEX "gin_sentences_cache_2" ON zdlstore.sentences_cache USING GIN (sentence_text gin_trgm_ops) ;
    CREATE INDEX "bt_sentences_cache_3" ON zdlstore.sentences_cache USING BTREE (sentence_text) ;
    CREATE INDEX "gin_sentences_cache_4" ON zdlstore.sentences_cache USING GIN (annotation jsonb_path_ops) WHERE annotation IS NOT NULL  ;
    -- 031-zdlstore-feature_vectors.sql
    DROP INDEX IF EXISTS zdlstore."uk_feature_vector_1" ;
    DROP INDEX IF EXISTS zdlstore."bt_feature_vector_2" ;
    CREATE UNIQUE INDEX "uk_feature_vector_1" ON zdlstore.feature_vectors USING BTREE (sentence_id, model_info) ;
    CREATE INDEX "bt_feature_vector_2" ON zdlstore.feature_vectors USING BTREE (sentence_id) ;
END;
$$
LANGUAGE plpgsql
;