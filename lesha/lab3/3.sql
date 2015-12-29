-- дать право оператору удалять право покупателей не покупали 5 лет

CREATE OR REPLACE VIEW view_operator
AS
  SELECT * FROM CUSTOMERS
  WHERE EXISTS
(
  SELECT * FROM GOODS_CUSTOMING
  WHERE GOODS_CUSTOMING.GOOD_CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
  AND GOODS_CUSTOMING.GOOD_CUSTOMING_DATE  < now() - INTERVAL '5 years'
);

CREATE OR REPLACE RULE rule_operator_delete AS ON DELETE TO view_operator
DO INSTEAD DELETE FROM CUSTOMERS where customer_id=OLD.customer_id;

CREATE ROLE role_operator;
GRANT SELECT, DELETE ON TABLE view_operator TO role_operator;

CREATE USER subd_operator
  PASSWORD 'password'
  IN ROLE role_operator;

-- оператору вносить данные о товаре не менее 500 руб
GRANT SELECT, INSERT ON TABLE GOODS TO role_operator;

CREATE OR REPLACE RULE rule_operator_insert AS ON INSERT TO GOODS
WHERE NEW.GOOD_PRICE<500
DO INSTEAD NOTHING;


-- psql -d subd -U subd_operator
--
-- SELECT * FROM view_operator;
-- DELETE FROM view_operator WHERE customer_id=9;
--
-- SELECT * FROM GOODS;
-- INSERT INTO GOODS VALUES (51, 'lessthan500', 100);
-- INSERT INTO GOODS VALUES (52, 'morethan500', 600);