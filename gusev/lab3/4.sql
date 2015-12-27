CREATE ROLE administrator;
CREATE USER administrator_user
  PASSWORD 'password'
  IN ROLE administrator;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE users, contracts, calls TO administrator;

CREATE OR REPLACE FUNCTION _check_time()
  RETURNS TRIGGER AS $$
    BEGIN
      IF (current_user = 'administrator_user')
      THEN
        IF NOT (current_time BETWEEN '8:00:00' AND '15:00:00')
        THEN
          RAISE EXCEPTION 'Current time is %s, you can work between 8:00 and 15:00', current_time;
        END IF;
      END IF;
      RETURN NULL;
    END;
  $$ LANGUAGE plpgsql;


CREATE TRIGGER check_time_trigger
  BEFORE INSERT OR UPDATE OR DELETE ON contracts
  EXECUTE PROCEDURE _check_time();

CREATE TRIGGER check_time_trigger
  BEFORE INSERT OR UPDATE OR DELETE ON users
  EXECUTE PROCEDURE _check_time();

CREATE TRIGGER check_time_trigger
  BEFORE INSERT OR UPDATE OR DELETE ON calls
  EXECUTE PROCEDURE _check_time();
