CREATE OR REPLACE VIEW dispatcher_old_view
AS
  SELECT contracts.*
  FROM contracts
  WHERE (contracts.last_activity < now() - INTERVAL '2 years');

GRANT SELECT, DELETE ON TABLE dispatcher_old_view TO dispatcher;
