
-- 
-- zdlstore.sentences_cache
-- 
INSERT INTO zdlstore.sentences_cache(sentence_id, sentence_text, annotation) VALUES
(
    '21152788-5dcd-4e4b-80e2-e476b242afbc', 'Moyses hat seinem Feind dem Pharad in dem Wasser deß rothen Meers versencket aber Magdalena in disem Wasser vil besser.',
    '{"tokens": [{"lemma": "Fahrrad", "span": [28, 34]}], "spans": [], "compounds": []}'::jsonb
)
,(
    'b4f02652-dc85-42a3-a51f-c19890ade812', 'Es ist die Ebene von Beisittun, vor dem Ausgange jenes Felsenweges, der durch die Liebe des unglücklichen Fahrat zur schönen Schirin im Morgenlande so berühmt ist.',
    '{"tokens": [], "spans": [{"lemma": "Fahrrad", "span": [106, 112]}], "compounds": []}'::jsonb
)
,(
    'd4f4cc2d-4711-4e56-b2d0-4857aee35b13', 'Letzterer besteht aus einem von 2 Fahrrädern und einem Vorderkarren getragenen Gestelle, unter welchem, von gekuppelten Hebeln getragen, ein für den Tiefgang stellbarer Rahmen mit Scharen angebracht ist.',
    '{"tokens": [{"lemma": "Rahmen"}], "spans": [], "compounds": [{"lemma": "Fahrrad", "spans": [[34, 43]]}]}'::jsonb
)
,(
    'e6db3858-5df3-40cd-bcbb-2fbf5daeab2c', 'Derselbe besteht aus einem durch zwei große Fahrräder im Schwerpunkte unterstützten, schmiedeeisernen Rahmen, an dessen beiden in einem stumpfen Winkel zu einander stehenden Seitentheilen in einer Reihe 4--8 stählerne Pflugkörper befestigt sind.',
    '{"tokens": [{"lemma": "Fahrrad", "span": [44, 53]}, {"lemma": "Rahmen"}]}'::jsonb
)
,(
    '49c53004-455c-4d99-a326-6220bf69006e', 'Die Fahrräder des Grubbers werden durch den Führer gesteuert, der bei dem Kehren des Geräthes nur seinen Sitz zu wechseln hat.',
    '{"tokens": [{"lemma": "Fahrrad", "span": [4, 13]}], "spans": [], "compounds": []}'::jsonb
)
,(
    'ff05db90-ea35-483c-b183-c360258d679a', 'Der Cultivator wird dadurch etwas nach rückwärts geschoben und das neue Fahrrad und mit diesem die Schare durch Aufstellen auf den mit einer Scharspitze versehenen Schuh gehoben.',
    '{"tokens": [{"lemma": "Fahrrad", "span": [72, 79]}], "spans": [], "compounds": []}'::jsonb
)
,(
    '27919871-64b2-43f6-b31e-f64c44439008', 'Wichtig für den Radfahrer ist ferner die Signalglocke, welche in Anbetracht der fast lautlosen Bewegung des Fahrrades unentbehrlich ist, um Collisionen zu vermeiden.',
    '{"tokens": [{"lemma": "Fahrrad", "span": [108, 117]}], "spans": [], "compounds": []}'::jsonb
)
,(
    'ee14aaae-49ff-48f9-a4eb-9956c2574fe5', 'Die Bremsvorrichtung bildet einen wichtigen Bestandtheil des Fahrrades.',
    '{"tokens": [{"lemma": "Fahrrad", "span": [61, 70]}], "spans": [], "compounds": []}'::jsonb
)
,(
    '4c421bd7-d5ad-4749-a1ac-882b42df59ec', 'Solche hohe Personen werfen in der einen Stunde einen Wunsch hin, um ihn in der nächsten zu vergessen.',
    '{"tokens": [], "spans": [], "compounds": [{"lemma": "hinwerfen", "span": [[61,64], [21,27]]}]}'::jsonb
)
,(
    '79dc056b-9d7c-4c38-87dd-c888b75510aa', 'Das warf auch Bonaparte im Gespräch hin.',
    '{"tokens": [], "spans": [], "compounds": [{"lemma": "hinwerfen", "spans": [[36,39], [4,8]]}]}'::jsonb
)
,(
    'f2b98700-7e1f-40b5-b53e-532588651576', 'Denn so lange dies Verhältniß bestanden, war unser Freund zwischen Lust und Gram, zwischen Trotz und Reue, zwischen Begier und Abscheu hin und her geworfen zu keiner eigentlichen Ruhe gelangt.',
    '{"tokens": [], "spans": [], "compounds": [{"lemma": "hinwerfen", "spans": [[135,138], [147,155]]}]}'::jsonb
)
,(
    '1dc4b16b-d9f7-4e9c-aed8-adb4d0fb86e2', 'Ja, so beim Kaffee, so unter der Hand, gelegentlich hingeworfen, erfährt ein Fürst die Wahrheit -- von guten Freunden.',
    '{"tokens": [{"lemma": "hinwerfen", "span": [52, 63]}], "spans": [], "compounds": []}'::jsonb
)
,(
    '11b8c10f-3340-414a-9737-a1979c6eb1aa', 'Ueberall hin warf es seine Schatten.',
    '{"tokens": [], "spans": [{"lemma": "hinwerfen", "span": [9, 17]}], "compounds": []}'::jsonb
)
,(
    'b85c4f88-809d-4bd7-accc-3aceb4ecda42', 'Nun lebten sie frech in kurzen Lüsten, und über den Tag hin warfen sie kaum noch Ziele.',
    '{"tokens": [], "spans": [{"lemma": "hinwerfen", "span": [56, 66]}], "compounds": []}'::jsonb
)
ON CONFLICT DO NOTHING
;


