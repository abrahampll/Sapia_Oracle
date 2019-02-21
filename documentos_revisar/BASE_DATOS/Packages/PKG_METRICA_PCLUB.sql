CREATE OR REPLACE PACKAGE pclub.pkg_metrica_pclub
IS
  v_cod_cpto CONSTANT VARCHAR2(2) := '14';
  v_recarga  CONSTANT VARCHAR2(7) := 'RECARGA';

  PROCEDURE metss_dato_155( pi_fecha_ini IN DATE,
                            pi_fecha_fin IN DATE,
                            po_valor     OUT NUMBER,
                            po_cantreg   OUT INTEGER,
                            po_resultado OUT INTEGER,
                            po_msgerr    OUT VARCHAR2 );
END;
/