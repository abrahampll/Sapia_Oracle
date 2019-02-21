create or replace package body PCLUB.PKG_REALIZARCANJE is

procedure sp_realizarcanje(  solicitud in varchar2,                 
                             numeroOrden in varchar2,         
                             codigoContrato in varchar2,      
                             numeroLinea in number,           
                             tipoDocumento in varchar2,       
                             numeroDocumento in varchar2,          
                             codigoPuntoVenta in varchar2,        
                             nombrePuntoVenta in varchar2,        
                             origen in varchar2,                     
                             codigoAsesor in varchar2,         
                             nombreAsesor in varchar2,         
                             segmento in varchar2,            
                             codigoProducto in varchar2,          
                             nombreProducto in varchar2,          
                             cantidadPuntos in varchar2,          
                             puntosSoles in varchar2,           
                             cantidad in varchar2,                        
                             tipoPremio in varchar2,            
                             nombreTipoPremio in varchar2,      
                             codigorespuesta out varchar2,        
                             mensajerespuesta out varchar2) is      

--VARIBLES MOVIL - FIJA
      no_solicitud EXCEPTION;
      no_numeroOrden EXCEPTION;
      no_codigoContrato EXCEPTION;
      no_codigoPuntoVenta EXCEPTION;
      no_nombrePuntoVenta EXCEPTION;
      no_origen EXCEPTION;
      no_codigoAsesor EXCEPTION;
      no_nombreAsesor EXCEPTION;
      no_segmento EXCEPTION;
      no_codigoProducto EXCEPTION;
      no_nombreProducto EXCEPTION;
      no_cantidadPuntos EXCEPTION;
      no_puntosSoles EXCEPTION;
      no_cantidad  EXCEPTION;
      no_tipoPremio  EXCEPTION;
      no_nombreTipoPremio EXCEPTION;
      
      NO_DESC_PUNTOS EXCEPTION;
      
      EX_ERROR_DCTOPTO  EXCEPTION;
    
      K_GRUPO  NUMBER;
      V_COD_CANJE NUMBER;
      V_ID_KARDEX NUMBER;
      V_SEC       NUMBER := 1 ;
      V_PUNTOS_REQUERIDOS NUMBER;

      K_TIP_CLI VARCHAR2 (2);
      V_SALDO NUMBER;
      V_SALDO_CC_M NUMBER;
      V_SALDO_CC_F NUMBER;
      V_SALDO_CLIBONO_M NUMBER;
      V_SALDO_KDX_M NUMBER;
      V_SALDO_KDX_F NUMBER;
      V_SALDOKDX  NUMBER;
   
      V_CODERROR  NUMBER;
      V_ENCUESTA CHAR(1);
      V_COD_CPTO  NUMBER;
      V_DESCERROR VARCHAR2(400);
      K_ESTADO CHAR(1);
      V_TIPO_DOC VARCHAR2(20);
      K_CODERROR_EX  NUMBER;
      V_EXISTE    NUMBER;
      V_EXISTE_F  NUMBER;
      V_EXISTE_P  NUMBER;
      V_SEGMENTO     VARCHAR2(7) := segmento;

      V_TIPO_DOC  VARCHAR2(20);
      K_CODERROR_EX  NUMBER;
     
  
  BEGIN
      if solicitud is null then
        raise no_solicitud;
      end if;
       
      if numeroOrden is null then
        raise no_numeroOrden;
      end if;
      
      if codigoContrato is null then
        raise no_codigoContrato;
      end if;
      
      if codigoPuntoVenta is null then
         raise no_codigoPuntoVenta;
       end if;
       
       if nombrePuntoVenta is null then
         raise no_nombrePuntoVenta;
       end if;
       
        if origen is null then
         raise no_origen;
       end if; 
      
      if codigoAsesor is null then
         raise no_codigoAsesor;
       end if;
       
       if nombreAsesor is null then
         raise no_nombreAsesor;
       end if;
      
      
       if segmento is null then
         raise no_segmento;
       end if;
      
       if codigoProducto is null then
         raise no_codigoProducto;
       end if;
      
      if nombreProducto is null then
         raise no_nombreProducto;
       end if;
       
       if cantidadPuntos is null then
         raise no_cantidadPuntos;
       end if;
       
       if puntosSoles is null then
         raise no_puntosSoles;
       end if;
       
       if cantidad is null then
         raise no_cantidad;
       end if;
       
       if tipoPremio is null then
         raise no_tipoPremio;
       end if;

        SELECT count(1)
               INTO V_EXISTE_P
        FROM pclub.admpt_tipo_premio
        WHERE admpv_cod_tpopr = tipoPremio
              and admpc_estado = 'A';
        
        IF V_EXISTE_P = 0 THEN
           codigorespuesta  := 1;
           mensajerespuesta := 'Tipo de premio no esta registrado';
           return;
        END IF ; 
       
       
        if nombreTipoPremio is null then
         raise no_nombreTipoPremio;
       end if;
       
       --Validando si es cliente MOVIL
       SELECT count(1)
             INTO V_EXISTE
       FROM pclub.admpt_cliente 
       WHERE admpv_cod_cli = codigoContrato 
            AND admpv_tipo_doc = tipoDocumento
            AND admpv_num_doc = numeroDocumento
            AND admpc_estado = 'A';
       
       --Validando si es cliente FIJA
       SELECT count(1)
             INTO V_EXISTE_F
       FROM pclub.admpt_clientefija 
       WHERE admpv_cod_cli = codigoContrato 
            AND admpv_tipo_doc = tipoDocumento
            AND admpv_num_doc = numeroDocumento
            AND admpc_estado= 'A';
            
            
       IF V_EXISTE = 0 and  V_EXISTE_F = 0 THEN
         codigorespuesta  := 1;
         mensajerespuesta := 'El tipo de documento '||tipoDocumento ||' y número de documento '||numeroDocumento||' no se encuentra afiliado a Claro Club';
         return;
       END IF;
       
       --Obteniendo K_GRUPO
              SELECT ADMPN_GRUPO
                     INTO K_GRUPO
              FROM PCLUB.ADMPT_TIPO_PREMIO
              WHERE ADMPV_COD_TPOPR= tipoPremio
                    AND ADMPC_ESTADO = 'A';
       
       --Calculando los puntos por numero y tipo de documento
              --Puntos Claro Movil
              SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0))
                     INTO V_SALDO_CC_M
              FROM PCLUB.ADMPT_CLIENTE C
                   INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                   ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
              WHERE (C.ADMPV_TIPO_DOC = tipoDocumento AND
                    C.ADMPV_NUM_DOC = numeroDocumento)
                    AND C.ADMPC_ESTADO = 'A'
                    AND SC.ADMPC_ESTPTO_CC = 'A'; 
              --Puntos Claro Fija
              SELECT  SUM(NVL(S.ADMPN_SALDO_CC,0))
                      INTO V_SALDO_CC_F
              FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
                   INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P ON (S.ADMPV_COD_CLI_PROD=P.ADMPV_COD_CLI_PROD)
                   INNER JOIN PCLUB.ADMPT_CLIENTEFIJA C ON (P.ADMPV_COD_CLI=C.ADMPV_COD_CLI)
              WHERE C.ADMPV_TIPO_DOC = tipoDocumento
                    AND C.ADMPV_NUM_DOC = numeroDocumento
                    AND C.ADMPC_ESTADO='A'
                    AND P.ADMPV_ESTADO_SERV='A';        
              --Puntos Bono Movil
              SELECT SUM(NVL(SB.ADMPN_SALDO, 0))
                     INTO V_SALDO_CLIBONO_M
              FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
              WHERE SB.ADMPN_GRUPO = K_GRUPO AND
                    SB.ADMPV_COD_CLI IN
                    (SELECT CC2.ADMPV_COD_CLI
                     FROM PCLUB.ADMPT_CLIENTE CC2
                     WHERE CC2.ADMPV_TIPO_DOC = tipoDocumento
                           AND CC2.ADMPV_NUM_DOC = numeroDocumento
                           AND CC2.admpc_estado = 'A'); 

              V_SALDO := NVL (V_SALDO_CC_M,0) + NVL (V_SALDO_CC_F,0) + NVL (V_SALDO_CLIBONO_M,0);
              
              V_PUNTOS_REQUERIDOS := to_number(cantidadPuntos, '9999999') * to_number( cantidad,'9999999' );
              
              --Validando Saldo
              IF V_PUNTOS_REQUERIDOS > V_SALDO THEN
                codigorespuesta  := 1;
                mensajerespuesta := 'No tiene saldo para realizar el canje ';
                return;
              END IF;
              
              --Obtengo la Suma de Saldo kardex movil
              SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0)
                     INTO V_SALDO_KDX_M
              FROM PCLUB.ADMPT_KARDEX K
              WHERE K.ADMPV_COD_CLI IN
              (SELECT CC2.ADMPV_COD_CLI
              FROM PCLUB.admpt_cliente CC2
              WHERE  CC2.ADMPV_TIPO_DOC = tipoDocumento
                     AND CC2.ADMPV_NUM_DOC = numeroDocumento
                     AND CC2.admpc_estado = 'A')
                     AND K.ADMPC_ESTADO='A';
              --Obtengo la Suma de Saldo kardex fija
              SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0)
                     INTO V_SALDO_KDX_F
              FROM PCLUB.ADMPT_KARDEXFIJA K
                   INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P ON (K.ADMPV_COD_CLI_PROD=P.ADMPV_COD_CLI_PROD)
                   INNER JOIN PCLUB.ADMPT_CLIENTEFIJA C ON (P.ADMPV_COD_CLI=C.ADMPV_COD_CLI)
              WHERE  C.ADMPV_TIPO_DOC = tipoDocumento
                     AND C.ADMPV_NUM_DOC = numeroDocumento
                     AND C.ADMPC_ESTADO='A'
                     AND P.ADMPV_ESTADO_SERV='A'
                     AND K.ADMPC_ESTADO='A'
                     AND K.ADMPC_TPO_OPER='E'
                     AND K.ADMPN_SLD_PUNTO>0;
              