-- WILL NOT USE THE CORRECT LEMMATA
-- Generate fake example items
-- A1. Whitespace Tokenization with STRING_TO_ARRAY
-- A2. Expand sql array row to N txt rows (UNNEST)
-- A3. Trim each string
-- A4. Remove all non-alphanumeric symbols
-- B. Add some non-saying context data
-- C. Generate random score
-- 
-- INSERT INTO evidence.example_items (sentence_id, lemma, context, score)
--     SELECT sentence_id
--         , regexp_replace(regexp_replace(
--                 UNNEST(STRING_TO_ARRAY(sentence_text, ' ')),
--                 '[\s+]', '', 'g'), '\W+', '', 'g')::text as "lemma"
--         , '{"publisher": "DWDS Wörterbuch"}'::jsonb as "context"
--         , random()::double precision as "score"
--     FROM zdlstore.sentences_cache
-- ON CONFLICT DO NOTHING
-- ;


-- tokens
INSERT INTO evidence.example_items (sentence_id, lemma, context, score)
    select sentence_id, lemma
         , '{"publisher": "DWDS Wörterbuch"}'::jsonb as "context"
         , random()::double precision as "score"
    from (
        select sentence_id, annotation -> 'tokens' -> 0 -> 'lemma' #>>'{}' as "lemma" from zdlstore.sentences_cache 
        union select sentence_id, annotation -> 'tokens' -> 1 -> 'lemma' #>>'{}' as "lemma" from zdlstore.sentences_cache 
    ) tb 
    where lemma is not null
ON CONFLICT DO NOTHING
;
-- spans
INSERT INTO evidence.example_items (sentence_id, lemma, context, score)
    select sentence_id, lemma
         , '{"publisher": "DWDS Wörterbuch"}'::jsonb as "context"
         , random()::double precision as "score"
    from (select sentence_id, annotation -> 'spans' -> 0 -> 'lemma' #>>'{}' as "lemma"
        from zdlstore.sentences_cache ) tb 
    where lemma is not null
ON CONFLICT DO NOTHING
;
-- compounds
INSERT INTO evidence.example_items (sentence_id, lemma, context, score)
    select sentence_id, lemma
         , '{"publisher": "DWDS Wörterbuch"}'::jsonb as "context"
         , random()::double precision as "score"
    from (select sentence_id, annotation -> 'compounds' -> 0 -> 'lemma' #>>'{}' as "lemma"
        from zdlstore.sentences_cache ) tb 
    where lemma is not null
ON CONFLICT DO NOTHING
;


-- Insert fake feature vectors
INSERT INTO zdlstore.feature_vectors (sentence_id, model_info, feature_vectors)
SELECT sentence_id
     , '{"model": "random-demo-features", "version": "0.1.2"}'::jsonb
     , (select array_agg((2.0 * random() - 1.0)::real) from generate_series (0, 567))::real[]
FROM zdlstore.sentences_cache
;
