create or replace package body PCLUB.PKG_CLAROCLUB is
procedure ADMPSI_ACTIV_IB (K_FECHA IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR )
IS
/****************************************************************
'* Nombre SP           :  ADMPSI_ACTIV_IB
'* Propósito           :  Insertar a los clientes IB al sistema de puntos
'* Input               :  K_FECHA 
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  (Venkizmet) Rossana Janampa       
'* Fec Creación        :
'* Fec Actualización   :  21/09/2010
'****************************************************************/

/* Declaracion de variables */

TYPE CURCLARO_DATOSCLIENTE IS REF CURSOR;
C_CUR_DATOS_CLIE CURCLARO_DATOSCLIENTE;
C_CUR_DAT_LINEA CURCLARO_DATOSCLIENTE;
C_CUR_DATOS_TRIADOS CURCLARO_DATOSCLIENTE;

CURSOR CLIENTEIB IS
SELECT  admpc_cod_trans, 
        admpv_tipo_doc, 
        admpv_num_doc, 
        admpv_nom_pri, 
        admpv_nom_seg, 
        admpv_ape_pat, 
        admpv_ape_mat, 
        admpv_num_linea, 
        TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), -- SSC solicitado por Monica para que se registre la fecha en que se importo el registro -- admpd_fec_act, 
        admpc_acep_bono, 
        admpd_fec_oper, 
        admpv_nom_arch, 
        admpc_cod_error, 
        admpv_msje_error
        
FROM PCLUB.admpt_tmp_accamo_ib WHERE ADMPD_FEC_OPER=K_FECHA AND TRIM(ADMPC_COD_TRANS) ='1' AND (length(admpv_msje_error)=0 or admpv_msje_error is null) ;

-- Campos de la tabla TMP_ACCAMO_IB
C_COD_TRANS       ADMPT_TMP_ACCAMO_IB.admpc_cod_trans%type;
C_TIPO_DOC        ADMPT_TMP_ACCAMO_IB.admpv_tipo_doc%type;
C_NUM_DOC         ADMPT_TMP_ACCAMO_IB.admpv_num_doc%type;
C_NOM_PRI         ADMPT_TMP_ACCAMO_IB.admpv_nom_pri%type;
C_NOM_SEG         ADMPT_TMP_ACCAMO_IB.admpv_nom_pri%type;
C_APE_PAT         ADMPT_TMP_ACCAMO_IB.admpv_ape_pat%type;
C_APE_MAT         ADMPT_TMP_ACCAMO_IB.admpv_nom_pri%type;
C_NUM_LINEA       ADMPT_TMP_ACCAMO_IB.admpv_num_linea%type;
C_FEC_ACT         ADMPT_TMP_ACCAMO_IB.admpd_fec_act%type;
C_ACEP_BONO       ADMPT_TMP_ACCAMO_IB.admpc_acep_bono%type;
C_FEC_OPER        ADMPT_TMP_ACCAMO_IB.admpd_fec_oper%type;
C_NOM_ARCH        ADMPT_TMP_ACCAMO_IB.admpv_nom_arch%type;
C_COD_ERROR       ADMPT_TMP_ACCAMO_IB.admpc_cod_error%type;
C_MSJE_ERROR      ADMPT_TMP_ACCAMO_IB.admpv_msje_error%type;

--
-- Cursor datos cliente
C_CUR_CUENTA                   varchar2(40);
C_CUR_TIP_DOC                  varchar2(20);
C_CUR_NUM_DOC                  varchar2(30);
C_CUR_COD_ID                   integer;
C_CUR_CICLO_FAC                varchar2(2);
C_CUR_CODIGO_TIPO_CLIENTE      varchar2(10);
C_CUR_TIPO_CLIENTE             varchar2(30);

C_CUR_MSGERROR              varchar2(400);
-- Cursor datos de linea
C_CUR2_TELEFONO             VARCHAR2(63);
C_CUR2_PLAN                 VARCHAR2(30);
C_CUR2_FLAG_PLATAFORMA      CHAR(1);
C_CUR2_CODIGO_PLAN_TARIFARIO   NUMBER;
--Cursor triados
V_TIPO_TRIADO                  VARCHAR2(20);
V_NUM_TRIO                     INTEGER;
V_TELEFONO                     VARCHAR2(20);
V_FACTOR                       VARCHAR2(20);
V_COD_TIPO_DESTINO             VARCHAR2(20);
V_TIPO_DESTINO                 VARCHAR2(20);

V_TIPO_DOC_EQUIV             VARCHAR2(20);
V_B2E_PUNTOS                 NUMBER(4);
V_CODCLIIB                   number;
V_COD_CPTO                   VARCHAR2(2);
V_PLAN_CODE_SERV             number(4);
V_CONT                       number(1);
V_PLAN_CODE_PQ               NUMBER;
--V_R_FUN029                   VARCHAR2(100);
V_ERROR                      VARCHAR2(400);
V_TIPO_DOC_CLARO             VARCHAR2(2);
V_CONTB2B_SALDO              INTEGER:=0;
V_COD_PENDIENTE              NUMBER;
V_TRIADOS                    NUMBER;

-- Verificar si el contrato se encuentra activo
V_FLAG_RESULTADO            NUMBER;
V_COD_ERROR                 NUMBER;
V_DSC_ERROR                 VARCHAR2(400);

ERROR_ACTIVACION_REGISTRO EXCEPTION;
NO_USERS_CLIENTE EXCEPTION;
NO_USERS_LINEA EXCEPTION;
NO_DATA_ACTIVO EXCEPTION;                -- SSC 27102010

