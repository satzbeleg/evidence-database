-- 
-- Add test accounts (Don't delete!)
-- 
SELECT auth.add_user('testuser2', 'secret2');

-- Query
SELECT * FROM auth.users;



-- Email
SELECT auth.add_new_email_account('test123@example.com', 'secret3');
SELECT auth.validate_email_password('test123@example.com', 'secret3');
SELECT auth.validate_email_password2('test123@example.com', 'secret3');
SELECT auth.email_isactive(auth.lookup_userid_by_email('test123@example.com'));
SELECT * FROM auth.emails;
-- Verify
SELECT auth.issue_verification_token(auth.lookup_userid_by_email('test123@example.com'));
SELECT * FROM auth.verify;
SELECT auth.check_verification_token(auth.issue_verification_token(auth.lookup_userid_by_email('test123@example.com')));
SELECT * FROM auth.verify;
SELECT * FROM auth.emails;
