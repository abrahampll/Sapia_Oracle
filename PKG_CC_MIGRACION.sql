CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_MIGRACION IS

PROCEDURE ADMPSS_OBTPREAPOS(K_FECHA IN DATE, K_NUMREGTOT OUT NUMBER, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, CURSOROBTPREAPOS out SYS_REFCURSOR)
IS
--****************************************************************
-- Nombre SP           :  ADMPSS_OBTPREAPOS
-- Propósito           :  Obtiene los números de teléfonos que fueron migrados de Prepago a Postpago.
-- Input               :  K_FECHA
-- Output              :  K_NUMREGTOT
--                        K_CODERROR
--                        K_DESCERROR
--                        CURSOROBTPREAPOS
-- Creado por          :  Deysi Galvez 
-- Fec Creación        :  31/11/2010
-- Fec Actualización   :  13/01/2012
--****************************************************************


V_COUNT NUMBER;
BEGIN

SELECT COUNT(*) INTO V_COUNT FROM
(
  SELECT A.msisdn,A.fch_migracion
  FROM DM.ods_migracion_positiva@dbl_reptdm_d A
  WHERE A.IDSEGMENTOORIGEN in (1)
  AND A.IDSEGMENTO = 3
  AND A.fch_migracion >= TRUNC(K_FECHA - 2)
  AND A.fch_migracion < TRUNC(K_FECHA - 1)
);

OPEN CURSOROBTPREAPOS FOR
  SELECT A.msisdn,A.fch_migracion
    FROM DM.ods_migracion_positiva@dbl_reptdm_d A
    WHERE A.IDSEGMENTOORIGEN in (1)
    AND A.IDSEGMENTO = 3
    AND A.fch_migracion >= TRUNC(K_FECHA - 2)
    AND A.fch_migracion < TRUNC(K_FECHA - 1)
    order BY A.MSISDN; 


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

procedure ADMPSS_OBTPOSAPRE(K_FECHA IN DATE, K_NUMREGTOT OUT NUMBER, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, CURSOROBTPOSAPRE out SYS_REFCURSOR)
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
-- Creado por          :  Deysi Galvez
-- Fec Creación        :  11/01/2012
--****************************************************************

V_COUNT NUMBER;
BEGIN

SELECT COUNT(*) INTO V_COUNT FROM
(
    SELECT A.custcode,A.msisdn,A.fch_migracion
    FROM DM.ods_migracion_positiva@dbl_reptdm_d A
    WHERE A.IDSEGMENTOORIGEN in (2, 3)
    AND A.IDSEGMENTO = 1
    AND A.fch_migracion >= TRUNC(K_FECHA - 2)
    AND A.fch_migracion < TRUNC(K_FECHA - 1) 
 );

BEGIN
OPEN CURSOROBTPOSAPRE FOR
    SELECT A.custcode,A.msisdn,A.fch_migracion
    FROM DM.ods_migracion_positiva@dbl_reptdm_d A
    WHERE A.IDSEGMENTOORIGEN in (2, 3)
    AND A.IDSEGMENTO = 1
    AND A.fch_migracion >= TRUNC(K_FECHA - 2)
    AND A.fch_migracion < TRUNC(K_FECHA - 1) 
    ORDER BY A.custcode;
  
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

PROCEDURE ADMPSS_OBTLINEAXCTA(K_TELEFONO IN VARCHAR,K_CUENTA IN VARCHAR2,K_NUMREGTOT OUT NUMBER, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, CUR_LINXCTA out SYS_REFCURSOR)
IS
--****************************************************************
-- Nombre SP           :  ADMPSS_OBTCTA
-- Propósito           :  Obtiene lineas por cliente
-- Input               :  K_TIPO_DOC
--                        K_NUM_DOC               
-- Output              :  K_NUMREGTOT
--                        K_CODERROR
--                        K_DESCERROR
--                        CUR_OBTCTA
-- Creado por          :  Deysi Galvez
-- Fec Creación        :  11/01/2012
--****************************************************************
V_COUNT NUMBER; 

BEGIN

SELECT COUNT(*) INTO V_COUNT FROM
(
    select a.msisdn
  from DM.ods_postpago_contratos@dbl_reptdm_d a
 where a.idestadoultmod in (1,3)      
   and a.custcode = K_CUENTA
   and a.msisdn <> '51'||K_TELEFONO
);

OPEN CUR_LINXCTA FOR
    select a.msisdn
  from DM.ods_postpago_contratos@dbl_reptdm_d a
 where a.idestadoultmod in (1,3)      
   and a.custcode = K_CUENTA
   and a.msisdn <> '51'||K_TELEFONO;

K_NUMREGTOT:=V_COUNT;         
K_CODERROR:='0';
K_DESCERROR:=' ';

COMMIT;

EXCEPTION

WHEN OTHERS THEN
  K_CODERROR  := SQLCODE;
  K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  ROLLBACK;

END ADMPSS_OBTLINEAXCTA;

PROCEDURE ADMPSS_OBTCTA(K_CUENTA IN VARCHAR2,K_TIPO_DOC IN VARCHAR2,K_NUM_DOC IN VARCHAR2,K_NUMREGTOT OUT NUMBER, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, CUR_OBTCTA out SYS_REFCURSOR)
IS
--****************************************************************
-- Nombre SP           :  ADMPSS_OBTCTA
-- Propósito           :  Obtiene lineas por cliente
-- Input               :  K_TIPO_DOC
--                        K_NUM_DOC               
-- Output              :  K_NUMREGTOT
--                        K_CODERROR
--                        K_DESCERROR
--                        CUR_OBTCTA
-- Creado por          :  Deysi Galvez
-- Fec Creación        :  11/01/2012
--****************************************************************
V_COUNT NUMBER; 

BEGIN

SELECT COUNT(*) INTO V_COUNT FROM
(
    SELECT A.ADMPV_COD_CLI
    FROM ADMPT_CLIENTE A 
    WHERE A.ADMPV_COD_TPOCL IN ('1','2')
    AND A.ADMPC_ESTADO = 'A'
    AND A.ADMPV_COD_CLI <> K_CUENTA
    AND A.ADMPV_TIPO_DOC = K_TIPO_DOC
    AND A.ADMPV_NUM_DOC = K_NUM_DOC
);

OPEN CUR_OBTCTA FOR
    SELECT A.ADMPV_COD_CLI
    FROM ADMPT_CLIENTE A 
    WHERE A.ADMPV_COD_TPOCL IN ('1','2')
    AND A.ADMPC_ESTADO = 'A'
    AND A.ADMPV_COD_CLI <> K_CUENTA
    AND A.ADMPV_TIPO_DOC = K_TIPO_DOC
    AND A.ADMPV_NUM_DOC = K_NUM_DOC
    AND ROWNUM = 1
    ORDER BY A.ADMPD_FEC_REG;

K_NUMREGTOT:=V_COUNT;         
K_CODERROR:='0';
K_DESCERROR:=' ';

COMMIT;

EXCEPTION

WHEN OTHERS THEN
  K_CODERROR  := SQLCODE;
  K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  ROLLBACK;

END ADMPSS_OBTCTA;

