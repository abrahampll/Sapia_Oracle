create or replace package body PCLUB.PKG_CC_ALINEACION_PTO is

PROCEDURE ADMPSI_ACT_SLDO_INI(K_HILOS IN NUMBER,
                              K_FECHA IN DATE,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2)
  IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ACT_SLDO_INI
  -- Proposito           :  Proceso inicial para actualizar los nuevos campos ADMPN_ALIN_SALDO_CC y ADMPN_ALIN_FECHA_CC
  --                        con el kardex.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************


V_NUM_REG NUMBER:=0;
V_CONTADOR NUMBER:=0;
V_CAT_MAX NUMBER:=K_HILOS;
V_TAM_PAGE NUMBER:=0;

V_INDEX NUMBER:=1;
V_COUNT_REG NUMBER;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';


SELECT COUNT(1) INTO V_COUNT_REG
FROM PCLUB.ADMPT_TMP_CLIENTE_PRE
WHERE
     ADMPN_REGPROC = 0
     AND ADMPN_CATEGORIA=-1;

IF (V_COUNT_REG=0) THEN

 INSERT INTO PCLUB.TMP_CLI_ALL(ADMPV_COD_CLI)
    SELECT A.ADMPV_COD_CLI
    FROM PCLUB.ADMPT_CLIENTE A
    WHERE
    A.ADMPV_COD_TPOCL='3'
    AND A.ADMPC_ESTADO='A';
    COMMIT;

   INSERT INTO PCLUB.TMP_CLI_NOEXISTE_SALDO
   SELECT ADMPV_COD_CLI
   FROM PCLUB.TMP_CLI_ALL B
   WHERE
   NOT EXISTS (
              select  1
              from
              PCLUB.ADMPT_SALDOS_CLIENTE C
              where C.ADMPV_COD_CLI =   B.ADMPV_COD_CLI);
   COMMIT;

   INSERT INTO PCLUB.ADMPT_TMP_CLIENTE_PRE(ADMPV_COD_CLI)
   SELECT ADMPV_COD_CLI FROM (
     SELECT ADMPV_COD_CLI FROM PCLUB.TMP_CLI_ALL
     MINUS
     SELECT ADMPV_COD_CLI FROM PCLUB.TMP_CLI_NOEXISTE_SALDO
   );
   COMMIT;





SELECT COUNT(C.ADMPV_COD_CLI)
    INTO V_NUM_REG
    FROM PCLUB.ADMPT_TMP_CLIENTE_PRE C;

  IF V_NUM_REG > 0 THEN

    V_TAM_PAGE:= (V_NUM_REG/V_CAT_MAX);

    WHILE V_INDEX < (V_CAT_MAX + 1)
      LOOP

          UPDATE PCLUB.ADMPT_TMP_CLIENTE_PRE
          SET ADMPN_CATEGORIA = V_INDEX
          WHERE ROWNUM BETWEEN 1 AND (V_TAM_PAGE + 1)
          AND ADMPN_CATEGORIA=-1
          AND ADMPN_REGPROC = 0;
          COMMIT;

          V_INDEX:=V_INDEX + 1;
      END LOOP;
   END IF;
   INSERT INTO PCLUB.ADMPT_ALINEACION_PREP VALUES(SYSDATE);
   COMMIT;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_CLI_ALL';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_CLI_NOEXISTE_SALDO';
ELSE
   K_CODERROR:=-1;
   K_DESCERROR:='Existen registros en la tabla ADMPT_TMP_CLIENTE_PRE. Ejecutar el Shell SH013_ALINEACION_PUNTOS_INI_LIMPIAR.sh';
END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR:=1;
    K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ACT_SLDO_INI;

PROCEDURE ADMPSI_ACT_SLDO_PROCE(K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
c_cursor SYS_REFCURSOR;
V_COD_CLI VARCHAR2(50);

V_SALDO_PUNTO NUMBER:=0;
V_SALDO_ACT NUMBER:=0;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';

 FOR REGISTR IN (SELECT C.ADMPV_COD_CLI FROM
                 PCLUB.ADMPT_TMP_CLIENTE_PRE C
                 WHERE
                 C.ADMPN_CATEGORIA  = K_PROC
                 AND C.ADMPN_REGPROC = 0)

 LOOP
   V_COD_CLI := REGISTR.ADMPV_COD_CLI;

   --------------INICIO PROCESO---------------------------
     BEGIN
          SELECT NVL(SUM(K.ADMPN_SLD_PUNTO),0) INTO V_SALDO_PUNTO FROM PCLUB.ADMPT_KARDEX K
          WHERE
          K.ADMPV_COD_CLI = V_COD_CLI
          AND ((K.ADMPC_TPO_PUNTO='C') OR (K.ADMPC_TPO_PUNTO='L')OR (K.ADMPC_TPO_PUNTO='B'))
          AND K.ADMPN_SLD_PUNTO>0
          AND K.ADMPC_TPO_OPER='E'
          AND (K.ADMPV_COD_CPTO NOT IN ('95','96','97','4'))
          AND K.ADMPC_ESTADO='A';


          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
          SET
          S.ADMPN_SALDO_CC = V_SALDO_PUNTO,
          S.ADMPN_ALIN_SALDO_CC = V_SALDO_PUNTO,
          S.ADMPN_ALIN_FECHA_CC = SYSDATE,
          S.ADMPN_SALDO_CC_ANTERIOR = V_SALDO_ACT
          WHERE
          S.ADMPV_COD_CLI = V_COD_CLI;

          UPDATE PCLUB.ADMPT_TMP_CLIENTE_PRE
          SET
          ADMPN_REGPROC = 1
          WHERE
          ADMPV_COD_CLI = V_COD_CLI;

        COMMIT;

     EXCEPTION
       WHEN OTHERS THEN
        ROLLBACK;

        UPDATE PCLUB.ADMPT_TMP_CLIENTE_PRE
        SET ADMPN_REGPROC = 1,
        ADMPN_CODERROR=-1,
        ADMPV_ERRORMSJ='Error en la ejecución de actualización'
        WHERE
        ADMPV_COD_CLI = V_COD_CLI;
        COMMIT;

     END;

 END LOOP;

END ADMPSI_ACT_SLDO_PROCE;


PROCEDURE ADMPSI_ACT_SLDO_PROCE_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR    OUT NUMBER,
                                     K_DESCERROR   OUT VARCHAR2)
IS
BEGIN
  K_CODERROR:='0';
  K_DESCERROR:='';
SELECT COUNT(1) INTO K_COUNT FROM ADMPT_TMP_CLIENTE_PRE T
WHERE T.ADMPN_CATEGORIA = K_PROC
AND T.ADMPN_REGPROC = 0;
EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ACT_SLDO_PROCE_CONF;

PROCEDURE ADMPSI_ACT_SLDO_INI_BON(K_HILOS IN NUMBER,
                              K_FECHA IN DATE,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2)
  IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ACT_SLDO_INI_BON
  -- Proposito           :  Proceso inicial para actualizar los nuevos campos ADMPN_ALIN_SALDO_CC y ADMPN_ALIN_FECHA_CC
  --                        con el kardex.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************


V_NUM_REG NUMBER:=0;
V_CONTADOR NUMBER:=0;
V_CAT_MAX NUMBER:=K_HILOS;
V_TAM_PAGE NUMBER:=0;
-----
V_INDEX NUMBER:=1;
V_COUNT_REG NUMBER;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';


SELECT COUNT(1) INTO V_COUNT_REG FROM ADMPT_TMP_CLIENTE_PRE_BONO;


IF (V_COUNT_REG=0) THEN
  INSERT INTO ADMPT_TMP_CLIENTE_PRE_BONO(ADMPV_COD_CLI,ADMPN_GRUPO)
  select c.admpv_cod_cli,s.admpn_grupo from admpt_saldos_bono_cliente s,admpt_cliente c
  where s.admpv_cod_cli = c.admpv_cod_cli
  and c.ADMPV_COD_TPOCL='3'
  and c.ADMPC_ESTADO='A'
  AND C.ADMPD_FEC_REG>=trunc(TO_DATE('01/01/2015','DD/MM/YYYY'))
  AND C.ADMPD_FEC_REG<trunc(TO_DATE('06/08/2015','DD/MM/YYYY'));
  --AND C.ADMPD_FEC_REG>=trunc(TO_DATE('01/01/2014','DD/MM/YYYY'))
  --AND C.ADMPD_FEC_REG<trunc(TO_DATE('01/02/2015','DD/MM/YYYY'));

COMMIT;


SELECT COUNT(1)
    INTO V_NUM_REG
    FROM ADMPT_TMP_CLIENTE_PRE_BONO C;
--    WHERE ADMPD_FECHA = K_FECHA;

  IF V_NUM_REG > 0 THEN

    V_TAM_PAGE:= (V_NUM_REG/V_CAT_MAX);

    WHILE V_INDEX < (V_CAT_MAX + 1)
      LOOP
          UPDATE ADMPT_TMP_CLIENTE_PRE_BONO
          SET ADMPN_CATEGORIA = V_INDEX
          WHERE ROWNUM BETWEEN 1 AND (V_TAM_PAGE + 1)
          AND ADMPN_CATEGORIA=-1;
          COMMIT;
          V_INDEX:=V_INDEX + 1;
      END LOOP;
   END IF;
ELSE
   K_CODERROR:=-1;
   K_DESCERROR:='Existen registros en la tabla ADMPT_TMP_CLIENTE_PRE_BONO. Ejecutar el Shell SH013_ALINEACION_PUNTOS_INI_LIMPIAR_BON.sh';
END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR:=1;
    K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ACT_SLDO_INI_BON;


