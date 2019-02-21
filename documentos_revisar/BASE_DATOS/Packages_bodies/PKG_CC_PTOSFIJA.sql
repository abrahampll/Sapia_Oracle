CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_PTOSFIJA IS

FUNCTION SPLITCAD(P_IN_STRING VARCHAR2, P_DELIM VARCHAR2)
RETURN TAB_ARRAY
  /*
        Proposito            : Separacion de parametros enviados en un cadena por un determinante
        Parametros          : p_in_string   Cadena que contiene los parametros concatenados
                                p_delim         Caracter delimitador
        Fecha Creacion      : 09:30 a.m. 02/02/2012
        Fecha Modificacion  : 09:30 a.m. 02/02/2012
     -----------------------------------------------------------------------
  */
  IS
    I         NUMBER := 0;
    POS       NUMBER := 0;
    LV_STR    VARCHAR2(200) := LTRIM(P_IN_STRING);
    ARREGLO   TAB_ARRAY;
    CVALOR    VARCHAR2(200);
  BEGIN
    POS :=  INSTR(LV_STR,P_DELIM ,1 ,1);
    WHILE (POS != 0 OR  POS != NULL)
    LOOP
      I := I + 1;
      --Capturando valores para el arreglo
      CVALOR:=SUBSTR(LV_STR, 1, POS - 1);
      IF CVALOR='|' OR CVALOR IS NULL THEN
         ARREGLO(I) :='NULL';
      ELSE
         ARREGLO(I) :=CVALOR;
      END IF;

      LV_STR     :=SUBSTR(LV_STR, POS + 1, LENGTH(LV_STR));
      POS        :=INSTR(LV_STR ,P_DELIM  ,1 ,1);

      IF POS = 0 THEN
        --Capturando valor para el primer elemento
        ARREGLO(I + 1) := LV_STR;
      END IF;
    END LOOP;

    RETURN ARREGLO;
END SPLITCAD;

FUNCTION DEVOLVER_POSICION(P_IN_STRING VARCHAR2) RETURN NUMBER
   /*
          Proposito            : Devuelve la posición de "_" del primer registro.
          Parametros          : p_in_string   Cadena que contiene los parametros CUSCODE
          Fecha Creacion      : 10:40 a.m. 20/10/2016
          Fecha Modificacion  : 10:40 a.m. 20/10/2016
       -----------------------------------------------------------------------
    */
   IS
    POSICION NUMBER := 0;   
  BEGIN
    SELECT INSTR(P.ADMPV_COD_CLI_PROD,'_',1,1) INTO POSICION FROM ADMPT_CLIENTEPRODUCTO P 
    WHERE P.ADMPV_COD_CLI_PROD LIKE P_IN_STRING||'%' 
    AND SUBSTR(P.ADMPV_COD_CLI,LENGTH(P.ADMPV_COD_CLI),1) = 7 AND rownum = 1;
  
    RETURN POSICION;
  END DEVOLVER_POSICION;

PROCEDURE ADMPSI_BUSCARCLIENTE(K_TIPDOC IN VARCHAR2,K_NUMDOC IN VARCHAR2,K_TIPCLIE IN VARCHAR2, K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,CLIEN_CUR OUT SYS_REFCURSOR) IS
--****************************************************************
  -- Nombre SP           :  ADMPSI_BUSCARCLIENTE
  -- Propósito           :   Buscar cliente
  -- Input               :  tipdoc,num_doc,tipclie
  -- Output              :
  -- Fec Creación        :  18/04/2012
  -- Fec Actualización   :
  --Autor               :   Juan Carlos Gutiérrez Trujillo
  --****************************************************************
K_CLIEN NUMBER;

BEGIN
K_CODERROR:=3;
--K_DESCERROR:='El cliente ya se encuentra registrado en CLARO CLUB';

   SELECT COUNT(*) INTO K_CLIEN
   FROM PCLUB.ADMPT_CLIENTEFIJA C
   WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
   AND C.ADMPV_NUM_DOC = K_NUMDOC
   AND C.ADMPV_COD_TPOCL = K_TIPCLIE;

 IF K_CLIEN = 0 THEN
    K_CODERROR:=2;
    --K_DESCERROR:='El cliente no esta registrado en CLARO CLUB';
 ELSE
    OPEN CLIEN_CUR FOR
    SELECT *
    FROM PCLUB.ADMPT_CLIENTEFIJA C
    WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
    AND C.ADMPV_NUM_DOC = K_NUMDOC
    AND C.ADMPV_COD_TPOCL = K_TIPCLIE;
 END IF;

--MANEJO DE ERRORES
    BEGIN
        SELECT ADMPV_DES_ERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
    END;
EXCEPTION WHEN OTHERS THEN
K_CODERROR:=1;
K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);

END ADMPSI_BUSCARCLIENTE;

PROCEDURE ADMPSI_PREMODIF_CLIENTE(K_FLAG IN VARCHAR2,K_COD_CLIPROD IN  VARCHAR2,K_TIPODOC IN VARCHAR2,K_NUMDOC IN VARCHAR2,K_NOMCLI IN VARCHAR2,K_APECLI IN VARCHAR2,K_SEX IN VARCHAR2,K_EST_CIV IN VARCHAR2,
                              K_EMAIL IN VARCHAR2,K_DEPT IN VARCHAR2,K_PROV IN VARCHAR2,K_DIST IN VARCHAR2,K_CIC_FAC IN VARCHAR2,K_TIPCLIE IN VARCHAR2,
                              K_USUARIO IN VARCHAR2, K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS
  K_LISTA_PRODUCTO LISTA_CLI_PRODUCTO;
DET_CLI_PRODUCTO CLI_PRODUCTO;
LIST_REGISTRO TAB_ARRAY;
COL_REGISTRO TAB_ARRAY;
I NUMBER;
J NUMBER;
SEQ NUMBER;
BEGIN

--identificador del registro-----
    SELECT PCLUB.ADMPT_PREMODIF_CLIENTE_SQ.nextval INTO SEQ FROM DUAL;
---------------------------------

K_LISTA_PRODUCTO := LISTA_CLI_PRODUCTO();
DET_CLI_PRODUCTO := CLI_PRODUCTO(NULL,NULL);
LIST_REGISTRO:=SPLITCAD(K_COD_CLIPROD,'*');
K_LISTA_PRODUCTO.EXTEND(LIST_REGISTRO.COUNT);

FOR I IN 1..LIST_REGISTRO.COUNT
LOOP
    COL_REGISTRO:=SPLITCAD(LIST_REGISTRO(I),'|');
    FOR J IN 1..COL_REGISTRO.COUNT
    LOOP
        IF J = 1 THEN
            DET_CLI_PRODUCTO.COD_CLI_PROD:=COL_REGISTRO(J);
        ELSE
            DET_CLI_PRODUCTO.DESC_PRODUCTO:=COL_REGISTRO(J);
        END IF;
    END LOOP;

    K_LISTA_PRODUCTO(I):=DET_CLI_PRODUCTO;
END LOOP;

 IF K_FLAG = 'AN' THEN
    --Inserto en la tabla IMP
    INSERT INTO PCLUB.ADMPT_IMP_PREMODIF_CLIENTE
    (ADMPN_ID_FILA,
     ADMPV_FLAG,
     ADMPV_COD_TPOCL,
     ADMPV_COD_CLIPROD,
     ADMPV_TIPO_DOC,
     ADMPV_NUM_DOC,
     ADMPV_COD_ERROR,
     ADMPV_MSJE_ERROR,
     ADMPD_FCH_TRANS)
    VALUES( SEQ,
            K_FLAG,
            K_TIPCLIE,
            K_COD_CLIPROD,
            K_TIPODOC,
            K_NUMDOC,
            NULL,
            NULL,
            SYSDATE);
   ADMPSI_ALTACLIENTE(K_LISTA_PRODUCTO,K_TIPODOC,K_NUMDOC,K_NOMCLI,K_APECLI,K_SEX,K_EST_CIV,K_EMAIL,K_DEPT,K_PROV,K_DIST,K_CIC_FAC,K_TIPCLIE,
                             K_USUARIO, K_CODERROR,K_DESCERROR);

          UPDATE PCLUB.ADMPT_IMP_PREMODIF_CLIENTE
          SET ADMPV_COD_ERROR = K_CODERROR,
          ADMPV_MSJE_ERROR= K_DESCERROR
          WHERE ADMPN_ID_FILA =SEQ;

 ELSIF K_FLAG = 'BA' THEN
    --Inserto en la tabla IMP
    INSERT INTO PCLUB.ADMPT_IMP_PREMODIF_CLIENTE
     (ADMPN_ID_FILA,
     ADMPV_FLAG,
     ADMPV_COD_TPOCL,
     ADMPV_COD_CLIPROD,
     ADMPV_TIPO_DOC,
     ADMPV_NUM_DOC,
     ADMPV_COD_ERROR,
     ADMPV_MSJE_ERROR,
     ADMPD_FCH_TRANS)
    VALUES( SEQ,
            K_FLAG,
            K_TIPCLIE,
            K_COD_CLIPROD,
            K_TIPODOC,
            K_NUMDOC,
            NULL,
            NULL,
            SYSDATE);

   ADMPSI_BAJACLICHFC(K_LISTA_PRODUCTO,K_TIPODOC,K_NUMDOC,K_USUARIO,K_CODERROR,K_DESCERROR);
--    IF K_CODERROR<>0 THEN
          UPDATE PCLUB.ADMPT_IMP_PREMODIF_CLIENTE
          SET ADMPV_COD_ERROR = K_CODERROR,
          ADMPV_MSJE_ERROR= K_DESCERROR
          WHERE ADMPN_ID_FILA =SEQ;
  --   END IF;
 ELSIF K_FLAG = 'ACP' OR K_FLAG = 'BCP' THEN
    --Inserto en la tabla IMP
    INSERT INTO PCLUB.ADMPT_IMP_PREMODIF_CLIENTE
    (ADMPN_ID_FILA,ADMPV_FLAG,ADMPV_COD_TPOCL,ADMPV_COD_CLIPROD,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_COD_ERROR,ADMPV_MSJE_ERROR,ADMPD_FCH_TRANS)
    VALUES( SEQ,
            K_FLAG,
            K_TIPCLIE,
            K_COD_CLIPROD,
            K_TIPODOC,
            K_NUMDOC,
            NULL,
            NULL,
            SYSDATE);

   ADMPSI_CAMBIOPLAN(K_LISTA_PRODUCTO,K_TIPODOC,K_NUMDOC,K_USUARIO,K_CODERROR,K_DESCERROR);
    ---IF K_CODERROR<>0 THEN
          UPDATE PCLUB.ADMPT_IMP_PREMODIF_CLIENTE
          SET ADMPV_COD_ERROR = K_CODERROR,
          ADMPV_MSJE_ERROR= K_DESCERROR
          WHERE ADMPN_ID_FILA =SEQ;
    -- END IF;
 ELSE
      K_CODERROR:=1;
      K_DESCERROR := 'La operacion a realizar no se encuentra mapeada';
 END IF;


EXCEPTION WHEN OTHERS THEN
      K_CODERROR:=1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_PREMODIF_CLIENTE;

PROCEDURE ADMPSI_ALTACLIENTE(K_COD_CLIPROD IN LISTA_CLI_PRODUCTO,K_TIPODOC IN VARCHAR2,K_NUMDOC IN VARCHAR2,K_NOMCLI IN VARCHAR2,K_APECLI IN VARCHAR2,K_SEX IN VARCHAR2,K_EST_CIV IN VARCHAR2,
                              K_EMAIL IN VARCHAR2,K_DEPT IN VARCHAR2,K_PROV IN VARCHAR2,K_DIST IN VARCHAR2,K_CIC_FAC IN VARCHAR2,K_TIPCLIE IN VARCHAR2,
                             K_USUARIO IN VARCHAR2, K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALTACLIC
  -- Propósito           :   Alta de Clientes
  -- Input               :  tipdoc_num_dom,nom,ape,sex,est_civ,email,prov,dep,dist,ciclo_fac,
  -- Output              :
  -- Fec Creación        :  18/04/2012
  -- Fec Actualización   :
    --Autor               :   Juan Carlos Gutiérrez Trujillo
  --****************************************************************

  EX_ERROR EXCEPTION;
  EX_SALDO EXCEPTION;
  V_REGCLI     NUMBER;
  C_CODCLI     VARCHAR2(40);

  COD_SALDO    VARCHAR2(40);
  V_IDSALDO    NUMBER;
  V_CLI_PRODUCTO CLI_PRODUCTO;

  NUM_REG    NUMBER;
  V_IND_COD VARCHAR2(2);
  K_TIPDOC VARCHAR2(20);

 /*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
/*CUPONERAVIRTUAL - JCGT FIN*/

BEGIN
  NUM_REG:=0;

  K_CODERROR  := 0;
  K_DESCERROR := '';


  -- Solo podemos validar si enviaron datos en codigo de cliente
  IF K_TIPODOC IS NULL THEN
    K_CODERROR  :=4;
    K_DESCERROR:='Ingrese el campo Tipo de Dcto., es un campo obligatorio';
    RAISE EX_ERROR;
  END IF;

  IF K_NUMDOC IS NULL THEN
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese el campo Nro. de Dcto., es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

  IF K_TIPCLIE IS NULL THEN
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese el campo Tipo de cliente, es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

  IF K_TIPCLIE = '7' THEN

        BEGIN
            SELECT ADMPV_COD_TPDOC INTO K_TIPDOC
            FROM PCLUB.ADMPT_TIPO_DOC D
            WHERE D.ADMPV_EQU_FIJA=K_TIPODOC;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            K_CODERROR  :=4;
            K_DESCERROR:='Ingrese un Tipo de documento válido';
            RAISE EX_ERROR;
        END;

  ELSE
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese un Tipo de cliente válido';
     RAISE EX_ERROR;
  END IF;

  IF K_COD_CLIPROD IS NULL  THEN
     K_CODERROR  :=27;
     K_DESCERROR:='';
     RAISE EX_ERROR;
  END IF;

--generamos el codigo unico que nos permitira identificar
  C_CODCLI:=K_TIPDOC||'.'||K_NUMDOC||'.'||K_TIPCLIE;

--validar si el cliente existe EN TABLA MAESTRA
  SELECT COUNT(*) INTO V_REGCLI
  FROM PCLUB.ADMPT_CLIENTEFIJA C
  WHERE C.ADMPV_COD_CLI=C_CODCLI
  AND C.ADMPC_ESTADO = 'A';

  IF V_REGCLI = 0 THEN

     INSERT INTO PCLUB.ADMPT_CLIENTEFIJA H
          (H.ADMPV_COD_CLI,
           H.ADMPV_COD_SEGCLI,
           H.ADMPN_COD_CATCLI,
           H.ADMPV_TIPO_DOC,
           H.ADMPV_NUM_DOC,
           H.ADMPV_NOM_CLI,
           H.ADMPV_APE_CLI,
           H.ADMPC_SEXO,
           H.ADMPV_EST_CIVIL,
           H.ADMPV_EMAIL,
           H.ADMPV_PROV,
           H.ADMPV_DEPA,
           H.ADMPV_DIST,
           H.ADMPD_FEC_ACTIV,
           --H.ADMPV_CICL_FACT,
           H.ADMPC_ESTADO,
           H.ADMPV_COD_TPOCL,
           H.ADMPD_FEC_REG,
           H.ADMPV_USU_REG)
        VALUES
          (C_CODCLI,
           NULL,
           2,
           K_TIPDOC,
           K_NUMDOC,
           K_NOMCLI,
           K_APECLI,
           K_SEX,
           K_EST_CIV,
           K_EMAIL,
           K_PROV,
           K_DEPT,
           K_DIST,
           SYSDATE,
           --K_CIC_FAC,
           'A',
           K_TIPCLIE,
           SYSDATE,
           K_USUARIO);   /*SE REGISTRA PARA DTH Y HFC*/

  ELSE
      SELECT COUNT(*) INTO V_REGCLI
      FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
      WHERE C.ADMPV_COD_CLI=C_CODCLI
      AND C.ADMPV_ESTADO_SERV = 'A';

      IF V_REGCLI=0 THEN
           UPDATE PCLUB.ADMPT_CLIENTEFIJA
           SET ADMPD_FEC_ACTIV=SYSDATE,
           ADMPD_FEC_MOD=SYSDATE,
           ADMPV_USU_MOD=K_USUARIO
           WHERE ADMPV_COD_CLI=C_CODCLI;
      END IF;

  END IF;

  IF K_TIPCLIE = '7' THEN
    FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
    LOOP

       V_CLI_PRODUCTO := K_COD_CLIPROD(I);

       SELECT COUNT(*) INTO V_REGCLI
       FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
       WHERE --C.ADMPV_COD_CLI=C_CODCLI AND
       C.ADMPV_COD_CLI_PROD=V_CLI_PRODUCTO.COD_CLI_PROD
       AND C.ADMPV_ESTADO_SERV='B';

       IF V_REGCLI = 0 THEN

           SELECT COUNT(*) INTO V_REGCLI
           FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
           WHERE --C.ADMPV_COD_CLI=C_CODCLI AND
           C.ADMPV_COD_CLI_PROD=V_CLI_PRODUCTO.COD_CLI_PROD
           AND C.ADMPV_ESTADO_SERV='A';

           IF V_REGCLI = 0 THEN

              SELECT SUBSTR(V_CLI_PRODUCTO.COD_CLI_PROD,LENGTH(V_CLI_PRODUCTO.COD_CLI_PROD),1) INTO V_IND_COD
                  FROM DUAL;

              INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H
                (H.ADMPV_COD_CLI_PROD,
                 H.ADMPV_COD_CLI,
                 H.ADMPV_SERVICIO,
                 H.ADMPV_ESTADO_SERV,
                 H.ADMPV_FEC_ULTANIV,
                 H.ADMPD_FEC_REG,
                 H.ADMPV_USU_REG,
                 H.ADMPV_INDICEGRUPO,
                 ADMPV_CICL_FACT )
              VALUES
                (V_CLI_PRODUCTO.COD_CLI_PROD,
                 C_CODCLI,
                 V_CLI_PRODUCTO.DESC_PRODUCTO,
                 'A',
                 SYSDATE,
                 SYSDATE,
                 K_USUARIO,
                 V_IND_COD,
                 K_CIC_FAC);

                -- Debemos verificar si el cliente tiene algun saldo asociado
              BEGIN
                SELECT G.ADMPV_COD_CLI_PROD INTO COD_SALDO
                  FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA G      /*CAMBIAR ESTA TABLA*/
                 WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;---C_CODCLI;

                 K_CODERROR  :=5;
                 K_DESCERROR := 'El cliente tiene registrado saldos en el servicio: ' || COD_SALDO;
                 RAISE EX_SALDO;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN

                   /**Generar secuencial de Saldo*/
                  SELECT PCLUB.ADMPT_SLD_CLFIJA_SQ.NEXTVAL INTO V_IDSALDO FROM DUAL;

                  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA        /*CAMBIAR ESTA TABLA*/
                    (ADMPN_ID_SALDO,
                     ADMPV_COD_CLI_PROD,
                     ADMPN_COD_CLI_IB,
                     ADMPN_SALDO_CC,
                     ADMPN_SALDO_IB,
                     ADMPC_ESTPTO_CC,
                     ADMPC_ESTPTO_IB,
                     ADMPD_FEC_REG,
                     ADMPV_USU_REG)
                  VALUES
                    (V_IDSALDO, V_CLI_PRODUCTO.COD_CLI_PROD, NULL, 0.00, 0.00, 'A', NULL,SYSDATE,K_USUARIO);

                   NUM_REG:=NUM_REG+1;

                 WHEN EX_SALDO THEN
                    RAISE EX_ERROR;
              END;

           END IF;

       ELSE
             K_CODERROR  :=7;
             K_DESCERROR :=  COD_SALDO;
             RAISE EX_ERROR;

       END IF;

    END LOOP;

     IF NUM_REG=0 THEN
        K_CODERROR  :=8;
        --K_DESCERROR := 'Los servicios asociados al cliente ya se encuentran registrados ';
        RAISE EX_ERROR;
    END IF;

  END IF;

  /*CUPONERAVIRTUAL - JCGT INI*/
  PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(K_TIPDOC,K_NUMDOC,K_NOMCLI,K_APECLI,K_EMAIL,'ALTA',K_USUARIO,C_CODERROR,C_DESCERROR);
  /*CUPONERAVIRTUAL - JCGT FIN*/

 K_DESCERROR := 'Se ha registrado ' || NUM_REG || ' servicio(s)';
 --COMMIT; JCGT 22082012

--MANEJO DE ERRORES
    BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='';
    END;

EXCEPTION
  WHEN EX_ERROR THEN
    --ROLLBACK; JCGT 22082012
    BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
    END;

  WHEN OTHERS THEN
    --ROLLBACK; JCGT 22082012
    K_CODERROR:=1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALTACLIENTE;

PROCEDURE ADMPSI_BAJACLICHFC(K_COD_CLIPROD IN LISTA_CLI_PRODUCTO,K_TIPDOC IN VARCHAR2,K_NUMDOC IN VARCHAR2,K_USUARIO IN VARCHAR2, K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_BAJACLICHFC
-- Propósito           :    Actualizar los saldos de los clientes que se dieron de baja
-- Input               :      K_FECHAPROCESO
-- Output              :    K_CODERROR Codigo de Error o Exito
--                              K_DESCERROR Descripcion del Error (si se presento)
  --Autor               :   Juan Carlos Gutiérrez Trujillo
--****************************************************************
EX_ERROR EXCEPTION;

C_COD_CLI VARCHAR2(40);
V_COD_CPTO VARCHAR2(2);
V_COD_CPTO2 VARCHAR2(2);
V_REGCLIENTE NUMBER;
V_REG NUMBER;
V_SALDO_CLI NUMBER;
V_COD_NUEVO  NUMBER;
V_COD_CLINUE VARCHAR2(40);
V_ESTADO   VARCHAR2(2);
V_CLIENTE_AUX VARCHAR2(40);
V_REGCLI NUMBER;

V_SALDO_CLI_S NUMBER;
V_CLI_PRODUCTO CLI_PRODUCTO;
V_ULT_CODSER NUMBER;
K_TIPODOC VARCHAR2(20);
V_IND_COD VARCHAR2(2);
/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  C_COD_CLICUP NUMBER;
/*CUPONERAVIRTUAL - JCGT FIN*/

BEGIN

  K_CODERROR  := 0;
  K_DESCERROR := '';

  IF K_TIPDOC IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR:='Ingrese el campo Tipo de Dcto., es un campo obligatorio';
      RAISE EX_ERROR;
  ELSE
         BEGIN
            SELECT ADMPV_COD_TPDOC INTO K_TIPODOC
            FROM PCLUB.ADMPT_TIPO_DOC D
            WHERE D.ADMPV_EQU_FIJA=K_TIPDOC;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            K_CODERROR  := 4;
            K_DESCERROR:='Ingrese un Tipo de documento válido';
            RAISE EX_ERROR;
        END;
  END IF;

  IF K_NUMDOC IS NULL THEN
     K_CODERROR  := 4;
     K_DESCERROR:='Ingrese el campo Nro. de Dcto., es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

   IF K_COD_CLIPROD IS NULL  THEN
     K_CODERROR  :=27;
     K_DESCERROR:='';
     RAISE EX_ERROR;
   END IF;
 -- validar si el cliente existe
   SELECT COUNT(0) INTO V_REGCLIENTE
   FROM PCLUB.ADMPT_CLIENTEFIJA C
   WHERE C.ADMPV_TIPO_DOC=K_TIPODOC
   AND C.ADMPV_NUM_DOC=K_NUMDOC
   AND C.ADMPV_COD_TPOCL='7'
   AND C.ADMPC_ESTADO = 'A';

  IF V_REGCLIENTE>0 THEN

     SELECT C.ADMPV_COD_CLI, C.ADMPC_ESTADO INTO C_COD_CLI, V_ESTADO
     FROM PCLUB.ADMPT_CLIENTEFIJA C
     WHERE C.ADMPV_TIPO_DOC=K_TIPODOC
     AND C.ADMPV_NUM_DOC=K_NUMDOC
     AND C.ADMPV_COD_TPOCL='7'
     AND C.ADMPC_ESTADO = 'A' ;

      /* IF V_ESTADO <> 'A' THEN
          K_DESCERROR:='El cliente no esta activo';
          RAISE EX_ERROR;
       END IF;*/

      SELECT COUNT(*) INTO V_REGCLIENTE
      FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
      WHERE C.ADMPV_COD_CLI=C_COD_CLI
      AND C.ADMPV_ESTADO_SERV='A';

      IF V_REGCLIENTE=0 THEN
          K_CODERROR  := 7;
          --K_DESCERROR:='El cliente no tiene servicios activos';
          RAISE EX_ERROR;
      END IF;

  ELSE
     K_CODERROR  := 6;
     --K_DESCERROR:='El cliente no existe o esta de BAJA';
     RAISE EX_ERROR;
  END IF;

  BEGIN
    --SE ALMACENA EL CODIGO DEL CONCEPTO 'BAJA CLIENTE PREPAGO'
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC='BAJA CLIENTE HFC';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
  END;

  BEGIN
    --SE ALMACENA EL CODIGO DEL CONCEPTO 'INGRESO POR BAJA CLIENTE PREPAGO'
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO2
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC = 'INGRESO POR BAJA CLIENTE HFC';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN V_COD_CPTO2:=NULL;
  END;

  V_ULT_CODSER := K_COD_CLIPROD.LAST;
  FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
  LOOP
       V_REGCLI :=0;
       V_SALDO_CLI := 0;
       V_SALDO_CLI_S := 0;
       V_CLI_PRODUCTO := K_COD_CLIPROD(I);

       SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.ADMPT_CLIENTEPRODUCTO B
       WHERE B.ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD
             AND B.ADMPV_ESTADO_SERV='A';

       --EXISTE EL CLIENTE
       IF (V_REGCLI>0) THEN
            --  Si el cliente tiene mas de un PRODUCTO(SERVICIO)  los puntos pasan a su otra cuenta ASOCIADA

            BEGIN
               V_CLIENTE_AUX := NULL;

                SELECT COD_CLI INTO V_CLIENTE_AUX
                FROM (SELECT P.ADMPV_COD_CLI_PROD COD_CLI
                        FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
                       WHERE F.ADMPV_COD_CLI = C_COD_CLI AND
                             F.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
                             P.ADMPV_COD_CLI_PROD <> V_CLI_PRODUCTO.COD_CLI_PROD AND
                             P.ADMPV_SERVICIO = V_CLI_PRODUCTO.DESC_PRODUCTO AND
                             F.ADMPV_COD_TPOCL = '7' AND
                             F.ADMPC_ESTADO = 'A' AND
                             P.ADMPV_ESTADO_SERV = 'A'
                             ORDER BY P.ADMPD_FEC_REG)
                 WHERE ROWNUM=1;


            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                 BEGIN

                    SELECT SUBSTR(V_CLI_PRODUCTO.COD_CLI_PROD,LENGTH(V_CLI_PRODUCTO.COD_CLI_PROD),1) INTO V_IND_COD
                    FROM DUAL;

                    SELECT COD_CLI INTO V_CLIENTE_AUX
                    FROM (SELECT  P.ADMPV_COD_CLI_PROD COD_CLI
                            FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_TIPOSERV_DTH_HFC T
                           WHERE F.ADMPV_COD_CLI = C_COD_CLI AND
                                 F.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
                                 P.ADMPV_COD_CLI_PROD <> V_CLI_PRODUCTO.COD_CLI_PROD AND
                                 P.ADMPV_SERVICIO <> V_CLI_PRODUCTO.DESC_PRODUCTO AND
                                 --P.ADMPV_INDICEGRUPO <> V_IND_COD  AND
                                 F.ADMPV_COD_TPOCL = '7' AND
                                 F.ADMPC_ESTADO = 'A' AND
                                 P.ADMPV_ESTADO_SERV = 'A' AND
                                 P.ADMPV_SERVICIO = T.ADMPV_SERVICIO
                                 ORDER BY T.ADMPN_PRIORIDAD )
                     WHERE ROWNUM=1;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_CLIENTE_AUX := NULL;
                 END;
            END;

            --V_CLIENTE_AUX := NULL;/*AGREGADO JCGT PARA NO TRANSMITIR PUNTOS*/

            BEGIN
                V_SALDO_CLI := 0.00;
                SELECT ADMPN_SALDO_CC INTO V_SALDO_CLI
                  FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                 WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

            EXCEPTION
                  WHEN NO_DATA_FOUND THEN V_SALDO_CLI := 0.00;
            END;

            IF V_SALDO_CLI >= 0 THEN

                  --SE ACTUALIZA LA TABLA PCLUB.ADMPT_KARDEX
                  UPDATE PCLUB.ADMPT_KARDEXFIJA
                  SET ADMPN_SLD_PUNTO=0,
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPC_TPO_OPER='E'
                  AND ADMPC_TPO_PUNTO IN ('C','L')
                  AND ADMPN_SLD_PUNTO>0
                  AND ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                  --SE INSERTA EL REGISTRO DE SALIDA EN LA TABLA PCLUB.ADMPT_KARDEX
                  V_SALDO_CLI_S:=V_SALDO_CLI*(-1);

                  IF V_SALDO_CLI>0 THEN
                      INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS
                      ,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG)
                      VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,V_CLI_PRODUCTO.COD_CLI_PROD,V_COD_CPTO,SYSDATE,
                      V_SALDO_CLI_S,'S','C',0,'A',SYSDATE,K_USUARIO);
                  END IF;
                  --SE ACTUALIZA EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE AL CLIENTE QUE SE DA DE BAJA

                  UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                  SET ADMPN_SALDO_CC = 0,ADMPC_ESTPTO_CC='B',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPV_COD_CLI_PROD=V_CLI_PRODUCTO.COD_CLI_PROD;

                  UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
                  SET ADMPV_ESTADO_SERV='B',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;


                  IF V_CLIENTE_AUX IS NOT NULL THEN/*TRANSMITIR PUNTOS*/
                     --INSERTA EN EL KARDEX LOS PUNTOS AL CLIENTE DE TRASPASO

                     IF V_SALDO_CLI>0 THEN
                        INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,
                        ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
                        VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,V_CLIENTE_AUX, V_COD_CPTO2,SYSDATE,
                        V_SALDO_CLI,'E', 'C', V_SALDO_CLI, 'A',K_USUARIO,SYSDATE);
                      END IF;

                    --SE ACTUALIZA EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE DEL CLIENTE DE TRASPASO

                    UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                    SET ADMPN_SALDO_CC=V_SALDO_CLI + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                     FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                     WHERE ADMPV_COD_CLI_PROD = V_CLIENTE_AUX),
                        ADMPC_ESTPTO_CC='A',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                    WHERE ADMPV_COD_CLI_PROD=V_CLIENTE_AUX;

                  ELSE

                        IF I = V_ULT_CODSER THEN
                            V_COD_NUEVO  := 1;
                            V_COD_CLINUE := '';

                              WHILE V_COD_NUEVO > 0 LOOP
                                V_COD_CLINUE := TRIM(C_COD_CLI) || '-' || TO_CHAR(V_COD_NUEVO);

                                V_REG := 0;

                                BEGIN
                                  SELECT COUNT(*)
                                    INTO V_REG
                                    FROM PCLUB.ADMPT_CLIENTEFIJA
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


                              INSERT INTO PCLUB.ADMPT_CLIENTEFIJA(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,
                                                      ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                              SELECT V_COD_CLINUE,F.ADMPV_COD_SEGCLI,F.ADMPN_COD_CATCLI,F.ADMPV_TIPO_DOC,F.ADMPV_NUM_DOC,F.ADMPV_NOM_CLI,F.ADMPV_APE_CLI,F.ADMPC_SEXO,F.ADMPV_EST_CIVIL,
                                                      F.ADMPV_EMAIL,F.ADMPV_PROV,F.ADMPV_DEPA,F.ADMPV_DIST,F.ADMPD_FEC_ACTIV,F.ADMPC_ESTADO,F.ADMPV_COD_TPOCL,F.ADMPD_FEC_REG,F.ADMPV_USU_REG
                              FROM PCLUB.ADMPT_CLIENTEFIJA F
                              WHERE F.ADMPV_COD_CLI=C_COD_CLI;

                              UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
                              SET ADMPV_COD_CLI=V_COD_CLINUE,
                                    ADMPD_FEC_MOD=SYSDATE,
                                    ADMPV_USU_MOD=K_USUARIO
                              WHERE ADMPV_COD_CLI=C_COD_CLI;

                              UPDATE PCLUB.ADMPT_CANJEFIJA
                              SET ADMPV_COD_CLI=V_COD_CLINUE,
                                    ADMPD_FEC_MOD=SYSDATE,
                                    ADMPV_USU_MOD=K_USUARIO
                              WHERE ADMPV_COD_CLI=C_COD_CLI;

                              UPDATE PCLUB.ADMPT_CLIENTEFIJA
                              SET ADMPC_ESTADO='B',
                                    ADMPD_FEC_MOD=SYSDATE,
                                    ADMPV_USU_MOD=K_USUARIO
                              WHERE ADMPV_COD_CLI=V_COD_CLINUE;

                              DELETE PCLUB.ADMPT_CLIENTEFIJA
                              WHERE ADMPV_COD_CLI=C_COD_CLI;

                            /*CUPONERAVIRTUAL - JCGT INI*/
                              PKG_CC_CUPONERA.ADMPSI_BAJACLIENTE(K_TIPODOC,K_NUMDOC,'HFC',K_USUARIO,C_COD_CLICUP,C_CODERROR,C_DESCERROR);
                              /*CUPONERAVIRTUAL - JCGT FIN*/

                        END IF;
                  END IF;

            END IF;

       END IF;

  END LOOP;


  --COMMIT; JCGT 22082012

  BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
  END;

EXCEPTION
     WHEN EX_ERROR THEN
          --K_CODERROR:=1;
          --ROLLBACK; JCGT 22082012
          BEGIN
                SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                FROM PCLUB.ADMPT_ERRORES_CC
                WHERE ADMPN_COD_ERROR=K_CODERROR;
          EXCEPTION WHEN OTHERS THEN
                K_DESCERROR:='ERROR';
          END;
     WHEN OTHERS THEN
         --ROLLBACK; JCGT 22082012
         K_CODERROR:=1;
         K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_BAJACLICHFC;

PROCEDURE ADMPSI_PREVENCPTO( K_TIP_CLI IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREVENCPTO
  -- Propósito           :  Obtiene y cancela los movimientos de ingreso al Kardex de las cuentas prepago que ya tienen más de lo permitido y no fueron utilizados
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Juan Carlos Gutiérrez Trujillo
  -- Modificado por      :  Susana Ramos Gonzales
  -- Fec Creación        :  23/11/2010
  -- Modificado por      :  Carlos Carrillo O.
  -- Fec Creacion        :  19/04/2010
  -- Proposito           :  Vence puntos a partir de suma de meses
  --****************************************************************
  NO_CONCEPTO EXCEPTION;
  V_TPO_CPTO VARCHAR2(20);

  /*SELECCIONAR LOS CONCEPTOS QUE CUMPLEN CON LO REQUERIDO*/

   CURSOR C_CONCEPTO (TPO_CPTO varchar2) IS
    SELECT ADMPV_COD_CPTO, ADMPN_PER_CADU,ADMPC_TPO_PUNTO
    FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPN_PER_CADU >0 AND ADMPC_ESTADO='A' AND ADMPC_TPO_PUNTO IN ('C','L')
       AND ADMPV_TPO_CPTO=TPO_CPTO;

  C_CODCPTO VARCHAR2(4);
  C_PER_CADU NUMBER;
  C_TPO_PUNTO VARCHAR2(2);
  V_COD_CPTO VARCHAR2(2);
  V_FECHA DATE;
  V_COD_CLI VARCHAR2(40);
  V_TPO_PUNTO VARCHAR2(2);
  TOTALPTOS NUMBER;

  V_COD_CPTOHFC VARCHAR2(4);
  V_FECTRANS DATE;

  nKARDEX NUMBER;
  V_FECHA_0 DATE;
  dFECHA_REG_VEN DATE;
  nDIA INTEGER;

  CURSOR C_CLIENTE IS
  SELECT K.ADMPV_COD_CLI_PROD, SUM(K.ADMPN_SLD_PUNTO), K.ADMPC_TPO_PUNTO
  FROM PCLUB.ADMPT_KARDEXFIJA K, PCLUB.ADMPT_CLIENTEPRODUCTO C, PCLUB.ADMPT_CLIENTEFIJA F
  WHERE C.ADMPV_COD_CLI = F.ADMPV_COD_CLI
  AND C.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
  AND ( K.ADMPD_FEC_TRANS > V_FECHA_0 AND K.ADMPD_FEC_TRANS < V_FECHA )
  AND K.ADMPV_COD_CPTO=C_CODCPTO
  AND K.ADMPC_TPO_PUNTO = C_TPO_PUNTO
  AND K.ADMPN_SLD_PUNTO > 0
  AND K.ADMPC_TPO_OPER = 'E'
  AND F.ADMPV_COD_TPOCL= K_TIP_CLI  -- HFC
  AND F.ADMPC_ESTADO = 'A'
  GROUP BY K.ADMPV_COD_CLI_PROD,K.ADMPC_TPO_PUNTO;

  CURSOR C_CLIENTE_PROM IS
    SELECT K.ADMPV_COD_CLI_PROD, SUM(K.ADMPN_SLD_PUNTO), K.ADMPC_TPO_PUNTO, TRUNC(K.ADMPD_FEC_TRANS)
    FROM ADMPT_KARDEXFIJA K, ADMPT_CLIENTEPRODUCTO C, ADMPT_CLIENTEFIJA F
    WHERE C.ADMPV_COD_CLI = F.ADMPV_COD_CLI
    AND C.ADMPV_COD_CLI_PROD = K.ADMPV_COD_CLI_PROD
    AND K.ADMPV_COD_CPTO = C_CODCPTO    
    AND K.ADMPC_TPO_PUNTO = C_TPO_PUNTO
    AND K.ADMPN_SLD_PUNTO > 0
    AND K.ADMPC_TPO_OPER = 'E'
    AND F.ADMPV_COD_TPOCL = K_TIP_CLI
    AND F.ADMPC_ESTADO = 'A'
    GROUP BY K.ADMPV_COD_CLI_PROD,K.ADMPC_TPO_PUNTO,K.ADMPD_FEC_TRANS;

BEGIN
  
  nDIA := TO_NUMBER(TO_CHAR(SYSDATE,'DD'));
  IF nDIA <= 5 THEN
    dFECHA_REG_VEN := TRUNC(LAST_DAY(ADD_MONTHS(SYSDATE, -1)));
  ELSE
    dFECHA_REG_VEN := TRUNC(LAST_DAY(SYSDATE));
  END IF;
  
  K_CODERROR:=0;
  K_DESCERROR:=' ';

    BEGIN
       IF  K_TIP_CLI='6' THEN
            V_TPO_CPTO :='DTH';
            SELECT ADMPV_COD_CPTO    INTO V_COD_CPTOHFC
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE ADMPV_DESC='VENCIMIENTO DE PUNTOS DTH';
        ELSIF K_TIP_CLI='7' THEN
            V_TPO_CPTO :='HFC';
            SELECT ADMPV_COD_CPTO    INTO V_COD_CPTOHFC
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE ADMPV_DESC = 'VENCIMIENTO DE PUNTOS HFC';
        ELSE
            K_CODERROR:=4;
            K_DESCERROR:='Ingrese un tipo de cliente válido.';
            RAISE NO_CONCEPTO;
        END IF ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
            V_COD_CPTOHFC:=NULL;
    END;

      IF V_COD_CPTOHFC IS NULL THEN
        IF  K_TIP_CLI='6' THEN
            K_CODERROR:=9;
            K_DESCERROR := 'Concepto = VENCIMIENTO DE PUNTO DTH.';
            RAISE NO_CONCEPTO;
        ELSIF K_TIP_CLI='7' THEN
            K_CODERROR:=9;
            K_DESCERROR := 'Concepto = VENCIMIENTO DE PUNTO HFC.';
            RAISE NO_CONCEPTO;
        END IF;
      END IF;

    V_COD_CPTO:=V_COD_CPTOHFC;

     OPEN C_CONCEPTO(V_TPO_CPTO);
     FETCH C_CONCEPTO INTO C_CODCPTO,C_PER_CADU,C_TPO_PUNTO;
     WHILE C_CONCEPTO%FOUND LOOP
            /*ALMACENAR FECHA LIMITE ADMITIDA*/
            V_FECHA_0 := TRUNC(ADD_MONTHS(dFECHA_REG_VEN, - C_PER_CADU), 'MM')+(1 / (24 * 60 * 60))-(2 / (24 * 60 * 60));
            V_FECHA := TRUNC(LAST_DAY(ADD_MONTHS(dFECHA_REG_VEN, -C_PER_CADU)))+(1-(1 / (24 * 60 * 60)));
            OPEN C_CLIENTE;
            LOOP
            FETCH C_CLIENTE INTO V_COD_CLI,TOTALPTOS,V_TPO_PUNTO;
            EXIT WHEN C_CLIENTE%NOTFOUND;

            SELECT PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL INTO nKARDEX FROM DUAL;


            /*INSERTAR EN EL KARDEX UN NUEVO REGISTRO CON EL CLIENTE ALMACENADO Y TOTAL DE PUNTOS VENCIDOS*/
              INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO
              ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO
              ,ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
              VALUES(nKARDEX,V_COD_CLI,V_COD_CPTO,dFECHA_REG_VEN,
              (-1*TOTALPTOS),'S','C',0,'V',K_USUARIO,SYSDATE);


            IF ((V_TPO_PUNTO = 'L') OR (V_TPO_PUNTO = 'C')) THEN
              /*ACTUALIZAR LOS SALDOS DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE*/
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
              SET ADMPN_SALDO_CC = (NVL(ADMPN_SALDO_CC,0) + (TOTALPTOS*(-1))),
                     ADMPV_USU_MOD=K_USUARIO,
                     ADMPD_FEC_MOD=SYSDATE
              WHERE ADMPV_COD_CLI_PROD = V_COD_CLI;

            END IF;

            /*ACTUALIZAR EN LA TABLA KARDEX A LOS CLIENTES DE LOS MOVIMIENTOS VENCIDOS*/
            UPDATE PCLUB.ADMPT_KARDEXFIJA
            SET ADMPN_SLD_PUNTO = 0, ADMPC_ESTADO = 'C',
                     ADMPV_USU_MOD=K_USUARIO,
                     ADMPD_FEC_MOD=SYSDATE,
                     ADMPD_FEC_VCMTO = SYSDATE,
                     ADMPN_ID_KRDX_VTO = nKARDEX,
                     ADMPN_ULTM_SLD_PTO = ADMPN_SLD_PUNTO
            WHERE ( ADMPD_FEC_TRANS > V_FECHA_0 AND ADMPD_FEC_TRANS < V_FECHA )
            AND ADMPV_COD_CPTO=C_CODCPTO
            AND ADMPV_COD_CLI_PROD=V_COD_CLI
            AND ADMPN_SLD_PUNTO>0
            AND ADMPC_TPO_OPER='E';

            END LOOP;
            CLOSE C_CLIENTE;
        FETCH C_CONCEPTO INTO C_CODCPTO,C_PER_CADU,C_TPO_PUNTO;
      END LOOP;
  CLOSE C_CONCEPTO;

  --COMMIT;

  
   V_COD_CPTOHFC := '';
   IF K_TIP_CLI='7' THEN
       V_TPO_CPTO :='HFC - PROMO';
       OPEN C_CONCEPTO(V_TPO_CPTO);
       FETCH C_CONCEPTO INTO C_CODCPTO,C_PER_CADU,C_TPO_PUNTO;
       WHILE C_CONCEPTO%FOUND LOOP
         
          BEGIN
            IF K_TIP_CLI='7' THEN            
              SELECT ADMPV_COD_CPTO INTO V_COD_CPTOHFC
              FROM ADMPT_CONCEPTO
              WHERE ADMPN_PER_CADU = C_PER_CADU AND ADMPV_TPO_CPTO='HFC - PROMO';
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                  V_COD_CPTOHFC:=NULL;
          END;
       
          IF V_COD_CPTOHFC IS NULL THEN       
              K_CODERROR:=9;
              K_DESCERROR := 'Concepto = VENCIMIENTO DE PUNTO HFC.';
              RAISE NO_CONCEPTO;
          END IF;
       
              OPEN C_CLIENTE_PROM;
              LOOP
              FETCH C_CLIENTE_PROM INTO V_COD_CLI,TOTALPTOS,V_TPO_PUNTO,V_FECTRANS;
              EXIT WHEN C_CLIENTE_PROM%NOTFOUND;                  

              SELECT PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL INTO nKARDEX FROM DUAL;

              ---ALMACENAR FECHA LIMITE ADMITIDA
              V_FECHA := TO_DATE(TO_CHAR(ADD_MONTHS(TRUNC(V_FECTRANS),+C_PER_CADU), 'dd/mm/yyyy'), 'dd/mm/yyyy');

              IF TO_DATE(SYSDATE,'dd/mm/yyyy') > TO_DATE(V_FECHA,'dd/mm/yyyy') THEN
              
                  ---INSERTAR EN EL KARDEX UN NUEVO REGISTRO CON EL CLIENTE ALMACENADO Y TOTAL DE PUNTOS VENCIDOS
                  INSERT INTO ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO
                    ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO
                    ,ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
                    VALUES(ADMPT_KARDEXFIJA_SQ.NEXTVAL,V_COD_CLI,V_COD_CPTO,dFECHA_REG_VEN,
                    (-1*TOTALPTOS),'S','C',0,'V',K_USUARIO,SYSDATE);
       
                    IF ((V_TPO_PUNTO = 'L') OR (V_TPO_PUNTO = 'C')) THEN
                      ---ACTUALIZAR LOS SALDOS DEL CLIENTE EN LA TABLA ADMPT_SALDOS_CLIENTE---
                      UPDATE ADMPT_SALDOS_CLIENTEFIJA
                      SET ADMPN_SALDO_CC = (NVL(ADMPN_SALDO_CC,0) + (TOTALPTOS*(-1))),
                             ADMPV_USU_MOD=K_USUARIO,
                             ADMPD_FEC_MOD=SYSDATE
                      WHERE ADMPV_COD_CLI_PROD = V_COD_CLI;
                    
                    END IF;

                    ---ACTUALIZAR EN LA TABLA KARDEX A LOS CLIENTES DE LOS MOVIMIENTOS VENCIDOS---
                    UPDATE ADMPT_KARDEXFIJA
                    SET ADMPN_SLD_PUNTO = 0, ADMPC_ESTADO = 'C',
                             ADMPV_USU_MOD=K_USUARIO,
                             ADMPD_FEC_MOD=SYSDATE,
                             ADMPD_FEC_VCMTO = SYSDATE,
                             ADMPN_ID_KRDX_VTO = nKARDEX,
                             ADMPN_ULTM_SLD_PTO = ADMPN_SLD_PUNTO
                    WHERE ADMPD_FEC_TRANS < V_FECHA
                    AND ADMPV_COD_CPTO=C_CODCPTO
                    AND ADMPV_COD_CLI_PROD=V_COD_CLI
                    AND ADMPN_SLD_PUNTO>0
                    AND ADMPC_TPO_OPER='E';
       
              END IF;
            
              END LOOP;
              CLOSE C_CLIENTE_PROM;
          FETCH C_CONCEPTO INTO C_CODCPTO,C_PER_CADU,C_TPO_PUNTO;
        END LOOP;
       CLOSE C_CONCEPTO;
         
   END IF;

   COMMIT;

   BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
   END;


EXCEPTION
    WHEN NO_CONCEPTO THEN
      --K_CODERROR  := 55;
      ROLLBACK;
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
      END;

    WHEN OTHERS THEN
      ROLLBACK;
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_PREVENCPTO;


PROCEDURE ADMPSI_FACTURAHFC(K_FECHA IN DATE,
                            K_USUARIO IN VARCHAR2,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2,
                            K_NUMREGTOT OUT NUMBER,
                            K_NUMREGPRO OUT NUMBER,
                            K_NUMREGERR OUT NUMBER) IS

--****************************************************************
-- Nombre SP           :  ADMPSI_FACTURAHFC
-- Propósito           :  Asigna puntos por los diferentes tipos de pagos del cliente.
-- Input               :  K_FECHA
-- Output              :  K_CODERROR  Codigo de Error
--                        K_DESCERROR Descripcion del Error
--                        K_NUMREGTOT Numero de Registros Totales
--                        K_NUMREGPRO Numero de Registros Procesados
--                        K_NUMREGERR Numero de Registros con Error
-- Fec Creación        :  25/06/2012
-- Autor   :                Juan Carlos Gutiérrez Trujillo
--****************************************************************


V_COD_CLI_PROD          VARCHAR2(40);
V_PERIODO               VARCHAR2(6);
V_DIAS_VENC             NUMBER;
V_MNT_CGOFIJ            NUMBER;

V_NUMDIAS               NUMBER;
V_TIPO_CLI              VARCHAR2 (2);
V_TIPO_PUNTO            CHAR(1);

V_PUNTOS_PPAGO_NORMALS  NUMBER;
V_PUNTOS_CFIJS          NUMBER;


-- Codigos de conceptos por pagos
V_CONCEP_PPAGO_N        NUMBER;
V_CONCEP_CFIJ           NUMBER;


-- Costo por punto
V_CTO_PPAGO         NUMBER;
V_CTO_CFIJ          NUMBER;

-- Puntos x concepto
V_PUNTOS_PPAGO_NORMAL   NUMBER;
V_PUNTOS_CFIJ           NUMBER;

V_COD_CATCLI            NUMBER;
V_COD_CLI_IB            VARCHAR2(40);
V_TOTAL_PUNTOS          NUMBER;
ORA_ERROR               VARCHAR2(205);
V_CONTADOR              NUMBER;
V_NOM_ARCH              VARCHAR2(150);
NRO_ERROR               NUMBER;
V_SEQ                   NUMBER;

ERROR_VALIDAR           EXCEPTION;
EX_ERROR                EXCEPTION;

-- Mod. 06_05_2013
V_IND_PROC_PPAGO        CHAR(1);
V_IND_PROC_CFIJO        CHAR(1);

CURSOR CUR_PAGOS IS
    SELECT ADMPV_COD_CLI_PROD, ADMPV_PERIODO,
           ADMPN_DIAS_VENC, ADMPN_MNT_CGOFIJ,
           ADMPV_NOM_ARCH,ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_PAGO_HFC
    WHERE (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ' )
          AND ADMPD_FEC_OPER=K_FECHA;

BEGIN

K_DESCERROR:='';
K_CODERROR := 0;
NRO_ERROR := 0;

IF K_FECHA IS NULL THEN
   K_DESCERROR:='Ingrese la fecha a procesar.';
   K_CODERROR := 4;
   RAISE EX_ERROR;
END IF;

   --CLIENTE NO EXISTE
   UPDATE PCLUB.ADMPT_TMP_PAGO_HFC TM
   SET ADMPC_COD_ERROR = 16,
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos'
   WHERE  NOT EXISTS (SELECT 1
                      FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
                      WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD )
          AND ADMPD_FEC_OPER=K_FECHA;

   --CLIENTE NO ES HFC
   UPDATE PCLUB.ADMPT_TMP_PAGO_HFC TM
   SET ADMPC_COD_ERROR = 17,
         ADMPV_MSJE_ERROR = 'El cliente no es HFC'
   WHERE  EXISTS (SELECT 1
                  FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
                  WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD
                        AND F.ADMPV_COD_CLI=C.ADMPV_COD_CLI
                        AND F.ADMPV_COD_TPOCL<>'7' )
         AND ADMPD_FEC_OPER=K_FECHA;

   --SERVICIO NO ESTA ACTIVO
   UPDATE PCLUB.ADMPT_TMP_PAGO_HFC TM
   SET ADMPC_COD_ERROR = 18,
       ADMPV_MSJE_ERROR = 'El SERVICIO no esta activo'
   WHERE EXISTS (SELECT 1
                 FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
                 WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD
                       AND F.ADMPV_COD_CLI=C.ADMPV_COD_CLI
                       AND (F.ADMPC_ESTADO='A'
                           AND C.ADMPV_ESTADO_SERV='B') )
         AND ADMPD_FEC_OPER=K_FECHA;

    --CLIENTE NO ESTA ACTIVO
   UPDATE PCLUB.ADMPT_TMP_PAGO_HFC TM
   SET ADMPC_COD_ERROR = 19,
       ADMPV_MSJE_ERROR = 'El cliente no esta activo'
   WHERE EXISTS (SELECT 1
                 FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
                 WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD
                       AND F.ADMPV_COD_CLI=C.ADMPV_COD_CLI
                       AND (F.ADMPC_ESTADO='B') )
         AND ADMPD_FEC_OPER=K_FECHA;

   --MONTOS INFERIORES A 0
   UPDATE PCLUB.ADMPT_TMP_PAGO_HFC TM
   SET ADMPC_COD_ERROR = 20,
       ADMPV_MSJE_ERROR = 'El monto es menor o igual a cero'
   WHERE EXISTS (SELECT 1
                 FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
                 WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD
                       AND F.ADMPV_COD_CLI=C.ADMPV_COD_CLI
                       AND (F.ADMPC_ESTADO='A'
                            AND C.ADMPV_ESTADO_SERV='A')
                 )
         AND ADMPD_FEC_OPER=K_FECHA
         AND TM.ADMPN_MNT_CGOFIJ<=0;

   BEGIN
     SELECT ADMPV_COD_CPTO, ADMPC_PROC INTO V_CONCEP_PPAGO_N, V_IND_PROC_PPAGO
     FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'PRONTO PAGO NORMAL HFC'; /* Concepto - pronto pago normal */

     SELECT ADMPV_COD_CPTO, ADMPC_PROC INTO V_CONCEP_CFIJ, V_IND_PROC_CFIJO
     FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'CARGO FIJO NORMAL HFC';  /* Concepto - cargo fijo */
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            K_DESCERROR:='"PRONTO PAGO NORMAL HFC" ó "CARGO FIJO NORMAL HFC"';
            K_CODERROR:=9;
            RAISE EX_ERROR;
   END;

    -- Obtenemos la cantidad de dias de pago anticipado para considerarlo como pronto pago
    SELECT TO_NUMBER(ADMPV_VALOR) INTO V_NUMDIAS
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'DIAS_VENCIMIENTO_PAGO_CC'; --UPPER(ADMPV_DESC)

  IF NRO_ERROR = 0 THEN

     OPEN CUR_PAGOS;
     FETCH CUR_PAGOS INTO V_COD_CLI_PROD, V_PERIODO, V_DIAS_VENC, V_MNT_CGOFIJ,V_NOM_ARCH,V_SEQ;

     WHILE CUR_PAGOS%FOUND
       LOOP
          BEGIN
             V_PUNTOS_PPAGO_NORMAL    := 0;
             V_PUNTOS_CFIJ            := 0;
             V_TOTAL_PUNTOS           := 0;

             SELECT COUNT(1) INTO V_CONTADOR
             FROM PCLUB.ADMPT_AUX_PAGO_HFC
             WHERE ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                   AND ADMPV_PERIODO=V_PERIODO
                   AND ADMPD_FEC_OPER=K_FECHA
                   AND ADMPV_NOM_ARCH=V_NOM_ARCH;

             IF V_CONTADOR=0 THEN

                V_COD_CLI_IB:=NULL;

                -- Busca la categoria del cliente
                SELECT F.ADMPN_COD_CATCLI, F.ADMPV_COD_TPOCL INTO V_COD_CATCLI, V_TIPO_CLI
                FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
                WHERE P.ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                      AND P.ADMPV_COD_CLI=F.ADMPV_COD_CLI;

                IF V_COD_CATCLI IS NULL THEN
                   V_COD_CATCLI := 2; -- Cliente Normal
                END IF;

                /* Costo de Puntos x categoria AÑADIR EN LA TABLA CAT_CLIENTE EL NUEVO CLIENTE HFC*/
                SELECT ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ  INTO V_CTO_PPAGO, V_CTO_CFIJ
                FROM PCLUB.ADMPT_CAT_CLIENTE
                WHERE ADMPN_COD_CATCLI = V_COD_CATCLI
                      AND ADMPV_COD_TPOCL = V_TIPO_CLI;

                -- Cálculo de puntos para Pronto Pago Normal, Pronto Pago Adicional, Cargo Fijo , Cargo Adicional
                V_PUNTOS_CFIJ:= TRUNC((V_MNT_CGOFIJ)/ V_CTO_CFIJ,0);

                -- Mod. 06_05_2013
                -- Validar si el concepto por pronto pago esta habilitado 1= habilitado 0=deshabilitado
                IF V_IND_PROC_PPAGO IS NOT NULL AND V_IND_PROC_PPAGO = '1' THEN

                  /*Pronto Pago normal*/
                  IF  V_DIAS_VENC >= V_NUMDIAS THEN
                      V_PUNTOS_PPAGO_NORMAL:=  TRUNC((V_MNT_CGOFIJ)/ V_CTO_PPAGO,0);

                      IF V_PUNTOS_PPAGO_NORMAL <> 0 THEN

                         IF V_PUNTOS_PPAGO_NORMAL > 0 THEN
                           V_TIPO_PUNTO := 'E';
                           V_PUNTOS_PPAGO_NORMALS := V_PUNTOS_PPAGO_NORMAL;
                           /*20110523*/
                           INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB,
                                                         ADMPV_COD_CLI_PROD, ADMPV_COD_CPTO,
                                                         ADMPD_FEC_TRANS, ADMPN_PUNTOS,
                                                         ADMPV_NOM_ARCH, ADMPC_TPO_OPER,
                                                         ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO,
                                                         ADMPC_ESTADO, ADMPD_FEC_REG,
                                                         ADMPV_USU_REG)
                           VALUES (ADMPT_KARDEXFIJA_SQ.NEXTVAL, V_COD_CLI_IB,
                                   V_COD_CLI_PROD, V_CONCEP_PPAGO_N,
                                   SYSDATE, V_PUNTOS_PPAGO_NORMAL,
                                   V_NOM_ARCH, V_TIPO_PUNTO,
                                   'C', V_PUNTOS_PPAGO_NORMALS,
                                   'A',SYSDATE,
                                   K_USUARIO);

                           --V_TOTAL_PUNTOS:= NVL (V_PUNTOS_PPAGO_NORMAL, 0) + NVL (V_PUNTOS_CFIJ, 0);

                           -- Actualizamos los saldos del cliente fijo
                           UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                           SET ADMPN_SALDO_CC = ADMPN_SALDO_CC + V_PUNTOS_PPAGO_NORMAL,--V_TOTAL_PUNTOS,
                               ADMPD_FEC_MOD = SYSDATE,
                               ADMPV_USU_MOD=K_USUARIO
                           WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD;

                           /* Actualiza el total de puntos (admpn_puntos) en ADMPT_tmp_pago_cc */
                           UPDATE PCLUB.ADMPT_TMP_PAGO_HFC
                           SET ADMPN_PUNTOS = (NVL(ADMPN_PUNTOS,0) + V_PUNTOS_PPAGO_NORMAL) --V_TOTAL_PUNTOS
                           WHERE ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                                 AND ADMPV_PERIODO=V_PERIODO
                                 AND ADMPD_FEC_OPER=K_FECHA;

                         ELSE
                           --V_TIPO_PUNTO := 'S';
                           V_PUNTOS_PPAGO_NORMALS:=0;
                           V_PUNTOS_PPAGO_NORMAL:= 0;
                         END IF;
                      END IF;

                  END IF;

                END IF; -- FIN IF V_IND_PROC_PPAGO IS NULL OR V_IND_PROC_PPAGO = '0'

                -- Validar si el concepto por cargo fijo esta habilitado 1= habilitado 0=deshabilitado
                IF V_IND_PROC_CFIJO IS NOT NULL AND V_IND_PROC_CFIJO = '1' THEN

                  IF V_PUNTOS_CFIJ <> 0 THEN

                     IF V_PUNTOS_CFIJ > 0 THEN
                       V_TIPO_PUNTO := 'E';
                       V_PUNTOS_CFIJS:= V_PUNTOS_CFIJ;

                       -- insertamos en la tabla kardex el movimiento de ingreso
                       INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB,
                                                     ADMPV_COD_CLI_PROD, ADMPV_COD_CPTO,
                                                     ADMPD_FEC_TRANS, ADMPN_PUNTOS,
                                                     ADMPV_NOM_ARCH, ADMPC_TPO_OPER,
                                                     ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO,
                                                     ADMPC_ESTADO,ADMPD_FEC_REG,
                                                     ADMPV_USU_REG)
                       VALUES (ADMPT_KARDEXFIJA_SQ.NEXTVAL, V_COD_CLI_IB,
                               V_COD_CLI_PROD, V_CONCEP_CFIJ,
                               SYSDATE, V_PUNTOS_CFIJ,
                               V_NOM_ARCH, V_TIPO_PUNTO,
                               'C', V_PUNTOS_CFIJS,
                               'A',SYSDATE,
                               K_USUARIO);

                       -- actualizamos los puntos del cliente fijo en sus saldos
                       UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                       SET ADMPN_SALDO_CC = ADMPN_SALDO_CC + V_PUNTOS_CFIJ,--V_TOTAL_PUNTOS,
                           ADMPD_FEC_MOD = SYSDATE,
                           ADMPV_USU_MOD=K_USUARIO
                       WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD;

                     ELSE
                         V_PUNTOS_CFIJS:= 0;
                         V_PUNTOS_CFIJ:= 0;
                     END IF;
                  END IF;

                END IF;
                -- Insertamos en la tabla temporal por si es necesario el reproceso
                INSERT INTO PCLUB.ADMPT_AUX_PAGO_HFC (ADMPV_COD_CLI_PROD, ADMPV_PERIODO,
                                                ADMPD_FEC_OPER, ADMPV_NOM_ARCH)
                VALUES (V_COD_CLI_PROD, V_PERIODO,
                        K_FECHA, V_NOM_ARCH);

             ELSE
                 UPDATE PCLUB.ADMPT_TMP_PAGO_HFC
                 SET  ADMPC_COD_ERROR = '101',
                      ADMPV_MSJE_ERROR = 'El servicio ya fue procesado'
                 WHERE ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                       AND ADMPV_PERIODO=V_PERIODO
                       AND ADMPN_SEQ=V_SEQ;
                --COMMIT;
             END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF V_COD_CATCLI IS NULL THEN

                  UPDATE PCLUB.ADMPT_TMP_PAGO_HFC
                  SET ADMPC_COD_ERROR = '21',
                      ADMPV_MSJE_ERROR = 'El cliente no se encuentra categorizado'
                  WHERE ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                        AND ADMPV_PERIODO=V_PERIODO
                        AND ADMPN_SEQ=V_SEQ;
                END IF;

                IF V_CTO_PPAGO IS NULL OR V_CTO_CFIJ IS NULL THEN

                   UPDATE PCLUB.ADMPT_TMP_PAGO_HFC
                   SET ADMPC_COD_ERROR = '23',
                       ADMPV_MSJE_ERROR = 'No se pudo obtener el costo de puntos por categoría'
                   WHERE ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                         AND ADMPV_PERIODO=V_PERIODO
                         AND ADMPN_SEQ=V_SEQ;
                END IF;

              WHEN OTHERS THEN
                ORA_ERROR:=SUBSTR(SQLERRM,1,250);
                 UPDATE PCLUB.ADMPT_TMP_PAGO_HFC
                    SET ADMPC_COD_ERROR = 'ORA',
                        ADMPV_MSJE_ERROR = ORA_ERROR
                    WHERE ADMPV_COD_CLI_PROD=V_COD_CLI_PROD
                          AND ADMPV_PERIODO=V_PERIODO
                          AND ADMPN_SEQ=V_SEQ;
          END;
          FETCH CUR_PAGOS INTO V_COD_CLI_PROD, V_PERIODO, V_DIAS_VENC, V_MNT_CGOFIJ,V_NOM_ARCH,V_SEQ;
      END LOOP;

  -- Exportar datos a la tabla ADMPT_imp_pago_cc
    INSERT INTO PCLUB.ADMPT_IMP_PAGO_HFC
    SELECT  ADMPT_PAGOHFC_SQ.NEXTVAL , ADMPV_COD_CLI_PROD,
            ADMPV_PERIODO , ADMPN_DIAS_VENC,
            ADMPN_MNT_CGOFIJ, ADMPD_FEC_OPER,
            ADMPV_NOM_ARCH, ADMPN_PUNTOS,
            ADMPC_COD_ERROR, ADMPV_MSJE_ERROR,
            SYSDATE, ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_PAGO_HFC
    WHERE ADMPD_FEC_OPER=K_FECHA;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
    SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_PAGO_HFC WHERE ADMPD_FEC_OPER=K_FECHA;
    SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_PAGO_HFC WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPC_COD_ERROR IS NOT NULL);
    SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_PAGO_HFC WHERE ADMPD_FEC_OPER=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_PAGO_HFC WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_PAGO_HFC  WHERE ADMPD_FEC_OPER=K_FECHA;

   ELSE
     RAISE ERROR_VALIDAR;
   END IF;

   COMMIT;

   BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
   END;

EXCEPTION
  WHEN EX_ERROR THEN
      ROLLBACK;
       BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
            K_DESCERROR:='ERROR';
       END;
  WHEN ERROR_VALIDAR THEN
      K_CODERROR := -1;
      K_DESCERROR:='No se procesó el archivo porque encontró error en la validación: ORA-'||NRO_ERROR ;
  WHEN OTHERS THEN
      ROLLBACK;
      K_CODERROR:=1;
      K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_FACTURAHFC;

PROCEDURE ADMPSI_EFACTURAHFC(K_FECHA IN DATE,CURSORPAGO OUT SYS_REFCURSOR) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_EFACTURAHFC
-- Propósito           :  Lista clientes que cumplen un año en claro clun
-- Input               :  K_FECHA
-- Output              :  K_CODERROR  Codigo de Error
--                        K_DESCERROR Descripcion del Error
--                        K_NUMREGTOT Numero de Registros Totales
--                        K_NUMREGPRO Numero de Registros Procesados
--                        K_NUMREGERR Numero de Registros con Error
-- Fec Creación        :  25/09/2010
-- Autor   :                Juan Carlos Gutiérrez Trujillo
--****************************************************************
BEGIN

OPEN CURSORPAGO FOR
    SELECT  ADMPV_COD_CLI_PROD, ADMPV_PERIODO , ADMPN_DIAS_VENC, ADMPN_MNT_CGOFIJ,
            ADMPC_COD_ERROR, ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_IMP_PAGO_HFC I
    WHERE ADMPD_FEC_OPER=K_FECHA
    AND I.ADMPC_COD_ERROR IS NOT NULL
    OR TRIM(I.ADMPV_MSJE_ERROR) <> '' ;


END ADMPSI_EFACTURAHFC;

PROCEDURE ADMPSI_CAMBIOPLAN(K_COD_CLIPROD IN  LISTA_CLI_PRODUCTO,K_TIPO_DOC IN VARCHAR2,K_NUM_DOC IN VARCHAR2,K_USUARIO IN VARCHAR2,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS


  V_CLI_PRODUCTO CLI_PRODUCTO;
  V_COD_CLI VARCHAR2(40);
  V_REG_SALDO NUMBER;
  V_ESTADO VARCHAR2(2);
  V_SERVICIO VARCHAR2(5);
  V_IND_COD VARCHAR2(2);
  V_COD_CPTO VARCHAR2(3);
  V_IDSALDO NUMBER;
  V_REGCLI NUMBER;
  V_SALDO_CLI NUMBER;
  V_SALDO_CLI_S NUMBER;
  V_CLIENTE_AUX VARCHAR2(40);
  K_TIP_DOC VARCHAR2(40);
  V_CIC_FAC VARCHAR2(2);
  EX_ERROR EXCEPTION;
BEGIN
    K_CODERROR := 0;
    K_DESCERROR:='';

    IF K_TIPO_DOC IS NULL THEN
       K_CODERROR := 4;
       K_DESCERROR:='Ingrese un Tipo de documento válido';
       RAISE EX_ERROR;
    END IF;

    IF K_NUM_DOC IS NULL THEN
       K_CODERROR := 4;
       K_DESCERROR:='Ingrese un Nro. de documento válido';
       RAISE EX_ERROR;
    END IF;

    IF K_COD_CLIPROD IS NULL  THEN
       K_CODERROR  :=27;
       K_DESCERROR:='';
       RAISE EX_ERROR;
    END IF;

      BEGIN
            SELECT ADMPV_COD_TPDOC INTO K_TIP_DOC
            FROM PCLUB.ADMPT_TIPO_DOC D
            WHERE D.ADMPV_EQU_FIJA=K_TIPO_DOC;

      EXCEPTION WHEN NO_DATA_FOUND THEN
            K_CODERROR := 4;
            K_DESCERROR:='Ingrese un Tipo de documento válido';
            RAISE EX_ERROR;
      END;

    BEGIN
        --SE ALMACENA EL CODIGO DEL CONCEPTO 'INGRESO POR BAJA CLIENTE PREPAGO'
        SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
        WHERE ADMPV_DESC = 'CAMBIO PLAN HFC';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
    END;

    BEGIN
            SELECT F.ADMPV_COD_CLI INTO V_COD_CLI
            FROM PCLUB.ADMPT_CLIENTEFIJA F
            WHERE F.ADMPV_COD_TPOCL = '7'
            AND F.ADMPV_TIPO_DOC = K_TIP_DOC
            AND F.ADMPV_NUM_DOC = K_NUM_DOC
            AND  F.ADMPC_ESTADO = 'A';

    EXCEPTION WHEN NO_DATA_FOUND
        THEN
                K_CODERROR := 6;
                RAISE EX_ERROR;
    END;

    FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
    LOOP
        V_CLI_PRODUCTO := K_COD_CLIPROD(I);
         IF V_CLI_PRODUCTO.DESC_PRODUCTO <> 'A' AND V_CLI_PRODUCTO.DESC_PRODUCTO <> 'B'  THEN
            K_CODERROR := 4;
            K_DESCERROR := 'No esta mapeada la operacion para el servicio '|| V_CLI_PRODUCTO.COD_CLI_PROD;
            RAISE EX_ERROR;
         END IF;
    END LOOP;


    --dar de altas a servicios
    FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
    LOOP

         V_CLI_PRODUCTO := K_COD_CLIPROD(I);
         IF V_CLI_PRODUCTO.DESC_PRODUCTO = 'A' THEN

            BEGIN
                SELECT P.ADMPV_ESTADO_SERV INTO V_ESTADO
                FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
                WHERE F.ADMPV_COD_CLI = P.ADMPV_COD_CLI
                AND F.ADMPV_COD_CLI = V_COD_CLI
                AND P.ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD
                AND F.ADMPC_ESTADO = 'A';

                IF V_ESTADO = 'A' THEN
                    K_CODERROR := 8;
                    K_DESCERROR := V_CLI_PRODUCTO.COD_CLI_PROD;
                    RAISE EX_ERROR;

                ELSIF V_ESTADO = 'B' THEN

                    UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
                    SET  ADMPV_ESTADO_SERV = 'A',
                          ADMPD_FEC_MOD = SYSDATE,
                          ADMPV_USU_MOD = K_USUARIO
                    WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                END IF;

            EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                 SELECT SUBSTR(V_CLI_PRODUCTO.COD_CLI_PROD,LENGTH(V_CLI_PRODUCTO.COD_CLI_PROD),1) INTO V_IND_COD
                      FROM DUAL;

                  SELECT SUBSTR(V_CLI_PRODUCTO.COD_CLI_PROD,INSTR(V_CLI_PRODUCTO.COD_CLI_PROD,'_')+1,4) INTO V_SERVICIO
                      FROM DUAL;

                  SELECT NVL(MAX(P.ADMPV_CICL_FACT),'') INTO V_CIC_FAC
                    FROM PCLUB.ADMPT_CLIENTEPRODUCTO P
                    WHERE P.ADMPV_COD_CLI=ADMPV_COD_CLI
                    AND P.ADMPV_INDICEGRUPO=V_IND_COD;

                  INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H
                    (H.ADMPV_COD_CLI_PROD,
                     H.ADMPV_COD_CLI,
                     H.ADMPV_SERVICIO,
                     H.ADMPV_ESTADO_SERV,
                     H.ADMPV_FEC_ULTANIV,
                     H.ADMPD_FEC_REG,
                     H.ADMPV_USU_REG,
                     H.ADMPV_INDICEGRUPO,
                     H.ADMPV_CICL_FACT )
                  VALUES
                    (V_CLI_PRODUCTO.COD_CLI_PROD,
                     V_COD_CLI,
                     V_SERVICIO,
                     'A',
                     SYSDATE,
                     SYSDATE,
                     K_USUARIO,
                     V_IND_COD,
                     V_CIC_FAC);

                    -- Debemos verificar si el cliente tiene algun saldo asociado
                    SELECT COUNT(G.ADMPV_COD_CLI_PROD) INTO V_REG_SALDO
                      FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA G
                     WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                    IF V_REG_SALDO > 0 THEN
                         K_CODERROR := 5;
                         K_DESCERROR := 'Se tiene registrado saldos en el servicio: ' || V_CLI_PRODUCTO.COD_CLI_PROD;
                         RAISE EX_ERROR;
                    END IF;

                       /**Generar secuencial de Saldo*/
                      SELECT PCLUB.ADMPT_SLD_CLFIJA_SQ.NEXTVAL INTO V_IDSALDO FROM DUAL;

                      INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                        (ADMPN_ID_SALDO,
                         ADMPV_COD_CLI_PROD,
                         ADMPN_COD_CLI_IB,
                         ADMPN_SALDO_CC,
                         ADMPN_SALDO_IB,
                         ADMPC_ESTPTO_CC,
                         ADMPC_ESTPTO_IB,
                         ADMPD_FEC_REG,
                         ADMPV_USU_REG)
                      VALUES
                        (V_IDSALDO, V_CLI_PRODUCTO.COD_CLI_PROD, NULL, 0.00, 0.00, 'A', NULL,SYSDATE,K_USUARIO);

            END;
         END IF;

    END LOOP;

    --dar de baja servicio y transferir puntos
    FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
    LOOP

           V_REGCLI := 0;
           V_SALDO_CLI := 0;
           V_SALDO_CLI_S := 0;
           V_CLI_PRODUCTO := K_COD_CLIPROD(I);

         IF V_CLI_PRODUCTO.DESC_PRODUCTO = 'B' THEN

               SELECT COUNT(1) INTO V_REGCLI
               FROM PCLUB.ADMPT_CLIENTEPRODUCTO B
               WHERE B.ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD
               AND B.ADMPV_ESTADO_SERV='A';

               --EXISTE EL CLIENTE
               IF (V_REGCLI>0) THEN
                    --  Si el cliente tiene mas de un PRODUCTO(SERVICIO)  los puntos pasan a su otra cuenta ASOCIADA
                    BEGIN
                        V_CLIENTE_AUX := NULL;

                        SELECT SUBSTR(V_CLI_PRODUCTO.COD_CLI_PROD,LENGTH(V_CLI_PRODUCTO.COD_CLI_PROD),1) INTO V_IND_COD
                        FROM DUAL;

                        SELECT COD_CLI_PROD INTO V_CLIENTE_AUX
                        FROM (SELECT  P.ADMPV_COD_CLI_PROD COD_CLI_PROD
                                FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_TIPOSERV_DTH_HFC T
                               WHERE F.ADMPV_COD_CLI = V_COD_CLI AND
                                     F.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
                                     P.ADMPV_COD_CLI_PROD <> V_CLI_PRODUCTO.COD_CLI_PROD AND
                                     P.ADMPV_INDICEGRUPO = V_IND_COD  AND
                                     F.ADMPV_COD_TPOCL = '7' AND
                                     F.ADMPC_ESTADO = 'A' AND
                                     P.ADMPV_ESTADO_SERV = 'A' AND
                                     P.ADMPV_SERVICIO = T.ADMPV_SERVICIO
                                     ORDER BY T.ADMPN_PRIORIDAD )
                         WHERE ROWNUM=1;

                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                           K_CODERROR :=11;
                           --K_DESCERROR := 'No hay registrado un cliente para transferir los puntos.';
                          RAISE EX_ERROR;
                    END;

                    BEGIN
                        V_SALDO_CLI := 0.00;
                        SELECT ADMPN_SALDO_CC INTO V_SALDO_CLI
                          FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                         WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN V_SALDO_CLI := 0.00;
                    END;

                    IF V_SALDO_CLI >= 0 THEN

                          --SE ACTUALIZA LA TABLA PCLUB.ADMPT_KARDEX
                          UPDATE PCLUB.ADMPT_KARDEXFIJA
                          SET ADMPN_SLD_PUNTO=0,
                                ADMPD_FEC_MOD=SYSDATE,
                                ADMPV_USU_MOD=K_USUARIO
                          WHERE ADMPC_TPO_OPER='E'
                          AND ADMPC_TPO_PUNTO IN ('C','L')
                          AND ADMPN_SLD_PUNTO>0
                          AND ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                          --SE INSERTA EL REGISTRO DE SALIDA EN LA TABLA PCLUB.ADMPT_KARDEX
                          V_SALDO_CLI_S:=V_SALDO_CLI*(-1);

                          IF V_SALDO_CLI>0 THEN
                              INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS
                              ,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG)
                              VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,V_CLI_PRODUCTO.COD_CLI_PROD,V_COD_CPTO,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
                              V_SALDO_CLI_S,'S','C',0,'A',SYSDATE,K_USUARIO);
                          END IF;
                          --SE ACTUALIZA EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE AL CLIENTE QUE SE DA DE BAJA

                          UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                          SET ADMPN_SALDO_CC = 0,ADMPC_ESTPTO_CC='B',
                                ADMPD_FEC_MOD=SYSDATE,
                                ADMPV_USU_MOD=K_USUARIO
                          WHERE ADMPV_COD_CLI_PROD=V_CLI_PRODUCTO.COD_CLI_PROD;

                          UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
                          SET ADMPV_ESTADO_SERV='B',
                                ADMPD_FEC_MOD=SYSDATE,
                                ADMPV_USU_MOD=K_USUARIO
                          WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                          IF V_CLIENTE_AUX IS NOT NULL THEN
                             --INSERTA EN EL KARDEX LOS PUNTOS AL CLIENTE DE TRASPASO
                             IF V_SALDO_CLI>0 THEN
                                INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,
                                ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
                                VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,V_CLIENTE_AUX, V_COD_CPTO,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
                                V_SALDO_CLI,'E', 'C', V_SALDO_CLI, 'A',K_USUARIO,SYSDATE);
                              END IF;

                            --SE ACTUALIZA EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE DEL CLIENTE DE TRASPASO
                            UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                            SET ADMPN_SALDO_CC=V_SALDO_CLI + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                             FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                             WHERE ADMPV_COD_CLI_PROD = V_CLIENTE_AUX),
                                ADMPC_ESTPTO_CC='A',
                                ADMPD_FEC_MOD=SYSDATE,
                                ADMPV_USU_MOD=K_USUARIO
                            WHERE ADMPV_COD_CLI_PROD=V_CLIENTE_AUX;

                          END IF;

                    END IF;

               END IF;
         END IF;
    END LOOP;

   --COMMIT;   JCGT 22082012
   BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
   END;

EXCEPTION
        WHEN EX_ERROR THEN
        --ROLLBACK; JCGT 22082012
        BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
        EXCEPTION WHEN OTHERS THEN
            K_DESCERROR:='ERROR';
        END;
        WHEN OTHERS THEN
           --ROLLBACK; JCGT 22082012
           K_CODERROR := 1;
           K_DESCERROR:= SUBSTR(SQLERRM,1,250);
END ADMPSI_CAMBIOPLAN;

PROCEDURE ADMPSI_VALIDARCLIENTE(K_TIPDOC IN VARCHAR2,K_NUMDOC IN VARCHAR2,K_TIPCLIE IN VARCHAR2,K_COD_CLI OUT VARCHAR2, K_MENSAJE OUT VARCHAR2,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS
    EX_ERROR EXCEPTION;
    V_DESCERROR VARCHAR2(500);
    V_CODERROR NUMBER;
    V_REG NUMBER;
BEGIN
    K_CODERROR:=0;
    K_DESCERROR:='El cliente se encuentra registrado en CLARO CLUB';

    IF K_TIPDOC IS NULL THEN
        K_CODERROR:=4;
        K_DESCERROR:='El tipo de documento no es válido';
        RAISE EX_ERROR;
    END IF;
    IF K_NUMDOC IS NULL THEN
        K_CODERROR:=4;
        K_DESCERROR:='El Nro. de documento no es válido';
        RAISE EX_ERROR;
    END IF;
    IF K_TIPCLIE IS NULL OR K_TIPCLIE<>'7' THEN
        K_CODERROR:=4;
        K_DESCERROR:='El tipo de cliente no es válido';
        RAISE EX_ERROR;
    END IF;

       SELECT COUNT(*) INTO V_REG
       FROM PCLUB.ADMPT_CLIENTEFIJA C
       WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
       AND C.ADMPV_NUM_DOC = K_NUMDOC
       AND C.ADMPV_COD_TPOCL = K_TIPCLIE;

     IF V_REG = 0 THEN
         PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGHFCPRESMSERROR',K_MENSAJE,V_CODERROR,V_DESCERROR);
         K_CODERROR:=6;
         K_DESCERROR:='';
     ELSE
        SELECT C.ADMPV_COD_CLI INTO K_COD_CLI
        FROM PCLUB.ADMPT_CLIENTEFIJA C
        WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
        AND C.ADMPV_NUM_DOC = K_NUMDOC
        AND C.ADMPV_COD_TPOCL = K_TIPCLIE;
     END IF;

     BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
     EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
     END;

EXCEPTION  WHEN EX_ERROR THEN
                PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGHFCERROR',K_MENSAJE,V_CODERROR,V_DESCERROR);
                BEGIN
                    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                    FROM PCLUB.ADMPT_ERRORES_CC
                    WHERE ADMPN_COD_ERROR=K_CODERROR;
                EXCEPTION WHEN OTHERS THEN
                    K_DESCERROR:='ERROR';
                END;
                 WHEN OTHERS THEN
                K_CODERROR:=1;
                K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSI_VALIDARCLIENTE;

/*SUSANA*/
   PROCEDURE ADMPSI_PROMDTH_HFC(K_TIP_CLI IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_FECHA   IN DATE,
                               K_NOM_ARCH IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_NUMREGTOT OUT NUMBER,
                               K_NUMREGPRO OUT NUMBER,
                               K_NUMREGERR OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_PREPROMOCION
  -- Propósito           :  Debe entregar los puntos por Promoción para los clientes indicados en el archivo
  -- Input               :  K_TIP_CLI - Tipo de Cliente
  --                        K_FECHA - Fecha de Proceso
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT - Numero Total de registros
  --                        K_NUMREGPRO - Numero de Registros Procesados
  --                        K_NUMREGERR - Numero de Registros con Error
  -- Creado por          :  Susana Ramos
  -- Fec Creación        :
  -- Fec Actualización   :  22/05/2012
  --****************************************************************
  NO_CONCEPTO      EXCEPTION;
  NO_PARAMETROS    EXCEPTION;
  V_COD_CPTO VARCHAR2(3);

  V_CODERROR     NUMBER;
  V_DESCERROR    VARCHAR2(400);

  CURSOR CURSOR_TMP_DTH_HFC_PROMO IS
    SELECT C.ADMPV_COD_CLI,C.ADMPV_NOM_PROMO,C.ADMPV_PERIODO,CEIL(C.ADMPN_PUNTOS),C.ADMPV_NOM_ARCH,C.ADMPD_FEC_OPER,
           C.ADMPV_COD_TPOCL,C.ADMPV_SERVICIO, C.ADMPN_PUNTOS, C.ADMPV_MESVENCI
      FROM PCLUB.ADMPT_TMP_PROM_DTH_HFC C
    WHERE C.ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(C.ADMPD_FEC_REG)=TRUNC(K_FECHA)
    AND C.ADMPV_NOM_ARCH=K_NOM_ARCH
      FOR UPDATE OF C.ADMPV_MSJE_ERROR;

  CURSOR CUR_PTOS_DSCTO(CODIGO_CLIENTE VARCHAR2,CODIGO_SERVICIO VARCHAR2 )       IS
    SELECT  A.ADMPV_COD_CLI_PROD CLIE,  E.ADMPN_SALDO_CC  PTOS
              FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
              INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
              INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
              INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA E ON (A.ADMPV_COD_CLI_PROD=E.ADMPV_COD_CLI_PROD)
     WHERE B.ADMPV_COD_CLI= CODIGO_CLIENTE AND B.ADMPC_ESTADO = 'A'    AND D.ADMPV_SERVICIO = CODIGO_SERVICIO AND
           B.ADMPV_COD_TPOCL = K_TIP_CLI   AND A.ADMPV_ESTADO_SERV='A' AND E.ADMPN_SALDO_CC >0
     ORDER BY  D.ADMPN_PRIORIDAD, A.ADMPD_FEC_REG,A.ADMPV_COD_CLI_PROD ASC;

  COD_CLI_PROD PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_COD_CLI_PROD%TYPE;
  COD_SERVI    PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_SERVICIO%TYPE;

  C_COD_CLI VARCHAR2(40);
  C_NOM_PROMO VARCHAR2(100);
  C_PERIODO VARCHAR2(6);
  C_PUNTOS      NUMBER;
  C_PTO_DSCTO    NUMBER;
  C_PTOS_EFEC   NUMBER;
  C_PTOS_ORI     NUMBER;
  C_NOM_ARCH VARCHAR2(100);
  C_FEC_OPER DATE;
  C_TIP_CLI   VARCHAR2(2);
  C_SERVICIO  VARCHAR2(20);
  V_ERROR VARCHAR2(400);
  V_COUNT NUMBER;
  V_COUNT2 NUMBER;
  V_COUNT3 NUMBER;
  V_PTOS_TOT NUMBER;
  V_COUNT_PTOS NUMBER;
  V_COUNT4 NUMBER;
  V_TPO_OPER VARCHAR2(2);
  V_SLD_PUNTO NUMBER;
  V_REGCLI NUMBER;
  EST_ERROR NUMBER;
  V_MESVENC NUMBER;
  V_IDKARDEX NUMBER;
  BEGIN

  K_CODERROR:=0;
  K_DESCERROR:=' ';

    IF K_TIP_CLI IS NULL OR K_USUARIO IS NULL OR  K_FECHA IS NULL THEN
       K_CODERROR:=4;

       IF K_TIP_CLI IS NULL THEN
          K_DESCERROR := 'Parametro = K_TIP_CLI';
       END IF ;

       IF K_USUARIO IS NULL THEN
          K_DESCERROR := K_DESCERROR  ||  ' Parametro = K_USUARIO';
       END IF ;

       IF K_FECHA IS NULL THEN
          K_DESCERROR := K_DESCERROR  ||  ' Parametro = K_FECHA';
       END IF ;
       RAISE NO_PARAMETROS;
    END IF;

    BEGIN
       IF  K_TIP_CLI='6' THEN
            SELECT ADMPV_COD_CPTO    INTO V_COD_CPTO
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE ADMPV_DESC='PROMOCION DTH';      
        END IF ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
    END;

  IF V_COD_CPTO IS NULL THEN
    IF  K_TIP_CLI='6' THEN
        K_CODERROR:=9;
        K_DESCERROR := 'Concepto = PROMOCION DTH';
        RAISE NO_CONCEPTO; 
    END IF;
  END IF;

  BEGIN
    OPEN CURSOR_TMP_DTH_HFC_PROMO;
    FETCH CURSOR_TMP_DTH_HFC_PROMO INTO C_COD_CLI,C_NOM_PROMO,C_PERIODO,C_PUNTOS,C_NOM_ARCH,C_FEC_OPER,C_TIP_CLI,C_SERVICIO,C_PTOS_ORI,V_MESVENC ;

    WHILE CURSOR_TMP_DTH_HFC_PROMO%FOUND LOOP
     EST_ERROR:=0;

     IF K_TIP_CLI='7' THEN     
        BEGIN
            SELECT CO.ADMPV_COD_CPTO INTO V_COD_CPTO 
            FROM PCLUB.ADMPT_CONCEPTO CO WHERE CO.ADMPN_PER_CADU = V_MESVENC;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
        END;
        IF V_COD_CPTO IS NULL THEN 
            K_CODERROR:=9;
            K_DESCERROR := 'Concepto = HFC - PROMO';            
            UPDATE ADMPT_TMP_PROM_DTH_HFC
            SET ADMPV_MSJE_ERROR = K_DESCERROR
            WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
        END IF;
     END IF; 


     IF V_COD_CPTO IS NOT NULL THEN

      IF (C_COD_CLI IS NULL) OR (REPLACE(C_COD_CLI, ' ', '') IS NULL) THEN
        EST_ERROR:=1;
        --MODIFICAR EL ERROR SI EL NUMERO TELEFONICO ESTA EN BLANCO O NULO A LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC
         V_ERROR := 'El Codigo de Cliente es un dato obligatorio.';
         UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC
           SET ADMPV_MSJE_ERROR = V_ERROR
         WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
      ELSE
        SELECT COUNT(*) INTO V_COUNT
        FROM PCLUB.ADMPT_CLIENTEFIJA
        WHERE ADMPV_COD_CLI = C_COD_CLI   AND ADMPV_COD_TPOCL= K_TIP_CLI;
         IF V_COUNT = 0 THEN
           EST_ERROR:=1;
           --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC SI CLIENTE NO EXISTE
           V_ERROR := 'Cliente No existe.';
           UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC
           SET ADMPV_MSJE_ERROR = V_ERROR
           WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
         ELSE
           SELECT COUNT(*) INTO V_COUNT2 FROM PCLUB.ADMPT_CLIENTEFIJA
             WHERE ADMPV_COD_CLI = C_COD_CLI AND ADMPV_COD_TPOCL= K_TIP_CLI AND ADMPC_ESTADO = 'B';
           IF V_COUNT2<>0 THEN
              EST_ERROR:=1;
              --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC SI CLIENTE ESTA EN ESTADO DE BAJA
              V_ERROR := 'Cliente se encuentra de Baja no se le entregará la Promoción.';
              UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC
               SET ADMPV_MSJE_ERROR = V_ERROR
              WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
           ELSE
               SELECT COUNT(*) INTO V_COUNT4 FROM PCLUB.ADMPT_TIPOSERV_DTH_HFC S
               WHERE S.ADMPV_COD_TPOCL = K_TIP_CLI AND S.ADMPV_SERVICIO=C_SERVICIO;

               IF V_COUNT4=0 THEN
                  EST_ERROR:=1;
                  --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL SERVICIO NO EXISTE
                  V_ERROR := 'El Servicio no Existe ';
                  UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC SET ADMPV_MSJE_ERROR = V_ERROR
                  WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
               ELSE
                  V_COUNT4:=0;
                  SELECT COUNT(*)INTO V_COUNT4 FROM PCLUB.ADMPT_CLIENTEPRODUCTO
                  WHERE ADMPV_COD_CLI=C_COD_CLI AND ADMPV_SERVICIO=C_SERVICIO ;

                   IF V_COUNT4=0 THEN
                     EST_ERROR:=1;
                     --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL CLIENTE NO CUENTA CON EL SERVICIO
                      V_ERROR := 'El Cliente no cuenta con este Servicio';
                      UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC SET ADMPV_MSJE_ERROR = V_ERROR
                      WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
                   ELSE
                       V_COUNT4:=0;
                       SELECT COUNT(*)INTO V_COUNT4 FROM PCLUB.ADMPT_CLIENTEPRODUCTO
                       WHERE ADMPV_COD_CLI=C_COD_CLI AND ADMPV_SERVICIO=C_SERVICIO AND ADMPV_ESTADO_SERV='A' ;

                       IF V_COUNT4=0 THEN
                         EST_ERROR:=1;
                         --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC EL SERVICIO DEL CLIENTE ESTA EN BAJA
                          V_ERROR := 'El Servicio esta en Baja';
                          UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC SET ADMPV_MSJE_ERROR = V_ERROR
                          WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
                       ELSE
                           IF C_PUNTOS=0 THEN
                             EST_ERROR:=1;
                             --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL PUNTOS ES 0
                              V_ERROR := 'El punto a Entregar debe ser Diferente de Cero';
                              UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC
                                SET ADMPV_MSJE_ERROR = V_ERROR
                             WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
                           ELSIF C_PUNTOS<1 THEN
                               EST_ERROR:=1;
                               --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL PUNTOS ES NEGATIVO
                                V_ERROR := 'El punto a Entregar No debe ser Negativo';
                                   UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC
                                      SET ADMPV_MSJE_ERROR = V_ERROR
                                   WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
                           END IF;
                       END IF;
                   END IF;
               END IF;
           END IF;
         END IF;
      END IF;

       IF EST_ERROR=0 THEN
         /* V_REGCLI:=0;
          SELECT COUNT(*) INTO V_REGCLI FROM PCLUB.ADMPT_AUX_PROM_DTH_HFC
          WHERE ADMPV_COD_CLI = C_COD_CLI    AND ADMPV_NOM_PROMO = C_NOM_PROMO   AND
                ADMPV_PERIODO   = C_PERIODO  AND ADMPN_PUNTOS    = C_PUNTOS      AND
                ADMPV_NOM_ARCH  = C_NOM_ARCH AND ADMPV_SERVICIO = C_SERVICIO ;
         */
          --   IF V_REGCLI=0 THEN
                IF C_PUNTOS<0 THEN
                   V_TPO_OPER:='S';
                   V_SLD_PUNTO:=0;
                ELSIF C_PUNTOS>0 THEN
                   V_TPO_OPER :='E';
                   V_SLD_PUNTO:=C_PUNTOS;
                END IF;

                  SELECT COUNT(*) INTO V_COUNT3 FROM  PCLUB.ADMPT_CLIENTEPRODUCTO
                  WHERE ADMPV_COD_CLI = C_COD_CLI AND   ADMPV_ESTADO_SERV='A';

                  IF V_COUNT3=0 THEN
                     EST_ERROR:=1;
                     --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC SI CLIENTE ESTA EN ESTADO DE BAJA
                      V_ERROR := 'El Cliente no Cuenta con ningun servicio Activo,no se le entregará la Promoción.';
                       UPDATE PCLUB.ADMPT_TMP_PROM_DTH_HFC
                          SET ADMPV_MSJE_ERROR = V_ERROR
                       WHERE CURRENT OF CURSOR_TMP_DTH_HFC_PROMO;
                  ELSE
                      BEGIN
                             IF C_PUNTOS >0 THEN
                                 --Segun la prioridad definida se entregara los puntos promocionales (en caso de que tenga mas de un servicio)
                                 SELECT CLIE, SERV  INTO COD_CLI_PROD, COD_SERVI
                                 FROM  (SELECT  A.ADMPV_COD_CLI_PROD CLIE, A.ADMPV_SERVICIO SERV
                                          FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
                                          INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
                                          INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
                                 WHERE B.ADMPV_COD_CLI= C_COD_CLI AND B.ADMPC_ESTADO = 'A'    AND D.ADMPV_SERVICIO = C_SERVICIO AND
                                       B.ADMPV_COD_TPOCL = K_TIP_CLI   AND A.ADMPV_ESTADO_SERV='A' AND ROWNUM=1
                                 ORDER BY  D.ADMPN_PRIORIDAD, A.ADMPD_FEC_REG,A.ADMPV_COD_CLI_PROD ASC)
                                 WHERE ROWNUM=1;
                                 ------------ACTUALIZAR EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                 SELECT  NVL(ADMPN_SALDO_CC,0) INTO V_SLD_PUNTO
                                        FROM  PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                 WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;
                                 -----------&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&-----------------------
                                 IF  V_SLD_PUNTO >= 0 THEN
                                     INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                      ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_DESC_PROM,ADMPV_USU_REG)
                                     VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,COD_CLI_PROD,V_COD_CPTO,SYSDATE, C_PUNTOS,C_NOM_ARCH,
                                            V_TPO_OPER,'C',C_PUNTOS,'A',C_NOM_PROMO, K_USUARIO);
                                     ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTEFIJA----------------------------------
                                     UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                     SET ADMPN_SALDO_CC = C_PUNTOS +  NVL(ADMPN_SALDO_CC,0),  ADMPC_ESTPTO_CC='A', ADMPV_USU_MOD = K_USUARIO
                                     WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;
                                 END IF;
                            ELSE
                               -----PUNTOS TOTAL
                                SELECT  SUM(E.ADMPN_SALDO_CC) INTO V_PTOS_TOT
                                FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
                                INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
                                INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
                                INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA E ON (A.ADMPV_COD_CLI_PROD=E.ADMPV_COD_CLI_PROD)
                                WHERE B.ADMPV_COD_CLI= C_COD_CLI AND B.ADMPC_ESTADO = 'A'    AND D.ADMPV_SERVICIO = C_SERVICIO AND
                                      B.ADMPV_COD_TPOCL = K_TIP_CLI   AND A.ADMPV_ESTADO_SERV='A' AND E.ADMPN_SALDO_CC >0;

                                      IF  C_PUNTOS*-1 > V_PTOS_TOT THEN
                                          C_PTOS_EFEC := V_PTOS_TOT;
                                      ELSE
                                          C_PTOS_EFEC := C_PUNTOS*-1;
                                      END IF;
                                   BEGIN
                                        V_COUNT_PTOS :=C_PTOS_EFEC;
                                         OPEN CUR_PTOS_DSCTO(C_COD_CLI,C_SERVICIO);
                                              FETCH CUR_PTOS_DSCTO INTO COD_CLI_PROD, C_PTO_DSCTO;
                                              WHILE CUR_PTOS_DSCTO%FOUND AND V_COUNT_PTOS > 0 LOOP
                                                IF C_PTO_DSCTO <= V_COUNT_PTOS THEN
                                                   --C_PUNTOS := V_SLD_PUNTO*-1;
                                                   ------------------------INSERTAR EN KARDEXFIJA---------------------------------------
                                                   INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                    ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_DESC_PROM, ADMPV_USU_REG)
                                                   VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,COD_CLI_PROD,V_COD_CPTO,SYSDATE, C_PTO_DSCTO*-1,C_NOM_ARCH,
                                                          V_TPO_OPER,'C',0,'A',C_NOM_PROMO, K_USUARIO);
                                                   ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTEFIJA----------------------------------
                                                   UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                      SET ADMPN_SALDO_CC = 0.00,  ADMPC_ESTPTO_CC='A', ADMPV_USU_MOD = K_USUARIO
                                                   WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;
                                                    V_COUNT_PTOS := V_COUNT_PTOS - C_PTO_DSCTO;
                                                ELSE
                                                   IF C_PTO_DSCTO >  V_COUNT_PTOS THEN
                                                     ------------------------INSERTAR EN KARDEXFIJA---------------------------------------
                                                     INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                      ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_DESC_PROM, ADMPV_USU_REG)
                                                     VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,COD_CLI_PROD,V_COD_CPTO,SYSDATE, V_COUNT_PTOS*-1,C_NOM_ARCH,
                                                            V_TPO_OPER,'C',0,'A',C_NOM_PROMO,K_USUARIO);
                                                     ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTEFIJA----------------------------------
                                                     UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                     SET ADMPN_SALDO_CC =  NVL(ADMPN_SALDO_CC,0) - V_COUNT_PTOS ,  ADMPC_ESTPTO_CC='A', ADMPV_USU_MOD = K_USUARIO
                                                     WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;
                                                     V_COUNT_PTOS := 0;
                                                   END IF;
                                                END IF;
                                              FETCH CUR_PTOS_DSCTO INTO COD_CLI_PROD, C_PTO_DSCTO;
                                              END LOOP;
                                         CLOSE CUR_PTOS_DSCTO;
                                   END;
                                     IF C_PTOS_EFEC>0 THEN
                                        ADMPSI_DESCPTOS_PROMO(C_PTOS_EFEC,C_SERVICIO,C_COD_CLI,K_USUARIO, V_CODERROR,V_DESCERROR);
                                     END IF;
                            END IF;
                             -------------INSERTAR EL REGISTRO CORRESPONDIENTE EN LA TABLA PCLUB.ADMPT_AUX_PROM_DTH_HFC
                             INSERT INTO PCLUB.ADMPT_AUX_PROM_DTH_HFC(ADMPV_COD_CLI,ADMPV_NOM_PROMO,ADMPV_PERIODO,ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPV_COD_TPOCL,ADMPV_SERVICIO,ADMPN_PTOS_ORI)
                             VALUES(C_COD_CLI,C_NOM_PROMO,C_PERIODO,C_PUNTOS,C_NOM_ARCH,K_TIP_CLI,C_SERVICIO,C_PTOS_ORI);
                      END;
                  END IF;
             --END IF;
             END IF;

       END IF;

        FETCH CURSOR_TMP_DTH_HFC_PROMO INTO C_COD_CLI,C_NOM_PROMO,C_PERIODO,C_PUNTOS,C_NOM_ARCH,C_FEC_OPER,C_TIP_CLI,C_SERVICIO,C_PTOS_ORI,V_MESVENC;
    END LOOP;
   CLOSE CURSOR_TMP_DTH_HFC_PROMO;
  COMMIT;  --PROBAR COMENTANDO ESTE TROZO DE CODIGO
  END;

  INSERT INTO PCLUB.ADMPT_IMP_PROM_DTH_HFC(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_NOM_PROMO,ADMPV_PERIODO,
                                 ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR,ADMPD_FEC_TRANS,ADMPV_COD_TPOCL,ADMPV_SERVICIO,ADMPN_PTOS_ORI,ADMPV_MESVENCI)
  SELECT PCLUB.ADMPT_IMP_PROM_DTH_HFC_SQ.NEXTVAL,T.ADMPV_COD_CLI,T.ADMPV_NOM_PROMO,T.ADMPV_PERIODO,
         CEIL(T.ADMPN_PUNTOS),T.ADMPV_NOM_ARCH,T.ADMPD_FEC_OPER,T.ADMPV_MSJE_ERROR,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'),
         T.ADMPV_COD_TPOCL,T.ADMPV_SERVICIO, T.ADMPN_PUNTOS, ADMPV_MESVENCI
  FROM PCLUB.ADMPT_TMP_PROM_DTH_HFC T
  WHERE  T.ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(T.ADMPD_FEC_REG)=TRUNC(K_FECHA) AND T.ADMPV_NOM_ARCH=K_NOM_ARCH;

 SELECT COUNT(*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_PROM_DTH_HFC WHERE ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(ADMPD_FEC_REG)=TRUNC(K_FECHA) AND ADMPV_NOM_ARCH=K_NOM_ARCH;--ADMPD_FEC_OPER=K_FECHA ;
 SELECT COUNT(*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_PROM_DTH_HFC WHERE ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(ADMPD_FEC_REG)=TRUNC(K_FECHA) AND ADMPV_NOM_ARCH=K_NOM_ARCH--ADMPD_FEC_OPER=K_FECHA
 AND(ADMPV_MSJE_ERROR IS NOT NULL);
 SELECT COUNT(*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_PROM_DTH_HFC WHERE ADMPV_COD_TPOCL = K_TIP_CLI;

 -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_TMP_PROM_DTH_HFC WHERE ADMPV_COD_TPOCL=K_TIP_CLI AND  TRUNC(ADMPD_FEC_REG)=TRUNC(K_FECHA); --ADMPD_FEC_OPER=TRUNC(K_FECHA);
   DELETE PCLUB.ADMPT_AUX_PROM_DTH_HFC WHERE ADMPV_COD_TPOCL=K_TIP_CLI;

  COMMIT;
/*  K_CODERROR:=0;
  K_DESCERROR:=' ';*/

   BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
   END;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
       ROLLBACK;
       BEGIN
         SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
         K_DESCERROR:='ERROR';
       END;
    WHEN NO_CONCEPTO THEN
       ROLLBACK;
       BEGIN
         SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
         K_DESCERROR:='ERROR';
       END;
    WHEN OTHERS THEN
     ROLLBACK;
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_PROMDTH_HFC;

PROCEDURE ADMPSI_EPROMDTH_HFC( K_TIP_CLI IN VARCHAR2,
                                        K_FECHA   IN DATE,
                                        K_CODERROR OUT NUMBER,
                                        K_DESCERROR OUT VARCHAR2,
                                        CURSORE_DTH_HFC_PROMO OUT SYS_REFCURSOR)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EPROMDTH_HFC
  -- Propósito           :  Devuelve en un cursor solo los puntos por Promoción que no pudieron ser agregadas por algún error controlado
  -- Input               :  K_TIP_CLI -  Tipo de Cliente a Procesar
  --                        K_FECHA - Fecha de Proceso
  -- Output              :  CURSORE_DTH_HFC_PROMO Cursor que Contiene Lista de Clientes con Registro de Puntos de Promocion que generaron Errores
  -- Creado por          :  Susana Ramos
  -- Fec Creación        :
  -- Fec Actualización   :  22/05/2012
  --****************************************************************
  NO_PARAMETROS EXCEPTION;
  BEGIN
    K_CODERROR        := 0;
    IF K_TIP_CLI IS NULL OR   K_FECHA IS NULL  THEN
        RAISE NO_PARAMETROS;
    END IF;

  OPEN CURSORE_DTH_HFC_PROMO FOR
  SELECT ADMPV_COD_CLI, ADMPV_NOM_PROMO, ADMPV_PERIODO, ADMPN_PUNTOS,ADMPV_NOM_ARCH, ADMPV_MSJE_ERROR
         FROM PCLUB.ADMPT_IMP_PROM_DTH_HFC
  WHERE  ADMPV_MSJE_ERROR IS NOT NULL  AND
         PCLUB.ADMPT_IMP_PROM_DTH_HFC.ADMPV_COD_TPOCL = K_TIP_CLI AND ADMPD_FEC_OPER=K_FECHA;
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      K_DESCERROR:='Ingresó datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_DESCERROR:=SUBSTR( SQLERRM ,1,250);
 END ADMPSI_EPROMDTH_HFC;

PROCEDURE ADMPSI_REGDTH_HFC(K_TIP_CLI IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_FECHA   IN DATE,
                             K_NOM_ARCH IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGPRO OUT NUMBER,
                             K_NUMREGERR OUT NUMBER)
  IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_REG_DTH_HFC
  -- Propósito           :  Debe entregar los puntos por Promoción para los clientes indicados en el archivo
  -- Input               :  K_TIP_CLI - Tipo de Cliente
  --                        K_FECHA - Fecha de Proceso
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT - Numero Total de registros
  --                        K_NUMREGPRO - Numero de Registros Procesados
  --                        K_NUMREGERR - Numero de Registros con Error
  -- Creado por          :  Susana Ramos
  -- Fec Creación        :
  -- Fec Actualización   :  22/05/2012
  --****************************************************************
  NO_CONCEPTO      EXCEPTION;
  NO_PARAMETROS    EXCEPTION;
  V_COD_CPTO VARCHAR2(3);

  V_CODERROR     NUMBER;
  V_DESCERROR    VARCHAR2(400);

  CURSOR CUR_REGULARIZA_PTOS IS
  SELECT A.ADMPV_COD_CLI,A.ADMPV_NOM_REGUL,A.ADMPV_PERIODO,CEIL(A.ADMPN_PUNTOS),A.ADMPV_NOM_ARCH,
         A.ADMPD_FEC_OPER,A.ADMPV_COD_TPOCL,A.ADMPV_SERVICIO,A.ADMPN_PUNTOS
  FROM PCLUB.ADMPT_TMP_REGDTH_HFC A
  WHERE A.ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(A.ADMPD_FEC_REG)=TRUNC(K_FECHA)
  AND A.ADMPV_NOM_ARCH=K_NOM_ARCH
        FOR UPDATE OF A.ADMPV_MSJE_ERROR;


CURSOR CUR_PTOS_DSCTO(CODIGO_CLIENTE VARCHAR2,CODIGO_SERVICIO VARCHAR2 )       IS
    SELECT  A.ADMPV_COD_CLI_PROD CLIE,  E.ADMPN_SALDO_CC  PTOS
              FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
              INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
              INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
              INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA E ON (A.ADMPV_COD_CLI_PROD=E.ADMPV_COD_CLI_PROD)
     WHERE B.ADMPV_COD_CLI= CODIGO_CLIENTE AND B.ADMPC_ESTADO = 'A'    AND D.ADMPV_SERVICIO = CODIGO_SERVICIO AND
           B.ADMPV_COD_TPOCL = K_TIP_CLI   AND A.ADMPV_ESTADO_SERV='A' AND E.ADMPN_SALDO_CC >0
     ORDER BY  D.ADMPN_PRIORIDAD, MIN(A.ADMPD_FEC_REG),A.ADMPV_COD_CLI_PROD ASC;

    COD_CLI_PROD PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_COD_CLI_PROD%TYPE;
    COD_SERVI    PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_SERVICIO%TYPE;

  C_COD_CLI VARCHAR2(40);
  C_NOM_REGUL VARCHAR2(100);
  C_PERIODO VARCHAR2(6);
  C_PUNTOS      NUMBER;
  C_PTOS_ORI     NUMBER;
  C_PTO_DSCTO    NUMBER;
  C_PTOS_EFEC   NUMBER;
  C_NOM_ARCH VARCHAR2(100);
  C_FEC_OPER DATE;
  C_TIP_CLI   VARCHAR2(2);
  C_SERVICIO  VARCHAR2(20);
  V_ERROR VARCHAR2(400);
  V_COUNT NUMBER;
  V_COUNT2 NUMBER;
  V_COUNT3 NUMBER;
  V_PTOS_TOT NUMBER;
  V_COUNT_PTOS NUMBER;
  V_COUNT4 NUMBER;
  V_TPO_OPER VARCHAR2(2);
  V_SLD_PUNTO NUMBER;
  V_REGCLI NUMBER;
  EST_ERROR NUMBER;
  BEGIN

  K_CODERROR:=0;
  K_DESCERROR:=' ';

    IF K_TIP_CLI IS NULL OR K_USUARIO IS NULL OR  K_FECHA IS NULL THEN
        RAISE NO_PARAMETROS;
    END IF;

    BEGIN
       IF  K_TIP_CLI='6' THEN
            SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_COD_CPTO
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE UPPER(ADMPV_DESC)='REGULARIZACION DTH';
        ELSIF K_TIP_CLI='7' THEN
            SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_COD_CPTO
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE UPPER(ADMPV_DESC)='REGULARIZACION HFC';
        END IF ;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
    END;

  IF V_COD_CPTO IS NULL THEN
        IF  K_TIP_CLI='6' THEN
        K_CODERROR:=9;
        K_DESCERROR := 'Concepto = REGULARIZACION DTH';
        RAISE NO_CONCEPTO;
    ELSIF K_TIP_CLI='7' THEN
        K_CODERROR:=9;
        K_DESCERROR := 'Concepto = REGULARIZACION HFC';
        RAISE NO_CONCEPTO;
    END IF;
  END IF;

  BEGIN
    OPEN CUR_REGULARIZA_PTOS;
    FETCH CUR_REGULARIZA_PTOS INTO C_COD_CLI,C_NOM_REGUL,C_PERIODO,C_PUNTOS,C_NOM_ARCH,C_FEC_OPER,C_TIP_CLI,C_SERVICIO,C_PTOS_ORI;
    WHILE CUR_REGULARIZA_PTOS%FOUND LOOP
     EST_ERROR:=0;

     IF (C_COD_CLI IS NULL) OR (REPLACE(C_COD_CLI, ' ', '') IS NULL) THEN
        EST_ERROR:=1;
        --MODIFICAR EL ERROR SI EL NUMERO TELEFONICO ESTA EN BLANCO O NULO A LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC
         V_ERROR := 'El Codigo de Cliente es un dato obligatorio.';
         UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC
           SET ADMPV_MSJE_ERROR = V_ERROR
         WHERE CURRENT OF CUR_REGULARIZA_PTOS;
      ELSE
         SELECT COUNT(*) INTO V_COUNT
         FROM PCLUB.ADMPT_CLIENTEFIJA
         WHERE ADMPV_COD_CLI = C_COD_CLI   AND ADMPV_COD_TPOCL= K_TIP_CLI;

         IF V_COUNT = 0 THEN
           EST_ERROR:=1;
           --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC SI CLIENTE NO EXISTE
           V_ERROR := 'Cliente No existe.';
           UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC
           SET ADMPV_MSJE_ERROR = V_ERROR
           WHERE CURRENT OF CUR_REGULARIZA_PTOS;

         ELSE
           SELECT COUNT(*) INTO V_COUNT2 FROM PCLUB.ADMPT_CLIENTEFIJA
             WHERE ADMPV_COD_CLI = C_COD_CLI AND ADMPV_COD_TPOCL= K_TIP_CLI AND ADMPC_ESTADO = 'B';

           IF V_COUNT2<>0 THEN
              EST_ERROR:=1;
              --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC SI CLIENTE ESTA EN ESTADO DE BAJA
              V_ERROR := 'Cliente se encuentra de Baja no se le entregará la Promoción.';
              UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC
               SET ADMPV_MSJE_ERROR = V_ERROR
              WHERE CURRENT OF CUR_REGULARIZA_PTOS;
           ELSE
                SELECT COUNT(*) INTO V_COUNT4 FROM PCLUB.ADMPT_TIPOSERV_DTH_HFC S
                WHERE S.ADMPV_COD_TPOCL = K_TIP_CLI AND S.ADMPV_SERVICIO=C_SERVICIO;
               IF V_COUNT4=0 THEN
                 EST_ERROR:=1;
                 --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL SERVICIO NO EXISTE
                  V_ERROR := 'El Servicio no Existe ';
                  UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC SET ADMPV_MSJE_ERROR = V_ERROR
                  WHERE CURRENT OF CUR_REGULARIZA_PTOS;
               ELSE
                 V_COUNT4:=0;
                 SELECT COUNT(*)INTO V_COUNT4 FROM PCLUB.ADMPT_CLIENTEPRODUCTO
                 WHERE ADMPV_COD_CLI=C_COD_CLI AND ADMPV_SERVICIO=C_SERVICIO ;

                   IF V_COUNT4=0 THEN
                     EST_ERROR:=1;
                     --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL CLIENTE NO CUENTA CON EL SERVICIO
                      V_ERROR := 'El Cliente no cuenta con este Servicio';
                      UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC SET ADMPV_MSJE_ERROR = V_ERROR
                      WHERE CURRENT OF CUR_REGULARIZA_PTOS;
                   ELSE
                       V_COUNT4:=0;
                       SELECT COUNT(*)INTO V_COUNT4 FROM PCLUB.ADMPT_CLIENTEPRODUCTO
                       WHERE ADMPV_COD_CLI=C_COD_CLI AND ADMPV_SERVICIO=C_SERVICIO AND ADMPV_ESTADO_SERV='A' ;

                       IF V_COUNT4=0 THEN
                         EST_ERROR:=1;
                         --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC EL SERVICIO DEL CLIENTE ESTA EN BAJA
                          V_ERROR := 'El Servicio esta en Baja';
                          UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC SET ADMPV_MSJE_ERROR = V_ERROR
                          WHERE CURRENT OF CUR_REGULARIZA_PTOS;
                       ELSE
                           IF C_PUNTOS=0 THEN
                             EST_ERROR:=1;
                             --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC CUANDO EL PUNTOS ES 0
                              V_ERROR := 'El punto a Entregar debe ser Diferente de Cero';
                              UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC
                                SET ADMPV_MSJE_ERROR = V_ERROR
                             WHERE CURRENT OF CUR_REGULARIZA_PTOS;
                           END IF;
                       END IF;
                   END IF;
               END IF;
           END IF;
         END IF;
      END IF;

       IF EST_ERROR=0 THEN

                IF C_PUNTOS<0 THEN
                   V_TPO_OPER:='S';
                   V_SLD_PUNTO:=0;
                ELSIF C_PUNTOS>0 THEN
                   V_TPO_OPER :='E';
                   V_SLD_PUNTO:=C_PUNTOS;
                END IF;

                  SELECT COUNT(*) INTO V_COUNT3 FROM  PCLUB.ADMPT_CLIENTEPRODUCTO
                  WHERE ADMPV_COD_CLI = C_COD_CLI AND   ADMPV_ESTADO_SERV='A';

                  IF V_COUNT3=0 THEN
                     EST_ERROR:=1;
                     --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROM_DTH_HFC SI CLIENTE ESTA EN ESTADO DE BAJA
                      V_ERROR := 'El Cliente no Cuenta con ningun servicio Activo,no se le entregará la Promoción.';
                       UPDATE PCLUB.ADMPT_TMP_REGDTH_HFC
                          SET ADMPV_MSJE_ERROR = V_ERROR
                       WHERE CURRENT OF CUR_REGULARIZA_PTOS;

                  ELSE
                      BEGIN
                          IF C_PUNTOS >0 THEN
                             --Segun la prioridad definida se entregara los puntos promocionales (en caso de que tenga mas de un servicio)
                             SELECT CLIE, SERV  INTO COD_CLI_PROD, COD_SERVI
                             FROM  (SELECT  A.ADMPV_COD_CLI_PROD CLIE, A.ADMPV_SERVICIO SERV
                                      FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
                                      INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
                                      INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
                             WHERE B.ADMPV_COD_CLI= C_COD_CLI AND B.ADMPC_ESTADO = 'A'    AND D.ADMPV_SERVICIO = C_SERVICIO AND
                                   B.ADMPV_COD_TPOCL = K_TIP_CLI   AND A.ADMPV_ESTADO_SERV='A'
                             ORDER BY  D.ADMPN_PRIORIDAD,A.ADMPD_FEC_REG,A.ADMPV_COD_CLI_PROD ASC)
                             WHERE ROWNUM=1;
                             ------------ACTUALIZAR EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                             SELECT  NVL(ADMPN_SALDO_CC,0) INTO V_SLD_PUNTO
                                    FROM  PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                             WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;

                             IF  V_SLD_PUNTO >= 0 THEN
                                  ------------------------INSERTAR EN KARDEXFIJA---------------------------------------
                                 INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                  ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_DESC_PROM,ADMPV_USU_REG)
                                 VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,COD_CLI_PROD,V_COD_CPTO,SYSDATE, C_PUNTOS,C_NOM_ARCH,
                                        V_TPO_OPER,'C',C_PUNTOS,'A',C_NOM_REGUL, K_USUARIO);
                                 ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTEFIJA----------------------------------
                                 UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                 SET ADMPN_SALDO_CC = C_PUNTOS +  NVL(ADMPN_SALDO_CC,0),  ADMPC_ESTPTO_CC='A', ADMPV_USU_MOD = K_USUARIO
                                  WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;
                            END IF;
                       ELSE
                            -----PUNTOS TOTAL
                                SELECT  SUM(E.ADMPN_SALDO_CC) INTO V_PTOS_TOT
                                FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
                                INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
                                INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
                                INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA E ON (A.ADMPV_COD_CLI_PROD=E.ADMPV_COD_CLI_PROD)
                                WHERE B.ADMPV_COD_CLI= C_COD_CLI AND B.ADMPC_ESTADO = 'A'    AND D.ADMPV_SERVICIO = C_SERVICIO AND
                                      B.ADMPV_COD_TPOCL = K_TIP_CLI   AND A.ADMPV_ESTADO_SERV='A' AND E.ADMPN_SALDO_CC >0;

                                      IF  C_PUNTOS*-1 > V_PTOS_TOT THEN
                                          C_PTOS_EFEC := V_PTOS_TOT;
                                      ELSE
                                          C_PTOS_EFEC := C_PUNTOS*-1;
                                      END IF;

                                      BEGIN
                                        V_COUNT_PTOS :=C_PTOS_EFEC;
                                         OPEN CUR_PTOS_DSCTO(C_COD_CLI,C_SERVICIO);
                                              FETCH CUR_PTOS_DSCTO INTO COD_CLI_PROD, C_PTO_DSCTO;
                                              WHILE CUR_PTOS_DSCTO%FOUND AND V_COUNT_PTOS > 0 LOOP
                                                IF C_PTO_DSCTO <= V_COUNT_PTOS THEN
                                                   --C_PUNTOS := V_SLD_PUNTO*-1;
                                                   ------------------------INSERTAR EN KARDEXFIJA---------------------------------------
                                                   INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                   ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_DESC_PROM, ADMPV_USU_REG)
                                                  VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,COD_CLI_PROD,V_COD_CPTO,SYSDATE, C_PTO_DSCTO*-1,C_NOM_ARCH,
                                                         V_TPO_OPER,'C',0,'A',C_NOM_REGUL, K_USUARIO);
                                                   ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTEFIJA----------------------------------
                                                   UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                      SET ADMPN_SALDO_CC = 0.00,  ADMPC_ESTPTO_CC='A', ADMPV_USU_MOD = K_USUARIO
                                                   WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;

                                                    V_COUNT_PTOS := V_COUNT_PTOS - C_PTO_DSCTO;
                                                ELSE
                                                   IF C_PTO_DSCTO >  V_COUNT_PTOS THEN
                                                     ------------------------INSERTAR EN KARDEXFIJA---------------------------------------
                                                     INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                      ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_DESC_PROM, ADMPV_USU_REG)
                                                     VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,COD_CLI_PROD,V_COD_CPTO,SYSDATE, V_COUNT_PTOS*-1,C_NOM_ARCH,
                                                            V_TPO_OPER,'C',0,'A',C_NOM_REGUL,K_USUARIO);
                                                     ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTEFIJA----------------------------------
                                                     UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                     SET ADMPN_SALDO_CC =  NVL(ADMPN_SALDO_CC,0) - V_COUNT_PTOS ,  ADMPC_ESTPTO_CC='A', ADMPV_USU_MOD = K_USUARIO
                                                     WHERE ADMPV_COD_CLI_PROD=COD_CLI_PROD;

                                                     V_COUNT_PTOS := 0;
                                                   END IF;
                                                END IF;
                                              FETCH CUR_PTOS_DSCTO INTO COD_CLI_PROD, C_PTO_DSCTO;
                                            END LOOP;
                                         CLOSE CUR_PTOS_DSCTO;
                                   END;
                                      IF C_PTOS_EFEC>0 THEN
                                         ADMPSI_DESCPTOS_PROMO(C_PTOS_EFEC,C_SERVICIO,C_COD_CLI,K_USUARIO, V_CODERROR,V_DESCERROR);
                                      END IF;
                             END IF;
                             -------------INSERTAR EL REGISTRO CORRESPONDIENTE EN LA TABLA PCLUB.ADMPT_AUX_PROM_DTH_HFC
                             INSERT INTO PCLUB.ADMPT_AUX_REGDTH_HFC(ADMPV_COD_CLI,ADMPV_NOM_REGUL,ADMPV_PERIODO,ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPV_COD_TPOCL,ADMPV_SERVICIO,ADMPN_PTOS_ORI)
                             VALUES(C_COD_CLI,C_NOM_REGUL,C_PERIODO,C_PUNTOS,C_NOM_ARCH,K_TIP_CLI,C_SERVICIO,C_PTOS_ORI);
                      END;
                  END IF;
             --END IF;
             END IF;
        FETCH CUR_REGULARIZA_PTOS INTO C_COD_CLI,C_NOM_REGUL,C_PERIODO,C_PUNTOS,C_NOM_ARCH,C_FEC_OPER,C_TIP_CLI,C_SERVICIO,C_PTOS_ORI;
    END LOOP;
   CLOSE CUR_REGULARIZA_PTOS;
  COMMIT; --PROBAR COMENTANDO ESTE TROZO DE CODIGO
  END;

  INSERT INTO PCLUB.ADMPT_IMP_REGDTH_HFC(ADMPN_ID_FILA,ADMPV_COD_CLI,ADMPV_NOM_REGUL,ADMPV_PERIODO,
                                 ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPD_FEC_OPER,ADMPV_MSJE_ERROR,ADMPD_FEC_TRANS,ADMPV_COD_TPOCL,ADMPV_SERVICIO,ADMPN_PTOS_ORI)
  SELECT PCLUB.ADMPT_IMP_REG_DTH_HFC_SQ.NEXTVAL,T.ADMPV_COD_CLI,T.ADMPV_NOM_REGUL,T.ADMPV_PERIODO,
         CEIL(T.ADMPN_PUNTOS),T.ADMPV_NOM_ARCH,T.ADMPD_FEC_OPER,T.ADMPV_MSJE_ERROR,TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'),
         T.ADMPV_COD_TPOCL,T.ADMPV_SERVICIO,T.ADMPN_PUNTOS
  FROM PCLUB.ADMPT_TMP_REGDTH_HFC T
  WHERE  T.ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(T.ADMPD_FEC_REG)=TRUNC(K_FECHA) AND T.ADMPV_NOM_ARCH = K_NOM_ARCH;

 SELECT COUNT(*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_REGDTH_HFC WHERE ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(ADMPD_FEC_REG)=TRUNC(K_FECHA) AND ADMPV_NOM_ARCH = K_NOM_ARCH;
 SELECT COUNT(*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_REGDTH_HFC WHERE ADMPV_COD_TPOCL = K_TIP_CLI AND TRUNC(ADMPD_FEC_REG)=TRUNC(K_FECHA) AND ADMPV_NOM_ARCH = K_NOM_ARCH
 AND(ADMPV_MSJE_ERROR IS NOT NULL);
 SELECT COUNT(*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_REGDTH_HFC WHERE ADMPV_COD_TPOCL = K_TIP_CLI;

 -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_TMP_REGDTH_HFC WHERE ADMPV_COD_TPOCL=K_TIP_CLI AND  TRUNC(ADMPD_FEC_REG)=TRUNC(K_FECHA); 
   DELETE PCLUB.ADMPT_AUX_REGDTH_HFC WHERE ADMPV_COD_TPOCL=K_TIP_CLI;

  COMMIT;

   BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
   END;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
       ROLLBACK;
       BEGIN
         SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
         K_DESCERROR:='ERROR';
       END;
    WHEN NO_CONCEPTO THEN
       ROLLBACK;
       BEGIN
         SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
         K_DESCERROR:='ERROR';
       END;
    WHEN OTHERS THEN
     ROLLBACK;
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_REGDTH_HFC;


PROCEDURE ADMPSI_EREGDTH_HFC(K_TIP_CLI IN VARCHAR2,
                                        K_FECHA   IN DATE,
                                        K_CODERROR OUT NUMBER,
                                        K_DESCERROR OUT VARCHAR2,
                                        CURSORREGPTO OUT SYS_REFCURSOR) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_EREGDTH_HFC
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Regularizacion de Puntos
-- Input               :  K_TIP_CLI -  Tipo de Cliente a Procesar
--                        K_FECHA - Fecha de Proceso
-- Output              :  CURSORREGPTO
-- Fec Creación        :  24/09/2010
-- Fec Actualización   :
--****************************************************************
  NO_PARAMETROS EXCEPTION;

BEGIN
    K_CODERROR        := 0;
    IF K_TIP_CLI IS NULL OR   K_FECHA IS NULL  THEN
        RAISE NO_PARAMETROS;
    END IF;

OPEN CURSORREGPTO FOR
 SELECT ADMPV_COD_CLI, ADMPV_NOM_REGUL, ADMPV_PERIODO, ADMPN_PUNTOS,ADMPV_NOM_ARCH, ADMPV_MSJE_ERROR
         FROM PCLUB.ADMPT_IMP_REGDTH_HFC
  WHERE  ADMPV_MSJE_ERROR IS NOT NULL  AND
         PCLUB.ADMPT_IMP_REGDTH_HFC.ADMPV_COD_TPOCL = K_TIP_CLI AND ADMPD_FEC_OPER=K_FECHA;
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      K_DESCERROR:='Ingresó datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_DESCERROR:=SUBSTR( SQLERRM ,1,250);

END ADMPSI_EREGDTH_HFC;



PROCEDURE ADMPSI_DESCPTOS_PROMO( K_PUNTOS      IN NUMBER,
                                 K_SERVICIO    IN VARCHAR2,
                                 K_CODCLIE     IN VARCHAR2,
                                 K_USUARIO     IN VARCHAR2,
                                 K_CODERROR    OUT NUMBER,
                                 K_DESCERROR   OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_DESC_PUNTOS
    -- Propósito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
    -- Input               :  K_ID_CANJE Identificador del canje
    --                        K_SEC Secuencial del Detalle
    --                        K_PUNTOS Total de Puntos a descontar
    --                        K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIP_CLI Tipo de Cliente
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  22/05/2012
    --****************************************************************

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;


    NO_PARAMETROS EXCEPTION;

    /* Cursor 1 */-- Prepago
    CURSOR LISTA_KARDEX IS
       SELECT KA.ADMPC_TPO_PUNTO, KA.ADMPN_ID_KARDEX, KA.ADMPN_SLD_PUNTO,
             KA.ADMPV_COD_CLI_PROD, ADMPN_COD_CLI_IB FROM PCLUB.ADMPT_KARDEXFIJA KA
       WHERE KA.ADMPC_ESTADO = 'A' AND KA.ADMPC_TPO_OPER = 'E' AND KA.ADMPN_SLD_PUNTO > 0
         AND TO_DATE(TO_CHAR(KA.ADMPD_FEC_TRANS, 'DD/MM/YYYY'), 'DD/MM/YYYY') <=  TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')
         AND KA.ADMPV_COD_CLI_PROD IN
                     (SELECT CP.ADMPV_COD_CLI_PROD    FROM PCLUB.ADMPT_CLIENTEPRODUCTO CP
                          INNER JOIN PCLUB.ADMPT_CLIENTEFIJA CF ON (CF.ADMPV_COD_CLI = CP.ADMPV_COD_CLI)
                       WHERE CF.ADMPV_COD_CLI  = K_CODCLIE AND CP.ADMPV_ESTADO_SERV = 'A' AND CP.ADMPV_SERVICIO= K_SERVICIO)
        /*Selecciona todos los codigos que cumplen con la condicion*/
       ORDER BY DECODE(ADMPC_TPO_PUNTO, 'I', 1, 'L', 2, 'C', 3),   ADMPN_ID_KARDEX ASC;
  BEGIN
    K_CODERROR  := 0;
    K_DESCERROR := '';
    V_PUNTOS_REQUERIDOS := K_PUNTOS;

    IF K_PUNTOS IS NOT NULL AND K_PUNTOS<> 0 THEN
        OPEN LISTA_KARDEX;
        FETCH LISTA_KARDEX
          INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        WHILE LISTA_KARDEX%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
         IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
            -- Actualiza Kardexfija
            UPDATE PCLUB.ADMPT_KARDEXFIJA  SET ADMPN_SLD_PUNTO = 0, ADMPV_USU_MOD= K_USUARIO
             WHERE ADMPN_ID_KARDEX = LK_ID_KARDEX;
            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
         ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN
                -- Actualiza Kardex
                  UPDATE PCLUB.ADMPT_KARDEXFIJA    SET ADMPN_SLD_PUNTO = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS, ADMPV_USU_MOD= K_USUARIO
                  WHERE ADMPN_ID_KARDEX = LK_ID_KARDEX;
                V_PUNTOS_REQUERIDOS := 0;
            END IF;
         END IF;
          FETCH LISTA_KARDEX
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        END LOOP;
        CLOSE LISTA_KARDEX;
    ELSE
       IF K_PUNTOS IS NULL THEN
          K_CODERROR:=4;
          K_DESCERROR := 'Parametro = K_PUNTOS';
       END IF ;

       IF K_PUNTOS=0 THEN
          K_CODERROR:=19;
       END IF ;

       RAISE NO_PARAMETROS;
    END IF;

     BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
     EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
     END;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
       BEGIN
         SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
         K_DESCERROR:='ERROR';
       END;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);

 END ADMPSI_DESCPTOS_PROMO;

PROCEDURE ADMPSI_CAMBTIT    (K_TIP_CLI        IN VARCHAR2,
                             K_COD_CLIPROD    IN LISTA_CLI_PRODUCTO,
                             K_TIPODOC        IN VARCHAR2,
                             K_NUMDOC         IN VARCHAR2,
                             K_COD_CLIPROD_N  IN LISTA_CLI_PRODUCTO,
                             K_TIPODOC_N      IN VARCHAR2,
                             K_NUMDOC_N       IN VARCHAR2,
                             K_NOMCLI         IN VARCHAR2,
                             K_APECLI         IN VARCHAR2,
                             K_SEXO           IN VARCHAR2,
                             K_ESTCIVIL       IN VARCHAR2,
                             K_EMAIL          IN VARCHAR2,
                             K_PROV           IN VARCHAR2,
                             K_DEPAR          IN VARCHAR2,
                             K_DIST           IN VARCHAR2,
                             K_CICLOFACT      IN VARCHAR2,
                             K_USUARIO        IN VARCHAR2,
                             K_CODERROR       OUT NUMBER,
                             K_DESCERROR      OUT VARCHAR2) IS

--****************************************************************
-- Nombre SP           :  ADMPSI_CAMBTIT
-- Propósito           :  Cambio de Titularidad HFC
-- Input               :  K_COD_CLIPROD   - Lista de Cliente Productos de Cliente Actual - a cambiar Titular del Producto HFC
--                        K_TIPODOC       - Tipo de Documento del Actual Titular
--                        K_NUMDOC        - Numero de Documento del Actual Titular
--                        K_COD_CLIPROD_N   - Lista de Cliente Productos Nuevo Cliente - a cambiar Titular del Producto HFC
--                        K_TIPODOC_N     - Tipo de Documento del Nuevo Titular
--                        K_NUMDOC_N      - Numero de Documento del Nuevo Titular
--                        K_NOMCLI        - Nombres Nuevo Titular
--                        K_APECLI        - Apellidos Nuevo Titular
--                        K_SEXO          - Sexo Nuevo Titular
--                        K_ESTCIVIL      - Estado Civil Nuevo Titular
--                        K_EMAIL         - Email Nuevo Titular
--                        K_PROV          - Provincia Residencia Nuevo Titular
--                        K_DEPAR         - Departamento Residencia Nuevo Titular
--                        K_DIST          - Distrito Residencia Nuevo Titular
--                        K_CICLOFACT     - Cliclo de Facturacion Nuevo Titular
--                        K_USUARIO       - Usuario de la Aplicacion
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
-- Creado por          :  Susana Ramos
-- Fec Creación        :  15/05/2012
-- Fec Actualización   :  22/05/2012
--****************************************************************


V_CODCLIENTE     VARCHAR2(40);
V_CODCLIENTE_N   VARCHAR2(40);
V_IDKARDEX       NUMBER;
C_PUNTOS        NUMBER;
V_CODIDCOSALDO  VARCHAR2(40);
V_IDSALDO       NUMBER;
V_COD_CPTO      VARCHAR2(2);
V_ESTADO        VARCHAR2(2);
V_REGCLIENTE    NUMBER;
V_REG_CLIPROD   NUMBER;
V_REGCLIFIJA    NUMBER;
V_REGCLI        NUMBER;
V_REGCLIPROD    NUMBER;
V_REGCLIPROD_N  NUMBER;
V_REGINDICEGRUPO NUMBER;
V_REGINDICEGRUPO_N NUMBER;
V_CLI_PRODUCTO   CLI_PRODUCTO;
V_CLI_PRODUCTO_N CLI_PRODUCTO;
V_SALDO_CC      NUMBER;
V_TIPO_PUNTO    CHAR (1);
VCOD_TPDOC      VARCHAR2(2);
VCOD_TPDOC_N      VARCHAR2(2);
COD_CLI_PROD PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_COD_CLI_PROD%TYPE;
COD_SERVI    PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_SERVICIO%TYPE;

EX_ERROR  EXCEPTION;
EX_SALDO  EXCEPTION;
NO_EXISTE EXCEPTION;
V_CODERROR     NUMBER;
V_DESCERROR    VARCHAR2(400);
V_INDICEGRUPO VARCHAR2(2);
K_CODERROR_1 NUMBER;
K_DESCERROR_1 VARCHAR2(400);

/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
/*CUPONERAVIRTUAL - JCGT FIN*/

BEGIN

  K_CODERROR  := 0;
  K_DESCERROR := '';

    -- Solo podemos validar si enviaron datos en codigo de cliente
  IF K_TIP_CLI  IS NULL THEN
    K_CODERROR  :=4;
    K_DESCERROR:='Ingrese el Tipo de Cliente, es un campo obligatorio';
    RAISE EX_ERROR;
  END IF;

  IF K_TIPODOC IS NULL THEN
    K_CODERROR  :=4;
    K_DESCERROR:='Ingrese el campo Tipo de Dcto., es un campo obligatorio';
    RAISE EX_ERROR;
  END IF;

  IF K_NUMDOC IS NULL THEN
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese el campo Nro. de Dcto., es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

  IF K_COD_CLIPROD IS NULL THEN
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese la Lista de Servicios a Cambiar de Titularidad, es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

  -------------------
 IF K_TIPODOC_N IS NULL THEN
    K_CODERROR  :=4;
    K_DESCERROR:='Ingrese el campo Tipo de Dcto., es un campo obligatorio';
    RAISE EX_ERROR;
  END IF;

  IF K_NUMDOC_N IS NULL THEN
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese el campo Nro. de Dcto., es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

  IF K_NOMCLI IS NULL OR K_APECLI IS NULL THEN
     K_CODERROR  :=4;
     K_DESCERROR:='Ingrese el campo Nombres/Apellidos del Cliente, es un campo obligatorio';
     RAISE EX_ERROR;
  END IF;

  ------------------ Validaciones del Cliente Actual
      BEGIN
          SELECT ADMPV_COD_TPDOC INTO VCOD_TPDOC
          FROM PCLUB.ADMPT_TIPO_DOC
          WHERE ADMPV_EQU_FIJA = K_TIPODOC;
      EXCEPTION WHEN NO_DATA_FOUND THEN
          K_CODERROR  :=4;
          K_DESCERROR:='Ingrese un Tipo de documento válido';
          RAISE EX_ERROR;
      END;

/*  IF VCOD_TPDOC='' OR VCOD_TPDOC IS NULL THEN
      RAISE NO_EXISTE;
   END IF ;*/

   SELECT COUNT(ROWID) INTO V_REGCLIENTE
   FROM PCLUB.ADMPT_CLIENTEFIJA CF
   WHERE CF.ADMPV_TIPO_DOC = VCOD_TPDOC  AND CF.ADMPV_NUM_DOC=K_NUMDOC  AND CF.ADMPV_COD_TPOCL = K_TIP_CLI;

  IF V_REGCLIENTE>0 THEN
     SELECT C.ADMPV_COD_CLI, C.ADMPC_ESTADO INTO V_CODCLIENTE, V_ESTADO
     FROM PCLUB.ADMPT_CLIENTEFIJA C
     WHERE C.ADMPV_TIPO_DOC = VCOD_TPDOC  AND C.ADMPV_NUM_DOC = K_NUMDOC   AND C.ADMPV_COD_TPOCL = K_TIP_CLI;

       IF V_ESTADO <> 'A' THEN
          K_CODERROR  := 6;
          RAISE EX_ERROR;
       END IF;

       /***/
       ADMPSS_VLD_CAMTIT(K_TIP_CLI,K_COD_CLIPROD,VCOD_TPDOC,K_NUMDOC,K_CODERROR_1,K_DESCERROR_1);

       IF K_CODERROR_1=1 THEN
          K_CODERROR  := 31;
          RAISE EX_ERROR;
       END IF;
       /***/

       --Verifica si Todos los Servicios del Cliente Actual esta en Baja
       SELECT COUNT(*) INTO V_REGCLIENTE
          FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
       WHERE C.ADMPV_COD_CLI=V_CODCLIENTE   AND C.ADMPV_ESTADO_SERV='A';

       IF V_REGCLIENTE=0 THEN
         -- K_DESCERROR:='El Cliente No tiene Servicios Activos';
          K_CODERROR  := 31;
          RAISE EX_ERROR;
       END IF;
  ELSE
       K_CODERROR  := 6;
       RAISE EX_ERROR;
  END IF;

    BEGIN
       IF  K_TIP_CLI='6' THEN
            SELECT ADMPV_COD_CPTO    INTO V_COD_CPTO
            FROM PCLUB.ADMPT_concepto
            WHERE admpv_desc='CAMBIO TITULARIDAD DTH';
        ELSIF K_TIP_CLI='7' THEN
            SELECT ADMPV_COD_CPTO    INTO V_COD_CPTO
            FROM PCLUB.ADMPT_concepto
            WHERE admpv_desc = 'CAMBIO TITULARIDAD HFC';
        END IF ;
    EXCEPTION  WHEN NO_DATA_FOUND THEN
         V_COD_CPTO:=NULL;
         K_CODERROR := 9;
         RAISE EX_ERROR;
    END;

   /*-------Se Verifica Cuantos si hay otro Grupo(HFC)/Servicio(DTH) Activo Para el Traspaso de puntos---------*/
     IF  K_TIP_CLI='6' THEN
         SELECT COUNT(ADMPV_INDICEGRUPO) INTO V_REGINDICEGRUPO FROM PCLUB.ADMPT_CLIENTEPRODUCTO
         WHERE ADMPV_COD_CLI = V_CODCLIENTE  AND ADMPV_ESTADO_SERV='A';
     ELSE
         SELECT COUNT(DISTINCT ADMPV_INDICEGRUPO) INTO V_REGINDICEGRUPO   FROM PCLUB.ADMPT_CLIENTEPRODUCTO
         WHERE ADMPV_COD_CLI = V_CODCLIENTE  AND ADMPV_ESTADO_SERV='A';
     END IF;

  -------------Se recupera el Tipo de Doc--------------------------
     BEGIN
         SELECT ADMPV_COD_TPDOC INTO VCOD_TPDOC_N
         FROM PCLUB.ADMPT_TIPO_DOC
         WHERE ADMPV_EQU_FIJA = K_TIPODOC_N;
      EXCEPTION WHEN NO_DATA_FOUND THEN
          K_CODERROR  :=4;
          K_DESCERROR:='Ingrese un Tipo de documento válido';
          RAISE EX_ERROR;
      END;

  V_CODCLIENTE_N:=VCOD_TPDOC_N||'.'||K_NUMDOC_N||'.'||K_TIP_CLI;

  --V_ULT_CODSER := K_COD_CLIPROD.LAST;
  FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
  LOOP
       V_REGCLI :=0;
       V_REGCLIPROD :=0;
       --V_SALDO_CLI := 0;
       C_PUNTOS:=0;
       V_SALDO_CC := 0.00;
       V_CLI_PRODUCTO := K_COD_CLIPROD(I);

       IF K_TIP_CLI='7' then
          SELECT SUBSTR(V_CLI_PRODUCTO.COD_CLI_PROD,LENGTH(V_CLI_PRODUCTO.COD_CLI_PROD),1)  INTO V_INDICEGRUPO FROM DUAL;
       ELSE
          V_INDICEGRUPO :=1;
       END IF;

       SELECT COUNT(ROWID) INTO V_REGCLI FROM PCLUB.ADMPT_CLIENTEPRODUCTO B
       WHERE B.ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD AND   B.ADMPV_ESTADO_SERV='A';
       IF V_REGCLI>0 THEN
            BEGIN
                SELECT NVL(S.ADMPN_SALDO_CC,NULL) INTO V_SALDO_CC
                  FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                WHERE S.ADMPV_COD_CLI_PROD =  V_CLI_PRODUCTO.COD_CLI_PROD;
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 V_SALDO_CC := 0.00;
            END;

            -- Insertamos en el Kardex el movimiento sólo si el saldo es mayor que 0, Para la Salida de Puntos por Cambio de Titularidad
            IF V_SALDO_CC > 0 THEN
               V_TIPO_PUNTO  := 'S';
                  /* genera secuencial de kardex*/
                  SELECT PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL INTO V_IDKARDEX FROM DUAL;

                  INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB,ADMPV_COD_CLI_PROD, ADMPV_COD_CPTO, ADMPD_FEC_TRANS,ADMPN_PUNTOS,
                                                ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO,ADMPV_USU_REG)
                                        VALUES(V_IDKARDEX, NULL,V_CLI_PRODUCTO.COD_CLI_PROD, V_COD_CPTO, SYSDATE , V_SALDO_CC * -1 ,
                                               V_TIPO_PUNTO, 'C', C_PUNTOS, 'A',K_USUARIO);
            END IF;

              -- ACTUALIZAMOS EL SALDO DE LOS MOVIMIENTOS DE ENTRADA DEL KARDEX A 0 SEGUN CODIGO DEL CLIENTE SOLO SI ES MAYOR A 0
                   UPDATE PCLUB.ADMPT_KARDEXFIJA SET ADMPN_SLD_PUNTO = C_PUNTOS , ADMPV_USU_MOD = K_USUARIO
                   WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD AND
                         ADMPC_TPO_PUNTO IN ('C','L')       AND ADMPN_SLD_PUNTO > 0 AND ADMPC_TPO_OPER = 'E';

              -- ACTUALIZAR EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE PROD (CLIENTE ANTERIOR)
                   UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S   SET S.ADMPN_SALDO_CC = C_PUNTOS , S.ADMPV_USU_MOD = K_USUARIO, S.ADMPC_ESTPTO_CC='B'
                   WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD ;

              -- Servicio que se cambia de titularidad
                 /*---Se Verfica que haya mas productos de este mismo servicio---*/
                 SELECT COUNT(*)  INTO V_REG_CLIPROD FROM PCLUB.ADMPT_CLIENTEPRODUCTO
                 WHERE ADMPV_COD_CLI = V_CODCLIENTE  AND ADMPV_ESTADO_SERV='A' AND ADMPV_SERVICIO=V_CLI_PRODUCTO.DESC_PRODUCTO ;

                 /*-------Si Hay otro Grupo Activo Para el Traspaso de puntos---------*/
                  IF V_REGINDICEGRUPO=1 THEN
                       --Se actualiza el campo ADMPV_ESTADO_SERV  a (B) Baja  de la tabla PCLUB.ADMPT_CLIENTEPRODUCTO
                       UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO  CP SET CP.ADMPV_ESTADO_SERV='B', CP.ADMPV_USU_MOD=K_USUARIO
                       WHERE ADMPV_COD_CLI = V_CODCLIENTE AND ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;
                  ELSIF V_REGINDICEGRUPO>1 THEN
                       UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO  CP SET CP.ADMPV_ESTADO_SERV='B', CP.ADMPV_USU_MOD=K_USUARIO
                       WHERE ADMPV_COD_CLI = V_CODCLIENTE AND ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO.COD_CLI_PROD;

                        IF V_SALDO_CC > 0 THEN
                           IF V_REG_CLIPROD>1  THEN
                               /*--Se ordena por Prioridad, para saber a quien pasa el saldo, En caso el Cliente HFC Tiene + de un Producto, pasara al + Antiguo --*/
                              BEGIN
                                 SELECT CLIPROD, SERVICIO INTO COD_CLI_PROD, COD_SERVI
                                 FROM (SELECT  A.ADMPV_COD_CLI_PROD CLIPROD, A.ADMPV_SERVICIO SERVICIO
                                      --INTO COD_CLI_PROD, COD_SERVI
                                 FROM PCLUB.ADMPT_CLIENTEPRODUCTO A
                                    INNER JOIN PCLUB.ADMPT_CLIENTEFIJA      B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
                                    INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND   D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
                                 WHERE B.ADMPV_COD_CLI= V_CODCLIENTE AND B.ADMPC_ESTADO = 'A'    AND
                                       B.ADMPV_COD_TPOCL = K_TIP_CLI AND A.ADMPV_ESTADO_SERV='A' /*AND ROWNUM=1 */ AND A.ADMPV_SERVICIO = V_CLI_PRODUCTO.DESC_PRODUCTO
                                 ORDER BY  D.ADMPN_PRIORIDAD, A.ADMPD_FEC_REG,A.ADMPV_COD_CLI_PROD ASC)
                                 WHERE ROWNUM=1;

                                  IF V_SALDO_CC > 0 THEN
                                     V_TIPO_PUNTO  := 'E';
                                     /* genera secuencial de kardex*/
                                     SELECT PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL INTO V_IDKARDEX FROM DUAL;
                                     /*----Se le Pasa los ptos , en caso tenga mas de un producto(DTH/HFC)------*/
                                     INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB,ADMPV_COD_CLI_PROD, ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
                                                          ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, ADMPV_USU_REG)
                                                          VALUES(V_IDKARDEX, NULL, COD_CLI_PROD, V_COD_CPTO, SYSDATE,
                                                          V_SALDO_CC , V_TIPO_PUNTO, 'C', V_SALDO_CC, 'A', K_USUARIO);

                                      UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S  SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_SALDO_CC , ADMPV_USU_MOD = K_USUARIO
                                      WHERE ADMPV_COD_CLI_PROD = COD_CLI_PROD;
                                  END IF;
                              END ;
                          ELSE
                            BEGIN
                                 SELECT COD_CLI INTO COD_CLI_PROD
                                  FROM (SELECT  P.ADMPV_COD_CLI_PROD COD_CLI
                                          FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_TIPOSERV_DTH_HFC T
                                         WHERE F.ADMPV_COD_CLI = V_CODCLIENTE AND
                                               F.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
                                               P.ADMPV_COD_CLI_PROD <> V_CLI_PRODUCTO.COD_CLI_PROD AND
                                               P.ADMPV_SERVICIO     <> V_CLI_PRODUCTO.DESC_PRODUCTO AND
                                               P.ADMPV_INDICEGRUPO  <> V_INDICEGRUPO  AND
                                               F.ADMPV_COD_TPOCL = K_TIP_CLI AND
                                               F.ADMPC_ESTADO = 'A' AND
                                               P.ADMPV_ESTADO_SERV = 'A' AND
                                               P.ADMPV_SERVICIO = T.ADMPV_SERVICIO
                                               ORDER BY T.ADMPN_PRIORIDAD )
                                   WHERE ROWNUM=1;
                                  IF V_SALDO_CC > 0 THEN
                                     V_TIPO_PUNTO  := 'E';
                                     /* genera secuencial de kardex*/
                                     SELECT PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL INTO V_IDKARDEX FROM DUAL;
                                     /*----Se le Pasa los ptos , en caso tenga mas de un producto(DTH/HFC)------*/
                                     INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB,ADMPV_COD_CLI_PROD, ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
                                                          ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, ADMPV_USU_REG)
                                                          VALUES(V_IDKARDEX, NULL, COD_CLI_PROD, V_COD_CPTO, SYSDATE,
                                                          V_SALDO_CC , V_TIPO_PUNTO, 'C', V_SALDO_CC, 'A', K_USUARIO);

                                      UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S  SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_SALDO_CC , ADMPV_USU_MOD = K_USUARIO
                                      WHERE ADMPV_COD_CLI_PROD = COD_CLI_PROD;
                                  END IF;
                            END ;
                          END IF ;
                      END IF;
                   END IF;
                 --Validar si el cliente existe EN TABLA PCLUB.ADMPT_CLIENTEFIJA
                 SELECT COUNT(*) INTO V_REGCLIFIJA
                   FROM PCLUB.ADMPT_CLIENTEFIJA C
                  WHERE C.ADMPV_COD_CLI = V_CODCLIENTE_N AND  C.ADMPC_ESTADO = 'A';
                 ---VALIDACION DE CLIENTE EXISTE O NO  EN CC, Y ADEMAS EL ESTADO ACTIVO O BAJA
                 IF V_REGCLIFIJA=0 THEN
                   -- Debemos insertar los clientes en la tabla de Clientes
                   INSERT INTO PCLUB.ADMPT_CLIENTEFIJA H
                    (H.ADMPV_COD_CLI,H.ADMPV_COD_SEGCLI, H.ADMPN_COD_CATCLI, H.ADMPV_TIPO_DOC, H.ADMPV_NUM_DOC,H.ADMPV_NOM_CLI,  H.ADMPV_APE_CLI, H.ADMPC_SEXO,
                     H.ADMPV_EST_CIVIL, H.ADMPV_EMAIL,H.ADMPV_PROV,   H.ADMPV_DEPA,  H.ADMPV_DIST, H.ADMPD_FEC_ACTIV,
                     /*H.ADMPV_CICL_FACT,*/  H.ADMPC_ESTADO,  H.ADMPV_COD_TPOCL, H.ADMPV_USU_REG )
                    VALUES (V_CODCLIENTE_N,NULL ,'2',VCOD_TPDOC_N, K_NUMDOC_N ,K_NOMCLI,K_APECLI,K_SEXO,
                     K_ESTCIVIL,K_EMAIL,K_PROV, K_DEPAR, K_DIST, SYSDATE,
                     /*K_CICLOFACT,*/'A',K_TIP_CLI,K_USUARIO );
                 END IF;
                   /*----Recorreremos la Lista de Productos del nuevo titular----------*/
                   FOR J IN K_COD_CLIPROD_N.FIRST .. K_COD_CLIPROD_N.LAST
                   LOOP
                        V_CLI_PRODUCTO_N := K_COD_CLIPROD_N(J);

                      IF V_CLI_PRODUCTO.DESC_PRODUCTO = V_CLI_PRODUCTO_N.DESC_PRODUCTO THEN
                        /*-----Verificar si el Servicio Existe en PCLUB.ADMPT_CLIENTEPRODUCTO esta Activo---------*/
                            SELECT COUNT(*) INTO V_REGCLIPROD_N
                            FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
                                 WHERE C.ADMPV_COD_CLI=V_CODCLIENTE_N   AND C.ADMPV_COD_CLI_PROD =  V_CLI_PRODUCTO_N.COD_CLI_PROD
                            AND C.ADMPV_ESTADO_SERV = 'A';
                          IF V_REGCLIPROD_N=0 THEN

                              IF  K_TIP_CLI='6' THEN
                                  V_REGINDICEGRUPO_N := 1;
                              ELSIF K_TIP_CLI='7' THEN
                                  V_REGINDICEGRUPO_N := SUBSTR(V_CLI_PRODUCTO_N.COD_CLI_PROD,LENGTH(V_CLI_PRODUCTO_N.COD_CLI_PROD),1);
                              END IF ;

                              IF K_TIP_CLI='6' THEN
                                IF V_REG_CLIPROD=1 THEN
                                  ADMPSS_BAJA(K_TIP_CLI,V_CODCLIENTE,'C',V_CLI_PRODUCTO_N.COD_CLI_PROD ,K_USUARIO,V_CODERROR, V_DESCERROR);
                                ELSIF V_REG_CLIPROD>1 THEN
                                  ADMPSS_BAJA(K_TIP_CLI,V_CODCLIENTE,'P',V_CLI_PRODUCTO_N.COD_CLI_PROD ,K_USUARIO,V_CODERROR, V_DESCERROR);
                                END IF ;
                              END IF;

                                INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H  (H.ADMPV_COD_CLI_PROD, H.ADMPV_COD_CLI, H.ADMPV_SERVICIO,
                                               H.ADMPV_ESTADO_SERV,  H.ADMPV_FEC_ULTANIV, H.ADMPV_USU_REG, H.ADMPV_INDICEGRUPO )
                                   VALUES(V_CLI_PRODUCTO_N.COD_CLI_PROD, V_CODCLIENTE_N, V_CLI_PRODUCTO_N.DESC_PRODUCTO,
                                          'A',  SYSDATE, K_USUARIO, V_REGINDICEGRUPO_N );

                              -- Debemos verificar si el cliente tiene algun saldo asociado
                                BEGIN
                                  SELECT G.ADMPV_COD_CLI_PROD INTO V_CODIDCOSALDO FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA G
                                   WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO_N.COD_CLI_PROD;
                                        K_DESCERROR := 'El Nuevo cliente tiene registrado saldos en el servicio: ' || V_CODIDCOSALDO;
                                   RAISE EX_SALDO;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                     /**Generar secuencial de Saldo*/
                                    SELECT PCLUB.ADMPT_SLD_CLFIJA_SQ.NEXTVAL INTO V_IDSALDO FROM DUAL;

                                      INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA(ADMPN_ID_SALDO,ADMPV_COD_CLI_PROD,ADMPN_SALDO_CC,ADMPN_SALDO_IB,
                                                  ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,ADMPV_USU_REG)
                                      VALUES (V_IDSALDO, V_CLI_PRODUCTO_N.COD_CLI_PROD, 0.00, 0.00, 'A', NULL,K_USUARIO);
                                      WHEN EX_SALDO THEN
                                      RAISE EX_ERROR;
                                END;
                          ELSE
                              UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S  SET S.ADMPN_SALDO_CC = 0.00 , ADMPV_USU_MOD = K_USUARIO
                              WHERE ADMPV_COD_CLI_PROD = V_CLI_PRODUCTO_N.COD_CLI_PROD;
                          END IF;
                      END IF;
                   END LOOP;
       END IF;
  END LOOP;

   -----------SE DARA DE BAJA AL CLIENTE------------
   IF V_REGINDICEGRUPO=1 AND K_TIP_CLI='7' THEN
      ADMPSS_BAJA(K_TIP_CLI,V_CODCLIENTE,'C','',K_USUARIO,V_CODERROR, V_DESCERROR);
   END IF;

   /*CUPONERAVIRTUAL - JCGT INI*/
  PKG_CC_CUPONERA.ADMPSI_CAMBIOTITULAR(VCOD_TPDOC,K_NUMDOC,K_TIPODOC_N,K_NUMDOC_N,K_NOMCLI,K_APECLI,K_EMAIL,'CMBTIT', K_USUARIO,C_CODERROR,C_DESCERROR);
  /*CUPONERAVIRTUAL - JCGT FIN*/

  COMMIT;

--MANEJO DE ERRORES
    BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='';
    END;

EXCEPTION
  WHEN EX_ERROR THEN
    ROLLBACK;
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR:=1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_CAMBTIT;

PROCEDURE ADMPSI_CAMBIOTITULAR_HFC( K_FECHAPROC IN DATE,K_NUMREGTOT OUT NUMBER,K_NUMREGERR OUT NUMBER,K_NUMREGPRO OUT NUMBER,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) AS
TYPE REG IS RECORD
( COD_CLI_PROD  VARCHAR2(40),
  ESTADO        VARCHAR2(6),
  TIP_DOC       VARCHAR2(40),
  NUM_DOC       VARCHAR2(40),
  NOM_CLI       VARCHAR2(150),
  APE_CLI       VARCHAR2(150),
  SEX           VARCHAR2(10),
  EST_CIV       VARCHAR2(10),
  EMAIL         VARCHAR2(150),
  PROV          VARCHAR2(50),
  DEPT          VARCHAR2(50),
  DIST          VARCHAR2(50),
  CIC_FAC       VARCHAR2(10),
  FEC_PRO       DATE,
  SECUENCIA           NUMBER,
  NRO_OPERACION   NUMBER,
  CODERROR NUMBER,
  DESERROR VARCHAR2(200),
  NOM_ARCH      VARCHAR2(200));
  LINEA REG;

OPER NUMBER;
NROOPER NUMBER;
ITER NUMBER;
TIPDOC       VARCHAR2(40);
NUMDOC       VARCHAR2(40);
TIPDOC_ANT VARCHAR2(40);
NUMDOC_ANT VARCHAR2(40);
NOMCLI       VARCHAR2(150);
APECLI       VARCHAR2(150);
SEXO           VARCHAR2(10);
ESTCI       VARCHAR2(10);
EMAI         VARCHAR2(150);
PRO          VARCHAR2(50);
DEP          VARCHAR2(50);
DIS          VARCHAR2(50);
CI_FAC       VARCHAR2(10);
CONTREG NUMBER;

CONTBAJAS NUMBER;
CONTALTAS NUMBER;

L_CLIBAJA  LISTA_CLI_PRODUCTO;
L_CLIALTA  LISTA_CLI_PRODUCTO;
DET_CLI_PRODUCTO CLI_PRODUCTO;

CURSOR OPERACIONES IS
SELECT H.ADMPV_NROOPERACION,COUNT(*)/2 NRO
FROM PCLUB.ADMPT_TMP_CAMBTIT_HFC H
WHERE H.ADMPV_FEC_PRO=K_FECHAPROC
AND H.ADMPV_MSJE_ERROR IS NULL
GROUP BY H.ADMPV_NROOPERACION;

CURSOR CLIEBAJAS(NRO_OPER NUMBER) IS
SELECT *
FROM PCLUB.ADMPT_TMP_CAMBTIT_HFC H
WHERE H.ADMPV_FEC_PRO=K_FECHAPROC
AND H.ADMPV_ESTADO='B'
AND H.ADMPV_NROOPERACION=NRO_OPER
AND H.ADMPV_MSJE_ERROR IS NULL;

CURSOR CLIEALTAS(NRO_OPER NUMBER) IS
SELECT *
FROM PCLUB.ADMPT_TMP_CAMBTIT_HFC H
WHERE H.ADMPV_FEC_PRO=K_FECHAPROC
AND H.ADMPV_ESTADO='A'
AND H.ADMPV_NROOPERACION=NRO_OPER
AND H.ADMPV_MSJE_ERROR IS NULL;

BEGIN
K_CODERROR:=0;
K_DESCERROR:='';

UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
SET H.ADMPV_MSJE_ERROR='El tipo o numero de documento SON OBLIGATORIOS.'
WHERE H.ADMPV_FEC_PRO=K_FECHAPROC
AND (H.ADMPV_TIP_DOC IS NULL OR H.ADMPV_NUM_DOC IS NULL);

UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
SET H.ADMPV_MSJE_ERROR='El numero de operacion es un dato OBLIGATORIO.'
WHERE H.ADMPV_FEC_PRO=K_FECHAPROC
AND H.ADMPV_NROOPERACION IS NULL
AND H.ADMPV_MSJE_ERROR IS NULL;

UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
SET H.ADMPV_MSJE_ERROR='El estado es un dato OBLIGATORIO.'
WHERE H.ADMPV_FEC_PRO=K_FECHAPROC
AND H.ADMPV_ESTADO IS NULL
AND H.ADMPV_MSJE_ERROR IS NULL;



OPEN OPERACIONES;
FETCH OPERACIONES INTO OPER,NROOPER;
WHILE OPERACIONES%FOUND LOOP
    CONTBAJAS :=0;
    CONTALTAS :=0;

    OPEN CLIEALTAS(OPER);
    FETCH CLIEALTAS INTO LINEA;
    WHILE CLIEALTAS%FOUND LOOP

    CONTALTAS:=CONTALTAS+1;

    FETCH CLIEALTAS INTO  LINEA;
    END LOOP;

    OPEN CLIEBAJAS(OPER);
    FETCH CLIEBAJAS INTO LINEA;
    WHILE CLIEBAJAS%FOUND LOOP

    CONTBAJAS:=CONTBAJAS+1;

    FETCH CLIEBAJAS INTO  LINEA;
    END LOOP;

    CLOSE CLIEALTAS;
    CLOSE CLIEBAJAS;

    OPEN CLIEALTAS(OPER);
    OPEN CLIEBAJAS(OPER);

    IF CONTBAJAS = CONTALTAS THEN

            L_CLIALTA := LISTA_CLI_PRODUCTO();
            L_CLIALTA.EXTEND(NROOPER);
            ITER:=0;

            --OPEN CLIEALTAS(OPER);
            FETCH CLIEALTAS INTO LINEA;
            WHILE CLIEALTAS%FOUND LOOP

                SELECT COUNT(*) INTO CONTREG
                FROM PCLUB.ADMPT_AUX_CAMBTIT_HFC H
                WHERE H.ADMPV_COD_CLI_PROD=LINEA.COD_CLI_PROD
                AND H.ADMPV_ESTADO=LINEA.ESTADO
                AND H.ADMPV_TIP_DOC=LINEA.TIP_DOC
                AND H.ADMPV_NUM_DOC=LINEA.NUM_DOC
                AND H.ADMPV_NROOPERACION=LINEA.NRO_OPERACION
                AND H.ADMPV_FEC_PRO=K_FECHAPROC;

                IF CONTREG=0 THEN

                    IF ITER=0 THEN
                        TIPDOC:=LINEA.TIP_DOC;
                        NUMDOC:=LINEA.NUM_DOC;
                        NOMCLI:=LINEA.NOM_CLI;
                        APECLI:=LINEA.APE_CLI;
                        SEXO:=LINEA.SEX;
                        ESTCI:=LINEA.EST_CIV;
                        EMAI:=LINEA.EMAIL;
                        PRO:=LINEA.PROV;
                        DEP:=LINEA.DEPT;
                        DIS:=LINEA.DIST;
                        CI_FAC:=LINEA.CIC_FAC;
                    END IF;
                    ITER:=ITER+1;
                    DET_CLI_PRODUCTO := CLI_PRODUCTO(NULL,NULL);
                    DET_CLI_PRODUCTO.COD_CLI_PROD :=  LINEA.COD_CLI_PROD;
                    DET_CLI_PRODUCTO.DESC_PRODUCTO := SUBSTR(LINEA.COD_CLI_PROD,INSTR(LINEA.COD_CLI_PROD,'_')+1,4);
                    L_CLIALTA(ITER):=DET_CLI_PRODUCTO;

                    INSERT INTO PCLUB.ADMPT_AUX_CAMBTIT_HFC VALUES(LINEA.COD_CLI_PROD,LINEA.ESTADO,LINEA.TIP_DOC,LINEA.NUM_DOC,LINEA.NRO_OPERACION,LINEA.FEC_PRO);

                ELSE
                    UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
                    SET H.ADMPV_MSJE_ERROR='Se esta enviando a procesar el registro mas de una vez.'
                    WHERE H.ADMPV_COD_CLI_PROD=LINEA.COD_CLI_PROD
                    AND H.ADMPV_ESTADO=LINEA.ESTADO
                    AND H.ADMPV_TIP_DOC=LINEA.TIP_DOC
                    AND H.ADMPV_NUM_DOC=LINEA.NUM_DOC
                    AND H.ADMPV_NROOPERACION=LINEA.NRO_OPERACION
                    AND H.ADMPV_FEC_PRO=K_FECHAPROC;
                END IF;

            FETCH CLIEALTAS INTO  LINEA;
            END LOOP;
            --CLOSE CLIEALTAS;

            L_CLIBAJA := LISTA_CLI_PRODUCTO();
            L_CLIBAJA.EXTEND(NROOPER);
            ITER:=0;

            --OPEN CLIEBAJAS(OPER);
            FETCH CLIEBAJAS INTO LINEA;
            WHILE CLIEBAJAS%FOUND LOOP

                SELECT COUNT(*) INTO CONTREG
                FROM PCLUB.ADMPT_AUX_CAMBTIT_HFC H
                WHERE H.ADMPV_COD_CLI_PROD=LINEA.COD_CLI_PROD
                AND H.ADMPV_ESTADO=LINEA.ESTADO
                AND H.ADMPV_TIP_DOC=LINEA.TIP_DOC
                AND H.ADMPV_NUM_DOC=LINEA.NUM_DOC
                AND H.ADMPV_NROOPERACION=LINEA.NRO_OPERACION
                AND H.ADMPV_FEC_PRO=K_FECHAPROC;

                IF CONTREG=0 THEN

                    IF ITER=0 THEN
                        TIPDOC_ANT:=LINEA.TIP_DOC;
                        NUMDOC_ANT:=LINEA.NUM_DOC;
                    END IF;
                    ITER:=ITER+1;
                    DET_CLI_PRODUCTO := CLI_PRODUCTO(NULL,NULL);
                    DET_CLI_PRODUCTO.COD_CLI_PROD :=  LINEA.COD_CLI_PROD;
                    DET_CLI_PRODUCTO.DESC_PRODUCTO := SUBSTR(LINEA.COD_CLI_PROD,INSTR(LINEA.COD_CLI_PROD,'_')+1,4);
                    L_CLIBAJA(ITER):=DET_CLI_PRODUCTO;

                         INSERT INTO PCLUB.ADMPT_AUX_CAMBTIT_HFC VALUES(LINEA.COD_CLI_PROD,LINEA.ESTADO,LINEA.TIP_DOC,LINEA.NUM_DOC,LINEA.NRO_OPERACION,LINEA.FEC_PRO);

                ELSE

                    UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
                    SET H.ADMPV_MSJE_ERROR='Se esta enviando a procesar el registro mas de una vez.'
                    WHERE H.ADMPV_COD_CLI_PROD=LINEA.COD_CLI_PROD
                    AND H.ADMPV_ESTADO=LINEA.ESTADO
                    AND H.ADMPV_TIP_DOC=LINEA.TIP_DOC
                    AND H.ADMPV_NUM_DOC=LINEA.NUM_DOC
                    AND H.ADMPV_NROOPERACION=LINEA.NRO_OPERACION
                    AND H.ADMPV_FEC_PRO=K_FECHAPROC;

                END IF;

            FETCH CLIEBAJAS INTO  LINEA;
            END LOOP;
            --CLOSE CLIEBAJAS;
            COMMIT;
            ADMPSI_CAMBTIT('7',L_CLIBAJA,TIPDOC_ANT,NUMDOC_ANT,L_CLIALTA,TIPDOC,NUMDOC,NOMCLI,APECLI,SEXO,ESTCI,EMAI,PRO,DEP,DIS,CI_FAC,'USRCTITHFC',K_CODERROR,K_DESCERROR);

            IF K_CODERROR<>0 THEN
                UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC
                SET ADMPV_COD_ERROR = K_CODERROR,
                ADMPV_MSJE_ERROR= K_DESCERROR
                WHERE ADMPV_NROOPERACION=OPER
                AND ADMPV_FEC_PRO=K_FECHAPROC;
            END IF;

    ELSE
        IF CONTBAJAS > 0 THEN

            FETCH CLIEBAJAS INTO LINEA;
            WHILE CLIEBAJAS%FOUND LOOP

                    UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
                    SET H.ADMPV_MSJE_ERROR='No coinciden ALTAS y BAJAS.'
                    WHERE H.ADMPV_COD_CLI_PROD=LINEA.COD_CLI_PROD
                    AND H.ADMPV_ESTADO=LINEA.ESTADO
                    AND H.ADMPV_TIP_DOC=LINEA.TIP_DOC
                    AND H.ADMPV_NUM_DOC=LINEA.NUM_DOC
                    AND H.ADMPV_NROOPERACION=LINEA.NRO_OPERACION
                    AND H.ADMPV_FEC_PRO=K_FECHAPROC;

            FETCH CLIEBAJAS INTO  LINEA;
            END LOOP;
            --CLOSE CLIEBAJAS;

        END IF;

        IF CONTALTAS > 0 THEN
            FETCH CLIEALTAS INTO LINEA;
            WHILE CLIEALTAS%FOUND LOOP

                    UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC H
                    SET H.ADMPV_MSJE_ERROR='No coinciden ALTAS y BAJAS.'
                    WHERE H.ADMPV_COD_CLI_PROD=LINEA.COD_CLI_PROD
                    AND H.ADMPV_ESTADO=LINEA.ESTADO
                    AND H.ADMPV_TIP_DOC=LINEA.TIP_DOC
                    AND H.ADMPV_NUM_DOC=LINEA.NUM_DOC
                    AND H.ADMPV_NROOPERACION=LINEA.NRO_OPERACION;

            FETCH CLIEALTAS INTO  LINEA;
            END LOOP;
           -- CLOSE CLIEALTAS;

        END IF;

    END IF;

   CLOSE CLIEALTAS;
   CLOSE CLIEBAJAS;

FETCH OPERACIONES INTO  OPER,NROOPER;
END LOOP;
CLOSE OPERACIONES;
/*INSERTAR EN LA TABLA IMP*/

-- Exportar datos a la tabla PCLUB.ADMPT_imp_pago_cc
    INSERT INTO PCLUB.ADMPT_IMP_CAMBTIT_HFC
    SELECT  PCLUB.ADMPT_SQ_CAMBTIT_HFC.NEXTVAL ,H.ADMPV_COD_CLI_PROD,ADMPV_ESTADO,ADMPV_TIP_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPV_SEX,
                ADMPV_EST_CIV,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPT,ADMPV_DIST,ADMPV_CIC_FAC,ADMPV_FEC_PRO,ADMPV_NROOPERACION,ADMPV_COD_ERROR,ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_TMP_CAMBTIT_HFC H
    WHERE H.ADMPV_FEC_PRO=K_FECHAPROC;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
    SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_CAMBTIT_HFC WHERE ADMPV_FEC_PRO=K_FECHAPROC;
    SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_CAMBTIT_HFC WHERE ADMPV_FEC_PRO=K_FECHAPROC AND (ADMPV_MSJE_ERROR IS NOT NULL);
    SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_CAMBTIT_HFC WHERE ADMPV_FEC_PRO=K_FECHAPROC;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_CAMBTIT_HFC WHERE ADMPV_FEC_PRO=K_FECHAPROC;
   DELETE PCLUB.ADMPT_TMP_CAMBTIT_HFC  WHERE ADMPV_FEC_PRO=K_FECHAPROC;

COMMIT;
K_CODERROR:=0;
K_DESCERROR:='';
   BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
   END;

EXCEPTION
        WHEN OTHERS THEN
        K_CODERROR:=1;
        K_DESCERROR:=SUBSTR(SQLERRM, 1, 400);

END ADMPSI_CAMBIOTITULAR_HFC;

PROCEDURE ADMPSI_CAMBIOTITULAR_DTH (K_USUARIO   IN VARCHAR2,
                                  K_FECHAOPER IN DATE,
                                  K_NUMREGTOT OUT NUMBER,
                                  K_NUMREGPRO OUT NUMBER,
                                  K_NUMREGERR OUT NUMBER,
                                  K_CODERROR  OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2 ) is
--****************************************************************
-- Nombre SP           :  ADMPSI_CAMBIOTITULAR_DTH
-- Propósito           :  Actualizacion de los saldos de puntos por cambio de Titularidad
-- Input               :  K_USUARIO  - Usuario de Aplicativo
--                        K_FECHAOPER
-- Output              :  K_CODERROR  - Codigo de Error o Exito
--                        K_DESCERROR - Descripcion del Error (si se presento)
--                        K_NUMREGTOT - Numero Total de registros
--                        K_NUMREGPRO - Numero de Registros Procesados
--                        K_NUMREGERR - Numero de Registros con Error
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  22/05/2012
--****************************************************************

V_REGCLI     NUMBER;
C_PUNTOS     NUMBER;
/*-----------------*/
L_CLIPROD    LISTA_CLI_PRODUCTO;
DET_CLIPROD  CLI_PRODUCTO;
C_CUR_SQLERROR VARCHAR2(400);
/*----------------*/
C_CODCLI_PROD VARCHAR2(40);
V_TIPODOC    VARCHAR2(20);
C_NUMDOC     VARCHAR2(20);
C_NOMARCHIVO VARCHAR2(150);
C_FECOPER     DATE;

C_CUENTA_N    VARCHAR2(40);
C_TIPODOC_N   VARCHAR2(20);
C_NUMDOC_N    VARCHAR2(20);
C_NOMCLI_N    VARCHAR2(80);
C_APECLI_N    VARCHAR2(80);
C_SEXO_N      CHAR(1);
C_ESTCIV_N    VARCHAR2(20);
C_EMAIL_N     VARCHAR2(80);
C_PROV_N      VARCHAR2(30);
C_DEPA_N      VARCHAR2(40);
C_DISTR_N     VARCHAR2(200);
C_CICFACT_N   VARCHAR2(2);


EX_ERROR  EXCEPTION;
EX_SALDO  EXCEPTION;
NO_EXISTE EXCEPTION;
NO_USERS_CLIENTE EXCEPTION;


TYPE Cur_DatosCliente IS REF CURSOR;
C_CUR_DATOS_CLIE Cur_DatosCliente;


CURSOR CMB_TIT_DTH IS
select C.ADMPV_NUM_DOC,
       C.ADMPV_COD_CLI_PROD,
       C.ADMPV_NOM_ARCH,
       C.ADMPD_FEC_OPER
FROM PCLUB.ADMPT_TMP_CAMBTIT_DTH C
WHERE C.ADMPD_FEC_OPER=K_FECHAOPER AND
      (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='');

BEGIN
/*----------------------Validaciones para el Cliente Actual--------------------*/
  -- Verificar elNo ingreso el Tipo de Documento
 /* UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH D
     SET D.ADMPV_MSJE_ERROR = 'El Tipo de Documento es un DATO OBLIGATORIO.'
  WHERE  D.ADMPD_FEC_OPER= K_FECHAOPER AND
      (D.ADMPV_TIPO_DOC = '' OR D.ADMPV_TIPO_DOC IS NULL);
  */
  -- Verificar que el Cliente Actual no este en Baja en ClienteFija
   UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH TC
     SET ADMPV_MSJE_ERROR = 'El Cliente Actual esta en baja, no se puede Cambiar Titularidad'
   WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C, PCLUB.ADMPT_CLIENTEFIJA F
                            WHERE C.ADMPV_COD_CLI = F.ADMPV_COD_CLI
                             AND  C.ADMPV_COD_CLI_PROD = TC.ADMPV_COD_CLI_PROD
                             AND  F.ADMPV_COD_TPOCL='6' AND F.ADMPC_ESTADO='B' );

  --Verificar  que Existe el Cliente Actual y que sea Tipo de Cliente DTH, sino Error
   UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH TC
     SET ADMPV_MSJE_ERROR = 'El servicio no es un cliente DTH.'
   WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C, PCLUB.ADMPT_CLIENTEFIJA F
                 WHERE C.ADMPV_COD_CLI = F.ADMPV_COD_CLI   AND
                       C.ADMPV_COD_CLI_PROD = TC.ADMPV_COD_CLI_PROD AND  F.ADMPV_COD_TPOCL<>'6' );

   -- Solo podemos validar si el cliente existe en la tabla clienteproducto
   UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH TB
     SET ADMPV_MSJE_ERROR = 'El servicio no existe, no se le puede dar de baja.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
                     WHERE C.ADMPV_COD_CLI_PROD=TB.ADMPV_COD_CLI_PROD AND C.ADMPV_ESTADO_SERV='A');

  -- Validamos que el Servicio Actual no tenga saldos Negativos
   UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH TC
     SET ADMPV_MSJE_ERROR = 'El servicio, cuenta con saldo negativo.'
   WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C, PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                 WHERE C.ADMPV_COD_CLI_PROD = S.ADMPV_COD_CLI_PROD AND
                       C.ADMPV_COD_CLI_PROD = TC.ADMPV_COD_CLI_PROD AND  S.ADMPN_SALDO_CC<0 );

  ----------------------Validaciones para el Nuevo Cliente--------------------*/
/*  UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH
     SET ADMPC_COD_ERROR = '20',
         ADMPV_MSJE_ERROR = 'El codigo del Nuevo Cliente_Producto es obligatorio.'
  WHERE ADMPV_COD_CLI_PROD_N = '' OR ADMPV_COD_CLI_PROD_N IS NULL;*/

  -- Validamos que el Servicio Nuevo no exista en Alta
/*  UPDATE PCLUB.ADMPT_TMP_CAMBTIT_DTH TB
     SET ADMPV_MSJE_ERROR = 'El servicio para el Nuevo Cliente ya Existe, no se puede cambiar Titularidad'
  WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C WHERE C.ADMPV_COD_CLI_PROD=TB.ADMPV_COD_CLI_PROD_N AND C.ADMPV_ESTADO_SERV='A');
  COMMIT;*/

  OPEN CMB_TIT_DTH;
   FETCH CMB_TIT_DTH INTO C_NUMDOC,C_CODCLI_PROD, C_NOMARCHIVO, C_FECOPER;
    WHILE CMB_TIT_DTH %FOUND LOOP

     V_REGCLI :=0;
     C_PUNTOS :=0;

   SELECT COUNT(1) INTO V_REGCLI FROM
       PCLUB.ADMPT_AUX_CAMBTIT_DTH D
   WHERE D.ADMPV_COD_CLI_PROD = C_CODCLI_PROD AND D.ADMPD_FEC_OPER = K_FECHAOPER AND NVL(ADMPV_NOM_ARCH,NULL)  = C_NOMARCHIVO;

    L_CLIPROD := LISTA_CLI_PRODUCTO();
    L_CLIPROD.EXTEND(1);

    IF (V_REGCLI=0) THEN
        -- Insertamos en la auxiliar para los reprocesos
        DET_CLIPROD := CLI_PRODUCTO(NULL,NULL);

        DET_CLIPROD.COD_CLI_PROD  := C_CODCLI_PROD;
        DET_CLIPROD.DESC_PRODUCTO :='0062';

        L_CLIPROD(1)  := DET_CLIPROD;

        ADMPSS_DATOS_CLIENTEDTH(C_CODCLI_PROD, C_CUR_SQLERROR, C_CUR_DATOS_CLIE);

        -- El cursor retorno datos validos
        FETCH C_CUR_DATOS_CLIE
         INTO C_CUENTA_N, C_TIPODOC_N, C_NUMDOC_N, C_NOMCLI_N, C_APECLI_N, C_SEXO_N, C_ESTCIV_N, C_EMAIL_N, C_DEPA_N, C_PROV_N, C_DISTR_N, C_CICFACT_N;  --, C_TIPCLI_N ;
            IF C_NUMDOC_N is null THEN
              raise NO_USERS_CLIENTE;
            END IF;

            INSERT INTO PCLUB.ADMPT_AUX_CAMBTIT_DTH cc (cc.ADMPV_COD_CLI_PROD,cc.ADMPV_NUM_DOC,cc.ADMPD_FEC_OPER, cc.ADMPV_NOM_ARCH)
                                           VALUES (C_CODCLI_PROD, C_NUMDOC,C_FECOPER, C_NOMARCHIVO);

         select a.admpv_equ_fija f INTO V_TIPODOC
         from PCLUB.ADMPT_tipo_doc a
           inner join PCLUB.ADMPT_clientefija b on (b.admpv_tipo_doc=a.admpv_cod_tpdoc)
         where b.admpv_num_doc= C_NUMDOC and b.admpv_cod_tpocl='6';

         ADMPSI_CAMBTIT('6',L_CLIPROD,V_TIPODOC,C_NUMDOC,L_CLIPROD,C_TIPODOC_N, C_NUMDOC_N, C_NOMCLI_N, C_APECLI_N,C_SEXO_N,
                                               C_ESTCIV_N, C_EMAIL_N,  C_DEPA_N, C_PROV_N, C_DISTR_N, C_CICFACT_N,K_USUARIO,K_CODERROR,K_DESCERROR);
            IF K_CODERROR<>0 THEN
                UPDATE PCLUB.ADMPT_TMP_CAMBTIT_HFC
                SET   ADMPV_MSJE_ERROR= K_DESCERROR;
    --            WHERE ADMPV_NROOPERACION=OPER;
            END IF;
       CLOSE C_CUR_DATOS_CLIE;

     END IF;
     --COMMIT;
      FETCH CMB_TIT_DTH INTO C_NUMDOC,C_CODCLI_PROD, C_NOMARCHIVO, C_FECOPER;
   END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  --TOTALES
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_CAMBTIT_DTH
         WHERE ADMPD_FEC_OPER=K_FECHAOPER ;
  --PROCESADOS
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_CAMBTIT_DTH
         WHERE ADMPD_FEC_OPER=K_FECHAOPER AND ADMPV_MSJE_ERROR Is Not null;
  --CON ERROR
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_CAMBTIT_DTH
         WHERE ADMPD_FEC_OPER=K_FECHAOPER ;

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_CAMBTIT_DTH cc
( cc.ADMPN_ID_FILA,  cc.ADMPV_COD_CLI_PROD,cc.ADMPV_NUM_DOC,cc.ADMPD_FEC_OPER ,cc.ADMPV_NOM_ARCH,cc.ADMPV_MSJE_ERROR ,cc.ADMPD_FCH_TRANS, cc.ADMPN_SEQ)

  SELECT PCLUB.ADMPT_CAMBIOTT_DTH_HFC_SQ.nextval,v.admpv_cod_cli_prod,v.admpv_num_doc,v.admpd_fec_oper,v.admpv_nom_arch,V.ADMPV_MSJE_ERROR,sysdate,v.admpn_seq
     FROM PCLUB.ADMPT_TMP_CAMBTIT_DTH v
  WHERE V.ADMPD_FEC_OPER=K_FECHAOPER;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_CAMBTIT_DTH  WHERE ADMPD_FEC_OPER = K_FECHAOPER ;
   DELETE PCLUB.ADMPT_TMP_CAMBTIT_DTH  WHERE ADMPD_FEC_OPER = K_FECHAOPER ;

  COMMIT;
  K_CODERROR:= '0';
  K_DESCERROR:= '';

 EXCEPTION
   WHEN NO_EXISTE THEN
     K_CODERROR:= 1;
     K_DESCERROR:= 'Error el Concepto de Cambio de Titularidad para DTH, no Existe';
   WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
END ADMPSI_CAMBIOTITULAR_DTH;



PROCEDURE ADMPSI_ECAMBIOTITULAR_HFC( K_FECHAPROC IN DATE,CURSORCAMBTI OUT SYS_REFCURSOR) AS
BEGIN
OPEN CURSORCAMBTI  FOR
SELECT *--ADMPV_COD_CLI_PROD,ADMPV_ESTADO,ADMPV_TIP_DOC,ADMPV_NUM_DOC,ADMPV_MSJE_ERROR
             --ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPT,ADMPV_DIST,ADMPV_CIC_FAC,ADMPV_FEC_PRO,ADMPV_NROOPERACION,ADMPV_COD_ERROR,ADMPV_MSJE_ERROR
FROM PCLUB.ADMPT_IMP_CAMBTIT_HFC
    WHERE ADMPV_FEC_PRO=K_FECHAPROC
    AND (ADMPV_MSJE_ERROR IS NOT NULL
    OR ADMPV_MSJE_ERROR <>' ');
END ADMPSI_ECAMBIOTITULAR_HFC;


PROCEDURE ADMPSI_ECAMBIOTITULAR_DTH (K_FECHAPROC IN DATE, CURSORCAMBTI OUT SYS_REFCURSOR) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_ECAMBIOTITULAR_DTH
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Cambio de Titular
-- Input               :  K_FECHAPROC - Fecha de Proceso
-- Output              :  CURSORCAMBTI Cursor que Contiene Lista de Clientes de Cambio de Titularidad que generaron Errores
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  22/05/2012
--****************************************************************

BEGIN
OPEN CURSORCAMBTI FOR
SELECT
       C.ADMPV_COD_CLI_PROD,
       C.ADMPV_NUM_DOC,
       C.ADMPV_NOM_ARCH,
       C.ADMPD_FEC_OPER,
       C.ADMPV_MSJE_ERROR
FROM PCLUB.ADMPT_IMP_CAMBTIT_DTH C
     WHERE C.ADMPD_FEC_OPER=K_FECHAPROC
       AND ADMPV_MSJE_ERROR IS NOT NULL
       AND ADMPV_MSJE_ERROR <> ' ';
END ADMPSI_ECAMBIOTITULAR_DTH;


PROCEDURE ADMPSS_DATOS_CLIENTEDTH(K_CUSTCODE IN VARCHAR2,
                                       K_SQLERROR OUT VARCHAR2,
                                       K_CURSOR   IN OUT SYS_REFCURSOR) IS
    /****************************************************************
    '* Nombre SP           :  ADMPSS_DATOS_CLIEDTHPOSTPAGO
    '* Propósito           :  Buscar en la base de datos BSCS, los datos del cliente
    '* Input               :  K_CUSTCODE,
    '* Output              :  K_SQLERROR, K_CURSOR
    '* Creado por          :  Susana Ramos
    '* Fec Creación        :  18/07/2012
    '* Fec Actualización   :
    '****************************************************************/
    v_custcode varchar(40); --customer_all@DBL_BSCS.custcode%TYPE := '';
    -- Variable que almacena el numero de cuentas
    v_num_cuentas INTEGER := 0;
    -- Variable que almacena el numero de lineas
    v_num_lineas INTEGER := 0;

  BEGIN

    IF NVL(K_CUSTCODE, '0') <> '0' THEN
      v_custcode := K_CUSTCODE;
    END IF;

    IF v_custcode IS NOT NULL THEN
      SELECT COUNT(DISTINCT ccr.customer_id), SUM(ccr.a + ccr.s)
        INTO v_num_cuentas, v_num_lineas
        FROM tim.tim_consol_cliente_ref@DBL_BSCS ccr
       WHERE ccr.custcode LIKE v_custcode || '%';
    END IF;
    -- Cursor que devuelve el resultado
    OPEN K_CURSOR FOR
      SELECT    cu.custcode       cuenta,
                case when it.idtype_code='2' then '002'
                     else '0'   end tip_doc,
                cc.passportno  num_doc,
                cc.ccfname     nombre,
                cc.cclname     apellidos,
                cc.ccsex       sexo,
                ms.mas_des     estado_civil,
                cc.ccemail     email,
                cc.cccity      departamento_fac,
                cc.ccstreet    provincia_fac,
                cc.ccaddr3     distrito_fac,
                cu.billcycle   ciclo_fac/*,
                cu.prgcode     codigo_tipo_cliente,
                pg.prgname     tipo_cliente*/
    FROM customer_all@DBL_BSCS    cu,
             ccontact_all@DBL_BSCS    cc,
             ccontact_all@DBL_BSCS    cc2,
             id_type@DBL_BSCS         it,
             title@DBL_BSCS           t,
             country@DBL_BSCS         c,
             info_cust_combo@DBL_BSCS icc,
             marital_status@DBL_BSCS  ms,
             pricegroup_all@DBL_BSCS  pg,
             language@DBL_BSCS        la,
             payment_all@DBL_BSCS     pa,
             paymenttype_all@DBL_BSCS pt
       WHERE cu.customer_id = cc.customer_id
         AND cc.ccbill = 'X'
         AND cc2.ccforward(+) = 'X'
         AND cc2.ccseq(+) = 2
         AND cu.customer_id = cc2.customer_id(+)
         AND cc.id_type = it.idtype_code(+)
         AND cc.cctitle = t.ttl_id(+)
         AND cc.csnationality = c.country_id(+)
         AND cu.custcode = v_custcode
         AND icc.customer_id(+) = cu.customer_id
         AND cu.marital_status = ms.mas_id(+)
         AND cu.prgcode = pg.prgcode
         AND cu.cslanguage = la.lng_id(+)
         AND pa.payment_type = pt.payment_id
         AND cu.customer_id = pa.customer_id
         AND pa.seq_id = (SELECT MAX(seq_id)
                          FROM payment_all@DBL_BSCS
                          WHERE customer_id = pa.customer_id);
  EXCEPTION
    WHEN OTHERS THEN
      K_SQLERROR := 'Error TIM.PP004_SIAC_CONSULTAS.SP_DATOS_CLIEN: ' || TO_CHAR(SQLCODE) || ' ' || SQLERRM;
  END ADMPSS_DATOS_CLIENTEDTH;


PROCEDURE ADMPSS_BAJA       (K_TIP_CLI     IN VARCHAR2,
                             K_CODCLIENTE  IN VARCHAR2,
                             K_TIP_BAJA    IN VARCHAR2,
                             K_COD_CLIPROD IN VARCHAR2,
                             K_USUARIO    IN VARCHAR2,
                             K_CODERROR   OUT NUMBER,
                             K_DESCERROR  OUT VARCHAR2)
 IS
V_COD_NUEVO   NUMBER;
V_COD_CLINUE  VARCHAR2(40);

V_COD_PRODNUEVO  NUMBER;
V_COD_PRODCLINUE VARCHAR2(40);

V_REG         NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';


   V_COD_NUEVO  := 1;
   V_COD_CLINUE := '';

  IF K_TIP_BAJA='C' THEN
   WHILE V_COD_NUEVO > 0 LOOP
       V_COD_CLINUE := TRIM(K_CODCLIENTE) || '-' || TO_CHAR(V_COD_NUEVO);
       V_REG := 0;
       BEGIN
          SELECT COUNT(*) INTO V_REG
              FROM PCLUB.ADMPT_CLIENTEFIJA
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
  END IF;

  IF K_TIP_CLI='6' THEN
     V_COD_PRODNUEVO  := 1;
     V_COD_PRODCLINUE := '';
      WHILE V_COD_PRODNUEVO > 0 LOOP
         V_COD_PRODCLINUE := TRIM(K_COD_CLIPROD) || '-' || TO_CHAR(V_COD_PRODNUEVO);
         V_REG := 0;
         BEGIN
            SELECT COUNT(*) INTO V_REG
                FROM PCLUB.ADMPT_CLIENTEPRODUCTO
              WHERE ADMPV_COD_CLI_PROD = V_COD_PRODCLINUE;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   V_REG := 0;
         END;
            IF V_REG > 0 THEN
              V_COD_PRODNUEVO := V_COD_PRODNUEVO + 1;
            ELSE
              V_COD_PRODNUEVO := 0;
            END IF;
      END LOOP;
  END IF ;

  IF K_TIP_BAJA='C' THEN
      INSERT INTO PCLUB.ADMPT_CLIENTEFIJA(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,
                  ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACTIV,
                  ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPV_USU_REG)
      SELECT V_COD_CLINUE,F.ADMPV_COD_SEGCLI,F.ADMPN_COD_CATCLI,F.ADMPV_TIPO_DOC,F.ADMPV_NUM_DOC,F.ADMPV_NOM_CLI, F.ADMPV_APE_CLI,
             F.ADMPC_SEXO,F.ADMPV_EST_CIVIL,F.ADMPV_EMAIL,F.ADMPV_PROV,F.ADMPV_DEPA,F.ADMPV_DIST,F.ADMPD_FEC_ACTIV,
             F.ADMPC_ESTADO,F.ADMPV_COD_TPOCL,F.ADMPV_USU_REG
      FROM PCLUB.ADMPT_CLIENTEFIJA F
      WHERE F.ADMPV_COD_CLI = K_CODCLIENTE;
  END IF;

  IF K_TIP_CLI='6' THEN
    IF K_TIP_BAJA='C' THEN
      INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H  (H.ADMPV_COD_CLI_PROD, H.ADMPV_COD_CLI, H.ADMPV_SERVICIO,
                         H.ADMPV_ESTADO_SERV,  H.ADMPV_FEC_ULTANIV, H.ADMPV_USU_REG, H.ADMPV_INDICEGRUPO )
      VALUES(V_COD_PRODCLINUE, V_COD_CLINUE, '0062','B',SYSDATE, K_USUARIO, '1' );
    ELSE
      INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H  (H.ADMPV_COD_CLI_PROD, H.ADMPV_COD_CLI, H.ADMPV_SERVICIO,
                         H.ADMPV_ESTADO_SERV,  H.ADMPV_FEC_ULTANIV, H.ADMPV_USU_REG, H.ADMPV_INDICEGRUPO )
      VALUES(V_COD_PRODCLINUE, K_CODCLIENTE, '0062','B',SYSDATE, K_USUARIO, '1' );
    END IF ;
       UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
         SET ADMPV_USU_MOD=K_USUARIO , ADMPV_COD_CLI_PROD = V_COD_PRODCLINUE
       WHERE ADMPV_COD_CLI_PROD= K_COD_CLIPROD;

       UPDATE PCLUB.ADMPT_KARDEXFIJA
         SET ADMPV_USU_MOD=K_USUARIO , ADMPV_COD_CLI_PROD = V_COD_PRODCLINUE
       WHERE ADMPV_COD_CLI_PROD= K_COD_CLIPROD;
  ELSIF K_TIP_CLI='7' THEN
      UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
            SET ADMPV_COD_CLI=V_COD_CLINUE,   ADMPV_USU_MOD=K_USUARIO
      WHERE ADMPV_COD_CLI = K_CODCLIENTE;
  END IF ;

  IF K_TIP_BAJA='C' THEN
      UPDATE PCLUB.ADMPT_CANJEFIJA
            SET ADMPV_COD_CLI=V_COD_CLINUE,   ADMPD_FEC_MOD=SYSDATE,   ADMPV_USU_MOD=K_USUARIO
      WHERE ADMPV_COD_CLI = K_CODCLIENTE;

      UPDATE PCLUB.ADMPT_CLIENTEFIJA
             SET ADMPC_ESTADO='B',  ADMPV_USU_MOD=K_USUARIO
      WHERE ADMPV_COD_CLI = V_COD_CLINUE;
  END IF ;

  IF K_TIP_CLI='6' THEN
    DELETE PCLUB.ADMPT_CLIENTEPRODUCTO
    WHERE ADMPV_COD_CLI= K_CODCLIENTE AND ADMPV_COD_CLI_PROD= K_COD_CLIPROD;

   IF  K_TIP_BAJA='C' THEN
     DELETE PCLUB.ADMPT_CLIENTEFIJA
     WHERE ADMPV_COD_CLI= K_CODCLIENTE;
   END IF ;

  ELSIF K_TIP_CLI='7' THEN
      DELETE PCLUB.ADMPT_CLIENTEFIJA
      WHERE ADMPV_COD_CLI= K_CODCLIENTE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
END ADMPSS_BAJA;

/*SUSANA*/
/*JCGT MIGRACION*/

PROCEDURE ADMPSI_MIGRACLIENTEHFC(K_FEC_PROCESO IN DATE,K_USUARIO IN VARCHAR2, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER,
                                                K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) AS
TYPE REGALTACLI IS RECORD(
 COD_CLI_PROD VARCHAR2(40),
 TIPO_DOC VARCHAR2(20),
  NUM_DOC VARCHAR2(20),
  NOM_CLI VARCHAR2(80),
  APE_CLI VARCHAR2(80),
  SEXO CHAR(1),
  EST_CIVIL VARCHAR2(20),
  EMAIL VARCHAR2(80),
  PROV VARCHAR2(30),
  DEPA VARCHAR2(40),
  DIST VARCHAR2(200),
  FEC_ACT DATE,
  FEC_OPER DATE,
  NOM_ARCH VARCHAR2(150),
  COD_ERROR CHAR(3),
  MSJE_ERROR VARCHAR2(400),
  SEQ NUMBER,
  CICL_FACT VARCHAR2(2),
  SERVICIO VARCHAR(20)
   );

  vREGCLI  REGALTACLI;

CURSOR ALTACLI IS
SELECT *
FROM PCLUB.ADMPT_TMP_ALTACLI_HFC D
WHERE  D.ADMPD_FEC_OPER = K_FEC_PROCESO
AND (D.ADMPV_MSJE_ERROR IS NULL OR D.ADMPV_MSJE_ERROR ='');

V_REGCLI NUMBER;
C_CODCLI VARCHAR2(40);
COD_SALDO VARCHAR2(40);
V_IDSALDO  NUMBER;
V_IND_COD VARCHAR2(2);

BEGIN

K_CODERROR:=0;
K_DESCERROR:='';

UPDATE  PCLUB.ADMPT_TMP_ALTACLI_HFC
SET ADMPV_MSJE_ERROR='El codigo de servicio es un dato obligatorio.'
WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
AND ADMPV_COD_CLI_PROD IS NULL;

UPDATE  PCLUB.ADMPT_TMP_ALTACLI_HFC
SET ADMPV_MSJE_ERROR='El codigo y tipo de documento son datos obligatorios.'
WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
AND (ADMPV_TIPO_DOC IS NULL OR ADMPV_NUM_DOC IS NULL);

UPDATE  PCLUB.ADMPT_TMP_ALTACLI_HFC T
SET T.ADMPV_MSJE_ERROR='El codigo de servicio ya se encuentra registrado.'
WHERE T.ADMPD_FEC_OPER = K_FEC_PROCESO
AND (T.ADMPV_MSJE_ERROR IS NULL OR T.ADMPV_MSJE_ERROR ='')
AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_COD_CLI_PROD = T.ADMPV_COD_CLI_PROD ) ;

UPDATE PCLUB.ADMPT_TMP_ALTACLI_HFC T
SET T.ADMPV_TIPO_DOC=(SELECT D.ADMPV_COD_TPDOC  FROM PCLUB.ADMPT_TIPO_DOC D WHERE D.ADMPV_EQU_FIJA=T.ADMPV_TIPO_DOC)
WHERE T.ADMPV_MSJE_ERROR IS NULL OR T.ADMPV_MSJE_ERROR ='';

UPDATE PCLUB.ADMPT_TMP_ALTACLI_HFC T
SET T.ADMPV_MSJE_ERROR='El tipo de documento no existe en CC.'
WHERE T.ADMPV_TIPO_DOC IS NULL AND (T.ADMPV_MSJE_ERROR IS NULL OR T.ADMPV_MSJE_ERROR ='');


OPEN ALTACLI;
     FETCH ALTACLI INTO vREGCLI;

     WHILE ALTACLI%FOUND
       LOOP

          SELECT COUNT(*) INTO V_REGCLI
          FROM PCLUB.ADMPT_AUX_ALTACLI_HFC T
          WHERE T.ADMPV_TIPO_DOC = vREGCLI.TIPO_DOC
          AND T.ADMPV_NUM_DOC = vREGCLI.NUM_DOC
          AND T.ADMPV_COD_CLI_PROD = vREGCLI.COD_CLI_PROD
          AND T.ADMPD_FEC_OPER = vREGCLI.FEC_OPER
          AND T.ADMPV_NOM_ARCH = vREGCLI.NOM_ARCH;

           IF V_REGCLI = 0 THEN

              --generamos el codigo unico que nos permitira identificar
              C_CODCLI:= vREGCLI.TIPO_DOC||'.'||vREGCLI.NUM_DOC||'.'||'7';

              SELECT COUNT(*) INTO V_REGCLI
              FROM PCLUB.ADMPT_CLIENTEFIJA C
              WHERE C.ADMPV_COD_CLI = C_CODCLI--C.ADMPV_TIPO_DOC = vREGCLI.TIPO_DOC
              --AND C.ADMPV_NUM_DOC = vREGCLI.NUM_DOC
              AND C.ADMPV_COD_TPOCL = '7'
              AND C.ADMPC_ESTADO = 'A';

                IF V_REGCLI = 0 THEN
                  INSERT INTO PCLUB.ADMPT_CLIENTEFIJA H
                  (H.ADMPV_COD_CLI,
                   H.ADMPV_COD_SEGCLI,
                   H.ADMPN_COD_CATCLI,
                   H.ADMPV_TIPO_DOC,
                   H.ADMPV_NUM_DOC,
                   H.ADMPV_NOM_CLI,
                   H.ADMPV_APE_CLI,
                   H.ADMPC_SEXO,
                   H.ADMPV_EST_CIVIL,
                   H.ADMPV_EMAIL,
                   H.ADMPV_PROV,
                   H.ADMPV_DEPA,
                   H.ADMPV_DIST,
                   H.ADMPD_FEC_ACTIV,
                   --H.ADMPV_CICL_FACT,
                   H.ADMPC_ESTADO,
                   H.ADMPV_COD_TPOCL,
                   H.ADMPD_FEC_REG,
                   H.ADMPV_USU_REG)
                VALUES
                  (C_CODCLI,
                   NULL,
                   2,
                   vREGCLI.TIPO_DOC,
                   vREGCLI.NUM_DOC,
                   vREGCLI.NOM_CLI,
                   vREGCLI.APE_CLI,
                   vREGCLI.SEXO,
                   vREGCLI.EST_CIVIL,
                   vREGCLI.EMAIL,
                   vREGCLI.PROV,
                   vREGCLI.DEPA,
                   vREGCLI.DIST,
                   SYSDATE,
                   --vREGCLI.CICL_FACT,
                   'A',
                   '7',
                   SYSDATE,
                   K_USUARIO);

                  END IF;

               SELECT SUBSTR(vREGCLI.COD_CLI_PROD,LENGTH(vREGCLI.COD_CLI_PROD),1) INTO V_IND_COD
                  FROM DUAL;


               INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H (H.ADMPV_COD_CLI_PROD,H.ADMPV_COD_CLI,H.ADMPV_SERVICIO,H.ADMPV_ESTADO_SERV,
                 H.ADMPV_FEC_ULTANIV,H.ADMPD_FEC_REG,H.ADMPV_USU_REG,H.ADMPV_INDICEGRUPO,H.ADMPV_CICL_FACT)
               VALUES(vREGCLI.COD_CLI_PROD,C_CODCLI,vREGCLI.SERVICIO,'A',SYSDATE,SYSDATE,K_USUARIO,V_IND_COD,vREGCLI.CICL_FACT);

                -- Debemos verificar si el cliente tiene algun saldo asociado
              BEGIN

                 SELECT G.ADMPV_COD_CLI_PROD INTO COD_SALDO
                 FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA G      /*CAMBIAR ESTA TABLA*/
                 WHERE ADMPV_COD_CLI_PROD = vREGCLI.COD_CLI_PROD;

                 UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                 SET ADMPN_SALDO_CC=0,
                 ADMPN_COD_CLI_IB=NULL,
                 ADMPN_SALDO_IB=0,
                 ADMPC_ESTPTO_CC= 'A',
                 ADMPC_ESTPTO_IB=NULL,
                 ADMPD_FEC_MOD=SYSDATE,
                 ADMPV_USU_MOD=K_USUARIO
                 WHERE ADMPV_COD_CLI_PROD = COD_SALDO;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN

                   /**Generar secuencial de Saldo*/
                  SELECT PCLUB.ADMPT_SLD_CLFIJA_SQ.NEXTVAL INTO V_IDSALDO FROM DUAL;

                  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA        /*CAMBIAR ESTA TABLA*/
                    (ADMPN_ID_SALDO,
                     ADMPV_COD_CLI_PROD,
                     ADMPN_COD_CLI_IB,
                     ADMPN_SALDO_CC,
                     ADMPN_SALDO_IB,
                     ADMPC_ESTPTO_CC,
                     ADMPC_ESTPTO_IB,
                     ADMPD_FEC_REG,
                     ADMPV_USU_REG)
                  VALUES
                    (V_IDSALDO, vREGCLI.COD_CLI_PROD, NULL, 0.00, 0.00, 'A', NULL,SYSDATE,K_USUARIO);


              END;

               INSERT INTO PCLUB.ADMPT_AUX_ALTACLI_HFC VALUES(vREGCLI.COD_CLI_PROD,vREGCLI.TIPO_DOC,vREGCLI.NUM_DOC,vREGCLI.FEC_OPER,vREGCLI.NOM_ARCH);


           END IF;

        FETCH ALTACLI INTO vREGCLI;
       END LOOP;

-- Exportar datos a la tabla PCLUB.ADMPT_imp_pago_cc
    INSERT INTO PCLUB.ADMPT_IMP_ALTACLI_HFC
    SELECT  PCLUB.ADMPT_ALTADTH_SQ.NEXTVAL , ADMPV_COD_CLI_PROD, ADMPV_TIPO_DOC , ADMPV_NUM_DOC, ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,
    ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACT,ADMPD_FEC_OPER, ADMPV_NOM_ARCH,ADMPV_COD_ERROR, ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_TMP_ALTACLI_HFC
    WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
    SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ALTACLI_HFC WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;
    SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ALTACLI_HFC WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NOT NULL);
    SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ALTACLI_HFC WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_ALTACLI_HFC WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;
   DELETE PCLUB.ADMPT_TMP_ALTACLI_HFC WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;

COMMIT;

EXCEPTION
        WHEN OTHERS THEN
            K_CODERROR:=1;
            K_DESCERROR:=SUBSTR(SQLERRM,250);
END ADMPSI_MIGRACLIENTEHFC;

PROCEDURE ADMPSI_EMIGRACLIENTEHFC(K_FEC_PROCESO IN DATE,CURCLIENTES OUT SYS_REFCURSOR) IS

BEGIN
    OPEN  CURCLIENTES FOR
    SELECT I.ADMPV_COD_CLI_PROD,I.ADMPV_TIPO_DOC,I.ADMPV_NUM_DOC,I.ADMPV_MSJE_ERROR,
               TO_CHAR(I.ADMPD_FEC_ACT,'DD/MM/YYYY') FEC_ACT
    FROM PCLUB.ADMPT_IMP_ALTACLI_HFC I
    WHERE I.ADMPD_FEC_OPER=K_FEC_PROCESO
    AND (I.ADMPV_MSJE_ERROR IS NOT NULL OR I.ADMPV_MSJE_ERROR <>'');

END ADMPSI_EMIGRACLIENTEHFC;

PROCEDURE ADMPSS_VLD_CAMTIT       (K_TIP_CLI        IN VARCHAR2,
                             K_COD_CLIPROD    IN LISTA_CLI_PRODUCTO,
                             K_TIPODOC        IN VARCHAR2,
                             K_NUMDOC         IN VARCHAR2,
                             K_CODERROR   OUT NUMBER,
                             K_DESCERROR  OUT VARCHAR2)
 IS
V_COUNT   INTEGER;
V_CLI_PRODUCTO CLI_PRODUCTO;

BEGIN
  FOR I IN K_COD_CLIPROD.FIRST .. K_COD_CLIPROD.LAST
  LOOP
      V_CLI_PRODUCTO := K_COD_CLIPROD(I);

       SELECT COUNT(1) INTO V_COUNT FROM PCLUB.ADMPT_CLIENTEPRODUCTO CP
       INNER JOIN PCLUB.ADMPT_CLIENTEFIJA CF
       ON CP.ADMPV_COD_CLI=CF.ADMPV_COD_CLI
       WHERE CF.ADMPV_NUM_DOC=K_NUMDOC
       AND CF.ADMPV_TIPO_DOC=K_TIPODOC
       AND CP.ADMPV_COD_CLI_PROD=V_CLI_PRODUCTO.COD_CLI_PROD
       AND CF.ADMPV_COD_TPOCL=K_TIP_CLI;

       IF V_COUNT=0 THEN
          K_CODERROR := 1;
          K_DESCERROR :='El cliente no tiene asociado este servicio.';
          EXIT;
       ELSE
          K_CODERROR := 0;
          K_DESCERROR :='';
       END IF;
  END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
END ADMPSS_VLD_CAMTIT;


PROCEDURE ADMPSI_ALTACLIENTEDTH(K_FEC_PROCESO IN DATE,K_USUARIO IN VARCHAR2, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER,
                                                K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) AS
TYPE REGALTACLI IS RECORD(
 COD_CLI_PROD VARCHAR2(40),
 TIPO_DOC VARCHAR2(20),
  NUM_DOC VARCHAR2(20),
  NOM_CLI VARCHAR2(80),
  APE_CLI VARCHAR2(80),
  SEXO CHAR(1),
  EST_CIVIL VARCHAR2(20),
  EMAIL VARCHAR2(80),
  PROV VARCHAR2(30),
  DEPA VARCHAR2(40),
  DIST VARCHAR2(200),
  FEC_ACT DATE,
  FEC_OPER DATE,
  NOM_ARCH VARCHAR2(150),
  COD_ERROR CHAR(3),
  MSJE_ERROR VARCHAR2(400),
  SEQ NUMBER,
  CICL_FACT VARCHAR2(2)
   );

  vREGCLI  REGALTACLI;

CURSOR ALTACLI IS
SELECT *
FROM PCLUB.ADMPT_TMP_ALTACLI_DTH D
WHERE  D.ADMPD_FEC_OPER = K_FEC_PROCESO
AND (D.ADMPV_MSJE_ERROR IS NULL OR D.ADMPV_MSJE_ERROR ='');

V_REGCLI NUMBER;
V_REGCONT NUMBER;
C_CODCLI VARCHAR2(40);
COD_SALDO VARCHAR2(40);
V_IDSALDO  NUMBER;

/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
/*CUPONERAVIRTUAL - JCGT FIN*/

BEGIN

K_CODERROR:=0;
K_DESCERROR:='';

UPDATE  PCLUB.ADMPT_TMP_ALTACLI_DTH
SET ADMPV_MSJE_ERROR='El codigo de servicio es un dato obligatorio.'
WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
AND ADMPV_COD_CLI_PROD IS NULL;

UPDATE  PCLUB.ADMPT_TMP_ALTACLI_DTH
SET ADMPV_MSJE_ERROR='El codigo y tipo de documento son datos obligatorios.'
WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
AND (ADMPV_TIPO_DOC IS NULL OR ADMPV_NUM_DOC IS NULL);

UPDATE  PCLUB.ADMPT_TMP_ALTACLI_DTH T
SET T.ADMPV_MSJE_ERROR='El codigo de servicio ya se encuentra registrado.'
WHERE T.ADMPD_FEC_OPER = K_FEC_PROCESO
AND (T.ADMPV_MSJE_ERROR IS NULL OR T.ADMPV_MSJE_ERROR ='')
AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_COD_CLI_PROD = T.ADMPV_COD_CLI_PROD ) ;

OPEN ALTACLI;
     FETCH ALTACLI INTO vREGCLI;

     WHILE ALTACLI%FOUND
       LOOP

          SELECT COUNT(*) INTO V_REGCLI
          FROM PCLUB.ADMPT_AUX_ALTACLI_DTH T
          WHERE T.ADMPV_TIPO_DOC = vREGCLI.TIPO_DOC
          AND T.ADMPV_NUM_DOC = vREGCLI.NUM_DOC
          AND T.ADMPV_COD_CLI_PROD = vREGCLI.COD_CLI_PROD
          AND T.ADMPD_FEC_OPER = vREGCLI.FEC_OPER
          AND T.ADMPV_NOM_ARCH = vREGCLI.NOM_ARCH;

           IF V_REGCLI = 0 THEN

              --generamos el codigo unico que nos permitira identificar
              C_CODCLI:= vREGCLI.TIPO_DOC||'.'||vREGCLI.NUM_DOC||'.'||'6';

              SELECT COUNT(*) INTO V_REGCLI
              FROM PCLUB.ADMPT_CLIENTEFIJA C
              WHERE C.ADMPV_COD_CLI = C_CODCLI--C.ADMPV_TIPO_DOC = vREGCLI.TIPO_DOC
              --AND C.ADMPV_NUM_DOC = vREGCLI.NUM_DOC
              AND C.ADMPV_COD_TPOCL = '6'
              AND C.ADMPC_ESTADO = 'A';

                IF V_REGCLI = 0 THEN
                  INSERT INTO PCLUB.ADMPT_CLIENTEFIJA H
                  (H.ADMPV_COD_CLI,
                   H.ADMPV_COD_SEGCLI,
                   H.ADMPN_COD_CATCLI,
                   H.ADMPV_TIPO_DOC,
                   H.ADMPV_NUM_DOC,
                   H.ADMPV_NOM_CLI,
                   H.ADMPV_APE_CLI,
                   H.ADMPC_SEXO,
                   H.ADMPV_EST_CIVIL,
                   H.ADMPV_EMAIL,
                   H.ADMPV_PROV,
                   H.ADMPV_DEPA,
                   H.ADMPV_DIST,
                   H.ADMPD_FEC_ACTIV,
                   --H.ADMPV_CICL_FACT,
                   H.ADMPC_ESTADO,
                   H.ADMPV_COD_TPOCL,
                   H.ADMPD_FEC_REG,
                   H.ADMPV_USU_REG)
                VALUES
                  (C_CODCLI,
                   NULL,
                   2,
                   vREGCLI.TIPO_DOC,
                   vREGCLI.NUM_DOC,
                   vREGCLI.NOM_CLI,
                   vREGCLI.APE_CLI,
                   vREGCLI.SEXO,
                   vREGCLI.EST_CIVIL,
                   vREGCLI.EMAIL,
                   vREGCLI.PROV,
                   vREGCLI.DEPA,
                   vREGCLI.DIST,
                   SYSDATE,
                   --vREGCLI.CICL_FACT,
                   'A',
                   '6',
                   SYSDATE,
                   K_USUARIO);

                  END IF;

               INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H (H.ADMPV_COD_CLI_PROD,H.ADMPV_COD_CLI,H.ADMPV_SERVICIO,H.ADMPV_ESTADO_SERV,
                 H.ADMPV_FEC_ULTANIV,H.ADMPD_FEC_REG,H.ADMPV_USU_REG,H.ADMPV_INDICEGRUPO,H.ADMPV_CICL_FACT)
               VALUES(vREGCLI.COD_CLI_PROD,C_CODCLI,'0062','A',SYSDATE,SYSDATE,K_USUARIO,1,vREGCLI.CICL_FACT);

                -- Debemos verificar si el cliente tiene algun saldo asociado
              BEGIN

                 SELECT G.ADMPV_COD_CLI_PROD INTO COD_SALDO
                 FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA G      /*CAMBIAR ESTA TABLA*/
                 WHERE ADMPV_COD_CLI_PROD = vREGCLI.COD_CLI_PROD;

                 UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                 SET ADMPN_SALDO_CC=0,
                 ADMPN_COD_CLI_IB=NULL,
                 ADMPN_SALDO_IB=0,
                 ADMPC_ESTPTO_CC= 'A',
                 ADMPC_ESTPTO_IB=NULL,
                 ADMPD_FEC_MOD=SYSDATE,
                 ADMPV_USU_MOD=K_USUARIO
                 WHERE ADMPV_COD_CLI_PROD = COD_SALDO;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN

                   /**Generar secuencial de Saldo*/
                  SELECT PCLUB.ADMPT_SLD_CLFIJA_SQ.NEXTVAL INTO V_IDSALDO FROM DUAL;

                  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA        /*CAMBIAR ESTA TABLA*/
                    (ADMPN_ID_SALDO,
                     ADMPV_COD_CLI_PROD,
                     ADMPN_COD_CLI_IB,
                     ADMPN_SALDO_CC,
                     ADMPN_SALDO_IB,
                     ADMPC_ESTPTO_CC,
                     ADMPC_ESTPTO_IB,
                     ADMPD_FEC_REG,
                     ADMPV_USU_REG)
                  VALUES
                    (V_IDSALDO, vREGCLI.COD_CLI_PROD, NULL, 0.00, 0.00, 'A', NULL,SYSDATE,K_USUARIO);


              END;

               INSERT INTO PCLUB.ADMPT_AUX_ALTACLI_DTH VALUES(vREGCLI.COD_CLI_PROD,vREGCLI.TIPO_DOC,vREGCLI.NUM_DOC,vREGCLI.FEC_OPER,vREGCLI.NOM_ARCH);

               /*CUPONERAVIRTUAL - JCGT INI*/
                PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(vREGCLI.TIPO_DOC,vREGCLI.NUM_DOC,vREGCLI.NOM_CLI,vREGCLI.APE_CLI,vREGCLI.EMAIL,'ALTA',K_USUARIO,C_CODERROR,C_DESCERROR);
                /*CUPONERAVIRTUAL - JCGT FIN*/

           ELSE

              UPDATE PCLUB.ADMPT_TMP_ALTACLI_DTH T
              SET T.ADMPV_MSJE_ERROR='El cliente ya fue procesado.',
                    T.ADMPV_COD_ERROR='101'
              WHERE T.ADMPV_TIPO_DOC = vREGCLI.TIPO_DOC
              AND T.ADMPV_NUM_DOC = vREGCLI.NUM_DOC
              AND T.ADMPV_COD_CLI_PROD = vREGCLI.COD_CLI_PROD
              AND T.ADMPD_FEC_OPER = vREGCLI.FEC_OPER
              AND T.ADMPV_NOM_ARCH = vREGCLI.NOM_ARCH;

           END IF;

        FETCH ALTACLI INTO vREGCLI;
       END LOOP;

-- Exportar datos a la tabla PCLUB.ADMPT_imp_pago_cc
    INSERT INTO PCLUB.ADMPT_IMP_ALTACLI_DTH
    SELECT  PCLUB.ADMPT_ALTACLIDTH_SQ.NEXTVAL , ADMPV_COD_CLI_PROD, ADMPV_TIPO_DOC , ADMPV_NUM_DOC, ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,
    ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACT,ADMPD_FEC_OPER, ADMPV_NOM_ARCH,ADMPV_COD_ERROR, ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_TMP_ALTACLI_DTH
    WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
    SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ALTACLI_DTH WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;
    SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ALTACLI_DTH WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NOT NULL);
    SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ALTACLI_DTH WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_ALTACLI_DTH WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;
   DELETE PCLUB.ADMPT_TMP_ALTACLI_DTH  WHERE ADMPD_FEC_OPER=K_FEC_PROCESO;

COMMIT;

EXCEPTION
        WHEN OTHERS THEN
            K_CODERROR:=1;
            K_DESCERROR:=SUBSTR(SQLERRM,250);
END ADMPSI_ALTACLIENTEDTH;

PROCEDURE ADMPSI_EALTACLIENTEDTH(K_FEC_PROCESO IN DATE,CURCLIENTES OUT SYS_REFCURSOR) IS

BEGIN
    OPEN  CURCLIENTES FOR
    SELECT I.ADMPV_COD_CLI_PROD,I.ADMPV_TIPO_DOC,I.ADMPV_NUM_DOC,I.ADMPV_MSJE_ERROR,
               TO_CHAR(I.ADMPD_FEC_ACT,'DD/MM/YYYY') FEC_ACT
    FROM PCLUB.ADMPT_IMP_ALTACLI_DTH I
    WHERE I.ADMPD_FEC_OPER=K_FEC_PROCESO
    AND (I.ADMPV_MSJE_ERROR IS NOT NULL OR I.ADMPV_MSJE_ERROR <>'');

END ADMPSI_EALTACLIENTEDTH;


PROCEDURE ADMPSI_BAJACLIENTEDTH(K_FECHA IN DATE,K_USUARIO IN VARCHAR2,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_BAJACLIC
-- Propósito           :  Actualizar los saldos de los clientes que se dieron de baja
-- Input               :    K_FECHAPROCESO
-- Output              :    K_CODERROR Codigo de Error o Exito
--                              K_DESCERROR Descripcion del Error (si se presento)
-- Fec Creaci?n        :  15/05/2012
  --Autor               :   Juan Carlos Gutiérrez Trujillo
--****************************************************************

V_REGCLI NUMBER;
C_FECOPER DATE;
C_NOMARCHIVO VARCHAR2(150);
C_CODCLIENTE VARCHAR2(40);
C_CODCLIENTE_PROD VARCHAR2(40);
V_SALDO_CLI NUMBER;
V_SALDO_CLI_S NUMBER;
V_COD_CPTO VARCHAR2(2);
V_COD_CPTO2 VARCHAR2(2);
C_FECBAJA DATE;
V_REG NUMBER;
V_CLIENTE_AUX VARCHAR2(40);
V_COD_NUEVO  NUMBER;
V_COD_CLINUE VARCHAR2(40);
EX_ERROR EXCEPTION;
/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  K_TIPODOC VARCHAR2(20);
  K_NUMDOC VARCHAR2(20);
  C_COD_CLICUP NUMBER;
/*CUPONERAVIRTUAL - JCGT FIN*/
CURSOR BAJA_CLIENTES IS
  SELECT a.ADMPV_COD_CLI_PROD,
         a.admpd_fch_baja,
         a.ADMPD_FEC_OPER,
         a.ADMPV_NOM_ARCH
  FROM PCLUB.ADMPT_TMP_BAJACLI_DTH a
  WHERE a.ADMPD_FEC_OPER=K_FECHA
        AND (a.ADMPV_MSJE_ERROR IS NULL or a.ADMPV_MSJE_ERROR='');

 BEGIN

 K_CODERROR:=0;
 K_DESCERROR:=' ';
 -- si no envian el codigo de clienteproducto
   UPDATE PCLUB.ADMPT_TMP_BAJACLI_DTH
   SET ADMPV_MSJE_ERROR = 'El codigo de servicio es obligatorio.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
   AND (ADMPV_COD_CLI_PROD = '' OR ADMPV_COD_CLI_PROD IS NULL);

  -- Solo podemos validar si el cliente existe en la tabla clienteproducto
   UPDATE PCLUB.ADMPT_TMP_BAJACLI_DTH TB
   SET ADMPV_MSJE_ERROR = 'El codigo de servicio no existe, no se le puede dar de baja.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
   AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C WHERE C.ADMPV_COD_CLI_PROD=TB.ADMPV_COD_CLI_PROD );

   -- Solo podemos validar si el cliente NO ES DTH
   UPDATE PCLUB.ADMPT_TMP_BAJACLI_DTH TB
   SET ADMPV_MSJE_ERROR = 'El codigo de servicio no es un cliente DTH.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
   AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C, PCLUB.ADMPT_CLIENTEFIJA F
                            WHERE C.ADMPV_COD_CLI=F.ADMPV_COD_CLI
                            AND C.ADMPV_COD_CLI_PROD=TB.ADMPV_COD_CLI_PROD
                            AND F.ADMPV_COD_TPOCL<>'6' );

    -- El cliente esta de baja
   UPDATE PCLUB.ADMPT_TMP_BAJACLI_DTH TB
   SET ADMPV_MSJE_ERROR = 'El cliente se encuentra de baja.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
   AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C, PCLUB.ADMPT_CLIENTEFIJA F
                            WHERE C.ADMPV_COD_CLI=F.ADMPV_COD_CLI
                            AND C.ADMPV_COD_CLI_PROD=TB.ADMPV_COD_CLI_PROD
                            AND F.ADMPC_ESTADO='B' );

       -- El servicio esta de baja
   UPDATE PCLUB.ADMPT_TMP_BAJACLI_DTH TB
   SET ADMPV_MSJE_ERROR = 'El servicio se encuentra de baja.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
   AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
                            WHERE  C.ADMPV_COD_CLI_PROD=TB.ADMPV_COD_CLI_PROD
                            AND C.ADMPV_ESTADO_SERV='B' );

   BEGIN
      --SE ALMACENA EL CODIGO DEL CONCEPTO 'BAJA CLIENTE PREPAGO'
      SELECT ADMPV_COD_CPTO
      INTO V_COD_CPTO
      FROM PCLUB.ADMPT_CONCEPTO
      WHERE ADMPV_DESC = 'BAJA CLIENTE DTH';--BAJA CLIENTE DTH
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
       K_CODERROR:=9;
       K_DESCERROR:='BAJA CLIENTE DTH';
       RAISE EX_ERROR;
   END;

    BEGIN
      --SE ALMACENA EL CODIGO DEL CONCEPTO 'INGRESO POR BAJA CLIENTE PREPAGO'
      SELECT ADMPV_COD_CPTO
      INTO V_COD_CPTO2
      FROM PCLUB.ADMPT_CONCEPTO
      WHERE ADMPV_DESC = 'INGRESO POR BAJA CLIENTE DTH';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       K_CODERROR:=9;
       K_DESCERROR:='INGRESO POR BAJA CLIENTE DTH';
       RAISE EX_ERROR;
    END;

  OPEN BAJA_CLIENTES;
  FETCH BAJA_CLIENTES INTO C_CODCLIENTE_PROD,C_FECBAJA,C_FECOPER, C_NOMARCHIVO;
  WHILE BAJA_CLIENTES %FOUND LOOP

     V_REGCLI :=0;
     V_SALDO_CLI := 0;
     V_SALDO_CLI_S := 0;


     SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.ADMPT_AUX_BAJACLI_DTH B
     WHERE B.ADMPV_COD_CLI_PROD = C_CODCLIENTE_PROD
           AND B.ADMPD_FCH_BAJA = C_FECBAJA
           AND B.ADMPD_FEC_OPER = C_FECOPER
           AND B.ADMPV_NOM_ARCH = C_NOMARCHIVO;

     IF (V_REGCLI=0) THEN
        BEGIN

            SELECT MAX(F.ADMPV_COD_CLI),MAX(F.ADMPV_TIPO_DOC),MAX(F.ADMPV_NUM_DOC) INTO C_CODCLIENTE,K_TIPODOC,K_NUMDOC/*SELECT MAX(F.ADMPV_COD_CLI) INTO C_CODCLIENTE*/
              FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
             WHERE F.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
                   P.ADMPV_COD_CLI_PROD = C_CODCLIENTE_PROD;

            BEGIN

               V_CLIENTE_AUX := NULL;

                SELECT COD_CLI INTO V_CLIENTE_AUX
                FROM (SELECT P.ADMPV_COD_CLI_PROD COD_CLI
                        FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
                       WHERE F.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
                             F.ADMPV_COD_CLI = C_CODCLIENTE AND
                             P.ADMPV_COD_CLI_PROD <> C_CODCLIENTE_PROD AND
                             F.ADMPV_COD_TPOCL = '6' AND
                             F.ADMPC_ESTADO = 'A' AND
                             P.ADMPV_ESTADO_SERV = 'A'
                             ORDER BY P.ADMPD_FEC_REG)
                  WHERE ROWNUM=1;

            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      V_CLIENTE_AUX := null;
            END;

            BEGIN
                V_SALDO_CLI := 0.00;
                SELECT ADMPN_SALDO_CC INTO V_SALDO_CLI
                  FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                 WHERE ADMPV_COD_CLI_PROD = C_CODCLIENTE_PROD;

            EXCEPTION
                  WHEN NO_DATA_FOUND THEN V_SALDO_CLI := 0.00;
            END;

            IF V_SALDO_CLI >= 0 THEN

                  --SE ACTUALIZA LA TABLA PCLUB.ADMPT_KARDEXFIJA
                  UPDATE PCLUB.ADMPT_KARDEXFIJA
                  SET ADMPN_SLD_PUNTO=0,
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPC_TPO_OPER='E'
                  AND ADMPC_TPO_PUNTO IN ('C','L')
                  AND ADMPN_SLD_PUNTO>0
                  AND ADMPV_COD_CLI_PROD = C_CODCLIENTE_PROD;

                  --SE INSERTA EL REGISTRO DE SALIDA EN LA TABLA PCLUB.ADMPT_KARDEXFIJA
                  V_SALDO_CLI_S:=V_SALDO_CLI*(-1);
                  IF V_SALDO_CLI>0 THEN
                      INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,ADMPD_FEC_TRANS
                      ,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG,ADMPV_NOM_ARCH)
                      VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,C_CODCLIENTE_PROD,V_COD_CPTO,SYSDATE,
                      V_SALDO_CLI_S,'S','C',0,'A',K_USUARIO,SYSDATE,C_NOMARCHIVO);
                  END IF;
                  --SE ACTUALIZA EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE AL CLIENTE QUE SE DA DE BAJA

                  UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                  SET ADMPN_SALDO_CC = 0,ADMPC_ESTPTO_CC='B',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPV_COD_CLI_PROD=C_CODCLIENTE_PROD;

                  UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
                  SET ADMPV_ESTADO_SERV='B',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPV_COD_CLI_PROD = C_CODCLIENTE_PROD;

                  /*UPDATE PCLUB.ADMPT_CLIENTEFIJA F
                  SET F.ADMPD_FEC_MOD = SYSDATE,
                      F.ADMPV_USU_MOD = K_USUARIO
                  WHERE F.ADMPV_COD_CLI = C_CODCLIENTE; */

                  IF V_CLIENTE_AUX IS NOT NULL THEN
                     --INSERTA EN EL KARDEX LOS PUNTOS AL CLIENTE DE TRASPASO
                     IF V_SALDO_CLI>0 THEN
                        INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,
                        ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG,ADMPV_NOM_ARCH)
                        VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,V_CLIENTE_AUX, V_COD_CPTO2,SYSDATE,
                        V_SALDO_CLI,'E', 'C', V_SALDO_CLI, 'A',K_USUARIO,SYSDATE,C_NOMARCHIVO);
                      END IF;

                    --SE ACTUALIZA EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE DEL CLIENTE DE TRASPASO
                    UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                    SET ADMPN_SALDO_CC=V_SALDO_CLI + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                     FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                                     WHERE ADMPV_COD_CLI_PROD = V_CLIENTE_AUX),
                        ADMPC_ESTPTO_CC='A',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                    WHERE ADMPV_COD_CLI_PROD=V_CLIENTE_AUX;

                  ELSE
                    V_COD_NUEVO  := 1;
                    V_COD_CLINUE := '';

                      WHILE V_COD_NUEVO > 0 LOOP
                        V_COD_CLINUE := TRIM(C_CODCLIENTE) || '-' || TO_CHAR(V_COD_NUEVO);

                        V_REG := 0;

                        BEGIN
                          SELECT COUNT(*)
                            INTO V_REG
                            FROM PCLUB.ADMPT_CLIENTEFIJA
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


                      INSERT INTO PCLUB.ADMPT_CLIENTEFIJA(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,
                                              ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG)
                      SELECT V_COD_CLINUE,F.ADMPV_COD_SEGCLI,F.ADMPN_COD_CATCLI,F.ADMPV_TIPO_DOC,F.ADMPV_NUM_DOC,F.ADMPV_NOM_CLI,F.ADMPV_APE_CLI,F.ADMPC_SEXO,F.ADMPV_EST_CIVIL,
                                              F.ADMPV_EMAIL,F.ADMPV_PROV,F.ADMPV_DEPA,F.ADMPV_DIST,F.ADMPD_FEC_ACTIV,F.ADMPC_ESTADO,F.ADMPV_COD_TPOCL,F.ADMPD_FEC_REG,F.ADMPV_USU_REG
                      FROM PCLUB.ADMPT_CLIENTEFIJA F
                      WHERE F.ADMPV_COD_CLI=C_CODCLIENTE;

                      UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
                      SET ADMPV_COD_CLI=V_COD_CLINUE,
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                      WHERE ADMPV_COD_CLI=C_CODCLIENTE;

                      UPDATE PCLUB.ADMPT_CANJEFIJA
                      SET ADMPV_COD_CLI=V_COD_CLINUE,
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                      WHERE ADMPV_COD_CLI=C_CODCLIENTE;

                      UPDATE PCLUB.ADMPT_CLIENTEFIJA
                      SET ADMPC_ESTADO='B',
                        ADMPD_FEC_MOD=SYSDATE,
                        ADMPV_USU_MOD=K_USUARIO
                      WHERE ADMPV_COD_CLI=V_COD_CLINUE;

                      DELETE PCLUB.ADMPT_CLIENTEFIJA
                      WHERE ADMPV_COD_CLI=C_CODCLIENTE;

                      /*CUPONERAVIRTUAL - JCGT INI*/
                      PKG_CC_CUPONERA.ADMPSI_BAJACLIENTE(K_TIPODOC,K_NUMDOC,'BAJA',K_USUARIO,C_COD_CLICUP,C_CODERROR,C_DESCERROR);
                      /*CUPONERAVIRTUAL - JCGT FIN*/

                  END IF;

            END IF;

           -- Insertamos en la auxiliar para los reprocesos
           INSERT INTO PCLUB.ADMPT_AUX_BAJACLI_DTH(ADMPV_COD_CLI_PROD,ADMPD_FCH_BAJA,ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
           VALUES(C_CODCLIENTE_PROD,C_FECBAJA,C_FECOPER, C_NOMARCHIVO);

        END;

     ELSE

        UPDATE PCLUB.ADMPT_TMP_BAJACLI_DTH B
        SET B.ADMPC_COD_ERROR='101',
               B.ADMPV_MSJE_ERROR='El cliente ya fue procesado.'
        WHERE B.ADMPV_COD_CLI_PROD = C_CODCLIENTE_PROD
           AND B.ADMPD_FCH_BAJA = C_FECBAJA
           AND B.ADMPD_FEC_OPER = C_FECOPER
           AND B.ADMPV_NOM_ARCH = C_NOMARCHIVO;

     END IF;


     FETCH BAJA_CLIENTES INTO C_CODCLIENTE_PROD,C_FECBAJA,C_FECOPER, C_NOMARCHIVO;

  END LOOP;

 -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_BAJACLI_DTH WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_BAJACLI_DTH WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPV_MSJE_ERROR Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_BAJACLI_DTH WHERE (admpd_fec_oper=K_FECHA);

 -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_BAJACLI_DTH
  SELECT PCLUB.ADMPT_IMP_BAJADTH_SQ.nextval,
         ADMPV_COD_CLI_PROD,
         ADMPD_FCH_BAJA,
         ADMPD_FEC_OPER,
         ADMPV_NOM_ARCH,
         ADMPC_COD_ERROR,
         ADMPV_MSJE_ERROR,
         SYSDATE,
         ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_BAJACLI_DTH
   WHERE admpd_fec_oper=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_BAJACLI_DTH;
   DELETE PCLUB.ADMPT_TMP_BAJACLI_DTH  WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

   BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='';
    END;

  EXCEPTION
    WHEN EX_ERROR THEN
     BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='';
    END;
    WHEN OTHERS THEN
    ROLLBACK;
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_BAJACLIENTEDTH;


PROCEDURE ADMPSI_EBAJACLIENTEDTH(K_FEC_PROCESO IN DATE,CURCLIENTES OUT SYS_REFCURSOR) IS

BEGIN
    OPEN  CURCLIENTES FOR
    SELECT I.ADMPV_COD_CLI_PROD,TO_CHAR(I.ADMPD_FCH_BAJA,'DD/MM/YYYY') ,TO_CHAR(I.ADMPD_FEC_OPER,'DD/MM/YYYY'),I.ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_IMP_BAJACLI_DTH I
    WHERE I.ADMPD_FEC_OPER=K_FEC_PROCESO
    AND (I.ADMPV_MSJE_ERROR IS NOT NULL OR I.ADMPV_MSJE_ERROR <>'');

END ADMPSI_EBAJACLIENTEDTH;

PROCEDURE ADMPSI_FACTURADTH(K_FECHA     IN DATE,
                            K_USUARIO   IN VARCHAR2,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2,
                            K_NUMREGTOT OUT NUMBER,
                            K_NUMREGPRO OUT NUMBER,
                            K_NUMREGERR OUT NUMBER) AS

  V_COD_CLI_PROD VARCHAR2(40);
  V_PERIODO      VARCHAR2(6);
  V_DIAS_VENC    NUMBER;
  V_MNT_CGOFIJ   NUMBER;

  V_NUMDIAS    NUMBER;
  V_TIPO_CLI   VARCHAR2(2);
  V_TIPO_PUNTO CHAR(1);

  V_PUNTOS_PPAGO_NORMALS NUMBER;
  V_PUNTOS_CFIJS         NUMBER;

  -- Codigos de conceptos por pagos
  V_CONCEP_PPAGO_N   NUMBER;
  V_CONCEP_CFIJ      NUMBER;
  V_IND_PROC_CFIJ    NUMBER;
  V_IND_PROC_PPAGO_N NUMBER;

  -- Costo por punto
  V_CTO_PPAGO NUMBER;
  V_CTO_CFIJ  NUMBER;

  -- Puntos x concepto
  V_PUNTOS_PPAGO_NORMAL NUMBER;
  V_PUNTOS_CFIJ         NUMBER;

  V_COD_CATCLI   NUMBER;
  V_COD_CLI_IB   VARCHAR2(40);
  V_TOTAL_PUNTOS NUMBER;
  ORA_ERROR      VARCHAR2(205);
  V_CONTADOR     NUMBER;
  V_NOM_ARCH     VARCHAR2(150);
  NRO_ERROR      NUMBER;
  V_SEQ          NUMBER;

  EX_ERROR EXCEPTION;

  CURSOR CUR_PAGOS IS
    SELECT ADMPV_COD_CLI_PROD,
           ADMPV_PERIODO,
           ADMPN_DIAS_VENC,
           ADMPN_MNT_CGOFIJ,
           ADMPV_NOM_ARCH,
           ADMPN_SEQ
      FROM PCLUB.ADMPT_TMP_PAGO_DTH
     WHERE (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ')
       AND ADMPD_FEC_OPER = K_FECHA;

BEGIN

  K_DESCERROR := '';
  K_CODERROR  := 0;
  NRO_ERROR   := 0;

  IF K_FECHA IS NULL THEN
    K_DESCERROR := 'Ingrese la fecha a procesar.';
    K_CODERROR  := 4;
    RAISE EX_ERROR;
  END IF;

  --cod.servicio NO EXISTE
  UPDATE PCLUB.ADMPT_TMP_PAGO_DTH TM
     SET ADMPV_MSJE_ERROR = 'El campo codigo de servicio es obligatorio.'
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND (TM.ADMPV_COD_CLI_PROD IS NULL OR TM.ADMPV_COD_CLI_PROD = '');

  --CLIENTE NO EXISTE
  UPDATE PCLUB.ADMPT_TMP_PAGO_DTH TM
     SET ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos'
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND NOT EXISTS
   (SELECT 1
            FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
           WHERE C.ADMPV_COD_CLI_PROD = TM.ADMPV_COD_CLI_PROD);

  --CLIENTE NO ES HFC
  UPDATE PCLUB.ADMPT_TMP_PAGO_DTH TM
     SET ADMPV_MSJE_ERROR = 'El cliente no es DTH'
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND EXISTS (SELECT 1
            FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
           WHERE C.ADMPV_COD_CLI_PROD = TM.ADMPV_COD_CLI_PROD
             AND F.ADMPV_COD_CLI = C.ADMPV_COD_CLI
             AND F.ADMPV_COD_TPOCL <> '6');

  --SERVICIO NO ESTA ACTIVO
  UPDATE PCLUB.ADMPT_TMP_PAGO_DTH TM
     SET ADMPV_MSJE_ERROR = 'El SERVICIO no esta activo'
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND EXISTS (SELECT 1
            FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
           WHERE C.ADMPV_COD_CLI_PROD = TM.ADMPV_COD_CLI_PROD
             AND F.ADMPV_COD_CLI = C.ADMPV_COD_CLI
             AND C.ADMPV_ESTADO_SERV = 'B');

  --CLIENTE NO ESTA ACTIVO
  UPDATE PCLUB.ADMPT_TMP_PAGO_DTH TM
     SET ADMPV_MSJE_ERROR = 'El cliente no esta activo'
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND EXISTS (SELECT 1
            FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
           WHERE C.ADMPV_COD_CLI_PROD = TM.ADMPV_COD_CLI_PROD
             AND F.ADMPV_COD_CLI = C.ADMPV_COD_CLI
             AND F.ADMPC_ESTADO = 'B');

  --MONTOS INFERIORES A 0
  UPDATE PCLUB.ADMPT_TMP_PAGO_DTH TM
     SET ADMPV_MSJE_ERROR = 'El monto es menor o igual a cero'
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND EXISTS (SELECT 1
            FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C
           WHERE C.ADMPV_COD_CLI_PROD = TM.ADMPV_COD_CLI_PROD
             AND F.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
     AND TM.ADMPN_MNT_CGOFIJ <= 0;

  BEGIN
    SELECT ADMPV_COD_CPTO, ADMPC_PROC
      INTO V_CONCEP_PPAGO_N, V_IND_PROC_PPAGO_N
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'PRONTO PAGO NORMAL DTH'; /* Concepto - pronto pago normal */
    SELECT ADMPV_COD_CPTO, ADMPC_PROC
      INTO V_CONCEP_CFIJ, V_IND_PROC_CFIJ
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'CARGO FIJO NORMAL DTH'; /* Concepto - cargo fijo */
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_DESCERROR := '"PRONTO PAGO NORMAL DTH" ó "CARGO FIJO NORMAL DTH"';
      K_CODERROR  := 9;
      RAISE EX_ERROR;
  END;

  -- Obtenemos la cantidad de dias de pago anticipado para considerarlo como pronto pago
  BEGIN
    SELECT TO_NUMBER(ADMPV_VALOR)
      INTO V_NUMDIAS
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE UPPER(ADMPV_DESC) = 'DIAS_VENCIMIENTO_PAGO_CC';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_DESCERROR := 'Parametro = "DIAS_VENCIMIENTO_PAGO_CC".';
      K_CODERROR  := 14;
      RAISE EX_ERROR;
  END;

  -- IF V_NUMDIAS <= 0 THEN

  OPEN CUR_PAGOS;
  FETCH CUR_PAGOS
    INTO V_COD_CLI_PROD,
         V_PERIODO,
         V_DIAS_VENC,
         V_MNT_CGOFIJ,
         V_NOM_ARCH,
         V_SEQ;

  WHILE CUR_PAGOS%FOUND LOOP
    BEGIN
      V_PUNTOS_PPAGO_NORMAL := 0;
      V_PUNTOS_CFIJ         := 0;
      V_TOTAL_PUNTOS        := 0;
    
      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM PCLUB.ADMPT_AUX_PAGO_DTH
       WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
         AND ADMPV_PERIODO = V_PERIODO
         AND ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_NOM_ARCH = V_NOM_ARCH;
    
      IF V_CONTADOR = 0 THEN
      
        V_COD_CLI_IB := NULL;
      
        -- Busca la categoria del cliente
        SELECT F.ADMPN_COD_CATCLI, F.ADMPV_COD_TPOCL
          INTO V_COD_CATCLI, V_TIPO_CLI
          FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
         WHERE P.ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
           AND P.ADMPV_COD_CLI = F.ADMPV_COD_CLI;
      
        IF V_COD_CATCLI IS NULL THEN
          V_COD_CATCLI := 2; -- Cliente Normal
        END IF;
      
        /* Costo de Puntos x categoria AÑADIR EN LA TABLA CAT_CLIENTE EL NUEVO CLIENTE HFC*/
        SELECT ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ
          INTO V_CTO_PPAGO, V_CTO_CFIJ
          FROM PCLUB.ADMPT_CAT_CLIENTE
         WHERE ADMPN_COD_CATCLI = V_COD_CATCLI
           AND ADMPV_COD_TPOCL = V_TIPO_CLI;
      
        -- Cálculo de puntos para Pronto Pago Normal, Pronto Pago Adicional
        /* Pronto Pago normal  */
        --Veifico la configuración para otorgar puntos por Cargo Fijo
        IF V_IND_PROC_PPAGO_N IS NOT NULL AND V_IND_PROC_PPAGO_N = '1' THEN
          IF V_DIAS_VENC >= V_NUMDIAS THEN
            V_PUNTOS_PPAGO_NORMAL := TRUNC((V_MNT_CGOFIJ) / V_CTO_PPAGO, 0);
          
            IF V_PUNTOS_PPAGO_NORMAL <> 0 THEN
              IF V_PUNTOS_PPAGO_NORMAL > 0 THEN
                V_TIPO_PUNTO           := 'E';
                V_PUNTOS_PPAGO_NORMALS := V_PUNTOS_PPAGO_NORMAL;
                /*20110523*/
                INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                  (ADMPN_ID_KARDEX,
                   ADMPN_COD_CLI_IB,
                   ADMPV_COD_CLI_PROD,
                   ADMPV_COD_CPTO,
                   ADMPD_FEC_TRANS,
                   ADMPN_PUNTOS,
                   ADMPV_NOM_ARCH,
                   ADMPC_TPO_OPER,
                   ADMPC_TPO_PUNTO,
                   ADMPN_SLD_PUNTO,
                   ADMPC_ESTADO,
                   ADMPD_FEC_REG,
                   ADMPV_USU_REG)
                VALUES
                  (PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                   V_COD_CLI_IB,
                   V_COD_CLI_PROD,
                   V_CONCEP_PPAGO_N,
                   SYSDATE,
                   V_PUNTOS_PPAGO_NORMAL,
                   V_NOM_ARCH,
                   V_TIPO_PUNTO,
                   'C',
                   V_PUNTOS_PPAGO_NORMALS,
                   'A',
                   SYSDATE,
                   K_USUARIO);
              ELSE
                --V_TIPO_PUNTO := 'S';
                V_PUNTOS_PPAGO_NORMALS := 0;
                V_PUNTOS_PPAGO_NORMAL  := 0;
              END IF;
            END IF;
          ELSE
            UPDATE PCLUB.ADMPT_TMP_PAGO_DTH
               SET ADMPC_COD_ERROR  = '101',
                   ADMPV_MSJE_ERROR = 'El numero de dias de vencimiento sobrepasa el limite.'
             WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
               AND ADMPV_PERIODO = V_PERIODO
               AND ADMPN_SEQ = V_SEQ;
          END IF;
        END IF;
      
       
        /*Cargo Fijo*/
        --Validamos que la configuración para otorgar puntos por Cargo Fijo se encuentre habilitada
        IF V_IND_PROC_CFIJ IS NOT NULL AND V_IND_PROC_CFIJ = '1' THEN
          
        -- Cálculo de puntos para Cargo Fijo
        V_PUNTOS_CFIJ := TRUNC((V_MNT_CGOFIJ) / V_CTO_CFIJ, 0);
        
          IF V_PUNTOS_CFIJ <> 0 THEN
            IF V_PUNTOS_CFIJ > 0 THEN
              V_TIPO_PUNTO   := 'E';
              V_PUNTOS_CFIJS := V_PUNTOS_CFIJ;
            
              INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                (ADMPN_ID_KARDEX,
                 ADMPN_COD_CLI_IB,
                 ADMPV_COD_CLI_PROD,
                 ADMPV_COD_CPTO,
                 ADMPD_FEC_TRANS,
                 ADMPN_PUNTOS,
                 ADMPV_NOM_ARCH,
                 ADMPC_TPO_OPER,
                 ADMPC_TPO_PUNTO,
                 ADMPN_SLD_PUNTO,
                 ADMPC_ESTADO,
                 ADMPD_FEC_REG,
                 ADMPV_USU_REG)
              VALUES
                (PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                 V_COD_CLI_IB,
                 V_COD_CLI_PROD,
                 V_CONCEP_CFIJ,
                 SYSDATE,
                 V_PUNTOS_CFIJ,
                 V_NOM_ARCH,
                 V_TIPO_PUNTO,
                 'C',
                 V_PUNTOS_CFIJS,
                 'A',
                 SYSDATE,
                 K_USUARIO);
            
            ELSE
              V_PUNTOS_CFIJS := 0;
              V_PUNTOS_CFIJ  := 0;
            END IF;
          END IF;
        
        END IF;
      
        /* Actualiza Tabla de Saldos con el total de puntos acumulados  */
        V_TOTAL_PUNTOS := NVL(V_PUNTOS_PPAGO_NORMAL, 0) +
                          NVL(V_PUNTOS_CFIJ, 0);
      
        UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
           SET ADMPN_SALDO_CC = ADMPN_SALDO_CC + V_TOTAL_PUNTOS,
               ADMPD_FEC_MOD  = SYSDATE,
               ADMPV_USU_MOD  = K_USUARIO
         WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD;
      
        /* Actualiza el total de puntos (admpn_puntos) en ADMPT_tmp_pago_cc */
        UPDATE PCLUB.ADMPT_TMP_PAGO_DTH
           SET ADMPN_PUNTOS = V_TOTAL_PUNTOS
         WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
           AND ADMPV_PERIODO = V_PERIODO
           AND ADMPD_FEC_OPER = K_FECHA;
      
        -- Insertamos en la tabla temporal por si es necesario el reproceso
        INSERT INTO PCLUB.ADMPT_AUX_PAGO_DTH
          (ADMPV_COD_CLI_PROD,
           ADMPV_PERIODO,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH)
        VALUES
          (V_COD_CLI_PROD, V_PERIODO, K_FECHA, V_NOM_ARCH);
      
      ELSE
        UPDATE PCLUB.ADMPT_TMP_PAGO_DTH
           SET ADMPC_COD_ERROR  = '102',
               ADMPV_MSJE_ERROR = 'El servicio ya fue procesado'
         WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
           AND ADMPV_PERIODO = V_PERIODO
           AND ADMPN_SEQ = V_SEQ;
        --COMMIT;
      END IF;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        IF V_COD_CATCLI IS NULL THEN
          UPDATE PCLUB.ADMPT_TMP_PAGO_DTH
             SET ADMPV_MSJE_ERROR = 'El cliente no se encuentra categorizado'
           WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
             AND ADMPV_PERIODO = V_PERIODO
             AND ADMPD_FEC_OPER = K_FECHA;
        
        END IF;
      
        IF V_CTO_PPAGO IS NULL OR V_CTO_CFIJ IS NULL THEN
          UPDATE PCLUB.ADMPT_TMP_PAGO_DTH
             SET ADMPC_COD_ERROR  = '23',
                 ADMPV_MSJE_ERROR = 'No se pudo obtener el costo de puntos por categoría'
           WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
             AND ADMPV_PERIODO = V_PERIODO;
        
        END IF;
      
      WHEN OTHERS THEN
        ORA_ERROR := SUBSTR(SQLERRM, 1, 250);
        UPDATE PCLUB.ADMPT_TMP_PAGO_DTH
           SET ADMPC_COD_ERROR = 'ORA', ADMPV_MSJE_ERROR = ORA_ERROR
         WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
           AND ADMPV_PERIODO = V_PERIODO;
      
    END;
  
    FETCH CUR_PAGOS
      INTO V_COD_CLI_PROD,
           V_PERIODO,
           V_DIAS_VENC,
           V_MNT_CGOFIJ,
           V_NOM_ARCH,
           V_SEQ;
  END LOOP;

  -- Exportar datos a la tabla ADMPT_imp_pago_cc
  INSERT INTO PCLUB.ADMPT_IMP_PAGO_DTH
    SELECT PCLUB.ADMPT_PAGODTH_SQ.NEXTVAL,
           ADMPV_COD_CLI_PROD,
           ADMPV_PERIODO,
           ADMPN_DIAS_VENC,
           ADMPN_MNT_CGOFIJ,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH,
           ADMPN_PUNTOS,
           ADMPC_COD_ERROR,
           ADMPV_MSJE_ERROR,
           SYSDATE,
           ADMPN_SEQ
      FROM PCLUB.ADMPT_TMP_PAGO_DTH
     WHERE ADMPD_FEC_OPER = K_FECHA;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
  SELECT COUNT(1)
    INTO K_NUMREGTOT
    FROM PCLUB.ADMPT_TMP_PAGO_DTH
   WHERE ADMPD_FEC_OPER = K_FECHA;
  SELECT COUNT(1)
    INTO K_NUMREGERR
    FROM PCLUB.ADMPT_TMP_PAGO_DTH
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND (ADMPV_MSJE_ERROR IS NOT NULL);
  SELECT COUNT(1)
    INTO K_NUMREGPRO
    FROM PCLUB.ADMPT_AUX_PAGO_DTH
   WHERE ADMPD_FEC_OPER = K_FECHA;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_PAGO_DTH WHERE ADMPD_FEC_OPER = K_FECHA;
  DELETE PCLUB.ADMPT_TMP_PAGO_DTH WHERE ADMPD_FEC_OPER = K_FECHA;

  --
  --   ELSE
  --        K_DESCERROR:='Parametro mayor a 0.';
  --        K_CODERROR:=14;
  --        RAISE EX_ERROR;
  --   END IF;

  COMMIT;

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
  WHEN EX_ERROR THEN
    ROLLBACK;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_FACTURADTH;


PROCEDURE ADMPSI_EFACTURADTH(K_FEC_PROCESO IN DATE,CURCLIENTES OUT SYS_REFCURSOR) IS

BEGIN
    OPEN  CURCLIENTES FOR
    SELECT I.ADMPV_COD_CLI_PROD,I.ADMPN_DIAS_VENC,I.ADMPN_MNT_CGOFIJ,I.ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_IMP_PAGO_DTH I
    WHERE I.ADMPD_FEC_OPER=K_FEC_PROCESO
    AND (I.ADMPV_MSJE_ERROR IS NOT NULL OR I.ADMPV_MSJE_ERROR <>'');

END ADMPSI_EFACTURADTH;

PROCEDURE ADMPSI_ANIVERSARIO (K_FEC_PROCESO IN DATE,K_USUARIO IN VARCHAR2, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2,
                                                K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) AS

V_CODCONCEPTODTH          VARCHAR2(2);
V_PUNTOSDTH               NUMBER;
EX_ERROR    EXCEPTION;
V_FLAG_REGANIVER VARCHAR2(2);

BEGIN
  K_CODERROR:= 0;
  K_DESCERROR:= '';

    BEGIN

       SELECT NVL(ADMPV_VALOR,'0') INTO V_FLAG_REGANIVER
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE UPPER(ADMPV_DESC) LIKE '%REG_ANIVERSARIO_DTH%';

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
                K_DESCERROR:='REG_ANIVERSARIO_DTH.';
                K_CODERROR:=9;
                RAISE EX_ERROR;
    END;

    IF V_FLAG_REGANIVER='S' THEN
            BEGIN

               SELECT ADMPV_COD_CPTO INTO V_CODCONCEPTODTH
                FROM PCLUB.ADMPT_CONCEPTO
               WHERE UPPER(ADMPV_DESC) LIKE '%ANIVERSARIO DTH%';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                            K_DESCERROR:='ANIVERSARIO DTH.';
                            K_CODERROR:=9;
                            RAISE EX_ERROR;
            END;

            BEGIN

               SELECT NVL(ADMPV_VALOR,'0') INTO V_PUNTOSDTH
                FROM PCLUB.ADMPT_PARAMSIST
               WHERE UPPER(ADMPV_DESC) LIKE '%PUNTOS_ANIVERSARIO_DTH%';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                            K_DESCERROR:='PUNTOS_ANIVERSARIO_DTH.';
                            K_CODERROR:=9;
                            RAISE EX_ERROR;
            END;

             --cod.servicio NO EXISTE
           UPDATE PCLUB.ADMPT_TMP_ANIVERSDTH TM
           SET ADMPV_MSJE_ERROR = 'El campo codigo de servicio es obligatorio.'
           WHERE  ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
                 AND (TM.ADMPV_COD_CLI_PROD IS NULL OR TM.ADMPV_COD_CLI_PROD='');

           --CLIENTE NO EXISTE
           UPDATE PCLUB.ADMPT_TMP_ANIVERSDTH TM
           SET ADMPV_MSJE_ERROR = 'El codigo de servicio no existe, no se le puede entregar puntos'
           WHERE  ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
                 AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO C WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD );

           --CLIENTE NO ES DTH
           UPDATE PCLUB.ADMPT_TMP_ANIVERSDTH TM
           SET ADMPV_MSJE_ERROR = 'El cliente no es DTH'
           WHERE  ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
                 AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO C WHERE C.ADMPV_COD_CLI_PROD=TM.ADMPV_COD_CLI_PROD
                                       AND F.ADMPV_COD_CLI=C.ADMPV_COD_CLI AND F.ADMPV_COD_TPOCL<>'6' );

           --verificamos que los clientes se encuentren registrados
            UPDATE PCLUB.ADMPT_TMP_ANIVERSDTH T
            SET T.ADMPV_MSJE_ERROR = 'El servicio NO se encuentra registrado.'
            WHERE T.ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
                    AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEFIJA C, PCLUB.ADMPT_CLIENTEPRODUCTO P
                                                WHERE C.ADMPV_COD_CLI=P.ADMPV_COD_CLI AND C.ADMPV_COD_TPOCL = '6'
                                                AND P.ADMPV_COD_CLI_PROD=T.ADMPV_COD_CLI_PROD);

            -- Verificamos que los servicios no esten de Baja
            UPDATE PCLUB.ADMPT_TMP_ANIVERSDTH T
               SET T.ADMPV_MSJE_ERROR = 'El servicio se encuentra de Baja.'
             WHERE T.ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
                    AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEFIJA C, PCLUB.ADMPT_CLIENTEPRODUCTO P
                   WHERE C.ADMPV_COD_CLI=P.ADMPV_COD_CLI AND C.ADMPV_COD_TPOCL = '6'
                   AND P.ADMPV_COD_CLI_PROD=T.ADMPV_COD_CLI_PROD AND P.ADMPV_ESTADO_SERV = 'B');

            -- Verificamos que los clientes no esten de Baja
            UPDATE PCLUB.ADMPT_TMP_ANIVERSDTH T
               SET T.ADMPV_MSJE_ERROR = 'El cliente se encuentra de Baja.'
             WHERE T.ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')
                    AND EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTEFIJA C, PCLUB.ADMPT_CLIENTEPRODUCTO P
                   WHERE C.ADMPV_COD_CLI=P.ADMPV_COD_CLI AND C.ADMPV_COD_TPOCL = '6'
                   AND P.ADMPV_COD_CLI_PROD=T.ADMPV_COD_CLI_PROD AND C.ADMPC_ESTADO='B');

            INSERT INTO PCLUB.ADMPT_AUX_ANIVERSDTH
            SELECT C.ADMPV_COD_CLI_PROD,C.ADMPV_CUST_ID,C.ADMPD_COD_SERV,C.ADMPV_TIPO_DOC,C.ADMPV_NUM_DOC,C.ADMPD_FEC_OPER FROM PCLUB.ADMPT_TMP_ANIVERSDTH C
            WHERE C.ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ');


            --CLIENTES DTH

            UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                  SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_PUNTOSDTH,
                        S.ADMPD_FEC_MOD=SYSDATE,S.ADMPV_USU_MOD=K_USUARIO
                  WHERE ADMPV_COD_CLI_PROD IN (SELECT A.ADMPV_COD_CLI_PROD FROM PCLUB.ADMPT_AUX_ANIVERSDTH A,PCLUB.ADMPT_CLIENTEPRODUCTO P,PCLUB.ADMPT_CLIENTEFIJA F
                                                                     WHERE F.ADMPV_COD_CLI=P.ADMPV_COD_CLI AND P.ADMPV_COD_CLI_PROD=A.ADMPV_COD_CLI_PROD AND F.ADMPV_COD_TPOCL='6' )
                  AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_KARDEXFIJA K WHERE K.ADMPV_COD_CLI_PROD = S.ADMPV_COD_CLI_PROD
                  AND K.ADMPV_COD_CPTO = V_CODCONCEPTODTH
                  AND TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY'));



            --ACTUALIZAR KARDEX FIJA - CLIENTES HFC
            INSERT INTO PCLUB.ADMPT_KARDEXFIJA (
            ADMPN_ID_KARDEX,
            ADMPN_COD_CLI_IB,
            ADMPV_COD_CLI_PROD,
            ADMPV_COD_CPTO,
            ADMPD_FEC_TRANS,
            ADMPN_PUNTOS,
            ADMPV_NOM_ARCH,
            ADMPC_TPO_OPER,
            ADMPC_TPO_PUNTO,
            ADMPN_SLD_PUNTO,
            ADMPC_ESTADO,
            ADMPD_FEC_REG,
            ADMPV_USU_REG)
            SELECT PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,
            NULL,
            C.ADMPV_COD_CLI_PROD,
            V_CODCONCEPTODTH,
            SYSDATE,
            V_PUNTOSDTH,
            C.ADMPV_NOM_ARCH,
            'E',
            'C',
            V_PUNTOSDTH,
            'A',
            SYSDATE,
            K_USUARIO
           FROM PCLUB.ADMPT_TMP_ANIVERSDTH C
           INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P ON (C.ADMPV_COD_CLI_PROD= P.ADMPV_COD_CLI_PROD)
           INNER JOIN PCLUB.ADMPT_CLIENTEFIJA F ON (P.ADMPV_COD_CLI = F.ADMPV_COD_CLI AND F.ADMPV_COD_TPOCL='6')
           WHERE C.ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ')
           AND NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_KARDEXFIJA K WHERE K.ADMPV_COD_CLI_PROD = C.ADMPV_COD_CLI_PROD
                          AND K.ADMPV_COD_CPTO = V_CODCONCEPTODTH AND
                           TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY'));


           --ACTUALIZAMOS LA FECHA DE ULTIMO ANIVERSARIO
           UPDATE PCLUB.ADMPT_CLIENTEPRODUCTO
           SET ADMPV_FEC_ULTANIV=SYSDATE,--ADMPV_FEC_ULTANIV=A.ADMPD_FEC_ANIV,
                  ADMPD_FEC_MOD=SYSDATE,
                  ADMPV_USU_MOD=K_USUARIO
           WHERE ADMPV_COD_CLI_PROD IN (SELECT A.ADMPV_COD_CLI_PROD  FROM PCLUB.ADMPT_TMP_ANIVERSDTH A
                                      WHERE A.ADMPV_COD_CLI_PROD IS NOT NULL
                                      AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = ' ')
                                      AND ADMPD_FEC_OPER = K_FEC_PROCESO);


            -- Obtenemos los registros totales, procesados y con error
            SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ANIVERSDTH WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;
            SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ANIVERSDTH WHERE (ADMPD_FEC_OPER = K_FEC_PROCESO) AND ADMPV_MSJE_ERROR IS NOT NULL;
            SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ANIVERSDTH;

            -- Insertamos de la tabla temporal a la final
            INSERT INTO PCLUB.ADMPT_IMP_ANIVERSDTH
            SELECT PCLUB.ADMPT_IMP_ANIVDTH_SQ.NEXTVAL,ADMPV_COD_CLI_PROD, ADMPV_CUST_ID,ADMPD_COD_SERV,ADMPV_TIPO_DOC,ADMPV_NUM_DOC, ADMPD_FEC_OPER,
                        ADMPV_NOM_ARCH,ADMPV_MSJE_ERROR,ADMPN_SEQ
              FROM PCLUB.ADMPT_TMP_ANIVERSDTH
             WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;-- AND ADMPV_MSJE_ERROR IS NOT NULL;

             -- Eliminamos los registros de la tabla temporal y auxiliar
             DELETE PCLUB.ADMPT_AUX_ANIVERSDTH;
             DELETE PCLUB.ADMPT_TMP_ANIVERSDTH WHERE (ADMPD_FEC_OPER = K_FEC_PROCESO);

            COMMIT;

    END IF;

     BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
     EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
     END;


EXCEPTION
     WHEN EX_ERROR THEN
      ROLLBACK;
       BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
            K_DESCERROR:='ERROR';
       END;
     WHEN OTHERS THEN
       ROLLBACK;
       K_CODERROR:= 1;
       K_DESCERROR:= SUBSTR(SQLERRM,1,250);
END ADMPSI_ANIVERSARIO;

PROCEDURE ADMPSI_EANIVERSARIO(K_FEC_PROCESO IN DATE,CURCLIENTES OUT SYS_REFCURSOR) IS

BEGIN
    OPEN  CURCLIENTES FOR
    SELECT I.ADMPV_COD_CLI_PROD,I.ADMPV_TIPO_DOC,I.ADMPV_NUM_DOC,TO_CHAR(I.ADMPD_FEC_OPER,'DD/MM/YYYY'),I.ADMPV_MSJE_ERROR
    FROM PCLUB.ADMPT_IMP_ANIVERSDTH I
    WHERE I.ADMPD_FEC_OPER=K_FEC_PROCESO
    AND (I.ADMPV_MSJE_ERROR IS NOT NULL OR I.ADMPV_MSJE_ERROR <>'');

END ADMPSI_EANIVERSARIO;

PROCEDURE ADMPSI_ALTACLIENTE_SVR
(
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2, 
  K_CODERROR OUT NUMBER, 
  K_DESCERROR OUT VARCHAR2, 
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER,
  K_NUMCLIEXI OUT NUMBER,
  K_NUMCLIDUP OUT NUMBER,
  K_NUMREG OUT NUMBER, 
  K_NUMREGERR OUT NUMBER
) 
AS
  TYPE REGALTACLI IS RECORD(  
    ADMPN_SEQ	NUMBER,
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPV_TIPO_DOC	VARCHAR2(20),
    ADMPV_NUM_DOC	VARCHAR2(20),
    ADMPV_NOM_CLI	VARCHAR2(80),
    ADMPV_APE_CLI	VARCHAR2(80),
    ADMPC_SEXO	CHAR(1),
    ADMPV_EST_CIVIL	VARCHAR2(20),
    ADMPV_EMAIL	VARCHAR2(80),
    ADMPV_PROV	VARCHAR2(30),
    ADMPV_DEPA	VARCHAR2(40),
    ADMPV_DIST	VARCHAR2(200),
    ADMPD_FEC_ACT	DATE,
    ADMPV_CICL_FACT	VARCHAR2(20),
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPV_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400)
  );

  vREGCLI  REGALTACLI;

  CURSOR ALTACLI IS
  SELECT *
  FROM ADMPT_TMP_ALTACLIENTE_SVR D
  WHERE D.ADMPD_FEC_OPER = K_FEC_PROCESO
  AND (D.ADMPV_MSJE_ERROR IS NULL OR D.ADMPV_MSJE_ERROR ='' OR D.ADMPV_COD_ERROR  = '105')
  AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
  
  EX_ERROR EXCEPTION;

  V_REGCLI NUMBER;
  V_REGCONT NUMBER;
  C_CODCLI VARCHAR2(40);
  V_REGOK NUMBER;
  COD_SALDO VARCHAR2(40);
  V_IDSALDO  NUMBER;
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  V_NOMARCSER VARCHAR2(150);
  V_CLIEXI NUMBER;
  V_CANCLI NUMBER;
     
  BEGIN

    K_CODERROR:=0;
    K_DESCERROR:='';
    V_CLIEXI:=0;
    V_CANCLI:=0;
    
    IF K_TIPCLIENTE IS NULL THEN
      K_DESCERROR := 'Ingrese el tipo de cliente a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_FEC_PROCESO IS NULL THEN
      K_DESCERROR := 'Ingrese la fecha a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_USUARIO IS NULL THEN
      K_DESCERROR := 'Ingrese el usuario procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;

    /** Ini: Validaciones Alta Cliente **/
    UPDATE ADMPT_TMP_ALTACLIENTE_SVR
    SET ADMPV_MSJE_ERROR='La cuenta es un dato obligatorio.', 
        ADMPV_COD_ERROR = '101'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND 
    (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
    AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE='')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    UPDATE ADMPT_TMP_ALTACLIENTE_SVR
    SET ADMPV_MSJE_ERROR='El tipo de cliente es un dato obligatorio.', 
        ADMPV_COD_ERROR = '102'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND 
    (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
    AND (ADMPV_TIP_CLIENTE IS NULL OR ADMPV_TIP_CLIENTE = '');

    UPDATE ADMPT_TMP_ALTACLIENTE_SVR
    SET ADMPV_MSJE_ERROR='El codigo y tipo de documento son datos obligatorios.', 
        ADMPV_COD_ERROR = '103'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND 
    (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
    AND (ADMPV_TIPO_DOC IS NULL OR ADMPV_NUM_DOC IS NULL)
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    --- Si tiene un servicio ya registrado se marca a no procesar ---
    UPDATE ADMPT_TMP_ALTACLIENTE_SVR A
    SET A.ADMPV_MSJE_ERROR = 'Uno o varios de los servicios ya se encuentran registrados.', 
        A.ADMPV_COD_ERROR = '104'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (A.ADMPV_MSJE_ERROR IS NULL OR A.ADMPV_MSJE_ERROR ='')
    AND A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_TMP_ALTACLIENTESERV_SVR S
     WHERE P.ADMPV_COD_CLI_PROD = S.ADMPV_CUSTCODE ||'_'|| S.ADMPV_TIPO_SERV
     AND P.ADMPV_COD_CLI = A.ADMPV_TIPO_DOC ||'.'|| A.ADMPV_NUM_DOC ||'.'|| A.ADMPV_TIP_CLIENTE);    
---- Cliente ya se encuentra registrado. Aún así se registra sus servicios
    UPDATE ADMPT_TMP_ALTACLIENTE_SVR A
       SET A.ADMPV_MSJE_ERROR = 'Cliene ya se encuentra registrado.',
           A.ADMPV_COD_ERROR  = '105'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (A.ADMPV_MSJE_ERROR IS NULL OR A.ADMPV_MSJE_ERROR = '')
       AND A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
       AND EXISTS
       (SELECT 1 FROM ADMPT_CLIENTEFIJA C WHERE C.ADMPV_COD_CLI =
        A.ADMPV_TIPO_DOC || '.' || A.ADMPV_NUM_DOC || '.' || A.ADMPV_TIP_CLIENTE);   
    /** Fin: Validaciones Alta Cliente **/

    /** Ini: Validaciones Del Servicio **/
    UPDATE ADMPT_TMP_ALTACLIENTESERV_SVR
    SET ADMPV_MSJE_ERROR = 'El codigo de cuenta es un dato obligatorio.', 
        ADMPV_COD_ERROR = '201'    
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
    AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
        
    UPDATE ADMPT_TMP_ALTACLIENTESERV_SVR
    SET ADMPV_MSJE_ERROR = 'El tipo de servicio es un dato obligatorio.', 
        ADMPV_COD_ERROR = '202'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR ='')
    AND (ADMPV_TIPO_SERV IS NULL OR ADMPV_TIPO_SERV = '')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    UPDATE ADMPT_TMP_ALTACLIENTESERV_SVR TP
    SET TP.ADMPV_MSJE_ERROR = 'El codigo de servicio ya se encuentra registrado.', 
        ADMPV_COD_ERROR = '203'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (TP.ADMPV_MSJE_ERROR IS NULL OR TP.ADMPV_MSJE_ERROR ='')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_TMP_ALTACLIENTE_SVR C
     WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE ||'_'|| TP.ADMPV_TIPO_SERV
     AND P.ADMPV_COD_CLI = C.ADMPV_TIPO_DOC ||'.'|| C.ADMPV_NUM_DOC ||'.'|| C.ADMPV_TIP_CLIENTE);    
    /** Fin: Validaciones Del Servicio **/

    SELECT COUNT(1) INTO V_CANCLI FROM ADMPT_TMP_ALTACLIENTESERV_SVR WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;

    IF V_CANCLI > 0 THEN
      SELECT ADMPV_NOM_ARCH INTO V_NOMARCSER FROM ADMPT_TMP_ALTACLIENTESERV_SVR
      WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ROWNUM = 1;
    END IF;

 OPEN ALTACLI;

     FETCH ALTACLI INTO vREGCLI;

     WHILE ALTACLI%FOUND     
     LOOP

          SELECT COUNT(1) INTO V_REGOK 
          FROM ADMPT_TMP_ALTACLIENTESERV_SVR 
          WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
          AND ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
          AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
          AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

          SELECT COUNT(1) INTO V_REGCLI
          FROM ADMPT_TMP_ALTACLIENTESERV_SVR S
          WHERE S.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
          AND S.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
          AND S.ADMPD_FEC_OPER = K_FEC_PROCESO
          AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
                             
           --generamos el codigo unico que nos permitira identificar          
          C_CODCLI:= vREGCLI.ADMPV_TIPO_DOC||'.'||vREGCLI.ADMPV_NUM_DOC||'.'||vREGCLI.ADMPV_TIP_CLIENTE;
         
          IF V_REGCLI > 0 THEN
            
             IF V_REGCLI = V_REGOK THEN
                            
                BEGIN
             
                  /** INI: INSERTAMOS AL CLIENTE **/
                  SELECT COUNT(1) INTO V_CLIEXI FROM ADMPT_CLIENTEFIJA C 
                  WHERE C.ADMPV_COD_CLI = C_CODCLI;
                  IF V_CLIEXI = 0 THEN
                       INSERT INTO ADMPT_CLIENTEFIJA H
                          (H.ADMPV_COD_CLI,
                           H.ADMPV_COD_SEGCLI,
                           H.ADMPN_COD_CATCLI,
                           H.ADMPV_TIPO_DOC,
                           H.ADMPV_NUM_DOC,
                           H.ADMPV_NOM_CLI,
                           H.ADMPV_APE_CLI,
                           H.ADMPC_SEXO,
                           H.ADMPV_EST_CIVIL,
                           H.ADMPV_EMAIL,
                           H.ADMPV_PROV,
                           H.ADMPV_DEPA,
                           H.ADMPV_DIST,
                           H.ADMPD_FEC_ACTIV,  
                           H.ADMPC_ESTADO,
                           H.ADMPV_COD_TPOCL,
                           H.ADMPD_FEC_REG,
                           H.ADMPV_USU_REG)
                        VALUES
                          (C_CODCLI,
                           NULL,
                           2,
                           vREGCLI.ADMPV_TIPO_DOC,
                           vREGCLI.ADMPV_NUM_DOC,
                           vREGCLI.ADMPV_NOM_CLI,
                           vREGCLI.ADMPV_APE_CLI,
                           vREGCLI.ADMPC_SEXO,
                           vREGCLI.ADMPV_EST_CIVIL,
                           vREGCLI.ADMPV_EMAIL,
                           vREGCLI.ADMPV_PROV,
                           vREGCLI.ADMPV_DEPA,
                           vREGCLI.ADMPV_DIST,
                           SYSDATE,
                           'A',
                           vREGCLI.ADMPV_TIP_CLIENTE,
                           SYSDATE,
                           K_USUARIO);

                   ELSE
                        
                          UPDATE ADMPT_TMP_ALTACLIENTE_SVR T
                          SET T.ADMPV_MSJE_ERROR = 'Cliente duplicado en archivo de carga.', 
                              T.ADMPV_COD_ERROR = '206'
                          WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                          AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                          AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                          AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC
                          AND T.ADMPN_SEQ = vREGCLI.ADMPN_SEQ
                          AND T.ADMPV_MSJE_ERROR <> '';  
                   
                  END IF;
                  /** FIN: INSERTAMOS AL CLIENTE **/

                 /** INI: INSERTAMOS LOS SERVICIOS **/               
                   INSERT INTO ADMPT_CLIENTEPRODUCTO H 
                   (
                          H.ADMPV_COD_CLI_PROD,H.ADMPV_COD_CLI,H.ADMPV_SERVICIO,
                          H.ADMPV_ESTADO_SERV,H.ADMPV_FEC_ULTANIV,H.ADMPD_FEC_REG,
                          H.ADMPV_USU_REG,H.ADMPV_INDICEGRUPO,H.ADMPV_CICL_FACT
                   )
                   SELECT 
                          S.ADMPV_CUSTCODE ||'_'|| S.ADMPV_TIPO_SERV,C_CODCLI,S.ADMPV_TIPO_SERV,
                          'A',SYSDATE,SYSDATE,
                          K_USUARIO,1,vREGCLI.ADMPV_CICL_FACT
                   FROM 
                          ADMPT_TMP_ALTACLIENTESERV_SVR S
                   WHERE 
                          S.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                          AND S.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE;
                 /** FIN: INSERTAMOS LOS SERVICIOS **/
                 
                 /** INI: INSERTAMOS EL SALDO **/              
                    INSERT INTO ADMPT_SALDOS_CLIENTEFIJA
                    (
                       ADMPN_ID_SALDO,
                       ADMPV_COD_CLI_PROD,
                       ADMPN_COD_CLI_IB,
                       ADMPN_SALDO_CC,
                       ADMPN_SALDO_IB,
                       ADMPC_ESTPTO_CC,
                       ADMPC_ESTPTO_IB,
                       ADMPD_FEC_REG,
                       ADMPV_USU_REG
                     )              
                    SELECT 
                       (ADMPT_SLD_CLFIJA_SQ.NEXTVAL + 1),
                       S.ADMPV_CUSTCODE ||'_'|| S.ADMPV_TIPO_SERV,
                       NULL,
                       0,
                       0,'A',NULL,
                       SYSDATE,
                       K_USUARIO
                    FROM 
                       ADMPT_TMP_ALTACLIENTESERV_SVR S
                    WHERE 
                       S.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                       AND S.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE;
                 /** FIN: INSERTAMOS EL SALDO **/

                EXCEPTION                    
                    WHEN OTHERS THEN
                                          
                      UPDATE ADMPT_TMP_ALTACLIENTE_SVR T
                      SET T.ADMPV_MSJE_ERROR = 'ERROR al insertar cliente o sus servicios.', 
                          T.ADMPV_COD_ERROR = '101'
                      WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                      AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                      AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                      AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC;
                      
                      IF V_CLIEXI = 0 THEN
                        DELETE FROM ADMPT_CLIENTEFIJA C WHERE C.ADMPV_COD_CLI = C_CODCLI;
                      END IF;
                      
                      DELETE FROM ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_COD_CLI = C_CODCLI
                      AND EXISTS 
                      (SELECT 1 FROM ADMPT_TMP_ALTACLIENTESERV_SVR S WHERE P.ADMPV_COD_CLI_PROD = S.ADMPV_CUSTCODE ||'_'||S.ADMPV_TIPO_SERV) 
                      AND P.ADMPV_USU_REG = K_USUARIO;
                      
                END;
                   
             ELSE
               
                UPDATE ADMPT_TMP_ALTACLIENTE_SVR T
                SET T.ADMPV_MSJE_ERROR='El cliente no cuenta con todos los servicios correctos a procesar.', 
                    ADMPV_COD_ERROR = '205'
                WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC;
             
             END IF;            

          ELSE
              
                UPDATE ADMPT_TMP_ALTACLIENTE_SVR T
                SET T.ADMPV_MSJE_ERROR='El cliente no cuenta con servicios a procesar.', 
                    ADMPV_COD_ERROR = '204'
                WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC;
             
          END IF;

          FETCH ALTACLI INTO vREGCLI;
     END LOOP;

      -- Exportar datos a la tabla ADMPT_IMP_ALTACLIENTESERV_SVR
      INSERT INTO ADMPT_IMP_ALTACLIENTESERV_SVR
      SELECT  
          ADMPT_IMP_ALTACLIENTESERV_SQ.NEXTVAL,ADMPV_TIP_CLIENTE,ADMPV_CUSTCODE,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
          ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACT,ADMPV_CICL_FACT,
          NULL,ADMPV_TIPO_DOC||'.'||ADMPV_NUM_DOC||'.'||ADMPV_TIP_CLIENTE,ADMPD_FEC_OPER,ADMPV_NOM_ARCH,V_NOMARCSER,ADMPV_COD_ERROR, 
          ADMPV_MSJE_ERROR
      FROM ADMPT_TMP_ALTACLIENTE_SVR
      WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE
      AND ADMPD_FEC_OPER = K_FEC_PROCESO;

    -- Generar Resultados (Total registros, Total procesados, Total de errores)
      SELECT COUNT (1) INTO K_NUMREGTOT FROM ADMPT_TMP_ALTACLIENTE_SVR 
      WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT (1) INTO K_NUMREGERR FROM ADMPT_TMP_ALTACLIENTE_SVR 
      WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NOT NULL OR ADMPV_MSJE_ERROR <> '')
      AND ADMPV_COD_ERROR  <> '105' AND ADMPV_COD_ERROR  <> '206'
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT (1) INTO K_NUMREG FROM ADMPT_IMP_ALTACLIENTESERV_SVR 
      WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT(1) INTO K_NUMCLIEXI FROM ADMPT_TMP_ALTACLIENTE_SVR D
      WHERE D.ADMPD_FEC_OPER = K_FEC_PROCESO AND D.ADMPV_COD_ERROR  = '105'
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT(1) INTO K_NUMCLIDUP FROM ADMPT_TMP_ALTACLIENTE_SVR C
      WHERE C.ADMPD_FEC_OPER = K_FEC_PROCESO AND C.ADMPV_COD_ERROR  = '206'
      AND C.ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

      SELECT K_NUMREG + K_NUMCLIEXI + K_NUMCLIDUP INTO K_NUMREGPRO FROM DUAL;

     -- Eliminamos los registros de la tabla temporal y auxiliar
     DELETE FROM ADMPT_TMP_ALTACLIENTE_SVR WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
     DELETE FROM ADMPT_TMP_ALTACLIENTESERV_SVR WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

     COMMIT;
     
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
     
  EXCEPTION    
      WHEN EX_ERROR THEN
        BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR
            INTO K_DESCERROR
            FROM ADMPT_ERRORES_CC
           WHERE ADMPN_COD_ERROR = K_CODERROR;
        EXCEPTION
          WHEN OTHERS THEN
            K_DESCERROR := 'ERROR';
        END;
  
      WHEN OTHERS THEN
        BEGIN
          ROLLBACK;
          K_CODERROR := 1;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
          SELECT ADMPV_DES_ERROR || K_DESCERROR 
            INTO K_DESCERROR
          FROM ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR = K_CODERROR;
        EXCEPTION
          WHEN OTHERS THEN
            K_DESCERROR := 'ERROR';
        END;

END ADMPSI_ALTACLIENTE_SVR;

PROCEDURE ADMPSI_ELIMINA_ALTACLIENTE_HFC
(  
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_NOMARC IN VARCHAR2,
  K_CODERROR OUT NUMBER, 
  K_DESCERROR OUT VARCHAR2 
) 
AS
  EX_ERROR EXCEPTION;
BEGIN
  
  K_CODERROR:=0;
  K_DESCERROR:='';
  
  IF K_TIPCLIENTE IS NULL THEN
      K_DESCERROR := 'Ingrese el tipo de cliente.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
  END IF;
  
  IF K_FEC_PROCESO IS NULL THEN
      K_DESCERROR := 'Ingrese la fecha a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
  END IF;
  
  IF K_NOMARC IS NULL THEN
      K_DESCERROR := 'Ingrese el nombre del archivo a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
  END IF;
  
  DELETE FROM ADMPT_TMP_ALTACLIENTE_SVR A WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO AND
  A.ADMPV_NOM_ARCH = K_NOMARC;
  
  COMMIT;

  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR
      INTO K_DESCERROR
      FROM ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;
  EXCEPTION
    WHEN OTHERS THEN
      K_DESCERROR := 'ERROR';
  END;

EXCEPTION
  WHEN EX_ERROR THEN
    ROLLBACK;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ELIMINA_ALTACLIENTE_HFC;

PROCEDURE ADMPSI_FACTURA
(
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2,
  K_CODERROR  OUT NUMBER,
  K_DESCERROR OUT VARCHAR2,
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER,
  K_NUMREGERR OUT NUMBER
) 
AS
 TYPE REC_PAGFAC IS RECORD(        
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPV_TIPO_SERV	VARCHAR2(4),
	  ADMPV_PERIODO_ANIO	VARCHAR2(4),
	  ADMPV_PERIODO_MES	VARCHAR2(2),
    ADMPN_MNT_CGOFIJ	NUMBER,
    ADMPN_DIAS_VENC	NUMBER,    
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPN_PUNTOS	NUMBER,
    ADMPC_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400),
    ADMPN_SEQ NUMBER
  );

  vRECPAGFAC  REC_PAGFAC;

  V_NUMDIAS NUMBER;
  V_TIPO_CLI VARCHAR2(2);
  V_TIPO_PUNTO CHAR(1);
  V_PUNTOS_PPAGO_NORMALS NUMBER;
  V_PUNTOS_CFIJS NUMBER;
  V_CODCLIPROD VARCHAR2(150);

  -- Codigos de conceptos por pagos
  V_CONCEP_PPAGO_N   NUMBER;
  V_CONCEP_CFIJ      NUMBER;
  V_IND_PROC_CFIJ    NUMBER;
  V_IND_PROC_PPAGO_N NUMBER;

  -- Costo por punto
  V_CTO_PPAGO NUMBER;
  V_CTO_CFIJ  NUMBER;

  -- Puntos x concepto
  V_PUNTOS_PPAGO_NORMAL NUMBER;
  V_PUNTOS_CFIJ         NUMBER;

  V_COD_CATCLI   NUMBER;
  V_COD_CLI_IB   VARCHAR2(40);
  V_TOTAL_PUNTOS NUMBER;
  ORA_ERROR      VARCHAR2(205);
  V_CONTADOR     NUMBER;
  --V_NOM_ARCH     VARCHAR2(150);
  --NRO_ERROR      NUMBER;
  --V_SEQ          NUMBER;

  EX_ERROR EXCEPTION;

  CURSOR CUR_PAGOS IS
    SELECT 
        ADMPV_TIP_CLIENTE,
        ADMPV_CUSTCODE,
        ADMPV_TIPO_SERV,
        ADMPV_PERIODO_ANIO,
	      ADMPV_PERIODO_MES,
        ADMPN_MNT_CGOFIJ,
        ADMPN_DIAS_VENC,        
        ADMPD_FEC_OPER,
        ADMPV_NOM_ARCH,
        ADMPN_PUNTOS,
        ADMPC_COD_ERROR,
        ADMPV_MSJE_ERROR,
        ADMPN_SEQ
    FROM 
        ADMPT_TMP_PAGO_FACT
    WHERE 
        (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')

        AND ADMPD_FEC_OPER = K_FEC_PROCESO;

BEGIN

  K_DESCERROR := '';
  K_CODERROR  := 0;
  --NRO_ERROR   := 0;
    
  IF K_FEC_PROCESO IS NULL THEN
    K_DESCERROR := 'Ingrese la fecha a procesar.';
    K_CODERROR  := 4;
    RAISE EX_ERROR;
  END IF;
    
  IF K_USUARIO IS NULL THEN
    K_DESCERROR := 'Ingrese el usuario procesar.';
    K_CODERROR  := 4;
    RAISE EX_ERROR;
  END IF;

  /** cod.servicio NO EXISTE **/
  UPDATE ADMPT_TMP_PAGO_FACT
     SET ADMPV_MSJE_ERROR = 'El codigo de servicio es un dato obligatorio.',
         ADMPC_COD_ERROR = '105'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND (ADMPV_TIPO_SERV IS NULL OR ADMPV_TIPO_SERV = '');
          
  /** Nro de Cuenta NO EXISTE **/
  UPDATE ADMPT_TMP_PAGO_FACT
     SET ADMPV_MSJE_ERROR = 'La cuenta es un dato obligatorio.',
         ADMPC_COD_ERROR = '106'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '');
     
  /** Servicio NO EXISTE **/
   UPDATE ADMPT_TMP_PAGO_FACT TP
     SET ADMPV_MSJE_ERROR = 'El servicio no existe, no se le puede asignar puntos.',
         ADMPC_COD_ERROR = '107'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '') 
     AND NOT EXISTS 
     (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P
      WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV);


  /** CLIENTE NO EXISTE **/
  UPDATE ADMPT_TMP_PAGO_FACT TP
    SET ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede asignar puntos.',
         ADMPC_COD_ERROR = '108'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '') 
    AND NOT EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI);

  /*** CLIENTE NO ES HFC ***/
  UPDATE ADMPT_TMP_PAGO_FACT TP
    SET ADMPV_MSJE_ERROR = 'El cliente no es HFC.',
         ADMPC_COD_ERROR = '109'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '') 
    AND EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
    AND TP.ADMPV_TIP_CLIENTE <> '7';
             

  /** SERVICIO NO ESTA ACTIVO **/
   UPDATE ADMPT_TMP_PAGO_FACT TP
    SET ADMPV_MSJE_ERROR = 'El servicio esta se encuentra en baja, no se le puede asignar puntos.',
         ADMPC_COD_ERROR = '201'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '') 
    AND EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI AND P.ADMPV_ESTADO_SERV = 'B');
    

  /** CLIENTE NO ESTA ACTIVO **/
   UPDATE ADMPT_TMP_PAGO_FACT TP
    SET ADMPV_MSJE_ERROR = 'El cliente no esta activo.',
         ADMPC_COD_ERROR = '202'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '') 
    AND EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI AND C.ADMPC_ESTADO = 'B');

  /** MONTOS INFERIORES A 0 **/
  UPDATE ADMPT_TMP_PAGO_FACT TP
    SET ADMPV_MSJE_ERROR = 'El monto es menor o igual a cero',
         ADMPC_COD_ERROR = '203'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '') 
    AND EXISTS 
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
    AND TP.ADMPN_MNT_CGOFIJ <= 0;
     

  BEGIN
    SELECT ADMPV_COD_CPTO, ADMPC_PROC
      INTO V_CONCEP_PPAGO_N, V_IND_PROC_PPAGO_N
      FROM ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'PRONTO PAGO NORMAL HFC'; -- Concepto - pronto pago normal --
    SELECT ADMPV_COD_CPTO, ADMPC_PROC
      INTO V_CONCEP_CFIJ, V_IND_PROC_CFIJ
      FROM ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'CARGO FIJO NORMAL HFC'; -- Concepto - cargo fijo --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_DESCERROR := '"PRONTO PAGO NORMAL HFC" o "CARGO FIJO NORMAL HFC"';
      K_CODERROR  := 9;
      RAISE EX_ERROR;
  END;

  -- Obtenemos la cantidad de dias de pago anticipado para considerarlo como pronto pago
  BEGIN
    SELECT TO_NUMBER(ADMPV_VALOR)
      INTO V_NUMDIAS
      FROM ADMPT_PARAMSIST
     WHERE UPPER(ADMPV_DESC) = 'DIAS_VENCIMIENTO_PAGO_CC';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_DESCERROR := 'Parametro = "DIAS_VENCIMIENTO_PAGO_CC".';
      K_CODERROR  := 14;
      RAISE EX_ERROR;
  END;
  
  OPEN CUR_PAGOS;
  FETCH CUR_PAGOS INTO vRECPAGFAC;
   
    WHILE CUR_PAGOS%FOUND LOOP
    
    BEGIN
      V_PUNTOS_PPAGO_NORMAL := 0;
      V_PUNTOS_CFIJ         := 0;
      V_TOTAL_PUNTOS        := 0;
      
      /*** Se genera el codigo para utilizar en todo el proceso **/
      V_CODCLIPROD:= vRECPAGFAC.ADMPV_CUSTCODE||'_'||vRECPAGFAC.ADMPV_TIPO_SERV;

      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM ADMPT_AUX_PAGO_DTH
       WHERE ADMPV_COD_CLI_PROD = V_CODCLIPROD
         AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO_ANIO || vRECPAGFAC.ADMPV_PERIODO_MES
         AND ADMPD_FEC_OPER = K_FEC_PROCESO
         AND ADMPV_NOM_ARCH = vRECPAGFAC.ADMPV_NOM_ARCH;
    
      IF V_CONTADOR = 0 THEN
         
        V_COD_CLI_IB := NULL;

        -- Busca la categoria del cliente
        SELECT F.ADMPN_COD_CATCLI, F.ADMPV_COD_TPOCL
          INTO V_COD_CATCLI, V_TIPO_CLI
          FROM ADMPT_CLIENTEFIJA F, ADMPT_CLIENTEPRODUCTO P
         WHERE P.ADMPV_COD_CLI_PROD = V_CODCLIPROD
           AND P.ADMPV_COD_CLI = F.ADMPV_COD_CLI;

        IF V_COD_CATCLI IS NULL THEN
          V_COD_CATCLI := 2; -- Cliente Normal
        END IF;

        -- Costo de Puntos x categoria A?ADIR EN LA TABLA CAT_CLIENTE EL NUEVO CLIENTE HFC --
        SELECT ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ
          INTO V_CTO_PPAGO, V_CTO_CFIJ
          FROM ADMPT_CAT_CLIENTE
         WHERE ADMPN_COD_CATCLI = V_COD_CATCLI
           AND ADMPV_COD_TPOCL = V_TIPO_CLI;          
       
        /*** Calculo de puntos para Pronto Pago Normal, Pronto Pago Adicional ***/
        
        -- Pronto Pago normal  --
        --Verifico la configuracion para otorgar puntos por Cargo Fijo
        IF V_IND_PROC_PPAGO_N IS NOT NULL AND V_IND_PROC_PPAGO_N = '1' THEN
      
          IF vRECPAGFAC.ADMPN_DIAS_VENC >= V_NUMDIAS THEN          
            --V_PUNTOS_PPAGO_NORMAL := TRUNC((V_MNT_CGOFIJ) / V_CTO_PPAGO, 0);
         
            V_PUNTOS_PPAGO_NORMAL := TRUNC((vRECPAGFAC.ADMPN_MNT_CGOFIJ) / V_CTO_PPAGO, 0);           
            IF V_PUNTOS_PPAGO_NORMAL <> 0 THEN
              IF V_PUNTOS_PPAGO_NORMAL > 0 THEN
                V_TIPO_PUNTO           := 'E';
                V_PUNTOS_PPAGO_NORMALS := V_PUNTOS_PPAGO_NORMAL;
              
                INSERT INTO ADMPT_KARDEXFIJA
                  (ADMPN_ID_KARDEX,
                   ADMPN_COD_CLI_IB,
                   ADMPV_COD_CLI_PROD,
                   ADMPV_COD_CPTO,
                   ADMPD_FEC_TRANS,
                   ADMPN_PUNTOS,
                   ADMPV_NOM_ARCH,
                   ADMPC_TPO_OPER,
                   ADMPC_TPO_PUNTO,
                   ADMPN_SLD_PUNTO,
                   ADMPC_ESTADO,
                   ADMPD_FEC_REG,
                   ADMPV_USU_REG)
                VALUES
                  (ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                   V_COD_CLI_IB,
                   V_CODCLIPROD,--V_COD_CLI_PROD,
                   V_CONCEP_PPAGO_N,
                   SYSDATE,
                   V_PUNTOS_PPAGO_NORMAL,
                   vRECPAGFAC.ADMPV_NOM_ARCH,--V_NOM_ARCH,
                   V_TIPO_PUNTO,
                   'C',
                   V_PUNTOS_PPAGO_NORMALS,
                   'A',
                   SYSDATE,
                   K_USUARIO);
              ELSE
                --V_TIPO_PUNTO := 'S';
                V_PUNTOS_PPAGO_NORMALS := 0;
                V_PUNTOS_PPAGO_NORMAL  := 0;
              END IF;
            END IF;
          ELSE
            UPDATE ADMPT_TMP_PAGO_FACT
               SET ADMPC_COD_ERROR  = '101',
                   ADMPV_MSJE_ERROR = 'El numero de dias de vencimiento sobrepasa el limite.'
             WHERE ADMPV_CUSTCODE  = vRECPAGFAC.ADMPV_CUSTCODE
               AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
               AND ADMPV_PERIODO_ANIO = vRECPAGFAC.ADMPV_PERIODO_ANIO 
			         AND ADMPV_PERIODO_MES = vRECPAGFAC.ADMPV_PERIODO_MES
               AND ADMPN_SEQ = vRECPAGFAC.ADMPN_SEQ;
          END IF;
        END IF;


        --Cargo Fijo--
        --Validamos que la configuracion para otorgar puntos por Cargo Fijo se encuentre habilitada
        IF V_IND_PROC_CFIJ IS NOT NULL AND V_IND_PROC_CFIJ = '1' THEN
          -- Calculo de puntos para Cargo Fijo
          V_PUNTOS_CFIJ := TRUNC((vRECPAGFAC.ADMPN_MNT_CGOFIJ) / V_CTO_CFIJ, 0);
      
          IF V_PUNTOS_CFIJ <> 0 THEN
            IF V_PUNTOS_CFIJ > 0 THEN
              V_TIPO_PUNTO   := 'E';
              V_PUNTOS_CFIJS := V_PUNTOS_CFIJ;

              INSERT INTO ADMPT_KARDEXFIJA
                (ADMPN_ID_KARDEX,
                 ADMPN_COD_CLI_IB,
                 ADMPV_COD_CLI_PROD,
                 ADMPV_COD_CPTO,
                 ADMPD_FEC_TRANS,
                 ADMPN_PUNTOS,
                 ADMPV_NOM_ARCH,
                 ADMPC_TPO_OPER,
                 ADMPC_TPO_PUNTO,
                 ADMPN_SLD_PUNTO,
                 ADMPC_ESTADO,
                 ADMPD_FEC_REG,
                 ADMPV_USU_REG)
              VALUES
                (ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                 V_COD_CLI_IB,
                 V_CODCLIPROD,--V_COD_CLI_PROD,
                 V_CONCEP_CFIJ,
                 SYSDATE,
                 V_PUNTOS_CFIJ,
                 vRECPAGFAC.ADMPV_NOM_ARCH,--V_NOM_ARCH,
                 V_TIPO_PUNTO,
                 'C',
                 V_PUNTOS_CFIJS,
                 'A',
                 SYSDATE,
                 K_USUARIO);

            ELSE
              V_PUNTOS_CFIJS := 0;
              V_PUNTOS_CFIJ  := 0;
            END IF;
          END IF;
     
        END IF;

        --Actualiza Tabla de Saldos con el total de puntos acumulados --
        V_TOTAL_PUNTOS := NVL(V_PUNTOS_PPAGO_NORMAL, 0) +
                          NVL(V_PUNTOS_CFIJ, 0);

        UPDATE ADMPT_SALDOS_CLIENTEFIJA
           SET ADMPN_SALDO_CC = ADMPN_SALDO_CC + V_TOTAL_PUNTOS,
               ADMPD_FEC_MOD  = SYSDATE,
               ADMPV_USU_MOD  = K_USUARIO
         WHERE ADMPV_COD_CLI_PROD = V_CODCLIPROD;

        --Actualiza el total de puntos (admpn_puntos) en ADMPT_tmp_pago_cc
        UPDATE ADMPT_TMP_PAGO_FACT
           SET ADMPN_PUNTOS = V_TOTAL_PUNTOS
         WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
           AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
           AND ADMPV_PERIODO_ANIO = vRECPAGFAC.ADMPV_PERIODO_ANIO 
		       AND ADMPV_PERIODO_MES = vRECPAGFAC.ADMPV_PERIODO_MES
           AND ADMPD_FEC_OPER = K_FEC_PROCESO;

        -- Insertamos en la tabla temporal por si es necesario el reproceso
        INSERT INTO ADMPT_AUX_PAGO_DTH
          (ADMPV_COD_CLI_PROD,
           ADMPV_PERIODO,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH)
        VALUES
          (V_CODCLIPROD,
           vRECPAGFAC.ADMPV_PERIODO_ANIO || vRECPAGFAC.ADMPV_PERIODO_MES, 
           K_FEC_PROCESO, 
           vRECPAGFAC.ADMPV_NOM_ARCH);
     
      
      ELSE
        UPDATE ADMPT_TMP_PAGO_FACT
           SET ADMPC_COD_ERROR  = '102',
               ADMPV_MSJE_ERROR = 'El servicio ya fue procesado'
         WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
           AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
           AND ADMPV_PERIODO_ANIO = vRECPAGFAC.ADMPV_PERIODO_ANIO 
		       AND ADMPV_PERIODO_MES = vRECPAGFAC.ADMPV_PERIODO_MES
           AND ADMPN_SEQ = vRECPAGFAC.ADMPN_SEQ;
        
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        IF V_COD_CATCLI IS NULL THEN
          UPDATE ADMPT_TMP_PAGO_FACT
             SET ADMPV_MSJE_ERROR = 'El cliente no se encuentra categorizado',
                 ADMPC_COD_ERROR  = '110'
           WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
             AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
             AND ADMPV_PERIODO_ANIO = vRECPAGFAC.ADMPV_PERIODO_ANIO 
		         AND ADMPV_PERIODO_MES = vRECPAGFAC.ADMPV_PERIODO_MES
             AND ADMPD_FEC_OPER = K_FEC_PROCESO;

        END IF;

        IF V_CTO_PPAGO IS NULL OR V_CTO_CFIJ IS NULL THEN
          UPDATE ADMPT_TMP_PAGO_FACT
             SET ADMPC_COD_ERROR  = '111',
                 ADMPV_MSJE_ERROR = 'No se pudo obtener el costo de puntos por categoria'
          WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
             AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
             AND ADMPV_PERIODO_ANIO = vRECPAGFAC.ADMPV_PERIODO_ANIO 
		         AND ADMPV_PERIODO_MES = vRECPAGFAC.ADMPV_PERIODO_MES;

        END IF;

      WHEN OTHERS THEN
        ORA_ERROR := SUBSTR(SQLERRM, 1, 250);
        UPDATE ADMPT_TMP_PAGO_FACT
           SET ADMPC_COD_ERROR = 'ORA', ADMPV_MSJE_ERROR = ORA_ERROR
         WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
           AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
           AND ADMPV_PERIODO_ANIO = vRECPAGFAC.ADMPV_PERIODO_ANIO 
		       AND ADMPV_PERIODO_MES = vRECPAGFAC.ADMPV_PERIODO_MES;

    END;

    FETCH CUR_PAGOS INTO vRECPAGFAC;
     
    END LOOP;


  -- Exportar datos a la tabla ADMPT_imp_pago_cc
    INSERT INTO ADMPT_IMP_PAGO_FACT
    SELECT 
           ADMPV_TIP_CLIENTE,           
           ADMPV_CUSTCODE,
           ADMPV_TIPO_SERV,
           ADMPV_PERIODO_ANIO,
		       ADMPV_PERIODO_MES,
           ADMPN_MNT_CGOFIJ,
           ADMPN_DIAS_VENC, 
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH,
           ADMPN_PUNTOS,
           ADMPC_COD_ERROR,
           ADMPV_MSJE_ERROR,          
           ADMPT_PAGODTH_SQ.NEXTVAL
      FROM ADMPT_TMP_PAGO_FACT
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
  SELECT COUNT(1) INTO K_NUMREGTOT FROM ADMPT_TMP_PAGO_FACT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;
  SELECT COUNT(1) INTO K_NUMREGERR FROM ADMPT_TMP_PAGO_FACT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NOT NULL);
  SELECT COUNT(1) INTO K_NUMREGPRO FROM ADMPT_TMP_PAGO_FACT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL);
  
  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE ADMPT_TMP_PAGO_FACT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;
  --DELETE ADMPT_AUX_PAGO_DTH WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;

  COMMIT;

  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR
      INTO K_DESCERROR
      FROM ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;
  EXCEPTION
    WHEN OTHERS THEN
      K_DESCERROR := 'ERROR';
  END;

EXCEPTION
  WHEN EX_ERROR THEN
    ROLLBACK;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_FACTURA;


PROCEDURE ADMPSI_ANIVERSARIO_CC
(
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2,
  K_CODERROR  OUT NUMBER,
  K_DESCERROR OUT VARCHAR2,
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER,
  K_NUMREGERR OUT NUMBER
) 
AS

  TYPE REC_PTOANIV IS RECORD(        
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPN_PUNTOS	NUMBER,
    ADMPC_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400),
    ADMPN_SEQ NUMBER
  );
  
  vRECPTOANIV REC_PTOANIV;
  
  TYPE REG_RODUCTO IS RECORD(        
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPN_PUNTOS	NUMBER
  );
  
  vREGRODUCTO REG_RODUCTO;  
  
  V_CODCONCEPTOHFC VARCHAR2(4);
  V_PUNTOSHFC NUMBER;
  V_FLAG_REGANIVER VARCHAR2(3);
  V_CANSER NUMBER;
  V_PTOSDIS NUMBER;
  EX_ERROR EXCEPTION;
  V_CUSCOD VARCHAR2(40);
  V_PUNACT NUMBER;
  V_ACUPTO NUMBER;
  V_CONTAD NUMBER;
  V_FILCUS VARCHAR2(40);
  V_CANINS NUMBER;

  CURSOR CUR_PTOSANIV IS
    SELECT
          ADMPV_TIP_CLIENTE,
          ADMPV_CUSTCODE,
          ADMPD_FEC_OPER,
          ADMPV_NOM_ARCH,
          ADMPN_PUNTOS,
          ADMPC_COD_ERROR,
          ADMPV_MSJE_ERROR,
          ADMPN_SEQ
    FROM 
          ADMPT_TMP_ANIV_CC
    WHERE 
          (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
          AND ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
  
  
   /****** Ini: ROLLBACK PRODUCTOS ******/
  CURSOR CUR_ROLLB_SALDOS IS
   SELECT 
         S.ADMPV_COD_CLI_PROD,
         S.ADMPN_SALDO_CC,
         S.ADMPC_ESTPTO_CC
   FROM 
         ADMPT_SALDOS_CLIENTEFIJA S 
   WHERE 
         SUBSTR(S.ADMPV_COD_CLI_PROD,0,INSTR(S.ADMPV_COD_CLI_PROD,'_')-1) = V_FILCUS         
         AND S.ADMPC_ESTPTO_CC = 'A'
         AND EXISTS 
         (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P
          WHERE P.ADMPV_COD_CLI_PROD = S.ADMPV_COD_CLI_PROD
          AND (SUBSTR(P.ADMPV_COD_CLI,-1,1)='7')
          AND P.ADMPV_ESTADO_SERV = 'A' );
                              
  TYPE REC_ROLLB_PD IS RECORD(        
   ADMPV_COD_CLI_PROD	VARCHAR2(40),
   ADMPN_SALDO_CC	NUMBER,
   ADMPC_ESTPTO_CC VARCHAR2(1)
  );
          
  vRECROLLBPD REC_ROLLB_PD;  
  /****** Fin: ROLLBACK PRODUCTOS ******/
    
BEGIN

  K_DESCERROR := '';
  K_CODERROR  := 0;
  V_CANSER := 0;
  V_PTOSDIS :=0;
  V_FILCUS := '';

    IF K_TIPCLIENTE IS NULL THEN
      K_DESCERROR := 'Ingrese el tipo de cliente a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_FEC_PROCESO IS NULL THEN
      K_DESCERROR := 'Ingrese la fecha a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_USUARIO IS NULL THEN
      K_DESCERROR := 'Ingrese el usuario procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;

  BEGIN
     
    SELECT NVL(ADMPV_VALOR,'0') INTO V_FLAG_REGANIVER
    FROM ADMPT_PARAMSIST
    WHERE TRIM(UPPER(ADMPV_DESC)) LIKE '%PUNTOS_ANIVERSARIO_HFC%';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        K_DESCERROR:='PUNTOS_ANIVERSARIO_HFC.';
        K_CODERROR:=9;
        RAISE EX_ERROR;
  END;
    
    BEGIN

      SELECT ADMPV_COD_CPTO INTO V_CODCONCEPTOHFC
      FROM ADMPT_CONCEPTO
      WHERE TRIM(UPPER(ADMPV_DESC)) LIKE '%ANIVERSARIO HFC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          K_DESCERROR:='ANIVERSARIO HFC.';
          K_CODERROR:=9;
          RAISE EX_ERROR;
    END;
  
    BEGIN

        SELECT NVL(ADMPV_VALOR,'0') INTO V_PUNTOSHFC
        FROM ADMPT_PARAMSIST
        WHERE UPPER(ADMPV_DESC) LIKE '%PUNTOS_ANIVERSARIO_HFC%';

        UPDATE ADMPT_TMP_ANIV_CC SET ADMPN_PUNTOS = V_PUNTOSHFC;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        K_DESCERROR:='PUNTOS_ANIVERSARIO_HFC.';
        K_CODERROR:=9;
        RAISE EX_ERROR;
    END;
    
    -- cod.servicio NO EXISTE --
    UPDATE ADMPT_TMP_ANIV_CC
       SET ADMPV_MSJE_ERROR = 'El tipo de cliente es un dato obligatorio.',
           ADMPC_COD_ERROR = '101'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_TIP_CLIENTE IS NULL OR ADMPV_TIP_CLIENTE = '');
            
    -- Nro de Cuenta NO EXISTE --
    UPDATE ADMPT_TMP_ANIV_CC
       SET ADMPV_MSJE_ERROR = 'La cuenta es un dato obligatorio.',
           ADMPC_COD_ERROR = '102'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
    -- No cuenta con servicios --
    UPDATE ADMPT_TMP_ANIV_CC A
      SET ADMPV_MSJE_ERROR = 'La cuenta no tiene servicios.',
          ADMPC_COD_ERROR = '103'
    WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO
      AND NOT EXISTS 
      (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P 
      WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,INSTR(P.ADMPV_COD_CLI_PROD,'_')-1) = A.ADMPV_CUSTCODE)
      AND (A.ADMPV_MSJE_ERROR IS NULL OR A.ADMPV_MSJE_ERROR = '')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
    -- Cliente en estado de BAJA --
    UPDATE ADMPT_TMP_ANIV_CC A
      SET ADMPV_MSJE_ERROR = 'El cliente se encuentra en baja.',
          ADMPC_COD_ERROR = '104'
    WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO
      AND EXISTS 
      (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P, ADMPT_CLIENTEFIJA C
      WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,INSTR(P.ADMPV_COD_CLI_PROD,'_')-1) = A.ADMPV_CUSTCODE 
      AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI 
      AND SUBSTR(P.ADMPV_COD_CLI,-1,1) = '7' 
      AND C.ADMPC_ESTADO = 'B')
      AND (A.ADMPV_MSJE_ERROR IS NULL OR A.ADMPV_MSJE_ERROR = '')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
    -- PUNTOS asignados igual o menor que CERO --
    UPDATE ADMPT_TMP_ANIV_CC A
      SET ADMPV_MSJE_ERROR = 'La cantidad de puntos es cero o menor que cero.',
          ADMPC_COD_ERROR = '105'
    WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO
      AND A.ADMPN_PUNTOS <= 0
      AND (A.ADMPV_MSJE_ERROR IS NULL OR A.ADMPV_MSJE_ERROR = '')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
        
    /***** Recorremos el Cursor *****/
    OPEN CUR_PTOSANIV;
    FETCH CUR_PTOSANIV INTO vRECPTOANIV;
           
      WHILE CUR_PTOSANIV%FOUND LOOP
              
      BEGIN

            V_FILCUS := vRECPTOANIV.ADMPV_CUSTCODE;

            OPEN CUR_ROLLB_SALDOS;
            V_CONTAD := 1;
            V_ACUPTO := 0;

            /**** Se valida servicios en baja ****/
            SELECT COUNT(1) INTO V_CANSER FROM ADMPT_CLIENTEPRODUCTO P 
            WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,INSTR(P.ADMPV_COD_CLI_PROD,'_')-1) = vRECPTOANIV.ADMPV_CUSTCODE 
            AND SUBSTR(P.ADMPV_COD_CLI,-1,1) = '7'
            AND P.ADMPV_ESTADO_SERV = 'A';
         
            IF V_CANSER > 0 THEN
                V_CANINS := 0;           
                BEGIN
                                                  
                   SELECT FLOOR(vRECPTOANIV.ADMPN_PUNTOS/V_CANSER) INTO V_PTOSDIS FROM DUAL;              
                                   
                EXCEPTION
                    WHEN OTHERS THEN
                      K_DESCERROR := 'Hubo inconvenientes al calcular los puntos.';
                      K_CODERROR:=1;
                END;
                              
               DECLARE CURSOR CUR_PTOSXPROD IS
                   SELECT
                          ADMPV_COD_CLI_PROD,                         
                          ADMPN_SALDO_CC
                   FROM 
                          ADMPT_SALDOS_CLIENTEFIJA S
                   WHERE 
                          SUBSTR(S.ADMPV_COD_CLI_PROD,0,INSTR(S.ADMPV_COD_CLI_PROD,'_')-1) = vRECPTOANIV.ADMPV_CUSTCODE
                          AND EXISTS 
                          (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P
                           WHERE P.ADMPV_COD_CLI_PROD = S.ADMPV_COD_CLI_PROD
                           AND SUBSTR(P.ADMPV_COD_CLI,-1,1) = '7'
                           AND P.ADMPV_ESTADO_SERV = 'A' );
              
                BEGIN

                    OPEN CUR_PTOSXPROD;
                    FETCH CUR_PTOSXPROD INTO vREGRODUCTO;   
                      WHILE CUR_PTOSXPROD%FOUND LOOP                          
                          
                          BEGIN

                              V_CUSCOD := vREGRODUCTO.ADMPV_CUSTCODE;
                              V_PUNACT := vREGRODUCTO.ADMPN_PUNTOS;
                              
                              IF V_CONTAD = 3 THEN
                                V_PTOSDIS := vRECPTOANIV.ADMPN_PUNTOS - V_ACUPTO;
                              END IF;
                              
                              /******** Ini: Suma el saldo ********/
                              UPDATE ADMPT_SALDOS_CLIENTEFIJA S
                              SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_PTOSDIS
                              WHERE ADMPV_COD_CLI_PROD = vREGRODUCTO.ADMPV_CUSTCODE;
                              /******** Ini: Suma el saldo ********/
                  
                              /******** Ini: Insertamos en KARDEX ********/ 
                              INSERT INTO ADMPT_KARDEXFIJA
                              (
                                  ADMPN_ID_KARDEX,
                                  ADMPN_COD_CLI_IB,
                                  ADMPV_COD_CLI_PROD,
                                  ADMPV_COD_CPTO,
                                  ADMPD_FEC_TRANS,
                                  ADMPN_PUNTOS,
                                  ADMPV_NOM_ARCH,
                                  ADMPC_TPO_OPER,
                                  ADMPC_TPO_PUNTO,
                                  ADMPN_SLD_PUNTO,
                                  ADMPC_ESTADO,
                                  ADMPD_FEC_REG,
                                  ADMPV_USU_REG
                              )
                              VALUES
                              (      
                                  ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                                  NULL,
                                  vREGRODUCTO.ADMPV_CUSTCODE,
                                  V_CODCONCEPTOHFC,
                                  SYSDATE,
                                  V_PTOSDIS,
                                  vRECPTOANIV.ADMPV_NOM_ARCH,
                                  'E',
                                  'C',
                                  V_PTOSDIS,
                                  'A',
                                  SYSDATE,
                                  K_USUARIO
                              );
                              /******** Fin: Insertamos en KARDEX ********/
                              
                              V_ACUPTO := V_ACUPTO + V_PTOSDIS;
                              V_CONTAD := V_CONTAD + 1;
                              V_CANINS := V_CANINS + 1;
                              
                          EXCEPTION
                              WHEN OTHERS THEN
                                               
                                  UPDATE ADMPT_TMP_ANIV_CC A
                                  SET A.ADMPV_MSJE_ERROR = 'Hubo inconvenientes al insertar en KARDEX o actualizar SALDO.', 
                                      A.ADMPC_COD_ERROR = '101'
                                  WHERE A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
                                  AND A.ADMPV_CUSTCODE = vRECPTOANIV.ADMPV_CUSTCODE
                                  AND A.ADMPD_FEC_OPER = K_FEC_PROCESO;
                              
                          END;
                     
                    FETCH CUR_PTOSXPROD INTO vREGRODUCTO;
                    END LOOP;

                END;
            
                    IF V_CANSER <> V_CANINS THEN

                      FETCH CUR_ROLLB_SALDOS INTO vRECROLLBPD;                               
                        WHILE CUR_ROLLB_SALDOS%FOUND LOOP                                
                          BEGIN
                                  
                            UPDATE ADMPT_SALDOS_CLIENTEFIJA S
                            SET S.ADMPN_SALDO_CC = vRECROLLBPD.ADMPN_SALDO_CC
                            WHERE S.ADMPV_COD_CLI_PROD = vRECROLLBPD.ADMPV_COD_CLI_PROD;                              
                                                      
                            DELETE FROM ADMPT_KARDEXFIJA K
                            WHERE K.ADMPV_COD_CLI_PROD = vRECROLLBPD.ADMPV_COD_CLI_PROD
                            AND K.ADMPV_NOM_ARCH = vRECPTOANIV.ADMPV_NOM_ARCH
                            AND K.ADMPV_USU_REG = K_USUARIO;                                  
                                  
                          END;
                        FETCH CUR_ROLLB_SALDOS INTO vRECROLLBPD;                                 
                        END LOOP;
                                                          
                    END IF;
            
            END IF;
            CLOSE CUR_ROLLB_SALDOS;                  
    
      END;

      FETCH CUR_PTOSANIV INTO vRECPTOANIV;     
      END LOOP;
        
      --- Obtenemos los registros totales, procesados y con error ---
      SELECT COUNT (1) INTO K_NUMREGTOT FROM ADMPT_TMP_ANIV_CC 
      WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT (1) INTO K_NUMREGERR FROM ADMPT_TMP_ANIV_CC 
      WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
      AND ADMPD_FEC_OPER = K_FEC_PROCESO 
      AND (ADMPV_MSJE_ERROR IS NOT NULL OR ADMPV_MSJE_ERROR <> '');
      
      SELECT COUNT (1) INTO K_NUMREGPRO FROM ADMPT_TMP_ANIV_CC 
      WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
      AND ADMPD_FEC_OPER = K_FEC_PROCESO 
      AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '');
      
      --- Insertamos de la tabla temporal a la final ---
      INSERT INTO ADMPT_IMP_ANIV_CC
      SELECT ADMPV_TIP_CLIENTE,ADMPV_CUSTCODE,ADMPV_CODCLI,ADMPV_MSISDN,ADMPV_TIPO_DOC,
             ADMPV_NUM_DOC,ADMPD_FEC_OPER,ADMPV_NOM_ARCH,ADMPN_PUNTOS,ADMPC_COD_ERROR,
             ADMPV_MSJE_ERROR,ADMPT_IMP_ANIVCC_SQ.NEXTVAL
      FROM ADMPT_TMP_ANIV_CC A
      WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO AND A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
      -- Eliminamos los registros de la tabla temporal y auxiliar --      
      DELETE FROM ADMPT_TMP_ANIV_CC WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
     
  COMMIT;

  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR
      INTO K_DESCERROR
      FROM ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;
  EXCEPTION
    WHEN OTHERS THEN
      K_DESCERROR := 'ERROR';
  END;

EXCEPTION
  WHEN EX_ERROR THEN
    ROLLBACK;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ANIVERSARIO_CC;

PROCEDURE ADMPSI_BAJA_CC
(
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2,
  K_CODERROR OUT NUMBER, 
  K_DESCERROR OUT VARCHAR2, 
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER, 
  K_NUMREGERR OUT NUMBER
) 
IS

  /****** Ini: PUNTOS BAJA ******/
  TYPE REC_PTOBAJ IS RECORD(        
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPD_FEC_BAJA	DATE,
    ADMPV_TIPO_DOC VARCHAR2(2),
    ADMPV_NUM_DOC VARCHAR2(20),
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPC_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400),
    ADMPN_SEQ NUMBER
  );
  
  vRECPTOBAJA REC_PTOBAJ;

  CURSOR CUR_PTOSBAJA IS
    SELECT
          ADMPV_TIP_CLIENTE,
          ADMPV_CUSTCODE,
          ADMPD_FEC_BAJA,
          ADMPV_TIPO_DOC,
          ADMPV_NUM_DOC,
          ADMPD_FEC_OPER,
          ADMPV_NOM_ARCH,
          ADMPC_COD_ERROR,
          ADMPV_MSJE_ERROR,
          ADMPN_SEQ
    FROM 
          ADMPT_TMP_BAJA_CC
    WHERE 
          (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
          AND ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
  /****** Fin: PUNTOS BAJA ******/

  /****** Ini: ROLLBACK PRODUCTOS BAJA ******/
  CURSOR CUR_ROLLB_SALDOS IS
   SELECT 
         S.ADMPV_COD_CLI_PROD,
         S.ADMPN_SALDO_CC,
         S.ADMPC_ESTPTO_CC
   FROM 
         ADMPT_SALDOS_CLIENTEFIJA S 
   WHERE    
         EXISTS
              (SELECT 1 FROM ADMPT_TMP_BAJA_CC B WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
               AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
               AND B.ADMPV_CUSTCODE = SUBSTR(S.ADMPV_COD_CLI_PROD,1,INSTR(S.ADMPV_COD_CLI_PROD,'_') - 1))
         AND S.ADMPC_ESTPTO_CC = 'A';
                              
  EX_ERROR EXCEPTION;

  V_CANT NUMBER;
  V_COD_CPTO VARCHAR2(2); 
  C_CODCLIENTE VARCHAR2(35);
  V_REG NUMBER;
  V_COD_NUEVO  NUMBER;
  V_COD_CLINUE VARCHAR2(40);
  
  nCOUNT NUMBER;
  nSALDO NUMBER;
  nSUMSALDO NUMBER;
  vCODCLIPROD VARCHAR2(40);
  V_IDKARDEX NUMBER;
  vCODCLIENTE VARCHAR2(40);
  nVALTRANS INTEGER;
  vCODCLIPRODAUX VARCHAR2(40);
  V_COD_CPTO2 VARCHAR2(2);
  

  
BEGIN

    K_CODERROR  := 0;
    K_DESCERROR := '';
    V_CANT := 0;

  IF K_TIPCLIENTE IS NULL THEN
     K_DESCERROR := 'Ingrese el tipo de cliente a procesar.';
     K_CODERROR  := 4;
     RAISE EX_ERROR;
  END IF;


  IF K_FEC_PROCESO IS NULL THEN
     K_DESCERROR := 'Ingrese la fecha a procesar.';
     K_CODERROR  := 4;
     RAISE EX_ERROR;
  END IF;
        

  IF K_USUARIO IS NULL THEN
     K_DESCERROR := 'Ingrese el usuario procesar.';
     K_CODERROR  := 4;
     RAISE EX_ERROR;
  END IF;
    

  /****** Tipo.Cliente Vacio ******/

  UPDATE ADMPT_TMP_BAJA_CC
     SET ADMPV_MSJE_ERROR = 'El tipo de cliente es un dato obligatorio.',
         ADMPC_COD_ERROR = '101'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND (ADMPV_TIP_CLIENTE IS NULL OR ADMPV_TIP_CLIENTE = '');
          

  /****** Cuenta Vacia ******/

  UPDATE ADMPT_TMP_BAJA_CC
     SET ADMPV_MSJE_ERROR = 'La cuenta es un dato obligatorio.',
         ADMPC_COD_ERROR = '102'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '')
     AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
  

  /****** Fec.Baja Vacia ******/

  UPDATE ADMPT_TMP_BAJA_CC
     SET ADMPV_MSJE_ERROR = 'La fecha de baja es un dato obligatorio.',
         ADMPC_COD_ERROR = '103'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
     AND (ADMPD_FEC_BAJA IS NULL OR ADMPD_FEC_BAJA = '')
     AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
     

/****** Cliente en Baja ******/

    UPDATE ADMPT_TMP_BAJA_CC E
    SET E.ADMPV_MSJE_ERROR = 'Cliente ya se encuentra en BAJA.',
        E.ADMPC_COD_ERROR  = '104'
    WHERE E.ADMPD_FEC_OPER = K_FEC_PROCESO AND E.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND (E.ADMPV_MSJE_ERROR IS NULL OR E.ADMPV_MSJE_ERROR = '')
    AND E.ADMPV_CUSTCODE IN
    (SELECT B.ADMPV_CUSTCODE FROM ADMPT_TMP_BAJA_CC B ,
         (SELECT DISTINCT P.ADMPV_COD_CLI,SUBSTR (P.ADMPV_COD_CLI_PROD,1,INSTR (P.ADMPV_COD_CLI_PROD, '_') - 1) AS ADMPV_COD_CLI_PROD 
             FROM ADMPT_CLIENTEPRODUCTO P
           ) C,
           ADMPT_CLIENTEFIJA D
    WHERE B.ADMPD_FEC_OPER = K_FEC_PROCESO AND B.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND (B.ADMPV_MSJE_ERROR IS NULL OR B.ADMPV_MSJE_ERROR = '')
    AND B.ADMPV_CUSTCODE = c.ADMPV_COD_CLI_PROD
    AND C.ADMPV_COD_CLI=D.ADMPV_COD_CLI
    AND D.ADMPC_ESTADO='B');


  /****** Cuenta sin Productos ******/

   UPDATE ADMPT_TMP_BAJA_CC B
     SET B.ADMPV_MSJE_ERROR = 'Cliente no posee servicios.',
         B.ADMPC_COD_ERROR = '105'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
   AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')    
   AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE
   AND NOT EXISTS 
   (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_ESTADO_SERV ='A'
    AND SUBSTR (P.ADMPV_COD_CLI_PROD,1,INSTR(P.ADMPV_COD_CLI_PROD, '_') - 1) = B.ADMPV_CUSTCODE);
             

  BEGIN
    --SE ALMACENA EL CODIGO DEL CONCEPTO 'BAJA CLIENTE'
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO
    FROM ADMPT_CONCEPTO
    WHERE ADMPV_DESC='BAJA CLIENTE HFC';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN 
    K_DESCERROR := 'BAJA CLIENTE HFC.';
				K_CODERROR  := 9;
				RAISE EX_ERROR;

  END;
    
  
  BEGIN
    --SE ALMACENA EL CODIGO DEL CONCEPTO 'INGRESO POR BAJA CLIENTE HFC'
    SELECT ADMPV_COD_CPTO
    INTO V_COD_CPTO2
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE ADMPV_DESC = 'INGRESO POR BAJA CLIENTE HFC';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    K_DESCERROR := 'INGRESO POR BAJA CLIENTE HFC.';
        K_CODERROR  := 9;
        RAISE EX_ERROR;

  END;

  /*OPEN CUR_ROLLB_SALDOS;*/-- ABRE Y CARGA DATOS PARA EL ROLLBACK
  
  OPEN CUR_PTOSBAJA;
  FETCH CUR_PTOSBAJA INTO vRECPTOBAJA;
  
    WHILE CUR_PTOSBAJA%FOUND LOOP    
    BEGIN
      
     C_CODCLIENTE := vRECPTOBAJA.ADMPV_TIPO_DOC||'.'||vRECPTOBAJA.ADMPV_NUM_DOC||'.'||vRECPTOBAJA.ADMPV_TIP_CLIENTE;
     vCODCLIENTE := C_CODCLIENTE;

     SELECT COUNT(1) INTO V_CANT FROM 
        ADMPT_TMP_BAJA_CC B,
       (SELECT DISTINCT P.ADMPV_COD_CLI,SUBSTR (P.ADMPV_COD_CLI_PROD,1,INSTR (P.ADMPV_COD_CLI_PROD, '_') - 1) AS ADMPV_COD_CLI_PROD 
           FROM ADMPT_CLIENTEPRODUCTO P
         ) C,
         ADMPT_CLIENTEFIJA D
        WHERE B.ADMPD_FEC_OPER = K_FEC_PROCESO AND B.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
        AND (B.ADMPV_MSJE_ERROR IS NULL OR B.ADMPV_MSJE_ERROR = '')
        AND B.ADMPV_CUSTCODE = C.ADMPV_COD_CLI_PROD 
        AND B.ADMPV_CUSTCODE = vRECPTOBAJA.ADMPV_CUSTCODE
        AND C.ADMPV_COD_CLI = D.ADMPV_COD_CLI
        AND D.ADMPC_ESTADO='B';

--
        IF V_CANT = 0 THEN
        
           DECLARE CURSOR KARDEX_BAJA(vCUENTA VARCHAR2) IS
           SELECT KF.ADMPV_COD_CLI_PROD, SUM(KF.ADMPN_SLD_PUNTO) 
           FROM ADMPT_KARDEXFIJA KF, (SELECT C.ADMPV_COD_CLI_PROD FROM ADMPT_CLIENTEPRODUCTO C
           WHERE C.ADMPV_ESTADO_SERV = 'A' AND C.ADMPV_COD_CLI_PROD LIKE vCUENTA||'%' ) CP
           WHERE KF.ADMPV_COD_CLI_PROD = CP.ADMPV_COD_CLI_PROD AND KF.ADMPN_SLD_PUNTO <> 0
           AND KF.ADMPC_ESTADO = 'A'
           GROUP BY KF.ADMPV_COD_CLI_PROD;
                               
                 
            BEGIN
                
              nCOUNT := 0;    
              nSALDO := 0;
              nSUMSALDO := 0;
                    
             /*------INICIO GENERAR MOVIMIENTO DE SALIDA BAJA-----*/

              OPEN KARDEX_BAJA(vRECPTOBAJA.ADMPV_CUSTCODE);
              FETCH KARDEX_BAJA INTO vCODCLIPROD, nSALDO;
              WHILE KARDEX_BAJA %FOUND LOOP

                nSUMSALDO := nSUMSALDO + nSALDO;        
                SELECT NVL(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,0) INTO V_IDKARDEX FROM DUAL;
                                             
                                
                                INSERT INTO ADMPT_KARDEXFIJA(
                                    ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,
                                    ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
                                    ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPC_TPO_OPER,
                                    ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,
                                    ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG)
                VALUES(V_IDKARDEX, vCODCLIPROD, V_COD_CPTO,SYSDATE, nSALDO*-1,'',
                'S', 'C', 0, 'B',SYSDATE,K_USUARIO);
                                 
                            
                UPDATE ADMPT_KARDEXFIJA K 
                SET K.ADMPC_ESTADO = 'B', K.ADMPN_SLD_PUNTO = 0, K.ADMPV_USU_MOD = K_USUARIO, 
                K.ADMPN_ID_KRDX_VTO = V_IDKARDEX, K.ADMPN_ULTM_SLD_PTO = K.ADMPN_SLD_PUNTO
                WHERE K.ADMPV_COD_CLI_PROD = vCODCLIPROD AND K.ADMPC_ESTADO = 'A'
                AND K.ADMPN_SLD_PUNTO <> 0;

                
              FETCH KARDEX_BAJA INTO vCODCLIPROD,nSALDO;
              END LOOP;

              CLOSE KARDEX_BAJA;
              /*--------FNI GENERAR MOVIMIENTO DE SALIDA BAJA------*/

              
              /*------INICIO DANDO DE BAJA A LA CUENTA-----*/

                            UPDATE ADMPT_SALDOS_CLIENTEFIJA S
              SET S.ADMPC_ESTPTO_CC = 'B', S.ADMPN_SALDO_CC = 0,
              S.ADMPV_USU_MOD = K_USUARIO, S.ADMPD_FEC_MOD = SYSDATE
              WHERE S.ADMPV_COD_CLI_PROD IN (SELECT C.ADMPV_COD_CLI_PROD FROM ADMPT_CLIENTEPRODUCTO C
              WHERE C.ADMPV_ESTADO_SERV = 'A' AND C.ADMPV_COD_CLI_PROD LIKE vRECPTOBAJA.ADMPV_CUSTCODE||'%'  )
                                AND S.ADMPC_ESTPTO_CC = 'A';                        
                            
  
                            UPDATE ADMPT_CLIENTEPRODUCTO P
                            SET P.ADMPV_ESTADO_SERV = 'B',
              P.ADMPV_USU_MOD = K_USUARIO, P.ADMPD_FEC_MOD = SYSDATE
              WHERE P.ADMPV_COD_CLI_PROD LIKE vRECPTOBAJA.ADMPV_CUSTCODE||'%'
              AND P.ADMPV_ESTADO_SERV = 'A';
                                                        
              /*---------FIN DANDO DE BAJA A LA CUENTA------*/
         
                               
              /*---VERIFICANDO SI SE TRANFIERE O DA DE BAJA---*/
                                
              SELECT COUNT(*) INTO nVALTRANS FROM ADMPT_CLIENTEPRODUCTO P
              WHERE P.ADMPV_COD_CLI_PROD NOT IN (SELECT C.ADMPV_COD_CLI_PROD FROM ADMPT_CLIENTEPRODUCTO C
              WHERE C.ADMPV_ESTADO_SERV = 'A' AND C.ADMPV_COD_CLI_PROD LIKE vRECPTOBAJA.ADMPV_CUSTCODE||'%' ) 
              AND P.ADMPV_COD_CLI = vCODCLIENTE
              AND P.ADMPV_ESTADO_SERV = 'A';
                                                            
                                                                                                        
              IF nVALTRANS > 0  THEN
              /*---INICIO TRANSFERENCIA DE PUNTOS---*/
                                  
                IF nSUMSALDO > 0 THEN
                  SELECT MAX(P.ADMPV_COD_CLI_PROD) INTO vCODCLIPRODAUX FROM ADMPT_CLIENTEPRODUCTO P
                  WHERE P.ADMPV_COD_CLI_PROD NOT IN (SELECT C.ADMPV_COD_CLI_PROD FROM ADMPT_CLIENTEPRODUCTO C
                  WHERE C.ADMPV_ESTADO_SERV = 'A' AND C.ADMPV_COD_CLI_PROD LIKE vRECPTOBAJA.ADMPV_CUSTCODE||'%' ) 
                  AND P.ADMPV_COD_CLI = vCODCLIENTE
                  AND P.ADMPV_ESTADO_SERV = 'A';
                                        
                                      
                  SELECT COUNT(*) INTO nCOUNT FROM ADMPT_SALDOS_CLIENTEFIJA SC
                  WHERE SC.ADMPV_COD_CLI_PROD = vCODCLIPRODAUX;

                            
                  IF nCOUNT>0 THEN
                    UPDATE ADMPT_SALDOS_CLIENTEFIJA SC
                    SET SC.ADMPN_SALDO_CC = SC.ADMPN_SALDO_CC + nSUMSALDO, SC.ADMPD_FEC_MOD = SYSDATE,
                    SC.ADMPV_USU_MOD = K_USUARIO
                    WHERE SC.ADMPV_COD_CLI_PROD = vCODCLIPRODAUX;

                  ELSE
                    INSERT INTO ADMPT_SALDOS_CLIENTEFIJA ( ADMPN_ID_SALDO, ADMPV_COD_CLI_PROD, ADMPN_SALDO_CC, ADMPC_ESTPTO_CC, ADMPD_FEC_REG, ADMPV_USU_REG)
                    VALUES(PCLUB.ADMPT_SLD_CLFIJA_SQ.NEXTVAL, vCODCLIPRODAUX, nSUMSALDO, 'A', SYSDATE, K_USUARIO);

                  END IF;
                
                
                  INSERT INTO PCLUB.ADMPT_KARDEXFIJA (ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,
                  ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
                  VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,vCODCLIPRODAUX, V_COD_CPTO2,SYSDATE,
                  nSUMSALDO,'E', 'C', nSUMSALDO, 'A',K_USUARIO,SYSDATE);
                
                  /*-----FIN TRANSFERENCIA DE PUNTOS----*/

                END IF;
                  
              ELSE
                /*-----INICIO BAJA DE CLIENTE----*/          
                   V_COD_NUEVO  := 1;
                   V_COD_CLINUE := '';

                   WHILE V_COD_NUEVO > 0 LOOP
                  V_COD_CLINUE := TRIM(vCODCLIENTE) || '-' || TO_CHAR(V_COD_NUEVO);
                      V_REG := 0;

                      BEGIN
                        SELECT COUNT(*) INTO V_REG FROM ADMPT_CLIENTEFIJA
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
                                      
            
                INSERT INTO ADMPT_CLIENTEFIJA(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,
                ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACTIV,ADMPC_ESTADO,ADMPV_COD_TPOCL,ADMPD_FEC_REG,ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD)
                SELECT V_COD_CLINUE,F.ADMPV_COD_SEGCLI,F.ADMPN_COD_CATCLI,F.ADMPV_TIPO_DOC,F.ADMPV_NUM_DOC,F.ADMPV_NOM_CLI,F.ADMPV_APE_CLI,F.ADMPC_SEXO,F.ADMPV_EST_CIVIL,
                F.ADMPV_EMAIL,F.ADMPV_PROV,F.ADMPV_DEPA,F.ADMPV_DIST,F.ADMPD_FEC_ACTIV,F.ADMPC_ESTADO,F.ADMPV_COD_TPOCL,F.ADMPD_FEC_REG,F.ADMPV_USU_REG, SYSDATE, K_USUARIO
                FROM ADMPT_CLIENTEFIJA F
                WHERE F.ADMPV_COD_CLI = vCODCLIENTE;


                   UPDATE ADMPT_CLIENTEPRODUCTO P
                   SET P.ADMPV_COD_CLI = V_COD_CLINUE, P.ADMPD_FEC_MOD = SYSDATE, 
                       P.ADMPV_USU_MOD = K_USUARIO
                WHERE P.ADMPV_COD_CLI = vCODCLIENTE;

                   
                   UPDATE ADMPT_CANJEFIJA
                   SET ADMPV_COD_CLI = V_COD_CLINUE, ADMPD_FEC_MOD = SYSDATE,
                      ADMPV_USU_MOD = K_USUARIO
                WHERE ADMPV_COD_CLI = vCODCLIENTE;

                     
                     UPDATE ADMPT_CLIENTEFIJA
                     SET ADMPC_ESTADO = 'B', ADMPD_FEC_MOD = SYSDATE,
                         ADMPV_USU_MOD = K_USUARIO
                     WHERE ADMPV_COD_CLI = V_COD_CLINUE;
                     
                  
                DELETE ADMPT_CLIENTEFIJA WHERE ADMPV_COD_CLI = vCODCLIENTE;          
                /*-------FIN BAJA DE CLIENTE-----*/

            
                   END IF;

            EXCEPTION
              WHEN OTHERS THEN
              ROLLBACK;
              UPDATE ADMPT_TMP_BAJA_CC A
              SET A.ADMPV_MSJE_ERROR = 'Hubo inconvenientes al insertar o actualizar la BAJA.',
              A.ADMPC_COD_ERROR = '106'
              WHERE A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
              AND A.ADMPV_CUSTCODE = vRECPTOBAJA.ADMPV_CUSTCODE
              AND A.ADMPD_FEC_OPER = K_FEC_PROCESO;
                
              COMMIT;            
            END;                              
                     

        ELSE
          
            UPDATE ADMPT_TMP_BAJA_CC E 
            SET E.ADMPV_MSJE_ERROR = 'Cliente ya se encuentra en BAJA.',
                E.ADMPC_COD_ERROR  = '104'
            WHERE E.ADMPD_FEC_OPER = K_FEC_PROCESO AND E.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
            AND (E.ADMPV_MSJE_ERROR IS NULL OR E.ADMPV_MSJE_ERROR = '')
            AND E.ADMPV_CUSTCODE IN
            (SELECT B.ADMPV_CUSTCODE FROM ADMPT_TMP_BAJA_CC B ,
                 (SELECT DISTINCT P.ADMPV_COD_CLI,SUBSTR (P.ADMPV_COD_CLI_PROD,1,INSTR (P.ADMPV_COD_CLI_PROD, '_') - 1) AS ADMPV_COD_CLI_PROD 
                                FROM ADMPT_CLIENTEPRODUCTO P
                   ) C,
                   ADMPT_CLIENTEFIJA D
            WHERE B.ADMPD_FEC_OPER = K_FEC_PROCESO AND B.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
            AND (B.ADMPV_MSJE_ERROR IS NULL OR B.ADMPV_MSJE_ERROR = '')
            AND B.ADMPV_CUSTCODE = c.ADMPV_COD_CLI_PROD
            AND C.ADMPV_COD_CLI=D.ADMPV_COD_CLI
            AND D.ADMPC_ESTADO='B');


        END IF;
                

    END;

    FETCH CUR_PTOSBAJA INTO vRECPTOBAJA;     
    END LOOP;
    
    CLOSE CUR_PTOSBAJA;

    --- Obtenemos los registros totales, procesados y con error ---
    SELECT COUNT (1) INTO K_NUMREGTOT FROM ADMPT_TMP_BAJA_CC 
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      

    SELECT COUNT (1) INTO K_NUMREGERR FROM ADMPT_TMP_BAJA_CC 
    WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
    AND ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPV_MSJE_ERROR IS NOT NULL OR ADMPV_MSJE_ERROR <> '');
      

    SELECT COUNT (1) INTO K_NUMREGPRO FROM ADMPT_TMP_BAJA_CC 
    WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
    AND ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '');
    

    /********* Ini: Se inserta en Historial *********/

    INSERT INTO ADMPT_IMP_BAJA_CC
      SELECT  ADMPV_TIP_CLIENTE,
              ADMPV_CUSTCODE,
              ADMPD_FEC_BAJA,
              ADMPV_TIPO_DOC,
              ADMPV_NUM_DOC,
              ADMPD_FEC_OPER,
              ADMPV_NOM_ARCH,
              ADMPC_COD_ERROR,
              ADMPV_MSJE_ERROR,
              ADMPT_IMP_BAJACC_SQ.NEXTVAL
      FROM    ADMPT_TMP_BAJA_CC
      WHERE   ADMPV_TIP_CLIENTE = K_TIPCLIENTE AND
              ADMPD_FEC_OPER = K_FEC_PROCESO;

     /********* Fin: Se inserta en Historial *********/
        

    DELETE FROM ADMPT_TMP_BAJA_CC 
    WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE AND ADMPD_FEC_OPER = K_FEC_PROCESO;
          

    COMMIT;

  BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;

  EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';

  END;


EXCEPTION
  WHEN EX_ERROR THEN
  ROLLBACK;
      BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;

      EXCEPTION WHEN OTHERS THEN
            K_DESCERROR:='ERROR';

      END;

  WHEN OTHERS THEN
     K_CODERROR:=1;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_BAJA_CC;

PROCEDURE ADMPSI_CAMBIOPLAN_HFCB
(
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2,
  K_CODERROR  OUT NUMBER,
  K_DESCERROR OUT VARCHAR2,
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER,
  K_NUMREGERR OUT NUMBER
)
AS

  TYPE REC_PTOCAMPLAHFCB IS RECORD(
    ADMPV_TIP_CLIENTE  VARCHAR2(2),
    ADMPV_TIPO_DOC  VARCHAR2(20),
    ADMPV_NUM_DOC  VARCHAR2(20),
    ADMPV_CUSTCODE  VARCHAR2(40),
    ADMPV_TIPO_SERV  VARCHAR2(20),
    ADMPV_FEC_CAM     DATE,
    ADMPC_TO   CHAR(1),
    ADMPD_FEC_OPER  DATE,
    ADMPV_NOM_ARCH  VARCHAR2(150),
    ADMPC_COD_ERROR  CHAR(3),
    ADMPV_MSJE_ERROR  VARCHAR2(400),
    ADMPN_SEQ  NUMBER
  );

  vRECPTOCAMPLA_HFCB REC_PTOCAMPLAHFCB;

  vCODCLI VARCHAR2(40);
  vCODCLIPROD VARCHAR2(40);
  vCANTPROD NUMBER;
  vSALDOCC NUMBER;
  vSALDOCCNEG NUMBER;
  vCODCPTO VARCHAR2(4);
  vSUMPTOS NUMBER;
  vCICFAC VARCHAR2(2);
  EX_ERROR EXCEPTION;
  vACT_SUMPTOS NUMBER;
  v_CUEBAJA VARCHAR2(40);
  v_CANTBAJA NUMBER;
  V_CANSINOBS NUMBER;
  V_SQ NUMBER;
  V_vCODCLIPROD VARCHAR2(40);
  V_STR_ROLLCODCLIPROD VARCHAR2(40);

  CURSOR CUR_PTOSCAMPLA_HFCB IS
    SELECT
          ADMPV_TIP_CLIENTE,
          ADMPV_TIPO_DOC,
          ADMPV_NUM_DOC,
          ADMPV_CUSTCODE,
          ADMPV_TIPO_SERV,
          ADMPD_FEC_CAM,
          ADMPC_TO,
          ADMPD_FEC_OPER,
          ADMPV_NOM_ARCH,
          ADMPC_COD_ERROR,
          ADMPV_MSJE_ERROR,
          ADMPN_SEQ
    FROM
          ADMPT_TMP_CAMBIOPLAN_HFCB
    WHERE
          (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
          AND ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

  CURSOR CUR_ROLLBACK (CUSTCODE VARCHAR2) IS
     SELECT S.ADMPV_COD_CLI_PROD,S.ADMPN_SALDO_CC,S.ADMPC_ESTPTO_CC
     FROM ADMPT_SALDOS_CLIENTEFIJA S
     WHERE SUBSTR(S.ADMPV_COD_CLI_PROD,0,INSTR(S.ADMPV_COD_CLI_PROD,'_')-1)
     IN (SELECT C.ADMPV_CUSTCODE FROM ADMPT_TMP_CAMBIOPLAN_HFCB C 
         WHERE C.ADMPV_CUSTCODE = CUSTCODE);

BEGIN

    K_DESCERROR := '';
    K_CODERROR  := 0;
    V_CANTBAJA  := 0;

    IF K_TIPCLIENTE IS NULL THEN
      K_DESCERROR := 'Ingrese el tipo de cliente a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;

    IF K_FEC_PROCESO IS NULL THEN
      K_DESCERROR := 'Ingrese la fecha a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;

    IF K_USUARIO IS NULL THEN
      K_DESCERROR := 'Ingrese el usuario procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
      
    BEGIN

      SELECT ADMPV_COD_CPTO INTO vCODCPTO
      FROM ADMPT_CONCEPTO
      WHERE TRIM(UPPER(ADMPV_DESC)) LIKE '%CAMBIO PLAN HFC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_DESCERROR:='CONCEPTO CAMBIO PLAN HFC.';
        K_CODERROR:=9;
        BEGIN
          DELETE FROM ADMPT_TMP_CAMBIOPLAN_HFCB 
          WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
          COMMIT;
        END;
        RAISE EX_ERROR;
    END;

    -- Tipo Cliente Vacio --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB
       SET ADMPV_MSJE_ERROR = 'El tipo de Cliente es un dato obligatorio.',
           ADMPC_COD_ERROR = '201'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_TIP_CLIENTE IS NULL OR ADMPV_TIP_CLIENTE = '');

    -- Tipo Documento Vacio --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB
       SET ADMPV_MSJE_ERROR = 'El tipo de Documento es un dato obligatorio.',
           ADMPC_COD_ERROR = '202'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_TIPO_DOC IS NULL OR ADMPV_TIPO_DOC = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    -- Nro Documento Vacio --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB
       SET ADMPV_MSJE_ERROR = 'El Nro de Documento es un dato obligatorio.',
           ADMPC_COD_ERROR = '203'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_NUM_DOC IS NULL OR ADMPV_NUM_DOC = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    -- Nro de Cuenta Vacia --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB
       SET ADMPV_MSJE_ERROR = 'La cuenta es un dato obligatorio.',
           ADMPC_COD_ERROR = '204'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    -- Servicio Vacio --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB
       SET ADMPV_MSJE_ERROR = 'El Tipo de Servicio es un dato obligatorio.',
           ADMPC_COD_ERROR = '205'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPV_TIPO_SERV IS NULL OR ADMPV_TIPO_SERV = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    -- Tipo de Operacion --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB
       SET ADMPV_MSJE_ERROR = 'El Tipo de Operación es un dato obligatorio.',
           ADMPC_COD_ERROR = '206'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
       AND (ADMPC_TO IS NULL OR ADMPC_TO = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    -- Producto No Registrado para Baja --
     UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB T 
       SET T.ADMPV_MSJE_ERROR = 'Servicio no Registrado para dar Baja.',
           T.ADMPC_COD_ERROR = '207'
    WHERE T.ADMPC_TO = 'D' AND NOT EXISTS  
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_ESTADO_SERV ='A'
     AND P.ADMPV_COD_CLI_PROD = T.ADMPV_CUSTCODE||'_'||T.ADMPV_TIPO_SERV);

     -- Producto Registrado para Alta --
     UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB T 
       SET T.ADMPV_MSJE_ERROR = 'Servicio ya Registrado.',
           T.ADMPC_COD_ERROR = '208'
    WHERE T.ADMPC_TO = 'U' AND EXISTS   
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_ESTADO_SERV ='A'
     AND P.ADMPV_COD_CLI_PROD = T.ADMPV_CUSTCODE||'_'||T.ADMPV_TIPO_SERV);

   -- Producto Ya en Baja --
     UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB T 
       SET T.ADMPV_MSJE_ERROR = 'Servicio se encuentra ya en Baja.',
           T.ADMPC_COD_ERROR = '209'
    WHERE T.ADMPC_TO = 'D' AND EXISTS  
    (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_ESTADO_SERV ='B'
     AND P.ADMPV_COD_CLI_PROD = T.ADMPV_CUSTCODE||'_'||T.ADMPV_TIPO_SERV);
    
    -- No figura custcode para dar de Alta --
    UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB T 
       SET T.ADMPV_MSJE_ERROR = 'Cliente no posee servicios.',
           T.ADMPC_COD_ERROR = '213'
    WHERE T.ADMPC_TO = 'U' AND (T.ADMPV_MSJE_ERROR IS NULL OR T.ADMPV_MSJE_ERROR = '') 
     AND T.ADMPV_TIP_CLIENTE = K_TIPCLIENTE AND
     NOT EXISTS 
     (SELECT 1 FROM ADMPT_CLIENTEPRODUCTO P 
     WHERE P.ADMPV_COD_CLI = T.ADMPV_TIPO_DOC||'.'||T.ADMPV_NUM_DOC||'.'||T.ADMPV_TIP_CLIENTE 
     AND SUBSTR(P.ADMPV_COD_CLI_PROD,1,INSTR(P.ADMPV_COD_CLI_PROD,'_')-1) = T.ADMPV_CUSTCODE);

    vCODCLI := '';
    vCODCLIPROD := '';
    vCANTPROD := 0;
    vSALDOCC := 0;
    vSALDOCCNEG := 0;
    vSUMPTOS := 0;
    vCICFAC := '';
    vACT_SUMPTOS := 0;
    V_CANSINOBS := 0;
    V_SQ := '';

    OPEN CUR_PTOSCAMPLA_HFCB;
      FETCH CUR_PTOSCAMPLA_HFCB INTO vRECPTOCAMPLA_HFCB;
      WHILE CUR_PTOSCAMPLA_HFCB%FOUND LOOP

      BEGIN

            vCODCLI := vRECPTOCAMPLA_HFCB.ADMPV_TIPO_DOC||'.'||vRECPTOCAMPLA_HFCB.ADMPV_NUM_DOC||'.'||vRECPTOCAMPLA_HFCB.ADMPV_TIP_CLIENTE;
            vCODCLIPROD := vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE ||'_'|| vRECPTOCAMPLA_HFCB.ADMPV_TIPO_SERV;

            OPEN CUR_ROLLBACK(vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE);
   
            SELECT COUNT(1) INTO V_CANSINOBS FROM ADMPT_TMP_CAMBIOPLAN_HFCB T
            WHERE T.ADMPV_CUSTCODE = vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE
            AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '');

            BEGIN

                IF V_CANSINOBS > 0 THEN
                
                  /******* INI: BAJA DE PRODUCTO *******/
                  IF vRECPTOCAMPLA_HFCB.ADMPC_TO = 'D' THEN
                     vSALDOCC := 0;
                     vSALDOCCNEG := 0;
                     BEGIN

                         SELECT NVL(S.ADMPN_SALDO_CC,0) INTO vSALDOCC FROM ADMPT_SALDOS_CLIENTEFIJA S
                         WHERE S.ADMPV_COD_CLI_PROD = vCODCLIPROD AND S.ADMPC_ESTPTO_CC = 'A';

                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB P
                             SET P.ADMPV_MSJE_ERROR = 'El servicio no fue encontrado.',
                                 P.ADMPC_COD_ERROR = '210'
                           WHERE P.ADMPD_FEC_OPER = K_FEC_PROCESO AND P.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
                             AND (P.ADMPV_MSJE_ERROR IS NULL OR P.ADMPV_MSJE_ERROR = '')
                             AND P.ADMPV_CUSTCODE = vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE
                             AND P.ADMPV_TIPO_SERV = vRECPTOCAMPLA_HFCB.ADMPV_TIPO_SERV
                             AND P.ADMPV_NUM_DOC = vRECPTOCAMPLA_HFCB.ADMPV_NUM_DOC;
                     END;

                     /********** Ini: Si existe Saldo, se da la BAJA **********/
                     IF vSALDOCC > 0 THEN

                          SELECT SUM(K.ADMPN_PUNTOS) INTO vACT_SUMPTOS FROM ADMPT_KARDEXFIJA K
                          WHERE K.ADMPV_COD_CLI_PROD = vCODCLIPROD AND K.ADMPC_ESTADO = 'A';

                          vSALDOCCNEG := vSALDOCC * (-1);

                          INSERT INTO ADMPT_KARDEXFIJA(
                              ADMPN_ID_KARDEX,ADMPV_COD_CLI_PROD,
                              ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
                              ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPC_TPO_OPER,
                              ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,
                              ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG)
                          VALUES(
                              ADMPT_KARDEXFIJA_SQ.NEXTVAL,vCODCLIPROD,
                              vCODCPTO,SYSDATE,
                              vSALDOCCNEG,vRECPTOCAMPLA_HFCB.ADMPV_NOM_ARCH,'S',
                              'C',0,
                              'A',SYSDATE,K_USUARIO
                          );                          
                       
                          SELECT SUM(K.ADMPN_PUNTOS) INTO vSUMPTOS FROM ADMPT_KARDEXFIJA K
                          WHERE K.ADMPV_COD_CLI_PROD = vCODCLIPROD AND K.ADMPC_ESTADO = 'A';
                          UPDATE ADMPT_SALDOS_CLIENTEFIJA S
                          SET S.ADMPN_SALDO_CC = vSUMPTOS, S.ADMPC_ESTPTO_CC = 'B',
                              S.ADMPV_USU_MOD = K_USUARIO
                          WHERE S.ADMPV_COD_CLI_PROD = vCODCLIPROD;

                          UPDATE ADMPT_KARDEXFIJA K SET K.ADMPC_ESTADO = 'B'
                          WHERE K.ADMPV_COD_CLI_PROD = vCODCLIPROD;

                      END IF;
                      /********** Fin: Si existe Saldo, se da la BAJA **********/
                      
                      /***** Ini: No existe saldo, Cambio Estado *****/                      
                      UPDATE ADMPT_CLIENTEPRODUCTO P 
                      SET P.ADMPV_ESTADO_SERV = 'B', P.ADMPV_USU_MOD = K_USUARIO
                      WHERE P.ADMPV_COD_CLI_PROD = vCODCLIPROD;
                      
                      UPDATE ADMPT_SALDOS_CLIENTEFIJA P 
                      SET P.ADMPC_ESTPTO_CC = 'B', P.ADMPV_USU_MOD = K_USUARIO
                      WHERE P.ADMPV_COD_CLI_PROD = vCODCLIPROD;
                      /***** Fin: No existe saldo, Cambio Estado *****/

                  END IF;
                  /******* FIN: BAJA DE PRODUCTO *******/

                  /******* INI: ALTA DE PRODUCTO *******/
                  IF vRECPTOCAMPLA_HFCB.ADMPC_TO = 'U' THEN

                     SELECT P.ADMPV_CICL_FACT INTO vCICFAC FROM ADMPT_CLIENTEPRODUCTO P
                     WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,INSTR(P.ADMPV_COD_CLI_PROD,'_')-1) = vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE --CAMBIO CCO
                     AND P.ADMPV_COD_CLI = vCODCLI AND ROWNUM = 1;

                     IF (vCICFAC = '' OR vCICFAC IS NULL) THEN
                          
                       UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB P
                         SET P.ADMPV_MSJE_ERROR = 'El ciclo de Facturacion no fue encontrado.',
                             P.ADMPC_COD_ERROR = '211'
                       WHERE P.ADMPD_FEC_OPER = K_FEC_PROCESO AND P.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
                         AND (P.ADMPV_MSJE_ERROR IS NULL OR P.ADMPV_MSJE_ERROR = '')
                         AND P.ADMPV_CUSTCODE = vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE
                         AND P.ADMPV_TIPO_SERV = vRECPTOCAMPLA_HFCB.ADMPV_TIPO_SERV
                         AND P.ADMPV_NUM_DOC = vRECPTOCAMPLA_HFCB.ADMPV_NUM_DOC;
                        
                     END IF;

                     IF LENGTH(TRIM(vCICFAC)) > 0 THEN

                          INSERT INTO ADMPT_CLIENTEPRODUCTO(
                              ADMPV_COD_CLI_PROD,ADMPV_COD_CLI,ADMPV_SERVICIO,
                              ADMPV_ESTADO_SERV,ADMPV_FEC_ULTANIV,ADMPD_FEC_REG,
                              ADMPV_USU_REG,ADMPV_INDICEGRUPO,ADMPV_CICL_FACT
                          )
                          VALUES(
                              vCODCLIPROD,vCODCLI,vRECPTOCAMPLA_HFCB.ADMPV_TIPO_SERV,
                              'A',SYSDATE,SYSDATE,
                              K_USUARIO,1,vCICFAC
                          );
                        
                          SELECT ADMPT_SLD_CLFIJA_SQ.NEXTVAL+1 INTO V_SQ FROM DUAL;
                     
                          INSERT INTO ADMPT_SALDOS_CLIENTEFIJA(
                             ADMPN_ID_SALDO,
                             ADMPV_COD_CLI_PROD,
                             ADMPN_COD_CLI_IB,
                             ADMPN_SALDO_CC,
                             ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,
                             ADMPD_FEC_REG,
                             ADMPV_USU_REG
                          )
                          VALUES(
                             V_SQ,
                             vCODCLIPROD,
                             NULL,
                             0,
                             0,'A',NULL,
                             SYSDATE,
                             K_USUARIO
                          );
                      
                     END IF;

                  END IF;
                  /******* FIN: ALTA DE PRODUCTO *******/

                END IF;

            EXCEPTION
               WHEN OTHERS THEN
                 K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
                 UPDATE ADMPT_TMP_CAMBIOPLAN_HFCB P
                   SET P.ADMPV_MSJE_ERROR = 'Hubo inconvenientes al registrar en tablas.',
                       P.ADMPC_COD_ERROR = '212'
                 WHERE P.ADMPD_FEC_OPER = K_FEC_PROCESO AND P.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
                   AND (P.ADMPV_MSJE_ERROR IS NULL OR P.ADMPV_MSJE_ERROR = '')
                   AND P.ADMPV_CUSTCODE = vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE
                   AND P.ADMPV_NUM_DOC = vRECPTOCAMPLA_HFCB.ADMPV_NUM_DOC;

                 IF vRECPTOCAMPLA_HFCB.ADMPC_TO = 'D' THEN
                    IF vSALDOCC > 0 THEN
                        DELETE FROM ADMPT_KARDEXFIJA WHERE ADMPN_PUNTOS = vSALDOCCNEG
                        AND ADMPD_FEC_REG = SYSDATE AND ADMPV_COD_CLI_PROD = vCODCLIPROD AND ADMPV_USU_REG = K_USUARIO;
                        UPDATE ADMPT_SALDOS_CLIENTEFIJA S
                        SET S.ADMPN_SALDO_CC = vACT_SUMPTOS WHERE S.ADMPV_COD_CLI_PROD = vCODCLIPROD;
                        UPDATE ADMPT_KARDEXFIJA K SET K.ADMPC_ESTADO = 'A'
                        WHERE K.ADMPV_COD_CLI_PROD = vCODCLIPROD AND ADMPD_FEC_REG = SYSDATE;
                    END IF;
                    IF vSALDOCC = 0 THEN
                          DELETE FROM ADMPT_CLIENTEPRODUCTO WHERE ADMPV_COD_CLI_PROD = vCODCLIPROD
                          AND ADMPV_USU_REG = K_USUARIO AND ADMPD_FEC_REG = SYSDATE;

                          DELETE FROM ADMPT_SALDOS_CLIENTEFIJA WHERE ADMPV_COD_CLI_PROD = vCODCLIPROD
                          AND ADMPV_USU_REG = K_USUARIO AND ADMPD_FEC_REG = SYSDATE;
                    END IF;
                 END IF;

                 IF vRECPTOCAMPLA_HFCB.ADMPC_TO = 'U' THEN

                   DELETE FROM ADMPT_KARDEXFIJA K WHERE K.ADMPN_PUNTOS < 0
                   AND SUBSTR(K.ADMPV_COD_CLI_PROD,0,INSTR(K.ADMPV_COD_CLI_PROD,'_')-1) = vRECPTOCAMPLA_HFCB.ADMPV_CUSTCODE
                   AND K.ADMPV_USU_REG = K_USUARIO AND K.ADMPV_COD_CPTO = vCODCPTO
                   AND K.ADMPD_FEC_REG = SYSDATE;
                   
                   DELETE FROM ADMPT_SALDOS_CLIENTEFIJA WHERE ADMPV_COD_CLI_PROD = vCODCLIPROD
                   AND ADMPV_USU_REG = K_USUARIO AND ADMPD_FEC_REG = SYSDATE;
                   DELETE FROM ADMPT_CLIENTEPRODUCTO WHERE ADMPV_COD_CLI_PROD = vCODCLIPROD
                   AND ADMPV_USU_REG = K_USUARIO AND ADMPD_FEC_REG = SYSDATE;

                 END IF;

                 DECLARE
                 V_ROLLCODCLIPROD VARCHAR2(40);
                 V_ROLLSALDOCC NUMBER;
                 V_ESTPTO_CC CHAR(1);

                 BEGIN
                     FETCH CUR_ROLLBACK INTO V_ROLLCODCLIPROD,V_ROLLSALDOCC,V_ESTPTO_CC;
                     WHILE CUR_ROLLBACK%FOUND LOOP
                       BEGIN

                           SELECT SUBSTR(vCODCLIPROD,0,INSTR(vCODCLIPROD,'_')-1) INTO V_vCODCLIPROD FROM DUAL;
                           SELECT SUBSTR(V_ROLLCODCLIPROD,0,INSTR(V_ROLLCODCLIPROD,'_')-1) INTO V_STR_ROLLCODCLIPROD FROM DUAL;

                           IF V_vCODCLIPROD = V_STR_ROLLCODCLIPROD THEN

                               DELETE FROM ADMPT_KARDEXFIJA K WHERE K.ADMPN_PUNTOS < 0
                               AND K.ADMPV_COD_CLI_PROD = V_ROLLCODCLIPROD
                               AND K.ADMPV_USU_REG = K_USUARIO AND K.ADMPV_COD_CPTO = vCODCPTO
                               AND K.ADMPD_FEC_REG = SYSDATE;

                               UPDATE
                                   ADMPT_SALDOS_CLIENTEFIJA S
                               SET S.ADMPN_SALDO_CC = V_ROLLSALDOCC,
                                   S.ADMPC_ESTPTO_CC = V_ESTPTO_CC
                               WHERE
                                   S.ADMPV_COD_CLI_PROD = V_ROLLCODCLIPROD;

                               DELETE FROM ADMPT_SALDOS_CLIENTEFIJA S WHERE ADMPV_USU_REG = K_USUARIO
                               AND EXISTS (SELECT 1 FROM ADMPT_TMP_CAMBIOPLAN_HFCB C WHERE
                               C.ADMPV_CUSTCODE ||'_'|| C.ADMPV_TIPO_SERV = S.ADMPV_COD_CLI_PROD AND
                               (C.ADMPV_MSJE_ERROR IS NOT NULL OR C.ADMPV_MSJE_ERROR <> ''));

                               DELETE FROM ADMPT_CLIENTEPRODUCTO P WHERE ADMPV_USU_REG = K_USUARIO
                               AND EXISTS (SELECT 1 FROM ADMPT_TMP_CAMBIOPLAN_HFCB C WHERE
                               C.ADMPV_CUSTCODE ||'_'|| C.ADMPV_TIPO_SERV = P.ADMPV_COD_CLI_PROD AND
                               (C.ADMPV_MSJE_ERROR IS NOT NULL OR C.ADMPV_MSJE_ERROR <> ''));

                           END IF;

                       END;
                     FETCH CUR_ROLLBACK INTO V_ROLLCODCLIPROD,V_ROLLSALDOCC,V_ESTPTO_CC;
                     END LOOP;
                 END;

            END;
            CLOSE CUR_ROLLBACK;

      EXCEPTION
        WHEN OTHERS THEN
          K_CODERROR  := 1;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;

      FETCH CUR_PTOSCAMPLA_HFCB INTO vRECPTOCAMPLA_HFCB;
      END LOOP;
    CLOSE CUR_PTOSCAMPLA_HFCB;

    --- Insertamos de la tabla temporal a la final ---
    INSERT INTO ADMPT_IMP_CAMBIOPLAN_HFCB
    SELECT ADMPV_TIP_CLIENTE,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_CUSTCODE,ADMPV_TIPO_SERV,
           ADMPD_FEC_CAM,ADMPC_TO,ADMPD_FEC_OPER,ADMPV_NOM_ARCH,ADMPC_COD_ERROR,ADMPV_MSJE_ERROR,
           ADMPT_IMP_CAMBIOPLANHFCB_SQ.NEXTVAL
    FROM ADMPT_TMP_CAMBIOPLAN_HFCB
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

   /***** Ini: Obtenemos los registros totales, procesados y con error *****/
    SELECT COUNT(1) INTO K_NUMREGTOT FROM ADMPT_TMP_CAMBIOPLAN_HFCB
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    SELECT COUNT(1) INTO K_NUMREGERR FROM ADMPT_TMP_CAMBIOPLAN_HFCB
    WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NOT NULL OR ADMPV_MSJE_ERROR <> '');

    SELECT COUNT(1) INTO K_NUMREGPRO FROM ADMPT_TMP_CAMBIOPLAN_HFCB
    WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '');
   /***** Fin: Obtenemos los registros totales, procesados y con error *****/

    DELETE FROM ADMPT_TMP_CAMBIOPLAN_HFCB WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    COMMIT;

    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;

EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
    WHEN OTHERS THEN
      ROLLBACK;
      K_CODERROR  := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      
END ADMPSI_CAMBIOPLAN_HFCB;



PROCEDURE ADMPSI_ALTACLIENTE_RPT
(
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2, 
  K_CODERROR OUT NUMBER, 
  K_DESCERROR OUT VARCHAR2, 
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER, 
  K_NUMREGERR OUT NUMBER
) 
AS
  TYPE REGALTACLI IS RECORD(  
    ADMPN_SEQ	NUMBER,
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPV_TIPO_DOC	VARCHAR2(20),
    ADMPV_NUM_DOC	VARCHAR2(20),
    ADMPV_NOM_CLI	VARCHAR2(80),
    ADMPV_APE_CLI	VARCHAR2(80),
    ADMPC_SEXO	CHAR(1),
    ADMPV_EST_CIVIL	VARCHAR2(20),
    ADMPV_EMAIL	VARCHAR2(80),
    ADMPV_PROV	VARCHAR2(30),
    ADMPV_DEPA	VARCHAR2(40),
    ADMPV_DIST	VARCHAR2(200),
    ADMPD_FEC_ACT	DATE,
    ADMPV_CICL_FACT	VARCHAR2(20),
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPV_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400)
  );

  vREGCLI  REGALTACLI;

  CURSOR ALTACLI IS
  SELECT *
  FROM PCLUB.ADMPT_TMP_ALTACLIENTE_RPT D
  WHERE D.ADMPD_FEC_OPER = K_FEC_PROCESO
  AND D.ADMPV_COD_ERROR='-1'
  AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
  EX_ERROR EXCEPTION;

  V_REGCLI NUMBER;
  V_REGCONT NUMBER;
  C_CODCLI VARCHAR2(40);
  V_REGOK NUMBER;
  COD_SALDO VARCHAR2(40);
  V_IDSALDO  NUMBER;
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  V_NOMARCSER VARCHAR2(150);
  V_CLIEXI NUMBER;
  V_CANCLI NUMBER;
    V_CANPROD NUMBER;
  V_COUNT_COMMIT NUMBER;   
  BEGIN

    K_CODERROR:=0;
    K_DESCERROR:='';
    V_CLIEXI:=0;
    V_CANCLI:=0;
    
    IF K_TIPCLIENTE IS NULL THEN
      K_DESCERROR := 'Ingrese el tipo de cliente a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_FEC_PROCESO IS NULL THEN
      K_DESCERROR := 'Ingrese la fecha a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_USUARIO IS NULL THEN
      K_DESCERROR := 'Ingrese el usuario procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;

    /** Ini: Validaciones Alta Cliente **/
    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT
    SET ADMPV_MSJE_ERROR='La cuenta es un dato obligatorio.', 
        ADMPV_COD_ERROR = '101'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND 
    (ADMPV_COD_ERROR = '-1')
    AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE='')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT
    SET ADMPV_MSJE_ERROR='El tipo de cliente es un dato obligatorio.', 
        ADMPV_COD_ERROR = '102'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND 
    (ADMPV_COD_ERROR = '-1')
    AND (ADMPV_TIP_CLIENTE IS NULL OR ADMPV_TIP_CLIENTE = '');

    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT
    SET ADMPV_MSJE_ERROR='El codigo y tipo de documento son datos obligatorios.', 
        ADMPV_COD_ERROR = '103'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND 
    (ADMPV_COD_ERROR = '-1')
    AND (ADMPV_TIPO_DOC IS NULL OR ADMPV_NUM_DOC IS NULL)
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    --- Si tiene un servicio ya registrado se marca a no procesar ---
    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT A
    SET A.ADMPV_MSJE_ERROR = 'Uno o varios de los servicios ya se encuentran registrados.', 
        A.ADMPV_COD_ERROR = '104'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_COD_ERROR = '-1')
    AND A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT S
     WHERE P.ADMPV_COD_CLI_PROD = S.ADMPV_CUSTCODE ||'_'|| S.ADMPV_TIPO_SERV
     AND P.ADMPV_COD_CLI = A.ADMPV_TIPO_DOC ||'.'|| A.ADMPV_NUM_DOC ||'.'|| A.ADMPV_TIP_CLIENTE);    
    /** Fin: Validaciones Alta Cliente **/

    /** Ini: Validaciones Del Servicio **/
    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT
    SET ADMPV_MSJE_ERROR = 'El codigo de cuenta es un dato obligatorio.', 
        ADMPV_COD_ERROR = '201'    
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    and (ADMPV_COD_ERROR = '-1')
    AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
        
    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT
    SET ADMPV_MSJE_ERROR = 'El tipo de servicio es un dato obligatorio.', 
        ADMPV_COD_ERROR = '202'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_COD_ERROR = '-1')
    AND (ADMPV_TIPO_SERV IS NULL OR ADMPV_TIPO_SERV = '')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;

    UPDATE PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT TP
    SET TP.ADMPV_MSJE_ERROR = 'El codigo de servicio ya se encuentra registrado.', 
        ADMPV_COD_ERROR = '203'
    WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
    AND (ADMPV_COD_ERROR = '-1')
    AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE
    AND EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_TMP_ALTACLIENTE_RPT C
     WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE ||'_'|| TP.ADMPV_TIPO_SERV
     AND P.ADMPV_COD_CLI = C.ADMPV_TIPO_DOC ||'.'|| C.ADMPV_NUM_DOC ||'.'|| C.ADMPV_TIP_CLIENTE);    
    /** Fin: Validaciones Del Servicio **/

    COMMIT;

    SELECT COUNT(1) INTO V_CANCLI FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;

    IF V_CANCLI > 0 THEN
      SELECT ADMPV_NOM_ARCH INTO V_NOMARCSER FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT
      WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ROWNUM = 1;
    END IF;

 OPEN ALTACLI;

     FETCH ALTACLI INTO vREGCLI;
     V_COUNT_COMMIT:=0;
     WHILE ALTACLI%FOUND     
     LOOP
          V_COUNT_COMMIT:=V_COUNT_COMMIT+1;

          SELECT COUNT(1) INTO V_REGOK 
          FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT 
          WHERE 
          ADMPD_FEC_OPER = K_FEC_PROCESO
          AND ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
          AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE
          AND (ADMPV_COD_ERROR = '-1');

          SELECT COUNT(1) INTO V_REGCLI
          FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT S
          WHERE 
          S.ADMPD_FEC_OPER = K_FEC_PROCESO
          AND S.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
          AND S.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE;
                             
           --generamos el codigo unico que nos permitira identificar          
          C_CODCLI:= vREGCLI.ADMPV_TIPO_DOC||'.'||vREGCLI.ADMPV_NUM_DOC||'.'||vREGCLI.ADMPV_TIP_CLIENTE;
         
          IF V_REGCLI > 0 THEN
            
             IF V_REGCLI = V_REGOK THEN
                            
                BEGIN
             
                  /** INI: INSERTAMOS AL CLIENTE **/
                  SELECT COUNT(1) INTO V_CLIEXI FROM PCLUB.ADMPT_CLIENTEFIJA C 
                  WHERE C.ADMPV_COD_CLI = C_CODCLI;
                  IF V_CLIEXI = 0 THEN
                       INSERT INTO PCLUB.ADMPT_CLIENTEFIJA H
                          (H.ADMPV_COD_CLI,
                           H.ADMPV_COD_SEGCLI,
                           H.ADMPN_COD_CATCLI,
                           H.ADMPV_TIPO_DOC,
                           H.ADMPV_NUM_DOC,
                           H.ADMPV_NOM_CLI,
                           H.ADMPV_APE_CLI,
                           H.ADMPC_SEXO,
                           H.ADMPV_EST_CIVIL,
                           H.ADMPV_EMAIL,
                           H.ADMPV_PROV,
                           H.ADMPV_DEPA,
                           H.ADMPV_DIST,
                           H.ADMPD_FEC_ACTIV,  
                           H.ADMPC_ESTADO,
                           H.ADMPV_COD_TPOCL,
                           H.ADMPD_FEC_REG,
                           H.ADMPV_USU_REG)
                        VALUES
                          (C_CODCLI,
                           NULL,
                           2,
                           vREGCLI.ADMPV_TIPO_DOC,
                           vREGCLI.ADMPV_NUM_DOC,
                           vREGCLI.ADMPV_NOM_CLI,
                           vREGCLI.ADMPV_APE_CLI,
                           vREGCLI.ADMPC_SEXO,
                           vREGCLI.ADMPV_EST_CIVIL,
                           vREGCLI.ADMPV_EMAIL,
                           vREGCLI.ADMPV_PROV,
                           vREGCLI.ADMPV_DEPA,
                           vREGCLI.ADMPV_DIST,
                           SYSDATE,
                           'A',
                           vREGCLI.ADMPV_TIP_CLIENTE,
                           SYSDATE,
                           K_USUARIO);                   
                  END IF;
                  /** FIN: INSERTAMOS AL CLIENTE **/

                  SELECT COUNT(1) INTO V_CANPROD FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
                  INNER JOIN PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT R
                  ON C.ADMPV_COD_CLI_PROD = R.ADMPV_CUSTCODE ||'_'|| R.ADMPV_TIPO_SERV
                  WHERE 
                  R.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                  AND R.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE;

                 /** INI: INSERTAMOS LOS SERVICIOS **/               
                   INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO H 
                   (
                          H.ADMPV_COD_CLI_PROD,H.ADMPV_COD_CLI,H.ADMPV_SERVICIO,
                          H.ADMPV_ESTADO_SERV,H.ADMPV_FEC_ULTANIV,H.ADMPD_FEC_REG,
                          H.ADMPV_USU_REG,H.ADMPV_INDICEGRUPO,H.ADMPV_CICL_FACT
                   )
                   SELECT  RPT.ADMPV_CUSTCODE ||'_'|| RPT.ADMPV_TIPO_SERV,C_CODCLI,RPT.ADMPV_TIPO_SERV,
                          'A',SYSDATE,SYSDATE,
                          K_USUARIO,1,vREGCLI.ADMPV_CICL_FACT FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT RPT
                    INNER JOIN (

                            SELECT Z.T FROM (
                            SELECT (R.ADMPV_CUSTCODE ||'_'|| R.ADMPV_TIPO_SERV) T  FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT R
                                              WHERE R.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                                              AND R.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE) Z
                            MINUS 
                            SELECT Y.T FROM (SELECT /*+ parallel 5*/ C.ADMPV_COD_CLI_PROD T  FROM PCLUB.ADMPT_CLIENTEPRODUCTO C
                                              INNER JOIN PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT R
                                              ON C.ADMPV_COD_CLI_PROD = R.ADMPV_CUSTCODE ||'_'|| R.ADMPV_TIPO_SERV
                                              WHERE R.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                                              AND R.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE) Y
                    ) J ON RPT.ADMPV_CUSTCODE ||'_'|| RPT.ADMPV_TIPO_SERV = J.T
                    WHERE RPT.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                                              AND RPT.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE;                          
                 /** FIN: INSERTAMOS LOS SERVICIOS **/
                 
                 /** INI: INSERTAMOS EL SALDO **/              
                    INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                    (
                       ADMPN_ID_SALDO,
                       ADMPV_COD_CLI_PROD,
                       ADMPN_COD_CLI_IB,
                       ADMPN_SALDO_CC,
                       ADMPN_SALDO_IB,
                       ADMPC_ESTPTO_CC,
                       ADMPC_ESTPTO_IB,
                       ADMPD_FEC_REG,
                       ADMPV_USU_REG
                     )              
                    SELECT 
                      (ADMPT_SLD_CLFIJA_SQ.NEXTVAL + 1),
                       S.ADMPV_CUSTCODE ||'_'|| S.ADMPV_TIPO_SERV,
                       NULL,
                       0,
                       0,'A',NULL,
                       SYSDATE,
                       K_USUARIO
                    FROM 
                       PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT S
                    WHERE 
                       S.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                       AND S.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE;
                 /** FIN: INSERTAMOS EL SALDO **/

                EXCEPTION                    
                    WHEN OTHERS THEN
                      
                      UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT T
                      SET T.ADMPV_MSJE_ERROR = 'ERROR al insertar cliente o sus servicios.', 
                          T.ADMPV_COD_ERROR = '101'
                      WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                      AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                      AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                      AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC;
                      
                      IF V_CLIEXI = 0 THEN
                        DELETE FROM PCLUB.ADMPT_CLIENTEFIJA C WHERE C.ADMPV_COD_CLI = C_CODCLI;
                      END IF;
                      
                      DELETE FROM PCLUB.ADMPT_CLIENTEPRODUCTO P WHERE P.ADMPV_COD_CLI = C_CODCLI
                      AND EXISTS 
                      (SELECT 1 FROM PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT S WHERE P.ADMPV_COD_CLI_PROD = S.ADMPV_CUSTCODE ||'_'||S.ADMPV_TIPO_SERV) 
                      AND P.ADMPV_USU_REG = K_USUARIO;
                      
                END;
                   
             ELSE
               
                UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT T
                SET T.ADMPV_MSJE_ERROR='El cliente no cuenta con todos los servicios correctos a procesar.', 
                    ADMPV_COD_ERROR = '205'
                WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC;
             
             END IF;            

          ELSE
              
                UPDATE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT T
                SET T.ADMPV_MSJE_ERROR='El cliente no cuenta con servicios a procesar.', 
                    ADMPV_COD_ERROR = '204'
                WHERE T.ADMPV_TIP_CLIENTE = vREGCLI.ADMPV_TIP_CLIENTE
                AND T.ADMPV_CUSTCODE = vREGCLI.ADMPV_CUSTCODE
                AND T.ADMPV_TIPO_DOC = vREGCLI.ADMPV_TIPO_DOC
                AND T.ADMPV_NUM_DOC = vREGCLI.ADMPV_NUM_DOC;
             
          END IF;
          
          IF (V_COUNT_COMMIT=100) THEN
            V_COUNT_COMMIT:=0;
            COMMIT;
          END IF;
          
          --COMMIT;
          FETCH ALTACLI INTO vREGCLI;
     END LOOP;
     COMMIT;
      -- Exportar datos a la tabla ADMPT_IMP_ALTACLIENTESERV_SVR
      INSERT INTO PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT
      SELECT 
          PCLUB.ADMPT_IMP_ALTACLIESERVRPT_SQ.NEXTVAL,ADMPV_TIP_CLIENTE,ADMPV_CUSTCODE,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_CLI,
          ADMPV_APE_CLI,ADMPC_SEXO,ADMPV_EST_CIVIL,ADMPV_EMAIL,ADMPV_PROV,ADMPV_DEPA,ADMPV_DIST,ADMPD_FEC_ACT,ADMPV_CICL_FACT,
          NULL,ADMPV_TIPO_DOC||'.'||ADMPV_NUM_DOC||'.'||ADMPV_TIP_CLIENTE,ADMPD_FEC_OPER,ADMPV_NOM_ARCH,V_NOMARCSER,ADMPV_COD_ERROR, 
          ADMPV_MSJE_ERROR
      FROM PCLUB.ADMPT_TMP_ALTACLIENTE_RPT
      WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE
      AND ADMPD_FEC_OPER = K_FEC_PROCESO;
      COMMIT;
    -- Generar Resultados (Total registros, Total procesados, Total de errores)
      SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ALTACLIENTE_RPT 
      WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ALTACLIENTE_RPT 
      WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NOT NULL OR ADMPV_MSJE_ERROR <> '')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT 
      WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      

     -- Eliminamos los registros de la tabla temporal y auxiliar
     DELETE FROM PCLUB.ADMPT_TMP_ALTACLIENTE_RPT WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
     DELETE FROM PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT WHERE ADMPD_FEC_OPER=K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
     COMMIT;
    
     
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
      WHEN EX_ERROR THEN
        BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR
            INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
           WHERE ADMPN_COD_ERROR = K_CODERROR;
        EXCEPTION
          WHEN OTHERS THEN
            K_DESCERROR := 'ERROR';
        END;
  
      WHEN OTHERS THEN
        BEGIN
          ROLLBACK;
          K_CODERROR := 1;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
          SELECT ADMPV_DES_ERROR || K_DESCERROR 
            INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR = K_CODERROR;
        EXCEPTION
          WHEN OTHERS THEN
            K_DESCERROR := 'ERROR';
        END;

END ADMPSI_ALTACLIENTE_RPT;

PROCEDURE ADMPSI_FACTURA_HFC
(
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2,
  K_CODERROR  OUT NUMBER,
  K_DESCERROR OUT VARCHAR2,
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER,
  K_NUMREGERR OUT NUMBER
) 
AS
 TYPE REC_PAGFAC IS RECORD(        
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPV_TIPO_SERV	VARCHAR2(4),
    ADMPV_PERIODO	VARCHAR2(6),
    ADMPN_DIAS_VENC	NUMBER,
    ADMPN_MNT_CGOFIJ	NUMBER,
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPN_PUNTOS	NUMBER,
    ADMPC_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400),
    ADMPN_SEQ NUMBER
  );

  vRECPAGFAC  REC_PAGFAC;

  V_NUMDIAS NUMBER;
  V_TIPO_CLI VARCHAR2(2);
  V_TIPO_PUNTO CHAR(1);
  V_PUNTOS_PPAGO_NORMALS NUMBER;
  V_PUNTOS_CFIJS NUMBER;
  V_CODCLIPROD VARCHAR2(150);

  -- Codigos de conceptos por pagos
  V_CONCEP_PPAGO_N   NUMBER;
  V_CONCEP_CFIJ      NUMBER;
  V_IND_PROC_CFIJ    NUMBER;
  V_IND_PROC_PPAGO_N NUMBER;

  -- Costo por punto
  V_CTO_PPAGO NUMBER;
  V_CTO_CFIJ  NUMBER;

  -- Puntos x concepto
  V_PUNTOS_PPAGO_NORMAL NUMBER;
  V_PUNTOS_CFIJ         NUMBER;

  V_COD_CATCLI   NUMBER;
  V_COD_CLI_IB   VARCHAR2(40);
  V_TOTAL_PUNTOS NUMBER;
  ORA_ERROR      VARCHAR2(205);
  V_CONTADOR     NUMBER;
  V_NOM_ARCH     VARCHAR2(150);
  NRO_ERROR      NUMBER;
  V_SEQ          NUMBER;

  EX_ERROR EXCEPTION;

  CURSOR CUR_PAGOS IS
    SELECT 
        ADMPV_TIP_CLIENTE,
        ADMPV_CUSTCODE,
        ADMPV_TIPO_SERV,
        ADMPV_PERIODO_ANIO||ADMPV_PERIODO_MES AS ADMPV_PERIODO,
        ADMPN_DIAS_VENC,
        ADMPN_MNT_CGOFIJ,
        ADMPD_FEC_OPER,
        ADMPV_NOM_ARCH,
        ADMPN_PUNTOS,
        ADMPC_COD_ERROR,
        ADMPV_MSJE_ERROR,
        ADMPN_SEQ
    FROM 
        PCLUB.ADMPT_TMP_PAGOFACT_RPT
    WHERE 
        (ADMPC_COD_ERROR='-1')
        AND ADMPD_FEC_OPER = K_FEC_PROCESO;

BEGIN

  K_DESCERROR := '';
  K_CODERROR  := 0;
  NRO_ERROR   := 0;
    
  IF K_FEC_PROCESO IS NULL THEN
    K_DESCERROR := 'Ingrese la fecha a procesar.';
    K_CODERROR  := 4;
    RAISE EX_ERROR;
  END IF;
    
  IF K_USUARIO IS NULL THEN
    K_DESCERROR := 'Ingrese el usuario procesar.';
    K_CODERROR  := 4;
    RAISE EX_ERROR;
  END IF;

  /** cod.servicio NO EXISTE **/
  UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
     SET ADMPV_MSJE_ERROR = 'El codigo de servicio es un dato obligatorio.',
         ADMPC_COD_ERROR = '105'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPC_COD_ERROR='-1')
     AND (ADMPV_TIPO_SERV IS NULL OR ADMPV_TIPO_SERV = '');
          
  /** Nro de Cuenta NO EXISTE **/
  UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
     SET ADMPV_MSJE_ERROR = 'La cuenta es un dato obligatorio.',
         ADMPC_COD_ERROR = '106'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
     AND (ADMPC_COD_ERROR='-1')
     AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '');
     
  /** Servicio NO EXISTE **/
   UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT TP
     SET ADMPV_MSJE_ERROR = 'El servicio no existe, no se le puede asignar puntos.',
         ADMPC_COD_ERROR = '107'
   WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
     AND (ADMPC_COD_ERROR='-1')
     AND NOT EXISTS 
     (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P
      WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV);


  /** CLIENTE NO EXISTE **/
  UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT TP
    SET ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede asignar puntos.',
         ADMPC_COD_ERROR = '108'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPC_COD_ERROR='-1')
    AND NOT EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI);

  /*** CLIENTE NO ES HFC ***/
  UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT TP
    SET ADMPV_MSJE_ERROR = 'El cliente no es HFC.',
         ADMPC_COD_ERROR = '109'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPC_COD_ERROR='-1')
    AND EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
    AND TP.ADMPV_TIP_CLIENTE <> '7';
             

  /** SERVICIO NO ESTA ACTIVO **/
   UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT TP
    SET ADMPV_MSJE_ERROR = 'El servicio esta se encuentra en baja, no se le puede asignar puntos.',
         ADMPC_COD_ERROR = '201'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPC_COD_ERROR='-1')
    AND EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI AND P.ADMPV_ESTADO_SERV = 'B');
    

  /** CLIENTE NO ESTA ACTIVO **/
   UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT TP
    SET ADMPV_MSJE_ERROR = 'El cliente no esta activo.',
         ADMPC_COD_ERROR = '202'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPC_COD_ERROR='-1')
    AND EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI AND C.ADMPC_ESTADO = 'B');

  /** MONTOS INFERIORES A 0 **/
  UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT TP
    SET ADMPV_MSJE_ERROR = 'El monto es menor o igual a cero',
         ADMPC_COD_ERROR = '203'
  WHERE ADMPD_FEC_OPER = K_FEC_PROCESO 
    AND (ADMPC_COD_ERROR='-1')
    AND EXISTS 
    (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_CLIENTEFIJA C
    WHERE P.ADMPV_COD_CLI_PROD = TP.ADMPV_CUSTCODE||'_'||TP.ADMPV_TIPO_SERV
    AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
    AND TP.ADMPN_MNT_CGOFIJ <= 0;
     

  BEGIN
    SELECT ADMPV_COD_CPTO, ADMPC_PROC
      INTO V_CONCEP_PPAGO_N, V_IND_PROC_PPAGO_N
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'PRONTO PAGO NORMAL HFC'; -- Concepto - pronto pago normal --
    SELECT ADMPV_COD_CPTO, ADMPC_PROC
      INTO V_CONCEP_CFIJ, V_IND_PROC_CFIJ
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_DESC = 'CARGO FIJO NORMAL HFC'; -- Concepto - cargo fijo --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_DESCERROR := '"PRONTO PAGO NORMAL HFC" o "CARGO FIJO NORMAL HFC"';
      K_CODERROR  := 9;
      RAISE EX_ERROR;
  END;

  -- Obtenemos la cantidad de dias de pago anticipado para considerarlo como pronto pago
  BEGIN
    SELECT TO_NUMBER(ADMPV_VALOR)
      INTO V_NUMDIAS
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE UPPER(ADMPV_DESC) = 'DIAS_VENCIMIENTO_PAGO_CC';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_DESCERROR := 'Parametro = "DIAS_VENCIMIENTO_PAGO_CC".';
      K_CODERROR  := 14;
      RAISE EX_ERROR;
  END;
  
  OPEN CUR_PAGOS;
  FETCH CUR_PAGOS INTO vRECPAGFAC;
   
    WHILE CUR_PAGOS%FOUND LOOP
    
    BEGIN
      V_PUNTOS_PPAGO_NORMAL := 0;
      V_PUNTOS_CFIJ         := 0;
      V_TOTAL_PUNTOS        := 0;
      
      /*** Se genera el codigo para utilizar en todo el proceso **/
      V_CODCLIPROD:= vRECPAGFAC.ADMPV_CUSTCODE||'_'||vRECPAGFAC.ADMPV_TIPO_SERV;

      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM PCLUB.ADMPT_AUX_PAGO_RPT
       WHERE ADMPV_COD_CLI_PROD = V_CODCLIPROD
         AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO
         AND ADMPD_FEC_OPER = K_FEC_PROCESO
         AND ADMPV_NOM_ARCH = vRECPAGFAC.ADMPV_NOM_ARCH;
    
      IF V_CONTADOR = 0 THEN
         
        V_COD_CLI_IB := NULL;

        -- Busca la categoria del cliente
        SELECT F.ADMPN_COD_CATCLI, F.ADMPV_COD_TPOCL
          INTO V_COD_CATCLI, V_TIPO_CLI
          FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
         WHERE P.ADMPV_COD_CLI_PROD = V_CODCLIPROD
           AND P.ADMPV_COD_CLI = F.ADMPV_COD_CLI;

        IF V_COD_CATCLI IS NULL THEN
          V_COD_CATCLI := 2; -- Cliente Normal
        END IF;

        -- Costo de Puntos x categoria A?ADIR EN LA TABLA CAT_CLIENTE EL NUEVO CLIENTE HFC --
        SELECT ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ
          INTO V_CTO_PPAGO, V_CTO_CFIJ
          FROM PCLUB.ADMPT_CAT_CLIENTE
         WHERE ADMPN_COD_CATCLI = V_COD_CATCLI
           AND ADMPV_COD_TPOCL = V_TIPO_CLI;          
       
        /*** Calculo de puntos para Pronto Pago Normal, Pronto Pago Adicional ***/
        
        -- Pronto Pago normal  --
        --Verifico la configuracion para otorgar puntos por Cargo Fijo
        IF V_IND_PROC_PPAGO_N IS NOT NULL AND V_IND_PROC_PPAGO_N = '1' THEN
      
          IF vRECPAGFAC.ADMPN_DIAS_VENC >= V_NUMDIAS THEN          
            --V_PUNTOS_PPAGO_NORMAL := TRUNC((V_MNT_CGOFIJ) / V_CTO_PPAGO, 0);
         
            V_PUNTOS_PPAGO_NORMAL := TRUNC((vRECPAGFAC.ADMPN_MNT_CGOFIJ) / V_CTO_PPAGO, 0);           
            IF V_PUNTOS_PPAGO_NORMAL <> 0 THEN
              IF V_PUNTOS_PPAGO_NORMAL > 0 THEN
                V_TIPO_PUNTO           := 'E';
                V_PUNTOS_PPAGO_NORMALS := V_PUNTOS_PPAGO_NORMAL;
              
                INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                  (ADMPN_ID_KARDEX,
                   ADMPN_COD_CLI_IB,
                   ADMPV_COD_CLI_PROD,
                   ADMPV_COD_CPTO,
                   ADMPD_FEC_TRANS,
                   ADMPN_PUNTOS,
                   ADMPV_NOM_ARCH,
                   ADMPC_TPO_OPER,
                   ADMPC_TPO_PUNTO,
                   ADMPN_SLD_PUNTO,
                   ADMPC_ESTADO,
                   ADMPD_FEC_REG,
                   ADMPV_USU_REG)
                VALUES
                  (PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                   V_COD_CLI_IB,
                   V_CODCLIPROD,
                   V_CONCEP_PPAGO_N,
                   SYSDATE,
                   V_PUNTOS_PPAGO_NORMAL,
                   vRECPAGFAC.ADMPV_NOM_ARCH,
                   V_TIPO_PUNTO,
                   'C',
                   V_PUNTOS_PPAGO_NORMALS,
                   'A',
                   SYSDATE,
                   K_USUARIO);
              ELSE
                V_PUNTOS_PPAGO_NORMALS := 0;
                V_PUNTOS_PPAGO_NORMAL  := 0;
              END IF;
            END IF;
          ELSE
            UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
               SET ADMPC_COD_ERROR  = '101',
                   ADMPV_MSJE_ERROR = 'El numero de dias de vencimiento sobrepasa el limite.'
             WHERE ADMPV_CUSTCODE  = vRECPAGFAC.ADMPV_CUSTCODE
               AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
               AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO
               AND ADMPN_SEQ = vRECPAGFAC.ADMPN_SEQ;
          END IF;
        END IF;


        --Cargo Fijo--
        --Validamos que la configuracion para otorgar puntos por Cargo Fijo se encuentre habilitada
        IF V_IND_PROC_CFIJ IS NOT NULL AND V_IND_PROC_CFIJ = '1' THEN
          -- Calculo de puntos para Cargo Fijo
          V_PUNTOS_CFIJ := TRUNC((vRECPAGFAC.ADMPN_MNT_CGOFIJ) / V_CTO_CFIJ, 0);
      
          IF V_PUNTOS_CFIJ <> 0 THEN
            IF V_PUNTOS_CFIJ > 0 THEN
              V_TIPO_PUNTO   := 'E';
              V_PUNTOS_CFIJS := V_PUNTOS_CFIJ;

              INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                (ADMPN_ID_KARDEX,
                 ADMPN_COD_CLI_IB,
                 ADMPV_COD_CLI_PROD,
                 ADMPV_COD_CPTO,
                 ADMPD_FEC_TRANS,
                 ADMPN_PUNTOS,
                 ADMPV_NOM_ARCH,
                 ADMPC_TPO_OPER,
                 ADMPC_TPO_PUNTO,
                 ADMPN_SLD_PUNTO,
                 ADMPC_ESTADO,
                 ADMPD_FEC_REG,
                 ADMPV_USU_REG)
              VALUES
                (PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                 V_COD_CLI_IB,
                 V_CODCLIPROD,
                 V_CONCEP_CFIJ,
                 SYSDATE,
                 V_PUNTOS_CFIJ,
                 vRECPAGFAC.ADMPV_NOM_ARCH,
                 V_TIPO_PUNTO,
                 'C',
                 V_PUNTOS_CFIJS,
                 'A',
                 SYSDATE,
                 K_USUARIO);

            ELSE
              V_PUNTOS_CFIJS := 0;
              V_PUNTOS_CFIJ  := 0;
            END IF;
          END IF;
     
        END IF;

        --Actualiza Tabla de Saldos con el total de puntos acumulados --
        V_TOTAL_PUNTOS := NVL(V_PUNTOS_PPAGO_NORMAL, 0) +
                          NVL(V_PUNTOS_CFIJ, 0);

        UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
           SET ADMPN_SALDO_CC = ADMPN_SALDO_CC + V_TOTAL_PUNTOS,
               ADMPD_FEC_MOD  = SYSDATE,
               ADMPV_USU_MOD  = K_USUARIO
         WHERE ADMPV_COD_CLI_PROD = V_CODCLIPROD;

        --Actualiza el total de puntos (admpn_puntos) en ADMPT_tmp_pago_cc
        UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
           SET ADMPN_PUNTOS = V_TOTAL_PUNTOS
         WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
           AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
           AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO
           AND ADMPD_FEC_OPER = K_FEC_PROCESO;

        -- Insertamos en la tabla temporal por si es necesario el reproceso
        INSERT INTO PCLUB.ADMPT_AUX_PAGO_RPT
          (ADMPV_COD_CLI_PROD,
           ADMPV_PERIODO,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH)
        VALUES
          (V_CODCLIPROD,
           vRECPAGFAC.ADMPV_PERIODO, 
           K_FEC_PROCESO, 
           vRECPAGFAC.ADMPV_NOM_ARCH);
     
      
      ELSE
        UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
           SET ADMPC_COD_ERROR  = '102',
               ADMPV_MSJE_ERROR = 'El servicio ya fue procesado'
         WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
           AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
           AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO
           AND ADMPN_SEQ = vRECPAGFAC.ADMPN_SEQ;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        IF V_COD_CATCLI IS NULL THEN
          UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
             SET ADMPV_MSJE_ERROR = 'El cliente no se encuentra categorizado',
                 ADMPC_COD_ERROR  = '110'
           WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
             AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
             AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO
             AND ADMPD_FEC_OPER = K_FEC_PROCESO;

        END IF;

        IF V_CTO_PPAGO IS NULL OR V_CTO_CFIJ IS NULL THEN
          UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
             SET ADMPC_COD_ERROR  = '111',
                 ADMPV_MSJE_ERROR = 'No se pudo obtener el costo de puntos por categoria'
          WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
             AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
             AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO;

        END IF;

      WHEN OTHERS THEN
        ORA_ERROR := SUBSTR(SQLERRM, 1, 250);
        UPDATE PCLUB.ADMPT_TMP_PAGOFACT_RPT
           SET ADMPC_COD_ERROR = 'ORA', ADMPV_MSJE_ERROR = ORA_ERROR
         WHERE ADMPV_CUSTCODE = vRECPAGFAC.ADMPV_CUSTCODE
           AND ADMPV_TIPO_SERV = vRECPAGFAC.ADMPV_TIPO_SERV
           AND ADMPV_PERIODO = vRECPAGFAC.ADMPV_PERIODO;

    END;

    FETCH CUR_PAGOS INTO vRECPAGFAC;
     
    END LOOP;


  -- Exportar datos a la tabla ADMPT_imp_pago_cc
    INSERT INTO PCLUB.ADMPT_IMP_PAGOFACT_RPT(
        ADMPV_TIP_CLIENTE,
        ADMPV_CUSTCODE,
        ADMPV_TIPO_SERV,
        ADMPV_PERIODO_ANIO,
        ADMPV_PERIODO_MES,
        ADMPN_DIAS_VENC,
        ADMPN_MNT_CGOFIJ,
        ADMPD_FEC_OPER,
        ADMPV_NOM_ARCH,
        ADMPV_PERIODO,
        ADMPN_PUNTOS,
        ADMPC_COD_ERROR,
        ADMPV_MSJE_ERROR,
        ADMPN_SEQ
    )
    SELECT 
           ADMPV_TIP_CLIENTE,           
           ADMPV_CUSTCODE,
           ADMPV_TIPO_SERV,
           ADMPV_PERIODO_ANIO,
           ADMPV_PERIODO_MES,
           ADMPN_DIAS_VENC,           
           ADMPN_MNT_CGOFIJ,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH,
           ADMPV_PERIODO,
           ADMPN_PUNTOS,
           ADMPC_COD_ERROR,
           ADMPV_MSJE_ERROR,          
           ADMPT_PAGORPT_SQ.NEXTVAL
      FROM PCLUB.ADMPT_TMP_PAGOFACT_RPT
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
  SELECT COUNT(1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_PAGOFACT_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;
  SELECT COUNT(1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_PAGOFACT_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPC_COD_ERROR<>'-1');
  SELECT COUNT(1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_TMP_PAGOFACT_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND (ADMPC_COD_ERROR='-1');

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_TMP_PAGOFACT_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;
  DELETE PCLUB.ADMPT_AUX_PAGO_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO;

  COMMIT;

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
  WHEN EX_ERROR THEN
    ROLLBACK;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_FACTURA_HFC;

PROCEDURE ADMPSI_ANIVERSARIO_HFC
(
  K_TIPCLIENTE IN VARCHAR2,
  K_FEC_PROCESO IN DATE,
  K_USUARIO IN VARCHAR2,
  K_CODERROR  OUT NUMBER,
  K_DESCERROR OUT VARCHAR2,
  K_NUMREGTOT OUT NUMBER,
  K_NUMREGPRO OUT NUMBER,
  K_NUMREGERR OUT NUMBER
) 
AS

  TYPE REC_PTOANIV IS RECORD(        
    ADMPV_TIP_CLIENTE	VARCHAR2(2),
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPD_FEC_OPER	DATE,
    ADMPV_NOM_ARCH	VARCHAR2(150),
    ADMPN_PUNTOS	NUMBER,
    ADMPC_COD_ERROR	CHAR(3),
    ADMPV_MSJE_ERROR	VARCHAR2(400),
    ADMPN_SEQ NUMBER
  );
  
  vRECPTOANIV REC_PTOANIV;
  
  TYPE REG_RODUCTO IS RECORD(        
    ADMPV_CUSTCODE	VARCHAR2(40),
    ADMPN_PUNTOS	NUMBER
  );
  
  vREGRODUCTO REG_RODUCTO;  
  
  V_CODCONCEPTOHFC VARCHAR2(2);
  V_PUNTOSHFC NUMBER;
  V_FLAG_REGANIVER VARCHAR2(3);
  V_CANSER NUMBER;
  V_PTOSDIS NUMBER;
  EX_ERROR EXCEPTION;
  V_CUSCOD VARCHAR2(40);
  V_PUNACT NUMBER;
  V_ACUPTO NUMBER;
  V_CONTAD NUMBER;
  V_FILCUS VARCHAR2(40);
  V_CANINS NUMBER;

  CURSOR CUR_PTOSANIV IS
    SELECT
          ADMPV_TIP_CLIENTE,
          ADMPV_CUSTCODE,
          ADMPD_FEC_OPER,
          ADMPV_NOM_ARCH,
          ADMPN_PUNTOS,
          ADMPC_COD_ERROR,
          ADMPV_MSJE_ERROR,
          ADMPN_SEQ
    FROM 
          PCLUB.ADMPT_TMP_ANIV_RPT
    WHERE 
          (ADMPC_COD_ERROR='-1')
          AND ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
  
  
   /****** Ini: ROLLBACK PRODUCTOS ******/
  CURSOR CUR_ROLLB_SALDOS IS
   SELECT 
         S.ADMPV_COD_CLI_PROD,
         S.ADMPN_SALDO_CC,
         S.ADMPC_ESTPTO_CC
   FROM 
         PCLUB.ADMPT_SALDOS_CLIENTEFIJA S 
   WHERE 
         SUBSTR(S.ADMPV_COD_CLI_PROD,0,22) = V_FILCUS         
         AND S.ADMPC_ESTPTO_CC = 'A';
               
               
  TYPE REC_ROLLB_PD IS RECORD(        
   ADMPV_COD_CLI_PROD	VARCHAR2(40),
   ADMPN_SALDO_CC	NUMBER,
   ADMPC_ESTPTO_CC VARCHAR2(1)
  );
          
  vRECROLLBPD REC_ROLLB_PD;  
  /****** Fin: ROLLBACK PRODUCTOS ******/
  
  
BEGIN

  K_DESCERROR := '';
  K_CODERROR  := 0;
  V_CANSER := 0;
  V_PTOSDIS :=0;
  V_FILCUS := '';

    IF K_TIPCLIENTE IS NULL THEN
      K_DESCERROR := 'Ingrese el tipo de cliente a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_FEC_PROCESO IS NULL THEN
      K_DESCERROR := 'Ingrese la fecha a procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;
    
    IF K_USUARIO IS NULL THEN
      K_DESCERROR := 'Ingrese el usuario procesar.';
      K_CODERROR  := 4;
      RAISE EX_ERROR;
    END IF;

  BEGIN
     
    SELECT NVL(ADMPV_VALOR,'0') INTO V_FLAG_REGANIVER
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE TRIM(UPPER(ADMPV_DESC)) LIKE '%PUNTOS_ANIVERSARIO_HFC%';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        K_DESCERROR:='PUNTOS_ANIVERSARIO_HFC.';
        K_CODERROR:=9;
        RAISE EX_ERROR;
  END;

    
    BEGIN

      SELECT ADMPV_COD_CPTO INTO V_CODCONCEPTOHFC
      FROM PCLUB.ADMPT_CONCEPTO
      WHERE TRIM(UPPER(ADMPV_DESC)) LIKE '%ANIVERSARIO HFC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          K_DESCERROR:='ANIVERSARIO HFC.';
          K_CODERROR:=9;
          RAISE EX_ERROR;
    END;
  
    BEGIN

        SELECT NVL(ADMPV_VALOR,'0') INTO V_PUNTOSHFC
        FROM PCLUB.ADMPT_PARAMSIST
        WHERE UPPER(ADMPV_DESC) LIKE '%PUNTOS_ANIVERSARIO_HFC%';

        UPDATE ADMPT_TMP_ANIV_RPT SET ADMPN_PUNTOS = V_PUNTOSHFC;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        K_DESCERROR:='PUNTOS_ANIVERSARIO_HFC.';
        K_CODERROR:=9;
        RAISE EX_ERROR;
    END;
    
    -- cod.servicio NO EXISTE --
    UPDATE PCLUB.ADMPT_TMP_ANIV_RPT A
       SET ADMPV_MSJE_ERROR = 'El tipo de cliente es un dato obligatorio.',
           ADMPC_COD_ERROR = '101'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (A.ADMPC_COD_ERROR='-1')
       AND (ADMPV_TIP_CLIENTE IS NULL OR ADMPV_TIP_CLIENTE = '');
            
    -- Nro de Cuenta NO EXISTE --
    UPDATE PCLUB.ADMPT_TMP_ANIV_RPT A
       SET ADMPV_MSJE_ERROR = 'La cuenta es un dato obligatorio.',
           ADMPC_COD_ERROR = '102'
     WHERE ADMPD_FEC_OPER = K_FEC_PROCESO
       AND (A.ADMPC_COD_ERROR='-1')
       AND (ADMPV_CUSTCODE IS NULL OR ADMPV_CUSTCODE = '')
       AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
    -- No cuenta con servicios --
    UPDATE PCLUB.ADMPT_TMP_ANIV_RPT A
      SET ADMPV_MSJE_ERROR = 'La cuenta no tiene servicios.',
          ADMPC_COD_ERROR = '103'
    WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO
      AND NOT EXISTS 
      (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P 
      WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,22) = A.ADMPV_CUSTCODE)
      AND (A.ADMPC_COD_ERROR='-1')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
    -- Cliente en estado de BAJA --
    UPDATE PCLUB.ADMPT_TMP_ANIV_RPT A
      SET ADMPV_MSJE_ERROR = 'El cliente se encuentra en baja.',
          ADMPC_COD_ERROR = '104'
    WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO
      AND EXISTS 
      (SELECT 1 FROM PCLUB.ADMPT_CLIENTEPRODUCTO P, PCLUB.ADMPT_CLIENTEFIJA C
      WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,22) = A.ADMPV_CUSTCODE 
      AND P.ADMPV_COD_CLI = C.ADMPV_COD_CLI AND C.ADMPC_ESTADO = 'B')
      AND (A.ADMPC_COD_ERROR='-1')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
    -- PUNTOS asignados igual o menor que CERO --
    UPDATE PCLUB.ADMPT_TMP_ANIV_RPT A
      SET ADMPV_MSJE_ERROR = 'La cantidad de puntos es cero o menor que cero.',
          ADMPC_COD_ERROR = '105'
    WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO
      AND A.ADMPN_PUNTOS <= 0
      AND (A.ADMPC_COD_ERROR='-1')
      AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
        
    /***** Recorremos el Cursor *****/
    OPEN CUR_PTOSANIV;
    FETCH CUR_PTOSANIV INTO vRECPTOANIV;
           
      WHILE CUR_PTOSANIV%FOUND LOOP
              
      BEGIN

            V_FILCUS := vRECPTOANIV.ADMPV_CUSTCODE;

            OPEN CUR_ROLLB_SALDOS;
            V_CONTAD := 1;
            V_ACUPTO := 0;

            /**** Se valida servicios en baja ****/
            SELECT COUNT(1) INTO V_CANSER FROM PCLUB.ADMPT_CLIENTEPRODUCTO P 
            WHERE SUBSTR(P.ADMPV_COD_CLI_PROD,0,22) = vRECPTOANIV.ADMPV_CUSTCODE 
                  AND P.ADMPV_ESTADO_SERV = 'A';
         
            IF V_CANSER > 0 THEN
                V_CANINS := 0;           
                BEGIN
                                                  
                   SELECT FLOOR(vRECPTOANIV.ADMPN_PUNTOS/V_CANSER) INTO V_PTOSDIS FROM DUAL;              
                                   
                EXCEPTION
                    WHEN OTHERS THEN
                      K_DESCERROR := 'Hubo inconvenientes al calcular los puntos.';
                      K_CODERROR:=1;
                END;
                              
               DECLARE CURSOR CUR_PTOSXPROD IS
                   SELECT
                          ADMPV_COD_CLI_PROD,                         
                          ADMPN_SALDO_CC
                   FROM 
                          PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                   WHERE 
                          SUBSTR(S.ADMPV_COD_CLI_PROD,0,22) = vRECPTOANIV.ADMPV_CUSTCODE;
              
                BEGIN

                    OPEN CUR_PTOSXPROD;
                    FETCH CUR_PTOSXPROD INTO vREGRODUCTO;   
                      WHILE CUR_PTOSXPROD%FOUND LOOP                          
                          
                          BEGIN

                              V_CUSCOD := vREGRODUCTO.ADMPV_CUSTCODE;
                              V_PUNACT := vREGRODUCTO.ADMPN_PUNTOS;
                              
                              IF V_CONTAD = 3 THEN
                                V_PTOSDIS := vRECPTOANIV.ADMPN_PUNTOS - V_ACUPTO;
                              END IF;
                              
                              /******** Ini: Suma el saldo ********/
                              UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                              SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_PTOSDIS
                              WHERE ADMPV_COD_CLI_PROD = vREGRODUCTO.ADMPV_CUSTCODE;
                              /******** Ini: Suma el saldo ********/
                  
                              /******** Ini: Insertamos en KARDEX ********/ 
                              INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                              (
                                  ADMPN_ID_KARDEX,
                                  ADMPN_COD_CLI_IB,
                                  ADMPV_COD_CLI_PROD,
                                  ADMPV_COD_CPTO,
                                  ADMPD_FEC_TRANS,
                                  ADMPN_PUNTOS,
                                  ADMPV_NOM_ARCH,
                                  ADMPC_TPO_OPER,
                                  ADMPC_TPO_PUNTO,
                                  ADMPN_SLD_PUNTO,
                                  ADMPC_ESTADO,
                                  ADMPD_FEC_REG,
                                  ADMPV_USU_REG
                              )
                              VALUES
                              (      
                                  ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                                  NULL,
                                  vREGRODUCTO.ADMPV_CUSTCODE,
                                  V_CODCONCEPTOHFC,
                                  SYSDATE,
                                  V_PTOSDIS,
                                  vRECPTOANIV.ADMPV_NOM_ARCH,
                                  'E',
                                  'C',
                                  V_PTOSDIS,
                                  'A',
                                  SYSDATE,
                                  K_USUARIO
                              );
                              /******** Fin: Insertamos en KARDEX ********/
                              
                              V_ACUPTO := V_ACUPTO + V_PTOSDIS;
                              V_CONTAD := V_CONTAD + 1;
                              V_CANINS := V_CANINS + 1;
                              
                          EXCEPTION
                              WHEN OTHERS THEN
                                               
                                  UPDATE PCLUB.ADMPT_TMP_ANIV_RPT A
                                  SET A.ADMPV_MSJE_ERROR = 'Hubo inconvenientes al insertar en KARDEX o actualizar SALDO.', 
                                      A.ADMPC_COD_ERROR = '101'
                                  WHERE A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE
                                  AND A.ADMPV_CUSTCODE = vRECPTOANIV.ADMPV_CUSTCODE
                                  AND A.ADMPD_FEC_OPER = K_FEC_PROCESO;
                              
                          END;
                     
                    FETCH CUR_PTOSXPROD INTO vREGRODUCTO;
                    END LOOP;

                END;
            
                    IF V_CANSER <> V_CANINS THEN

                      FETCH CUR_ROLLB_SALDOS INTO vRECROLLBPD;                               
                        WHILE CUR_ROLLB_SALDOS%FOUND LOOP                                
                          BEGIN
                                  
                            UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                            SET S.ADMPN_SALDO_CC = vRECROLLBPD.ADMPN_SALDO_CC
                            WHERE S.ADMPV_COD_CLI_PROD = vRECROLLBPD.ADMPV_COD_CLI_PROD;                              
                                                      
                            DELETE FROM PCLUB.ADMPT_KARDEXFIJA K
                            WHERE K.ADMPV_COD_CLI_PROD = vRECROLLBPD.ADMPV_COD_CLI_PROD
                            AND K.ADMPV_NOM_ARCH = vRECPTOANIV.ADMPV_NOM_ARCH
                            AND K.ADMPV_USU_REG = K_USUARIO;                                  
                                  
                          END;
                        FETCH CUR_ROLLB_SALDOS INTO vRECROLLBPD;                                 
                        END LOOP;
                                                          
                    END IF;
            
            END IF;
            CLOSE CUR_ROLLB_SALDOS;                  
    
      END;

      FETCH CUR_PTOSANIV INTO vRECPTOANIV;     
      END LOOP;
    
    
      --- Obtenemos los registros totales, procesados y con error ---
      SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ANIV_RPT 
      WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
      
      SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ANIV_RPT A
      WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
      AND ADMPD_FEC_OPER = K_FEC_PROCESO 
      AND (A.ADMPC_COD_ERROR='-1');
      
      SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_TMP_ANIV_RPT A
      WHERE ADMPV_TIP_CLIENTE = K_TIPCLIENTE 
      AND ADMPD_FEC_OPER = K_FEC_PROCESO 
      AND (A.ADMPC_COD_ERROR<>'-1');    
    
      --- Insertamos de la tabla temporal a la final ---
      INSERT INTO PCLUB.ADMPT_IMP_ANIV_RPT
      (
        ADMPV_TIP_CLIENTE,
        ADMPV_CUSTCODE,
        ADMPD_FEC_OPER,
        ADMPV_NOM_ARCH,
        ADMPN_PUNTOS,
        ADMPC_COD_ERROR,
        ADMPV_MSJE_ERROR,
        ADMPN_SEQ
      )
      SELECT ADMPV_TIP_CLIENTE,
      ADMPV_CUSTCODE,
      ADMPD_FEC_OPER,
      ADMPV_NOM_ARCH,
      ADMPN_PUNTOS,
      ADMPC_COD_ERROR,
      ADMPV_MSJE_ERROR,
      ADMPT_IMP_ANIVRT_SQ.NEXTVAL
      FROM PCLUB.ADMPT_TMP_ANIV_RPT A
      WHERE A.ADMPD_FEC_OPER = K_FEC_PROCESO AND A.ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
    
      -- Eliminamos los registros de la tabla temporal y auxiliar --
      DELETE FROM PCLUB.ADMPT_TMP_ANIV_RPT WHERE ADMPD_FEC_OPER = K_FEC_PROCESO AND ADMPV_TIP_CLIENTE = K_TIPCLIENTE;
     
  COMMIT;

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
  WHEN EX_ERROR THEN
    ROLLBACK;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;
  WHEN OTHERS THEN
    ROLLBACK;
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ANIVERSARIO_HFC;

END PKG_CC_PTOSFIJA;
/