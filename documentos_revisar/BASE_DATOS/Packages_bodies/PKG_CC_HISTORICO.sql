create or replace package body PCLUB.PKG_CC_HISTORICO is


PROCEDURE ADMPSS_MIG_KARDEX(K_USRREG   IN VARCHAR2,
                            K_TAMPAG   IN NUMBER,
                            K_CANTDIAS IN NUMBER,               
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS                


   listaProcesar          NUMBER :=0;
   K_DURACION_EJECUCION   NUMBER :=0;
   vAcumDuracion_regMigr  NUMBER :=0;
   contRegMigrProcesado   NUMBER :=0;
   contRegMigrExito       NUMBER :=0;
   contRegMigrError       NUMBER :=0;
   ID_ESTADO_PROC    PCLUB.ADMPT_CONF_HISTORICO.ID_ESTADO_PROC%TYPE;
   ESTADO            PCLUB.ADMPT_CONF_HISTORICO.ESTADO_PROCESO%TYPE;
   FECINICIAL        PCLUB.ADMPT_CONF_HISTORICO.FECHA_REGIST%TYPE;



   CURSOR CUR_CONF_HISTORICO 
   IS 
      SELECT ID_ESTADO_PROC, ESTADO_PROCESO, FECHA_REGIST
      FROM PCLUB.ADMPT_CONF_HISTORICO
      WHERE ESTADO_EJECUCION = '1' 
      ORDER BY ID_ESTADO_PROC;

   TYPE TABLE_CUR_CONF_HISTORICO IS 
      TABLE OF CUR_CONF_HISTORICO%ROWTYPE
      INDEX BY PLS_INTEGER;

  l_TABLE_CUR_CONF_HISTORICO TABLE_CUR_CONF_HISTORICO;

BEGIN
   K_CODERROR         := 0;
   K_DESCERROR        := 'Proceso EXITOSO';
  
   DBMS_OUTPUT.put_line('*************************************************************');  
   DBMS_OUTPUT.put_line('EJECUCION DE MIGRACIONES POR CONFIGURACION');   
   DBMS_OUTPUT.put_line('Parametros de entrada:');
   DBMS_OUTPUT.put_line('K_USRREG: ' || CHR(9)        || K_USRREG);
   DBMS_OUTPUT.put_line('K_TAMPAG: ' || CHR(9)        || K_TAMPAG);
   DBMS_OUTPUT.put_line('K_CANTDIAS: ' || CHR(9)      || K_CANTDIAS);
   DBMS_OUTPUT.put_line('*************************************************************'||CHR(10)||CHR(13));


   SELECT COUNT(*) into listaProcesar
   FROM PCLUB.ADMPT_CONF_HISTORICO
   WHERE ESTADO_EJECUCION = '1'; 

   IF listaProcesar > 0 THEN

      DBMS_OUTPUT.put_line('SE PROCESARAN: '|| listaProcesar || ' REGISTROS DE FECHA DE EJCUCION');
      OPEN CUR_CONF_HISTORICO;
     
LOOP
        FETCH CUR_CONF_HISTORICO 
          BULK COLLECT INTO l_TABLE_CUR_CONF_HISTORICO LIMIT 100;
          EXIT WHEN l_TABLE_CUR_CONF_HISTORICO.COUNT=0; 
          IF l_TABLE_CUR_CONF_HISTORICO.COUNT > 0 THEN
              
              FOR indx IN 1 .. l_TABLE_CUR_CONF_HISTORICO.COUNT 
              LOOP
                contRegMigrProcesado := contRegMigrProcesado+1;
                ID_ESTADO_PROC  := l_TABLE_CUR_CONF_HISTORICO(indx).ID_ESTADO_PROC;
                ESTADO          := l_TABLE_CUR_CONF_HISTORICO(indx).ESTADO_PROCESO;
                FECINICIAL      := l_TABLE_CUR_CONF_HISTORICO(indx).FECHA_REGIST;
              
                
            
                BEGIN
                   DBMS_OUTPUT.put_line(CHR(10) || CHR(10) || '---------------------- EJECUCION '||indx||' --------------------------');
                   DBMS_OUTPUT.put_line('ID_ESTADO_PROC: '  || ID_ESTADO_PROC);
                   DBMS_OUTPUT.put_line('INVOCANDO SP: '    || CHR(9) ||  'pclub.ADMPSS_MIG_KARDEX_REX2');
                   DBMS_OUTPUT.put_line('ESTADO: '          || CHR(9) || ESTADO);
                   DBMS_OUTPUT.put_line('FECINICIAL: '      || CHR(9) || FECINICIAL);
                 
                   
                   K_DURACION_EJECUCION := 0; 
                 
                   PCLUB.PKG_CC_HISTORICO.EJECUTA_REGISTRO_MIGRACIONES(
                      K_USRREG, K_TAMPAG, K_CANTDIAS, ESTADO,
                  
                      K_DURACION_EJECUCION,K_CODERROR, K_DESCERROR
                   );
                   
                   vAcumDuracion_regMigr := vAcumDuracion_regMigr + K_DURACION_EJECUCION;
                  
                   BEGIN
                     IF  K_CODERROR = 0 THEN 
                       contRegMigrExito := contRegMigrExito +1;
                       
                       UPDATE PCLUB.ADMPT_CONF_HISTORICO
                       SET ESTADO_EJECUCION ='1',
             
                         FECHA_REGIST=sysdate
                       WHERE ID_ESTADO_PROC = ID_ESTADO_PROC
                             AND ESTADO_EJECUCION = '0';
                       commit;
                     ELSE 
                       contRegMigrError := contRegMigrError + 1;
                       
                       UPDATE PCLUB.ADMPT_CONF_HISTORICO
                       SET ESTADO_EJECUCION =K_CODERROR, 
                     
                        FECHA_REGIST=sysdate
                       WHERE ID_ESTADO_PROC = ID_ESTADO_PROC
                             AND ESTADO_EJECUCION = '0';
                       commit;
                     END IF;
                     DBMS_OUTPUT.put_line(CHR(10) || 'Se hizo UPDATE en ESTADO_EJECUCION EN TABLA ADMPT_CONF_HISTORICO de ID_ESTADO_PROC: '|| ID_ESTADO_PROC);
                   EXCEPTION
                      WHEN OTHERS THEN
                        DBMS_OUTPUT.put_line('ERROR EN UPDATE ESTADO_EJECUCION EN TABLA ADMPT_CONF_HISTORICO de ID_ESTADO_PROC: '|| ID_ESTADO_PROC);
                        DBMS_OUTPUT.put_line('CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                        DBMS_OUTPUT.put_line('DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                        ROLLBACK;
                   END;
                EXCEPTION
                  WHEN OTHERS THEN
                    DBMS_OUTPUT.put_line('OCURRIO UN ERROR AL EJECUTAR EL  REGISTRO DE CONF HISTORICO NRO: '|| indx);
                    DBMS_OUTPUT.put_line('CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                    DBMS_OUTPUT.put_line('DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                END;
              END LOOP;
          ELSE
             DBMS_OUTPUT.put_line('LA CONSULTA DEL CURSOR NO DEVUELVE REGISTROS, l_TABLE_CUR_CONF_HISTORICO <= 0');
          END IF;
        EXIT WHEN CUR_CONF_HISTORICO%NOTFOUND;
      END LOOP;
      
      CLOSE CUR_CONF_HISTORICO;
      

      DBMS_OUTPUT.put_line(CHR(10)||CHR(13) || CHR(9) || '---------------------------------------------------');
      DBMS_OUTPUT.put_line('listaProcesar: ' || listaProcesar);
      
      DBMS_OUTPUT.put_line('Tiempo total PROCESAMIENTO : '|| vAcumDuracion_regMigr || ' segundos');       
      DBMS_OUTPUT.put_line('Cantidad registros migracion PROCESADO : '|| contRegMigrProcesado);
      DBMS_OUTPUT.put_line('Cantidad registros migracion EXITOSOS : ' || contRegMigrExito);
      DBMS_OUTPUT.put_line('Cantidad registros migracion ERRONEOS : ' || contRegMigrError);
      DBMS_OUTPUT.put_line('*************************************************************' || CHR(10));  
      
   ELSE
      K_CODERROR         := -1;
      K_DESCERROR        := 'NO HAY REGISTROS EN LA TABLA ADMPT_CONF_HISTORICO A PROCESAR';
      DBMS_OUTPUT.put_line(K_DESCERROR);
   END IF;
   

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    K_CODERROR         := -2;
    K_DESCERROR        := 'ERROR: NO se encontraron registros a procesar';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;
  WHEN DUP_VAL_ON_INDEX THEN
    K_CODERROR         := -3;
    K_DESCERROR        := 'ERROR: Se esta intentando guardar un REGISTRO DUPLICADO';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;
  WHEN TIMEOUT_ON_RESOURCE THEN
    K_CODERROR         := -4;
    K_DESCERROR        := 'ERROR: Se excedio el tiempo maximo de espera por un recurso en Oracle';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;  
  WHEN PROGRAM_ERROR THEN
    K_CODERROR         := -5;
    K_DESCERROR        := 'ERROR: ocurrio un error interno de PL/SQL';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;
  WHEN STORAGE_ERROR THEN
    K_CODERROR         := -6;
    K_DESCERROR        := 'ERROR: se ha excedido el tamanio de la memoria';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;        
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR :=SQLERRM;
    ROLLBACK;
    DBMS_OUTPUT.put_line('STATUS DE EJECUCION FINAL');
    DBMS_OUTPUT.put_line('K_CODERROR: '  || K_CODERROR);
    DBMS_OUTPUT.put_line('K_DESCERROR: ' || K_DESCERROR);     
   
END;

PROCEDURE EJECUTA_REGISTRO_MIGRACIONES(
                            K_USRREG     IN VARCHAR2,
                            K_TAMPAG       IN NUMBER,
                            K_CANTDIAS     IN NUMBER,
                            ESTADO         IN CHAR,
                            K_DURACION_EJECUCION OUT NUMBER,
                            K_CODERROR    OUT NUMBER,
                            K_DESCERROR   OUT VARCHAR2) 
IS


   estadoKardex              CHAR(1)          := ESTADO;
   BulkCollectLimit          integer           := K_TAMPAG;
   usuario                   VARCHAR2(10)      := K_USRREG;



   cantRegMigrados      NUMBER              :=0;
   LoteBCVI             NUMBER              :=0;
   LoteBCVF             NUMBER              :=0;
   contLote             NUMBER               :=0;
   conRegistros         NUMBER               :=0;
   limSup               NUMBER               :=0;
   lotereal             NUMBER               :=0;
   indice               NUMBER               :=0;
   sentencia            VARCHAR2(10)        :='';
   idKardex_lanzaINI    NUMBER              :=0; 
   idKardex_lanzaFIN    NUMBER              :=0; 

   vTimeIniLote         DATE;
   vTimeFinLote         DATE;
   vDuracionLote        INTEGER             :=0;
   vAcumDuracionLotes   INTEGER             :=0;
   vContLotesExito      INTEGER             :=0;
   vContLotesError      INTEGER             :=0;
   vCadenaLotesError    VARCHAR2(2000)      :='Lotes que presentan error: ';
   idKardex_error       NUMBER              :=0;
   
   --variables para registro de auditoria
   vAUD_ID_PROCESO             VARCHAR2(10) := 'MH';
   vAUD_FECHA_REGISTRO        DATE     := sysdate;
   vAUD_DESCRIPCION_PROCESO   VARCHAR2(30) := 'MIGRACION A HISTORICO';
   vAUD_ID_EJEC_PROCESO        VARCHAR (3)  := 'EP';
   vAUD_EJECUCION_PROCESO      VARCHAR2(50) := 'EJECUCION DEL PROCESO';
   vAUD_PARAMETROS            VARCHAR2(2000) := 
                                'estadoKardex: '    || estadoKardex     || CHR(10)||
                   
                                'BulkCollectLimit: '|| BulkCollectLimit || CHR(10)||
                                'usuario: '         || usuario          || CHR(10);
   
   vAUD_HORA_INICIO_LOTE       DATE;
   vAUD_HORA_FIN_LOTE          DATE;
   
   vAUD_LOTE_DEBE_IR           VARCHAR2(400)    := '';
   vAUD_LOTE_EJECUTO           VARCHAR2(400)    := '';
   vAUD_ESTADO_LOTE            VARCHAR2(255)    := '';

   vAUD_REGISTRO_ERROR_LOTE    VARCHAR2(600)    := '';
   vAUD_MENSAJE_ERROR          VARCHAR2(255)    := '';



   CURSOR CUR_ADMPT_KARDEX 
   IS 
             SELECT 
         ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI, ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
         ADMPN_PUNTOS, ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO,
         ADMPC_ESTADO, ADMPV_IDTRANSLOY, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_DESC_PROM,
         ADMPN_TIP_PREMIO, ADMPD_FEC_VCMTO, ADMPV_USU_REG, ADMPV_USU_MOD, SYSDATE,
         usuario
      FROM PCLUB.ADMPT_KARDEX
      WHERE
          admpc_estado = estadoKardex
               AND ADMPD_FEC_TRANS < (SYSDATE - K_CANTDIAS)
      ORDER BY ADMPN_ID_KARDEX;
                    
   TYPE TABLE_CUR_ADMPT_KARDEX IS 
      TABLE OF CUR_ADMPT_KARDEX%ROWTYPE
      INDEX BY PLS_INTEGER;

   l_TABLE_CUR_ADMPT_KARDEX TABLE_CUR_ADMPT_KARDEX;
   
BEGIN

   K_DURACION_EJECUCION := 0;
   K_CODERROR         := 0;
   K_DESCERROR        := 'Proceso ejcutado de manera EXITOSA';
   
   DBMS_OUTPUT.put_line(CHR(9) || '======================================================');  
   DBMS_OUTPUT.put_line(CHR(9) || 'MIGRACION DE DATOS DE ADMPT_KARDEX a ADMPT_KARDEX_MIG');   
   DBMS_OUTPUT.put_line(CHR(9) || 'Parametros de entrada:');
   DBMS_OUTPUT.put_line(CHR(9) || 'estadoKardex: '|| CHR(9)   || estadoKardex);
   DBMS_OUTPUT.put_line(CHR(9) || 'BulkCollectLimit: '        || BulkCollectLimit);
   DBMS_OUTPUT.put_line(CHR(9) || '======================================================'||CHR(10)||CHR(13));
   


   conRegistros := conRegistros + 1;
     
     OPEN CUR_ADMPT_KARDEX;
        
     LOOP
        FETCH CUR_ADMPT_KARDEX 
           BULK COLLECT INTO l_TABLE_CUR_ADMPT_KARDEX LIMIT BulkCollectLimit;
            EXIT WHEN l_TABLE_CUR_ADMPT_KARDEX.COUNT=0; 
           IF l_TABLE_CUR_ADMPT_KARDEX.COUNT > 0 THEN
             BEGIN
               vTimeIniLote := sysdate;
     
              
               vAUD_HORA_INICIO_LOTE :=  sysdate;
               contLote := contLote +1;
               limSup := contLote * BulkCollectLimit;
               lotereal := conRegistros + l_TABLE_CUR_ADMPT_KARDEX.COUNT -1;
               
               vAUD_LOTE_DEBE_IR := 'LOTE NRO DEBE IR: ' || contLote || ' del ' || conRegistros || ' al ' || limSup;
               vAUD_LOTE_EJECUTO := 'LOTE NRO VA:      ' || contLote || ' del ' || conRegistros || ' al ' || lotereal || CHR(10);
               DBMS_OUTPUT.put_line(CHR(9) || '---------------------------------------------------');
               DBMS_OUTPUT.put_line(CHR(9) || vAUD_LOTE_DEBE_IR);
               DBMS_OUTPUT.put_line(CHR(9) || vAUD_LOTE_EJECUTO);
               
              
               FOR indx IN 1 .. l_TABLE_CUR_ADMPT_KARDEX.COUNT 
               LOOP
                  indice    := indx;
                  sentencia := 'INSERT';
                  
                
                  IF indx = 1 THEN
                    LoteBCVI := l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_ID_KARDEX;
                    DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR IDKARDEX INICIAL: ' || LoteBCVI);
                    vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR IDKARDEX INICIAL: ' || LoteBCVI || CHR(10);
                    
                    IF contLote = 1 THEN
                      idKardex_lanzaINI := LoteBCVI;
                    END IF; 
                  ELSIF indx = l_TABLE_CUR_ADMPT_KARDEX.COUNT THEN            
                    LoteBCVF := l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_ID_KARDEX;
                    DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR IDKARDEX   FINAL: ' || LoteBCVF); 
                    vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR IDKARDEX   FINAL: ' || LoteBCVF;
                  ELSIF indx = BulkCollectLimit THEN
                    LoteBCVF := l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_ID_KARDEX;
                    DBMS_OUTPUT.put_line(CHR(9) || 'LOTE VALOR IDKARDEX  -FINAL: ' || LoteBCVF);
                    vAUD_LOTE_EJECUTO := vAUD_LOTE_EJECUTO || 'LOTE VALOR IDKARDEX   FINAL: ' || LoteBCVF;
                  END IF;
                            
                  insert into PCLUB.ADMPT_KARDEX_MIG 
                  ( ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI, ADMPV_COD_CPTO, ADMPD_FEC_TRANS,
                    ADMPN_PUNTOS, ADMPV_NOM_ARCH, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO,
                    ADMPC_ESTADO, ADMPV_IDTRANSLOY, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_DESC_PROM,
                    ADMPN_TIP_PREMIO, ADMPD_FEC_VCMTO, ADMPV_USU_REG, ADMPV_USU_MOD,ADMPD_FEC_MIG,
      ADMPV_USU_MIG
      )
                  values
                  (
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_ID_KARDEX,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_COD_CLI_IB,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_COD_CLI,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_COD_CPTO,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPD_FEC_TRANS,
                   
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_PUNTOS,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_NOM_ARCH,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPC_TPO_OPER,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPC_TPO_PUNTO,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_SLD_PUNTO,
                   
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPC_ESTADO,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_IDTRANSLOY,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPD_FEC_REG,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPD_FEC_MOD,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_DESC_PROM,
                   
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_TIP_PREMIO,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPD_FEC_VCMTO,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_USU_REG,
                   l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPV_USU_MOD,            
                   SYSDATE, usuario
      );
                  conRegistros := conRegistros + 1;
               END LOOP; 
               
            
               FOR indx IN 1 .. l_TABLE_CUR_ADMPT_KARDEX.COUNT 
               LOOP     
                  indice    := indx;
                  sentencia := 'DELETE';          
                  delete from PCLUB.ADMPT_KARDEX where ADMPN_ID_KARDEX = l_TABLE_CUR_ADMPT_KARDEX(indx).ADMPN_ID_KARDEX;
               END LOOP; 
               
               vAUD_ESTADO_LOTE := 'Insert y delete correcto, se realiza COMMIT';
               DBMS_OUTPUT.put_line(CHR(9) || vAUD_ESTADO_LOTE);
               commit;
              
              vAUD_HORA_FIN_LOTE := sysdate; 
               
               vContLotesExito    := vContLotesExito + 1;
               vTimeFinLote       := sysdate;
               vDuracionLote      := (vTimeFinLote - vTimeIniLote)*24*60*60;
               vAcumDuracionLotes := vAcumDuracionLotes + vDuracionLote;
               DBMS_OUTPUT.put_line(CHR(9) || 'Tiempo de ejecucion de lote en segundos: '|| vDuracionLote );

         
             
               BEGIN
                
                   insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
                   (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_ID_EJEC_PROCESO,  
                   AUD_EJECUCION_PROCESO, AUD_PARAMETROS, AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR, 
                   AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE, AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
                   )
                   values
                   (
                  pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_ID_EJEC_PROCESO,
                  vAUD_EJECUCION_PROCESO, vAUD_PARAMETROS, vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, 
                  vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE, vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, usuario
                   );
                   
                 
                   commit;
                   DBMS_OUTPUT.put_line(CHR(9) || 'REGISTRADO EN TABLA AUDITORIA_PROC_CLAROCLUB EXITOSO');
               EXCEPTION
                  WHEN OTHERS THEN
                  DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE EXITOSO');
                  DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                  DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                  ROLLBACK;
               END;
   
              EXIT WHEN CUR_ADMPT_KARDEX%NOTFOUND;
      
              EXCEPTION
                WHEN OTHERS THEN
                idKardex_error := l_TABLE_CUR_ADMPT_KARDEX(indice).ADMPN_ID_KARDEX;
                vAUD_REGISTRO_ERROR_LOTE := 'Sentencia: '|| sentencia || 
                        'ID_KARDEX Registro que genera ERROR: ' || idKardex_error ||CHR(10)||CHR(13)||
                        'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13)|| 
                        'DESCERROR' || SUBSTR(SQLERRM, 1, 250);
                vAUD_MENSAJE_ERROR := 'Ha ocurrido un ERROR en el LOTE: ' || contLote;
      
                DBMS_OUTPUT.put_line(CHR(9) || vAUD_MENSAJE_ERROR);
                DBMS_OUTPUT.put_line(CHR(9) || vAUD_REGISTRO_ERROR_LOTE);
  
                vContLotesError   := vContLotesError + 1;
                vCadenaLotesError := vCadenaLotesError || contLote || ', '; 

                conRegistros := contLote * BulkCollectLimit + 1;
                ROLLBACK;


                BEGIN
                  insert into PCLUB.AUDITORIA_PROC_CLAROCLUB
                   (AUD_ID_SECUENCIA, AUD_ID_PROCESO, AUD_FECHA_REGISTRO, AUD_DESCRIPCION_PROCESO, AUD_PARAMETROS, 
                   AUD_HORA_INICIO, AUD_HORA_FIN, AUD_LOTE_DEBE_IR, AUD_LOTE_EJECUTO, AUD_ESTADO_LOTE,
                   AUD_REGISTRO_ERROR_LOTE, AUD_MENSAJE_ERROR, AUD_USUARIOREG
                   )
                   values
                   (
                  pclub.seq_auditoria_pcclub.NEXTVAL, vAUD_ID_PROCESO, vAUD_FECHA_REGISTRO, vAUD_DESCRIPCION_PROCESO, vAUD_PARAMETROS,
                  vAUD_HORA_INICIO_LOTE, vAUD_HORA_FIN_LOTE, vAUD_LOTE_DEBE_IR, vAUD_LOTE_EJECUTO, vAUD_ESTADO_LOTE,
                  vAUD_REGISTRO_ERROR_LOTE, vAUD_MENSAJE_ERROR, usuario
                   );
                  commit;
                EXCEPTION
                  WHEN OTHERS THEN
                    DBMS_OUTPUT.put_line(CHR(9) || 'OCURRIO UN ERROR AL REALIZAR INSERT EN TABLA AUDITORIA_PROC_CLAROCLUB PARA INSERT DE LOTE FALLIDO');
                    DBMS_OUTPUT.put_line(CHR(9) || 'CODERROR: '|| SQLCODE ||CHR(10)||CHR(13));
                    DBMS_OUTPUT.put_line(CHR(9) || 'DESCERROR: '|| SUBSTR(SQLERRM, 1, 250) ||CHR(10)||CHR(13));
                    ROLLBACK;
                END; 
      
      
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
                END; 
              END; 
           ELSE
             DBMS_OUTPUT.put_line(CHR(9) || 'LOTE NO CONTIENE REGISTROS A PROCESAR');
           END IF;
END LOOP;
   
     CLOSE CUR_ADMPT_KARDEX;
     
     idKardex_lanzaFIN := LoteBCVF;
     
    
     SELECT count(*) into cantRegMigrados
     FROM PCLUB.ADMPT_KARDEX_MIG m
     where
     m.ADMPN_ID_KARDEX between  idKardex_lanzaINI and idKardex_lanzaFIN
     AND m.admpc_estado = estadoKardex;
 
     
     DBMS_OUTPUT.put_line(CHR(10)||CHR(13) || CHR(9) || '---------------------------------------------------');
     DBMS_OUTPUT.put_line(CHR(9) || 'idKardex_lanzaINI: '  || idKardex_lanzaINI);
     DBMS_OUTPUT.put_line(CHR(9) || 'idKardex_lanzaFIN: '  || idKardex_lanzaFIN   || CHR(10)||CHR(13));     
     
     DBMS_OUTPUT.put_line(CHR(9) || 'Se migraron      : '  || cantRegMigrados     || ' registros');
     DBMS_OUTPUT.put_line(CHR(9) || 'Tiempo total de ejecucion    : '|| vAcumDuracionLotes || ' segundos');
     
     DBMS_OUTPUT.put_line(CHR(9) || 'Cantidad de lotes procesados : ' || contLote);
     DBMS_OUTPUT.put_line(CHR(9) || 'Cantidad de lotes exitosos   : ' || vContLotesExito);
     DBMS_OUTPUT.put_line(CHR(9) || 'Cantidad de lotes con error  : ' || vContLotesError);
     DBMS_OUTPUT.put_line(CHR(9) || vCadenaLotesError || CHR(10)||CHR(13));
     
     K_DURACION_EJECUCION := vAcumDuracionLotes;
     DBMS_OUTPUT.put_line(K_CODERROR);
     DBMS_OUTPUT.put_line( K_DESCERROR);
  
  
 
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    K_CODERROR         := -2;
    K_DESCERROR        := 'ERROR: NO se encontraron registros a procesar';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;
  WHEN DUP_VAL_ON_INDEX THEN
    K_CODERROR         := -3;
    K_DESCERROR        := 'ERROR: Se esta intentando guardar un REGISTRO DUPLICADO';
    DBMS_OUTPUT.put_line(CHR(9) || K_DESCERROR);
    ROLLBACK;
  WHEN TIMEOUT_ON_RESOURCE THEN
    K_CODERROR         := -4;
    K_DESCERROR        := 'ERROR: Se excedio el tiempo maximo de espera por un recurso en Oracle';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;  
  WHEN PROGRAM_ERROR THEN
    K_CODERROR         := -5;
    K_DESCERROR        := 'ERROR: ocurrio un error interno de PL/SQL';
    DBMS_OUTPUT.put_line( K_DESCERROR);
    ROLLBACK;
  WHEN STORAGE_ERROR THEN
    K_CODERROR         := -6;
    K_DESCERROR        := 'ERROR: se ha excedido el tamanio de la memoria';
    DBMS_OUTPUT.put_line(K_DESCERROR);
    ROLLBACK;        
  WHEN OTHERS THEN
   K_CODERROR  := SQLCODE;
    K_DESCERROR := (SQLERRM);
    ROLLBACK;
    DBMS_OUTPUT.put_line(CHR(9) || 'STATUS DE EJECUCION FINAL');
    DBMS_OUTPUT.put_line(K_CODERROR);
    DBMS_OUTPUT.put_line( K_DESCERROR);   

END;
 end PKG_CC_HISTORICO;
/