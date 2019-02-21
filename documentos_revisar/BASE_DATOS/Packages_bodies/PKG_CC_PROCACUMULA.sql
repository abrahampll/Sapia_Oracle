create or replace package body pclub.PKG_CC_PROCACUMULA is

procedure ADMPSI_PAGO (K_FECHA IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_PAGO
-- Propósito           :  Asigna puntos por los diferentes tipos de pagos del cliente.
-- Input               :  K_FECHA
-- Output              :  K_CODERROR  Codigo de Error
--                        K_DESCERROR Descripcion del Error
--                        K_NUMREGTOT Numero de Registros Totales
--                        K_NUMREGPRO Numero de Registros Procesados
--                        K_NUMREGERR Numero de Registros con Error
-- Fec Creación        :  25/09/2010
-- Fec Actualización   :hoy
--****************************************************************
/*
Se debe Validar:
- Que el codigo de cliente exista en la tabla cliente
- Todos los clientes deben estar categorizados
- Los campos signos deben solo tener '+' o '-', no deberia estar vacio
*/

V_COD_CLI               VARCHAR2(40);
V_PERIODO               VARCHAR2(6);
V_DIAS_VENC             NUMBER;
V_MNT_CGOFIJ            NUMBER;
V_MNT_ADIC              NUMBER;
V_MNT_INT               NUMBER;
V_ACGOFIJ               NUMBER;
V_MNT_ADEB              NUMBER;
V_SGACGOFIJ             CHAR(1);
V_AJUADIC               NUMBER;
V_SGAJUADI              CHAR(1);
V_ADEBITO               NUMBER;--AF.DEB
V_NUMDIAS               NUMBER;
V_TIPO_CLI              VARCHAR2 (2);
V_TIPO_PUNTO            CHAR(1);
V_PUNTOS_PPAGO_NORMALS  NUMBER;
V_PUNTOS_CADIS         NUMBER;
V_PUNTOS_PPAGO_ADICIONALS NUMBER;
V_PUNTOS_CFIJS            NUMBER;
V_PUNTOS_CALLINS          NUMBER;
V_PUNTOS_ADEBS            NUMBER;--AF.ADEB


-- Codigos de conceptos por pagos
V_CONCEP_PPAGO_N          NUMBER;
V_CONCEP_PPAGO_A          NUMBER;
V_CONCEP_CFIJ             NUMBER;
V_CONCEP_CADI             NUMBER;
V_CONCEP_LLIN             NUMBER; --LLAMADA INTERNACIONAL.
V_CONCEP_ADEB             NUMBER;--AF.DEB

-- Costo por punto
V_CTO_PPAGO         NUMBER;
V_CTO_CFIJ          NUMBER;
V_CTO_CADI          NUMBER;
V_LLM_INT           NUMBER;--LLAMADA INTERNACIONAL. --Se entyregara 1 punto por cada sol.
V_CTO_ADEB          NUMBER;--AF.DEB


-- Puntos x concepto
V_PUNTOS_PPAGO_ADICIONAL   NUMBER;
V_PUNTOS_PPAGO_NORMAL      NUMBER;
V_PUNTOS_CFIJ              NUMBER;
V_PUNTOS_CADI              NUMBER;
V_PUNTOS_CALLIN            NUMBER;---LLAMADAS INTERNACIONALES
V_PUNTOS_ADEB             NUMBER;--AF.DEB


V_COD_CATCLI               NUMBER;
V_COD_CLI_IB               VARCHAR2(40);
V_TOTAL_PUNTOS             NUMBER;
ORA_ERROR                  VARCHAR2(205);
V_CONTADOR                 NUMBER;
V_NOM_ARCH                 VARCHAR2(150);
NRO_ERROR                  NUMBER;
C_EXISTESMSCF              NUMBER;

ERROR_VALIDAR              EXCEPTION;

/***********************************************/
V_IND_PROC_PPAGO NUMBER;
V_IND_PROC_PCFIJ NUMBER;
V_PUNTOS_CFIJ_UNIF NUMBER;
V_PUNTOS_PPAGO_UNIF NUMBER;
/***********************************************/

/* INICIO PROY-18369 */
V_FLAG_ESTADO NUMBER;
/* FIN PROY-18369 */


CURSOR CUR_PAGOS IS
    SELECT admpv_cod_cli, admpv_periodo, admpn_dias_venc, admpn_mnt_cgofij, admpn_mnt_adic, admpn_acgofij, admpc_sgacgofij, admpn_ajuadic, admpc_sgajuadi, admpn_mnt_int, admpv_nom_arch,admpv_adebito,admpv_puntos_adeb/*AF.DEB*/
    FROM PCLUB.admpt_tmp_pago_cc
    WHERE (admpv_msje_error IS NULL OR admpv_msje_error = ' ' ) AND admpd_fec_oper=K_FECHA;

BEGIN

K_DESCERROR:='';
K_CODERROR := 0;
NRO_ERROR := 0;

  -- Valida Archivo
  -- Valida que el codigo de cliente exista en la tabla Cliente
  /*UPDATE admpt_tmp_pago_cc
     SET admpc_cod_error = 16,
         admpv_msje_error = 'El cliente no existe, no se le puede entregar puntos'
   WHERE admpv_cod_cli NOT IN (SELECT admpv_cod_cli FROM admpt_cliente ) AND
         admpd_fec_oper=K_FECHA;*/

   UPDATE PCLUB.admpt_tmp_pago_cc tm
     SET admpc_cod_error = 16,
         admpv_msje_error = 'El cliente no existe, no se le puede entregar puntos'
   WHERE  NOT EXISTS (SELECT 1 FROM PCLUB.admpt_cliente c where c.admpv_cod_cli=tm.admpv_cod_cli ) AND
         admpd_fec_oper=K_FECHA;

   COMMIT;

  -- Verifica que el campo signo debe tener '+' o '-' */
  UPDATE PCLUB.admpt_tmp_pago_cc
     SET admpc_cod_error = 55,
         admpv_msje_error = 'Es necesario el signo (+ o -) para realizar la entrega de puntos.'
   WHERE ( admpc_sgacgofij NOT IN ('+','-') OR
         admpc_sgajuadi NOT IN ('+','-') OR
         admpc_sgacgofij IS NULL ) AND
         admpd_fec_oper=K_FECHA;

   COMMIT;

   -- Obtenemos la cantidad de dias de pago anticipado para considerarlo como pronto pago
    SELECT TO_NUMBER(ADMPV_VALOR)
      INTO V_NUMDIAS
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE UPPER(ADMPV_DESC) = 'DIAS_VENCIMIENTO_PAGO_CC';

  IF NRO_ERROR =0 THEN

      OPEN CUR_PAGOS;
     FETCH CUR_PAGOS INTO V_COD_CLI, V_PERIODO, V_DIAS_VENC, V_MNT_CGOFIJ, V_MNT_ADIC, V_ACGOFIJ, V_SGACGOFIJ, V_AJUADIC, V_SGAJUADI, V_MNT_INT,  V_NOM_ARCH ,V_ADEBITO,V_MNT_ADEB;--AF.DEB

     WHILE CUR_PAGOS%FOUND
       LOOP
          BEGIN
             V_PUNTOS_PPAGO_NORMAL    := 0;
             V_PUNTOS_PPAGO_ADICIONAL := 0;
             V_PUNTOS_CFIJ            := 0;
             V_PUNTOS_CADI            := 0;
             V_PUNTOS_CALLIN          := 0;
             V_TOTAL_PUNTOS           := 0;
		 V_PUNTOS_ADEB            := 0;

             SELECT COUNT(1) INTO V_CONTADOR
             from PCLUB.admpt_aux_pago_cc
             where admpv_cod_cli=V_COD_CLI
             and admpv_periodo=V_PERIODO
             and admpd_fec_oper=K_FECHA
             and admpv_nom_arch=V_NOM_ARCH;

             if V_CONTADOR=0 then
                -- Buscar el Codigo de Cliente IB
                BEGIN
                  SELECT admpn_cod_cli_ib INTO V_COD_CLI_IB
                    FROM PCLUB.admpt_clienteib
                   WHERE admpv_cod_cli=V_COD_CLI and admpc_estado='A';

                  EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_COD_CLI_IB:=null;
                END;

                -- Busca el tipo de cliente
                SELECT admpv_cod_tpocl
                  INTO V_TIPO_CLI
                  FROM  PCLUB.admpt_cliente
                 WHERE admpv_cod_cli = V_COD_CLI;

                /* Concepto - pronto pago normal */
                SELECT admpv_cod_cpto, ADMPC_PROC
                  INTO V_CONCEP_PPAGO_N, V_IND_PROC_PPAGO
                  from PCLUB.ADMPT_CONCEPTO
                 where admpv_desc = 'PRONTO PAGO NORMAL';
                /* Concepto - cargo fijo */
                SELECT admpv_cod_cpto, ADMPC_PROC
                  INTO V_CONCEP_CFIJ, V_IND_PROC_PCFIJ
                  from PCLUB.ADMPT_CONCEPTO
                 where admpv_desc = 'CARGO FIJO';
                /*Concepto - Afiliación Débito*/
                SELECT admpv_cod_cpto
                  INTO V_CONCEP_ADEB
                  from PCLUB.ADMPT_CONCEPTO
                 where admpv_desc = 'AFILIACION DEBITO';

                /* Costo de Puntos x categoría*/
                SELECT admpn_cxpt_ppag,
                       admpn_cxpt_cfij,
                       admpn_cxpt_cadi,
                       admpn_cxpt_adeb
                  INTO V_CTO_PPAGO, V_CTO_CFIJ, V_CTO_CADI, V_CTO_ADEB
                  FROM PCLUB.ADMPT_CAT_CLIENTE
                 WHERE admpn_cod_catcli = 2
                   AND admpv_cod_tpocl = V_TIPO_CLI;

                if V_SGACGOFIJ = '-' then
                  V_ACGOFIJ := V_ACGOFIJ*(-1);
                end if;

                if V_SGAJUADI = '-' then
                  V_AJUADIC := V_AJUADIC*(-1);
                end if;

               --Cálculo de puntos por Afiliación a débito automático
                V_PUNTOS_ADEB   := trunc((V_MNT_ADEB / V_CTO_ADEB), 0); --AF.DEB

                --Inicio - Puntos por Pronto Pago
                /* Pronto Pago normal y Pronto Pago Adicional */
                --Verificamos si está configurado el Concepto de Pronto Pago, para poder otorgar puntos

                IF V_IND_PROC_PPAGO IS NOT NULL AND V_IND_PROC_PPAGO = '1' THEN

                if V_DIAS_VENC >= V_NUMDIAS then
                  V_PUNTOS_PPAGO_NORMAL    := trunc((V_MNT_CGOFIJ + V_ACGOFIJ) /
                                                    V_CTO_PPAGO,
                                                    0);
                  V_PUNTOS_PPAGO_ADICIONAL := trunc((V_MNT_ADIC + V_AJUADIC) /
                                                    V_CTO_PPAGO,
                                                    0);

                    V_PUNTOS_PPAGO_UNIF := V_PUNTOS_PPAGO_NORMAL + V_PUNTOS_PPAGO_ADICIONAL;

                    IF V_PUNTOS_PPAGO_UNIF <> 0 THEN
                      IF V_PUNTOS_PPAGO_UNIF > 0 THEN
                      V_TIPO_PUNTO           := 'E';

                      insert into PCLUB.admpt_kardex
                        (admpn_id_kardex,
                         admpn_cod_cli_ib,
                         admpv_cod_cli,
                         admpv_cod_cpto,
                         admpd_fec_trans,
                         admpn_puntos,
                         admpv_nom_arch,
                         admpc_tpo_oper,
                         admpc_tpo_punto,
                         admpn_sld_punto,
                         admpc_estado)
                      values
                        (admpt_kardex_sq.nextval,
                         V_COD_CLI_IB,
                         V_COD_CLI,
                         V_CONCEP_PPAGO_N,
                         TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),
                           V_PUNTOS_PPAGO_UNIF,
                         V_NOM_ARCH,
                         V_TIPO_PUNTO,
                         'C',
                           V_PUNTOS_PPAGO_UNIF,
                         'A');
                    ELSE
                        V_PUNTOS_PPAGO_UNIF  := 0;
                    END IF;
                    ELSE
                      V_PUNTOS_PPAGO_UNIF  := 0;
                  END IF;

                end if;
                ELSE
                  V_PUNTOS_PPAGO_UNIF :=0;
                END IF;

                --Fin - Puntos por Pronto Pago
                --------------------------------------

                /********Inicio - Puntos por Cargo Fijo
                --Se unfica los conceptos de Cargo Fijo, Cargo Adicional y Cargo por Llamadas Internacionales en
                --un solo concepto: Cargo Fijo */

                /*Valor parametrizable de llamada costo : 1 punto (por cada sol)*/
                V_LLM_INT := 1;

                --V_PUNTOS_CFIJ_UNIF := TRUNC(((V_PUNTOS_CFIJ + V_PUNTOS_CADI + V_PUNTOS_CALLIN)/V_CTO_CFIJ),0);
                V_PUNTOS_CFIJ_UNIF :=  TRUNC((((V_MNT_CGOFIJ + V_ACGOFIJ)+ (V_MNT_ADIC + V_AJUADIC) + (V_MNT_INT * V_LLM_INT) )/V_CTO_CFIJ),0);

                /* Pago Normal */
                IF V_PUNTOS_CFIJ_UNIF <> 0 THEN
                  IF V_PUNTOS_CFIJ_UNIF > 0 THEN
                    V_TIPO_PUNTO   := 'E';
                    insert into PCLUB.admpt_kardex
                      (admpn_id_kardex,
                       admpn_cod_cli_ib,
                       admpv_cod_cli,
                       admpv_cod_cpto,
                       admpd_fec_trans,
                       admpn_puntos,
                       admpv_nom_arch,
                       admpc_tpo_oper,
                       admpc_tpo_punto,
                       admpn_sld_punto,
                       admpc_estado)
                    values
                      (admpt_kardex_sq.nextval,
                       V_COD_CLI_IB,
                       V_COD_CLI,
                       V_CONCEP_CFIJ,
                       TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),
                       V_PUNTOS_CFIJ_UNIF,
                       V_NOM_ARCH,
                       V_TIPO_PUNTO,
                       'C',
                       V_PUNTOS_CFIJ_UNIF,
                       'A');

                    SELECT COUNT(1)
                      INTO C_EXISTESMSCF
                      FROM PCLUB.ADMPT_SMS_TELEFONOS T
                     WHERE T.ADMPV_COD_CLIENTE = V_COD_CLI
                       AND T.ADMPV_FECHA_REG >= TRUNC(SYSDATE)
                       AND T.ADMPV_NOMBRE_PROCESO = 'CARGO FIJO';

                    IF C_EXISTESMSCF = 0 THEN
                      BEGIN
                        INSERT INTO PCLUB.ADMPT_SMS_TELEFONOS
                          (ADMPV_TELEFONO,
                           ADMPC_ESTADO,
                           ADMPV_ESTADO_SMS,
                           ADMPV_NOMBRE_PROCESO,
                           ADMPV_USUARIO_REG,
                           ADMPV_FECHA_REG,
                           ADMPV_COD_CLIENTE)
                          select DISTINCT p.DN_NUM,
                                          'R',
                                          'PENDIENTE',
                                          'CARGO FIJO',
                                          'USRCCLUB',
                                          SYSDATE,
                                          c.custcode
                            from tim.pp_datos_contrato@DBL_BSCS p
                           INNER JOIN customer_all@DBL_BSCS c
                              on p.customer_id = c.customer_id
                           where c.custcode = V_COD_CLI;
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          NULL;
                        WHEN OTHERS THEN
                          NULL;
                      END;
                    END IF;
                  ELSE
                    V_PUNTOS_CFIJ_UNIF  := 0;
                  END IF;
                ELSE
                  V_PUNTOS_CFIJ_UNIF  := 0;
                END IF;

                /* Pago Adicional */


                /********Fin - Puntos por Cargo Fijo
                /****************************************************************

                 /* Afiliacion debito */
                 /*IF V_PUNTOS_ADEB <> 0 THEN*/
                  /* INICIO PROY-18369 */	
                  			 
                     V_FLAG_ESTADO:=0;            				 
                     SELECT COUNT(*)
                     INTO V_FLAG_ESTADO
                     FROM ADMPT_USR_DEBTAUT
                     WHERE ADMPV_COD_CLI = V_COD_CLI;
        				 
                    IF  V_ADEBITO = 1 AND V_FLAG_ESTADO = 0 AND V_PUNTOS_ADEB > 0 THEN 
                      
                  /* FIN PROY-18369 */	
                        V_TIPO_PUNTO := 'E';
                        V_PUNTOS_ADEBS:=V_PUNTOS_ADEB;
                        /*20120329*/
                        insert into admpt_kardex
                        (admpn_id_kardex, admpn_cod_cli_ib, admpv_cod_cli, admpv_cod_cpto, admpd_fec_trans, admpn_puntos, admpv_nom_arch, admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto, admpc_estado)
                        values
                        (admpt_kardex_sq.nextval, V_COD_CLI_IB, V_COD_CLI, V_CONCEP_ADEB, TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'), V_PUNTOS_ADEB, V_NOM_ARCH, V_TIPO_PUNTO, 'C', V_PUNTOS_ADEBS, 'A');
                        
                        /* INICIO PROY-18369 */
                        
                       insert into ADMPT_USR_DEBTAUT 
                        (USR_DEBTAUT_ID ,ADMPV_COD_CLI,USER_REG,FEC_REG)
                        values
                        (PCLUB.ADMPT_DEBTAUT_SQ.NEXTVAL ,V_COD_CLI,'USRCCLUB' ,sysdate);
                        
                        /* FIN PROY-18369 */
                        
                    ELSE
                        V_PUNTOS_ADEBS:=0;
                        V_PUNTOS_ADEB:=0;
                    END IF;
                 /*END IF;*/
                 /*AF. DEB*/

                /* Actualiza Tabla de Saldos con el total de puntos acumulados  */
                -- SSC 22122010 - Se agrega a validación por si son nulos, no asigne en nulo todo el saldo
                V_TOTAL_PUNTOS := NVL(V_PUNTOS_PPAGO_UNIF, 0) +
                              NVL(V_PUNTOS_CFIJ_UNIF, 0) +
                              NVL(V_PUNTOS_ADEB, 0); --AF.DEB--AGREGAR LLAMADA INTERNACIONAL

                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpn_saldo_cc = admpn_saldo_cc + V_TOTAL_PUNTOS
                 WHERE admpv_cod_cli = V_COD_CLI;

                /* Actualiza el total de puntos (admpn_puntos) en admpt_tmp_pago_cc */
                update PCLUB.admpt_tmp_pago_cc
                   set admpn_puntos = V_TOTAL_PUNTOS
                 where admpv_cod_cli=V_COD_CLI  and admpv_periodo=V_PERIODO  and admpd_fec_oper=K_FECHA and admpv_nom_arch = V_NOM_ARCH;

                -- Insertamos en la tabla temporal por si es necesario el reproceso
                INSERT INTO PCLUB.ADMPT_AUX_PAGO_CC
                  (admpv_cod_cli, admpv_periodo, admpd_fec_oper, admpv_nom_arch)
                VALUES
                  (V_COD_CLI, V_PERIODO, K_FECHA, V_NOM_ARCH);

                --COMMIT;
          END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                if V_COD_CATCLI is null then
                  update PCLUB.admpt_tmp_pago_cc
                    set
                         admpc_cod_error = '42',
                         admpv_msje_error = 'El cliente no se encuentra categorizado'
                    where admpv_cod_cli=V_COD_CLI and
                         admpv_periodo=V_PERIODO;
                 commit;
                end if;

                if V_CONCEP_PPAGO_N is null or V_CONCEP_PPAGO_A is null or V_CONCEP_CFIJ is null or V_CONCEP_CADI is null  or V_CONCEP_LLIN is null then
                  update PCLUB.admpt_tmp_pago_cc
                    set
                         admpc_cod_error = '30',
                         admpv_msje_error = 'No se encontró el concepto. Inserte el concepto en la tabla admpt_concepto'
                    where admpv_cod_cli=V_COD_CLI and
                         admpv_periodo=V_PERIODO;
                  commit;
                end if;
                if V_CTO_PPAGO is null or V_CTO_CFIJ is null or V_CTO_CADI is null or V_LLM_INT is null then
                  update PCLUB.admpt_tmp_pago_cc
                    set
                         admpc_cod_error = '43',
                         admpv_msje_error = 'No se pudo obtener el costo de puntos por categoría'
                    where admpv_cod_cli=V_COD_CLI and
                         admpv_periodo=V_PERIODO;
                  commit;
                end if;

              WHEN OTHERS THEN
                ORA_ERROR:=SUBSTR(SQLERRM,1,250);
                 update PCLUB.admpt_tmp_pago_cc
                    set
                        admpc_cod_error = 'ORA',
                        admpv_msje_error = ORA_ERROR
                    where
                        admpv_cod_cli=V_COD_CLI and
                        admpv_periodo=V_PERIODO;
                 commit;
          END;
          FETCH CUR_PAGOS INTO V_COD_CLI, V_PERIODO, V_DIAS_VENC, V_MNT_CGOFIJ, V_MNT_ADIC, V_ACGOFIJ, V_SGACGOFIJ, V_AJUADIC, V_SGAJUADI, V_MNT_INT, V_NOM_ARCH ,V_ADEBITO,V_MNT_ADEB;--AF.DEB
      END LOOP;

  -- Exportar datos a la tabla admpt_imp_pago_cc
    insert into PCLUB.admpt_imp_pago_cc
    select  admpt_pagocc_sq.Nextval , admpv_cod_cli, admpv_periodo , admpn_dias_venc, admpn_mnt_cgofij, admpn_mnt_adic, admpn_acgofij, admpc_sgacgofij,
    admpn_ajuadic, admpc_sgajuadi, ADMPN_MNT_INT, admpd_fec_oper, admpv_nom_arch, admpn_puntos, admpc_cod_error, admpv_msje_error, SYSDATE, ADMPN_SEQ,ADMPV_ADEBITO,ADMPV_PUNTOS_ADEB/*AD.DEB*/
    from PCLUB.admpt_tmp_pago_cc
    where admpd_fec_oper=K_FECHA;

  -- Generar Resultados (Total registros, Total procesados, Total de errores)
    SELECT COUNT (1) into k_numregtot from PCLUB.admpt_tmp_pago_cc WHERE ADMPD_FEC_OPER=K_FECHA;
    SELECT COUNT (1) into k_numregerr from PCLUB.admpt_tmp_pago_cc WHERE ADMPD_FEC_OPER=K_FECHA and (admpc_cod_error is not null);
    SELECT COUNT (1) into k_numregpro from PCLUB.admpt_aux_pago_cc WHERE ADMPD_FEC_OPER=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.admpt_aux_pago_cc WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.admpt_tmp_pago_cc  WHERE ADMPD_FEC_OPER=K_FECHA;

   COMMIT;

   ELSE
     RAISE ERROR_VALIDAR;
   END IF;


EXCEPTION
  WHEN ERROR_VALIDAR THEN
      K_CODERROR := -1;
      K_DESCERROR:='No se procesó el archivo porque encontró error en la validación: ORA-'||NRO_ERROR ;
  WHEN OTHERS THEN
      K_CODERROR:=SQLCODE;
      K_DESCERROR:= SUBSTR(SQLERRM,1,250);

end ADMPSI_PAGO;

PROCEDURE ADMPSS_EPAGO (K_FECHAPROC IN DATE, CURSORPAGO out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSS_EPAGO
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Pagos
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREGPTO
-- Fec Creación        :  07/10/2010
-- Fec Actualización   :
--****************************************************************

BEGIN

OPEN CURSORPAGO FOR
SELECT TRIM (ADMPV_COD_CLI),TRIM (ADMPV_PERIODO),ADMPN_DIAS_VENC,ADMPN_MNT_CGOFIJ,ADMPN_MNT_ADIC,ADMPN_ACGOFIJ,
       TRIM (ADMPC_SGACGOFIJ),ADMPN_AJUADIC,TRIM (ADMPC_SGAJUADI),ADMPN_MNT_INT,TRIM (ADMPC_COD_ERROR), ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_PAGO_CC
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       ADMPC_COD_ERROR Is Not Null AND
       TRIM (ADMPV_MSJE_ERROR) <> ' '
 ORDER BY ADMPN_SEQ ASC;

END ADMPSS_EPAGO;

PROCEDURE ADMPSI_ALTACONT (K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ALTACONT
-- Propósito           :  Importar los puntos por Alta de Contratos
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creación        :  07/10/2010
-- Fec Actualización   :
--****************************************************************

NO_PARAMETRO EXCEPTION;

V_REGCLI NUMBER;
C_NOMARCHIVO VARCHAR2(150);
C_CODCLIENTE VARCHAR2(40);
C_CONTRATO NUMBER;
C_FECHACT DATE;
C_NOMCAMP VARCHAR (200);
C_PLANTARIF VARCHAR2 (50);
C_PLAN_UPP VARCHAR2 (50);
C_VIGACUERDO VARCHAR2 (100);
C_FECHAOPE DATE;

C_PUNTOS NUMBER;
V_CODCONCEPTO VARCHAR2(2);
V_IDKARDEX NUMBER;
C_CODCLIENTEIB NUMBER;
C_CONTSMS NUMBER;

 CURSOR ALTACONT_PTOS IS
  SELECT a.ADMPV_COD_CLI,
         a.ADMPV_NOM_ARCH,
         a.ADMPN_COD_CONTR,
         a.ADMPD_FCH_ACT,
         a.ADMPV_NOM_CAMP,
         a.ADMPV_PLNTARIF,
         a.ADMPV_VIGACUE,
         a.ADMPD_FEC_OPER
  FROM PCLUB.ADMPT_TMP_ALTACON_CC a
  WHERE a.ADMPD_FEC_OPER=K_FECHA
        AND (a.ADMPC_COD_ERROR IS NULL OR a.ADMPC_COD_ERROR='');

BEGIN
  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_ALTACON_CC
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_ALTACON_CC
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

   UPDATE PCLUB.ADMPT_TMP_ALTACON_CC TC
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE CC where CC.ADMPV_COD_CLI=TC.ADMPV_COD_CLI);

  COMMIT;

  BEGIN
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%ALTA DE CONTRATO%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  -- SSC 09112010 - Inicio
  /*
  BEGIN
    SELECT TO_NUMBER (ADMPV_VALOR) INTO C_PUNTOS
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE UPPER(ADMPV_DESC) = 'PUNTOS_ALTA_CONTRATO';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN RAISE NO_PARAMETRO;
  END;
  */  -- SSC 09112010 - Fin

  OPEN ALTACONT_PTOS;
  FETCH ALTACONT_PTOS INTO C_CODCLIENTE, C_NOMARCHIVO, C_CONTRATO, C_FECHACT, C_NOMCAMP, C_PLANTARIF, C_VIGACUERDO, C_FECHAOPE;

  WHILE ALTACONT_PTOS %FOUND LOOP

     V_REGCLI :=0;

     SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.ADMPT_AUX_ALTACON_CC
     WHERE ADMPV_COD_CLI = C_CODCLIENTE
           AND ADMPN_COD_CONTR = C_CONTRATO
           AND ADMPD_FCH_ACT = C_FECHACT
           AND ADMPV_NOM_CAMP = C_NOMCAMP
           AND ADMPV_PLNTARIF = C_PLANTARIF
           AND ADMPV_VIGACUE = C_VIGACUERDO
           AND ADMPD_FEC_OPER = C_FECHAOPE
           AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

     IF (V_REGCLI=0) THEN
        BEGIN
          /* Se obtiene el codigo de cliente IB*/
          BEGIN
            SELECT NVL(ADMPN_COD_CLI_IB,NULL) INTO C_CODCLIENTEIB
              FROM PCLUB.ADMPT_CLIENTEIB
             WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';
            EXCEPTION
            WHEN NO_DATA_FOUND then
            C_CODCLIENTEIB := null;
          END;

           -- SSC 09112010 - Inicio Obtenemos los puntos de acuerdo al Plan - cambios 09112010 Indicados por Juan Bulnes
           BEGIN
             C_PUNTOS   := 0;
             C_PLAN_UPP := LTRIM (RTRIM (UPPER (C_PLANTARIF)));

             SELECT ADMPN_PTORENCON INTO C_PUNTOS
               FROM PCLUB.ADMPT_TIPO_PLAN
              WHERE LTRIM (RTRIM (UPPER (ADMPV_DES_PLAN))) = C_PLAN_UPP;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN C_PUNTOS := 0;
           END;
           -- SSC 09112010 - Fin

          IF C_PUNTOS <> 0 THEN
              /* genera secuencial de kardex*/
              SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

              INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                              ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                              ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
              VALUES(V_IDKARDEX, C_CODCLIENTEIB, C_CODCLIENTE, V_CODCONCEPTO,
                     TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), C_PUNTOS, C_NOMARCHIVO, 'E', 'C', C_PUNTOS, 'A');

              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_CC = C_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                    FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                                   WHERE ADMPV_COD_CLI = C_CODCLIENTE)
                WHERE ADMPV_COD_CLI = C_CODCLIENTE;
          END IF;

          -- Insertamos en la auxiliar para los reprocesos
          INSERT INTO PCLUB.ADMPT_AUX_ALTACON_CC
            (ADMPV_COD_CLI, ADMPN_COD_CONTR, ADMPD_FCH_ACT, ADMPV_NOM_CAMP, ADMPV_PLNTARIF, ADMPV_VIGACUE, ADMPD_FEC_OPER, ADMPV_NOM_ARCH)
          VALUES
            (C_CODCLIENTE, C_CONTRATO, C_FECHACT, C_NOMCAMP, C_PLANTARIF, C_VIGACUERDO, C_FECHAOPE, C_NOMARCHIVO);

          -- Insertamos el telefono segun el contrato Luis de la Fuente

          SELECT COUNT(*) INTO C_CONTSMS FROM ADMPT_SMS_TELEFONOS S
          WHERE S.ADMPV_TELEFONO=
                    (select DN_NUM FROM tim.pp_datos_contrato@DBL_BSCS p
                            where p.co_id=C_CONTRATO)
          AND S.ADMPV_FECHA_REG>=TRUNC(SYSDATE)
          AND S.ADMPV_NOMBRE_PROCESO='ALTA DE CONTRATO';

          IF C_CONTSMS=0 THEN
              BEGIN
                INSERT INTO ADMPT_SMS_TELEFONOS(ADMPV_TELEFONO,ADMPC_ESTADO,ADMPV_ESTADO_SMS,ADMPV_NOMBRE_PROCESO,ADMPV_USUARIO_REG,ADMPV_FECHA_REG)
                select DN_NUM,'R','PENDIENTE','ALTA DE CONTRATO','USRCCLUB',SYSDATE from tim.pp_datos_contrato@DBL_BSCS p where p.co_id=C_CONTRATO;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
              NULL;
              WHEN OTHERS THEN
              NULL;
              END;
          END IF;

          -------
        END;
     END IF;

     --COMMIT;

      FETCH ALTACONT_PTOS INTO C_CODCLIENTE, C_NOMARCHIVO, C_CONTRATO, C_FECHACT, C_NOMCAMP, C_PLANTARIF, C_VIGACUERDO, C_FECHAOPE;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ALTACON_CC WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ALTACON_CC WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPC_COD_ERROR Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ALTACON_CC WHERE (admpd_fec_oper=K_FECHA);

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_ALTACON_CC
  SELECT PCLUB.ADMPT_ALTACONT_SQ.nextval, ADMPV_COD_CLI, ADMPN_COD_CONTR, ADMPD_FCH_ACT, ADMPV_NOM_CAMP,
         ADMPV_PLNTARIF, ADMPV_VIGACUE, ADMPD_FEC_OPER, admpv_nom_arch,
         admpc_cod_error, admpv_msje_error, SYSDATE, ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_ALTACON_CC
   WHERE admpd_fec_oper=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_ALTACON_CC WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_ALTACON_CC  WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

  K_CODERROR:= 0;
  K_DESCERROR:= '';

  EXCEPTION
    WHEN NO_PARAMETRO THEN
     K_CODERROR:= 56;
     K_DESCERROR:= 'No se tiene registrado el parametro de entrega de Puntos por Alta de Contratos (PUNTOS_ALTA_CONTRATO).';

    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_ALTACONT;

