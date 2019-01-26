CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_PROMOCION is


TYPE SYS_REFCURSOR IS REF CURSOR;
TYPE K_REF_CURSOR IS REF CURSOR;
TYPE VAR_CURPREMIOS IS REF CURSOR;

            
--funciones
FUNCTION ADMFF_TIPODOC(K_ADMPV_TIPO_DOC IN ADMPT_CLIENTE.ADMPV_TIPO_DOC%TYPE,
                       K_ADMPV_NUM_DOC  IN ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE)
  RETURN NUMBER;

FUNCTION ADMFF_MOVIMIENTOS(K_ADMPV_TIPO_DOC IN ADMPT_CLIENTE.ADMPV_TIPO_DOC%TYPE,
                           K_ADMPV_NUM_DOC  IN ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE)
  RETURN NUMBER;

PROCEDURE ADMPSS_MOV_PROMOCION(K_ID_CANJE        IN VARCHAR2,
                               K_ADMPV_NUM_DOC   IN VARCHAR2,
                               K_ADMPV_TIPO_DOC  IN VARCHAR2,
                               K_ADMPN_ID_PROMO  IN NUMBER,
                               K_ADMPN_ID_RULETA IN VARCHAR2,
                               K_ADMPV_TPOLINEA  IN VARCHAR2,
                               K_ADMPV_ASESOR    IN VARCHAR2,
                               K_ADMPV_CAC       IN VARCHAR2,
                               K_ADMPV_NUM_LINEA IN VARCHAR2,
                               K_ADMPV_USUARIO   IN VARCHAR2,
                               K_ADMPV_COID      IN VARCHAR2,
                               K_EXITOTRANS      OUT NUMBER,
                               K_CODERROR        OUT NUMBER,
                               K_DESCERROR       OUT VARCHAR2);

--procedure afiliacion
PROCEDURE ADMPSS_OBTENER_IDRULETA(K_ADMPV_TIPO_DOC IN ADMPT_TIPO_DOC.ADMPV_EQU_DWH%TYPE,
                                  K_ADMPV_NUM_DOC  IN ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE,
                                  K_ADMPV_USUARIO  IN VARCHAR2,
                                  K_ID_CANJE       IN VARCHAR2,
                                  K_ADMPV_COID     IN VARCHAR2,
                                  K_ID_RULETA      OUT VARCHAR2,
                                  K_MENSAJE        OUT VARCHAR2,
                                  K_CODERROR       OUT NUMBER,
                                  K_DESCERROR      OUT VARCHAR2);

PROCEDURE ADMPSS_PROCESAR_PREMIO(K_ADMPV_ID_RULETA  IN VARCHAR2,
                                 K_ADMPN_ID_PREMIO  IN ADMPT_PREMIO_PROMO.ADMPN_ID_PREMIO%TYPE,
                                 K_ADMPV_USUARIO    IN VARCHAR2,
                                 K_ADMPV_NUM_LINEA  OUT VARCHAR2,
                                 K_ADMPV_TIPO_LINEA OUT VARCHAR2,
                                 K_ADMPN_MNRECARGA  OUT NUMBER,
                                 K_ADMPV_CODSERV    OUT VARCHAR2,
                                 K_ADMPV_ENV_SMS    OUT VARCHAR2,
                                 K_ADMPV_SMS_MSJ    OUT VARCHAR2,
                                 K_ADMPN_ID_TPREMIO OUT NUMBER,
                                 K_ADMPV_COID       OUT VARCHAR2,
                                 K_CODERROR         OUT NUMBER,
                                 K_DESCERROR        OUT VARCHAR2);

PROCEDURE ADMPSS_REVOKE_PREMIO(K_ADMPV_ID_RULETA IN VARCHAR2,
                               K_ADMPV_USUARIO   IN VARCHAR2,
                               K_CODERROR        OUT NUMBER,
                               K_DESCERROR       OUT VARCHAR2);

PROCEDURE ADMPSS_REVOKE_IDRULETA(K_ADMPV_ID_RULETA IN VARCHAR2,
                                 K_CODERROR        OUT NUMBER,
                                 K_DESCERROR       OUT VARCHAR2);

PROCEDURE ADMPSS_LISTAR_PREMIOS_PROMO(P_RESULTADO OUT K_REF_CURSOR);

--------------------------------------------------------------------
--------------------------------------------------------------------

PROCEDURE ADMPSS_VALIDARPROMOCION(K_ADMPN_ID_PROMO OUT NUMBER,
                                  K_CODERROR       OUT NUMBER,
                                  K_DESCERROR      OUT VARCHAR2);

PROCEDURE ADMPSS_STATUS_PROVINCIA(K_ADMPV_NUM_LINEA IN VARCHAR2,
                                  K_TIP_LINEA       IN VARCHAR2,
                                  K_USUARIOPROMO    OUT VARCHAR2,
                                  K_ESPROVINCIA     OUT NUMBER,
                                  K_CODERROR        OUT NUMBER,
                                  K_DESCERROR       OUT VARCHAR2);

PROCEDURE ADMPSS_GET_LINEA(   K_ADMPN_ALFANUMERICO IN  VARCHAR2
                           ,  K_ADMPN_ID_PROMO     IN  NUMBER 
                           ,  K_NUM_LINEA          OUT VARCHAR2
                           ,  K_TIP_LINEA          OUT VARCHAR2
                           ,  K_CODE_CONTRATO      OUT VARCHAR2
                           ,  K_CODERROR           OUT NUMBER
                           ,  K_DESCERROR          OUT VARCHAR2);

FUNCTION ADMPSS_EXISTE_MOVIMIENTO(K_ADMPN_ALFANUMERICO VARCHAR2,
                                  K_ADMPN_ID_PROMO     NUMBER)
  RETURN NUMBER;

PROCEDURE ADMPSS_GET_NOT_PREMIOS(K_ADMPV_ALFANUMERICO IN VARCHAR2,
                                 K_CURPREMIOS         OUT PKG_CC_PROMOCION.VAR_CURPREMIOS,
                                 K_USUARIOPROMO       OUT VARCHAR2,
                                 K_CODERROR           OUT NUMBER,
                                 K_DESCERROR          OUT VARCHAR2);



FUNCTION ADMFF_PREMIO_SERVICIO(K_ADMPN_ID_PROMO IN NUMBER,
                               K_CODIG_CONTRATO IN VARCHAR2)
  RETURN VARCHAR2;


  
END PKG_CC_PROMOCION;
/