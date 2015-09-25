CREATE OR REPLACE VIEW another_dispatcher_view
  AS SELECT contracts.*, users.firstname, users.lastname
  FROM contracts
  JOIN users ON contracts.USERID = users.USERID;
  
GRANT SELECT ON another_dispatcher_view TO dispatcher;