BEGIN -- DEL PROCEDURE
  
   K_CODERROR:=0;
   K_DESCERROR:='';
   
    OPEN CLIENTEIB;
    FETCH CLIENTEIB INTO C_COD_TRANS, C_TIPO_DOC, C_NUM_DOC, C_NOM_PRI, C_NOM_SEG, C_APE_PAT, C_APE_MAT, C_NUM_LINEA, C_FEC_ACT, C_ACEP_BONO, C_FEC_OPER, C_NOM_ARCH, C_COD_ERROR, C_MSJE_ERROR;
    WHILE CLIENTEIB %FOUND
      LOOP
        IF C_NUM_LINEA IS NULL THEN
            Select count(*) into V_CONT FROM PCLUB.admpt_aux_accamo_ib
            where admpc_cod_trans=C_COD_TRANS and admpv_tipo_doc=C_TIPO_DOC and admpv_num_doc=C_NUM_DOC and admpv_num_linea IS NULL and admpd_fec_oper=K_FECHA ;
        ELSE
            Select count(*) into V_CONT FROM PCLUB.admpt_aux_accamo_ib
            where admpc_cod_trans=C_COD_TRANS and admpv_tipo_doc=C_TIPO_DOC and admpv_num_doc=C_NUM_DOC and admpv_num_linea=C_NUM_LINEA and admpd_fec_oper=K_FECHA;
        END IF;
        -- Bloque
        BEGIN
            IF v_cont=0 THEN
                  IF TRIM(C_NUM_LINEA) IS NULL THEN
                     BEGIN
                        -- Parametros
                        SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,'-1') INTO V_CODCLIIB FROM dual;
                        SELECT nvl(admpv_cod_tpdoc,'-1') INTO V_TIPO_DOC_CLARO FROM PCLUB.ADMPT_TIPO_DOC WHERE admpv_cod_equiv=C_TIPO_DOC;

                        SAVEPOINT BQ1;

                        -- Registra Cliente IB                        
                        IF C_ACEP_BONO='S' THEN
                          INSERT INTO PCLUB.admpt_clienteib
                            (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act, admpv_nom_cli, admpv_ape_cli)
                          VALUES
                           (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, '','', C_FEC_ACT , 'A', 0, 0, 0, C_NOM_PRI||' '||C_NOM_SEG,C_APE_PAT||' '||C_APE_MAT );
                          
                        ELSE -- acep_bono='N'
                          INSERT INTO PCLUB.admpt_clienteib
                            (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act, admpv_nom_cli, admpv_ape_cli)
                          VALUES
                           (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, '','', C_FEC_ACT , 'A', 0, 0, 2, C_NOM_PRI||' '||C_NOM_SEG,C_APE_PAT||' '||C_APE_MAT );
                          
                        END IF;

                        -- Inserta registro en la tabla Saldos_cliente
                        INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib,admpn_saldo_cc,admpn_saldo_ib,admpc_estpto_cc,admpc_estpto_ib)
                        VALUES (PCLUB.admpt_sld_cl_sq.nextval, '', V_CODCLIIB, 0, 0,'', 'A' );

                        -- Inserta registro en la tabla Aux
                        INSERT INTO PCLUB.admpt_aux_accamo_ib (admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpd_fec_oper, admpv_nom_arch)
                        VALUES ( '1', C_TIPO_DOC, C_NUM_DOC ,C_NUM_LINEA, K_FECHA, NVL(C_NOM_ARCH,''));
                        COMMIT;

                     EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                           if V_CODCLIIB='-1' or V_CODCLIIB is null then
                                 update PCLUB.admpt_tmp_accamo_ib 
                                 set    admpc_cod_error='28',
                                        admpv_msje_error ='No se encontró la secuencia admpt_cli_ib_sq.nextval'
                                 where  admpc_cod_trans= '1' and 
                                        admpv_tipo_doc=C_TIPO_DOC and admpv_num_doc=C_NUM_DOC; 
                                 commit;

                           else
                                 if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                     update PCLUB.admpt_tmp_accamo_ib 
                                     set    admpc_cod_error='29',
                                            admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                     where  admpc_cod_trans= '1' and 
                                            admpv_tipo_doc=C_TIPO_DOC and 
                                            admpv_num_doc=C_NUM_DOC; 
                                     commit;
                                 end if;
                            end if;

                         WHEN OTHERS THEN
                           ROLLBACK TO BQ1;
                           V_ERROR:=SUBSTR(SQLERRM,1,400);                           
                           update PCLUB.admpt_tmp_accamo_ib 
                           set    admpc_cod_error = 'ORA',
                                  admpv_msje_error = V_ERROR
                           where admpc_cod_trans= '1' and 
                                 admpv_tipo_doc=C_TIPO_DOC and 
                                 admpv_num_doc=C_NUM_DOC;
                           commit;
                     END;
                  ELSE
                     --PKG_CLAROCLUB.sp_datos_clien('',C_NUM_LINEA, C_CUR_MSGERROR, C_CUR_DATOS_CLIE);                     
                     PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',C_NUM_LINEA, C_CUR_MSGERROR, C_CUR_DATOS_CLIE);
                     --TIM.pp004_siac_consultas.sp_datos_clien@DBL_BSCS('0',C_NUM_LINEA, C_CUR_MSGERROR, C_CUR_DATOS_CLIE);
                     --LOOP
                       BEGIN
                       -- No se produjo error en la adquisicion de los datos del cliente
                       FETCH C_CUR_DATOS_CLIE INTO
                           C_CUR_CUENTA,       C_CUR_TIP_DOC,                C_CUR_NUM_DOC,  C_CUR_COD_ID,
                           C_CUR_CICLO_FAC,    C_CUR_CODIGO_TIPO_CLIENTE,    C_CUR_TIPO_CLIENTE;                      
                                              
                       IF Length(C_CUR_MSGERROR)<>0 OR C_CUR_MSGERROR IS NOT NULL THEN
                         RAISE NO_USERS_CLIENTE; -- CLARO: consultar como devuelve C_CUR_MSGERROR en caso no se encuentre el numero consultado en la BD
                       END IF;

                       SELECT nvl(admpv_dsc_docum,'-1')  INTO V_TIPO_DOC_EQUIV FROM PCLUB.ADMPT_TIPO_DOC WHERE admpv_cod_equiv=C_TIPO_DOC;
                       -- Verifica si el numero de telefono pertenece al cliente
                       IF V_TIPO_DOC_EQUIV=C_CUR_TIP_DOC AND C_NUM_DOC=C_CUR_NUM_DOC THEN
                           BEGIN

                             IF TRIM(C_CUR_CODIGO_TIPO_CLIENTE)='3' or TRIM(C_CUR_CODIGO_TIPO_CLIENTE)='5' THEN -- el numero es B2E o empleados Claro
                                BEGIN
                                  -- Parametros
                                  SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,-1) INTO V_CODCLIIB FROM dual;
                                  SELECT nvl(admpv_cod_cpto,'-1') INTO V_COD_CPTO FROM PCLUB.admpt_concepto WHERE admpv_desc='ACTIVACION TC';
                                  SELECT nvl(admpv_valor,'-1') INTO V_B2E_PUNTOS FROM PCLUB.admpt_paramsist WHERE admpv_desc='B2E_ACTIVACION_TC';
                                  SELECT nvl(admpv_cod_tpdoc,'-1') INTO V_TIPO_DOC_CLARO FROM PCLUB.admpt_tipo_doc WHERE admpv_dsc_docum=V_TIPO_DOC_EQUIV;
                                  
                                  SELECT COUNT(*) INTO V_CONTB2B_SALDO FROM PCLUB.admpt_saldos_cliente WHERE admpv_cod_cli=C_CUR_CUENTA;

                                  SAVEPOINT BQ2;

                                  IF C_ACEP_BONO='S' THEN
                                    --Registra Cliente IB
                                    INSERT into PCLUB.admpt_clienteib
                                    (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act,admpv_nom_cli,admpv_ape_cli )
                                    values
                                    (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, C_NUM_LINEA, C_CUR_CUENTA, C_FEC_ACT, 'A',0 ,0, 1, C_NOM_PRI||' '||C_NOM_SEG, C_APE_PAT||' '||C_APE_MAT );

                                    --Registra en Kardex 500 puntos
                                    INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                    ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                    ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                                    VALUES(PCLUB.admpt_kardex_sq.nextval, V_CODCLIIB, C_CUR_CUENTA, V_COD_CPTO, TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'),
                                    TO_NUMBER(V_B2E_PUNTOS), C_NOM_ARCH, 'E', 'I', TO_NUMBER(V_B2E_PUNTOS), 'A');

                                    IF V_CONTB2B_SALDO=0 THEN
                                       --Registra ingreso de cliente en Saldos
                                       INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib,admpn_saldo_cc,admpn_saldo_ib,admpc_estpto_cc,admpc_estpto_ib)
                                       VALUES (PCLUB.admpt_sld_cl_sq.nextval, C_CUR_CUENTA, V_CODCLIIB, 0, V_B2E_PUNTOS, '', 'A' );
                                    ELSE
                                       UPDATE PCLUB.admpt_saldos_cliente
                                          SET
                                              admpn_cod_cli_ib = V_CODCLIIB ,
                                              admpn_saldo_ib = V_B2E_PUNTOS,
                                              admpc_estpto_ib = 'A'
                                        WHERE  admpv_cod_cli=C_CUR_CUENTA ;
                                    END IF;

                                  ELSE  --C_ACEP_BONO='N'
                                    --Registra Cliente IB
                                    INSERT into PCLUB.admpt_clienteib
                                    (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act,admpv_nom_cli,admpv_ape_cli )
                                    values
                                    (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, C_NUM_LINEA, C_CUR_CUENTA, C_FEC_ACT, 'A',0 ,0, 2, C_NOM_PRI||' '||C_NOM_SEG, C_APE_PAT||' '||C_APE_MAT );

                                    IF V_CONTB2B_SALDO=0 THEN
                                       --Registra ingreso de cliente en Saldos
                                       INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib,admpn_saldo_cc,admpn_saldo_ib,admpc_estpto_cc,admpc_estpto_ib)
                                       VALUES (PCLUB.admpt_sld_cl_sq.nextval, C_CUR_CUENTA, V_CODCLIIB, 0, 0, '', 'A' );
                                    ELSE
                                       UPDATE PCLUB.admpt_saldos_cliente
                                          SET
                                              admpn_cod_cli_ib = V_CODCLIIB ,
                                              admpn_saldo_ib = 0,
                                              admpc_estpto_ib = 'A'
                                        WHERE  admpv_cod_cli=C_CUR_CUENTA ;
                                    END IF;
                                                                        
                                  END IF;
                                  
                                  --  Inserta registro en la tabla Aux
                                  INSERT INTO PCLUB.admpt_aux_accamo_ib (admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpd_fec_oper, admpv_nom_arch)
                                  VALUES ('1', C_TIPO_DOC, C_NUM_DOC, C_NUM_LINEA, K_FECHA, C_NOM_ARCH);

                                  COMMIT;
                                EXCEPTION
                                   WHEN NO_DATA_FOUND THEN
                                      if V_CODCLIIB =-1 then
                                         update PCLUB.admpt_tmp_accamo_ib 
                                         set    admpc_cod_error='28',
                                                admpv_msje_error = 'No se encontró la secuencia admpt_cli_ib_sq.nextval)'
                                         where  admpc_cod_trans= '1' and 
                                                admpv_tipo_doc=C_TIPO_DOC and 
                                                admpv_num_doc=C_NUM_DOC; 
                                         commit;
                                       else 
                                         if  V_COD_CPTO='-1' or V_COD_CPTO is null then
                                           update PCLUB.admpt_tmp_accamo_ib 
                                           set    admpc_cod_error='30',
                                                  admpv_msje_error = 'No se encontró el concepto. Inserte el concepto en la tabla admpt_concepto'
                                           where  admpc_cod_trans= '1' and 
                                                  admpv_tipo_doc=C_TIPO_DOC and 
                                                  admpv_num_doc=C_NUM_DOC; 
                                           commit;
                                         else
                                           if V_B2E_PUNTOS='-1' or V_B2E_PUNTOS is null then
                                             update PCLUB.admpt_tmp_accamo_ib 
                                             set    admpc_cod_error='31',
                                                    admpv_msje_error = 'No se encontró el parámetro en la tabla admpt_paramsist'
                                             where  admpc_cod_trans= '1' and 
                                                    admpv_tipo_doc=C_TIPO_DOC and 
                                                    admpv_num_doc=C_NUM_DOC; 
                                             commit;
                                            else
                                               if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                                 update PCLUB.admpt_tmp_accamo_ib 
                                                 set    admpc_cod_error='29',
                                                        admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                                 where  admpc_cod_trans= '1' and 
                                                        admpv_tipo_doc=C_TIPO_DOC and 
                                                        admpv_num_doc=C_NUM_DOC; 
                                                 commit;
                                             end if;
                                            end if;
                                         end if;
                                       end if; 
                                                                              
                                   WHEN OTHERS THEN
                                      ROLLBACK TO SAVEPOINT BQ2;
                                      V_ERROR:=SUBSTR(SQLERRM,1,400);                                      
                                      update PCLUB.admpt_tmp_accamo_ib 
                                      set    admpc_cod_error='ORA',
                                             admpv_msje_error = V_ERROR
                                      where admpc_cod_trans= '1' and 
                                            admpv_tipo_doc=C_TIPO_DOC and 
                                            admpv_num_doc=C_NUM_DOC; 
                                      commit;
                                END;

                             ELSE 
                               If C_CUR_CODIGO_TIPO_CLIENTE='2' then --Consumer
                                   BEGIN
                                      --PCLUB.PKG_CLAROCLUB.sp_claro_datos_linea(C_CUR_COD_ID, C_CUR_DAT_LINEA); 
                                      PKG_CLAROCLUB.ADMPSS_DAT_LINE(C_CUR_COD_ID, C_CUR_DAT_LINEA);
                                      
                                      --Si el cursor devuelve un registro para la consulta se considera que la linea esta habilitada para recibir el bono
                                      FETCH C_CUR_DAT_LINEA INTO C_CUR2_TELEFONO, C_CUR2_PLAN, C_CUR2_FLAG_PLATAFORMA, C_CUR2_CODIGO_PLAN_TARIFARIO;

                                      IF (C_CUR_DAT_LINEA%rowcount=0)   THEN
                                         RAISE NO_USERS_LINEA;
                                      END IF;

                                      IF C_ACEP_BONO='S' THEN
                                          -- Consulta si el numero enviado tiene triados                                        
                                          PKG_CLAROCLUB.admpss_triados(C_CUR_COD_ID, C_CUR_DATOS_TRIADOS);
                                          V_TRIADOS:=1;                                    
                                          FETCH C_CUR_DATOS_TRIADOS INTO v_Tipo_triado, v_num_trio, v_telefono, v_factor, v_cod_tipo_destino, v_tipo_destino;                                          
                                          
                                          IF (C_CUR_DATOS_TRIADOS%rowcount=0)   THEN
                                             V_TRIADOS:=0;                                             
                                          -- SSC 26102010 - Se solicito que se valide que el tipo de destino sea Claro y movil
                                          --END IF;
                                          ELSE
                                            WHILE C_CUR_DATOS_TRIADOS %FOUND
                                              LOOP
                                                 IF v_tipo_destino = 'CLARO' THEN
                                                     BEGIN
                                                        V_TRIADOS:=1;
                                                        EXIT;
                                                     END;
                                                  ELSE
                                                     V_TRIADOS:=0;
                                                  END IF;   
                                              
                                                 FETCH C_CUR_DATOS_TRIADOS INTO v_Tipo_triado, v_num_trio, v_telefono, v_factor, v_cod_tipo_destino, v_tipo_destino;               
                                              END LOOP;
                                          END IF;      
                                          -- SSC 26102010
                                                
                                          -- SSC 26102010 - Se realizan los cambios necesarios para que solo le otorgue el bono si esta activo
                                          V_FLAG_RESULTADO := 0;
                                          IF V_TRIADOS > 0 THEN
                                            BEGIN
                                               PKG_CLAROCLUB.ADMPSS_SP_STATUS_DN_NUM_CO_ID (2, C_CUR_COD_ID,V_FLAG_RESULTADO,V_COD_ERROR,V_DSC_ERROR);

                                               IF (V_COD_ERROR<>0) THEN
                                                  RAISE NO_DATA_ACTIVO;
                                               END IF;
                                               IF V_FLAG_RESULTADO = 0 THEN
                                                  V_TRIADOS:=0;    -- Como esta inactivo se asigna este valor para que no le de el bono y hacer otro IF
                                               END IF;
                                            END;
                                          END IF;
                                          -- SSC 26102010
                                      
                                          IF V_TRIADOS > 0 AND C_CUR_CICLO_FAC = to_char(sysdate,'DD') THEN -- Se le otorgan puntos
                                             BEGIN
                                                 -- Parámetros
                                                 SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,-1) INTO V_CODCLIIB FROM dual;
                                                 SELECT nvl(admpv_valor,'-1') INTO V_PLAN_CODE_SERV FROM PCLUB.admpt_paramsist WHERE admpv_desc='COD_SERV_BONO_ACTIVACION_TC';
                                                 SELECT nvl(admpv_valor,'-1') INTO V_PLAN_CODE_PQ FROM PCLUB.admpt_paramsist WHERE admpv_desc='COD_PAQU_BONO_ACTIVACION_TC';
                                                 SELECT COUNT(*) INTO V_CONTB2B_SALDO FROM PCLUB.admpt_saldos_cliente WHERE admpv_cod_cli=C_CUR_CUENTA;
                                                 SELECT nvl(admpv_cod_tpdoc,'-1') INTO V_TIPO_DOC_CLARO FROM PCLUB.admpt_tipo_doc WHERE admpv_dsc_docum=V_TIPO_DOC_EQUIV;
                                                 SELECT nvl(admpt_serv_pen_sq.nextval,-1) INTO V_COD_PENDIENTE FROM dual;
                                                   
                                                 /*begin
                                                   V_R_FUN029:= TIM.tfun029_register_service_sp@DBL_BSCS(NULL,C_NUM_LINEA, NULL, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ,'1') ;
                                                   commit;
                                                 end;
                                                 -- V_R_FUN029:=  ADMPF_ACTIVA_REGISTRO (C_NUM_LINEA, V_PLAN_CODE_SERV , V_PLAN_CODE_PQ, 1 );
                                                                                                                                                                                                
                                                 IF To_number(trim(V_R_FUN029))<0 THEN
                                                   RAISE ERROR_ACTIVACION_REGISTRO;
                                                 END IF;
                                                 */
                                                 SAVEPOINT BQ3;
                                                   
                                                 -- Inserta en la tabla ADMPT_SERV_PEN
                                                 INSERT INTO PCLUB.admpt_serv_pend
                                                   (admpn_id_fila, admpv_num_linea, admpn_sn_code, admpn_sp_code, admpc_estado, admpd_fec_reg, adpmv_accion)
                                                 VALUES (V_COD_PENDIENTE,C_NUM_LINEA, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ, 'P',  TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'), '1');
                                                                                                                                                                                               
                                                 -- Registra Cliente IB
                                                 INSERT INTO PCLUB.admpt_clienteib
                                                 (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado,
                                                 admpn_flg_debi, admpn_flg_num, admpn_bono_act,admpv_nom_cli,admpv_ape_cli )
                                                 VALUES
                                                 (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, C_NUM_LINEA, C_CUR_CUENTA, C_FEC_ACT, 'A',0 ,0, 1, C_NOM_PRI||' '||C_NOM_SEG, C_APE_PAT||' '||C_APE_MAT);

                                                 IF V_CONTB2B_SALDO=0 THEN
                                                     --Registra ingreso de cliente en Saldos
                                                     INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib, admpn_saldo_cc, admpn_saldo_ib, admpc_estpto_cc, admpc_estpto_ib)
                                                     VALUES (PCLUB.admpt_sld_cl_sq.nextval, C_CUR_CUENTA, V_CODCLIIB, 0, 0, '', 'A' );
                                                 ELSE
                                                     UPDATE PCLUB.admpt_saldos_cliente
                                                        SET
                                                            admpn_cod_cli_ib = V_CODCLIIB,
                                                            admpn_saldo_ib = 0,
                                                            admpc_estpto_ib = 'A'
                                                      WHERE  admpv_cod_cli=C_CUR_CUENTA ;
                                                 END IF;

                                                 -- Inserta registro en la tabla Aux
                                                 INSERT INTO PCLUB.admpt_aux_accamo_ib (admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpd_fec_oper, admpv_nom_arch)
                                                 VALUES ('1', C_TIPO_DOC, C_NUM_DOC, C_NUM_LINEA, K_FECHA, C_NOM_ARCH);

                                                 COMMIT;
                                               EXCEPTION                     
                                                   WHEN NO_DATA_FOUND THEN
                                                       if V_CODCLIIB =-1  then
                                                           update PCLUB.admpt_tmp_accamo_ib 
                                                           set    admpc_cod_error='28',
                                                                  admpv_msje_error = 'No se encontró la secuencia admpt_cli_ib_sq.nextval)'
                                                           where  admpc_cod_trans= '1' and 
                                                                  admpv_tipo_doc=C_TIPO_DOC and 
                                                                  admpv_num_doc=C_NUM_DOC; 
                                                           commit;
                                                         else 
                                                           if  V_COD_CPTO='-1' or V_COD_CPTO is null then
                                                             update PCLUB.admpt_tmp_accamo_ib 
                                                             set    admpc_cod_error='30',
                                                                    admpv_msje_error = 'No se encontró el concepto. Inserte el concepto en la tabla admpt_concepto'
                                                             where  admpc_cod_trans= '1' and 
                                                                    admpv_tipo_doc=C_TIPO_DOC and 
                                                                    admpv_num_doc=C_NUM_DOC; 
                                                             commit;
                                                           else
                                                             if V_B2E_PUNTOS='-1' or V_B2E_PUNTOS is null or V_PLAN_CODE_SERV is null or V_PLAN_CODE_PQ is null then
                                                               update PCLUB.admpt_tmp_accamo_ib 
                                                               set    admpc_cod_error='31',
                                                                      admpv_msje_error = 'No se encontró el registro en la tabla admpt_paramsist'
                                                               where  admpc_cod_trans= '1' and 
                                                                      admpv_tipo_doc=C_TIPO_DOC and 
                                                                      admpv_num_doc=C_NUM_DOC; 
                                                               commit;
                                                              else
                                                                 if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                                                   update PCLUB.admpt_tmp_accamo_ib 
                                                                   set    admpc_cod_error='29',
                                                                          admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                                                   where  admpc_cod_trans= '1' and 
                                                                          admpv_tipo_doc=C_TIPO_DOC and 
                                                                          admpv_num_doc=C_NUM_DOC; 
                                                                   commit;
                                                               end if;
                                                              end if;
                                                           end if;
                                                         end if;
                                                                            
                                                   WHEN OTHERS THEN
                                                      ROLLBACK TO SAVEPOINT BQ3;
                                                      V_ERROR:=SUBSTR(SQLERRM,1,400);
                                                      update PCLUB.admpt_tmp_accamo_ib 
                                                      set    admpv_msje_error = V_ERROR
                                                      where admpc_cod_trans= '1' and 
                                                            admpv_tipo_doc=C_TIPO_DOC and 
                                                            admpv_num_doc=C_NUM_DOC and 
                                                            admpv_nom_arch=C_NOM_ARCH ;

                                               END;

                                          ELSE 
                                            IF (V_TRIADOS >0 AND C_CUR_CICLO_FAC <> to_char(sysdate,'DD')) OR 
                                               (V_TRIADOS =0 AND  C_CUR_CICLO_FAC = to_char(sysdate,'DD')) OR 
                                               (V_TRIADOS =0 AND  C_CUR_CICLO_FAC <> to_char(sysdate,'DD')) THEN
                                              
                                                BEGIN
                                                  -- Parámetros
                                                  SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,'1') INTO V_CODCLIIB FROM dual;                                          
                                                  SELECT admpv_cod_tpdoc INTO V_TIPO_DOC_CLARO FROM admpt_tipo_doc WHERE admpv_dsc_docum=V_TIPO_DOC_EQUIV;
                                                  SELECT COUNT(*) INTO V_CONTB2B_SALDO FROM admpt_saldos_cliente WHERE admpv_cod_cli=C_CUR_CUENTA;

                                                  SAVEPOINT BQ5;
                                                  
                                                  -- Registra Cliente IB
                                                  INSERT INTO PCLUB.admpt_clienteib
                                                  (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act,admpv_nom_cli,admpv_ape_cli)
                                                  VALUES (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, C_NUM_LINEA, C_CUR_CUENTA, C_FEC_ACT, 'A', 0, 0, 0, C_NOM_PRI||' '||C_NOM_SEG, C_APE_PAT||' '||C_APE_MAT);
                                                  
                                                  IF V_CONTB2B_SALDO=0 THEN
                                                       --Registra ingreso de cliente en Saldos
                                                       INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib, admpn_saldo_cc, admpn_saldo_ib, admpc_estpto_cc, admpc_estpto_ib)
                                                       VALUES (PCLUB.admpt_sld_cl_sq.nextval, C_CUR_CUENTA, V_CODCLIIB, 0, 0, '', 'A' );
                                                   ELSE
                                                       UPDATE PCLUB.admpt_saldos_cliente
                                                          SET
                                                              admpn_cod_cli_ib = V_CODCLIIB,
                                                              admpn_saldo_ib = 0,
                                                              admpc_estpto_ib = 'A'
                                                        WHERE  admpv_cod_cli=C_CUR_CUENTA ;
                                                   END IF;
                                                   
                                                  -- Inserta registro en la tabla Aux
                                                  INSERT INTO PCLUB.admpt_aux_accamo_ib (admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpd_fec_oper, admpv_nom_arch)
                                                  VALUES ('1', C_TIPO_DOC, C_NUM_DOC, C_NUM_LINEA, K_FECHA, C_NOM_ARCH);
                                                  COMMIT;
                                                  
                                               EXCEPTION
                                                  WHEN NO_DATA_FOUND THEN
                                                    if V_CODCLIIB =-1 then
                                                       update PCLUB.admpt_tmp_accamo_ib 
                                                       set    admpc_cod_error='28',
                                                              admpv_msje_error = 'No se encontró la secuencia admpt_cli_ib_sq.nextval)'
                                                       where  admpc_cod_trans= '1' and 
                                                              admpv_tipo_doc=C_TIPO_DOC and 
                                                              admpv_num_doc=C_NUM_DOC; 
                                                       commit;
                                                     else                                                    
                                                         if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                                           update PCLUB.admpt_tmp_accamo_ib 
                                                           set    admpc_cod_error='29',
                                                                  admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                                           where  admpc_cod_trans= '1' and 
                                                                  admpv_tipo_doc=C_TIPO_DOC and 
                                                                  admpv_num_doc=C_NUM_DOC; 
                                                           commit;
                                                          end if;
                                                     end if;
                                                     
                                                  WHEN OTHERS THEN
                                                     ROLLBACK TO BQ5;
                                                     V_ERROR:=SUBSTR(SQLERRM,1,400);
                                                     update   PCLUB.admpt_tmp_accamo_ib 
                                                     set      admpv_msje_error = V_ERROR
                                                     where    admpc_cod_trans= '1' and 
                                                              admpv_tipo_doc=C_TIPO_DOC and 
                                                              admpv_num_doc=C_NUM_DOC and 
                                                              admpv_nom_arch=C_NOM_ARCH ;
                                               END;                                                                                             
                                            END IF;  
                                          END IF;                                                                                
                                        CLOSE C_CUR_DATOS_TRIADOS;
                                      ELSE
                                         IF  C_ACEP_BONO='N' THEN 
                                           BEGIN
                                               -- Parametros
                                               SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,-1) INTO V_CODCLIIB FROM dual;
                                               SELECT nvl(admpv_cod_tpdoc,'-1') INTO V_TIPO_DOC_CLARO FROM PCLUB.admpt_tipo_doc WHERE admpv_dsc_docum=V_TIPO_DOC_EQUIV;
                                               SELECT COUNT(*) INTO V_CONTB2B_SALDO FROM admpt_saldos_cliente WHERE admpv_cod_cli=C_CUR_CUENTA;
                                               
                                               SAVEPOINT BQ7;

                                               -- Registra Cliente IB
                                               INSERT into PCLUB.admpt_clienteib
                                               (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado,
                                               admpn_flg_debi, admpn_flg_num, admpn_bono_act,admpv_nom_cli,admpv_ape_cli )
                                               VALUES
                                               (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, C_NUM_LINEA, C_CUR_CUENTA, C_FEC_ACT, 'A',0 ,0, 2, C_NOM_PRI||' '||C_NOM_SEG, C_APE_PAT||' '||C_APE_MAT);
                                               
                                               IF V_CONTB2B_SALDO=0 THEN
                                                   --Registra ingreso de cliente en Saldos
                                                   INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib, admpn_saldo_cc, admpn_saldo_ib, admpc_estpto_cc, admpc_estpto_ib)
                                                   VALUES (PCLUB.admpt_sld_cl_sq.nextval, C_CUR_CUENTA, V_CODCLIIB, 0, 0, '', 'A' );
                                               ELSE
                                                   UPDATE PCLUB.admpt_saldos_cliente
                                                      SET
                                                          admpn_cod_cli_ib = V_CODCLIIB,
                                                          admpn_saldo_ib = 0,
                                                          admpc_estpto_ib = 'A'
                                                    WHERE  admpv_cod_cli=C_CUR_CUENTA ;
                                               END IF;
                                               
                                               -- Inserta registro en la tabla Aux
                                               INSERT INTO PCLUB.admpt_aux_accamo_ib (admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpd_fec_oper, admpv_nom_arch)
                                               VALUES ('1', C_TIPO_DOC, C_NUM_DOC, C_NUM_LINEA, K_FECHA, C_NOM_ARCH);

                                               COMMIT;

                                           EXCEPTION
                                              WHEN NO_DATA_FOUND THEN
                                                if V_CODCLIIB =-1 then
                                                   update PCLUB.admpt_tmp_accamo_ib 
                                                   set    admpc_cod_error='28',
                                                          admpv_msje_error = 'No se encontró la secuencia admpt_cli_ib_sq.nextval)'
                                                   where  admpc_cod_trans= '1' and 
                                                          admpv_tipo_doc=C_TIPO_DOC and 
                                                          admpv_num_doc=C_NUM_DOC; 
                                                   commit;
                                                 else                                                    
                                                     if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                                       update PCLUB.admpt_tmp_accamo_ib 
                                                       set    admpc_cod_error='29',
                                                              admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                                       where  admpc_cod_trans= '1' and 
                                                              admpv_tipo_doc=C_TIPO_DOC and 
                                                              admpv_num_doc=C_NUM_DOC; 
                                                       commit;
                                                      end if;
                                                 end if;
                                                  
                                              WHEN OTHERS THEN
                                                 ROLLBACK TO BQ7;
                                                 V_ERROR:=SUBSTR(SQLERRM,1,400);
                                                 update PCLUB.admpt_tmp_accamo_ib 
                                                 set    admpv_msje_error = V_ERROR
                                                 where admpc_cod_trans= '1' and 
                                                       admpv_tipo_doc=C_TIPO_DOC and 
                                                       admpv_num_doc=C_NUM_DOC and 
                                                       admpv_nom_arch=C_NOM_ARCH;
                                                 commit;

                                           END;                                           
                                         END IF;                                         
                                      END IF;                                                                               

                                      CLOSE C_CUR_DAT_LINEA;
                                   EXCEPTION
                                      WHEN NO_USERS_LINEA THEN
                                         update PCLUB.admpt_tmp_accamo_ib
                                         set    admpc_cod_error = '20',
                                                admpv_msje_error = 'Error en la devolución del cursor sp_datos_linea'
                                         where 
                                                admpc_cod_trans= '1' and 
                                                admpv_tipo_doc=C_TIPO_DOC and 
                                                admpv_num_doc=C_NUM_DOC and 
                                                admpv_nom_arch=C_NOM_ARCH;

                                      -- SSC 27102010 - Inicio - Si se presenta un error en el SP de activacion
                                      WHEN NO_DATA_ACTIVO THEN
                                         update PCLUB.admpt_tmp_accamo_ib
                                         set    admpc_cod_error = '20',
                                                admpv_msje_error = 'Error: Se presentó un error al leer el SP ADMPSS_SP_STATUS_DN_NUM_CO_ID'
                                         where 
                                                admpc_cod_trans= '1' and 
                                                admpv_tipo_doc=C_TIPO_DOC and 
                                                admpv_num_doc=C_NUM_DOC and 
                                                admpv_nom_arch=C_NOM_ARCH;
                                      -- SSC 27102010 - Fin
                                                
                                   END;
                               else -- Cualquier otro tipo de cliente
                                 BEGIN 
                                   -- Parametros                                   
                                    SELECT COUNT(*) INTO V_CONTB2B_SALDO FROM PCLUB.admpt_saldos_cliente WHERE admpv_cod_cli=C_CUR_CUENTA;
                                    SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,'-1') INTO V_CODCLIIB FROM dual;
                                    SELECT nvl(admpv_cod_tpdoc,'-1') INTO V_TIPO_DOC_CLARO FROM admpt_tipo_doc WHERE admpv_dsc_docum=V_TIPO_DOC_EQUIV;
                                    
                                    SAVEPOINT BQ8;
                                    -- Inserta en Cliente IB
                                    INSERT into PCLUB.admpt_clienteib
                                    (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act,admpv_nom_cli,admpv_ape_cli )
                                    values
                                    (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, C_NUM_LINEA, C_CUR_CUENTA, C_FEC_ACT, 'A',0 ,0, 2, C_NOM_PRI||' '||C_NOM_SEG, C_APE_PAT||' '||C_APE_MAT );
                                    
                                    -- Inserta o actualiza en Saldo_cliente
                                    IF V_CONTB2B_SALDO=0 THEN
                                       --Registra ingreso de cliente en Saldos
                                       INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib,admpn_saldo_cc,admpn_saldo_ib,admpc_estpto_cc,admpc_estpto_ib)
                                       VALUES (PCLUB.admpt_sld_cl_sq.nextval, C_CUR_CUENTA, V_CODCLIIB, 0, 0, '', 'A' );
                                    ELSE
                                       UPDATE PCLUB.admpt_saldos_cliente
                                          SET
                                              admpn_cod_cli_ib = V_CODCLIIB ,
                                              admpn_saldo_ib = 0,
                                              admpc_estpto_ib = 'A'
                                        WHERE  admpv_cod_cli=C_CUR_CUENTA ;
                                    END IF;
                                  EXCEPTION
                                       WHEN NO_DATA_FOUND THEN
                                          if V_CODCLIIB =-1 then
                                             update PCLUB.admpt_tmp_accamo_ib 
                                             set    admpc_cod_error='28',
                                                    admpv_msje_error = 'No se encontró la secuencia admpt_cli_ib_sq.nextval)'
                                             where  admpc_cod_trans= '1' and 
                                                    admpv_tipo_doc=C_TIPO_DOC and 
                                                    admpv_num_doc=C_NUM_DOC; 
                                             commit;
                                           else                                                    
                                               if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                                 update PCLUB.admpt_tmp_accamo_ib 
                                                 set    admpc_cod_error='29',
                                                        admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                                 where  admpc_cod_trans= '1' and 
                                                        admpv_tipo_doc=C_TIPO_DOC and 
                                                        admpv_num_doc=C_NUM_DOC; 
                                                 commit;
                                                end if;
                                           end if;
                                         WHEN OTHERS THEN
                                                  ROLLBACK TO SAVEPOINT BQ8;
                                                  V_ERROR:=SUBSTR(SQLERRM,1,400);
                                                  update PCLUB.admpt_tmp_accamo_ib 
                                                  set    admpv_msje_error = V_ERROR
                                                  where admpc_cod_trans= '1' and 
                                                        admpv_tipo_doc=C_TIPO_DOC and 
                                                        admpv_num_doc=C_NUM_DOC and 
                                                        admpv_nom_arch=C_NOM_ARCH ;  
                                 
                                 END;
                               end if; 
                             END IF;
                           END;
                         ELSE --El teléfono no pertenece al cliente
                             BEGIN
                                -- Parametros
                                SELECT nvl(PCLUB.admpt_cli_ib_sq.nextval,-1) INTO V_CODCLIIB FROM dual;
                                SELECT nvl(admpv_cod_tpdoc,'-1') INTO V_TIPO_DOC_CLARO FROM admpt_tipo_doc WHERE admpv_dsc_docum=V_TIPO_DOC_EQUIV;

                                SAVEPOINT BQ6;                              
                                -- Registra Cliente IB
                                INSERT INTO PCLUB.admpt_clienteib
                                  (admpn_cod_cli_ib, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpv_cod_cli, admpd_fec_act, admpc_estado, admpn_flg_debi, admpn_flg_num, admpn_bono_act, admpv_nom_cli, admpv_ape_cli)
                                VALUES
                                 (V_CODCLIIB, V_TIPO_DOC_CLARO, C_NUM_DOC, '','', C_FEC_ACT , 'A', 0, 0, 0, C_NOM_PRI||' '||C_NOM_SEG,C_APE_PAT||' '||C_APE_MAT );
                                 
                                -- Inserta registro en la tabla Saldos_cliente
                                INSERT INTO PCLUB.admpt_saldos_cliente (admpn_id_saldo, admpv_cod_cli,admpn_cod_cli_ib,admpn_saldo_cc,admpn_saldo_ib,admpc_estpto_cc,admpc_estpto_ib)
                                VALUES (PCLUB.admpt_sld_cl_sq.nextval, '', V_CODCLIIB, 0, 0,'', 'A' );
                                
                                -- Inserta registro en la tabla Aux
                                INSERT INTO PCLUB.admpt_aux_accamo_ib (admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpv_num_linea, admpd_fec_oper, admpv_nom_arch)
                                VALUES ( 1, C_TIPO_DOC, C_NUM_DOC ,C_NUM_LINEA, K_FECHA, C_NOM_ARCH);
                                COMMIT;
                                
                                -- Registra mensaje en el temporal
                                update PCLUB.admpt_tmp_accamo_ib
                                set 
                                       admpc_cod_error = '22',
                                       admpv_msje_error = 'El número enviado no pertenece al cliente'
                                where   admpc_cod_trans= '1' and 
                                         admpv_tipo_doc=C_TIPO_DOC and 
                                         admpv_num_doc=C_NUM_DOC;
                                commit;
                             EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    if V_CODCLIIB =-1 then
                                       update PCLUB.admpt_tmp_accamo_ib 
                                       set    admpc_cod_error='28',
                                              admpv_msje_error = 'No se encontró la secuencia admpt_cli_ib_sq.nextval)'
                                       where  admpc_cod_trans= '1' and 
                                              admpv_tipo_doc=C_TIPO_DOC and 
                                              admpv_num_doc=C_NUM_DOC; 
                                       commit;
                                     else                                                    
                                         if V_TIPO_DOC_CLARO ='-1' or V_TIPO_DOC_CLARO is null or V_TIPO_DOC_EQUIV='-1' or V_TIPO_DOC_EQUIV is null then
                                           update PCLUB.admpt_tmp_accamo_ib 
                                           set    admpc_cod_error='29',
                                                  admpv_msje_error = 'No se encontró el tipo de documento equivalente en la tabla admpt_tipo_doc'
                                           where  admpc_cod_trans= '1' and 
                                                  admpv_tipo_doc=C_TIPO_DOC and 
                                                  admpv_num_doc=C_NUM_DOC; 
                                           commit;
                                          end if;
                                     end if;
                                WHEN OTHERS THEN
                                    ROLLBACK TO SAVEPOINT BQ6;
                                    V_ERROR:=SUBSTR(SQLERRM,1,400);
                                    update PCLUB.admpt_tmp_accamo_ib 
                                    set    admpv_msje_error = V_ERROR
                                    where admpc_cod_trans= '1' and 
                                          admpv_tipo_doc=C_TIPO_DOC and 
                                          admpv_num_doc=C_NUM_DOC and 
                                          admpv_nom_arch=C_NOM_ARCH ;  
                                                                   
                             END;
                         END IF;

                       EXCEPTION
                                       
                        WHEN NO_USERS_CLIENTE THEN
                           update PCLUB.admpt_tmp_accamo_ib
                                  set  admpc_cod_error = '21',
                                       admpv_msje_error = 'Error en la devolución del cursor sp_datos_cliente ' || SUBSTR(C_CUR_MSGERROR,1,200)
                                  where admpc_cod_trans= '1' and 
                                        admpv_tipo_doc=C_TIPO_DOC and 
                                        admpv_num_doc=C_NUM_DOC and 
                                        admpv_nom_arch=C_NOM_ARCH ;
                           commit;
                        WHEN OTHERS THEN
                           V_ERROR:=SUBSTR(SQLERRM,1,400);
                           update PCLUB.admpt_tmp_accamo_ib
                                  set   admpc_cod_error='ORA',
                                        admpv_msje_error = V_ERROR                                  
                                  where admpc_cod_trans= '1' and admpv_tipo_doc=C_TIPO_DOC and admpv_num_doc=C_NUM_DOC ;
                           commit;
                       END ;
                     CLOSE C_CUR_DATOS_CLIE;
                     --END LOOP; --
                  END IF; --trim(C_NUM_LINEA)
            END IF;  -- (v_cont=0)

        EXCEPTION          
          WHEN OTHERS THEN
             k_coderror:=SQLCODE;
             k_descerror:=SUBSTR(SQLERRM,1,400);
        END;
        -- Fin del Bloque 1
    FETCH CLIENTEIB INTO C_COD_TRANS, C_TIPO_DOC, C_NUM_DOC, C_NOM_PRI, C_NOM_SEG, C_APE_PAT, C_APE_MAT, C_NUM_LINEA, C_FEC_ACT, C_ACEP_BONO, C_FEC_OPER, C_NOM_ARCH, C_COD_ERROR, C_MSJE_ERROR;

      END LOOP; --DEL WHILE
   CLOSE CLIENTEIB;
   
