create or replace package body PCLUB.PKG_CC_PREPAGO is

procedure ADMPSI_PRERECAR(K_FECHA       IN DATE,
                          K_NUME_PROCES IN  NUMBER,
                          K_CODERROR    OUT NUMBER,
                          K_DESCERROR   OUT VARCHAR2,
                          K_NUMREGTOT   OUT NUMBER,
                          K_NUMREGPRO   OUT NUMBER,
                          K_NUMREGERR   OUT NUMBER) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_PRERECAR
    -- Propósito           :  Importar los puntos por Prepago Recarga
    -- Input               :  K_FECHA
    -- Output              :  K_CODERROR Codigo de Error o Exito
    --                        K_DESCERROR Descripcion del Error (si se presento)
    --                        K_NUMREGTOT Numero total de Registros
    --                        K_NUMREGPRO Numero de Registros procesador
    --                        K_NUMREGERR Numero de Registros errados
    -- Creado por          :  Maomed Chocce
    -- Modificado por      :  Fredy Fernandez Espinoza
    -- Fec Creación        :  17/11/2010
    -- Fec Actualización   :  16/03/2015
    --****************************************************************

    NO_CONCEPTO EXCEPTION;
    NO_PARAMETRO EXCEPTION;

    V_NUMREGTOT NUMBER;
    TYPE TY_CURSOR IS REF CURSOR;

    V_NUMREGPRO NUMBER;
    V_COD_CPTO  NUMBER;
    V_PARAMETRO NUMBER;

-- *******************************;
    C_PUNTOS  TY_CURSOR;
    V_ADMPN_COD_CLI_IB NUMBER;
    V_ADMPV_COD_CLI VARCHAR2(40);
    V_PUNTOS NUMBER;
    V_SALDO_PUNTOS NUMBER;
    V_EXISTSALDO NUMBER;
    V_ENTPTOS NUMBER;
    V_MONTO NUMBER;
    V_FECULTREC DATE;
    V_C_ERROR NUMBER;

  BEGIN

K_CODERROR  := 0;
V_C_ERROR :=0;
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

