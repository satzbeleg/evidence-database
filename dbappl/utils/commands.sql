
-- Detect invalid indices
SELECT * FROM pg_class, pg_index 
WHERE pg_index.indisvalid = false 
  AND pg_index.indexrelid = pg_class.oid;


-- Rebuild indices
CALL evidence.rebuild_indices();
CALL zdlstore.rebuild_indices();
CALL auth.rebuild_indices();
