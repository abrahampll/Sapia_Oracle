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
              INNER JOIN 	.ADMPT_TIPOSERV_DTH_HFC D ON (B.ADMPV_COD_TPOCL=D.ADMPV_COD_TPOCL AND  D.ADMPV_SERVICIO=A.ADMPV_SERVICIO)
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