PROCEDURE ADMPSI_EALTACONT (K_FECHAPROC IN DATE, CURSORALTCONT out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EALTACONT
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Alta de Contratos
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREGPTO
-- Fec Creación        :  07/10/2010
-- Fec Actualización   :
--****************************************************************

BEGIN

OPEN CURSORALTCONT FOR
SELECT TRIM (ADMPV_COD_CLI), ADMPN_COD_CONTR, ADMPD_FCH_ACT, TRIM (ADMPV_NOM_CAMP), TRIM (ADMPV_PLNTARIF),
       TRIM (ADMPV_VIGACUE),TRIM (ADMPC_COD_ERROR), ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_ALTACON_CC
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       ADMPC_COD_ERROR Is Not Null AND
       TRIM (ADMPV_MSJE_ERROR) <> ' '
 ORDER BY ADMPN_SEQ ASC;

END ADMPSI_EALTACONT;

PROCEDURE ADMPSI_ALTACLIC(K_FECHA IN DATE,K_CODERROR  OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER,K_NUMREGERR OUT NUMBER) is
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALTACLIC
  -- Propósito           :  Importar los puntos por Alta de Clientes
  --
  -- Input               :  K_FECHAPROCESO
  --
  -- Output              :  K_CODERROR Codigo de Error o Exito
  --                        K_DESCERROR Descripcion del Error (si se presento)
  --
  -- Fec Creación        :  18/10/2010
  -- Fec Actualización   :
  --****************************************************************
  V_REGCLI     NUMBER;
  C_NOMARCHIVO VARCHAR2(150);
  C_TIPODOC    VARCHAR2(20);
  C_NUMDOC     VARCHAR2(20);
  C_NOMCLI     VARCHAR2(60);
  C_APECLI     VARCHAR2(60);
  C_SEXO       VARCHAR(1);
  C_ESTCIV     VARCHAR2(20);
  C_CODCLI     VARCHAR2(40);
  C_EMAIL      VARCHAR2(80);
  C_PROV       VARCHAR(30);
  C_DEPA       VARCHAR2(40);
  C_DIST       VARCHAR2(200);
  C_FECACT     DATE;
  C_CICFAC     VARCHAR2(2);
  C_CLIENIB    NUMBER;
  C_EXICLIIB   NUMBER;
  COD_SALDO    VARCHAR2(40);
  V_IDSALDO    NUMBER;
/*  C_FECOPER    DATE;*/
/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
/*CUPONERAVIRTUAL - JCGT FIN*/


  CURSOR ALTACLIENTES IS
    SELECT a.ADMPV_TIPO_DOC,
           a.ADMPV_NUM_DOC,
           a.ADMPV_NOM_CLI,
           a.ADMPV_APE_CLI,
           a.ADMPC_SEXO,
           a.ADMPV_EST_CIVIL,
           a.ADMPV_COD_CLI,
           a.ADMPV_EMAIL,
           a.ADMPV_PROV,
           a.ADMPV_DEPA,
           a.ADMPV_DIST,
           a.ADMPD_FEC_ACT,
           a.ADMPV_CICL_FACT,
     /*      A.ADMPD_FEC_OPER,*/
           a.ADMPV_NOM_ARCH
      FROM PCLUB.ADMPT_TMP_ALTACLI_CC a
     WHERE a.ADMPD_FEC_OPER = K_FECHA
       AND (a.ADMPV_COD_ERROR IS NULL OR a.ADMPV_COD_ERROR = '');

BEGIN

  -- Solo podemos validar si enviaron datos en codigo de cliente
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_CC
     SET ADMPV_COD_ERROR  = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = ''
      OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
 /* UPDATE PCLUB.ADMPT_TMP_ALTACLI_CC
     SET ADMPV_COD_ERROR  = '33',
         ADMPV_MSJE_ERROR = 'El codigo de cliente ya existe.'
   WHERE ADMPV_COD_CLI IN (SELECT c.ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE c);*/


   UPDATE PCLUB.ADMPT_TMP_ALTACLI_CC TC
     SET TC.ADMPV_COD_ERROR  = '33',
         TC.ADMPV_MSJE_ERROR = 'El codigo de cliente ya existe.'
   WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE c WHERE c.ADMPV_COD_CLI=TC.ADMPV_COD_CLI);

  COMMIT;

  OPEN ALTACLIENTES;
  FETCH ALTACLIENTES
    INTO C_TIPODOC, C_NUMDOC, C_NOMCLI, C_APECLI, C_SEXO, C_ESTCIV, C_CODCLI, C_EMAIL, C_PROV, C_DEPA, C_DIST, C_FECACT, C_CICFAC, C_NOMARCHIVO;

  WHILE ALTACLIENTES %FOUND LOOP

    V_REGCLI := 0;

    SELECT COUNT(1)
      INTO V_REGCLI
      FROM PCLUB.ADMPT_AUX_ALTACLI_CC
     WHERE ADMPV_TIPO_DOC = C_TIPODOC
       AND ADMPV_NUM_DOC = C_NUMDOC
       AND ADMPV_NOM_CLI = C_NOMCLI
       AND ADMPV_APE_CLI = C_APECLI
       AND ADMPV_COD_CLI = C_CODCLI
       AND ADMPD_FEC_ACT = C_FECACT
       AND ADMPD_FEC_OPER = K_FECHA
       AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO;

    IF (V_REGCLI = 0) THEN
      BEGIN
        -- Debemos verificar si el cliente existe en cliente IB y no tiene Cuenta Claro asociada
        C_EXICLIIB := 1;
        C_CLIENIB := null;

        -- Si existe y no tiene cuenta claro asociada

        -- Debemos insertar los clientes en la tabla de Clientes
        INSERT INTO PCLUB.ADMPT_CLIENTE H
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
           H.ADMPV_CICL_FACT,
           H.ADMPC_ESTADO,
           H.ADMPV_COD_TPOCL)
        VALUES
          (C_CODCLI,
           null,
           null,
           C_TIPODOC,
           C_NUMDOC,
           C_NOMCLI,
           C_APECLI,
           C_SEXO,
           C_ESTCIV,
           C_EMAIL,
           C_PROV,
           C_DEPA,
           C_DIST,
           C_FECACT,
           C_CICFAC,
           'A',
           '2');
           --'3');

        BEGIN
          SELECT g.admpv_cod_cli INTO COD_SALDO
            FROM PCLUB.ADMPT_SALDOS_CLIENTE g
           WHERE admpv_cod_cli = C_CODCLI;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN

             /**Generar secuencial de Saldo*/
            SELECT PCLUB.admpt_sld_cl_sq.nextval INTO V_IDSALDO FROM DUAL;

            INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
              (admpn_id_saldo,
               admpv_cod_cli,
               admpn_cod_cli_ib,
               admpn_saldo_cc,
               admpn_saldo_ib,
               admpc_estpto_cc,
               admpc_estpto_ib)
            VALUES
              (V_IDSALDO, C_CODCLI, C_CLIENIB, 0.00, 0.00, 'A', NULL);

        END;

         -- Insertamos en la auxiliar para los reprocesos
          INSERT INTO PCLUB.ADMPT_AUX_ALTACLI_CC t( t.admpv_tipo_doc, t.admpv_num_doc, t.admpv_nom_cli, t.admpv_ape_cli,
          t.admpv_cod_cli, t.admpd_fec_act, t.admpd_fec_oper, t.admpv_nom_arch)
          VALUES
          (C_TIPODOC,C_NUMDOC,C_NOMCLI,C_APECLI,C_CODCLI,C_FECACT,K_FECHA,C_NOMARCHIVO);

        -- Se asume que es Post debido a que si es Control se utiliza la misma bolsa y para el canje se manda el tipo de cliente segun el telefono
        ----7.  Verificar si el código del cliente existe en la tabla ADMPT_SALDOS_CLIENTE, si existe continuar con el siguiente punto.
        --------Si no existe insertar un registro en esta tabla-----
        --COMMIT;

         /*CUPONERAVIRTUAL - JCGT INI*/
        PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(C_TIPODOC,C_NUMDOC,C_NOMCLI,C_APECLI,C_EMAIL,'ALTA','USRPOST',C_CODERROR,C_DESCERROR);
        /*CUPONERAVIRTUAL - JCGT FIN*/
     END;
    END IF;

    FETCH ALTACLIENTES
      INTO C_TIPODOC, C_NUMDOC, C_NOMCLI, C_APECLI, C_SEXO, C_ESTCIV, C_CODCLI, C_EMAIL, C_PROV, C_DEPA, C_DIST, C_FECACT, C_CICFAC, C_NOMARCHIVO;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT(1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA;
  SELECT COUNT(1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA AND (ADMPV_COD_ERROR Is Not null);
  SELECT COUNT(1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ALTACLI_CC WHERE (ADMPD_FEC_OPER = K_FECHA);

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_ALTACLI_CC
    SELECT PCLUB.ADMPT_ALTACLI_SQ.nextval,
           ADMPV_TIPO_DOC,
           ADMPV_NUM_DOC,
           ADMPV_NOM_CLI,
           ADMPV_APE_CLI,
           ADMPC_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_COD_CLI,
           ADMPV_EMAIL,
           ADMPV_PROV,
           ADMPV_DEPA,
           ADMPV_DIST,
           ADMPD_FEC_ACT,
           ADMPV_CICL_FACT,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH,
           ADMPV_COD_ERROR,
           ADMPV_MSJE_ERROR,
           SYSDATE,
           ADMPN_SEQ
      FROM PCLUB.ADMPT_TMP_ALTACLI_CC
     WHERE admpd_fec_oper = K_FECHA;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA;
  DELETE PCLUB.ADMPT_TMP_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA;

  COMMIT;

  K_CODERROR  := 0;
  K_DESCERROR := '';

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALTACLIC;

PROCEDURE ADMPSI_EALTACLIC(K_FECHAPROC IN DATE,CURSORALTCLI out SYS_REFCURSOR) is
  --****************************************************************
  -- Nombre SP           :  ADMPSI_EALTACLIC
  -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Alta de Clientes
  -- Input               :  K_FECHAPROC
  -- Output              :  CURSORREGPTO
  -- Fec Creación        :  19/10/2010
  -- Fec Actualización   :
  --****************************************************************

BEGIN

  OPEN CURSORALTCLI FOR
    SELECT TRIM(ADMPV_TIPO_DOC),
           TRIM(ADMPV_NUM_DOC),
           TRIM(ADMPV_NOM_CLI),
           TRIM(ADMPV_APE_CLI),
           TRIM(ADMPC_SEXO),
           TRIM(ADMPV_EST_CIVIL),
           TRIM(ADMPV_COD_CLI),
           TRIM(ADMPV_EMAIL),
           TRIM(ADMPV_PROV),
           TRIM(ADMPV_DEPA),
           TRIM(ADMPV_DIST),
           TO_DATE (TO_CHAR(ADMPD_FEC_ACT, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
           TRIM(ADMPV_CICL_FACT),
           TO_DATE (TO_CHAR(ADMPD_FEC_OPER, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
           TRIM(ADMPV_NOM_ARCH),
           TRIM(ADMPV_COD_ERROR),
           TRIM(ADMPV_MSJE_ERROR)
      FROM PCLUB.ADMPT_IMP_ALTACLI_CC
     WHERE ADMPD_FEC_OPER = K_FECHAPROC
       AND ADMPV_COD_ERROR Is Not Null
       AND TRIM(ADMPV_MSJE_ERROR) <> ' '
     ORDER BY ADMPN_SEQ ASC;

END ADMPSI_EALTACLIC;

PROCEDURE ADMPSI_PROMOC(K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_PROMOC
-- Propósito           :  Importar los puntos por Promociones
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creación        :  12/10/2010
-- Fec Actualización   :
--****************************************************************

V_REGCLI NUMBER;
C_FECPROCESO DATE;
C_NOMARCHIVO VARCHAR2(150);
C_NOM_PROM VARCHAR2(150);
C_CODCLIENTE VARCHAR2(40);
C_PUNTOS NUMBER;
C_SALDO NUMBER;
V_TIPOP CHAR(1);
V_CODCONCEPTO VARCHAR2(2);
V_IDKARDEX NUMBER;
C_CODCLIENTEIB NUMBER;
C_PERIODO VARCHAR2(6);
C_CONTRATO NUMBER;
C_FEG_REG DATE;
C_HORAMIN VARCHAR2(5);
V_TIPO_CLIENTE VARCHAR(2);

 CURSOR PROMOCION_PTOS IS
  SELECT a.ADMPV_COD_CLI,
         a.ADMPN_PUNTOS,
         a.ADMPD_FEC_OPER,
         a.ADMPV_NOM_ARCH,
         a.ADMPV_NOM_PROM,
         a.ADMPV_PERIODO,
         a.ADMPN_CONTR,
         a.ADMPD_FEC_REG,
         a.ADMPV_HORAMIN
  FROM PCLUB.ADMPT_TMP_PROM a
  WHERE a.ADMPD_FEC_OPER=K_FECHA
        AND (a.admpv_msje_error IS NULL OR a.admpv_msje_error = ' ');

BEGIN
  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_PROM
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
 /* UPDATE PCLUB.ADMPT_TMP_PROM
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);
   */
   UPDATE PCLUB.ADMPT_TMP_PROM tm
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE c where c.ADMPV_COD_CLI=tm.ADMPV_COD_CLI);

  COMMIT;

  BEGIN
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%PROMOCIONES CC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  OPEN PROMOCION_PTOS;
  FETCH PROMOCION_PTOS INTO C_CODCLIENTE, C_PUNTOS, C_FECPROCESO, C_NOMARCHIVO, C_NOM_PROM, C_PERIODO, C_CONTRATO, C_FEG_REG, C_HORAMIN;

  WHILE PROMOCION_PTOS %FOUND LOOP

     V_REGCLI :=0;

     SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.ADMPT_AUX_PROM
     WHERE ADMPV_COD_CLI = C_CODCLIENTE
           AND ADMPV_NOM_PROM = C_NOM_PROM
           AND ADMPV_PERIODO = C_PERIODO
           AND ADMPN_CONTR = C_CONTRATO
           AND ADMPD_FEC_REG = C_FEG_REG
           AND ADMPV_HORAMIN = C_HORAMIN
           AND ADMPN_PUNTOS = C_PUNTOS
           AND ADMPD_FEC_OPER = C_FECPROCESO
           AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

     IF (V_REGCLI=0) THEN
        BEGIN

          IF C_PUNTOS < 0 THEN
             V_TIPOP := 'S';
             C_SALDO := 0.00;
          ELSE
             V_TIPOP := 'E';
             C_SALDO := C_PUNTOS;
          END IF;

          /* Se obtiene el codigo de cliente IB*/
          BEGIN
            SELECT NVL(ADMPN_COD_CLI_IB,NULL) INTO C_CODCLIENTEIB
              FROM PCLUB.ADMPT_CLIENTEIB
             WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';
            EXCEPTION
            WHEN NO_DATA_FOUND then
            C_CODCLIENTEIB := null;
          END;

          /*Se obtiene el tipo de cliente*/
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
                       TO_DATE (TO_CHAR(SYSDATE, 'dd/mm/yyyy'), 'dd/mm/yyyy'), C_PUNTOS , C_NOMARCHIVO, V_TIPOP, 'C', C_SALDO, 'A');

              END IF;

            ELSE

              /* genera secuencial de kardex*/
              SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

              INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                              ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                              ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
              VALUES(V_IDKARDEX, C_CODCLIENTEIB, C_CODCLIENTE, V_CODCONCEPTO,
                     TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), C_PUNTOS, C_NOMARCHIVO, V_TIPOP, 'C', C_SALDO, 'A');


        BEGIN
              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_CC =  ADMPN_SALDO_CC + C_PUNTOS
                WHERE ADMPV_COD_CLI = C_CODCLIENTE;
        END;

            END IF;
          END IF;

          -- Insertamos en la auxiliar para los reprocesos
          INSERT INTO PCLUB.ADMPT_AUX_PROM
            (admpv_cod_cli, admpv_nom_prom, admpn_puntos, admpd_fec_oper, admpv_nom_arch)
          VALUES
            (C_CODCLIENTE, C_NOM_PROM, C_PUNTOS, C_FECPROCESO, C_NOMARCHIVO);

        END;
     END IF;

        --COMMIT;

      FETCH PROMOCION_PTOS INTO C_CODCLIENTE, C_PUNTOS, C_FECPROCESO, C_NOMARCHIVO, C_NOM_PROM, C_PERIODO, C_CONTRATO, C_FEG_REG, C_HORAMIN;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_PROM WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_PROM WHERE ADMPD_FEC_OPER=K_FECHA AND (admpc_cod_error Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_PROM WHERE (admpd_fec_oper=K_FECHA);

  -- Insertamos de la tabla temporal al final
  INSERT INTO PCLUB.ADMPT_IMP_PROM
  SELECT PCLUB.ADMPT_PROM_SQ.nextval, admpv_cod_cli, admpv_nom_prom, admpv_periodo, admpn_contr,
         admpd_fec_reg, admpv_horamin, admpn_puntos, admpd_fec_oper, admpv_nom_arch,
         admpc_cod_error, admpv_msje_error, SYSDATE, ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_PROM
   WHERE admpd_fec_oper=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_PROM WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_PROM  WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

  EXCEPTION
    WHEN OTHERS THEN


     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_PROMOC;

PROCEDURE ADMPSI_EPROMOC(K_FECHAPROC IN DATE, CURSORPROMPTO out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EPROMOC
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Puntos por Promocion
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREGPTO
-- Fec Creación        :  12/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORPROMPTO FOR
SELECT TRIM (ADMPV_COD_CLI), TRIM (ADMPV_NOM_PROM), TRIM (ADMPV_PERIODO), ADMPN_CONTR, ADMPD_FEC_REG,
       TRIM (ADMPV_HORAMIN), ADMPN_PUNTOS, TRIM (ADMPC_COD_ERROR), ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_PROM
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       ADMPC_COD_ERROR Is Not Null AND
       TRIM (ADMPV_MSJE_ERROR) <> ' '
 ORDER BY ADMPN_SEQ ASC;

END ADMPSI_EPROMOC;

procedure ADMPSI_ANIVERS (K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER,K_NUMREGERR OUT NUMBER) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ANIVERS
-- Propósito           :  Importación de datos por Aniversario de líneas Claro
--
-- Input               :  K_FECHAOPER
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creación        :  12/09/2010
-- Fec Actualización   :
--****************************************************************

NO_PARAMETRO EXCEPTION;

V_REGCLI NUMBER;
C_FECOPER DATE;
C_NOMARCHIVO VARCHAR2(150);
C_PERIODO VARCHAR2(6);
C_CODCLIENTE VARCHAR2(40);
C_PUNTOS NUMBER;
C_SALDO NUMBER;
V_TIPOP CHAR(1);
V_CODCONCEPTO VARCHAR2(2);
V_IDKARDEX NUMBER;
C_CODCLIENTEIB NUMBER;
V_CAT_CLI NUMBER;
V_TIPO_CLI VARCHAR(2);

CURSOR IMPORT_ANIVERSARIO IS
SELECT  admpv_cod_cli,
        ADMPV_PERIODO,
        admpd_fec_oper,
        admpv_nom_arch
   FROM PCLUB.admpt_tmp_aniv
   WHERE ADMPD_FEC_OPER=K_FECHA
   AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='')     ;


BEGIN
  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_ANIV
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_ANIV
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

     UPDATE PCLUB.ADMPT_TMP_ANIV TA
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TA.ADMPV_COD_CLI);

  COMMIT;
  ---Asignar el concepto ------
  BEGIN
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%ANIVERSARIO CC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  OPEN IMPORT_ANIVERSARIO;
  FETCH IMPORT_ANIVERSARIO INTO C_CODCLIENTE, C_PERIODO, C_FECOPER, C_NOMARCHIVO;

  WHILE IMPORT_ANIVERSARIO %FOUND LOOP

     V_REGCLI :=0;
     C_PUNTOS := 0;

     SELECT COUNT(1)INTO V_REGCLI FROM PCLUB.ADMPT_AUX_ANIV D
     WHERE D.ADMPV_COD_CLI = C_CODCLIENTE
           AND ADMPV_PERIODO=C_PERIODO
            AND D.ADMPD_FEC_OPER = C_FECOPER
           AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

     -- Obtenemos la Categoria y Tipo del Cliente
     BEGIN
       SELECT ADMPN_COD_CATCLI, ADMPV_COD_TPOCL INTO V_CAT_CLI, V_TIPO_CLI
         FROM PCLUB.ADMPT_CLIENTE
        WHERE ADMPV_COD_CLI = C_CODCLIENTE;

       EXCEPTION
            WHEN NO_DATA_FOUND then
            V_CAT_CLI := 2;     -- Cliente Normal
            V_TIPO_CLI := '2';  -- Postpago
     END;

     -- Obtenemos los puntos segun la categoria del cliente
     BEGIN
        -- SSC 22122010 - Si el cliente no tiene categoria se asume la Normal
        IF V_CAT_CLI IS NULL THEN
           V_CAT_CLI := 2;
        END IF;

        SELECT ADMPN_PTOANIV INTO C_PUNTOS
          FROM PCLUB.ADMPT_CAT_CLIENTE
         WHERE ADMPN_COD_CATCLI = V_CAT_CLI AND
               ADMPV_COD_TPOCL = V_TIPO_CLI;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN RAISE NO_PARAMETRO;
     END;

     IF (V_REGCLI=0) THEN
        BEGIN

          IF C_PUNTOS < 0 THEN
             V_TIPOP := 'S';
             C_SALDO := 0.00;
          ELSE
             V_TIPOP := 'E';
             C_SALDO := C_PUNTOS;
          END IF;

          /* Se obtiene el codigo de cliente IB*/
          BEGIN
            SELECT NVL(ADMPN_COD_CLI_IB,NULL) INTO C_CODCLIENTEIB
              FROM PCLUB.ADMPT_CLIENTEIB
             WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';
            EXCEPTION
            WHEN NO_DATA_FOUND then
            C_CODCLIENTEIB := null;
          END;

          IF C_PUNTOS <> 0 THEN
              /* genera secuencial de kardex*/
              SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

              INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI, ADMPV_COD_CPTO,
                                                 ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                 ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
              VALUES(V_IDKARDEX, C_CODCLIENTEIB, C_CODCLIENTE, V_CODCONCEPTO,
                     TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), C_PUNTOS, C_NOMARCHIVO, V_TIPOP, 'C', C_SALDO, 'A');


              UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_CC = C_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0)
                                                    FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                                   WHERE ADMPV_COD_CLI = C_CODCLIENTE)
                WHERE ADMPV_COD_CLI = C_CODCLIENTE;

              -- Actualizamos el temporal para que se pueda mostrar en el reporte de DetMovto
              UPDATE PCLUB.ADMPT_TMP_ANIV
                 SET ADMPN_PUNTOS = C_PUNTOS
               WHERE ADMPV_COD_CLI = C_CODCLIENTE AND
                     ADMPV_PERIODO = C_PERIODO AND
                     ADMPD_FEC_OPER = C_FECOPER AND
                     ADMPV_NOM_ARCH = C_NOMARCHIVO;

          END IF;

          -- Insertamos en la auxiliar para los reprocesos
          INSERT INTO PCLUB.ADMPT_AUX_ANIV
          (admpv_cod_cli, ADMPV_PERIODO, admpd_fec_oper, admpv_nom_arch)
          VALUES
            (C_CODCLIENTE, C_PERIODO, C_FECOPER, C_NOMARCHIVO);

        END;
     END IF;

        --COMMIT;

      FETCH IMPORT_ANIVERSARIO INTO C_CODCLIENTE,C_PERIODO,C_FECOPER, C_NOMARCHIVO;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ANIV WHERE ADMPD_FEC_OPER=K_FECHA; --TOTALES
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ANIV WHERE ADMPD_FEC_OPER=K_FECHA AND (admpc_cod_error Is Not null);-- PROCESADOS
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ANIV WHERE ADMPD_FEC_OPER=K_FECHA; -- CON ERROR

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_ANIV
  SELECT PCLUB.ADMPT_ANIV_SQ.nextval, V.ADMPV_COD_CLI, V.ADMPV_PERIODO, V.ADMPD_FEC_OPER,
         V.ADMPV_NOM_ARCH, V.ADMPC_COD_ERROR, V.ADMPV_MSJE_ERROR, sysdate, v.admpn_seq, ADMPN_PUNTOS
         FROM PCLUB.ADMPT_TMP_ANIV  v
         WHERE V.ADMPD_FEC_OPER=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_ANIV WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_ANIV  WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

  EXCEPTION
   WHEN NO_PARAMETRO THEN
     K_CODERROR:= 56;
     K_DESCERROR:= 'No se tiene registrado el parametro de entrega de Puntos por Aniversario (PUNTOS_ANIVERSARIO).';

    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);


END ADMPSI_ANIVERS;

PROCEDURE ADMPSI_EANIVERS(K_FECHAPROC IN DATE, CURSORANIVER out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EANIVERS
-- Propósito           :  Devuelve en un cursor solo los registros con errores encontrados en el proceso de Aniversario.
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREGANIVER
-- Fec Creación        :  13/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORANIVER FOR
SELECT TRIM(ADMPV_COD_CLI), TRIM(ADMPV_PERIODO),
       TRIM(ADMPC_COD_ERROR),ADMPV_MSJE_ERROR
FROM PCLUB.ADMPT_IMP_ANIV
WHERE ADMPD_FEC_OPER=K_FECHAPROC
AND ADMPC_COD_ERROR IS NOT NULL
AND TRIM (ADMPV_MSJE_ERROR) <> ' '
ORDER BY ADMPN_SEQ ASC;

END ADMPSI_EANIVERS;

procedure ADMPSI_CAMBTITC (K_FECHAOPER IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER,K_NUMREGERR OUT NUMBER) is
--****************************************************************
-- Nombre SP           :  ADMPSI_CAMBTITC
-- Propósito           :  Actualizacion de los saldos de puntos por cambio de Titularidad
--
-- Input               :  K_FECHAOPER
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creación        :  14/09/2010
-- Fec Actualización   :
--****************************************************************

V_REGCLI NUMBER;
C_PUNTOS NUMBER;
V_CODCONCEPTO VARCHAR2(2);
V_IDKARDEX NUMBER;
C_CODCLIENTEIB NUMBER;
C_TIPODOC    VARCHAR2(20);
C_NUMDOC     VARCHAR2(20);
C_NOMBRE_CLI VARCHAR2(80);
C_APELLIDO   VARCHAR2(80);
C_SEXO       CHAR(1);
C_EST_CIVIL  VARCHAR2(20);
C_CODCLIENTE VARCHAR2(40);
C_EMAIL      VARCHAR2(80);
C_PROV       VARCHAR2(30);
C_DEPA       VARCHAR2(40);
C_DISTR      VARCHAR2(200);
C_FEC_ACT    DATE;
C_CICL_FACT  VARCHAR2(2);
C_NOMARCHIVO VARCHAR2(150);
C_FECOPER   DATE;
V_IDSALDO   NUMBER;
V_SALDO_CC   NUMBER;
V_SALDO_CI   NUMBER;
V_SALDO_ALMAC NUMBER;
V_TIPO_PUNTO  CHAR (1);

V_COD_SALDO    VARCHAR(40);
V_COD_NUEVO   NUMBER;
V_COD_CLINUE   VARCHAR(40);
V_REG                 NUMBER;
V_COD_ERROR NUMBER;

/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  K_TIPODOC VARCHAR2(20);
  K_NUMDOC VARCHAR2(20);
  /*CUPONERAVIRTUAL - JCGT FIN*/

CURSOR CAMBIO_TITULARIDAD IS

SELECT C.ADMPV_TIPO_DOC,
       C.ADMPV_NUM_DOC,
       C.ADMPV_NOM_CLI,
       C.ADMPV_APE_CLI,
       C.ADMPC_SEXO,
       C.ADMPV_EST_CIVIL,
       C.ADMPV_COD_CLI,
       C.ADMPV_EMAIL,
       C.ADMPV_PROV,
       C.ADMPV_DEPA,
       C.ADMPV_DIST,
       C.ADMPD_FEC_ACT,
       C.ADMPV_CICL_FACT,
       C.ADMPV_NOM_ARCH,
       C.ADMPD_FEC_OPER
  FROM PCLUB.admpt_tmp_cmbtit_cc C
 WHERE ADMPD_FEC_OPER=K_FECHAOPER
   AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='');

CURSOR CUR_VALIDA_SALKARDEX IS
SELECT C.ADMPV_COD_CLI
 FROM    PCLUB.admpt_tmp_cmbtit_cc C
 WHERE ADMPD_FEC_OPER=K_FECHAOPER
   AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR='');