--  INICIO VALIDACIONES PROCESO ESTO PUEDE SER OTRO SP
    PCLUB.PKG_CC_PREPAGO.ADMPSI_PRERECAR_VALID(K_FECHA,
                                           K_NUME_PROCES,
                                           V_PARAMETRO,
                                           K_CODERROR,
                                           K_DESCERROR);



    --INSERTAMOS EN LA IMP LOS REGISTRO CON ERROR
        INSERT INTO PCLUB.ADMPT_IMP_PRERECARGA
            SELECT
            ADMPT_PRERECARGA_SQ.NEXTVAL,
            ADMPV_COD_CLI,
            ADMPD_FEC_ULTREC,
            ADMPN_MONTO,
            ADMPD_FEC_OPER,
            ADMPV_MSJE_ERROR
            FROM PCLUB.ADMPT_TMP_PRERECARGA
            WHERE ADMPV_ERROR IS NOT NULL
            AND ADMPV_CATEGORIA=K_NUME_PROCES;
        COMMIT;


        --EMPEZAMOS CON LA ENTREGA DE PUNTOS
          OPEN C_PUNTOS FOR
              SELECT
                  T4.ADMPN_COD_CLI_IB,
                  A.ADMPV_COD_CLI,
                  FLOOR(NVL(A.ADMPN_MONTO, 0) / V_PARAMETRO),
                  A.ADMPN_MONTO,
                  A.ADMPD_FEC_ULTREC
              FROM
               PCLUB.ADMPT_TMP_PRERECARGA A
               INNER JOIN PCLUB.ADMPT_CLIENTE T3 ON
               T3.ADMPV_COD_CLI=A.ADMPV_COD_CLI
               LEFT JOIN PCLUB.ADMPT_CLIENTEIB T4 ON
               A.ADMPV_COD_CLI = T4.ADMPV_COD_CLI
               WHERE A.ADMPV_ERROR IS NULL
               AND T3.ADMPV_COD_TPOCL='3' AND
               T3.ADMPC_ESTADO='A'
               --A.ADMPD_FEC_ULTREC>=T3.ADMPD_FEC_REG
               AND A.ADMPD_FEC_OPER=K_FECHA
               AND A.ADMPV_CATEGORIA= K_NUME_PROCES;


           LOOP
              FETCH C_PUNTOS INTO V_ADMPN_COD_CLI_IB,V_ADMPV_COD_CLI,V_PUNTOS, V_MONTO, V_FECULTREC;
              EXIT WHEN C_PUNTOS%NOTFOUND;

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
                        ADMPN_COD_CLI_IB,
                        ADMPV_COD_CLI,
                        ADMPV_COD_CPTO,
                        ADMPD_FEC_TRANS,
                        ADMPN_PUNTOS,
                        ADMPC_TPO_OPER,
                        ADMPC_TPO_PUNTO,
                        ADMPN_SLD_PUNTO,
                        ADMPC_ESTADO)
                     VALUES
                       (PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,
                        V_ADMPN_COD_CLI_IB,
                        V_ADMPV_COD_CLI,
                        V_COD_CPTO,
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
                             PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,
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
                  -- ERROR MARCARLO

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

              COMMIT;

           END LOOP;
           CLOSE C_PUNTOS;



    SELECT
         COUNT(1) INTO V_NUMREGTOT
         FROM PCLUB.ADMPT_TMP_PRERECARGA T1
         WHERE T1.ADMPD_FEC_OPER=K_FECHA AND
         T1.ADMPV_CATEGORIA=K_NUME_PROCES;

    SELECT
         COUNT(1) INTO V_NUMREGPRO
         FROM PCLUB.ADMPT_TMP_PRERECARGA T1
         WHERE T1.ADMPD_FEC_OPER=K_FECHA AND
         T1.ADMPV_CATEGORIA=K_NUME_PROCES
         AND T1.ADMPV_ERROR IS NOT NULL;

    K_NUMREGTOT := V_NUMREGTOT;
    K_NUMREGERR := V_NUMREGPRO + V_C_ERROR;
    K_NUMREGPRO := V_NUMREGTOT - K_NUMREGERR;

    --ELIMINAMOS LOS REGISTROS DE LAS TABLAS TEMPORALES
    DELETE PCLUB.ADMPT_TMP_PRERECARGA
    WHERE ADMPD_FEC_OPER = K_FECHA
	  AND ADMPV_CATEGORIA = K_NUME_PROCES;
    COMMIT;


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

  END ADMPSI_PRERECAR;



procedure ADMPSS_EPRERECAR(K_FECHA       IN DATE,
                             CURSOREPREREC out SYS_REFCURSOR) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_EPRERECAR
    -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Prepago Recarga
    -- Input               :  K_FECHA
    -- Output              :  CURSOREPREREC
    -- Creado por          :  Maomed Chocce
    -- Fec Creación        :  17/11/2010
    -- Fec Actualización   :
    --****************************************************************
  BEGIN

    OPEN CURSOREPREREC FOR

      SELECT TRIM(ADMPV_COD_CLI),
             ADMPD_FEC_ULTREC,
             ADMPN_MONTO,
             ADMPD_FEC_OPER,
             TRIM(ADMPV_MSJE_ERROR)
        FROM PCLUB.ADMPT_IMP_PRERECARGA
        WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR Is Not Null
        ORDER BY ADMPN_ID_FILA ASC;

  END ADMPSS_EPRERECAR;


procedure ADMPSI_PRERECAR_VALID(K_FECHA IN DATE,
                                 K_NUME_PROCES IN  NUMBER,
                                 K_PARAMETRO NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2)IS
BEGIN
K_CODERROR:=1;
K_DESCERROR:='';

 --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO
   UPDATE ADMPT_TMP_PRERECARGA SET
      ADMPV_ERROR = 1,
      ADMPV_MSJE_ERROR = 'Número de Teléfono es un dato obligatorio.'
    WHERE
      ADMPD_FEC_OPER=K_FECHA
      AND ADMPV_CATEGORIA = K_NUME_PROCES
      AND ((ADMPV_COD_CLI IS NULL) OR (REPLACE(ADMPV_COD_CLI, ' ', '') IS NULL));

    --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO EN LA TABLA ADMPT_CLIENTE
    UPDATE (
    SELECT T.* FROM ADMPT_TMP_PRERECARGA T LEFT JOIN
          ADMPT_CLIENTE T2 ON T2.ADMPV_COD_CLI = T.ADMPV_COD_CLI AND T2.ADMPV_COD_TPOCL='3'
          AND T2.ADMPC_ESTADO='A'
          WHERE
           ADMPD_FEC_OPER=K_FECHA
           AND ADMPV_CATEGORIA = K_NUME_PROCES
           AND T2.ADMPV_COD_CLI IS NULL
           AND ((T.ADMPV_COD_CLI IS NOT NULL) OR (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
    ) SET ADMPV_ERROR = 2,
    ADMPV_MSJE_ERROR = 'Cliente no existe o se encuentra en baja.';

    --SE LE ASIGNA EL ERROR SI EL NUMERO TELEFONICO ESTA DE BAJA
    UPDATE (
    SELECT T.* FROM ADMPT_TMP_PRERECARGA T
          INNER JOIN ADMPT_CLIENTE C ON C.ADMPV_COD_CLI = T.ADMPV_COD_CLI
          AND C.ADMPC_ESTADO='B' AND C.ADMPV_COD_TPOCL='3'
          WHERE
           ADMPD_FEC_OPER=K_FECHA
          AND ADMPV_CATEGORIA = K_NUME_PROCES
          AND ((T.ADMPV_COD_CLI IS NOT NULL) OR (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
    )SET ADMPV_ERROR = 3,
    ADMPV_MSJE_ERROR = 'El Cliente se encuentra de Baja, no se le entregará puntos.';


    --SE LE ASIGNA EL ERROR SI EL MONTO EN EL CURSOR ES MENOR A 0
    UPDATE ADMPT_TMP_PRERECARGA SET
      ADMPV_ERROR = 4,
      ADMPV_MSJE_ERROR = 'Monto de Recarga debe ser mayor que ' || TO_CHAR(K_PARAMETRO)
    WHERE
      ADMPD_FEC_OPER=K_FECHA
      AND ADMPV_CATEGORIA = K_NUME_PROCES
      AND (ADMPN_MONTO < K_PARAMETRO);

    --SI LA FECHA DE LA ULTIMA RECARGA ES MENOR A LA FECHA DE REGISTRO EN CLAROCLUB NO DEBE ENTREGAR PUNTOS

    UPDATE (
    SELECT T.* FROM ADMPT_TMP_PRERECARGA T INNER JOIN
          ADMPT_CLIENTE T2 ON T2.ADMPV_COD_CLI = T.ADMPV_COD_CLI AND T2.ADMPV_COD_TPOCL='3'
          AND T2.ADMPC_ESTADO='A' AND  T.ADMPD_FEC_ULTREC<T2.ADMPD_FEC_REG
          WHERE
           ADMPD_FEC_OPER=K_FECHA
           AND ADMPV_CATEGORIA = K_NUME_PROCES
    ) SET ADMPV_ERROR = 5,
    ADMPV_MSJE_ERROR = 'La fecha de la última recarga es menor a la fecha de registro CC';

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;



END ADMPSI_PRERECAR_VALID;

procedure ADMPSI_PREACTIV(K_CODCLI    IN VARCHAR2,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREACTIV
  -- Propósito           :  Devuelve en el cogigo y el mensaje de error, y asigna puntos por activacion, proceso de Puntos por Activacion Prepago
  -- Input               :  K_CODCLI
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  19/11/2010
  -- Fec Actualización   :
  --****************************************************************

    NO_CONCEPTO EXCEPTION;
    NO_PARAMETRO EXCEPTION;

    V_COD_CPTO VARCHAR2(2);
    V_COUNT    NUMBER;
    V_EST_ERR  NUMBER;
    V_ERROR    VARCHAR2(10);
    V_PUNTOS   VARCHAR2(10);
    V_COUNT_IB NUMBER;
    V_COD_CLI_IB NUMBER;

  BEGIN

    V_PUNTOS  := 0;
    V_EST_ERR := 0;

    BEGIN
    -- Obtener los puntos que corresponden por activacion
    SELECT NVL(ADMPV_VALOR, 0)
      INTO V_PUNTOS
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE ADMPV_DESC LIKE '%PUNTOS_ACTIVACION_PREPAGO%';
    EXCEPTION
     WHEN NO_DATA_FOUND THEN V_PUNTOS:=NULL;
    END;

    BEGIN
     -- Obtener el codigo por concepto
     SELECT ADMPV_COD_CPTO
      INTO V_COD_CPTO
      FROM PCLUB.ADMPT_CONCEPTO C
     WHERE C.ADMPV_DESC LIKE '%ACTIVACION PREPAGO%' AND C.ADMPC_ESTADO='A';
    EXCEPTION
     WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
    END;

    IF V_PUNTOS IS NULL THEN
       RAISE NO_PARAMETRO;
    END IF;

    IF V_COD_CPTO IS NULL THEN
       RAISE NO_CONCEPTO;
    END IF;

    IF (K_CODCLI IS NOT NULL) OR (REPLACE(K_CODCLI, ' ', '') IS NOT NULL) THEN

      SELECT COUNT(1)
      INTO V_COUNT
      FROM PCLUB.ADMPT_CLIENTE
      WHERE ADMPV_COD_CLI = K_CODCLI
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A';

      IF V_COUNT = 0 THEN
        --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO EN LA TABLA ADMPT_CLIENTE
        V_ERROR   := 'Cliente no existe.';
        V_EST_ERR := 1;
      ELSE
        V_ERROR   := '';
        V_EST_ERR := 0;
      END IF;
    ELSE
      --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO EN EL CURSOR
      V_ERROR   := 'Número de Teléfono es un dato obligatorio.';
      V_EST_ERR := 1;
    END IF;

    IF V_EST_ERR = 1 THEN
      --SI EXISTE ERROR SE PROCEDE A INSERTA EN LA TABLA ADMPT_IMP_PREACTIV
      INSERT INTO PCLUB.ADMPT_IMP_PREACTIV
        (ADMPN_ID_FILA, ADMPV_COD_CLI, ADMPD_FEC_OPER, ADMPV_MSJE_ERROR)
      VALUES
        (PCLUB.ADMPT_PREACTIV_SQ.NEXTVAL,
         K_CODCLI,
         to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
         V_ERROR);

  COMMIT;

    ELSE
      --SI NO EXISTE ERROR SE PROCEDE A INSERTAR O MODIFICAR EN LAS TABLAS ADMPT_KARDEX Y ADMPT_SALDOS_CLIENTE
      SELECT COUNT(1)
        INTO V_COUNT
        FROM PCLUB.ADMPT_KARDEX
       WHERE ADMPV_COD_CLI = K_CODCLI
         AND ADMPV_COD_CPTO = V_COD_CPTO;

      IF V_COUNT = 0 THEN

        SELECT COUNT(1) INTO V_COUNT_IB
        FROM PCLUB.ADMPT_CLIENTEIB I
        WHERE ADMPV_COD_CLI=K_CODCLI AND I.ADMPC_ESTADO='A';

        IF V_COUNT_IB = 0 THEN
                --SI NO EXISTE EL PUNTAJE POR ACTIVACION EN KARDEX DEL CLIENTE SE PROCEDE A INSERTAR
                INSERT INTO PCLUB.ADMPT_KARDEX
                  (ADMPN_ID_KARDEX,
                   ADMPV_COD_CLI,
                   ADMPV_COD_CPTO,
                   ADMPD_FEC_TRANS,
                   ADMPN_PUNTOS,
                   ADMPC_TPO_OPER,
                   ADMPC_TPO_PUNTO,
                   ADMPN_SLD_PUNTO,
                   ADMPC_ESTADO)
                VALUES
                  (PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,
                   K_CODCLI,
                   V_COD_CPTO,
                   to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
                   V_PUNTOS,
                   'E',
                   'C',
                   V_PUNTOS,
                   'A');

        COMMIT;

                SELECT COUNT(1)
                  INTO V_COUNT
                  FROM PCLUB.ADMPT_SALDOS_CLIENTE
                 WHERE ADMPV_COD_CLI = K_CODCLI;

                IF V_COUNT = 0 THEN

                  --SI EL CODIGO DEL CLIENTE NO EXISTE EN SALDOS, SE LLEGA A INSERTAR
                  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                    (ADMPN_ID_SALDO,
                     ADMPV_COD_CLI,
                     ADMPN_SALDO_CC,
                     ADMPC_ESTPTO_CC
                     )
                  VALUES
                    (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL, K_CODCLI, V_PUNTOS, 'A');

          COMMIT;

                ELSE
                  --SI EL CODIGO DEL CLIENTE EXISTE EN SALDOS, SE LLEGA A MODIFICAR

          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                     SET S.ADMPC_ESTPTO_CC = 'A',
                     S.ADMPN_SALDO_CC = V_PUNTOS + NVL(S.ADMPN_SALDO_CC, 0)
                    WHERE S.ADMPV_COD_CLI = K_CODCLI;

                END IF;
        ELSE


                SELECT I.ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
                FROM ADMPT_CLIENTEIB I
                WHERE I.ADMPV_COD_CLI=K_CODCLI AND I.ADMPC_ESTADO='A';

                --SI NO EXISTE EL PUNTAJE POR ACTIVACION EN KARDEX DEL CLIENTE SE PROCEDE A INSERTAR
                INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,
                   ADMPN_COD_CLI_IB,
                   ADMPV_COD_CLI,
                   ADMPV_COD_CPTO,
                   ADMPD_FEC_TRANS,
                   ADMPN_PUNTOS,
                   ADMPC_TPO_OPER,
                   ADMPC_TPO_PUNTO,
                   ADMPN_SLD_PUNTO,
                   ADMPC_ESTADO)
                VALUES
                  (PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,
                   V_COD_CLI_IB,
                   K_CODCLI,
                   V_COD_CPTO,
                   to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
                   V_PUNTOS,
                   'E',
                   'C',
                   V_PUNTOS,
                   'A');

        COMMIT;

                SELECT COUNT(*)
                  INTO V_COUNT
                  FROM PCLUB.ADMPT_SALDOS_CLIENTE
                 WHERE ADMPV_COD_CLI = K_CODCLI;

                IF V_COUNT = 0 THEN

                  --SI EL CODIGO DEL CLIENTE NO EXISTE EN SALDOS, SE LLEGA A INSERTAR
                  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,
                     ADMPN_COD_CLI_IB,
                     ADMPV_COD_CLI,
                     ADMPN_SALDO_CC,
                     ADMPC_ESTPTO_CC)
                  VALUES
                    (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,V_COD_CLI_IB,K_CODCLI, V_PUNTOS, 'A');

                ELSE
                  --SI EL CODIGO DEL CLIENTE EXISTE EN SALDOS, SE LLEGA A MODIFICAR

        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                     SET S.ADMPC_ESTPTO_CC = 'A',
                     S.ADMPN_SALDO_CC = V_PUNTOS + NVL(S.ADMPN_SALDO_CC, 0)
                WHERE S.ADMPV_COD_CLI = K_CODCLI;

      COMMIT;

                END IF;
        END IF;
      END IF;
    END IF;
    COMMIT;

    K_CODERROR  := '0';
    K_DESCERROR := ' ';

  EXCEPTION

    WHEN NO_PARAMETRO THEN
      K_CODERROR  := 56;
      K_DESCERROR := 'No se tiene registrado el parametro de PUNTOS_ACTIVACION_PREPAGO (ADMPT_PARAMSIST).';
      ROLLBACK;

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado el parametro de ACTIVACION PREPAGO (ADMPT_CONCEPTO).';
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSI_PREACTIV;

  procedure ADMPSS_EPREACTIV(K_FECHA DATE,CURSOREPREACTIV out SYS_REFCURSOR) IS
  --****************************************************************
  -- Nombre SP           :  ADMPSS_EPREACTIV
  -- Propósito           :  Devuelve en un cursor con los registros con errores encontrados en el proceso de Puntos por Activacion Prepago
  -- Input               :  K_FECHA
  -- Output              :  CURSOREPREACTIV
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  19/11/2010
  -- Fec Actualización   :
  --****************************************************************

  BEGIN

    OPEN CURSOREPREACTIV FOR
      SELECT TRIM(ADMPV_COD_CLI), ADMPV_MSJE_ERROR
        FROM PCLUB.ADMPT_IMP_PREACTIV
       WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR IS NOT NULL
       ORDER BY ADMPN_ID_FILA ASC;

  END ADMPSS_EPREACTIV;

      procedure ADMPSI_PREALTACLI(K_FECHA IN DATE,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREALTACLI
  -- Propósito           :  Devuelve en el cogigo y el mensaje de error, y asigna puntos por activaron o dieron de Alta
  -- Input               :  K_FECHA
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  25/11/2010
  -- Fec Actualización   :
  --****************************************************************


  CURSOR CURSORCLIENTE IS
  SELECT TRIM(ADMPV_COD_CLI),TRIM(ADMPV_TIPO_DOC),TRIM(ADMPV_NUM_DOC)
  FROM PCLUB.ADMPT_CLIENTE CC
  WHERE ADMPD_FEC_ACTIV = trunc(K_FECHA)
  AND ADMPV_COD_TPOCL='3'
  AND ADMPC_ESTADO='A'
  AND NOT EXISTS
  (
    SELECT I.PHONE
    FROM TABLE_INTERACT@DBL_CLARIFY I
    INNER JOIN TABLE_X_PLUS_INTER@DBL_CLARIFY C
    ON I.OBJID = C.X_PLUS_INTER2INTERACT
    WHERE I.S_REASON_1='PREPAGO'
    AND I.S_REASON_2='VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
    AND I.S_REASON_3='CAMBIO TIT / USUARIO / REP. LEGAL'
    AND I.CREATE_DATE >= K_FECHA
    AND I.CREATE_DATE < K_FECHA
    AND I.PHONE = CC.ADMPV_COD_CLI
  );

  C_COD_CLI VARCHAR2(40);
  C_TIPO_DOC VARCHAR2(20);
  C_NUM_DOC VARCHAR2(20);


  V_COD_CLI_IB NUMBER;
  V_COUNT_IB NUMBER;
  V_COUNT NUMBER;

  V_NUMREGPRO NUMBER;
  V_NUMREGERR NUMBER;

  BEGIN

  V_NUMREGERR:=0;
  V_NUMREGPRO:=0;
  K_NUMREGTOT:=0;

  OPEN CURSORCLIENTE;
  LOOP
  FETCH CURSORCLIENTE
  INTO C_COD_CLI,C_TIPO_DOC,C_NUM_DOC;
  EXIT WHEN CURSORCLIENTE%NOTFOUND;

    --VERIFICAR SI EL CLIENTE TIENE TARJETA DE CREDITO IB

    SELECT COUNT(*) INTO V_COUNT_IB
    FROM PCLUB.ADMPT_CLIENTEIB I
    WHERE TRIM(I.ADMPV_TIPO_DOC)=C_TIPO_DOC
    AND I.ADMPV_NUM_DOC=C_NUM_DOC
    AND ((I.ADMPV_COD_CLI IS NULL) OR (REPLACE(I.ADMPV_COD_CLI,' ','') IS NULL))
    AND I.ADMPC_ESTADO = 'A';

    IF V_COUNT_IB > 0 THEN

        IF V_COUNT_IB > 1 THEN

           K_CODERROR:=-1;
           GOTO VALIDACODERROR;

        END IF;

        --SE PROCEDE A ASOCIAR EL CLIENTE IB CON EL CLIENTE PREPAGO
        SELECT I.ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
        FROM PCLUB.ADMPT_CLIENTEIB I
        WHERE TRIM(I.ADMPV_TIPO_DOC)=C_TIPO_DOC
        AND I.ADMPV_NUM_DOC=C_NUM_DOC
        AND ((I.ADMPV_COD_CLI IS NULL) OR (REPLACE(I.ADMPV_COD_CLI,' ','') IS NULL)) AND I.ADMPC_ESTADO='A';

        UPDATE PCLUB.ADMPT_CLIENTEIB
        SET ADMPV_COD_CLI=C_COD_CLI,
        ADMPV_NUM_LINEA=SUBSTR(C_COD_CLI,LENGTH(C_COD_CLI)-8,9)
        WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB;

        UPDATE PCLUB.ADMPT_KARDEX
        SET ADMPV_COD_CLI=C_COD_CLI
        WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB
        AND ADMPV_COD_CLI IS NULL;

        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
        SET ADMPV_COD_CLI = C_COD_CLI
        WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB
        AND ADMPV_COD_CLI IS NULL;
        --AND ADMPC_ESTPTO_IB='A';

    ELSE
        --EN CASO NO TENGA TARJETA IB EL CLIENTE PREPAGO, SE INSERTAR UN REGISTRO EN SALDO
        SELECT COUNT(*) INTO V_COUNT
        FROM PCLUB.ADMPT_SALDOS_CLIENTE
        WHERE ADMPV_COD_CLI=C_COD_CLI;

        IF V_COUNT = 0 THEN

           SELECT COUNT(1) INTO V_COUNT
           FROM PCLUB.ADMPT_CLIENTEIB I
           WHERE TRIM(I.ADMPV_TIPO_DOC)=C_TIPO_DOC
           AND I.ADMPV_NUM_DOC=C_NUM_DOC
           AND I.ADMPV_COD_CLI=C_COD_CLI AND I.ADMPC_ESTADO='A';

           IF V_COUNT = 0 THEN

              INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_SALDO_CC,
              ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
              VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,C_COD_CLI,0,0,'A');

           ELSE

              SELECT I.ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
              FROM PCLUB.ADMPT_CLIENTEIB I
              WHERE TRIM(I.ADMPV_TIPO_DOC)=C_TIPO_DOC
              AND I.ADMPV_NUM_DOC=C_NUM_DOC
              AND I.ADMPV_COD_CLI=C_COD_CLI AND I.ADMPC_ESTADO='A';

              INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,
              ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
              VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,C_COD_CLI,V_COD_CLI_IB,0,0,'A');

          END IF;
        END IF;

    END IF;

    --SE LE OTORGA LOS PUNTOS POR ACTIVACION
    PCLUB.PKG_CC_PREPAGO.ADMPSI_PREACTIV(C_COD_CLI,K_CODERROR,K_DESCERROR);

    <<VALIDACODERROR>>
    IF K_CODERROR = 0 THEN
      V_NUMREGPRO:=V_NUMREGPRO+1;
    ELSE
       V_NUMREGERR:=V_NUMREGERR+1;
    END IF;

    COMMIT;
    END LOOP;
    CLOSE CURSORCLIENTE;

  K_NUMREGTOT:=V_NUMREGERR+V_NUMREGPRO;
  K_NUMREGPRO:=V_NUMREGPRO;
  K_NUMREGERR:=V_NUMREGERR;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSI_PREALTACLI;

  procedure ADMPSI_REGCLIENTECC(K_NUMTELF IN VARCHAR2,K_TIPDOC IN VARCHAR2, K_NUMDOC IN VARCHAR2, K_NOMBRE IN VARCHAR2, K_APELLIDO IN VARCHAR2, K_SEXO IN VARCHAR2, K_ESTCIV IN VARCHAR2, K_EMAIL IN VARCHAR2, K_PROV IN VARCHAR2, K_DEPART IN VARCHAR2, K_DIST IN VARCHAR2, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_REGCLIENTECC
  -- Propósito           :  Registrar los clientes Prepago en la BD Claro Club, este SP va ser invocado desde el WS.
  -- Input               :  K_NUMTELF,K_TIPDOC,K_NUMDOC,K_NOMBRE,K_APELLIDO,
  --                        K_SEXO,K_ESTCIV,K_EMAIL,K_PROV,K_DEPART,K_DIST
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  10/12/2010
  -- Fec Actualización   :
  --****************************************************************
  EXISTE_CL EXCEPTION;
  NO_NUMTEL EXCEPTION;

  V_COUNT NUMBER;

  V_SEXO VARCHAR2(2);


  V_MSJE_ERROR VARCHAR2(400);
  EST_ERROR NUMBER;
  BEGIN

  EST_ERROR:=0;

  SELECT COUNT(*) INTO V_COUNT
  FROM PCLUB.ADMPT_CLIENTE
  WHERE ADMPV_COD_CLI=K_NUMTELF
  AND ADMPV_COD_TPOCL='3'
  AND ADMPC_ESTADO='A';

  --VERIFICANDO LA EXISTENCIA DEL CLIENTE
  IF V_COUNT = 1 THEN

     V_MSJE_ERROR:='Cliente existe';

     INSERT INTO PCLUB.ADMPT_IMP_PREALTAC(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TIPO_DOC
     ,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL
     ,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
     VALUES(PCLUB.ADMPT_IMP_PREALTAC_SQ.NEXTVAL,K_NUMTELF,K_TIPDOC,K_NUMDOC,K_NOMBRE,
     K_APELLIDO,K_SEXO,K_ESTCIV,K_EMAIL,K_PROV,K_DEPART,K_DIST,to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
     V_MSJE_ERROR);

     EST_ERROR:=1;
     COMMIT;

     RAISE EXISTE_CL;

  END IF;

  --VERIFICANDO SI ESTA EN BLANCO O NULO EL NUMERO DEL CLIENTE
  IF ((K_NUMTELF IS NULL) OR (REPLACE(K_NUMTELF,' ','') IS NULL)) THEN

     V_MSJE_ERROR:='Número de Teléfono es un dato obligatorio.';

     INSERT INTO PCLUB.ADMPT_IMP_PREALTAC(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TIPO_DOC
     ,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL
     ,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
     VALUES(PCLUB.ADMPT_IMP_PREALTAC_SQ.NEXTVAL,K_NUMTELF,K_TIPDOC,K_NUMDOC,K_NOMBRE,
     K_APELLIDO,K_SEXO,K_ESTCIV,K_EMAIL,K_PROV,K_DEPART,K_DIST,to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
     V_MSJE_ERROR);
     COMMIT;
     EST_ERROR:=1;

     RAISE NO_NUMTEL;
  END IF;

  IF EST_ERROR <>1 THEN

     --TRANSFORMANDO LA VARIABLE SEXO DE ACUERDO A LA TABLA CLIENTE
     IF K_SEXO = 1 THEN
        V_SEXO:='M';
     ELSIF K_SEXO=2 THEN
        V_SEXO:='F';
     ELSE
        V_SEXO:='X';
     END IF;

     INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI
     ,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,
     ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL)
     VALUES(K_NUMTELF,K_TIPDOC,K_NUMDOC,K_NOMBRE,K_APELLIDO,V_SEXO,K_ESTCIV,K_EMAIL,K_PROV,K_DEPART,
     K_DIST,to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),'A','3');

  END IF;
  COMMIT;

  K_CODERROR:=0;
  K_DESCERROR:=' ';

  EXCEPTION
    WHEN EXISTE_CL THEN
         K_CODERROR:=50;
         K_DESCERROR:='Cliente existe.';

    WHEN NO_NUMTEL THEN
         K_CODERROR:=60;
         K_DESCERROR:='Número de Teléfono es un dato obligatorio.';

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSI_REGCLIENTECC;

  procedure ADMPSI_EPREALTACLI(K_FECHA IN DATE, CURSOREPREALTACLI out SYS_REFCURSOR) IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPREALTACLI
  -- Propósito           :  Devuelve en un cursor con los registros con activaciones que no pudieron ser agregadas por algún error controlado
  -- Input               :  K_FECHA
  -- Output              :  CURSOREPREALTACLI
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  22/11/2010
  -- Fec Actualización   :
  --****************************************************************

  BEGIN

  OPEN CURSOREPREALTACLI FOR
      SELECT TRIM(ADMPV_COD_CLI), TRIM(ADMPV_TIPO_DOC),
      TRIM(ADMPV_NUM_DOC), TRIM(ADMPV_NOM_CLI), TRIM(ADMPV_APE_CLI), TRIM(ADMPC_SEXO),
      TRIM(ADMPV_EST_CIVIL), TRIM(ADMPV_EMAIL), TRIM(ADMPV_PROV), TRIM(ADMPV_DEPA),
      TRIM(ADMPV_DIST), ADMPD_FEC_ACTIV, TRIM(ADMPV_MSJE_ERROR)
        FROM PCLUB.ADMPT_IMP_PREALTAC
       WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR IS NOT NULL
       ORDER BY ADMPN_ID_FILA ASC;

  END ADMPSI_EPREALTACLI;

PROCEDURE ADMPSI_PRECMBTIT(K_FEC_PRO IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_TOT_REG OUT NUMBER, K_TOT_PRO OUT NUMBER, K_TOT_ERR OUT NUMBER) is
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PRECMBTIT
  -- Propósito           :  Proceso de cambio de Titular de Cuentas Prepago
  --
  -- Input               :  K_FEC_PRO Fecha de Proceso
  --
  -- Output              :  K_CODERROR Codigo de Error o Exito
  --                        K_DESCERROR Descripcion del Error (si se presento)
  --                        K_TOT_REG Total de Registros
  --                        K_TOT_PRO Total de Procesados
  --                        K_TOT_ERR Total de Errados
  --
  -- Creado por          :  Stiven Saavedra C.
  -- Fec Creacion        :  22/11/2010
  -- Fec Actualizacion   :  02/02/2011
  --****************************************************************
  K_USUARIO CONSTANT CHAR(10) := 'USRCAMBTIT';
  TYPE CURCLARO_CAMBIOTITULAR IS REF CURSOR;
  C_CUR_CMBTITULAR CURCLARO_CAMBIOTITULAR;

  C_CODCLIENTE   VARCHAR2(40);
  C_CLIENTE_IB   NUMBER;
  V_SALDO_CLI    NUMBER;
  V_SALDO_CLI_IB NUMBER;
  V_CODCONCEPTO  VARCHAR2(3);
  V_CODCONCEPTO_B  VARCHAR2(3);
  V_IDKARDEX     NUMBER;
  V_IDSALDO      NUMBER;
  V_COD_NUEVO    NUMBER;
  V_REG          NUMBER;
  V_AUX          NUMBER;
  V_COD_CLINUE   VARCHAR(40);
  V_COD_SALDO    VARCHAR(40);
  C_TIPODOC      VARCHAR2(20);
  C_NUMDOC       VARCHAR2(20);
  C_NOMCLI       VARCHAR2(80);
  C_APECLI       VARCHAR2(80);
  C_SEXO         VARCHAR2(1);
  C_EST_CIVIL    VARCHAR2(20);
  C_EMAIL        VARCHAR2(80);
  C_PROV         VARCHAR2(30);
  C_DEPA         VARCHAR2(40);
  C_DIST         VARCHAR2(200);
  C_FECCMB       DATE;
  V_IDIMPCMB     NUMBER;

 /*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  K_TIPODOC VARCHAR2(20);
  K_NUMDOC VARCHAR2(20);
  /*CUPONERAVIRTUAL - JCGT FIN*/
  V_SALDO_BONO   NUMBER;
BEGIN
  BEGIN
    -- Obtenemos el codigo del Concepto
    SELECT NVL(ADMPV_COD_CPTO, NULL)
      INTO V_CODCONCEPTO
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE UPPER(ADMPV_DESC) LIKE '%CAMBIO TITULAR PREPAGO%';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_CODCONCEPTO := null;
  END;

  BEGIN
    -- Obtenemos el codigo del Concepto para bono
    SELECT NVL(ADMPV_COD_CPTO, NULL)
      INTO V_CODCONCEPTO_B
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) = 'BAJA CLIENTE CAMBIO TITULARIDAD - BONO';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_CODCONCEPTO_B := NULL;
  END;

  K_TOT_PRO := 0;
  K_TOT_ERR := 0;
  K_TOT_REG := 0;

  PKG_CC_PREPAGO.CamTituCC(K_FEC_PRO,C_CUR_CMBTITULAR);

  BEGIN
    FETCH C_CUR_CMBTITULAR INTO C_CODCLIENTE, C_NOMCLI, C_APECLI, C_TIPODOC, C_NUMDOC,
    C_SEXO, C_EST_CIVIL,C_EMAIL,C_PROV,C_DEPA,C_DIST,C_FECCMB;

    IF (C_CUR_CMBTITULAR%rowcount = 0) THEN
      K_TOT_REG := C_CUR_CMBTITULAR%rowcount;
    ELSE

      WHILE C_CUR_CMBTITULAR%FOUND LOOP
        -- Obtenemos el total de registros
        K_TOT_REG := K_TOT_REG + 1;

          -- Realizamos las validaciones necesarias
          -- Verificamos si el Codigo de Cliente existe
          V_AUX := 0;
          BEGIN
            SELECT COUNT(1) INTO V_AUX
            FROM PCLUB.ADMPT_CLIENTE
            WHERE ADMPV_COD_CLI = C_CODCLIENTE;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_AUX := 0;
          END;

          IF V_AUX = 0 THEN
            K_TOT_ERR := K_TOT_ERR + 1;

            SELECT PCLUB.ADMPT_PRECMBTIT_SQ.NEXTVAL
              INTO V_IDIMPCMB
              FROM DUAL;

            INSERT INTO PCLUB.ADMPT_IMP_PRECMBTIT(ADMPN_ID_FILA, ADMPV_COD_CLI,
            ADMPV_TIPO_DOC, ADMPV_NUM_DOC, ADMPV_NOM_CLI, ADMPV_APE_CLI, ADMPC_SEXO,
            ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACTIV,
            ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
            VALUES (V_IDIMPCMB, C_CODCLIENTE, C_TIPODOC, C_NUMDOC, C_NOMCLI, C_APECLI,
                    C_SEXO,C_EST_CIVIL,C_EMAIL,C_PROV,C_DEPA,C_DIST,C_FECCMB, TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
                    'El Codigo de Cliente NO existe. No se puede cambiar el titular.');
            COMMIT;

          ELSE
            K_TOT_PRO := K_TOT_PRO + 1;

          -- Primero operamos con el cliente que se cambia de titular (origen) ----
            -- Obtenemos el saldo de la cuenta que cambia de titular
            BEGIN
              V_SALDO_CLI := 0.00;
              SELECT NVL(SUM(ADMPN_SLD_PUNTO),0) INTO V_SALDO_CLI
             FROM PCLUB.ADMPT_KARDEX
            WHERE ADMPV_COD_CLI = C_CODCLIENTE
                  AND ADMPC_TPO_OPER = 'E'
                  AND ADMPC_TPO_PUNTO = 'C'
                  AND ADMPN_SLD_PUNTO > 0
                  AND ADMPC_ESTADO='A';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_CLI := 0;
            END;

            -- Insertamos en el Kardex el movimiento sólo si el saldo es mayor que 0
            IF V_SALDO_CLI > 0 THEN
              SELECT PCLUB.admpt_kardex_sq.NEXTVAL
                INTO V_IDKARDEX
                FROM DUAL;

              INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI, ADMPV_COD_CPTO, ADMPD_FEC_TRANS, ADMPN_PUNTOS,
                 ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, ADMPV_USU_REG)
              VALUES
                (V_IDKARDEX, NULL, C_CODCLIENTE, V_CODCONCEPTO, TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'), V_SALDO_CLI * -1,
                 '', 'S', 'C', 0, 'B', K_USUARIO);
            END IF;

          -- Verificamos el saldo por bono
          BEGIN

           SELECT NVL(SUM(ADMPN_SLD_PUNTO),0) INTO V_SALDO_BONO
             FROM PCLUB.ADMPT_KARDEX
            WHERE ADMPV_COD_CLI = C_CODCLIENTE
                  AND ADMPC_TPO_OPER = 'E'
                  AND ADMPC_TPO_PUNTO = 'B'
                  AND ADMPN_SLD_PUNTO > 0
                  AND ADMPC_ESTADO='A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDO_BONO := 0;
          END;

          IF V_SALDO_BONO > 0 THEN
            INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                      ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
                                      ADMPN_PUNTOS, ADMPV_NOM_ARCH, ADMPC_TPO_OPER,
                                      ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, ADMPV_USU_REG)
            VALUES (admpt_kardex_sq.NEXTVAL, NULL, C_CODCLIENTE,
                    V_CODCONCEPTO_B, TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
                    (V_SALDO_BONO * (-1)), '', 'S',
                    'B', 0, 'B', K_USUARIO);

            -- Actualizamos todos los movimientos de ingreso con 0
            UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPN_SLD_PUNTO = 0,
                ADMPC_ESTADO = 'B',
                ADMPV_USU_MOD = K_USUARIO
            WHERE ADMPV_COD_CLI = C_CODCLIENTE
                  AND ADMPC_TPO_OPER = 'E'
                  AND ADMPC_TPO_PUNTO = 'B'
                  AND ADMPN_SLD_PUNTO > 0
                  AND ADMPC_ESTADO='A';
          END IF;

            -- Verificamos si el cliente tambien es Cliente IB
            BEGIN
              C_CLIENTE_IB := NULL;

              SELECT ADMPN_COD_CLI_IB
                INTO C_CLIENTE_IB
                FROM PCLUB.ADMPT_CLIENTEIB
               WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                C_CLIENTE_IB := NULL;
            END;

            IF C_CLIENTE_IB IS NOT NULL THEN
              BEGIN
                -- Obtenemos el saldo de la cuenta que cambia de titular
                BEGIN
                  V_SALDO_CLI_IB := 0.00;
                  SELECT ADMPN_SALDO_IB
                    INTO V_SALDO_CLI_IB
                    FROM PCLUB.ADMPT_SALDOS_CLIENTE
                   WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_SALDO_CLI_IB := 0;
                END;

                -- Actualizamos la tabla de ClienteIB
                UPDATE PCLUB.ADMPT_CLIENTEIB
                   SET ADMPV_COD_CLI = NULL, ADMPV_NUM_LINEA = NULL
                 WHERE ADMPN_COD_CLI_IB = C_CLIENTE_IB;

                -- Insertamos el registro de saldos en la tabla correspondiente
                SELECT PCLUB.admpt_sld_cl_sq.nextval
                  INTO V_IDSALDO
                  FROM DUAL;

                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE (admpn_id_saldo, admpv_cod_cli, admpn_cod_cli_ib, admpn_saldo_cc, admpn_saldo_ib,
                   admpc_estpto_cc, admpc_estpto_ib)
                VALUES
                  (V_IDSALDO, NULL, C_CLIENTE_IB, 0.00, V_SALDO_CLI_IB, NULL, 'A');

                -- Actualizamos todos los movimientos de ingreso con 0
                UPDATE PCLUB.ADMPT_KARDEX
                   SET ADMPV_COD_CLI = NULL,
                     ADMPV_USU_MOD = K_USUARIO
                 WHERE ADMPN_COD_CLI_IB = C_CLIENTE_IB
                   AND ADMPC_TPO_OPER = 'E'
                   AND ADMPC_TPO_PUNTO = 'I'
                   AND ADMPN_SLD_PUNTO > 0;

                -- Actualizamos el cliente con nulo en el cliente Claro
                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                   SET S.ADMPN_COD_CLI_IB = NULL, S.ADMPN_SALDO_IB = 0, s.admpc_estpto_ib='B'
                 WHERE ADMPV_COD_CLI = C_CODCLIENTE;

              END;
            END IF;

            -- Actualizamos todos los movimientos de ingreso con 0
            UPDATE PCLUB.ADMPT_KARDEX
               SET ADMPN_SLD_PUNTO = 0,
                 ADMPC_ESTADO = 'B',
                 ADMPV_USU_MOD = K_USUARIO
             WHERE ADMPV_COD_CLI = C_CODCLIENTE
               AND ADMPC_TPO_OPER = 'E'
               AND ADMPC_TPO_PUNTO = 'C'
               AND ADMPN_SLD_PUNTO > 0;

            -- Ahora obtenemos el nuevo código del cliente origen
            V_COD_NUEVO  := 1;
            V_COD_CLINUE := '';

            WHILE V_COD_NUEVO > 0 LOOP
              V_COD_CLINUE := TRIM(C_CODCLIENTE) || '-' || TO_CHAR(V_COD_NUEVO);

              V_REG := 0;

              BEGIN
                SELECT COUNT(1)
                  INTO V_REG
                  FROM PCLUB.ADMPT_CLIENTE
                 WHERE ADMPV_COD_CLI = V_COD_CLINUE;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_REG := 0;
              END;

              IF V_REG > 0 THEN
                V_COD_NUEVO := V_COD_NUEVO + 1;
              ELSE
                V_COD_NUEVO := 0;
              END IF;
            END LOOP;

            -- Debido a la FK primero se debe insertar el registro
            INSERT INTO PCLUB.ADMPT_CLIENTE (ADMPV_COD_CLI)
                 VALUES ('999999999999999999999');

            UPDATE PCLUB.ADMPT_CANJE
               SET ADMPV_COD_CLI = '999999999999999999999'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            -- Ahora actualizamos los movimientos, saldos y código de cliente con el código obtenido
            UPDATE PCLUB.ADMPT_KARDEX
               SET ADMPV_COD_CLI = V_COD_CLINUE,
                 ADMPV_USU_MOD = K_USUARIO
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
               SET ADMPV_COD_CLI = V_COD_CLINUE, ADMPN_SALDO_CC = 0,ADMPC_ESTPTO_CC='B'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

          UPDATE PCLUB.ADMPT_SALDOS_BONO_CLIENTE
          SET ADMPV_COD_CLI = V_COD_CLINUE,
              ADMPN_SALDO = 0,
              ADMPV_ESTADO = 'B',
              ADMPV_USU_MOD = K_USUARIO
          WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_CLIENTE
               SET ADMPV_COD_CLI = V_COD_CLINUE, ADMPC_ESTADO = 'B'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_CANJE
               SET ADMPV_COD_CLI = V_COD_CLINUE,
                   ADMPV_USU_MOD = K_USUARIO
             WHERE ADMPV_COD_CLI = '999999999999999999999';

            DELETE FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = '999999999999999999999';

            BEGIN
              SELECT
               TC.ADMPV_COD_TPDOC INTO C_TIPODOC
              FROM
               PCLUB.ADMPT_TIPO_DOC TC
              WHERE UPPER(TRIM(TC.ADMPV_DSC_DOCUM)) = UPPER(TRIM(C_TIPODOC));
            EXCEPTION
              WHEN OTHERS THEN
                 NULL;
            END;
            ----------------------------------------- Segundo operamos con el cliente que es el nuevo titular (destino) -------------------------------------------
            -- Debemos insertar los clientes en la tabla de Clientes
            INSERT INTO PCLUB.ADMPT_CLIENTE H (H.ADMPV_COD_CLI, H.ADMPV_COD_SEGCLI, H.ADMPN_COD_CATCLI, H.ADMPV_TIPO_DOC, H.ADMPV_NUM_DOC,
                                               H.ADMPV_NOM_CLI, H.ADMPV_APE_CLI, H.ADMPC_SEXO, H.ADMPV_EST_CIVIL, H.ADMPV_EMAIL, H.ADMPV_PROV, H.ADMPV_DEPA,
                                               H.ADMPV_DIST, H.ADMPD_FEC_ACTIV, H.ADMPV_CICL_FACT, H.ADMPC_ESTADO, H.ADMPV_COD_TPOCL)
            VALUES (C_CODCLIENTE, null, '2', C_TIPODOC, C_NUMDOC, C_NOMCLI, C_APECLI, C_SEXO, NULL, NULL, NULL, NULL, NULL,
               TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'), NULL, 'A', '3');

            BEGIN
              SELECT ADMPV_COD_CLI
                INTO V_COD_SALDO
                FROM PCLUB.ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                /**Generar secuencial de Saldo*/
                SELECT PCLUB.admpt_sld_cl_sq.nextval
                  INTO V_IDSALDO
                  FROM DUAL;

                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE (admpn_id_saldo, admpv_cod_cli, admpn_cod_cli_ib, admpn_saldo_cc, admpn_saldo_ib, admpc_estpto_cc, admpc_estpto_ib)
                VALUES (V_IDSALDO, C_CODCLIENTE, NULL, 0.00, 0.00, 'A', NULL);
            END;

            /*CUPONERAVIRTUAL - JCGT INI*/
           PCLUB.PKG_CC_CUPONERA.ADMPSI_CAMBIOTITULAR(K_TIPODOC,K_NUMDOC,C_TIPODOC,C_NUMDOC,C_NOMCLI,C_APECLI,C_EMAIL,'CMBTIT', 'USRPREPAGO',C_CODERROR,C_DESCERROR);
           /*CUPONERAVIRTUAL - JCGT FIN*/

            COMMIT;

          END IF;

    FETCH C_CUR_CMBTITULAR INTO C_CODCLIENTE, C_NOMCLI, C_APECLI, C_TIPODOC, C_NUMDOC,
    C_SEXO, C_EST_CIVIL,C_EMAIL,C_PROV,C_DEPA,C_DIST,C_FECCMB;

      END LOOP;

    END IF;

  END;

  CLOSE C_CUR_CMBTITULAR;
  COMMIT;

  K_CODERROR  := 0;
  K_DESCERROR := '';

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_PRECMBTIT;

PROCEDURE ADMPSI_EPRECMBTIT (K_FEC_PRO IN DATE, CMBTIT_CUR OUT SYS_REFCURSOR)
IS
--****************************************************************
-- Nombre SP           :  ADMPSI_EPRECMBTIT
-- Propósito           :  Proceso que devuelve los errores producidos por el cambio de Titular de Cuentas Prepago
--
-- Input               :  K_FEC_PRO Fecha de Proceso
--
-- Output              :  CMBTIT_CUR Cursor con los errores encontrados en el proceso de cambio de titular
--
-- Creado por          :  Stiven Saavedra C.
-- Fec Creacion        :  22/11/2010
-- Fec Actualizacion   :  14/12/2010
--****************************************************************

BEGIN
       OPEN CMBTIT_CUR FOR
       SELECT ADMPV_COD_CLI, ADMPV_TIPO_DOC, ADMPV_NUM_DOC, ADMPV_NOM_CLI, ADMPV_APE_CLI, ADMPC_SEXO, ADMPV_EST_CIVIL,
              ADMPV_EMAIL, ADMPV_PROV, ADMPV_DEPA, ADMPV_DIST, ADMPD_FEC_ACTIV, ADMPV_MSJE_ERROR
         FROM PCLUB.ADMPT_IMP_PRECMBTIT
        WHERE TO_DATE (ADMPD_FEC_OPER, 'DD/MM/YYYY') = TO_DATE (K_FEC_PRO, 'DD/MM/YYYY') AND ADMPV_MSJE_ERROR IS NOT NULL
       ORDER BY ADMPN_ID_FILA;

END ADMPSI_EPRECMBTIT;

procedure CamTituCC(K_FECHA IN DATE, CURSORCamTituCC out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  CamTituCC
  -- Propósito           :  Devuelve un cursor con la lista de clientes que an cambiado de titular.
  -- Input               :  K_FECHA
  -- Output              :  CURSORCamTituCC
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  02/02/2011
  -- Fec Actualización   :
  --****************************************************************
  BEGIN
  OPEN CURSORCamTituCC FOR

 select I.PHONE,C.X_FIRST_NAME,C.X_LAST_NAME, C.X_TYPE_DOCUMENT, C.X_DOCUMENT_NUMBER,  '' AS x_sex, '' AS x_marital_status,
 '' AS e_mail, '' AS s_city, '' AS x_department, '' AS x_address_3, I.CREATE_DATE
    from table_interact@DBL_CLARIFY i, TABLE_X_PLUS_INTER@DBL_CLARIFY c
    where i.OBJID = c.X_PLUS_INTER2INTERACT
    AND I.S_REASON_1='PREPAGO'
    AND I.S_REASON_2='VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
    AND I.S_REASON_3='CAMBIO TIT / USUARIO / REP. LEGAL'
    and to_char(i.create_date,'DD/MM/YYYY') = to_char(K_FECHA,'DD/MM/YYYY');

  END CamTituCC;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_PRESINREC
-- Propósito           :  Elimina puntos por 12 meses sin recarga.
-- Input               :  K_NOMBARCH  --Nombre del archivo
-- Output              :  K_NUMREGTOT --Total de registros
--                        K_NUMREGVAL --Registros válidos
--                        K_NUMREGERR --Registros errados
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  02/08/2013
  -- Fec Actualización   :
  --****************************************************************
PROCEDURE ADMPSI_PRESINREC(K_NOMARCH IN VARCHAR2,
                           K_USUARIO IN VARCHAR2,
                           K_NUMREGTOT OUT NUMBER,
                           K_NUMREGVAL OUT NUMBER,
                           K_NUMREGERR OUT NUMBER,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2) IS


CURSOR V_CUR_LINEAS(NOMARCH VARCHAR2) IS
SELECT T.ADMPN_SEC,
       T.ADMPV_COD_CLI,
       NVL((SELECT SUM(K.ADMPN_SLD_PUNTO)
            FROM PCLUB.ADMPT_KARDEX K
            WHERE T.ADMPV_COD_CLI = K.ADMPV_COD_CLI
                  AND K.ADMPC_TPO_PUNTO='C' AND K.ADMPC_ESTADO='A'
                  AND K.ADMPC_TPO_OPER='E' AND K.ADMPN_SLD_PUNTO>0),0) AS SALDO_CC,
       NVL((SELECT SUM(K.ADMPN_SLD_PUNTO)
            FROM PCLUB.ADMPT_KARDEX K
            WHERE T.ADMPV_COD_CLI = K.ADMPV_COD_CLI
                  AND K.ADMPC_TPO_PUNTO='B' AND K.ADMPC_ESTADO='A'
                  AND K.ADMPC_TPO_OPER='E' AND K.ADMPN_SLD_PUNTO>0),0) AS SALDO_BONO,
       I.ADMPN_COD_CLI_IB
FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
LEFT JOIN PCLUB.ADMPT_CLIENTEIB I ON T.ADMPV_COD_CLI = I.ADMPV_COD_CLI
                               AND I.ADMPC_ESTADO = 'A'
WHERE T.ADMPV_NOMARCHIVO = NOMARCH
      AND T.ADMPV_CODERROR IS NULL;

 V_COD_CPTO VARCHAR2(2);
 V_CONTADOR NUMBER := 0;
 V_CONTOTAL NUMBER;
 V_CONTREGVAL NUMBER := 0;
 V_NUMREGCOMMIT NUMBER;
 V_NUMREGPROCES NUMBER;
 V_FECHASYS DATE := TRUNC(SYSDATE);
 VC_SEC NUMBER;
 VC_LINEA VARCHAR2(50);
 VC_SALDO NUMBER;
VC_SALDO_BONO NUMBER;
 VC_COD_CLI_IB VARCHAR2(20);
 EX_ERROR EXCEPTION;
 EX_CONCEPTO EXCEPTION;
  BEGIN

  CASE
    WHEN K_NOMARCH IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := ''; K_NUMREGTOT := 0; K_NUMREGVAL := 0; K_NUMREGERR := 0;
  END CASE;

  BEGIN
    SELECT ADMPV_COD_CPTO INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC = 'MESES SIN RECARGA PREPAGO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 9;
      K_DESCERROR := 'ORA: No está registrado el concepto MESES SIN RECARGA PREPAGO.';
      RAISE EX_CONCEPTO;
  END;

  BEGIN
    SELECT ADMPV_VALOR INTO V_NUMREGCOMMIT
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 50;
      K_DESCERROR := 'ORA: No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO.';
      RAISE EX_ERROR;
  END;

  --SE OBTIENE EL TOTAL DE REGISTROS A PROCESAR
  SELECT COUNT(1) INTO K_NUMREGTOT
  FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
  WHERE T.ADMPV_NOMARCHIVO = K_NOMARCH;

  --SE LE ASIGNA EL ERROR SI LA LINEA NO TIENE 9 DIGITOS
  UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA
  SET ADMPV_CODERROR = 1,
      ADMPV_MSJE_ERROR = 'La línea no tiene 9 dígitos.'
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NULL
        AND LENGTH(TRIM(ADMPV_COD_CLI)) <> 9;

  --SE LE ASIGNA EL ERROR SI LA LINEA NO ES NUMERICO
  UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA
  SET ADMPV_CODERROR = 2,
      ADMPV_MSJE_ERROR = 'La línea no es numérica.'
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NULL
        AND LENGTH(TRIM(TRANSLATE(ADMPV_COD_CLI,'0123456789',' '))) > 0;

  --SE LE ASIGNA EL ERROR SI NO EXISTEN DATOS OBLIGATORIOS
  UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA
  SET ADMPV_CODERROR = 3,
      ADMPV_MSJE_ERROR = 'La línea no fue ingresada.'
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NULL
        AND ADMPV_COD_CLI IS NULL;

  --SE VERIFICA LA EXISTENCIA DEL CLIENTE EN LA TABLA ADMPT_CLIENTE
  MERGE INTO ADMPT_TMP_PRESINRECARGA I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
         LEFT JOIN PCLUB.ADMPT_CLIENTE C ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
                                      AND C.ADMPV_COD_TPOCL = '3'
         WHERE T.ADMPV_NOMARCHIVO = K_NOMARCH
               AND T.ADMPV_CODERROR IS NULL
               AND C.ADMPV_COD_CLI IS NULL
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
    SET ADMPV_CODERROR = 4,
        ADMPV_MSJE_ERROR = 'La línea no existe.';

  COMMIT;

  --SE OBTIENE EL TOTAL DE REGISTROS CARGADOS
  SELECT COUNT(1) INTO K_NUMREGTOT
  FROM PCLUB.ADMPT_TMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH;

  --SE OBTIENE EL TOTAL DE REGISTROS A PROCESAR
  SELECT COUNT(1) INTO V_NUMREGPROCES
  FROM PCLUB.ADMPT_TMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NULL;

  V_CONTADOR := 0;
  V_CONTOTAL := 0;

  OPEN V_CUR_LINEAS(K_NOMARCH);
  FETCH V_CUR_LINEAS INTO VC_SEC,VC_LINEA,VC_SALDO,VC_SALDO_BONO,VC_COD_CLI_IB;

  WHILE V_CUR_LINEAS%FOUND LOOP
    V_CONTADOR := V_CONTADOR + 1;
    V_CONTOTAL := V_CONTOTAL + 1;

    PCLUB.PKG_CC_PREPAGO.ADMPSI_PRESINREC_MASIVO
    (
      K_NOMARCH,
      VC_LINEA,
      VC_SALDO,
      VC_SALDO_BONO,
      VC_COD_CLI_IB,
      V_COD_CPTO,
      K_USUARIO,
      K_CODERROR,
      K_DESCERROR
    );

    IF K_CODERROR = 0 THEN
      UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA T
      SET T.ADMPC_ESTADO = 'P'
      WHERE T.ADMPN_SEC = VC_SEC;

      V_CONTREGVAL := V_CONTREGVAL + 1;
    ELSE
      UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA T
      SET T.ADMPC_ESTADO = 'P',
          T.ADMPV_CODERROR = K_CODERROR,
          T.ADMPV_MSJE_ERROR = K_DESCERROR
      WHERE T.ADMPN_SEC = VC_SEC;
    END IF;

    IF V_CONTADOR = V_NUMREGCOMMIT OR V_CONTOTAL = V_NUMREGPROCES THEN
      INSERT INTO PCLUB.ADMPT_IMP_PRESINRECARGA
      (
        ADMPN_ID_FILA,
        ADMPV_NOMARCHIVO,
        ADMPV_COD_CLI,
        ADMPC_ESTADOSMS,
        ADMPD_FEC_OPER,
        ADMPD_FEC_TRANS,
        ADMPD_USU_REG
      )
      SELECT ADMPT_IMP_PRESINRECARGA_SQ.NEXTVAL,
            ADMPV_NOMARCHIVO,
            ADMPV_COD_CLI,
            'P',
            V_FECHASYS,
            SYSDATE,
            K_USUARIO
      FROM PCLUB.ADMPT_TMP_PRESINRECARGA
      WHERE ADMPV_NOMARCHIVO = K_NOMARCH
            AND ADMPC_ESTADO = 'P';

      DELETE ADMPT_TMP_PRESINRECARGA
      WHERE ADMPV_NOMARCHIVO = K_NOMARCH
            AND ADMPC_ESTADO = 'P';

  COMMIT;
      V_CONTADOR := 0;
    END IF;

    FETCH V_CUR_LINEAS INTO VC_SEC,VC_LINEA,VC_SALDO,VC_SALDO_BONO,VC_COD_CLI_IB;
  END LOOP;
  CLOSE V_CUR_LINEAS;

  INSERT INTO PCLUB.ADMPT_IMP_PRESINRECARGA
  (
    ADMPN_ID_FILA,
    ADMPV_NOMARCHIVO,
    ADMPV_COD_CLI,
    ADMPV_CODERROR,
    ADMPV_MSJE_ERROR,
    ADMPD_FEC_OPER,
    ADMPD_FEC_TRANS,
    ADMPD_USU_REG
  )
  SELECT ADMPT_IMP_PRESINRECARGA_SQ.NEXTVAL,
         K_NOMARCH,
         ADMPV_COD_CLI,
         ADMPV_CODERROR,
         ADMPV_MSJE_ERROR,
         V_FECHASYS,
         SYSDATE,
         K_USUARIO
  FROM PCLUB.ADMPT_TMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

  --SE OBTIENE LOS VALORES K_NUMREGVAL Y K_NUMREGERR
  K_NUMREGVAL := V_CONTREGVAL;

  SELECT COUNT(1) INTO K_NUMREGERR
  FROM PCLUB.ADMPT_TMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

  --SE ELIMINA LOS REGISTROS ERRADOS
  DELETE PCLUB.ADMPT_TMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

  COMMIT;

EXCEPTION
  WHEN EX_CONCEPTO THEN
    K_CODERROR := K_CODERROR;
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ADMPSI_PRESINREC;

--****************************************************************
-- Nombre SP           :  ADMPSI_PRESINREC_MASIVO
-- Propósito           :  Descuenta los puntos por non recarga
-- Input               :  K_NOMARCH       --Nombre del archivo
--                        K_LINEA         --Número de la línea
--                        K_SALDO         --Saldo del cliente
--                        K_SALDO_BONO    --Saldo bono del cliente
--                        K_CODCLI_IB     --Código de cliente IB
--                        K_CONCEPTO      --Código de concepto
--                        K_USUARIO       --Usuario de proceso
-- Output              :  K_CODERROR      --Código de error o éxito
--                        K_DESCERROR     --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  26/07/2013
--****************************************************************
PROCEDURE ADMPSI_PRESINREC_MASIVO(K_NOMARCH IN VARCHAR2,
                                  K_LINEA IN VARCHAR2,
                                  K_SALDO IN NUMBER,
                                  K_SALDO_BONO IN NUMBER,
                                  K_CODCLI_IB IN VARCHAR2,
                                  K_CONCEPTO IN VARCHAR2,
                                  K_USUARIO IN VARCHAR2,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2) IS
V_IDKARDEX NUMBER;
V_SALDO_IB NUMBER;
V_NUEVOCODIGO VARCHAR2(50);
V_SECUENCIA NUMBER;
V_CODARTIFICIO VARCHAR2(40);
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  IF K_SALDO > 0 THEN
    SELECT NVL(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,0) INTO V_IDKARDEX FROM DUAL;

    IF V_IDKARDEX = 0 THEN
      K_CODERROR := 39;
      K_DESCERROR := 'No se generó un correlativo en tabla ADMPT_KARDEX. ';
      RAISE EX_ERROR;
    END IF;

    INSERT INTO PCLUB.ADMPT_KARDEX
    (
      ADMPN_ID_KARDEX,
      ADMPV_COD_CLI,
      ADMPV_COD_CPTO,
      ADMPD_FEC_TRANS,
      ADMPN_PUNTOS,
      ADMPC_TPO_OPER,
      ADMPC_TPO_PUNTO,
      ADMPN_SLD_PUNTO,
      ADMPC_ESTADO,
      ADMPV_NOM_ARCH,
      ADMPV_USU_REG
    )
    VALUES
    (
      V_IDKARDEX,
      K_LINEA,
      K_CONCEPTO,
      TRUNC(SYSDATE),
      K_SALDO * -1,
      'S',
      'C',
      0,
      'B',
      K_NOMARCH,
      K_USUARIO
    );
    
    
    UPDATE PCLUB.ADMPT_KARDEX
    SET ADMPN_SLD_PUNTO = 0,
      ADMPC_ESTADO = 'B',
      ADMPV_USU_MOD = K_USUARIO,
      ADMPN_ID_KRDX_VTO = V_IDKARDEX,
      ADMPN_ULTM_SLD_PTO = ADMPN_SLD_PUNTO
        WHERE ADMPC_TPO_OPER='E'
        AND ADMPC_TPO_PUNTO IN ('C', 'L','B')
        AND ADMPN_SLD_PUNTO>0
        AND ADMPC_ESTADO = 'A'
        AND ADMPV_COD_CLI = K_LINEA;
  END IF;

  IF K_SALDO_BONO > 0 THEN
    SELECT NVL(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,0) INTO V_IDKARDEX FROM DUAL;

    IF V_IDKARDEX = 0 THEN
      K_CODERROR := 39;
      K_DESCERROR := 'No se generó un correlativo en tabla ADMPT_KARDEX. ';
      RAISE EX_ERROR;
    END IF;

    INSERT INTO PCLUB.ADMPT_KARDEX
    (
      ADMPN_ID_KARDEX,
      ADMPV_COD_CLI,
      ADMPV_COD_CPTO,
      ADMPD_FEC_TRANS,
      ADMPN_PUNTOS,
      ADMPC_TPO_OPER,
      ADMPC_TPO_PUNTO,
      ADMPN_SLD_PUNTO,
      ADMPC_ESTADO,
      ADMPV_NOM_ARCH,
      ADMPV_USU_REG
    )
    VALUES
    (
      V_IDKARDEX,
      K_LINEA,
      K_CONCEPTO,
      TRUNC(SYSDATE),
      K_SALDO_BONO * -1,
      'S',
      'B',
      0,
      'B',
      K_NOMARCH,
      K_USUARIO
    );
  END IF;

  IF K_CODCLI_IB IS NOT NULL THEN
    SELECT ADMPN_SALDO_IB INTO V_SALDO_IB
    FROM PCLUB.ADMPT_SALDOS_CLIENTE
    WHERE ADMPN_COD_CLI_IB = K_CODCLI_IB
          AND ADMPC_ESTPTO_IB = 'A';

    UPDATE PCLUB.ADMPT_CLIENTEIB
    SET ADMPV_COD_CLI = NULL,
        ADMPV_NUM_LINEA = NULL
    WHERE ADMPN_COD_CLI_IB = K_CODCLI_IB;

    INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
    (
      ADMPN_ID_SALDO,
      ADMPN_COD_CLI_IB,
      ADMPN_SALDO_IB,
      ADMPN_SALDO_CC,
      ADMPC_ESTPTO_IB
    )
    VALUES
    (
      ADMPT_SLD_CL_SQ.NEXTVAL,
      K_CODCLI_IB,
      V_SALDO_IB,
      0,
      'A'
    );

    UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
    SET ADMPN_SALDO_IB = 0,
        ADMPC_ESTPTO_IB = 'B',
        ADMPN_COD_CLI_IB = NULL
    WHERE ADMPV_COD_CLI = K_LINEA;

 UPDATE PCLUB.ADMPT_KARDEX
    SET ADMPV_COD_CLI = NULL,
        ADMPV_USU_MOD = K_USUARIO
    WHERE ADMPN_COD_CLI_IB = K_CODCLI_IB
          AND ADMPC_TPO_PUNTO = 'I'
          AND ADMPN_SLD_PUNTO > 0
          AND ADMPC_TPO_OPER = 'E';
  END IF;


  V_NUEVOCODIGO := PCLUB.PKG_CC_PREPAGO.F_GETNUEVOCODIGO(K_LINEA);

  IF V_NUEVOCODIGO IS NULL THEN
    K_CODERROR := 39;
    K_DESCERROR := 'No se generó nuevo código de cliente.';
    RAISE EX_ERROR;
  END IF;

  UPDATE PCLUB.ADMPT_KARDEX
  SET ADMPV_COD_CLI = V_NUEVOCODIGO,
      ADMPV_USU_MOD = K_USUARIO
  WHERE ADMPV_COD_CLI = K_LINEA;

  UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
  SET ADMPV_COD_CLI = V_NUEVOCODIGO,
      ADMPN_SALDO_CC = 0,
      ADMPC_ESTPTO_CC = 'B'
  WHERE ADMPV_COD_CLI = K_LINEA;

  UPDATE PCLUB.ADMPT_SALDOS_BONO_CLIENTE
  SET ADMPV_COD_CLI = V_NUEVOCODIGO,
      ADMPN_SALDO = 0,
      ADMPV_ESTADO = 'B',
      ADMPV_USU_MOD = K_USUARIO
  WHERE ADMPV_COD_CLI = K_LINEA;

  -- Debido a la FK primero se debe insertar el registro
  SELECT NVL(PCLUB.ADMPT_CLIENTE_SQ.NEXTVAL,0) INTO V_SECUENCIA FROM DUAL;
  V_CODARTIFICIO := 'XX' || V_SECUENCIA;

  INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI)
  VALUES(V_CODARTIFICIO);

  UPDATE PCLUB.ADMPT_CANJE
  SET ADMPV_COD_CLI = V_CODARTIFICIO
  WHERE ADMPV_COD_CLI = K_LINEA;

  UPDATE PCLUB.ADMPT_CLIENTE
  SET ADMPV_COD_CLI = V_NUEVOCODIGO,
      ADMPC_ESTADO = 'B',
      ADMPV_USU_MOD = K_USUARIO
  WHERE ADMPV_COD_CLI = K_LINEA
        AND ADMPV_COD_TPOCL = '3';

  UPDATE PCLUB.ADMPT_CANJE
  SET ADMPV_COD_CLI = V_NUEVOCODIGO,
      ADMPV_USU_MOD = K_USUARIO
  WHERE ADMPV_COD_CLI = V_CODARTIFICIO;

  DELETE FROM PCLUB.ADMPT_CLIENTE
  WHERE ADMPV_COD_CLI = V_CODARTIFICIO;

  EXCEPTION
    WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSI_PRESINREC_MASIVO. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_PRESINREC_MASIVO;

--****************************************************************
-- Nombre SP           :  ADMPSS_TMP_PRESINRECARGA
-- Propósito           :  Lista registros de tabla ADMPT_TMP_PRESINRECARGA
-- Input               :  K_NOMARCH   --Nombre del archivo
-- Output              :  K_NUMREG    --Número de registros
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  02/08/2013
--****************************************************************
PROCEDURE ADMPSS_TMP_PRESINRECARGA(K_NOMARCH IN VARCHAR2,
                                   K_NUMREG OUT NUMBER,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_NOMARCH IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO K_NUMREG
  FROM PCLUB.ADMPT_TMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSS_TMP_PRESINRECARGA. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSS_TMP_PRESINRECARGA;

--****************************************************************
-- Nombre Function     :  F_GETNUEVOCODIGO
-- Propósito           :  Obtiene nuevo código del cliente
-- Input               :  K_CODIGO
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  02/08/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETNUEVOCODIGO(K_CODIGO IN VARCHAR) RETURN VARCHAR2
  IS
V_VALOR VARCHAR2(40);
V_CODIGO VARCHAR2(40);
V_PATRON VARCHAR2(40) := K_CODIGO || '%';
V_SECUENCIA NUMBER := 1;
V_POSICION NUMBER := 0;
BEGIN

  SELECT MAX(ADMPV_COD_CLI) INTO V_CODIGO
  FROM PCLUB.ADMPT_CLIENTE C
  WHERE C.ADMPV_COD_CLI LIKE V_PATRON;

  SELECT INSTR(V_CODIGO, '-') INTO V_POSICION FROM DUAL;
  IF V_POSICION > 0 THEN
    SELECT CAST(SUBSTR(V_CODIGO, V_POSICION + 1) AS SMALLINT) + 1
    INTO V_SECUENCIA
    FROM DUAL;
  END IF;

  V_VALOR := TRIM(K_CODIGO) || '-' || TO_CHAR(V_SECUENCIA);

  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END F_GETNUEVOCODIGO;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPRESINREC
-- Propósito           :  Lista registros errados
-- Input               :  K_NOMARCH   --Nombre del archivo
-- Output              :  K_CUR_LISTA --Cursor de datos
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  16/08/2013
  -- Fec Actualización   :
  --****************************************************************
PROCEDURE ADMPSI_EPRESINREC(K_NOMARCH IN VARCHAR2,
                            K_CUR_LISTA OUT SYS_REFCURSOR,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
  BEGIN

  CASE
    WHEN K_NOMARCH IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  OPEN K_CUR_LISTA FOR
  SELECT ADMPV_COD_CLI,
         ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_PRESINRECARGA
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSI_EPRESINREC. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSI_EPRESINREC;

  PROCEDURE ADMPSI_PREBAJACL(K_FECHA IN DATE,
                             K_USUARIO IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGPRO OUT NUMBER,
                             K_NUMREGERR OUT NUMBER) IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PRESINREC
  -- Propósito           :  Devuelve los errores producidos por eliminar puntos por 12 meses sin recarga.
  -- Input               :  K_FECHA
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  13/12/2010
    -- Modificado por      :  Jorge Luis Ortiz Castillo
    -- Fec Actualización   :  10/09/2013
  --****************************************************************

  NO_CONCEPTO EXCEPTION;

  CURSOR CURSORPREBAJACL IS
  SELECT ADMPV_COD_CLI,ADMPD_FEC_BAJA,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_TMP_PREBAJA
  WHERE ADMPD_FEC_OPER=K_FECHA
  AND ADMPV_MSJE_ERROR IS NULL;

  C_COD_CLI VARCHAR2(40);
  C_FEC_BAJA DATE;
  C_FEC_OPER DATE;
  C_MSJE_ERROR VARCHAR2(400);

  V_COUNT2 NUMBER := 0;
  V_COUNT_IB NUMBER;
  EST_ERROR NUMBER;
  V_SALDO_CLI NUMBER;
  V_COD_CPTO VARCHAR2(2);

  V_SALDO_IB NUMBER;
  V_CLIENTE_IB NUMBER;

  V_COD_NUEVO  NUMBER;
  V_COD_CLINUE VARCHAR2(40);
  V_REG NUMBER;
  /*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  K_TIPODOC VARCHAR2(20);
  K_NUMDOC VARCHAR2(20);
  C_COD_CLICUP NUMBER;
  /*CUPONERAVIRTUAL - JCGT FIN*/

    /* BONO INI */
    V_SALDO_BONO      NUMBER;
    /* BONO FIN */
    V_CODARTIFICIO VARCHAR2(25) := '999999999999999999999';
  BEGIN

  BEGIN
    --SE ALMACENA EL CODIGO DEL CONCEPTO 'BAJA CLIENTE PREPAGO'
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC='BAJA CLIENTE PREPAGO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
  END;

    IF V_COD_CPTO IS NULL THEN
     RAISE NO_CONCEPTO;
  END IF;

  --SE VERIFICA QUE EL CODIGO DEL CLIENTE NO SEA NULO O BLANCO

  UPDATE PCLUB.ADMPT_TMP_PREBAJA T
     SET T.ADMPV_MSJE_ERROR='Número de Teléfono es un dato obligatorio.'
     WHERE T.ADMPD_FEC_OPER=K_FECHA
  AND ((T.ADMPV_COD_CLI IS NULL) OR (REPLACE(T.ADMPV_COD_CLI,' ','') IS NULL));

  COMMIT;

  --SE VERIFICA LA EXISTENCIA DEL CLIENTE EN LA TABLA ADMPT_CLIENTE

  UPDATE PCLUB.ADMPT_TMP_PREBAJA T
  SET ADMPV_MSJE_ERROR='Cliente Activo no Existe '
  WHERE NOT EXISTS (SELECT 1
                    FROM PCLUB.ADMPT_CLIENTE C
                    WHERE C.ADMPV_COD_CLI=T.ADMPV_COD_CLI
                            AND C.ADMPV_COD_TPOCL='3'
                            AND C.ADMPC_ESTADO='A')
          AND T.ADMPD_FEC_OPER=K_FECHA
          AND T.ADMPV_MSJE_ERROR IS NULL;

  COMMIT;

  BEGIN

  COMMIT;

  OPEN CURSORPREBAJACL;
  FETCH CURSORPREBAJACL INTO C_COD_CLI,C_FEC_BAJA,C_FEC_OPER,C_MSJE_ERROR;
  WHILE CURSORPREBAJACL%FOUND LOOP
  EST_ERROR:=0;

     --SE VERIFICA LA EXISTENCIA DEL CLIENTE EN LA TABLA ADMPT_AUX_PREBAJA
     SELECT COUNT(1) INTO V_COUNT2
     FROM PCLUB.ADMPT_AUX_PREBAJA
     WHERE ADMPV_COD_CLI=C_COD_CLI
     AND ADMPD_FEC_BAJA=C_FEC_BAJA
     AND ADMPD_FEC_OPER=C_FEC_OPER;

     IF V_COUNT2=0 THEN
          V_SALDO_CLI := 0.00;
          BEGIN
          SELECT NVL(SUM(ADMPN_SLD_PUNTO),0) INTO V_SALDO_CLI
             FROM PCLUB.ADMPT_KARDEX
            WHERE ADMPV_COD_CLI = C_COD_CLI
                  AND ADMPC_TPO_OPER = 'E'
                  AND ADMPC_TPO_PUNTO = 'C'
                  AND ADMPN_SLD_PUNTO > 0
                  AND ADMPC_ESTADO='A';
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_SALDO_CLI := 0;
          END;

          IF V_SALDO_CLI > 0 THEN

           INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX, ADMPV_COD_CLI,
                                    ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
                                    ADMPN_PUNTOS, ADMPC_TPO_OPER,
                                    ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,
                                    ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG)
           VALUES(ADMPT_KARDEX_SQ.NEXTVAL, C_COD_CLI,
                  V_COD_CPTO,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
                  V_SALDO_CLI*(-1),'S',
                  'C',0,
                  'B',SYSDATE,K_USUARIO);

        END IF;

          -- COMMIT;

        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
          SET ADMPN_SALDO_CC=0,
              ADMPC_ESTPTO_CC='B'
          WHERE ADMPV_COD_CLI=C_COD_CLI;

          COMMIT;

          -- Verificando la existencia de saldo por BONO de Fidelidad del Cliente
          BEGIN
            SELECT NVL(SUM(ADMPN_SLD_PUNTO),0) INTO V_SALDO_BONO
            FROM PCLUB.ADMPT_KARDEX
            WHERE ADMPV_COD_CLI = C_COD_CLI
                  AND ADMPC_TPO_OPER = 'E'
                  AND ADMPC_TPO_PUNTO = 'B'
                  AND ADMPN_SLD_PUNTO > 0
                  AND ADMPC_ESTADO='A';
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_SALDO_BONO := 0;
          END;

          IF V_SALDO_BONO > 0 THEN
            -- insertamos la salida por el total del saldo por bonos recibidos
            INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPV_COD_CLI,
                                      ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
                                      ADMPN_PUNTOS,ADMPC_TPO_OPER,
                                      ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,
                                      ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG)
            VALUES (PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, C_COD_CLI,
                    V_COD_CPTO, TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
                    (V_SALDO_BONO * (-1)), 'S',
                    'B', 0,
                    'B', SYSDATE,K_USUARIO);
          -- Dar de baja al saldo por el total de bono recibido
            UPDATE PCLUB.ADMPT_SALDOS_BONO_CLIENTE BC
            SET BC.ADMPN_SALDO = 0,
                BC.ADMPV_ESTADO = 'B',
                BC.ADMPV_USU_MOD = K_USUARIO
            WHERE BC.ADMPV_COD_CLI = C_COD_CLI;

          -- Dar de Baja las entradas del kardex por concepto del bono
          UPDATE PCLUB.ADMPT_KARDEX
          SET ADMPN_SLD_PUNTO=0,
              ADMPC_ESTADO = 'B',
              ADMPV_USU_MOD = K_USUARIO
            WHERE ADMPV_COD_CLI=C_COD_CLI
                  AND ADMPC_TPO_PUNTO = 'B'
          AND ADMPN_SLD_PUNTO>0
                  AND ADMPC_TPO_OPER='E';

        END IF;

          --VERIFICANDO LA EXISTENCIA DEL CLIENTE EN LA TABLA ADMPT_CLIENTEIB
         V_COUNT_IB:=0;
          SELECT COUNT(1) INTO V_COUNT_IB
          FROM PCLUB.ADMPT_CLIENTEIB
         WHERE ADMPV_COD_CLI=C_COD_CLI;

         IF V_COUNT_IB <>0 THEN

            V_CLIENTE_IB:=NULL;
            SELECT ADMPN_COD_CLI_IB INTO V_CLIENTE_IB
            FROM PCLUB.ADMPT_CLIENTEIB
            WHERE ADMPV_COD_CLI=C_COD_CLI;

            --SE ALMACENA EL SALDO DE PUNTOS IB DEL CLIENTE IB
            V_SALDO_IB:=0;
            SELECT ADMPN_SALDO_IB INTO V_SALDO_IB
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPN_COD_CLI_IB=V_CLIENTE_IB
                  AND ADMPC_ESTPTO_IB='A';

            --DESVINCULAR AL CLIENTE PREPAGO DEL CLIENTE IB
            UPDATE PCLUB.ADMPT_CLIENTEIB
            SET ADMPV_COD_CLI=NULL, ADMPV_NUM_LINEA=NULL
            WHERE ADMPN_COD_CLI_IB=V_CLIENTE_IB;



            --INSERTAR EL CLIENTE IB EN LA TABLA ADMPT_SALDOS_CLIENTE
            INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPN_COD_CLI_IB,ADMPN_SALDO_IB
            ,ADMPN_SALDO_CC,ADMPC_ESTPTO_IB)
            VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_CLIENTE_IB,V_SALDO_IB,0,'A');

            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPN_SALDO_IB=0,ADMPC_ESTPTO_IB='B',ADMPN_COD_CLI_IB=NULL
            WHERE ADMPV_COD_CLI=C_COD_CLI;


            --ACTUALIZAR EL CODIGO DE CLIENTE PREPAGO EN LA TABLA KARDEX DEL CLIENTE IB
            UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPV_COD_CLI=NULL,
                ADMPV_USU_MOD = K_USUARIO
            WHERE ADMPN_COD_CLI_IB=V_CLIENTE_IB
            AND ADMPC_TPO_PUNTO = 'I'
            AND ADMPN_SLD_PUNTO>0
            AND ADMPC_TPO_OPER='E';


             --ACTUALIZA LOS SALDOS EN LA TABLA ADMPT_KARDEX
            UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPN_SLD_PUNTO=0,
                ADMPC_ESTADO = 'B',
                ADMPV_USU_MOD = K_USUARIO
            WHERE ADMPC_TPO_OPER='E'
            AND ADMPC_TPO_PUNTO IN ('L','C')
            AND ADMPN_SLD_PUNTO>0
            AND ADMPV_COD_CLI=C_COD_CLI;

         ELSE

            UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPN_SLD_PUNTO=0,
                ADMPC_ESTADO = 'B',
                ADMPV_USU_MOD = K_USUARIO
            WHERE ADMPV_COD_CLI=C_COD_CLI
            AND ADMPC_TPO_PUNTO IN ('L','C')
            AND ADMPN_SLD_PUNTO>0
            AND ADMPC_TPO_OPER='E';
      END IF;

      --DAR DE BAJA AL CLIENTE
        --MODIFICAR EL ESTADO DEL CLIENTE PREPAGO, ESTADO B(BAJA), EN LA TABLA CLIENTE
        UPDATE PCLUB.ADMPT_CLIENTE
        SET ADMPC_ESTADO='B'
        WHERE ADMPV_COD_CLI=C_COD_CLI
        AND ADMPV_COD_TPOCL='3';


          -- INSERTAR EN LA TABLA ADMPT_AUX_PREBAJA PARA UN POSIBLE REPROCESO
          INSERT INTO PCLUB.ADMPT_AUX_PREBAJA(ADMPV_COD_CLI,ADMPD_FEC_BAJA,ADMPD_FEC_OPER)
          VALUES(C_COD_CLI,C_FEC_BAJA,C_FEC_OPER);

          /*CUPONERAVIRTUAL - JCGT INI*/
          BEGIN
              SELECT C.ADMPV_NUM_DOC,C.ADMPV_TIPO_DOC INTO K_TIPODOC,K_NUMDOC
              FROM PCLUB.ADMPT_CLIENTE C
              WHERE C.ADMPV_COD_CLI=C_COD_CLI;

            PKG_CC_CUPONERA.ADMPSI_BAJACLIENTE(K_TIPODOC,K_NUMDOC,'BAJA','USRPREPAGO',C_COD_CLICUP,C_CODERROR,C_DESCERROR);
            /*CUPONERAVIRTUAL - JCGT FIN*/
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              C_CODERROR:=1;
              C_DESCERROR := SUBSTR(SQLERRM, 1, 200);

           WHEN OTHERS THEN
              C_CODERROR:=1;
              C_DESCERROR := SUBSTR(SQLERRM, 1, 200);
          END;

          -- este bloque estaba antes de INSERTAR EN LA TABLA ADMPT_AUX_PREBAJA
          -- Ini bloque
         V_COD_NUEVO  := 1;
         V_COD_CLINUE := '';

            WHILE V_COD_NUEVO > 0 LOOP
              V_COD_CLINUE := TRIM(C_COD_CLI) || '-' || TO_CHAR(V_COD_NUEVO);

              V_REG := 0;

              BEGIN
              SELECT COUNT(1) INTO V_REG
                  FROM PCLUB.ADMPT_CLIENTE
                 WHERE ADMPV_COD_CLI = V_COD_CLINUE;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_REG := 0;
              END;

              IF V_REG > 0 THEN
                V_COD_NUEVO := V_COD_NUEVO + 1;
              ELSE
                V_COD_NUEVO := 0;
              END IF;
            END LOOP;

        BEGIN
          UPDATE PCLUB.ADMPT_KARDEX
          SET ADMPV_COD_CLI=V_COD_CLINUE,
                ADMPV_USU_MOD = K_USUARIO
          WHERE ADMPV_COD_CLI=C_COD_CLI;


            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPV_COD_CLI=V_COD_CLINUE
            WHERE ADMPV_COD_CLI=C_COD_CLI;

            UPDATE PCLUB.ADMPT_SALDOS_BONO_CLIENTE
            SET ADMPV_COD_CLI=V_COD_CLINUE,
                ADMPV_USU_MOD = K_USUARIO
             WHERE ADMPV_COD_CLI=C_COD_CLI;

          -- Debido a la FK primero se debe insertar el registro
          INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI)
          VALUES(V_CODARTIFICIO);

          UPDATE PCLUB.ADMPT_CANJE
          SET ADMPV_COD_CLI = V_CODARTIFICIO
          WHERE ADMPV_COD_CLI = C_COD_CLI;

          UPDATE PCLUB.ADMPT_CLIENTE
          SET ADMPV_COD_CLI=V_COD_CLINUE
          WHERE ADMPV_COD_CLI=C_COD_CLI
          AND ADMPC_ESTADO='B';

          UPDATE PCLUB.ADMPT_CANJE
          SET ADMPV_COD_CLI = V_COD_CLINUE,
              ADMPV_USU_MOD = K_USUARIO
          WHERE ADMPV_COD_CLI = V_CODARTIFICIO;

          DELETE FROM PCLUB.ADMPT_CLIENTE
          WHERE ADMPV_COD_CLI = V_CODARTIFICIO;
        END;
      END IF;

  COMMIT;
      FETCH CURSORPREBAJACL INTO C_COD_CLI,C_FEC_BAJA,C_FEC_OPER,C_MSJE_ERROR;
  END LOOP;
  CLOSE CURSORPREBAJACL;

  COMMIT;
  END;

  --INSERTAMOS EN LA TABLA ADMPT_IMP_PREBAJA SI SE CUMPLIO SIN NIGUN ERROR EN LA BD
  INSERT INTO PCLUB.ADMPT_IMP_PREBAJA(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR
  ,ADMPD_FEC_BAJA,ADMPD_FEC_TRANS)
  SELECT  ADMPT_PREBAJA_SQ.NEXTVAL,T.ADMPV_COD_CLI,T.ADMPD_FEC_OPER,
  T.ADMPV_MSJE_ERROR,T.ADMPD_FEC_BAJA,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM')
  FROM PCLUB.ADMPT_TMP_PREBAJA T
  WHERE T.ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

    SELECT COUNT(1) INTO K_NUMREGTOT
  FROM PCLUB.ADMPT_TMP_PREBAJA
  WHERE ADMPD_FEC_OPER=K_FECHA;

    SELECT COUNT(1) INTO K_NUMREGERR
  FROM PCLUB.ADMPT_TMP_PREBAJA
  WHERE ADMPD_FEC_OPER=K_FECHA
  AND ADMPV_MSJE_ERROR IS NOT NULL;

    SELECT COUNT(1) INTO K_NUMREGPRO
    FROM PCLUB.ADMPT_AUX_PREBAJA
    WHERE ADMPD_FEC_OPER=K_FECHA;

  DELETE PCLUB.ADMPT_TMP_PREBAJA WHERE ADMPD_FEC_OPER=K_FECHA;
  DELETE PCLUB.ADMPT_AUX_PREBAJA WHERE ADMPD_FEC_OPER=K_FECHA;
  COMMIT;

  K_CODERROR:=0;
  K_DESCERROR:='';

   EXCEPTION

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado los parametros(ADMPT_CONCEPTO)';
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSI_PREBAJACL;

  procedure ADMPSI_EPREBAJACL(K_FECHA IN DATE, CURSOREPREBAJACL out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPREBAJACL
  -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de baja del Clientes Prepago
  -- Input               :  K_FECHA
  -- Output              :  CURSOREPREBAJACL
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  14/12/2010
  -- Fec Actualización   :
  --****************************************************************

  BEGIN
  OPEN CURSOREPREBAJACL FOR
    SELECT ADMPV_COD_CLI,ADMPD_FEC_BAJA,ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_IMP_PREBAJA
    WHERE ADMPD_FEC_OPER=K_FECHA
    AND ADMPV_MSJE_ERROR IS NOT NULL
    ORDER BY ADMPN_ID_FILA ASC;

  END ADMPSI_EPREBAJACL;


  procedure ADMPSI_PREVENCPTO(K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREVENCPTO
  -- Propósito           :  Obtiene y cancela los movimientos de ingreso al Kardex de las cuentas prepago que ya tienen más de lo permitido y no fueron utilizados
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  23/11/2010
  -- Fec Actualización   :
  --****************************************************************
  K_USUARIO CONSTANT CHAR(10) := 'USRVENCPTO';
  NO_CONCEPTO EXCEPTION;

  /*SELECCIONAR LOS CONCEPTOS QUE CUMPLEN CON LO REQUERIDO*/

  CURSOR C_CONCEPTO IS
  SELECT ADMPV_COD_CPTO, ADMPN_PER_CADU,ADMPC_TPO_PUNTO
  FROM PCLUB.ADMPT_CONCEPTO
  WHERE ADMPN_PER_CADU >0 AND ADMPC_ESTADO='A' AND ADMPC_TPO_PUNTO IN ('C','L')
  AND ADMPV_TPO_CPTO IS NULL;

  C_CODCPTO VARCHAR2(2);
  C_PER_CADU NUMBER;
  C_TPO_PUNTO VARCHAR2(2);
  V_COD_CPTO VARCHAR2(2);
  V_FECHA DATE;
  V_COD_CLI VARCHAR2(40);
  V_TPO_PUNTO VARCHAR2(2);
  TOTALPTOS NUMBER;
  V_COUNT NUMBER;
  V_COD_CLI_IB NUMBER;

  nKARDEX NUMBER;
  V_FECHA_0 DATE;
  dFECHA_REG_VEN DATE;
  nDIA INTEGER;

  CURSOR C_CLIENTE IS
  SELECT K.ADMPV_COD_CLI, SUM(K.ADMPN_SLD_PUNTO), K.ADMPC_TPO_PUNTO
  FROM PCLUB.ADMPT_KARDEX K, PCLUB.ADMPT_CLIENTE C
  WHERE ( k.ADMPD_FEC_TRANS > V_FECHA_0 AND k.ADMPD_FEC_TRANS < V_FECHA )
  AND K.ADMPV_COD_CPTO=C_CODCPTO
  AND C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
  AND K.ADMPC_TPO_PUNTO = C_TPO_PUNTO
  AND K.ADMPN_SLD_PUNTO > 0
  AND K.ADMPC_TPO_OPER = 'E'
  AND C.ADMPV_COD_TPOCL = '3' -- PREPAGO
  AND K.ADMPD_FEC_VCMTO IS NULL
  AND C.ADMPC_ESTADO = 'A'
  GROUP BY K.ADMPV_COD_CLI,K.ADMPC_TPO_PUNTO;

  BEGIN
  
  nDIA := TO_NUMBER(TO_CHAR(SYSDATE,'DD'));
  IF nDIA <= 5 THEN
    dFECHA_REG_VEN := TRUNC(LAST_DAY(ADD_MONTHS(SYSDATE, -1)));
  ELSE
    dFECHA_REG_VEN := TRUNC(LAST_DAY(SYSDATE));
  END IF;
    
     BEGIN
       /*SE ALMACENA EL CODIGO DEL CONCEPTO 'VENCIMIENTO DE PUNTO PREPAGO'*/
       SELECT ADMPV_COD_CPTO
       INTO V_COD_CPTO
       FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPV_DESC LIKE '%VENCIMIENTO DE PUNTO PREPAGO%';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
     END;

     IF V_COD_CPTO IS NULL THEN
        RAISE NO_CONCEPTO;
     END IF;

     OPEN C_CONCEPTO;
     FETCH C_CONCEPTO INTO C_CODCPTO,C_PER_CADU,C_TPO_PUNTO;
     WHILE C_CONCEPTO%FOUND LOOP
            /*ALMACENAR FECHA LIMITE ADMITIDA*/
            V_FECHA_0 := TRUNC(ADD_MONTHS(dFECHA_REG_VEN, - C_PER_CADU), 'MM')+(1 / (24 * 60 * 60))-(2 / (24 * 60 * 60));
            V_FECHA := TRUNC(LAST_DAY(ADD_MONTHS(dFECHA_REG_VEN, -C_PER_CADU)))+(1-(1 / (24 * 60 * 60)));
            OPEN C_CLIENTE;
            LOOP
            FETCH C_CLIENTE INTO V_COD_CLI,TOTALPTOS,V_TPO_PUNTO;
            EXIT WHEN C_CLIENTE%NOTFOUND;

            SELECT COUNT(1) INTO V_COUNT
            FROM PCLUB.ADMPT_CLIENTEIB
            WHERE ADMPV_COD_CLI = V_COD_CLI;

            SELECT PCLUB.ADMPT_KARDEX_SQ.NEXTVAL INTO nKARDEX FROM DUAL;

            IF V_COUNT = 1 THEN

              SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
              FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI = V_COD_CLI;

              /*INSERTAR EN EL KARDEX UN NUEVO REGISTRO CON EL CLIENTE ALMACENADO Y TOTAL DE PUNTOS VENCIDOS*/
              INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO
              ,ADMPC_ESTADO, admpd_fec_reg, ADMPV_USU_REG)
              VALUES(nKARDEX,V_COD_CLI_IB,V_COD_CLI,V_COD_CPTO,dFECHA_REG_VEN,
              TOTALPTOS*(-1),'S','C',0,'V',SYSDATE,K_USUARIO);

            ELSE


              /*INSERTAR EN EL KARDEX UN NUEVO REGISTRO CON EL CLIENTE ALMACENADO Y TOTAL DE PUNTOS VENCIDOS*/
              INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO
              ,ADMPC_ESTADO, admpd_fec_reg, ADMPV_USU_REG)
              VALUES(nKARDEX,V_COD_CLI,V_COD_CPTO,dFECHA_REG_VEN,
              TOTALPTOS*(-1),'S','C',0,'V',SYSDATE,K_USUARIO);

            END IF;

            IF ((V_TPO_PUNTO = 'L') OR (V_TPO_PUNTO = 'C')) THEN
              /*ACTUALIZAR LOS SALDOS DEL CLIENTE EN LA TABLA ADMPT_SALDOS_CLIENTE*/
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_CC = ADMPN_SALDO_CC + (TOTALPTOS*(-1))
              WHERE ADMPV_COD_CLI = V_COD_CLI;

            ELSIF V_TPO_PUNTO ='I' THEN
              /*ACTUALIZAR LOS SALDOS DEL CLIENTE EN LA TABLA ADMPT_SALDOS_CLIENTE*/
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_IB = ADMPN_SALDO_IB + (TOTALPTOS*(-1))
              WHERE ADMPV_COD_CLI = V_COD_CLI;
            END IF;

            /*ACTUALIZAR EN LA TABLA KARDEX A LOS CLIENTES DE LOS MOVIMIENTOS VENCIDOS*/
            UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPN_SLD_PUNTO = 0, ADMPC_ESTADO = 'V',
                ADMPV_USU_MOD = K_USUARIO,
                   ADMPD_FEC_VCMTO = SYSDATE,
                   ADMPN_ID_KRDX_VTO = nKARDEX,
                   ADMPN_ULTM_SLD_PTO = ADMPN_SLD_PUNTO
            WHERE ( ADMPD_FEC_TRANS > V_FECHA_0 AND ADMPD_FEC_TRANS < V_FECHA )
            AND ADMPV_COD_CPTO=C_CODCPTO
            AND ADMPV_COD_CLI=V_COD_CLI
            AND ADMPN_SLD_PUNTO>0
            AND ADMPC_TPO_OPER='E';

            COMMIT;

            END LOOP;
            CLOSE C_CLIENTE;
        FETCH C_CONCEPTO INTO C_CODCPTO,C_PER_CADU,C_TPO_PUNTO;
      END LOOP;
  CLOSE C_CONCEPTO;

  K_CODERROR:=0;
  K_DESCERROR:=' ';

  EXCEPTION

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado el parametro de VENCIMIENTO DE PUNTO PREPAGO (ADMPT_CONCEPTO).';
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

