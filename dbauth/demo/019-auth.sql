-- 
-- Add test accounts (Don't delete!)
-- 
SELECT auth.add_user('testuser2', 'secret2');

-- Query
SELECT * FROM auth.users;
