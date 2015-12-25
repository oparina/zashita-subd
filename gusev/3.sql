--1
CREATE OR REPLACE VIEW my_calls_view
  AS SELECT calls.*
  FROM calls
  JOIN contracts ON (
    calls.callerid = contracts.contractid
    OR calls.receiverid = contracts.contractid)
  JOIN users ON users.userid = contracts.userid
  WHERE users.username = (SELECT user FROM dual);

GRANT SELECT ON my_calls_view TO dispatcher;
SELECT * FROM my_calls_view;

--3
CREATE USER dispatcher IDENTIFIED BY pass;

GRANT CREATE SESSION TO dispatcher;

CREATE OR REPLACE VIEW dispatcher_view
  AS SELECT *
  FROM contracts
  WHERE rownum <= 5
  ORDER BY contractid DESC;
  
GRANT SELECT ON dispatcher_view TO dispatcher;

SELECT * FROM gusev.dispatcher_view;

--2
CREATE OR REPLACE VIEW another_dispatcher_view
  AS SELECT contracts.*, users.firstname, users.lastname
  FROM contracts
  JOIN users ON contracts.USERID = users.USERID;
  
GRANT SELECT ON another_dispatcher_view TO dispatcher;

SELECT * FROM gusev.another_dispatcher_view;

--5
CREATE OR REPLACE VIEW client_view
  AS SELECT contracts.*
  FROM contracts
  WHERE contracts.lastaction < ADD_MONTHS(TRUNC(SYSDATE), -24);

GRANT SELECT, DELETE ON client_view TO dispatcher;

SELECT * FROM gusev.client_view;
DELETE FROM gusev.client_view WHERE contractid = 1;