END ADMPSI_PREVENCPTO;

procedure ADMPSI_PREMIGPRE(K_FECHINI IN DATE, K_FECHFIN IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREMIGPRE
  -- Propósito           :  Devuelve los errores producidos por otorgar puntos por Migracion hacia un plan Postpago
  -- Input               :  K_FECHINI
  --                        K_FECHFIN
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  23/11/2010
  -- Fec Actualización   :  07/01/2011
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  NO_PARAMETRO EXCEPTION;

  V_FECHINI DATE;
  V_FECHFIN DATE;
  V_NUMREGTOT NUMBER;
  V_CODERROR VARCHAR2(10);
  V_DESCERROR VARCHAR2(400);
  TYPE TY_CURSOR IS REF CURSOR;
  CURSOROBTPREAPOS  TY_CURSOR;
  C_CUR_DATOS_CLIE TY_CURSOR;

  C_NUM_LINEA  VARCHAR2(20);
  C_FECHAMIGR DATE;
  --C_ORIGEN VARCHAR2(20);
  --C_DESTINO VARCHAR2(20);

  V_COD_CPTO VARCHAR2(2);
  V_CODCPTO_BONO VARCHAR2(2);
  V_COUNT NUMBER;
  V_COUNT2 NUMBER;
  V_EST_ERR NUMBER;
  V_ERROR VARCHAR2(200);
  V_ESTADO VARCHAR2(3);
  V_VALOR NUMBER;

  C_CUENTA VARCHAR2(40);
  C_TIP_DOC VARCHAR2(20);
  C_NUM_DOC VARCHAR2(30);
  C_CO_ID INTEGER;
  C_CI_FAC VARCHAR2(2);
  C_COD_TIP_CL VARCHAR2(10);
  C_TIP_CL VARCHAR2(30);
  V_SALDO_CC NUMBER;

  V_TIPO_DOC VARCHAR2(20);
  V_NUM_DOC VARCHAR2(20);
  V_NOM_CLI VARCHAR2(80);
  V_APE_CLI VARCHAR2(80);
  V_SEXO VARCHAR2(2);
  V_EST_CIVIL VARCHAR2(20);
  V_EMAIL VARCHAR2(80);
  V_PROV VARCHAR2(30);
  V_DEPA VARCHAR2(40);
  V_DIST VARCHAR2(200);

  C_PLANTARIF VARCHAR2(50);
  C_PUNTOS NUMBER;
  C_PLAN_UPP VARCHAR2(50);
  V_CODCONCEPTO VARCHAR2(2);
--  V_COUNT_IB NUMBER;
  V_COD_CLI_IB NUMBER;
  V_LONG NUMBER;
  V_NUMTEL VARCHAR2(40);
  V_SALDO_IB NUMBER;
  V_CODCPTO_IB VARCHAR2(2);

  SQL1 VARCHAR2(400);
  SQL2 VARCHAR2(400);
  V_EXT_CPOST NUMBER;

  BEGIN

  V_FECHINI:=to_date(to_char(K_FECHINI,'dd/mm/yyyy'), 'dd/mm/yyyy');
  V_FECHFIN:=to_date(to_char(K_FECHFIN,'dd/mm/yyyy'), 'dd/mm/yyyy');

  BEGIN
    SELECT ADMPV_COD_CPTO INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%ALTA DE CONTRATO%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_CODCONCEPTO:=NULL;
  END;

  BEGIN
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC LIKE '%MIGRACIONES PREPAGO A POSTPAGO CC%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
  END;

  BEGIN
    SELECT ADMPV_COD_CPTO
    INTO V_CODCPTO_BONO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC LIKE '%BONO POR MIGRACIONES PREPAGO A POSTPAGO%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_CODCPTO_BONO:=NULL;
  END;

  BEGIN
    SELECT ADMPV_COD_CPTO
    INTO V_CODCPTO_IB
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC LIKE '%MIGRACIONES PREPAGO A POSTPAGO IB%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_CODCPTO_IB:=NULL;
  END;

  BEGIN
    SELECT ADMPV_VALOR
    INTO V_VALOR
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC LIKE '%PUNTOS_MIGRACION_PREPAGO_POSTPAGO%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_VALOR:=NULL;
  END;

  --VERIFICANDO LA EXISTENCIA DE LOS CONCEPTOS A UTILIZAR
  IF ((V_CODCONCEPTO IS NULL) OR (V_COD_CPTO IS NULL) OR (V_CODCPTO_BONO IS NULL) OR (V_CODCPTO_IB IS NULL)) THEN
    RAISE NO_CONCEPTO;
  END IF;

  --VERIFICANDO LA EXISTENCIA DEL PARAMETRO A UTILIZAR
  IF V_VALOR IS NULL THEN
    RAISE NO_PARAMETRO;
  END IF;

  --OBTENIENDO EL CURSOR CON LAS MIGRACIONES DE PREPAGO A POSTPAGO
  PCLUB.PKG_CC_PREPAGO.ADMPSS_OBTPREAPOS(V_FECHINI,V_FECHFIN,V_NUMREGTOT,V_CODERROR,V_DESCERROR,CURSOROBTPREAPOS);
    LOOP
      FETCH CURSOROBTPREAPOS
      INTO  C_NUM_LINEA,C_FECHAMIGR; --,C_ORIGEN,C_DESTINO;
      EXIT WHEN CURSOROBTPREAPOS%NOTFOUND;
      V_EST_ERR:= 0;

      SELECT COUNT(*) INTO V_COUNT
      FROM PCLUB.ADMPT_CLIENTE
      WHERE ADMPV_COD_CLI = C_NUM_LINEA
      AND ADMPV_COD_TPOCL ='3';


      IF V_COUNT = 0 THEN
         --SE LE ASIGNA EL ERROR SI ESTA EL CLIENTE NO EXISTE
         V_ERROR:='Cliente Prepago no existe';
         V_EST_ERR:= 1;
         INSERT INTO PCLUB.ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
         ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
         VALUES(PCLUB.ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,C_NUM_LINEA,C_FECHAMIGR,
         to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);
      ELSE

         SELECT ADMPC_ESTADO INTO V_ESTADO
         FROM PCLUB.ADMPT_CLIENTE
         WHERE ADMPV_COD_CLI = C_NUM_LINEA
         AND ADMPV_COD_TPOCL ='3';

         IF V_ESTADO = 'B' THEN
            --SE LE ASIGNA EL ERROR SI ESTA EL CLIENTE EN ESTADO DE BAJA
            V_ERROR   := 'El Cliente ya se encuentra de Baja.';
            V_EST_ERR := 1;
            INSERT INTO PCLUB.ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
            ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
            VALUES(PCLUB.ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,C_NUM_LINEA,C_FECHAMIGR,
            to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);
         END IF;
      END IF;

      IF (C_NUM_LINEA IS NULL) OR (REPLACE(C_NUM_LINEA, ' ', '') IS NULL) THEN
        --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO
        V_ERROR   := 'Número de Teléfono es un dato obligatorio.';
        V_EST_ERR := 1;
        INSERT INTO PCLUB.ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
        ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
        VALUES(PCLUB.ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,C_NUM_LINEA,C_FECHAMIGR,
        to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);
      END IF;

      IF V_EST_ERR = 0 THEN
         --SI NO EXISTE ERROR
         C_CUENTA:=NULL;
         C_TIP_DOC:=NULL;
         C_NUM_DOC:=NULL;
         C_CO_ID:=NULL;
         C_CI_FAC:=NULL;
         C_COD_TIP_CL:=NULL;
         C_TIP_CL:=NULL;

         PCLUB.PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',C_NUM_LINEA, V_ERROR, C_CUR_DATOS_CLIE);

         LOOP
         FETCH C_CUR_DATOS_CLIE INTO C_CUENTA,C_TIP_DOC,C_NUM_DOC,C_CO_ID,
         C_CI_FAC,C_COD_TIP_CL,C_TIP_CL;

         IF C_CUR_DATOS_CLIE%NOTFOUND OR C_CUENTA IS NULL THEN
           IF C_CUENTA IS NULL THEN
             --SE LE ASIGNA EL ERROR SI NO EXISTE DATOS DEL CLIENTE
             V_ERROR   := 'Cliente No existe en Postpago. No se realizara el proceso';
             INSERT INTO PCLUB.ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
             ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
             VALUES(PCLUB.ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,C_NUM_LINEA,C_FECHAMIGR,
             to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);
           END IF;
           EXIT WHEN C_CUR_DATOS_CLIE%NOTFOUND;
         ELSE
           EXIT WHEN C_CUR_DATOS_CLIE%NOTFOUND;

           --SI EXITE DATOS DEL CLIENTE

           --ALMACENAR SALDO DEL CLIENTE PREPAGO
           SELECT NVL(ADMPN_SALDO_CC,0) INTO V_SALDO_CC
           FROM PCLUB.ADMPT_SALDOS_CLIENTE
           WHERE ADMPV_COD_CLI=C_NUM_LINEA;

           BEGIN
             V_COD_CLI_IB:=NULL;

             SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
               FROM PCLUB.ADMPT_CLIENTEIB
             WHERE ADMPV_COD_CLI=C_NUM_LINEA
             AND ADMPC_ESTADO = 'A';

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  V_COD_CLI_IB:=NULL;
           END;

           --INSERTAR REGISTRO EN LA TABLA ADMPT_KARDEX
             INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI
             ,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO
             ,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
             VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, V_COD_CLI_IB,C_NUM_LINEA,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
             V_SALDO_CC*(-1),'S','C',0,'C');

           --MODIFICAR EL SALDO DEL CLIENTE PREPAGO EN LA TABLA DE SALDOS
           UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
           SET ADMPN_SALDO_CC = 0, ADMPC_ESTPTO_CC='B'
           WHERE ADMPV_COD_CLI=C_NUM_LINEA;

           IF V_COD_CLI_IB IS NOT NULL THEN
               UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
               SET ADMPC_ESTPTO_IB='B'
               WHERE ADMPV_COD_CLI=C_NUM_LINEA;
           END IF;

           --MODIFICAR LOS SALDOS Y ESTADOS DEL CLIENTE PREPAGO EN EL KARDEX
           UPDATE PCLUB.ADMPT_KARDEX
           SET ADMPN_SLD_PUNTO = 0,
           ADMPC_ESTADO='C'
           WHERE ADMPV_COD_CLI=C_NUM_LINEA AND
           ADMPC_TPO_OPER='E' AND
           ADMPC_TPO_PUNTO IN ('C','L') AND
           ADMPN_SLD_PUNTO > 0;

           --MODIFICAR EL ESTADO DEL CLIENTE PREPAGO, ESTADO B(BAJA), EN LA TABLA CLIENTE
           UPDATE PCLUB.ADMPT_CLIENTE
           SET ADMPC_ESTADO='B'
           WHERE ADMPV_COD_CLI=C_NUM_LINEA
           AND ADMPV_COD_TPOCL='3';

           --ACTUALIZAR EL CODIGO DEL CLIENTE '999999999-#'
           V_LONG:=LENGTH(C_NUM_LINEA);

           IF V_LONG=9 THEN
             V_NUMTEL:=C_NUM_LINEA||'-1';
           ELSIF V_LONG>9 THEN
             V_NUMTEL:=SUBSTR(C_NUM_LINEA,11,(V_LONG-9))+1;
             V_NUMTEL:=SUBSTR(C_NUM_LINEA,1,10)||V_NUMTEL;
           END IF;

           BEGIN
             --SQL1:='ALTER TABLE PCLUB.admpt_canje disable constraint SYS_C00157188';
             --SQL2:='ALTER TABLE PCLUB.ADMPT_CLIENTE disable constraint PK_ADMPT_CLIENTE';

            --EXECUTE IMMEDIATE SQL1;
             --EXECUTE IMMEDIATE SQL2;

             --ACTUALIZAR EN LAS TABLAS ADMPT_KARDEX, ADMPT_SALDOS_CLIENTE, ADMPT_CLIENTE, ADMPT_CANJE EL CÓDIGO DEL CLIENTE PREPAGO
             UPDATE PCLUB.ADMPT_KARDEX
             SET ADMPV_COD_CLI=V_NUMTEL
             WHERE ADMPV_COD_CLI=C_NUM_LINEA;

             UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
             SET ADMPV_COD_CLI=V_NUMTEL
             WHERE ADMPV_COD_CLI=C_NUM_LINEA;

             UPDATE PCLUB.ADMPT_CLIENTE
             SET ADMPV_COD_CLI=V_NUMTEL
             WHERE ADMPV_COD_CLI=C_NUM_LINEA
             AND ADMPC_ESTADO='B'
             AND ADMPV_COD_TPOCL='3';

             UPDATE PCLUB.ADMPT_CANJE
             SET ADMPV_COD_CLI=V_NUMTEL
             WHERE ADMPV_COD_CLI=C_NUM_LINEA;

             --SQL1:='ALTER TABLE PCLUB.ADMPT_CLIENTE ENABLE CONSTRAINT PK_ADMPT_CLIENTE';
             --SQL2:='ALTER TABLE PCLUB.admpt_canje ENABLE constraint SYS_C00157188';

             --EXECUTE IMMEDIATE SQL1;
            -- EXECUTE IMMEDIATE SQL2;

           END;

           --CAPTURAR LOS DATOS DEL CLIENTE PREPAGO
           SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
           ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
           ADMPV_DEPA,ADMPV_DIST
           INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
           V_EMAIL,V_PROV,V_DEPA,V_DIST
           FROM PCLUB.ADMPT_CLIENTE
           WHERE ADMPV_COD_CLI=V_NUMTEL;
           --VALIDAMOS SI EXISTE CLIENTE POSTPAGO

           SELECT COUNT(ADMPV_COD_CLI) INTO V_EXT_CPOST
           FROM PCLUB.ADMPT_CLIENTE
           WHERE ADMPV_COD_CLI=C_CUENTA
           AND ADMPV_COD_TPOCL IN (1,2);

           IF V_EXT_CPOST=0 THEN
                 --INSERTAR EL CLIENTE POSTPAGO CON CODIGO OBTENIDO DEL SP ADMPSS_DAT_CLIE Y LOS DATOS DEL CLIENTE PREPAGO
                 INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI
                 ,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST
                 ,ADMPN_COD_CATCLI,ADMPD_FEC_ACTIV,ADMPV_CICL_FACT,ADMPC_ESTADO,ADMPV_COD_TPOCL)
                 VALUES(C_CUENTA,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
                 V_EMAIL,V_PROV,V_DEPA,V_DIST,2,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),C_CI_FAC,'A','2');
           ELSE
                 UPDATE PCLUB.ADMPT_CLIENTE
                 SET ADMPV_TIPO_DOC=V_TIPO_DOC,
                 ADMPV_NUM_DOC=V_NUM_DOC,
                 ADMPV_NOM_CLI=V_NOM_CLI,
                 ADMPV_APE_CLI=V_APE_CLI,
                 ADMPC_SEXO=V_SEXO,
                 ADMPV_EST_CIVIL=V_EST_CIVIL,
                 ADMPV_EMAIL=V_EMAIL,
                 ADMPV_PROV=V_PROV,
                 ADMPV_DEPA=V_DEPA,
                 ADMPV_DIST=V_DIST,
                 ADMPN_COD_CATCLI=2,
                 ADMPD_FEC_ACTIV=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                 ADMPV_CICL_FACT=C_CI_FAC,
                 ADMPC_ESTADO='A',
                 ADMPV_COD_TPOCL='2'
                 WHERE ADMPV_COD_CLI=C_CUENTA
                 AND ADMPV_COD_TPOCL IN (1,2);
           END IF;
           --INSERTAR EN LA TABLA KARDEX UN MOVIMIENTO CON CONCEPTO DE MIGRACION DE PREPAGO A POSTPAGO
           INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
           ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
           VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,C_CUENTA,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
           V_SALDO_CC,'E','C',V_SALDO_CC,'A');

           SELECT COUNT(*) INTO V_COUNT2
           FROM PCLUB.ADMPT_SALDOS_CLIENTE
           WHERE ADMPV_COD_CLI=C_CUENTA;

           IF V_COUNT2 = 0 THEN
              --INSERTAR SI NO EXISTE CLIENTE POSTPAGO EN LA TABLA SALDOS.
              INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_SALDO_CC
              ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
              VALUES(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,C_CUENTA,V_SALDO_CC,0,'A');
           ELSE
              --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO, AÑADIENDO EL SALDO ALMACENADO CUANDO ERA PREPAGO
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
              SET ADMPC_ESTPTO_CC='A',
              ADMPN_SALDO_CC  = V_SALDO_CC +
                                     (SELECT NVL(ADMPN_SALDO_CC, 0)
                                        FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                       WHERE ADMPV_COD_CLI = C_CUENTA)
              WHERE ADMPV_COD_CLI = C_CUENTA;
           END IF;

           --INSERTAR EN LA TABLA DE KARDEX LOS PUNTOS DE BENEFICIO POR HABER MIGRADO
           INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS
           ,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
           VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,C_CUENTA,V_CODCPTO_BONO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
           V_VALOR,'E','C',V_VALOR,'A');

           --MODIFICAR SALDO DEL CLIENTE POSTPAGO
           UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
           SET ADMPN_SALDO_CC  = V_VALOR +
                                     (SELECT NVL(ADMPN_SALDO_CC, 0)
                                        FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                       WHERE ADMPV_COD_CLI = C_CUENTA)
           WHERE ADMPV_COD_CLI = C_CUENTA;

           --ALMACENAR EL TIPO DE PLAN POSTPAGO AL CUAL MIGRO
           BEGIN
               SELECT rp.des INTO C_PLANTARIF
               FROM rateplan@DBL_BSCS rp,curr_contr_services_cap@DBL_BSCS csc,
               sysadm.contract_all@DBL_BSCS co,directory_number@DBL_BSCS dn
               WHERE co.tmcode = rp.tmcode
               AND csc.dn_id =  dn.dn_id
               AND co.co_id = csc.co_id
               AND csc.CS_ACTIV_DATE = (SELECT MAX(CS_ACTIV_DATE) FROM curr_contr_services_cap@DBL_BSCS WHERE DN_ID=dn.dn_id)
               AND dn.dn_num = C_CUENTA;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN C_PLANTARIF := '';
           END;

           BEGIN
             C_PUNTOS   := 0;
             C_PLAN_UPP := LTRIM (RTRIM (UPPER (C_PLANTARIF)));

             --ALMACENAR EL PUNTAJE POR EL TIPO DE PLAN DEL CLIENTE
             SELECT ADMPN_PTORENCON INTO C_PUNTOS
               FROM PCLUB.ADMPT_TIPO_PLAN
              WHERE LTRIM (RTRIM (UPPER (ADMPV_DES_PLAN))) = C_PLAN_UPP;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN C_PUNTOS := 0;
           END;

          IF C_PUNTOS <> 0 THEN

              --SE INSERTA AL KARDEX EL MOVIMIENTO DEL CLIENTE POSTPAGO POR EL TIPO DE PLAN ELEJIDO
              INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
              ADMPN_PUNTOS,ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
              VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, V_COD_CLI_IB, C_CUENTA, V_CODCONCEPTO,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), C_PUNTOS,'E', 'C', C_PUNTOS, 'A');

              --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO CON EL PUNTAJE POR EL TIPO DE PLAN
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_CC = C_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                    FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                                   WHERE ADMPV_COD_CLI = C_CUENTA)
                WHERE ADMPV_COD_CLI = C_CUENTA;
          END IF;


          SELECT SUM(ADMPN_SALDO_IB) INTO V_SALDO_IB
          FROM PCLUB.ADMPT_SALDOS_CLIENTE
          WHERE ADMPV_COD_CLI=V_NUMTEL;

          IF V_COD_CLI_IB IS NOT NULL THEN

             --INSERTAR REGISTRO EN LA TABLA ADMPT_KARDEX DEL CLIENTE PREPAGO
             INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
             ADMPN_PUNTOS,ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
             VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, V_COD_CLI_IB,V_NUMTEL, V_CODCPTO_IB,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
             V_SALDO_IB*(-1),'S','I',0,'C');

             UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
             SET ADMPN_SALDO_IB=0
             WHERE ADMPV_COD_CLI = V_NUMTEL;

             --MODIFICAR LOS SALDOS Y ESTADOS DEL CLIENTE PREPAGO EN EL KARDEX
             UPDATE PCLUB.ADMPT_KARDEX
             SET ADMPN_SLD_PUNTO = 0,
             ADMPC_ESTADO='C'
             WHERE ADMPV_COD_CLI=V_NUMTEL AND
             ADMPC_TPO_OPER='E' AND
             ADMPC_TPO_PUNTO = 'I' AND
             ADMPN_SLD_PUNTO > 0;

          --INSERTAR REGISTRO EN LA TABLA ADMPT_KARDEX DEL CLIENTE POSTPAGO
          INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
          ADMPN_PUNTOS,ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
          VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, V_COD_CLI_IB,C_CUENTA, V_CODCPTO_IB,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
          V_SALDO_IB,'E','I',V_SALDO_IB,'A');

          SELECT COUNT(*) INTO V_COUNT2
          FROM PCLUB.ADMPT_SALDOS_CLIENTE
          WHERE ADMPV_COD_CLI = C_CUENTA;

          IF V_COUNT2 = 0 THEN
             --INSERTAR SI NO EXISTE CLIENTE POSTPAGO EN LA TABLA SALDOS.
             INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_SALDO_CC
             ,ADMPN_SALDO_IB,ADMPC_ESTPTO_IB)
             VALUES(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,C_CUENTA,0,V_SALDO_IB,'A');
          ELSE
            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPC_ESTPTO_IB='A',
            ADMPN_SALDO_IB= V_SALDO_IB + (SELECT NVL(ADMPN_SALDO_IB,0)
                                              FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                              WHERE ADMPV_COD_CLI = C_CUENTA),
                                              ADMPN_COD_CLI_IB=V_COD_CLI_IB
            WHERE ADMPV_COD_CLI = C_CUENTA;
          END IF;

            UPDATE PCLUB.ADMPT_CLIENTEIB
            SET ADMPV_COD_CLI=C_CUENTA
            WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB;

            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPN_COD_CLI_IB = ''
            WHERE ADMPV_COD_CLI=V_NUMTEL;
         END IF;

       END IF;
       END LOOP;
       CLOSE C_CUR_DATOS_CLIE;

      END IF;
      COMMIT;
    END LOOP;
    CLOSE CURSOROBTPREAPOS;
    K_CODERROR:=0;
    K_DESCERROR:=' ';

    SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_IMP_PREPREPOS WHERE ADMPD_FEC_OPER=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
    AND ( ADMPV_MSJE_ERROR Is Not null);

    K_NUMREGTOT:=V_NUMREGTOT;
    K_NUMREGPRO:=V_NUMREGTOT - K_NUMREGERR;

    EXCEPTION
    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado los parametros(ADMPT_CONCEPTO)';
      ROLLBACK;

    WHEN NO_PARAMETRO THEN
      K_CODERROR  := 56;
      K_DESCERROR := 'No se tiene registrado los parametros(ADMPT_PARAMSIST)';
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR:= SQLCODE;
      K_DESCERROR:= SUBSTR(SQLERRM,1,250);
      ROLLBACK;

  END ADMPSI_PREMIGPRE;

