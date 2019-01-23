PROCEDURE ADMPSI_REGULPTO(K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_REGULPTO
-- Propósito           :  Importar los puntos por Regularizacion
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creación        :  15/10/2010
-- Fec Actualización   :
--****************************************************************

V_REGCLI NUMBER;
C_FECPROCESO DATE;
C_NOMARCHIVO VARCHAR2(150);
C_NOM_REGUL VARCHAR2(150);
C_CODCLIENTE VARCHAR2(40);
C_PUNTOS NUMBER;
V_SALDO NUMBER;
V_TIPOP CHAR(1);
V_CODCONCEPTO VARCHAR2(2);
V_IDKARDEX NUMBER;
C_CODCLIENTEIB NUMBER;
V_TIPO_CLIENTE VARCHAR(2);
V_COUNT    NUMBER;

 CURSOR REGULARIZA_PTOS IS
  SELECT a.ADMPV_COD_CLI,
         a.ADMPN_PUNTOS,
         a.ADMPD_FEC_OPER,
         a.ADMPV_NOM_ARCH,
         a.ADMPV_NOM_REGUL
  FROM PCLUB.ADMPT_TMP_REGULARIZA a
  WHERE a.ADMPD_FEC_OPER=K_FECHA
        AND (a.ADMPC_COD_ERROR IS NULL or a.ADMPC_COD_ERROR='');

BEGIN

  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_REGULARIZA
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_REGULARIZA
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

    UPDATE PCLUB.ADMPT_TMP_REGULARIZA TR
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TR.ADMPV_COD_CLI );

  COMMIT;

  BEGIN
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%REGULARIZACION CC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  OPEN REGULARIZA_PTOS;
  FETCH REGULARIZA_PTOS INTO C_CODCLIENTE, C_PUNTOS, C_FECPROCESO, C_NOMARCHIVO, C_NOM_REGUL;

  WHILE REGULARIZA_PTOS %FOUND LOOP

         V_REGCLI :=0;

         SELECT COUNT(*)INTO V_REGCLI FROM PCLUB.ADMPT_AUX_REGULARIZA
         WHERE ADMPV_COD_CLI = C_CODCLIENTE
               AND ADMPV_NOM_REGUL = C_NOM_REGUL
               AND ADMPN_PUNTOS = C_PUNTOS
               AND ADMPD_FEC_OPER=C_FECPROCESO
               AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

         IF (V_REGCLI=0) THEN
            BEGIN
                IF C_PUNTOS < 0 THEN
                   V_TIPOP := 'S';
                   V_SALDO := 0;
                ELSE
                   V_TIPOP := 'E';
                   V_SALDO := C_PUNTOS;
                END IF;

                -- Se obtiene el codigo de cliente IB
                BEGIN
                  SELECT NVL(ADMPN_COD_CLI_IB,NULL) INTO C_CODCLIENTEIB
                    FROM PCLUB.ADMPT_CLIENTEIB
                   WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';

                   EXCEPTION
                     WHEN NO_DATA_FOUND
                       THEN C_CODCLIENTEIB := '';
                END;

                -- Se obtiene el tipo de cliente
                BEGIN
                   SELECT ADMPV_COD_TPOCL INTO V_TIPO_CLIENTE
                    FROM PCLUB.ADMPT_CLIENTE
                   WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';

                EXCEPTION
                   WHEN NO_DATA_FOUND
                       THEN V_TIPO_CLIENTE := '';
                END;

              IF C_PUNTOS <> 0 THEN

                  IF C_PUNTOS < 0 THEN

                    ADMPSI_DSCTO_PUNTO(C_CODCLIENTE,V_TIPO_CLIENTE,C_PUNTOS * -1,V_CODCONCEPTO,NULL,K_CODERROR,K_DESCERROR);

                    IF K_CODERROR <> '0' THEN

                      UPDATE ADMPT_TMP_REGULARIZA
                      SET ADMPC_COD_ERROR = '07', ADMPV_MSJE_ERROR = K_CODERROR || '-' || K_DESCERROR
                      WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                    ELSE

                      SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

                      INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                      ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                      ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                      VALUES(V_IDKARDEX, C_CODCLIENTEIB, C_CODCLIENTE, V_CODCONCEPTO,
                             TO_DATE (TO_CHAR(SYSDATE, 'dd/mm/yyyy'), 'dd/mm/yyyy'), C_PUNTOS, C_NOMARCHIVO, V_TIPOP, 'C', V_SALDO, 'A');

                    END IF;

                  ELSE

                  -- Obtenemos el secuencial del Kardex
                  SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

                  INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                  ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                  ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                  VALUES(V_IDKARDEX, C_CODCLIENTEIB, C_CODCLIENTE, V_CODCONCEPTO,
                         TO_DATE (TO_CHAR(SYSDATE, 'dd/mm/yyyy'), 'dd/mm/yyyy'), C_PUNTOS, C_NOMARCHIVO, V_TIPOP, 'C', V_SALDO, 'A');

                  
                  SELECT COUNT(1) INTO V_COUNT
                  FROM PCLUB.ADMPT_SALDOS_CLIENTE
                  WHERE ADMPV_COD_CLI = C_CODCLIENTE;
                 
                    IF (V_COUNT=0) THEN
                        INSERT INTO ADMPT_SALDOS_CLIENTE
                            (ADMPN_ID_SALDO,
                             ADMPV_COD_CLI,
                             ADMPN_SALDO_CC,
                             ADMPC_ESTPTO_CC,
                             ADMPD_FEC_REG
                         )VALUES(
                             ADMPT_SLD_CL_SQ.NEXTVAL,
                             C_CODCLIENTE,
                             C_PUNTOS,
                             'A',
                             SYSDATE
                         );
                    ELSE
                        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                        SET ADMPN_SALDO_CC = C_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                        FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                                       WHERE ADMPV_COD_CLI = C_CODCLIENTE),
                            ADMPD_FEC_MOD = SYSDATE
                        WHERE ADMPV_COD_CLI = C_CODCLIENTE;
                    END IF;
                  
                  END IF;

              END IF;

              -- Insertamos en la auxiliar para los reprocesos
              INSERT INTO PCLUB.ADMPT_AUX_REGULARIZA
                (admpv_cod_cli, admpv_nom_regul, admpn_puntos, admpd_fec_oper, admpv_nom_arch)
              VALUES
                (C_CODCLIENTE, C_NOM_REGUL, C_PUNTOS, C_FECPROCESO, C_NOMARCHIVO);

            END;
         END IF;

        --COMMIT;

      FETCH REGULARIZA_PTOS INTO C_CODCLIENTE, C_PUNTOS, C_FECPROCESO, C_NOMARCHIVO, C_NOM_REGUL;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_REGULARIZA WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_REGULARIZA WHERE ADMPD_FEC_OPER=K_FECHA AND (admpc_cod_error Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_REGULARIZA WHERE ADMPD_FEC_OPER=K_FECHA;

  -- Insertamos de la tabla temporal al final
  INSERT INTO PCLUB.ADMPT_IMP_REGULARIZA
  SELECT PCLUB.ADMPT_REGULA_SQ.nextval, admpv_cod_cli, admpv_nom_regul, admpv_periodo, admpn_cod_contr,
         admpd_fec_reg, admpv_hor_min, admpn_puntos, admpd_fec_oper, admpv_nom_arch,
         admpc_cod_error, admpv_msje_error, ADMPN_SEQ, SYSDATE
    FROM PCLUB.ADMPT_TMP_REGULARIZA
   WHERE admpd_fec_oper=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_REGULARIZA WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_REGULARIZA WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     K_CODERROR        := '-1';
     K_DESCERROR       := 'El concepto Regularizacion no se encuentra en la tabla. No se puede entrega puntos.';

   WHEN OTHERS THEN
     K_CODERROR:=to_char(SQLCODE);
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;

END ADMPSI_REGULPTO;