EXCEPTION
  WHEN others then
   K_CODERROR:=SQLCODE;
   K_DESCERROR:=SUBSTR(SQLERRM,1,400);
      
END ADMPSI_ACTIV_IB;


PROCEDURE ADMPSI_AGR_PTIB( K_CODCLIENTEIB IN NUMBER, K_CODCLIENTECC IN VARCHAR2, K_CODCONCEPTO IN VARCHAR2,K_PUNTOSIGNO IN NUMBER, K_NOMARCHIVO IN VARCHAR2, K_TIPOP IN CHAR,K_ESTADO IN CHAR)
IS
/****************************************************************
'* Nombre SP           :  ADMPSI_AGR_PTIB
'* Propósito           :  Insertar la transaccion en la tabla Kardex y en Saldos Clientes
'* Input               :  C_CODCLIENTEIB, C_CODCLIENTECC  
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  (Venkizmet) Sofia Khlebnikov       
'* Fec Creación        :
'* Fec Actualización   :  03/09/2010
'****************************************************************/

V_IDKARDEX NUMBER;

BEGIN
  /*genera secuencial de kardex*/

  SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;
  INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                  ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                  ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
  VALUES(V_IDKARDEX,K_CODCLIENTEIB,K_CODCLIENTECC,K_CODCONCEPTO,
         TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'),K_PUNTOSIGNO,K_NOMARCHIVO,K_TIPOP,'I',K_PUNTOSIGNO, K_ESTADO); 

  UPDATE PCLUB.ADMPT_SALDOS_CLIENTE SET    ---ACTUALIZACION DE LA TABLA SALDOS_CLIENTE
         ADMPN_SALDO_IB=K_PUNTOSIGNO+( SELECT NVL(ADMPN_SALDO_IB,0)FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                    WHERE ADMPN_COD_CLI_IB=K_CODCLIENTEIB),
         ADMPC_ESTPTO_IB=K_ESTADO
  WHERE ADMPN_COD_CLI_IB=K_CODCLIENTEIB;


END ADMPSI_AGR_PTIB;


PROCEDURE ADMPSI_CAMPA_IB (K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2)
IS

/****************************************************************
'* Nombre SP           :  ADMPSI_CAMPANA
'* Propósito           :  Asignar puntos IB por campaña
'* Input               :  K_FECHA
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  (Venkizmet) Sofia Khlebnikov
'* Fec Creación        :  10/08/2010
'* Fec Actualización   :  05/09/2010
'****************************************************************/

V_PUNTOSIGNO NUMBER;
V_TIPOP CHAR(1);
V_CODCONCEPTO VARCHAR2(2);
V_ESTADO CHAR(1);
V_CODIB NUMBER;     /*dato de saldos cliente*/
V_REGCLI NUMBER;
V_TPODOCIBEQ VARCHAR2(20);
V_CODIBER NUMBER;



C_CODCLIENTEIB VARCHAR2(40);   /* datos del cursor*/
C_CODCLIENTECC VARCHAR2(40);
C_TIPODOCUMENTO VARCHAR2(20);
C_NUMDOCUMENTO VARCHAR2(20);
C_SIGNO CHAR(1);
C_PUNTOS NUMBER;
C_FECPROCESO DATE;
C_NOMARCHIVO VARCHAR2(150);
C_CODTRANSAC CHAR(3);

 CURSOR CLIENTEIBCAM IS
  SELECT c.ADMPN_COD_CLI_IB,
         a.ADMPV_TIPO_DOC,
         a.ADMPV_NUM_DOC,
         a.ADMPC_SIGNO,
         a.ADMPN_PUNTOS,
         a.ADMPD_FEC_OPER,
         NVL(a.ADMPV_NOM_ARCH,null),
         a.ADMPC_COD_TRANS
  FROM PCLUB.ADMPT_TMP_FACADE_IB a, PCLUB.ADMPT_CLIENTEIB c
  WHERE a.ADMPD_FEC_OPER=K_FECHA  ---to_date(K_FECHA,'MM/DD/YYYY')
        AND c.ADMPC_ESTADO<>'B'
        AND a.ADMPC_COD_TRANS='5'
        AND TRIM (a.ADMPV_NUM_DOC) = TRIM (c.ADMPV_NUM_DOC)                  -- SSC 27102010 - Por si viene con espacios en blanco
        AND a.ADMPC_COD_ERROR IS NULL;


BEGIN

  OPEN CLIENTEIBCAM;
  FETCH CLIENTEIBCAM INTO C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_SIGNO, C_PUNTOS,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;
  WHILE CLIENTEIBCAM %FOUND LOOP

  SELECT COUNT(*)INTO V_REGCLI FROM PCLUB.ADMPT_AUX_FACADE_IB
  WHERE ADMPV_TIPO_DOC=C_TIPODOCUMENTO
       AND ADMPV_NUM_DOC=C_NUMDOCUMENTO
       AND ADMPD_FEC_OPER=C_FECPROCESO
       AND ADMPV_NOM_ARCH=C_NOMARCHIVO
       AND ADMPC_COD_TRANS=C_CODTRANSAC;
       
       
   BEGIN
    SELECT NVL(ADMPV_COD_TPDOC,NULL) INTO V_TPODOCIBEQ
    FROM PCLUB.admpt_tipo_doc
    WHERE ADMPV_COD_EQUIV= C_TIPODOCUMENTO;
    EXCEPTION
      WHEN OTHERS THEN
         V_TPODOCIBEQ:=null;
    END;      
       
   BEGIN
   SELECT NVL(ADMPN_COD_CLI_IB,0) INTO V_CODIBER
   FROM PCLUB.ADMPT_CLIENTEIB
   WHERE ADMPN_COD_CLI_IB = C_CODCLIENTEIB;                                  -- SSC 27102010 Tenemos la PK
          -- SSC 27102010 -  ADMPV_TIPO_DOC= V_TPODOCIBEQ
          -- SSC 27102010 - AND ADMPV_NUM_DOC=C_NUMDOCUMENTO;
   EXCEPTION
      WHEN OTHERS THEN
         V_CODIBER:=0;
   END; 
   

  /* verifica si el registro no existe en la tabla auxiliar*/
   IF (V_REGCLI=0 AND V_CODIBER <> 0) THEN

    BEGIN

  /*  verifica el signo de los puntos y cambio de tipo de operacion(entrada/salida)*/
     IF ( C_SIGNO='-') THEN
        V_PUNTOSIGNO:= C_PUNTOS*(-1);
        V_TIPOP :='S';
     ELSE  V_PUNTOSIGNO:= C_PUNTOS;
          V_TIPOP:='E';
     END IF;


  /* busca el codigoClaro del clienteIB*/


     BEGIN  
        SELECT  NVL(ADMPV_COD_CLI,NULL) INTO C_CODCLIENTECC
        FROM PCLUB.ADMPT_CLIENTEIB                  -- SELECT EL CODIGO DEL CLIENTE CLARO
        WHERE ADMPN_COD_CLI_IB = C_CODCLIENTEIB;
              -- SSC 27102010 Para hacer mas eficiente el query y evitar los espacios en blanco hacemos directamente la llamada con la PK
              -- SSC 27102010 ADMPV_TIPO_DOC= V_TPODOCIBEQ        --- DE LA TABLA CLIENTE
              -- SSC 27102010 AND ADMPV_NUM_DOC= C_NUMDOCUMENTO;
        EXCEPTION
          WHEN OTHERS THEN
             C_CODCLIENTECC:=NULL;
     END;


     BEGIN
        SELECT NVL(ADMPV_COD_CPTO,NULL)  INTO V_CODCONCEPTO
        FROM PCLUB.ADMPT_CONCEPTO
        WHERE UPPER(ADMPV_DESC) LIKE '%CAMPAÑA TC%';
        EXCEPTION
          WHEN OTHERS THEN
             V_CODCONCEPTO:=null;
     END;

     BEGIN
        SELECT NVL(ADMPN_COD_CLI_IB,NULL)  INTO V_CODIB
        FROM PCLUB.ADMPT_SALDOS_CLIENTE
        WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
        exception
          when OTHERS then
            V_CODIB:=null;
     END;
     
     IF(V_CODIB IS NOT NULL) THEN

   /* verifico el estado de los puntos*/
       BEGIN
     
          BEGIN
            SELECT NVL(ADMPC_ESTPTO_IB,NULL)  INTO V_ESTADO
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
            exception
              when OTHERS then
                V_ESTADO:=null;
          END;
    


        /* INSERTA EN LA TABLA KARDEX Y ACTUALIZA EN LA TABLA SALDOS_CLIENTE POR CAMPAÑA*/

          PKG_CLAROCLUB.ADMPSI_AGR_PTIB(C_CODCLIENTEIB,C_CODCLIENTECC ,V_CODCONCEPTO ,
                                            V_PUNTOSIGNO,C_NOMARCHIVO,V_TIPOP,V_ESTADO);
                                            
          INSERT INTO PCLUB.ADMPT_AUX_FACADE_IB (ADMPC_COD_TRANS,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                                               ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
          VALUES(C_CODTRANSAC,C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO);                                  
                                          
       END;
     END IF;

     COMMIT;
  
    END;
   END IF; /* FIN DE VERIFICA SI EXISTE EL REGISTRO EN AUX_FACADE*/

  FETCH CLIENTEIBCAM INTO  C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO, C_SIGNO, C_PUNTOS,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;

  END LOOP;
  CLOSE CLIENTEIBCAM;

K_CODERROR:=0; -- Correcto
K_DESCERROR:='';

EXCEPTION

 WHEN OTHERS THEN
   K_CODERROR:=SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,400);
   ROLLBACK;

  
END ADMPSI_CAMPA_IB ; ---PCLUB.admpsi_campana;

PROCEDURE ADMPSI_CANCE_IB (K_FECHA IN DATE, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
IS
/****************************************************************
'* Nombre SP           :  ADMPSI_CANCELTC
'* Propósito           :  Eliminacion de puntos IB por cancelacion de tarjeta de credito IB
'* Input               :  K_FECHA
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          : (Venkizmet) Sofia Khlebnikov
'* Fec Creación        : 12/08/2010
'* Fec Actualización   :  04/09/2010
'****************************************************************/

V_CODCONCEPTO VARCHAR2(2);
V_SALDO NUMBER;
V_CODIB NUMBER;
V_REGCLI NUMBER;  /* DEVUELVE 1 SI EXISTEEL REGISTRO EN TABLA AUX  0 SI NO */
V_TPODOCIBEQ VARCHAR2(20);
V_CODIBS NUMBER;
V_CODIBER NUMBER;

C_CODCLIENTEIB NUMBER;
C_TIPODOCUMENTO VARCHAR2(20);
C_NUMDOCUMENTO VARCHAR2(20);
C_CODCLIENTECC VARCHAR2(40);
C_FECPROCESO DATE;
C_NOMARCHIVO VARCHAR2(150);
C_CODTRANSAC CHAR(3);


  CURSOR CLIENTEIBC  IS
   SELECT c.ADMPN_COD_CLI_IB,
          a.ADMPV_TIPO_DOC,
          a.ADMPV_NUM_DOC,
          a.ADMPD_FEC_OPER,
          a.ADMPV_NOM_ARCH,
          a.ADMPC_COD_TRANS


   FROM PCLUB.ADMPT_TMP_ACCAMO_IB  a, PCLUB.ADMPT_CLIENTEIB c
   WHERE a.ADMPD_FEC_OPER=K_FECHA--to_date(K_FECHA,'MM/DD/YYYY')
         AND c.ADMPC_ESTADO<>'B'
         AND a.ADMPC_COD_TRANS='2'
         AND a.ADMPV_NUM_DOC=c.ADMPV_NUM_DOC
         AND a.ADMPC_COD_ERROR IS NULL ;

------------------ejecucion del cursor----------------------

BEGIN

  OPEN CLIENTEIBC;
  FETCH CLIENTEIBC INTO C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;
     

  WHILE CLIENTEIBC%FOUND LOOP

     SELECT COUNT(*)INTO V_REGCLI FROM PCLUB.ADMPT_AUX_ACCAMO_IB
     WHERE ADMPV_TIPO_DOC=C_TIPODOCUMENTO
           AND ADMPV_NUM_DOC=C_NUMDOCUMENTO
           AND ADMPD_FEC_OPER=C_FECPROCESO
           AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO
           AND ADMPC_COD_TRANS=C_CODTRANSAC;
           
     BEGIN
        SELECT NVL(ADMPV_COD_TPDOC,NULL) INTO V_TPODOCIBEQ
        FROM PCLUB.admpt_tipo_doc
        WHERE ADMPV_COD_EQUIV= C_TIPODOCUMENTO;
        EXCEPTION
          WHEN OTHERS THEN
             V_TPODOCIBEQ:=null;
     END;      
           
     BEGIN
        SELECT  NVL(ADMPN_COD_CLI_IB,0) INTO V_CODIBER
        FROM PCLUB.ADMPT_CLIENTEIB
        WHERE  ADMPV_TIPO_DOC= V_TPODOCIBEQ
               AND ADMPV_NUM_DOC=C_NUMDOCUMENTO;
        EXCEPTION
          WHEN OTHERS THEN
             V_CODIBER:=0;
     END;   

  
     IF (V_REGCLI=0 AND V_CODIBER <> 0) THEN

       BEGIN
      ---  busca el codigo del cliente claro------
      
          BEGIN
            SELECT NVL(ADMPV_COD_CLI,NULL) INTO C_CODCLIENTECC
            FROM PCLUB.ADMPT_CLIENTEIB
            WHERE ADMPV_TIPO_DOC=V_TPODOCIBEQ
                  AND ADMPV_NUM_DOC=C_NUMDOCUMENTO;
            EXCEPTION
                WHEN OTHERS THEN
                   C_CODCLIENTECC:=NULL;
          END;      

      
      /* insert en la tabla kardex por cancelacion de la TC*/

          BEGIN
            SELECT NVL(ADMPV_COD_CPTO,NULL)  into V_CODCONCEPTO
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE UPPER(ADMPV_DESC) LIKE '%CANC%'; 
            exception
                when OTHERS then
                   V_CODCONCEPTO:=null;
          END; 
        
      
          BEGIN
            SELECT NVL(ADMPN_SALDO_IB,0) INTO V_SALDO
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
            exception
                when OTHERS then
                   V_SALDO:=0;
          END; 
         
          IF(V_SALDO<0) THEN
            V_SALDO:=V_SALDO;
          ELSE
            IF(V_SALDO>0) THEN
              V_SALDO:=V_SALDO*(-1);
            END IF;    
          END IF; 
          
          INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                    ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS,
                                    ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO,
                                    ADMPN_SLD_PUNTO, ADMPC_ESTADO)
          VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, C_CODCLIENTEIB, C_CODCLIENTECC,V_CODCONCEPTO,
                  TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'),V_SALDO,
                  C_NOMARCHIVO,'S','I',0,'C');

        
          BEGIN
            SELECT COUNT(ADMPN_COD_CLI_IB) INTO V_CODIB
            FROM PCLUB.ADMPT_KARDEX
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
            exception
                when OTHERS then
                   V_CODIB:=0;
          END;

          IF(V_CODIB <> 0) THEN
           BEGIN
            UPDATE PCLUB.admpt_kardex SET    ----actualizacion de la tabla kardex
                   ADMPN_SLD_PUNTO=0,
                   ADMPC_ESTADO='C'
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB
                  AND ADMPC_TPO_PUNTO='I'
                  AND ADMPN_SLD_PUNTO>0;
           END;
          END IF;      
      
          BEGIN
            SELECT NVL(ADMPN_COD_CLI_IB,0) INTO V_CODIBS
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
            exception
                WHEN OTHERS THEN
                   V_CODIBS:=0;
          END;
          
          IF (V_CODIBS <> 0) THEN
           BEGIN
            UPDATE PCLUB.admpt_saldos_cliente SET   -----actualizacion de la tabla saldos_cliente
                   ADMPN_SALDO_IB=0,
                   ADMPC_ESTPTO_IB='C'
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
           END;
          END IF;


          UPDATE PCLUB.admpt_clienteib SET       ----actualizacion de la tabla clienteIB
                 ADMPC_ESTADO='B'
          WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;


          INSERT INTO PCLUB.ADMPT_AUX_ACCAMO_IB (ADMPC_COD_TRANS,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                                                 ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
          VALUES(C_CODTRANSAC,C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO);


        COMMIT;
      
       END;
      
     END IF;  /* FIN DE VERIFICA DEL REGISTRO EN TABLA AUX_ACCAMO*/

  FETCH CLIENTEIBC INTO  C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;

  END LOOP;
    
  CLOSE CLIENTEIBC;

  K_CODERROR:=0; -- Correcto
  K_DESCERROR:='';

EXCEPTION

 WHEN OTHERS THEN
   K_CODERROR:=SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,400);
   ROLLBACK;

  
END ADMPSI_CANCE_IB;

procedure ADMPSI_DEBITOIB(K_FECHA IN DATE, K_NOM_ARCH IN VARCHAR2, K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)  
is

