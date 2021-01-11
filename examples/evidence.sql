
-- 
-- WITHOUT LOCAL TEXT BUFFFER
-- - it's assumed that the SentenceStore database exists.
-- - only the `sentence_id` from the SentenceStore is saved in 
--      in `evidence.example_items`
-- - it's assumed that an REST API would connect to the SentenceStore API
--      to read the `sentence_text` associated with the `sentence_id`
-- 


-- 
-- WITH LOCAL TEXT BUFFER
-- - add `sentence_text` along with an example item
-- - this table has it's seperate dummy API(!)
-- - the text data is combined lateron inside the API(!)
-- 


-- 
-- How to save evaluated example sets for BWS-UIs
-- 
INSERT INTO evidence.evaluated_bestworst(
    username, ui_name, set_id, lemmata, event_history, state_sentid_map) 
VALUES
    (
        'testuser456'::text, 
        'bestworst4'::text, 
        uuid_generate_v4()::uuid, 
        '{"lemma1", "lemma2"}'::text[], 
        '[{"data": "goes here"}]'::jsonb, 
        '{"0": "idA", "1": "idB"}'::jsonb
    ),
    (
        'testuser456'::text, 
        'bestworst5'::text, 
        uuid_generate_v4()::uuid, 
        '{"hello", "lemma2"}'::text[], 
        '[{"event": "is stored"}]'::jsonb, 
        '{"0": "idB", "1": "idC"}'::jsonb
    ),
    (
        'testuser789'::text, 
        'bestworst4'::text, 
        uuid_generate_v4()::uuid, 
        '{"lemma1", "world"}'::text[], 
        '[{"data": "makes sense"}]'::jsonb, 
        '{"0": "idA", "1": "idC"}'::jsonb
    )
ON CONFLICT DO NOTHING 
RETURNING set_id
;

-- 
-- WHERE clause on an Array column
-- 
SELECT * FROM evidence.evaluated_bestworst WHERE  'lemma1' = ANY(lemmata);

-- 
-- Duplicate rows for each Lemma
-- 
SELECT set_id, event_history, unnest(lemmata) 
  FROM evidence.evaluated_bestworst 
 WHERE  'lemma1' = ANY(lemmata)
;

