
-- show users
select * from auth.users;

-- Add a new user (returns: uuid)
SELECT auth.add_user('newusername', 'secretpw');

-- Validate user (returns: bool)
SELECT auth.validate_user('newusername', 'secretpw');

-- Check if username is active (returns: bool)
SELECT auth.is_active_user('newusername');

-- Get UserId by username (returns: uuid)
SELECT auth.username_to_userid('newusername');


-- try to delete row in auth.users (Expected to fail)
DELETE FROM auth.users WHERE user_id in (SELECT user_id FROM auth.users LIMIT 1);
