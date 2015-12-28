---
-- INIT
---

CREATE TABLE KOSTYUCHENKO.L5_CUSTOMERS (
  CUSTOMER_ID INT,
  CUSTOMER_NAME VARCHAR2(30) NOT NULL,
  CUSTOMER_IS_ADMIN INT NOT NULL,
  PRIMARY KEY(CUSTOMER)
);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMERS VALUES (5, 'KOSTYUCHENKO5', 0);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMERS VALUES (6, 'KOSTYUCHENKO6', 0);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMERS VALUES (7, 'KOSTYUCHENKO7', 1);

CREATE TABLE KOSTYUCHENKO.L5_CUSTOMS (
  CUSTOM_ID INT,
  CUSTOM_NAME VARCHAR(255),
  CUSTOMER_ID INT,

  PRIMARY KEY(CUSTOM_ID),
  FOREIGN KEY(CUSTOMER_ID) REFERENCES L5_CUSTOMERS(CUSTOMER_ID) ON DELETE CASCADE
);

INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (1, 'lakto', 5);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (2, 'fromagxo', 5);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (3, 'bovajxo', 5);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (4, 'viando', 6);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (5, 'porkajxo', 6);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (6, 'legomoj', 7);
INSERT INTO KOSTYUCHENKO.L5_CUSTOMS VALUES (7, 'fragoj', 7);

CREATE USER KOSTYUCHENKO5 IDENTIFIED BY mnbvcxz;
GRANT CREATE SESSION TO KOSTYUCHENKO5;
GRANT SELECT, INSERT, UPDATE, DELETE ON L5_CUSTOMS TO KOSTYUCHENKO5;

CREATE USER KOSTYUCHENKO6 IDENTIFIED BY mnbvcxz;
GRANT CREATE SESSION TO KOSTYUCHENKO6;
GRANT SELECT, INSERT, UPDATE, DELETE ON L5_CUSTOMS TO KOSTYUCHENKO6;

CREATE USER KOSTYUCHENKO7 IDENTIFIED BY mnbvcxz;
GRANT CREATE SESSION TO KOSTYUCHENKO7;
GRANT SELECT, INSERT, UPDATE, DELETE ON L5_CUSTOMS TO KOSTYUCHENKO7;

---
-- USTANOVKA KONTEKSTA
---

CREATE OR REPLACE CONTEXT L5_CONTEXT USING KOSTYUCHENKO.L5_CONTEXT_FUNCTION;

CREATE OR REPLACE PROCEDURE L5_CONTEXT_FUNCTION
(P_USERNAME IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV','SESSION_USER'))
AS
  A NUMBER;
  B NUMBER;
  C VARCHAR2(255) DEFAULT 'SECR_CUSTOMER';
BEGIN
  SELECT COUNT(*) INTO B FROM DUAL
    WHERE EXISTS
    (
      SELECT * FROM KOSTYUCHENKO.L5_CUSTOMERS
      WHERE (CUSTOMER_NAME = P_USERNAME) and (CUSTOMER_IS_ADMIN=1)
    )
  ;

  IF (B<>0) THEN
    DBMS_SESSION.SET_CONTEXT(C, 'ROLENAME', 'ADMIN');
  ELSE
    SELECT COUNT(*) INTO B FROM DUAL
      WHERE EXISTS
      (
        SELECT * FROM IVANOV.UPRAV
        WHERE (CUSTOMER_NAME = P_USERNAME) and (CUSTOMER_IS_ADMIN=0)
      )
    ;

    IF (B<>0) THEN
      DBMS_SESSION.SET_CONTEXT(C, 'ROLENAME', 'CUSTOMER');
    END IF;
  END IF;
END L5_CONTEXT_FUNCTION;


CREATE OR REPLACE TRIGGER L5_LOG_TRIGGER
AFTER LOGON ON DATABASE
BEGIN
  EXEC L5_CONTEXT_FUNCTION;
END;

---
-- POLITIKA PEZOPASNOSTI
---

CREATE OR REPLACE PACKAGE BODY L5_PREDICATE
AS
  X CONSTANT VARCHAR2(30) DEFAULT 'SECR_CUSTOMER';
  S VARCHAR2(1024) DEFAULT NULL;
  P VARCHAR2(1024) DEFAULT NULL;

  FUNCTION SELECT_FUNCTION(P_SCHEMA IN VARCHAR2, P_OBJECT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (S IS NULL) THEN
      IF (SYS_CONTEXT(X, 'ROLENAME') = 'ADMIN') THEN
        S:= '1=1';
      ELSIF(SYS_CONTEXT(X, 'ROLENAME') = 'CUSTOMER') THEN
        S := 'CUSTOMER_ID IN SELECT CUSTOMER_ID FROM CUSTOMERS
        WHERE UPPER(CUSTOMER_NAME)= USER';
      END IF;
    END IF;
    RETURN S;
  END;

  FUNCTION UPDATE_FUNCTION(P_SCHEMA IN VARCHAR2, P_OBJECT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (P IS NULL) THEN
      IF (SYS_CONTEXT(X, 'ROLENAME') = 'ADMIN') THEN
        P:= '1=1';
      ELSIF(SYS_CONTEXT(X, 'ROLENAME') = 'CUSTOMER') THEN
        P:='1=0';
      END IF;
    END IF;
    RETURN P;
  END;
END L5_PREDICATE;


---
-- wtf is goin on
---

EXEC DBMS_RLS.ADD_POLICY (
  OBJECT_SCHEMA   => 'KOSTYUCHENKO',
  OBJECT_NAME     => 'L5_CUSTOMS',
  POLICY_NAME     => 'L5_POLICY_SELECT',
  FUNCTION_SCHEMA => 'KOSTYUCHENKO',
  POLICY_FUNCTION => 'L5_PREDICATE.SELECT_FUNCTION',
  STATEMENT_TYPES => 'SELECT',
  ENABLE          => TRUE
);

EXEC DBMS_RLS.ADD_POLICY (
  OBJECT_SCHEMA   => 'KOSTYUCHENKO',
  OBJECT_NAME     => 'L5_CUSTOMS',
  POLICY_NAME     => 'L5_POLICY_UPDATE',
  FUNCTION_SCHEMA => 'KOSTYUCHENKO',
  POLICY_FUNCTION => 'L5_PREDICATE.UPDATE_FUNCTION',
  STATEMENT_TYPES => 'UPDATE',
  UPDATE_CHECK    => TRUE,
  ENABLE          => TRUE
);
