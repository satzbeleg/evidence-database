-- 
-- Purpose
-- - Compare convergence of model scores vs training scores
-- - Exclude previously shown sentences (Cannot be reset)
-- 

-- -----------------------------------------------------------------------
-- (A) REQUIRED TYPES
-- -----------------------------------------------------------------------

--  n.a.


-- -----------------------------------------------------------------------
-- (B) TABLE 
-- - Unique: (user_id, sentence_id, created_at)
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS 
evidence.interactivity_deleted_episodes (
    episode_id  uuid DEFAULT uuid_generate_v4() 
  -- recorded episode
  , training_score_history  real[] NOT NULL
  , model_score_history     real[] NOT NULL
  , displayed               boolean[] NOT NULL
  -- documentation
  , user_id       uuid NOT NULL
  , sentence_id   uuid NOT NULL
  , created_at    timestamp NOT NULL default CURRENT_TIMESTAMP
  , created_by    text NOT NULL default CURRENT_USER
  , PRIMARY KEY(episode_id)
);

-- keys
CREATE UNIQUE INDEX "uk_interactivity_deleted_episodes_1" 
  ON evidence.interactivity_deleted_episodes USING BTREE (user_id, sentence_id, created_at)
;

-- search by: user_id, sentence_id
CREATE INDEX "bt_interactivity_deleted_episodes_2" 
  ON evidence.interactivity_deleted_episodes USING BTREE (user_id)
; -- for "="

CREATE INDEX "bt_interactivity_deleted_episodes_3" 
  ON evidence.interactivity_deleted_episodes USING BTREE (sentence_id)
; -- for "="


-- -----------------------------------------------------------------------
-- (C) TRIGGERS 
-- -----------------------------------------------------------------------

-- n.a.


-- -----------------------------------------------------------------------
-- (D) FUNCTIONS 
-- -----------------------------------------------------------------------

-- n.a.