procedure ADMPSI_EPREMIGPRE(K_FECHA IN DATE, CURSOREPREMIGPRE out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPREMIGPRE
  -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Migracion a Postpago
  -- Input               :  K_FECHA
  -- Output              :  CURSOREPREMIGPRE
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  23/11/2010
  -- Fec Actualización   :
  --****************************************************************

  BEGIN
  OPEN CURSOREPREMIGPRE FOR
       SELECT ADMPV_COD_CLI,ADMPD_FEC_MIG, ADMPV_MSJE_ERROR
       FROM PCLUB.ADMPT_IMP_PREPREPOS
       WHERE ADMPD_FEC_OPER=to_date(to_char(K_FECHA,'dd/mm/yyyy'),'dd/mm/yyyy')
       AND ADMPV_MSJE_ERROR IS NOT NULL
       ORDER BY ADMPN_ID_FILA ASC;

  END ADMPSI_EPREMIGPRE;

procedure ADMPSS_OBTPREAPOS(K_FECHINI IN DATE, K_FECHFIN IN DATE, K_NUMREGTOT OUT NUMBER, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, CURSOROBTPREAPOS out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSS_OBTPREAPOS
  -- Propósito           :  Obtiene los números de teléfonos que fueron migrados de Prepago a Postpago.
  -- Input               :  K_FECHINI
  --                        K_FECHFIN
  -- Output              :  K_NUMREGTOT
  --                        K_CODERROR
  --                        K_DESCERROR
  --                        CURSOROBTPREAPOS
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  23/11/2010
  -- Fec Actualización   :  07/01/2011
  --****************************************************************


  V_COUNT NUMBER;
  BEGIN

  SELECT COUNT(*) INTO V_COUNT FROM
  (
  select SUBSTR(a.msisdn,LENGTH(a.msisdn)-8,9) as msisdn, a.fechamigracion
  from dm.dw_sus_m_migracionpositiva@dbl_reptdm_d a
 where idsegmentoorigen = 1--de donde vino Prepago
   and idsegmento in(2, 3)--a donde ha llegado Postpago Consumer
   and fechamigracion >= K_FECHINI
   and fechamigracion < K_FECHFIN
  );

  BEGIN
  OPEN CURSOROBTPREAPOS FOR
  select SUBSTR(a.msisdn,LENGTH(a.msisdn)-8,9) as msisdn, a.fechamigracion
  from dm.dw_sus_m_migracionpositiva@dbl_reptdm_d a
 where idsegmentoorigen = 1--de donde vino Prepago
   and idsegmento in(2, 3)--a donde ha llegado Postpago Consumer
   and fechamigracion >= K_FECHINI
   and fechamigracion < K_FECHFIN
  ;


  END CURSOROBTPREAPOS;


  K_NUMREGTOT:=V_COUNT;
  K_CODERROR:='0';
  K_DESCERROR:=' ';

  COMMIT;

  EXCEPTION

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSS_OBTPREAPOS;

  procedure ADMPSI_PREMIGPOS(K_FECHINI IN DATE, K_FECHFIN IN DATE,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
  IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREMIGPOS
  -- Propósito           :  Devuelve los errores producidos por otorgar puntos por Migracion hacia un plan Prepago
  -- Input               :  K_FECHINI
  --                        K_FECHFIN
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  30/11/2010
  -- Fec Actualización   :  07/01/2011
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  NO_PARAMETRO EXCEPTION;

  V_FECHINI DATE;
  V_FECHFIN DATE;
  V_NUMREGTOT NUMBER;
  V_CODERROR VARCHAR2(10);
  V_DESCERROR VARCHAR2(400);
  TYPE TY_CURSOR IS REF CURSOR;
  CURSOROBTPOSAPRE  TY_CURSOR;
  C_CUR_DATOS_CLIE TY_CURSOR;

  C_NUMTELEF  VARCHAR2(20);
  C_FECHAMIGR DATE;

  C_CUENTA VARCHAR2(40);
  C_TIP_DOC VARCHAR2(20);
  C_NUM_DOC VARCHAR2(30);
  C_CO_ID INTEGER;
  C_CI_FAC VARCHAR2(2);
  C_COD_TIP_CL VARCHAR2(10);
  C_TIP_CL VARCHAR2(30);

  V_CUENTA VARCHAR2(40);
  V_TIP_DOC VARCHAR2(20);
  V_NU_DOC VARCHAR2(30);
  V_CO_ID INTEGER;
  V_CI_FAC VARCHAR2(2);
  V_COD_TIP_CL VARCHAR2(10);
  V_TIP_CL VARCHAR2(30);

  V_TIPO_DOC VARCHAR2(20);
  V_NUM_DOC VARCHAR2(20);
  V_NOM_CLI VARCHAR2(80);
  V_APE_CLI VARCHAR2(80);
  V_SEXO VARCHAR2(2);
  V_EST_CIVIL VARCHAR2(20);
  V_EMAIL VARCHAR2(80);
  V_PROV VARCHAR2(30);
  V_DEPA VARCHAR2(40);
  V_DIST VARCHAR2(200);

  V_COD_CPTO VARCHAR2(2);
  V_CODCPTO_BONO VARCHAR2(2);
  V_COUNT NUMBER;
  V_COUNT2 NUMBER;
  V_EST_ERR NUMBER;
  V_ERROR VARCHAR2(200);
  V_ESTADO VARCHAR2(3);
  V_VALOR NUMBER;
  V_SALDO NUMBER;
  V_COUNT_IB NUMBER;
  V_COD_CLI_IB NUMBER;

  V_KARDEX_SQ NUMBER;

  K_ID_CANJE NUMBER;
  K_SEC NUMBER;
  K_PUNTOS NUMBER;
  K_COD_CLIENTE VARCHAR2(40);
  K_TIPO_DOC VARCHAR2(2);
  K_NUM_DOC VARCHAR2(40);
  K_TIP_CLI VARCHAR2(2);

  V_PUNTOS_REQUERIDOS      number:=0;

  V_SALDO_IB NUMBER;
  V_COUNT3 NUMBER;
  LK_TPO_PUNTO VARCHAR2(2);
  LK_ID_KARDEX  NUMBER;
  LK_SLD_PUNTOS NUMBER;
  LK_COD_CLI VARCHAR2(40);
  LK_COD_CLIIB NUMBER;
  V_COUNTPRE NUMBER;
  V_SALDOCC NUMBER;

/* Cursor 1 */

cursor LISTA_KARDEX_1 is
select ka.admpc_tpo_punto, ka.admpn_id_kardex, ka.admpn_sld_punto, ka.admpv_cod_cli, admpn_cod_cli_ib
from PCLUB.admpt_kardex ka
where ka.admpc_estado='A'
and ka.admpc_tpo_oper='E'
and ka.admpn_sld_punto>0
and ka.admpc_tpo_punto<>'I'
and ka.admpd_fec_trans<=TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') --'17/09/2010'
and ka.admpv_cod_cli in (select CC2.ADMPV_COD_CLI
                         from PCLUB.admpt_cliente CC2, (select ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                                                  from PCLUB.admpt_cliente
                                                  where ADMPV_COD_CLI=K_COD_CLIENTE
                                                  and ADMPV_COD_TPOCL=K_TIP_CLI
                                                  and admpc_estado='A'
                                                   ) CC1 /*Obtiene el numero de doc y su tipo*/
                         where CC2.ADMPV_TIPO_DOC=CC1.ADMPV_TIPO_DOC
                               and CC2.ADMPV_NUM_DOC=CC1.ADMPV_NUM_DOC
                               and CC2.ADMPV_COD_TPOCL=K_TIP_CLI
                               and CC2.admpc_estado='A'
                         ) /*Selecciona todos los codigos que cumplen con la condicion*/
order by decode(admpc_tpo_punto, 'I', 1 ,'L', 2 ,'C', 3), admpn_id_kardex asc;



  BEGIN

  BEGIN
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC LIKE '%MIGRACIONES POSTPAGO A PREPAGO CC%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
  END;

  BEGIN
    SELECT ADMPV_VALOR
    INTO V_VALOR
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC LIKE '%PUNTOS_MIGRACION_POSTPAGO_PREPAGO%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_VALOR:=NULL;
  END;

  BEGIN
    SELECT ADMPV_COD_CPTO
    INTO V_CODCPTO_BONO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC LIKE '%PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_CODCPTO_BONO:=NULL;
  END;

  --VERIFICANDO LA EXISTENCIA DE LOS CONCEPTOS A UTILIZAR
  IF ((V_COD_CPTO IS NULL) OR (V_CODCPTO_BONO IS NULL)) THEN
    RAISE NO_CONCEPTO;
  END IF;

  --VERIFICANDO LA EXISTENCIA DEL PARAMETRO A UTILIZAR
  IF V_VALOR IS NULL THEN
    RAISE NO_PARAMETRO;
  END IF;

  V_FECHINI:=to_date(to_char(K_FECHINI,'dd/mm/yyyy'), 'dd/mm/yyyy');
  V_FECHFIN:=to_date(to_char(K_FECHFIN,'dd/mm/yyyy'), 'dd/mm/yyyy');

  PCLUB.PKG_CC_PREPAGO.ADMPSS_OBTPOSAPRE(V_FECHINI,V_FECHFIN,V_NUMREGTOT,V_CODERROR,V_DESCERROR,CURSOROBTPOSAPRE);

  LOOP
      FETCH CURSOROBTPOSAPRE
      INTO  C_NUMTELEF,C_FECHAMIGR; --,C_ORIGEN,C_DESTINO;
      EXIT WHEN CURSOROBTPOSAPRE%NOTFOUND;
      V_EST_ERR:= 0;


      --OBTENER DATOS POSTPAGO DEL CLIENTE PREPAGO
      PCLUB.PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',C_NUMTELEF, V_ERROR, C_CUR_DATOS_CLIE);
      LOOP

        FETCH C_CUR_DATOS_CLIE INTO C_CUENTA,C_TIP_DOC,C_NUM_DOC,C_CO_ID,
        C_CI_FAC,C_COD_TIP_CL,C_TIP_CL;
        EXIT WHEN C_CUR_DATOS_CLIE%NOTFOUND;

        V_CUENTA:=C_CUENTA;
        V_TIP_DOC:=C_TIP_DOC;
        V_NU_DOC:=C_NUM_DOC;
        V_CO_ID:=C_CO_ID;
        V_CI_FAC:=C_CI_FAC;
        V_COD_TIP_CL:=C_COD_TIP_CL;
        V_TIP_CL:=C_TIP_CL;

      END LOOP;

      CLOSE C_CUR_DATOS_CLIE;

      SELECT COUNT(*) INTO V_COUNT
      FROM PCLUB.ADMPT_CLIENTE
      WHERE ADMPV_COD_CLI = C_NUMTELEF
      AND ADMPV_COD_TPOCL = '3';

     /* IF V_COUNT > 0 THEN

         V_ERROR:='El número Postpago ya tiene una cuenta Prepago';
         V_EST_ERR:= 1;

         INSERT INTO PCLUB.ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
         ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
         VALUES(PCLUB.ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,C_FECHAMIGR,
         to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);

         GOTO VERIFICAERROR;
      END IF;*/

      IF (V_CUENTA IS NULL) OR (REPLACE(V_CUENTA, ' ', '') IS NULL) THEN

        --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO
        V_ERROR   := 'Código de Cliente Postpago es un dato obligatorio.';
        V_EST_ERR := 1;
        INSERT INTO PCLUB.ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
        ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
        VALUES(PCLUB.ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,C_FECHAMIGR,
        to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);

        GOTO VERIFICAERROR;
      END IF;

      SELECT COUNT(*) INTO V_COUNT
      FROM PCLUB.ADMPT_CLIENTE
      WHERE ADMPV_COD_CLI = V_CUENTA
      AND ADMPV_COD_TPOCL IN ('1','2');

      IF V_COUNT = 0 THEN

        --SE LE ASIGNA EL ERROR SI EL CLIENTE NO EXISTE
        V_ERROR:='Cliente Postpago no existe';
        V_EST_ERR:= 1;

        INSERT INTO PCLUB.ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
        ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
        VALUES(PCLUB.ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,C_FECHAMIGR,
        to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);

        GOTO VERIFICAERROR;
      END IF;

     SELECT ADMPC_ESTADO INTO V_ESTADO
     FROM PCLUB.ADMPT_CLIENTE
     WHERE ADMPV_COD_CLI = V_CUENTA
     AND ADMPV_COD_TPOCL IN ('1','2');

     IF V_ESTADO = 'B' THEN

          --SE LE ASIGNA EL ERROR SI ESTA EL CLIENTE EN ESTADO DE BAJA
          V_ERROR   := 'El Cliente ya se encuentra de Baja.';
          V_EST_ERR := 1;

          INSERT INTO PCLUB.ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG
          ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
          VALUES(PCLUB.ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,C_FECHAMIGR,
          to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),V_ERROR);

        GOTO VERIFICAERROR;
      END IF;

      <<VERIFICAERROR>>
      IF V_EST_ERR = 0 THEN

            --ALMACENAR EL SALDO DEL CLIENTE POSTPAGO
            SELECT ADMPN_SALDO_CC INTO V_SALDO FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPV_COD_CLI = V_CUENTA;

            --MODIFICAR LOS SALDOS Y EL ESTADO DEL CLIENTE POSTPAGO EN LA TABLA KARDEX
            UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPN_SLD_PUNTO=0,
            ADMPC_ESTADO = 'C'
            WHERE ADMPV_COD_CLI = V_CUENTA
            AND ADMPC_TPO_OPER='E'
            AND ADMPC_TPO_PUNTO IN ('C','L')
            AND ADMPN_SLD_PUNTO > 0;

            --MODIFICAR EL ESTADO DEL CLIENTE POSTPAGO EN LA TABLA CLIENTE
            UPDATE PCLUB.ADMPT_CLIENTE
            SET ADMPC_ESTADO = 'B'
            WHERE ADMPV_COD_CLI=V_CUENTA
            AND ADMPV_COD_TPOCL IN ('1','2');

            --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO
            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPN_SALDO_CC=0,ADMPC_ESTPTO_CC='B'
            WHERE ADMPV_COD_CLI=V_CUENTA;

            BEGIN
              SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
              FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI=V_CUENTA;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_COD_CLI_IB:=NULL;
            END;

            --INSERTAR EL MOVIMIENTO POR CONCEPTO DE 'MIGRACIONES POSTPAGO A PREPAGO' DEL CLIENTE POSTPAGO
            INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
            ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
            VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_CUENTA,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
            ,V_SALDO*(-1),'S','C',0,'C');

            --ALMACENAR LOS DATOS DEL CLIENTE POSTPAGO
            SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
            ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
            ADMPV_DEPA,ADMPV_DIST
            INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
            V_EMAIL,V_PROV,V_DEPA,V_DIST
            FROM PCLUB.ADMPT_CLIENTE
            WHERE ADMPV_COD_CLI=V_CUENTA
            AND ADMPV_COD_TPOCL IN ('1','2');


            SELECT COUNT(*) INTO V_COUNTPRE
            FROM PCLUB.ADMPT_CLIENTE
            WHERE ADMPV_COD_CLI = C_NUMTELEF
            AND ADMPV_COD_TPOCL = '3';

            IF V_COUNTPRE=0 THEN
            ---INSERTAR LOS DATOS POSTPAGO DEL CLIENTE PREPAGO
            INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC
            ,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA
            ,ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL)
            VALUES(C_NUMTELEF,2,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,V_EMAIL
            ,V_PROV,V_DEPA,V_DIST,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),'A','3');
            END IF;

            SELECT COUNT(*) INTO V_COUNT2
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPV_COD_CLI=C_NUMTELEF;

            IF V_COUNT2 = 0 THEN
               --INSERTAR EN LA TABLA DE SALDOS EL CLIENTE PREPAGO SI NO EXISTE EL CLIENTE PREPAGO EN LA TABLA SALDOS
               INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_SALDO_CC
               ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
               VALUES(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,C_NUMTELEF,0,0,'A');
            END IF;

            --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO EN LA TABLA KARDEX CON EL SALDO CAPTURADO DEL CLIENTE POSTPAGO
            INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
            ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
            VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,C_NUMTELEF,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
            ,V_SALDO,'E','C',V_SALDO,'A');

            --MODIFICAR EL SALDO EN LA TABLA SALDO DEL CLIENTE PREPAGO
            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPN_SALDO_CC  = V_SALDO +
                                     (SELECT NVL(ADMPN_SALDO_CC, 0)
                                        FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                       WHERE ADMPV_COD_CLI = C_NUMTELEF)
            WHERE ADMPV_COD_CLI = C_NUMTELEF;

            SELECT PCLUB.ADMPT_KARDEX_SQ.NEXTVAL INTO V_KARDEX_SQ FROM DUAL;

            SELECT ADMPN_SALDO_CC INTO V_SALDOCC
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPV_COD_CLI=C_NUMTELEF;

            IF V_SALDOCC<= V_VALOR*(-1) THEN
               V_VALOR:=V_SALDOCC*(-1);
            END IF;

            --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO DE 'PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO'
            INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
            ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
            VALUES(V_KARDEX_SQ,V_COD_CLI_IB,C_NUMTELEF,V_CODCPTO_BONO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
            ,V_VALOR,'S','C',0,'C');

            K_ID_CANJE:=V_KARDEX_SQ;
            K_SEC:=1;
            K_PUNTOS:=(V_VALOR*(-1));
            K_COD_CLIENTE:=C_NUMTELEF;
            K_TIPO_DOC:='';
            K_NUM_DOC:='';
            K_TIP_CLI:='3';
            V_PUNTOS_REQUERIDOS:=K_PUNTOS;
            --PCLUB.PKG_CC_TRANSACCION.ADMPSI_DESC_PUNTOS(K_ID_CANJE,K_SEC,K_PUNTOS,K_COD_CLIENTE,K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR,K_MSJERROR);

            if C_NUMTELEF is not null then
              if K_TIP_CLI='3' or K_TIP_CLI='4' then
                Open LISTA_KARDEX_1;
                fetch LISTA_KARDEX_1 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
                while LISTA_KARDEX_1%found and V_PUNTOS_REQUERIDOS>0
                loop
                      if LK_SLD_PUNTOS<=V_PUNTOS_REQUERIDOS then
                        -- Actualiza Kardex
                        update PCLUB.admpt_kardex
                        set
                        admpn_sld_punto = 0, admpc_estado = 'C'
                        where admpn_id_kardex = LK_ID_KARDEX;

                       /* -- Inserta Canje_kardex
                        insert into PCLUB.admpt_canjedt_kardex (admpv_id_canje, admpn_id_kardex , admpv_id_canjesec, admpn_puntos)
                        values (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS);*/

                        -- Actualiza Saldos_cliente
                        if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then /* Punto Claro Club */
                            update PCLUB.admpt_saldos_cliente
                               set
                                   admpn_saldo_cc = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                            where admpv_cod_cli=LK_COD_CLI)
                             where admpv_cod_cli = LK_COD_CLI;
                        end if;
                        V_PUNTOS_REQUERIDOS:=V_PUNTOS_REQUERIDOS-LK_SLD_PUNTOS;
                        else
                            if LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS then

                               -- Actualiza Kardex
                               update PCLUB.admpt_kardex
                               set
                               admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                               where admpn_id_kardex = LK_ID_KARDEX;

                             /*  -- Inserta Canje_kardex
                               insert into PCLUB.admpt_canjedt_kardex (admpv_id_canje, admpn_id_kardex , admpv_id_canjesec, admpn_puntos)
                               values (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS);*/
                               -- Actualiza Saldos_cliente
                               if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then /* Punto Claro Club */
                               update PCLUB.admpt_saldos_cliente
                               set
                               admpn_saldo_cc = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                        where admpv_cod_cli=LK_COD_CLI)
                                        where admpv_cod_cli = LK_COD_CLI;

                               end if;
                               V_PUNTOS_REQUERIDOS:=0;
                               end if;
                        end if;

                fetch LISTA_KARDEX_1 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
                end loop;
                close LISTA_KARDEX_1;
                end if;
            end if;

            --INSERTAR EN LA TABLA KARDEX Y ACTUALIZAR EL SALDO POR LA ENTREGA DE PUNTOS POR ACTIVACIÓN
            --PCLUB.PKG_CC_PREPAGO.ADMPSI_PREACTIV(C_NUMTELEF,K_CODERROR,K_DESCERROR);

            SELECT COUNT(*) INTO V_COUNT_IB
            FROM PCLUB.ADMPT_CLIENTEIB
            WHERE ADMPV_COD_CLI=V_CUENTA
            AND ADMPC_ESTADO = 'A';

            IF V_COUNT_IB <>0 THEN

              SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
              FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI=V_CUENTA
              AND ADMPC_ESTADO = 'A';

              SELECT ADMPN_SALDO_IB INTO V_SALDO_IB
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
              WHERE ADMPV_COD_CLI=V_CUENTA;


              --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO DE 'PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO'
              INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
              VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_CUENTA,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
              ,V_SALDO_IB*(-1),'S','I',0,'C');

              --MODIFICAR EL SALDO DEL CLIENTE PREPAGO EN LA TABLA SALDO POR CONCEPTO DE PENALIDAD
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_IB  = 0
              WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB;


              --MODIFICAR LOS SALDOS Y EL ESTADO DEL CLIENTE POSTPAGO EN LA TABLA KARDEX
              UPDATE PCLUB.ADMPT_KARDEX
              SET ADMPN_SLD_PUNTO=0,
              ADMPC_ESTADO = 'C'
              WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB
              AND ADMPC_TPO_OPER='E'
              AND ADMPC_TPO_PUNTO ='I'
              AND ADMPN_SLD_PUNTO > 0;

              BEGIN

                SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
                FROM PCLUB.ADMPT_CLIENTEIB
                WHERE ADMPV_COD_CLI=V_CUENTA
                AND ADMPC_ESTADO = 'A';

              EXCEPTION
                  WHEN NO_DATA_FOUND THEN V_COD_CLI_IB:=NULL;
              END;

            --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO DE 'PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO'
            INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
            ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
            VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,C_NUMTELEF,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
            ,V_SALDO_IB,'E','I',V_SALDO_IB,'A');


            SELECT COUNT(*) INTO V_COUNT3 FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPV_COD_CLI=C_NUMTELEF;

            IF V_COUNT3 = 0 THEN
               --INSERTAR EN LA TABLA DE SALDOS EL CLIENTE PREPAGO SI NO EXISTE EL CLIENTE PREPAGO EN LA TABLA SALDOS
               INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
               ,ADMPN_SALDO_IB,ADMPC_ESTPTO_IB)
               VALUES(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,C_NUMTELEF,V_COD_CLI_IB,0,V_SALDO_IB,'A');

            ELSE

              --MODIFICAR EL SALDO DEL CLIENTE PREPAGO EN LA TABLA SALDO POR CONCEPTO DE PENALIDAD
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
              SET ADMPC_ESTPTO_IB = 'A',ADMPN_COD_CLI_IB=V_COD_CLI_IB,
              ADMPN_SALDO_IB  = V_SALDO_IB +
                                       (SELECT NVL(ADMPN_SALDO_IB, 0)
                                          FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                         WHERE ADMPV_COD_CLI = C_NUMTELEF)

              WHERE ADMPV_COD_CLI = C_NUMTELEF;

            END IF;

            UPDATE PCLUB.ADMPT_CLIENTEIB
            SET ADMPV_COD_CLI=C_NUMTELEF
            WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB;


            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
            SET ADMPN_COD_CLI_IB=''
            WHERE ADMPV_COD_CLI=V_CUENTA;

          END IF;

      END IF;
  COMMIT;
  END LOOP;
  CLOSE CURSOROBTPOSAPRE;

  SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_IMP_PREPOSPRE WHERE ADMPD_FEC_OPER=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
    AND ( ADMPV_MSJE_ERROR Is Not null);

    K_NUMREGTOT:=V_NUMREGTOT;
    K_NUMREGPRO:=V_NUMREGTOT - K_NUMREGERR;

    K_CODERROR:= 0;
    K_DESCERROR:=' ';

  EXCEPTION

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado los parametros(ADMPT_CONCEPTO)';

    WHEN NO_PARAMETRO THEN
      K_CODERROR  := 56;
      K_DESCERROR := 'No se tiene registrado los parametros(ADMPT_PARAMSIST)';

    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

  END ADMPSI_PREMIGPOS;