PROCEDURE ADMPSI_ACT_SLDO_PROCE_BON(K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
c_cursor SYS_REFCURSOR;
V_COD_CLI VARCHAR2(50);

V_SALDO_PUNTO NUMBER:=0;
V_SALDO_PUNTO_IB NUMBER:=0;
V_ADMPV_TIPO NUMBER;
V_SALDO_ACT NUMBER:=0;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';
OPEN c_cursor FOR
SELECT C.ADMPV_COD_CLI,C.ADMPN_GRUPO FROM
ADMPT_TMP_CLIENTE_PRE_BONO C
WHERE
C.ADMPN_CATEGORIA  = K_PROC
AND C.ADMPN_REGPROC = 0;

LOOP
    FETCH c_cursor INTO V_COD_CLI,V_ADMPV_TIPO;
    EXIT WHEN c_cursor%NOTFOUND;
    BEGIN

      BEGIN
        SELECT NVL(S.ADMPN_SALDO,0) INTO V_SALDO_ACT
        FROM ADMPT_SALDOS_BONO_CLIENTE S
        WHERE S.ADMPV_COD_CLI = V_COD_CLI AND S.ADMPN_GRUPO = V_ADMPV_TIPO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_SALDO_ACT:= NULL;
      END;

    IF (V_SALDO_ACT IS NOT NULL) THEN
       --************************
        SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0) INTO V_SALDO_PUNTO
        FROM ADMPT_KARDEX K
        WHERE
        K.ADMPV_COD_CLI=V_COD_CLI
        AND K.ADMPN_SLD_PUNTO>0
        AND K.ADMPC_TPO_OPER='E'
        AND K.ADMPC_TPO_PUNTO='B'
        AND K.ADMPV_COD_CPTO IN ('95','96','97')
        AND K.ADMPN_TIP_PREMIO=V_ADMPV_TIPO
        AND K.ADMPC_ESTADO='A';



        UPDATE ADMPT_SALDOS_BONO_CLIENTE S
        SET
        S.ADMPN_SALDO = V_SALDO_PUNTO,
        S.ADMPN_ALIN_SALDO_BONO =  V_SALDO_PUNTO,
        S.ADMPN_ALIN_FECHA_BONO  = SYSDATE,
        S.ADMPN_SALDO_BON_ANTERIOR = V_SALDO_ACT
        WHERE
        ADMPV_COD_CLI = V_COD_CLI
        AND ADMPN_GRUPO=V_ADMPV_TIPO;


        UPDATE ADMPT_TMP_CLIENTE_PRE_BONO
        SET
        ADMPN_REGPROC = 1
        WHERE
        ADMPV_COD_CLI = V_COD_CLI
        AND ADMPN_GRUPO = V_ADMPV_TIPO;
        --************************
    ELSE
      UPDATE ADMPT_TMP_CLIENTE_PRE_BONO
        SET ADMPN_REGPROC = 1,
        ADMPN_CODERROR=-1,
        ADMPV_ERRORMSJ='El codigo de cliente '|| V_COD_CLI || ' no se encuentra en la tabla ADMPT_SALDOS_BONO_CLIENTE.'
        WHERE
        ADMPV_COD_CLI = V_COD_CLI
        AND ADMPN_GRUPO = V_ADMPV_TIPO;
    END IF;


    COMMIT;
        --SOLO PARA PODER PROBAR LA ALINEACION DE UNA LINEA
        --n_index:=n_index+1;
        --EXIT WHEN n_index=3;
     EXCEPTION
       WHEN OTHERS THEN
        ROLLBACK;

        UPDATE ADMPT_TMP_CLIENTE_PRE_BONO
        SET ADMPN_REGPROC = 1,
        ADMPN_CODERROR=-1,
        ADMPV_ERRORMSJ='Error en la ejecución de actualización'
        WHERE
        ADMPV_COD_CLI = V_COD_CLI
        AND ADMPN_GRUPO = V_ADMPV_TIPO;
        COMMIT;

     END;
end loop;

close c_cursor;


END ADMPSI_ACT_SLDO_PROCE_BON;


PROCEDURE ADMPSI_ACT_SLDO_PROC_BON_CNF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2)
IS
BEGIN
 K_CODERROR:='0';
  K_DESCERROR:='';
SELECT COUNT(1) INTO K_COUNT FROM ADMPT_TMP_CLIENTE_PRE_BONO T
WHERE T.ADMPN_CATEGORIA = K_PROC
AND T.ADMPN_REGPROC = 0;
EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ACT_SLDO_PROC_BON_CNF;


PROCEDURE ADMPSI_ACT_SLDO_INI_IB(K_HILOS IN NUMBER,
                              K_FECHA IN DATE,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2)
  IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ACT_SLDO_INI_IB
  -- Proposito           :  Proceso inicial para actualizar los nuevos campos ADMPN_ALIN_SALDO_CC y ADMPN_ALIN_FECHA_CC
  --                        con el kardex.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************


V_NUM_REG NUMBER:=0;
V_CONTADOR NUMBER:=0;
V_CAT_MAX NUMBER:=K_HILOS;
V_TAM_PAGE NUMBER:=0;
-----
V_INDEX NUMBER:=1;
V_COUNT_REG NUMBER;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';


SELECT COUNT(1) INTO V_COUNT_REG FROM ADMPT_TMP_CLIENTE_PRE_IB;

IF (V_COUNT_REG=0) THEN
  INSERT INTO ADMPT_TMP_CLIENTE_PRE_IB(ADMPV_COD_CLI_IB)
  select cib.admpn_cod_cli_ib from admpt_clienteib cib
    where
    cib.admpc_estado='A';
    
    --AND cib.admpd_fec_act>=trunc(TO_DATE('01/01/2014','DD/MM/YYYY'))
    --AND cib.admpd_fec_act<trunc(TO_DATE('01/02/2015','DD/MM/YYYY'));

    /*select s.admpn_cod_cli_ib,s.admpn_saldo_ib from admpt_clienteib cib, admpt_saldos_cliente s
    where
    cib.admpn_cod_cli_ib = s.admpn_cod_cli_ib
    and cib.admpc_estado='A'
    and s.admpn_saldo_ib is not null;*/

  /*INSERT INTO ADMPT_TMP_CLIENTE_PRE_IB(ADMPV_COD_CLI_IB,ADMPN_SALDO)
    select s.admpn_cod_cli_ib,0 from admpt_clienteib cib, admpt_saldos_cliente s
    where
    cib.admpn_cod_cli_ib = s.admpn_cod_cli_ib
    and cib.admpc_estado='A'
    and s.admpn_saldo_ib is null;  */
COMMIT;


SELECT COUNT(1)
    INTO V_NUM_REG
    FROM ADMPT_TMP_CLIENTE_PRE_IB C;
--    WHERE ADMPD_FECHA = K_FECHA;

  IF V_NUM_REG > 0 THEN

    V_TAM_PAGE:= (V_NUM_REG/V_CAT_MAX);

    WHILE V_INDEX < (V_CAT_MAX + 1)
      LOOP
          UPDATE ADMPT_TMP_CLIENTE_PRE_IB
          SET ADMPN_CATEGORIA = V_INDEX
          WHERE ROWNUM BETWEEN 1 AND (V_TAM_PAGE + 1)
          AND ADMPN_CATEGORIA=-1;
          COMMIT;
          V_INDEX:=V_INDEX + 1;
      END LOOP;
   END IF;
ELSE
   K_CODERROR:=-1;
   K_DESCERROR:='Existen registros en la tabla ADMPT_TMP_CLIENTE_PRE_IB. Ejecutar el Shell SH013_ALINEACION_PUNTOS_INI_IB_LIMPIAR.sh';
END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR:=1;
    K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ACT_SLDO_INI_IB;

PROCEDURE ADMPSI_ACT_SLDO_PROCE_IB(K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
c_cursor SYS_REFCURSOR;

V_COD_CLI_IB NUMBER;

V_SALDO_PUNTO_IB NUMBER:=0;
V_SALDO_ACT NUMBER:=0;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';
OPEN c_cursor FOR
SELECT C.ADMPV_COD_CLI_IB FROM
ADMPT_TMP_CLIENTE_PRE_IB C
WHERE
C.ADMPN_CATEGORIA  = K_PROC
AND C.ADMPN_REGPROC = 0;
/*SELECT C.ADMPV_COD_CLI_IB,C.ADMPN_SALDO FROM
ADMPT_TMP_CLIENTE_PRE_IB C
WHERE
C.ADMPN_CATEGORIA  = K_PROC;*/

LOOP
    FETCH c_cursor INTO V_COD_CLI_IB;
    EXIT WHEN c_cursor%NOTFOUND;
    BEGIN
        --************************

        BEGIN
          SELECT NVL(S.ADMPN_SALDO_IB,0) INTO V_SALDO_ACT FROM ADMPT_SALDOS_CLIENTE S
          WHERE S.ADMPN_COD_CLI_IB = V_COD_CLI_IB;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               V_SALDO_ACT:= NULL;
        END;

        IF (V_SALDO_ACT IS NOT NULL) THEN
          SELECT NVL(SUM(K.ADMPN_SLD_PUNTO),0) INTO V_SALDO_PUNTO_IB FROM ADMPT_KARDEX K
          WHERE
          K.ADMPN_COD_CLI_IB=V_COD_CLI_IB
          AND K.ADMPC_TPO_PUNTO='I'
          AND K.ADMPN_SLD_PUNTO>0
          AND K.ADMPC_TPO_OPER='E'
          AND K.ADMPC_ESTADO='A';

          UPDATE ADMPT_SALDOS_CLIENTE S
          SET
          S.ADMPN_SALDO_IB = V_SALDO_PUNTO_IB,
          S.ADMPN_ALIN_SALDO_IB = V_SALDO_PUNTO_IB,
          S.ADMPN_ALIN_FECHA_IB = SYSDATE,
          S.ADMPN_SALDO_IB_ANTERIOR = V_SALDO_ACT
          WHERE
          S.ADMPN_COD_CLI_IB=V_COD_CLI_IB;


          UPDATE ADMPT_TMP_CLIENTE_PRE_IB I
          SET
          I.ADMPN_REGPROC = 1
          WHERE
          I.ADMPV_COD_CLI_IB = V_COD_CLI_IB;
        ELSE
           UPDATE ADMPT_TMP_CLIENTE_PRE_IB
            SET ADMPN_REGPROC = 1,
            ADMPN_CODERROR=-1,
            ADMPV_ERRORMSJ='No se encontró el codigo ib ' || to_char(V_COD_CLI_IB) || ' en la tabla ADMPT_SALDOS_CLIENTE.'
            WHERE
            ADMPV_COD_CLI_IB = V_COD_CLI_IB;
        END IF;


        --************************
        COMMIT;

     EXCEPTION
       WHEN OTHERS THEN
        ROLLBACK;

        UPDATE ADMPT_TMP_CLIENTE_PRE_IB
        SET ADMPN_REGPROC = 1,
        ADMPN_CODERROR=-1,
        ADMPV_ERRORMSJ='Error en la ejecución de actualización'
        WHERE
        ADMPV_COD_CLI_IB = V_COD_CLI_IB;
        COMMIT;

     END;
end loop;

close c_cursor;


END ADMPSI_ACT_SLDO_PROCE_IB;


PROCEDURE ADMPSI_ACT_SLDO_PROC_IB_CNF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2)
IS
BEGIN
K_CODERROR:='0';
K_DESCERROR:='';
SELECT COUNT(1) INTO K_COUNT FROM ADMPT_TMP_CLIENTE_PRE_IB T
WHERE T.ADMPN_CATEGORIA = K_PROC
AND T.ADMPN_REGPROC = 0;
EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ACT_SLDO_PROC_IB_CNF;

