WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_TASADO_DEMANDA');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_SPSS2_TASADO_DEM_MES');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_USAGE_DEM_D');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_USAGE_DET_DEM_D');
END;
/

create table dm.DW_SPSS2_TASADO_DEMANDA
(
  served_number VARCHAR2(25) not null,
  fecha         NUMBER,
  vf2_315       NUMBER,
  vf2_316       NUMBER,
  vf2_317       NUMBER,
  vf2_318       NUMBER,
  vf2_319       NUMBER,
  vf2_320       NUMBER,
  vf2_321       NUMBER,
  vf2_322       NUMBER,
  vf2_359       NUMBER,
  vf2_360       NUMBER,
  vf2_370       NUMBER,
  vf2_287       NUMBER,
  vf2_288       NUMBER,
  vf2_289       NUMBER,
  vf2_290       NUMBER,
  vf2_291       NUMBER,
  vf2_303       NUMBER,
  vf2_340       NUMBER,
  vf2_341       NUMBER,
  vf2_342       NUMBER,
  vf2_343       NUMBER,
  vf2_344       NUMBER,
  vf2_345       NUMBER,
  vf2_346       NUMBER,
  vf2_347       NUMBER,
  vf2_365       NUMBER,
  vf2_366       NUMBER,
  vf2_374       NUMBER
) nologging;