PROCEDURE ADMPSI_PREMIGPOS(K_FECHA IN DATE,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
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
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  11/11/2010
  -- Fec Actualización   :  
  --****************************************************************
  
  NO_CONCEPTO EXCEPTION;
  NO_PARAMETRO EXCEPTION;

  V_NUMREGTOT NUMBER;
  V_EST_ERR VARCHAR2(10);
  V_CODERROR VARCHAR2(10);
  V_DESCERROR VARCHAR2(400);
  TYPE TY_CURSOR IS REF CURSOR;
  CUR_OBTPOSAPRE  TY_CURSOR;
  CUR_OBTLINCLI   TY_CURSOR;
  CUR_OBTCTA	TY_CURSOR;

  C_NUMTELEF  VARCHAR2(20);
  C_FECHAMIGR DATE;

  C_CUENTA VARCHAR2(100);  
  
  V_COUNT NUMBER;
  V_TELEFONO VARCHAR2(20);
  V_CUENTA	VARCHAR2(100);
  
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
  V_SALDO NUMBER;
  V_SALDO_IB NUMBER;
  V_FECHAMIGR DATE;
  
  V_COD_CPTO_CC VARCHAR2(20);
  V_COD_CPTO_IB VARCHAR2(20);
  V_VALOR VARCHAR2(100);
  
  V_CUENTA_1 VARCHAR(100);
  C_CUENTA_1 VARCHAR(100);
  
  V_PENALIDAD NUMBER; 
  V_KARDEX_ID VARCHAR(100);
  V_COD_CLI_IB VARCHAR(100);
  V_CODCPTO_BONO VARCHAR(2);
  V_ESTADO VARCHAR(2);
  K_TIP_CLI VARCHAR2(2);
  
  K_ID_CANJE NUMBER;
  K_SEC NUMBER;
  K_PUNTOS NUMBER;
  V_PUNTOS_REQUERIDOS NUMBER:=0;
  
  LK_TPO_PUNTO VARCHAR2(2);
  LK_ID_KARDEX  NUMBER;
  LK_SLD_PUNTOS NUMBER;
  LK_COD_CLI VARCHAR2(40);
  LK_COD_CLIIB NUMBER;
  
  cursor LISTA_KARDEX_1 is
  select ka.admpc_tpo_punto, ka.admpn_id_kardex, ka.admpn_sld_punto, ka.admpv_cod_cli, admpn_cod_cli_ib
  from admpt_kardex ka
  where ka.admpc_estado='A'
  and ka.admpc_tpo_oper='E'
  and ka.admpn_sld_punto>0
  and ka.admpc_tpo_punto<>'I'
  and ka.admpd_fec_trans<=TO_DATE(TO_CHAR(SYSDATE + 1,'DD/MM/YYYY'),'DD/MM/YYYY') --'17/09/2010'
  and ka.admpv_cod_cli = V_TELEFONO
  order by decode(admpc_tpo_punto, 'I', 1 ,'L', 2 ,'C', 3), admpn_id_kardex asc;
  
BEGIN

	BEGIN
		SELECT ADMPV_COD_CPTO
		INTO V_COD_CPTO_CC
		FROM ADMPT_CONCEPTO
		WHERE ADMPV_DESC LIKE '%MIGRACIONES POSTPAGO A PREPAGO CC%';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN V_COD_CPTO_CC:=NULL;
	END;

	BEGIN
		SELECT ADMPV_COD_CPTO
		INTO V_COD_CPTO_IB
		FROM ADMPT_CONCEPTO
		WHERE ADMPV_DESC LIKE '%MIGRACIONES POSTPAGO A PREPAGO IB%';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN V_COD_CPTO_IB:=NULL;
	END;
	
	BEGIN
		SELECT ADMPV_VALOR
		INTO V_VALOR
		FROM ADMPT_PARAMSIST
		WHERE ADMPV_DESC LIKE '%PUNTOS_MIGRACION_POSTPAGO_PREPAGO%';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN V_VALOR:=NULL;
	END;

	BEGIN
		SELECT ADMPV_COD_CPTO
		INTO V_CODCPTO_BONO
		FROM ADMPT_CONCEPTO
		WHERE ADMPV_DESC LIKE '%PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO%';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN V_CODCPTO_BONO:=NULL;
	END;

	--VERIFICANDO LA EXISTENCIA DE LOS CONCEPTOS A UTILIZAR
	IF ((V_COD_CPTO_CC IS NULL) OR ((V_COD_CPTO_IB IS NULL)) OR (V_CODCPTO_BONO IS NULL)) THEN
	RAISE NO_CONCEPTO;
	END IF;

	--VERIFICANDO LA EXISTENCIA DEL PARAMETRO A UTILIZAR
	IF V_VALOR IS NULL THEN
	RAISE NO_PARAMETRO;
	END IF;

--1. Obtener Migraciones a Prepago

	PKG_CC_MIGRACION.ADMPSS_OBTPOSAPRE(K_FECHA,V_NUMREGTOT,V_CODERROR,V_DESCERROR,CUR_OBTPOSAPRE);

  IF V_NUMREGTOT > 0 THEN 
		LOOP
		  FETCH CUR_OBTPOSAPRE
		  INTO  C_CUENTA,C_NUMTELEF,C_FECHAMIGR; 
		  EXIT WHEN CUR_OBTPOSAPRE%NOTFOUND;
		  V_EST_ERR:= 0;
		  
      V_CUENTA := C_CUENTA;
		  V_TELEFONO := SUBSTR(C_NUMTELEF,3);
		  V_FECHAMIGR := C_FECHAMIGR;
      
      
      IF 	TRIM(V_TELEFONO) IS NULL AND TRIM(V_CUENTA) IS NULL THEN 
          V_DESCERROR   := 'La cuenta y la línea no pueden ser vacias, son datos obligatorios';
          V_EST_ERR := 1;

          INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
          ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
          VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,sysdate,V_DESCERROR);
      ELSE          
              
        SELECT COUNT(*) INTO V_COUNT 
        FROM ADMPT_AUX_PREPOSPRE      
        WHERE ADMPV_COD_CLI = V_CUENTA
        AND ADMPV_TELEFONO = V_TELEFONO
        AND ADMPD_FEC_OPER >= TRUNC(SYSDATE);
        
        IF V_COUNT = 0 THEN
          --2.	La cuenta de la línea migrada tiene más línea.
  		  		  
        SELECT COUNT(*) INTO V_COUNT
        FROM ADMPT_CLIENTE
        WHERE ADMPV_COD_CLI = V_CUENTA
        AND ADMPV_COD_TPOCL IN ('1','2');

        IF V_COUNT = 0 THEN
        --SE LE ASIGNA EL ERROR SI EL CLIENTE NO EXISTE
        V_DESCERROR:='Cliente Postpago '||V_CUENTA||' no es cliente Claro Club';
        V_EST_ERR:= 1;

        INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
        ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
        VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,sysdate,V_DESCERROR);

        GOTO VERIFICAERROR;
        END IF;
  		  
        SELECT ADMPC_ESTADO INTO V_ESTADO
        FROM ADMPT_CLIENTE
        WHERE ADMPV_COD_CLI = V_CUENTA
        AND ADMPV_COD_TPOCL IN ('1','2');

        IF V_ESTADO = 'B' THEN

        --SE LE ASIGNA EL ERROR SI ESTA EL CLIENTE EN ESTADO DE BAJA
        V_DESCERROR   := 'El cliente postpago '||V_CUENTA||', se encuentra en estado de baja';
        V_EST_ERR := 1;

        INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
        ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
        VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,sysdate,V_DESCERROR);

        GOTO VERIFICAERROR;
        END IF;

        SELECT COUNT(ADMPN_COD_CLI_IB) INTO V_COUNT
        FROM ADMPT_CLIENTEIB
        WHERE ADMPV_COD_CLI=V_CUENTA
        AND ADMPV_NUM_LINEA = V_TELEFONO;
        
        IF V_COUNT > 1 THEN
          V_DESCERROR   := 'El Cliente '||V_CUENTA||' tiene varias cuentas IB registradas.';
          V_EST_ERR := 1;

          INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
          ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
          VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,sysdate,V_DESCERROR);
          
        GOTO VERIFICAERROR;
        END IF;
             
        <<VERIFICAERROR>>
        IF V_EST_ERR = 0 THEN
  				
          --2.2	Ejecutar el SP ¿ADMPSS_OBTLINEAXCTA¿ parámetro de entrada la cuenta y parámetro de salida la lista de teléfono.	
  			  
          PKG_CC_MIGRACION.ADMPSS_OBTLINEAXCTA(V_TELEFONO,V_CUENTA,V_NUMREGTOT,V_CODERROR,V_DESCERROR,CUR_OBTLINCLI);
  			  
          IF V_NUMREGTOT > 0 THEN
  			  
          --8.	La línea migrada está asociada a la tarjeta IB.	
            
            SELECT COUNT(A.ADMPV_COD_CLI) INTO V_COUNT					
            FROM ADMPT_CLIENTE A 
            WHERE A.ADMPV_COD_CLI = V_TELEFONO
            AND A.ADMPV_COD_TPOCL = '3'
            AND A.ADMPC_ESTADO = 'A';
  							
            IF V_COUNT = 0 THEN						
              --ALMACENAR LOS DATOS DEL CLIENTE POSTPAGO
              SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
              ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
              ADMPV_DEPA,ADMPV_DIST
              INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
              V_EMAIL,V_PROV,V_DEPA,V_DIST
              FROM ADMPT_CLIENTE
              WHERE ADMPV_COD_CLI=V_CUENTA
              AND ADMPV_COD_TPOCL IN ('1','2');

              ---INSERTAR LOS DATOS POSTPAGO DEL CLIENTE PREPAGO
              INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
              ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
              ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
              VALUES(V_TELEFONO,2,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,V_EMAIL,
              V_PROV,V_DEPA,V_DIST,TRUNC(SYSDATE),'A','3',SYSDATE,'USRMIGCC');						
            END IF;
  							
                
            SELECT COUNT(*) INTO V_COUNT FROM ADMPT_SALDOS_CLIENTE
            WHERE ADMPV_COD_CLI=V_TELEFONO;

            IF V_COUNT = 0 THEN
               --INSERTAR EN LA TABLA DE SALDOS EL CLIENTE PREPAGO SI NO EXISTE EL CLIENTE PREPAGO EN LA TABLA SALDOS
               INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
               ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
               VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_TELEFONO,'',0,0,'A','',sysdate);             
            END IF;		  
            
            SELECT COUNT(A.ADMPN_COD_CLI_IB) INTO V_COUNT
            FROM ADMPT_CLIENTEIB A 
            WHERE A.ADMPV_COD_CLI = V_CUENTA
            AND A.ADMPV_NUM_LINEA = V_TELEFONO
            AND A.ADMPC_ESTADO = 'A';
  						
            IF V_COUNT > 0 THEN
                                
              --9.Los puntos IB pasan a la Bolsa  Prepago.
              --OBTENER CODCLIENTE IB
              SELECT NVL(ADMPN_COD_CLI_IB,'') INTO V_COD_CLI_IB
              FROM ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI=V_CUENTA
              AND ADMPV_NUM_LINEA = V_TELEFONO
              AND ADMPC_ESTADO = 'A';							
  							
              --ALMACENAR EL SALDO IB DEL CLIENTE POSTPAGO
  							
              SELECT ADMPN_SALDO_IB INTO V_SALDO_IB
              FROM ADMPT_SALDOS_CLIENTE
              WHERE ADMPV_COD_CLI=V_CUENTA;
  																											
              --ACTUALIZAR KARDEX							
              UPDATE ADMPT_KARDEX
              SET ADMPN_SLD_PUNTO=0,
              ADMPC_ESTADO = 'C',
              ADMPD_FEC_MOD = sysdate
              WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB
              AND ADMPC_TPO_OPER='E'
              AND ADMPC_TPO_PUNTO ='I'
              AND ADMPN_SLD_PUNTO > 0;
  							
                	
              --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO DE 'PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO'
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
              VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_CUENTA,V_COD_CPTO_IB,sysdate
              ,(V_SALDO_IB * (-1)),'S','I',0,'C',sysdate);
              --puntos -
              --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO
              UPDATE ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_IB=0,
              ADMPN_COD_CLI_IB = '',
              ADMPC_ESTPTO_IB = '',
              ADMPD_FEC_MOD = sysdate
              WHERE ADMPV_COD_CLI=V_CUENTA;
  														
              --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO 41
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
              VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_TELEFONO,V_COD_CPTO_IB,sysdate
              ,V_SALDO_IB,'E','I',V_SALDO_IB,'A',sysdate);
  							              
              UPDATE ADMPT_CLIENTEIB
              SET ADMPV_COD_CLI=V_TELEFONO,
              ADMPD_FEC_MOD=sysdate
              WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB;

  							
              UPDATE ADMPT_SALDOS_CLIENTE
              SET ADMPC_ESTPTO_IB = 'A',
              ADMPN_SALDO_IB  = V_SALDO_IB,
              ADMPN_COD_CLI_IB = V_COD_CLI_IB,
              ADMPD_FEC_MOD = sysdate
              WHERE ADMPV_COD_CLI = V_TELEFONO;                
            END IF;	
            
           INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
            ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
            VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,
            sysdate,''); 
          ELSE		    
  				
            SELECT A.ADMPV_TIPO_DOC,A.ADMPV_NUM_DOC INTO V_TIPO_DOC,V_NUM_DOC
            FROM ADMPT_CLIENTE A
            WHERE A.ADMPV_COD_CLI = V_CUENTA
            AND ADMPV_COD_TPOCL IN ('1','2');
            
            --Cliente tiene otras cuentas en CC ??			
            PKG_CC_MIGRACION.ADMPSS_OBTCTA(V_CUENTA,V_TIPO_DOC,V_NUM_DOC,V_NUMREGTOT,V_CODERROR,V_DESCERROR,CUR_OBTCTA);
    								
            IF V_NUMREGTOT > 0 THEN
            --7.	Los puntos ganados por la cuenta de la línea migrada pasan a la otra cuenta del cliente.
              LOOP
                FETCH CUR_OBTCTA
                INTO  C_CUENTA_1; 
                EXIT WHEN CUR_OBTCTA%NOTFOUND;
    					  
                V_CUENTA_1 := C_CUENTA_1;				  
    					  
              END LOOP;

              CLOSE CUR_OBTCTA;
  					
              --ALMACENAR EL SALDO DEL CLIENTE POSTPAGO
              SELECT ADMPN_SALDO_CC INTO V_SALDO 
              FROM ADMPT_SALDOS_CLIENTE
              WHERE ADMPV_COD_CLI = V_CUENTA;
  								
              --MODIFICAR LOS SALDOS Y EL ESTADO DEL CLIENTE POSTPAGO EN LA TABLA KARDEX
              UPDATE ADMPT_KARDEX
              SET ADMPN_SLD_PUNTO=0,
              ADMPC_ESTADO = 'C'
              WHERE ADMPV_COD_CLI = V_CUENTA
              AND ADMPC_TPO_OPER='E'
              AND ADMPC_TPO_PUNTO IN ('C','L')
              AND ADMPN_SLD_PUNTO > 0;
  						
              --INSERTAR EL MOVIMIENTO POR CONCEPTO DE 'MIGRACIONES POSTPAGO A PREPAGO' DEL CLIENTE POSTPAGO
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
              VALUES(ADMPT_KARDEX_SQ.NEXTVAL,'',V_CUENTA,V_COD_CPTO_CC,sysdate
              ,(V_SALDO * (-1)),'S','C',0,'C',sysdate);

              --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO
              UPDATE ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_CC=0,
              ADMPC_ESTPTO_CC='B'
              WHERE ADMPV_COD_CLI=V_CUENTA;					
    								  							
              --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO EN LA TABLA KARDEX CON EL SALDO CAPTURADO DEL CLIENTE POSTPAGO
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
              VALUES(ADMPT_KARDEX_SQ.NEXTVAL,'',V_CUENTA_1,V_COD_CPTO_CC,sysdate
              ,V_SALDO,'E','C',V_SALDO,'A');
    					
              --MODIFICAR EL SALDO EN LA TABLA SALDO DEL CLIENTE PREPAGO
              UPDATE ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_CC  = V_SALDO +
                           (SELECT NVL(ADMPN_SALDO_CC, 0)
                            FROM ADMPT_SALDOS_CLIENTE
                             WHERE ADMPV_COD_CLI = V_CUENTA_1)
              WHERE ADMPV_COD_CLI = V_CUENTA_1;
    					
              --MODIFICAR EL ESTADO DEL CLIENTE POSTPAGO EN LA TABLA CLIENTE
              UPDATE ADMPT_CLIENTE
              SET ADMPC_ESTADO = 'B',
                  ADMPV_USU_MOD = 'USRMIGCC',
                  ADMPD_FEC_MOD = sysdate
              WHERE ADMPV_COD_CLI=V_CUENTA
              AND ADMPV_COD_TPOCL IN ('1','2');
               
              SELECT COUNT(A.ADMPV_COD_CLI) INTO V_COUNT					
              FROM ADMPT_CLIENTE A 
              WHERE A.ADMPV_COD_CLI = V_TELEFONO
              AND A.ADMPV_COD_TPOCL = '3'
              AND A.ADMPC_ESTADO = 'A';
        							
              IF V_COUNT = 0 THEN						
                --ALMACENAR LOS DATOS DEL CLIENTE POSTPAGO
                SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
                ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
                ADMPV_DEPA,ADMPV_DIST
                INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
                V_EMAIL,V_PROV,V_DEPA,V_DIST
                FROM ADMPT_CLIENTE
                WHERE ADMPV_COD_CLI=V_CUENTA
                AND ADMPV_COD_TPOCL IN ('1','2');

                ---INSERTAR LOS DATOS POSTPAGO DEL CLIENTE PREPAGO
                INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
                ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                VALUES(V_TELEFONO,2,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,V_EMAIL,
                V_PROV,V_DEPA,V_DIST,TRUNC(SYSDATE),'A','3',SYSDATE,'USRMIGCC');						
              END IF;
        							
                      
              SELECT COUNT(*) INTO V_COUNT FROM ADMPT_SALDOS_CLIENTE
              WHERE ADMPV_COD_CLI=V_TELEFONO;

              IF V_COUNT = 0 THEN
                 --INSERTAR EN LA TABLA DE SALDOS EL CLIENTE PREPAGO SI NO EXISTE EL CLIENTE PREPAGO EN LA TABLA SALDOS
                 INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
                 ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
                 VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_TELEFONO,'',0,0,'A','',sysdate);
              END IF;	 
              
              SELECT COUNT(A.ADMPN_COD_CLI_IB) INTO V_COUNT
              FROM ADMPT_CLIENTEIB A 
              WHERE A.ADMPV_COD_CLI = V_CUENTA
              AND A.ADMPV_NUM_LINEA = V_TELEFONO
              AND A.ADMPC_ESTADO = 'A';
    						
              IF V_COUNT > 0 THEN               
                        
                --OBTENER CODCLIENTE IB
                SELECT NVL(ADMPN_COD_CLI_IB,'') INTO V_COD_CLI_IB
                FROM ADMPT_CLIENTEIB
                WHERE ADMPV_COD_CLI=V_CUENTA
                AND ADMPV_NUM_LINEA = V_TELEFONO
                AND ADMPC_ESTADO = 'A';							
    							
                --ALMACENAR EL SALDO IB DEL CLIENTE POSTPAGO
    							
                SELECT ADMPN_SALDO_IB INTO V_SALDO_IB
                FROM ADMPT_SALDOS_CLIENTE
                WHERE ADMPV_COD_CLI=V_CUENTA;
    							    																					
                --ACTUALIZAR KARDEX							
                UPDATE ADMPT_KARDEX
                SET ADMPN_SLD_PUNTO=0,
                ADMPC_ESTADO = 'C',
                ADMPD_FEC_MOD = sysdate
                WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB
                AND ADMPC_TPO_OPER='E'
                AND ADMPC_TPO_PUNTO ='I'
                AND ADMPN_SLD_PUNTO > 0;
    								
                --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO DE 'PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO'
                INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
                ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
                VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_CUENTA,V_COD_CPTO_IB,sysdate
                ,(V_SALDO_IB * (-1)),'S','I',0,'C',sysdate);
    							
                --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO
                UPDATE ADMPT_SALDOS_CLIENTE
                SET ADMPN_SALDO_IB=0,
                ADMPN_COD_CLI_IB = '',
                ADMPC_ESTPTO_IB = '',
                ADMPD_FEC_MOD = sysdate
                WHERE ADMPV_COD_CLI=V_CUENTA;
    														
                --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO 41
                INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
                ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
                VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_TELEFONO,V_COD_CPTO_IB,sysdate
                ,V_SALDO_IB,'E','I',V_SALDO_IB,'A',sysdate);
    							  							
                UPDATE ADMPT_CLIENTEIB
                SET ADMPV_COD_CLI=V_TELEFONO
                WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB;
    							
                UPDATE ADMPT_SALDOS_CLIENTE
                SET ADMPC_ESTPTO_IB = 'A',
                ADMPN_SALDO_IB  = V_SALDO_IB,
                ADMPN_COD_CLI_IB = V_COD_CLI_IB,
                ADMPD_FEC_MOD = sysdate
                WHERE ADMPV_COD_CLI = V_TELEFONO;	
                                   	
              END IF;
                
              INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
              ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
              VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,
              SYSDATE,'');
              	
          ELSE
              
              --ALMACENAR EL SALDO DEL CLIENTE POSTPAGO
              SELECT ADMPN_SALDO_CC INTO V_SALDO 
              FROM ADMPT_SALDOS_CLIENTE
              WHERE ADMPV_COD_CLI = V_CUENTA;
  					
              --MODIFICAR LOS SALDOS Y EL ESTADO DEL CLIENTE POSTPAGO EN LA TABLA KARDEX
              UPDATE ADMPT_KARDEX
              SET ADMPN_SLD_PUNTO=0,
              ADMPC_ESTADO = 'C'
              WHERE ADMPV_COD_CLI = V_CUENTA
              AND ADMPC_TPO_OPER='E'
              AND ADMPC_TPO_PUNTO IN ('C','L')
              AND ADMPN_SLD_PUNTO > 0;	
  											
              --INSERTAR EL MOVIMIENTO POR CONCEPTO DE 'MIGRACIONES POSTPAGO A PREPAGO' DEL CLIENTE POSTPAGO
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
              VALUES(ADMPT_KARDEX_SQ.NEXTVAL,'',V_CUENTA,V_COD_CPTO_CC,sysdate
              ,(V_SALDO * (-1)),'S','C',0,'C');	
              
              --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO
              UPDATE ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_CC=0,
                  ADMPC_ESTPTO_CC='B'
              WHERE ADMPV_COD_CLI=V_CUENTA;
            				              
              SELECT COUNT(A.ADMPV_COD_CLI) INTO V_COUNT					
              FROM ADMPT_CLIENTE A 
              WHERE A.ADMPV_COD_CLI = V_TELEFONO
              AND A.ADMPV_COD_TPOCL = '3'
              AND A.ADMPC_ESTADO = 'A';
      							
              IF V_COUNT = 0 THEN						
                --ALMACENAR LOS DATOS DEL CLIENTE POSTPAGO
                SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
                ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
                ADMPV_DEPA,ADMPV_DIST
                INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
                V_EMAIL,V_PROV,V_DEPA,V_DIST
                FROM ADMPT_CLIENTE
                WHERE ADMPV_COD_CLI=V_CUENTA
                AND ADMPV_COD_TPOCL IN ('1','2');

                ---INSERTAR LOS DATOS POSTPAGO DEL CLIENTE PREPAGO
                INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
                ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                VALUES(V_TELEFONO,2,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,V_EMAIL,
                V_PROV,V_DEPA,V_DIST,TRUNC(SYSDATE),'A','3',SYSDATE,'USRMIGCC');						
              END IF;
      							
                    
              SELECT COUNT(*) INTO V_COUNT FROM ADMPT_SALDOS_CLIENTE
              WHERE ADMPV_COD_CLI=V_TELEFONO;

              IF V_COUNT = 0 THEN
                 --INSERTAR EN LA TABLA DE SALDOS EL CLIENTE PREPAGO SI NO EXISTE EL CLIENTE PREPAGO EN LA TABLA SALDOS
                 INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
                 ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
                 VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_TELEFONO,'',0,0,'A','',sysdate);             
              END IF;	
                						
              --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO EN LA TABLA KARDEX CON EL SALDO CAPTURADO DEL CLIENTE POSTPAGO
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
              VALUES(ADMPT_KARDEX_SQ.NEXTVAL,'',V_TELEFONO,V_COD_CPTO_CC,sysdate
              ,V_SALDO,'E','C',V_SALDO,'A');

              --MODIFIC7AR EL SALDO EN LA TABLA SALDO DEL CLIENTE PREPAGO
              UPDATE ADMPT_SALDOS_CLIENTE
              SET ADMPN_SALDO_CC  = V_SALDO +
                                       (SELECT NVL(ADMPN_SALDO_CC, 0)
                                          FROM ADMPT_SALDOS_CLIENTE
                                         WHERE ADMPV_COD_CLI = V_TELEFONO)
              WHERE ADMPV_COD_CLI = V_TELEFONO;
  						
              SELECT ADMPT_KARDEX_SQ.NEXTVAL INTO V_KARDEX_ID FROM DUAL;
              
              V_VALOR := V_VALOR * (-1);
              
              IF V_SALDO > V_VALOR THEN
                V_PENALIDAD := V_VALOR; 
              ELSE
                V_PENALIDAD := V_SALDO;
              END IF;
              
              INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
              VALUES(V_KARDEX_ID,'',V_TELEFONO,V_CODCPTO_BONO,sysdate
              ,(V_PENALIDAD * (-1)),'S','C',0,'C');
               						           
              K_ID_CANJE:=V_KARDEX_ID;
              K_SEC:=1;
              K_PUNTOS:=V_PENALIDAD;
              K_TIP_CLI:='3';
              V_PUNTOS_REQUERIDOS:=K_PUNTOS;
              
              if V_TELEFONO is not null then
                if K_TIP_CLI='3' or K_TIP_CLI='4' then
                  Open LISTA_KARDEX_1;
                  fetch LISTA_KARDEX_1 into LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
                  while LISTA_KARDEX_1%found and V_PUNTOS_REQUERIDOS>0
                  loop
                        if LK_SLD_PUNTOS<=V_PUNTOS_REQUERIDOS then
                          -- Actualiza Kardex
                          update admpt_kardex
                          set
                          admpn_sld_punto = 0, admpc_estado = 'C'
                          where admpn_id_kardex = LK_ID_KARDEX;

                          -- Actualiza Saldos_cliente
                          if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then 
                              update admpt_saldos_cliente
                                 set
                                     admpn_saldo_cc = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_cc,0) from admpt_saldos_cliente
                                              where admpv_cod_cli=LK_COD_CLI)
                               where admpv_cod_cli = LK_COD_CLI;
                          end if;
                          V_PUNTOS_REQUERIDOS:=V_PUNTOS_REQUERIDOS-LK_SLD_PUNTOS;
                          else
                              if LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS then

                                 -- Actualiza Kardex
                                 update admpt_kardex
                                 set
                                 admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                                 where admpn_id_kardex = LK_ID_KARDEX;

                                 -- Actualiza Saldos_cliente
                                 if LK_TPO_PUNTO='C' or LK_TPO_PUNTO='L' then 
                                 update admpt_saldos_cliente
                                 set
                                 admpn_saldo_cc = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_cc,0) from admpt_saldos_cliente
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
  										                   
                UPDATE ADMPT_CLIENTE
                SET ADMPC_ESTADO = 'B',
                ADMPV_USU_MOD = 'USRMIGCC'
                WHERE ADMPV_COD_CLI=V_CUENTA
                AND ADMPV_COD_TPOCL IN ('1','2');
    								              				
                --8.	La línea migrada está asociada a la tarjeta IB.	
                IF 	TRIM(V_TELEFONO) IS NOT NULL AND TRIM(V_CUENTA) IS NOT NULL THEN 
      						
                  SELECT COUNT(A.ADMPN_COD_CLI_IB) INTO V_COUNT
                  FROM ADMPT_CLIENTEIB A 
                  WHERE A.ADMPV_COD_CLI = V_CUENTA
                  AND A.ADMPV_NUM_LINEA = V_TELEFONO
                  AND A.ADMPC_ESTADO = 'A';
      						
                  IF V_COUNT > 0 THEN               
                    --9.Los puntos IB pasan a la Bolsa  Prepago.
      							
                    SELECT COUNT(A.ADMPV_COD_CLI) INTO V_COUNT					
                    FROM ADMPT_CLIENTE A 
                    WHERE A.ADMPV_COD_CLI = V_TELEFONO
                    AND A.ADMPV_COD_TPOCL = '3'
                    AND A.ADMPC_ESTADO = 'A';
      							
                    IF V_COUNT = 0 THEN						
                      --ALMACENAR LOS DATOS DEL CLIENTE POSTPAGO
                      SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
                      ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
                      ADMPV_DEPA,ADMPV_DIST
                      INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
                      V_EMAIL,V_PROV,V_DEPA,V_DIST
                      FROM ADMPT_CLIENTE
                      WHERE ADMPV_COD_CLI=V_CUENTA
                      AND ADMPV_COD_TPOCL IN ('1','2');

                      ---INSERTAR LOS DATOS POSTPAGO DEL CLIENTE PREPAGO
                      INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                      ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,
                      ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                      VALUES(V_TELEFONO,2,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,V_EMAIL,
                      V_PROV,V_DEPA,V_DIST,TRUNC(SYSDATE),'A','3',SYSDATE,'USRMIGCC');						
                    END IF;
      							
                    
                    SELECT COUNT(*) INTO V_COUNT FROM ADMPT_SALDOS_CLIENTE
                    WHERE ADMPV_COD_CLI=V_TELEFONO;

                    IF V_COUNT = 0 THEN
                       --INSERTAR EN LA TABLA DE SALDOS EL CLIENTE PREPAGO SI NO EXISTE EL CLIENTE PREPAGO EN LA TABLA SALDOS
                       INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC
                       ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
                       VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_TELEFONO,'',0,0,'','',sysdate);

                    END IF;				
                    
                    --OBTENER CODCLIENTE IB
                    SELECT NVL(ADMPN_COD_CLI_IB,'') INTO V_COD_CLI_IB
                    FROM ADMPT_CLIENTEIB
                    WHERE ADMPV_COD_CLI=V_CUENTA
                    AND ADMPV_NUM_LINEA = V_TELEFONO
                    AND ADMPC_ESTADO = 'A';							
      							
                    --ALMACENAR EL SALDO IB DEL CLIENTE POSTPAGO
      							
                    SELECT ADMPN_SALDO_IB INTO V_SALDO_IB
                    FROM ADMPT_SALDOS_CLIENTE
                    WHERE ADMPV_COD_CLI=V_CUENTA;
      																											
                    --ACTUALIZAR KARDEX							
                    UPDATE ADMPT_KARDEX
                    SET ADMPN_SLD_PUNTO=0,
                    ADMPC_ESTADO = 'C',
                    ADMPD_FEC_MOD = sysdate
                    WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB
                    AND ADMPC_TPO_OPER='E'
                    AND ADMPC_TPO_PUNTO ='I'
                    AND ADMPN_SLD_PUNTO > 0;
      								
                    --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO DE 'PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO'
                    INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
                    ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
                    VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_CUENTA,V_COD_CPTO_IB,sysdate
                    ,(V_SALDO_IB * (-1)),'S','I',0,'C',sysdate);
      							
                    --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO
                    UPDATE ADMPT_SALDOS_CLIENTE
                    SET ADMPN_SALDO_IB=0,
                    ADMPN_COD_CLI_IB = '',
                    ADMPC_ESTPTO_IB = '',
                    ADMPD_FEC_MOD = sysdate
                    WHERE ADMPV_COD_CLI=V_CUENTA;
      														
                    --INSERTAR EL MOVIMIENTO DEL CLIENTE PREPAGO POR CONCEPTO 41
                    INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
                    ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG)
                    VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,V_TELEFONO,V_COD_CPTO_IB,sysdate
                    ,V_SALDO_IB,'E','I',V_SALDO_IB,'A',sysdate);
      							              
                    UPDATE ADMPT_CLIENTEIB
                    SET ADMPV_COD_CLI=V_TELEFONO
                    WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB;
      							
                    UPDATE ADMPT_SALDOS_CLIENTE
                    SET ADMPC_ESTPTO_IB = 'A',
                    ADMPN_SALDO_IB  = V_SALDO_IB,
                    ADMPN_COD_CLI_IB = V_COD_CLI_IB,
                    ADMPD_FEC_MOD = sysdate
                    WHERE ADMPV_COD_CLI = V_TELEFONO;		
                  END IF;
                ELSE
                    V_DESCERROR:='El Numero de Telefono y la cuenta no pueden ser vacias';
                    V_EST_ERR:= 1;
        						
                    INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
                    ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
                    VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,
                    sysdate,V_DESCERROR);
        						
                    EXIT;
                END IF;	
              					
                INSERT INTO ADMPT_IMP_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG
                ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
                VALUES(ADMPT_IMP_PREPOSPRE_SQ.NEXTVAL,V_CUENTA,V_TELEFONO,V_FECHAMIGR,
                SYSDATE,'');
                					
            END IF;				
            END IF;
            
            INSERT INTO ADMPT_AUX_PREPOSPRE(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_TELEFONO,ADMPD_FEC_MIG,ADMPD_FEC_OPER)
            VALUES(admpt_aux_preprepos_sq.nextval,V_CUENTA,V_TELEFONO,V_FECHAMIGR,SYSDATE);
            COMMIT;
          END IF;
        		
         K_CODERROR:= 0;	
         K_DESCERROR := ' ';
       ELSE
         K_CODERROR := '0';
         K_DESCERROR := 'No se encontraron registros para procesar.';
         K_NUMREGTOT := 0;
         K_NUMREGPRO := 0; 
         K_NUMREGERR := 0;
       END IF;	 
  		   
      END IF; 
		  END LOOP;
		  CLOSE CUR_OBTPOSAPRE;
      
      DELETE ADMPT_AUX_PREPOSPRE WHERE ADMPD_FEC_OPER >= TRUNC(SYSDATE);
      COMMIT;	

      SELECT COUNT (*) INTO K_NUMREGTOT FROM ADMPT_IMP_PREPOSPRE WHERE ADMPD_FEC_OPER>=TRUNC(sysdate);
        
		  SELECT COUNT (*) INTO K_NUMREGERR FROM ADMPT_IMP_PREPOSPRE WHERE ADMPD_FEC_OPER>=TRUNC(sysdate)
	      AND ( ADMPV_MSJE_ERROR Is Not null);

      K_NUMREGPRO:=K_NUMREGTOT - K_NUMREGERR; 
		  
	ELSE
		K_CODERROR := '0';         
		K_DESCERROR := 'No se encontraron registros para procesar.';
		K_NUMREGTOT := 0;
		K_NUMREGPRO := 0; 
		K_NUMREGERR := 0;
	END IF;	