PROCEDURE ADMPSI_ALIN_SLD_CARGA(K_FECHA IN DATE,
                                K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_CARGA
  -- Proposito           :  Proceso para cargar los clientes que hayan realizado movimiento desde la ultima alineacion de puntos
  --                        en la tabla temporal ADMPT_TMP_ALINEACION_SLDO
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
  V_COUNT        NUMBER := 0;
  V_COUNTTMP     NUMBER := 0;
  V_COUNTTMPPROC NUMBER := 0;
  V_LASTDATEALIN DATE;
  V_LIMITE NUMBER;
----------W----------------------------------  
V_ID_EJEC_PROCESO  VARCHAR2 (3);
V_EJECUCION_PROCESO  VARCHAR2(50);
V_CURRENT_DATE DATE;
VID_PROCESO varchar2(3);
VDESC_PROCESO varchar2(50);
V_PARAM_ENT varchar2(100);
V_CURRENT_DATE_INI DATE;
V_CURRENT_DATE_FIN DATE;
V_USER VARCHAR2(10);
V_ADMPV_COD_CLI VARCHAR2(40);
V_SENTENCIA VARCHAR2(10) := '';
V_ERROR VARCHAR2(1000);
contLote             NUMBER := 0;
conRegistros         NUMBER :=0;
limSup               NUMBER :=0;
lotereal             NUMBER :=0;
V_LOTE_DEBE_IR varchar2(50);
V_LOTE_EJECUTO varchar2(50);
V_MSG_ERROR VARCHAR(1000);
V_TABLA VARCHAR(30);
---------W---------------------------------
  cursor c1(fecha date) is
   select ADMPV_COD_CLI,K.ADMPN_SLD_PUNTO
     FROM PCLUB.admpt_kardex k
    WHERE (not k.admpv_cod_cli like ('%-1'))
      and k.admpd_fec_reg > fecha
      and ((K.ADMPC_TPO_PUNTO = 'C') or (K.ADMPC_TPO_PUNTO = 'L') or
          (K.ADMPC_TPO_PUNTO = 'B'))
      and K.ADMPN_SLD_PUNTO > 0
      and K.ADMPC_TPO_OPER = 'E'
      and (K.ADMPV_COD_CPTO <> '95' and K.ADMPV_COD_CPTO <> '96' and
          K.ADMPV_COD_CPTO <> '97' and K.ADMPV_COD_CPTO <> '4')
      and K.ADMPC_ESTADO = 'A';

  cursor c2 is
    SELECT DISTINCT ADMPV_COD_CLI
      FROM PCLUB.ADMPT_KARDEX_CLIE B
     WHERE EXISTS (select 1
              from PCLUB.admpt_cliente C
             where C.ADMPV_COD_CLI = B.ADMPV_COD_CLI
               AND C.admpc_estado = 'A'
               AND C.admpv_cod_tpocl = '3');
  cursor c3 is
    SELECT A.ADMPV_COD_CLI, A.ADMPV_SALDO_K
       from (SELECT B.ADMPV_COD_CLI, SUM(SK.ADMPV_SALDO_K) ADMPV_SALDO_K
               FROM PCLUB.ADMPT_CLIE_ALIN_PREP B
              INNER JOIN PCLUB.ADMPT_KARDEX_CLIE SK
                 ON B.ADMPV_COD_CLI = SK.ADMPV_COD_CLI
              group by B.ADMPV_COD_CLI) A
      inner join PCLUB.admpt_saldos_cliente C
         on A.ADMPV_COD_CLI = C.ADMPV_COD_CLI
      where a.ADMPV_SALDO_K > C.ADMPN_SALDO_CC;          
 
  type type_t1 is table of c1%rowtype index by pls_integer;
  t type_t1;

  type type_t2 is table of c2%rowtype index by pls_integer;
  t2 type_t2;

  type type_t3 is table of c3%rowtype index by pls_integer;
  t3 type_t3;
   
BEGIN

  V_LIMITE:=1000;
----------W------------------------------ 
VID_PROCESO:='APP';
VDESC_PROCESO:='CARGA DE SALDOS';
V_ID_EJEC_PROCESO:='CR';
V_EJECUCION_PROCESO:='CARGA DE REGISTROS';

V_CURRENT_DATE:=SYSDATE;
V_PARAM_ENT:='Parametros de entrada: ' || 'K_FECHA=' || K_FECHA  ||' K_USUARIO=' || K_USUARIO || ' V_BULKCOLLECT_LIMIT=' || V_LIMITE;
V_USER:=USER;
V_ADMPV_COD_CLI:='';
--V_ERROR:='';
V_MSG_ERROR:='';
----------W-----------------------------
  SELECT COUNT(1) INTO V_COUNTTMP FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO;

  IF V_COUNTTMP = 0 THEN
    
    SELECT MAX(FECHA) INTO V_LASTDATEALIN FROM PCLUB.ADMPT_ALINEACION_PREP;
---------------W------------------------------------
      V_CURRENT_DATE_INI:=SYSDATE;
      V_SENTENCIA:='INSERT';    
   -----------------W-1------------------------------   
    conRegistros := conRegistros + 1; 
    OPEN c1(V_LASTDATEALIN);
    LOOP
      FETCH c1 BULK COLLECT
        INTO t LIMIT V_LIMITE;
    --  FORALL i IN 1 .. t.count
    BEGIN
      contLote := contLote +1;
      limSup := contLote * V_LIMITE;   
      lotereal := conRegistros + t.COUNT-1;
      V_LOTE_DEBE_IR:='LOTE NRO DEBE IR: ' || contLote || ' del ' || conRegistros || ' al ' || limSup;
      V_LOTE_EJECUTO:='LOTE NRO VA:      ' || contLote || ' del ' || conRegistros || ' al ' || lotereal;  
    ---------------------------------------
     
      FOR i IN 1 .. t.count
       LOOP 
        V_ADMPV_COD_CLI:=  t(i).admpv_cod_cli;            
        INSERT INTO PCLUB.ADMPT_KARDEX_CLIE
          (ADMPV_COD_CLI,ADMPV_SALDO_K)
        values
          (t(i).admpv_cod_cli,t(i).ADMPN_SLD_PUNTO);
         
         conRegistros := conRegistros + 1;
         COMMIT;  
        END LOOP;
        
       V_CURRENT_DATE_FIN:=SYSDATE;
       --Registro para auditoria--w-----------------------------------------
       V_ERROR:='';
       V_TABLA:='ADMPT_KARDEX_CLIE';         
       INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
       values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI, V_CURRENT_DATE_FIN, V_LOTE_DEBE_IR, V_LOTE_EJECUTO ,'Sentencia: ' || V_SENTENCIA || ' ' || V_TABLA ||  ' correcto, se realiza COMMIT','','',V_USER);
      
       COMMIT;
       --------w---------------------------------------------------------------------------  --        
      EXIT WHEN c1%NOTFOUND;
      EXCEPTION
            WHEN OTHERS THEN
            ROLLBACK;   
             --Registro para auditoria Error-
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
       
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
              values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
      COMMIT;
            conRegistros := conRegistros + V_LIMITE;
               
      END;
    END LOOP;
    CLOSE c1;
  
    
  ---------------------------------------------
  conRegistros:=0;
  limSup:=0;
  lotereal:=0;
  contLote:=0;
  conRegistros := conRegistros + 1;
    OPEN c2;
    LOOP
      FETCH c2 BULK COLLECT
        INTO t2 LIMIT V_LIMITE;       
      BEGIN
---------w--------------------------------------------        
      contLote := contLote +1;
      limSup := contLote * V_LIMITE;   
      lotereal := conRegistros + t2.COUNT-1;
      V_LOTE_DEBE_IR:='LOTE NRO DEBE IR: ' || contLote || ' del ' || conRegistros || ' al ' || limSup;
      V_LOTE_EJECUTO:='LOTE NRO VA:      ' || contLote || ' del ' || conRegistros || ' al ' || lotereal;  
    ---------------------------------------       
     --- FORALL i IN 1 .. t2.count     
       FOR i IN 1 .. t2.count
       LOOP
        V_ADMPV_COD_CLI:=  t2(i).admpv_cod_cli;   
        INSERT INTO PCLUB.ADMPT_CLIE_ALIN_PREP
          (ADMPV_COD_CLI)
        values
          (t2(i).ADMPV_COD_CLI);
          
         conRegistros := conRegistros + 1;
         COMMIT;
       END LOOP;
      
       V_CURRENT_DATE_FIN:=SYSDATE;
       --Registro para auditoria--w-----------------------------------------
       V_ERROR:='';
       V_TABLA:='ADMPT_CLIE_ALIN_PREP';         
       INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG) 
       values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI, V_CURRENT_DATE_FIN, V_LOTE_DEBE_IR, V_LOTE_EJECUTO ,'Sentencia: ' || V_SENTENCIA || ' ' || V_TABLA ||  ' correcto, se realiza COMMIT','','',V_USER);
       COMMIT;
       
      EXIT WHEN c2%NOTFOUND;
      EXCEPTION
            WHEN OTHERS THEN
            ROLLBACK; 
             --Registro para auditoria Error-
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
       
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
             values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
      COMMIT;
            conRegistros := conRegistros + V_LIMITE;
 
      --------w---------------------------------------------------------------------------   
  END;                    
    END LOOP;
    CLOSE c2;
    
-------------------------3----------------------------------------------------------------
  conRegistros:=0;
  limSup:=0;
  lotereal:=0;
  contLote:=0;
   conRegistros := conRegistros + 1;
    OPEN c3;
    LOOP
      FETCH c3 BULK COLLECT
        INTO t3 LIMIT V_LIMITE;        
   BEGIN
      contLote := contLote +1;
      limSup := contLote * V_LIMITE;   
      lotereal := conRegistros + t3.COUNT-1;
      V_LOTE_DEBE_IR:='LOTE NRO DEBE IR: ' || contLote || ' del ' || conRegistros || ' al ' || limSup;
      V_LOTE_EJECUTO:='LOTE NRO VA:      ' || contLote || ' del ' || conRegistros || ' al ' || lotereal;  
       ---   FORALL i IN 1 .. t3.count
       FOR i IN 1 .. t3.count
       LOOP  
           V_ADMPV_COD_CLI:=  t3(i).admpv_cod_cli;          
        INSERT INTO PCLUB.ADMPT_TMP_ALINEACION_SLDO
          (ADMPV_COD_CLI,
           ADMPD_ULT_ACTU,
           ADMPD_FECHA,
           ADMPN_SLD_PTO_KX)
        values
          (t3(i).admpv_cod_cli,
           V_LASTDATEALIN,
           K_FECHA,
           t3(i).ADMPV_SALDO_K);                      
           
           conRegistros := conRegistros + 1;
           COMMIT;
       END LOOP;
       
       V_CURRENT_DATE_FIN:=SYSDATE;
       --Registro para auditoria--w-----------------------------------------
       V_ERROR:='';   
       V_TABLA:='ADMPT_TMP_ALINEACION_SLDO';
       INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
       values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI, V_CURRENT_DATE_FIN, V_LOTE_DEBE_IR, V_LOTE_EJECUTO ,'Sentencia: ' || V_SENTENCIA || ' ' || V_TABLA ||  ' correcto, se realiza COMMIT','','',V_USER);
       COMMIT;
       --------w---------------------------------------------------------------------------   
      EXIT WHEN c3%NOTFOUND; 
        EXCEPTION
            WHEN OTHERS THEN
            ROLLBACK; 
             --Registro para auditoria Error-
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
      COMMIT;
       
            conRegistros := conRegistros + V_LIMITE;
     END;                
    END LOOP;
    CLOSE c3;
  
  
   EXECUTE IMMEDIATE 'TRUNCATE TABLE PCLUB.ADMPT_KARDEX_CLIE';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE PCLUB.ADMPT_CLIE_ALIN_PREP';  
      
    K_CODERROR  := 0;
    K_DESCERROR := ' ';
  
    select count(1) into V_COUNT from PCLUB.ADMPT_TMP_ALINEACION_SLDO;
    if V_COUNT = 0 then
      K_CODERROR  := 1;
      K_DESCERROR := 'No se encontraron registros para alinear.';
    end if;
  
  ELSE
    SELECT COUNT(1)
      INTO V_COUNTTMPPROC
      FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO
     WHERE ADMPN_REGPROC = 1;
    IF V_COUNTTMP = V_COUNTTMPPROC THEN
      K_CODERROR  := 1;
      K_DESCERROR := 'Existen registros de la anterior alineacion en la tabla ADMPT_TMP_ALINEACION_SLDO procesados. Debe de limpiar la tabla.';
    ELSE
      K_CODERROR  := 1;
      K_DESCERROR := 'Existen registros de la anterior alineacion en la tabla ADMPT_TMP_ALINEACION_SLDO sin procesar.';
    END IF;
  
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PCLUB.ADMPT_KARDEX_CLIE';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PCLUB.ADMPT_CLIE_ALIN_PREP';    
    ROLLBACK;
    
 -------------w----------------------------------------------------
             --Registro para auditoria Error-
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
       
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
             values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
             COMMIT;
