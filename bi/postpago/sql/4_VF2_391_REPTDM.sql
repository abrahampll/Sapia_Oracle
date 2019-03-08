WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

DROP TABLE DM.dw_spss2_f_m_lineas_celda_cdr PURGE;

DECLARE

  V_PERIODO  VARCHAR2(6);
  V_QUERY    VARCHAR2(30000);
  v_MsgError VARCHAR2(130);
  LD_FECINI  DATE;
  LD_FECFIN  DATE;
  V_PERIODO_SMES VARCHAR2(10);
  V_COUNT    NUMBER;
  i          NUMBER;
  x          NUMBER;
  y          NUMBER;

BEGIN

	SELECT TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') INTO V_PERIODO FROM DUAL;
	
    Execute Immediate 'ALTER SESSION SET NLS_DATE_FORMAT=''DD/MM/RR'''; 
      
    V_QUERY := '';     
    V_QUERY := 'create table dm.dw_spss2_f_m_lineas_celda_cdr nologging parallel 2 as select * from dm.f_m_lineas_celda_cdr partition (p_'||V_PERIODO||') a ';

    EXECUTE IMMEDIATE V_QUERY;  

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_MsgError := 'Proceso Nro. 03 no se ejecuto correctamente.';
    DBMS_OUTPUT.PUT_LINE(v_MsgError);
     DBMS_OUTPUT.PUT_LINE(v_query);
  WHEN OTHERS THEN
    v_MsgError := 'Error ' || 'ORA' || SqlCode || ' ' ||substr(SQLERRM, 1, 100);
     DBMS_OUTPUT.PUT_LINE(v_MsgError);
      DBMS_OUTPUT.PUT_LINE(v_query);
END;
/

GRANT ALL ON DM.dw_spss2_f_m_lineas_celda_cdr TO DBLINK_DWO;

EXIT;