procedure ADMPSI_EPREMIGPOS(K_FECHA IN DATE, CURSOREPREMIGPOS out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPREMIGPOS
  -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Migracion a Prepago
  -- Input               :  K_FECHA
  -- Output              :  CURSOREPREMIGPOS
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  23/11/2010
  -- Fec Actualización   :
  --****************************************************************
  BEGIN
  OPEN CURSOREPREMIGPOS FOR
  SELECT ADMPV_COD_CLI,ADMPD_FEC_MIG,ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_PREPOSPRE
  WHERE ADMPD_FEC_OPER=to_date(to_char(K_FECHA,'dd/mm/yyyy'),'dd/mm/yyyy')
  AND ADMPV_MSJE_ERROR IS NOT NULL
  ORDER BY ADMPN_ID_FILA ASC;

  END ADMPSI_EPREMIGPOS;

procedure ADMPSS_OBTPOSAPRE(K_FECHINI IN DATE, K_FECHFIN IN DATE, K_NUMREGTOT OUT NUMBER, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, CURSOROBTPOSAPRE out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSS_OBTPOSAPRE
  -- Propósito           :  Obtiene los números de teléfonos que fueron migrados de Postpago a Prepago.
  -- Input               :  K_FECHINI
  --                        K_FECHFIN
  -- Output              :  K_NUMREGTOT
  --                        K_CODERROR
  --                        K_DESCERROR
  --                        CURSOROBTPOSAPRE
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  23/11/2010
  -- Fec Actualización   :  07/01/2011
  --****************************************************************


  V_COUNT NUMBER;
  BEGIN

  SELECT COUNT(*) INTO V_COUNT FROM
  (
 select a.msisdn, a.fechamigracion
  from dm.dw_sus_m_migracionpositiva@dbl_reptdm_d a
 where idsegmentoorigen in(2, 3)--de donde vino Postpago Consumer
   and idsegmento = 1--a donde ha llegado Prepago
   and fechamigracion >= K_FECHINI
   and fechamigracion < K_FECHFIN
   );

  BEGIN
  OPEN CURSOROBTPOSAPRE FOR
    --Migración Positiva a Prepago (Sale de Posptpago - entra a ¨Prepago)
--Postpago a Prepago
select SUBSTR(a.msisdn,LENGTH(a.msisdn)-8,9) as msisdn, a.fechamigracion
  from dm.dw_sus_m_migracionpositiva@dbl_reptdm_d a
 where idsegmentoorigen in(2, 3)--de donde vino Postpago Consumer
   and idsegmento = 1--a donde ha llegado Prepago
   and fechamigracion >= K_FECHINI
   and fechamigracion < K_FECHFIN
   order by a.msisdn;

  END CURSOROBTPOSAPRE;

  K_NUMREGTOT:=V_COUNT;
  K_CODERROR:='0';
  K_DESCERROR:=' ';
  COMMIT;

  EXCEPTION

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSS_OBTPOSAPRE;

PROCEDURE ADMPSI_PREANIVER (K_FEC_PROCESO IN DATE, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_PREANIVER
-- Propósito           :  Entrega los puntos por Aniversario para los telefonos Prepago
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  Stiven Saavedra C.
-- Fec Creacion        :  17/11/2010
-- Fec Actualizacion   :  09/12/2010
--****************************************************************


V_CODCONCEPTO          VARCHAR2(2);
V_PUNTOS               NUMBER;

BEGIN
    BEGIN
      -- Obtenemos el codigo del Concepto
      SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE UPPER(ADMPV_DESC) LIKE '%ANIVERSARIO PREPAGO%';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
    END;

    BEGIN
      -- Obtenemos los puntos a entregar
      SELECT NVL(ADMPV_VALOR,'0') INTO V_PUNTOS
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE UPPER(ADMPV_DESC) LIKE '%PUNTOS_ANIVERSARIO_PREPAGO%';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN V_PUNTOS := 0.00;
    END;

    -- Verificamos que los clientes no esten de Baja y que exista
    UPDATE PCLUB.ADMPT_TMP_PREANIVERS T
       SET T.ADMPV_MSJE_ERROR = 'El Cliente se encuentra de Baja.'
     WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C
           WHERE C.ADMPC_ESTADO = 'B' AND C.ADMPV_COD_TPOCL = '3' AND C.ADMPV_COD_CLI=T.ADMPV_COD_CLI);

    COMMIT;

    UPDATE PCLUB.ADMPT_TMP_PREANIVERS T
       SET T.ADMPV_MSJE_ERROR = 'El Cliente NO se encuentra en la BD.'
     WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C
                      WHERE C.ADMPC_ESTADO = 'A' AND C.ADMPV_COD_TPOCL = '3' AND C.ADMPV_COD_CLI=T.ADMPV_COD_CLI);

    COMMIT;


    INSERT INTO PCLUB.ADMPT_AUX_PREANIVERS(ADMPV_COD_CLI, ADMPD_FEC_ANIV)
    SELECT C.ADMPV_COD_CLI,C.ADMPD_FEC_ANIV FROM PCLUB.ADMPT_TMP_PREANIVERS C
    WHERE C.ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ');

    COMMIT;

    UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
          SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_PUNTOS
                 WHERE ADMPV_COD_CLI IN (SELECT A.ADMPV_COD_CLI FROM ADMPT_AUX_PREANIVERS A)
                 AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_KARDEX K WHERE K.ADMPV_COD_CLI = S.ADMPV_COD_CLI
                  AND K.ADMPV_COD_CPTO = V_CODCONCEPTO AND
                   TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY'));

    COMMIT;

    INSERT INTO PCLUB.ADMPT_KARDEX (
    ADMPN_ID_KARDEX,
    ADMPN_COD_CLI_IB,
    ADMPV_COD_CLI,
    ADMPV_COD_CPTO,
    ADMPD_FEC_TRANS,
    ADMPN_PUNTOS,
    ADMPV_NOM_ARCH,
    ADMPC_TPO_OPER,
    ADMPC_TPO_PUNTO,
    ADMPN_SLD_PUNTO,
    ADMPC_ESTADO)

    SELECT PCLUB.admpt_kardex_sq.NEXTVAL,
    I.ADMPN_COD_CLI_IB,
    C.ADMPV_COD_CLI,
    V_CODCONCEPTO,
    TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
    V_PUNTOS,
    '',
    'E',
    'C',
    V_PUNTOS,
    'A'
   FROM PCLUB.ADMPT_TMP_PREANIVERS C LEFT JOIN PCLUB.ADMPT_CLIENTEIB I
        ON (C.ADMPV_COD_CLI=I.ADMPV_COD_CLI AND I.ADMPC_ESTADO = 'A')
   WHERE C.ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ')
   AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_KARDEX K WHERE K.ADMPV_COD_CLI = C.ADMPV_COD_CLI
                  AND K.ADMPV_COD_CPTO = V_CODCONCEPTO AND
                   TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY'));

   COMMIT;


    -- Obtenemos los registros totales, procesados y con error
    SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_PREANIVERS;
    SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_PREANIVERS WHERE (ADMPD_FEC_OPER = K_FEC_PROCESO) AND ADMPV_MSJE_ERROR IS NOT NULL;
    SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_PREANIVERS;

    -- Insertamos de la tabla temporal a la final
    INSERT INTO PCLUB.ADMPT_IMP_PREANIVERS
    SELECT PCLUB.ADMPT_IMP_PREANIV_SQ.nextval,ADMPV_COD_CLI, ADMPD_FEC_ANIV, ADMPD_FEC_OPER,
           TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'),
           ADMPV_MSJE_ERROR
      FROM PCLUB.ADMPT_TMP_PREANIVERS
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_MSJE_ERROR IS NOT NULL;

     -- Eliminamos los registros de la tabla temporal y auxiliar
     DELETE PCLUB.ADMPT_AUX_PREANIVERS;
     DELETE PCLUB.ADMPT_TMP_PREANIVERS WHERE (ADMPD_FEC_OPER = K_FEC_PROCESO);

    COMMIT;

    K_CODERROR:= 0;
    K_DESCERROR:= '';

    EXCEPTION
      WHEN OTHERS THEN
       K_CODERROR:= SQLCODE;
       K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_PREANIVER;

PROCEDURE ADMPSI_EPREANIVER (K_FEC_PRO IN DATE, PREANIVER_CUR OUT SYS_REFCURSOR)
IS
--****************************************************************
-- Nombre SP           :  ADMPSI_EPREANIVER
-- Propósito           :  Proceso que devuelve los errores producidos por la entrega de puntos por aniversario
--
-- Input               :  K_FEC_PRO Fecha de Proceso
--
-- Output              :  PREANIVER_CUR Cursor con los errores encontrados
--
-- Creado por          :  Stiven Saavedra C.
-- Fec Creacion        :  10/12/2010
-- Fec Actualizacion   :
--****************************************************************

BEGIN
       OPEN PREANIVER_CUR FOR
       SELECT ADMPV_COD_CLI, ADMPD_FEC_ANIV, ADMPV_MSJE_ERROR
         FROM PCLUB.ADMPT_IMP_PREANIVERS
        WHERE TO_DATE (ADMPD_FEC_OPER, 'DD/MM/YYYY') = TO_DATE (K_FEC_PRO, 'DD/MM/YYYY') AND ADMPV_MSJE_ERROR IS NOT NULL;

END ADMPSI_EPREANIVER;

  procedure ADMPSI_TMPPROMOCION(K_CODCLI IN VARCHAR2, K_NOMPROM IN VARCHAR2,K_PERIODO IN VARCHAR2,K_PUNTOS IN NUMBER,K_NOMARCH IN VARCHAR2,K_SEQ IN NUMBER,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_TMPPROMOCION
  -- Propósito           :  Insertar registros en la tabla temporal de promociones Prepago
  -- Input               :  K_CODCLI
  --                        K_NOMPROM
  --                        K_PERIODO
  --                        K_PUNTOS
  --                        K_NOMARCH
  --                        K_SEQ
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  15/12/2010
  -- Fec Actualización   :
  --****************************************************************

  BEGIN
    INSERT INTO PCLUB.ADMPT_TMP_PREPROMO(ADMPV_COD_CLI,ADMPV_NOM_PROMO,ADMPV_PERIODO,ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPD_FEC_OPER,ADMPN_SEQ)
    VALUES(K_CODCLI,K_NOMPROM,K_PERIODO,K_PUNTOS,K_NOMARCH,to_date(to_char(SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy'),K_SEQ);
    COMMIT;
    K_CODERROR:=0;
    K_DESCERROR:=' ';
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;
  END ADMPSI_TMPPROMOCION;

  procedure ADMPSI_PREPROMOCION(K_FECHA IN DATE,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREPROMOCION
  -- Propósito           :  Debe entregar los puntos por Promoción para los clientes indicados en el archivo
  -- Input               :  K_FECHA
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  30/11/2010
  -- Fec Actualización   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;

  V_COD_CPTO VARCHAR2(3);

  CURSOR CURSOR_TMP_PREPROMO IS
  SELECT ADMPV_COD_CLI,ADMPV_NOM_PROMO,ADMPV_PERIODO,NVL(ADMPN_PUNTOS,0) PUNTOS,ADMPV_NOM_ARCH,ADMPD_FEC_OPER
  FROM PCLUB.ADMPT_TMP_PREPROMO
  WHERE ADMPD_FEC_OPER=TRUNC(K_FECHA) FOR UPDATE OF PCLUB.ADMPT_TMP_PREPROMO.ADMPV_MSJE_ERROR;

  C_COD_CLI VARCHAR2(40);
  C_NOM_PROMO VARCHAR2(100);
  C_PERIODO VARCHAR2(6);
  C_PUNTOS NUMBER;
  C_NOM_ARCH VARCHAR2(100);
  C_FEC_OPER DATE;

  V_COD_CLI_IB NUMBER;

  V_ERROR VARCHAR2(400);
  V_COUNT NUMBER;
  V_COUNT2 NUMBER;
  V_COUNT3 NUMBER;
  V_TPO_OPER VARCHAR2(2);
  V_SLD_PUNTO NUMBER;
  V_REGCLI NUMBER;
  EST_ERROR NUMBER;
  BEGIN

  BEGIN
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC LIKE '%PROMO PREPAGO%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
  END;

  IF V_COD_CPTO IS NULL THEN
    RAISE NO_CONCEPTO;
  END IF;

  BEGIN
  OPEN CURSOR_TMP_PREPROMO;
  FETCH CURSOR_TMP_PREPROMO INTO C_COD_CLI,C_NOM_PROMO,C_PERIODO,C_PUNTOS,C_NOM_ARCH,C_FEC_OPER;

  WHILE CURSOR_TMP_PREPROMO%FOUND LOOP
    EST_ERROR:=0;
    IF (C_COD_CLI IS NULL) OR (REPLACE(C_COD_CLI, ' ', '') IS NULL) THEN
      EST_ERROR:=1;
      --MODIFICAR EL ERROR SI EL NUMERO TELEFONICO ESTA EN BLANCO O NULO A LA TABLA ADMPT_TMP_PREPROMO
      V_ERROR := 'Número de Teléfono es un dato obligatorio.';
      UPDATE PCLUB.ADMPT_TMP_PREPROMO
      SET ADMPV_MSJE_ERROR = V_ERROR
      WHERE CURRENT OF CURSOR_TMP_PREPROMO;
    END IF;

    SELECT COUNT(*) INTO V_COUNT
    FROM PCLUB.ADMPT_CLIENTE
    WHERE ADMPV_COD_CLI = C_COD_CLI
    AND ADMPV_COD_TPOCL='3';


    IF V_COUNT = 0 THEN
       EST_ERROR:=1;
       --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA ADMPT_TMP_PREPROMO SI CLIENTE NO EXISTE
       V_ERROR := 'Cliente No existe.';
       UPDATE PCLUB.ADMPT_TMP_PREPROMO
       SET ADMPV_MSJE_ERROR = V_ERROR
       WHERE CURRENT OF CURSOR_TMP_PREPROMO;
    ELSE
       SELECT COUNT(*) INTO V_COUNT2
       FROM PCLUB.ADMPT_CLIENTE
       WHERE ADMPV_COD_CLI = C_COD_CLI
       AND ADMPV_COD_TPOCL='3'
       AND ADMPC_ESTADO = 'B';

       IF V_COUNT2<>0 THEN
          EST_ERROR:=1;
          --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA ADMPT_TMP_PREPROMO SI CLIENTE ESTA EN ESTADO DE BAJA
          V_ERROR := 'Cliente se encuentra de Baja no se le entregará la Promoción.';
          UPDATE PCLUB.ADMPT_TMP_PREPROMO
          SET ADMPV_MSJE_ERROR = V_ERROR
          WHERE CURRENT OF CURSOR_TMP_PREPROMO;
       END IF;
     END IF;

     IF EST_ERROR=0 THEN

          V_REGCLI:=0;

          SELECT COUNT(*) INTO V_REGCLI FROM PCLUB.ADMPT_AUX_PREPROMO
          WHERE ADMPV_COD_CLI= C_COD_CLI
          AND ADMPV_NOM_PROMO=C_NOM_PROMO
          AND ADMPV_PERIODO=C_PERIODO
          AND ADMPN_PUNTOS=C_PUNTOS
          AND ADMPV_NOM_ARCH=C_NOM_ARCH;

          IF V_REGCLI=0 THEN

                IF C_PUNTOS<0 THEN
                   V_TPO_OPER:='S';
                   V_SLD_PUNTO:=0;
                ELSIF C_PUNTOS>0 THEN
                   V_TPO_OPER :='E';
                   V_SLD_PUNTO:=C_PUNTOS;
                END IF;

                SELECT COUNT(*) INTO V_COUNT3
                FROM PCLUB.ADMPT_CLIENTEIB
                WHERE ADMPV_COD_CLI = C_COD_CLI;

                IF V_COUNT3=0 THEN
                  --INSERTAR EL MOVIMIENTO EN LA TABLA KARDEX
                  INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPV_COD_CLI,ADMPV_COD_CPTO
                  ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO
                  ,ADMPC_ESTADO)
                  VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,C_COD_CLI,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                  C_PUNTOS,C_NOM_ARCH,V_TPO_OPER,'C',V_SLD_PUNTO,'A');


                ELSE

                  SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
                  FROM PCLUB.ADMPT_CLIENTEIB
                  WHERE ADMPV_COD_CLI = C_COD_CLI;
                  --INSERTAR EL MOVIMIENTO EN LA TABLA KARDEX
                  INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
                  ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO
                  ,ADMPC_ESTADO)
                  VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,C_COD_CLI,V_COD_CPTO,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                  C_PUNTOS,C_NOM_ARCH,V_TPO_OPER,'C',V_SLD_PUNTO,'A');

                END IF;

                --ACTUALIZAR EL SALDO DEL CLIENTE EN LA TABLA SALDOS
                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                SET ADMPN_SALDO_CC = C_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                 FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                                 WHERE ADMPV_COD_CLI=C_COD_CLI),
                    ADMPC_ESTPTO_CC='A'
                WHERE ADMPV_COD_CLI=C_COD_CLI;

                --INSERTAR EL REGISTRO CORRESPONDIENTE EN LA TABLA ADMPT_AUX_PREPROMO
                INSERT INTO PCLUB.ADMPT_AUX_PREPROMO(ADMPV_COD_CLI,ADMPV_NOM_PROMO,ADMPV_PERIODO
                ,ADMPN_PUNTOS,ADMPV_NOM_ARCH)
                VALUES(C_COD_CLI,C_NOM_PROMO,C_PERIODO,C_PUNTOS,C_NOM_ARCH);

          END IF;
      END IF;
      FETCH CURSOR_TMP_PREPROMO INTO C_COD_CLI,C_NOM_PROMO,C_PERIODO,C_PUNTOS,C_NOM_ARCH,C_FEC_OPER;
  END LOOP;
  CLOSE CURSOR_TMP_PREPROMO;
  COMMIT;
  END;

  INSERT INTO PCLUB.ADMPT_IMP_PREPROMO(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_NOM_PROMO,ADMPV_PERIODO,
  ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR,ADMPD_FEC_TRANS)
  SELECT PCLUB.ADMPT_IMP_PREPROMO_SQ.NEXTVAL,T.ADMPV_COD_CLI,T.ADMPV_NOM_PROMO,T.ADMPV_PERIODO
  ,T.ADMPN_PUNTOS,T.ADMPV_NOM_ARCH,T.ADMPD_FEC_OPER,T.ADMPV_MSJE_ERROR,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM')
  FROM PCLUB.ADMPT_TMP_PREPROMO T
  WHERE ADMPD_FEC_OPER=TRUNC(K_FECHA);

  SELECT COUNT(*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_PREPROMO WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT(*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_PREPROMO WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR Is Not null);
  SELECT COUNT(*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_PREPROMO;

 -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_TMP_PREPROMO WHERE ADMPD_FEC_OPER=TRUNC(K_FECHA);
   DELETE PCLUB.ADMPT_AUX_PREPROMO;

  COMMIT;
  K_CODERROR:=0;
  K_DESCERROR:=' ';

  EXCEPTION

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado el parametro de PROMO PREPAGO (ADMPT_CONCEPTO).';
      ROLLBACK;

    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;

  END ADMPSI_PREPROMOCION;

  procedure ADMPSI_EPREPROMOCION(K_FECHA IN DATE, CURSOREPREPROMO out SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPREPROMOCION
  -- Propósito           :  Devuelve en un cursor solo los puntos por Promoción que no pudieron ser agregadas por algún error controlado
  -- Input               :  K_NOMARCH
  -- Output              :  CURSOREPREPROMO
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  30/11/2010
  -- Fec Actualización   :
  --****************************************************************
  BEGIN

  OPEN CURSOREPREPROMO FOR
  SELECT ADMPV_COD_CLI, ADMPV_NOM_PROMO, ADMPV_PERIODO, ADMPN_PUNTOS, ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_PREPROMO
  WHERE ADMPV_MSJE_ERROR IS NOT NULL
  AND ADMPD_FEC_OPER=K_FECHA;

  END ADMPSI_EPREPROMOCION;

  procedure ValPalSMS(K_PALABRA IN VARCHAR2,K_TIP_CLI IN VARCHAR2,K_CODCONTR IN NUMBER,K_COD_SERVC OUT NUMBER,K_ID_PROCLA OUT VARCHAR2,K_COD_TPOPR OUT VARCHAR2,K_PUNTOS OUT NUMBER,K_MNT_RECAR OUT NUMBER, K_COD_PAQT OUT VARCHAR2, K_CODRET OUT VARCHAR2,K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  ValPalSMS
  -- Propósito           :  Devuelve los datos de un premio mediante una palabra clave asignada al premio
  -- Input               :  K_PALABRA
  --                        K_TIP_CLI
  --                        K_CODCONTR
  -- Output              :  K_COD_SERVC
  --                        K_ID_PROCLA
  --                        K_COD_TPOPR
  --                        K_PUNTOS
  --                        K_MNT_RECAR
  --                        K_COD_PAQT
  --                        K_CODRET
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  01/12/2010
  -- Fec Actualización   :
  --****************************************************************

  NULO_PALABRA EXCEPTION;
  MAS_REGISTROS EXCEPTION;
  V_COUNT NUMBER;
  V_COUNT2 NUMBER;
  V_ESTADO VARCHAR2(2);
  V_ERRNUM NUMBER;
  V_ERRMSJ VARCHAR2(400);

  N_FLG_OBLIGA NUMBER;
  N_FLG_OPCION NUMBER;
  
    TYPE REC_CANJE_SERV IS RECORD(        
        ADMPV_COD_SERV NUMBER,
        ADMPV_DES_SERV VARCHAR2(120)
     );
  
    vREC_CANJE_SERV REC_CANJE_SERV;
  
    CURSOR CUR_CANJESSERV IS
      SELECT
            ADMPV_COD_SERV,
            ADMPV_DES_SERV  
      FROM 
            ADMPT_CANJE_SERVICIO
      WHERE 
            ADMPV_ESTADO = 1 ORDER BY ADMPV_FLG_ACTIVO DESC;

  BEGIN
    --VALIDANDO PARAMETROS
    IF K_PALABRA IS NULL THEN
       RAISE NULO_PALABRA;
    END IF;

    IF K_TIP_CLI IS NULL THEN
       RAISE NULO_PALABRA;
    END IF;

    IF K_CODCONTR IS NULL THEN
       RAISE NULO_PALABRA;
    END IF;

    IF REPLACE(K_PALABRA, ' ','') IS NULL THEN
       RAISE NULO_PALABRA;
    END IF;

    IF REPLACE(K_TIP_CLI, ' ','') IS NULL THEN
       RAISE NULO_PALABRA;
    END IF;

    IF REPLACE(K_CODCONTR, ' ','') IS NULL THEN
       RAISE NULO_PALABRA;
    END IF;

    SELECT COUNT(*) INTO V_COUNT2
    FROM PCLUB.ADMPT_TIPO_CLIENTE
    WHERE ADMPV_COD_TPOCL=K_TIP_CLI
    AND ADMPC_ESTADO='A';

    IF V_COUNT2<>0 THEN

    SELECT COUNT(*) INTO V_COUNT
    FROM PCLUB.ADMPT_PREMIO P, PCLUB.ADMPT_TIPO_PREMCLIE C
    WHERE P.ADMPV_COD_TPOPR = C.ADMPV_COD_TPOPR
    AND C.ADMPV_COD_TPOCL = K_TIP_CLI
    AND P.ADMPV_CLAVE = K_PALABRA;


    --VALIDANDO EXISTENCIA DE SOLO UN REGISTRO CON LA PALABRA CLAVE INSERTADA COMO PARAMETRO

    IF V_COUNT > 1 THEN
       RAISE MAS_REGISTROS;
    ELSIF V_COUNT = 0 THEN
       RAISE NO_DATA_FOUND;
    END IF;

    IF V_COUNT = 1 THEN

     /* SELECT NVL(P.ADMPN_COD_SERVC,0) ADMPN_COD_SERVC,P.ADMPV_ID_PROCLA,P.ADMPV_COD_TPOPR,P.ADMPN_PUNTOS,P.ADMPN_MNT_RECAR,NVL(P.ADMPV_COD_PAQDAT,0)
       INTO K_COD_SERVC,K_ID_PROCLA,K_COD_TPOPR,K_PUNTOS,K_MNT_RECAR, K_COD_PAQT
       FROM PCLUB.ADMPT_PREMIO P, PCLUB.ADMPT_TIPO_PREMCLIE C
       WHERE P.ADMPV_COD_TPOPR = C.ADMPV_COD_TPOPR
       AND C.ADMPV_COD_TPOCL = K_TIP_CLI
       AND P.ADMPV_CLAVE = K_PALABRA;*/

     SELECT CASE WHEN C.ADMPV_COD_TPOCL='3' THEN 0 ELSE  NVL(P.ADMPN_COD_SERVC,0) END ADMPN_COD_SERVC, P.ADMPV_ID_PROCLA,P.ADMPV_COD_TPOPR,P.ADMPN_PUNTOS,
                   CASE WHEN C.ADMPV_COD_TPOCL='3' OR C.ADMPV_COD_TPOPR='27' THEN  P.ADMPN_MNT_RECAR   ELSE 0    END ADMPN_MNT_RECAR ,
                   CASE WHEN C.ADMPV_COD_TPOCL='3' THEN  NVL(SUBSTR(P.ADMPV_COD_PAQDAT,1, INSTR(P.ADMPV_COD_PAQDAT, ';' ,1)-1),0)  ELSE
                   NVL(SUBSTR(P.ADMPV_COD_PAQDAT, INSTR(P.ADMPV_COD_PAQDAT, ';' , 1) + 1 , LENGTH(P.ADMPV_COD_PAQDAT) - INSTR(P.ADMPV_COD_PAQDAT, ';' ,1) ),0) END ADMPV_COD_PAQDAT
             INTO K_COD_SERVC,K_ID_PROCLA,K_COD_TPOPR,K_PUNTOS,K_MNT_RECAR, K_COD_PAQT
       FROM PCLUB.ADMPT_PREMIO P
             INNER JOIN PCLUB.ADMPT_TIPO_PREMCLIE C ON (P.ADMPV_COD_TPOPR= C.ADMPV_COD_TPOPR)
     WHERE  P.ADMPC_ESTADO='A' AND   C.ADMPV_COD_TPOCL = K_TIP_CLI AND
            P.ADMPV_CLAVE = K_PALABRA;


      IF ((K_TIP_CLI=2) AND (K_COD_TPOPR=27) AND (K_COD_PAQT=0))  THEN
    --IF ((K_TIP_CLI=2) AND (K_COD_TPOPR=5) AND (K_COD_PAQT=0))  THEN

     N_FLG_OBLIGA := 1;
     N_FLG_OPCION := 0;                   

     OPEN CUR_CANJESSERV;
      FETCH CUR_CANJESSERV INTO vREC_CANJE_SERV;
        WHILE CUR_CANJESSERV%FOUND LOOP
          BEGIN
          V_ESTADO:=NULL;
          V_ERRNUM:=NULL;
          V_ERRMSJ:=NULL;
          
             IF N_FLG_OBLIGA = 1 THEN               
               N_FLG_OBLIGA := 0;
                TIM.PKG_CATALOGO_SERVICIOS.CONSULTA_SERVICIO_COMERCIAL@DBL_BSCS(TO_CHAR(K_CODCONTR),vREC_CANJE_SERV.ADMPV_COD_SERV,V_ESTADO,V_ERRNUM,V_ERRMSJ);
          IF ((V_ESTADO<>'A') OR (V_ERRNUM<>0))THEN
             K_CODRET:='4';
             K_DESCERROR:='El servicio no se encuentra Activo.';
                   EXIT;
                END IF;                
             ELSE
               TIM.PKG_CATALOGO_SERVICIOS.CONSULTA_SERVICIO_COMERCIAL@DBL_BSCS(TO_CHAR(K_CODCONTR),vREC_CANJE_SERV.ADMPV_COD_SERV,V_ESTADO,V_ERRNUM,V_ERRMSJ);
                IF ((V_ESTADO='A') AND (V_ERRNUM=0))THEN
                   N_FLG_OPCION := 1;  
                END IF;     
          END IF;

          END;
        FETCH CUR_CANJESSERV INTO vREC_CANJE_SERV;
      END LOOP;
          
      IF N_FLG_OBLIGA = 0 AND N_FLG_OPCION=0 THEN
        K_CODRET:='4';
        K_DESCERROR:='El servicio no se encuentra Activo.';
      END IF;
         /* IF K_CODRET <> '4' THEN
            PKG_CATALOGO_SERVICIOS.CONSULTA_SERVICIO_COMERCIAL@DBL_BSCS(TO_CHAR(K_CODCONTR),367,V_ESTADO,V_ERRNUM,V_ERRMSJ);
            IF ((V_ESTADO<>'A') OR (V_ERRNUM<>0))THEN
               K_CODRET:='4';
               K_DESCERROR:='El servicio no se encuentra Activo.';
            END IF;
          END IF;*/
       END IF;

       IF ((K_CODRET IS NULL) OR (REPLACE(K_CODRET,' ','') IS NULL)) THEN
         K_CODRET:='0';
         K_DESCERROR:=' ';
       END IF;

    END IF;

    END IF;
    COMMIT;

    EXCEPTION

        WHEN NULO_PALABRA THEN
             K_CODRET:='1';
             K_DESCERROR:='Palabra Clave En Blanco';
             ROLLBACK;

        WHEN MAS_REGISTROS THEN
             K_CODRET:='2';
             K_DESCERROR:='Palabra Clave pertenece a más de un premio';
             ROLLBACK;

        WHEN NO_DATA_FOUND THEN
             K_CODRET:='3';
             K_DESCERROR:='Palabra Clave no pertenece a ningún premio';
             ROLLBACK;

        WHEN OTHERS THEN
             K_CODRET:='-1';
             K_DESCERROR:= SUBSTR(SQLERRM,1,250);
             ROLLBACK;

  END ValPalSMS;


procedure ADMPSS_TRANSPUNTOS(K_TELEFORI IN VARCHAR2, K_TIPCLIORI IN VARCHAR2, K_TELEFDES IN VARCHAR2, K_TIPCLIDES IN VARCHAR2, K_PUNTOS IN NUMBER,K_SALDO_CD OUT NUMBER, K_CODRET OUT NUMBER, K_MSJSERROR OUT VARCHAR2)
IS

  --****************************************************************
  -- Nombre SP           :  ADMPSS_TRANSPUNTOS
  -- Propósito           :  Transferir puntos de cliente Prepago para el mismo cliente pero en Postpago.
  -- Input               :  K_TELEFORI
  --                        K_TIPCLIORI
  --                        K_TELEFDES
  --                        K_TIPCLIDES
  --                        K_PUNTOS
  -- Output              :  K_SALDO_CD
  --                        K_CODRET
  --                        K_MSJSERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  01/12/2010
  -- Fec Actualización   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  NO_ORIGEN EXCEPTION;
  NO_DESTINO EXCEPTION;
  SALDO_MENOR EXCEPTION;
  PTS_MENOR EXCEPTION;
  NO_ACTIVORI EXCEPTION;
  NO_ACTIVODES EXCEPTION;
  NO_DOCUMENTO EXCEPTION;

  V_COUNT_OR NUMBER;
  V_COUNT_DES NUMBER;
  --V_COUNT_SALDO NUMBER;
  V_CODERROR VARCHAR2(400);
  V_COD_CPTO VARCHAR2(2);
  V_COUNT_IB NUMBER;
  V_COD_CLI_IB NUMBER;
  V_ESTADO VARCHAR2(2);
  V_TIPDOC_DES VARCHAR2(20);
  V_NUMDOC_DES VARCHAR2(20);
  V_TIPDOC_ORI VARCHAR2(20);
  V_NUMDOC_ORI VARCHAR2(20);
  V_SALDO_ORI NUMBER;
  V_COUNT_SAL NUMBER;

  TYPE TY_CURSOR IS REF CURSOR;
  CURSORDAT_CLIE  TY_CURSOR;

  C_CUENTA VARCHAR2(40);
  C_TIP_DOC VARCHAR2(20);
  C_NUM_DOC VARCHAR2(30);
  C_CO_ID INTEGER;
  C_CI_FAC VARCHAR2(2);
  C_COD_TIP_CL VARCHAR2(10);
  C_TIP_CL VARCHAR2(30);

  V_CUENTADES VARCHAR2(40);
  V_CUENTAORI VARCHAR2(40);


BEGIN

--SE ALMACENA EL CONCEPTO 'TRANSFERENCIA PREPAGO A POSTPAGO'

BEGIN
  SELECT ADMPV_COD_CPTO INTO V_COD_CPTO
  FROM PCLUB.ADMPT_CONCEPTO
  WHERE ADMPV_DESC LIKE '%TRANSFERENCIA PREPAGO A POSTPAGO%';
EXCEPTION
  WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
END;

IF V_COD_CPTO IS NULL THEN
   RAISE NO_CONCEPTO;
END IF;

V_COUNT_OR:=0;
V_ESTADO:=NULL;

--SE VERIFICA SI EXISTE EL CLIENTE ORIGEN
SELECT COUNT(*) INTO V_COUNT_OR
FROM PCLUB.ADMPT_CLIENTE
WHERE ADMPV_COD_CLI=K_TELEFORI
AND ADMPV_COD_TPOCL=K_TIPCLIORI;

IF V_COUNT_OR=0 THEN
   RAISE NO_ORIGEN;
ELSE
   --SE VERIFICA SI ESTA ACTIVO EL CLIENTE ORIGEN
   SELECT ADMPC_ESTADO INTO V_ESTADO
   FROM PCLUB.ADMPT_CLIENTE
   WHERE ADMPV_COD_CLI=K_TELEFORI
   AND ADMPV_COD_TPOCL=K_TIPCLIORI;

   IF V_ESTADO<>'A'THEN
      RAISE NO_ACTIVORI;
   END IF;
END IF;


V_COUNT_DES:=0;
V_ESTADO:=NULL;

--SE VERIFICA SI EXISTE EL CLIENTE DESTINO

   --OBTENER CUENTA DEL CLIENTE DESTINO
   IF K_TIPCLIDES='2' OR K_TIPCLIDES='1' THEN
       PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',K_TELEFDES,V_CODERROR,CURSORDAT_CLIE);
       LOOP
          FETCH CURSORDAT_CLIE
          INTO C_CUENTA,C_TIP_DOC,C_NUM_DOC,C_CO_ID,
          C_CI_FAC,C_COD_TIP_CL,C_TIP_CL;
          EXIT WHEN CURSORDAT_CLIE%NOTFOUND;
          V_CUENTADES:=C_CUENTA;
       END LOOP;
       CLOSE CURSORDAT_CLIE;
    ELSE
       V_CUENTADES:=K_TELEFDES;
    END IF;

SELECT COUNT(*) INTO V_COUNT_DES
FROM PCLUB.ADMPT_CLIENTE
WHERE ADMPV_COD_CLI=V_CUENTADES
AND (ADMPV_COD_TPOCL=K_TIPCLIDES OR ADMPV_COD_TPOCL IN ('1','2'));

IF V_COUNT_DES=0 THEN
   RAISE NO_DESTINO;
ELSE
   --SE VERIFICA SI ESTA ACTIVO EL CLIENTE DESTINO

   SELECT ADMPC_ESTADO INTO V_ESTADO
   FROM PCLUB.ADMPT_CLIENTE
   WHERE ADMPV_COD_CLI=V_CUENTADES
   AND (ADMPV_COD_TPOCL=K_TIPCLIDES OR ADMPV_COD_TPOCL IN ('1','2'));

   IF V_ESTADO<>'A'THEN
      RAISE NO_ACTIVODES;
   END IF;
END IF;

--SE VERIFICA QUE LOS PUNTOS SEAN MAYORES A 0 Y QUE LA SUMA DEL SALDO IB Y CC DEL CLIENTE ORIGEN SEA MAYOR AL REQUERIDO
IF K_PUNTOS>0 THEN

   SELECT SUM(ADMPN_SALDO_CC+ADMPN_SALDO_IB) SALDO INTO V_SALDO_ORI
   FROM PCLUB.ADMPT_SALDOS_CLIENTE SC
   WHERE ADMPN_SALDO_CC+ADMPN_SALDO_IB>=0
   AND ADMPV_COD_CLI IN (SELECT C1.ADMPV_COD_CLI
                         FROM PCLUB.ADMPT_CLIENTE C1, (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                                                FROM PCLUB.ADMPT_CLIENTE
                                                WHERE ADMPV_COD_CLI = K_TELEFORI
                                                AND ADMPV_COD_TPOCL=K_TIPCLIORI
                                                AND ADMPC_ESTADO='A') C2
                         WHERE C1.ADMPV_TIPO_DOC=C2.ADMPV_TIPO_DOC
                               AND C1.ADMPV_NUM_DOC=C2.ADMPV_NUM_DOC
                               AND C1.ADMPV_COD_TPOCL=K_TIPCLIORI
                               AND C1.ADMPC_ESTADO='A'
                               );

   IF V_SALDO_ORI<K_PUNTOS THEN
      RAISE SALDO_MENOR;
   END IF;


ELSE
   RAISE PTS_MENOR;
END IF;

--VERIFICANDO QUE EL NUMERO Y TIPO DE DOCUMENTO DEL CLIENTE ORIGEN Y CLIENTE DESTINO SEAN IGUALES

SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC INTO V_TIPDOC_DES,V_NUMDOC_DES
FROM PCLUB.ADMPT_CLIENTE
WHERE ADMPV_COD_CLI=V_CUENTADES
AND ADMPV_COD_TPOCL=K_TIPCLIDES;

SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC INTO V_TIPDOC_ORI,V_NUMDOC_ORI
FROM PCLUB.ADMPT_CLIENTE
WHERE ADMPV_COD_CLI=K_TELEFORI
AND ADMPV_COD_TPOCL=K_TIPCLIORI;

IF V_TIPDOC_DES=V_TIPDOC_ORI THEN

   IF V_NUMDOC_DES=V_NUMDOC_ORI THEN

    --OBTENER CUENTA DEL CLIENTE ORIGEN
    IF K_TIPCLIORI='2' OR K_TIPCLIORI='1' THEN
       PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',K_TELEFORI,V_CODERROR,CURSORDAT_CLIE);
       LOOP
          FETCH CURSORDAT_CLIE
          INTO C_CUENTA,C_TIP_DOC,C_NUM_DOC,C_CO_ID,
          C_CI_FAC,C_COD_TIP_CL,C_TIP_CL;
          EXIT WHEN CURSORDAT_CLIE%NOTFOUND;
          V_CUENTAORI:=C_CUENTA;
       END LOOP;
       CLOSE CURSORDAT_CLIE;
    ELSE
       V_CUENTAORI:=K_TELEFORI;
    END IF;

    --VERIFICANDO EXISTENCI DE CUENTA DEL CLIENTE EN LA TABLA ADMPT_CLIENTEIB
    SELECT COUNT(*) INTO V_COUNT_IB
    FROM PCLUB.ADMPT_CLIENTEIB
    WHERE ADMPV_COD_CLI=V_CUENTADES
    AND ADMPC_ESTADO='A';

    IF V_COUNT_IB=0 THEN

      --REGISTRANDO LOS PUNTOS DE LA TRANSFERENCIA EN EL KARDEX
      INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
      ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
      VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_CUENTADES,V_COD_CPTO,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
      K_PUNTOS,'E','C',K_PUNTOS,'A');

    ELSE

      SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
      FROM PCLUB.ADMPT_CLIENTEIB
      WHERE ADMPV_COD_CLI=V_CUENTADES
      AND ADMPC_ESTADO='A';

      --REGISTRANDO LOS PUNTOS DE LA TRANSFERENCIA EN EL KARDEX
      INSERT INTO PCLUB.ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
      ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
      VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_CUENTADES,V_COD_CPTO,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
      K_PUNTOS,'E','C',K_PUNTOS,'A');

    END IF;

    --VERIFICANDO SI EXISTE REGISTRO DE SALDO DEL CLIENTE DESTINO

    SELECT COUNT(*) INTO V_COUNT_SAL
    FROM PCLUB.ADMPT_SALDOS_CLIENTE
    WHERE ADMPV_COD_CLI=V_CUENTADES;

    IF V_COUNT_SAL=0 THEN

      --INSERTAMOS EL REGISTRO DE SALDO SI NO EXISTE

      IF V_COUNT_IB = 0 THEN

        --SI NO EXISTE CUENTA IB DEL CLIENTE DESTINO
        INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,
        ADMPN_SALDO_CC,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
        VALUES(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,V_CUENTADES,K_PUNTOS,0,'A');

      ELSE

        --SI EXISTE CUENTE IB DEL CLIENTE DESTINO
        SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
        FROM PCLUB.ADMPT_CLIENTEIB
        WHERE ADMPV_COD_CLI=V_CUENTADES
        AND ADMPC_ESTADO='A';

        INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI
        ,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
        VALUES(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,V_CUENTADES,V_COD_CLI_IB,K_PUNTOS,0,'A');

      END IF;
    ELSE

      --ACTUALIZANDO EL SALDO DEL CLIENTE DESTINO SI EXISTE EL REGISTRO SALDO
      UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
      SET ADMPN_SALDO_CC=K_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0)
                                     FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                     WHERE ADMPV_COD_CLI=V_CUENTADES)
      WHERE ADMPV_COD_CLI=V_CUENTADES;

    END IF;
    --ACTUALIZANDO E INSERTANDO LOS MOVIMIENTOS DEL CLIENTE ORIGEN EN LAS TABLAS DE KARDEX Y SALDOS DEL CLIENTE
    PCLUB.PKG_CC_PREPAGO.ADMPSI_DSCTO_PUNTO(V_CUENTAORI,K_TIPCLIORI,K_PUNTOS,'43','44',K_CODRET,K_MSJSERROR);

   ELSE
    RAISE NO_DOCUMENTO;
   END IF;
  ELSE
  RAISE NO_DOCUMENTO;
 END IF;

SELECT (ADMPN_SALDO_CC+ADMPN_SALDO_IB) SALDO INTO K_SALDO_CD
FROM PCLUB.ADMPT_SALDOS_CLIENTE
WHERE ADMPV_COD_CLI=V_CUENTADES;

COMMIT;
K_CODRET :=0;
K_MSJSERROR:=' ';

EXCEPTION
 WHEN NO_CONCEPTO THEN
   K_CODRET:=55;
   K_MSJSERROR:='No se tiene registrado el parametro de TRANSFERENCIA PREPAGO A POSTPAGO (ADMPT_CONCEPTO).';
   ROLLBACK;

 WHEN NO_ORIGEN THEN
   K_CODRET:=10;
   K_MSJSERROR:='El Cliente enviado como origen NO existe.';
   ROLLBACK;

 WHEN NO_DESTINO THEN
   K_CODRET:=20;
   K_MSJSERROR:='El Cliente enviado como destino NO existe.';
   ROLLBACK;

 WHEN NO_DOCUMENTO THEN
   K_CODRET:=30;
   K_MSJSERROR:='El Cliente Origen y Destino tienen diferente Tipo o Número de Documento.';
   ROLLBACK;

 WHEN NO_ACTIVODES THEN
   K_CODRET:=50;
   K_MSJSERROR:='El Cliente Destino no se encuentra Activo, no se puede hacer transferencia de puntos.';
   ROLLBACK;

 WHEN NO_ACTIVORI THEN
   K_CODRET:=40;
   K_MSJSERROR:='El Cliente Origen no se encuentra Activo, no se puede hacer transferencia de puntos.';
   ROLLBACK;

 WHEN SALDO_MENOR THEN
   K_CODRET:=60;
   K_MSJSERROR:='El saldo del cliente origen es menor que el total de puntos a transferir.';
   ROLLBACK;

 WHEN PTS_MENOR THEN
   K_CODRET:=70;
   K_MSJSERROR:='Los puntos a transferir deben ser mayor que 0.';
   ROLLBACK;

 WHEN OTHERS THEN
   K_CODRET  := -1;
   K_MSJSERROR := SUBSTR(SQLERRM, 1, 250);
   ROLLBACK;

END ADMPSS_TRANSPUNTOS;

procedure ADMPSI_DSCTO_PUNTO(K_COD_CLIENTE IN VARCHAR2, K_TIP_CLI IN VARCHAR2, K_PUNTOS IN NUMBER, K_CONCEPTOCC IN VARCHAR2, K_CONCEPTOIB IN VARCHAR2,K_CODERROR OUT NUMBER, K_MSJERROR OUT VARCHAR2)
is

--****************************************************************
-- Nombre SP           :  ADMPSI_DESC_PUNTOS
-- Propósito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
-- Input               :  K_COD_CLIENTE Codigo de Cliente
--                        K_TIP_CLI Tipo de Cliente
--                        K_PUNTOS Total de Puntos a descontar
--                        K_CONCEPTOCC Concepto CC
--                        K_CONCEPTOIB Concepto IB
-- Output              :  K_CODERROR
--                        K_MSJERROR
-- Creado por          :  (Venkizmet) Rossana Janampa
-- Fec Creación        :  27/09/2010
-- Fec Actualización   :
--****************************************************************

V_PUNTOS_REQUERIDOS      number:=0;


LK_TPO_PUNTO                     char(1);
LK_ID_KARDEX                     number;
LK_SLD_PUNTOS                    number;
LK_COD_CLI                       varchar2(40);
LK_COD_CLIIB                     number;

/* Cursor 1 */
cursor LISTA_KARDEX_1 is
select ka.admpc_tpo_punto, ka.admpn_id_kardex, ka.admpn_sld_punto, ka.admpv_cod_cli, admpn_cod_cli_ib
from PCLUB.admpt_kardex ka
where ka.admpc_estado='A'
and ka.admpc_tpo_oper='E'
and ka.admpn_sld_punto>0
and ka.admpd_fec_trans<=TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')
and ka.admpv_cod_cli in (select CC2.ADMPV_COD_CLI
                         from PCLUB.admpt_cliente CC2, (select ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                                                  from PCLUB.admpt_cliente
                                                  where ADMPV_COD_CLI=K_COD_CLIENTE
                                                  and ADMPV_COD_TPOCL=K_TIP_CLI
                                                  and admpc_estado='A'
                                                   ) CC1 /*Obtiene el numero de doc y su tipo*/
                         where CC2.ADMPV_TIPO_DOC=CC1.ADMPV_TIPO_DOC
                               and CC2.ADMPV_NUM_DOC=CC1.ADMPV_NUM_DOC
                               and CC2.ADMPV_COD_TPOCL=K_TIP_CLI
                               and CC2.admpc_estado='A'
                         ) /*Selecciona todos los codigos que cumplen con la condicion*/
order by decode(admpc_tpo_punto, 'I', 1 ,'L', 2 ,'C', 3), admpn_id_kardex asc;


/* Cursor 3 */
cursor LISTA_KARDEX_3 is
select ka.admpc_tpo_punto, ka.admpn_id_kardex, ka.admpn_sld_punto,  ka.admpv_cod_cli, admpn_cod_cli_ib
from PCLUB.admpt_kardex ka
where ka.admpc_estado='A'
and ka.admpc_tpo_oper='E'
and ka.admpn_sld_punto>0
and ka.admpd_fec_trans<=TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')
and ka.admpv_cod_cli in (select CC2.ADMPV_COD_CLI
                         from PCLUB.admpt_cliente CC2, (select ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                                                  from PCLUB.admpt_cliente
                                                  where ADMPV_COD_CLI=K_COD_CLIENTE
                                                  and (ADMPV_COD_TPOCL=K_TIP_CLI or ADMPV_COD_TPOCL in ('1', '2'))
                                                  and admpc_estado='A'
                                                 ) CC1 /*Obtiene el numero de doc y su tipo*/
                         where CC2.ADMPV_TIPO_DOC=CC1.ADMPV_TIPO_DOC
                               and CC2.ADMPV_NUM_DOC=CC1.ADMPV_NUM_DOC
                               and (CC2.ADMPV_COD_TPOCL=K_TIP_CLI or ADMPV_COD_TPOCL in ('1', '2'))
                               and CC2.admpc_estado='A'
                         ) /*Selecciona todos los codigos que cumplen con la condicion*/
order by decode(admpc_tpo_punto,'I', 1, 'L', 2 ,'C', 3), admpn_id_kardex asc;


begin

/*
Los puntos IB son los q se consumiran primero Tipo de punto 'I'
los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden

*/

K_CODERROR:=0;
K_MSJERROR:='';

V_PUNTOS_REQUERIDOS:=K_PUNTOS;

   -- Comienza el Canje, dato de entrada el codigo de cliente
   if K_COD_CLIENTE is not null then
       if K_TIP_CLI='3' or K_TIP_CLI='4' then -- Clientes Prepago o B2E
         Open LISTA_KARDEX_1;
         fetch LISTA_KARDEX_1 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
         while LISTA_KARDEX_1%found and V_PUNTOS_REQUERIDOS>0
           loop

              if LK_SLD_PUNTOS<=V_PUNTOS_REQUERIDOS then

                -- Actualiza Kardex
                update PCLUB.admpt_kardex
                   set
                       admpn_sld_punto = 0, admpc_estado = 'C'
                 where admpn_id_kardex = LK_ID_KARDEX;

                if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then /* Punto Claro Club */

                    -- Inserta kardex
                    insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                    ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                    values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOCC,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                    LK_SLD_PUNTOS * (-1),'S','C',0,'A');

                    -- Actualiza Saldos_cliente
                    update PCLUB.admpt_saldos_cliente
                       set
                           admpn_saldo_cc = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                    where admpv_cod_cli=LK_COD_CLI)
                     where admpv_cod_cli = LK_COD_CLI;

                else /* Punto IB*/
                  if LK_TPO_PUNTO='I' then

                   -- Inserta kardex

                  insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                  ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                  values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOIB,to_date(to_char(sysdate,'DD/MM/YYYY'),'DD/MM/YYYY'),
                  LK_SLD_PUNTOS * (-1),'S','I',0,'A');

                     -- Actualiza Saldos_cliente
                     update PCLUB.admpt_saldos_cliente
                         set
                             admpn_saldo_ib = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_ib,0) from PCLUB.admpt_saldos_cliente
                                                                 where admpv_cod_cli=K_COD_CLIENTE AND admpn_cod_cli_ib=LK_COD_CLIIB )
                         where admpv_cod_cli=K_COD_CLIENTE AND admpn_cod_cli_ib=LK_COD_CLIIB;

                  end if;
                end if;

                V_PUNTOS_REQUERIDOS:=V_PUNTOS_REQUERIDOS-LK_SLD_PUNTOS;

              else
                if LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS then

                   -- Actualiza Kardex
                   update PCLUB.admpt_kardex
                     set
                         admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                   where admpn_id_kardex = LK_ID_KARDEX;

                    if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then /* Punto Claro Club */

                       -- Inserta kardex

                       insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                       ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                       values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOCC,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                       V_PUNTOS_REQUERIDOS * (-1),'S','C',0,'A');

                       -- Actualiza Saldos_cliente
                       update PCLUB.admpt_saldos_cliente
                           set
                               admpn_saldo_cc = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                        where admpv_cod_cli=LK_COD_CLI)
                         where admpv_cod_cli = LK_COD_CLI;

                    else /* Punto IB*/
                      if LK_TPO_PUNTO='I' then

                         -- Inserta kardex
                         insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                         ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                         values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOIB,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                         V_PUNTOS_REQUERIDOS * (-1),'S','I',0,'A');

                         -- Actualiza Saldos_cliente
                         update PCLUB.admpt_saldos_cliente
                             set
                                 admpn_saldo_ib = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_ib,0) from PCLUB.admpt_saldos_cliente
                                          where admpn_cod_cli_ib=LK_COD_CLIIB AND admpv_cod_cli=K_COD_CLIENTE)
                           where admpn_cod_cli_ib = LK_COD_CLIIB AND admpv_cod_cli=K_COD_CLIENTE;
                       end if;
                    end if;
                    V_PUNTOS_REQUERIDOS:=0;

                end if;
              end if;
              fetch LISTA_KARDEX_1 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
           end loop;
         close LISTA_KARDEX_1;
       else
         if K_TIP_CLI='1' or K_TIP_CLI='2' then
           open LISTA_KARDEX_3;
           fetch LISTA_KARDEX_3 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
           while LISTA_KARDEX_3%found and V_PUNTOS_REQUERIDOS>0
           loop
              if LK_SLD_PUNTOS<=V_PUNTOS_REQUERIDOS then
                -- Actualiza Kardex
                update PCLUB.admpt_kardex
                   set admpn_sld_punto = 0, admpc_estado='C'
                 where admpn_id_kardex = LK_ID_KARDEX;

                -- Actualiza Saldos_cliente
                if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then /* Punto Claro Club */

                    -- Inserta kardex
                    insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                    ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                    values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOCC,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                    LK_SLD_PUNTOS * (-1),'S','C',0,'A');


                    -- Actualiza Saldos_cliente
                    update PCLUB.admpt_saldos_cliente
                       set
                           admpn_saldo_cc = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                    where admpv_cod_cli=LK_COD_CLI)
                     where admpv_cod_cli = LK_COD_CLI;
                else /* Punto IB*/
                  if LK_TPO_PUNTO='I' then

                     -- Inserta kardex
                     insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                     ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                     values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOIB,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                     LK_SLD_PUNTOS * (-1),'S','I',0,'A');

                     -- Actualiza Saldos_cliente
                     update PCLUB.admpt_saldos_cliente
                         set
                             admpn_saldo_ib = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_ib,0) from PCLUB.admpt_saldos_cliente
                                      where admpn_cod_cli_ib=LK_COD_CLIIB AND admpv_cod_cli=K_COD_CLIENTE)
                       where admpn_cod_cli_ib = LK_COD_CLIIB AND admpv_cod_cli=K_COD_CLIENTE;
                   end if;
                end if;
                V_PUNTOS_REQUERIDOS:=V_PUNTOS_REQUERIDOS-LK_SLD_PUNTOS;

              else
                if LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS then

                   update PCLUB.admpt_kardex
                     set
                         admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                   where admpn_id_kardex = LK_ID_KARDEX;

                    if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L'then /* Punto Claro Club */

                        -- Inserta kardex
                        insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                        ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                        values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOCC,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                        V_PUNTOS_REQUERIDOS * (-1),'S','C',0,'A');

                        -- Actualiza Saldos_cliente
                        update PCLUB.admpt_saldos_cliente
                           set
                               admpn_saldo_cc = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                        where admpv_cod_cli=LK_COD_CLI)
                         where admpv_cod_cli = LK_COD_CLI;
                    else /* Punto IB*/
                      if LK_TPO_PUNTO='I' then

                         -- Inserta kardex
                         insert into PCLUB.admpt_kardex(admpn_id_kardex,admpn_cod_cli_ib,admpv_cod_cli,admpv_cod_cpto
                         ,admpd_fec_trans,admpn_puntos,admpc_tpo_oper,admpc_tpo_punto,admpn_sld_punto,admpc_estado)
                         values(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,LK_COD_CLIIB,K_COD_CLIENTE,K_CONCEPTOIB,to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'),
                         V_PUNTOS_REQUERIDOS * (-1),'S','I',0,'A');

                         -- Actualiza Saldos_cliente
                         update PCLUB.admpt_saldos_cliente
                             set
                                 admpn_saldo_ib = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_ib,0) from PCLUB.admpt_saldos_cliente
                                          where admpn_cod_cli_ib=LK_COD_CLIIB AND admpv_cod_cli=K_COD_CLIENTE)
                           where admpn_cod_cli_ib = LK_COD_CLIIB AND admpv_cod_cli=K_COD_CLIENTE;
                       end if;
                    end if;
                    V_PUNTOS_REQUERIDOS:=0;
                end if;
              end if;
              fetch LISTA_KARDEX_3 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
           end loop;
         close LISTA_KARDEX_3;
         else
           if K_TIP_CLI='5' then -- CLIENTES IB que no tienen cuenta en CLARO CLUB
             null;
             -- Aun no definido
            end if;
         end if;
       end if;
   end if;