-----------w---------------------------------------------------------------------
    ---------------------
END ADMPSI_ALIN_SLD_CARGA;


PROCEDURE ADMPSI_ALIN_SLD_CATEG(K_HILOS        IN NUMBER,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
 --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_CATEG
  -- Proposito           :  Categoriza todos los registros de la tabla temporal ADMPT_TMP_ALINEACION_SLDO.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
  V_CAT_MAX NUMBER;
  V_NUM_REG NUMBER;
  V_TAM_PAGE NUMBER;
  V_INDEX NUMBER;
  BEGIN
    V_INDEX:=1;
    K_CODERROR:=0;
    K_DESCERROR:=0;
    V_CAT_MAX:=K_HILOS;

    SELECT COUNT(1)
    INTO V_NUM_REG
    FROM ADMPT_TMP_ALINEACION_SLDO C
    WHERE ADMPD_FECHA = K_FECHA;

    IF V_NUM_REG > 0 THEN


    V_TAM_PAGE:= (V_NUM_REG/V_CAT_MAX);

    WHILE V_INDEX < (V_CAT_MAX + 1)
      LOOP
          UPDATE ADMPT_TMP_ALINEACION_SLDO
          SET ADMPN_CATEGORIA = V_INDEX
          WHERE ROWNUM BETWEEN 1 AND (V_TAM_PAGE + 1)
          AND ADMPN_CATEGORIA=-1
          AND ADMPN_REGPROC = 0;
          COMMIT;

          V_INDEX:=V_INDEX + 1;
      END LOOP;

      INSERT INTO ADMPT_ALINEACION_PREP VALUES(SYSDATE);
      COMMIT;

    ELSE
      K_CODERROR  := 1;
      K_DESCERROR := 'No existen registros.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALIN_SLD_CATEG;

PROCEDURE ADMPSI_ALIN_SLD_PROCE(K_FECHA        IN DATE,
                                K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_PROCE
  -- Proposito           :  Proceso que se encargará de realizar la alineacion de puntos.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Wilber Donayres
  -- Fec Creacion        :  17/0/2017
  --****************************************************************

V_LIMITE numeric;
--------ww--------------------------
V_ID_EJEC_PROCESO  VARCHAR2 (3);
V_EJECUCION_PROCESO  VARCHAR2(50);
V_CURRENT_DATE DATE;
VID_PROCESO varchar2(3);
VDESC_PROCESO varchar2(50);
V_PARAM_ENT varchar2(100);
V_CURRENT_DATE_INI DATE;
V_CURRENT_DATE_FIN DATE;
V_USER VARCHAR2(10);
V_ADMPV_COD_CLI VARCHAR2(40);
V_SENTENCIA VARCHAR2(10) := '';
V_ERROR VARCHAR2(1000);
contLote             NUMBER := 0;
conRegistros         NUMBER :=0;
limSup               NUMBER :=0;
lotereal             NUMBER :=0;
V_LOTE_DEBE_IR varchar2(50);
V_LOTE_EJECUTO varchar2(50);
V_MSG_ERROR VARCHAR(1000);
V_TABLA VARCHAR(30);
------------------------------------------
cursor c_cursor(V_FECHA DATE) is
select  t1.admpv_cod_cli,t1.admpn_sld_pto_kx
from PCLUB.admpt_tmp_alineacion_sldo t1
where t1.admpn_categoria=K_PROC
and trunc(t1.admpd_fecha)=V_FECHA;

type type_t1 is table of c_cursor%rowtype index by pls_integer;

t type_t1;

BEGIN
V_LIMITE:=1000;
VID_PROCESO:='APP';
VDESC_PROCESO:='Alineación de puntos prepago';
V_ID_EJEC_PROCESO:='EP';
V_EJECUCION_PROCESO:='EJECUCION DEL PROCESO';
V_CURRENT_DATE:=SYSDATE;
V_PARAM_ENT:='Parametros de entrada: ' || 'K_FECHA=' || K_FECHA  ||' K_PROC=' || K_PROC || ' V_BULKCOLLECT_LIMIT=' || V_LIMITE;
V_USER:=USER;
V_ADMPV_COD_CLI:='';
--V_ERROR:='';
V_MSG_ERROR:='';

conRegistros := conRegistros + 1;
OPEN c_cursor(K_FECHA);
    LOOP
      FETCH c_cursor BULK COLLECT
        INTO t LIMIT V_LIMITE;
      BEGIN
    
      V_CURRENT_DATE_INI:=SYSDATE;
      V_SENTENCIA:='UPDATE';
      
      contLote := contLote +1;
      lotereal := conRegistros + t.COUNT-1;
      limSup := contLote * V_LIMITE;           
       V_LOTE_DEBE_IR:='LOTE NRO DEBE IR: ' || contLote || ' del ' || conRegistros || ' al ' || limSup;
       V_LOTE_EJECUTO:='LOTE NRO VA:      ' || contLote || ' del ' || conRegistros || ' al ' || lotereal;
     

      FOR i IN 1 .. t.count
      LOOP                   
         V_TABLA:='ADMPT_SALDOS_CLIENTE';
         V_ADMPV_COD_CLI:=  t(i).admpv_cod_cli;
      update PCLUB.admpt_saldos_cliente s
         set s.admpn_saldo_cc_anterior = s.admpn_saldo_cc,
             s.admpn_saldo_cc          = (select NVL(SUM(K.ADMPN_SLD_PUNTO),0) from PCLUB.ADMPT_KARDEX K
                      where
                      K.ADMPV_COD_CLI = t(i).admpv_cod_cli
                      and ((K.ADMPC_TPO_PUNTO='C') or (K.ADMPC_TPO_PUNTO='L') or (K.ADMPC_TPO_PUNTO='B'))
                      and K.ADMPN_SLD_PUNTO>0
                      and K.ADMPC_TPO_OPER='E'
                      and (K.ADMPV_COD_CPTO not in ('95','96','97','4'))
                      and K.ADMPC_ESTADO = 'A'),
             s.admpn_alin_fecha_cc     = K_FECHA,
             s.admpn_alin_saldo_cc     = t(i).admpn_sld_pto_kx 
       where s.admpv_cod_cli = t(i).admpv_cod_cli; 
       
       COMMIT;  
       conRegistros := conRegistros + 1;
       

     
        UPDATE PCLUB.admpt_tmp_alineacion_sldo s
        SET s.ADMPN_REGPROC = 1, ADMPV_PROCMSJ = 'Alineación Exitosa'
        WHERE s.admpv_cod_cli = t(i).admpv_cod_cli;
        COMMIT; 
        
      END LOOP;

       V_CURRENT_DATE_FIN:=SYSDATE;
       --Registro para auditoria ---
       V_ERROR:='';
       
         INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
         values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI, V_CURRENT_DATE_FIN, V_LOTE_DEBE_IR, V_LOTE_EJECUTO,'Sentencia: ' || V_SENTENCIA || ' ' || V_TABLA || ' correcto, se realiza COMMIT','','',V_USER);
         COMMIT; 
       
   EXIT WHEN c_cursor%NOTFOUND;     
    EXCEPTION
        when others then
             rollback;                           
      
             --Registro para auditoria Error--
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
      
            V_CURRENT_DATE_FIN:=SYSDATE;  
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
        
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
             values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
      COMMIT;
            conRegistros := conRegistros + V_LIMITE;
              
           
     END;
    END LOOP;
    CLOSE c_cursor;
    

K_CODERROR  := 0;
K_DESCERROR := ' ';

EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
       --Registro para auditoria Error---
        V_CURRENT_DATE_FIN:=SYSDATE;  
        V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
       V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;            
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
             values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
       COMMIT;
   
END ADMPSI_ALIN_SLD_PROCE;

PROCEDURE ADMPSI_ALIN_SLD_PROCE_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2)
IS
BEGIN
K_CODERROR:='0';
K_DESCERROR:='';
SELECT COUNT(1) INTO K_COUNT FROM PCLUB.admpt_tmp_alineacion_sldo T
WHERE T.ADMPN_CATEGORIA = K_PROC
AND T.ADMPN_REGPROC = 0;

EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ALIN_SLD_PROCE_CONF;

