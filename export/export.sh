#!/usr/bin/env bash

# BWS Evaluations
psql --host=127.0.0.1 --port=55015 --username=postgres \
    -d postgres -t -A -F"," -c \
    "SELECT ROW_TO_JSON(tb) FROM (SELECT * FROM evidence.evaluated_bestworst) tb;" \
    | gzip -9 > "evaluated_bestworst-$(date +%Y-%m-%d).json.gz"

# Raw Sentences
# All sents: SELECT ROW_TO_JSON(tb) FROM (SELECT * FROM evidence.sentences_cache) tb;
psql --host=127.0.0.1 --port=55015 --username=postgres \
    -d postgres -t -A -F"," -c \
    "SELECT ROW_TO_JSON(tb) FROM (
        SELECT * FROM evidence.sentences_cache
        WHERE sentence_id IN (
            SELECT (state_sentid_map->>'0')::uuid as "sent_id" FROM evidence.evaluated_bestworst 
            UNION SELECT (state_sentid_map->>'1')::uuid FROM evidence.evaluated_bestworst
            UNION SELECT (state_sentid_map->>'2')::uuid FROM evidence.evaluated_bestworst
            UNION SELECT (state_sentid_map->>'3')::uuid FROM evidence.evaluated_bestworst)
    ) tb;" \
    | gzip -9 > "sentences_cache-$(date +%Y-%m-%d).json.gz"

# Old Scores
psql --host=127.0.0.1 --port=55015 --username=postgres \
    -d postgres -t -A -F"," -c \
    "SELECT ROW_TO_JSON(tb) FROM (
        SELECT sentence_id, lemma, context, score FROM evidence.example_items 
        WHERE score IS NOT NULL
          AND sentence_id IN (
            SELECT (state_sentid_map->>'0')::uuid as "sent_id" FROM evidence.evaluated_bestworst 
            UNION SELECT (state_sentid_map->>'1')::uuid FROM evidence.evaluated_bestworst
            UNION SELECT (state_sentid_map->>'2')::uuid FROM evidence.evaluated_bestworst
            UNION SELECT (state_sentid_map->>'3')::uuid FROM evidence.evaluated_bestworst)
    ) tb;" \
    | gzip -9 > "example_scores-$(date +%Y-%m-%d).json.gz"
