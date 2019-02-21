create or replace package body PCLUB.PKG_CC_IMPLOYALTY is

PROCEDURE ADMPSI_LOYCLIENTE(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is
--****************************************************************
-- Nombre SP           :  ADMPSI_LOYCLIENTE
-- Propósito           :  Contiene el proceso necesario para cargar los datos de Clientes dejados por Loyalty.
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  Luis De la Fuente -
-- Fec Creacion        :  18/10/2010
-- Fec Actualizacion   :
--****************************************************************

BEGIN

     UPDATE PCLUB.ADMPT_LOY_CLIENTE L
     SET ADMPV_MSJE_ERROR = 'ERROR. EL CODIGO DEL CLIENTE YA EXISTE'
     WHERE exists (SELECT '1' FROM PCLUB.ADMPT_CLIENTE C where C.ADMPV_COD_CLI=L.ADMPV_COD_CLI) ;

     COMMIT;

     INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI,
             ADMPV_COD_SEGCLI,
             ADMPN_COD_CATCLI,
             ADMPV_TIPO_DOC,
             ADMPV_NUM_DOC,
             ADMPV_NOM_CLI,
             ADMPV_APE_CLI,
             ADMPC_SEXO,
             ADMPV_EST_CIVIL,
             ADMPV_EMAIL,
             ADMPV_PROV,
             ADMPV_DEPA,
             ADMPV_DIST,
             ADMPD_FEC_ACTIV,
             ADMPV_CICL_FACT,
             ADMPC_ESTADO,
             ADMPV_COD_TPOCL)

             SELECT distinct L.ADMPV_COD_CLI,
                    NULL,
                 L.ADMPN_CATCLI,
                 L.ADMPV_TIP_DOC,
                 L.ADMPV_NUM_DOC,
                 L.ADMPV_NOM_CLI,
                 L.ADMPV_APE_CLI,
                 NULL,
                 L.ADMPV_ESTCIV,
                 L.ADMPV_EMAIL,
                 L.ADMPV_PROV,
                 L.ADMPV_DEP,
                 L.ADMPV_DIST,
                 L.ADMPV_FECACT,
                 L.ADMPV_CIC_FAC,
                 (CASE L.ADMPV_SEXO WHEN '1' THEN 'A' ELSE 'B' END),
                 '2'
            FROM PCLUB.ADMPT_LOY_CLIENTE L
           WHERE ADMPV_ESTADO = 'P' AND                 -- Agregado para la entrega de puntos delta
                 L.ADMPV_COD_CLI is not null 
                              and not exists (SELECT '1' FROM PCLUB.ADMPT_CLIENTE C where C.ADMPV_COD_CLI=L.ADMPV_COD_CLI);

           COMMIT;
				 
		   UPDATE PCLUB.ADMPT_CLIENTE C
           SET C.ADMPV_TIPO_DOC=0
           WHERE
           PCLUB.FN_VALIDAR_RUC(C.ADMPV_NUM_DOC)=1; 
           
	COMMIT;
	
  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
  SELECT PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,J.ADMPV_COD_CLI,
        null,
        0.00,
        0.00,
        'A',
        null
         FROM 
(
select c.admpv_cod_cli 
FROM PCLUB.ADMPT_CLIENTE C
where NOT EXISTS(SELECT 1 FROM PCLUB.ADMPT_SALDOS_CLIENTE S WHERE S.ADMPV_COD_CLI=c.ADMPV_COD_CLI) ---- Agregado para no duplicar saldos
GROUP BY c.ADMPV_COD_CLI
	)J;

 COMMIT;

-- Obtenemos los registros totales, procesados y con error
SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_LOY_CLIENTE;
SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_LOY_CLIENTE WHERE ADMPV_MSJE_ERROR IS NOT NULL;
SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_LOY_CLIENTE WHERE ADMPV_MSJE_ERROR IS NULL;

 K_CODERROR:= 0;
 K_DESCERROR:= '';

  EXCEPTION

    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_LOYCLIENTE;