END ADMPSI_PREMIGPOS;

procedure ADMPSI_PREMIGPRE(K_FECHA IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER)
  IS
--****************************************************************
-- Nombre SP           :  ADMPSI_PREMIGPRE
-- Propósito           :  Devuelve los errores producidos por otorgar puntos por Migracion hacia un plan Postpago
-- Input               :  K_FECHA
-- Output              :  K_CODERROR
--                        K_DESCERROR
--                        K_NUMREGTOT
--                        K_NUMREGPRO
--                        K_NUMREGERR
-- Creado por          :  Deysi Galvez
-- Fec Creación        :  11/11/2010
-- Fec Actualización   :  
--****************************************************************

NO_CONCEPTO EXCEPTION;
NO_PARAMETRO EXCEPTION;

V_NUMREGTOT NUMBER;
V_CODERROR VARCHAR2(10);
V_DESCERROR VARCHAR2(400);
TYPE TY_CURSOR IS REF CURSOR;
CURSOROBTPREAPOS  TY_CURSOR;
C_CUR_DATOS_CLIE TY_CURSOR;

C_NUM_LINEA  VARCHAR2(20);
C_FECHAMIGR DATE;

V_NUM_LINEA  VARCHAR2(20);

V_COD_CPTO VARCHAR2(2);
V_CODCPTO_BONO VARCHAR2(2);
V_COUNT NUMBER;
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

