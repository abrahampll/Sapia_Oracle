WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_TASADO_GRANEL');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_TASADO_BK');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_USAGE_DIA');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_USAGE_DETAIL_DIA');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.t$_spss2_trafico_adic_fact');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_TASADO_CB_BK');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_SPSS2_USAGE_DIA_CB');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_SPSS2_USAGE_DETAIL_DIA_CB');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.t$_spss2_trafico_adic_fact_SMS');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.t$_trafico_fact_granel');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.t$_trafico_facturado_granel');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.t$_trafico_tasado_granel');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_trafico_granel');
END;
/

create table dm.DW_SPSS2_TASADO_GRANEL
(
  served_number VARCHAR2(25) not null,
  fecha         NUMBER,
  vf2_323       NUMBER,
  vf2_324       NUMBER,
  vf2_325       NUMBER,
  vf2_326       NUMBER,
  vf2_327       NUMBER,
  vf2_328       NUMBER,
  vf2_329       NUMBER,
  vf2_330       NUMBER,
  vf2_331       NUMBER,
  vf2_361       NUMBER,
  vf2_362       NUMBER,
  vf2_369       NUMBER,
  vf2_292       NUMBER,
  vf2_293       NUMBER,
  vf2_294       NUMBER,
  vf2_295       NUMBER,
  vf2_296       NUMBER,
  vf2_304       NUMBER,
  vf2_348       NUMBER,
  vf2_349       NUMBER,
  vf2_350       NUMBER,
  vf2_351       NUMBER,
  vf2_352       NUMBER,
  vf2_353       NUMBER,
  vf2_354       NUMBER,
  vf2_355       NUMBER,
  vf2_356       NUMBER,
  vf2_367       NUMBER,
  vf2_368       NUMBER,
  vf2_373       NUMBER,
  vf2_447       NUMBER,
  vf2_448       NUMBER,
  vf2_449       NUMBER,
  vf2_450       NUMBER,
  vf2_451       NUMBER,
  vf2_452       NUMBER,
  vf2_441       NUMBER,
  vf2_442       NUMBER,
  vf2_443       NUMBER,
  vf2_444       NUMBER,
  vf2_445       NUMBER,
  vf2_446       NUMBER
)nologging;

create table dm.DW_SPSS2_TASADO_BK
(
  served_number VARCHAR2(25) not null,
  fecha         CHAR(6),
  vf2_323       NUMBER,
  vf2_324       NUMBER,
  vf2_325       NUMBER,
  vf2_326       NUMBER,
  vf2_327       NUMBER,
  vf2_328       NUMBER,
  vf2_329       NUMBER,
  vf2_330       NUMBER,
  vf2_331       NUMBER,
  vf2_361       NUMBER,
  vf2_362       NUMBER,
  vf2_369       NUMBER,
  vf2_292       NUMBER,
  vf2_293       NUMBER,
  vf2_294       NUMBER,
  vf2_295       NUMBER,
  vf2_296       NUMBER,
  vf2_304       NUMBER,
  vf2_348       NUMBER,
  vf2_349       NUMBER,
  vf2_350       NUMBER,
  vf2_351       NUMBER,
  vf2_352       NUMBER,
  vf2_353       NUMBER,
  vf2_354       NUMBER,
  vf2_355       NUMBER,
  vf2_356       NUMBER,
  vf2_367       NUMBER,
  vf2_368       NUMBER,
  vf2_373       NUMBER,
  vf2_447       NUMBER,
  vf2_448       NUMBER,
  vf2_449       NUMBER,
  vf2_450       NUMBER,
  vf2_451       NUMBER,
  vf2_452       NUMBER,
  vf2_441       NUMBER,
  vf2_442       NUMBER,
  vf2_443       NUMBER,
  vf2_444       NUMBER,
  vf2_445       NUMBER,
  vf2_446       NUMBER
) nologging;


DECLARE

  V_PERIODO  VARCHAR2(6);
  V_QUERY    VARCHAR2(30000);
  v_MsgError VARCHAR2(130);
  LD_FECINI  DATE;
  LD_FECFIN  DATE;
  V_DIA_SMES VARCHAR2(10);
  V_COUNT    NUMBER;
  V_DIA      VARCHAR2(8);
  i          NUMBER;
  x          NUMBER;
  y          NUMBER;

