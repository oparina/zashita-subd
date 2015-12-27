EATE OR REPLACE VIEW client_view
AS
  SELECT (calls.*)
  FROM calls
    JOIN contracts ON (contracts.id = calls.caller_id OR contracts.id = calls.receiver_id)
    JOIN users ON users.id = contracts.user_id
  WHERE users.user_name = (SELECT current_user);

CREATE ROLE client;
GRANT SELECT ON TABLE client_view TO client;
CREATE USER john
  PASSWORD 'password'
  IN ROLE client;
