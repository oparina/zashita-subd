REATE OR REPLACE VIEW dispatcher_view
AS
  SELECT
    users.first_name,
    users.last_name,
    contracts.*
  FROM users
    JOIN contracts ON contracts.user_id = users.id;

CREATE ROLE dispatcher;
GRANT SELECT ON TABLE dispatcher_view TO dispatcher;
CREATE USER dispatcher_user
  PASSWORD 'password'
  IN ROLE dispatcher;
