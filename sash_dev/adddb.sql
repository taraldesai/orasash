set linesize 200
set pagesize 999
SET HEAD OFF
SET VER OFF
set feedback off

accept DBNAME prompt "Enter database name " 

accept INST_NUM default 1 prompt "Enter number of instances [default 1]"

SET TERMOUT OFF

spool instance.sql
select 'accept HOST' || rownum || ' prompt "Enter host name for instance number ' || rownum || ' "' from all_source where rownum <= &INST_NUM;
select 'accept INST' || rownum || ' default ' || decode('&INST_NUM',1,'&DBNAME', '&DBNAME' || rownum) || ' prompt "Enter instance name for instance number ' 
       || rownum || ' [ default ' || decode('&INST_NUM',1,'&DBNAME', '&DBNAME' || rownum) ||' ] "' from all_source where rownum <= &INST_NUM;
spool off

SET TERMOUT ON

@instance.sql

accept PORT default 1521 prompt "Enter listener port number [default 1521] "
accept SASHPASS prompt "Enter SASH password on target database "
accept VER default 11.2 prompt "Enter version of target database in following format 10.2,11.1,11.2 [default 11.2] "

-- set term off
column f_st new_value v_dblink 
select '&DBNAME' || '1' || replace(substr('&HOST1',1,8),'.','_') f_st from dual;

spool setup.sql
select 'exec sash_repo.add_db(''&' || 'HOST' || rownum || ''', ' || &PORT || ', ''&SASHPASS'', ''&DBNAME'', ''&' || 'INST' || rownum || ''',' || rownum || ', ''' ||&VER ||''', 8);' from all_source where rownum <= &INST_NUM;
select 'exec sash_pkg.configure_db(''&V_DBLINK'');' from dual;
select 'exec sash_pkg.set_dbid(''&V_DBLINK'');' from dual;
select 'exec sash_repo.setup_jobs' from dual;
select 'exec sash_repo.start_collecting_jobs' from dual;
select 'exec sash_repo.purge_tables' from dual;
spool off
set term on

spool setup.log
@setup.sql

prompt "------------------------------------------------------------------------------------"
prompt  Database added. 
prompt "------------------------------------------------------------------------------------"

spool off

