CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_ACUMULACION IS

          
PROCEDURE SP_ACUMULACION( codigoContrato       IN VARCHAR2,
                          numerolinea          IN VARCHAR2,
                          fechaOperacion       IN DATE,
                          cantidadPuntos       IN NUMBER, 
                          tipoPuntos           IN NUMBER,
                          origen               IN VARCHAR2,
                          concepto             IN VARCHAR2,
                          codigoRespuesta      OUT VARCHAR2,
                          mensajeRespuesta     OUT VARCHAR2 ) IS 
--****************************************************************
-- Nombre SP           :  SP_ACUMULACION
-- Propósito           :  Permite acumular puntos claro club
-- Input               :  codigoContrato     Codigo de Contrato
--                        numerolinea        Numero de la linea
--                        fechaOperacion     Fecha Actual
--                        cantidadPuntos     Cantidad de puntos a asignar
--                        tipoPuntos         Tipo de Puntos asignados
--                        origen             Origen o Canal
--                        concepto           Variable key estándar de consulta
-- Output              :  codigoRespuesta
--                        mensajeRespuesta
-- Creado por          :  Gian Marco Apolo
-- Fec Creación        :  17/07/2018
--****************************************************************
        
N_PUNTOS                   NUMBER;
N_CONTADOR1                NUMBER;
N_CONTADOR2                NUMBER;
N_CONTADORM                NUMBER;
N_CONTADORF                NUMBER;
V_CONCEPTO                 VARCHAR2(4);
v_LINEA                    VARCHAR2(9):=numerolinea;


BEGIN
      
      SELECT COUNT(1)INTO N_CONTADOR1 FROM PCLUB.admpt_cliente CT 
      WHERE ct.admpv_cod_cli=codigoContrato  ;
      
      SELECT COUNT(1)INTO N_CONTADOR2 FROM PCLUB.admpt_clientefija CT 
      WHERE ct.admpv_cod_cli=codigoContrato  ;
      
 
      
  IF (codigoContrato IS NOT NULL) THEN  
                                   
      IF N_CONTADOR1>0 OR N_CONTADOR2>0  THEN
           
         IF cantidadPuntos>0 THEN 
           
            --SOLO 1 CONTRATO
            SELECT COUNT(*)INTO N_CONTADORM FROM PCLUB.ADMPT_CLIENTE CM WHERE CM.ADMPV_COD_CLI=codigoContrato;
            SELECT COUNT(*)INTO N_CONTADORF FROM PCLUB.ADMPT_CLIENTEFIJA CF WHERE CF.ADMPV_COD_CLI=codigoContrato;                     
            SELECT COUNT(*) INTO V_CONCEPTO FROM PCLUB.ADMPT_CONCEPTO CT  WHERE CT.ADMPV_COD_CPTO=concepto;
            
            N_PUNTOS:=cantidadPuntos;
                     
            IF origen='TCRM' THEN
                          
               IF V_CONCEPTO>0 THEN
                               
                  IF N_CONTADORM>0 THEN
                                    
                     IF tipoPuntos=1 THEN
					 
                        --INSERTA EN LA TABLA KARDEX
                        INSERT INTO PCLUB.ADMPT_KARDEX
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
                        VALUES
                          (admpt_kardex_sq.nextval,
                           '',
                           codigoContrato,
                           concepto,
                           fechaOperacion,
                           N_PUNTOS,
                           origen,
                           'E',
                           'C',
                           N_PUNTOS,
                           'A');
                                                       
                          --ACTUALIZA LA TABLA DE SALDO_CLIENTE AÑADIENDO LA CANTIDAD DE PUNTOS
                          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE s
                             SET s.admpn_saldo_cc = s.admpn_saldo_cc + N_PUNTOS
                           WHERE s.admpv_cod_cli= codigoContrato;
                                               
                     ELSE 
                             codigoRespuesta := 1;
                             mensajeRespuesta:='ERROR EN TIPO DE PUNTO' ;
                             RETURN;
                     END IF; 
                     
                  ELSE
                    
                  IF N_CONTADORF>0 THEN
                                     
                     IF tipoPuntos=1 THEN
                                               
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
                                       ADMPC_ESTADO)
                               VALUES (ADMPT_KARDEXFIJA_SQ.NEXTVAL,
                                       '',
                                       codigoContrato,
                                       concepto,
                                       fechaOperacion,
                                       N_PUNTOS,
                                       origen,
                                       'E',
                                       'C',
                                       N_PUNTOS,
                                       'A');
                                                    
                                     UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA ss
                                     SET ss.admpn_saldo_cc= ss.admpn_saldo_cc + N_PUNTOS --V_TOTAL_PUNTOS,
                                     WHERE ss.admpv_cod_cli_prod= codigoContrato;
                     ELSE 
                             codigoRespuesta := 1;
                             mensajeRespuesta:='TIPO DE PUNTO INVALIDO' ;
                             RETURN;
                     END IF;
                     
                  ELSE 
                         codigoRespuesta := 1;
                         mensajeRespuesta:='CONTRATO CON TIPO DE PRODUCTO INVALIDO' ;
                         RETURN;
                  END IF;

                  END IF;
               ELSE
                       codigoRespuesta := 1;
                       mensajeRespuesta:='EL CONCEPTO INDICADO NO ESTA CONFIGURADO EN CLAROCLUB' ;
                       RETURN;
               END IF;
            ELSE
                   codigoRespuesta := 1;
                   mensajeRespuesta:='ORIGEN INVALIDO' ;
                   RETURN;
            END IF; 
         ELSE
                codigoRespuesta := 1;
                mensajeRespuesta:='ERROR : INGRESAR PUNTOS'; 
         
                RETURN;
         END IF;
      ELSE
           codigoRespuesta := 1;
           mensajeRespuesta:='CONTRATO INVALIDO O NO EXISTENTE EN CLARO CLUB'; 
         
           RETURN;
      END IF;  
  ELSE
         codigoRespuesta := 1;
         mensajeRespuesta:='INGRESAR CONTRATO'; 
         
         RETURN;
  END IF;   
                                  
 codigoRespuesta := 0;
 mensajeRespuesta:='Transaction ok';
            
      EXCEPTION
          WHEN OTHERS THEN
            codigoRespuesta := SQLCODE;
            mensajeRespuesta:= SUBSTR(SQLERRM,1,250);

