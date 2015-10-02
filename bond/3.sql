-- 1)

create or replace TYPE AccountStateRowSet AS TABLE OF AccountStateRow;

create or replace TYPE AccountStateRow AS OBJECT (
  ACC_ID NUMBER(38),
  ACC_STATE NUMBER
);

create or replace FUNCTION SHOW_MY_ACCOUNTS
  RETURN AccountStateRowSet PIPELINED
IS
  out_row AccountStateRow := AccountStateRow(NULL,NULL);
BEGIN
  FOR item IN
    (SELECT ACC_ID, ACC_STATE FROM BANK_ACC_STATE
      WHERE
        (SELECT BANK_ACCOUNTS.ACC_USER_ID
            FROM BANK_ACCOUNTS
            WHERE BANK_ACCOUNTS.ACC_ID = BANK_ACC_STATE.ACC_ID)
            =
        (SELECT USER_ID FROM USER_TO_USER_MAPPING WHERE USER_NAME = USER))
  LOOP
    out_row.ACC_ID := item.ACC_ID;
    out_row.ACC_STATE := item.ACC_STATE;
    PIPE ROW(out_row);
  END LOOP;
END;

INSERT INTO USER_TO_USER_MAPPING (USER_ID, USER_NAME) VALUES (3, USER);
CREATE ROLE BANK_USER_ROLE NOT IDENTIFIED;

GRANT EXECUTE ON SHOW_MY_ACCOUNTS TO BANK_USER_ROLE;

GRANT BANK_USER_ROLE TO BANK_CLIENT_USER;

SELECT SHOW_MY_ACCOUNTS() FROM DUAL;

-- 2)

CREATE OR REPLACE PROCEDURE DELETE_USER_WITH_NO_CREDITS
  (USER_TO_DELETE_ID NUMBER)
IS
  CR_COUNT INTEGER;
BEGIN
    SELECT COUNT(*) INTO CR_COUNT
    FROM BANK_CREDITS
    WHERE CR_ACC_ID IN (
      SELECT ACC_ID
      FROM BANK_ACCOUNTS
      WHERE ACC_USER_ID = USER_TO_DELETE_ID);
      
  IF CR_COUNT != 0 THEN
    RETURN;
  END IF;

  DELETE FROM BANK_CREDIT_CARDS WHERE CC_ACC_ID IN
    (SELECT ACC_ID FROM BANK_ACCOUNTS WHERE ACC_USER_ID = USER_TO_DELETE_ID);
  DELETE FROM BANK_ACCOUNTS WHERE ACC_USER_ID = USER_TO_DELETE_ID;
  DELETE FROM BANK_USER_DOCS WHERE DOC_USER_ID = USER_TO_DELETE_ID;
  DELETE FROM BANK_USERS WHERE BANK_USERS.USER_ID = USER_TO_DELETE_ID;
END;