create table dm.DW_SPSS2_TASADO_DEM_MES
(
  served_number VARCHAR2(25) not null,
  fecha         NUMBER,
  vf2_315       NUMBER,
  vf2_316       NUMBER,
  vf2_317       NUMBER,
  vf2_318       NUMBER,
  vf2_319       NUMBER,
  vf2_320       NUMBER,
  vf2_321       NUMBER,
  vf2_322       NUMBER,
  vf2_359       NUMBER,
  vf2_360       NUMBER,
  vf2_370       NUMBER,
  vf2_287       NUMBER,
  vf2_288       NUMBER,
  vf2_289       NUMBER,
  vf2_290       NUMBER,
  vf2_291       NUMBER,
  vf2_303       NUMBER,
  vf2_340       NUMBER,
  vf2_341       NUMBER,
  vf2_342       NUMBER,
  vf2_343       NUMBER,
  vf2_344       NUMBER,
  vf2_345       NUMBER,
  vf2_346       NUMBER,
  vf2_347       NUMBER,
  vf2_365       NUMBER,
  vf2_366       NUMBER,
  vf2_374       NUMBER
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
 
	select '&1' into V_PERIODO from dual;
	
    Execute Immediate 'ALTER SESSION SET NLS_DATE_FORMAT=''DD/MM/RRRR''';    
    LD_FECINI := TO_DATE(V_PERIODO, 'YYYYMM');  
    SELECT LAST_DAY(LD_FECINI) + 1 INTO LD_FECFIN FROM DUAL;
	
    if substr(V_PERIODO,6)='6' then
       LD_FECINI:=TO_DATE(V_PERIODO||'24','YYYYMMDD');
    end if; 
    
    WHILE LD_FECINI < LD_FECFIN LOOP
      V_DIA := TO_CHAR(LD_FECINI, 'yyyymmdd');
      V_QUERY := '';
      V_QUERY := ' CREATE TABLE DM.DW_SPSS2_USAGE_DEM_D NOLOGGING  AS '||
   'select /* +append index (j, USAGE_JANUS_IDX2) */ '||
    'j.usage_event_id, '||
    'j.usage_event_sc, '||
    'j.served_number, '||
    'to_char(j.usage_date_start,''yyyymmdd'') fecha, '||
    'et.source_code requesttype, '||
    'j.served_network_opera, '||
    'j.other_network_opera, '||
    'CASE WHEN  ET.SOURCE_CODE IN (''1001'',''1003'') AND  J.LOCAL_USAGE_IND<>''3'' AND J.OTHER_NETWORK_OPERA<>''21'' THEN 1 ELSE 0 END AS VF2_315, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2141'' and J.OTHER_NETWORK_OPERA=''24'' THEN 1 ELSE 0 END AS VF2_316, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''3'' and J.OTHER_NETWORK_OPERA=''20'' THEN 1 ELSE 0 END AS VF2_317, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''22'' THEN 1 ELSE 0 END AS VF2_318, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'') THEN 1 ELSE 0 END AS VF2_319, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''25'' THEN 1 ELSE 0 END AS VF2_320, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE IN (''7'',''8'') and J.OTHER_NETWORK_OPERA=''32'' THEN 1 ELSE 0 END AS VF2_321, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND   UD.SOURCE_CODE IN (''7'',''8'') and J.OTHER_NETWORK_OPERA NOT IN (''37'',''32'') THEN 1 ELSE 0 END AS VF2_322, '||
    'CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND  UD.SOURCE_CODE=1 AND J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_359, '||
   ' CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND  UD.SOURCE_CODE IN (''5'',''6'') AND J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_360, '||
   ' CASE WHEN ET.SOURCE_CODE IN (''1001'',''1003'') AND  J.LOCAL_USAGE_IND=''3'' THEN 1 ELSE 0 END AS VF2_370, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2141'' and J.OTHER_NETWORK_OPERA=''24'' THEN 1 ELSE 0 END AS VF2_287 , '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''3'' and J.OTHER_NETWORK_OPERA=''20'' THEN 1 ELSE 0 END AS VF2_288, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''22'' THEN 1 ELSE 0 END AS VF2_289, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA=''25'' THEN 1 ELSE 0 END AS VF2_290, '||
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''2'' and J.OTHER_NETWORK_OPERA NOT IN (''24'',''20'',''22'',''25'')  THEN 1 ELSE 0 END AS VF2_291, '||      
   'CASE WHEN ET.SOURCE_CODE =''1004'' AND   UD.SOURCE_CODE =''1'' and J.OTHER_NETWORK_OPERA=''21'' THEN 1 ELSE 0 END AS VF2_303 '||        
   ' FROM DWO.USAGE SUBPARTITION(p_'||V_DIA||'_janus) j '||
    'LEFT JOIN DWO.DW_C_USAGE_EVENT_TYPE ET ON ET.USG_EVENT_TYPE_ID=J.USAGE_TYPE_ID '||
    'LEFT JOIN DWO.DW_C_USAGE_DOMAIN UD ON J.USAGE_DOMAIN_ID=UD.USAGE_DOMAIN_ID '||
    'WHERE ET.SOURCE_CODE IN (''1001'',''1003'',''1004'')';  
      EXECUTE IMMEDIATE V_QUERY;
	  
      V_QUERY := '';
      V_QUERY := 'CREATE TABLE DM.DW_SPSS2_USAGE_DET_DEM_D NOLOGGING  AS '|| 
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
    ' uw.source_code in (''2'',''3'') and b.usage_units<>0';

     EXECUTE IMMEDIATE V_QUERY;

        V_QUERY:='';
     v_query:=' INSERT /*+ APPEND NOLOGGING*/ INTO DM.DW_SPSS2_TASADO_DEM_MES '||
    'select '||
    'j.served_number, '||V_DIA||' AS FECHA, '||
    'SUM(J.VF2_315) AS VF2_315,  '||
    'SUM(j.VF2_316) AS VF2_316,  '||
    'SUM(j.VF2_317) AS VF2_317, '||
    'SUM(j.VF2_318) AS VF2_318,  '||
    'SUM(j.VF2_319) AS VF2_319,  '||
    'SUM(j.VF2_320) AS VF2_320, '||
    'SUM(j.VF2_321) AS VF2_321,  '||
    'SUM(j.VF2_322) AS VF2_322, '||
    'SUM(j.VF2_359) AS VF2_359, '||
    'SUM(j.VF2_360) AS VF2_360, '||
    'SUM(j.VF2_370) AS VF2_370,    '||
    'SUM(j.VF2_287) AS VF2_287 , '||
    'SUM(j.VF2_288) AS VF2_288, '||
    'SUM(j.VF2_289) AS VF2_289,  '||
    'SUM(j.VF2_290) AS VF2_290,  '||
    'SUM(j.VF2_291) AS VF2_291, '||
    'SUM(j.VF2_303) AS VF2_303,    '|| 
    'sum(case when j.VF2_315>0 then b.usage_units else 0 end) as VF2_340,  '||
    'sum(case when j.VF2_316>0 then b.usage_units else 0 end) as VF2_341,  '||
    'sum(case when j.VF2_317>0 then b.usage_units else 0 end) as VF2_342,  '||
    'sum(case when j.VF2_318>0 then b.usage_units else 0 end) as VF2_343, '||
    'sum(case when j.VF2_319>0 then b.usage_units else 0 end) as VF2_344, '||
    'sum(case when j.VF2_320>0 then b.usage_units else 0 end) as VF2_345, '||
    'sum(case when j.VF2_321>0 then b.usage_units else 0 end) as VF2_346, '||
    'sum(case when j.VF2_322>0 then b.usage_units else 0 end) as VF2_347, '||
    'sum(case when j.VF2_359>0 then b.usage_units else 0 end) as VF2_365, '||
    'sum(case when j.VF2_360>0 then b.usage_units else 0 end) as VF2_366,  '||     
    'sum(case when j.VF2_370>0 then b.usage_units else 0 end) as VF2_374 '||           
    'from  DM.DW_SPSS2_USAGE_DEM_D  j '||
    'join DM.DW_SPSS2_USAGE_DET_DEM_D b on j.usage_event_id=b.usage_event_id  '||
    'and j.served_number=b.served_number '||
    'group by  j.served_number';
    
EXECUTE IMMEDIATE V_QUERY;
	COMMIT;
  V_QUERY:='';
     v_query:='truncate table DM.DW_SPSS2_USAGE_DEM_D drop all storage';
                EXECUTE IMMEDIATE V_QUERY;

  V_QUERY:='';
     v_query:='drop table DM.DW_SPSS2_USAGE_DEM_D purge';
                EXECUTE IMMEDIATE V_QUERY;                
   
        V_QUERY:='';
     v_query:='truncate table DM.DW_SPSS2_USAGE_DET_DEM_D drop all storage';
                EXECUTE IMMEDIATE V_QUERY;

  V_QUERY:='';
     v_query:='drop table DM.DW_SPSS2_USAGE_DET_DEM_D purge';
                EXECUTE IMMEDIATE V_QUERY; 
      
      LD_FECINI := LD_FECINI + 1;
    END LOOP;
        

             
      V_QUERY:='';
     v_query:=' INSERT /*+ APPEND nologging */ INTO  DM.DW_SPSS2_TASADO_DEMANDA  ' ||
    'select /*+ CHOOSE, INDEX (j, idx2_usage_janust1_'||v_DIA||')*/ '||
    'j.served_number,' ||V_PERIODO||' AS FECHA, '||
    'SUM(J.VF2_315) AS VF2_315, SUM(j.VF2_316) AS VF2_316, SUM(j.VF2_317) AS VF2_317,SUM(j.VF2_318) AS VF2_318, '||
    'SUM(j.VF2_319) AS VF2_319, SUM(j.VF2_320) AS VF2_320, SUM(j.VF2_321) AS VF2_321, SUM(j.VF2_322) AS VF2_322, '||
    'SUM(j.VF2_359) AS VF2_359,SUM(j.VF2_360) AS VF2_360,SUM(j.VF2_370) AS VF2_370, SUM(j.VF2_287 ) AS VF2_287 ,SUM(j.VF2_288) AS VF2_288, '||
    'SUM(j.VF2_289) AS VF2_289, SUM(j.VF2_290) AS VF2_290,  SUM(j.VF2_291) AS VF2_291, SUM(j.VF2_303) AS VF2_303,'||    
    'ROUND(sum(VF2_340)/60,2) as VF2_340, ROUND(sum(VF2_341)/60,2) as VF2_341,ROUND(sum(VF2_342)/60,2) as VF2_342, '||
     'ROUND(sum(VF2_343)/60,2) as VF2_343,ROUND(sum(VF2_344)/60,2) as VF2_344,ROUND(sum(VF2_345)/60,2) as VF2_345, '||
     'ROUND(sum(VF2_346)/60,2) as VF2_346, '||
     'ROUND(sum(VF2_347)/60,2) as VF2_347, ROUND(sum(VF2_365)/60,2) as VF2_365, '||
     'ROUND(sum(VF2_366)/60,2) as VF2_366,ROUND(sum(VF2_374)/60,2) as VF2_374 '||         
   ' from DM.DW_SPSS2_TASADO_DEM_MES j group by  j.served_number' ;
                EXECUTE IMMEDIATE V_QUERY;
                COMMIT;
      V_QUERY:='';
      V_QUERY:='TRUNCATE TABLE DM.DW_SPSS2_TASADO_DEM_MES DROP ALL STORAGE';
      EXECUTE IMMEDIATE V_QUERY;
	  
	 V_QUERY:='';
     v_query:='drop table DM.DW_SPSS2_TASADO_DEM_MES purge';
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

INSERT INTO DWM.DW_SPSS2_TASADO_DEMANDA SELECT * FROM DM.DW_SPSS2_TASADO_DEMANDA; 
COMMIT;

DROP TABLE DM.DW_SPSS2_TASADO_DEMANDA PURGE;

EXIT;
