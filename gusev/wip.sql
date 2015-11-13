--1
CREATE OR REPLACE TYPE callInfo AS OBJECT (
  callid NUMBER,
  calldate DATE,
  receiverid NUMBER(4),
  callerid NUMBER(4),
  callduration NUMBER
);

CREATE OR REPLACE TYPE callsSet AS TABLE OF callInfo;

CREATE OR REPLACE FUNCTION showCalls
  RETURN callsSet PIPELINED
IS
  out_row callInfo := callInfo(NULL,NULL,NULL,NULL,NULL);
BEGIN
  FOR item IN
    (SELECT callid, calldate, receiverid, callerid, callduration FROM calls
      WHERE
        calls.callerid = 
          (SELECT users.userid 
            FROM users
            WHERE users.username = (SELECT user FROM dual))
      OR
        calls.receiverid = 
          (SELECT users.userid 
            FROM users
            WHERE users.username = (SELECT user FROM dual)))
  LOOP
    out_row.callid := item.callid;
    out_row.calldate := item.calldate;
    out_row.receiverid := item.receiverid;
    out_row.callerid := item.callerid;
    out_row.callduration := item.callduration;
    PIPE ROW(out_row);
  END LOOP;
END;

CREATE ROLE userRole NOT IDENTIFIED;
GRANT EXECUTE ON showCalls TO userRole;
GRANT userRole TO gusev;

--3
CREATE USER dispatcher IDENTIFIED BY pass;

GRANT CREATE SESSION TO dispatcher;

CREATE OR REPLACE VIEW dispatcher_view
  AS SELECT *
  FROM contracts
  WHERE rownum <= 5
  ORDER BY contractid DESC;
  
GRANT SELECT ON dispatcher_view TO dispatcher;

--2
CREATE OR REPLACE VIEW another_dispatcher_view
  AS SELECT contracts.*, users.firstname, users.lastname
  FROM contracts
  JOIN users ON contracts.USERID = users.USERID;
  
GRANT SELECT ON another_dispatcher_view TO dispatcher;

--5
CREATE MATERIALIZED VIEW old_calls
  AS SELECT *
  FROM calls;

GRANT DELETE ON old_calls TO gusev;
