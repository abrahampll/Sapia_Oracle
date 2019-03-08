WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

CREATE TABLE DM.DW_SAS_COMUNIDAD_NOV17 nologging parallel 20 AS
  select '201809' as periodo,
  a.nlineaid as msisdn,    
         case
           when a.ROL = 1 THEN  'LIDER'
           when a.ROL = 2 THEN  'SEGUIDOR'
           when a.ROL = 3 THEN  'MARGINAL DE GRADO 1'
           when a.ROL = 4 THEN  'OUTLIER'
           when a.ROL = 5 THEN  'MARGINAL DE GRADO 2'
         END VF2_134,
         a.comunidad as VF2_132,
         b. cant_lineas_VF2_128 as VF2_128
    from DM.dWH_SAS_COMUNIDAD PARTITION(P_201806) a
   inner join (SELECT COMUNIDAD, COUNT(COMUNIDAD) cant_lineas_VF2_128
                 FROM DM.DWH_SAS_COMUNIDAD PARTITION(P_201806)
                GROUP BY COMUNIDAD) b
      on a.comunidad = b.comunidad;
GRANT SELECT ON DM.DW_SAS_COMUNIDAD_NOV17 TO DBLINK_DWO;
	  
EXIT;