PROCEDURE ADMPSI_ALIN_SLD_CARGA_BON(K_FECHA IN DATE,
                                K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_CARGA_BON
  -- Proposito           :  Proceso para cargar los clientes que hayan realizado movimiento desde la ultima alineacion de puntos
  --                        en la tabla temporal ADMPT_TMP_ALINEACION_SLDO
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
V_COUNT NUMBER:=0;
V_COUNTTMP NUMBER:=0;
V_COUNTTMPPROC NUMBER:=0;
BEGIN

SELECT COUNT(1) INTO V_COUNTTMP FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO;
--V_COUNTTMP:=0;
IF V_COUNTTMP=0 THEN

--------------------------------------
    insert into PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO(ADMPV_COD_CLI,ADMPN_GRUPO,ADMPD_ULT_ACTU,ADMPD_FECHA)
      select k.admpv_cod_cli,k.admpn_tip_premio,s.admpn_alin_fecha_bono,K_FECHA
      from PCLUB.admpt_cliente c
      inner join PCLUB.admpt_saldos_bono_cliente s
            on s.admpv_cod_cli = c.admpv_cod_cli
      inner join PCLUB.admpt_kardex k
            on k.admpv_cod_cli = s.admpv_cod_cli
            and k.admpn_tip_premio = s.admpn_grupo
      where c.admpc_estado='A'
            AND c.admpv_cod_tpocl='3'
            AND k.admpc_tpo_punto='B'
            AND k.admpc_tpo_oper='E'
            AND (k.admpv_cod_cpto = '95' OR k.admpv_cod_cpto = '96' OR k.admpv_cod_cpto = '97')
            AND k.admpc_estado='A'
            AND s.admpn_alin_fecha_bono<k.admpd_fec_reg
      group by k.admpv_cod_cli,k.admpn_tip_premio,s.admpn_alin_fecha_bono;
      
      
   

    commit;
    K_CODERROR:=0;
    K_DESCERROR:=' ';

    select count(1) into V_COUNT from PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO;
    if V_COUNT=0 then
      K_CODERROR:=1;
      K_DESCERROR:='No se encontraron registros para alinear.';
    end if;
--------------------------------------
ELSE
    SELECT COUNT(1) INTO V_COUNTTMPPROC FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO WHERE ADMPN_REGPROC = 1;
    IF V_COUNTTMP = V_COUNTTMPPROC THEN
       K_CODERROR:=1;
       K_DESCERROR:='Existen registros de la anterior alineacion en la tabla ADMPT_TMP_ALINEACION_SLDO_BONO procesados. Debe de limpiar la tabla.';
    ELSE
       K_CODERROR:=1;
       K_DESCERROR:='Existen registros de la anterior alineacion en la tabla ADMPT_TMP_ALINEACION_SLDO_BONO sin procesar.';
    END IF;

END IF;



EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ADMPSI_ALIN_SLD_CARGA_BON;

PROCEDURE ADMPSI_ALIN_SLD_CATEG_BON(K_HILOS        IN NUMBER,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_CATEG_BON
  -- Proposito           :  Categoriza todos los registros de la tabla temporal ADMPT_TMP_ALINEACION_SLDO.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
  V_CONTADOR NUMBER;
  V_CAT_MAX NUMBER;
  V_NUM_REG NUMBER;
  
  V_INDEX NUMBER;
  V_TAM_PAGE NUMBER;

  BEGIN
    K_CODERROR:=0;
    K_DESCERROR:=0;
    V_CONTADOR:=0;
    V_INDEX:=1;
    V_CAT_MAX:=K_HILOS;

    SELECT COUNT(1)
    INTO V_NUM_REG
    FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO C
    WHERE ADMPD_FECHA = K_FECHA;

    IF V_NUM_REG > 0 THEN
    
      V_TAM_PAGE:= (V_NUM_REG/V_CAT_MAX);

      WHILE V_INDEX < (V_CAT_MAX + 1)
        LOOP
            UPDATE PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO
            SET ADMPN_CATEGORIA = V_INDEX
            WHERE ROWNUM BETWEEN 1 AND (V_TAM_PAGE + 1)
            AND ADMPN_CATEGORIA = -1;
            
            COMMIT;

            V_INDEX:=V_INDEX + 1;
        END LOOP;  
        
        
    

    
    
      K_CODERROR  := 0;
      K_DESCERROR := '';    
    ELSE
      K_CODERROR  := 1;
      K_DESCERROR := 'No existen registros.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALIN_SLD_CATEG_BON;

PROCEDURE ADMPSI_ALIN_SLD_PROCE_BON(K_FECHA        IN DATE,
                                K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_PROCE_BON
  -- Proposito           :  Proceso que se encargará de realizar la alineacion de puntos.
  --
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************

c_cursor SYS_REFCURSOR;

V_CURRENT_DATE DATE;
V_FUNCION varchar2(20);
BEGIN
--
V_CURRENT_DATE:=K_FECHA;

open c_cursor for
select t1.admpv_cod_cli, t1.admpn_grupo, t1.admpd_ult_actu from PCLUB.admpt_tmp_alineacion_sldo_bono t1
where t1.admpn_categoria=K_PROC
and t1.admpd_fecha=K_FECHA
AND t1.admpn_regproc = 0;


V_FUNCION := ADMPSI_ALIN_SLD_PROCE_BON_PRLL(V_CURRENT_DATE,C_CURSOR);

close c_cursor;
K_CODERROR  := 0;
K_DESCERROR := ' ';

EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ALIN_SLD_PROCE_BON;

FUNCTION ADMPSI_ALIN_SLD_PROCE_BON_PRLL(V_CURRENT_DATE IN DATE,
  c_cursor IN SYS_REFCURSOR
)
RETURN varchar2
PARALLEL_ENABLE (PARTITION c_cursor BY ANY)

IS
  PRAGMA AUTONOMOUS_TRANSACTION;

TYPE t_some_type IS RECORD (
  V_CODCLI VARCHAR(40),V_GRUPO NUMBER,V_FEC_ULT DATE
);
type t_some_type_tab is table of t_some_type;
/*
TYPE COLUMNATYPE IS TABLE OF varchar2(40);
tmpTable COLUMNATYPE;*/

  --lt_some_record  t_some_type;
  lt_some_array t_some_type_tab := NEW t_some_type_tab();

--------Variables log--------------------------
V_CURRENT_DATE1 DATE;
V_LIMITE numeric;
VID_PROCESO varchar2(3);
VDESC_PROCESO varchar2(50);
V_ID_EJEC_PROCESO  VARCHAR2 (3);
V_EJECUCION_PROCESO  VARCHAR2(50);
V_PARAM_ENT varchar2(100);
V_CURRENT_DATE_INI DATE;
V_CURRENT_DATE_FIN DATE;
V_USER VARCHAR2(10);
V_ADMPV_COD_CLI VARCHAR2(40);
V_SENTENCIA VARCHAR2(10) := '';
V_ERROR VARCHAR2(1000);
contLote NUMBER := 0;
conRegistros NUMBER :=0;
limSup  NUMBER :=0;
lotereal NUMBER :=0;
V_LOTE_DEBE_IR varchar2(50);
V_LOTE_EJECUTO varchar2(50);
V_MSG_ERROR VARCHAR(1000);
V_TABLA VARCHAR(30);
------------------------------------------
V_CODCLI VARCHAR(40);
V_SLD_KX NUMBER;
V_SLD_ULT_ALIN_KX NUMBER;
V_SLD_CC NUMBER;
V_GRUPO NUMBER;
-----------------------
V_FEC_ULT DATE;
N_LIMIT number;

BEGIN
N_LIMIT:=1000;

---------------------------------------------------------------------
V_LIMITE:=N_LIMIT;
VID_PROCESO:='APB';
VDESC_PROCESO:='Alineación de puntos bono';
V_CURRENT_DATE1:=SYSDATE;
V_ID_EJEC_PROCESO  :='EP';
V_EJECUCION_PROCESO:='EJECUCION DEL PROCESO';
V_PARAM_ENT:='Parametros de entrada: ' || 'V_CURRENT_DATE=' || V_CURRENT_DATE  || ' V_BULKCOLLECT_LIMIT=' || V_LIMITE;
V_USER:=USER;
V_ADMPV_COD_CLI:='';
V_ERROR:='';
V_MSG_ERROR:='';
conRegistros := conRegistros + 1;
------------------------------------------------------------------------

loop

    FETCH c_cursor BULK COLLECT 
    INTO lt_some_array LIMIT N_LIMIT;
  -----------------------------------------------------------------------   
      V_CURRENT_DATE_INI:=SYSDATE;
      V_SENTENCIA:='UPDATE';     
      contLote := contLote +1;
      lotereal := conRegistros + lt_some_array.COUNT-1;
      limSup := contLote * V_LIMITE;           
      V_LOTE_DEBE_IR:='LOTE NRO DEBE IR: ' || contLote || ' del ' || conRegistros || ' al ' || limSup;
      V_LOTE_EJECUTO:='LOTE NRO VA:      ' || contLote || ' del ' || conRegistros || ' al ' || lotereal;
 ----------------------------------------------------------------------  
    
      FOR indx IN 1 .. lt_some_array.COUNT
      LOOP
       
          V_CODCLI := lt_some_array(indx).V_CODCLI;
          V_GRUPO := lt_some_array(indx).V_GRUPO;
          V_FEC_ULT := lt_some_array(indx).V_FEC_ULT;
BEGIN

            BEGIN
              SELECT NVL(S.ADMPN_SALDO,0),NVL(S.ADMPN_ALIN_SALDO_BONO,0) INTO V_SLD_CC,V_SLD_ULT_ALIN_KX
               FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE S
              WHERE S.ADMPV_COD_CLI=V_CODCLI AND S.ADMPN_GRUPO = V_GRUPO;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SLD_CC:=NULL;
            END;

            IF (V_SLD_CC IS NOT NULL) THEN

          SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0) INTO V_SLD_KX
            FROM PCLUB.ADMPT_KARDEX K
            WHERE
            K.ADMPV_COD_CLI=V_CODCLI
            AND K.ADMPN_SLD_PUNTO>0
            AND K.ADMPC_TPO_OPER='E'
            AND K.ADMPC_TPO_PUNTO='B'
            AND K.ADMPV_COD_CPTO IN ('95','96','97')
            AND K.ADMPN_TIP_PREMIO=V_GRUPO
            AND K.ADMPC_ESTADO='A';
            --AND K.ADMPD_FEC_REG>V_FEC_ULT;
            --si el saldo de kx + el saldo de la ultima alineacion es igual al saldo que se encuentra en la tabla de Saldos
            --if (V_SLD_KX + V_SLD_ULT_ALIN_KX)=V_SLD_CC then
            if (V_SLD_KX)=V_SLD_CC then
      
        BEGIN
          
         ---1---admpt_tmp_alineacion_sldo_bono--------------------------------
        V_ERROR:='';
        V_SENTENCIA:='UPDATE';     
        V_ADMPV_COD_CLI:= lt_some_array(indx).V_CODCLI;
        V_TABLA:='admpt_tmp_alineacion_sldo_bono';                  
        --------------------------------------------------------
              --sólo se actualiza el campo procesado de la tabla temporal y se indica que el registro se encuentra alineado.
              update PCLUB.admpt_tmp_alineacion_sldo_bono set
                ADMPN_REGPROC = 1,
                ADMPV_PROCMSJ = V_CODCLI || ' Registro se encuentra alineado.'
              where admpv_cod_cli = V_CODCLI
              and admpn_grupo = V_GRUPO;

             EXCEPTION
             WHEN OTHERS THEN
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
              values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
                                 
             COMMIT;               
       END;
       
       BEGIN
         ---2---admpt_saldos_bono_cliente--------------------------------
        V_ERROR:='';
        V_SENTENCIA:='UPDATE';     
        V_ADMPV_COD_CLI:= lt_some_array(indx).V_CODCLI;
        V_TABLA:='admpt_saldos_bono_cliente';
        -----------------------------------------------------
              update PCLUB.admpt_saldos_bono_cliente s
              set
              s.admpn_alin_fecha_bono = sysdate
              where  s.admpv_cod_cli = V_CODCLI
              and s.admpn_grupo = V_GRUPO;

          EXCEPTION
             WHEN OTHERS THEN
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
                                 
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
              values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER); 
              
             COMMIT;
          END;

          ELSE --caso contrario
           
        BEGIN   
       ---3---admpt_saldos_bono_cliente------------------------------
        V_ERROR:='';
        V_SENTENCIA:='UPDATE'; 
        V_ADMPV_COD_CLI:= lt_some_array(indx).V_CODCLI;
        V_TABLA:='admpt_saldos_bono_cliente';
        ---------------------------------------------- 
              --se actualiza el campo ADMPN_SALDO_CC de la tabla Saldos con la suma de Saldo de kx + el Saldo de la ultima alineacion.
              update PCLUB.admpt_saldos_bono_cliente s
              set s.admpn_saldo = (V_SLD_KX),-- + V_SLD_ULT_ALIN_KX),
              s.admpn_alin_fecha_bono = sysdate,
              s.admpn_alin_saldo_bono = (V_SLD_KX),-- + V_SLD_ULT_ALIN_KX),
              s.admpn_saldo_bon_anterior = V_SLD_CC
              where  s.admpv_cod_cli = V_CODCLI
              and s.admpn_grupo = V_GRUPO;
              
           EXCEPTION
              WHEN OTHERS THEN
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
          
            INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
             values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER); 
             
            COMMIT;
          END;
          
        BEGIN