BEGIN

    SELECT '&1' INTO V_PERIODO FROM DUAL;
  
    Execute Immediate 'ALTER SESSION SET NLS_DATE_FORMAT=''DD/MM/RR''';
    
    LD_FECINI := TO_DATE(V_PERIODO, 'YYYYMM');  
   
    SELECT LAST_DAY(LD_FECINI) + 1 INTO LD_FECFIN FROM DUAL;
  
    WHILE LD_FECINI < LD_FECFIN LOOP

      V_DIA := TO_CHAR(LD_FECINI, 'yyyymmdd');

      V_QUERY := '';
      V_QUERY := ' CREATE TABLE dm.DW_SPSS2_USAGE_DIA NOLOGGING PARALLEL 3 AS '||
   'select /* +append index (j, USAGE_JANUS_IDX2) */ '||
    'j.usage_event_id, '||
    'j.usage_event_sc, '||
    'j.served_number, '||
    'to_char(j.usage_date_start,''yyyymmdd'') fecha, '||
    'et.source_code requesttype, '||
    'j.served_network_opera, '||
    'j.other_network_opera, '||
    'CASE WHEN  ET.SOURCE_CODE IN (''1001'',''1003'') AND  J.LOCAL_USAGE_IND<>''3'' AND J.OTHER_NETWORK_OPERA<>''21'' THEN 1 ELSE 0 END AS VF2_323, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2141'' and J.OTHER_NETWORK_OPERA=''24'' THEN 1 ELSE 0 END AS VF2_324, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''3'' and J.OTHER_NETWORK_OPERA=''20'' THEN 1 ELSE 0 END AS VF2_325, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''22'' THEN 1 ELSE 0 END AS VF2_326, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'',''21'') THEN 1 ELSE 0 END AS VF2_327, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''25'' THEN 1 ELSE 0 END AS VF2_328, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE IN (''7'',''8'') and J.OTHER_NETWORK_OPERA=''37'' THEN 1 ELSE 0 END AS VF2_329, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE IN (''7'',''8'') and J.OTHER_NETWORK_OPERA=''32'' THEN 1 ELSE 0 END AS VF2_330, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE IN (''7'',''8'') and J.OTHER_NETWORK_OPERA NOT IN (''37'',''32'',''21'') THEN 1 ELSE 0 END AS VF2_331, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND  UD.SOURCE_CODE=1 AND J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_361, '||
   ' CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND  UD.SOURCE_CODE IN (''5'',''6'') AND J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_362, '||
   ' CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND  J.LOCAL_USAGE_IND=''3'' THEN 1 ELSE 0 END AS VF2_369, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2141'' and J.OTHER_NETWORK_OPERA=''24'' THEN 1 ELSE 0 END AS VF2_292, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''3'' and J.OTHER_NETWORK_OPERA=''20'' THEN 1 ELSE 0 END AS VF2_293, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''22'' THEN 1 ELSE 0 END AS VF2_294, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''25'' THEN 1 ELSE 0 END AS VF2_295, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'',''21'')  THEN 1 ELSE 0 END AS VF2_296, '||      
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''1'' and J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_304 '||        
   ' FROM DWO.USAGE SUBPARTITION(p_'||V_DIA||'_janus) j '||
    'LEFT JOIN DWO.DW_C_USAGE_EVENT_TYPE ET ON ET.USG_EVENT_TYPE_ID=J.USAGE_TYPE_ID '||
    'LEFT JOIN DWO.DW_C_USAGE_DOMAIN UD ON J.USAGE_DOMAIN_ID=UD.USAGE_DOMAIN_ID '||
    'WHERE ET.SOURCE_CODE IN (''1001'',''1003'',''1004'')';  
    
      EXECUTE IMMEDIATE V_QUERY;
  
      V_QUERY := '';
      V_QUERY := 'CREATE TABLE dm.DW_SPSS2_USAGE_DETAIL_DIA NOLOGGING PARALLEL 3 AS '|| 
    'select /*+ CHOOSE, INDEX (b, USAGE_DETAIL_JANUS_IDX4)*/ '||
    'b.usage_event_id, '||
    'b.served_number, '||
    'to_char(b.usage_date_start,''yyyymmdd'') AS FECHA, '||
    'b.usage_units, '||
   ' b.chapp_unit_measure_id, '||
    'b.chapp_amt, '||
   ' b.chapp_dis_amt, '||
    'b.chapp_inv_amt, '||
    'b.chapp_tax_amt '||
    'FROM DWO.USAGE_DETAIL SUBPARTITION(p_'||V_DIA||'_janus) B '||
    'LEFT JOIN DWO.DW_C_USAGE_EVENT_TYPE ET ON ET.USG_EVENT_TYPE_ID=B.USAGE_TYPE_ID '||
    'LEFT JOIN (select t.created_id,t.iden_value from dwo.iden_base_usage t '||
    'join dwo.iden_type i on (i.iden_type_id = t.iden_type and i.iden_type_code = ''JANUS.C_JANUS_TARIFF_MASTER.TARIFF_ID_N.IDEN'')) t on t.created_id=b.tariff_id '||
    'LEFT JOIN DWO.DW_C_USAGE_WALLET UW ON UW.TYPE_ID=B.APPLIED_WALLET_ID '||
    'WHERE ET.SOURCE_CODE IN (''1001'',''1003'',''1004'') AND '||  
    ' uw.source_code=''7'' and b.usage_units<>0';

    
      EXECUTE IMMEDIATE V_QUERY;

        V_QUERY:='';
     v_query:=' INSERT /*+ APPEND NOLOGGING*/ INTO dm.DW_SPSS2_TASADO_GRANEL '||
    'select '||
    'j.served_number, '||V_DIA||' AS FECHA, '||
    'SUM(J.VF2_323) AS VF2_323,  '||
    'SUM(j.VF2_324) AS VF2_324,  '||
    'SUM(j.VF2_325) AS VF2_325, '||
    'SUM(j.VF2_326) AS VF2_326,  '||
    'SUM(j.VF2_327) AS VF2_327,  '||
    'SUM(j.VF2_328) AS VF2_328, '||
    'SUM(j.VF2_329) AS VF2_329, '||
    'SUM(j.VF2_330) AS VF2_330,  '||
    'SUM(j.VF2_331) AS VF2_331, '||
    'SUM(j.VF2_361) AS VF2_361, '||
    'SUM(j.VF2_362) AS VF2_362, '||
    'SUM(j.VF2_369) AS VF2_369,    '||
    'SUM(j.VF2_292) AS VF2_292, '||
    'SUM(j.VF2_293) AS VF2_293, '||
    'SUM(j.VF2_294) AS VF2_294,  '||
    'SUM(j.VF2_295) AS VF2_295,  '||
    'SUM(j.VF2_296) AS VF2_296, '||
    'SUM(j.VF2_304) AS VF2_304,    '|| 
    'sum(case when j.VF2_323>0 then b.usage_units else 0 end) as VF2_348,  '||
    'sum(case when j.VF2_324>0 then b.usage_units else 0 end) as VF2_349,  '||
    'sum(case when j.VF2_325>0 then b.usage_units else 0 end) as VF2_350,  '||
    'sum(case when j.VF2_326>0 then b.usage_units else 0 end) as VF2_351, '||
    'sum(case when j.VF2_327>0 then b.usage_units else 0 end) as VF2_352, '||
    'sum(case when j.VF2_328>0 then b.usage_units else 0 end) as VF2_353, '||
    'sum(case when j.VF2_329>0 then b.usage_units else 0 end) as VF2_354,  '||
    'sum(case when j.VF2_330>0 then b.usage_units else 0 end) as VF2_355, '||
    'sum(case when j.VF2_331>0 then b.usage_units else 0 end) as VF2_356, '||
    'sum(case when j.VF2_361>0 then b.usage_units else 0 end) as VF2_367, '||
    'sum(case when j.VF2_362>0 then b.usage_units else 0 end) as VF2_368,     '||     
    'sum(case when j.VF2_369>0 then b.usage_units else 0 end) as VF2_373, '||
    'sum(case when j.VF2_325>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_447, '||
    'sum(case when j.VF2_326>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_448, '||
    'sum(case when j.VF2_328>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_449, '||
    'sum(case when j.VF2_330>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_450, '||
    'sum(case when j.VF2_361>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_451, '||
    'sum(case when j.VF2_362>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_452, '||
    'sum(case when j.VF2_292>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_441,  '||
    'sum(case when j.VF2_293>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_442, '||
    'sum(case when j.VF2_294>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_443, '||
    'sum(case when j.VF2_295>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_444, '||
    'sum(case when j.VF2_304>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_445,  '|| 
    'sum(case when j.VF2_324>0 then  b.chapp_inv_amt + b.chapp_tax_amt  else 0 end) as VF2_446  '||           
    'from  dm.DW_SPSS2_USAGE_DIA  j '||
    'join dm.DW_SPSS2_USAGE_DETAIL_DIA b on j.usage_event_id=b.usage_event_id  '||
    'and j.served_number=b.served_number '||
    'group by  j.served_number';
    
                EXECUTE IMMEDIATE V_QUERY;
                COMMIT;
       --   DBMS_OUTPUT.PUT_LINE(V_QUERY);
          
  
        
            V_QUERY:='';
     v_query:='truncate table dm.DW_SPSS2_USAGE_DIA drop all storage';
                EXECUTE IMMEDIATE V_QUERY;

  V_QUERY:='';
     v_query:='drop table dm.DW_SPSS2_USAGE_DIA purge';
                EXECUTE IMMEDIATE V_QUERY;                
   
        V_QUERY:='';
     v_query:='truncate table dm.DW_SPSS2_USAGE_DETAIL_DIA drop all storage';
                EXECUTE IMMEDIATE V_QUERY;

  V_QUERY:='';
     v_query:='drop table dm.DW_SPSS2_USAGE_DETAIL_DIA purge';
                EXECUTE IMMEDIATE V_QUERY; 
      
      LD_FECINI := LD_FECINI + 1;
    END LOOP;
        


      V_QUERY:='';
     v_query:=' INSERT /*+ APPEND nologging */ INTO  dm.DW_SPSS2_TASADO_bk  ' ||
    'select /*+ CHOOSE, INDEX (j, idx2_usage_janust1_'||v_DIA||')*/ '||
    'j.served_number,' ||V_PERIODO||' AS FECHA, '||
    'SUM(J.VF2_323) AS VF2_323, SUM(j.VF2_324) AS VF2_324, SUM(j.VF2_325) AS VF2_325,SUM(j.VF2_326) AS VF2_326, '||
    'SUM(j.VF2_327) AS VF2_327, SUM(j.VF2_328) AS VF2_328, SUM(j.VF2_329) AS VF2_329, SUM(j.VF2_330) AS VF2_330, SUM(j.VF2_331) AS VF2_331, '||
    'SUM(j.VF2_361) AS VF2_361,SUM(j.VF2_362) AS VF2_362,SUM(j.VF2_369) AS VF2_369, SUM(j.VF2_292) AS VF2_292,SUM(j.VF2_293) AS VF2_293, '||
    'SUM(j.VF2_294) AS VF2_294, SUM(j.VF2_295) AS VF2_295,  SUM(j.VF2_296) AS VF2_296, SUM(j.VF2_304) AS VF2_304,'||    
    'ROUND(sum(VF2_348)/60,2) as VF2_348, ROUND(sum(VF2_349)/60,2) as VF2_349,ROUND(sum(VF2_350)/60,2) as VF2_350, '||
     'ROUND(sum(VF2_351)/60,2) as VF2_351,ROUND(sum(VF2_352)/60,2) as VF2_352,ROUND(sum(VF2_353)/60,2) as VF2_353, '||
     'ROUND(sum(VF2_354)/60,2) as VF2_354,ROUND(sum(VF2_355)/60,2) as VF2_355, '||
     'ROUND(sum(VF2_356)/60,2) as VF2_356, ROUND(sum(VF2_367)/60,2) as VF2_367, '||
     'ROUND(sum(VF2_368)/60,2) as VF2_368,ROUND(sum(VF2_373)/60,2) as VF2_373,ROUND(sum(VF2_447)/10000,2) as VF2_447, '||
    'ROUND(sum(VF2_448)/10000,2)  as VF2_448,ROUND(sum(VF2_449)/10000,2)  as VF2_449, '||
    'ROUND(sum(VF2_450)/10000,2)  as VF2_450, ROUND(sum(VF2_451)/10000,2)  as VF2_451, '||
    'ROUND(sum(VF2_452)/10000,2) as VF2_452, ROUND(sum(VF2_441)/10000,2)  as VF2_441, '||
    'ROUND(sum(VF2_442)/10000,2) as  VF2_442,ROUND(sum(VF2_443)/10000,2) as  VF2_443, '||
    ' ROUND(sum(VF2_444)/10000,2) as VF2_444, ROUND(sum(VF2_445)/10000,2) as  VF2_445, '||  
    'ROUND(sum(VF2_446)/10000,2) as  VF2_446 '||            
   ' from dm.DW_SPSS2_TASADO_GRANEL j group by  j.served_number' ;
                EXECUTE IMMEDIATE V_QUERY;
                COMMIT;

      V_QUERY:='';
      V_QUERY:='TRUNCATE TABLE dm.DW_SPSS2_TASADO_GRANEL DROP ALL STORAGE';
      EXECUTE IMMEDIATE V_QUERY;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_MsgError := 'Proceso Nro. 03 no se ejecuto correctamente.';
    DBMS_OUTPUT.PUT_LINE(v_MsgError);
  WHEN OTHERS THEN
    v_MsgError := 'Error ' || 'ORA' || SqlCode || ' ' || substr(SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE(v_MsgError);
END;
/

create table dm.t$_spss2_trafico_adic_fact nologging as
select TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') AS PERIODO, t1.msisdn, 
sum(case when substr(t1.tariffzone,1,3) = 'MOV' then 1  end) as VF2_323,
round(sum(case when substr(t1.tariffzone,1,3) = 'MOV'  and callduration not like '%:%' then t1.callduration else '0' end)/60,2) as VF2_348,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'VIE' then 1  end) VF2_324, 
round(sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'VIE' and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_349,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'NEX' then 1  end) VF2_325, 
round(sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'NEX' and callduration not like '%:%' then t1.callduration else '0'  end)/60,2) VF2_350,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'NEX' then t1.CALLTOTAL  end) VF2_447,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'TM' then 1  end) VF2_326, 
round(sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'TM' and callduration not like '%:%' then t1.callduration else '0'  end)/60,2) VF2_351,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'TM' then t1.CALLTOTAL  end) VF2_448,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'VIR' then 1  end) VF2_328, 
round(sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'VIR' and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_353,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'VIR' then t1.CALLTOTAL  end) VF2_449,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION NOT IN ('VIE','NEX','TM','VIR') then 1  end) VF2_327, 
round(sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION NOT IN ('VIE','NEX','TM','VIR') and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_352,
sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'NEX' then 1  end) VF2_329,
sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'TDP' then 1  end) VF2_330,
sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION NOT IN ('TDP','NEX') then 1  end) VF2_331,
round(sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'NEX' and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_354,  
round(sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'TDP' and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_355,
round(sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION NOT IN ('TDP','NEX') and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_356, 
sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'TDP' then t1.CALLTOTAL  end) VF2_450,
sum(case when TIPOLLAMADA = 12  then 1  end) VF2_361,  --(substr(t1.tariffzone,1,3) = 'NET' OR substr(t1.tariffzone,1,3) = 'TDA')
sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'CLA' then 1  end) VF2_362,
round(sum(case when TIPOLLAMADA = 12 and callduration not like '%:%'  then t1.callduration else '0' end)/60,2) VF2_367,  --(substr(t1.tariffzone,1,3) = 'NET' OR substr(t1.tariffzone,1,3) = 'TDA')
round(sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'CLA' and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_368,
sum(case when substr(t1.tariffzone,1,3) = 'LDI' then 1  end) VF2_369,
round(sum(case when substr(t1.tariffzone,1,3) = 'LDI' and callduration not like '%:%' then t1.callduration else '0' end)/60,2) VF2_373,
sum(case when TIPOLLAMADA = 12  then t1.CALLTOTAL  end) VF2_451,  --(substr(t1.tariffzone,1,3) = 'NET' OR substr(t1.tariffzone,1,3) = 'TDA')
sum(case when substr(t1.tariffzone,1,3) = 'FIJ' and t1.CALLDESTINATION = 'CLA' then t1.CALLTOTAL  end) VF2_452,
sum(case when substr(t1.tariffzone,1,3) = 'MOV' and t1.CALLDESTINATION = 'VIE' then t1.CALLTOTAL  end) VF2_446 
from DM.SA_TEMP_TAG_1460_SPSS2 t1
where t1.calltotal > 0
group by msisdn;

create table dm.DW_SPSS2_TASADO_GRANEL_CB
(
  served_number VARCHAR2(25) not null,
  fecha         CHAR(8),
  vf2_323       NUMBER,
  vf2_324       NUMBER,
  vf2_325       NUMBER,
  vf2_326       NUMBER,
  vf2_327       NUMBER,
  vf2_328       NUMBER,
  vf2_329       NUMBER,
  vf2_330       NUMBER,
  vf2_331       NUMBER,
  vf2_361       NUMBER,
  vf2_362       NUMBER,
  vf2_369       NUMBER,
  vf2_292       NUMBER,
  vf2_293       NUMBER,
  vf2_294       NUMBER,
  vf2_295       NUMBER,
  vf2_296       NUMBER,
  vf2_304       NUMBER,
  vf2_348       NUMBER,
  vf2_349       NUMBER,
  vf2_350       NUMBER,
  vf2_351       NUMBER,
  vf2_352       NUMBER,
  vf2_353       NUMBER,
  vf2_354       NUMBER,
  vf2_355       NUMBER,
  vf2_356       NUMBER,
  vf2_367       NUMBER,
  vf2_368       NUMBER,
  vf2_373       NUMBER,
  vf2_447       NUMBER,
  vf2_448       NUMBER,
  vf2_449       NUMBER,
  vf2_450       NUMBER,
  vf2_451       NUMBER,
  vf2_452       NUMBER,
  vf2_441       NUMBER,
  vf2_442       NUMBER,
  vf2_443       NUMBER,
  vf2_444       NUMBER,
  vf2_445       NUMBER,
  vf2_446       NUMBER
) nologging;

create table dm.DW_SPSS2_TASADO_CB_BK
(
  served_number VARCHAR2(25) not null,
  fecha         CHAR(6),
  vf2_323       NUMBER,
  vf2_324       NUMBER,
  vf2_325       NUMBER,
  vf2_326       NUMBER,
  vf2_327       NUMBER,
  vf2_328       NUMBER,
  vf2_329       NUMBER,
  vf2_330       NUMBER,
  vf2_331       NUMBER,
  vf2_361       NUMBER,
  vf2_362       NUMBER,
  vf2_369       NUMBER,
  vf2_292       NUMBER,
  vf2_293       NUMBER,
  vf2_294       NUMBER,
  vf2_295       NUMBER,
  vf2_296       NUMBER,
  vf2_304       NUMBER,
  vf2_348       NUMBER,
  vf2_349       NUMBER,
  vf2_350       NUMBER,
  vf2_351       NUMBER,
  vf2_352       NUMBER,
  vf2_353       NUMBER,
  vf2_354       NUMBER,
  vf2_355       NUMBER,
  vf2_356       NUMBER,
  vf2_367       NUMBER,
  vf2_368       NUMBER,
  vf2_373       NUMBER,
  vf2_447       NUMBER,
  vf2_448       NUMBER,
  vf2_449       NUMBER,
  vf2_450       NUMBER,
  vf2_451       NUMBER,
  vf2_452       NUMBER,
  vf2_441       NUMBER,
  vf2_442       NUMBER,
  vf2_443       NUMBER,
  vf2_444       NUMBER,
  vf2_445       NUMBER,
  vf2_446       NUMBER
) nologging;

DECLARE

  V_PERIODO  VARCHAR2(6);
  V_QUERY    VARCHAR2(30000);
  v_MsgError VARCHAR2(130);
  LD_FECINI  DATE;
  LD_FECFIN  DATE;
  V_DIA_SMES VARCHAR2(10);
  V_COUNT    NUMBER;
  V_DIA      VARCHAR2(8);
  i          NUMBER;
  x          NUMBER;
  y          NUMBER;

BEGIN
	SELECT '&1' INTO V_PERIODO FROM DUAL;
  
    Execute Immediate 'ALTER SESSION SET NLS_DATE_FORMAT=''DD/MM/RR''';
    LD_FECINI := TO_DATE(V_PERIODO, 'YYYYMM');  
    SELECT LAST_DAY(LD_FECINI) + 1 INTO LD_FECFIN FROM DUAL;
    WHILE LD_FECINI < LD_FECFIN LOOP
      V_DIA := TO_CHAR(LD_FECINI, 'yyyymmdd');
      V_QUERY := '';
      V_QUERY := 'CREATE TABLE dm.dw_SPSS2_USAGE_DIA_CB NOLOGGING PARALLEL 3 AS '||
  'select /* +append index (j, USAGE_JANUS_IDX2) */ '||
  '  j.usage_event_id, '||
   ' j.usage_event_sc, '||
   ' j.served_number, '||
   ' to_char(j.usage_date_start,''yyyymmdd'') fecha, '||
   ' et.source_code requesttype, '||
   ' j.served_network_opera, '||
   ' j.other_network_opera, '||
   ' CASE WHEN  J.source_system_id=282 AND  J.LOCAL_USAGE_IND<>''3'' AND J.OTHER_NETWORK_OPERA<>''21'' THEN 1 ELSE 0 END AS VF2_323, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''24'' THEN 1 ELSE 0 END AS VF2_324, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''20'' THEN 1 ELSE 0 END AS VF2_325, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''22'' THEN 1 ELSE 0 END AS VF2_326, ' ||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'',''21'') THEN 1 ELSE 0 END AS VF2_327, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''25'' THEN 1 ELSE 0 END AS VF2_328, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE IN (''207'',''209'') and J.OTHER_NETWORK_OPERA in (''20'',''37'') THEN 1 ELSE 0 END AS VF2_329, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE IN (''207'',''209'') and J.OTHER_NETWORK_OPERA=''32'' THEN 1 ELSE 0 END AS VF2_330, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE IN (''207'',''209'') and J.OTHER_NETWORK_OPERA NOT IN (''37'',''32'',''21'') THEN 1 ELSE 0 END AS VF2_331, '||
   ' CASE WHEN  J.source_system_id=282 AND  J.LOCAL_USAGE_IND<>''3'' AND J.OTHER_NETWORK_OPERA<>''21'' THEN j.usage_qty ELSE 0 END AS VF2_348, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''24'' THEN j.usage_qty ELSE 0 END AS VF2_349, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''20'' THEN j.usage_qty ELSE 0 END AS VF2_350, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''22'' THEN j.usage_qty ELSE 0 END AS VF2_351, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'',''21'') THEN j.usage_qty ELSE 0 END AS VF2_352, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE =''211'' and J.OTHER_NETWORK_OPERA=''25'' THEN j.usage_qty ELSE 0 END AS VF2_353, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE IN (''207'',''209'') and J.OTHER_NETWORK_OPERA in (''20'',''37'') THEN j.usage_qty ELSE 0 END AS VF2_354, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE IN (''207'',''209'') and J.OTHER_NETWORK_OPERA=''32'' THEN j.usage_qty ELSE 0 END AS VF2_355, '||
   ' CASE WHEN J.source_system_id=282 AND   UD.SOURCE_CODE IN (''207'',''209'') and J.OTHER_NETWORK_OPERA NOT IN (''37'',''32'',''21'') THEN j.usage_qty ELSE 0 END AS VF2_356, '||
   ' CASE WHEN J.source_system_id=282 AND  UD.SOURCE_CODE in (''221'',''210'') AND J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_361, '||
   ' CASE WHEN J.source_system_id=282 AND  UD.SOURCE_CODE IN (''206'',''208'') AND J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_362, '||    
   ' CASE WHEN J.source_system_id=282 AND  UD.SOURCE_CODE in (''221'',''210'') AND J.OTHER_NETWORK_OPERA=''21'' THEN j.usage_qty ELSE 0 END AS VF2_367, '||
   ' CASE WHEN J.source_system_id=282 AND  UD.SOURCE_CODE IN (''206'',''208'') AND J.OTHER_NETWORK_OPERA=''21'' THEN j.usage_qty ELSE 0 END AS VF2_368,  '||
   ' CASE WHEN J.source_system_id=282 AND  J.LOCAL_USAGE_IND=''3'' THEN 1 ELSE 0 END AS VF2_369, '||
   '  CASE WHEN J.source_system_id=282 AND  J.LOCAL_USAGE_IND=''3'' THEN j.usage_qty ELSE 0 END AS VF2_373, '||
   'CASE WHEN J.source_system_id=283 AND   UD.SOURCE_CODE =''217'' and J.OTHER_NETWORK_OPERA=''24'' THEN 1 ELSE 0 END AS VF2_292, '||
   'CASE WHEN J.source_system_id=283 AND   UD.SOURCE_CODE =''217'' and J.OTHER_NETWORK_OPERA=''20'' THEN 1 ELSE 0 END AS VF2_293, '||
   'CASE WHEN J.source_system_id=283 AND   UD.SOURCE_CODE =''217'' and J.OTHER_NETWORK_OPERA=''22'' THEN 1 ELSE 0 END AS VF2_294, '||
   'CASE WHEN J.source_system_id=283 AND   UD.SOURCE_CODE =''217'' and J.OTHER_NETWORK_OPERA=''25'' THEN 1 ELSE 0 END AS VF2_295, '||
   'CASE WHEN J.source_system_id=283 AND   UD.SOURCE_CODE =''217'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'',''21'')  THEN 1 ELSE 0 END AS VF2_296, '||      
   'CASE WHEN J.source_system_id=283 AND   UD.SOURCE_CODE =''217'' and J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_304 '||       
   ' FROM DWO.USAGE PARTITION (p_'||V_DIA||') j '||
   ' LEFT JOIN DWO.DW_C_USAGE_EVENT_TYPE ET ON ET.USG_EVENT_TYPE_ID=J.USAGE_TYPE_ID '||
   ' LEFT JOIN DWO.DW_C_USAGE_DOMAIN UD ON J.USAGE_DOMAIN_ID=UD.USAGE_DOMAIN_ID '||
   ' WHERE J.source_system_id in (282,283) AND nvl(j.error_type_id,0)=0 and nvl(j.USAGE_QTY,0)>0';  
    
      EXECUTE IMMEDIATE V_QUERY;

      V_QUERY := '';
      V_QUERY := 'create table dm.dw_SPSS2_USAGE_DETAIL_DIA_CB nologging parallel 2 as '||
  'select /*+ PARALLEL (2)*/ '||
  '  b.usage_event_id, '||
   ' sum(b.chapp_inv_amt) chapp_inv_amt, '||
   ' sum(b.usage_units) usage_units, '||
   ' sum(b.chapp_tax_amt) chapp_tax_amt, '||
   ' sum(b.chapp_amt) chapp_amt, '||
   ' b.exponent '||
   ' from dwo.usage_detail partition(p_'||V_DIA||') b '||
   ' LEFT JOIN DWO.DW_C_USAGE_WALLET UW ON UW.TYPE_ID=B.APPLIED_WALLET_ID '||
   ' WHERE source_system_id in (282,283) AND UW.SOURCE_CODE in (''7000'',''7001'',''7002'',''7003'') '||
   ' GROUP BY b.usage_event_id,b.exponent';

   EXECUTE IMMEDIATE V_QUERY;

        V_QUERY:='';
     v_query:=' INSERT /*+ APPEND NOLOGGING*/ INTO dm.dw_SPSS2_TASADO_GRANEL_CB '||
    'select  '||
    'j.served_number, '||
    'j.fecha, '||
    'SUM(J.VF2_323) AS VF2_323, '||
    'SUM(j.VF2_324) AS VF2_324,  '||
    'SUM(j.VF2_325) AS VF2_325, '||
    'SUM(j.VF2_326) AS VF2_326, '||
    'SUM(j.VF2_327) AS VF2_327, '||
    'SUM(j.VF2_328) AS VF2_328, '||
    'SUM(j.VF2_329) AS VF2_329, '||
    'SUM(j.VF2_330) AS VF2_330, '||
    'SUM(j.VF2_331) AS VF2_331, '||
    'SUM(j.VF2_361) AS VF2_361, '||
    'SUM(j.VF2_362) AS VF2_362, '||
    'SUM(j.VF2_369) AS VF2_369,  '||
    'SUM(j.VF2_292) AS VF2_292, '||
    'SUM(j.VF2_293) AS VF2_293, '||
    'SUM(j.VF2_294) AS VF2_294, '||
    'SUM(j.VF2_295) AS VF2_295, '||
    'SUM(j.VF2_296) AS VF2_296, '||
    'SUM(j.VF2_304) AS VF2_304, '||    
    'sum(j.VF2_348) as VF2_348, '||
    'sum(J.VF2_349) as VF2_349, '||
    'sum(J.VF2_350) as VF2_350, '||
    'sum(J.VF2_351) as VF2_351, '||
    'sum(J.VF2_352) as VF2_352, '||
    'sum(J.VF2_353) as VF2_353, '||
    'sum(J.VF2_354) as VF2_354, '||
    'sum(J.VF2_355) as VF2_355, '||
    'sum(J.VF2_356) as VF2_356, '||
    'sum(J.VF2_367) as VF2_367, '||
    'sum(J.VF2_368) as VF2_368, '||         
    'sum(J.VF2_373) as VF2_373, '||
    'sum(case when j.VF2_324>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_446,  '||
    'sum(case when j.VF2_326>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent) else 0 end) as VF2_448, '||
    'sum(case when j.VF2_328>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_449, '||
    'sum(case when j.VF2_330>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_450, '||
    'sum(case when j.VF2_361>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_451, '||
    'sum(case when j.VF2_362>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_452, '||
    'sum(case when j.VF2_292>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_441, '||
    'sum(case when j.VF2_293>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_442, '||
    'sum(case when j.VF2_294>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_443, '||
    'sum(case when j.VF2_295>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_444, '||
    'sum(case when j.VF2_304>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_445, '||             
    'sum(case when j.VF2_325>0 then  (nvl(b.chapp_inv_amt,0) + nvl(b.chapp_tax_amt,0))*POWER(10,b.exponent)  else 0 end) as VF2_447 '||
    'from   dm.dw_SPSS2_USAGE_DIA_CB  j  '||
    'join dm.dw_SPSS2_USAGE_DETAIL_DIA_CB b on j.usage_event_id=b.usage_event_id '||
    'group by  j.served_number,J.fecha';
    
                EXECUTE IMMEDIATE V_QUERY;
                COMMIT;

            V_QUERY:='';
     v_query:='truncate table dm.dw_SPSS2_USAGE_DIA_CB drop all storage';
                EXECUTE IMMEDIATE V_QUERY;

  V_QUERY:='';
     v_query:='drop table dm.dw_SPSS2_USAGE_DIA_CB purge';
                EXECUTE IMMEDIATE V_QUERY;                
   
        V_QUERY:='';
     v_query:='truncate table dm.dw_SPSS2_USAGE_DETAIL_DIA_CB drop all storage';
                EXECUTE IMMEDIATE V_QUERY;

  V_QUERY:='';
     v_query:='drop table dm.dw_SPSS2_USAGE_DETAIL_DIA_CB purge';
                EXECUTE IMMEDIATE V_QUERY; 
      
      LD_FECINI := LD_FECINI + 1;
    END LOOP;

      V_QUERY:='';
     v_query:=' INSERT /*+ APPEND nologging */ INTO  dm.dw_SPSS2_TASADO_CB_bk  ' ||
    'select '||
    'j.served_number, '||V_PERIODO||' FECHA, '||
    'SUM(J.VF2_323) AS VF2_323, '||
    'SUM(j.VF2_324) AS VF2_324, '||
    'SUM(j.VF2_325) AS VF2_325, '||
    'SUM(j.VF2_326) AS VF2_326, '||
    'SUM(j.VF2_327) AS VF2_327, '||
    'SUM(j.VF2_328) AS VF2_328, '||
    'SUM(j.VF2_329) AS VF2_329, '||
    'SUM(j.VF2_330) AS VF2_330, '||
    'SUM(j.VF2_331) AS VF2_331, '||
    'SUM(j.VF2_361) AS VF2_361, '||
    'SUM(j.VF2_362) AS VF2_362, '||
    'SUM(j.VF2_369) AS VF2_369,    '||
    'SUM(j.VF2_292) AS VF2_292, '||
    'SUM(j.VF2_293) AS VF2_293, '||
    'SUM(j.VF2_294) AS VF2_294, '||
    'SUM(j.VF2_295) AS VF2_295, '||
    'SUM(j.VF2_296) AS VF2_296, '||
    'SUM(j.VF2_304) AS VF2_304, '||    
    'ROUND(sum(VF2_348)/60,2) as VF2_348, '||
     'ROUND(sum(VF2_349)/60,2) as VF2_349, '||
     'ROUND(sum(VF2_350)/60,2) as VF2_350, '||
     'ROUND(sum(VF2_351)/60,2) as VF2_351, '||
     'ROUND(sum(VF2_352)/60,2) as VF2_352, '||
     'ROUND(sum(VF2_353)/60,2) as VF2_353, '||
     'ROUND(sum(VF2_354)/60,2) as VF2_354, '||
     'ROUND(sum(VF2_355)/60,2) as VF2_355, '||
     'ROUND(sum(VF2_356)/60,2) as VF2_356, '||
     'ROUND(sum(VF2_367)/60,2) as VF2_367, '||
     'ROUND(sum(VF2_368)/60,2) as VF2_368, '||         
     'ROUND(sum(VF2_373)/60,2) as VF2_373, '||
     'ROUND(sum(VF2_447),2) as VF2_447, '||
    'ROUND(sum(VF2_448),2)  as VF2_448, '||
    'ROUND(sum(VF2_449),2)  as VF2_449, '||
    'ROUND(sum(VF2_450),2)  as VF2_450, '||
    'ROUND(sum(VF2_451),2)  as VF2_451, '||
    'ROUND(sum(VF2_452),2) as VF2_452, '||
   'ROUND(sum(VF2_441),2)  as VF2_441, '||
    'ROUND(sum(VF2_442),2) as  VF2_442, '||
    'ROUND(sum(VF2_443),2) as  VF2_443, '||
     'ROUND(sum(VF2_444),2) as VF2_444, '||
    'ROUND(sum(VF2_445),2) as  VF2_445, '||   
    'ROUND(sum(VF2_446),2) as  VF2_446 '||            
    'from dm.dw_SPSS2_TASADO_GRANEL_CB J  '||
    'group by  j.served_number' ;
                EXECUTE IMMEDIATE V_QUERY;
                COMMIT;
				
      V_QUERY:='';
      V_QUERY:='TRUNCATE TABLE dm.dw_SPSS2_TASADO_GRANEL_CB DROP ALL STORAGE';
      EXECUTE IMMEDIATE V_QUERY;
    
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_MsgError := 'Proceso Nro. 03 no se ejecuto correctamente.';
    DBMS_OUTPUT.PUT_LINE(v_MsgError);
  WHEN OTHERS THEN
    v_MsgError := 'Error ' || 'ORA' || SqlCode || ' ' || substr(SQLERRM, 1, 100);
    DBMS_OUTPUT.PUT_LINE(v_MsgError);
