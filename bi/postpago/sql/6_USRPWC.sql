WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

INSERT INTO dwm.dw_spss2_f_m_lineas_celda_cdr
SELECT * FROM dm.dw_spss2_f_m_lineas_celda_cdr@DBL_DWM;
COMMIT;

INSERT INTO dwm.DW_SPSS2_CURSADO
SELECT * FROM dm.DW_SPSS2_CURSADO@DBL_DWM;
COMMIT;

INSERT INTO dwm.DW_VF2_192_f
SELECT * FROM dm.DW_VF2_192_f@DBL_DWM;
COMMIT;

INSERT INTO dwm.DW_SPSS2_TOPE_CONSUMO
SELECT * FROM dm.DW_SPSS2_TOPE_CONSUMO@DBL_DWM;
COMMIT;



EXIT;