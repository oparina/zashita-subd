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