END;
/

create table dm.t$_spss2_trafico_adic_fact_SMS nologging parallel 2 as 
select TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') AS PERIODO, t1.msisdn, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'VIE' then t1.smsduration end) VF2_292, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'VIE' then t1.smstotal  end) VF2_441, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'NEX' then t1.smsduration end) VF2_293, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'NEX' then t1.smstotal  end) VF2_442, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'TM' then t1.smsduration end) VF2_294, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'TM' then t1.smstotal  end) VF2_443, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'VIR' then t1.smsduration end) VF2_295, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'VIR' then t1.smstotal  end) VF2_444,
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION NOT IN ('VIE','NEX','TM','VIR','CLA') then t1.smsduration end) VF2_296, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'CLA' then t1.smsduration end) VF2_304, 
sum(case when T1.TARIFFZONE NOT LIKE 'IDE%' and T1.tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and t1.SMSDESTINATION = 'CLA' then t1.smsTOTAL end) VF2_445 
from DWS.SA_TEMP_TAG_1480 t1 where t1.period= '&1' and t1.smstotal > 0 group by msisdn;


--------------------------------------------------------------------------------------------------------------------

create table dm.t$_trafico_fact_granel 
(
periodo char(6),
msisdn  varchar2(25),
vf2_323 number,
vf2_348 number,
vf2_324 number,
vf2_349 number,
vf2_325 number,
vf2_350 number,
vf2_447 number,
vf2_326 number,
vf2_351 number,
vf2_448 number,
vf2_328 number,
vf2_353 number,
vf2_449 number,
vf2_327 number,
vf2_352 number,
vf2_329 number,
vf2_330 number,
vf2_331 number,
vf2_354 number,
vf2_355 number,
vf2_356 number,
vf2_450 number,
vf2_361 number,
vf2_362 number,
vf2_367 number,
vf2_368 number,
vf2_369 number,
vf2_373 number,
vf2_451 number,
vf2_452 number,
vf2_446 number,
vf2_292 number,
vf2_441 number,
vf2_293 number,
vf2_442 number,
vf2_294 number,
vf2_443 number,
vf2_295 number,
vf2_444 number,
vf2_296 number,
vf2_304 number,
vf2_445 number
) nologging;

