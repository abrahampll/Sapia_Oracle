create or replace package body PCLUB.PKG_CC_PREPAGO_RECAR is
PROCEDURE ADMPSS_CATEG_PRERECARGA_WA(K_FECHA IN DATE,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
  V_CONTADOR NUMBER;
  V_CAT_MAX NUMBER;
  V_NUM_REG NUMBER;


  BEGIN
    K_CODERROR:=0;
    K_DESCERROR:=0;
    V_CONTADOR:=0;
    V_CAT_MAX:=60;


    SELECT COUNT(C.ADMPV_COD_CLI)
    INTO V_NUM_REG
    FROM PCLUB.ADMPT_TMP_PRERECARGA C
    WHERE C.ADMPD_FEC_OPER = K_FECHA;

    IF V_NUM_REG > 0 THEN

    FOR REGISTR IN (  SELECT C.ADMPV_COD_CLI
                      FROM PCLUB.ADMPT_TMP_PRERECARGA C)
    LOOP
      V_CONTADOR:=V_CONTADOR+1;
      UPDATE PCLUB.ADMPT_TMP_PRERECARGA
         SET ADMPV_CATEGORIA=V_CONTADOR
      WHERE ADMPV_COD_CLI=REGISTR.ADMPV_COD_CLI;

      IF (V_CONTADOR + 1) > V_CAT_MAX  THEN
        V_CONTADOR:=0;
      END IF;
       COMMIT;
    END LOOP;
    ELSE
      K_CODERROR  := 1;
      K_DESCERROR := 'No existen registros.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

  END ADMPSS_CATEG_PRERECARGA_WA; 
  
procedure ADMPSI_PRERECAR_WA(
                          K_USUARIO     VARCHAR2,
                          K_FECHA       IN DATE,
                          K_NUME_PROCES IN  NUMBER,
                          K_CODERROR    OUT NUMBER,
                          K_DESCERROR   OUT VARCHAR2,
                          K_NUMREGTOT   OUT NUMBER,
                          K_NUMREGPRO   OUT NUMBER,
                          K_NUMREGERR   OUT NUMBER) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_PRERECAR
    -- Proposito           :  Importar los puntos por Prepago Recarga
    -- Input               :  K_FECHA
    -- Output              :  K_CODERROR Codigo de Error o Exito
    --                        K_DESCERROR Descripcion del Error (si se presento)
    --                        K_NUMREGTOT Numero total de Registros
    --                        K_NUMREGPRO Numero de Registros procesador
    --                        K_NUMREGERR Numero de Registros errados
    -- Creado por          :  Maomed Chocce
    -- Modificado por      :  Fredy Fernandez Espinoza
    -- Fec Creacion        :  17/11/2010
    -- Fec Actualizacion   :  16/03/2015
    -- Modificado por      :  Carlos Carrillo Orellano
    -- Fec Actualizacion   :  05/06/2015
    --****************************************************************


    NO_CONCEPTO EXCEPTION;
    NO_PARAMETRO EXCEPTION;

    V_NUMREGTOT NUMBER;
    TYPE TY_CURSOR IS REF CURSOR;

    V_NUMREGPRO NUMBER;
    V_COD_CPTO  NUMBER;
    V_PARAMETRO NUMBER;

    V_SQLCOD_ERROR NUMBER;
    V_SQL_ERROR VARCHAR2(400);

    C_PUNTOS  TY_CURSOR;
    V_ADMPN_COD_CLI_IB NUMBER;
    V_ADMPV_COD_CLI VARCHAR2(40);
    V_PUNTOS NUMBER;
    V_EXISTSALDO NUMBER;
    V_ENTPTOS NUMBER;
    V_MONTO NUMBER;
    V_FECULTREC DATE;
    V_C_ERROR NUMBER;

    V_C_CLIENTE NUMBER;
    V_FECHA VARCHAR2(6);
    V_NOM_PART CHAR(13);
    V_TIME_INICIO NUMBER:=0;
    
  BEGIN


K_CODERROR  := 0;
V_C_ERROR   := 0;
      BEGIN
        SELECT ADMPV_COD_CPTO
          INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
         WHERE ADMPV_DESC LIKE '%RECARGAS PREPAGO%';
        EXCEPTION
         WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
      END;

      BEGIN
         SELECT ADMPV_VALOR INTO V_PARAMETRO
         FROM PCLUB.ADMPT_PARAMSIST
         WHERE ADMPV_DESC LIKE '%PUNTOS_RECARGA_PREPAGO%';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN V_PARAMETRO:=NULL;
      END;

    IF V_COD_CPTO IS NULL THEN
       RAISE NO_CONCEPTO;
    END IF;

    IF V_PARAMETRO IS NULL THEN
       RAISE NO_PARAMETRO;
    END IF;

     V_NUMREGPRO := 0;
     V_NUMREGTOT := 0;

--  INICIO VALIDACIONES PROCESO ESTO PUEDE SER OTRO SP
--Se considero el flag de acumulacion de puntos en la validacion.
    PCLUB.PKG_CC_PREPAGO_RECAR.ADMPSI_PRERECAR_VALID_WA(K_FECHA,
                                           K_NUME_PROCES,
                                           V_PARAMETRO,
                                           K_CODERROR,
                                           K_DESCERROR);


        --EMPEZAMOS CON LA ENTREGA DE PUNTOS
          OPEN C_PUNTOS FOR
              SELECT
                  NULL,
                  A.ADMPV_COD_CLI,
                  FLOOR(NVL(A.ADMPN_MONTO, 0) / V_PARAMETRO),
                  A.ADMPN_MONTO,
                  A.ADMPD_FEC_ULTREC
              FROM
               PCLUB.ADMPT_TMP_PRERECARGA A
              WHERE
               A.ADMPV_ERROR IS NULL
               AND A.ADMPD_FEC_OPER +0=K_FECHA
               AND A.ADMPV_CATEGORIA= K_NUME_PROCES
               AND A.ADMPV_ESTPRO = '0'
               ;

           LOOP
              FETCH C_PUNTOS INTO V_ADMPN_COD_CLI_IB,V_ADMPV_COD_CLI,V_PUNTOS, V_MONTO, V_FECULTREC;
              EXIT WHEN C_PUNTOS%NOTFOUND;

              V_NUMREGTOT:=V_NUMREGTOT+1;



              BEGIN


              SELECT COUNT(1) INTO V_C_CLIENTE FROM PCLUB.ADMPT_CLIENTE C
              WHERE C.ADMPV_COD_CLI = V_ADMPV_COD_CLI
              AND C.ADMPC_ESTADO='A' AND C.ADMPV_COD_TPOCL='3';

              IF (V_C_CLIENTE=0) THEN

                  UPDATE PCLUB.ADMPT_TMP_PRERECARGA T
                  SET
                   T.ADMPV_ERROR = 2,
                   T.ADMPV_MSJE_ERROR='Cliente no existe o se encuentra en baja.',
                   T.ADMPV_ESTPRO=1
                   WHERE
                   T.ADMPV_COD_CLI=V_ADMPV_COD_CLI;


                    INSERT INTO PCLUB.ADMPT_IMP_PRERECARGA
                    (
                      ADMPN_ID_FILA,
                      ADMPV_COD_CLI,
                      ADMPD_FEC_ULTREC,
                      ADMPN_MONTO,
                      ADMPD_FEC_OPER,
                      ADMPV_MSJE_ERROR
                    ) VALUES
                    (
                      ADMPT_PRERECARGA_SQ.NEXTVAL,
                      V_ADMPV_COD_CLI,
                      V_FECULTREC,
                      V_MONTO,
                      to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
                      'Cliente no existe o se encuentra en baja.'
                    );

                    V_C_ERROR:=V_C_ERROR+1;

              ELSE
                  --******************EXISTE CLIENTE-----


                     V_TIME_INICIO:= DBMS_UTILITY.get_time;
                     
                     SELECT to_char(K_FECHA, 'yyyymm') 
                     INTO V_FECHA FROM dual;
                     V_NOM_PART:= TRIM('P_KARD_' || V_FECHA);
              SELECT COUNT(1)
                    INTO V_ENTPTOS
                    FROM PCLUB.ADMPT_KARDEX K
                   WHERE K.ADMPV_COD_CLI = V_ADMPV_COD_CLI
                     AND K.ADMPV_COD_CPTO = V_COD_CPTO
                     AND K.ADMPD_FEC_TRANS > TRUNC(K_FECHA - 1)
                     AND K.ADMPD_FEC_TRANS < TRUNC(K_FECHA + 1);

                        IF V_ENTPTOS=0 THEN
                             --INSERTAMOS EN KARDEX
                             INSERT INTO PCLUB.ADMPT_KARDEX
                               (ADMPN_ID_KARDEX,
                                ADMPV_COD_CLI,
                                ADMPV_COD_CPTO,
                                ADMPV_USU_REG,
                                ADMPD_FEC_TRANS,
                                ADMPN_PUNTOS,
                                ADMPC_TPO_OPER,
                                ADMPC_TPO_PUNTO,
                                ADMPN_SLD_PUNTO,
                                ADMPC_ESTADO)
                             VALUES
                               (ADMPT_KARDEX_SQ.NEXTVAL,
                                V_ADMPV_COD_CLI,
                                V_COD_CPTO,
                                K_USUARIO,
                                to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
                                V_PUNTOS,
                                'E',
                                'C',
                                V_PUNTOS,
                                'A');


                         --SI EL CODIGO DEL CLIENTE NO EXISTE EN SALDOS,
                         SELECT CASE
                                  WHEN EXISTS
                                   (SELECT 1
                                          FROM PCLUB.ADMPT_SALDOS_CLIENTE S
                                         WHERE S.ADMPV_COD_CLI = V_ADMPV_COD_CLI) THEN
                                   1
                                  ELSE
                                   0
                                END
                           INTO V_EXISTSALDO
                           FROM DUAL;

                           --SE LLEGA A INSERTAR CASO CONTRARIO, ACTUALIZAR.
                           IF (V_EXISTSALDO=0) THEN
                                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                                    (ADMPN_ID_SALDO,
                                     ADMPV_COD_CLI,
                                     ADMPN_SALDO_CC,
                                     ADMPC_ESTPTO_CC,
                                     ADMPD_FEC_REG
                                 )VALUES(
                                     ADMPT_SLD_CL_SQ.NEXTVAL,
                                     V_ADMPV_COD_CLI,
                                     V_PUNTOS,
                                     'A',
                                     SYSDATE
                                 );
                           ELSE
                                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                                SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_PUNTOS,
                                ADMPD_FEC_MOD = SYSDATE
                                WHERE S.ADMPV_COD_CLI = V_ADMPV_COD_CLI;
                           END IF;

                        ELSE
                         

                          INSERT INTO PCLUB.ADMPT_IMP_PRERECARGA
                          (
                            ADMPN_ID_FILA,
                            ADMPV_COD_CLI,
                            ADMPD_FEC_ULTREC,
                            ADMPN_MONTO,
                            ADMPD_FEC_OPER,
                            ADMPV_MSJE_ERROR
                          ) VALUES
                          (
                            ADMPT_PRERECARGA_SQ.NEXTVAL,
                            V_ADMPV_COD_CLI,
                            V_FECULTREC,
                            V_MONTO,
                            to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
                            'El cliente ya recibio los puntos por recarga en este periodo'
                          );

                          V_C_ERROR:=V_C_ERROR+1;

                      END IF;

                      /******* INI: ESTADO DE PROCESO Y REPROCESO *******/
                      UPDATE PCLUB.ADMPT_TMP_PRERECARGA R
                      SET R.ADMPV_ESTPRO = '1'
                      WHERE R.ADMPV_COD_CLI = V_ADMPV_COD_CLI AND R.ADMPD_FEC_OPER = K_FECHA
                      AND R.ADMPV_CATEGORIA = K_NUME_PROCES;

                  --******************FIN EXISTE CLIENTE-----
              END IF;

             COMMIT;
             V_NUMREGPRO := V_NUMREGPRO + 1;
             EXCEPTION
                  WHEN OTHERS THEN
                    ROLLBACK;
                    V_SQLCOD_ERROR := SQLCODE;
                    V_SQL_ERROR := SUBSTR(SQLERRM, 1, 250);
                    UPDATE PCLUB.ADMPT_TMP_PRERECARGA
                    SET ADMPV_ESTPRO = 1,
                        ADMPV_ERROR = V_SQLCOD_ERROR,
                        ADMPV_MSJE_ERROR = V_SQL_ERROR
                    WHERE ADMPV_COD_CLI = V_ADMPV_COD_CLI
                    AND ADMPV_CATEGORIA = K_NUME_PROCES;
                    V_C_ERROR := V_C_ERROR + 1;
                    COMMIT;
              END;

           END LOOP;

           CLOSE C_PUNTOS;

    K_NUMREGTOT := V_NUMREGTOT;
    K_NUMREGERR := V_NUMREGPRO + V_C_ERROR;
    K_NUMREGPRO := V_NUMREGTOT - K_NUMREGERR;

  EXCEPTION
    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado el parametro de RECARGAS PREPAGO (ADMPT_CONCEPTO).';
      ROLLBACK;

    WHEN NO_PARAMETRO THEN
      K_CODERROR  := 56;
      K_DESCERROR := 'No se tiene registrado el parametro de PUNTOS_RECARGA_PREPAGO (ADMPT_PARAMSIST).';
      ROLLBACK;

    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

END ADMPSI_PRERECAR_WA;

procedure ADMPSI_PRERECAR_VALID_WA(K_FECHA IN DATE,
                                 K_NUME_PROCES IN  NUMBER,
                                 K_PARAMETRO NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2)IS
BEGIN
K_CODERROR:=1;
K_DESCERROR:='';
    
    UPDATE PCLUB.ADMPT_TMP_PRERECARGA T
      SET
      ADMPV_ERROR = 2,
      ADMPV_MSJE_ERROR='Cliente no existe o se encuentra en baja.',
      ADMPV_ESTPRO=1
      WHERE NOT EXISTS (SELECT 1
                        FROM PCLUB.ADMPT_CLIENTE C
                        WHERE C.ADMPV_COD_CLI=T.ADMPV_COD_CLI
                                AND C.ADMPV_COD_TPOCL='3'
                                AND C.ADMPC_ESTADO='A')
              AND T.ADMPD_FEC_OPER+0=K_FECHA
              AND T.ADMPV_MSJE_ERROR IS NULL
              AND T.ADMPV_CATEGORIA = K_NUME_PROCES;


COMMIT;

    --SE LE ASIGNA EL ERROR SI EL MONTO EN EL CURSOR ES MENOR A 0
    UPDATE PCLUB.ADMPT_TMP_PRERECARGA SET
      ADMPV_ERROR = 4,
      admpv_estpro=1,
      ADMPV_MSJE_ERROR = 'Monto de Recarga debe ser mayor que ' || TO_CHAR(K_PARAMETRO)
    WHERE
      ADMPD_FEC_OPER=K_FECHA
      AND ADMPV_CATEGORIA = K_NUME_PROCES
      AND (ADMPN_MONTO < K_PARAMETRO)
      AND ADMPV_ERROR IS NULL;
      COMMIT;
    --SI LA FECHA DE LA ULTIMA RECARGA ES MENOR A LA FECHA DE REGISTRO EN CLAROCLUB NO DEBE ENTREGAR PUNTOS

      UPDATE PCLUB.ADMPT_TMP_PRERECARGA T
      SET ADMPV_ERROR = 5,
          ADMPV_ESTPRO=1,
          ADMPV_MSJE_ERROR = 'La fecha de la última recarga es menor a la fecha de registro CC'
      WHERE
      EXISTS (
        SELECT 1
        FROM PCLUB.ADMPT_CLIENTE C
        WHERE C.ADMPV_COD_CLI = T.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL='3'
              AND C.ADMPC_ESTADO='A'
              AND T.ADMPD_FEC_ULTREC<C.ADMPD_FEC_REG
      )
      AND T.ADMPD_FEC_OPER=K_FECHA
      AND ADMPV_CATEGORIA = K_NUME_PROCES;


    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;



END ADMPSI_PRERECAR_VALID_WA; 


PROCEDURE ADMPSI_FECHAFALTA_PRO
(
    K_FECHA OUT DATE,
    K_CANTSIN_PROC OUT NUMBER,
    K_CANTSIN_CATE OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_FECHAFALTA_PRO
  -- Proposito           :
  -- Output              :  K_FECHA
  --                        K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Carlos Carrillo Orellano
  -- Fec Creacion        :  08/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;
  V_CANTREGERR NUMBER;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_CANTSIN_PROC := 0;
  K_CANTSIN_CATE := 0;
  V_CANTREGERR := 0;

  SELECT COUNT(1) INTO V_CANTREGERR FROM PCLUB.ADMPT_TMP_PRERECARGA R WHERE R.ADMPV_MSJE_ERROR IS NOT NULL;
  SELECT COUNT(1) INTO V_CANTREG FROM PCLUB.ADMPT_TMP_PRERECARGA R WHERE R.ADMPV_MSJE_ERROR IS NULL;
  SELECT COUNT(1) INTO V_CANTPRO FROM PCLUB.ADMPT_TMP_PRERECARGA R WHERE R.ADMPV_ESTPRO = '1';

  IF (V_CANTREG=V_CANTPRO) THEN

    IF (V_CANTREG<>0) THEN
      K_CODERROR := 1;
      K_DESCERROR:='Debe de ejecutar el shell SH010_RECARGA_VALPROREC.sh para eliminar los registros temporales.';
    END IF;
    IF (V_CANTREGERR<>0)THEN
      K_CODERROR:=1;
      K_DESCERROR:='Debe de ejecutar el shell SH012_LIMPIAR_TMP_VENCIMIENTO.sh. antes de vencer los puntos.';
    END IF;

  ELSE

    SELECT COUNT(1) INTO K_CANTSIN_PROC FROM PCLUB.ADMPT_TMP_PRERECARGA
    WHERE ADMPV_ESTPRO = 0;

    SELECT COUNT(1) INTO K_CANTSIN_CATE FROM PCLUB.ADMPT_TMP_PRERECARGA
    WHERE (ADMPV_CATEGORIA IS NULL OR ADMPV_CATEGORIA = '');

    IF K_CANTSIN_PROC > 0 THEN
       SELECT T.ADMPD_FEC_OPER INTO K_FECHA FROM PCLUB.ADMPT_TMP_PRERECARGA T
       WHERE T.ADMPV_ESTPRO = 0 AND ROWNUM = 1;
    END IF;
    IF (V_CANTREGERR <> 0)THEN
      K_CODERROR:=1;
      K_DESCERROR:='Debe de ejecutar el shell SH012_LIMPIAR_TMP_VENCIMIENTO.sh. antes de vencer los puntos.';
    END IF;

  END IF;

  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR
      INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;
  EXCEPTION
    WHEN OTHERS THEN
      K_DESCERROR := 'ERROR';
  END;

EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_FECHAFALTA_PRO;

PROCEDURE ADMPSI_PRERECAR_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR    OUT NUMBER,
                                     K_DESCERROR   OUT VARCHAR2)
IS
BEGIN
  K_CODERROR:='0';
  K_DESCERROR:='';
SELECT COUNT(1) INTO K_COUNT FROM PCLUB.ADMPT_TMP_PRERECARGA T
WHERE T.ADMPV_CATEGORIA = K_PROC
AND T.ADMPV_ESTPRO = '0';
EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_PRERECAR_CONF;
end PKG_CC_PREPAGO_RECAR;
/