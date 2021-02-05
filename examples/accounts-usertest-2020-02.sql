-- Benutzerkonten für den Benutzertest im Rahmen des Blockseminars an der Uni Potsdam
SELECT auth.add_user('evuser11', '|#>-:)Q.');
SELECT auth.add_user('evuser12', '3(ayE78w');
SELECT auth.add_user('evuser13', '%tM9[S~.');
SELECT auth.add_user('evuser14', 'bIpwzklG');
SELECT auth.add_user('evuser15', '|D0r~}^z');
SELECT auth.add_user('evuser16', 'Xnj|3IRO');
SELECT auth.add_user('evuser17', '+<g54(rV');
SELECT auth.add_user('evuser18', '{FP|D"cR');
SELECT auth.add_user('evuser19', '_ib!#0o|');
SELECT auth.add_user('evuser20', 'SiTLO9N8');


-- 5x Ungerade User: Top-150
SELECT evidence.upsert_user_settings('evuser11'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 150, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser13'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 150, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser15'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 150, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser17'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 150, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser19'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 150, "sampling-offset": 0}'::jsonb);
-- 5x Gerade: Top-10000
SELECT evidence.upsert_user_settings('evuser12'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 10000, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser14'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 10000, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser16'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 10000, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser18'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 10000, "sampling-offset": 0}'::jsonb);
SELECT evidence.upsert_user_settings('evuser20'::text, '{"language": "de", "darkmodetheme": false, "reorderpoint": 5, "orderquantity": 30, "sampling-numtop": 10000, "sampling-offset": 0}'::jsonb);