COMMIT;

exception
  when others then
    K_CODERROR:=SQLCODE;
    K_MSJERROR:=SUBSTR( SQLERRM, 1,400);
    ROLLBACK;

end ADMPSI_DSCTO_PUNTO;

procedure ActCanSMS(K_IDCANJE IN VARCHAR2, K_MSJSMS IN VARCHAR2, K_TICKET IN VARCHAR2, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ActCanSMS
  -- Propósito           :  El proceso debe permitir actualizar los campos de Ticket y Mensaje para un canje existente.
  -- Input               :  K_IDCANJE
  --                        K_MSJSMS
  --                        K_TICKET
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  06/01/2011
  -- Fec Actualización   :
  --****************************************************************

NO_ENCRIPTA EXCEPTION;
NO_PARAMETRO EXCEPTION;

V_TICKET VARCHAR2(40);
V_ID_CANJE NUMBER;
V_AENCRIPTAR VARCHAR2(50);
V_ESTADO BOOLEAN;
V_ENCRIPTADA VARCHAR2(150);

BEGIN

  --VERIFICANDO SI LOS PARAMETROS INGRESADOS ESTAN NULOS O EN BLANCO
  IF K_IDCANJE IS NULL OR REPLACE(K_IDCANJE,' ','') IS NULL THEN
     RAISE NO_PARAMETRO;
  END IF;

  IF K_MSJSMS IS NULL OR REPLACE(K_MSJSMS,' ','') IS NULL THEN
     RAISE NO_PARAMETRO;
  END IF;
  /*
  IF K_TICKET IS NULL AND REPLACE(K_TICKET,' ','') IS NULL THEN
     RAISE NO_PARAMETRO;
  END IF;
  */

  --VERIFICANDO LA EXISTENCIA DEL CANJE
  BEGIN
    IF K_TICKET IS NULL OR REPLACE(K_TICKET,' ','') IS NULL THEN
     SELECT ADMPV_TICKET, ADMPV_ID_CANJE INTO V_TICKET,V_ID_CANJE
     FROM PCLUB.ADMPT_CANJE
     WHERE ADMPV_TICKET IS NULL
     AND ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);
     V_TICKET:=NULL;
    ELSE
     SELECT ADMPV_TICKET, ADMPV_ID_CANJE INTO V_TICKET,V_ID_CANJE
     FROM PCLUB.ADMPT_CANJE
     WHERE ADMPV_TICKET=K_TICKET
     AND ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_TICKET:=NULL;
      V_ID_CANJE:=NULL;
      K_CODERROR:=1;
      K_DESCERROR:='No existe el canje';
  END;

  IF (V_TICKET IS NOT NULL) AND (V_ID_CANJE IS NOT NULL) THEN

     --ENCRIPTANDO EL TICKET
     V_AENCRIPTAR:=V_ID_CANJE||'-'||V_TICKET;

     --VARIABLE A ENCRIPTAR: "ID_CANJE-TICKET"
     /*PENDIENTE*/
      --V_ESTADO:=PCLUB.PKG_CC_SEGURIDAD.ENCRIPTAR_CLAVE(V_AENCRIPTAR,V_ENCRIPTADA);

     IF V_ESTADO THEN
       --SI SE LLEGO A ENCRIPTAR EXITOSAMENTE SE ACTUALIZA LOS CAMPOS ADMPV_TICKET Y ADMPV_MENSAJE DE LA TABLA ADMPT_CANJE
       UPDATE PCLUB.ADMPT_CANJE
       SET ADMPV_TICKET=V_ENCRIPTADA,
       ADMPV_MENSAJE=K_MSJSMS
       WHERE ADMPV_ID_CANJE=V_ID_CANJE;

       K_CODERROR:=0;
       K_DESCERROR:=' ';

     ELSE
       RAISE NO_ENCRIPTA;
     END IF;
  END IF;
  COMMIT;


EXCEPTION

  WHEN NO_PARAMETRO THEN
    K_CODERROR:=1;
    K_DESCERROR:='Los parametros son datos obligatorios';
    ROLLBACK;
  WHEN NO_ENCRIPTA THEN
    K_CODERROR:=1;
    K_DESCERROR:='Error en la encriptacion';
    ROLLBACK;
  WHEN OTHERS THEN
    K_CODERROR:=1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ActCanSMS;

procedure DelCanSMS(K_IDCANJE IN VARCHAR2, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  DelCanSMS
  -- Propósito           :  El proceso debe permitir eliminar los datos de un canje registrado.
  -- Input               :  K_IDCANJE
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Maomed Chocce
  -- Fec Creación        :  28/12/2010
  -- Fec Actualización   :
  --****************************************************************

 NULO_IDCANJE EXCEPTION;
 NO_EXISTE EXCEPTION;

 CURSOR CURSOR_CANJ_KARD IS
 SELECT ADMPN_ID_KARDEX,ADMPN_PUNTOS
 FROM PCLUB.ADMPT_CANJEDT_KARDEX
 WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);

 C_ID_KARDEX NUMBER;
 C_PUNTOS NUMBER;
 V_COD_CLI VARCHAR2(40);
 V_TPO_PUNTO VARCHAR2(2);
 V_ID_KARDEX NUMBER;
 V_COUNT_C NUMBER;

BEGIN
--VERIFICANDO QUE EL PARAMETRO DE ID CANJE NO SEA NULO NI EN BLANCO
IF ((K_IDCANJE IS NULL) OR (REPLACE(K_IDCANJE,' ','') IS NULL)) THEN
   RAISE NULO_IDCANJE;
ELSE
   --VERIFICANDO LA EXISTENCIA DE ID CANJE EN LA TABLA ADMPT_CANJE
   SELECT COUNT(*) INTO V_COUNT_C FROM PCLUB.ADMPT_CANJE WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);
   IF V_COUNT_C=0 THEN
      RAISE NO_EXISTE;
   ELSE

    SELECT ADMPV_COD_CLI INTO V_COD_CLI FROM PCLUB.ADMPT_CANJE WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);

    --ELIMINANDO REGISTROS DE CANJE DETALLE
    DELETE PCLUB.ADMPT_CANJE_DETALLE WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);

    OPEN CURSOR_CANJ_KARD;
    LOOP
    FETCH CURSOR_CANJ_KARD INTO C_ID_KARDEX,C_PUNTOS;
    EXIT WHEN CURSOR_CANJ_KARD%NOTFOUND;

      --ACTUALIZANDO LA SALDO DE PUNTOS DE LA TABLA KARDEX DE ACUERDO CON LA TABLA ADMPT_CANJEDT_KARDEX
      UPDATE PCLUB.ADMPT_KARDEX
      SET ADMPC_ESTADO='A',
      ADMPN_SLD_PUNTO=C_PUNTOS + (SELECT NVL(ADMPN_SLD_PUNTO,0)
                                      FROM PCLUB.ADMPT_KARDEX
                                      WHERE ADMPN_ID_KARDEX=C_ID_KARDEX)
      WHERE ADMPN_ID_KARDEX=C_ID_KARDEX;

      --DE ACUERDO AL TIPO DE PUNTO DE LA TABLA KARDEX SE ACTUALIZA EL SALDO DEL CLIENTE
      --TPO_PUNTO I:MODIFICA SALDO_IB, TPO_PUNTO C o L:MODIFICA SALDO_CC

      V_TPO_PUNTO:=NULL;

      SELECT ADMPC_TPO_PUNTO INTO V_TPO_PUNTO
      FROM PCLUB.ADMPT_KARDEX
      WHERE ADMPN_ID_KARDEX=C_ID_KARDEX;

      IF V_TPO_PUNTO='I' THEN

        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
        SET ADMPC_ESTPTO_IB='A',
        ADMPN_SALDO_IB=C_PUNTOS+(SELECT NVL(ADMPN_SALDO_IB,0)
                                     FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                     WHERE ADMPV_COD_CLI=V_COD_CLI)
        WHERE ADMPV_COD_CLI=V_COD_CLI;

      ELSE --V_TPO_PUNTO='C' O 'L'

        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
        SET ADMPC_ESTPTO_CC='A',
        ADMPN_SALDO_CC=C_PUNTOS+(SELECT NVL(ADMPN_SALDO_CC,0)
                                     FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                     WHERE ADMPV_COD_CLI=V_COD_CLI)
        WHERE ADMPV_COD_CLI=V_COD_CLI;

      END IF;

    END LOOP;

    CLOSE CURSOR_CANJ_KARD;

    --ELIMINACION DE LOS REGISTROS DE LA TABLA ADMPT_CANJEDT_KARDEX,ADMPT_KARDEX Y ADMPT_CANJE
    DELETE PCLUB.ADMPT_CANJEDT_KARDEX WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);

    SELECT ADMPN_ID_KARDEX INTO V_ID_KARDEX
    FROM PCLUB.ADMPT_CANJE
    WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);

    IF V_ID_KARDEX IS NOT NULL THEN
      DELETE PCLUB.ADMPT_KARDEX WHERE ADMPN_ID_KARDEX=V_ID_KARDEX;
    END IF;

    DELETE PCLUB.ADMPT_CANJE WHERE ADMPV_ID_CANJE=TO_NUMBER(K_IDCANJE);

    COMMIT;

    K_CODERROR:=0;
    K_DESCERROR:=' ';

   END IF;
END IF;

EXCEPTION
    WHEN NULO_IDCANJE THEN
      K_CODERROR:=-1;
      K_DESCERROR:='El ID Canje es un dato obligatorio.';
      ROLLBACK;

    WHEN NO_EXISTE THEN
      K_CODERROR:=-1;
      K_DESCERROR:='El ID del Canje No existe.';
      ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR:=-1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END DelCanSMS;

PROCEDURE ADMPSI_CARGA_CLIENTE(K_FECHA IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PRECARGAIN
  -- Propósito           :  Registrar los clientes prepago que deben ser insertados como carga inicial de datos.
  -- Input               :  K_FECHA
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  24/11/2010
  -- Fec Actualización   :
  --****************************************************************
  V_COUNT                NUMBER;
  V_TIPODOC              NUMBER;
  V_EXIST                NUMBER;

  CURSOR CUR_LINEASXCLI(tipodoc VARCHAR2, num_doc VARCHAR2)is
    select D.MSISDN,D.S_FIRST_NAME,D.S_LAST_NAME,D.X_SEXO,D.DEPARTAMENTO,D.FIRSTCALLDATE
      from dm.BASE_ABONADOS_CLARO@dbl_reptdm_d D
     where UPPER(D.X_DOC_TYPE) = (SELECT UPPER(A.ADMPV_EQU_DWH) FROM ADMPT_TIPO_DOC A WHERE A.ADMPV_COD_TPDOC = tipodoc)
       and D.X_DOC_NUM=num_doc
       AND TIPO_ABONADO = 1
       AND ESTADO IN ( 'ACTIVE','ACTIVO','GRACE');

  CURSOR CUR_TMP_CLIENTE IS
     SELECT J.ADMPV_TIPO_DOC,J.ADMPV_NUM_DOC
     FROM ADMPT_TMP_PRECARGAIN J WHERE J.ADMPD_FEC_OPER = K_FECHA AND J.ADMPV_MSJE_ERROR IS NULL;

  CURSOR CUR_X IS
     SELECT T.ADMPV_TIPO_DOC,T.ADMPV_NUM_DOC,T.ADMPV_MSJE_ERROR
     FROM ADMPT_TMP_PRECARGAIN T
     WHERE T.ADMPD_FEC_OPER=K_FECHA;

  BEGIN

     BEGIN

         UPDATE ADMPT_TMP_PRECARGAIN T
         SET T.ADMPV_MSJE_ERROR = 'Número de Teléfono es un dato obligatorio.',T.ADMPD_FEC_OPER=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
         WHERE T.ADMPV_TIPO_DOC IS NULL OR REPLACE(T.ADMPV_TIPO_DOC, ' ', '') IS NULL
         AND T.ADMPV_NUM_DOC IS NULL OR REPLACE(T.ADMPV_NUM_DOC, ' ', '') IS NULL;

         UPDATE ADMPT_TMP_PRECARGAIN T
         SET ADMPV_MSJE_ERROR = 'Cliente no existe en DWH. No se va insertar.',ADMPD_FEC_OPER=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
         WHERE not exists (SELECT '1' FROM dm.BASE_ABONADOS_CLARO@dbl_reptdm_d
                                  WHERE TIPO_ABONADO=1 AND ESTADO IN ( 'ACTIVE','ACTIVO','GRACE')
                                  AND X_DOC_NUM = T.ADMPV_NUM_DOC AND
                                  UPPER(X_DOC_TYPE) = (SELECT UPPER(A.ADMPV_EQU_DWH) FROM ADMPT_TIPO_DOC A WHERE A.ADMPV_COD_TPDOC = T.ADMPV_TIPO_DOC));

         COMMIT;
     END;

     BEGIN
      FOR A IN CUR_TMP_CLIENTE LOOP
           FOR R IN CUR_LINEASXCLI(A.ADMPV_TIPO_DOC,A.ADMPV_NUM_DOC) LOOP
               SELECT NVL(COUNT(*),0) INTO V_COUNT FROM ADMPT_CLIENTE C
               where C.ADMPV_COD_CLI=SUBSTR(R.MSISDN,3,9);

               IF V_COUNT = 0 THEN
                  /*UPDATE ADMPT_TMP_PRECARGAIN T
                  SET ADMPV_MSJE_ERROR = 'Cliente ya existe. No se va insertar.',ADMPD_FEC_OPER=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')
                  WHERE T.ADMPV_NUM_DOC= A.ADMPV_NUM_DOC AND T.ADMPV_TIPO_DOC = A.ADMPV_TIPO_DOC;*/
               --RECUERDA SE MODIFICO LA CATEGORIA DEL CLIENTE
                  INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,
                  ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
                  ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPV_CICL_FACT,ADMPC_ESTADO,ADMPV_COD_TPOCL)
                  VALUES(SUBSTR(R.MSISDN,3,9),NULL,'2',A.ADMPV_TIPO_DOC,A.ADMPV_NUM_DOC,R.S_FIRST_NAME,R.S_LAST_NAME,
                  R.X_SEXO,NULL,NULL,NULL,R.DEPARTAMENTO,NULL,R.FIRSTCALLDATE,NULL,'A','3');

                  INSERT INTO ADMPT_IMP_PRECARGACLI
                    (admpv_tipo_doc, admpv_num_doc, admpv_msisdn, admpd_fec_oper)
                  VALUES
                    (A.ADMPV_TIPO_DOC, A.ADMPV_NUM_DOC, SUBSTR(R.MSISDN,3,9), SYSDATE);

                  SELECT NVL(COUNT(*),0) INTO V_EXIST
                  FROM ADMPT_SALDOS_CLIENTE S
                  WHERE S.ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);

                  IF V_EXIST = 0 THEN
                     INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
                      ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB)
                     VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,SUBSTR(R.MSISDN,3,9),NULL,0,0,'A',NULL);
                  ELSE
                     UPDATE ADMPT_SALDOS_CLIENTE
                     SET ADMPN_SALDO_IB = 0,
                         ADMPN_SALDO_CC = 0
                     WHERE ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);
                  END IF;
               END IF;
          END LOOP;
       END LOOP;
       COMMIT;

     END;
     BEGIN
         --todos los registros y como fue procesado
        FOR X IN CUR_X LOOP
          INSERT INTO ADMPT_IMP_PRECARGAIN(ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
          VALUES(X.ADMPV_TIPO_DOC,X.ADMPV_NUM_DOC,SYSDATE,X.ADMPV_MSJE_ERROR);
        END LOOP;

        -- Obtenemos los registros totales, procesados y con error
        SELECT COUNT (*) INTO K_NUMREGTOT FROM ADMPT_TMP_PRECARGAIN WHERE ADMPD_FEC_OPER=K_FECHA;
        SELECT COUNT (*) INTO K_NUMREGERR FROM ADMPT_TMP_PRECARGAIN WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR Is Not null);
        SELECT COUNT (*) INTO K_NUMREGPRO FROM ADMPT_TMP_PRECARGAIN WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR Is null or ADMPV_MSJE_ERROR = '');

        -- Eliminamos los registros de la tabla temporal y auxiliar
        DELETE ADMPT_TMP_PRECARGAIN  WHERE ADMPD_FEC_OPER=K_FECHA;

        COMMIT;

     END;

  K_CODERROR:=0;
  K_DESCERROR:=' ';

  EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;
END ADMPSI_CARGA_CLIENTE;

PROCEDURE ADMPSI_CARGA_MICLARO(K_FECHA IN DATE,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PRECARGAIN
  -- Propósito           :  Registrar los clientes prepago que deben ser insertados como carga inicial de datos.
  -- Input               :  K_FECHA
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  24/11/2010
  -- Fec Actualización   :
  --****************************************************************
V_COUNT                NUMBER;
V_CONT                 NUMBER;
V_EXIST                NUMBER;
V_TIPDOC               NUMBER;

/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
/*CUPONERAVIRTUAL - JCGT FIN*/

CURSOR CUR_INTERACCIONES is
  select distinct I.PHONE,C.X_DOC_NUM,C.X_DOC_TYPE
  from table_interact@dbl_clarify i,
       table_x_plus_inter@dbl_clarify a,
       table_contact@dbl_clarify c
  where i.s_reason_1='PREPAGO'
  AND i.s_reason_2='VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
  AND i.s_reason_3='REGISTRO / ACTUALIZACIÓN DE DATOS'
  AND i.s_Agent='USRCEL'
  and a.x_plus_inter2interact = i.objid
  and i.interact2contact = c.objid
  AND c.x_contact_status = 'Activo'
  AND (i.create_date >= K_FECHA AND i.create_date < K_FECHA + 1 );

CURSOR CUR_LINEASXCLI(TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2)is
    select D.MSISDN,D.S_FIRST_NAME,D.S_LAST_NAME,D.X_SEXO,D.DEPARTAMENTO,D.FIRSTCALLDATE
      from dm.BASE_ABONADOS_CLARO@dbl_reptdm_d D
     where UPPER(D.X_DOC_TYPE) = UPPER(TIPO_DOC)
       and D.X_DOC_NUM=NUM_DOC
       AND TIPO_ABONADO = 1
       AND (ESTADO = 'ACTIVE' OR ESTADO = 'ACTIVO' OR ESTADO = 'GRACE');

BEGIN
  FOR A IN CUR_INTERACCIONES LOOP

    SELECT COUNT(*) INTO V_COUNT FROM dm.BASE_ABONADOS_CLARO@dbl_reptdm_d
    WHERE TIPO_ABONADO=1 AND (ESTADO = 'ACTIVE' OR ESTADO = 'ACTIVO' OR ESTADO = 'GRACE')
    AND X_DOC_NUM = A.X_DOC_NUM AND
    UPPER(X_DOC_TYPE) = UPPER(A.X_DOC_TYPE);

    SELECT E.ADMPV_COD_TPDOC INTO V_TIPDOC
    FROM ADMPT_TIPO_DOC E
    WHERE UPPER(E.ADMPV_DSC_DOCUM) = UPPER(A.X_DOC_TYPE);

    IF V_COUNT = 0 THEN

      SELECT NVL(COUNT(*),0) INTO V_CONT
      FROM ADMPT_AUX_CARGAMICLARO X
      WHERE X.ADMPV_TIPO_DOC = A.X_DOC_TYPE
      AND X.ADMPV_NUM_DOC = A.X_DOC_NUM
      AND X.ADMPD_FECHA=TRUNC(SYSDATE);

      IF V_CONT = 0 THEN
        INSERT INTO ADMPT_IMP_CARGAMICLARO(ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPD_FEC_OPER,ADMPN_COD_ERROR)
        VALUES(V_TIPDOC,A.X_DOC_NUM,A.PHONE,SYSDATE,1);
        COMMIT;
      END IF;
    ELSE
      FOR R IN CUR_LINEASXCLI(A.X_DOC_TYPE,A.X_DOC_NUM) LOOP
        SELECT NVL(COUNT(*),0) INTO V_CONT
        FROM ADMPT_AUX_CARGAMICLARO X
        WHERE X.ADMPV_MSISDN=SUBSTR(R.MSISDN,3,9)
        AND X.ADMPD_FECHA=TRUNC(SYSDATE);

        IF V_CONT = 0 THEN
         BEGIN
           SELECT NVL(COUNT(*),0) INTO V_COUNT
           FROM ADMPT_CLIENTE C
           where C.ADMPV_COD_CLI=SUBSTR(R.MSISDN,3,9);

           IF V_COUNT > 0 THEN
              INSERT INTO ADMPT_IMP_CARGAMICLARO(ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPD_FEC_OPER,ADMPN_COD_ERROR)
              VALUES(V_TIPDOC,A.X_DOC_NUM,SUBSTR(R.MSISDN,3,9),SYSDATE,2);

              INSERT INTO ADMPT_AUX_CARGAMICLARO(ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPD_FECHA)
              VALUES(V_TIPDOC,A.X_DOC_NUM,SUBSTR(R.MSISDN,3,9),SYSDATE);

              COMMIT;
           ELSE
              INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,
              ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
              ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPV_CICL_FACT,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
              VALUES(SUBSTR(R.MSISDN,3,9),NULL,'2',V_TIPDOC,A.X_DOC_NUM,R.S_FIRST_NAME,R.S_LAST_NAME,
              R.X_SEXO,NULL,NULL,NULL,R.DEPARTAMENTO,NULL,R.FIRSTCALLDATE,NULL,'A','3',SYSDATE,'USRMICLARO');


              INSERT INTO ADMPT_IMP_CARGAMICLARO(ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPD_FEC_OPER,ADMPN_COD_ERROR)
              VALUES(V_TIPDOC,A.X_DOC_NUM,SUBSTR(R.MSISDN,3,9),SYSDATE,NULL);

              INSERT INTO ADMPT_AUX_CARGAMICLARO(ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPD_FECHA)
              VALUES(V_TIPDOC,A.X_DOC_NUM,SUBSTR(R.MSISDN,3,9),SYSDATE);

              SELECT NVL(COUNT(*),0) INTO V_EXIST
              FROM ADMPT_SALDOS_CLIENTE S
              WHERE S.ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);

              IF V_EXIST = 0 THEN
                 INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
                  ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB)
                 VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,SUBSTR(R.MSISDN,3,9),'',0,0,'A','');
              ELSE
                 UPDATE ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_IB = 0,
                     ADMPN_SALDO_CC = 0
                 WHERE ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);
              END IF;

              COMMIT;
           END IF;
         END;

         /*CUPONERAVIRTUAL - JCGT INI*/
          PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(V_TIPDOC,A.X_DOC_NUM,R.S_FIRST_NAME,R.S_LAST_NAME,NULL,'ALTA','USRPREPAGO',C_CODERROR,C_DESCERROR);
          /*CUPONERAVIRTUAL - JCGT FIN*/

        END IF;
       END LOOP;
    END IF;
  END LOOP;
  SELECT COUNT (*) INTO K_NUMREGTOT FROM ADMPT_IMP_CARGAMICLARO WHERE ADMPD_FEC_OPER>=TRUNC(SYSDATE);
  SELECT COUNT (*) INTO K_NUMREGERR FROM ADMPT_IMP_CARGAMICLARO WHERE ADMPD_FEC_OPER>=TRUNC(SYSDATE) AND (ADMPN_COD_ERROR IS NOT NULL);
  SELECT COUNT (*) INTO K_NUMREGPRO FROM ADMPT_IMP_CARGAMICLARO WHERE ADMPD_FEC_OPER>=TRUNC(SYSDATE) AND (ADMPN_COD_ERROR IS NULL OR ADMPN_COD_ERROR = '');

  DELETE ADMPT_AUX_CARGAMICLARO;
  COMMIT;

