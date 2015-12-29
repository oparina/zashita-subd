-- Дать возможность поставщику просматривать данные о своих поставках
DROP VIEW view_supplier;
CREATE OR REPLACE VIEW view_supplier
AS
  SELECT * FROM GOODS_SUPPLING
  INNER JOIN SUPPLIERS USING (SUPPLIER_ID)
  INNER JOIN GOODS USING (GOOD_ID)
  WHERE SUPPLIER_NAME = user;

CREATE ROLE role_supplier;
GRANT SELECT ON TABLE view_supplier TO role_supplier;
CREATE USER ac61f4
  PASSWORD 'password'
  IN ROLE role_supplier;

-- psql -d subd -U ac61f4
-- select * from view_supplier;