V_COD_CLI_IB NUMBER;
V_NUMTEL VARCHAR2(40);
V_SALDO_IB NUMBER;
V_CODCPTO_IB VARCHAR2(2);
V_EXT_CPOST NUMBER;

V_COD_NUEVO    NUMBER;
V_REG          NUMBER;
V_COD_CLINUE   VARCHAR(40);

BEGIN  
  
BEGIN
SELECT ADMPV_COD_CPTO
INTO V_COD_CPTO
FROM ADMPT_CONCEPTO
WHERE ADMPV_DESC LIKE '%MIGRACIONES PREPAGO A POSTPAGO CC%';
EXCEPTION
WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
END;

BEGIN
SELECT ADMPV_COD_CPTO
INTO V_CODCPTO_BONO
FROM ADMPT_CONCEPTO
WHERE ADMPV_DESC LIKE '%BONO POR MIGRACIONES PREPAGO A POSTPAGO%';
EXCEPTION
WHEN NO_DATA_FOUND THEN V_CODCPTO_BONO:=NULL;
END;

BEGIN
SELECT ADMPV_COD_CPTO
INTO V_CODCPTO_IB
FROM ADMPT_CONCEPTO
WHERE ADMPV_DESC LIKE '%MIGRACIONES PREPAGO A POSTPAGO IB%';
EXCEPTION
WHEN NO_DATA_FOUND THEN V_CODCPTO_IB:=NULL;
END;