END SP_ACUMULACION;

-------------------------------------------------------------------------------

PROCEDURE SP_ACUMULACION_TCRM (fechaOperacion IN DATE)IS
--****************************************************************
-- Nombre SP           :  SP_ACUMULACION_TCRM
-- Propósito           :  Permite acumular puntos claro club provenientes del OAC .
-- Input               :  fechaOperacion     Fecha Actual
-- Output              :  codigoRespuesta
--                        mensajeRespuesta
-- Creado por          :  Gian Marco Apolo / Jesus Meza
-- Fec Creación        :  20/07/2018
--****************************************************************
N_FAM                                      NUMBER:=0;
N_TEC                                      NUMBER:=0;
N_DIVISOR                                  NUMBER:=0;
N_FLAG                                     NUMBER:=0;
N_CONTADOR_1                               NUMBER:=0;
N_CONTADOR_2                               NUMBER:=0;
N_RESTO                                    NUMBER:=0;
N_NUMDIAS                                  NUMBER:=0;
N_DIF                                      NUMBER:=0;
N_MONTO                                    NUMBER:=0;
N_MON                                      NUMBER:=0;
N_ITERA_1                                  NUMBER:=1;
N_ITERA_2                                  NUMBER:=1;
N_ITERA_3                                  NUMBER:=0;
V_MAX                                      VARCHAR2(40);
V_CONCEP_PPAGO_N                           VARCHAR2(20);
codigoRespuesta                            VARCHAR2(20);
mensajeRespuesta                           VARCHAR2(40);

-------------------
TYPE LISTACONTRATOS  IS TABLE OF ADMPT_TMP_TCRM.COD_ID%TYPE;
LISTA1 LISTACONTRATOS;
TYPE LISTAFACTURACION IS TABLE OF ADMPT_TMP_TCRM.BILLINGACCOUNTID%TYPE;
LISTA2 LISTAFACTURACION;
-------------------
BEGIN

SELECT COUNT(*)INTO N_CONTADOR_1 FROM (SELECT DISTINCT TC.BILLINGACCOUNTID  FROM PCLUB.ADMPT_TMP_TCRM TC);
SELECT DISTINCT(TC.BILLINGACCOUNTID) BULK COLLECT INTO LISTA2 FROM PCLUB.ADMPT_TMP_TCRM TC WHERE TC.FEC_OPERA=TRUNC(SYSDATE); 

WHILE N_ITERA_2<=N_CONTADOR_1 LOOP