--------4------admpt_tmp_alineacion_sldo_bono-------------------------------------------------------------------     
        V_ERROR:='';
        V_SENTENCIA:='UPDATE'; 
        V_ADMPV_COD_CLI:= lt_some_array(indx).V_CODCLI;
        V_TABLA:='admpt_tmp_alineacion_sldo_bono';
 -----------------------------------------------------
              --Se actualiza el campo procesado de la tabla temporal y se indica que el registro no se encontraba alineado.
              update PCLUB.admpt_tmp_alineacion_sldo_bono set
                ADMPN_REGPROC = 1,
                ADMPV_PROCMSJ = V_CODCLI || ' No se encontraba alineado, se procedió a Alinear - Kx Desde la ultima Alineacion: '|| to_char(V_SLD_KX) ||' ; Sld de la ultima alineacion: '|| to_char(V_SLD_ULT_ALIN_KX) ||' ; Sld Claro Club Actual: '|| to_char(V_SLD_CC) ||'.'
              where admpv_cod_cli = V_CODCLI
              and admpn_grupo = V_GRUPO;

          EXCEPTION
               WHEN OTHERS THEN
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
           
             INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
              values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
                        
             COMMIT;
        END;
        
       BEGIN
----------5------ADMPT_IMP_ALIN_CLIE_BON-------------------------------------------------------------------
        V_ERROR:='';
        V_SENTENCIA:='INSERT'; 
        V_ADMPV_COD_CLI:= lt_some_array(indx).V_CODCLI;
        V_TABLA:='ADMPT_IMP_ALIN_CLIE_BON';
              --insertando en el historico de alineacion claroclub
              insert into PCLUB.ADMPT_IMP_ALIN_CLIE_BON(ADMPD_FEC_PROC_ALIN,ADMPV_COD_CLI,ADMPN_GRUPO,ADMPN_PTOS,ADMPN_PTOS_ALIN)
              values(V_CURRENT_DATE,V_CODCLI,V_GRUPO,V_SLD_CC,V_SLD_KX + V_SLD_ULT_ALIN_KX);

         EXCEPTION
               WHEN OTHERS THEN
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
                       
            INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
              values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER); 
                      
             COMMIT;    
        
            END;
            end if;
            
           
        ELSE
    
     BEGIN
        ---6-----admpt_tmp_alineacion_sldo_bono-------------------------------------------------------------------
        V_ERROR:='';
        V_SENTENCIA:='UPDATE'; 
        V_ADMPV_COD_CLI:= lt_some_array(indx).V_CODCLI;
        V_TABLA:='admpt_tmp_alineacion_sldo_bono';
        ----------------------------------------------------
          update PCLUB.admpt_tmp_alineacion_sldo_bono set
            ADMPN_REGPROC = 1,
            ADMPN_CODERROR = -1,
            ADMPV_ERRORMSJ = 'el codigo de cliente  '||V_CODCLI||'no existe en la tabla admpt_saldos_bono_cliente.'
            where admpv_cod_cli = V_CODCLI
            and admpn_grupo = V_GRUPO;

           EXCEPTION
               WHEN OTHERS THEN
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;

            INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
              values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);
             
             COMMIT;      
            
        END;     
    END IF;
          exception
            when others then
            rollback;
            update PCLUB.admpt_tmp_alineacion_sldo_bono set
            ADMPN_REGPROC = 1,
            ADMPN_CODERROR = -1,
            ADMPV_ERRORMSJ = 'Error en la ejecución, se realizó rollback al '||V_CODCLI
            where admpv_cod_cli = V_CODCLI
            and admpn_grupo = V_GRUPO;
            commit;
     -------------w----------------------------------------------------
             --Registro para auditoria Error-LOG-TEMPORAL
             V_CURRENT_DATE_FIN:=SYSDATE;  
             V_ERROR:='Sentencia: '|| V_SENTENCIA || ' ID_CLIENTE Tabla:' || V_TABLA || ' Registro que genera ERROR: ' || V_ADMPV_COD_CLI ||CHR(10)||CHR(13)||
            ' CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
            'DESCERROR' || SUBSTR(SQLERRM, 1, 250);      
            V_MSG_ERROR:='Ha ocurrido un ERROR en el LOTE: ' || contLote;
            
          
           
     
      INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
             values(SEQ_AUDITORIA_PCCLUB.nextval,VID_PROCESO,V_CURRENT_DATE1, VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT,V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN ,V_LOTE_DEBE_IR ,V_LOTE_EJECUTO ,'',V_ERROR ,V_MSG_ERROR ,V_USER);  
                       
             COMMIT;          
             --------------------------------------------------------------------
          end;
           conRegistros := conRegistros + 1;  ----CONTADOR
      END LOOP;
      commit; --confirmar el cambio.
      ----------------------------------------
       ------------Registro para auditoria----------------------------------------------------------- 
       V_ERROR:='';
       V_TABLA:='admpt_tmp_alineacion_sldo_bono';    
        V_CURRENT_DATE_FIN:=SYSDATE;
     --Registro para auditoria-LOG-TEMPORAL-----
       INSERT INTO PCLUB.AUDITORIA_PROC_CLAROCLUB 
             ( AUD_ID_SECUENCIA,
               AUD_ID_PROCESO,
               AUD_FECHA_REGISTRO,
               AUD_DESCRIPCION_PROCESO,
               AUD_ID_EJEC_PROCESO,
               AUD_EJECUCION_PROCESO,
               AUD_PARAMETROS,
               AUD_HORA_INICIO,
               AUD_HORA_FIN,
               AUD_LOTE_DEBE_IR,
               AUD_LOTE_EJECUTO,
               AUD_ESTADO_LOTE,
               AUD_REGISTRO_ERROR_LOTE,
               AUD_MENSAJE_ERROR,
               AUD_USUARIOREG)
       values(SEQ_AUDITORIA_PCCLUB.nextval, VID_PROCESO, V_CURRENT_DATE1,VDESC_PROCESO,V_ID_EJEC_PROCESO,V_EJECUCION_PROCESO,V_PARAM_ENT, V_CURRENT_DATE_INI,V_CURRENT_DATE_FIN, V_LOTE_DEBE_IR,V_LOTE_EJECUTO, 'Sentencia: ' || V_SENTENCIA || ' ' || V_TABLA ||  ' correcto, se realiza COMMIT', '', '', V_USER);
       COMMIT;
 ------------------------------------------------------
         
      EXIT WHEN
      lt_some_array.COUNT < N_LIMIT;
end loop;

RETURN 'OK';
END;

PROCEDURE ADMPSI_ALIN_SLD_PROCE_BON_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2)
IS
BEGIN
  K_CODERROR:='0';
  K_DESCERROR:='';
  SELECT COUNT(1) INTO K_COUNT FROM ADMPT_TMP_ALINEACION_SLDO_BONO T
  WHERE T.ADMPN_CATEGORIA = K_PROC
  AND T.ADMPN_REGPROC = 0;
  EXCEPTION
    WHEN OTHERS THEN
        K_CODERROR  := SQLCODE;
        K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ALIN_SLD_PROCE_BON_CONF;