BEGIN
SELECT ADMPV_VALOR
INTO V_VALOR
FROM ADMPT_PARAMSIST
WHERE ADMPV_DESC LIKE '%PUNTOS_MIGRACION_PREPAGO_POSTPAGO%';
EXCEPTION
WHEN NO_DATA_FOUND THEN V_VALOR:=NULL;
END;

--VERIFICANDO LA EXISTENCIA DE LOS CONCEPTOS A UTILIZAR
IF ((V_COD_CPTO IS NULL) OR (V_CODCPTO_BONO IS NULL) OR (V_CODCPTO_IB IS NULL) OR (V_VALOR IS NULL)) THEN
RAISE NO_CONCEPTO;
END IF;

--VERIFICANDO LA EXISTENCIA DEL PARAMETRO A UTILIZAR
IF V_VALOR IS NULL THEN
RAISE NO_PARAMETRO;
END IF;
  
PKG_CC_MIGRACION.ADMPSS_OBTPREAPOS(K_FECHA,V_NUMREGTOT,V_CODERROR,V_DESCERROR,CURSOROBTPREAPOS);  
  
IF V_NUMREGTOT > 0 THEN
  LOOP
  FETCH CURSOROBTPREAPOS
    INTO  C_NUM_LINEA,C_FECHAMIGR; 
      EXIT WHEN CURSOROBTPREAPOS%NOTFOUND;
	    V_EST_ERR:= 0;  	  
      V_NUM_LINEA := SUBSTR(C_NUM_LINEA,3);
	  
	    SELECT COUNT(*) INTO V_COUNT 
      FROM ADMPT_AUX_PREPREPOS    
      where ADMPV_COD_CLI = V_NUM_LINEA
      AND ADMPD_FEC_OPER >= TRUNC(SYSDATE);
      
      IF V_COUNT = 0 THEN
      
      IF (V_NUM_LINEA IS NULL) OR (REPLACE(V_NUM_LINEA, ' ', '') IS NULL) THEN
        --SE LE ASIGNA EL ERROR SI NO EXISTE EL NUMERO TELEFONICO
        V_ERROR   := 'Número de Teléfono es un dato obligatorio.';
        V_EST_ERR := 1;
        INSERT INTO ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_CUENTA,ADMPD_FEC_MIG
        ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
        VALUES(ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,V_NUM_LINEA,'',C_FECHAMIGR,
        sysdate,V_ERROR);
        COMMIT;
        END IF;
  		
      IF V_EST_ERR = 0 THEN
        SELECT COUNT(*) INTO V_COUNT
        FROM ADMPT_CLIENTE
        WHERE ADMPV_COD_CLI = V_NUM_LINEA
        AND ADMPV_COD_TPOCL ='3';
  			
        IF V_COUNT = 0 THEN
           V_ERROR:='Cliente Prepago '|| V_NUM_LINEA ||' no existe en Claro Club';
           V_EST_ERR:= 1;
           INSERT INTO ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_CUENTA,ADMPD_FEC_MIG
           ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
           VALUES(ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,V_NUM_LINEA,'',C_FECHAMIGR,
           SYSDATE,V_ERROR);
           COMMIT;
        ELSE
           SELECT ADMPC_ESTADO INTO V_ESTADO
           FROM ADMPT_CLIENTE
           WHERE ADMPV_COD_CLI = V_NUM_LINEA
           AND ADMPV_COD_TPOCL ='3';

           IF V_ESTADO = 'B'  THEN
            V_ERROR   := 'Cliente Prepago '|| V_NUM_LINEA  ||' ya se encuentra de Baja.';
            V_EST_ERR := 1;
            INSERT INTO ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_CUENTA,ADMPD_FEC_MIG
            ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
            VALUES(ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,V_NUM_LINEA,'',C_FECHAMIGR,
            sysdate,V_ERROR);
            COMMIT;
           END IF;
        END IF;	
      END IF;
  		
      
      IF V_EST_ERR = 0 THEN
        PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',V_NUM_LINEA, V_ERROR, C_CUR_DATOS_CLIE);
  			
        LOOP
               FETCH C_CUR_DATOS_CLIE INTO C_CUENTA,C_TIP_DOC,C_NUM_DOC,C_CO_ID,
               C_CI_FAC,C_COD_TIP_CL,C_TIP_CL;
  			   
            IF C_CUR_DATOS_CLIE%NOTFOUND OR C_CUENTA IS NULL THEN
                 IF C_CUENTA IS NULL THEN
                   V_ERROR   := 'La línea '|| C_CUENTA ||' no existe en BSCS';
                   INSERT INTO ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_CUENTA,ADMPD_FEC_MIG
                   ,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
                   VALUES(ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,V_NUM_LINEA,'',C_FECHAMIGR,
                   SYSDATE,V_ERROR);
                 END IF;
                 EXIT WHEN C_CUR_DATOS_CLIE%NOTFOUND;
               ELSE
                 EXIT WHEN C_CUR_DATOS_CLIE%NOTFOUND;
                 
                 BEGIN
                   SELECT NVL(ADMPN_SALDO_CC,0) INTO V_SALDO_CC
                   FROM ADMPT_SALDOS_CLIENTE
                   WHERE ADMPV_COD_CLI=V_NUM_LINEA;
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN V_SALDO_CC:=0;
                 END;
      	  		   
              --MODIFICAR LOS SALDOS Y ESTADOS DEL CLIENTE PREPAGO EN EL KARDEX
                 UPDATE ADMPT_KARDEX
                 SET ADMPN_SLD_PUNTO = 0,
                 ADMPC_ESTADO='C'
                 WHERE ADMPV_COD_CLI=V_NUM_LINEA AND
                 ADMPC_TPO_OPER='E' AND
                 ADMPC_TPO_PUNTO IN ('C','L') AND
                 ADMPN_SLD_PUNTO > 0;
      	  		         	  		   		   		   
                 --INSERTAR REGISTRO EN LA TABLA ADMPT_KARDEX
                 INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI
                 ,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO
                 ,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
                 VALUES(ADMPT_KARDEX_SQ.NEXTVAL, '',V_NUM_LINEA,V_COD_CPTO,sysdate,
                 (V_SALDO_CC * (-1)),'S','C',0,'C');
          	  		  
                 --ACTUALIZA SALDO
                 UPDATE ADMPT_SALDOS_CLIENTE
                     SET ADMPN_SALDO_CC = 0,
                     ADMPC_ESTPTO_CC = 'B' 
                     WHERE ADMPV_COD_CLI=V_NUM_LINEA;
          	  		   
                 --ACTUALIZAR ESTADO A B
                 UPDATE ADMPT_CLIENTE
                 SET ADMPC_ESTADO='B',
                 ADMPV_USU_MOD='USRMIGCC'
                 WHERE ADMPV_COD_CLI=V_NUM_LINEA;
          	  		   
                 V_COD_NUEVO  := 1;
                 V_COD_CLINUE := '';

                 WHILE V_COD_NUEVO > 0 LOOP
                V_COD_CLINUE := TRIM(V_NUM_LINEA) || '-' || TO_CHAR(V_COD_NUEVO);
                  V_REG := 0;

                BEGIN
                 SELECT COUNT(*)
                 INTO V_REG
                 FROM ADMPT_CLIENTE
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
                  INSERT INTO ADMPT_CLIENTE (ADMPV_COD_CLI)
                  VALUES ('999999999999999');

                  UPDATE ADMPT_CANJE
                     SET ADMPV_COD_CLI = '999999999999999'
                   WHERE ADMPV_COD_CLI = V_NUM_LINEA;  
                	
                  UPDATE ADMPT_KARDEX
                  SET ADMPV_COD_CLI=V_COD_CLINUE
                  WHERE ADMPV_COD_CLI=V_NUM_LINEA;

                  UPDATE ADMPT_SALDOS_CLIENTE
                  SET ADMPV_COD_CLI=V_COD_CLINUE,
                  ADMPC_ESTPTO_CC = 'B',
                  ADMPC_ESTPTO_IB = ''
                  WHERE ADMPV_COD_CLI=V_NUM_LINEA;

                  UPDATE ADMPT_CLIENTE
                  SET ADMPV_COD_CLI=V_COD_CLINUE,
                      ADMPV_USU_MOD='USRMIGCC'
                  WHERE ADMPV_COD_CLI=V_NUM_LINEA
                  AND ADMPC_ESTADO='B';
          	  		       
                  UPDATE ADMPT_CANJE
                  SET ADMPV_COD_CLI=V_COD_CLINUE
                  WHERE ADMPV_COD_CLI='999999999999999';
                  	 
                  DELETE ADMPT_CLIENTE WHERE ADMPV_COD_CLI='999999999999999';
                                   
                END;
      	  		  		 	  
            --CAPTURAR LOS DATOS DEL CLIENTE PREPAGO
                 SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
                 ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,
                 ADMPV_DEPA,ADMPV_DIST
                 INTO V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
                 V_EMAIL,V_PROV,V_DEPA,V_DIST
                 FROM ADMPT_CLIENTE
                 WHERE ADMPV_COD_CLI=V_COD_CLINUE;		  
      	  					  
                 SELECT COUNT(ADMPV_COD_CLI) INTO V_EXT_CPOST
                 FROM ADMPT_CLIENTE
                 WHERE ADMPV_COD_CLI=C_CUENTA
                 AND ADMPV_COD_TPOCL IN (1,2);
      	  		   
                 IF V_EXT_CPOST=0 THEN
                   --INSERTAR EL CLIENTE POSTPAGO CON CODIGO OBTENIDO DEL SP ADMPSS_DAT_CLIE Y LOS DATOS DEL CLIENTE PREPAGO
                   INSERT INTO ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI
                   ,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST
                   ,ADMPN_COD_CATCLI,ADMPD_FEC_ACTIV,ADMPV_CICL_FACT,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                   VALUES(C_CUENTA,V_TIPO_DOC,V_NUM_DOC,V_NOM_CLI,V_APE_CLI,V_SEXO,V_EST_CIVIL,
                   V_EMAIL,V_PROV,V_DEPA,V_DIST,2,TRUNC(sysdate),C_CI_FAC,'A','2',SYSDATE,'USRMIGCC');
                 ELSE
                     UPDATE ADMPT_CLIENTE
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
                     ADMPD_FEC_ACTIV=TRUNC(sysdate),
                     ADMPV_CICL_FACT=C_CI_FAC,
                     ADMPC_ESTADO='A',
                     ADMPV_COD_TPOCL='2',
                     ADMPV_USU_MOD='USRMIGCC'
                     WHERE ADMPV_COD_CLI=C_CUENTA
                     AND ADMPV_COD_TPOCL IN (1,2);
                 END IF;
      	  		   
                 --INSERTAR EN LA TABLA KARDEX UN MOVIMIENTO CON CONCEPTO DE MIGRACION DE PREPAGO A POSTPAGO
                 INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO
                 ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
                 VALUES(ADMPT_KARDEX_SQ.NEXTVAL,'',C_CUENTA,V_COD_CPTO,sysdate,
                 V_SALDO_CC,'E','C',V_SALDO_CC,'A');
      	  		
                 SELECT COUNT(*) INTO V_COUNT
                 FROM ADMPT_SALDOS_CLIENTE
                 WHERE ADMPV_COD_CLI=C_CUENTA;

                 IF V_COUNT = 0 THEN
                    --INSERTAR SI NO EXISTE CLIENTE POSTPAGO EN LA TABLA SALDOS.
                    INSERT INTO ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_SALDO_CC
                    ,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC)
                    VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,C_CUENTA,V_SALDO_CC,0,'A');
                 ELSE
                    --MODIFICAR EL SALDO DEL CLIENTE POSTPAGO, AÑADIENDO EL SALDO ALMACENADO CUANDO ERA PREPAGO
                    UPDATE ADMPT_SALDOS_CLIENTE
                    SET ADMPC_ESTPTO_CC='A',
                    ADMPN_SALDO_CC  = V_SALDO_CC +
                                           (SELECT NVL(ADMPN_SALDO_CC, 0)
                                              FROM ADMPT_SALDOS_CLIENTE
                                             WHERE ADMPV_COD_CLI = C_CUENTA)
                    WHERE ADMPV_COD_CLI = C_CUENTA;
                 END IF;
      	  		   
              --INSERTAR EN LA TABLA DE KARDEX LOS PUNTOS DE BENEFICIO POR HABER MIGRADO
                 INSERT INTO ADMPT_KARDEX(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS
                 ,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO)
                 VALUES(ADMPT_KARDEX_SQ.NEXTVAL,V_COD_CLI_IB,C_CUENTA,V_CODCPTO_BONO,sysdate,
                 V_VALOR,'E','C',V_VALOR,'A');
      	  		   
             --MODIFICAR SALDO DEL CLIENTE POSTPAGO
                 UPDATE ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_CC  = V_VALOR +
                                           (SELECT NVL(ADMPN_SALDO_CC, 0)
                                              FROM ADMPT_SALDOS_CLIENTE
                                             WHERE ADMPV_COD_CLI = C_CUENTA)
                 WHERE ADMPV_COD_CLI = C_CUENTA;
      	  		   			
                 --CLIENTE IB
                     
                 SELECT COUNT(A.ADMPV_COD_CLI) INTO V_COUNT
                 FROM ADMPT_CLIENTEIB A 
                 WHERE A.ADMPV_COD_CLI = V_NUM_LINEA;
                     
                 IF V_COUNT > 0 THEN
                     
                    SELECT A.ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
                    FROM ADMPT_CLIENTEIB A
                    WHERE A.ADMPV_COD_CLI = V_NUM_LINEA;  
                                                        
                    SELECT SUM(ADMPN_SALDO_IB) INTO V_SALDO_IB
                    FROM ADMPT_SALDOS_CLIENTE
                    WHERE ADMPV_COD_CLI=V_COD_CLINUE;
                                                  	  		
                    UPDATE ADMPT_KARDEX
                    SET ADMPN_SLD_PUNTO = 0,
                    ADMPC_ESTADO='C'
                    WHERE ADMPV_COD_CLI=V_COD_CLINUE AND
                    ADMPC_TPO_OPER='E' AND
                    ADMPC_TPO_PUNTO = 'I' AND
                    ADMPN_SLD_PUNTO > 0;
                                            	  		  
                    --INSERTAR REGISTRO EN LA TABLA ADMPT_KARDEX DEL CLIENTE PREPAGO
                    INSERT INTO ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
                    ADMPN_PUNTOS,ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                    VALUES(ADMPT_KARDEX_SQ.NEXTVAL, V_COD_CLI_IB,V_COD_CLINUE, V_CODCPTO_IB,SYSDATE,
                    (V_SALDO_IB * (-1)),'S','I',0,'C');
                                            	  		 
                    UPDATE ADMPT_SALDOS_CLIENTE
                    SET ADMPN_SALDO_IB=0,
                    ADMPN_COD_CLI_IB='',
                    ADMPC_ESTPTO_IB=''
                    WHERE ADMPV_COD_CLI = V_COD_CLINUE;
            	  		  
                    --INSERTAR REGISTRO EN LA TABLA ADMPT_KARDEX DEL CLIENTE POSTPAGO
                    INSERT INTO ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
                    ADMPN_PUNTOS,ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                    VALUES(ADMPT_KARDEX_SQ.NEXTVAL, V_COD_CLI_IB,C_CUENTA, V_CODCPTO_IB,SYSDATE,
                    V_SALDO_IB,'E','I',V_SALDO_IB,'A');
                           
                    UPDATE ADMPT_SALDOS_CLIENTE
                    SET ADMPC_ESTPTO_IB='A',
                    ADMPN_COD_CLI_IB=V_COD_CLI_IB,
                    ADMPN_SALDO_IB= V_SALDO_IB + (SELECT NVL(ADMPN_SALDO_IB,0)
                                                  FROM ADMPT_SALDOS_CLIENTE
                                                  WHERE ADMPV_COD_CLI = C_CUENTA)
                    WHERE ADMPV_COD_CLI = C_CUENTA;
                                                            	  		  
                    UPDATE ADMPT_CLIENTEIB
                    SET ADMPV_COD_CLI=C_CUENTA
                    WHERE ADMPN_COD_CLI_IB=V_COD_CLI_IB;

                    UPDATE ADMPT_SALDOS_CLIENTE
                    SET ADMPN_COD_CLI_IB = ''
                    WHERE ADMPV_COD_CLI=V_NUMTEL;
                                                                      
                 END IF;                         
                END IF;	
  	    
                INSERT INTO ADMPT_IMP_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_CUENTA,ADMPD_FEC_MIG,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR)
                VALUES(ADMPT_IMP_PREPREPOS_SQ.NEXTVAL,V_NUM_LINEA,C_CUENTA,C_FECHAMIGR,SYSDATE,'');
        
                INSERT INTO ADMPT_AUX_PREPREPOS(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPD_FEC_MIG,ADMPD_FEC_OPER,ADMPV_CUENTA)
                VALUES(ADMPT_AUX_PREPREPOS_SQ.NEXTVAL,V_NUM_LINEA,C_FECHAMIGR,SYSDATE,C_CUENTA);
                
                COMMIT;
  			   
        END LOOP;   
        CLOSE C_CUR_DATOS_CLIE;
  			
         K_CODERROR:=0;
         K_DESCERROR:=' ';
  			
      END IF;
      END IF;
  END LOOP;	
  CLOSE CURSOROBTPREAPOS;
  
  DELETE FROM ADMPT_AUX_PREPREPOS A
  WHERE A.ADMPD_FEC_OPER >= TRUNC(SYSDATE);
  			  
  COMMIT;
  
  SELECT COUNT (*) INTO K_NUMREGTOT FROM ADMPT_IMP_PREPREPOS WHERE ADMPD_FEC_OPER>=TRUNC(sysdate);
        
  SELECT COUNT (*) INTO K_NUMREGERR FROM ADMPT_IMP_PREPREPOS WHERE ADMPD_FEC_OPER>=TRUNC(sysdate)
    AND ( ADMPV_MSJE_ERROR IS NOT NULL);

  K_NUMREGPRO:=K_NUMREGTOT - K_NUMREGERR; 
ELSE
		K_CODERROR := 0;
		K_DESCERROR := 'No se encontraron registros para procesar.';
		K_NUMREGTOT := 0;
		K_NUMREGPRO := 0; 
		K_NUMREGERR := 0;  
END IF;	  
END ADMPSI_PREMIGPRE;  

END PKG_CC_MIGRACION;
/

