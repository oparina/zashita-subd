sudo -u postgres pg_dump %db_name% -t %table_name% > dump.sql
sudo -u postgres psql %db_name% < dump.sql
