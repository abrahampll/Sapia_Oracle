WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

DROP TABLE DM.DW_spss_lineas_post_jul17_p PURGE;
DROP TABLE DM.DW_VF2_192_f PURGE;

create table DM.DW_spss_lineas_post_jul17_p AS
select TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') as periodo, a.nro_documento, count(1) VF2_192
from dm.f_m_abonados partition (p_201707) a , dm.dw_sus_d_segmento b , dm.dw_sus_d_estado e , 
(select nro_documento from DM.DW_maestra_postpago d 
where d.postpago='MASIVO' group by nro_documento) c
where a.idsegmento=b.idsegmento
and a.idsegmento=3
and a.idestado=e.idestado
and length(a.msisdn)=11
and a.idplataforma=e.idplataforma
and a.nro_documento=c.nro_documento
group by a.nro_documento;

CREATE TABLE DM.DW_VF2_192_f AS
SELECT A.*, B.VF2_192 FROM dm.DW_maestra_postpago a
INNER JOIN  DM.DW_spss_lineas_post_jul17_p b
ON A.MES = B.PERIODO
AND A.NRO_DOCUMENTO = B.NRO_DOCUMENTO
AND A.FCH_ACTIVACION IS NOT NULL
AND A.STATUS IN ('ACTIVO', 'SUSPENDIDO')
AND A.POSTPAGO = 'MASIVO';

GRANT ALL ON DM.DW_VF2_192_f TO DBLINK_DWO;

DROP TABLE DM.DW_spss_lineas_post_jul17_p PURGE;

EXIT;