BEGIN
  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.admpt_tmp_cmbtit_cc
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.admpt_tmp_cmbtit_cc
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede cambiar el Titular.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

   UPDATE PCLUB.admpt_tmp_cmbtit_cc TC
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede cambiar el Titular.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TC.ADMPV_COD_CLI);

   /*JCGT SD27112012*/
    UPDATE PCLUB.admpt_tmp_cmbtit_cc TC
     SET ADMPC_COD_ERROR = '17',
         ADMPV_MSJE_ERROR = 'El cliente tiene saldo negativo.'
   WHERE EXISTS (SELECT 1 FROM ADMPT_SALDOS_CLIENTE C WHERE C.ADMPV_COD_CLI=TC.ADMPV_COD_CLI AND C.ADMPN_SALDO_CC<0);

    UPDATE PCLUB.admpt_tmp_cmbtit_cc TC
     SET ADMPC_COD_ERROR = '6',
         ADMPV_MSJE_ERROR = 'El cliente Actual esta de Baja, no se puede cambiar el Titular'
   WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TC.ADMPV_COD_CLI AND ADMPC_ESTADO='B' );

/* Actualizar admpt_tmp_cmbtit_cc por Desalineacion de Puntos*/

OPEN CUR_VALIDA_SALKARDEX;
 FETCH CUR_VALIDA_SALKARDEX INTO C_CODCLIENTE;
 WHILE CUR_VALIDA_SALKARDEX %FOUND LOOP
              PCLUB.PKG_CC_TRANSACCION.ADMPSS_VALIDASALDOKDX(C_CODCLIENTE, '2', V_COD_ERROR);
              IF V_COD_ERROR = 1 THEN
                     UPDATE PCLUB.admpt_tmp_cmbtit_cc
                             SET ADMPC_COD_ERROR = '33',
                                 ADMPV_MSJE_ERROR = 'Los Puntos No se encuentran Alineados'
                      WHERE ADMPV_COD_CLI =C_CODCLIENTE ;
              END IF;
      FETCH CUR_VALIDA_SALKARDEX INTO C_CODCLIENTE;
 END LOOP;

  COMMIT;

   ---Asignar el codigo de concepto ------
  BEGIN
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE 'CAMBIO TITULARIDAD';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  OPEN CAMBIO_TITULARIDAD;
  FETCH CAMBIO_TITULARIDAD INTO C_TIPODOC, C_NUMDOC, C_NOMBRE_CLI, C_APELLIDO,C_SEXO, C_EST_CIVIL, C_CODCLIENTE,
  C_EMAIL, C_PROV, C_DEPA, C_DISTR, C_FEC_ACT, C_CICL_FACT, C_NOMARCHIVO, C_FECOPER;

  WHILE CAMBIO_TITULARIDAD %FOUND LOOP

     V_REGCLI :=0;
     C_PUNTOS :=0;

     SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.admpt_aux_cmbtit_cc D
     WHERE D.ADMPV_TIPO_DOC = C_TIPODOC
          AND  D.ADMPV_NUM_DOC= C_NUMDOC
          AND D.ADMPV_NOM_CLI= C_NOMBRE_CLI
          AND D.ADMPV_APE_CLI= C_APELLIDO
          AND D.ADMPC_SEXO= C_SEXO
          AND D.ADMPV_EST_CIVIL= C_EST_CIVIL
          AND D.ADMPV_COD_CLI= C_CODCLIENTE
          AND D.ADMPV_EMAIL= C_EMAIL
          AND D.ADMPV_PROV= C_PROV
          AND D.ADMPV_DEPA= C_DEPA
          AND D.ADMPV_DIST= C_DISTR
          AND D.ADMPD_FEC_ACT= C_FEC_ACT
          AND D.ADMPV_CICL_FACT=C_CICL_FACT
          AND D.ADMPD_FEC_OPER = C_FECOPER
          AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

     IF (V_REGCLI=0) THEN
          /* Se obtiene el saldo del cliente cc*/
         BEGIN
            V_SALDO_CC := 0.00;
            SELECT NVL(S.ADMPN_SALDO_CC,NULL) INTO V_SALDO_CC
              FROM PCLUB.ADMPT_SALDOS_CLIENTE S
             WHERE S.ADMPV_COD_CLI = C_CODCLIENTE;

              EXCEPTION
                   WHEN NO_DATA_FOUND then
                        V_SALDO_CC := 0.00;
         END;

         IF V_SALDO_CC < 0 THEN
            V_SALDO_ALMAC := V_SALDO_CC;
            V_TIPO_PUNTO  := 'E';
         ELSE
            V_SALDO_ALMAC := V_SALDO_CC * -1;
            V_TIPO_PUNTO  := 'S';
         END IF;

         /* Se obtiene el codigo del cliente IB si es diferente a nulo*/
         BEGIN
           SELECT D.ADMPN_COD_CLI_IB INTO C_CODCLIENTEIB
             FROM PCLUB.ADMPT_SALDOS_CLIENTE D
            WHERE D.ADMPN_SALDO_IB IS NOT NULL
                  AND D.ADMPV_COD_CLI = C_CODCLIENTE;

            EXCEPTION
                  WHEN NO_DATA_FOUND then
                       C_CODCLIENTEIB := null;
         END;

         /* Se obtiene el saldo del cliente IB*/
         IF C_CODCLIENTEIB IS NOT NULL AND  C_CODCLIENTEIB > 0 THEN
            BEGIN
              SELECT NVL(S.ADMPN_SALDO_IB,NULL) INTO V_SALDO_CI
              FROM PCLUB.ADMPT_SALDOS_CLIENTE S
              WHERE S.ADMPN_COD_CLI_IB = C_CODCLIENTEIB;

              EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         V_SALDO_CI := null;
            END;

            /*Con el cliente IB obtenido actualizar la tabla de ADMPT_CLIENTEIB en los campos ADMPV_COD_CLI y ADMPV_NUM_LINEA con nulos.*/
            UPDATE PCLUB.ADMPT_CLIENTEIB F
               SET F.ADMPV_COD_CLI=NULL,F.ADMPV_NUM_LINEA = NULL
             WHERE F.ADMPN_COD_CLI_IB=C_CODCLIENTEIB;

            /*Actualizar la tabla de saldo en los campos ADMPN_COD_CLI_IB, ADMPN_SALDO_IB y ADMPC_ESTPTO_IB, con nulo, cero y nulo respectivamente*/

             UPDATE PCLUB.ADMPT_SALDOS_CLIENTE d
                SET D.ADMPN_COD_CLI_IB= NULL, D.ADMPN_SALDO_IB=0, D.ADMPC_ESTPTO_IB=NULL
              WHERE D.ADMPN_COD_CLI_IB=C_CODCLIENTEIB;

            /* INSERTAMOS EN LA TABLA SALDO_CLIENTE*/
            SELECT PCLUB.admpt_sld_cl_sq.NEXTVAL INTO V_IDSALDO FROM DUAL;

            INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE (ADMPN_ID_SALDO, ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,
                                              ADMPN_SALDO_IB, ADMPC_ESTPTO_CC, ADMPC_ESTPTO_IB)
            VALUES (V_IDSALDO, NULL, C_CODCLIENTEIB, 0.00, V_SALDO_CI , NULL ,'A');

            -- Los puntos IB que tienen aun saldo deben romper la relacion con el cliente Claro
            UPDATE PCLUB.ADMPT_KARDEX
               SET ADMPV_COD_CLI = null
             WHERE ADMPN_COD_CLI_IB = C_CODCLIENTEIB
                   AND ADMPC_TPO_PUNTO = 'I'
                   AND ADMPN_SLD_PUNTO > 0
                   AND ADMPC_TPO_OPER = 'E';

                    -- Los puntos CC en el kardex debe romperse la relación con los puntos IB
            UPDATE PCLUB.ADMPT_KARDEX SET ADMPN_COD_CLI_IB = null
             WHERE ADMPV_COD_CLI = C_CODCLIENTE AND ADMPC_TPO_PUNTO <> 'I';

          END IF;

          IF V_SALDO_CC <> 0 THEN
              /* genera secuencial de kardex*/
              SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

              INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI, ADMPV_COD_CPTO,
                                                 ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                 ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
              VALUES(V_IDKARDEX, NULL, C_CODCLIENTE, V_CODCONCEPTO,
              TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_ALMAC, C_NOMARCHIVO, V_TIPO_PUNTO, 'C', C_PUNTOS, 'A');
          END IF;

          -- ACTUALIZAMOS EL SALDO DE LOS MOVIMIENTOS DE ENTRADA DEL KARDEX A 0 SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
          UPDATE PCLUB.ADMPT_KARDEX
             SET ADMPN_SLD_PUNTO = C_PUNTOS
           WHERE ADMPV_COD_CLI = C_CODCLIENTE
                 AND ADMPC_TPO_PUNTO IN ('C','L')
                 AND ADMPN_SLD_PUNTO > 0
                 AND ADMPC_TPO_OPER = 'E';

           -- ACTUALIZAR EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
               SET S.ADMPN_SALDO_CC = C_PUNTOS
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;


          -- Insertamos en la auxiliar para los reprocesos
          INSERT INTO PCLUB.ADMPT_AUX_CMBTIT_CC cc
          (cc.admpv_tipo_doc, cc.admpv_num_doc, cc.admpv_nom_cli, cc.admpv_ape_cli,
          cc.admpc_sexo, cc.admpv_est_civil, cc.admpv_email, cc.admpv_prov, cc.admpv_depa, cc.admpv_dist, cc.admpd_fec_act,
          cc.admpv_cicl_fact, cc.admpd_fec_oper,  cc.admpv_cod_cli, cc.admpv_nom_arch)
          VALUES (C_TIPODOC, C_NUMDOC, C_NOMBRE_CLI, C_APELLIDO, C_SEXO, C_EST_CIVIL, C_EMAIL, C_PROV,
           C_DEPA, C_DISTR, C_FEC_ACT, C_CICL_FACT, C_FECOPER,C_CODCLIENTE, C_NOMARCHIVO);

         /*---------------------------Ahora obtenemos el nuevo código del cliente origen----------------------------*/
            V_COD_NUEVO  := 1;
            V_COD_CLINUE := '';

              WHILE V_COD_NUEVO > 0 LOOP
                    V_COD_CLINUE := TRIM(C_CODCLIENTE) || '-' || TO_CHAR(V_COD_NUEVO);
                    V_REG := 0;
                BEGIN
                  SELECT COUNT(*)     INTO V_REG
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
        /*---------------------------Fin de Cliente Origen----------------------------*/
           -- Debido a la FK primero se debe insertar el registro
            INSERT INTO PCLUB.ADMPT_CLIENTE (ADMPV_COD_CLI)
                 VALUES ('999999999999999999999');

            UPDATE PCLUB.ADMPT_CANJE
               SET ADMPV_COD_CLI = '999999999999999999999'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            -- Ahora actualizamos los movimientos, saldos y código de cliente con el código obtenido
            UPDATE PCLUB.ADMPT_KARDEX
               SET ADMPV_COD_CLI = V_COD_CLINUE
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
               SET ADMPV_COD_CLI = V_COD_CLINUE, ADMPN_SALDO_CC = 0,ADMPC_ESTPTO_CC='B'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_CLIENTE
               SET ADMPV_COD_CLI = V_COD_CLINUE, ADMPC_ESTADO = 'B' , ADMPV_USU_MOD = 'USRCTITPOST'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_CANJE
               SET ADMPV_COD_CLI = V_COD_CLINUE
             WHERE ADMPV_COD_CLI = '999999999999999999999';

            DELETE FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = '999999999999999999999';

           DELETE FROM PCLUB.ADMPT_CLIENTE WHERE  ADMPV_COD_CLI = C_CODCLIENTE;
          /*ACTUALIZAR LA TABLA DE CLIENTES*/

          /*-------------------------------------------INSERTAMOS EL NUEVO CLIENTE------------------------------------------*/
                      -- Debemos insertar los clientes en la tabla de Clientes
            INSERT INTO PCLUB.ADMPT_CLIENTE H (H.ADMPV_COD_CLI, H.ADMPV_COD_SEGCLI, H.ADMPN_COD_CATCLI, H.ADMPV_TIPO_DOC, H.ADMPV_NUM_DOC,
                                         H.ADMPV_NOM_CLI, H.ADMPV_APE_CLI, H.ADMPC_SEXO, H.ADMPV_EST_CIVIL, H.ADMPV_EMAIL, H.ADMPV_PROV, H.ADMPV_DEPA, H.ADMPV_DIST,
                                         H.ADMPD_FEC_ACTIV, H.ADMPV_CICL_FACT,H.ADMPC_ESTADO, H.ADMPV_COD_TPOCL, ADMPV_USU_REG )
            VALUES (C_CODCLIENTE, null, '2', C_TIPODOC, C_NUMDOC, C_NOMBRE_CLI, C_APELLIDO, C_SEXO, C_EST_CIVIL, C_EMAIL, C_PROV, C_DEPA, C_DISTR,
                             TO_DATE(TO_CHAR(C_FEC_ACT, 'DD/MM/YYYY'), 'DD/MM/YYYY'), C_CICL_FACT, 'A', '2','USRCTITPOST');

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
          /*--------------------------------------------------------------------------------------------------------------------------------*/
         /*   BEGIN
               UPDATE PCLUB.admpt_cliente F
                  SET F.ADMPV_TIPO_DOC=C_TIPODOC,
                      F.ADMPV_NUM_DOC=C_NUMDOC,
                      F.ADMPV_NOM_CLI=C_NOMBRE_CLI,
                      F.ADMPV_APE_CLI=C_APELLIDO,
                      F.ADMPC_SEXO=C_SEXO,
                      F.ADMPV_EST_CIVIL=C_EST_CIVIL,
                      F.ADMPV_EMAIL=C_EMAIL,
                      F.ADMPV_PROV=C_PROV,
                      F.ADMPV_DEPA=C_DEPA,
                      F.ADMPV_DIST=C_DISTR,
                      F.ADMPD_FEC_ACTIV=C_FEC_ACT,
                      F.ADMPV_CICL_FACT=C_CICL_FACT
                WHERE F.ADMPV_COD_CLI=C_CODCLIENTE;

               EXCEPTION
                    WHEN NO_DATA_FOUND THEN C_CODCLIENTE := null;
            END;
       */
            /*CUPONERAVIRTUAL - JCGT INI*/
           PCLUB.PKG_CC_CUPONERA.ADMPSI_CAMBIOTITULAR(K_TIPODOC,K_NUMDOC,C_TIPODOC,C_NUMDOC,C_NOMBRE_CLI,C_APELLIDO,C_EMAIL,'CMBTIT', 'USRPOST',C_CODERROR,C_DESCERROR);
           /*CUPONERAVIRTUAL - JCGT FIN*/

     END IF;

     --COMMIT;

      FETCH CAMBIO_TITULARIDAD INTO C_TIPODOC, C_NUMDOC, C_NOMBRE_CLI, C_APELLIDO,C_SEXO, C_EST_CIVIL, C_CODCLIENTE,
            C_EMAIL, C_PROV, C_DEPA, C_DISTR, C_FEC_ACT, C_CICL_FACT, C_NOMARCHIVO, C_FECOPER;

   END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.admpt_tmp_cmbtit_cc WHERE ADMPD_FEC_OPER=K_FECHAOPER; --TOTALES
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.admpt_tmp_cmbtit_cc WHERE ADMPD_FEC_OPER=K_FECHAOPER AND (admpc_cod_error Is Not null);-- PROCESADOS
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.admpt_aux_cmbtit_cc WHERE ADMPD_FEC_OPER=K_FECHAOPER; -- CON ERROR

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.admpt_imp_cmbtit_cc
  SELECT PCLUB.ADMPT_CAMBIOTT_SQ.nextval, v.admpv_tipo_doc, v.admpv_num_doc, v.admpv_nom_cli, v.admpv_ape_cli,
         v.admpc_sexo, v.admpv_est_civil,v.admpv_cod_cli, v.admpv_email, v.admpv_prov, v.admpv_depa, v.admpv_dist, v.admpd_fec_act,
         v.admpv_cicl_fact, v.admpd_fec_oper, v.admpv_nom_arch, V.ADMPC_COD_ERROR, V.ADMPV_MSJE_ERROR, sysdate, v.admpn_seq
         FROM PCLUB.admpt_tmp_cmbtit_cc v
         WHERE V.ADMPD_FEC_OPER=K_FECHAOPER;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.admpt_aux_cmbtit_cc WHERE ADMPD_FEC_OPER=K_FECHAOPER;
   DELETE PCLUB.admpt_tmp_cmbtit_cc  WHERE ADMPD_FEC_OPER=K_FECHAOPER;

  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

 EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);