--====================SI ES CLIENTE MOVIL   
 
      IF V_EXISTE > 0 THEN
        
              --Asignando variable a tipo de cliente K_TIP_CLI
              SELECT admpv_cod_tpocl
                     INTO K_TIP_CLI
              FROM pclub.admpt_cliente
              WHERE admpv_cod_cli=codigoContrato;
              
    
      --Ejecuatndo SP ADMPI_BLOQUEOBOLSA
              PCLUB.PKG_CC_TRANSACCION.ADMPI_BLOQUEOBOLSA(  tipoDocumento,
                                                            numeroDocumento,
                                                            K_TIP_CLI,
                                                            codigoAsesor,
                                                            K_ESTADO,
                                                            codigorespuesta,
                                                            mensajerespuesta);
              
              IF codigorespuesta  = 0 AND K_ESTADO = 'L' THEN
                
                   V_SALDOKDX := V_SALDO_KDX_M + V_SALDO_KDX_F;
                   
              ELSE
                  IF codigorespuesta = 37 AND K_ESTADO = 'R' THEN
                     codigorespuesta  := 1;
                     mensajerespuesta := 'Kardex no liberado';
                     RETURN;
                  ELSE
                     codigorespuesta  := 1;
                     mensajerespuesta := 'Kardex bloqueado';
                     RETURN;
                  END IF;
              END IF;
              
              --Validando Kardex alineado
               IF V_SALDO <> V_SALDOKDX THEN
                   codigorespuesta  := 1;
                   mensajerespuesta := 'Kardex Desalineado';
                   return;
               END IF;
               
               
  -- Inicio de canje
      SELECT NVL(pclub.admpt_canje_sq.NEXTVAL, '-1')
             INTO V_COD_CANJE
      FROM dual;
    
    -- Relizando el insert en la tabla CANJE
    INSERT INTO pclub.admpt_canje
      (admpv_id_canje,
       admpv_cod_cli,
       admpv_id_solic,
       admpv_pto_venta,
       admpd_fec_canje,
       admpv_hra_canje,
       admpv_num_doc,
       admpv_cod_tpocl,
       admpv_cod_aseso,
       admpv_nom_aseso,
       admpc_tpo_oper,
       admpv_cod_tipapl,
       admpv_clave,
       admpv_mensaje,
       admpv_ticket,
       admpv_id_loyalty,
       admpv_id_gprs,
       admpv_num_linea,
       ADMPV_CODSEGMENTO,
       ADMPV_USU_ASEG,
       ADMPN_TIPCANJE,
       ADMPN_TIPPREMCJE,
       ADMPN_SOLESVTA)
    values
      (V_COD_CANJE,
       codigoContrato,
       solicitud,
       codigoPuntoVenta,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       TO_CHAR(SYSDATE, 'HH:MI AM'),
       numeroDocumento,
       K_TIP_CLI,
       codigoAsesor,
       nombreAsesor,
       'C',
       numeroOrden,
       nombreProducto,
       '', 
       '',   
       '', 
       '',   
       numeroLinea,
       V_SEGMENTO,
       '',   
       0,
       0,
       puntosSoles);

       -- Inserta en CANJE_DETALLE
       INSERT INTO pclub.admpt_canje_detalle
          (admpv_id_canje,
           admpv_id_canjesec,
           admpv_id_procla,
           admpv_desc,
           admpv_nom_camp,
           admpn_puntos,
           admpn_pago,
           admpn_cantidad,
           admpv_cod_tpopr,
           admpn_cod_servc,
           admpn_mnt_recar,
           admpc_estado,
           admpv_cod_paqdat,
           ADMPN_VALSEGMENTO,
           ADMPN_PUNTOSDSCTO)
        VALUES
          (V_COD_CANJE,
           V_SEC,
           codigoProducto,
           nombreProducto,
           '',
           cantidadPuntos,
           '',
           cantidad,
           tipoPremio,
           '',
           '',
           'C',
           '',
           '',
           '');
    
      --Realizando el descuento de puntos
      PCLUB.PKG_REALIZARCANJE.admpsi_desc_puntos( V_COD_CANJE,
                                                   V_SEC,
                                                   cantidadPuntos * cantidad,
                                                   codigoContrato,
                                                   tipoDocumento,
                                                   numeroDocumento,
                                                   K_GRUPO,
                                                   codigoAsesor,
                                                   V_CODERROR,
                                                   V_DESCERROR);
                                                   
      IF V_CODERROR > 0 THEN
         RAISE NO_DESC_PUNTOS;
      END IF;
      
   
   -- Relizando el insert en la tabla KARDEX
      IF K_TIP_CLI='8' THEN
         SELECT NVL(admpv_cod_cpto, '-1')
                INTO V_COD_CPTO
            FROM pclub.admpt_concepto
            WHERE admpv_desc = 'CANJE TFI';
      ELSE
            SELECT NVL(admpv_cod_cpto, '-1')
                  INTO V_COD_CPTO
                  FROM pclub.admpt_concepto
                  WHERE admpv_desc = 'CANJE';
      END IF;

      SELECT NVL(pclub.admpt_kardex_sq.NEXTVAL, '-1')
             INTO V_ID_KARDEX
      FROM dual;
  
      INSERT INTO pclub.admpt_kardex
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
          (V_ID_KARDEX,
           '',
           codigoContrato,
           V_COD_CPTO,
           TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
           V_PUNTOS_REQUERIDOS * (-1),
           'TCRM', --ORIGEN
           'S',
           'C', 
           0,
           'C'); 
     
  -- Relizando el insert en la tabla PUNTO DE VENTA
     insert into pclub.admpt_punto_venta
         (admpv_id_canje,
          admpv_pto_venta,
          admpv_pto_venta_des,
          admpv_desc)
     values
         (V_COD_CANJE,
          codigoPuntoVenta,
          nombrePuntoVenta,
          nombreTipoPremio);
     
  
   /* Actualiza el canje movil */
    UPDATE pclub.admpt_canje
    SET admpn_id_kardex = V_ID_KARDEX
    WHERE admpv_id_canje = V_COD_CANJE;


     -------- Validar si se genera el Registro en ADMPT_MOVENCUESTA --------
    BEGIN
      SELECT ADMPC_ENCUESTA 
             INTO V_ENCUESTA
      FROM  PCLUB.ADMPT_TIPO_CLIENTE
      WHERE ADMPV_COD_TPOCL = K_TIP_CLI;

      IF V_ENCUESTA = '1' THEN
      PCLUB.PKG_CC_ENCUESTA.ADMPSS_REGMOVENCUESTA(numeroLinea ,
                                                  codigoAsesor ,
                                                  V_COD_CANJE,
                                                  tipoDocumento ,
                                                  numeroDocumento ,
                                                  codigoContrato ,
                                                  V_CODERROR,
                                                  V_DESCERROR);
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
      END;
      
      --Liberando Bolsa      
      PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(  tipoDocumento,
                                                        numeroDocumento,
                                                        K_TIP_CLI,
                                                        codigorespuesta,
                                                        codigorespuesta);
        
      codigorespuesta := '0';
      mensajerespuesta:= 'Transaction Ok'; 
  
 
    --====== SI ES CLIENTE FIJA
    else
      if V_EXISTE_F > 0 then

  
              --Asignando variable a tipo de cliente K_TIP_CLI
              select admpv_cod_tpocl
                     into K_TIP_CLI
              from pclub.admpt_clientefija
              where admpv_cod_cli=codigoContrato;
   
  
        --Ejecuatndo SP ADMPI_BLOQUEOBOLSA
              PCLUB.PKG_CC_TRANSACCION.ADMPI_BLOQUEOBOLSA(  tipoDocumento,
                                                            numeroDocumento,
                                                            K_TIP_CLI,
                                                            codigoAsesor,
                                                            K_ESTADO,
                                                            codigorespuesta,
                                                            mensajerespuesta);
              
              IF codigorespuesta  = 0 AND K_ESTADO = 'L' THEN
                
                   V_SALDOKDX := V_SALDO_KDX_M + V_SALDO_KDX_F;
                   
              ELSE
                  IF codigorespuesta = 37 AND K_ESTADO = 'R' THEN
                     codigorespuesta  := 1;
                     mensajerespuesta := 'Kardex no liberado';
                     RETURN;
                  ELSE
                     codigorespuesta  := 1;
                     mensajerespuesta := 'Kardex bloqueado';
                     RETURN;
                  END IF;
              END IF;
              
              --Validando Kardex alineado
               IF V_SALDO <> V_SALDOKDX THEN
                   codigorespuesta  := 1;
                   mensajerespuesta := 'Kardex Desalineado';
                   return;
               END IF;



    --Inicio de canje
    SELECT NVL(PCLUB.ADMPT_canjefija_sq.NEXTVAL, '-1')
           INTO V_COD_CANJE
           FROM dual;

  
    -- Inserta entrada en la tabla CANJE
    INSERT INTO PCLUB.ADMPT_CANJEFIJA
      (admpv_id_canje,
       admpv_cod_cli,
       admpv_pto_venta,
       admpd_fec_canje,
       admpv_hra_canje,
       admpv_num_doc,
       admpv_cod_tpocl,
       admpv_cod_aseso,
       admpv_nom_aseso,
       admpc_tpo_oper,
       admpv_cod_tipapl,
       admpv_clave,
       admpv_num_linea_sms,
       admpv_premio_linea,
       admpv_tipo_linea,
       admpv_num_linea,
       admpv_cod_cli_prod,
       admpv_direc_cliprod,
       admpv_cod_serv_sga,
       admpv_usu_reg,
       ADMPV_CODSEGMENTO,
       ADMPV_USU_ASEG
    )
    values
      (V_COD_CANJE,
       codigoContrato,
       codigoPuntoVenta,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       TO_CHAR(SYSDATE, 'HH:MI AM'),
       numeroDocumento,
       K_TIP_CLI,
       codigoAsesor,
       nombreAsesor,
       'C',
       numeroOrden,
       nombreProducto,
       '',
       '',
       K_TIP_CLI,
       numeroLinea,
       codigoProducto,
       '',
       '',
       origen,
       segmento,
       ''
       );

    -- Inserta entrada en la tabla CANJE_DETALLE
    INSERT INTO PCLUB.ADMPT_canje_detallefija
       (admpv_id_canje,
        admpv_id_canjesec,
        admpv_id_procla,
        admpv_desc,
        admpv_nom_camp,
        admpn_puntos,
        admpn_pago,
        admpn_cantidad,
        admpv_cod_tpopr,
        admpn_cod_servc,
        admpn_mnt_recar,
        admpc_estado,
        admpv_cod_paqdat,
        ADMPN_VALSEGMENTO,
        ADMPN_PUNTOSDSCTO,
        admpv_usu_reg  
        )
    VALUES    
       (V_COD_CANJE,
        V_SEC,            
        codigoProducto, 
        nombreProducto,      
        '', 
        cantidadPuntos,
        '',               
        cantidad,
        tipoPremio,  
        '',        
        '',           
        'C', 
        '',        
        '',         
        '',        
        origen);
        
         
     
     --Realizando el descuento de puntos
     PCLUB.PKG_REALIZARCANJE.admpsi_desc_puntos(V_COD_CANJE, 
                                                      V_SEC,
                                                      cantidadPuntos * cantidad,
                                                      codigoContrato,
                                                      tipoDocumento,   
                                                      numeroDocumento,
                                                      K_GRUPO,
                                                      codigoAsesor,
                                                      V_CODERROR, 
                                                      V_DESCERROR);
                        
       IF V_CODERROR > 0 THEN
          codigorespuesta:=1;
          RAISE EX_ERROR_DCTOPTO;
       end if;  
  
        
   -- Relizando el insert en la tabla KARDEX    
      IF  K_TIP_CLI='6' THEN
          SELECT NVL(admpv_cod_cpto, '-1')    INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
          WHERE admpv_desc='CANJE DTH';
       ELSIF K_TIP_CLI='7' THEN
          SELECT NVL(admpv_cod_cpto, '-1')    INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
          WHERE admpv_desc = 'CANJE HFC';
     ELSIF K_TIP_CLI='9' THEN
          SELECT NVL(ADMPV_COD_CPTO, '-1')    INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
          WHERE ADMPV_DESC = 'CANJE 3PLAY';
       END IF ;


    
      SELECT NVL(PCLUB.ADMPT_kardexfija_sq.NEXTVAL, '-1')
             INTO V_ID_KARDEX
      FROM dual;

      INSERT INTO PCLUB.ADMPT_kardexfija 
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
          admpc_estado,
          admpv_usu_reg,
          admpv_id_canje
          )
       VALUES 
          (V_ID_KARDEX,   
           '',    
           codigoContrato,
           V_COD_CPTO, 
           SYSDATE,  
           V_PUNTOS_REQUERIDOS * (-1),
           '', 
           'S',
           'C', 
           0,
           'C', 
           origen,
           V_COD_CANJE
           );

     
     -- Relizando el insert en la tabla PUNTO DE VENTA
     INSERT INTO pclub.admpt_punto_venta
         (admpv_id_canje,
          admpv_pto_venta,
          admpv_pto_venta_des,
          admpv_desc)
     VALUES
         (V_COD_CANJE,
          codigoPuntoVenta,
          nombrePuntoVenta,
          nombreTipoPremio);
          
   /* Actualiza el canje movil */
    UPDATE pclub.admpt_canjefija
    SET admpn_id_kardex = V_ID_KARDEX
    WHERE admpv_id_canje = V_COD_CANJE;
    
    
      --Liberando Bolsa      
      PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(  tipoDocumento,
                                                        numeroDocumento,
                                                        K_TIP_CLI,
                                                        codigorespuesta,
                                                        codigorespuesta);
        
      codigorespuesta := '0';
      mensajerespuesta:= 'Transaction Ok'; 
                                         
      end if;                                        
    end if;
    
     exception
        when no_solicitud then
         codigorespuesta  :=1;        
         mensajerespuesta := 'Falta solicitud';
         
        when no_numeroOrden then
         codigorespuesta  :=1;        
         mensajerespuesta := 'Falta numeroOrden';
         
        when no_codigoContrato then
         codigorespuesta  :=1;        
         mensajerespuesta := 'Falta codigoContrato';
         
         when no_codigoPuntoVenta then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe codigo Punto Venta';
         
         when no_nombrePuntoVenta then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe nombre Punto Venta';
         
         when no_origen then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe origen';
         
         when no_codigoAsesor then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe codigo Asesor';
         
         when no_nombreAsesor then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe nombre Asesor';
         
         when no_segmento then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe segmento';
         
         when no_codigoProducto then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe codigoProducto';
         
         when no_nombreProducto then 
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe nombre Producto';
         
         when no_cantidadPuntos then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe cantidad Puntos';
         
         when no_puntosSoles then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe puntos Soles';
         
         when no_cantidad then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe cantidad';
         
         when no_tipoPremio then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No existe tipoPremio';
         
         when no_nombreTipoPremio then
         codigorespuesta  :=1;        
         mensajerespuesta := 'No nombre Tipo Premio';
         
    
