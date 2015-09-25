CREATE USER dispatcher IDENTIFIED BY pass;

GRANT CREATE SESSION TO dispatcher;

CREATE OR REPLACE VIEW dispatcher_view
  AS SELECT *
  FROM contracts
  WHERE rownum <= 5
  ORDER BY contractid DESC;
  
GRANT SELECT ON dispatcher_view TO dispatcher;
