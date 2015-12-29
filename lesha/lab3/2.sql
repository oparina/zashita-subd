-- дать право администратору просмативать записи первые 5 штук из customers

CREATE OR REPLACE VIEW view_admin
AS
  SELECT * FROM CUSTOMERS
  LIMIT 5;

CREATE ROLE role_admin;
GRANT SELECT ON TABLE view_admin TO role_admin;
CREATE USER subd_admin
  PASSWORD 'password'
  IN ROLE role_admin;

-- psql -d subd -U subd_admin
-- select * from view_admin;