SELECT TC.PAIDAMOUNT INTO N_MONTO FROM PCLUB.ADMPT_TMP_TCRM TC WHERE
       TC.BILLINGACCOUNTID=LISTA2(N_ITERA_2) 
       GROUP BY TC.BILLINGACCOUNTID,TC.PAIDAMOUNT;

SELECT COUNT (TC.COD_ID) INTO N_DIVISOR FROM  PCLUB.ADMPT_TMP_TCRM TC
       WHERE TC.BILLINGACCOUNTID=LISTA2(N_ITERA_2) AND  TC.ESTADO='PENDIENTE'; --DIVISOR

N_RESTO:= MOD(N_MONTO, N_DIVISOR);  --ESTO DEVUELVE EL RESTO DE MONTO CON DIVISOR
N_MON:=TRUNC(N_MONTO/N_DIVISOR);	--PUNTOS

--SACA EL MAXIMO CONTRATO
SELECT MAX(a.COD_ID) INTO V_MAX FROM PCLUB.ADMPT_TMP_TCRM a WHERE a.BILLINGACCOUNTID=LISTA2(N_ITERA_2) AND a.ESTADO='PENDIENTE';

N_ITERA_1:=1;
N_FLAG 	 :=0;  

WHILE N_ITERA_1 <= N_DIVISOR LOOP
    --COLOCA EN LA LISTA LOS CODIGOS DE CONTRATOS
      SELECT A.COD_ID BULK COLLECT INTO LISTA1 FROM PCLUB.ADMPT_TMP_TCRM A WHERE A.BILLINGACCOUNTID=LISTA2(N_ITERA_2) AND A.ESTADO='PENDIENTE';
       
      SELECT COUNT(*) INTO N_CONTADOR_2  from PCLUB.admpt_contratos a  WHERE A.ADMPV_CODIGOCONTRATO=LISTA1(N_ITERA_1);
      
      IF N_CONTADOR_2=0 THEN
      N_FLAG:=1;
      N_ITERA_3:=N_ITERA_1;
      END IF;
     
      N_ITERA_1:=N_ITERA_1+1;
      
      
END LOOP;

IF N_FLAG=0 THEN