/****************************************************************
'* Nombre SP           :  ADMPSI_DEBITOIB
'* Propósito           :  Activar servicio para los clientes que hicieron debito automatico con su tarjeta de credito IB
'* Input               :  K_FECHA, K_NOM_ARCH
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  (Venkizmet) Rossana Janampa       
'* Fec Creación        :
'* Fec Actualización   :  03/09/2010
'****************************************************************/

  TYPE CurClaro_DatosCliente IS REF CURSOR;
  C_CUR_DATOS_CLIE CurClaro_DatosCliente;
  C_CUR_DAT_LINEA CurClaro_DatosCliente;

  CURSOR CLIENTEIB1 IS
    SELECT admpv_cod_cli
      FROM PCLUB.admpt_clienteib
     WHERE admpn_flg_debi = 1
       AND admpv_cod_cli NOT IN
           (SELECT admpv_cod_cli
              FROM PCLUB.admpt_tmp_debito_ib
             WHERE admpd_fec_oper = K_FECHA
               AND  admpn_monto_deb= admpn_monto_fac 
               AND admpv_nom_arch=K_NOM_ARCH 
               AND admpv_msje_error IS NULL);

  CURSOR CLIENTEIB2 IS
    SELECT admpv_cod_cli
      FROM PCLUB.admpt_tmp_debito_ib
     WHERE admpd_fec_oper = K_FECHA
       AND admpv_msje_error IS NULL
       AND admpn_monto_deb= admpn_monto_fac
       AND admpv_cod_cli NOT IN
           (SELECT admpv_cod_cli
              FROM PCLUB.admpt_clienteib
             WHERE admpn_flg_debi = 1 
            );

  V_COD_CLIENTECC1 VARCHAR2(40);
  V_COD_CLIENTECC2 VARCHAR2(40);
  V_NUM_LINEA VARCHAR2(20);
  V_PLAN_CODE_SERV number(4);
  V_PLAN_CODE_PQ               NUMBER;
  --V_R_FUN029                   VARCHAR2(100); 
  V_COD_PENDIENTE              NUMBER;
  
  C_CUR_CUENTA         varchar2(40);
  C_CUR_TIP_DOC      varchar2(20);
  C_CUR_NUM_DOC      varchar2(30);
  C_CUR_COD_ID                integer;
  C_CUR_CICLO_FAC             varchar2(2);
  C_CUR_CODIGO_TIPO_CLIENTE   varchar2(10);
  C_CUR_TIPO_CLIENTE          varchar2(30);

  C_CUR2_TELEFONO             VARCHAR2(63);
  C_CUR2_PLAN                 VARCHAR2(30);
  C_CUR2_FLAG_PLATAFORMA      CHAR(1);
  C_CUR2_CODIGO_PLAN_TARIFARIO     NUMBER;
  
  C_CUR_SQLERROR VARCHAR2(400);

  ERROR_ACTIVACION_REGISTRO      EXCEPTION;
  NO_USERS_CLIENTE               EXCEPTION;
  NO_USERS_LINEA                 EXCEPTION;