K_CODERROR := 0;
K_DESCERROR := '';

EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;

END ADMPSI_CARGA_MICLARO;

PROCEDURE ADMPSS_VALIDAR_CLIENTECC(K_NUMERO IN VARCHAR2,K_MENSAJE OUT VARCHAR2,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
IS
V_COUNT NUMBER;
BEGIN

   SELECT NVL(COUNT(*),0) INTO V_COUNT
   FROM ADMPT_CLIENTE
   WHERE ADMPV_COD_CLI = K_NUMERO;

   IF V_COUNT > 0 THEN
      K_MENSAJE := 'CC';
   ELSE
      K_MENSAJE := '';
   END IF;

K_CODERROR := 0;
K_DESCERROR := 'OK';

EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;
END ADMPSS_VALIDAR_CLIENTECC;

PROCEDURE ADMPSS_REGISTRO_CLIENTECC (K_TELEFONO VARCHAR2,K_TIPO_DOC VARCHAR2,K_NRO_DOC VARCHAR2,K_USUARIO VARCHAR2,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
IS
V_TIPO_DOC VARCHAR(50);
V_TDOC_CC  VARCHAR(20);
V_COUNT NUMBER;
F_COUNT NUMBER;
/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
/*CUPONERAVIRTUAL - JCGT FIN*/

CURSOR CUR_LINEASXCLI(NRO_TELF VARCHAR2,TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2) IS
SELECT D.MSISDN,D.S_FIRST_NAME,D.S_LAST_NAME,D.X_SEXO,D.DEPARTAMENTO,D.FIRSTCALLDATE FROM (
  select D.MSISDN,D.NOMBRES AS S_FIRST_NAME,D.APELLIDOS AS S_LAST_NAME,D.SEXO AS X_SEXO,
  T.DESCDEPARTAMENTO AS DEPARTAMENTO,D.FCH_ACTIVACION AS FIRSTCALLDATE
  from dm.f_m_abonados@dbl_reptdm_d D inner join dm.dw_sus_d_departamento@dbl_reptdm_d T
  on D.IDDEPARTAMENTO = T.IDDEPARTAMENTO where D.MSISDN = NRO_TELF
  AND UPPER(D.TIPO_DOCUMENTO) = UPPER(K_TIPO_DOC)
  and D.NRO_DOCUMENTO=K_NRO_DOC
  AND d.idsegmento = 1
  and d.idestado in (2, 3)
  ORDER BY D.MES DESC) D WHERE ROWNUM = 1;

BEGIN

    SELECT COUNT(A.ADMPV_COD_TPDOC) INTO V_COUNT
    FROM ADMPT_TIPO_DOC A
    WHERE UPPER(A.ADMPV_EQU_DWH) = K_TIPO_DOC;

    IF V_COUNT = 0 THEN
        K_CODERROR := 1;
        K_DESCERROR := 'Documento no existe en DWH';
    ELSE
        SELECT A.ADMPV_DSC_DOCUM,A.ADMPV_COD_TPDOC INTO V_TIPO_DOC,V_TDOC_CC
        FROM ADMPT_TIPO_DOC A
        WHERE UPPER(A.ADMPV_EQU_DWH) = K_TIPO_DOC;

        select COUNT(D.MSISDN) INTO V_COUNT
       from dm.f_m_abonados@dbl_reptdm_d D
       where UPPER(D.TIPO_DOCUMENTO) = UPPER(K_TIPO_DOC)
       and D.NRO_DOCUMENTO=K_NRO_DOC
       AND d.idsegmento = 1
      and d.idestado in (2, 3);

       IF V_COUNT > 0 THEN

  SELECT COUNT(*) INTO V_COUNT FROM ADMPT_CLIENTE D
  WHERE D.ADMPV_NUM_DOC= K_NRO_DOC
  AND D.ADMPV_COD_TPOCL = 3
  AND D.ADMPC_ESTADO='A';

       SELECT ADMPV_VALOR INTO F_COUNT FROM PCLUB.Admpt_paramsist WHERE ADMPC_COD_PARAM = '250'; 

      IF V_COUNT >= F_COUNT THEN
          K_CODERROR := 2;
          K_DESCERROR := 'Tiene ' || V_COUNT || ' lineas afiliadas';
       ELSE          
            FOR R IN CUR_LINEASXCLI(K_TELEFONO,K_TIPO_DOC,K_NRO_DOC) LOOP
             BEGIN
               SELECT NVL(COUNT(*),0) INTO V_COUNT
               FROM ADMPT_CLIENTE C
               where C.ADMPV_COD_CLI=SUBSTR(R.MSISDN,3,9);

               IF V_COUNT = 0 THEN

                  INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,
                  ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
                  ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPV_CICL_FACT,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                  VALUES(SUBSTR(R.MSISDN,3,9),NULL,'2',V_TDOC_CC,K_NRO_DOC,R.S_FIRST_NAME,R.S_LAST_NAME,
                  R.X_SEXO,NULL,NULL,NULL,R.DEPARTAMENTO,NULL,R.FIRSTCALLDATE,NULL,'A','3',SYSDATE,K_USUARIO);

                  SELECT NVL(COUNT(*),0) INTO V_COUNT
                  FROM ADMPT_SALDOS_CLIENTE S
                  WHERE S.ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);

                  IF V_COUNT = 0 THEN
                     INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
                      ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
                     VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,SUBSTR(R.MSISDN,3,9),'',0,0,'A','',SYSDATE);
                  ELSE
                     UPDATE ADMPT_SALDOS_CLIENTE
                     SET ADMPN_SALDO_IB = 0,
                         ADMPN_SALDO_CC = 0
                     WHERE ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);
                  END IF;

                 /*CUPONERAVIRTUAL - JCGT INI*/
                  PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(V_TDOC_CC,K_NRO_DOC,R.S_FIRST_NAME,R.S_LAST_NAME,NULL,'ALTA','USRPREPAGO',C_CODERROR,C_DESCERROR);
                  /*CUPONERAVIRTUAL - JCGT FIN*/
                  COMMIT;
               END IF;
             END;
          END LOOP;
          K_CODERROR := 0;
          K_DESCERROR := 'OK';
          
       END IF;
          
       ELSE
          K_CODERROR := 1;
          K_DESCERROR := 'No existen líneas prepago para ese cliente';
          COMMIT;
       END IF;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;

END ADMPSS_REGISTRO_CLIENTECC;

PROCEDURE ADMPSS_VALCCPREP(K_TELEFONO IN VARCHAR,
                           K_TIP_CLIENTE IN VARCHAR,
                           K_RESPUESTA OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2,
                           K_MSJSIST OUT VARCHAR2)
  IS
  /*--****************************************************************
  -- Nombre SP           :  ADMPSS_VALCCPREP
  -- Propósito           :  Validar si el cliente CC se encuentra registrado
  -- Input               :  K_TELEFONO
                            K_TIP_CLIENTE
  -- Output              :  K_RESPUESTA
  --                        K_DESCERROR
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  10/11/2010
  -- Fec Actualización   :
  --*****************************************************************/
   V_COUNT NUMBER;
   K_RESPUESTA1 NUMBER;
   BEGIN

   SELECT COUNT(A.ADMPV_COD_CLI) INTO V_COUNT
   FROM PCLUB.ADMPT_CLIENTE A
   WHERE A.ADMPV_COD_CLI = K_TELEFONO
   AND A.ADMPV_COD_TPOCL = K_TIP_CLIENTE;

   IF V_COUNT > 0 THEN
      K_RESPUESTA := 1;
      PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGCCPRESMSFALLO',K_DESCERROR,K_RESPUESTA1,K_MSJSIST);
   ELSE
      K_RESPUESTA := 0;
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
     K_RESPUESTA := 1;
     PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGCCPRESMSERROR',K_DESCERROR,K_RESPUESTA1,K_MSJSIST);
     K_MSJSIST:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;
END ADMPSS_VALCCPREP;

PROCEDURE ADMPSI_REGCLIENTESMS(K_TELEFONO IN VARCHAR,
                           K_USUARIO     IN VARCHAR,
                           K_MENSAJE     OUT VARCHAR,
                           K_RESPUESTA   OUT NUMBER,
                           K_DESCERROR   OUT VARCHAR2)
  IS
  /*--****************************************************************
  -- Nombre SP           :  AMPSI_REGCLIENTESMS
  -- Propósito           :  Registrar al cliente CC
  -- Input               :  K_TELEFONO
                            K_USUARIO
  -- Output              :  K_MENSAJE
                            K_RESPUESTA
  --                        K_DESCERROR
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  11/11/2010
  -- Fec Actualización   :
  --*****************************************************************/
  V_DOC_TYPE                VARCHAR2(100);
  V_DOC_CC                  VARCHAR2(20);
  V_NUM_DOC                 VARCHAR2(100);
  V_COUNT                   NUMBER;
  V_EXIST                   NUMBER;
  V_CORR_IMP                NUMBER;
  V_RESPUESTA               VARCHAR(2);
  V_DESCERROR               VARCHAR2(100);

   /*CUPONERAVIRTUAL - JCGT INI*/
    C_CODERROR NUMBER;
    C_DESCERROR VARCHAR2(200);
   /*CUPONERAVIRTUAL - JCGT FIN*/

  CURSOR CUR_LINEASXCLI(NRO_TELF VARCHAR2, TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2)IS
SELECT D.MSISDN,D.S_FIRST_NAME,D.S_LAST_NAME,D.X_SEXO,D.DEPARTAMENTO,D.FIRSTCALLDATE
FROM (
  select D.MSISDN,D.NOMBRES AS S_FIRST_NAME,D.APELLIDOS AS S_LAST_NAME,D.SEXO AS X_SEXO,
  T.DESCDEPARTAMENTO AS DEPARTAMENTO,D.FCH_ACTIVACION AS FIRSTCALLDATE
  from dm.f_m_abonados@dbl_reptdm_d D inner join dm.dw_sus_d_departamento@dbl_reptdm_d T
  on D.IDDEPARTAMENTO = T.IDDEPARTAMENTO where D.MSISDN = NRO_TELF
  AND UPPER(D.TIPO_DOCUMENTO) = UPPER(TIPO_DOC)
  and D.NRO_DOCUMENTO=NUM_DOC
  AND d.idsegmento = 1
  and d.idestado in (2, 3)
  ORDER BY D.MES DESC) D WHERE ROWNUM = 1;

  BEGIN

  SELECT ADMPT_IMP_CCVIASMS_SQ.NEXTVAL INTO V_CORR_IMP
  FROM DUAL;

  SELECT TIPO_DOCUMENTO, NRO_DOCUMENTO INTO V_DOC_TYPE,V_NUM_DOC
  FROM(
  SELECT D.TIPO_DOCUMENTO, D.NRO_DOCUMENTO
  FROM  dm.f_m_abonados@dbl_reptdm_d D
  WHERE D.MSISDN = '51'||K_TELEFONO
  AND d.idestado in (2, 3)
  order by D.MES desc
  ) WHERE   ROWNUM =1;
  
  SELECT A.ADMPV_COD_TPDOC INTO V_DOC_CC
  FROM ADMPT_TIPO_DOC A
  WHERE UPPER(A.ADMPV_DSC_DOCUM) = UPPER(V_DOC_TYPE);

  SELECT COUNT(D.ADMPV_COD_CLI) INTO V_COUNT
  FROM ADMPT_CLIENTE D
  WHERE D.ADMPV_NUM_DOC = V_NUM_DOC
  AND D.ADMPV_TIPO_DOC = V_DOC_CC
  AND D.ADMPV_COD_TPOCL = '3'
  AND D.ADMPV_COD_CLI=K_TELEFONO
  AND D.ADMPC_ESTADO='A';

  IF V_COUNT > 0 THEN
     K_RESPUESTA := 0;
     PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGCCPRESMSFALLO',K_MENSAJE,K_RESPUESTA,K_DESCERROR);
  ELSE
     SELECT COUNT(*) INTO V_COUNT
     FROM  dm.f_m_abonados@dbl_reptdm_d D
     WHERE D.TIPO_DOCUMENTO = V_DOC_TYPE
     AND  D.NRO_DOCUMENTO = V_NUM_DOC
     AND D.idsegmento = 1
     AND D.idestado in (2, 3);

     IF V_COUNT > 0 THEN
     FOR R IN CUR_LINEASXCLI(K_TELEFONO, V_DOC_TYPE,V_NUM_DOC) LOOP
         SELECT NVL(COUNT(*),0) INTO V_COUNT FROM ADMPT_CLIENTE C
         where C.ADMPV_COD_CLI=SUBSTR(R.MSISDN,3,9)
         AND C.ADMPV_COD_TPOCL = '3'
         AND C.ADMPC_ESTADO='A';

         IF V_COUNT > 0 THEN
            INSERT INTO ADMPT_IMP_CCVIASMS
            (ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPV_MSJE_ERROR,ADMPV_USER_REG,ADMPD_FEC_REG,ADMPN_CORRELATIVO)
            VALUES
            (V_DOC_CC,V_NUM_DOC,R.MSISDN,'Cliente ya existe. No se va insertar.',K_USUARIO,SYSDATE,V_CORR_IMP);
         ELSE
            INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,
            ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
            ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPV_CICL_FACT,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
            VALUES(SUBSTR(R.MSISDN,3,9),NULL,NULL,V_DOC_CC,V_NUM_DOC,R.S_FIRST_NAME,R.S_LAST_NAME,
            R.X_SEXO,NULL,NULL,NULL,R.DEPARTAMENTO,NULL,R.FIRSTCALLDATE,NULL,'A','3',SYSDATE,K_USUARIO);

            SELECT NVL(COUNT(*),0) INTO V_EXIST
            FROM ADMPT_SALDOS_CLIENTE S
            WHERE S.ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);

            IF V_EXIST = 0 THEN
               INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,
               ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB)
               VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,SUBSTR(R.MSISDN,3,9),NULL,0,0,'A',NULL);
            ELSE
               UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_IB = 0,
                   ADMPN_SALDO_CC = 0
               WHERE ADMPV_COD_CLI = SUBSTR(R.MSISDN,3,9);
            END IF;

            INSERT INTO ADMPT_IMP_CCVIASMS
            (ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_MSISDN,ADMPV_MSJE_ERROR,ADMPV_USER_REG,ADMPD_FEC_REG,ADMPN_CORRELATIVO)
            VALUES
            (V_DOC_CC,V_NUM_DOC,R.MSISDN,'',K_USUARIO,SYSDATE,V_CORR_IMP);

         END IF;

         /*CUPONERAVIRTUAL - JCGT INI*/
            PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(V_DOC_CC,V_NUM_DOC,R.S_FIRST_NAME,R.S_LAST_NAME,NULL,'ALTA','USRPREPAGO',C_CODERROR,C_DESCERROR);
           /*CUPONERAVIRTUAL - JCGT FIN*/

    END LOOP;
    COMMIT;
          K_RESPUESTA := 0;
          K_DESCERROR := 'OK';
          PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGCCPRESMSEXITO',K_MENSAJE,V_RESPUESTA,V_DESCERROR);

     ELSE
    K_RESPUESTA := 0;
         K_DESCERROR := 'No existen datos para procesar.';
         PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGCCPRESMSERROR',K_MENSAJE,V_RESPUESTA,V_DESCERROR);

     END IF;



  END IF;

  EXCEPTION
    WHEN OTHERS THEN
     K_RESPUESTA := 1;
     PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGCCPRESMSERROR',K_MENSAJE,V_RESPUESTA,V_DESCERROR);
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;
END ADMPSI_REGCLIENTESMS;

PROCEDURE ADMPSI_REGCLIENTECC(K_COD_CLIENTE IN VARCHAR,
                           K_FEC_ENVIO     IN DATE,
                           K_RESULTADO     IN VARCHAR2,
                           K_MENSAJE       IN VARCHAR2,
                           K_USUARIO       IN VARCHAR2,
                           K_CODERROR      OUT NUMBER,
                           K_DESCERROR     OUT VARCHAR2)
  IS
  /*--****************************************************************
  -- Nombre SP           :  ADMPSI_REGCLIENTECC
  -- Propósito           :  Registrar al admpt_reg_clientecc
  -- Input               :  K_COD_CLIENTE
                            K_FEC_ENVIO
  --                        K_RESULTADO
                            K_MENSAJE
                            K_USUARIO
  -- Output              :  K_RESPUESTA
  --                        K_DESCERROR
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  07/12/2010
  -- Fec Actualización   :
  --*****************************************************************/
  BEGIN

  INSERT INTO ADMPT_REGCLIENTECC(ADMPN_ID_REG,ADMPV_COD_CLI,ADMPD_FECH_ENVIO,ADMPV_RESULTADO,
                                 ADMPV_MENSAJE,ADMPD_FEC_REG,ADMPV_USU_REG)
  VALUES(ADMPT_REGCLIENTECC_SQ.NEXTVAL,K_COD_CLIENTE,K_FEC_ENVIO,K_RESULTADO,K_MENSAJE,SYSDATE,K_USUARIO);

  COMMIT;

  K_CODERROR := 0;
  K_DESCERROR:='OK';

  EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= 1;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;
END ADMPSI_REGCLIENTECC;


 PROCEDURE ADMPSS_CATEG_PRERECARGA(K_CODERROR       OUT NUMBER,
                                    K_DESCERROR      OUT VARCHAR2) IS
  V_CONTADOR NUMBER;
  V_CAT_MAX NUMBER;
  V_NUM_REG NUMBER;


  BEGIN
    K_CODERROR:=0;
    K_DESCERROR:=0;
    V_CONTADOR:=0;
    V_CAT_MAX:=20;


    SELECT COUNT(C.ADMPV_COD_CLI)
    INTO V_NUM_REG
    FROM PCLUB.ADMPT_TMP_PRERECARGA C;

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

END ADMPSS_CATEG_PRERECARGA;


   PROCEDURE ADMPSS_SERVICIO_COMERCIAL(CURSORSERVICIO out SYS_REFCURSOR,
                                    K_CODERROR       OUT NUMBER,
                                    K_DESCERROR      OUT VARCHAR2)
IS
BEGIN
      K_CODERROR :=0;
      K_DESCERROR := 'OK';
     
       OPEN CURSORSERVICIO FOR
       SELECT ADMPV_COD_SERV,ADMPV_DES_SERV FROM ADMPT_CANJE_SERVICIO 
       WHERE ADMPV_ESTADO=1 ORDER BY ADMPV_FLG_ACTIVO DESC ;
       
    EXCEPTION
       WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
     
END ADMPSS_SERVICIO_COMERCIAL;                                           
                                     
PROCEDURE ADMPSI_DESAFI_VAL_INI(K_NOMARCH IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_PROCES IN NUMBER,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2)
IS
BEGIN
  K_CODERROR:=0;
  K_DESCERROR:='';

  --SE LE ASIGNA EL ERROR SI NO EXISTEN DATOS OBLIGATORIOS
  UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA
  SET
      ADMPC_ESTADO = 'P',
      ADMPV_CODERROR = 3,
      ADMPV_MSJE_ERROR = 'La linea no fue ingresada.'
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
  AND ADMPN_CATEGORIA = K_PROCES
  AND ADMPV_CODERROR = -1
  AND ADMPC_ESTADO = 'N'
  AND ADMPV_COD_CLI IS NULL;

  --SE VERIFICA LA EXISTENCIA DEL CLIENTE EN LA TABLA ADMPT_CLIENTE
  MERGE INTO PCLUB.ADMPT_TMP_PRESINRECARGA I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
         LEFT JOIN PCLUB.ADMPT_CLIENTE C ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
                                      AND C.ADMPV_COD_TPOCL = '3'
         WHERE T.ADMPV_NOMARCHIVO = K_NOMARCH
               AND T.ADMPV_CODERROR = -1
               AND T.ADMPN_CATEGORIA = K_PROCES
               AND T.ADMPC_ESTADO = 'N'
               AND C.ADMPV_COD_CLI IS NULL
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
    SET
        ADMPC_ESTADO = 'P',
        ADMPV_CODERROR = 4,
        ADMPV_MSJE_ERROR = 'La linea no existe.';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR:=SQLCODE;
      K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;
END ADMPSI_DESAFI_VAL_INI;

PROCEDURE ADMPSI_DESAFI_PROCE(K_NOMARCH IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_PROCES IN NUMBER,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGVAL OUT NUMBER,
                             K_NUMREGERR OUT NUMBER,
                             K_OCODERROR OUT NUMBER,
                             K_ODESCERROR OUT VARCHAR2)
IS
CURSORDESAFI SYS_REFCURSOR;
VC_SALDO NUMBER;
VC_SALDO_BONO NUMBER;
VC_SEC NUMBER;

VC_LINEA VARCHAR2(20);
VC_COD_CLI_IB VARCHAR2(20);
V_COD_CPTO VARCHAR2(2);
K_CODERROR NUMBER;
K_DESCERROR VARCHAR2(256);
K_NUMREGTOTPROC NUMBER;
BEGIN
K_OCODERROR:=0;
K_ODESCERROR:='';
SELECT ADMPV_COD_CPTO INTO V_COD_CPTO
FROM PCLUB.ADMPT_CONCEPTO
WHERE ADMPV_DESC = 'MESES SIN RECARGA PREPAGO'
AND ROWNUM = 1;

SELECT COUNT(1) INTO K_NUMREGTOT
FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
WHERE T.ADMPV_NOMARCHIVO = K_NOMARCH
AND T.ADMPN_CATEGORIA = K_PROCES;

PCLUB.PKG_CC_PREPAGO.ADMPSI_DESAFI_VAL_INI(K_NOMARCH => K_NOMARCH,K_USUARIO => K_USUARIO
                                          ,K_PROCES => K_PROCES, K_CODERROR => K_OCODERROR
                                          ,K_DESCERROR => K_ODESCERROR);

IF (K_OCODERROR=0) THEN


    OPEN CURSORDESAFI FOR
    SELECT T.ADMPN_SEC,
           T.ADMPV_COD_CLI,
           I.ADMPN_COD_CLI_IB
    FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
    LEFT JOIN PCLUB.ADMPT_CLIENTEIB I ON T.ADMPV_COD_CLI = I.ADMPV_COD_CLI
										AND I.ADMPC_ESTADO = 'A'
    WHERE T.ADMPV_NOMARCHIVO = K_NOMARCH
    AND T.ADMPN_CATEGORIA = K_PROCES
    AND T.ADMPV_CODERROR = -1
    AND T.ADMPC_ESTADO = 'N'
    AND T.ESPRE = 1;




    FETCH CURSORDESAFI INTO VC_SEC,VC_LINEA,VC_COD_CLI_IB;
    WHILE CURSORDESAFI%FOUND LOOP

      K_NUMREGTOTPROC := K_NUMREGTOTPROC + 1;
      --OBTENER SALDO CC DEL KARDEX
      BEGIN
        SELECT SUM(K.ADMPN_SLD_PUNTO) INTO VC_SALDO
          FROM PCLUB.ADMPT_KARDEX K
          WHERE K.ADMPV_COD_CLI = VC_LINEA
                AND K.ADMPC_TPO_PUNTO='C' AND K.ADMPC_ESTADO='A'
                AND K.ADMPC_TPO_OPER='E' AND K.ADMPN_SLD_PUNTO>0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VC_SALDO:=0;
      END;
      --OBTENER SALDO BONO DEL KARDEX
      BEGIN
        SELECT SUM(K.ADMPN_SLD_PUNTO) INTO VC_SALDO_BONO
        FROM PCLUB.ADMPT_KARDEX K
        WHERE K.ADMPV_COD_CLI = VC_LINEA
              AND K.ADMPC_TPO_PUNTO='B' AND K.ADMPC_ESTADO='A'
              AND K.ADMPC_TPO_OPER='E' AND K.ADMPN_SLD_PUNTO>0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        VC_SALDO_BONO:=0;
      END;

      PCLUB.PKG_CC_PREPAGO.ADMPSI_PRESINREC_MASIVO
        (
          K_NOMARCH,
          VC_LINEA,
          VC_SALDO,
          VC_SALDO_BONO,
          VC_COD_CLI_IB,
          V_COD_CPTO,
          K_USUARIO,
          K_CODERROR,
          K_DESCERROR
        );

        IF K_CODERROR = 0 THEN

          UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA T
          SET T.ADMPC_ESTADO = 'P'
          WHERE T.ADMPN_SEC = VC_SEC;

          K_NUMREGVAL := K_NUMREGVAL + 1;
        ELSE

          UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA T
          SET T.ADMPC_ESTADO = 'P',
              T.ADMPV_CODERROR = K_CODERROR,
              T.ADMPV_MSJE_ERROR = K_DESCERROR
          WHERE T.ADMPN_SEC = VC_SEC;

          K_NUMREGERR := K_NUMREGERR + 1;

        END IF;

        COMMIT;
        FETCH CURSORDESAFI INTO VC_SEC,VC_LINEA,VC_COD_CLI_IB;
    END LOOP;

    CLOSE CURSORDESAFI;







END IF;

SELECT COUNT(1) INTO K_NUMREGVAL
FROM PCLUB.ADMPT_TMP_PRESINRECARGA T
WHERE
T.ADMPV_NOMARCHIVO = K_NOMARCH
AND T.ADMPN_CATEGORIA = K_PROCES
AND T.ADMPV_CODERROR = -1
AND T.ADMPC_ESTADO = 'P'
AND T.ESPRE = 1;

K_NUMREGERR:=K_NUMREGTOT - K_NUMREGVAL;

IF (K_NUMREGTOT=0) THEN
  K_OCODERROR:=1;
  K_ODESCERROR:='No existen registros para procesar en el proceso ' || to_char(K_PROCES);
END IF;

END ADMPSI_DESAFI_PROCE;

