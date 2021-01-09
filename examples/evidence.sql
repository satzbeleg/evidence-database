
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

