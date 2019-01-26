CREATE OR REPLACE PACKAGE BODY pclub.pkg_metrica_pclub
IS
  PROCEDURE metss_dato_155( pi_fecha_ini IN DATE,
                            pi_fecha_fin IN DATE,
                            po_valor     OUT NUMBER,
                            po_cantreg   OUT INTEGER,
                            po_resultado OUT INTEGER,
                            po_msgerr    OUT VARCHAR2 )
  IS
  BEGIN
    po_resultado := 0;
    po_msgerr := 'Proceso satisfactorio';

    IF pi_fecha_ini IS NULL THEN
      po_resultado := -1;
      po_msgerr := 'Debe ingresar la fecha de inicio';
      RETURN;
    END IF;

    IF pi_fecha_fin IS NULL THEN
       po_resultado := -2;
       po_msgerr := 'Debe ingresar la fecha fin';
       RETURN;
    END IF;

    IF pi_fecha_fin < pi_fecha_ini THEN
      po_resultado := -3;
      po_msgerr := 'La fecha fin debe ser mayor a la fecha de inicio';
      RETURN;
    END IF;

    SELECT NVL(SUM(to_number(SUBSTR(ca.admpv_clave, INSTR(ca.admpv_clave, '.') + 1, LENGTH(ca.admpv_clave)))), 0) AS monto,
           COUNT(ka.admpv_cod_cli) AS cantidad
    INTO po_valor,
         po_cantreg
    FROM pclub.admpt_kardex ka
    INNER JOIN pclub.admpt_canje ca
      ON (ka.admpv_cod_cli = ca.admpv_cod_cli AND
          ka.admpn_id_kardex = ca.admpn_id_kardex)
    WHERE ka.admpv_cod_cpto = v_cod_cpto
      AND UPPER(ca.admpv_clave) LIKE '%' || v_recarga || '%'
      AND ka.admpd_fec_trans >= pi_fecha_ini
      AND ka.admpd_fec_trans <= pi_fecha_fin;

  EXCEPTION
    WHEN OTHERS THEN
      po_resultado := -99;
      po_msgerr := SQLERRM;
  END;
END;
/