PROCEDURE ADMPSI_ALIN_SLD_CARGA_IB(K_FECHA IN DATE,
                                K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_CARGA_IB
  -- Proposito           :  Proceso para cargar los clientes que hayan realizado movimiento desde la ultima alineacion de puntos
  --                        en la tabla temporal ADMPT_TMP_ALINEACION_SLDO
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
V_COUNT NUMBER:=0;
V_COUNTTMP NUMBER:=0;
V_COUNTTMPPROC NUMBER:=0;
BEGIN

SELECT COUNT(1) INTO V_COUNTTMP FROM ADMPT_TMP_ALINEACION_SLDO_IB;
--V_COUNTTMP:=0;
IF V_COUNTTMP=0 THEN
--------------------------------------
    insert into ADMPT_TMP_ALINEACION_SLDO_IB(ADMPV_COD_CLI_IB,ADMPD_ULT_ACTU,ADMPD_FECHA)
    select k.admpn_cod_cli_ib,s.admpn_alin_fecha_ib,K_FECHA
    from admpt_clienteib c,
         admpt_saldos_cliente s,
         admpt_kardex k
    where
        c.admpn_cod_cli_ib = s.admpn_cod_cli_ib and
        s.admpn_cod_cli_ib = k.admpn_cod_cli_ib and
        --------------------------------------
        c.admpc_estado='A'
        AND k.admpc_tpo_punto='I'
        AND k.admpc_tpo_oper='E'
        AND s.admpn_alin_fecha_ib<k.admpd_fec_reg
        AND k.admpc_estado='A'
     group by k.admpn_cod_cli_ib,s.admpn_alin_fecha_ib;

   commit;
    K_CODERROR:=0;
    K_DESCERROR:=' ';

    select count(1) into V_COUNT from ADMPT_TMP_ALINEACION_SLDO_IB;
    if V_COUNT=0 then
      K_CODERROR:=1;
      K_DESCERROR:='No se encontraron registros para alinear.';
    end if;
--------------------------------------
ELSE
    SELECT COUNT(1) INTO V_COUNTTMPPROC FROM ADMPT_TMP_ALINEACION_SLDO_IB WHERE ADMPN_REGPROC = 1;
    IF V_COUNTTMP = V_COUNTTMPPROC THEN
       K_CODERROR:=1;
       K_DESCERROR:='Existen registros de la anterior alineacion en la tabla ADMPT_TMP_ALINEACION_SLDO_IB procesados. Debe de limpiar la tabla.';
    ELSE
       K_CODERROR:=1;
       K_DESCERROR:='Existen registros de la anterior alineacion en la tabla ADMPT_TMP_ALINEACION_SLDO_IB sin procesar.';
    END IF;

END IF;



EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ADMPSI_ALIN_SLD_CARGA_IB;

PROCEDURE ADMPSI_ALIN_SLD_CATEG_IB(K_HILOS        IN NUMBER,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_CATEG
  -- Proposito           :  Categoriza todos los registros de la tabla temporal ADMPT_TMP_ALINEACION_SLDO.
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************
  V_CONTADOR NUMBER;
  V_CAT_MAX NUMBER;
  V_NUM_REG NUMBER;


  BEGIN
    K_CODERROR:=0;
    K_DESCERROR:=0;
    V_CONTADOR:=0;
    V_CAT_MAX:=K_HILOS;

    SELECT COUNT(1)
    INTO V_NUM_REG
    FROM ADMPT_TMP_ALINEACION_SLDO_IB C
    WHERE ADMPD_FECHA = K_FECHA;

    IF V_NUM_REG > 0 THEN

    FOR REGISTR IN (  SELECT C.ADMPV_COD_CLI_IB
                      FROM ADMPT_TMP_ALINEACION_SLDO_IB C)
    LOOP
      V_CONTADOR:=V_CONTADOR+1;
      UPDATE ADMPT_TMP_ALINEACION_SLDO_IB
         SET ADMPN_CATEGORIA=V_CONTADOR
      WHERE ADMPV_COD_CLI_IB=REGISTR.ADMPV_COD_CLI_IB;

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

END ADMPSI_ALIN_SLD_CATEG_IB;

PROCEDURE ADMPSI_ALIN_SLD_PROCE_IB(K_FECHA        IN DATE,
                                K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_PROCE_IB
  -- Proposito           :  Proceso que se encargará de realizar la alineacion de puntos.
  --
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Fredy Fernandez Espinoza
  -- Fec Creacion        :  23/06/2015
  -- Fec Actualizacion   :
  --****************************************************************

c_cursor SYS_REFCURSOR;
V_CODCLI NUMBER;
V_SLD_KX NUMBER;
V_SLD_ULT_ALIN_KX NUMBER;
V_SLD_CC NUMBER;
V_FEC_ULT DATE;
BEGIN
--
open c_cursor for
select t1.admpv_cod_cli_ib,t1.admpd_ult_actu
from admpt_tmp_alineacion_sldo_ib t1
where t1.admpn_categoria=K_PROC
--and t1.admpd_fecha = K_FECHA
and t1.admpn_regproc = 0;

/*select t.admpv_cod_cli_ib,t.admpn_sld_pto_kx, s.admpn_alin_saldo_ib,s.admpn_saldo_ib
from admpt_saldos_cliente s
inner join (select * from admpt_tmp_alineacion_sldo_ib t1
           where t1.admpn_categoria=K_PROC
           and t1.admpd_fecha=K_FECHA) t
on s.admpn_cod_cli_ib = t.admpv_cod_cli_ib;*/

loop
fetch c_cursor into V_CODCLI,V_FEC_ULT;
    exit when c_cursor%notfound;
    begin
      --V_SLD_KX,V_SLD_ULT_ALIN_KX,V_SLD_CC
      begin
        select nvl(s.admpn_saldo_ib,0), nvl(s.admpn_alin_saldo_ib,0)
        into  V_SLD_CC, V_SLD_ULT_ALIN_KX
        from admpt_saldos_cliente s
        where s.admpn_cod_cli_ib = V_CODCLI;
      exception
        when no_data_found then
          V_SLD_CC:=null;
      end;

      if (V_SLD_CC is not null) then
          SELECT NVL(SUM(K.ADMPN_SLD_PUNTO),0) INTO V_SLD_KX
          FROM ADMPT_KARDEX K
          WHERE
          K.ADMPN_COD_CLI_IB=V_CODCLI
          AND K.ADMPC_TPO_PUNTO='I'
          AND K.ADMPN_SLD_PUNTO>0
          AND K.ADMPC_TPO_OPER='E'
          AND K.ADMPC_ESTADO='A';
          --AND K.ADMPD_FEC_REG>V_FEC_ULT;

          --si el saldo de kx + el saldo de la ultima alineacion es igual al saldo que se encuentra en la tabla de Saldos
          if (V_SLD_KX )=V_SLD_CC then
            --sólo se actualiza el campo procesado de la tabla temporal y se indica que el registro se encuentra alineado.
            update admpt_tmp_alineacion_sldo_ib set
              ADMPN_REGPROC = 1,
              ADMPV_PROCMSJ = TO_CHAR(V_CODCLI) || ' Registro se encuentra alineado.'
            where admpv_cod_cli_ib = V_CODCLI;

            update admpt_saldos_cliente s
            set
            s.admpn_alin_fecha_ib = sysdate
            where  s.admpn_cod_cli_ib = V_CODCLI;

          else --caso contrario
            --se actualiza el campo ADMPN_SALDO_CC de la tabla Saldos con la suma de Saldo de kx + el Saldo de la ultima alineacion.
            update admpt_saldos_cliente s
            set s.admpn_saldo_ib = (V_SLD_KX),
            s.admpn_alin_fecha_ib = sysdate,
            s.admpn_alin_saldo_ib = (V_SLD_KX),
            s.admpn_saldo_ib_anterior = V_SLD_CC
            where  s.admpn_cod_cli_ib = V_CODCLI;
            --Se actualiza el campo procesado de la tabla temporal y se indica que el registro no se encontraba alineado.
            update admpt_tmp_alineacion_sldo_ib set
              ADMPN_REGPROC = 1,
              ADMPV_PROCMSJ = TO_CHAR(V_CODCLI) || ' No se encontraba alineado, se procedió a Alinear - Kx Desde la ultima Alineacion: '|| to_char(V_SLD_KX) ||' ; Sld de la ultima alineacion: '|| to_char(V_SLD_ULT_ALIN_KX) ||' ; Sld IB Actual: '|| to_char(V_SLD_CC) ||'.'
            where admpv_cod_cli_ib = V_CODCLI;

            --insertando en el historico de alineacion claroclub
            insert into ADMPT_IMP_ALIN_CLIE_IB(ADMPD_FEC_PROC_ALIN,ADMPN_COD_CLI_IB,ADMPN_PTOS,ADMPN_PTOS_ALIN)
            values(K_FECHA,V_CODCLI,V_SLD_CC,V_SLD_KX + V_SLD_ULT_ALIN_KX);

          end if;
      else

        update admpt_tmp_alineacion_sldo_ib set
          ADMPN_REGPROC = 1,
          ADMPN_CODERROR = -1,
          ADMPV_ERRORMSJ = 'El codigo de cliente Ib '|| to_char(V_CODCLI) || ' no existe en la tabla admpt_saldos_cliente.'
        where admpv_cod_cli_ib = V_CODCLI;

      end if;

      commit; --confirmar el cambio.
      exception
        when others then
          rollback;
          update admpt_tmp_alineacion_sldo_ib set
            ADMPN_REGPROC = 1,
            ADMPN_CODERROR = -1,
            ADMPV_ERRORMSJ = 'Error en la ejecución, se realizó rollback al '|| to_char(V_CODCLI)
            where admpv_cod_cli_ib = V_CODCLI;
          commit;
    end;
end loop;

close c_cursor;
K_CODERROR  := 0;
K_DESCERROR := ' ';

EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := 2;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ALIN_SLD_PROCE_IB;


PROCEDURE ADMPSI_ALIN_SLD_PROCE_IB_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2)
IS
BEGIN
  K_CODERROR:='0';
K_DESCERROR:='';
SELECT COUNT(1) INTO K_COUNT FROM ADMPT_TMP_ALINEACION_SLDO_IB T
WHERE T.ADMPN_CATEGORIA = K_PROC
AND T.ADMPN_REGPROC = 0;
EXCEPTION
  WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ALIN_SLD_PROCE_IB_CONF;


PROCEDURE ADMPSI_LIMP_TEMP_ALIN_INI
(
    K_RESULTADO OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
 --****************************************************************
  -- Nombre SP           :  ADMPSI_LIMP_TEMP_ALIN_INI
  -- Proposito           :
  -- Input               :  K_USUARIO
  -- Output              :  K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Fredy Fernandez
  -- Fec Creacion        :  01/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_RESULTADO := 1;

  INSERT INTO PCLUB.ADMPT_IMP_CLIENTE_PRE
    ( ADMPN_ID_FILA,
      ADMPV_COD_CLI,
      ADMPD_FECHA,
      ADMPN_CATEGORIA,
      ADMPN_REGPROC,
      ADMPN_CODERROR,
      ADMPV_ERRORMSJ)
    SELECT
         ADMPT_IMP_CLIENTE_PRE_SQ.NEXTVAL,
          T.ADMPV_COD_CLI,
          T.ADMPD_FECHA,
          T.ADMPN_CATEGORIA,
          T.ADMPN_REGPROC,
          T.ADMPN_CODERROR,
          T.ADMPV_ERRORMSJ
    FROM PCLUB.ADMPT_TMP_CLIENTE_PRE T
    WHERE T.ADMPN_CODERROR<0;
    COMMIT;


  SELECT COUNT(1) INTO V_CANTREG FROM PCLUB.ADMPT_TMP_CLIENTE_PRE R;
  SELECT COUNT(1) INTO V_CANTPRO FROM PCLUB.ADMPT_TMP_CLIENTE_PRE R WHERE R.ADMPN_REGPROC = 1;

  IF V_CANTREG = V_CANTPRO THEN
    IF V_CANTREG>0 THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ADMPT_TMP_CLIENTE_PRE';
          EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_CLI_NOEXISTE_SALDO';
          EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_CLI_ALL';
          K_RESULTADO := 0;
    ELSE
          K_RESULTADO := 2;
    END IF;

  ELSE
    K_CODERROR  := '-1';
    K_DESCERROR := 'No se procesaron todos los registros, revisar la tabla ADMPT_TMP_CLIENTE_PRE';
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_LIMP_TEMP_ALIN_INI;



PROCEDURE ADMPSI_LIMP_TMP_ALIN_INI_BONO
(
    K_RESULTADO OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_LIMP_TMP_ALIN_INI_BONO
  -- Proposito           :
  -- Input               :  K_USUARIO
  -- Output              :  K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Fredy Fernandez
  -- Fec Creacion        :  01/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_RESULTADO := 1;

  INSERT INTO ADMPT_IMP_CLIENTE_PRE_BONO
    ( ADMPN_ID_FILA,
      ADMPV_COD_CLI,
      ADMPD_FECHA,
      ADMPN_CATEGORIA,
      ADMPN_REGPROC,
      ADMPN_CODERROR,
      ADMPV_ERRORMSJ,
      ADMPN_GRUPO)
    SELECT
         ADMPT_IMP_CLIENTE_PRE_BONO_SQ.NEXTVAL,
          T.ADMPV_COD_CLI,
          T.ADMPD_FECHA,
          T.ADMPN_CATEGORIA,
          T.ADMPN_REGPROC,
          T.ADMPN_CODERROR,
          T.ADMPV_ERRORMSJ,
          T.ADMPN_GRUPO
    FROM ADMPT_TMP_CLIENTE_PRE_BONO T
    WHERE T.ADMPN_CODERROR<0;
    COMMIT;


  SELECT COUNT(1) INTO V_CANTREG FROM ADMPT_TMP_CLIENTE_PRE_BONO R;-- WHERE R.ADMPN_CODERROR IS NULL;
  SELECT COUNT(1) INTO V_CANTPRO FROM ADMPT_TMP_CLIENTE_PRE_BONO R WHERE R.ADMPN_REGPROC = 1;

  IF V_CANTREG = V_CANTPRO THEN
    IF V_CANTREG>0 THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ADMPT_TMP_CLIENTE_PRE_BONO';
          K_RESULTADO := 0;
    ELSE
          K_RESULTADO := 2;
    END IF;

  ELSE
    K_CODERROR  := '-1';
    K_DESCERROR := 'No se procesaron todos los registros, revisar la tabla ADMPT_TMP_CLIENTE_PRE_BONO';
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_LIMP_TMP_ALIN_INI_BONO;


PROCEDURE ADMPSI_LIMP_TMP_ALIN_INI_IB
(
    K_RESULTADO OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_LIMP_TMP_ALIN_INI_IB
  -- Proposito           :
  -- Input               :  K_USUARIO
  -- Output              :  K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Fredy Fernandez
  -- Fec Creacion        :  01/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_RESULTADO := 1;

  INSERT INTO ADMPT_IMP_CLIENTE_PRE_IB
    ( ADMPN_ID_FILA,
      ADMPV_COD_CLI_IB,
      ADMPD_FECHA,
      ADMPN_CATEGORIA,
      ADMPN_REGPROC,
      ADMPN_CODERROR,
      ADMPV_ERRORMSJ)
    SELECT
         ADMPT_IMP_CLIENTE_PRE_IB_SQ.NEXTVAL,
          T.ADMPV_COD_CLI_IB,
          T.ADMPD_FECHA,
          T.ADMPN_CATEGORIA,
          T.ADMPN_REGPROC,
          T.ADMPN_CODERROR,
          T.ADMPV_ERRORMSJ
    FROM ADMPT_TMP_CLIENTE_PRE_IB T
    WHERE T.ADMPN_CODERROR<0;
    COMMIT;


  SELECT COUNT(1) INTO V_CANTREG FROM ADMPT_TMP_CLIENTE_PRE_IB R;-- WHERE R.ADMPN_CODERROR IS NULL;
  SELECT COUNT(1) INTO V_CANTPRO FROM ADMPT_TMP_CLIENTE_PRE_IB R WHERE R.ADMPN_REGPROC = 1;

  IF V_CANTREG = V_CANTPRO THEN
    IF V_CANTREG>0 THEN
          EXECUTE IMMEDIATE 'TRUNCATE TABLE ADMPT_TMP_CLIENTE_PRE_IB';
          K_RESULTADO := 0;
    ELSE
          K_RESULTADO := 2;
    END IF;

  ELSE
    K_CODERROR  := '-1';
    K_DESCERROR := 'No se procesaron todos los registros, revisar la tabla ADMPT_TMP_CLIENTE_PRE_IB';
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_LIMP_TMP_ALIN_INI_IB;

PROCEDURE ADMPSI_ALIN_SLD_LIMP
(
    K_RESULTADO OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_LIMP_TEMP_ALIN_INI
  -- Proposito           :
  -- Input               :  K_USUARIO
  -- Output              :  K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Fredy Fernandez
  -- Fec Creacion        :  01/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_RESULTADO := 1;

  INSERT INTO PCLUB.ADMPT_IMP_ALINEACION_SLDO
    ( ADMPN_ID_FILA,
      ADMPV_COD_CLI,
      ADMPN_SLD_PTO_KX,
      ADMPD_FECHA,
      ADMPN_CATEGORIA,
      ADMPN_REGPROC,
      ADMPN_CODERROR,
      ADMPV_ERRORMSJ,
      ADMPV_PROCMSJ)
    SELECT
          ADMPT_IMP_ALINEACION_SLDO_SQ.NEXTVAL,
          ADMPV_COD_CLI,
          ADMPN_SLD_PTO_KX,
          ADMPD_FECHA,
          ADMPN_CATEGORIA,
          ADMPN_REGPROC,
          ADMPN_CODERROR,
          ADMPV_ERRORMSJ,
          ADMPV_PROCMSJ
    FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO T
    WHERE T.ADMPN_CODERROR<0;
    COMMIT;


  SELECT COUNT(1) INTO V_CANTREG FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO R;
  SELECT COUNT(1) INTO V_CANTPRO FROM PCLUB.ADMPT_TMP_ALINEACION_SLDO R WHERE R.ADMPN_REGPROC = 1;

  IF V_CANTREG = V_CANTPRO THEN
    IF V_CANTREG>0 THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ADMPT_TMP_ALINEACION_SLDO';
      K_RESULTADO := 0;
    ELSE
      K_RESULTADO := 2;
    END IF;
  ELSE
    K_CODERROR  := '-1';
    K_DESCERROR := 'No se procesaron todos los registros, revisar la tabla ADMPT_TMP_ALINEACION_SLDO';
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALIN_SLD_LIMP;

PROCEDURE ADMPSI_ALIN_SLD_LIMP_BONO
(
    K_RESULTADO OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_LIMP_BONO
  -- Proposito           :
  -- Input               :  K_USUARIO
  -- Output              :  K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Fredy Fernandez
  -- Fec Creacion        :  01/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_RESULTADO := 1;

  INSERT INTO ADMPT_IMP_ALINEACION_SLDO_BONO
    ( ADMPN_ID_FILA,
      ADMPV_COD_CLI,
      ADMPN_GRUPO,
      ADMPN_SLD_PTO_KX,
      ADMPD_FECHA,
      ADMPN_CATEGORIA,
      ADMPN_REGPROC,
      ADMPV_ERRORMSJ,
      ADMPV_PROCMSJ,
      ADMPN_CODERROR)
    SELECT
          ADMPT_IMP_ALIN_SLDO_BONO_SQ.NEXTVAL,
          ADMPV_COD_CLI,
          ADMPN_GRUPO,
          ADMPN_SLD_PTO_KX,
          ADMPD_FECHA,
          ADMPN_CATEGORIA,
          ADMPN_REGPROC,
          ADMPV_ERRORMSJ,
          ADMPV_PROCMSJ,
          ADMPN_CODERROR
    FROM ADMPT_TMP_ALINEACION_SLDO_BONO T
    WHERE T.ADMPN_CODERROR<0;
    COMMIT;


  SELECT COUNT(1) INTO V_CANTREG FROM ADMPT_TMP_ALINEACION_SLDO_BONO R;-- WHERE R.ADMPN_CODERROR IS NULL;
  SELECT COUNT(1) INTO V_CANTPRO FROM ADMPT_TMP_ALINEACION_SLDO_BONO R WHERE R.ADMPN_REGPROC = 1;

  IF V_CANTREG = V_CANTPRO THEN
    IF V_CANTREG>0 THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ADMPT_TMP_ALINEACION_SLDO_BONO';
      K_RESULTADO := 0;
    ELSE
      K_RESULTADO := 2;
      --K_CODERROR  := '-1';
      --K_DESCERROR := 'La tabla ADMPT_TMP_ALINEACION_SLDO, se encuentra sin registros.';
    END IF;
  ELSE
    K_CODERROR  := '-1';
    K_DESCERROR := 'No se procesaron todos los registros, revisar la tabla ADMPT_TMP_ALINEACION_SLDO_BONO';
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALIN_SLD_LIMP_BONO;

PROCEDURE ADMPSI_ALIN_SLD_LIMP_IB
(
    K_RESULTADO OUT NUMBER,
    K_CODERROR OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALIN_SLD_LIMP_IB
  -- Proposito           :
  -- Input               :  K_USUARIO
  -- Output              :  K_CODERROR
  --                        K_DESCERROR

  -- Creado por          :  Fredy Fernandez
  -- Fec Creacion        :  01/06/2015
  -- Modificado por      :
  -- Fec Actualizacion   :
  --****************************************************************

  NO_CONCEPTO EXCEPTION;
  V_CANTREG NUMBER;
  V_CANTPRO NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_RESULTADO := 1;

  INSERT INTO ADMPT_IMP_ALINEACION_SLDO_IB
    ( ADMPN_ID_FILA,
      ADMPV_COD_CLI_IB,
      ADMPN_SLD_PTO_KX,
      ADMPD_FECHA,
      ADMPN_CATEGORIA,
      ADMPN_REGPROC,
      ADMPN_CODERROR,
      ADMPV_ERRORMSJ,
      ADMPV_PROCMSJ)
    SELECT
          ADMPT_IMP_ALIN_SLDO_IB_SQ.NEXTVAL,
          ADMPV_COD_CLI_IB,
          ADMPN_SLD_PTO_KX,
          ADMPD_FECHA,
          ADMPN_CATEGORIA,
          ADMPN_REGPROC,
          ADMPN_CODERROR,
          ADMPV_ERRORMSJ,
          ADMPV_PROCMSJ
    FROM ADMPT_TMP_ALINEACION_SLDO_IB T
    WHERE T.ADMPN_CODERROR<0;
    COMMIT;


  SELECT COUNT(1) INTO V_CANTREG FROM ADMPT_TMP_ALINEACION_SLDO_IB R;-- WHERE R.ADMPN_CODERROR IS NULL;
  SELECT COUNT(1) INTO V_CANTPRO FROM ADMPT_TMP_ALINEACION_SLDO_IB R WHERE R.ADMPN_REGPROC = 1;

  IF V_CANTREG = V_CANTPRO THEN
    IF V_CANTREG>0 THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ADMPT_TMP_ALINEACION_SLDO_IB';
      K_RESULTADO := 0;
    ELSE
      K_RESULTADO := 2;
      --K_CODERROR  := '-1';
      --K_DESCERROR := 'La tabla ADMPT_TMP_ALINEACION_SLDO, se encuentra sin registros.';
    END IF;
  ELSE
    K_CODERROR  := '-1';
    K_DESCERROR := 'No se procesaron todos los registros, revisar la tabla ADMPT_TMP_ALINEACION_SLDO_IB';
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALIN_SLD_LIMP_IB;


end PKG_CC_ALINEACION_PTO;
/