create or replace package pclub.PKG_CC_AFILIACIONES is

FUNCTION VAL_CLIENTE_IBK(K_ADMPV_TIPO_DOC   IN PCLUB.ADMPT_CLIENTEIB.ADMPV_TIPO_DOC%TYPE,
                         K_ADMPV_NUM_DOC    IN PCLUB.ADMPT_CLIENTEIB.ADMPV_NUM_DOC%TYPE,
                         K_ADMPN_COD_CLI_IB OUT PCLUB.ADMPT_CLIENTEIB.ADMPN_COD_CLI_IB%TYPE)
RETURN NUMBER;

FUNCTION VAL_EXISTE_AFILIACION(K_ADMPN_COD_CLI_IB IN PCLUB.ADMPT_CLIENTEIB.ADMPN_COD_CLI_IB%TYPE,
                               K_ADMPV_COD_CLI    IN PCLUB.ADMPT_CLIENTEIB.ADMPV_COD_CLI%TYPE,
                               K_ADMPV_NUM_LINEA  IN PCLUB.ADMPT_CLIENTEIB.ADMPV_NUM_LINEA%TYPE,
                               K_TIPO_LINEA       IN PCLUB.ADMPT_CLIENTEIB.ADMPV_TIPO_DOC%TYPE)
RETURN NUMBER;

FUNCTION VAL_EXISTE_CLARO_CLUB(K_ADMPV_NUM_DOC  IN PCLUB.ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE,
                               K_ADMPV_TIPO_DOC IN PCLUB.ADMPT_CLIENTE.ADMPV_TIPO_DOC%TYPE,
                               K_ADMPV_COD_CLI  IN PCLUB.ADMPT_CLIENTE.ADMPV_COD_CLI%TYPE)
RETURN NUMBER;

FUNCTION VAL_EXISTE_BONO(K_ADMPN_COD_CLI_IB IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_COD_CLI_IB%TYPE)
RETURN NUMBER;

PROCEDURE ADMPSS_PROCESAR_AFILIACION(K_ADMPV_TIPO_DOC  IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TIPO_DOC%TYPE,
                                     K_ADMPV_NUM_DOC   IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_DOC%TYPE,
                                     K_ADMPV_NUM_LINEA IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA%TYPE,
                                     K_ADMPN_SN_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SN_CODE%TYPE,
                                     K_ADMPN_SP_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SP_CODE%TYPE,
                                     K_ADMPV_MENSAJE IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_MENSAJE%TYPE,
                                     K_ADMPV_USU_REG IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_REG%TYPE,
                                     K_ADMPV_USU_MOD IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_MOD%TYPE,
                                     K_ADMPV_COD_CLI IN VARCHAR2,
                                     K_ADMPV_TPO_CLI IN VARCHAR2,
                                     K_COID          IN VARCHAR2,
                                     K_ESTADOLINEA   IN VARCHAR2,
                                     K_CICLOFACT     IN VARCHAR2,
                                     K_EXITOTRANS    OUT NUMBER,
                                     K_CODERROR      OUT NUMBER,
                                     K_DESCERROR     OUT VARCHAR2);

procedure ADMPSI_VALIDATRIOS(K_COID      IN VARCHAR2,
                             K_VALOR     OUT NUMBER,
                             K_CODERROR  OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_REGAFILIACION(K_ADMPV_TIPO_DOC       IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TIPO_DOC%TYPE,
                                 K_ADMPV_NUM_DOC        IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_DOC%TYPE,
                                 K_ADMPV_NUM_LINEA      IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA%TYPE,
                                 K_ADMPC_ESTADO_BONO    IN PCLUB.ADMPT_AFILIACIONTC.ADMPC_ESTADO_BONO%TYPE,
                                 K_ADMPD_FEC_ENTBON     IN PCLUB.ADMPT_AFILIACIONTC.ADMPD_FEC_ENTBON%TYPE,
                                 K_ADMPD_FEC_AFILIA     IN PCLUB.ADMPT_AFILIACIONTC.ADMPD_FEC_AFILIA%TYPE,
                                 K_ADMPV_TPOLINEA       IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TPOLINEA%TYPE,
                                 K_ADMPN_COD_CLI_IB     IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_COD_CLI_IB%TYPE,
                                 K_ADMPN_SN_CODE        IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SN_CODE%TYPE,
                                 K_ADMPN_SP_CODE        IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SP_CODE%TYPE,
                                 K_ADMPV_MENSAJE        IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_MENSAJE%TYPE,
                                 K_ADMPV_USU_REG        IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_REG%TYPE,
                                 K_ADMPV_NUM_LINEA_BONO IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA_BONO%TYPE,
                                 K_EXITOTRANS           OUT NUMBER,
                                 K_CODERROR             OUT NUMBER,
                                 K_DESCERROR            OUT VARCHAR2);
                                 

procedure CORREGIR_AFILIACION_POSTPAGO(K_PARAM IN VARCHAR2);

procedure CORREGIR_AFILIACION_PREPAGO(K_PARAM IN VARCHAR2);

procedure CORREGIR_ALINEACION_PCLUB(FECHAPROCESO VARCHAR2);

procedure TXTReactivacionRenovacion(k_fecha in date,k_cursor out sys_refcursor);

PROCEDURE PROCESAR_AFILIACION_PREPAGO(K_ADMPV_TIPO_DOC  IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TIPO_DOC%TYPE,
                                     K_ADMPV_NUM_DOC   IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_DOC%TYPE,
                                     K_ADMPV_NUM_LINEA IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA%TYPE,
                                     K_ADMPN_SN_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SN_CODE%TYPE,
                                     K_ADMPN_SP_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SP_CODE%TYPE,
                                     K_ADMPV_MENSAJE IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_MENSAJE%TYPE,
                                     K_ADMPV_USU_REG IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_REG%TYPE,
                                     K_ADMPV_USU_MOD IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_MOD%TYPE,
                                     K_ADMPV_COD_CLI IN VARCHAR2,
                                     K_ADMPV_TPO_CLI IN VARCHAR2,
                                     K_COID          IN VARCHAR2,
                                     K_ESTADOLINEA   IN VARCHAR2,
                                     K_CICLOFACT     IN VARCHAR2,
                                     K_EXITOTRANS    OUT NUMBER,
                                     K_CODERROR      OUT NUMBER,
                                     K_DESCERROR     OUT VARCHAR2);


PROCEDURE ADMPSI_ALTACLIC_PREPAGO (K_FECHA IN DATE,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
end PKG_CC_AFILIACIONES;
/