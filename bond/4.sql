audit user;
audit session;

begin
  DBMS_FGA.ADD_POLICY(
    object_schema=>'BONDARENKO',
    object_name=>'BANK_ACCOUNTS',
    policy_name=>'B_BACC_DEL_AUD',
    statement_types=>'DELETE');
    
  DBMS_FGA.ADD_POLICY(
    object_schema=>'BONDARENKO',
    object_name=>'BANK_USER_DOCS',
    policy_name=>'B_BUDOC_NAME_ACC_AUD',
    audit_column=>'USER_FIRST_NAME');
end;

-- Get nonexist users login trials
select *
from SYS.DBA_AUDIT_TRAIL
where ACTION_NAME='LOGON' and
  0=(select count(*) from sys.dba_users where USERNAME = SYS.DBA_AUDIT_TRAIL.USERNAME)
ORDER BY EXTENDED_TIMESTAMP desc
;

-- Get user alterations

select *
from SYS.DBA_AUDIT_OBJECT
where ACTION_NAME='ALTER USER'
ORDER BY EXTENDED_TIMESTAMP desc
;


-- Get account deletions

select
  *
from
  sys.DBA_FGA_AUDIT_TRAIL
where
  POLICY_NAME = 'B_BACC_DEL_AUD';