insert /*+ append*/ into  dm.t$_trafico_fact_granel (periodo, 
msisdn, 
vf2_323, 
vf2_348, 
vf2_324, 
vf2_349, 
vf2_325, 
vf2_350, 
vf2_447, 
vf2_326, 
vf2_351, 
vf2_448, 
vf2_328, 
vf2_353, 
vf2_449, 
vf2_327, 
vf2_352, 
vf2_329, 
vf2_330, 
vf2_331, 
vf2_354, 
vf2_355, 
vf2_356, 
vf2_450, 
vf2_361, 
vf2_362, 
vf2_367, 
vf2_368, 
vf2_369, 
vf2_373, 
vf2_451, 
vf2_452, 
vf2_446
) 
select periodo, 
msisdn, 
vf2_323, 
vf2_348, 
vf2_324, 
vf2_349, 
vf2_325, 
vf2_350, 
vf2_447, 
vf2_326, 
vf2_351, 
vf2_448, 
vf2_328, 
vf2_353, 
vf2_449, 
vf2_327, 
vf2_352, 
vf2_329, 
vf2_330, 
vf2_331, 
vf2_354, 
vf2_355, 
vf2_356, 
vf2_450, 
vf2_361, 
vf2_362, 
vf2_367, 
vf2_368, 
vf2_369, 
vf2_373, 
vf2_451, 
vf2_452, 
vf2_446
 from dm.t$_spss2_trafico_adic_fact;
 commit;
 
 
 MERGE /*+ APPEND */ INTO dm.t$_trafico_fact_granel TMP
    USING (SELECT periodo, msisdn, vf2_292, vf2_441,vf2_293,vf2_442, 
          vf2_294, vf2_443, vf2_295, vf2_444, vf2_296, vf2_304, vf2_445
          FROM dm.t$_spss2_trafico_adic_fact_SMS
          ) mp
    ON  (tmp.MSISDN = mp.MSISDN and tmp.periodo=mp.periodo)
    WHEN MATCHED THEN
    UPDATE SET tmp.vf2_292 = mp.vf2_292,  tmp.vf2_441 = mp.vf2_441,  tmp.vf2_293 = mp.vf2_293 ,tmp.vf2_442 = mp.vf2_442,
    tmp.vf2_294 = mp.vf2_294, tmp.vf2_443 = mp.vf2_443, tmp.vf2_295 = mp.vf2_295,tmp.vf2_444 = mp.vf2_444, tmp.vf2_296 = mp.vf2_296,
     tmp.vf2_304 = mp.vf2_304, tmp.vf2_445 = mp.vf2_445
    WHEN NOT MATCHED THEN 
    INSERT (tmp.periodo, msisdn, vf2_292, vf2_441,vf2_293,vf2_442, 
          vf2_294, vf2_443, vf2_295, vf2_444, vf2_296, vf2_304, vf2_445)
    VALUES (mp.periodo, mp.msisdn, mp.vf2_292, mp.vf2_441,mp.vf2_293,mp.vf2_442, 
          mp.vf2_294, mp.vf2_443, mp.vf2_295, mp.vf2_444, mp.vf2_296, mp.vf2_304, mp.vf2_445);
    commit;

