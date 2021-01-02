
-- Check if a username is availabe (returns: bool)
SELECT auth.is_available_username('newusername');

-- Add a new user (returns: bool)
SELECT auth.add_new_user('newusername');

-- Get UserId by username (returns: uuid)
SELECT auth.username_to_userid('newusername');

-- Check if username is active (returns: bool)
SELECT auth.is_active_username('newusername');

-- Change account status
SELECT auth.deactivate_account('newusername');
SELECT auth.reactivate_account('newusername');
SELECT auth.request_deletion('newusername');

-- try to delete row in auth.users (Expected to fail)
DELETE FROM auth.users WHERE user_id in (SELECT user_id FROM auth.users LIMIT 1);