END sp_realizarcanje; 



PROCEDURE ADMPSI_DESC_PUNTOS(  K_ID_CANJE    NUMBER,
                               K_SEC         NUMBER,
                               K_PUNTOS      NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_GRUPO       IN NUMBER,
                               K_USUARIO     IN VARCHAR2,
                               K_CODERROR    OUT NUMBER,
                               K_MSJERROR    OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_DESC_PUNTOS
    -- Proposito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
    -- Input               :  K_ID_CANJE Identificador del canje
    --                        K_SEC Secuencial del Detalle
    --                        K_PUNTOS Total de Puntos a descontar
    --                        K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --
    -- Output              :  K_CODERROR
    --                        K_MSJERROR
    -- Creado por          :  
    -- Fec Creacion        :  
    -- Fec Actualizacion   :  
    --****************************************************************

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_TPO_PREMIO NUMBER;
    K_FEC_TRANS   date;
    V_EXISTE      NUMBER;
    V_EXISTE_F      NUMBER;
    /* Cursor */

    CURSOR LISTA_KARDEX IS
          SELECT   TIPO_PUNTO ,
                   ID_KARDEX,
                   SALDO_PUNTOS,
                   COD_CLI,
                   FEC_TRANS
          FROM   
             (SELECT KA.ADMPC_TPO_PUNTO AS TIPO_PUNTO ,
                     KA.ADMPN_ID_KARDEX AS ID_KARDEX,
                     KA.ADMPN_SLD_PUNTO AS SALDO_PUNTOS,
                     KA.ADMPV_COD_CLI AS COD_CLI,
                     KA.ADMPD_FEC_TRANS AS FEC_TRANS
              FROM PCLUB.ADMPT_KARDEX KA
              WHERE KA.ADMPC_ESTADO = 'A'
                   AND KA.ADMPC_TPO_OPER = 'E'
                   AND KA.ADMPN_SLD_PUNTO > 0
                   AND TO_DATE(TO_CHAR(KA.ADMPD_FEC_TRANS,'DD/MM/YYYY'),'DD/MM/YYYY') <= TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')
                   AND KA.ADMPV_COD_CLI IN
                   (SELECT CC2.ADMPV_COD_CLI
                    FROM PCLUB.ADMPT_CLIENTE CC2
                    WHERE CC2.ADMPV_TIPO_DOC = K_TIPO_DOC
                          AND CC2.ADMPV_NUM_DOC = K_NUM_DOC
                          AND CC2.ADMPC_ESTADO = 'A')
         
               UNION ALL
         
               SELECT KF.ADMPC_TPO_PUNTO AS TIPO_PUNTO ,
                      KF.ADMPN_ID_KARDEX AS ID_KARDEX, 
                      KF.ADMPN_SLD_PUNTO AS SALDO_PUNTOS,
                      KF.ADMPV_COD_CLI_PROD AS COD_CLI,
                      KF.ADMPD_FEC_TRANS AS FEC_TRANS
               FROM PCLUB.ADMPT_KARDEXFIJA KF
               WHERE KF.ADMPC_ESTADO = 'A' 
                     AND KF.ADMPC_TPO_OPER = 'E'
                     AND KF.ADMPN_SLD_PUNTO > 0
                     AND TO_DATE(TO_CHAR(KF.ADMPD_FEC_TRANS,'DD/MM/YYYY'),'DD/MM/YYYY') <=  TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')
                     AND KF.ADMPV_COD_CLI_PROD IN
                     (SELECT CP.ADMPV_COD_CLI_PROD    
                      FROM PCLUB.ADMPT_CLIENTEPRODUCTO CP
                          INNER JOIN PCLUB.ADMPT_CLIENTEFIJA CF ON (CF.ADMPV_COD_CLI = CP.ADMPV_COD_CLI)
                      WHERE CF.ADMPV_TIPO_DOC = K_TIPO_DOC  
                            AND CF.ADMPV_NUM_DOC = K_NUM_DOC 
                            AND CP.ADMPV_ESTADO_SERV = 'A')) B                 
                ORDER BY DECODE(TIPO_PUNTO,'B',1,'C',2), FEC_TRANS ASC;


  BEGIN
    /*
    Los puntos IB son los q se consumiran primero Tipo de punto 'I'
    los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden
    */
    K_CODERROR := 0;
    K_MSJERROR := '';

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

      -- Comienza el Canje, dato de entrada el tipo de doc y el num de doc
      IF K_COD_CLIENTE IS NOT NULL AND K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL THEN
        OPEN LISTA_KARDEX;
        FETCH LISTA_KARDEX
          INTO LK_TPO_PUNTO , 
               LK_ID_KARDEX,   
               LK_SLD_PUNTOS,
               LK_COD_CLI,     
               K_FEC_TRANS;                  
               
        WHILE LISTA_KARDEX%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
          
          --Validando si es cliente movil o fija
           SELECT count(1)
             INTO V_EXISTE
           FROM pclub.admpt_cliente 
           WHERE admpv_cod_cli = LK_COD_CLI
                AND admpc_estado = 'A';
       
           SELECT count(1)
                 INTO V_EXISTE_F
           FROM pclub.admpt_clientefija 
           WHERE admpv_cod_cli = LK_COD_CLI
                AND admpc_estado= 'A';
                
          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
            -- CONTRATO MOVIL
            IF V_EXISTE > 0 THEN
                -- Actualiza Kardex
                UPDATE admpt_kardex
                SET admpn_sld_punto = 0, admpc_estado = 'C'
                WHERE admpn_id_kardex = LK_ID_KARDEX;
                -- Inserta Canje_kardex
                INSERT INTO PCLUB.admpt_canjedt_kardex
                            (admpv_id_canje,
                             admpn_id_kardex,
                             admpv_id_canjesec,
                             admpn_puntos)
                 VALUES
                       (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS);
                 -- Actualiza Saldos_cliente
                  IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN  
                     UPDATE admpt_saldos_cliente
                     SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
                     WHERE admpv_cod_cli = LK_COD_CLI;    
                  ELSE
                      IF LK_TPO_PUNTO = 'B' THEN
                          IF LK_TPO_PREMIO = 0 THEN
                              /* Puntos Bonos para cualquier canje*/
                              UPDATE PCLUB.admpt_saldos_cliente
                              SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
                              WHERE admpv_cod_cli = LK_COD_CLI;
                            ELSE
                              /* Puntos Bonos para canjes de ciertos premios*/
                              UPDATE PCLUB.admpt_saldos_bono_cliente
                              SET ADMPN_SALDO = -LK_SLD_PUNTOS + NVL(ADMPN_SALDO, 0)
                              WHERE ADMPV_COD_CLI = LK_COD_CLI
                                    AND ADMPN_GRUPO = K_GRUPO;
                            END IF;
                       END IF;
                  END IF;
             
             -- CONTRATO FIJA   
             ELSE 
                -- Actualiza Kardex
                UPDATE PCLUB.ADMPT_kardexfija  
                SET admpn_sld_punto = 0, admpc_estado = 'C', ADMPV_USU_MOD= K_USUARIO
                WHERE admpn_id_kardex = LK_ID_KARDEX;
                -- Inserta Canje_kardex
                INSERT INTO PCLUB.ADMPT_canjedt_kardexfija 
                        (admpv_id_canje,
                         admpn_id_kardex,
                         admpv_id_canjesec,
                         admpn_puntos,
                         admpc_tpo_kardex)
                 VALUES 
                        (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS, 'E');
                 -- Actualiza Saldos_cliente
                  IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN  
                     UPDATE PCLUB.ADMPT_saldos_clientefija 
                     SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0) , ADMPV_USU_MOD= K_USUARIO
                     WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI;
                  END IF;       
             END IF;
            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
            
          ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN
               -- CONTRATO MOVIL
               IF V_EXISTE > 0 THEN
                  -- Actualiza Kardex
                  UPDATE admpt_kardex
                  SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                  WHERE admpn_id_kardex = LK_ID_KARDEX;
                  -- Inserta Canje_kardex
                  INSERT INTO PCLUB.admpt_canjedt_kardex
                          (admpv_id_canje,
                           admpn_id_kardex,
                           admpv_id_canjesec,
                           admpn_puntos)
                  VALUES
                    (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS);
                  -- Actualiza Saldos_cliente
                  IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                     UPDATE admpt_saldos_cliente
                     SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0)
                     WHERE admpv_cod_cli = LK_COD_CLI;
                  ELSE
                     IF LK_TPO_PUNTO = 'B' THEN
                          IF LK_TPO_PREMIO = 0 THEN
                              /* Puntos Bonos para cualquier canje*/
                              UPDATE PCLUB.admpt_saldos_cliente
                              SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
                              WHERE admpv_cod_cli = LK_COD_CLI;
                            ELSE
                              /* Puntos Bonos para canjes de ciertos premios*/
                              UPDATE PCLUB.admpt_saldos_bono_cliente
                              SET ADMPN_SALDO = -LK_SLD_PUNTOS + NVL(ADMPN_SALDO, 0)
                              WHERE ADMPV_COD_CLI = LK_COD_CLI
                                    AND ADMPN_GRUPO = K_GRUPO;
                            END IF;
                       END IF;                    
                  END IF;
                  
               -- CONTRATO FIJA
               ELSE
                  -- Actualiza Kardex
                  UPDATE PCLUB.ADMPT_kardexFIJA    
                  SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS, ADMPV_USU_MOD= K_USUARIO
                  WHERE admpn_id_kardex = LK_ID_KARDEX;
                  -- Inserta Canje_kardex
                  INSERT INTO PCLUB.ADMPT_canjedt_kardexFIJA 
                             (admpv_id_canje,
                              admpn_id_kardex,
                              admpv_id_canjesec,
                              admpn_puntos,
                              admpc_tpo_kardex)
                  VALUES 
                              (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS,'E');
                  -- Actualiza Saldos_cliente
                  IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                     UPDATE PCLUB.ADMPT_saldos_clientefija 
                     SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0), ADMPV_USU_MOD= K_USUARIO
                     WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI;
                  END IF;           
               END IF;
              V_PUNTOS_REQUERIDOS := 0;
            END IF;
          END IF;
          FETCH LISTA_KARDEX
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI,K_FEC_TRANS;
        END LOOP;
        CLOSE LISTA_KARDEX;

      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

  END ADMPSI_DESC_PUNTOS;


end PKG_REALIZARCANJE;
/