declare

n_igv number;

begin
  
select VAT_RATE into n_igv
   from dwo.dw_c_date
   where to_date(date_key,'YYYYMMDD') = last_day(to_date('&1','YYYYMM')  
   order by date_key;
  
execute immediate'create table dm.t$_trafico_facturado_granel nologging as
select periodo,
''51''||msisdn as msisdn,
vf2_323,
round(vf2_348,2) vf2_348,
vf2_324,
round(vf2_349,2) vf2_349,
vf2_325,
round(vf2_350,2) vf2_350,
round((vf2_447*('||n_igv||'+1)),2) vf2_447,
vf2_326,
round(vf2_351,2) vf2_351,
round((vf2_448*('||n_igv||'+1)),2) vf2_448,
vf2_328,
vf2_353,
round((vf2_449*('||n_igv||'+1)),2) vf2_449,
vf2_327,
round(vf2_352,2) vf2_352,
vf2_329,
vf2_330,
vf2_331,
vf2_354,
round(vf2_355,2) vf2_355,
round(vf2_356,2) vf2_356,
round((vf2_450*('||n_igv||'+1)),2) vf2_450,
vf2_361,
vf2_362,
round(vf2_367,2) vf2_367, -- revisar porque en el proceso llegaba sin dividir entre 60
vf2_368,
vf2_369,
vf2_373,
round((vf2_451*('||n_igv||'+1)),2) vf2_451,
round((vf2_452*('||n_igv||'+1)),2) vf2_452,
round((vf2_446*('||n_igv||'+1)),2) vf2_446,
vf2_292,
round((vf2_441*('||n_igv||'+1)),2) vf2_441,
vf2_293,
round((vf2_442*('||n_igv||'+1)),2) vf2_442,
vf2_294,
round((vf2_443*('||n_igv||'+1)),2) vf2_443,
vf2_295,
round((vf2_444*('||n_igv||'+1)),2) vf2_444,
vf2_296,
vf2_304,
round((vf2_445*('||n_igv||'+1)),2) vf2_445
 from dm.t$_trafico_fact_granel 
 where msisdn like ''9%''';

end;	
/

create table dm.t$_trafico_tasado_granel nologging as 
select served_number as msisdn, fecha as periodo, 
sum(vf2_323) vf2_323,sum(vf2_324) vf2_324,sum(vf2_325) vf2_325, 
sum(vf2_326) vf2_326, 
sum(vf2_327) vf2_327, 
sum(vf2_328) vf2_328, 
sum(vf2_329) vf2_329, 
sum(vf2_330) vf2_330, 
sum(vf2_331) vf2_331, 
sum(vf2_361) vf2_361, 
sum(vf2_362) vf2_362, 
sum(vf2_369) vf2_369, 
sum(vf2_292) vf2_292, 
sum(vf2_293) vf2_293, 
sum(vf2_294) vf2_294, 
sum(vf2_295) vf2_295, 
sum(vf2_296) vf2_296, 
sum(vf2_304) vf2_304, 
sum(vf2_348) vf2_348, 
sum(vf2_349) vf2_349, 
sum(vf2_350) vf2_350, 
sum(vf2_351) vf2_351, 
sum(vf2_352) vf2_352, 
sum(vf2_353) vf2_353, 
sum(vf2_354) vf2_354, 
sum(vf2_355) vf2_355, 
sum(vf2_356) vf2_356, 
sum(vf2_367) vf2_367, 
sum(vf2_368) vf2_368, 
sum(vf2_373) vf2_373, 
sum(vf2_447) vf2_447, 
sum(vf2_448) vf2_448, 
sum(vf2_449) vf2_449, 
sum(vf2_450) vf2_450, 
sum(vf2_451) vf2_451, 
sum(vf2_452) vf2_452, 
sum(vf2_441) vf2_441, 
sum(vf2_442) vf2_442, 
sum(vf2_443) vf2_443, 
sum(vf2_444) vf2_444, 
sum(vf2_445) vf2_445, 
sum(vf2_446) vf2_446
from 
(
select * from dm.DW_SPSS2_TASADO_bk
union all
select * from dm.DW_SPSS2_TASADO_cb_bk
)
group by served_number, fecha;


create table dm.dw_trafico_granel nologging as
select 
a.periodo as periodo,
a.msisdn as msisdn,
sum(vf2_323) vf2_323,sum(vf2_324) vf2_324,sum(vf2_325) vf2_325, 
sum(vf2_326) vf2_326, 
sum(vf2_327) vf2_327, 
sum(vf2_328) vf2_328, 
sum(vf2_329) vf2_329, 
sum(vf2_330) vf2_330, 
sum(vf2_331) vf2_331, 
sum(vf2_361) vf2_361, 
sum(vf2_362) vf2_362, 
sum(vf2_369) vf2_369, 
sum(vf2_292) vf2_292, 
sum(vf2_293) vf2_293, 
sum(vf2_294) vf2_294, 
sum(vf2_295) vf2_295, 
sum(vf2_296) vf2_296, 
sum(vf2_304) vf2_304, 
sum(vf2_348) vf2_348, 
sum(vf2_349) vf2_349, 
sum(vf2_350) vf2_350, 
sum(vf2_351) vf2_351, 
sum(vf2_352) vf2_352, 
sum(vf2_353) vf2_353, 
sum(vf2_354) vf2_354, 
sum(vf2_355) vf2_355, 
sum(vf2_356) vf2_356, 
sum(vf2_367) vf2_367, 
sum(vf2_368) vf2_368, 
sum(vf2_373) vf2_373, 
sum(vf2_447) vf2_447, 
sum(vf2_448) vf2_448, 
sum(vf2_449) vf2_449, 
sum(vf2_450) vf2_450, 
sum(vf2_451) vf2_451, 
sum(vf2_452) vf2_452, 
sum(vf2_441) vf2_441, 
sum(vf2_442) vf2_442, 
sum(vf2_443) vf2_443, 
sum(vf2_444) vf2_444, 
sum(vf2_445) vf2_445, 
sum(vf2_446) vf2_446
from 
(
select periodo,msisdn,vf2_292,vf2_293,vf2_294,vf2_295,vf2_296,vf2_304,vf2_323,vf2_324,vf2_325,vf2_326,vf2_327,
vf2_328,vf2_329,vf2_330,vf2_331,vf2_348,vf2_349,vf2_350,vf2_351,vf2_352,vf2_353,vf2_354,vf2_355,vf2_356,vf2_361,
vf2_362,vf2_367,vf2_368,vf2_369,vf2_373,vf2_441,vf2_442,vf2_443,vf2_444,vf2_445,vf2_446,vf2_447,vf2_448,vf2_449,
vf2_450,vf2_451,vf2_452
 from  dm.t$_trafico_tasado_granel
union all  
select periodo,msisdn,vf2_292,vf2_293,vf2_294,vf2_295,vf2_296,vf2_304,vf2_323,vf2_324,vf2_325,vf2_326,vf2_327,
vf2_328,vf2_329,vf2_330,vf2_331,vf2_348,vf2_349,vf2_350,vf2_351,vf2_352,vf2_353,vf2_354,vf2_355,vf2_356,vf2_361,
vf2_362,vf2_367,vf2_368,vf2_369,vf2_373,vf2_441,vf2_442,vf2_443,vf2_444,vf2_445,vf2_446,vf2_447,vf2_448,vf2_449,
vf2_450,vf2_451,vf2_452 from  dm.t$_trafico_facturado_granel
) a
group by a.msisdn, a.periodo;

INSERT INTO DWM.dw_trafico_granel SELECT * FROM DM.dw_trafico_granel; 
COMMIT;

drop table dm.DW_SPSS2_TASADO_GRANEL purge;
drop table dm.DW_SPSS2_TASADO_BK purge;
drop table dm.t$_spss2_trafico_adic_fact purge;
drop table dm.DW_SPSS2_TASADO_GRANEL_CB purge;
drop table dm.DW_SPSS2_TASADO_CB_BK purge;
drop table dm.t$_spss2_trafico_adic_fact_SMS purge;
drop table dm.t$_trafico_fact_granel purge;
drop table dm.t$_trafico_facturado_granel purge;
drop table dm.t$_trafico_tasado_granel purge;
drop table dm.dw_trafico_granel purge;

EXIT;