N_ITERA_1:=1;

                    WHILE N_ITERA_1 <= N_DIVISOR LOOP
                               
                                SELECT TO_NUMBER(ADMPV_VALOR)INTO N_NUMDIAS FROM PCLUB.ADMPT_PARAMSIST WHERE UPPER(ADMPV_DESC) = 'DIAS_VENCIMIENTO_PAGO_CC';
                                SELECT  TC.INVOICEEXPIRATIONDATE - TC.PAYMENTDATE  into N_DIF FROM PCLUB.ADMPT_TMP_TCRM TC WHERE TC.COD_ID=LISTA1(N_ITERA_1);  
                                                                                                                  
                                    IF N_DIF >= N_NUMDIAS then
                                      
                                      SELECT admpv_cod_cpto INTO V_CONCEP_PPAGO_N from PCLUB.ADMPT_CONCEPTO
                                                            WHERE admpv_desc = 'PRONTO PAGO NORMAL';
                                    ELSE
                                      
                                      SELECT admpv_cod_cpto INTO V_CONCEP_PPAGO_N from PCLUB.ADMPT_CONCEPTO
                                                            WHERE admpv_desc = 'CARGO FIJO';
                                    END IF;
                                    
                                    IF V_MAX = LISTA1(N_ITERA_1) THEN 
                                      --ASIGNAR MAYOR PUNTAJE AL MAXIMO CONTRATO
                                       N_MON:=N_MON+N_RESTO;
                               
                                    END IF;

                                    SELECT a.admpn_familia,a.admpn_tecnologia INTO N_FAM,N_TEC from PCLUB.admpt_contratos a INNER JOIN
                                    PCLUB.ADMPT_TMP_TCRM TC ON TC.COD_ID=LISTA1(N_ITERA_1) AND TC.COD_ID=A.ADMPV_CODIGOCONTRATO AND ROWNUM=1;

                                    IF N_FAM=1 THEN
                                    
                                      UPDATE PCLUB.ADMPT_TMP_TCRM TC SET TC.FLAG='M' WHERE TC.COD_ID=LISTA1(N_ITERA_1);
                                     
                                                --INSERTA DATOS AL KARDEX SEGUN CONTRATO DEFINIDO PARA MOVIL
                                                INSERT INTO PCLUB.ADMPT_KARDEX
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
                                                        VALUES
                                                          (admpt_kardex_sq.nextval,
                                                           '',
                                                           LISTA1(N_ITERA_1),
                                                           V_CONCEP_PPAGO_N,
                                                           fechaOperacion,
                                                           N_MON,
                                                           'TCRM',
                                                           'E',
                                                           'C',
                                                           N_MON,
                                                           'A');
											--ACTUALIZA LA TABLA DE SALDO_CLIENTE AÑADIENDO LA CANTIDAD DE PUNTOS
                                            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE s
                                               SET s.admpn_saldo_cc = s.admpn_saldo_cc + N_MON
                                             WHERE s.admpv_cod_cli= LISTA1(N_ITERA_1);
                                    -------------------------------------------
                                    ELSE 
									
                                      --FIJA
                                      IF  N_TEC=3 OR N_TEC=1 THEN
                                      
                                          UPDATE PCLUB.ADMPT_TMP_TCRM TC SET TC.FLAG='F' WHERE TC.COD_ID=LISTA1(N_ITERA_1);
                                   
                                               --INSERTA DATOS AL KARDEX SEGUN CONTRATO DEFINIDO PARA FIJA
                                               INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                                                          (admpn_id_kardex,
                                                           admpn_cod_cli_ib,
                                                           admpv_cod_cli_prod,
                                                           admpv_cod_cpto,
                                                           admpd_fec_trans,
                                                           admpn_puntos,
                                                           admpv_nom_arch,
                                                           admpc_tpo_oper,
                                                           admpc_tpo_punto,
                                                           admpn_sld_punto,
                                                           admpc_estado)
                                                        VALUES
                                                          (admpt_kardex_sq.nextval,
                                                           '',
                                                           LISTA1(N_ITERA_1),
                                                           V_CONCEP_PPAGO_N,
                                                           fechaOperacion,
                                                           N_MON,
                                                           'TCRM',
                                                           'E',
                                                           'C',
                                                           N_MON,
                                                           'A');
                                             --ACTUALIZA LA TABLA DE SALDO_CLIENTEFIJA AÑADIENDO LA CANTIDAD DE PUNTOS
                                             UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA ss
                                             SET ss.admpn_saldo_cc= ss.admpn_saldo_cc + N_MON
                                             WHERE ss.admpv_cod_cli_prod= LISTA1(N_ITERA_1);

                                      END IF;
                                       
                                     END IF;
                                     N_ITERA_1:=N_ITERA_1+1;
                                     N_FAM:=0;
                                     N_TEC:=0;
           
                          
                 END LOOP;
                  --ACTUALIZA EL FLAG DE PENDIENTE A PROCESADO
                    UPDATE PCLUB.ADMPT_TMP_TCRM TC SET TC.ESTADO='PROCESADO' WHERE TC.BILLINGACCOUNTID=LISTA2(N_ITERA_2);
                   
                 -- EXPORTAR DATOS PROCESADOS A TABLA HISTORICA
                    INSERT INTO PCLUB.ADMPT_TMP_TCRM_HT
                    SELECT TC.BSCSINVOICENUMBER,TC.BILLINGACCOUNTID,TC.COD_ID,TC.SUSCRIPTION,TC.PAYMENTDATE
                    ,TC.PAIDAMOUNT,TC.INVOICEEXPIRATIONDATE,TC.INVOICEISSUANCEDATE,TC.ADDITIONALPOINTSINDICATOR,
                    TC.FEC_OPERA,TC.ESTADO,TC.FLAG FROM PCLUB.ADMPT_TMP_TCRM TC WHERE TC.ESTADO='PROCESADO';
					
                  --ELIMINAMOS LOS REGISTROS PROCESADOS DE LA TABLA TEMPORAL
                    DELETE PCLUB.ADMPT_TMP_TCRM TC WHERE  TC.ESTADO='PROCESADO';
                  
ELSE
  
         UPDATE PCLUB.ADMPT_TMP_TCRM TC SET TC.CODIGOERROR='1',TC.DESCERROR='CONTRATO NO EXISTE',TC.ESTADO='PENDIENTE' WHERE
         TC.BILLINGACCOUNTID=LISTA2(N_ITERA_2) AND TC.COD_ID=LISTA1(N_ITERA_3);
               
END IF;

  N_ITERA_2:=N_ITERA_2+1;
  END LOOP;

  codigoRespuesta := 0;
  mensajeRespuesta:='Transaction ok';

EXCEPTION
    WHEN OTHERS THEN
    codigoRespuesta := '1';
    mensajeRespuesta:= 'ERROR'||SQLERRM; 


END SP_ACUMULACION_TCRM;
END PKG_ACUMULACION;
/