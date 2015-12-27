CREATE OR REPLACE VIEW dispatcher_limited_view
AS
  SELECT calls.*
  FROM calls
  LIMIT 5;

GRANT SELECT ON TABLE dispatcher_limited_view TO dispatcher;
