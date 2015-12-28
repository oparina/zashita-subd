-- дать право покупателю на вх с 8 утра до 8 веч

CREATE ROLE role_customer;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE customers TO role_customer;
CREATE USER subd_customer
  PASSWORD 'password'
  IN ROLE role_customer;

CREATE OR REPLACE FUNCTION _check_time()
  RETURNS TRIGGER AS $$
    BEGIN
      IF (current_user = 'subd_customer')
      THEN
        IF NOT (current_time BETWEEN '900:00' AND '20:00:00')
        THEN
          RAISE EXCEPTION 'Chasy raboty s 9:00 do 20:00';
        END IF;
      END IF;
      RETURN NULL;
    END;
  $$ LANGUAGE plpgsql;


CREATE TRIGGER check_time_trigger
  BEFORE INSERT OR UPDATE OR DELETE ON customers
  EXECUTE PROCEDURE _check_time();

-- psql -d subd -U subd_customer
-- INSERT INTO CUSTOMERS VALUES (10, '9ql18a', 'dkj1a', 1.2422556042178095);