PROCEDURE ADMPSI_DESAFI_CATEG(K_HILOS        IN NUMBER,
                                K_NOMBREARCH IN VARCHAR,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
V_CONTADOR NUMBER;
V_CAT_MAX NUMBER;
V_NUM_REG NUMBER;
EX_ERROR EXCEPTION;
EX_CONCEPTO EXCEPTION;
V_COD_CPTO VARCHAR2(2);
V_NUMREGCOMMIT NUMBER;
  BEGIN

   CASE
    WHEN K_NOMBREARCH IS NULL
      THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.';
      RAISE EX_ERROR;
    ELSE
      K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  BEGIN
    SELECT ADMPV_COD_CPTO INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC = 'MESES SIN RECARGA PREPAGO'
    AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 9;
      K_DESCERROR := 'ORA: No esta registrado el concepto MESES SIN RECARGA PREPAGO.';
      RAISE EX_CONCEPTO;
  END;

  BEGIN
    SELECT ADMPV_VALOR INTO V_NUMREGCOMMIT
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 50;
      K_DESCERROR := 'ORA: No esta registrado el parametro CANT_REG_COMMIT_PROC_MASIVO.';
      RAISE EX_ERROR;
  END;

    K_CODERROR:=0;
    K_DESCERROR:=0;
    V_CONTADOR:=0;
    V_CAT_MAX:=K_HILOS;

    SELECT COUNT(1)
    INTO V_NUM_REG
    FROM PCLUB.ADMPT_TMP_PRESINRECARGA C
    WHERE
    C.ADMPV_NOMARCHIVO = K_NOMBREARCH;

    IF V_NUM_REG > 0 THEN

      FOR REGISTR IN (  SELECT C.ADMPV_COD_CLI
                        FROM PCLUB.ADMPT_TMP_PRESINRECARGA C)
      LOOP
        V_CONTADOR:=V_CONTADOR+1;
        IF (LENGTH(REGISTR.ADMPV_COD_CLI) = 9) THEN
           UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA
           SET ADMPN_CATEGORIA=V_CONTADOR,
           ESPRE = 1
           WHERE ADMPV_COD_CLI=REGISTR.ADMPV_COD_CLI;


        ELSE
          UPDATE PCLUB.ADMPT_TMP_PRESINRECARGA T
          SET
              T.ADMPN_CATEGORIA=V_CONTADOR,
              T.ADMPC_ESTADO = 'P',
              T.ADMPV_CODERROR = '1',
              T.ADMPV_MSJE_ERROR = 'La linea no tiene 9 digitos'
          WHERE
          T.ADMPV_COD_CLI=REGISTR.ADMPV_COD_CLI;
        END IF;

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
    WHEN EX_ERROR THEN
      ROLLBACK;
    WHEN EX_CONCEPTO THEN
      ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;
END ADMPSI_DESAFI_CATEG;

PROCEDURE ADMPSI_DESAFI_LIMP(
                              K_RESULTADO    OUT NUMBER,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2)
IS
C_TOTAL NUMBER;
C_TOTALPRO NUMBER;
BEGIN
K_CODERROR:=0;
K_DESCERROR:='';
K_RESULTADO:=0;

SELECT COUNT(1) INTO C_TOTAL FROM PCLUB.ADMPT_TMP_PRESINRECARGA T;
SELECT COUNT(1) INTO C_TOTALPRO FROM PCLUB.ADMPT_TMP_PRESINRECARGA T WHERE T.ADMPC_ESTADO = 'P';

IF C_TOTAL > 0 THEN
  IF (C_TOTAL = C_TOTALPRO) THEN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PCLUB.ADMPT_TMP_PRESINRECARGA';

  ELSE
    K_RESULTADO:=1;
    K_CODERROR := 1;
    K_DESCERROR := ' La tabla ADMPT_TMP_PRESINRECARGA se encuentra con registros pendientes de procesar.';
  END IF;
ELSE
    K_RESULTADO:=2;
    K_CODERROR := 1;
    K_DESCERROR := ' La tabla ADMPT_TMP_PRESINRECARGA se encuentra vacia.';
END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := SQLCODE;
    K_DESCERROR :=  SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ADMPSI_DESAFI_LIMP;





      
  PROCEDURE ADMPSS_PREVENCPTO_VALI(K_CODERROR  OUT NUMBER,
  K_DESCERROR OUT VARCHAR2,
  K_FECHA OUT VARCHAR2,
  K_COUNT OUT NUMBER,
  K_COUNT_CAT OUT NUMBER)
IS
V_CANTREG NUMBER;
V_CANTREGERR NUMBER;
V_CANTPRO NUMBER;
BEGIN
K_CODERROR:=0;
K_COUNT:=0;
K_COUNT_CAT:=0;

SELECT COUNT(1) INTO V_CANTREGERR FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS R WHERE R.ADMPN_CODERROR IS NOT NULL;
SELECT COUNT(1) INTO V_CANTREG FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS R WHERE R.ADMPN_CODERROR IS NULL;
SELECT COUNT(1) INTO V_CANTPRO FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS R WHERE R.ADMPN_REGPROC = 1;

IF (V_CANTREG=V_CANTPRO) THEN
  IF (V_CANTREG<>0)THEN
    K_CODERROR:=1;
    K_DESCERROR:='Debe de ejecutar el shell SH012_LIMPIAR_TMP_VENCIMIENTO.sh. antes de vencer los puntos.';
  END IF;
  IF (V_CANTREGERR<>0)THEN
    K_CODERROR:=1;
    K_DESCERROR:='Debe de ejecutar el shell SH012_LIMPIAR_TMP_VENCIMIENTO.sh. antes de vencer los puntos.';
  END IF;
ELSE

  SELECT COUNT(1) INTO K_COUNT FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS
  WHERE ADMPN_REGPROC=0;

  SELECT COUNT(1) INTO K_COUNT_CAT FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS
  WHERE ADMPN_CATEGORIA IS NULL;

  IF (K_COUNT>0) THEN
    SELECT TO_CHAR(ADMPD_FECHA,'DD/MM/YYYY') INTO K_FECHA FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS
    WHERE ADMPN_REGPROC=0 AND ROWNUM=1;
  END IF;
  IF (V_CANTREGERR<>0)THEN
    K_CODERROR:=1;
    K_DESCERROR:='Debe de ejecutar el shell SH012_LIMPIAR_TMP_VENCIMIENTO.sh. antes de vencer los puntos.';
  END IF;
END IF;

END  ADMPSS_PREVENCPTO_VALI;


PROCEDURE ADMPSI_PREVENCPTO_CARGA(
K_FECHA IN DATE,
K_CODERROR OUT NUMBER, 
K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREVENCPTO_CARGA
  -- Proposito           :  Cargar la tabla temporal con los clientes de puntos vencidos.
  -- Input               :
  -- Output              :  K_CODERROR
  --                            K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  03/06/2015
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_COUNT_VEN NUMBER;
  
  V_COD_CPTO VARCHAR2(2);


  V_CAT_MAX NUMBER;
  V_CONTADOR NUMBER;
  NUMERO_FILA NUMBER;
  
   cursor c1 is 
   
                    
       SELECT distinct A.ADMPV_COD_CLI,ADMPC_TPO_PUNTO, ADMPV_COD_CPTO,ADMPN_PER_CADU,
       to_char(ADD_MONTHS( sysdate, -ADMPN_PER_CADU ),'dd/mm/YYYY') AS FECHA_CADUC
                  FROM (
                   SELECT K.ADMPV_COD_CLI,K.ADMPC_TPO_PUNTO,K.ADMPV_COD_CPTO,cto.ADMPN_PER_CADU
                    FROM PCLUB.ADMPT_KARDEX K, PCLUB.ADMPT_CLIENTE C, PCLUB.ADMPT_CONCEPTO cto
                    WHERE K.ADMPD_FEC_TRANS < to_date(to_char(ADD_MONTHS(sysdate,-cto.ADMPN_PER_CADU), 'dd/mm/yyyy'), 'dd/mm/yyyy')
                    AND K.ADMPV_COD_CPTO= cto.ADMPV_COD_CPTO
                    AND C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
                    AND K.ADMPC_TPO_PUNTO =  cto.ADMPC_TPO_PUNTO
                    AND K.ADMPN_SLD_PUNTO > 0
                    AND K.ADMPC_TPO_OPER = 'E'
                    AND C.ADMPV_COD_TPOCL = '3' 
                    AND K.ADMPD_FEC_VCMTO IS NULL
                    AND cto.ADMPN_PER_CADU >0 AND cto.ADMPC_ESTADO='A' AND cto.ADMPC_TPO_PUNTO IN ('C','L')
                    AND cto.ADMPV_TPO_CPTO IS NULL
                    
                    GROUP BY K.ADMPV_COD_CLI,K.ADMPC_TPO_PUNTO,K.ADMPV_COD_CPTO,cto.ADMPN_PER_CADU
                    ) A;
     
      type type_t1 is table of c1%rowtype index by pls_integer;
      t type_t1;
  

    BEGIN
  
     V_CAT_MAX:=20;
     K_CODERROR:=0;
     K_DESCERROR:=' ';
     V_CONTADOR:=0;
     NUMERO_FILA:=0;

           BEGIN
             /*SE ALMACENA EL CODIGO DEL CONCEPTO 'VENCIMIENTO DE PUNTO PREPAGO'*/
             SELECT ADMPV_COD_CPTO
             INTO V_COD_CPTO
             FROM PCLUB.ADMPT_CONCEPTO
             WHERE ADMPV_DESC LIKE '%VENCIMIENTO DE PUNTO PREPAGO%';
           EXCEPTION
             WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
           END;

           IF V_COD_CPTO IS NULL THEN
              RAISE NO_CONCEPTO;
           END IF;


  OPEN c1;

  LOOP
    FETCH c1 BULK COLLECT INTO t LIMIT 50;
      V_CONTADOR:=V_CONTADOR+1;
      FORALL i IN 1 .. t.COUNT      
   
          INSERT INTO PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS
                      (ADMPV_COD_CLI,
                      ADMPN_PUNTOS,
                      ADMPC_TPO_PUNTO,
                      ADMPV_COD_CPTO,
                      ADMPN_PER_CADU,
                      ADMPD_FECHA,
                      ADMPV_COD_VENPTO,
                      ADMPN_CATEGORIA
                    
                      )values(t(i).ADMPV_COD_CLI,null,t(i).ADMPC_TPO_PUNTO, t(i).ADMPV_COD_CPTO,t(i).ADMPN_PER_CADU,K_FECHA,V_COD_CPTO,V_CONTADOR);
          
      IF (V_CONTADOR + 1) > V_CAT_MAX  THEN
        V_CONTADOR:=0;
        END IF;
  
       COMMIT;
    EXIT WHEN c1%NOTFOUND;
  END LOOP;
  
  CLOSE c1;
  
        K_CODERROR:=0;
        K_DESCERROR:=' ';
        
       

        SELECT COUNT(1) INTO V_COUNT_VEN
        FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS;

        IF (V_COUNT_VEN=0) THEN
          K_CODERROR:=56;
          K_DESCERROR:='No se encontraron puntos por vencer.';
        END IF;


  EXCEPTION

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado el parametro de VENCIMIENTO DE PUNTO PREPAGO (ADMPT_CONCEPTO).';
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

END ADMPSI_PREVENCPTO_CARGA;


PROCEDURE ADMPSS_PREVENCPTO_CATEG(
                                    K_CODERROR       OUT NUMBER,
                                    K_DESCERROR      OUT VARCHAR2) IS

  --****************************************************************
  -- Nombre SP           :  ADMPSS_PREVENCPTO_CATEG
  -- Proposito           :  Categoriza todos los puntos vencidos de la tabla ADMPT_TMP_VENCIMIENTO_PUNTOS.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  03/06/2015
  -- Fec Actualizacion   :
  --****************************************************************

  BEGIN
    --
     K_CODERROR:=0;
    K_DESCERROR:='Exito';
EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSS_PREVENCPTO_CATEG;

PROCEDURE ADMPSS_PREVENCPTO_PROCE(K_FECHA IN DATE,K_CATEGORIA   IN NUMBER,
                                  K_CODERROR    OUT NUMBER,
                                  K_DESCERROR   OUT VARCHAR2,
                                  K_NUMREGTOT   OUT NUMBER,
                                  K_NUMREGPRO   OUT NUMBER,
                                  K_NUMREGERR   OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSS_PREVENCPTO_PROCE
  -- Proposito           :  Proceso que realiza el vencimiento de puntos.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  03/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
  K_USUARIO CONSTANT CHAR(10) := 'USRVENCPTO';
  NO_CONCEPTO EXCEPTION;
  K_BLIMIT    NUMBER :=10000;
   --Variables internas NO modificar
   TotalSaldos          NUMBER              :=0;
   cantRegMigrar        NUMBER              :=0;
   LoteBCVI             NUMBER              :=0;
   LoteBCVF             NUMBER              :=0;
   LoteBCVI_C           VARCHAR(40)         :='';
   LoteBCVF_C           VARCHAR(40)         :='';
   contLote             NUMBER               :=0;
   conRegistros         NUMBER               :=0;
   limSup               NUMBER               :=0;
   lotereal             NUMBER               :=0;
   indice               NUMBER               :=0;
   sentencia            VARCHAR2(50)        :='';
   idKardex_lanzaINI    NUMBER              :=0; --1er idKardex procesado en el lanzamiento
   idKardex_lanzaFIN    NUMBER              :=0; --ultimo idKardex procesado en el lanzamiento

   vTimeIniLote         DATE;
   vTimeFinLote         DATE;
   vDuracionLote        INTEGER             :=0;
   vAcumDuracionLotes   INTEGER             :=0;
   vContLotesExito      INTEGER             :=0;
   vContLotesError      INTEGER             :=0;
   vCadenaLotesError    VARCHAR2(2000)      :='Lotes que presentan error: ';
   idKardex_error       NUMBER              :=0;
   idCliente_error     VARCHAR2(40)         :='';
  
  --variables para registro de auditoria
  vAUD_ID_PROCESO        VARCHAR2(10)  := K_CATEGORIA || ' - VPP';
  vAUD_FECHA_REGISTRO     DATE       := sysdate;
  vAUD_DESCRIPCION_PROCESO   VARCHAR2(200)  := 'INICIO DE EJECUCION DEL PROCESO - VENCIMIENTO DE PUNTOS';
  vAUD_ID_EJEC_PROCESO     VARCHAR (3)   := 'EP';
  vAUD_EJECUCION_PROCESO   VARCHAR2(50)  := 'EJECUCION DEL PROCESO';
  vAUD_PARAMETROS       VARCHAR2(2000):=
                    'K_FECHA: '       || K_FECHA        ||
                    ' K_CATEGORIA: '  || K_CATEGORIA    ||
                    ' K_BLIMIT: '     || K_BLIMIT || CHR(10)||
                    ' K_USUARIO: '     || K_USUARIO          || CHR(10);
    
   vAUD_HORA_INICIO_LOTE       DATE;
   vAUD_HORA_FIN_LOTE          DATE;

   vAUD_LOTE_DEBE_IR           VARCHAR2(1000)    := '';
   vAUD_LOTE_EJECUTO           VARCHAR2(1000)    := '';
   vAUD_ESTADO_LOTE            VARCHAR2(255)    := '';

   vAUD_REGISTRO_ERROR_LOTE    VARCHAR2(600)    := '';
   vAUD_MENSAJE_ERROR          VARCHAR2(255)    := '';
   vESTADO_REGISTRO            VARCHAR2(25)    := ''; 
   K_OCODERROR   numeric  :=0;
   K_ODESCERROR   VARCHAR2(200)    := ''; 

  /* CURSOR PARA ALMACENAR EL KARDEX DEL CLIENTE PARA LA KARDEX_MIG */
  CURSOR C_ADMPT_KARDEX_MIG 
   IS
    SELECT 
     K.ADMPN_ID_KARDEX, K.ADMPN_COD_CLI_IB, K.ADMPV_COD_CLI, K.ADMPV_COD_CPTO, K.ADMPD_FEC_TRANS,
     K.ADMPN_PUNTOS, K.ADMPV_NOM_ARCH, K.ADMPC_TPO_OPER, K.ADMPC_TPO_PUNTO, K.ADMPN_SLD_PUNTO,
     K.ADMPC_ESTADO, K.ADMPV_IDTRANSLOY, K.ADMPD_FEC_REG, K.ADMPD_FEC_MOD, K.ADMPV_DESC_PROM,
     K.ADMPN_TIP_PREMIO, K.ADMPD_FEC_VCMTO, K.ADMPV_USU_REG, K.ADMPV_USU_MOD, SYSDATE, K_USUARIO
    FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS T 
    INNER JOIN PCLUB.ADMPT_KARDEX K ON T.ADMPV_COD_CLI =  K.ADMPV_COD_CLI
    WHERE T.ADMPN_CATEGORIA = K_CATEGORIA
          AND T.ADMPN_REGPROC = 0
          AND T.ADMPD_FECHA = K_FECHA
      
       AND K.ADMPD_FEC_TRANS < to_date(to_char(ADD_MONTHS(sysdate,-t.ADMPN_PER_CADU ), 'dd/mm/yyyy'), 'dd/mm/yyyy')
          AND K.ADMPC_TPO_PUNTO in ('C','L')
          AND K.ADMPV_COD_CPTO = T.ADMPV_COD_CPTO
          AND ADMPN_SLD_PUNTO > 0
          AND ADMPC_TPO_OPER = 'E'
    ORDER BY K.ADMPN_ID_KARDEX;
    
   
   TYPE TABLE_C_ADMPT_KARDEX_MIG IS
    TABLE OF C_ADMPT_KARDEX_MIG%ROWTYPE
    INDEX BY PLS_INTEGER;

   l_TABLE_C_ADMPT_KARDEX_MIG TABLE_C_ADMPT_KARDEX_MIG;
   


CURSOR C_CLIENTE 
   IS
  SELECT
    ADMPV_COD_CLI,
      rowid            
      FROM PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS
  WHERE
  ADMPN_CATEGORIA = K_CATEGORIA
  AND ADMPN_REGPROC = 0
    AND ADMPD_FECHA = K_FECHA
  ORDER BY ADMPV_COD_CLI;
     
  TYPE C_CLIENTE_ROW IS RECORD
  (
     ADMPV_COD_CLI PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS.ADMPV_COD_CLI%TYPE,   
     my_rowid  UROWID
  );

 
     TYPE TABLE_C_CLIENTE IS TABLE OF C_CLIENTE_ROW
     INDEX BY PLS_INTEGER;
    
    

   L_TABLE_C_CLIENTE TABLE_C_CLIENTE;
   

  BEGIN

     --Inicializacion de variables
     K_CODERROR         := 0;
     K_DESCERROR        := 'Proceso EXITOSO';
     vAUD_FECHA_REGISTRO :=SYSDATE;
     DBMS_OUTPUT.put_line(CHR(9) || '=============================================================================');
     DBMS_OUTPUT.put_line(CHR(9) || 'MIGRACION DE DATOS DE ADMPT_KARDEX a ADMPT_KARDEX_MIG - VENCIMIENTO DE PUNTOS');
     DBMS_OUTPUT.put_line(CHR(9) || 'Parametros de entrada:');
     
     DBMS_OUTPUT.put_line(CHR(9) || 'K_FECHA: ' || K_FECHA);
     DBMS_OUTPUT.put_line(CHR(9) || 'K_CATEGORIA: '|| CHR(9)   || K_CATEGORIA);
     DBMS_OUTPUT.put_line(CHR(9) || 'K_BLIMIT: '   || K_BLIMIT);
     DBMS_OUTPUT.put_line(CHR(9) || '============================================================================='||CHR(10)||CHR(13));
  -- INICIO PROCESO
        PCLUB.PKG_CC_PREPAGO.ADMPSI_DESAFI_REG_AUDITORIA(
        vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_ID_EJEC_PROCESO,
        vAUD_EJECUCION_PROCESO, vAUD_PARAMETROS, vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, 
        vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE, vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO,
        vESTADO_REGISTRO, K_OCODERROR, K_ODESCERROR 
        );

            
    
     conRegistros := conRegistros + 1;
    
      OPEN C_ADMPT_KARDEX_MIG;
      LOOP
      FETCH C_ADMPT_KARDEX_MIG      
         BULK COLLECT INTO l_TABLE_C_ADMPT_KARDEX_MIG LIMIT K_BLIMIT;     
             EXIT WHEN l_TABLE_C_ADMPT_KARDEX_MIG.COUNT=0; 
             K_NUMREGTOT := C_ADMPT_KARDEX_MIG%ROWCOUNT;    
       -- IF l_TABLE_C_ADMPT_KARDEX_MIG.COUNT > 0 THEN    
       
                 BEGIN
             -----INI EZC  
             vTimeIniLote := sysdate;
              
             vAUD_HORA_INICIO_LOTE :=  sysdate;
             contLote := contLote +1;
             limSup := contLote * K_BLIMIT;
             lotereal := conRegistros + l_TABLE_C_ADMPT_KARDEX_MIG.COUNT -1   ;
      
  
             vAUD_LOTE_DEBE_IR := 'LOTE NRO: '|| contLote || ' DEBE IR DEL ' || conRegistros || ' al ' || limSup;
             vAUD_LOTE_EJECUTO := 'LOTE NRO: '|| contLote || ' DEBE IR DEL ' || conRegistros || ' al ' || lotereal || CHR(10);
          
            
             DBMS_OUTPUT.put_line(CHR(9) || '---------------------------------------------------');
             DBMS_OUTPUT.put_line(CHR(9) || vAUD_LOTE_DEBE_IR);
             DBMS_OUTPUT.put_line(CHR(9) || vAUD_LOTE_EJECUTO);   
              sentencia := 'MIGRACION A KARDEX MIG';
             --Bucle de insercion de registros en ADMPT_KARDEX_MIG
             FOR indx IN 1 .. l_TABLE_C_ADMPT_KARDEX_MIG.COUNT   
             LOOP           
              indice    := indx;

                --Pinta valor inicial y valor final del lote
              IF indx = 1 THEN
                LoteBCVI := l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_ID_KARDEX;
                DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR ID_KARDEX INICIAL: ' || LoteBCVI);
                vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR ID_KARDEX INICIAL: ' || LoteBCVI || CHR(10);

                IF contLote = 1 THEN
                  idKardex_lanzaINI := LoteBCVI;
                END IF;
              
              ELSIF indx = l_TABLE_C_ADMPT_KARDEX_MIG.COUNT THEN
                LoteBCVF := l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_ID_KARDEX;
                DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR ID_KARDEX   FINAL: ' || LoteBCVF);
                vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR ID_KARDEX   FINAL: ' || LoteBCVF;
              ELSIF indx = K_BLIMIT THEN
                LoteBCVF := l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_ID_KARDEX;
                DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR ID_KARDEX  -FINAL: ' || LoteBCVF);
                vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR ID_KARDEX   FINAL: ' || LoteBCVF;
              END IF;
             
              sentencia := 'INSERT ADMPT_KARDEX_MIG';
              
              INSERT INTO PCLUB.ADMPT_KARDEX_MIG
              ( ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI, ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
              ADMPN_PUNTOS, ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO,
              ADMPC_ESTADO, ADMPV_IDTRANSLOY, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_DESC_PROM,
              ADMPN_TIP_PREMIO, ADMPD_FEC_VCMTO, ADMPV_USU_REG, ADMPV_USU_MOD,ADMPD_FEC_MIG,
              ADMPV_USU_MIG
              )
              values
              (
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_ID_KARDEX,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_COD_CLI_IB,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_COD_CLI,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_COD_CPTO,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPD_FEC_TRANS,

               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_PUNTOS,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_NOM_ARCH,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPC_TPO_OPER,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPC_TPO_PUNTO,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_SLD_PUNTO,

               --l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPC_ESTADO,
               'V',
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_IDTRANSLOY,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPD_FEC_REG,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPD_FEC_MOD,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_DESC_PROM,

               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_TIP_PREMIO,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPD_FEC_VCMTO,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_USU_REG,
               l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPV_USU_MOD,
               SYSDATE, K_USUARIO
               );
            
              conRegistros := conRegistros + 1;
             END LOOP;   
            
             --Bucle de eliminacion de registros en ADMPT_KARDEX
             FOR indx IN 1 .. l_TABLE_C_ADMPT_KARDEX_MIG.COUNT
             LOOP
              indice    := indx;
              sentencia := 'DELETE ADMPT_KARDEX';
              DELETE FROM PCLUB.ADMPT_KARDEX where ADMPN_ID_KARDEX = l_TABLE_C_ADMPT_KARDEX_MIG(indx).ADMPN_ID_KARDEX;
              --K_NUMREGPRO := K_NUMREGPRO + 1;
             END LOOP; --Fin for de deletes
             
             vContLotesExito    := vContLotesExito + 1;
             vTimeFinLote       := sysdate;
             vDuracionLote      := (vTimeFinLote - vTimeIniLote)*24*60*60;
             vAcumDuracionLotes := vAcumDuracionLotes + vDuracionLote;
             DBMS_OUTPUT.put_line(CHR(9) || 'Tiempo de ejecucion de lote en segundos: '|| vDuracionLote );
      
           
             vAUD_ESTADO_LOTE := 'Transacciones de tablas correctas, se realiza COMMIT';
             DBMS_OUTPUT.put_line(CHR(9) || vAUD_ESTADO_LOTE);
             commit;--las transacciones mantendran su propio commit
             vAUD_MENSAJE_ERROR :='';
             vAUD_REGISTRO_ERROR_LOTE :='';
           
             --Como el insert de auditoria no es mandatorio se controlara en su propio bloque de excepcion
             BEGIN
             --Insert de auditoria en caso de insert y delete de migracion EXITOSO
              vAUD_HORA_FIN_LOTE := sysdate;
              vAUD_FECHA_REGISTRO :=SYSDATE;
              vAUD_DESCRIPCION_PROCESO := 'EJECUCION DEL PROCESO - MIGRACION DE DATOS DE ADMPT_KARDEX a ADMPT_KARDEX_MIG - VENCIMIENTO DE PUNTOS';
    
               insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
               (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO, AUD_PARAMETROS, AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE, AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
               )
               values
               (
              pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_ID_EJEC_PROCESO,
              vAUD_EJECUCION_PROCESO, vAUD_PARAMETROS, vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR,
              vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE, vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO
               );

               --Se manejan 1 commit para el insert del bulkCollect y para el registro de auditoria de extio
               commit;
               DBMS_OUTPUT.put_line(CHR(9) || 'REGISTRADO EN TABLA AUDITORIA_PROC_CLAROCLUB EXITOSO - MIGRACION KARDEX');

                EXCEPTION
                WHEN OTHERS THEN
              DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE EXITOSO');
              DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
              DBMS_OUTPUT.put_line( 'DESCERROR: '||SQLERRM);
                  ROLLBACK;
                END ;


             EXIT WHEN C_ADMPT_KARDEX_MIG%NOTFOUND;   

  EXCEPTION
            WHEN OTHERS THEN
            idKardex_error := l_TABLE_C_ADMPT_KARDEX_MIG(indice).ADMPN_ID_KARDEX;
            vAUD_ESTADO_LOTE := 'ERROR EN LA TRANSACCION';
            vAUD_REGISTRO_ERROR_LOTE := 'Sentencia: '|| sentencia ||
                ' ID_KARDEX Registro que genera ERROR: ' || idKardex_error ||CHR(10)||CHR(13)||
                'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)||
                'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
            vAUD_MENSAJE_ERROR := 'Ha ocurrido un ERROR en el LOTE: ' || contLote;
            vAUD_DESCRIPCION_PROCESO := 'EJECUCION DEL PROCESO - MIGRACION DE DATOS DE ADMPT_KARDEX a ADMPT_KARDEX_MIG - VENCIMIENTO DE PUNTOS';

            DBMS_OUTPUT.put_line(CHR(9) || vAUD_MENSAJE_ERROR);
            DBMS_OUTPUT.put_line(CHR(9) || vAUD_REGISTRO_ERROR_LOTE);

            vContLotesError   := vContLotesError + 1;
            vCadenaLotesError := vCadenaLotesError || contLote || ', ';
            conRegistros := contLote * K_BLIMIT + 1;
      ROLLBACK;

            --Despues del rollback del lote se hara el insert en auditoria con los datos de error
            BEGIN
               vAUD_FECHA_REGISTRO := sysdate;
               vAUD_HORA_FIN_LOTE := sysdate;
               insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
               (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_PARAMETROS,
               AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR, AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
               )
               values
               (
              pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_PARAMETROS,
              vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE,
              vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO
               );
              commit;
            EXCEPTION
    WHEN OTHERS THEN
              DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE FALLIDO');
              DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
              DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
      ROLLBACK;
            END; -- fin de control de excepcion de auditoria

            --Se procedera a realizar el delete del registro que presenta el incoveniente para
            BEGIN
              DELETE FROM PCLUB.ADMPT_KARDEX WHERE ADMPN_ID_KARDEX = idKardex_error;
              DBMS_OUTPUT.put_line(CHR(9) || 'DELETE CORRECTO DE REGISTRO ' || idKardex_error || ' EXITOSO');
              commit;
            EXCEPTION
              WHEN OTHERS THEN
              DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR DELETE DE REGISTRO QUE OCASIONO CAIDA DEL LOTE : ' || idKardex_error);
              DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
              DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
              ROLLBACK;
            END; --fin de control de excepcion de eliminacion de idKardex que genera el error.

          END; -- fin de excepcion de lote  

      END LOOP;

      CLOSE C_ADMPT_KARDEX_MIG;

      K_NUMREGPRO := conRegistros;
      idKardex_lanzaFIN := LoteBCVF;      
      K_NUMREGERR:=vContLotesError;

       DBMS_OUTPUT.put_line(CHR(10)||CHR(13) || CHR(9) || '---------------------------------------------------');
       DBMS_OUTPUT.put_line(CHR(9) || 'idKardex_lanzaINI: '  || idKardex_lanzaINI);
       DBMS_OUTPUT.put_line(CHR(9) || 'idKardex_lanzaFIN: '  || idKardex_lanzaFIN   || CHR(10)||CHR(13));
       DBMS_OUTPUT.put_line(CHR(9) || 'Lanzados a migrar: '  || cantRegMigrar       || ' registros');
       DBMS_OUTPUT.put_line(CHR(9) || 'Se migraron      : '  || conRegistros         || ' registros');
       DBMS_OUTPUT.put_line(CHR(9) || 'Tiempo total de ejecucion    : '|| vAcumDuracionLotes || ' segundos');

       DBMS_OUTPUT.put_line(CHR(9) || 'Cantidad de lotes procesados : ' || contLote);
       DBMS_OUTPUT.put_line(CHR(9) || 'Cantidad de lotes exitosos   : ' || vContLotesExito);
       DBMS_OUTPUT.put_line(CHR(9) || 'Cantidad de lotes con error  : ' || vContLotesError);
       DBMS_OUTPUT.put_line(CHR(9) || vCadenaLotesError || CHR(10)||CHR(13));
                                   
       DBMS_OUTPUT.put_line(CHR(9) || 'K_CODERROR: '  || K_CODERROR);
       DBMS_OUTPUT.put_line(CHR(9) || 'K_DESCERROR: ' || K_DESCERROR);


  K_BLIMIT := 500; 
  vAUD_MENSAJE_ERROR :='';
  vAUD_REGISTRO_ERROR_LOTE :='';  
  vAUD_ESTADO_LOTE :='';  
  conRegistros :=0;
  contLote:=0;
   conRegistros := conRegistros + 1;
  lotereal :=0;
  limSup :=0;
  vAUD_FECHA_REGISTRO :=SYSDATE;
  vAUD_DESCRIPCION_PROCESO := 'ACTUALIZACION TABLA PCLUB.ADMPT_SALDOS_CLIENTE';
  DBMS_OUTPUT.put_line(CHR(9) || 'ACTUALIZACION TABLA PCLUB.ADMPT_SALDOS_CLIENTE');   
    OPEN C_CLIENTE;
      LOOP
      FETCH C_CLIENTE
         BULK COLLECT INTO l_TABLE_C_CLIENTE LIMIT K_BLIMIT;            
           EXIT WHEN l_TABLE_C_CLIENTE.COUNT=0; 
        -- BEGIN             
             -----INI EZC  
             vTimeIniLote := sysdate;           
             contLote := contLote +1;
             limSup := contLote * K_BLIMIT;
             lotereal := conRegistros + l_TABLE_C_CLIENTE.COUNT-1;            

              vAUD_LOTE_DEBE_IR := 'LOTE NRO: '|| contLote || ' DEBE IR DEL ' || conRegistros || ' al ' || limSup;
              vAUD_LOTE_EJECUTO := 'LOTE NRO: '|| contLote || ' DEBE IR DEL ' || conRegistros || ' al ' || lotereal || CHR(10);


             DBMS_OUTPUT.put_line(CHR(9) || '---------------------------------------------------');
             DBMS_OUTPUT.put_line(CHR(9) || vAUD_LOTE_DEBE_IR);
             DBMS_OUTPUT.put_line(CHR(9) || vAUD_LOTE_EJECUTO);   

             vAUD_HORA_INICIO_LOTE  := sysdate;  

             FOR indx IN 1 .. l_TABLE_C_CLIENTE.COUNT   
             LOOP      
                       --Pinta valor inicial y valor final del lote                      
              indice    := indx;

              IF indx = 1 THEN

                LoteBCVI_C := l_TABLE_C_CLIENTE(indx).ADMPV_COD_CLI;
                DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR COD_CLI INICIAL: ' || LoteBCVI_C);
                vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR ADMPV_COD_CLI INICIAL: ' || LoteBCVI_C || CHR(10);

               /* IF contLote = 1 THEN
                  idKardex_lanzaINI := LoteBCVI_C;
                END IF;*/

              ELSIF indx = l_TABLE_C_CLIENTE.COUNT THEN
                LoteBCVF_C := l_TABLE_C_CLIENTE(indx).ADMPV_COD_CLI;
                DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR COD_CLI   FINAL: ' || LoteBCVF_C);
                vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR COD_CLI   FINAL: ' || LoteBCVF_C;
              ELSIF indx = K_BLIMIT THEN
                LoteBCVF := l_TABLE_C_CLIENTE(indx).ADMPV_COD_CLI;
                DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR COD_CLI  -FINAL: ' || LoteBCVF_C);
                vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR COD_CLI  -FINAL: ' || LoteBCVF_C;
              END IF;     

               --ACTUALIZA VALORES EN LA TABLA   PCLUB.ADMPT_SALDOS_CLIENTE  
                   begin      
                           SELECT  NVL(SUM(K.ADMPN_SLD_PUNTO),0) INTO TotalSaldos FROM PCLUB.ADMPT_KARDEX K 
                                      WHERE K.admpv_cod_cli=l_TABLE_C_CLIENTE(indx).ADMPV_COD_CLI  
                                      and ((K.ADMPC_TPO_PUNTO='C') or (K.ADMPC_TPO_PUNTO='L') or (K.ADMPC_TPO_PUNTO='B'))
                                      and K.ADMPN_SLD_PUNTO>0
                                      and K.ADMPC_TPO_OPER='E'
                                      and (K.ADMPV_COD_CPTO not in ('95','96','97','4'))
                                      and K.ADMPC_ESTADO = 'A';  

                       IF TotalSaldos IS NOT NULL THEN
                          sentencia := 'UPDATE SALDOS CLIENTE';              
                          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE 
                          SET ADMPN_SALDO_CC = TotalSaldos, ADMPD_FEC_MOD = sysdate
                          WHERE ADMPV_COD_CLI = l_TABLE_C_CLIENTE(indx).ADMPV_COD_CLI;

                         ELSE
                         TotalSaldos:=0;
                         sentencia := 'UPDATE SALDOS CLIENTE';

                          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                          SET ADMPN_SALDO_CC = TotalSaldos, ADMPD_FEC_MOD = sysdate
                          WHERE ADMPV_COD_CLI = l_TABLE_C_CLIENTE(indx).ADMPV_COD_CLI;
                       END IF;

                   exception                         
                       when others then
                       idCliente_error := l_TABLE_C_CLIENTE(indice).ADMPV_COD_CLI;
                       vAUD_ESTADO_LOTE := 'ERROR EN LA TRANSACCION';
                        vAUD_REGISTRO_ERROR_LOTE := 'Sentencia: '|| sentencia ||
                                ' CATEGORIA : '|| K_CATEGORIA ||' ADMPV_COD_CLI Registro que genera ERROR: ' || idCliente_error ||CHR(10)||CHR(13)||
                                ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)||
                                ' DESCERROR ' || SUBSTR(SQLERRM, 1, 250);
                        vAUD_MENSAJE_ERROR := 'Ha ocurrido un ERROR en el LOTE: ' || contLote;

                        DBMS_OUTPUT.put_line(CHR(9) || vAUD_MENSAJE_ERROR);
                        DBMS_OUTPUT.put_line(CHR(9) || vAUD_REGISTRO_ERROR_LOTE);

                        /*vContLotesError   := vContLotesError + 1;
                        vCadenaLotesError := vCadenaLotesError || contLote || ', ';
                        conRegistros := contLote * K_BLIMIT + 1;*/
                        ROLLBACK;
                        --Despues del rollback del lote se hara el insert en auditoria con los datos de error
                          BEGIN
                            vAUD_FECHA_REGISTRO := sysdate;
                             insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
                             (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_PARAMETROS,
                             AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR, AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE,
                             AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
                             )
                             values
                             (
                            pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_PARAMETROS,
                            vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE,
                            vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO
                             );
                            commit;
                          EXCEPTION
                            WHEN OTHERS THEN
                            DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE FALLIDO');
                            DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                            DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                            ROLLBACK;
                          END; -- fin de control de excepcion de auditoria                  
                       END; 

                  -- ACTUALIZA VALORES EN LA TABLA   PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS  
                    sentencia := 'UPDATE ADMPT_TMP_VENCIMIENTO_PUNTOS';  
                    BEGIN 
                    
                      UPDATE PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS
                      SET ADMPN_REGPROC = 1
                      WHERE rowid = l_TABLE_C_CLIENTE(indx).my_rowid;                      
                       conRegistros := conRegistros + 1;

                    Exception                         
                       when others then
                          idCliente_error := l_TABLE_C_CLIENTE(indice).ADMPV_COD_CLI;
                          vAUD_ESTADO_LOTE := 'ERROR EN LA TRANSACCION';
                           vAUD_REGISTRO_ERROR_LOTE := 'Sentencia: '|| sentencia ||
                                    ' CATEGORIA : '|| K_CATEGORIA ||' ADMPV_COD_CLI Registro que genera ERROR: ' || idCliente_error ||CHR(10)||CHR(13)||
                                    ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)||
                                    ' DESCERROR ' || SUBSTR(SQLERRM, 1, 250);
                            vAUD_MENSAJE_ERROR := 'Ha ocurrido un ERROR en el LOTE: ' || contLote;

                            DBMS_OUTPUT.put_line(CHR(9) || vAUD_MENSAJE_ERROR);
                            DBMS_OUTPUT.put_line(CHR(9) || vAUD_REGISTRO_ERROR_LOTE);

                            vContLotesError   := vContLotesError + 1;
                            vCadenaLotesError := vCadenaLotesError || contLote || ', ';
                            conRegistros := contLote * K_BLIMIT + 1;
                            ROLLBACK;
                            --Despues del rollback del lote se hara el insert en auditoria con los datos de error
                              BEGIN 
                                vAUD_FECHA_REGISTRO := sysdate;
                                 insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
                                 (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_PARAMETROS,
                                 AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR, AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE,
                                 AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
                                 )
                                 values
                                 (
                                pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_PARAMETROS,
                                vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE,
                                vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO
                                 );
                                commit;
                              EXCEPTION
                                WHEN OTHERS THEN
                                DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE FALLIDO');
                                DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                                DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                                ROLLBACK;
                              END; -- fin de control de excepcion de auditoria                  
                       END; 


             END LOOP;  
             commit;
             vAUD_FECHA_REGISTRO :=SYSDATE;
             DBMS_OUTPUT.put_line(CHR(9) || 'ACTUALIZACION TABLA PCLUB.ADMPT_SALDOS_CLIENTE - PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS');     
             vAUD_ESTADO_LOTE  := 'ACTUALIZACION TABLA PCLUB.ADMPT_SALDOS_CLIENTE - PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS';     
             --vAUD_DESCRIPCION_PROCESO := 'ACTUALIZACION TABLA PCLUB.ADMPT_SALDOS_CLIENTE - PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS';
             vAUD_HORA_FIN_LOTE := sysdate;
             vAUD_REGISTRO_ERROR_LOTE :='';
             vAUD_MENSAJE_ERROR :='';
                      --Como el insert de auditoria no es mandatorio se controlara en su propio bloque de excepcion
               BEGIN
                   --Insert de auditoria en caso de insert y delete de migracion EXITOSO
                     insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
                     (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_ID_EJEC_PROCESO,
                     AUD_EJECUCION_PROCESO, AUD_PARAMETROS, AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR,
                     AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE, AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
                     )
                     values
                     (
                    pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_ID_EJEC_PROCESO,
                    vAUD_EJECUCION_PROCESO, vAUD_PARAMETROS, vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR,
                    vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE, vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO
                     );

                     --Se manejan 1 commit para el insert del bulkCollect y para el registro de auditoria de extio
                     commit;
                     DBMS_OUTPUT.put_line(CHR(9) || 'REGISTRADO EN TABLA AUDITORIA_PROC_CLAROCLUB EXITOSO - MIGRACION KARDEX');

                 commit;
                EXCEPTION
                  WHEN OTHERS THEN
                  DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE FALLIDO');
                  DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                  DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                  ROLLBACK;
                END; -- fin de control de excepcion de auditoria
               EXIT WHEN C_CLIENTE%NOTFOUND;             


           END LOOP;
      CLOSE C_CLIENTE;

  -- finaliza el proceso
    vAUD_FECHA_REGISTRO := sysdate;

    vAUD_DESCRIPCION_PROCESO    := 'FIN DE EJECUCION DEL PROCESO - VENCIMIENTO DE PUNTOS';
    vAUD_ID_EJEC_PROCESO        := 'EP';
    vAUD_EJECUCION_PROCESO      := 'EJECUCION DEL PROCESO';
    vAUD_LOTE_DEBE_IR           := '';
    vAUD_LOTE_EJECUTO           := '';
    vAUD_ESTADO_LOTE            := '';
    vAUD_REGISTRO_ERROR_LOTE    := '';
    vAUD_MENSAJE_ERROR          := '';
    
     PCLUB.PKG_CC_PREPAGO.ADMPSI_DESAFI_REG_AUDITORIA(
        vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_ID_EJEC_PROCESO,
        vAUD_EJECUCION_PROCESO, vAUD_PARAMETROS, NULL, NULL, vAUD_LOTE_DEBE_IR, 
        vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE, vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, K_USUARIO,
        vESTADO_REGISTRO, K_OCODERROR, K_ODESCERROR 
        );
  --Bloque de manejo de Excepciones   
EXCEPTION
    WHEN NO_DATA_FOUND THEN
K_CODERROR         := -2;
    K_DESCERROR        := 'ERROR: NO se encontraron registros a procesar';
    DBMS_OUTPUT.put_line(CHR(9) || K_DESCERROR);
    ROLLBACK;
    WHEN DUP_VAL_ON_INDEX THEN
    K_CODERROR         := -3;
    K_DESCERROR        := 'ERROR: Se esta intentando guardar un REGISTRO DUPLICADO';
    DBMS_OUTPUT.put_line(CHR(9) || K_DESCERROR);
    ROLLBACK;
    WHEN TIMEOUT_ON_RESOURCE THEN
    K_CODERROR         := -4;
    K_DESCERROR        := 'ERROR: Se excedio el tiempo maximo de espera por un recurso en Oracle';
    DBMS_OUTPUT.put_line(CHR(9) || K_DESCERROR);
    ROLLBACK;  
    WHEN PROGRAM_ERROR THEN
    K_CODERROR         := -5;
    K_DESCERROR        := 'ERROR: ocurrio un error interno de PL/SQL';
    DBMS_OUTPUT.put_line(CHR(9) || K_DESCERROR);
    ROLLBACK;
    WHEN STORAGE_ERROR THEN
    K_CODERROR         := -6;
    K_DESCERROR        := 'ERROR: se ha excedido el tamanio de la memoria';
    DBMS_OUTPUT.put_line(CHR(9) || K_DESCERROR);
    ROLLBACK;        
    WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
    DBMS_OUTPUT.put_line(CHR(9) || 'STATUS DE EJECUCION FINAL');
    DBMS_OUTPUT.put_line( K_CODERROR);
    DBMS_OUTPUT.put_line( K_DESCERROR); 

  
END ADMPSS_PREVENCPTO_PROCE;

PROCEDURE ADMPSI_DESAFI_REG_AUDITORIA( 
          vAUD_ID_PROCESO           IN VARCHAR2,
          vAUD_FECHA_REGISTRO       IN DATE,
          vAUD_DESCRIPCION_PROCESO   IN VARCHAR2,
          vAUD_ID_EJEC_PROCESO      IN VARCHAR2,
          vAUD_EJECUCION_PROCESO    IN VARCHAR2,
          vAUD_PARAMETROS            IN VARCHAR2,
          
          vAUD_HORA_INICIO_LOTE    IN DATE,
          vAUD_HORA_FIN_LOTE      IN DATE,
          vAUD_LOTE_DEBE_IR        IN VARCHAR2,
          vAUD_LOTE_EJECUTO        IN VARCHAR2,
          vAUD_ESTADO_LOTE        IN VARCHAR2,
          
          vAUD_REGISTRO_ERROR_LOTE   IN VARCHAR2,
          vAUD_MENSAJE_ERROR      IN VARCHAR2,
          vUSUARIO                IN VARCHAR2,
          vESTADO_REGISTRO        IN VARCHAR2, ---EXITOSO, FALLIDO
          
          K_CODERROR               OUT NUMBER,
          K_DESCERROR             OUT VARCHAR2)
IS

BEGIN
  K_CODERROR:=0;
  K_DESCERROR:='REGISTRO EN TABLA DE AUDITORIA '|| vESTADO_REGISTRO;
  
  insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
   (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_ID_EJEC_PROCESO, 
   AUD_EJECUCION_PROCESO, AUD_PARAMETROS, AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR, 
   AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE, AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
   )
   values
   (
  pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_ID_EJEC_PROCESO, 
  vAUD_EJECUCION_PROCESO,vAUD_PARAMETROS,vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, 
  vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE, vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, vUSUARIO
   );
   
  commit;
  DBMS_OUTPUT.put_line(CHR(9) || 'REGISTRADO EN TABLA AUDITORIA_PROC_CLAROCLUB ' || vESTADO_REGISTRO);
  
EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE '|| vESTADO_REGISTRO);
  DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
  DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
  
  K_CODERROR:=SQLCODE;
    K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
  ROLLBACK;
END ADMPSI_DESAFI_REG_AUDITORIA;
END PKG_CC_PREPAGO;
/