END ADMPSI_CAMBTITC;

PROCEDURE ADMPSI_ECAMBTITC (K_FECHAPROC IN DATE, CURSORCAMBTI out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ECAMBTITC
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Cambio de Titular
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREGCAMBT
-- Fec Creación        :  18/10/2010
-- Fec Actualización   :
--****************************************************************

BEGIN
OPEN CURSORCAMBTI FOR
SELECT C.ADMPV_TIPO_DOC,
       C.ADMPV_NUM_DOC,
       C.ADMPV_NOM_CLI,
       C.ADMPV_APE_CLI,
       C.ADMPC_SEXO,
       C.ADMPV_EST_CIVIL,
       C.ADMPV_COD_CLI,
       C.ADMPV_EMAIL,
       C.ADMPV_PROV,
       C.ADMPV_DEPA,
       C.ADMPV_DIST,
       C.ADMPD_FEC_ACT,
       C.ADMPV_CICL_FACT,
       C.ADMPD_FEC_OPER,
       C.ADMPV_NOM_ARCH,
       TRIM(ADMPC_COD_ERROR),
       C.ADMPV_MSJE_ERROR
FROM PCLUB.ADMPT_IMP_CMBTIT_CC C
WHERE ADMPD_FEC_OPER=K_FECHAPROC
AND ADMPC_COD_ERROR IS NOT NULL
AND TRIM (ADMPV_MSJE_ERROR) <> ' '
ORDER BY ADMPN_SEQ ASC;

END ADMPSI_ECAMBTITC;

PROCEDURE ADMPSI_RENCONTC(K_FECHAOPER IN DATE,
                                            K_CODERROR  OUT NUMBER,
                                            K_DESCERROR OUT VARCHAR2,
                                            K_NUMREGTOT OUT NUMBER,
                                            K_NUMREGPRO OUT NUMBER,
                                            K_NUMREGERR OUT NUMBER) is

  --****************************************************************
  -- Nombre SP           :  ADMPSI_RENCONTC
  -- Propósito           :  Importar los puntos por Renovacion de Contratos
  --
  -- Input               :  K_FECHAOPER
  --
  -- Output              :  K_CODERROR Codigo de Error o Exito
  --                        K_DESCERROR Descripcion del Error (si se presento)
  --
  -- Fec Creación        :  18/10/2010
  -- Fec Actualización   :
  --****************************************************************

  NO_PARAMETRO EXCEPTION;

  V_REGCLI       NUMBER;
  C_FECOPER      DATE;
  C_FECHA_RE     DATE;
  C_CODCLIENTE   VARCHAR2(40);
  C_NOMARCHIVO   VARCHAR2(150);
  COD_CONTR      NUMBER;
  C_PUNTOS       NUMBER;
  C_SALDO        NUMBER;
  C_FONO         NUMBER;
  V_TIPOP        CHAR(1);
  V_CODCONCEPTO  VARCHAR2(2);
  V_IDKARDEX     NUMBER;
  C_CODCLIENTEIB NUMBER;
  V_EXIST        NUMBER;

  CURSOR IMPORT_RENOV_CONT IS
     SELECT F.ADMPV_COD_CLI,
             F.ADMPD_FEC_REN,
             F.ADMPN_COD_CONTR,
             F.ADMPD_FEC_OPER,
             F.ADMPV_NOM_ARCH,
             F.ADMPV_NUM_FONO
      FROM PCLUB.ADMPT_TMP_RENCONT_CC F
      WHERE F.ADMPD_FEC_OPER= K_FECHAOPER
      AND (ADMPV_MSJE_ERROR IS NULL OR ADMPV_MSJE_ERROR = '');

  BEGIN
  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_RENCONT_CC
     SET ADMPC_COD_ERROR  = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = ''
      OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_RENCONT_CC
     SET ADMPC_COD_ERROR  = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

   UPDATE PCLUB.ADMPT_TMP_RENCONT_CC TR
     SET ADMPC_COD_ERROR  = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TR.ADMPV_COD_CLI);

  COMMIT;
  ---Asignar el concepto ------
  BEGIN
    SELECT NVL(ADMPV_COD_CPTO, NULL)
      INTO V_CODCONCEPTO
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE UPPER(ADMPV_DESC) LIKE '%RENOVACION DE CONTRAT%';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_CODCONCEPTO := null;
  END;

  BEGIN
    SELECT TO_NUMBER(ADMPV_VALOR)
      INTO C_PUNTOS
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE UPPER(ADMPV_DESC) = 'PUNTOS_RENOVACION_CONTRATO';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_PARAMETRO;
  END;

  OPEN IMPORT_RENOV_CONT;
  FETCH IMPORT_RENOV_CONT

    INTO C_CODCLIENTE, C_FECHA_RE, COD_CONTR, C_FECOPER, C_NOMARCHIVO,C_FONO;

  WHILE IMPORT_RENOV_CONT %FOUND LOOP

    V_REGCLI := 0;

    SELECT COUNT(1)
      INTO V_REGCLI
      FROM PCLUB.ADMPT_AUX_RENCONT_CC D
      WHERE D.ADMPV_COD_CLI = C_CODCLIENTE
       AND  D.ADMPD_FEC_REN = C_FECHA_RE
       AND D.ADMPN_COD_CONTR = COD_CONTR
       AND D.ADMPD_FEC_OPER = C_FECOPER
       AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO;

    IF (V_REGCLI = 0) THEN
      BEGIN

        IF C_PUNTOS < 0 THEN
          V_TIPOP := 'S';
          C_SALDO := 0.00;
        ELSE
          V_TIPOP := 'E';
          C_SALDO := C_PUNTOS;
        END IF;

        /* Se obtiene el codigo de cliente IB*/
        BEGIN
          SELECT NVL(ADMPN_COD_CLI_IB, NULL)
            INTO C_CODCLIENTEIB
            FROM PCLUB.ADMPT_CLIENTEIB
           WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';
        EXCEPTION
          WHEN NO_DATA_FOUND then
            C_CODCLIENTEIB := null;
        END;

        IF C_PUNTOS <> 0 THEN
          /* genera secuencial de kardex*/
          SELECT PCLUB.admpt_kardex_sq.NEXTVAL
            INTO V_IDKARDEX
            FROM DUAL;

          INSERT INTO PCLUB.ADMPT_KARDEX
            (ADMPN_ID_KARDEX,
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
          VALUES
            (V_IDKARDEX,
             C_CODCLIENTEIB,
             C_CODCLIENTE,
             V_CODCONCEPTO,
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
             C_PUNTOS,
             C_NOMARCHIVO,
             V_TIPOP,
             'C',
             C_SALDO,
             'A');


        BEGIN
          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                 SET ADMPN_SALDO_CC =  ADMPN_SALDO_CC + C_PUNTOS
           WHERE ADMPV_COD_CLI = C_CODCLIENTE;
        END;

        END IF;

        -- Insertamos en la auxiliar para los reprocesos
        INSERT INTO PCLUB.ADMPT_AUX_RENCONT_CC
          (ADMPV_COD_CLI,
           ADMPD_FEC_REN,
           ADMPN_COD_CONTR,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH)
        VALUES
          (C_CODCLIENTE, C_FECHA_RE, COD_CONTR, C_FECOPER, C_NOMARCHIVO);
        END;
    END IF;

	BEGIN

          SELECT NVL(COUNT(*),0) INTO V_EXIST
          FROM ADMPT_SMS_TELEFONOS
          WHERE ADMPV_TELEFONO=C_FONO
          AND ADMPV_USUARIO_REG = 'USRCONT'
          AND ADMPV_NOMBRE_PROCESO = 'RENOCONT'
          AND ADMPV_FECHA_REG>=TRUNC(SYSDATE);

          IF V_EXIST = 0 THEN
            INSERT INTO ADMPT_SMS_TELEFONOS
            (ADMPV_TELEFONO,ADMPC_ESTADO,ADMPV_NOMBRE_PROCESO,ADMPV_USUARIO_REG,ADMPV_FECHA_REG)
            VALUES
            (C_FONO,'R','RENOCONT','USRCONT',SYSDATE);
          END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
        WHEN OTHERS THEN
        NULL;
    END;

    --COMMIT;

    FETCH IMPORT_RENOV_CONT
      INTO C_CODCLIENTE, C_FECHA_RE, COD_CONTR, C_FECOPER, C_NOMARCHIVO, C_FONO;


  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT(1)
    INTO K_NUMREGTOT
    FROM PCLUB.ADMPT_TMP_RENCONT_CC
   WHERE ADMPD_FEC_OPER = K_FECHAOPER; --TOTALES

  SELECT COUNT(1)
    INTO K_NUMREGERR
    FROM PCLUB.ADMPT_TMP_RENCONT_CC
   WHERE ADMPD_FEC_OPER = K_FECHAOPER
     AND (admpc_cod_error Is Not null); -- PROCESADOS

  SELECT COUNT(1)
    INTO K_NUMREGPRO
    FROM PCLUB.ADMPT_AUX_RENCONT_CC
   WHERE ADMPD_FEC_OPER = K_FECHAOPER; -- CON ERROR

  -- Insertamos de la tabla temporal a la final de importacion
  INSERT INTO PCLUB.ADMPT_IMP_RENCONT_CC
    SELECT PCLUB.ADMPT_RENCONT_SQ.NEXTVAL,
           v.admpv_cod_cli,
           v.admpd_fec_ren,
           v.admpn_cod_contr,
           v.admpd_fec_oper,
           v.admpv_nom_arch,
           v.admpc_cod_error,
           v.admpv_msje_error,
           v.admpn_seq,
           sysdate,
           v.ADMPV_NUM_FONO           -- Se agrega 23122010
     FROM PCLUB.ADMPT_TMP_RENCONT_CC v
     WHERE V.ADMPD_FEC_OPER = K_FECHAOPER;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_RENCONT_CC WHERE ADMPD_FEC_OPER = K_FECHAOPER;
  DELETE PCLUB.ADMPT_TMP_RENCONT_CC WHERE ADMPD_FEC_OPER = K_FECHAOPER;

  COMMIT;

  K_CODERROR  := '0';
  K_DESCERROR := '';

EXCEPTION
  WHEN NO_PARAMETRO THEN
    K_CODERROR  := 56;
    K_DESCERROR := 'No se tiene registrado el parametro de entrega de Puntos por Renovacion por Contrato (RENOVACION POR CONTRATO).';

  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_RENCONTC;

PROCEDURE ADMPSI_ERENCONTC(K_FECHAPROC   IN DATE,
                                             CURSORRENCONT out SYS_REFCURSOR) is
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ERENCONTC
  -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Renovacion de Contratos
  -- Input               :  K_FECHAPROC
  -- Output              :  CURSORRENVCONT
  -- Fec Creación        :  18/10/2010
  -- Fec Actualización   :
  --****************************************************************
BEGIN
  OPEN CURSORRENCONT FOR
    SELECT C.ADMPV_COD_CLI,
           C.ADMPD_FEC_REN,
           C.ADMPV_NUM_FONO,           -- Se agrega 23122010
           C.ADMPN_COD_CONTR,
           C.ADMPD_FEC_OPER,
           C.ADMPV_NOM_ARCH,
           TRIM(ADMPC_COD_ERROR),
           C.ADMPV_MSJE_ERROR
      FROM PCLUB.ADMPT_IMP_RENCONT_CC C
     WHERE ADMPD_FEC_OPER = K_FECHAPROC
       AND ADMPC_COD_ERROR IS NOT NULL
       AND TRIM(ADMPV_MSJE_ERROR) <> ' '
     ORDER BY ADMPN_SEQ ASC;

END ADMPSI_ERENCONTC;

PROCEDURE ADMPSI_BAJACLIC(K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_BAJACLIC
-- Propósito           :  Actualizar los saldos de los clientes que se dieron de baja
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creaci?n        :  14/10/2010
-- Fec Actualizaci?n   :  22/12/2010 - Stiven Saavedra
--****************************************************************

vUSER VARCHAR2(10) :='USRSHBAJA';
V_REGCLI NUMBER;
C_FECOPER DATE;
C_NOMARCHIVO VARCHAR2(150);
C_CODCLIENTE VARCHAR2(40);
V_SALDO_CC NUMBER;
V_SALDO_IB NUMBER;
V_CODCONCEPTO VARCHAR2(2);
V_IDKARDEX NUMBER;
C_FECBAJA DATE;
V_SALDO_NUEVO VARCHAR2(40);
V_CLIENTE_AUX VARCHAR2(40);
V_CONT_IB NUMBER;
V_COD_CLI_IB NUMBER;

/*CUPONERAVIRTUAL - JCGT INI*/
  C_CODERROR NUMBER;
  C_DESCERROR VARCHAR2(200);
  K_TIPODOC VARCHAR2(20);
  K_NUMDOC VARCHAR2(20);
  C_COD_CLICUP NUMBER;
/*CUPONERAVIRTUAL - JCGT FIN*/

CURSOR BAJA_CLIENTES IS
  SELECT a.ADMPV_COD_CLI,
         a.admpd_fch_baja,
         a.ADMPD_FEC_OPER,
         a.ADMPV_NOM_ARCH
  FROM PCLUB.ADMPT_TMP_BAJACLI_CC a
  WHERE a.ADMPD_FEC_OPER=K_FECHA
        AND (a.ADMPC_COD_ERROR IS NULL or a.ADMPC_COD_ERROR='');

 BEGIN

 -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_BAJACLI_CC
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_BAJACLI_CC
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede dar de baja.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

   UPDATE PCLUB.ADMPT_TMP_BAJACLI_CC TB
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede dar de baja.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TB.ADMPV_COD_CLI );

  COMMIT;

  BEGIN
    -- Obtenemos el codigo del Concepto
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%BAJA CLIENTES%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  OPEN BAJA_CLIENTES;
  FETCH BAJA_CLIENTES INTO C_CODCLIENTE,C_FECBAJA,C_FECOPER, C_NOMARCHIVO;
  WHILE BAJA_CLIENTES %FOUND LOOP

     V_REGCLI :=0;
     V_SALDO_CC := 0;
     V_SALDO_IB := 0;
     V_COD_CLI_IB := NULL;

     SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.Admpt_Aux_Bajacli_Cc B
     WHERE B.ADMPV_COD_CLI = C_CODCLIENTE
           AND B.ADMPD_FCH_BAJA = C_FECBAJA
           AND B.ADMPD_FEC_OPER = C_FECOPER
           AND NVL(B.ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

     IF (V_REGCLI=0) THEN
        BEGIN

          -- SSC 22122010 - Verificamos si el cliente es IB
          BEGIN
             V_CONT_IB := 0;
             SELECT COUNT (1) INTO V_CONT_IB
               FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';

              IF V_CONT_IB > 0 THEN
                 BEGIN
                   V_COD_CLI_IB := NULL;

                   SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
                     FROM PCLUB.ADMPT_CLIENTEIB
                    WHERE ADMPV_COD_CLI = C_CODCLIENTE and admpc_estado='A';

                     EXCEPTION WHEN NO_DATA_FOUND THEN V_COD_CLI_IB := null;
                 END;
              END IF;
          END;

          -- SSC 22122010 - Si el cliente tiene mas de una cuenta los puntos pasan a su otra cuenta
          BEGIN
             V_CLIENTE_AUX := NULL;
             SELECT MIN (ADMPV_COD_CLI) INTO V_CLIENTE_AUX
              FROM PCLUB.ADMPT_CLIENTE,
                   (SELECT TRIM (AUX.ADMPV_TIPO_DOC) AS TIPO_DOC, TRIM (AUX.ADMPV_NUM_DOC) AS NUM_DOC
                      FROM PCLUB.ADMPT_CLIENTE AUX
                     WHERE AUX.ADMPV_COD_CLI = C_CODCLIENTE AND
                           AUX.ADMPV_COD_TPOCL IN ('1', '2') AND
                           AUX.ADMPC_ESTADO = 'A') TD
             WHERE ADMPV_COD_CLI <> C_CODCLIENTE AND
                   ADMPV_TIPO_DOC = TD.TIPO_DOC AND
                   ADMPV_NUM_DOC = TD.NUM_DOC AND
                   ADMPV_COD_TPOCL IN ('1', '2') AND
                   ADMPC_ESTADO = 'A';

             EXCEPTION
                WHEN NO_DATA_FOUND THEN V_CLIENTE_AUX := null;
          END;

          IF V_CLIENTE_AUX IS NULL THEN -- No tiene otra cuenta Postpago
             BEGIN
                IF V_CONT_IB > 0 THEN
                   BEGIN
                      --Se obtiene el saldo del cliente
                      BEGIN
                        SELECT NVL(ADMPN_SALDO_IB,NULL)
                          INTO V_SALDO_IB
                          FROM PCLUB.ADMPT_SALDOS_CLIENTE
                         WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                             EXCEPTION
                               WHEN NO_DATA_FOUND THEN V_SALDO_IB := 0;
                      END;

                      -- Actualizamos la tabla de ClienteIB rompiendo la relacion con Cliente CC
                      UPDATE PCLUB.ADMPT_CLIENTEIB I
                         SET I.ADMPV_COD_CLI = NULL
                       WHERE I.ADMPN_COD_CLI_IB = V_COD_CLI_IB;

                      -- Actualizamos los movimientos que tienen saldo y son IB
                      UPDATE PCLUB.ADMPT_KARDEX
                         SET ADMPV_COD_CLI = NULL
                       WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB AND
                             ADMPC_TPO_PUNTO = 'I' AND
                             ADMPN_SLD_PUNTO > 0 AND
                             ADMPC_TPO_OPER = 'E';

                      -- Ahora insertamos el registro del saldo del cliente IB
                      INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB)
                      VALUES (ADMPT_SLD_CL_SQ.NEXTVAL,NULL,V_COD_CLI_IB,0,V_SALDO_IB,NULL,'A');

                   END;
                END IF;

                BEGIN
                    --Se obtiene el saldo del cliente
                    BEGIN
                      SELECT NVL(SUM(ADMPN_SLD_PUNTO),NULL)
                        INTO V_SALDO_CC
                        FROM PCLUB.ADMPT_KARDEX
                      WHERE ADMPV_COD_CLI = C_CODCLIENTE AND
                      ADMPC_TPO_PUNTO IN('C','L')
                      AND ADMPN_SLD_PUNTO <> 0
                      AND ADMPC_TPO_OPER = 'E';

                       EXCEPTION WHEN NO_DATA_FOUND THEN V_SALDO_CC := 0;
                    END;
                    V_SALDO_NUEVO := V_SALDO_CC * -1;

                    IF V_SALDO_NUEVO < 0 THEN
                    /* genera secuencial de kardex*/
                          SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;
                    -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                       INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                          ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                          ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, 
                                                          ADMPD_FEC_REG, ADMPV_USU_REG)
                          VALUES(V_IDKARDEX, NULL, C_CODCLIENTE, V_CODCONCEPTO,
                                 TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_NUEVO, C_NOMARCHIVO, 'S', 'C', 0, 'A',
                                   SYSDATE, vUSER);

                        -- ACTUALIZAMOS LOS SALDOS A 0 DE LOS REGISTROS DEL KARDEX SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
                        UPDATE PCLUB.ADMPT_KARDEX
                        SET ADMPN_SLD_PUNTO = 0, 
                        ADMPD_FEC_MOD = SYSDATE,
                        ADMPV_USU_MOD = vUSER,
                        ADMPN_ID_KRDX_VTO = V_IDKARDEX,
                        ADMPN_ULTM_SLD_PTO = ADMPN_SLD_PUNTO
                        WHERE ADMPV_COD_CLI = C_CODCLIENTE AND
                        ADMPC_TPO_PUNTO IN('C','L')
                        AND ADMPN_SLD_PUNTO > 0
                        AND ADMPC_TPO_OPER = 'E';

                    END IF;
                        -- ACTUALIZAMOS EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
                        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                           SET S.ADMPN_SALDO_CC = 0,
                               S.ADMPN_SALDO_IB = 0,
                               S.ADMPN_COD_CLI_IB = NULL
                         WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                        -- ACTUALIZAMOS LA TABLA CLIENTE CON EL ESTADO 'B'
                        UPDATE PCLUB.ADMPT_CLIENTE C
                        SET C.ADMPC_ESTADO = 'B'
                        WHERE C.ADMPV_COD_CLI = C_CODCLIENTE;
                END;
             END;
          ELSE
             -- SSC 22122010 Si el cliente tiene otras cuentas
             BEGIN
                IF V_CONT_IB > 0 THEN
                   BEGIN
                      --Se obtiene el saldo del cliente
                      BEGIN
                        SELECT NVL(ADMPN_SALDO_IB,NULL)
                          INTO V_SALDO_IB
                          FROM PCLUB.ADMPT_SALDOS_CLIENTE
                         WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                             EXCEPTION
                               WHEN NO_DATA_FOUND THEN V_SALDO_IB := 0;
                      END;

                      -- Actualizamos la tabla de ClienteIB rompiendo la relacion con Cliente CC
                      UPDATE PCLUB.ADMPT_CLIENTEIB I
                         SET I.ADMPV_COD_CLI = V_CLIENTE_AUX
                       WHERE I.ADMPN_COD_CLI_IB = V_COD_CLI_IB;

                      -- Actualizamos los movimientos que tienen saldo y son IB
                      UPDATE PCLUB.ADMPT_KARDEX
                         SET ADMPV_COD_CLI = V_CLIENTE_AUX
                       WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB AND
                             ADMPC_TPO_PUNTO = 'I' AND
                             ADMPN_SLD_PUNTO > 0 AND
                             ADMPC_TPO_OPER = 'E';

                      -- ACTUALIZAMOS EL SALDO IB CON LA OTRA CUENTA DEL CLIENTE
                      UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                         SET S.ADMPN_SALDO_IB = V_SALDO_IB,
                             S.ADMPC_ESTPTO_IB = 'A',
                             S.ADMPN_COD_CLI_IB = V_COD_CLI_IB
                       WHERE ADMPV_COD_CLI = V_CLIENTE_AUX;
                   END;      -- Fin de Bloque si es ClienteIB
                END IF;

                BEGIN
                    --Se obtiene el saldo del cliente
                    BEGIN
                      SELECT NVL(SUM(ADMPN_SLD_PUNTO),NULL)
                        INTO V_SALDO_CC
                        FROM PCLUB.ADMPT_KARDEX
                       WHERE ADMPV_COD_CLI = C_CODCLIENTE AND
                      ADMPC_TPO_PUNTO IN('C','L')
                      AND ADMPN_SLD_PUNTO <> 0
                      AND ADMPC_TPO_OPER = 'E';

                       EXCEPTION WHEN NO_DATA_FOUND THEN V_SALDO_CC := 0;
                    END;
                    V_SALDO_NUEVO := V_SALDO_CC * -1;

                    IF V_SALDO_NUEVO < 0 THEN
                       /* genera secuencial de kardex*/
                       SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

                       -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                       INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                          ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                          ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, 
                                                            ADMPD_FEC_REG, ADMPV_USU_REG)
                          VALUES(V_IDKARDEX, NULL, C_CODCLIENTE, V_CODCONCEPTO,
                                 TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_NUEVO, C_NOMARCHIVO, 'S', 'C', 0, 'A',
                                   SYSDATE, vUSER);

                        -- ACTUALIZAMOS LOS SALDOS A 0 DE LOS REGISTROS DEL KARDEX SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
                       UPDATE PCLUB.ADMPT_KARDEX
                          SET ADMPN_SLD_PUNTO = 0, 
                          ADMPD_FEC_MOD = SYSDATE,
                          ADMPV_USU_MOD = vUSER,
                          ADMPN_ID_KRDX_VTO = V_IDKARDEX,
                          ADMPN_ULTM_SLD_PTO = ADMPN_SLD_PUNTO
                        WHERE ADMPV_COD_CLI = C_CODCLIENTE
                              AND ADMPC_TPO_PUNTO IN('C','L')
                              AND ADMPN_SLD_PUNTO > 0
                              AND ADMPC_TPO_OPER = 'E';



                         -- Ahora Insertamos el movimiento de ingreso para la otra cuenta
                         SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

                         -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                         INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                            ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                            ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO, 
                                                            ADMPD_FEC_REG, ADMPV_USU_REG)
                            VALUES(V_IDKARDEX, V_COD_CLI_IB, V_CLIENTE_AUX, V_CODCONCEPTO,
                                   TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_CC, NULL, 'E', 'C', V_SALDO_CC, 'A',
                                   SYSDATE, vUSER);

                         -- ACTUALIZAMOS EL SALDO CC DE LA OTRA CUENTA DEL CLIENTE
                          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                             SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + NVL (V_SALDO_CC, 0)
                           WHERE ADMPV_COD_CLI = V_CLIENTE_AUX;

                         -- Los registros de la otra cuenta deben ser actualizados con el código ib
                           UPDATE PCLUB.ADMPT_KARDEX
                              SET ADMPN_COD_CLI_IB = V_COD_CLI_IB
                            WHERE ADMPV_COD_CLI = V_CLIENTE_AUX
                                  AND ADMPC_TPO_PUNTO IN ('C','L')
                                  AND ADMPN_SLD_PUNTO > 0
                                  AND ADMPC_TPO_OPER = 'E';

                    END IF;

                        -- ACTUALIZAMOS EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
                        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                           SET S.ADMPN_SALDO_CC = 0,
                               S.ADMPN_SALDO_IB = 0,
                               S.ADMPN_COD_CLI_IB = NULL
                         WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                        -- ACTUALIZAMOS LA TABLA CLIENTE CON EL ESTADO 'B'
                        UPDATE PCLUB.ADMPT_CLIENTE C
                           SET C.ADMPC_ESTADO = 'B'
                         WHERE C.ADMPV_COD_CLI = C_CODCLIENTE;

                END;

             END;
          END IF;

           -- Insertamos en la auxiliar para los reprocesos
           INSERT INTO PCLUB.ADMPT_AUX_BAJACLI_CC(ADMPV_COD_CLI,ADMPD_FCH_BAJA,ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
           VALUES(C_CODCLIENTE,C_FECBAJA,C_FECOPER, C_NOMARCHIVO);

            BEGIN

            SELECT C.ADMPV_TIPO_DOC,C.ADMPV_NUM_DOC INTO K_TIPODOC,K_NUMDOC
            FROM ADMPT_CLIENTE C
            WHERE C.ADMPV_COD_CLI=C_CODCLIENTE;

               /*CUPONERAVIRTUAL - JCGT INI*/
               PCLUB.PKG_CC_CUPONERA.ADMPSI_BAJACLIENTE(K_TIPODOC,K_NUMDOC,'BAJA','USRPOST',C_COD_CLICUP,C_CODERROR,C_DESCERROR);
              /*CUPONERAVIRTUAL - JCGT FIN*/

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
                    C_CODERROR:= SQLCODE;
                    C_DESCERROR:= SUBSTR(SQLERRM,1,200);
           WHEN OTHERS THEN
                    C_CODERROR:= SQLCODE;
                    C_DESCERROR:= SUBSTR(SQLERRM,1,200);
           END;

        END;
     END IF;

     --COMMIT;

     FETCH BAJA_CLIENTES INTO C_CODCLIENTE,C_FECBAJA,C_FECOPER, C_NOMARCHIVO;

  END LOOP;

 -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_BAJACLI_CC WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_BAJACLI_CC WHERE ADMPD_FEC_OPER=K_FECHA AND (ADMPC_COD_ERROR Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_BAJACLI_CC WHERE (admpd_fec_oper=K_FECHA);

 -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_BAJACLI_CC
  SELECT PCLUB.admpt_baja_sq.nextval,
         ADMPV_COD_CLI,
         ADMPD_FCH_BAJA,
         ADMPD_FEC_OPER,
         ADMPV_NOM_ARCH,
         ADMPC_COD_ERROR,
         ADMPV_MSJE_ERROR,
         SYSDATE,
         ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_BAJACLI_CC
   WHERE admpd_fec_oper=K_FECHA;

   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_BAJACLI_CC WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_BAJACLI_CC  WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

  K_CODERROR:= 0;
  K_DESCERROR:= '';

  EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);


END ADMPSI_BAJACLIC;

PROCEDURE ADMPSI_EBAJACLIC(K_FECHAPROC IN DATE, CURSORBAJACLI out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EBAJACLIC
-- Propósito           :  Devuelve en un cursor solo los registros con errores encontrados en el proceso de Baja de Clientes.
-- Input               :  K_FECHAPROC
-- Output              :  CURSORBAJACLI
-- Fec Creación        :  15/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORBAJACLI FOR
SELECT TRIM(ADMPV_COD_CLI), TO_DATE(ADMPD_FCH_BAJA, 'DD/MM/YYYY'),
       TRIM(ADMPC_COD_ERROR),ADMPV_MSJE_ERROR
FROM PCLUB.ADMPT_IMP_BAJACLI_CC
WHERE ADMPD_FEC_OPER=K_FECHAPROC
AND ADMPC_COD_ERROR IS NOT NULL
AND TRIM (ADMPV_MSJE_ERROR) <> ' '
ORDER BY ADMPN_SEQ ASC;

END ADMPSI_EBAJACLIC;

PROCEDURE ADMPSI_NOFACTC(K_FECHAPROCESO IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_NOFACTC
-- Propósito           :  Actualizar los saldos de los clientes que no facturaron
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creaci?n        :  14/10/2010
-- Fec Actualizaci?n   :
--****************************************************************


V_REGCLI       NUMBER;
C_FECOPER      DATE;
C_NOMARCHIVO   VARCHAR2(150);
C_CODCLIENTE   VARCHAR2(40);
C_PUNTOS       NUMBER;
V_SALDO_CC     NUMBER;
V_CODCONCEPTO  VARCHAR2(2);
V_IDKARDEX     NUMBER;
C_FECPROC      DATE;
V_SALDO_NUEVO  VARCHAR2(40);
C_CODCLIENTEIB NUMBER;
V_ESTADO_PTO   CHAR (1);

CURSOR NO_FACTURACION IS
  SELECT a.ADMPV_COD_CLI,
         a.admpd_fch_proc,
         a.ADMPD_FEC_OPER,
         a.ADMPV_NOM_ARCH
  FROM PCLUB.ADMPT_TMP_NOFACT_CC a
  WHERE a.ADMPD_FEC_OPER=K_FECHAPROCESO
        AND (a.ADMPC_COD_ERROR IS NULL or a.ADMPC_COD_ERROR='');

 BEGIN

 -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_NOFACT_CC
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_NOFACT_CC
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede quitar los puntos.'
   WHERE ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE);*/

   UPDATE PCLUB.ADMPT_TMP_NOFACT_CC TN
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede quitar los puntos.'
   WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TN.ADMPV_COD_CLI);

  COMMIT;

  BEGIN
    -- Obtenemos el codigo del Concepto
    SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
    FROM PCLUB.ADMPT_CONCEPTO
    WHERE UPPER(ADMPV_DESC) LIKE '%NO FACTURADOS CC%';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_CODCONCEPTO := null;
  END;

  OPEN NO_FACTURACION;
  FETCH NO_FACTURACION INTO C_CODCLIENTE,C_FECPROC,C_FECOPER, C_NOMARCHIVO;

WHILE NO_FACTURACION %FOUND LOOP

     V_REGCLI :=0;
     C_PUNTOS :=0;
     C_CODCLIENTEIB := NULL;

     SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.Admpt_Aux_Nofact_Cc B
     WHERE B.ADMPV_COD_CLI = C_CODCLIENTE
           AND B.ADMPD_FCH_PROC = C_FECPROC
           AND B.ADMPD_FEC_OPER = C_FECOPER
           AND NVL(B.ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

       IF (V_REGCLI=0) THEN
          BEGIN

            --Se obtiene el saldo del cliente
            BEGIN
              SELECT NVL(ADMPN_SALDO_CC,NULL) INTO V_SALDO_CC
                    FROM PCLUB.ADMPT_SALDOS_CLIENTE
                   WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                   EXCEPTION
                     WHEN NO_DATA_FOUND
                       THEN V_SALDO_CC := 0;
            END;

            IF V_SALDO_CC < 0 THEN
               V_SALDO_NUEVO := V_SALDO_CC;
               V_ESTADO_PTO  := 'E';
            ELSE
               V_SALDO_NUEVO := V_SALDO_CC * -1;
               V_ESTADO_PTO  := 'S';
            END IF;

            /* genera secuencial de kardex*/
            SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

            -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
             INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                VALUES(V_IDKARDEX, C_CODCLIENTEIB, C_CODCLIENTE, V_CODCONCEPTO,
                       TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_NUEVO, C_NOMARCHIVO, V_ESTADO_PTO, 'C', C_PUNTOS, 'A');

            -- ACTUALIZAMOS LOS SALDOS A 0 DE LOS REGISTROS DEL KARDEX SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
           UPDATE PCLUB.ADMPT_KARDEX
            SET ADMPN_SLD_PUNTO = C_PUNTOS
            WHERE ADMPV_COD_CLI = C_CODCLIENTE AND
            ADMPC_TPO_PUNTO IN('C','L')
            AND ADMPN_SLD_PUNTO > 0
            AND ADMPC_TPO_OPER = 'E';

            -- ACTUALIZAMOS EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
            SET S.ADMPN_SALDO_CC = C_PUNTOS
            WHERE ADMPV_COD_CLI = C_CODCLIENTE;

             -- Insertamos en la auxiliar para los reprocesos
             INSERT INTO PCLUB.ADMPT_AUX_NOFACT_CC(ADMPV_COD_CLI,ADMPD_FCH_PROC,ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
             VALUES(C_CODCLIENTE,C_FECPROC,C_FECOPER, C_NOMARCHIVO);
          END;
       END IF;

     --COMMIT;

FETCH NO_FACTURACION INTO C_CODCLIENTE,C_FECPROC,C_FECOPER, C_NOMARCHIVO;

END LOOP;

 -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.Admpt_Tmp_Nofact_Cc WHERE ADMPD_FEC_OPER=K_FECHAPROCESO;
  SELECT COUNT (1) INTO K_NUMREGERR FROM PCLUB.Admpt_Tmp_Nofact_Cc WHERE ADMPD_FEC_OPER=K_FECHAPROCESO AND (ADMPC_COD_ERROR Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.Admpt_Aux_Nofact_Cc WHERE (admpd_fec_oper=K_FECHAPROCESO);

 -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_NOFACT_CC
  SELECT PCLUB.admpt_nofac_sq.nextval,
         ADMPV_COD_CLI,
         ADMPD_FCH_PROC,
         ADMPD_FEC_OPER,
         ADMPV_NOM_ARCH,
         ADMPC_COD_ERROR,
         ADMPV_MSJE_ERROR,
         SYSDATE,
         ADMPN_SEQ
    FROM PCLUB.ADMPT_TMP_NOFACT_CC
   WHERE admpd_fec_oper=K_FECHAPROCESO;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_NOFACT_CC WHERE ADMPD_FEC_OPER=K_FECHAPROCESO;
  DELETE PCLUB.ADMPT_TMP_NOFACT_CC WHERE ADMPD_FEC_OPER=K_FECHAPROCESO;

  COMMIT;

  K_CODERROR:= 0;
  K_DESCERROR:= '';

  EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);


END ADMPSI_NOFACTC;

PROCEDURE ADMPSI_ENOFACTC(K_FECHAPROC IN DATE, CURSORNOFACT out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ENOFACTC
-- Propósito           :  Devuelve en un cursor solo los registros con errores encontrados en el proceso de No facturados.
-- Input               :  K_FECHAPROC
-- Output              :  CURSORNOFACT
-- Fec Creación        :  15/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORNOFACT FOR
SELECT TRIM(ADMPV_COD_CLI), TO_DATE(ADMPD_FCH_PROC,'DD/MM/YYYY'),
       TRIM(ADMPC_COD_ERROR),ADMPV_MSJE_ERROR
FROM PCLUB.Admpt_Imp_Nofact_Cc
WHERE ADMPD_FEC_OPER=K_FECHAPROC
AND ADMPC_COD_ERROR IS NOT NULL
AND TRIM (ADMPV_MSJE_ERROR) <> ' '
ORDER BY ADMPN_SEQ ASC;

END ADMPSI_ENOFACTC;

PROCEDURE ADMPSI_PRXRCONC(K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_PRXRCONC
-- Propósito           :  Calcular el monto por Descuento de Equipo de los Clientes indicados por Claro
                          /*Importación de los datos de los clientes Claro próximos a renovar el contrato*/
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Fec Creación        :  07/09/2010
-- Fec Actualización   :
--****************************************************************

V_REGCLI NUMBER;
C_TIPO  CHAR (1);
C_NOMARCHIVO VARCHAR2(150);
C_CONTRATO NUMBER;
C_CODCLIENTE VARCHAR2(40);
 CURSOR PROXREN_CONT IS
  SELECT a.ADMPV_COD_CLI,
         a.ADMPC_TIP,
         a.ADMPN_COD_CONTR,
         a.ADMPV_NOM_ARCH
  FROM PCLUB.ADMPT_TMP_PRXRCON_CC a
  WHERE a.ADMPD_FEC_OPER=K_FECHA
        AND (a.ADMPC_COD_ERROR IS NULL or a.ADMPC_COD_ERROR='');

BEGIN

  -- Solo podemos validar si el cliente existe
  /*UPDATE PCLUB.ADMPT_TMP_PRXRCON_CC
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND
         ADMPV_COD_CLI NOT IN (SELECT ADMPV_COD_CLI FROM ADMPT_CLIENTE);*/

  UPDATE PCLUB.ADMPT_TMP_PRXRCON_CC TP
     SET ADMPC_COD_ERROR = '16',
         ADMPV_MSJE_ERROR = 'El cliente no existe, no se le puede entregar puntos.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND
          NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=TP.ADMPV_COD_CLI);

  -- Solo podemos validar si el cliente existe
  UPDATE PCLUB.ADMPT_TMP_PRXRCON_CC
     SET ADMPC_COD_ERROR = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPD_FEC_OPER=K_FECHA AND
         ( ADMPV_COD_CLI Is Null OR ADMPV_COD_CLI = '');

  COMMIT;

  OPEN PROXREN_CONT;
  FETCH PROXREN_CONT INTO C_CODCLIENTE, C_TIPO, C_CONTRATO, C_NOMARCHIVO;

  WHILE PROXREN_CONT %FOUND LOOP

         V_REGCLI :=0;

         SELECT COUNT(1) INTO V_REGCLI FROM PCLUB.ADMPT_AUX_PRXRCON_CC
         WHERE ADMPV_COD_CLI = C_CODCLIENTE
               AND ADMPC_TIP = C_TIPO
               AND ADMPN_COD_CONTR = C_CONTRATO
               AND ADMPD_FEC_OPER=K_FECHA
               AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO;

         IF (V_REGCLI=0) THEN
            BEGIN
              -- Insertamos en la auxiliar para los reprocesos
              INSERT INTO PCLUB.ADMPT_AUX_PRXRCON_CC
                (ADMPV_COD_CLI, ADMPC_TIP, ADMPN_COD_CONTR, ADMPD_FEC_OPER, ADMPV_NOM_ARCH)
              VALUES
                (C_CODCLIENTE, C_TIPO, C_CONTRATO, K_FECHA, C_NOMARCHIVO);

            END;
         END IF;

        --COMMIT;

      FETCH PROXREN_CONT INTO C_CODCLIENTE, C_TIPO, C_CONTRATO, C_NOMARCHIVO;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (1) INTO K_NUMREGTOT FROM ADMPT_TMP_PRXRCON_CC WHERE ADMPD_FEC_OPER=K_FECHA;
  SELECT COUNT (1) INTO K_NUMREGERR FROM ADMPT_TMP_PRXRCON_CC WHERE ADMPD_FEC_OPER=K_FECHA AND (admpc_cod_error Is Not null);
  SELECT COUNT (1) INTO K_NUMREGPRO FROM ADMPT_AUX_PRXRCON_CC WHERE (admpd_fec_oper=K_FECHA);

  -- Insertamos de la tabla temporal a la final

  INSERT INTO PCLUB.ADMPT_IMP_PRXRCON_CC
    SELECT PCLUB.ADMPT_PRXRCON_SQ.nextval,
           V.ADMPV_COD_CLI,
           V.ADMPC_TIP,
           V.ADMPN_COD_CONTR,
           V.ADMPD_FEC_OPER,
           V.ADMPV_NOM_ARCH,
           V.ADMPC_COD_ERROR,
           V.ADMPV_MSJE_ERROR,
           v.admpn_seq,
           SYSDATE
      FROM PCLUB.ADMPT_TMP_PRXRCON_CC v
     WHERE V.ADMPD_FEC_OPER = K_FECHA;



   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.ADMPT_AUX_PRXRCON_CC WHERE ADMPD_FEC_OPER=K_FECHA;
   DELETE PCLUB.ADMPT_TMP_PRXRCON_CC WHERE ADMPD_FEC_OPER=K_FECHA;

  COMMIT;

  K_CODERROR:= 0;
  K_DESCERROR:= '';

  EXCEPTION
   WHEN OTHERS THEN
     K_CODERROR:=SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_PRXRCONC;

PROCEDURE ADMPSI_EPRXRCONC(K_FECHAPROC IN DATE, CURSORPROXR out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EPRXRCONC
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Renovacion Especial (proxima)
-- Input               :  K_FECHAPROC
-- Output              :  CURSORPROXR
-- Fec Creación        :  27/09/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORPROXR FOR
SELECT TRIM (ADMPV_COD_CLI), ADMPC_TIPO, ADMPN_COD_CONTR, TRIM (ADMPC_COD_ERROR), ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_PRXRCON_CC
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       ADMPC_COD_ERROR Is Not Null AND
       TRIM (ADMPC_COD_ERROR) <> ' '
 ORDER BY ADMPN_SEQ ASC;

END;

PROCEDURE ADMPSS_PROXRCOC(K_FECHAPROC IN DATE, C_CUR_DATOS_CLIE OUT SYS_REFCURSOR) is
--**************************************************************************************************SP ADMPSS_PROXRCOC
-- Nombre SP           :  ADMPSS_PROXRCOC
-- Propósito           :  Exportación de los datos de los clientes Claro próximas a renovar contrato
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREND
-- Fec Creación        :  27/09/2010 - 21/10/2010 PS.
-- Fec Actualización   :
--***************************************************************************************************


C_CODCLIENTE VARCHAR (40);
C_TIPO       CHAR (1);
C_CONTRATO   NUMBER;
C_SECUENCIA  NUMBER;
C_PUNTOS     NUMBER;
C_EQUIVALEN  NUMBER;
V_SALDO_CC   NUMBER;
V_SALDO_IB   NUMBER;
V_EST_IB     CHAR (1);
C_FECOPER    DATE;
C_NOMARCH    VARCHAR(150);


CURSOR CURSORPROXR IS
SELECT TRIM (ADMPV_COD_CLI), ADMPC_TIPO, ADMPN_COD_CONTR, ADMPN_SEQ, ADMPD_FEC_OPER, ADMPV_NOM_ARCH
  FROM PCLUB.ADMPT_IMP_PRXRCON_CC
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       (ADMPC_COD_ERROR Is Null OR
       TRIM (ADMPC_COD_ERROR)= ' ')
 ORDER BY ADMPN_SEQ ASC;

BEGIN
    -- Los que tienen tipo 0

    OPEN CURSORPROXR;
    FETCH CURSORPROXR INTO C_CODCLIENTE, C_TIPO, C_CONTRATO, C_SECUENCIA, C_FECOPER, C_NOMARCH;
    WHILE CURSORPROXR %FOUND
      LOOP

          -- Para todos se calcula sus saldo de puntos
          BEGIN
            SELECT nvl(admpn_saldo_cc,0), nvl(admpn_saldo_ib,0), admpc_estpto_ib INTO V_SALDO_CC, V_SALDO_IB, V_EST_IB
              FROM PCLUB.admpt_saldos_cliente
             WHERE admpv_cod_cli=C_CODCLIENTE AND admpc_estpto_cc='A';

             EXCEPTION
               WHEN NO_DATA_FOUND
                  THEN
                    BEGIN
                      V_SALDO_CC := 0;
                      V_SALDO_IB := 0;
                    END;
          END;

           IF V_EST_IB = 'A' THEN          -- Cuando se encuentra Activo
             C_PUNTOS := V_SALDO_CC + V_SALDO_IB;
           ELSE
             C_PUNTOS := V_SALDO_CC;
           END IF;

           IF C_TIPO = '0' THEN
              C_EQUIVALEN := 0;
           ELSE
              -- Obtenemos el Descuento de Equipo
              BEGIN
                SELECT MAX (ADMPN_MNTDCTO) INTO C_EQUIVALEN
                 FROM PCLUB.ADMPT_PREMIO
                 WHERE ADMPV_COD_TPOPR = '4' AND
                       SUBSTR (ADMPV_ID_PROCLA, 2, 1) NOT IN ('1','2', '3', '4', '5', '6', '7', '8', '9') AND              -- JBulnes indico que se debe tomar el estandar
                       ADMPN_PUNTOS < C_PUNTOS;

                 EXCEPTION
                   WHEN NO_DATA_FOUND
                      THEN C_EQUIVALEN := 0;
              END;

              IF C_EQUIVALEN Is Null THEN
                C_EQUIVALEN := 0;
              END IF;

           END IF;

           -- Reglas de Negocio
           IF C_TIPO = '1' AND C_EQUIVALEN = 0 AND C_PUNTOS > 10 THEN
              C_TIPO := '0';
           END IF;

           IF (C_TIPO = '0' AND C_PUNTOS > 10) OR (C_PUNTOS > 0 AND C_EQUIVALEN > 0) THEN
              INSERT INTO PCLUB.admpt_exp_proxrco_cc

                (admpn_id_fila, admpv_cod_cli, admpc_tipo, admpn_cod_contr, admpn_puntos, admpn_equiv, ADMPN_SEQ, ADMPD_FEC_OPER, ADMPV_NOM_ARCH)
              VALUES
                ( PCLUB.Admpt_Expproxren_Sq.nextval, C_CODCLIENTE, C_TIPO, C_CONTRATO, C_PUNTOS, C_EQUIVALEN, C_SECUENCIA, C_FECOPER, C_NOMARCH);
              -- COMMIT;

           END IF;

        FETCH CURSORPROXR INTO C_CODCLIENTE, C_TIPO, C_CONTRATO, C_SECUENCIA, C_FECOPER, C_NOMARCH;
      END LOOP;

      -- Si el proceso completo culminó correctamente (sin errores de BD) se debe retornar los siguientes campos de la tabla--------------

      -- Segun las reglas de negocio eliminamos
      --Tipo 0 y saldo en puntos < 10
      DELETE FROM PCLUB.admpt_exp_proxrco_cc WHERE admpc_tipo = '0' AND admpn_puntos < 10;
      DELETE FROM PCLUB.admpt_exp_proxrco_cc WHERE admpn_puntos = 0 AND admpn_equiv = 0;

      COMMIT;

      BEGIN
      OPEN C_CUR_DATOS_CLIE FOR
      SELECT D.ADMPV_COD_CLI, D.ADMPC_TIPO, D.ADMPN_COD_CONTR, D.ADMPN_PUNTOS, D.ADMPN_EQUIV
      FROM  PCLUB.ADMPT_EXP_PROXRCO_CC D
      WHERE D.ADMPD_FEC_OPER=K_FECHAPROC
      ORDER BY D.ADMPN_SEQ ASC;
      END C_CUR_DATOS_CLIE;


END ADMPSS_PROXRCOC;

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

PROCEDURE ADMPSI_EREGULPTO(K_FECHAPROC IN DATE, CURSORREGPTO out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EREGULPTO
-- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Regularizacion de Puntos
-- Input               :  K_FECHAPROC
-- Output              :  CURSORREGPTO
-- Fec Creación        :  24/09/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORREGPTO FOR
SELECT TRIM (ADMPV_COD_CLI), TRIM (ADMPV_NOM_REGUL), TRIM (ADMPV_PERIODO), ADMPN_COD_CONTR, ADMPD_FEC_REG,
       TRIM (ADMPV_HOR_MIN), ADMPN_PUNTOS, TRIM (ADMPC_COD_ERROR), ADMPV_MSJE_ERROR
  FROM PCLUB.ADMPT_IMP_REGULARIZA
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       ADMPC_COD_ERROR Is Not Null AND
       TRIM (ADMPV_MSJE_ERROR) <> ' '
 ORDER BY ADMPN_SEQ ASC;

END ADMPSI_EREGULPTO;

PROCEDURE ADMPSS_CATEGCLI (K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS
--****************************************************************
-- Nombre SP           :  ADMPSS_CATEGCLI
-- Propósito           :  Actualiza la Categoria del Cliente segun la funcionalidad definida
-- Fec Creación        :  21/10/2010
-- Fec Actualización   :
--****************************************************************

C_CODCLI VARCHAR2(40) ;
C_TIP_CL VARCHAR2(2);       --1- CONTROL/2 - POSTPAGO
C_CAT_CLI NUMBER;           --1- PREMIUM / 2- NORMAL
V_LIM_PUNTOS NUMBER;
V_MESES NUMBER;
PUNTOS_CC NUMBER;

BEGIN

/*
CURSOR ACT_CATEG_CLIENTE IS

--BUSCA TODOS LOS CLIENTES QUE TIENEN ESTADO ACTIVO Y TIPO DE CLIENTE CONTROL Y POSTPAGO---
SELECT G.ADMPV_COD_CLI, G.ADMPN_COD_CATCLI, G.ADMPV_COD_TPOCL
FROM PCLUB.ADMPT_CLIENTE G
WHERE G.ADMPC_ESTADO='A'
AND ADMPV_COD_TPOCL IN ('1','2');--POSTPAGO O CONTROL

BEGIN
  OPEN ACT_CATEG_CLIENTE;
  FETCH ACT_CATEG_CLIENTE
  INTO C_CODCLI,C_CAT_CLI, C_TIP_CL;
  WHILE ACT_CATEG_CLIENTE%FOUND LOOP

  IF C_CAT_CLI IS NULL THEN
        UPDATE PCLUB.ADMPT_CLIENTE J
        SET J.ADMPN_COD_CATCLI='2'
        WHERE J.ADMPV_COD_CLI=C_CODCLI;
        COMMIT;
        C_CAT_CLI := '2';
   END IF;

--OBTENER EL VALOR CANTIDAD DE MESES Y PUNTOS RESPECTIVOS PARA CAMBIAR DE TIPO DE CLIENTE--

SELECT K.ADMPN_TME_PUNTO, K.ADMPN_LIM_INF INTO V_MESES, V_LIM_PUNTOS
FROM PCLUB.ADMPT_CAT_CLIENTE K
WHERE K.ADMPV_COD_TPOCL=C_TIP_CL
AND K.ADMPN_COD_CATCLI=C_CAT_CLI; -- Premiun o Normal

--OBTENER LA SUMA DE PUNTOS TOTAL DEL CLIENTE ------

  BEGIN
    SELECT SUM(NVL(X.ADMPN_PUNTOS,0)) INTO PUNTOS_CC
    FROM PCLUB.ADMPT_KARDEX X
    WHERE X.ADMPC_TPO_OPER= 'E'
    AND X.ADMPD_FEC_TRANS >= add_months(trunc(sysdate), -V_MESES)
    AND X.ADMPV_COD_CLI=C_CODCLI;

    EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              PUNTOS_CC := 0;
            END;
  END;

---CLIENTE EN 12 MESES O MENOS ACUMULO 2500 A MAS PUNTOS ACTUALIZAR A PREMIUN----

IF PUNTOS_CC >= V_LIM_PUNTOS THEN

UPDATE PCLUB.ADMPT_CLIENTE J
SET J.ADMPN_COD_CATCLI='1'
WHERE J.ADMPV_COD_CLI=C_CODCLI;

ELSE

UPDATE PCLUB.ADMPT_CLIENTE J
SET J.ADMPN_COD_CATCLI='2'
WHERE J.ADMPV_COD_CLI=C_CODCLI;

END IF;
COMMIT;
FETCH ACT_CATEG_CLIENTE INTO C_CODCLI,C_CAT_CLI, C_TIP_CL;
END LOOP;
CLOSE ACT_CATEG_CLIENTE;
*/

insert into PCLUB.ADMPT_TMP_CATCLI
SELECT G.ADMPV_COD_CLI, K.ADMPN_TME_PUNTO, K.ADMPN_LIM_INF,SUM(NVL(X.ADMPN_PUNTOS,0))
FROM PCLUB.ADMPT_CLIENTE G
join PCLUB.ADMPT_CAT_CLIENTE K
on K.ADMPV_COD_TPOCL=G.ADMPV_COD_TPOCL AND K.ADMPN_COD_CATCLI=nvl(G.ADMPN_COD_CATCLI,2)
join PCLUB.ADMPT_KARDEX X
on X.ADMPV_COD_CLI=G.ADMPV_COD_CLI
WHERE G.ADMPC_ESTADO='A'
AND g.ADMPV_COD_TPOCL IN ('1','2')
AND X.ADMPC_TPO_OPER= 'E'
    AND X.ADMPD_FEC_TRANS >= add_months(trunc(sysdate), -K.ADMPN_TME_PUNTO)
group by G.ADMPV_COD_CLI, K.ADMPN_TME_PUNTO, K.ADMPN_LIM_INF;

update PCLUB.ADMPT_CLIENTE c
set ADMPN_COD_CATCLI=1
where exists
(select 1 from PCLUB.ADMPT_TMP_CATCLI t where t.admpv_cod_cli=c.admpv_cod_cli and t.ptos>=t.admpn_lim_inf);


update PCLUB.ADMPT_CLIENTE c
set ADMPN_COD_CATCLI=2
where exists
(select 1 from PCLUB.ADMPT_TMP_CATCLI t where t.admpv_cod_cli=c.admpv_cod_cli and t.ptos<t.admpn_lim_inf);

commit;

  K_CODERROR:= '0';
  K_DESCERROR:= ' ';

  EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSS_CATEGCLI;

PROCEDURE ADMPSS_PTOFACTU(K_CODERROR    OUT NUMBER,
                                            K_DESCERROR   OUT VARCHAR2,
                                            CURSORPUNTFAC out SYS_REFCURSOR) IS
  --************************************************************************
  -- Nombre SP           :  ADMPSS_PTOFACTU
  -- Propósito           :  Devuelve en un cursor solo con los datos que son enviados para imprimir en la factura
  -- Input               :  K_FECHAPROC
  -- Output              :  CURSORPUNTFAC
  -- Fec Creación        :   22/10/2010
  -- Fec Actualización   :   25/10/2010
  --************************************************************************

  COD_CLI                ADMPT_CLIENTE.ADMPV_COD_CLI%TYPE;
  CC_FACT                NUMBER;
  C_CLIB                 ADMPT_CLIENTEIB.ADMPN_COD_CLI_IB%TYPE;
  V_SUM_SALDO_CUENTA     NUMBER;
  V_SALDO_IB             NUMBER;
  V_SALDO_CC             NUMBER;
  C_CUSTOMERID           INTEGER;
  C_DSC_ERROR            VARCHAR2(40);
  C_CONSIDERA_IB         VARCHAR2 (50);    -- SSC 09112010 - Migracion Loyalty
  C_FECHA                DATE;
/*
 CURSOR B_CLIENTE IS

 ---Obtiene los clientes activos del ciclo proximo obtenido---
     SELECT H.ADMPV_COD_CLI
     FROM PCLUB.ADMPT_CLIENTE H
     WHERE H.ADMPC_ESTADO = 'A'
     AND H.ADMPV_COD_TPOCL IN ('1', '2')
     AND H.ADMPV_CICL_FACT = CC_FACT;
*/

BEGIN
  --OBTENER LA FECHA DE CICLO PROXIMA--
    BEGIN
         SELECT MIN(H.ADMPV_CICL_FACT)
         INTO CC_FACT
         FROM PCLUB.ADMPT_CLIENTE H
         WHERE H.ADMPV_CICL_FACT >= TO_CHAR(SYSDATE, 'DD') AND h.admpc_estado='A' AND H.ADMPV_CICL_FACT<=28;
    EXCEPTION
             WHEN NO_DATA_FOUND THEN
             CC_FACT := NULL;
    END;

    IF CC_FACT IS NULL THEN
        SELECT MIN(H.ADMPV_CICL_FACT)
        INTO CC_FACT
        FROM PCLUB.ADMPT_CLIENTE H
        WHERE H.ADMPV_CICL_FACT < TO_CHAR(SYSDATE, 'DD') AND h.admpc_estado='A' AND H.ADMPV_CICL_FACT<=28;
    END IF;

    BEGIN
      SELECT ADMPV_VALOR INTO C_CONSIDERA_IB
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE UPPER(ADMPV_DESC) = 'CONSIDERA_PUNTOS_IB';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN C_CONSIDERA_IB := 'SI';
    END;

    C_FECHA:=TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'DD/MM/YYYY');
/*
    OPEN B_CLIENTE;
    FETCH B_CLIENTE INTO COD_CLI;

    WHILE B_CLIENTE%FOUND
       LOOP
          --OBTENER SALDO POR CUENTA: Puntos IB + Puntos CC de la tabla ADMPT_SALDOS_CLIENTE por cliente, si los puntos IB del cliente
          -- están Suspendidos, estos deben ser considerados en el saldo.
          ----------------SALDO DE CUENTA CC-------------------------
          BEGIN
               SELECT NVL(X.ADMPN_SALDO_CC, 0)  INTO V_SALDO_CC
                  FROM PCLUB.ADMPT_SALDOS_CLIENTE X
               WHERE X.ADMPV_COD_CLI = COD_CLI
                  AND X.ADMPC_ESTPTO_CC = 'A';

          EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    V_SALDO_CC := 0;
          END;
          ---------------------SALDO DE CUENTA IB--------------------
          BEGIN
               SELECT X.ADMPN_COD_CLI_IB, NVL(X.ADMPN_SALDO_IB, 0) INTO C_CLIB, V_SALDO_IB
                  FROM PCLUB.ADMPT_SALDOS_CLIENTE X
               WHERE X.ADMPV_COD_CLI = COD_CLI
                  AND X.ADMPC_ESTPTO_IB IN ('A','S');

          EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                   V_SALDO_IB :=  0;
          END;

          IF C_CONSIDERA_IB = 'NO' THEN
             V_SALDO_IB := 0;
          END IF;

          -- Total de la Cuenta
          IF V_SALDO_CC >= 0 AND V_SALDO_IB >= 0 THEN
             V_SUM_SALDO_CUENTA:= V_SALDO_IB + V_SALDO_CC;
          END IF;

          IF V_SALDO_CC >= 0 AND V_SALDO_IB < 0 THEN
             V_SUM_SALDO_CUENTA:= V_SALDO_CC;
          END IF;

          IF V_SUM_SALDO_CUENTA IS NULL THEN
             V_SUM_SALDO_CUENTA := 0.00;
          END IF;
*/


    /*     -- Obtenemos el ID del Cliente
         BEGIN
           C_DSC_ERROR := NULL;

           SELECT customer_id
             INTO C_CUSTOMERID
             FROM customer_all@dbl_bscs708
            WHERE custcode = COD_CLI;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                     C_DSC_ERROR := 'NO SE ENCUENTRO EL ID DE LA CUENTA';
                     C_CUSTOMERID:= NULL;
          END;
*/
   /*      INSERT INTO PCLUB.ADMPT_EXP_PTOFACTUR(ADMPV_COD_CLI, ADMPN_SALDO_A, ADMPN_PUNTOS_G, ADMPN_PUNTOS_UTIL, ADMPN_SALD_CUENTA, ADMPN_TRANSF, ADMPN_SALD_TOTAL, ADMPD_FECH_CICLO, FECHA_PROCESO, FECHA_TRANS, ADMPV_COD_ERROR, ADMPV_MSJE_ERROR, ADMPN_CUSTOMER_ID)
          VALUES(COD_CLI, 0, 0, 0, V_SUM_SALDO_CUENTA, 0, 0, CC_FACT, TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'DD/MM/YYYY'), SYSDATE, NULL, C_DSC_ERROR, C_CUSTOMERID);
         COMMIT;
   FETCH B_CLIENTE INTO COD_CLI;
   END LOOP;*/

    INSERT INTO PCLUB.ADMPT_EXP_PTOFACTUR(ADMPV_COD_CLI, ADMPN_SALDO_A, ADMPN_PUNTOS_G, ADMPN_PUNTOS_UTIL, ADMPN_SALD_CUENTA, ADMPN_TRANSF,
    ADMPN_SALD_TOTAL, ADMPD_FECH_CICLO, FECHA_PROCESO, FECHA_TRANS, ADMPV_COD_ERROR, ADMPV_MSJE_ERROR,
    ADMPN_CUSTOMER_ID)
          SELECT H.ADMPV_COD_CLI, 0, 0, 0 ,
         (case when NVL(X.ADMPN_SALDO_IB, 0) >= 0 AND C_CONSIDERA_IB = 'SI' then NVL(X.ADMPN_SALDO_CC, 0) + NVL(X.ADMPN_SALDO_IB, 0)
               when NVL(X.ADMPN_SALDO_IB, 0) < 0 then NVL(X.ADMPN_SALDO_CC, 0) end) "SALDO_CUENTA",
               0, 0, CC_FACT, C_FECHA, SYSDATE, NULL, decode(customer_id, null, 'NO SE ENCUENTRO EL ID DE LA CUENTA',''),
               customer_id

     FROM PCLUB.ADMPT_CLIENTE H
     Left JOIN PCLUB.ADMPT_SALDOS_CLIENTE X
     ON X.ADMPV_COD_CLI = H.ADMPV_COD_CLI AND (X.ADMPC_ESTPTO_IB <>'C' or X.ADMPC_ESTPTO_IB is null)--X.ADMPC_ESTPTO_IB IN ('A','S')
     left join customer_all@DBL_bscs bscs
     on H.ADMPV_COD_CLI=bscs.custcode
     WHERE H.ADMPC_ESTADO = 'A' AND H.ADMPV_COD_TPOCL IN ('1', '2')
     AND H.ADMPV_CICL_FACT = CC_FACT;

     commit;

       ---CURSOR DEVUELVE DATOS DE LA TABLA---
        BEGIN
         OPEN CURSORPUNTFAC FOR
            SELECT F.ADMPN_CUSTOMER_ID, --F.ADMPV_COD_CLI,F.ADMPN_SALDO_A, ADMPN_PUNTOS_G, ADMPN_PUNTOS_UTIL,
                   F.ADMPN_SALD_CUENTA, --ADMPN_TRANSF, ADMPN_SALD_TOTAL,
                   CC_FACT || '/' || (CASE TO_CHAR(SYSDATE, 'MM') WHEN '01' THEN 'ENE' WHEN '02' THEN 'FEB' WHEN '03' THEN 'MAR'
                                                                  WHEN '04' THEN 'ABR' WHEN '05' THEN 'MAY' WHEN '06' THEN 'JUN'
                                                                  WHEN '07' THEN 'JUL' WHEN '08' THEN 'AGO' WHEN '09' THEN 'SET'
                                                                  WHEN '10' THEN 'OCT' WHEN '11' THEN 'NOV' WHEN '12' THEN 'DIC'
                                                                  END)|| '/' || SUBSTR (TO_CHAR(SYSDATE, 'YYYY'), 3, 2)
                   --ADMPD_FECH_CICLO
             FROM PCLUB.ADMPT_EXP_PTOFACTUR F
            WHERE FECHA_PROCESO=TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'DD/MM/YYYY') AND
                  ADMPN_CUSTOMER_ID IS NOT NULL;
          END CURSORPUNTFAC;

   K_CODERROR := '0';
   K_DESCERROR := 'OK';

  EXCEPTION
         WHEN OTHERS THEN K_CODERROR := to_char(SQLCODE); K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSS_PTOFACTU;


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
-- Creado por          :  (Venkizmet)
-- Fec Creación        :  27/09/2010
-- Fec Actualización   :
--****************************************************************

V_PUNTOS_REQUERIDOS      NUMBER:=0;
V_SALDO                  NUMBER:=0;
LK_TPO_PUNTO             char(1);
LK_ID_KARDEX             number;
LK_SLD_PUNTOS            number;
LK_COD_CLI               varchar2(40);
LK_COD_CLIIB             number;
NO_SALDO                 EXCEPTION;

cursor LISTA_KARDEX_1 is
select ka.admpc_tpo_punto, ka.admpn_id_kardex, ka.admpn_sld_punto, ka.admpv_cod_cli, admpn_cod_cli_ib
from PCLUB.ADMPT_KARDEX ka
where ka.admpc_estado='A'
and ka.admpc_tpo_oper='E'
and ka.admpn_sld_punto>0
and ka.admpd_fec_trans<=TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')
and ka.admpv_cod_cli in (select /*+ INDEX_DESC(CC1) */ CC2.ADMPV_COD_CLI
                         FROM  PCLUB.admpt_cliente CC2
                                  INNER JOIN (select ADMPV_TIPO_DOC, 
                                                      ADMPV_NUM_DOC 
                                                  from PCLUB.admpt_cliente
                                                  where ADMPV_COD_CLI=K_COD_CLIENTE
                                                  and ADMPV_COD_TPOCL=K_TIP_CLI
                                                  and admpc_estado='A') CC1 /*Obtiene el numero de doc y su tipo*/
                         ON CC2.ADMPV_TIPO_DOC=CC1.ADMPV_TIPO_DOC
                               AND CC2.ADMPV_NUM_DOC=CC1.ADMPV_NUM_DOC
                               WHERE CC2.ADMPV_COD_TPOCL || '' = K_TIP_CLI
                               and CC2.admpc_estado || '' ='A') /*Selecciona todos los codigos que cumplen con la condicion*/
ORDER BY DECODE(admpc_tpo_punto, 'I', 1 ,'L', 2 ,'C', 3), admpn_id_kardex ASC;


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

   SELECT SUM(ADMPN_SALDO_CC+ADMPN_SALDO_IB) SALDO INTO V_SALDO
   FROM PCLUB.ADMPT_SALDOS_CLIENTE SC
   WHERE ADMPN_SALDO_CC+ADMPN_SALDO_IB>=0
   AND 
   ADMPV_COD_CLI IN (SELECT /*+ INDEX_DESC(C2) */ C1.ADMPV_COD_CLI
                         FROM PCLUB.ADMPT_CLIENTE C1
                         INNER JOIN (SELECT ADMPV_TIPO_DOC, 
                                            ADMPV_NUM_DOC
                                                FROM PCLUB.ADMPT_CLIENTE
                                                WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                                                AND ADMPV_COD_TPOCL=K_TIP_CLI
                                                AND ADMPC_ESTADO='A') C2
                          ON C1.ADMPV_TIPO_DOC=C2.ADMPV_TIPO_DOC
                               AND C1.ADMPV_NUM_DOC=C2.ADMPV_NUM_DOC
                          WHERE C1.ADMPV_COD_TPOCL || '' = K_TIP_CLI
                          AND C1.ADMPC_ESTADO || '' ='A'
                               );


   IF V_SALDO = 0 OR K_PUNTOS > V_SALDO THEN
       RAISE NO_SALDO;
   END IF;

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
                    -- Actualiza Saldos_cliente
                    update PCLUB.admpt_saldos_cliente
                       set
                           admpn_saldo_cc = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                    where admpv_cod_cli=LK_COD_CLI)
                     where admpv_cod_cli = LK_COD_CLI;

                else /* Punto IB*/
                  if LK_TPO_PUNTO='I' then
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
                       -- Actualiza Saldos_cliente
                       update PCLUB.admpt_saldos_cliente
                           set
                               admpn_saldo_cc = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                        where admpv_cod_cli=LK_COD_CLI)
                         where admpv_cod_cli = LK_COD_CLI;

                    else /* Punto IB*/
                      if LK_TPO_PUNTO='I' then
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
                    -- Actualiza Saldos_cliente
                    update PCLUB.admpt_saldos_cliente
                       set
                           admpn_saldo_cc = - LK_SLD_PUNTOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                    where admpv_cod_cli=LK_COD_CLI)
                     where admpv_cod_cli = LK_COD_CLI;
                else /* Punto IB*/
                  if LK_TPO_PUNTO='I' then
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
                        -- Actualiza Saldos_cliente
                        update PCLUB.admpt_saldos_cliente
                           set
                               admpn_saldo_cc = - V_PUNTOS_REQUERIDOS + (select NVL(admpn_saldo_cc,0) from PCLUB.admpt_saldos_cliente
                                        where admpv_cod_cli=LK_COD_CLI)
                         where admpv_cod_cli = LK_COD_CLI;
                    else /* Punto IB*/
                      if LK_TPO_PUNTO='I' then
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

  EXCEPTION
    WHEN NO_SALDO THEN
      K_CODERROR:='01';
      K_MSJERROR:='No Hay saldo disponible para realizar el descuento';
    when others then
      K_CODERROR:=SQLCODE;
      K_MSJERROR:=SUBSTR( SQLERRM, 1,400);
      ROLLBACK;

end ADMPSI_DSCTO_PUNTO;

END PKG_CC_PROCACUMULA;
/