BEGIN
  
  -- Valida Archivo
  BEGIN
      update PCLUB.admpt_tmp_debito_ib
         set 
             admpc_cod_error = '12',
             admpv_msje_error = 'El código de cliente es obligatorio'
       where admpv_cod_cli is null
             and admpd_fec_oper=K_FECHA ;
       commit;
       
       update PCLUB.admpt_tmp_debito_ib
         set 
             admpc_cod_error = '38',
             admpv_msje_error = 'El Monto Facturado y el Monto Debitado son datos obligatorios'
       where admpn_monto_fac is null or admpn_monto_deb is null and length(admpv_msje_error)>0
             and admpd_fec_oper=K_FECHA;
       commit;
       
       update PCLUB.admpt_tmp_debito_ib
         set 
             admpc_cod_error = '39',
             admpv_msje_error = 'No se procesó porque el monto facturado es diferente al monto debitado'
       where admpn_monto_fac <> admpn_monto_deb  and length(admpv_msje_error)>0
             and admpd_fec_oper=K_FECHA;
       commit;             
       
  END;      

  OPEN CLIENTEIB1; -- Quitar Servicio
  FETCH CLIENTEIB1 INTO V_COD_CLIENTECC1;
  WHILE CLIENTEIB1 %FOUND LOOP
       BEGIN
           -- Parametros
           Select admpv_num_linea into V_NUM_LINEA from PCLUB.admpt_clienteib where admpv_cod_cli = V_COD_CLIENTECC1;
           SELECT nvl(admpt_serv_pen_sq.nextval,-1) INTO V_COD_PENDIENTE FROM dual;
           
           
           ADMPSS_DAT_CLIE('',V_NUM_LINEA, C_CUR_SQLERROR, C_CUR_DATOS_CLIE);
           
           -- PCLUB.PKG_CLAROCLUB.sp_datos_clien('',V_NUM_LINEA, C_CUR_SQLERROR, C_CUR_DATOS_CLIE);
            
           IF LENGTH(C_CUR_SQLERROR) <>0 THEN
             RAISE NO_USERS_CLIENTE; -- CLARO: consultar como devuelve C_CUR_SQLERROR en caso no se encuentre el numero consultado en la BD
           END IF;
           
           -- El cursor retorno datos validos
           FETCH C_CUR_DATOS_CLIE INTO
           C_CUR_CUENTA,       C_CUR_TIP_DOC,                C_CUR_NUM_DOC,  C_CUR_COD_ID,
           C_CUR_CICLO_FAC,    C_CUR_CODIGO_TIPO_CLIENTE,    C_CUR_TIPO_CLIENTE;    
           
           If C_CUR_COD_ID is null then
             raise NO_USERS_CLIENTE;
           end if;
             
           -- Con el codigo de contrato obtener el tipo de Plan con el SP de Claro
           ADMPSS_DAT_LINE(C_CUR_COD_ID, C_CUR_DAT_LINEA);

           FETCH C_CUR_DAT_LINEA INTO C_CUR2_TELEFONO, C_CUR2_PLAN, C_CUR2_FLAG_PLATAFORMA, C_CUR2_CODIGO_PLAN_TARIFARIO;

           -- Si se obtuvo informacion en el cursor Datos_Linea
           IF (C_CUR_DAT_LINEA%rowcount=0)   THEN
               RAISE NO_USERS_LINEA;
           END IF;

           -- Parametros: El codigo del servicio segun el plan del cliente
           --SELECT admpn_cod_serv, admpn_cod_paq INTO V_PLAN_CODE_SERV, V_PLAN_CODE_PQ FROM admpt_tipo_plan WHERE admpv_des_plan=C_CUR2_PLAN;        
           SELECT admpn_cod_serv, admpn_cod_paq INTO V_PLAN_CODE_SERV, V_PLAN_CODE_PQ FROM admpt_tipo_plan WHERE admpn_cod_plan=C_CUR2_CODIGO_PLAN_TARIFARIO;
           
           savepoint inicio_trans;
           
           /*begin
             -- V_R_FUN029 := TIM.tfun029_register_service_sp@DBL_BSCS(C_CUR_COD_ID, V_NUM_LINEA,'', V_PLAN_CODE_SERV, V_PLAN_CODE_PQ,'2')  ;
             V_R_FUN029 := TIM.tfun029_register_service_sp@DBL_BSCS(NULL, V_NUM_LINEA, NULL, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ, 2)  ;
             commit;
           end;
           
           IF To_number(trim(V_R_FUN029))<0 THEN
             RAISE ERROR_ACTIVACION_REGISTRO;
           END IF;
           */
           
           -- Inserta en la tabla ADMPT_SERV_PEN
           insert into admpt_serv_pend
             (admpn_id_fila, admpv_num_linea, admpn_sn_code, admpn_sp_code, admpc_estado, admpd_fec_reg, adpmv_accion)
           values (V_COD_PENDIENTE,V_NUM_LINEA, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ, 'P', TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'),'2');
                      
           update PCLUB.admpt_clienteib set admpn_flg_debi = 0 where admpv_cod_cli = V_COD_CLIENTECC1 ;
           
           -- Agrega a la tabla auxiliar
           insert into PCLUB.admpt_aux_debito_ib (admpd_fec_oper, admpv_nom_arch, admpv_cod_cli)
           values (K_FECHA, K_NOM_ARCH, V_COD_CLIENTECC1);

           commit;
           CLOSE C_CUR_DATOS_CLIE;
           CLOSE C_CUR_DAT_LINEA;

       EXCEPTION
 
          WHEN NO_DATA_FOUND THEN 
             IF V_PLAN_CODE_SERV IS NULL OR V_PLAN_CODE_PQ IS NULL then
                insert into admpt_tmp_debito_ib
                  (admpv_cod_cli, admpv_num_fact, admpn_monto_fac, admpn_monto_pag, admpn_monto_deb, admpd_fec_oper, admpv_nom_arch, admpc_cod_error, admpv_msje_error)
                values
                 (V_COD_CLIENTECC1, null, null, null, null, K_FECHA, K_NOM_ARCH, '23', 'El codigo de plan no se encuentra en la tabla admpt_tipo_plan, no se activo o desactivo el servicio');                                   
                commit;
             else
               if V_NUM_LINEA is null then 
                  insert into admpt_tmp_debito_ib
                    (admpv_cod_cli, admpv_num_fact, admpn_monto_fac, admpn_monto_pag, admpn_monto_deb, admpd_fec_oper, admpv_nom_arch, admpc_cod_error, admpv_msje_error)
                  values
                   (V_COD_CLIENTECC1, null, null, null, null, K_FECHA, K_NOM_ARCH, '34', 'El número enviado para el débito automático no se encuentra registrado en la tabla admpt_clienteib');                                   
                  commit;
               end if;  
             end if;                              
             
          WHEN NO_USERS_CLIENTE THEN
            if C_CUR_SQLERROR is  null or LENGTH(C_CUR_SQLERROR)>0 then
               insert into admpt_tmp_debito_ib
                 (admpv_cod_cli, admpv_num_fact, admpn_monto_fac, admpn_monto_pag, admpn_monto_deb, admpd_fec_oper, admpv_nom_arch, admpc_cod_error, admpv_msje_error)
               values
                 (V_COD_CLIENTECC1, null, null, null, null, K_FECHA, K_NOM_ARCH, '21', 'Error en la devolución del cursor sp_datos_cliente, no se pudo desactivar el debito automatico al cliente');
               commit;
             end if;
               
          WHEN NO_USERS_LINEA THEN
             insert into admpt_tmp_debito_ib
               (admpv_cod_cli, admpv_num_fact, admpn_monto_fac, admpn_monto_pag, admpn_monto_deb, admpd_fec_oper, admpv_nom_arch, admpc_cod_error, admpv_msje_error)
             values
               (V_COD_CLIENTECC1, null, null, null, null, K_FECHA, K_NOM_ARCH, '20', 'Error en la devolución del cursor sp_datos_linea');
             commit;
            
          WHEN OTHERS THEN
             rollback to inicio_trans;
             -- k_coderror:=SQLCODE;
             k_descerror:=SUBSTR(SQLERRM,1,400);
             insert into admpt_tmp_debito_ib
               (admpv_cod_cli, admpv_num_fact, admpn_monto_fac, admpn_monto_pag, admpn_monto_deb, admpd_fec_oper, admpv_nom_arch, admpc_cod_error, admpv_msje_error)
             values
               (V_COD_CLIENTECC1, null, null, null, null, K_FECHA, K_NOM_ARCH, '', k_descerror);
             commit;
                           
        END;
      FETCH CLIENTEIB1 INTO V_COD_CLIENTECC1;
  END LOOP;
  CLOSE CLIENTEIB1;

/* ********************************************************************************************** */

  OPEN CLIENTEIB2;
  FETCH CLIENTEIB2 INTO V_COD_CLIENTECC2;
  WHILE CLIENTEIB2 %FOUND LOOP
    BEGIN
       -- Parametros
       Select admpv_num_linea into V_NUM_LINEA from PCLUB.admpt_clienteib where admpv_cod_cli = V_COD_CLIENTECC2;
       SELECT nvl(admpt_serv_pen_sq.nextval,-1) INTO V_COD_PENDIENTE FROM dual;
       
       ADMPSS_DAT_CLIE('',V_NUM_LINEA, C_CUR_SQLERROR, C_CUR_DATOS_CLIE);
       -- PCLUB.PKG_CLAROCLUB.sp_datos_clien('',V_NUM_LINEA, C_CUR_SQLERROR, C_CUR_DATOS_CLIE);

       IF LENGTH(C_CUR_SQLERROR) <>0 THEN
         RAISE NO_USERS_CLIENTE; -- CLARO: consultar como devuelve C_CUR_SQLERROR en caso no se encuentre el numero consultado en la BD
       END IF;

       FETCH C_CUR_DATOS_CLIE INTO
       C_CUR_CUENTA,       C_CUR_TIP_DOC,                C_CUR_NUM_DOC,  C_CUR_COD_ID,
       C_CUR_CICLO_FAC,    C_CUR_CODIGO_TIPO_CLIENTE,    C_CUR_TIPO_CLIENTE;    

       If C_CUR_COD_ID is null then
          raise NO_USERS_CLIENTE;
       end if;
       
       -- Con el codigo de contrato obtener el tipo de Plan con el SP de Claro
       ADMPSS_DAT_LINE(C_CUR_COD_ID, C_CUR_DAT_LINEA);
       
       FETCH C_CUR_DAT_LINEA INTO C_CUR2_TELEFONO, C_CUR2_PLAN, C_CUR2_FLAG_PLATAFORMA, C_CUR2_CODIGO_PLAN_TARIFARIO;

       -- Parametros: El codigo del servicio segun el plan del cliente
        --SELECT admpn_cod_serv, admpn_cod_paq INTO V_PLAN_CODE_SERV, V_PLAN_CODE_PQ FROM PCLUB.admpt_tipo_plan WHERE admpv_des_plan=C_CUR2_PLAN;           
        SELECT admpn_cod_serv, admpn_cod_paq INTO V_PLAN_CODE_SERV, V_PLAN_CODE_PQ FROM admpt_tipo_plan WHERE admpn_cod_plan=C_CUR2_CODIGO_PLAN_TARIFARIO;
        savepoint inicio_trans;
       
        /*begin
         -- V_R_FUN029 := TIM.tfun029_register_service_sp@DBL_BSCS(C_CUR_COD_ID, V_NUM_LINEA,'', V_PLAN_CODE_SERV, V_PLAN_CODE_PQ,'1')  ;
          V_R_FUN029 := TIM.tfun029_register_service_sp@DBL_BSCS(NULL, V_NUM_LINEA, NULL, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ, 1)  ;
          commit;
         end;
                
        IF To_number(trim(V_R_FUN029))<0 THEN
          RAISE ERROR_ACTIVACION_REGISTRO;
        END IF;
        */
       -- Inserta en la tabla ADMPT_SERV_PEN
       insert into admpt_serv_pend
         (admpn_id_fila, admpv_num_linea, admpn_sn_code, admpn_sp_code, admpc_estado, admpd_fec_reg, adpmv_accion )
       values (V_COD_PENDIENTE,V_NUM_LINEA, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ, 'P',  TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'),'1');        
           
        UPDATE PCLUB.admpt_clienteib SET admpn_flg_debi = 1  WHERE admpv_cod_cli = V_COD_CLIENTECC2;
        
        -- Agrega a la tabla auxiliar
        insert into admpt_aux_debito_ib (admpd_fec_oper, admpv_nom_arch, admpv_cod_cli)
        values (K_FECHA, K_NOM_ARCH, V_COD_CLIENTECC2);

        commit;

        CLOSE C_CUR_DATOS_CLIE;
        CLOSE C_CUR_DAT_LINEA;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN 
             IF V_PLAN_CODE_SERV IS NULL OR V_PLAN_CODE_PQ IS NULL then
               update PCLUB.admpt_tmp_debito_ib
                  set admpc_cod_error = '23',
                      admpv_msje_error = 'El codigo de plan no se encuentra en la tabla admpt_tipo_plan, no se activo o desactivo el servicio'
               where admpv_cod_cli=V_COD_CLIENTECC2 and admpv_nom_arch=K_NOM_ARCH  and admpd_fec_oper=K_FECHA ;
               commit;
             end if;
             if V_NUM_LINEA is null then 
               update PCLUB.admpt_tmp_debito_ib
                  set admpc_cod_error = '34',
                      admpv_msje_error = 'El número enviado para el débito automático no se encuentra registrado en la tabla admpt_clienteib'
               where admpv_cod_cli=V_COD_CLIENTECC2 and admpv_nom_arch=K_NOM_ARCH  and admpd_fec_oper=K_FECHA ;
               commit;
             end if;  
             
        WHEN NO_USERS_CLIENTE THEN
          if C_CUR_SQLERROR is  null or LENGTH(C_CUR_SQLERROR) >0 then
             update PCLUB.admpt_tmp_debito_ib
             set  admpc_cod_error = '21',
                  admpv_msje_error = 'Error en la devolución del cursor sp_datos_cliente: ' || SUBSTR(C_CUR_SQLERROR,1,200)
             where admpv_cod_cli=V_COD_CLIENTECC2 and admpv_nom_arch=K_NOM_ARCH  and admpd_fec_oper=K_FECHA ;
             commit;
           end if;  

        WHEN NO_USERS_LINEA THEN
           update PCLUB.admpt_tmp_debito_ib
           set    admpc_cod_error = '20',
                  admpv_msje_error = 'Error en la devolución del cursor sp_datos_linea'
            where admpv_cod_cli=V_COD_CLIENTECC2 and admpv_nom_arch=K_NOM_ARCH and admpd_fec_oper=K_FECHA ;
            commit;
            
/*        WHEN ERROR_ACTIVACION_REGISTRO THEN
        -- Registrar el error en la tabla Temporal
           update PCLUB.admpt_tmp_debito_ib
              set admpc_cod_error = '26',
                  admpv_msje_error = 'Error: No se pudo desactivar el bono por débito automático'
            where admpv_cod_cli=V_COD_CLIENTECC2 and admpv_nom_arch=K_NOM_ARCH and admpd_fec_oper=K_FECHA ;*/

        WHEN OTHERS THEN
           rollback to inicio_trans;
           --k_coderror:=SQLCODE;
           k_descerror:=SUBSTR(SQLERRM,1,400);
           update PCLUB.admpt_tmp_debito_ib
              set admpc_cod_error = '',
                  admpv_msje_error = k_descerror
            where admpv_cod_cli=V_COD_CLIENTECC2 and admpv_nom_arch=K_NOM_ARCH and admpd_fec_oper=K_FECHA ;
            commit;
            
    END;
    FETCH CLIENTEIB2 INTO V_COD_CLIENTECC2;
  END LOOP;
  CLOSE CLIENTEIB2;

EXCEPTION
    WHEN OTHERS THEN
       k_coderror:=SQLCODE;
       k_descerror:=SUBSTR(SQLERRM,1,400);

   K_CODERROR:=0;
   K_DESCERROR:='';

end ADMPSI_DEBITOIB;


PROCEDURE ADMPSI_FACTU_IB(K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2)
IS

/****************************************************************
'* Nombre SP           :  ADMPSI_FACTU_IB
'* Propósito           :  Asignar puntos IB al cliente
'* Input               :  K_FECHA
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          : (Venkizmet) Sofia Khlebnikov
'* Fec Creación        : 10/08/2010
'* Fec Actualización   :  04/09/2010
'****************************************************************/

 V_PUNTOSIGNO NUMBER;
 V_TIPOP CHAR(1);
 V_CODCONCEPTO VARCHAR2(2);
 V_ESTADO CHAR(1);
 V_CODIB NUMBER;     /*dato de saldos cliente*/
 V_REGCLI NUMBER;
 V_TPODOCIBEQ VARCHAR2(20);
 V_CODIBER NUMBER;


 C_CODCLIENTEIB VARCHAR2(40);   /* datos del cursor*/
 C_CODCLIENTECC VARCHAR2(40);
 C_TIPODOCUMENTO VARCHAR2(20);
 C_NUMDOCUMENTO VARCHAR2(20);
 C_SIGNO CHAR(1);
 C_PUNTOS NUMBER;
 C_FECPROCESO DATE;
 C_NOMARCHIVO VARCHAR2(150);
 C_CODTRANSAC CHAR(3);
 



 CURSOR CLIENTEIBF IS
  SELECT c.ADMPN_COD_CLI_IB,
         a.ADMPV_TIPO_DOC,
         a.ADMPV_NUM_DOC,
         a.ADMPC_SIGNO,
         a.ADMPN_PUNTOS,
         a.ADMPD_FEC_OPER,
         nvl(a.ADMPV_NOM_ARCH,null),
         a.ADMPC_COD_TRANS
  FROM PCLUB.ADMPT_TMP_FACADE_IB a, PCLUB.ADMPT_CLIENTEIB c
  WHERE a.ADMPD_FEC_OPER=K_FECHA ---to_date(K_FECHA,'MM/DD/YYYY')
        AND c.ADMPC_ESTADO<>'B'
        AND a.ADMPC_COD_TRANS='4'
        --AND a.ADMPV_TIPO_DOC=c.ADMPV_TIPO_DOC
        AND TRIM (a.ADMPV_NUM_DOC) = TRIM (c.ADMPV_NUM_DOC)                     -- SSC 27102010 - Por si viene con espacios en blanco
        AND a.ADMPC_COD_ERROR IS NULL ;

------------------ejecucion del cursos-------------------

BEGIN

  OPEN CLIENTEIBF;
  FETCH CLIENTEIBF INTO C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_SIGNO, C_PUNTOS,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;
  WHILE CLIENTEIBF %FOUND LOOP

     SELECT COUNT(*)INTO V_REGCLI FROM PCLUB.ADMPT_AUX_FACADE_IB
      WHERE ADMPV_TIPO_DOC=C_TIPODOCUMENTO
            AND ADMPV_NUM_DOC=C_NUMDOCUMENTO
            AND ADMPD_FEC_OPER=C_FECPROCESO
            AND ADMPV_NOM_ARCH=C_NOMARCHIVO
            AND ADMPC_COD_TRANS=C_CODTRANSAC;
       
     BEGIN
      SELECT NVL(ADMPV_COD_TPDOC,NULL) INTO V_TPODOCIBEQ
      FROM PCLUB.admpt_tipo_doc
      WHERE ADMPV_COD_EQUIV= C_TIPODOCUMENTO;
      exception
        when OTHERS then
           V_TPODOCIBEQ:=null;
     END;      
         
     BEGIN
       select  NVL(ADMPN_COD_CLI_IB,0) INTO V_CODIBER
       from PCLUB.ADMPT_CLIENTEIB
       where ADMPN_COD_CLI_IB = C_CODCLIENTEIB;                                  -- SSC 27102010 Tenemos la PK
             -- SSC 27102010 - ADMPV_TIPO_DOC= V_TPODOCIBEQ
             -- SSC 27102010 - AND ADMPV_NUM_DOC=C_NUMDOCUMENTO;
       exception
          when OTHERS then
             V_CODIBER:=0;
     END; 
   
   /* verifica si el registro no existe en la tabla auxiliar*/
     IF (V_REGCLI=0 AND V_CODIBER <> 0) THEN

       BEGIN   
        
     /* verifica el signo de los puntos y cambio el tipo de operacion(entrada/salida)*/

          IF ( C_SIGNO='-') THEN
             V_PUNTOSIGNO:= C_PUNTOS*(-1);
             V_TIPOP :='S';
          ELSE  V_PUNTOSIGNO:= C_PUNTOS;
                V_TIPOP:='E';
          END IF;


       /* busca el codigoClaro del clienteIB*/

          BEGIN
            SELECT  NVL(ADMPV_COD_CLI,NULL) INTO C_CODCLIENTECC
            FROM PCLUB.ADMPT_CLIENTEIB                  -- SELECT EL CODIGO DEL CLIENTE CLARO
            WHERE ADMPN_COD_CLI_IB = C_CODCLIENTEIB;
                  -- SSC 27102010 Para hacer mas eficiente el query y evitar los espacios en blanco hacemos directamente la llamada con la PK
                  -- SSC 27102010 ADMPV_TIPO_DOC= V_TPODOCIBEQ        --- DE LA TABLA CLIENTE
                  -- SSC 27102010 AND ADMPV_NUM_DOC= C_NUMDOCUMENTO;
            exception
              when OTHERS then
                C_CODCLIENTECC :=null;
          END;      

          BEGIN
            SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CODCONCEPTO
            FROM PCLUB.ADMPT_CONCEPTO
            WHERE UPPER(ADMPV_DESC) LIKE '%FACTURACION%'; --AND ADMPN_COD_CATCLI IS NULL;
            exception
              when OTHERS then
                V_CODCONCEPTO :=null;
          END;  
          

          BEGIN
            SELECT NVL(ADMPN_COD_CLI_IB,null)  INTO V_CODIB
            FROM PCLUB.ADMPT_SALDOS_CLIENTE
            WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
            exception
              when OTHERS then
                V_CODIB :=null;
          END;

          IF(V_CODIB IS NOT NULL) THEN

         /* verifico el estado de los puntos*/
            BEGIN
              BEGIN  
                SELECT NVL(ADMPC_ESTPTO_IB,NULL)  INTO V_ESTADO
                FROM PCLUB.ADMPT_SALDOS_CLIENTE
                WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
                exception
                  when OTHERS then
                    V_ESTADO :=null;
              END;
              

              /*insert en la tabla kardex por facturacion */

              PKG_CLAROCLUB.ADMPSI_AGR_PTIB(C_CODCLIENTEIB,C_CODCLIENTECC ,V_CODCONCEPTO ,
                                                V_PUNTOSIGNO,C_NOMARCHIVO,V_TIPOP,V_ESTADO);
                                                
              INSERT INTO PCLUB.ADMPT_AUX_FACADE_IB (ADMPC_COD_TRANS,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                                                   ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
              VALUES(C_CODTRANSAC,C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO); 
                                             
            END;
          END IF;

        COMMIT;
       

       END;

         
     END IF; /* FIN DE VERIFICA DEL REGISTRO EN TABLA AUX_FACADE*/

  FETCH CLIENTEIBF INTO  C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_SIGNO, C_PUNTOS,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;

  END LOOP;

  CLOSE CLIENTEIBF;

K_CODERROR:=0; -- Correcto
K_DESCERROR:='';

EXCEPTION
  
 WHEN OTHERS THEN
   K_CODERROR:=SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,400);
   ROLLBACK;

   
END ADMPSI_FACTU_IB; ----PCLUB.admpsi_facturacion;

procedure ADMPSS_BON_ACTTC(K_CODERROR OUT NUMBER, K_MSJERROR OUT VARCHAR2) is
/****************************************************************
'* Nombre SP           :  ADMPSS_BON_ACTTC
'* Propósito           :  Activar servicio de 1000 minutos para los clientes en el mismo dia de su facturación
'* Input               :  
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  (Venkizmet) Rossana Janampa       
'* Fec Creación        :  25/08/2010
'* Fec Actualización   :  05/09/2010
'****************************************************************/
TYPE CurClaro_DatosCliente IS REF CURSOR;
C_CUR_DATOS_CLIE CurClaro_DatosCliente;
C_CUR_DAT_LINEA CurClaro_DatosCliente;
C_CUR_DATOS_TRIADOS CURCLARO_DATOSCLIENTE;

CURSOR CLIENTEIB IS
SELECT admpv_cod_cli, admpn_cod_cli_ib, admpv_num_linea, admpv_tipo_doc, admpv_num_doc, admpv_nom_cli, admpv_ape_cli
from PCLUB.admpt_clienteib where admpn_bono_act=0 and admpv_cod_cli is not null  ;

V_COD_CLI_IB          NUMBER;
V_NUM_LINEA           NUMBER;
V_COD_CLI             VARCHAR2(40);
V_TIPO_DOC            varchar2(20);
V_NUM_DOC             varchar2(20);
V_NOM_CLI             varchar2(80);		-- SSC 12112010 Se amplio el tamano de 20 a 80
V_APE_CLI             varchar2(80);		-- SSC 12112010 Se amplio el tamano de 20 a 80


ERROR_ACTIVACION_REGISTRO     EXCEPTION;
NO_DATA_CLIENTE               EXCEPTION;
NO_DATA_LINEA                 EXCEPTION;
V_COD_PENDIENTE               NUMBER;
NO_DATA_ACTIVO                EXCEPTION;             -- SSC 27102010

C_CUR_CUENTA                   varchar2(40);
C_CUR_TIP_DOC                  varchar2(20);
C_CUR_NUM_DOC                  varchar2(30);
C_CUR_COD_ID                   integer;
C_CUR_CICLO_FAC                varchar2(2);
C_CUR_CODIGO_TIPO_CLIENTE      varchar2(10);
C_CUR_TIPO_CLIENTE             varchar2(30);
C_CUR_SQLERROR                 varchar2(400);

C_CUR2_TELEFONO             VARCHAR2(63);
C_CUR2_PLAN                 VARCHAR2(30);
C_CUR2_FLAG_PLATAFORMA      CHAR(1);
C_CUR2_CODIGO_PLAN_TARIFARIO   NUMBER;

/* Datos del cursor Triados */
V_TIPO_TRIADO                  VARCHAR2(20);
V_NUM_TRIO                     INTEGER;
V_TELEFONO                     VARCHAR2(20);
V_FACTOR                       VARCHAR2(20);
V_COD_TIPO_DESTINO             VARCHAR2(20);
V_TIPO_DESTINO                 VARCHAR2(20);

V_PLAN_CODE_PQ                 NUMBER;
--V_R_FUN029                     VARCHAR2(250);
V_PLAN_CODE_SERV               NUMBER;
V_TRIADOS                      NUMBER;

-- Verificar si el contrato se encuentra activo
V_FLAG_RESULTADO            NUMBER;
V_COD_ERROR                 NUMBER;
V_DSC_ERROR                 VARCHAR2(400);

BEGIN
--
    K_CODERROR:=0;
    K_MSJERROR :='';
    
    OPEN CLIENTEIB;
    FETCH CLIENTEIB INTO  V_COD_CLI, V_COD_CLI_IB, V_NUM_LINEA, V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI ;
    WHILE CLIENTEIB %FOUND
      LOOP
        BEGIN
                      
           ADMPSS_DAT_CLIE('',V_NUM_LINEA, C_CUR_SQLERROR, C_CUR_DATOS_CLIE);
           IF LENGTH(C_CUR_SQLERROR) <>0  THEN
             RAISE NO_DATA_CLIENTE; 
           END IF;
           
           -- No hubo error en llamar al TIM.SP_DATOS_CLIE
           FETCH C_CUR_DATOS_CLIE INTO
              C_CUR_CUENTA,       C_CUR_TIP_DOC,                C_CUR_NUM_DOC,  C_CUR_COD_ID,
              C_CUR_CICLO_FAC,    C_CUR_CODIGO_TIPO_CLIENTE,    C_CUR_TIPO_CLIENTE;

              ADMPSS_DAT_LINE(C_CUR_COD_ID, C_CUR_DAT_LINEA);                                   
              FETCH C_CUR_DAT_LINEA INTO C_CUR2_TELEFONO, C_CUR2_PLAN, C_CUR2_FLAG_PLATAFORMA, C_CUR2_CODIGO_PLAN_TARIFARIO;

              IF (C_CUR_DAT_LINEA%rowcount=0)   THEN
                RAISE NO_DATA_LINEA;
              END IF;
                   
              -- Consulta si el numero enviado tiene triados                                        
              PKG_CLAROCLUB.admpss_triados(C_CUR_COD_ID, C_CUR_DATOS_TRIADOS);
              V_TRIADOS:=1;
              FETCH C_CUR_DATOS_TRIADOS INTO v_Tipo_triado, v_num_trio, v_telefono, v_factor, v_cod_tipo_destino, v_tipo_destino;                                          
              
              IF (C_CUR_DATOS_TRIADOS%rowcount=0) THEN
                 V_TRIADOS:=0;
              -- SSC 26102010 - Se solicito que se valide que el tipo de destino sea Claro y movil                                                
              --END IF;
              ELSE
                  -- SSC 26102010 - Se solicito que se valide que el tipo de destino sea Claro y movil
                  WHILE C_CUR_DATOS_TRIADOS %FOUND
                    LOOP
                       IF v_tipo_destino = 'CLARO' THEN
                           BEGIN
                              V_TRIADOS:=1;
                              EXIT;
                           END;
                        ELSE
                           V_TRIADOS:=0;
                        END IF;   
                                                  
                       FETCH C_CUR_DATOS_TRIADOS INTO v_Tipo_triado, v_num_trio, v_telefono, v_factor, v_cod_tipo_destino, v_tipo_destino;               
                    END LOOP;
              END IF;      
              -- SSC 26102010
             
              -- SSC 26102010 - Se realizan los cambios necesarios para que solo le otorgue el bono si esta activo
              V_FLAG_RESULTADO := 0;
              IF V_TRIADOS > 0 THEN
                BEGIN
                   PKG_CLAROCLUB.ADMPSS_SP_STATUS_DN_NUM_CO_ID (2, C_CUR_COD_ID,V_FLAG_RESULTADO,V_COD_ERROR,V_DSC_ERROR);

                   IF (V_COD_ERROR<>0) THEN
                      RAISE NO_DATA_ACTIVO;
                   END IF;

                   IF V_FLAG_RESULTADO = 0 THEN
                      V_TRIADOS:=0;    -- Como esta inactivo se asigna este valor para que no le de el bono y hacer otro IF
                   END IF;
                END;
              END IF;
              -- SSC 26102010
                                                 
              -- Si el SP devuelve una linea se considera que se validó la linea
              IF V_TRIADOS >0 AND C_CUR_CICLO_FAC = to_char(sysdate,'DD') THEN 
                 BEGIN
                   -- Parámetros
                   SELECT admpv_valor INTO V_PLAN_CODE_SERV FROM PCLUB.admpt_paramsist WHERE admpv_desc='COD_SERV_BONO_ACTIVACION_TC';
                   SELECT admpv_valor INTO V_PLAN_CODE_PQ FROM PCLUB.admpt_paramsist WHERE admpv_desc='COD_PAQU_BONO_ACTIVACION_TC';
                   SELECT nvl(admpt_serv_pen_sq.nextval,-1) INTO V_COD_PENDIENTE FROM dual;
                       
                   -- Inserta en la tabla ADMPT_SERV_PEN
                   Savepoint Bono;
                   
                   insert into admpt_serv_pend
                     (admpn_id_fila, admpv_num_linea, admpn_sn_code, admpn_sp_code, admpc_estado, admpd_fec_reg, adpmv_accion)
                   values (V_COD_PENDIENTE,V_NUM_LINEA, V_PLAN_CODE_SERV, V_PLAN_CODE_PQ, 'P', TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY HH:MI PM'),'DD/MM/YYYY HH:MI PM'),'1');
                                          
                   -- No hubo error para activar el bono de activacion po TC                                                    
                   -- actualizar el campo bono_act = 1
                   UPDATE PCLUB.admpt_clienteib
                   SET admpn_bono_act = 1 where admpn_cod_cli_ib = V_COD_CLI_IB and admpv_cod_cli=V_COD_CLI;
                       
                   COMMIT;                       

                   END;
              END IF;
            
            CLOSE C_CUR_DATOS_CLIE;             
            CLOSE C_CUR_DAT_LINEA;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            if V_PLAN_CODE_SERV is null or V_PLAN_CODE_PQ is null then              
              insert into PCLUB.admpt_tmp_bonac
                (admpn_cod_bonac, admpv_tipo_doc, admpv_num_doc, admpv_nom_cli, admpv_ape_cli, admpv_num_linea, admpv_cod_error, admpv_msje_error, admpd_fec_reg)
              values
                (admpt_bonact_sq.nextval, V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI, V_NUM_LINEA, '31', 'No se encontró el registro en la tabla admpt_paramsist', TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'));
              commit;
           end if;
           
          WHEN NO_DATA_CLIENTE THEN
            insert into PCLUB.admpt_tmp_bonac
            (admpn_cod_bonac, admpv_tipo_doc, admpv_num_doc, admpv_nom_cli, admpv_ape_cli, admpv_num_linea, admpv_cod_error, admpv_msje_error, admpd_fec_reg)
            values (admpt_bonact_sq.nextval, V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI, V_NUM_LINEA, '21', 'Error en la devolución del cursor sp_datos_cliente ' || SUBSTR(C_CUR_SQLERROR,1,200),  TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'));
            commit;

          WHEN NO_DATA_LINEA THEN
            insert into PCLUB.admpt_tmp_bonac
            (admpn_cod_bonac, admpv_tipo_doc, admpv_num_doc, admpv_nom_cli, admpv_ape_cli, admpv_num_linea, admpv_cod_error, admpv_msje_error, admpd_fec_reg)
            values (admpt_bonact_sq.nextval, V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI, V_NUM_LINEA, '20', 'Error: No es posible leer los datos del cursor Datos_linea', TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'));
            commit;
          
          -- SSC 27102010 - Inicio - Si se presenta un error en el SP de activacion
          WHEN NO_DATA_ACTIVO THEN
            insert into PCLUB.admpt_tmp_bonac
            (admpn_cod_bonac, admpv_tipo_doc, admpv_num_doc, admpv_nom_cli, admpv_ape_cli, admpv_num_linea, admpv_cod_error, admpv_msje_error, admpd_fec_reg)
            values (admpt_bonact_sq.nextval, V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI, V_NUM_LINEA, '20', 'Error: Se presentó un error al leer el SP ADMPSS_SP_STATUS_DN_NUM_CO_ID', TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'));
            COMMIT;            
          -- SSC 27102010 - Fin
            
          WHEN OTHERS THEN
             rollback to bono;
             K_CODERROR:=SQLCODE;
             K_MSJERROR:=SUBSTR(SQLERRM,1,400); --V_ERROR:=SUBSTR(SQLERRM,1,400);
             insert into PCLUB.admpt_tmp_bonac
             (admpv_tipo_doc, admpv_num_doc, admpv_nom_cli, admpv_ape_cli, admpv_num_linea, admpv_cod_error, admpv_msje_error, admpd_fec_reg)
             values (V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI, V_NUM_LINEA, '', K_MSJERROR,  TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'));   
             commit;

        END;
        FETCH CLIENTEIB INTO  V_COD_CLI, V_COD_CLI_IB, V_NUM_LINEA, V_TIPO_DOC, V_NUM_DOC, V_NOM_CLI, V_APE_CLI ;
    END LOOP;
    CLOSE CLIENTEIB;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR:=SQLCODE;
    K_MSJERROR :=SUBSTR(SQLERRM,1,400);    

END;

procedure ADMPSS_EACAMOIB(K_FECHAPROC IN DATE, CURSORACCAMO out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSS_EACAMOIB
-- Propósito           :  Devuelve en un cursor los registros procesados del diario incluyendo los errores encontrados por registros
-- Input               :  K_FECHAPROC
-- Output              :  CursorAcCaMo
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :  03/09/2010
--****************************************************************
BEGIN
OPEN CursorAcCaMo FOR
SELECT  trim(ADMPC_COD_TRANS), ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_PRI,ADMPV_NOM_SEG ,ADMPV_APE_PAT,ADMPV_APE_MAT , ADMPV_NUM_LINEA, to_char (ADMPD_FEC_ACT, 'yyyymmdd'),
        trim(ADMPC_ACEP_BONO),to_char (ADMPD_FEC_VTA, 'yyyymmdd'),trim(NVL(ADMPC_COD_ERROR,'0')), ADMPV_MSJE_ERROR
FROM PCLUB.ADMPT_IMP_ACCAMO_IB
WHERE ADMPD_FEC_OPER=K_FECHAPROC
ORDER BY admpn_seq ASC;

end;

procedure ADMPSS_EFACAMIB(K_FECHAPROC IN DATE, CursorFaCaIB out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSS_EFACAMIB
-- Propósito           :  Devuelve en un cursor los registros procesados del archivo mensual incluyendo los errores encontrados por registros
-- Input               :  K_FECHAPROC
-- Output              :  CursorFaCaIB
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :  07/09/2010
--****************************************************************
BEGIN
OPEN CursorFaCaIB FOR
SELECT trim(admpc_cod_trans), admpv_tipo_doc, admpv_num_doc, admpc_signo,
       admpn_puntos, admpv_nom_camp, trim(NVL(ADMPC_COD_ERROR,'0')), ADMPV_MSJE_ERROR
  FROM PCLUB.admpt_imp_facade_ib
 WHERE ADMPD_FEC_OPER=K_FECHAPROC;

end;

procedure ADMPSI_EDEBITIB(K_FECHAPROC IN DATE, CursorDebito out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EDEBITIB
-- Propósito           :  Devuelve en un cursor los registros procesados de Debito Automatico incluyendo los errores encontrados por registros 
-- Input               :  K_FECHAPROC
-- Output              :  CursorFaCaIB
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :  07/09/2010
--****************************************************************  

  BEGIN
    OPEN CursorDebito FOR
    SELECT admpv_cod_cli,admpv_num_fact,admpn_monto_fac,admpn_monto_pag,admpn_monto_deb,
           trim(NVL(ADMPC_COD_ERROR,'0')), admpv_msje_error
      FROM PCLUB.admpt_imp_debito_ib
     WHERE ADMPD_FEC_OPER=K_FECHAPROC;
  END;


procedure ADMPSS_EJDIA_IB(K_FECHA IN DATE,K_CODERROR OUT VARCHAR2,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSS_EJDIA_IB
-- Propósito           :  Ejecutar los procesos de cada de puntos IB en forma Diaria
-- Input               :  K_FECHA
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--                     :  K_NUMREGTOT, K_NUMREGPRO, K_NUMREGERR   
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :  07/09/2010
--****************************************************************

ERRORBD_VADAT EXCEPTION;
ERRORBD_ACTIV EXCEPTION;
ERRORBD_CANCE EXCEPTION;
ERRORBD_MOROS EXCEPTION;

K_INDICADOR CHAR(1):='D';
K_CODERRORP NUMBER;
K_DESCERRORP VARCHAR2(150);
--K_NUMREGTOTAUX NUMBER;

BEGIN
  
  UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB SET
   ADMPD_FEC_OPER=K_FECHA,
   ADMPV_NOM_ARCH='IBACTCANMOR_'||to_char(K_FECHA,'YYYYMMDD')
  WHERE  ADMPD_FEC_OPER IS Null or ADMPD_FEC_OPER=''; 
  commit;

  -- Valiadcion solo de las activacaciones
  ADMPSS_VADAT_IB(K_FECHA,K_INDICADOR,'1',K_CODERRORP,K_DESCERRORP);
    
  IF(K_CODERRORP=0)THEN
    BEGIN

       ADMPSI_ACTIV_IB(K_FECHA,K_CODERRORP,K_DESCERRORP);

       IF(K_CODERRORP=0) THEN
       
          -- Valiadcion solo de las cancelaciones
          ADMPSS_VADAT_IB(K_FECHA,K_INDICADOR,'2',K_CODERRORP,K_DESCERRORP);
          
          IF(K_CODERRORP=0)THEN
          
               ADMPSI_CANCE_IB(K_FECHA,K_CODERRORP,K_DESCERRORP);

               IF (K_CODERRORP=0) THEN
                  -- Valiadcion solo de los clientes morosos
                  ADMPSS_VADAT_IB(K_FECHA,K_INDICADOR,'3',K_CODERRORP,K_DESCERRORP);
                  
                  IF(K_CODERRORP=0)THEN                  

                      ADMPSI_CLMOR_IB(K_FECHA,K_CODERRORP,K_DESCERRORP); -- Se probará en la etapa 2

                      IF (K_CODERRORP<>0) THEN RAISE ERRORBD_MOROS;

                      END IF;

                   ELSE
                     
                      RAISE ERRORBD_VADAT;
                   
                   END IF;       

               ELSE

                  RAISE ERRORBD_CANCE;

               END IF;

           ELSE
             
               RAISE ERRORBD_VADAT;
               
           END IF;    

         ELSE

            RAISE ERRORBD_ACTIV;

         END IF;

    END;

  ELSE

     RAISE ERRORBD_VADAT;

  END IF;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ACCAMO_IB;
  
  SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ACCAMO_IB WHERE (admpc_cod_error Is Not null);

  SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ACCAMO_IB WHERE (admpd_fec_oper=K_FECHA);

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_ACCAMO_IB
  SELECT PCLUB.admpt_aacamo_sq.nextval,admpc_cod_trans, admpv_tipo_doc,admpv_num_doc,
         NVL(admpv_nom_pri,NULL),NVL(admpv_ape_mat,NULL),NVL(admpv_num_linea,NULL),
         admpd_fec_act, admpd_fec_oper,NVL(admpv_nom_arch,NULL),NVL(admpc_cod_error,NULL),
         NVL(admpv_msje_error,NULL),NVL(admpv_nom_seg,NULL),NVL(admpv_ape_pat,NULL),admpc_acep_bono,
         admpn_seq, ADMPD_FEC_VTA
    FROM PCLUB.admpt_tmp_accamo_ib 
    WHERE admpd_fec_oper=K_FECHA;
  
   -- Eliminamos los registros de la tabla temporal y auxiliar
   DELETE PCLUB.admpt_aux_accamo_ib;
   DELETE PCLUB.admpt_tmp_accamo_ib;

  
  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

  EXCEPTION
    WHEN ERRORBD_VADAT THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||' Error de bd en sp admpss_vadat_ib';
     

    WHEN ERRORBD_ACTIV THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||' Error de bd en sp admpsi_activ_ib';
     

    WHEN ERRORBD_CANCE THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||' Error de bd en sp admpsi_cance_ib';
     
    

    WHEN ERRORBD_MOROS THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||'   Error de bd en sp admpsi_clmor_ib';
     

    WHEN OTHERS THEN
     K_CODERROR:=to_char(SQLCODE);
     K_DESCERROR:= SUBSTR(SQLERRM,1,400);
     
     

end ADMPSS_EJDIA_IB;


procedure ADMPSS_EJMEN_IB(K_FECHA IN DATE,K_CODERROR OUT VARCHAR2,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSS_EJMEN_IB
-- Propósito           :  Ejecutar los procesos de cada de puntos IB en forma mensual
-- Input               :  K_FECHA
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--                     :  K_NUMREGTOT, K_NUMREGPRO, K_NUMREGERR   
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :  07/08/2010
--****************************************************************

ERRORBD_VADAT EXCEPTION;
ERRORBD_FACTU EXCEPTION;
ERRORBD_CAMPA EXCEPTION;

K_INDICADOR CHAR(1):='M';
K_CODERRORP NUMBER;
K_DESCERRORP VARCHAR2(150);
--K_NUMREGTOTAUX NUMBER;

BEGIN
  

  UPDATE PCLUB.ADMPT_TMP_FACADE_IB SET
   ADMPD_FEC_OPER=K_FECHA,
   ADMPV_NOM_ARCH='IBFACCAMDEB_'||to_char(K_FECHA,'YYYYMMDD')
  WHERE  ADMPD_FEC_OPER IS Null or ADMPD_FEC_OPER=''; 
  commit;
  

  ADMPSS_VADAT_IB(K_FECHA,K_INDICADOR,'4',K_CODERRORP,K_DESCERRORP);
  
  
  IF(K_CODERRORP=0)THEN
    BEGIN

       ADMPSI_FACTU_IB(K_FECHA,K_CODERRORP,K_DESCERRORP);

       IF(K_CODERRORP=0) THEN

          ADMPSS_VADAT_IB(K_FECHA,K_INDICADOR,'5',K_CODERRORP,K_DESCERRORP);

          IF(K_CODERRORP=0) THEN

              ADMPSI_CAMPA_IB(K_FECHA,K_CODERRORP,K_DESCERRORP);

              IF (K_CODERRORP<>0) THEN RAISE ERRORBD_CAMPA;

              END IF;
           
          ELSE
            
              RAISE ERRORBD_VADAT;
          
          END IF;
             
       ELSE

          RAISE ERRORBD_FACTU;

       END IF;

    END;

  ELSE

     RAISE ERRORBD_VADAT;

  END IF;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_FACADE_IB;
  
  

  SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_FACADE_IB WHERE (admpc_cod_error Is Not Null);

  SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_FACADE_IB WHERE (admpd_fec_oper=K_FECHA);

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.admpt_imp_facade_ib
  SELECT PCLUB.admpt_afacad_sq.nextval,
         admpc_cod_trans, admpv_tipo_doc, admpv_num_doc, admpc_signo, admpn_puntos, NVL(admpv_nom_camp,NULL),
         NVL(admpd_fec_acum,NULL), admpd_fec_oper, NVL(admpv_nom_arch,NULL), NVL(admpc_cod_error,NULL),NVL(admpv_msje_error,NULL),
         admpn_seq
    FROM PCLUB.ADMPT_TMP_FACADE_IB WHERE admpd_fec_oper=K_FECHA;
  
  -- Eliminamos los registros de la tabla temporal 
  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_FACADE_IB;
  DELETE PCLUB.ADMPT_TMP_FACADE_IB;
   

  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

  EXCEPTION
    WHEN ERRORBD_VADAT THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||'  ERROR DE BD EN SP ADMPSS_VADAT_IB';
     
     
    WHEN ERRORBD_FACTU THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||'  ERROR DE BD EN SP ADMPSI_FACTU_IB';
     
     
    WHEN ERRORBD_CAMPA THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||'  ERROR DE BD EN SP ADMPSS_CAMPA_IB';
     
    
    WHEN OTHERS THEN
     K_CODERROR:=to_char(SQLCODE);
     K_DESCERROR:= SUBSTR(SQLERRM,1,400);
    
     
     
   
end ADMPSS_EJMEN_IB;

procedure ADMPSS_EJDEB_IB(K_FECHA IN DATE, K_CODERROR OUT VARCHAR2, K_DESCERROR OUT VARCHAR2, K_NUMREGTOT OUT NUMBER, K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSS_EJDEB_IB
-- Propósito           :  Ejecutar los procesos de debito automatico de puntos IB por cada cierre
-- Input               :  K_FECHA, 
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_NUMREGTOT Descripcion del Error (si se presento)
--                     :  K_NUMREGPRO
--                     :  K_NUMREGERR   
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :
--****************************************************************

ERRORBD_VADAT EXCEPTION;
ERRORBD_DEBID EXCEPTION;

K_INDICADOR CHAR(1):='D';
K_CODERRORP NUMBER;
K_DESCERRORP VARCHAR2(150);

BEGIN
  
  UPDATE PCLUB.ADMPT_TMP_DEBITO_IB SET
   ADMPD_FEC_OPER=K_FECHA,
   ADMPV_NOM_ARCH='DEBITOAUT_'||to_char(K_FECHA,'YYYYMMDD')
  WHERE  ADMPD_FEC_OPER IS Null or ADMPD_FEC_OPER='';
  commit;

  ADMPSS_VADAT_IB(K_FECHA,K_INDICADOR,0,K_CODERRORP,K_DESCERRORP);

  IF(K_CODERRORP=0)THEN
      BEGIN
        
         ADMPSI_DEBITOIB(K_FECHA, 'DEBITOAUT_'||to_char(K_FECHA,'YYYYMMDD'), K_CODERRORP,K_DESCERRORP);
         IF (K_CODERRORP<>0) THEN RAISE ERRORBD_DEBID;

         END IF;
      END;
    ELSE

       RAISE ERRORBD_VADAT;

    END IF;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_DEBITO_IB;

  SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_DEBITO_IB WHERE (admpc_cod_error Is Not null);

  SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_TMP_DEBITO_IB WHERE (admpc_cod_error Is Null);

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.admpt_imp_debito_ib
  SELECT PCLUB.admpt_deb_ib_sq.nextval,
         admpv_cod_cli,admpv_num_fact,admpn_monto_fac, admpn_monto_pag, admpn_monto_deb, admpd_fec_oper, admpv_nom_arch, 
          admpc_cod_error, admpv_msje_error, admpn_seq
    FROM PCLUB.ADMPT_TMP_DEBITO_IB
    WHERE admpd_fec_oper=K_FECHA;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_TMP_DEBITO_IB;

  DELETE PCLUB.ADMPT_AUX_DEBITO_IB;

  COMMIT;

  K_CODERROR:= '0';
  K_DESCERROR:= '';

  EXCEPTION
    WHEN ERRORBD_VADAT THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||' ERROR DE BD EN SP ADMPSS_VADAT_IB';
     

    WHEN ERRORBD_DEBID THEN
     K_NUMREGPRO:=0;
     K_NUMREGERR:=0;
     K_NUMREGTOT:=0;
     K_CODERROR:= to_char(K_CODERRORP);
     K_DESCERROR:= K_DESCERRORP ||' ERROR DE BD EN SP ADMPSI_ACTIV_IB';
     

end ADMPSS_EJDEB_IB;

procedure ADMPSS_CONCLRF(K_FECHA IN DATE, CursorClienteRef out SYS_REFCURSOR) is
BEGIN
--****************************************************************
-- Nombre SP           :  ADMPSS_CONCLRF
-- Propósito           :  Recuperar una lista de clientes que fueron ingresados como referidos
-- Input               :  K_FECHA - Fecha de Proceso
-- Output              :  CursorClienteRef Lista de Clientes ingresados como referidos para IB
--                     :  Lista de Clientes que obtuvieron que fueron ingresados como referidos
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  09/08/2010
-- Fec Actualización   :  27/09/2010 Se agrega el filtro de estado pendiente
--****************************************************************

-- Usamos tabla derivada para no hacer la union directa con toda la tabla de cliente
OPEN CursorClienteRef FOR
SELECT admpv_nombres,
       admpv_apellidos,
       admpt_tipo_doc.admpv_cod_equiv,
       admpv_num_doc,
       admpv_num_linea,
       admpv_num_refer,
       to_char (admpd_fec_regis, 'yyyymmdd')
  FROM admpt_cliref_ib INNER JOIN PCLUB.admpt_tipo_doc ON TRIM (admpt_cliref_ib.admpv_tipo_doc) = TRIM (admpt_tipo_doc.admpv_cod_tpdoc)
 WHERE admpd_fec_regis <= K_FECHA AND
       ADMPC_ESTADO = 'P';

END ADMPSS_CONCLRF;

procedure ADMPSS_CLIREFER(K_NOMBRES IN VARCHAR2, K_APELLIDOS IN VARCHAR2, K_TIPO_DOC IN VARCHAR2, K_NUM_DOC IN VARCHAR2, K_NUMLINEA IN VARCHAR2, K_NUMREF IN VARCHAR2, K_IPREG IN VARCHAR2,  K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2) is
/****************************************************************
'* Nombre SP           :  ADMPSS_CLIREFER
'* Propósito           :  Claro envia datos del cliente a la tabla referidos para IB
'* Input               :  K_TIPO_DOC (Tipo de Documento), K_NUM_DOC (Numero de documento), K_NOMBRES, K_APELLIDOS, K_NUMLINEA
                       :  K_NUMREF (Numero de telefono referido), K_FECREG (Fecha de registro), K_IPREG
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  (Venkizmet) Sofia Khlebnikov
'* Fec Creación        :  20/08/2010
'* Fec Actualización   :  27/09/2010 - Se cambio el orden de los parametros de entrada y se agrego el estado de la tabla
'****************************************************************/

V_REGCLI NUMBER;
ERRORDATOS EXCEPTION;
ERRORDATOSDOC EXCEPTION;
CLIEXISTE EXCEPTION;

BEGIN

  IF(K_TIPO_DOC IS NULL) OR (K_NUM_DOC IS NULL) OR (K_NOMBRES IS NULL) OR (K_APELLIDOS IS NULL) THEN
   raise ERRORDATOS;
  END IF;

   begin
     SELECT COUNT(*) INTO V_REGCLI FROM PCLUB.ADMPT_CLIREF_IB
     WHERE ADMPV_TIPO_DOC = K_TIPO_DOC
           AND ADMPV_NUM_DOC=K_NUM_DOC;

     exception
        when others then
           V_REGCLI:=-1;
   end;

   IF(V_REGCLI=0) THEN
    INSERT INTO PCLUB.ADMPT_CLIREF_IB VALUES(K_TIPO_DOC,K_NUM_DOC,K_NOMBRES,K_APELLIDOS,K_NUMLINEA,NVL(K_NUMREF,null),TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'),K_IPREG,'P',null);
   ELSE
    IF (V_REGCLI=-1) THEN
      raise ERRORDATOSDOC;
    END IF;
      IF (V_REGCLI>0) THEN
        raise CLIEXISTE;
      END IF;
   END IF;

   COMMIT;

   K_CODERROR:=0; -- Correcto
   K_DESCERROR:='';

  EXCEPTION
   WHEN ERRORDATOS THEN

    K_CODERROR:=25;
    K_DESCERROR:= 'El número de parametros es invalido para el cliente con tipoDocumento:  ' || K_TIPO_DOC ||',  con numeroDocumento: '|| K_NUM_DOC ||', con nombres: '|| K_NOMBRES ||', con apellidos: '|| K_APELLIDOS ||', con número del teléfono: '||K_NUMLINEA;

   WHEN ERRORDATOSDOC THEN
    K_CODERROR:=26;
    K_DESCERROR:= 'El código del tipo de documento es inválido';

   WHEN CLIEXISTE THEN
    K_CODERROR:=33;
    K_DESCERROR:= 'El cliente con tipo de documento: '|| K_TIPO_DOC || ' y con número de documento: '|| K_NUM_DOC ||' ya existe';

   WHEN OTHERS THEN
    K_CODERROR:=SQLCODE;
    K_DESCERROR:= SUBSTR(SQLERRM,1,400);

end ADMPSS_CLIREFER;

procedure ADMPSS_ACTREF(K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, CursorClienteRef OUT SYS_REFCURSOR) is
BEGIN
--****************************************************************
-- Nombre SP           :  ADMPSS_CONCLRF
-- Propósito           :  Recuperar una lista de clientes que fueron ingresados como referidos
-- Input               :  
-- Output              :  CursorClienteRef Lista de Clientes referidos que no pudieron ser actualizados
--                     :  
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  09/08/2010
-- Fec Actualización   :  27/09/2010 Se agrega el filtro de estado pendiente
--****************************************************************

-- Actualizamos los registros que se encuentran en estado Pendiente
UPDATE admpt_cliref_ib
   SET ADMPC_ESTADO = 'E',
       admpd_fec_envio = SYSDATE
 WHERE ADMPC_ESTADO = 'P';      

COMMIT;

OPEN CursorClienteRef FOR
SELECT admpv_nombres,
       admpv_apellidos,
       admpv_tipo_doc,
       admpv_num_doc,
       admpv_num_linea,
       admpv_num_refer,
       to_char (admpd_fec_regis, 'yyyymmdd')
  FROM admpt_cliref_ib
 WHERE ADMPC_ESTADO = 'P';

K_CODERROR:=0;
K_DESCERROR:='';

EXCEPTION
    WHEN OTHERS THEN
       K_CODERROR:=SQLCODE;
       K_DESCERROR:=SUBSTR(SQLERRM,1,400);

END ADMPSS_ACTREF;

procedure ADMPSS_VADAT_IB(K_FECHAPROCESO IN DATE, K_INDICADOR IN CHAR,K_TRANSACCION IN VARCHAR2,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) is

ERROR_FECHA EXCEPTION;

begin
--****************************************************************
-- Nombre SP           :  ADMPSS_VADAT_IB
-- Propósito           :  Validacion inicial los datos antes de ejecutar los procesos
-- Input               :  K_FECHAPROCESO
--                        K_INDICADOR (M Mensual (Facturacion y Campana), D Diaria (Activacion, Cancelacion,
--                        Moroso), N Ninguna (Debito Automatico))
--                        K_TRANSACCION (1 Activacion, 2 Cancelacion, 3 Debito Automatico)
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  20/08/2010
-- Fec Actualización   :
--****************************************************************


IF (TRIM (K_FECHAPROCESO) is Null ) THEN
  raise ERROR_FECHA;
  
ELSE  

IF TRIM (K_INDICADOR) = 'D' THEN         -- Proceso Diario
    -- Validamos el Tipo de Documento
    UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
       SET admpc_cod_error = '5',
           admpv_msje_error = 'El tipo de documento no existe'
     WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
           admpd_fec_oper = K_FECHAPROCESO AND
           (TRIM (admpv_tipo_doc) NOT IN (SELECT TRIM (admpv_cod_equiv) FROM PCLUB.ADMPT_TIPO_DOC) OR
            TRIM (admpv_tipo_doc) = '' OR admpv_tipo_doc Is Null )    ;

    -- Validamos el Número de Documento
    UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
       SET admpc_cod_error = '6',
           admpv_msje_error = 'El número de documento es obligatorio'
     WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
           admpd_fec_oper = K_FECHAPROCESO AND
           (TRIM (admpv_num_doc) = '' OR admpv_num_doc Is Null );

    -- Validamos el codigo de la transacción
     UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
        SET admpc_cod_error = '15',
            admpv_msje_error = 'El codigo de transacción es obligatorio '
      WHERE admpd_fec_oper = K_FECHAPROCESO AND
            (admpc_cod_trans NOT IN ('1', '2', '3') OR admpc_cod_trans='' OR admpc_cod_trans Is Null);

    IF K_TRANSACCION = 1 THEN
          -- Validamos la Fecha Activacion
          UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
             SET admpc_cod_error = '11',
                 admpv_msje_error = 'La Fecha de activación es un dato obligatorio'
           WHERE admpc_cod_trans = K_TRANSACCION AND
                 admpd_fec_oper = K_FECHAPROCESO AND
                 admpd_fec_act Is Null;
                 
           -- Validamos el codigo de aceptacione del bono
           UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
              SET admpc_cod_error = '17',
                  admpv_msje_error = 'El codigo de aceptacion del bono es invalido '
            WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
                  admpd_fec_oper = K_FECHAPROCESO AND
                  (admpc_acep_bono NOT IN ('S', 'N') OR admpc_acep_bono='' OR admpc_acep_bono Is Null);               
			
			-- Validamos la Fecha de Venta
          UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
             SET admpc_cod_error = '18',
                 admpv_msje_error = 'La Fecha de venta es un dato obligatorio'
           WHERE admpc_cod_trans = K_TRANSACCION AND
                 admpd_fec_oper = K_FECHAPROCESO AND
                 ADMPD_FEC_VTA Is Null;	  
    END IF;           

    -- Validamos que el cliente exista en la tabla de Clientes IB solo comparamos con el numero de documento
    IF K_TRANSACCION = 2 OR K_TRANSACCION = 3 THEN
        UPDATE PCLUB.ADMPT_TMP_ACCAMO_IB
           SET admpc_cod_error = '16',
               admpv_msje_error = 'El cliente IB no existe, no se le puede entregar puntos.'
         WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
               admpd_fec_oper = K_FECHAPROCESO AND
               (TRIM (admpv_num_doc) NOT IN (SELECT TRIM (admpv_num_doc) FROM PCLUB.ADMPT_CLIENTEIB) OR
               admpv_num_doc Is Null OR admpv_num_doc = '') ; 
     END IF;        
             
                        

ELSE
   IF TRIM (K_INDICADOR) = 'M' THEN      -- Proceso Mensual
     ---SELECT 1/0 INTO result FROM ADMPT_TMP_FACADE_IB;
      -- Validamos el Tipo de Documento
      UPDATE PCLUB.ADMPT_TMP_FACADE_IB
         SET admpc_cod_error = '5',
             admpv_msje_error = 'El tipo de documento no existe'
       WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
             admpd_fec_oper = K_FECHAPROCESO AND
             (TRIM (admpv_tipo_doc) NOT IN (SELECT TRIM (admpv_cod_equiv) FROM PCLUB.ADMPT_TIPO_DOC) OR
              TRIM (admpv_tipo_doc) = '' OR admpv_tipo_doc Is Null );

      -- Validamos el Número de Documento
      UPDATE PCLUB.ADMPT_TMP_FACADE_IB
         SET admpc_cod_error = '6',
             admpv_msje_error = 'El número de documento es obligatorio'
       WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
             admpd_fec_oper = K_FECHAPROCESO AND
             (TRIM (admpv_num_doc) = '' OR admpv_num_doc Is Null );

      -- Validamos el Signo
      UPDATE PCLUB.ADMPT_TMP_FACADE_IB
         SET admpc_cod_error = '10',
             admpv_msje_error = 'El signo es un dato obligatorio'
       WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
             admpd_fec_oper = K_FECHAPROCESO AND
             (TRIM (admpc_signo) = '' OR admpc_signo Is Null OR (admpc_signo <> '+' AND admpc_signo <> '-'));

      -- Validamos los puntos
      UPDATE PCLUB.ADMPT_TMP_FACADE_IB
         SET admpc_cod_error = '9',
             admpv_msje_error = 'Número de puntos obtenidos en el periodo igual a cero '
       WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
             admpd_fec_oper = K_FECHAPROCESO AND
             (admpn_puntos Is Null OR admpn_puntos = 0);

      -- Validamos el codigo de la transacción
      UPDATE PCLUB.ADMPT_TMP_FACADE_IB
         SET admpc_cod_error = '15',
             admpv_msje_error = 'El codigo de transacción es obligatorio '
       WHERE admpd_fec_oper = K_FECHAPROCESO AND
             (admpc_cod_trans NOT IN ('4', '5') OR TRIM(admpc_cod_trans)='' OR admpc_cod_trans Is Null);

      -- Validamos que el cliente exista en la tabla de Clientes IB solo comparamos con el numero de documento
      UPDATE PCLUB.ADMPT_TMP_FACADE_IB
         SET admpc_cod_error = '16',
             admpv_msje_error = 'El cliente IB no existe, no se le puede entregar puntos.'
       WHERE trim(admpc_cod_trans) = K_TRANSACCION AND
             admpd_fec_oper = K_FECHAPROCESO AND
             (TRIM (admpv_num_doc) NOT IN (SELECT TRIM (admpv_num_doc) FROM PCLUB.ADMPT_CLIENTEIB) OR
             admpv_num_doc Is Null OR admpv_num_doc = '') ;        
              

   ELSE  -- Debito automatico

      -- Validamos el código de cliente
      UPDATE PCLUB.ADMPT_TMP_DEBITO_IB
         SET admpc_cod_error = '12',
             admpv_msje_error = 'El codigo de cliente es obligatorio'
       WHERE admpd_fec_oper = K_FECHAPROCESO AND
             (TRIM (admpv_cod_cli) = '' OR admpv_cod_cli Is Null);

      -- Validamos el Monto Facturado
      UPDATE PCLUB.ADMPT_TMP_DEBITO_IB
         SET admpc_cod_error = '13',
             admpv_msje_error = 'El Monto facturado debe ser mayor que 0'
       WHERE admpd_fec_oper = K_FECHAPROCESO AND
             (admpn_monto_fac <= 0 OR admpn_monto_fac Is Null);

      -- Validamos el Monto Debitado
      UPDATE PCLUB.ADMPT_TMP_DEBITO_IB
         SET admpc_cod_error = '14',
             admpv_msje_error = 'El Monto debitado debe ser mayor que 0'
       WHERE admpd_fec_oper = K_FECHAPROCESO AND
             (admpn_monto_deb <= 0 OR admpn_monto_deb Is Null);

   END IF;

END IF;



COMMIT;

K_CODERROR:=0; -- Correcto
K_DESCERROR:='';

END IF;

EXCEPTION
  
 WHEN ERROR_FECHA THEN
   K_CODERROR:=27;
   K_DESCERROR:= 'El parametro fecha proceso es obligatoria';
   
 WHEN OTHERS THEN
   K_CODERROR:=SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,400);

end ADMPSS_VADAT_IB;

procedure ADMPSS_PUNTOSIB(K_FECHA IN DATE, CursorClienteIB out SYS_REFCURSOR) is
BEGIN
--****************************************************************
-- Nombre SP           :  ADMPSS_PUNTOSIB
-- Propósito           :  Recuperar una lista de clientes que obtuevieron puntos IB para generar un archuvo de texto
--                        que sera enviado a Loyalty
-- Input               :  K_FECHA - Fecha de Proceso
--                        CursorClienteIB Lista de Clientes con los puntos IB
-- Output              :  Lista de Clientes que obtuvieron puntos IB los datos a reportar son Tipo y Número de Documento,
--                        Puntos
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  09/08/2010
-- Fec Actualización   :
--****************************************************************

-- Usamos tabla derivada para no hacer la union directa con toda la tabla de cliente
OPEN CursorClienteIB FOR
SELECT cli.admpv_cod_cli, '00000', to_char(K_FECHA,'DD/MM/YYYY'), '0:0', dt.puntos
  FROM PCLUB.admpt_clienteib cli INNER JOIN
       (SELECT admpv_cod_cli as co_cli, SUM (admpn_puntos) as puntos
        FROM PCLUB.admpt_kardex
        WHERE admpd_fec_trans <= K_FECHA
        AND admpc_tpo_oper = 'E'
        AND admpc_tpo_punto = 'I'
        AND admpc_estado = 'A'
        AND admpv_cod_cli is not null
        GROUP BY admpv_cod_cli) dt
   ON dt.co_cli = cli.admpv_cod_cli;

END ADMPSS_PUNTOSIB;

PROCEDURE ADMPSS_DAT_CLIE ( K_CUSTCODE  IN  VARCHAR2,
                              K_DN_NUM    IN  VARCHAR2,
                              K_SQLERROR    OUT VARCHAR2,
                              K_CURSOR   IN OUT SYS_REFCURSOR ) IS
/****************************************************************
'* Nombre SP           :  ADMPSS_DAT_CLIE
'* Propósito           :  Buscar en la base de datos BSCS, los datos del cliente
'* Input               :  K_CUSTCODE, K_DN_NUM
'* Output              :  K_SQLERROR, K_CURSOR
'* Creado por          :  (Venkizmet) Rossana Janampa       
'* Fec Creación        :  01/09/2010
'* Fec Actualización   :  05/09/2010
'****************************************************************/                              

     v_custcode           varchar(40);--customer_all@DBL_BSCS.custcode%TYPE := '';
     v_co_id              integer; --contract_all.co_id%TYPE := 0;
     -- Variable que almacena el numero de cuentas
     v_num_cuentas        INTEGER := 0;
     -- Variable que almacena el numero de lineas
     v_num_lineas         INTEGER := 0;

   BEGIN
     
   IF NVL(K_CUSTCODE,'0') <> '0' THEN
         v_custcode := K_CUSTCODE;
     END IF;

     IF NVL(K_DN_NUM,0)<>0 THEN

       BEGIN

         SELECT cu.custcode, co.co_id
         INTO   v_custcode, v_co_id
         FROM   customer_all@DBL_BSCS CU, contract_all@DBL_BSCS co
         WHERE  cu.customer_id = co.customer_id
                AND co.co_id  = tim.tfun006_get_coid_from_dn@DBL_BSCS(K_DN_NUM);
       EXCEPTION

         WHEN OTHERS THEN NULL;
       END;

     END IF;
     IF v_custcode IS NOT NULL THEN
         SELECT COUNT(DISTINCT ccr.customer_id),
                SUM(ccr.a + ccr.s)
         INTO   v_num_cuentas, v_num_lineas
         FROM   tim.tim_consol_cliente_ref@DBL_BSCS ccr
         WHERE  ccr.custcode LIKE v_custcode||'%';

     END IF;

     -- Cursor que devuelve el resultado
     OPEN K_CURSOR FOR

         SELECT /*+ use_nl(cu cc t) */
                cu.custcode cuenta,
                it.idtype_name tip_doc,
                cc.passportno num_doc,
                v_co_id  co_id,
                cu.billcycle ciclo_fac,
                cu.prgcode codigo_tipo_cliente,
                pg.prgname tipo_cliente

         FROM   customer_all@DBL_BSCS cu,
                ccontact_all@DBL_BSCS  cc, 
                ccontact_all@DBL_BSCS  cc2,
                id_type@DBL_BSCS it,
                title@DBL_BSCS t,
                country@DBL_BSCS c,
                info_cust_combo@DBL_BSCS icc,
                marital_status@DBL_BSCS ms,
                pricegroup_all@DBL_BSCS pg,
                language@DBL_BSCS la,
                payment_all@DBL_BSCS pa,
                paymenttype_all@DBL_BSCS  pt

         WHERE  cu.customer_id = cc.customer_id
                AND cc.ccbill = 'X'
                AND cc2.ccforward (+)= 'X'
                AND cc2.ccseq (+)= 2
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
                AND cu.customer_id=pa.customer_id
                AND pa.seq_id = ( SELECT MAX(seq_id)
                                  FROM   payment_all@DBL_BSCS
                                  WHERE  customer_id = pa.customer_id);
  
   EXCEPTION
     WHEN OTHERS THEN
       K_SQLERROR := 'Error TIM.PP004_SIAC_CONSULTAS.SP_DATOS_CLIEN: ' || TO_CHAR(SQLCODE) || ' ' || SQLERRM ;
   END;
   
procedure ADMPSS_DAT_LINE (K_CO_ID IN NUMBER, K_CURSOR OUT SYS_REFCURSOR ) IS
/****************************************************************
'* Nombre SP           :  ADMPSS_DAT_LINE
'* Propósito           :  Buscar en la base de datos BSCS, los datos de la linea
'* Input               :  K_CO_ID 
'* Output              :  K_CURSOR (El cursor lleva todos los datos del cliente)
'* Creado por          :  (Venkizmet) Rossana Janampa       
'* Fec Creación        :  01/09/2010
'* Fec Actualización   :  03/09/2010
'****************************************************************/    
BEGIN
  -- Cursor que devuelve el resultado
  OPEN K_cursor FOR
  SELECT dn.dn_num telefono,
       rp.des plan,
         decode(substr(rp.shdes,1,3),'CON','C',
                decode(rp.tmcode,(SELECT ap.tmcode FROM tim.pp_amp_plan@DBL_BSCS ap
                                   WHERE ap.tmcode=rp.tmcode ),'R','P')) flag_plataforma,
       co.tmcode codigo_plan_tarifario
                                          
    FROM contract_all@DBL_BSCS co,
         curr_co_status@DBL_BSCS ch,
         reasonstatus_all@DBL_BSCS rs,
         curr_co_device@DBL_BSCS cd,
         port@DBL_BSCS p,
         storage_medium@DBL_BSCS sm,
         curr_contr_services_cap@DBL_BSCS csc,
         directory_number@DBL_BSCS dn,
         customer_all@DBL_BSCS cu,
         rateplan@DBL_BSCS rp,
         info_contr_combo@DBL_BSCS icc
         
   WHERE co.co_id = ch.co_id
     AND ch.ch_reason = rs.rs_id
     AND cd.port_id = p.port_id
     AND co.co_id = cd.co_id
     AND sm.sm_serialnum  = cd.cd_sm_num
     AND csc.dn_id = dn.dn_id
     AND co.co_id = csc.co_id
     AND co.co_id = icc.co_id(+)
     AND co.customer_id = cu.customer_id
     AND co.tmcode = rp.tmcode
     AND co.co_id = K_co_id   ;
END;   

PROCEDURE ADMPSS_TRIADOS ( K_CO_ID     IN  NUMBER,
                          K_CURSOR    OUT SYS_REFCURSOR)
   IS
--****************************************************************
-- Nombre SP           :  ADMPSS_TRIADOS
-- Propósito           :  Devuelve en un cursor con los numeros frecuentes de un CO_ID
-- Input               :  K_CO_ID
-- Output              :  CursorServPend
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  16/09/2010
-- Fec Actualización   :  
--****************************************************************

       v_msisdn              directory_number.dn_num%TYPE;
   BEGIN
     v_msisdn := '51' || TIM.TFUN051_GET_DNNUM_FROM_COID@DBL_BSCS(k_co_id);

     OPEN k_cursor FOR
         SELECT /*+ use_nl(ff fx) */
                ff.des Tipo_triado,
                --fx.ff_element_seqno num_trio,
                TIM.TFUN064_VALIDA_SECUENCIA@DBL_BSCS(fx.ff_element_seqno, k_co_id) num_trio,
                decode(substr(fx.destination,1,3),'512','51'||substr(fx.destination,7),fx.destination) telefono,
                to_char(ff.scalefactor*100,'999.99')||'%' factor,
                TIM.PP012_TRIACIONES.FN_TIPO_DESTINO@DBL_BSCS(v_msisdn, fx.destination, 'C') AS Cod_Tipo_Destino,
                TIM.PP012_TRIACIONES.FN_TIPO_DESTINO@DBL_BSCS(v_msisdn, fx.destination, 'T') AS Tipo_Destino
         FROM   mpufftab@DBL_BSCS ff, mpulkfxo@DBL_BSCS fx
         WHERE  ff.ffcode = fx.ffcode
                AND co_id = k_co_id
                AND fx.destination NOT LIKE '510%'
         ORDER BY ff.ffcode, fx.ff_element_seqno;            
         
END;
   
PROCEDURE ADMPSS_LEESERPN(K_FECHAPROC IN DATE, CursorServPend out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSS_LEESERPN
-- Propósito           :  Devuelve en un cursor con los Servicios por Bono de Bienvenida y Debito Automatico Pendientes de Activar
-- Input               :  K_FECHAPROC
-- Output              :  CursorServPend
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  16/09/2010
-- Fec Actualización   :  
--****************************************************************
BEGIN
OPEN CursorServPend FOR
SELECT ADMPN_ID_FILA, ADMPV_NUM_LINEA, ADMPN_SN_CODE, ADMPN_SP_CODE, ADPMV_ACCION
  FROM ADMPT_SERV_PEND
 WHERE TO_DATE(TO_CHAR(ADMPD_FEC_REG,'YYYYMMDD'),'YYYYMMDD') <= K_FECHAPROC AND  
       ADMPC_ESTADO = 'P';
END;  

PROCEDURE ADMPSS_ACTSERPN(K_IDFILA IN NUMBER, K_USUARIO IN VARCHAR2, K_MENSAJE IN VARCHAR2) is
--****************************************************************
-- Nombre SP           :  ADMPSS_ACTSERPN
-- Propósito           :  Actualiza el Servicio Pendiente de Activacion
-- Input               :  K_IDFILA  - Fila del registro a actualizar
--                        K_USUARIO - Usuario que realizo la actualizacion
--                        K_MENSAJE - Mensaje que envia el Shell
-- Output              :  
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  16/09/2010
-- Fec Actualización   :  
--****************************************************************
BEGIN
   UPDATE ADMPT_SERV_PEND
      SET ADMPC_ESTADO  = 'E',               -- Ejecutado
          ADMPD_FEC_PRO = SYSDATE,
          ADMPV_USUARIO = K_USUARIO,
          ADMPV_MENSAJE = K_MENSAJE
    WHERE ADMPN_ID_FILA = K_IDFILA;
    
    COMMIT;

END;   

procedure ADMPSI_CLIREFINV (K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
is

/****************************************************************
'* Nombre SP           :  ADMPSI_CLIREFINV
'* Propósito           :  Lee los registros dejados por Inventarte, los inserta en la tabla temporal y luego los inserta en la tabla q genera el file para IB
'* Input               :  K_FECHA, K_NOM_ARCH
'* Output              :  K_CODERROR, K_DESCERROR
'* Creado por          :  Stiven Saavedra
'* Fec Creación        :
'* Fec Actualización   :  04/10/2010
'****************************************************************/

CURSOR REFINVENTARTE IS
SELECT ADMPV_NOMBRES, ADMPV_APELLIDOS, ADMPV_TIPO_DOC, ADMPV_NUM_DOC, ADMPV_NUM_LINEA, ADMPV_NUM_REFER
  FROM PCLUB.ADMPT_TMP_REFINVEN;

V_NOMBRES  VARCHAR (40);
V_APELLIDO VARCHAR (80);
V_TIPDOC   VARCHAR (2);
V_NUMDOC   VARCHAR (20);
V_NUMLINEA VARCHAR2(20);
V_NUMREF   VARCHAR2(20);
V_CODERROR NUMBER;
V_DESCERROR VARCHAR (400);

BEGIN

  OPEN REFINVENTARTE; -- Quitar Servicio
  FETCH REFINVENTARTE INTO V_NOMBRES, V_APELLIDO, V_TIPDOC, V_NUMDOC, V_NUMLINEA, V_NUMREF;
  WHILE REFINVENTARTE %FOUND LOOP
    BEGIN

         PKG_CLAROCLUB.ADMPSS_CLIREFER (V_NOMBRES, V_APELLIDO, V_TIPDOC, V_NUMDOC, V_NUMLINEA, V_NUMREF, null, V_CODERROR, V_DESCERROR);

         IF V_CODERROR > 0 THEN
            UPDATE PCLUB.ADMPT_TMP_REFINVEN
               SET ADMPC_COD_ERROR = V_CODERROR,
                   ADMPV_MSJE_ERROR = V_DESCERROR
             WHERE ADMPV_NOMBRES = V_NOMBRES
                   AND ADMPV_APELLIDOS = V_APELLIDO
                   AND ADMPV_TIPO_DOC = V_TIPDOC
                   AND ADMPV_NUM_DOC = V_NUMDOC;
         END IF;


     END;    
     FETCH REFINVENTARTE INTO V_NOMBRES, V_APELLIDO, V_TIPDOC, V_NUMDOC, V_NUMLINEA, V_NUMREF;
      
    END LOOP;
    CLOSE REFINVENTARTE;

COMMIT;

K_CODERROR:=0;
K_DESCERROR:='';

EXCEPTION
    WHEN OTHERS THEN
       k_coderror:=SQLCODE;
       k_descerror:=SUBSTR(SQLERRM,1,400);

END ADMPSI_CLIREFINV;

procedure ADMPSI_ECLIREFINV (CursorRefInv out SYS_REFCURSOR)
IS
/****************************************************************
'* Nombre SP           :  ADMPSI_ECLIREFINV
'* Propósito           :  Devuelve los registros con error de los clientes refereidos enviados por Inventarte
'* Input               :  
'* Output              :  Cursor
'* Creado por          :  Stiven Saavedra
'* Fec Creación        :
'* Fec Actualización   :  04/10/2010
'****************************************************************/
BEGIN
    OPEN CursorRefInv FOR
    SELECT ADMPV_NOMBRES, ADMPV_APELLIDOS, ADMPV_TIPO_DOC, ADMPV_NUM_DOC, ADMPV_NUM_LINEA, ADMPV_NUM_REFER,
           trim(NVL(ADMPC_COD_ERROR,'0')), ADMPV_MSJE_ERROR
      FROM ADMPT_TMP_REFINVEN
     WHERE ADMPC_COD_ERROR IS NOT NULL AND ADMPV_MSJE_ERROR <> ' ';
   
   DELETE FROM ADMPT_TMP_REFINVEN;         
   COMMIT;

END ADMPSI_ECLIREFINV;

PROCEDURE ADMPSS_SP_STATUS_DN_NUM_CO_ID (p_flag IN INTEGER,p_valor IN VARCHAR2, v_flag_resultado OUT INTEGER, v_error OUT INTEGER, v_des_error OUT VARCHAR2)
IS
  v_ch_status VARCHAR2(1);
  v_co_id INTEGER;
  v_cont INTEGER;
BEGIN


   /*DEVUELVE v_flag_resultado=0 : SI EL CONTRATO ESTA SUSPENDIDO O BLOQUEADO
              v_flag_resultado=1 : SI ESTA ACTIVO Y SIN BLOQUEO
   */


   v_error:=0;
   v_des_error:='OK';
   v_flag_resultado:=1;

   IF p_flag =1 THEN -- BUSCAR POR NUMERO
      --Ultimo contrato dueño del numero
      v_co_id:=TIM.TFUN006_GET_COID_FROM_DN@DBL_BSCS(p_valor);
      IF v_co_id=-1 THEN
       v_flag_resultado:=-1;
       v_error:=1;
       v_des_error:='NUMERO NO EXISTE';

      END IF;

   ELSIF p_flag =2 THEN --BUSCAR POR CONTRATO
       v_co_id:=p_valor;
   ELSE
       v_flag_resultado:=-1;
       v_error:=2;
       v_des_error:='PARAMETRO FLAG INCORRECTO';
   END IF;

   IF v_error = 0 THEN
      BEGIN
        SELECT PP.CH_STATUS
        INTO  v_ch_status
        FROM TIM.PP_DATOS_CONTRATO@DBL_BSCS PP
        WHERE PP.CO_ID=v_co_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         v_flag_resultado:= -1;
         v_error:=2;
         v_des_error:='CONTRATO NO EXISTE';
      END;

      IF v_ch_status = 'a' THEN
          SELECT COUNT(1)
          INTO v_cont
          FROM profile_service@DBL_BSCS ps, pr_serv_status_hist@DBL_BSCS ssh
          WHERE ps.co_id = ssh.co_id
                AND ps.sncode = ssh.sncode
                AND ps.status_histno = ssh.histno
                AND ps.sncode IN (9,1201,1125)
                AND ssh.status = 'A'
                AND ps.co_id = v_co_id;
      ELSE
         v_flag_resultado:=0;
      END IF;

      IF v_cont = 0 AND v_ch_status = 'a' THEN
         v_flag_resultado:=1;
      ELSE
          v_flag_resultado:=0;
      END IF;

   END IF;

EXCEPTION

 WHEN OTHERS THEN
   v_flag_resultado:=-1;
   v_error:=SQLCODE;
   v_des_error:=SQLERRM;

END;

procedure ADMPSS_CADUC_IB(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) is

--****************************************************************
-- Nombre SP           :  ADMPSS_CADUC_IB
-- Propósito           :  Invoca a los SP de vencimientos de Puntos y de Bono de Activacion
-- Input               :  
--                        
-- Output              :  K_CODERROR     --> Código de Error (si se presento)
--                        K_MSJERROR     --> Mensaje de Error
--                        
-- Creado por          :  Sofia Khlebnikov 
-- Fec Creación        :  27/09/2010
-- Fec Actualización   :
--****************************************************************

K_CODERRORP NUMBER;
K_DESCERRORP VARCHAR2(150);

ERRORBD_PUNTVENC EXCEPTION;
ERRORBD_BONOVENC EXCEPTION;

begin
  
   ADMPSS_PUNTVENC(K_CODERRORP ,K_DESCERRORP);
   
   IF(K_CODERRORP=0) THEN
     ADMPSS_BONOVENC(K_CODERRORP ,K_DESCERRORP);
     
      IF(K_CODERRORP<>0)THEN
      
        RAISE ERRORBD_BONOVENC;
        
      END IF;
   ELSE
      RAISE ERRORBD_PUNTVENC; 
   END IF;
   
   
  
  K_CODERROR:= 0;
  K_DESCERROR:= '';
  
  EXCEPTION
    
    WHEN ERRORBD_PUNTVENC THEN
     
     K_CODERROR:= K_CODERRORP;
     K_DESCERROR:= K_DESCERRORP ||'  ERROR DE BD EN SP ADMPSS_PUNTVENC';
     
    WHEN ERRORBD_BONOVENC THEN
     
     K_CODERROR:= K_CODERRORP;
     K_DESCERROR:= K_DESCERRORP ||'  ERROR DE BD EN SP ADMPSS_BONOVENC'; 
     
    WHEN OTHERS THEN
      
     K_CODERROR:=to_char(SQLCODE);
     K_DESCERROR:= SUBSTR(SQLERRM,1,400); 
  
end ADMPSS_CADUC_IB;

procedure ADMPSS_PUNTVENC(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) is

--****************************************************************
-- Nombre SP           :  ADMPSS_PUNTVENC
-- Propósito           :  Cancelar los puntos por Vencimiento
--
-- Input               :  
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  SK
-- Fec Creación        :  06/09/2010
-- Fec Actualización   :
--****************************************************************


V_SUMA NUMBER;
V_CODIB NUMBER;
V_CODCLIB NUMBER;
V_VIGENCIA NUMBER;
V_CODCONPTO VARCHAR2(2);
V_DESCRIP VARCHAR2(50);
V_TIPOPTO CHAR(1);
V_CONCEPTO VARCHAR2(2);


V_CODCLIENTECC VARCHAR2(40);
V_CODCC VARCHAR2(40);


NO_DATA_CURSOR EXCEPTION;
NO_PUNTOS_CURSOR EXCEPTION;


CURSOR CONCEPTOS IS
  SELECT ADMPV_COD_CPTO,
         ADMPV_DESC,
         ADMPN_PER_CADU,
         ADMPC_TPO_PUNTO
  FROM PCLUB.admpt_concepto
  WHERE ADMPC_ESTADO IN ('A')
        AND ADMPN_PER_CADU>0
        AND ADMPV_DESC NOT LIKE '%DEBITO AUTOMATICO TC%' 
        AND ADMPV_DESC NOT LIKE '%BONO CADUCADO%';  


CURSOR PUNTOSVENCIB(cod_concepto varchar2,tipo_punto char,vigencia number) IS
  SELECT k.ADMPN_COD_CLI_IB,
         SUM(k.ADMPN_SLD_PUNTO)
         
  FROM PCLUB.admpt_kardex k,PCLUB.admpt_clienteib c
  WHERE months_between(SYSDATE,k.ADMPD_FEC_TRANS)>vigencia 
          AND k.ADMPC_TPO_PUNTO=tipo_punto
          AND k.ADMPC_TPO_OPER='E' 
          AND k.ADMPV_COD_CPTO=cod_concepto 
          AND k.ADMPC_ESTADO IN ('A','S') 
          AND k.ADMPN_COD_CLI_IB=c.ADMPN_COD_CLI_IB
          AND c.ADMPC_ESTADO='A'
  GROUP BY k.ADMPN_COD_CLI_IB;
  
  
CURSOR PUNTOSVENCC(cod_concepto varchar2,tipo_punto char,vigencia number) IS
  SELECT k.ADMPV_COD_CLI,
         SUM(k.ADMPN_SLD_PUNTO)
         
  FROM PCLUB.admpt_kardex k, PCLUB.admpt_cliente c
  WHERE months_between(SYSDATE,k.ADMPD_FEC_TRANS)>vigencia 
          AND k.ADMPC_TPO_PUNTO=tipo_punto
          AND k.ADMPC_TPO_OPER='E' 
          AND k.ADMPV_COD_CPTO=cod_concepto 
          AND k.ADMPC_ESTADO IN ('A','S')
          AND k.ADMPV_COD_CLI=c.ADMPV_COD_CLI
          AND c.ADMPC_ESTADO='A'  
  GROUP BY k.ADMPV_COD_CLI;  

------------------ejecucion del cursos-------------------

BEGIN
       
  OPEN CONCEPTOS;
  FETCH CONCEPTOS INTO V_CODCONPTO,V_DESCRIP,V_VIGENCIA,V_TIPOPTO;
    IF(CONCEPTOS %rowcount=0)   THEN
        RAISE NO_DATA_CURSOR;
    END IF; 
  
  WHILE CONCEPTOS %FOUND LOOP
     
   IF (V_VIGENCIA >0 ) THEN
          
     IF (V_TIPOPTO='I') THEN
   
       BEGIN 
    
         OPEN PUNTOSVENCIB(V_CODCONPTO,V_TIPOPTO,V_VIGENCIA);                 
         FETCH PUNTOSVENCIB INTO V_CODIB,V_SUMA;
         
          IF(PUNTOSVENCIB %rowcount=0)   THEN
            RAISE NO_PUNTOS_CURSOR;
          END IF;
         
         WHILE PUNTOSVENCIB %FOUND LOOP
           
         BEGIN
            
            BEGIN
              SELECT NVL(ADMPV_COD_CLI,NULL) INTO V_CODCLIENTECC
              FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPN_COD_CLI_IB=V_CODIB;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     V_CODCLIENTECC:=NULL;
            END; 
            
            
            BEGIN
              SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CONCEPTO
              FROM PCLUB.ADMPT_CONCEPTO
              WHERE ADMPV_DESC LIKE '%VENCIMIENTO DE PUNTOS';
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     V_CONCEPTO:=NULL;
            END;
            
             
            INSERT INTO PCLUB.admpt_kardex (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                    ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS,
                                    ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO,
                                    ADMPN_SLD_PUNTO, ADMPC_ESTADO)
            VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, V_CODIB, V_CODCLIENTECC,V_CONCEPTO,
                   SYSDATE,V_SUMA*(-1),null,'S','I',0,'V');
          
            UPDATE PCLUB.admpt_kardex SET
                   ADMPC_ESTADO='V',
                   ADMPN_SLD_PUNTO=0
            WHERE  ADMPN_COD_CLI_IB=V_CODIB
                   AND months_between(SYSDATE,ADMPD_FEC_TRANS)>V_VIGENCIA  
                   AND ADMPC_TPO_PUNTO='I'
                   AND ADMPV_COD_CPTO=V_CODCONPTO
                   AND ADMPC_ESTADO in ('A','S');       
            
            IF(V_SUMA>0)THEN
             V_SUMA:=V_SUMA;
            ELSE
             V_SUMA:=V_SUMA*(-1);  
            END IF;
                   
            BEGIN     
              UPDATE PCLUB.admpt_saldos_cliente SET
                     ADMPN_SALDO_IB=ADMPN_SALDO_IB-V_SUMA
              WHERE  ADMPN_COD_CLI_IB=V_CODIB;
              EXCEPTION
                 WHEN OTHERS THEN NULL;
            END;   
            
           COMMIT;
         END;
        
         FETCH PUNTOSVENCIB INTO V_CODIB,V_SUMA; 
        
         END LOOP;
         CLOSE PUNTOSVENCIB;
   
       END;
       
     ELSE
            
       BEGIN
         
         OPEN PUNTOSVENCC(V_CODCONPTO,V_TIPOPTO,V_VIGENCIA);
         FETCH PUNTOSVENCC INTO V_CODCC,V_SUMA;
         
          IF(PUNTOSVENCC %rowcount=0)   THEN
            RAISE NO_PUNTOS_CURSOR;
          END IF;
         
         WHILE PUNTOSVENCC %FOUND LOOP
           
         BEGIN
           
            BEGIN
              SELECT NVL(ADMPN_COD_CLI_IB,NULL) INTO V_CODCLIB
              FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI=V_CODCC;
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     V_CODCLIB:=NULL;
            END; 
            
            BEGIN
              SELECT NVL(ADMPV_COD_CPTO,NULL) INTO V_CONCEPTO
              FROM PCLUB.ADMPT_CONCEPTO
              WHERE ADMPV_DESC LIKE '%VENCIMIENTO DE PUNTOS';
              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     V_CONCEPTO:=NULL;
            END;
             
            INSERT INTO PCLUB.admpt_kardex (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                    ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS,
                                    ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO,
                                    ADMPN_SLD_PUNTO, ADMPC_ESTADO)
            VALUES(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL, V_CODCLIB, V_CODCC,V_CONCEPTO,
                   SYSDATE,V_SUMA*(-1),null,'S','C',0,'V');
          
            UPDATE PCLUB.admpt_kardex SET
                   ADMPC_ESTADO='V',
                   ADMPN_SLD_PUNTO=0
            WHERE  ADMPV_COD_CLI=V_CODCC
                   AND months_between(SYSDATE,ADMPD_FEC_TRANS)>V_VIGENCIA  
                   AND ADMPC_TPO_PUNTO='C'
                   AND ADMPV_COD_CPTO=V_CODCONPTO
                   AND ADMPC_ESTADO in ('A','S'); 
            
            
            IF(V_SUMA>0)THEN
             V_SUMA:=V_SUMA;
            ELSE
             V_SUMA:=V_SUMA*(-1);  
            END IF;
                   
            BEGIN     
              UPDATE PCLUB.admpt_saldos_cliente SET
                     ADMPN_SALDO_CC=ADMPN_SALDO_CC-V_SUMA
              WHERE  ADMPV_COD_CLI=V_CODCC;
              EXCEPTION
                 WHEN OTHERS THEN NULL;
            END;   
           
           COMMIT;
         END;
        
         FETCH PUNTOSVENCC INTO V_CODCC,V_SUMA; 
        
         END LOOP;
         CLOSE PUNTOSVENCC;
       
       END; 
       
     END IF;  
   
  
   END IF;
  
    
  FETCH CONCEPTOS INTO V_CODCONPTO,V_DESCRIP,V_VIGENCIA,V_TIPOPTO;
  END LOOP;
  CLOSE CONCEPTOS;    
  
  K_CODERROR:=0; -- Correcto
  K_DESCERROR:='';
  
EXCEPTION
  
  WHEN NO_DATA_CURSOR THEN
   K_CODERROR:=42;
   K_DESCERROR:='No hay registros de conceptos ';
   
  WHEN NO_PUNTOS_CURSOR THEN
   K_CODERROR:=43;
   K_DESCERROR:='No hay registros de puntos vencidos '; 
     
  WHEN OTHERS THEN
   K_CODERROR:=SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,400);
   ROLLBACK;
                              
end ADMPSS_PUNTVENC;

procedure ADMPSS_BONOVENC(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) is

V_VIGENCIA NUMBER;

BEGIN
   
   BEGIN
     SELECT NVL(ADMPN_PER_CADU,0) INTO V_VIGENCIA
     FROM PCLUB.admpt_concepto
     WHERE ADMPV_COD_CPTO='10' 
           AND ADMPV_DESC LIKE '%BONO CADUCADO%';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         V_VIGENCIA:=0;
             
   END;      
   
   IF (V_VIGENCIA>0) THEN 
         
     UPDATE PCLUB.admpt_clienteib SET
            ADMPN_BONO_ACT=2
     WHERE  months_between(SYSDATE,ADMPD_FEC_ACT)>V_VIGENCIA
            AND ADMPN_BONO_ACT = 0
            AND ADMPC_ESTADO NOT IN ('B'); 
            
     COMMIT; 
          
   END IF; 
   
   K_CODERROR:=0;
   K_DESCERROR:='';
   
   EXCEPTION
    WHEN OTHERS THEN
     
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,400);                    
     rollback;
     
END ADMPSS_BONOVENC;

procedure ADMPSS_EACAMOCC(K_FECHAPROC IN DATE, CURSOREACCAMO out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSS_EACAMOIB
-- Propósito           :  Devuelve en un cursor los registros procesados del diario incluyendo los errores encontrados por registros
-- Input               :  K_FECHAPROC
-- Output              :  CursorAcCaMo
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  29/10/2010
-- Fec Actualización   :  
--****************************************************************
BEGIN
OPEN CursorEAcCaMo FOR
SELECT  trim(ADMPC_COD_TRANS), ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_NOM_PRI,ADMPV_NOM_SEG ,ADMPV_APE_PAT,ADMPV_APE_MAT , ADMPV_NUM_LINEA, to_char (ADMPD_FEC_ACT, 'yyyymmdd'),
        trim(ADMPC_ACEP_BONO),trim(NVL(ADMPC_COD_ERROR,'0')), ADMPV_MSJE_ERROR		
FROM PCLUB.ADMPT_IMP_ACCAMO_IB
WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
      ADMPC_COD_ERROR IS NOT NULL AND
      TRIM (ADMPC_COD_ERROR) <> ' '
ORDER BY admpn_seq ASC;

end;

procedure ADMPSS_EFACAMCC (K_FECHAPROC IN DATE, CursorEFaCaIB out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSS_EFACAMIB
-- Propósito           :  Devuelve en un cursor los registros procesados del archivo mensual incluyendo los errores encontrados por registros
-- Input               :  K_FECHAPROC
-- Output              :  CursorFaCaIB
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  29/10/2010
-- Fec Actualización   :  
--****************************************************************
BEGIN
OPEN CursorEFaCaIB FOR
SELECT trim(admpc_cod_trans), admpv_tipo_doc, admpv_num_doc, admpc_signo,
       admpn_puntos, admpv_nom_camp, trim(NVL(ADMPC_COD_ERROR,'0')), ADMPV_MSJE_ERROR
  FROM PCLUB.admpt_imp_facade_ib
 WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
       ADMPC_COD_ERROR IS NOT NULL AND
       TRIM (ADMPC_COD_ERROR) <> ' ';

end;

procedure ADMPSI_EDEBITCC(K_FECHAPROC IN DATE, CursorEDebito out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_EDEBITIB
-- Propósito           :  Devuelve en un cursor los registros procesados de Debito Automatico incluyendo los errores encontrados por registros 
-- Input               :  K_FECHAPROC
-- Output              :  CursorFaCaIB
-- Creado por          :  (Venkizmet) Stiven Saavedra
-- Fec Creación        :  29/10/2010
-- Fec Actualización   :  
--****************************************************************  

  BEGIN
    OPEN CursorEDebito FOR
    SELECT admpv_cod_cli,admpv_num_fact,admpn_monto_fac,admpn_monto_pag,admpn_monto_deb,
           trim(NVL(ADMPC_COD_ERROR,'0')), admpv_msje_error
      FROM PCLUB.admpt_imp_debito_ib
     WHERE ADMPD_FEC_OPER=K_FECHAPROC AND
           ADMPC_COD_ERROR IS NOT NULL AND
           TRIM (ADMPC_COD_ERROR) <> ' ';
  END;

procedure ADMPSI_CLMOR_IB(K_FECHA IN DATE,K_CODERROR OUT VARCHAR2,K_MSJERROR OUT VARCHAR2) is

--****************************************************************
-- Nombre SP           :  ADMPSI_CLMOR_IB
-- Propósito           :  Ejecutar el proceso diariamente para suspender los puntos de los clientes morosos
--
-- Input               :  K_FECHAPROCESO
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  SK
-- Fec Creación        :  23/08/2010
-- Fec Actualización   :
--****************************************************************


V_REGCLI NUMBER;  /* DEVUELVE 1 SI EXISTEEL REGISTRO EN TABLA AUX  0 SI NO */
V_CODIB NUMBER;
V_CODIBS NUMBER;
V_TPODOCIBEQ VARCHAR2(20);
V_CODIBER NUMBER;
 

C_CODCLIENTEIB NUMBER;
C_TIPODOCUMENTO VARCHAR2(20);
C_NUMDOCUMENTO VARCHAR2(20);
C_FECPROCESO DATE;
C_NOMARCHIVO VARCHAR2(150);
C_CODTRANSAC CHAR(3);


  CURSOR CLIENTEIBMOR  IS
   SELECT c.ADMPN_COD_CLI_IB,
          a.ADMPV_TIPO_DOC,
          a.ADMPV_NUM_DOC,
          a.ADMPD_FEC_OPER,
          a.ADMPV_NOM_ARCH,
          a.ADMPC_COD_TRANS
   FROM PCLUB.ADMPT_TMP_ACCAMO_IB  a, PCLUB.ADMPT_CLIENTEIB c
   WHERE a.ADMPD_FEC_OPER=K_FECHA--to_date(K_FECHA,'MM/DD/YYYY')
         AND c.ADMPC_ESTADO<>'B'
         AND a.ADMPC_COD_TRANS='3'
         --AND a.ADMPV_TIPO_DOC=c.ADMPV_TIPO_DOC
         AND a.ADMPV_NUM_DOC=c.ADMPV_NUM_DOC
         AND a.ADMPC_COD_ERROR IS NULL;

BEGIN

  UPDATE PCLUB.admpt_kardex SET
         ADMPC_ESTADO='A'
  WHERE  ADMPC_TPO_PUNTO = 'I' 
         AND ADMPC_TPO_OPER = 'E'
         AND ADMPC_ESTADO = 'S';

  UPDATE PCLUB.admpt_saldos_cliente SET
         ADMPC_ESTPTO_IB='A'
  WHERE  ADMPC_ESTPTO_IB IN 'S';

  UPDATE PCLUB.admpt_clienteib SET
         ADMPC_ESTADO='A'
  WHERE ADMPC_ESTADO IN 'S';

  COMMIT;

   OPEN CLIENTEIBMOR;
  FETCH CLIENTEIBMOR INTO C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;
      
  WHILE CLIENTEIBMOR%FOUND LOOP    

    SELECT COUNT(*)INTO V_REGCLI FROM ADMPT_AUX_ACCAMO_IB
    WHERE ADMPV_TIPO_DOC=C_TIPODOCUMENTO
          AND ADMPV_NUM_DOC=C_NUMDOCUMENTO
          AND ADMPD_FEC_OPER=C_FECPROCESO
          AND NVL(ADMPV_NOM_ARCH,NULL)=C_NOMARCHIVO
          AND ADMPC_COD_TRANS=C_CODTRANSAC;
          
    /*Obtiene el tipo de documento de Claro equivalente al de IB*/      
    BEGIN
      SELECT NVL(ADMPV_COD_TPDOC,NULL) INTO V_TPODOCIBEQ
      FROM PCLUB.admpt_tipo_doc
      WHERE ADMPV_COD_EQUIV = C_TIPODOCUMENTO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           V_TPODOCIBEQ:=NULL;
    END;      
       
    BEGIN
      SELECT  NVL(ADMPN_COD_CLI_IB,0) INTO V_CODIBER
      FROM PCLUB.ADMPT_CLIENTEIB
      WHERE  ADMPV_TIPO_DOC= V_TPODOCIBEQ
             AND ADMPV_NUM_DOC=C_NUMDOCUMENTO;
      
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            V_CODIBER:=0;
    END; 
   
    IF (V_REGCLI=0 AND V_CODIBER <> 0) THEN

      BEGIN
       
         BEGIN
           SELECT COUNT(ADMPN_COD_CLI_IB) INTO V_CODIB
           FROM PCLUB.ADMPT_KARDEX
           WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
               V_CODIB:=0;
         END;

         IF(V_CODIB <> 0) THEN
           BEGIN
              UPDATE PCLUB.admpt_kardex SET
                     ADMPC_ESTADO='S'
              WHERE  ADMPC_TPO_PUNTO='I' 
                     AND ADMPC_ESTADO NOT IN('C','V')
                     AND ADMPC_TPO_OPER = 'E'
                     AND ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
           END;
         END IF;
          
         BEGIN
           SELECT COUNT(ADMPN_COD_CLI_IB) INTO V_CODIBS
           FROM PCLUB.admpt_saldos_cliente
           WHERE ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
               V_CODIBS:=0;
         END;
         
         IF(V_CODIBS <> 0) THEN
           BEGIN
             UPDATE PCLUB.admpt_saldos_cliente SET
                    ADMPC_ESTPTO_IB='S'
             WHERE  ADMPC_ESTPTO_IB NOT IN 'C'
                    AND ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
           END;
         END IF;
                

         UPDATE PCLUB.admpt_clienteib SET
                ADMPC_ESTADO='S'
         WHERE  ADMPC_ESTADO NOT IN 'B'
                AND ADMPN_COD_CLI_IB=C_CODCLIENTEIB;
                
                
         INSERT INTO PCLUB.ADMPT_AUX_ACCAMO_IB (ADMPC_COD_TRANS,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,
                                                   ADMPD_FEC_OPER,ADMPV_NOM_ARCH)
         VALUES(C_CODTRANSAC,C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO);      

       COMMIT;

      END;

    END IF;  /* FIN DE VERIFICA DEL REGISTRO EN TABLA AUX_ACCAMO*/

  FETCH CLIENTEIBMOR INTO  C_CODCLIENTEIB, C_TIPODOCUMENTO, C_NUMDOCUMENTO,C_FECPROCESO,C_NOMARCHIVO,C_CODTRANSAC;

  END LOOP;
    
  CLOSE CLIENTEIBMOR;

  K_CODERROR:='0'; -- Correcto
  K_MSJERROR:='';

 EXCEPTION
   WHEN OTHERS THEN
     K_CODERROR:=to_char(SQLCODE);
     K_MSJERROR:= SUBSTR(SQLERRM,1,400);
     ROLLBACK;

end ADMPSI_CLMOR_IB;

END PKG_CLAROCLUB;