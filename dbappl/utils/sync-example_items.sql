-- 
-- docker exec -it zdl_evidence_db bash
-- psql -U evidence evidence -f sync-example_items.sql
-- 
INSERT INTO evidence.example_items (sentence_id, lemma, context, score)
    select tb.sentence_id
        , tb.lemma
        , json_build_object('source', source, 'license', license) as "context"
        , random()::double precision as "score"
    from (
        select t.sentence_id
            , t.annotation -> 'source' as "source"
            , t.annotation -> 'license' as "license"
            , tokens -> 'lemma' as "lemma"
        from zdlstore.sentences_cache as t
        , jsonb_array_elements(annotation -> 'tokens') as "tokens"
    ) as tb
ON CONFLICT DO NOTHING
;

