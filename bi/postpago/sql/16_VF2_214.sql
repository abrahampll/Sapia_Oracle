WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;
BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_SEGMENTO_SIVCO_NOV17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_VF2_214');
END;
/

CREATE TABLE DM.DW_SPSS2_SEGMENTO_SIVCO_NOV17 NOLOGGING PARALLEL 2 AS
SELECT 
'&1' AS PERIODO, 
A.EMPRV_RUC RUC, 
P.PERFV_DESCR VF2_214
FROM DWS.SA_COBUT_EMPRESA A  
LEFT JOIN DWS.SA_COBUT_CONSULTOR E ON A.EMPRI_CONSID = E.CONSI_ID  
LEFT JOIN DWS.SA_COBUT_PERFIL P ON E.CONSI_NEWPERFID = P.PERFI_ID
LEFT JOIN DWS.SA_COBUT_TBP F ON E.CONSI_TBPCID = F.TBPCI_ID
WHERE P.PERFV_DESCR IS NOT NULL;

CREATE TABLE DM.DW_SPSS2_VF2_214 AS
SELECT PERIODO, RUC, VF2_214 FROM (
SELECT '&1' AS PERIODO, RUC, VF2_214,
ROW_NUMBER() OVER (PARTITION BY RUC ORDER BY PERIODO DESC) AS RW
FROM DM.DW_SPSS2_SEGMENTO_SIVCO_NOV17
)
WHERE RW = 1;

DELETE FROM DWM.DW_SPSS2_VF2_214 WHERE PERIODO='&1';
COMMIT;

INSERT INTO DWM.DW_SPSS2_VF2_214 SELECT * FROM DM.DW_SPSS2_VF2_214; 
COMMIT;

DROP TABLE DM.DW_SPSS2_VF2_214 PURGE;
DROP TABLE DM.DW_SPSS2_SEGMENTO_SIVCO_NOV17 PURGE;

EXIT;