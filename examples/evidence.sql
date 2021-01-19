
-- 
-- Sample random examples
-- - see `evidence.query_by_lemmata`
-- 
SELECT tb2.sentence_id, tb2.lemmata, tb2.context[1], tb2.score, tb2.count
     -- , evidence.get_sentence_text(tb2.sentence_id) as "sentence_text"
FROM (
    SELECT tb1.sentence_id
        , ARRAY_AGG(tb1.lemma) as "lemmata"
        , ARRAY_AGG(tb1.context) as "context"
        , AVG(score) as "score"
        , COUNT(tb1.sentence_id) as "count"
    FROM (
        SELECT sentence_id , context, lemma, score
        FROM evidence.example_items tb0
        WHERE (
            CASE
                WHEN array_length('{impeachment,Nixon}'::text[], 1) IS NULL THEN true
                ELSE tb0.lemma LIKE ANY(evidence.add_wildcards_to_text_array_element(
                    '{impeachment,Nixon}'::citext[]))
            END)
        ORDER BY tb0.sentence_id, tb0.lemma
    ) tb1
    GROUP BY tb1.sentence_id
) tb2
WHERE (
    CASE
        WHEN array_length('{impeachment,Nixon}'::text[], 1) IS NULL THEN true
        ELSE tb2.count = array_length('{impeachment,Nixon}'::text[], 1)
    END)
ORDER BY tb2.score DESC
LIMIT NULL OFFSET 1
;


-- test if no specific lemmata were requested
SELECT tb2.sentence_id, tb2.lemmata, tb2.context[1], tb2.score, tb2.count
     -- , evidence.get_sentence_text(tb2.sentence_id) as "sentence_text"
FROM (
    SELECT tb1.sentence_id
        , ARRAY_AGG(tb1.lemma) as "lemmata"
        , ARRAY_AGG(tb1.context) as "context"
        , AVG(score) as "score"
        , COUNT(tb1.sentence_id) as "count"
    FROM (
        SELECT sentence_id , context, lemma, score
        FROM evidence.example_items tb0
        WHERE (
            CASE
                WHEN array_length('{}'::text[], 1) IS NULL THEN true
                ELSE tb0.lemma LIKE ANY(evidence.add_wildcards_to_text_array_element(
                    '{}'::citext[]))
            END)
        ORDER BY tb0.sentence_id, tb0.lemma
    ) tb1
    GROUP BY tb1.sentence_id
) tb2
WHERE (
    CASE
        WHEN array_length('{}'::text[], 1) IS NULL THEN true
        ELSE tb2.count = array_length('{}'::text[], 1) 
    END)
ORDER BY tb2.score DESC
LIMIT NULL OFFSET 1
;



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

-- 
-- Stats lemma
-- 
SELECT lemma
     , count(sentence_id) as "num_sents"
  FROM evidence.example_items
GROUP BY lemma
LIMIT 100
; 


-- lösche lemma mit Zahlen
delete from evidence.example_items where lemma ~ '^[0-9\.]+$';
