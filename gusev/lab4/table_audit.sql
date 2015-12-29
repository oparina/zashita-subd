CREATE SCHEMA audit;

CREATE TABLE audit.logged_actions (
  schema_name   TEXT                     NOT NULL,
  TABLE_NAME    TEXT                     NOT NULL,
  user_name     TEXT,
  action_tstamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  action        TEXT                     NOT NULL CHECK (action IN ('I', 'D', 'U')),
  original_data TEXT,
  new_data      TEXT,
  query         TEXT
) WITH (FILLFACTOR =100
);

CREATE OR REPLACE FUNCTION audit.if_modified_func()
  RETURNS TRIGGER AS $body$
DECLARE
  v_old_data TEXT;
  v_new_data TEXT;
BEGIN
  IF (TG_OP = 'UPDATE')
  THEN
    v_old_data := ROW (OLD.*);
    v_new_data := ROW (NEW.*);
    INSERT INTO audit.logged_actions (schema_name, table_name, user_name, action, original_data, new_data, query)
    VALUES (TG_TABLE_SCHEMA :: TEXT, TG_TABLE_NAME :: TEXT, session_user :: TEXT, substring(TG_OP, 1, 1), v_old_data,
            v_new_data, current_query());
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE')
    THEN
      v_old_data := ROW (OLD.*);
      INSERT INTO audit.logged_actions (schema_name, table_name, user_name, action, original_data, query)
      VALUES (TG_TABLE_SCHEMA :: TEXT, TG_TABLE_NAME :: TEXT, session_user :: TEXT, substring(TG_OP, 1, 1), v_old_data,
              current_query());
      RETURN OLD;
  ELSIF (TG_OP = 'INSERT')
    THEN
      v_new_data := ROW (NEW.*);
      INSERT INTO audit.logged_actions (schema_name, table_name, user_name, action, new_data, query)
      VALUES (TG_TABLE_SCHEMA :: TEXT, TG_TABLE_NAME :: TEXT, session_user :: TEXT, substring(TG_OP, 1, 1), v_new_data,
              current_query());
      RETURN NEW;
  ELSE
    RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - Other action occurred: %, at %', TG_OP, now();
    RETURN NULL;
  END IF;

  EXCEPTION
  WHEN data_exception
    THEN
      RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
      RETURN NULL;
  WHEN unique_violation
    THEN
      RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
      RETURN NULL;
  WHEN OTHERS THEN
    RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
    RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit;

CREATE TRIGGER users_audit
  AFTER INSERT OR UPDATE OR DELETE ON users
  FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();