PROCEDURE ADMPSI_ELOYCLIENTE(CURSORLOYCLIENTE out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ELOYCLIENTE
-- Propósito           :  Contiene el proceso necesario para devolver los registros de carga de clientes de Loyalty, que no se insertaron en la tabla de clientes.
-- Input               :
-- Output              :  CURSORLOYCLIENTE
-- Creado por          :  Luis De la Fuente ()
-- Fec Creación        :  19/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORLOYCLIENTE FOR
SELECT
 L.ADMPV_COD_CLI,
 L.ADMPN_CATCLI,
 L.ADMPV_TIP_DOC,
 L.ADMPV_NUM_DOC,
 L.ADMPV_NOM_CLI,
 L.ADMPV_SEXO,
 L.ADMPV_ESTCIV,
 L.ADMPV_EMAIL,
 L.ADMPV_PROV,
 L.ADMPV_DEP,
 L.ADMPV_DIST,
 TO_DATE(L.ADMPV_FECACT,'DD/MM/YYYY'),
 L.ADMPV_CIC_FAC,
 L.ADMPV_MSJE_ERROR,
 L.ADMPV_APE_CLI
 FROM PCLUB.ADMPT_LOY_CLIENTE L
 WHERE TRIM(L.ADMPV_MSJE_ERROR) <> ' '
       AND ADMPV_ESTADO = 'P'             -- Agregado para la entrega de puntos delta
 ORDER BY L.ADMPV_COD_CLI;

-- SSC 25102010 - Actualizamos a Ejecutado (E) los que ya se procesaron y mostraron
UPDATE PCLUB.ADMPT_LOY_CLIENTE SET ADMPV_ESTADO = 'E' WHERE ADMPV_ESTADO = 'P';

COMMIT;
-- SSC 25102010
--L.ADMPV_APE_CLI,      -- SSC 03112010 - APELLIDO DEL CLIENTE NO SE PUEDE SEPARAR
END ADMPSI_ELOYCLIENTE;

PROCEDURE ADMPSI_LOYSALDOS(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_LOYSALDOS
-- Propósito           :  Contiene el proceso necesario para cargar los datos de saldos dejados por Loyalty.
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  Luis De la Fuente -
-- Fec Creacion        :  18/10/2010
-- Fec Actualizacion   :
--****************************************************************


 BEGIN

 UPDATE PCLUB.ADMPT_LOY_SALDOS S
SET ADMPV_MSJE_ERROR = 'ERROR. EL CODIGO DEL CLIENTE NO EXISTE'
WHERE not exists (select 1 from PCLUB.ADMPT_CLIENTE C where c.ADMPV_COD_CLI=S.ADMPV_COD_CLI);


UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
   SET S.ADMPN_SALDO_CC = (select L.ADMPN_SALDO_CC from PCLUB.ADMPT_LOY_SALDOS L
                          where ADMPV_ESTADO = 'P' and L.ADMPV_COD_CLI=S.ADMPV_COD_CLI
                                and L.ADMPV_MSJE_ERROR is null AND L.ADMPN_SALDO_CC>0 and rownum=1),
       S.ADMPC_ESTPTO_CC = 'A'
 WHERE exists (select 1 from PCLUB.ADMPT_LOY_SALDOS C
                      where C.ADMPV_COD_CLI=S.ADMPV_COD_CLI and ADMPV_ESTADO = 'P'
                            and C.ADMPV_MSJE_ERROR is null AND C.ADMPN_SALDO_CC>0);

COMMIT;
-- Obtenemos los registros totales, procesados y con error
SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_LOY_SALDOS;
SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_LOY_SALDOS WHERE ADMPV_MSJE_ERROR IS NOT NULL;
SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_LOY_SALDOS WHERE ADMPV_MSJE_ERROR IS NULL;

 K_CODERROR:= 0;
 K_DESCERROR:= '';

  EXCEPTION

    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_LOYSALDOS;

PROCEDURE ADMPSI_ELOYSALDOS(CURSORLOYSALDOS out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ELOYSALDOS
-- Propósito           :  Contiene el proceso necesario para devolver los registros de carga de clientes de Loyalty, que no se insertaron en la tabla de clientes.
-- Input               :
-- Output              :  CURSORLOYSALDOS
-- Creado por          :  Luis De la Fuente ()
-- Fec Creación        :  19/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORLOYSALDOS FOR
SELECT
 L.ADMPV_COD_CLI,
 L.ADMPN_SALDO_CC,
 L.ADMPV_MSJE_ERROR
 FROM PCLUB.ADMPT_LOY_SALDOS L
 WHERE TRIM(L.ADMPV_MSJE_ERROR) <> ' '
       AND ADMPV_ESTADO = 'P'             -- Agregado para la entrega de puntos delta
 ORDER BY L.ADMPV_COD_CLI;

-- SSC 25102010 - Actualizamos a Ejecutado (E) los que ya se procesaron y mostraron
UPDATE PCLUB.ADMPT_LOY_SALDOS SET ADMPV_ESTADO = 'E' WHERE ADMPV_ESTADO = 'P';

COMMIT;
-- SSC 25102010

END ADMPSI_ELOYSALDOS;

PROCEDURE ADMPSI_LOYCANJE(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_LOYCANJE
-- Propósito           :  Contiene el proceso necesario para cargar los datos de Canjes dejados por Loyalty.
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  Luis De la Fuente -
-- Fec Creacion        :  18/10/2010
-- Fec Actualizacion   :
--****************************************************************
             -- Agregado para la entrega de puntos delta

BEGIN


 UPDATE PCLUB.ADMPT_LOY_CANJE J
    SET J.ADMPV_MSJE_ERROR = 'ERROR. EL CODIGO DEL CLIENTE NO EXISTE'
   WHERE not exists (select 1  from PCLUB.ADMPT_CLIENTE C where C.ADMPV_COD_CLI=J.ADMPV_COD_CLI) AND
         J.ADMPV_ESTADO = 'P';

  UPDATE PCLUB.ADMPT_LOY_CANJE LC
    SET ADMPV_MSJE_ERROR = 'ERROR. EL CANJE YA SE ENCUENTRA REGISTRADO'
  WHERE exists (SELECT 1 FROM PCLUB.ADMPT_CANJE C where C.ADMPV_ID_LOYALTY = LC.ADMPV_ID_CANJE) AND
         ADMPV_ESTADO = 'P';

  UPDATE PCLUB.ADMPT_LOY_CANJE LC
    SET LC.ADMPV_MSJE_ERROR = 'ERROR. EL IDENTIFICADOR DE CANJE YA EXISTE'
  WHERE ADMPV_ID_CANJE in
  (select ADMPV_ID_CANJE from PCLUB.ADMPT_LOY_CANJE where ADMPV_ESTADO = 'P'
                         group by ADMPV_ID_CANJE having count(1)>1 );

 INSERT INTO PCLUB.ADMPT_CANJE (ADMPV_ID_CANJE, ADMPV_COD_CLI, ADMPV_ID_SOLIC, ADMPV_PTO_VENTA,
                                  ADMPD_FEC_CANJE, ADMPV_HRA_CANJE, ADMPV_NUM_DOC,
                                  ADMPV_COD_TPOCL, ADMPV_COD_ASESO, ADMPV_NOM_ASESO,
                                  ADMPC_TPO_OPER, ADMPN_ID_KARDEX, ADMPV_ID_LOYALTY)
 SELECT PCLUB.ADMPT_CANJE_SQ.NEXTVAL, L.ADMPV_COD_CLI, NULL, L.ADMPV_PTOVTA, L.ADMPD_FECHA,
        L.ADMPV_HORA, NULL,NULL,NULL,NULL,L.ADMPV_TIPO,NULL, L.ADMPV_ID_CANJE
       FROM PCLUB.ADMPT_LOY_CANJE L
       WHERE ADMPV_ESTADO = 'P' AND ADMPV_MSJE_ERROR IS NULL;

commit;

-- Obtenemos los registros totales, procesados y con error
SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_LOY_CANJE;
SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_LOY_CANJE WHERE ADMPV_MSJE_ERROR IS NOT NULL;
SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_LOY_CANJE WHERE ADMPV_MSJE_ERROR IS NULL;

K_CODERROR:= 0;
K_DESCERROR:= '';

EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR:= SQLCODE;
      K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_LOYCANJE;

PROCEDURE ADMPSI_ELOYCANJE(CURSORLOYCANJE out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ELOYCANJE
-- Propósito           :  Contiene el proceso necesario para devolver los registros de carga de clientes de Loyalty, que no se insertaron en la tabla de clientes.
-- Input               :
-- Output              :  CURSORLOYCANJE
-- Creado por          :  Luis De la Fuente ()
-- Fec Creación        :  19/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORLOYCANJE FOR
SELECT
 L.ADMPV_ID_CANJE,
 L.ADMPV_COD_CLI,
 L.ADMPV_PTOVTA,
 TO_DATE(L.ADMPD_FECHA,'DD/MM/YYYY'),
 L.ADMPV_HORA,
 L.ADMPV_TIPO,
 L.ADMPV_MSJE_ERROR
 FROM PCLUB.ADMPT_LOY_CANJE L
 WHERE TRIM(L.ADMPV_MSJE_ERROR) <> ' '
       AND ADMPV_ESTADO = 'P'             -- Agregado para la entrega de puntos delta
 ORDER BY L.ADMPV_COD_CLI;

-- SSC 25102010 - Actualizamos a Ejecutado (E) los que ya se procesaron y mostraron
UPDATE PCLUB.ADMPT_LOY_CANJE SET ADMPV_ESTADO = 'E' WHERE ADMPV_ESTADO = 'P';

COMMIT;
-- SSC 25102010

END ADMPSI_ELOYCANJE;

PROCEDURE ADMPSI_LOYCANJEDET(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is

--****************************************************************
-- Nombre SP           :  ADMPSI_LOYCANJEDET
-- Propósito           :  Contiene el proceso necesario para cargar los datos de Canjes dejados por Loyalty.
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  Luis De la Fuente -
-- Fec Creacion        :  18/10/2010
-- Fec Actualizacion   :
--****************************************************************


 BEGIN

       UPDATE PCLUB.ADMPT_LOY_CANJEDET C
         SET C.ADMPV_MSJE_ERROR = 'ERROR. LA CABECERA DEL CANJE NO EXISTE'
      WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CANJE J WHERE J.ADMPV_ID_LOYALTY = C.ADMPV_ID_CANJE) AND
            C.ADMPV_ESTADO = 'P';

      UPDATE PCLUB.ADMPT_LOY_CANJEDET C
         SET C.ADMPV_MSJE_ERROR = 'ERROR. EL DETALLE DEL CANJE YA EXISTE.'
      WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CANJE_DETALLE
                    WHERE  admpv_id_loyalty=C.ADMPV_ID_CANJE
                    AND ADMPV_ID_CANJESEC=C.ADMPV_SECUENC) AND
                    C.ADMPV_ESTADO = 'P';

      INSERT INTO PCLUB.ADMPT_CANJE_DETALLE(ADMPV_ID_CANJE,ADMPV_ID_CANJESEC,ADMPV_ID_PROCLA,ADMPV_DESC,
                  ADMPV_NOM_CAMP, ADMPN_PUNTOS, ADMPN_PAGO, ADMPN_CANTIDAD, ADMPV_COD_TPOPR, ADMPN_COD_SERVC,
                  ADMPN_MNT_RECAR, ADMPC_ESTADO, ADMPV_ID_LOYALTY)

      SELECT DISTINCT C.ADMPV_ID_CANJE,
             L.ADMPV_SECUENC,
             L.ADMPV_ID_PROD,
             L.ADMPV_DES_PROD,
             L.ADMPV_CAMPANA,
             L.ADMPN_PUNTOS,
             L.ADMPN_MONTO,
             L.ADMPN_CANTIDAD,
             L.ADMPV_TPOPREM,
             L.ADMPN_CODSERV,
             L.ADMPN_MNTREC,
             'C',
             L.ADMPV_ID_CANJE
      FROM PCLUB.ADMPT_LOY_CANJEDET L
      JOIN PCLUB.ADMPT_CANJE C
      ON L.ADMPV_ID_CANJE=C.ADMPV_ID_LOYALTY
      WHERE L.ADMPV_MSJE_ERROR IS NULL AND L.ADMPV_ESTADO = 'P';

   COMMIT;

-- Obtenemos los registros totales, procesados y con error
SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.Admpt_Loy_Canjedet;
SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.Admpt_Loy_Canjedet WHERE ADMPV_MSJE_ERROR IS NOT NULL;
SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.Admpt_Loy_Canjedet WHERE ADMPV_MSJE_ERROR IS NULL;

K_CODERROR:= 0;
K_DESCERROR:= '';

EXCEPTION
   WHEN OTHERS THEN
         K_CODERROR:= SQLCODE;
         K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_LOYCANJEDET;

PROCEDURE ADMPSI_ELOYCANJEDET(CURSORLOYCANJEDET out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ELOYCANJEDET
-- Propósito           :  Contiene el proceso necesario para devolver los registros de carga de Detalles de Canje de Loyalty, que no se insertaron en la tabla de Detalles de Canje.
-- Input               :
-- Output              :  CURSORLOYCANJEDET
-- Creado por          :  Luis De la Fuente ()
-- Fec Creación        :  19/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORLOYCANJEDET FOR
SELECT
 L.ADMPV_ID_CANJE,
 L.ADMPV_SECUENC,
 L.ADMPV_ID_PROD,
 L.ADMPV_DES_PROD,
 L.ADMPV_CAMPANA,
 L.ADMPN_PUNTOS,
 L.ADMPN_MONTO,
 L.ADMPN_CANTIDAD,
 L.ADMPV_TPOPREM,
 L.ADMPN_CODSERV,
 L.ADMPV_IDTRANS,
 L.ADMPV_MSJE_ERROR
 FROM PCLUB.ADMPT_LOY_CANJEDET L
 WHERE TRIM(L.ADMPV_MSJE_ERROR) <> ' '
       AND ADMPV_ESTADO = 'P'             -- Agregado para la entrega de puntos delta
 ORDER BY L.ADMPV_ID_CANJE;

-- SSC 25102010 - Actualizamos a Ejecutado (E) los que ya se procesaron y mostraron
UPDATE PCLUB.ADMPT_LOY_CANJEDET SET ADMPV_ESTADO = 'E' WHERE ADMPV_ESTADO = 'P';

COMMIT;
-- SSC 25102010

END ADMPSI_ELOYCANJEDET;

PROCEDURE ADMPSI_LOYMOVTOS(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) is
--****************************************************************
-- Nombre SP           :  ADMPSI_LOYMOVTOS
-- Propósito           :  Contiene el proceso necesario para cargar los datos de movimientos dejados por Loyalty.
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :
-- Fec Creacion        :  19/10/2010
-- Fec Actualizacion   :
--****************************************************************

BEGIN

  -- CURSOR PARA OBTENER LOS DATOS DE LA TABLA ADMPT_LOY_SALDOS


    -- Segun lo indicado por Loyalty los conceptos son
    /*
    ASIGNACION                       Uno solo para todos
    REGULARIZACION                   9
    ACTIVACION                       17
    REVERSION                        No se presento hasta la fecha
    PROMOCION                        8
    CAMBIO TITULARIDAD               20
    TRANSFERENCIA A BONUS (-)        25
    REVERSION CAMBIO TITULARIDAD     No se presento hasta la fecha
    TRANSFERENCIA DE BONUS           24
    PUNTOS VENCIDOS (-)              16
    CANJES (-)                       14
    DEVOLUCION CANJES                15
    */

          UPDATE PCLUB.ADMPT_KARDEX K
             SET (K.ADMPN_SLD_PUNTO,K.ADMPC_ESTADO) =
                        (select L.ADMPN_SLDPUNTOS , (CASE  WHEN L.ADMPV_TIPOPE = 'I' AND L.ADMPN_SLDPUNTOS = 0 THEN 'C'
                                           ELSE 'A' END)
                                from PCLUB.ADMPT_LOY_MOVTOS L
                                where l.admpv_idtrans=K.ADMPV_IDTRANSLOY AND ADMPV_ESTADO = 'P')

          WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_LOY_MOVTOS L WHERE l.admpv_idtrans=K.ADMPV_IDTRANSLOY AND ADMPV_ESTADO = 'P' );

		  COMMIT;

          UPDATE PCLUB.ADMPT_LOY_MOVTOS M
             SET M.ADMPV_MSJE_ERROR = 'ERROR. CODIGO DE CLIENTE NO EXISTE'
          WHERE NOT EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE C WHERE C.ADMPV_COD_CLI=M.ADMPV_COD_CLI);

		  COMMIT;
         -- INSERT
          INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI,ADMPV_COD_CPTO,ADMPD_FEC_TRANS,
          ADMPN_PUNTOS,ADMPV_NOM_ARCH,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,admpv_idtransloy)

             SELECT PCLUB.admpt_kardex_sq.NEXTVAL,ib.admpn_cod_cli_ib, MV.ADMPV_COD_CLI,
              CASE
              WHEN MV.ADMPV_MOTIVO LIKE '%ASIGNAC%' THEN '12'
              WHEN MV.ADMPV_MOTIVO LIKE '%REGULARI%' THEN '9'
              WHEN MV.ADMPV_MOTIVO LIKE '%PROMOCION%' THEN '8'
              WHEN MV.ADMPV_MOTIVO LIKE '%TITULARI%' THEN '20'
              WHEN MV.ADMPV_MOTIVO LIKE '%TRANSFERENCIA A BONUS%' THEN '25'
              WHEN MV.ADMPV_MOTIVO LIKE '%TRANSFERENCIA DE BONUS%' THEN '24'
              WHEN MV.ADMPV_MOTIVO LIKE '%VENCIDOS%' THEN '16'
              WHEN MV.ADMPV_MOTIVO LIKE '%CANJE%' THEN '14'
              WHEN MV.ADMPV_MOTIVO LIKE '%DEVOLUCI%' THEN '15'
              WHEN MV.ADMPV_MOTIVO LIKE '%ACTIVACION%' THEN '17'
              WHEN MV.ADMPV_MOTIVO LIKE '%ANIVERSARIO%' THEN '18'
              WHEN MV.ADMPV_MOTIVO LIKE '%RENOVACION DE CONTRATOS%' THEN '22'
              WHEN MV.ADMPV_MOTIVO LIKE '%ALTAS DE CONTRATOS%' THEN '17'
              WHEN MV.ADMPV_MOTIVO LIKE '%ICLARO%' THEN '38'
              WHEN MV.ADMPV_MOTIVO LIKE '%IBK%' THEN '4'
              WHEN MV.ADMPV_MOTIVO LIKE '%PUNTOS DE BAJA%' THEN '19'
              END "CONCEPTO",
              MV.ADMPD_FECHA,
              MV.ADMPN_PUNTOS, NULL,
              (CASE WHEN MV.ADMPN_PUNTOS >= 0 THEN 'E' ELSE 'S' END) ADMPV_TIPOPE,'L',
               MV.ADMPN_SLDPUNTOS, (CASE WHEN MV.ADMPV_TIPOPE = 'I' AND MV.ADMPN_SLDPUNTOS = 0 THEN 'C'
               ELSE 'A' END),MV.ADMPV_IDTRANS

             FROM PCLUB.ADMPT_LOY_MOVTOS MV
             JOIN PCLUB.ADMPT_CLIENTE C
             ON MV.ADMPV_COD_CLI=C.ADMPV_COD_CLI
             LEFT JOIN 
             (select i.*
             from PCLUB.admpt_clienteib i inner join PCLUB.admpt_saldos_cliente s on s.admpn_cod_cli_ib=i.admpn_cod_cli_ib 
                       and i.admpv_cod_cli=s.admpv_cod_cli) IB
             ON MV.ADMPV_COD_CLI= IB.ADMPV_COD_CLI
             WHERE MV.ADMPV_ESTADO = 'P' AND MV.ADMPV_MSJE_ERROR IS NULL 
                AND MV.ADMPV_MOTIVO NOT LIKE '%IBK%' AND
                NOT EXISTS(SELECT 1 FROM PCLUB.ADMPT_KARDEX WHERE ADMPV_IDTRANSLOY = MV.ADMPV_IDTRANS);
    COMMIT;

    UPDATE PCLUB.ADMPT_SALDOS_CLIENTE SC
     SET SC.ADMPN_SALDO_CC = SC.ADMPN_SALDO_CC -
                             (SELECT NVL(SUM(NVL(L.ADMPN_SLDPUNTOS,0)),0)
                                FROM PCLUB.ADMPT_LOY_MOVTOS L
                               WHERE L.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                                 AND L.ADMPV_ESTADO = 'P'
                                 AND L.ADMPV_MOTIVO LIKE '%IBK%'
                                 AND L.ADMPV_MSJE_ERROR IS NULL
                                 )
   WHERE SC.ADMPV_COD_CLI IN
         (SELECT DISTINCT M.ADMPV_COD_CLI
            FROM PCLUB.ADMPT_LOY_MOVTOS M
           WHERE M.ADMPV_ESTADO = 'P'
             AND M.ADMPV_MOTIVO LIKE '%IBK%'
			 AND M.ADMPV_MSJE_ERROR IS NULL
             )
     AND SC.ADMPN_SALDO_CC > 0;

		COMMIT;

        -- Obtenemos los registros totales, procesados y con error
    SELECT COUNT (*) INTO K_NUMREGTOT FROM PCLUB.ADMPT_LOY_MOVTOS;
    SELECT COUNT (*) INTO K_NUMREGERR FROM PCLUB.ADMPT_LOY_MOVTOS WHERE ADMPV_MSJE_ERROR IS NOT NULL;
    SELECT COUNT (*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_LOY_MOVTOS WHERE ADMPV_MSJE_ERROR IS NULL;

    K_CODERROR:= 0;
    K_DESCERROR:= '';

    EXCEPTION
       WHEN OTHERS THEN
             K_CODERROR:= SQLCODE;
             K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSI_LOYMOVTOS;

PROCEDURE ADMPSI_ELOYMOVTOS(CURSORLOYMOVTOS out SYS_REFCURSOR) is
--****************************************************************
-- Nombre SP           :  ADMPSI_ELOYMOVTOS
-- Propósito           :  Contiene el proceso necesario para devolver los registros de carga de movimientos de Loyalty, que no se insertaron en la tabla de Kardex.
-- Input               :
-- Output              :  CURSORLOYMOVTOS
-- Creado por          :  Luis De la Fuente ()
-- Fec Creación        :  19/10/2010
-- Fec Actualización   :
--****************************************************************
BEGIN
OPEN CURSORLOYMOVTOS FOR
SELECT
 L.ADMPV_COD_CLI,
 L.ADMPV_MOTIVO,
 TO_DATE(L.ADMPD_FECHA,'DD/MM/YYYY'),
 L.ADMPN_PUNTOS,
 L.ADMPV_TIPOPE,
 L.ADMPN_SLDPUNTOS,
 L.ADMPV_IDTRANS,
 L.ADMPV_MSJE_ERROR
 FROM PCLUB.ADMPT_LOY_MOVTOS L
 WHERE TRIM(L.ADMPV_MSJE_ERROR) <> ' '
       AND ADMPV_ESTADO = 'P'             -- Agregado para la entrega de puntos delta
 ORDER BY L.ADMPV_COD_CLI;

-- SSC 25102010 - Actualizamos a Ejecutado (E) los que ya se procesaron y mostraron
UPDATE PCLUB.ADMPT_LOY_MOVTOS SET ADMPV_ESTADO = 'E' WHERE ADMPV_ESTADO = 'P';

COMMIT;
-- SSC 25102010

END ADMPSI_ELOYMOVTOS;

PROCEDURE ADMPSI_LOY_ALINI(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER) IS
--****************************************************************
-- Nombre SP           :  ADMPSI_LOY_ALINI
-- Propósito           :  Contiene el proceso necesario para aliniar los clientes en estado de baja que tienen saldos distintos a 0
--
-- Input               :
--
-- Output              :  K_CODERROR Codigo de Error o Exito
--                        K_DESCERROR Descripcion del Error (si se presento)
--
-- Creado por          :  Maomed Chocce
-- Fec Creacion        :  15/03/2011
-- Fec Actualizacion   :
--****************************************************************

V_REGCLI NUMBER;
C_CODCLIENTE VARCHAR2(40);
V_SALDO_CC NUMBER;
V_SALDO_IB NUMBER;
V_IDKARDEX NUMBER;
V_SALDO_NUEVO VARCHAR2(40);
V_CLIENTE_AUX VARCHAR2(40);
V_CONT_IB NUMBER;
V_COD_CLI_IB NUMBER;

CURSOR BAJA_CLIENTES IS
  SELECT A.ADMPV_COD_CLI
  FROM PCLUB.ADMPT_CLIENTE a
  WHERE A.ADMPC_ESTADO='B';

 BEGIN

  OPEN BAJA_CLIENTES;
  FETCH BAJA_CLIENTES INTO C_CODCLIENTE;
  WHILE BAJA_CLIENTES %FOUND LOOP

     V_REGCLI :=0;
     V_SALDO_CC := 0;
     V_SALDO_IB := 0;
     V_COD_CLI_IB := NULL;

        --COPIAMOS DE LOS CLIENTES EN BAJA SUS SALDOS Y LOS COPIAMOS A LA TABLA ADMPT_SALDO_CLI_DES
        INSERT INTO PCLUB.ADMPT_SALDO_CLI_DES
        SELECT C.* FROM PCLUB.ADMPT_SALDOS_CLIENTE C 
        WHERE C.ADMPV_COD_CLI=C_CODCLIENTE AND (C.ADMPN_SALDO_CC+C.ADMPN_SALDO_IB)>0;

                  
        BEGIN
 
          -- SSC 22122010 - Verificamos si el cliente es IB
          BEGIN
             V_CONT_IB := 0;
             SELECT COUNT (1) INTO V_CONT_IB
               FROM PCLUB.ADMPT_CLIENTEIB
              WHERE ADMPV_COD_CLI = C_CODCLIENTE;

              IF V_CONT_IB > 0 THEN
                 BEGIN
                   V_COD_CLI_IB := NULL;

                   SELECT ADMPN_COD_CLI_IB INTO V_COD_CLI_IB
                     FROM PCLUB.ADMPT_CLIENTEIB
                    WHERE ADMPV_COD_CLI = C_CODCLIENTE;

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
                           AUX.ADMPC_ESTADO = 'B') TD
             WHERE ADMPV_COD_CLI <> C_CODCLIENTE AND
                   ADMPV_TIPO_DOC = TD.TIPO_DOC AND
                   ADMPV_NUM_DOC = TD.NUM_DOC AND
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

					   COMMIT;
                      -- Actualizamos los movimientos que tienen saldo y son IB
                      UPDATE PCLUB.ADMPT_KARDEX
                         SET ADMPV_COD_CLI = NULL
                       WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB AND
                             ADMPC_TPO_PUNTO = 'I' AND
                             ADMPN_SLD_PUNTO > 0 AND
                             ADMPC_TPO_OPER = 'E';
					   COMMIT;
                      -- Ahora insertamos el registro del saldo del cliente IB
                      INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                      VALUES (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,NULL,V_COD_CLI_IB,0,V_SALDO_IB,NULL,'A');

					  COMMIT;

                   END;
                END IF;

                BEGIN
                    --Se obtiene el saldo del cliente
                    BEGIN
                      SELECT NVL(ADMPN_SALDO_CC,NULL)
                        INTO V_SALDO_CC
                        FROM PCLUB.ADMPT_SALDOS_CLIENTE
                       WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                       EXCEPTION WHEN NO_DATA_FOUND THEN V_SALDO_CC := 0;
                    END;
                    V_SALDO_NUEVO := V_SALDO_CC * -1;

                    IF V_SALDO_NUEVO < 0 THEN
                    /* genera secuencial de kardex*/
                          SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;
                    -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                       INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                          ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPC_TPO_OPER,
                                                           ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                          VALUES(V_IDKARDEX, NULL, C_CODCLIENTE, '47',
                                 TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_NUEVO, 'S', 'C', 0, 'A');
					   COMMIT;
                        -- ACTUALIZAMOS LOS SALDOS A 0 DE LOS REGISTROS DEL KARDEX SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
                        UPDATE PCLUB.ADMPT_KARDEX
                        SET ADMPN_SLD_PUNTO = 0
                        WHERE ADMPV_COD_CLI = C_CODCLIENTE
                        AND ADMPC_TPO_PUNTO IN('C','L')
                        AND ADMPN_SLD_PUNTO > 0
                        AND ADMPC_TPO_OPER = 'E';

						COMMIT;
						
                        -- ACTUALIZAMOS EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
                        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                           SET S.ADMPN_SALDO_CC = 0,
                               S.ADMPN_SALDO_IB = 0,
                               S.ADMPN_COD_CLI_IB = NULL
                         WHERE ADMPV_COD_CLI = C_CODCLIENTE;
                        
						COMMIT;
                        
                    END IF;
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
					   COMMIT;					
                      -- Actualizamos los movimientos que tienen saldo y son IB
                      UPDATE PCLUB.ADMPT_KARDEX
                         SET ADMPV_COD_CLI = V_CLIENTE_AUX
                       WHERE ADMPN_COD_CLI_IB = V_COD_CLI_IB AND
                             ADMPC_TPO_PUNTO = 'I' AND
                             ADMPN_SLD_PUNTO > 0 AND
                             ADMPC_TPO_OPER = 'E';
						COMMIT;
                      -- ACTUALIZAMOS EL SALDO IB CON LA OTRA CUENTA DEL CLIENTE
                      UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                         SET S.ADMPN_SALDO_IB = V_SALDO_IB,
                             S.ADMPC_ESTPTO_IB = 'A',
                             S.ADMPN_COD_CLI_IB = V_COD_CLI_IB
                       WHERE ADMPV_COD_CLI = V_CLIENTE_AUX;
					   COMMIT;
					  UPDATE ADMPT_SALDOS_CLIENTE S
                         SET S.ADMPN_SALDO_IB = 0,
						 S.ADMPN_COD_CLI_IB = NULL
                      WHERE ADMPV_COD_CLI = C_CODCLIENTE;
                      COMMIT;
					   
                   END;      -- Fin de Bloque si es ClienteIB
                END IF;

BEGIN
                    --Se obtiene el saldo del cliente
                    BEGIN
                      SELECT NVL(ADMPN_SALDO_CC,NULL)
                        INTO V_SALDO_CC
                        FROM PCLUB.ADMPT_SALDOS_CLIENTE
                       WHERE ADMPV_COD_CLI = C_CODCLIENTE;

                       EXCEPTION WHEN NO_DATA_FOUND THEN V_SALDO_CC := 0;
                    END;
                    V_SALDO_NUEVO := V_SALDO_CC * -1;

                    IF V_SALDO_NUEVO < 0 THEN
                       /* genera secuencial de kardex*/
                       SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;
  
                       -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                       INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                          ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS,
                                                          ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                          VALUES(V_IDKARDEX, NULL, C_CODCLIENTE, '47',
                                 TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_NUEVO, 'S', 'C', 0, 'A');
						COMMIT;
                        -- ACTUALIZAMOS LOS SALDOS A 0 DE LOS REGISTROS DEL KARDEX SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
                       UPDATE PCLUB.ADMPT_KARDEX
                          SET ADMPN_SLD_PUNTO = 0
                        WHERE ADMPV_COD_CLI = C_CODCLIENTE
                              AND ADMPC_TPO_PUNTO IN('C','L')
                              AND ADMPN_SLD_PUNTO > 0
                              AND ADMPC_TPO_OPER = 'E';
						COMMIT;
                        -- ACTUALIZAMOS EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
                        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                           SET S.ADMPN_SALDO_CC = 0,
                               S.ADMPN_SALDO_IB = 0,
                               S.ADMPN_COD_CLI_IB = NULL
                         WHERE ADMPV_COD_CLI = C_CODCLIENTE;
						 COMMIT;
                        -- ACTUALIZAMOS LA TABLA CLIENTE CON EL ESTADO 'B'
                        UPDATE PCLUB.ADMPT_CLIENTE C
                           SET C.ADMPC_ESTADO = 'B'
                         WHERE C.ADMPV_COD_CLI = C_CODCLIENTE;
						 COMMIT;
                         -- Ahora Insertamos el movimiento de ingreso para la otra cuenta
                         SELECT PCLUB.admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;
  
                         -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                         INSERT INTO PCLUB.ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB, ADMPV_COD_CLI,
                                                            ADMPV_COD_CPTO,ADMPD_FEC_TRANS,ADMPN_PUNTOS, ADMPV_NOM_ARCH,
                                                            ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
                            VALUES(V_IDKARDEX, V_COD_CLI_IB, V_CLIENTE_AUX, '47',
                                   TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_SALDO_CC, NULL, 'E', 'C', V_SALDO_CC, 'A');
						 COMMIT;
                         -- ACTUALIZAMOS EL SALDO CC DE LA OTRA CUENTA DEL CLIENTE
                          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
                             SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + NVL (V_SALDO_CC, 0)
                           WHERE ADMPV_COD_CLI = V_CLIENTE_AUX;
						 COMMIT;
                         -- Los registros de la otra cuenta deben ser actualizados con el código ib
    UPDATE PCLUB.ADMPT_KARDEX
                              SET ADMPN_COD_CLI_IB = V_COD_CLI_IB
                            WHERE ADMPV_COD_CLI = V_CLIENTE_AUX
                                  AND ADMPC_TPO_PUNTO IN ('C','L')
                                  AND ADMPN_SLD_PUNTO > 0
                                  AND ADMPC_TPO_OPER = 'E';
							COMMIT;
   END IF;
                END;

             END;
  END IF;

        END;
    

COMMIT;

     FETCH BAJA_CLIENTES INTO C_CODCLIENTE;

END LOOP;
  

-- Obtenemos los registros totales, procesados y con error
SELECT COUNT (1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_SALDO_CLI_DES;
SELECT COUNT (1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_SALDO_CLI_DES;
K_NUMREGERR:= 0;

 K_CODERROR:= 0;
 K_DESCERROR:= '';

  EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);


END ADMPSI_LOY_ALINI;

end PKG_CC_IMPLOYALTY;
/