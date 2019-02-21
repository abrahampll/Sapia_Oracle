CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_TRANSACCION is

  TYPE K_REF_CURSOR IS REF CURSOR;
  TYPE tab_array IS TABLE OF VARCHAR2(50)    INDEX BY BINARY_INTEGER;
  procedure ADMPSS_CONSALDO(K_COD_CLIENTE     IN VARCHAR2,
                            K_TIPO_DOC        IN VARCHAR2,
                            K_NUM_DOC         IN VARCHAR2,
                            K_TIP_CLI         IN VARCHAR2,
                            K_CODERROR        OUT NUMBER,
                            K_MSJERROR        OUT VARCHAR2,
                            K_SALDO_PUNTOS    OUT NUMBER,
                            K_SALDO_PUNTOS_BONO OUT NUMBER,
                            K_SALDO_PUNTOS_CC OUT NUMBER,
                            K_SALDO_PUNTOS_IB OUT NUMBER,
                            K_CUR_LISTA       OUT SYS_REFCURSOR,
                            K_CUR_BONO          OUT SYS_REFCURSOR);

  procedure ADMPSS_CONSALDO(P_TIPO_DOC          IN PCLUB.admpt_cliente.admpv_tipo_doc%type,
                            P_NUM_DOC            IN PCLUB.admpt_cliente.admpv_num_doc%type,
                            P_SALDO_PUNTOS       OUT NUMBER,
                            P_COD_RESPUESTA      OUT NUMBER,
                            P_MENSAJE_RESPUESTA  OUT VARCHAR2);


  PROCEDURE ADMPSS_CONSALDOBONO(K_COD_CLIENTE       IN VARCHAR2,
                                K_TIPO_DOC          IN VARCHAR2,
                                K_NUM_DOC           IN VARCHAR2,
                                K_TIP_CLI           IN VARCHAR2,
                                K_TIP_PRE           IN VARCHAR2,
                                K_CODERROR          OUT NUMBER,
                                K_MSJERROR          OUT VARCHAR2,
                                K_SALDO_PUNTOS      OUT NUMBER,
                                K_SALDO_PUNTOS_BONO OUT NUMBER,
                                K_SALDO_PUNTOS_CC   OUT NUMBER,
                                K_SALDO_PUNTOS_IB   OUT NUMBER,
                                K_SALDO_PUNTOS_B    OUT NUMBER,
                                K_CUR_LISTA         OUT SYS_REFCURSOR
                                /*K_CUR_BONO        OUT SYS_REFCURSOR */);

  PROCEDURE ADMPSS_CONSCLIENTE(K_COD_CLIENTE IN VARCHAR2,K_RESULTADO OUT SYS_REFCURSOR);
  procedure ADMPSS_CONSPROD(K_CODPROD       IN VARCHAR2,
                            K_PUNTOS        IN NUMBER,
                            K_CODERROR      OUT NUMBER,
                            K_MSJERROR      OUT VARCHAR2,
                            CursorProductos OUT SYS_REFCURSOR);
  procedure ADMPSS_CANJPROD(K_ID_SOLICITUD IN VARCHAR2,
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_PUNTOVENTA   IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_COD_APLI     IN VARCHAR2,
                            K_CLAVE        IN VARCHAR2,
                            K_MSJSMSIN     IN VARCHAR2,
                            K_TICKET       IN VARCHAR2,
                            K_LISTA_PEDIDO IN LISTA_PEDIDO,
                            K_ID_LOYALTY   IN VARCHAR2,
                            K_ID_GPRS      IN VARCHAR2,
                            K_NUM_LINEA    IN VARCHAR2,
                            K_COD_ASESOR   IN VARCHAR2,
                            K_NOM_ASESOR   IN VARCHAR2,
                            K_CODSEGMENTO  IN VARCHAR2,
                            K_USU_ASEG     IN VARCHAR2,
                            K_TIPCANJE     IN NUMBER,
                            K_TIPPRECANJE  IN NUMBER,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_SALDO        OUT NUMBER,
                            K_MSJSMS       OUT VARCHAR2,
                            K_LISTA_CANJE  OUT SYS_REFCURSOR);
  procedure ADMPSS_COPRCANJ(K_CODCLI     IN VARCHAR2,
                            K_TIPODOC    IN VARCHAR2,
                            K_NUMDOC     IN VARCHAR2,
                            K_PUNTOVNTA  IN VARCHAR2,
                            K_TIPOCLI    IN VARCHAR2,
                            K_FECINICIAL IN DATE,
                            K_FECFINAL   IN DATE,
                            K_CODERROR   OUT NUMBER,
                            K_MSJERROR   OUT VARCHAR2,
                            K_SLDPUNTOS  OUT NUMBER,
                            CursorCanje  OUT SYS_REFCURSOR);
  PROCEDURE ADMPSS_DEVPUNTS(K_ID_SOLICITUD IN VARCHAR2,
                            K_PUNTOVENTA   IN VARCHAR2,
                            K_LISTA_DEV    IN LISTA_DEVOLUCION,
                            K_PUNTOS       IN NUMBER,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_SALDO        OUT NUMBER);
  procedure ADMPSS_SALDOCLI(K_COD_CLIENTE  IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            CUR_LISTASALDO OUT SYS_REFCURSOR);

  PROCEDURE ADMPSS_SALDOBONOCLI(K_COD_CLIENTE  IN VARCHAR2,
                                K_TIP_CLI      IN VARCHAR2,
                                K_CODERROR     OUT NUMBER,
                                K_MSJERROR     OUT VARCHAR2,
                                CUR_LISTASALDO OUT SYS_REFCURSOR);

  procedure ADMPSS_DATOSCLI(K_TIPO_DOC  IN VARCHAR2,
                            K_NUM_DOC   IN VARCHAR2,
                            K_TIPOLINEA IN VARCHAR2,
                            K_CODERROR  OUT NUMBER,
                            K_MSJERROR  OUT VARCHAR2,
                            CURSORCLI   OUT SYS_REFCURSOR);
  procedure ADMPSS_DETMOV(K_COD_CLIENTE IN VARCHAR2,
                          K_TIPO_DOC    IN VARCHAR2,
                          K_NUM_DOC     IN VARCHAR2,
                          K_TIP_CLI     IN VARCHAR2,
                          K_FECHA_INI   IN DATE,
                          K_FECHA_FIN   IN DATE,
                          K_CODERROR    OUT NUMBER,
                          K_MSJERROR    OUT VARCHAR2,
                          CURSORDATOS   OUT SYS_REFCURSOR);
  PROCEDURE ADMPSI_ES_CLIENTE(K_COD_CLIENTE IN VARCHAR2,
                              K_TIPO_DOC    IN VARCHAR2,
                              K_NUM_DOC     IN VARCHAR2,
                              K_TIP_CLI     IN VARCHAR2,
                              K_SALDO       OUT NUMBER,
                              K_CODERROR    OUT NUMBER);

  PROCEDURE ADMPSI_ES_CLIENTE_CJE(K_COD_CLIENTE IN VARCHAR2,
                              K_TIPO_DOC    IN VARCHAR2,
                              K_NUM_DOC     IN VARCHAR2,
                              K_TIP_CLI     IN VARCHAR2,
                              K_TIPCANJE     IN NUMBER,
                              K_TIPPRECANJE  IN NUMBER,
                              K_SALDO       OUT NUMBER,
                              K_CODERROR    OUT NUMBER);

  procedure ADMPSI_DESC_PUNTOS(K_ID_CANJE    NUMBER,
                               K_SEC         NUMBER,
                               K_PUNTOS      NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_CODERROR    OUT NUMBER,
                               K_MSJERROR    OUT VARCHAR2);

  PROCEDURE ADMPSI_DESC_PTOS_BONO(K_ID_CANJE    NUMBER,
                                  K_SEC         NUMBER,
                                  K_PUNTOS      NUMBER,
                                  K_COD_CLIENTE IN VARCHAR2,
                                  K_TIPO_DOC    IN VARCHAR2,
                                  K_NUM_DOC     IN VARCHAR2,
                                  K_TIP_CLI     IN VARCHAR2,
                                  K_GRUPO       IN NUMBER,
                                  K_CODERROR    OUT NUMBER,
                                  K_MSJERROR    OUT VARCHAR2);

  PROCEDURE ADMPSS_CONPERREN(K_SEGMENTO       IN VARCHAR2,
                             CURSORPERIODOSEG out SYS_REFCURSOR);
  PROCEDURE ADMPSS_CONPLANREN(K_SEGMENTO    IN VARCHAR2,
                              K_PERIODO     IN VARCHAR2,
                              CURSORPLANSEG out SYS_REFCURSOR);
  PROCEDURE ADMPSS_CONEQUREN(K_SEGMENTO     IN VARCHAR2,
                             K_PERIODO      IN VARCHAR2,
                             K_PLAN         IN NUMBER,
                             CURSOREQUIPSEG out SYS_REFCURSOR);
  PROCEDURE ADMPSS_CONBONREN(K_SEGMENTO IN VARCHAR2,
                             K_PERIODO  IN VARCHAR2,
                             K_PLAN     IN NUMBER,
                             K_EQUIPO   IN VARCHAR2,
                             K_BONMONTO OUT NUMBER,
                             K_BONPUNTO OUT NUMBER);
  PROCEDURE ADMPSS_DELBONREN(K_SEGMENTO IN VARCHAR2,
                             K_PERIODO  IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DSCERROR OUT VARCHAR2);
  PROCEDURE ADMPSS_REGBONREN(K_SEGMENTO IN VARCHAR2,
                             K_PERIODO  IN VARCHAR2,
                             K_PLAN     IN NUMBER,
                             K_EQUIPO   IN VARCHAR2,
                             K_BONMONTO IN NUMBER,
                             K_USUARIO  IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DSCERROR OUT VARCHAR2);
  PROCEDURE ADMPSS_CONBONBIE(K_TELEFONO IN VARCHAR2,
                             K_ESTADO   OUT VARCHAR2,
                             K_FECENT   OUT DATE);
  PROCEDURE ADMPSS_REPCANJE(K_COD_CLIENTE     IN CHAR,
                            K_FCH_INICIO      IN DATE,
                            K_FCH_FIN         IN DATE,
                            CURSORREPORTCANJE OUT SYS_REFCURSOR);
  PROCEDURE LISTADO_SEGMENTOS(CURSOR_SALIDA OUT K_REF_CURSOR);
  PROCEDURE LISTADO_PERIODOS(CURSOR_SALIDA OUT K_REF_CURSOR);
  PROCEDURE ADMPSS_REGTABLETEMP(P_COUNT  IN INTEGER,
                                P_INSERT IN VARCHAR2,
                                P_RETURN OUT VARCHAR2,
                                P_MSGERR OUT VARCHAR2);
                                /*
  PROCEDURE ADMPSS_PROCTABLETEMP(P_COUNTCOLUMN IN INTEGER,
                                 P_SEGMENTO    IN VARCHAR2,
                                 P_PERIODO     IN VARCHAR2,
                                 P_USUARIO     IN VARCHAR2,
                                 P_RETURN      OUT VARCHAR2,
                                 P_MSGERR      OUT VARCHAR2);
*/
  /*PROCEDURE ADMPSS_CONSBONOS(P_SEGMENTO IN VARCHAR2,P_PERIODO IN VARCHAR2,
  P_RETURN OUT VARCHAR2,P_MSGERR OUT VARCHAR2,CURSOR_SALIDA OUT K_REF_CURSOR);*/

 PROCEDURE ADMPSS_TIPPRE(K_CUR_LISTA OUT SYS_REFCURSOR);

  PROCEDURE ADMPSS_GRUPTIPPRE(K_CUR_LISTA OUT SYS_REFCURSOR);

 PROCEDURE ADMPSS_VALIDASALDOKDX(
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER
 );

 FUNCTION SPLITCAD(p_in_string VARCHAR2, p_delim VARCHAR2) RETURN tab_array;

 PROCEDURE ADMPSS_ACTCANJE(K_IDCANJE        IN VARCHAR2,
                            K_LISTA_IDPROCLA IN VARCHAR2,
                            K_LISTA_CODTXPAQ IN VARCHAR2,
                            K_MSJSMS         IN VARCHAR2,
                            K_EXITO          OUT NUMBER,
                            K_CODERROR       OUT NUMBER,
                            K_DESCERROR      OUT VARCHAR2);

 PROCEDURE ADMPSS_ELIMINARCANJE(K_IDCANJE   IN VARCHAR2,
                                 K_EXITO     OUT NUMBER,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPSS_VALIDA_DEVOLUCION(K_COD_CLIENTE IN VARCHAR2,
                                   K_ID_CANJE    IN VARCHAR2,
                                   K_FECHA_DEVOL IN DATE,
                                   K_EXITO     OUT NUMBER,
                                   K_CODERROR  OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPSS_ACT_INTERACT(k_idcanje    IN VARCHAR2,
                               k_id_inter  IN VARCHAR2,
                               k_exito     OUT NUMBER,
                               k_coderror  OUT NUMBER,
                               k_descerror OUT VARCHAR2);

 PROCEDURE ADMPSS_PRODUCTOSCANJE_MV(K_TIPDOC IN VARCHAR2,
                                   K_NUMDOC IN VARCHAR2,
                                   K_TIPCLIE IN VARCHAR2,
                                   K_FECINI IN VARCHAR2,
                                   K_FECFIN IN VARCHAR2,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2,
                                   CUR_CANJE OUT SYS_REFCURSOR);

 PROCEDURE ADMPSS_CONSTANCIACANJE_MV(K_IDCANJE IN NUMBER,
                                    K_CTO_ATEN OUT VARCHAR2,
                                    K_TIP_DOC OUT VARCHAR2,
                                    K_NUM_DOC OUT VARCHAR2,
                                    K_FEC OUT VARCHAR2,
                                    K_CSO_INT OUT VARCHAR2,
                                    K_NOTAS OUT VARCHAR2,
                                    K_NOMBRE OUT VARCHAR2,
                                    K_TIPCLIE OUT VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2,
                                    CUR_CANJE OUT SYS_REFCURSOR);

 FUNCTION F_OBTENERTIPODOC(K_TIPO_DOC IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION F_OBTENER_TBCLIENTE(K_TIPCLIE IN VARCHAR2) RETURN VARCHAR2;

 PROCEDURE ADMPI_BLOQUEOBOLSA(K_TIPO_DOC IN VARCHAR2,
                               K_NUM_DOC IN VARCHAR2,
                               K_TIPO_CLIE IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_ESTADO OUT CHAR,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC IN VARCHAR2,
                                  K_NUM_DOC IN VARCHAR2,
                                  K_TIPO_CLIE IN VARCHAR2,
                                  --K_USUARIO IN VARCHAR2,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC IN VARCHAR2,
                                  K_NUM_DOC IN VARCHAR2,
                                  K_TIPO_CLIE IN VARCHAR2,
                                  K_TIPO_DOC2 OUT VARCHAR2,
                                  K_ESTADO OUT CHAR,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_VALIDA_CANJEPTOS(K_TIPO_DOC    IN VARCHAR2,
                                    K_NUM_DOC     IN VARCHAR2,
                                    K_COD_CLIENTE IN VARCHAR2,
                                    K_TIP_CLI     IN VARCHAR2,
                                    K_TIPCANJE    IN NUMBER,
                                    K_TIPPRECANJE IN NUMBER,
                                    K_PTOS_TOT    IN NUMBER,
                                    K_SALDOPTO    OUT NUMBER,
                                    K_CODERROR    OUT NUMBER,
                                    K_MSJERROR    OUT VARCHAR2);
	PROCEDURE ADMPU_ACT_MASIVA(Tx_CODE   IN VARCHAR2,
                           K_USUARIO   IN VARCHAR2,
                           K_CODERROR  OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2,
                           K_TOT_REG   OUT NUMBER,
                           K_TOT_PRO   OUT NUMBER,
                           K_TOT_ERR   OUT NUMBER);

 PROCEDURE ADMPU_ACT_DATOSCLIE( K_TIPCLIENTE IN VARCHAR2,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_NUM_DOC IN VARCHAR2,
                               K_TIPODOC IN VARCHAR2,
                               K_FIRST_NAME IN VARCHAR2,
                               K_LAST_NAME IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

  procedure ADMPSI_VALIDA_CLIENTE (K_TIP_CLIMOVFIJA  IN  NUMBER,
                                        K_COD_CLIENTE     IN  VARCHAR2,
                                        K_TIPO_DOC        IN  VARCHAR2,
                                        K_NUM_DOC         IN  VARCHAR2,
                                        K_TIP_CLI         IN  VARCHAR2,
                                        K_ES_CLIENTE      OUT NUMBER,
                                        K_CODERROR        OUT NUMBER,
                                        K_DESCERROR       OUT VARCHAR2);

PROCEDURE ADMPSS_ESTADOCTACC(K_TIPODOC IN VARCHAR2,
                              K_NRODOC IN VARCHAR2,
                              K_FECHAINI IN DATE,
                              K_FECHAFIN IN DATE,
                              CURSORESTADOCTA OUT SYS_REFCURSOR,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) ;


PROCEDURE ADMPSS_PAQUETES_CANJEADOS (PI_CODCLI IN VARCHAR2, --CUST_CODE O LINEA
                              PI_FECHAINI IN VARCHAR2,
                              PI_FECHAFIN IN VARCHAR2,
                              PO_DATOS OUT SYS_REFCURSOR,
                              PO_CODERROR  OUT NUMBER,
                              PO_DESERROR  OUT Varchar2);
							  
							  
                              
PROCEDURE ADMPSS_PAQ_DATOS_CANJEADOS (PI_LINEA IN VARCHAR2,
							  PI_FECHAINI IN VARCHAR2,
							  PI_FECHAFIN IN VARCHAR2, --dd/mm/yyyy
							  PO_DATOS OUT SYS_REFCURSOR,
							  PO_CODERROR  OUT NUMBER,
							  PO_DESERROR  OUT VARCHAR2);
							  
PROCEDURE ADMPSS_CANJPROD_EVEN (K_ID_SOLICITUD IN VARCHAR2,
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_PUNTOVENTA   IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_COD_APLI     IN VARCHAR2,
                            K_CLAVE        IN VARCHAR2,
                            K_KEYWORD       IN VARCHAR2,
                            K_NUM_LINEA    IN     VARCHAR2,
                            K_COD_ASESOR       IN     VARCHAR2,
                            K_NOM_ASESOR       IN     VARCHAR2,
                            K_TIPCANJE     IN NUMBER,
                            K_TIPPRECANJE  IN NUMBER,
                            K_MENSAJE      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_CANJE        OUT VARCHAR2);
             
  /*
'****************************************************************************************************************
'* Nombre SP : ADMPSS_CLIENTE_CLAROCLUB
'* Propósito : Este procedimiento retorna los datos de cliente CC (MOVIL Y FIJA).
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_TIP_DOC_CC      -- Tipo de documento de Cliente Claro Club
              PI_NUM_DOC         -- Numero de documento de Cliente Claro Club
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_CUR_CLI        -- Cursor con datos del cliente
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros, 
                                    2 no hay cliente, -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 28/10/2017 
'****************************************************************************************************************
*/

PROCEDURE ADMPSS_CLIENTE_CLAROCLUB
            (PI_TIP_DOC       IN VARCHAR2,
             PI_NUM_DOC       IN VARCHAR2,
             PO_CUR_CLI       OUT SYS_REFCURSOR,
             PO_COD_ERR       OUT VARCHAR2,
             PO_DES_ERR       OUT VARCHAR2);
							  
END;
/