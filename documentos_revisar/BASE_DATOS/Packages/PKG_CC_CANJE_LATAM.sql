CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_CANJE_LATAM IS



PROCEDURE SYSFSS_EQUI_CC_KM
            (PI_TIP_PTO      in VARCHAR2,
             PI_PTOS         in NUMBER,
             PO_PTOS_EQUI    out NUMBER,
             PO_PTOS_CANJE   out NUMBER,
             PO_PTOS_RETORNO out NUMBER,
             PO_COD_ERR      out varchar2,
             PO_DES_ERR      out varchar2);
             
PROCEDURE SYSFSI_SOCIO_LATAM
            (PI_IDSOCIO_LATAM in VARCHAR2,
             PI_DIG_VERIFICA  in VARCHAR2,
             PI_APE_SOCIO     in VARCHAR2,
             PI_NOM_SOCIO     in VARCHAR2,
             PI_TIPDOC_LATAM  in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PI_USU_REG       in VARCHAR2,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2);
             
PROCEDURE SYSFSS_SOCIO_LATAM
            (PI_TIP_DOC  in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PO_CUR_SOCIO     out SYS_REFCURSOR,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2);
             
PROCEDURE SYSFSI_CANJE_KMLATAMCC
            (PI_TIP_CANJE     in VARCHAR2,
             PI_TIP_DOC_CC    in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PI_LINEA         in VARCHAR2,
             PI_CORREO        in VARCHAR2,
             PI_PTOS_CC       in NUMBER,
             PI_KM_LATAM      in NUMBER,
             PI_GRP_CANJE     IN NUMBER,
             PI_USU_REG       in VARCHAR2,
             PI_COD_APLI      in VARCHAR2,
             PI_ESTADO_REG    in VARCHAR2,
             PI_ID_SOCIO      IN VARCHAR2,
             PI_NOM_SOC       IN VARCHAR2,
             PI_APE_SOC       IN VARCHAR2,
             PI_COD_RESP      IN VARCHAR2,
             PI_MSG_RESP      IN VARCHAR2,
             PI_ID_TRANS      IN VARCHAR2,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2);



PROCEDURE SYSFSS_VAL_SOL_CANJE
            (PI_TIP_CANJE     in VARCHAR2,
             PI_TIP_DOC_CC    in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PI_PTOS          in VARCHAR2,
             PI_FECHA         in DATE,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2);

PROCEDURE SYSFSU_LOTE_CANJE
            (PI_TIP_PROC      IN VARCHAR2,
             PI_ID_LOTE       in NUMBER,
             PI_CANT_REG      in NUMBER,
             PI_ESTADO        in VARCHAR2,
             PI_USU_REG       in VARCHAR2,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2);

PROCEDURE SYSFSU_CANJE_KMLATAMCC
            (PI_ACCOUNT_NUM       in VARCHAR2,
             PI_EST_ERR           in VARCHAR2,
             PI_COD_ERR           in VARCHAR2,
             PI_USU_REG           in VARCHAR2,
             PO_LINEA             OUT VARCHAR2,
             PO_CORREO            OUT VARCHAR2,
             PO_COD_APLI          OUT VARCHAR2,
             PO_PTO_CC            OUT NUMBER,
             PO_KM_LATAM          OUT NUMBER,
             PO_COD_ERR           out varchar2,
             PO_DES_ERR           out varchar2);

PROCEDURE SYSFSS_CANJES_PENDIENTES
            (PI_ID_LOTE           in NUMBER,
             PI_NOM_ARCH          in VARCHAR2,
             PI_USUARIO           IN VARCHAR2,
             PO_ID_LOTE           OUT NUMBER,
             PO_REC_TYPE          OUT VARCHAR2,
             PO_COMPANY_ID        OUT VARCHAR2,
             PO_FILE_ID           OUT VARCHAR2,
             PO_CREATE_DATE       OUT VARCHAR2,
             PO_CUR_REG_PEND      out SYS_REFCURSOR,
             PO_COD_ERR           out VARCHAR2,
             PO_DES_ERR           out VARCHAR2);

PROCEDURE SYSFSS_CANJES_TODOS
            (PI_TIP_CANJE         in VARCHAR2,
             PI_LINEA             in VARCHAR2,
             PI_CORREO            in VARCHAR2,
             PI_FEC_INI           in DATE,
             PI_FEC_FIN           in DATE,
             PI_ESTADO            in VARCHAR2,
             PI_TIP_DOC           in VARCHAR2,
             PI_NUM_DOC           IN VARCHAR2,
             PI_COD_APLI          IN VARCHAR2,
             PI_NOMBRE_ARCHIVO    IN VARCHAR2,
             PI_ESTADO_CANJE      IN VARCHAR2,
             PO_CUR_REG           out SYS_REFCURSOR,
             PO_COD_ERR           out varchar2,
             PO_DES_ERR           out varchar2);
             
PROCEDURE SYSFSS_PTOS_ACUM_CLI
            (PI_TIP_DOC           in VARCHAR2,
             PI_NUM_DOC           IN VARCHAR2,
             PO_PUNTOS            out NUMBER,
             PO_COD_ERR           out varchar2,
             PO_DES_ERR           out varchar2);

PROCEDURE SYSFSD_CANJE_MLATAMCC(
             PI_IDCANJE  IN NUMBER,
             PI_USUARIO  IN VARCHAR2,
             PO_COD_ERR  OUT varchar2,
             PO_DES_ERR  OUT varchar2);           
             
PROCEDURE SYSFSS_CANJPROD_KMLATAMCC (
             K_ID_SOLICITUD IN VARCHAR2,
             K_TIPO_DOC     IN VARCHAR2,
             K_NUM_DOC      IN VARCHAR2,
             K_PUNTOS       IN NUMBER,
             K_COD_APLI     IN VARCHAR2,
             K_NUM_LINEA    IN     VARCHAR2,
             K_COD_ASESOR   IN     VARCHAR2,
             K_NOM_ASESOR   IN     VARCHAR2,
             K_MENSAJE      IN VARCHAR2,
             PI_USUARIO     IN VARCHAR2,
             K_CODERROR     OUT NUMBER,
             K_MSJERROR     OUT VARCHAR2,
             K_GRP_CANJE    OUT NUMBER);
             
 PROCEDURE SYSFSS_COD_CANJE_KMLATAMCC(
             K_IDCANJE       IN VARCHAR2,
             o_resultado     OUT VARCHAR2,
             o_mensaje       OUT VARCHAR2);
 
 PROCEDURE SYSFI_ACREDITAR_PUNTOS_CC(PI_TIPO_TRANS  IN CHAR,
                                    PI_TIPO_ACRE   IN VARCHAR2,
                                    PI_COD_CLI      IN VARCHAR2,
                                    PI_TIPO_DOC     IN VARCHAR2,
                                    PI_NUM_DOC      IN VARCHAR2,
                                    PI_PUNTOS_CC    IN NUMBER,
                                    PI_COD_CONCEPTO IN VARCHAR2,
                                    PI_USU_REG      IN VARCHAR2,
                                    PO_COD_ERR      OUT NUMBER,
                                    PO_DES_ERR      OUT VARCHAR2,
                                    PO_ID_KARDEX    OUT NUMBER);

 PROCEDURE SYSFS_CODIGO_CLIENTE(
           PI_TBL_CLI           IN VARCHAR2,
           PI_TIP_CLI           IN VARCHAR2,
           PI_TIP_DOC           IN VARCHAR2,
           PI_NUM_DOC           IN VARCHAR2,
           PO_COD_CLI           OUT VARCHAR2,
           PO_COD_ERR           OUT VARCHAR2,
           PO_DES_ERR           OUT VARCHAR2);

 PROCEDURE SYSFS_PTOS_X_CLIENTE(
           PI_TIP_CLI           IN VARCHAR2,
           PO_COD_CLI           IN VARCHAR2,
           PI_TIP_DOC           IN VARCHAR2,
           PI_NUM_DOC           IN VARCHAR2,
           PO_SALDO             OUT NUMBER,
           PO_COD_ERR           OUT VARCHAR2,
           PO_DES_ERR           OUT VARCHAR2);
 
 PROCEDURE SYSFI_ROLBK_ACRE_PTOS_CC(
           PI_TIPO_ACRE    IN VARCHAR2,
           PI_ID_KARDEX    IN NUMBER,
           PO_COD_ERR      OUT NUMBER,
           PO_DES_ERR      OUT VARCHAR2);

PROCEDURE SYSFSD_CANJE_MLATAMCC_FALLO(
             PI_IDGRP  IN NUMBER,
             PI_USUARIO  IN VARCHAR2,
             PO_COD_ERR  OUT varchar2,
             PO_DES_ERR  OUT varchar2);
             
PROCEDURE ADMPSI_DESC_PTOS_BONO(K_ID_CANJE    NUMBER,
                                  K_SEC         NUMBER,
                                  K_PUNTOS      NUMBER,
                                  K_COD_CLIENTE IN VARCHAR2,
                                  K_TIP_CLI     IN VARCHAR2,
                                  K_GRUPO       IN NUMBER,
                                  K_COD_CPTO      IN VARCHAR2,
                                  K_IDKARDEX    OUT NUMBER,
                                  K_CODERROR    OUT NUMBER,
                                  K_MSJERROR    OUT VARCHAR2);
                                  
procedure ADMPSI_DESC_PUNTOS(K_ID_CANJE    NUMBER,
                               K_SEC         NUMBER,
                               K_PUNTOS      NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_COD_CPTO      IN VARCHAR2,
                               K_IDKARDEX    OUT NUMBER,
                               K_CODERROR    OUT NUMBER,
                               K_MSJERROR    OUT VARCHAR2);
                               
PROCEDURE ADMPSI_DESC_PUNTOS_FIJA( K_ID_CANJE    IN NUMBER,
                               K_SEC         IN NUMBER,
                               K_PUNTOS      IN NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_USUARIO     IN VARCHAR2,
                               K_COD_CPTO      IN VARCHAR2,
                               K_IDGRP       IN NUMBER,
                               K_ITEMGRP_I   IN NUMBER,
                               K_TIPO        IN VARCHAR2,
                               K_TBLCLIENTE  IN VARCHAR2,
                               K_ITEMGRP_O   OUT NUMBER,
                               K_CODERROR    OUT NUMBER,
                               K_DESCERROR   OUT VARCHAR2);
                                     
PROCEDURE SYSFSS_VALIDASALDOKDX(K_COD_CLIENTE  IN VARCHAR2,
                                K_TIP_CLI      IN VARCHAR2,
                                K_CODERROR     OUT NUMBER);

PROCEDURE SYSFSI_CANJE_CAMP(PI_LINEA              in VARCHAR2,
                            PI_CORREO             in VARCHAR2,
                            PI_TIP_REG_LATAM      in VARCHAR2,
                            PI_ID_PROG_LATAM      in VARCHAR2,
                            PI_FEC_CANJE          in DATE,
                            PI_KM_LATAM           in NUMBER,
                            PI_NOM_CLI            in VARCHAR2,
                            PI_ID_SOCIO_LATAM     in VARCHAR2,
                            PI_CORRELATIVO        in VARCHAR2,
                            PI_COD_APLI           in VARCHAR2,
                            PI_TIPO_CANJE         in VARCHAR2,
                            PI_ESTADO_REG         in VARCHAR2,
                            PI_ESTADO_CANJE_LATAM in VARCHAR2,
                            PI_COD_ERR_LATAM      in VARCHAR2,
                            PI_USU_REG            in VARCHAR2,
                            PI_COD_RESP           in VARCHAR2,
                            PI_MSG_RESP           in VARCHAR2,
                            PI_ID_TRANS           in VARCHAR2,
                            PI_TIPO_DOC           in VARCHAR2,
                            PI_NUM_DOC            in VARCHAR2,
                            PI_NOM_ARCHIVO        in VARCHAR2,
                            PO_COD_ERR            out VARCHAR2,
                            PO_DES_ERR            out VARCHAR2,
                            PO_ID_CANJE           out NUMBER);

PROCEDURE SYSFSS_DATOS_CANJE(PI_ID_CANJE   IN NUMBER,                       
                       PO_COD_ERR    OUT VARCHAR2,
                       PO_DES_ERR    OUT VARCHAR2,
                       PO_LINEA      OUT VARCHAR2,
                       PO_CORREO     OUT VARCHAR2,
                       PO_COD_APLI   OUT VARCHAR2,
                       PO_PTO_CC     OUT NUMBER,
                       PO_KM_LATAM   OUT NUMBER,
                       PO_TIPO_CANJE OUT VARCHAR2,
                       PO_ID_PROG_LATAM OUT VARCHAR2,
                       PO_ID_SOCIO   OUT VARCHAR2);
                       
PROCEDURE SYSFSS_CANJES_PEND_CAMP
            (PI_ID_LOTE           IN NUMBER,
             PI_NOM_ARCH          IN VARCHAR2,
             PI_USUARIO           IN VARCHAR2,
             PI_TIPO_CANJE        IN VARCHAR2,
             PO_ID_LOTE           OUT NUMBER,
             PO_REC_TYPE          OUT VARCHAR2,
             PO_COMPANY_ID        OUT VARCHAR2,
             PO_FILE_ID           OUT VARCHAR2,
             PO_CREATE_DATE       OUT VARCHAR2,
             PO_CUR_REG_PEND      OUT SYS_REFCURSOR,
             PO_COD_ERR           OUT VARCHAR2,
             PO_DES_ERR           OUT VARCHAR2); 
             
PROCEDURE SYSFSI_VENTA_CAMP(PI_LINEA        IN VARCHAR2,
                       PI_DOCUMENTO         IN VARCHAR2,
                       PI_PLAN_TARIFA_COD   IN VARCHAR2,
                       PI_PLAN_TARIFA_DESC  IN VARCHAR2,
                       PI_TIPO_OPERACION    IN VARCHAR2,
                       PI_EQUIPO_COD        IN VARCHAR2,
                       PI_EQUIPO_DESC       IN VARCHAR2,
                       PI_FEC_VENTA         IN VARCHAR2,
                       PI_FEC_ACTIVACION    IN VARCHAR2,
                       PI_CAMPANA_COD       IN VARCHAR2,
                       PI_CAMPANA_DESC      IN VARCHAR2,
                       PI_LISTA_PRECIO      IN VARCHAR2,
                       PI_PRECIO_EQUIPO     IN VARCHAR2,
                       PI_REGION_ACTIV      IN VARCHAR2,
                       PI_DEP_ACTIV         IN VARCHAR2,
                       PI_CUSTOMERID        IN VARCHAR2,
                       PI_COID              IN VARCHAR2,
                       PI_NOMBRE_CLIENTE    IN VARCHAR2,
                       PI_USU_REG           IN VARCHAR2,
                       PI_ID_CAMPANA        IN NUMBER,
                       PI_APE_PAT           IN VARCHAR2,
                       PI_APE_MAT           IN VARCHAR2,
                       PI_TIP_DOC           IN VARCHAR2,
                       PI_FEC_NAC           IN DATE,
                       PI_GENERO            IN CHAR,
                       PI_EMAIL             IN VARCHAR2,
                       PI_PAIS_RESID        IN VARCHAR2,
                       PO_COD_ERR           out VARCHAR2,
                       PO_DES_ERR           out VARCHAR2,
                       PO_CANT_MILLAS       out NUMBER);
                       
PROCEDURE SYSFSU_EVALUAR_REG_VENCE_CAMP (
             PO_COD_ERR      out varchar2,
             PO_DES_ERR      out varchar2,
             PO_CUR_VENCIDO  out SYS_REFCURSOR);             

PROCEDURE SYSFSS_SOCIO_LATAM_REPORTE(PI_TIP_DOC_LATAM  in VARCHAR2,
                                     PI_NUM_DOC        in VARCHAR2,
                                     PI_ID_SOCIO_LATAM in VARCHAR2,
                                     PI_NOM_SOC        in VARCHAR2,
                                     PI_FEC_REG_INI    in DATE,
                                     PI_FEC_REG_FIN    in DATE,
                                     PO_CUR_SOCIO      out SYS_REFCURSOR,
                                     PO_COD_ERR        out VARCHAR2,
                                     PO_DES_ERR        out VARCHAR2);   
                                    
PROCEDURE SYSFSD_KRDX_MLATAMCC_FALLO(PI_KARDEX       IN VARCHAR2,
                                     PI_TPOCL        IN VARCHAR2,
                                     PI_USUARIO     IN VARCHAR2,
                                     PO_KARDEX       OUT VARCHAR2,
                                     PO_COD_ERR      OUT NUMBER,
                                     PO_DES_ERR    OUT VARCHAR2);          

PROCEDURE SYSFSS_CANJE_SOCIOS_PEND(PI_USUARIO      IN VARCHAR2,
                                   PI_TIPO_CANJE   IN VARCHAR2,
                                   PO_COD_ERR      OUT varchar2,
                                   PO_DES_ERR      OUT varchar2,
                                   PO_ID_LOTE      OUT NUMBER,
                                   PO_CUR_REG_PEND OUT SYS_REFCURSOR);

PROCEDURE SYSFSU_CANJE_SOCIO(PI_TIPO_DOC      IN VARCHAR2,
                             PI_NUM_DOC       IN VARCHAR2,
                             PI_EST_REG_SOC   IN VARCHAR2,
                             PI_EST_CANJE     IN VARCHAR2,
                             PI_COD_ERR_LATAM IN VARCHAR2,
                             PI_USUARIO       IN VARCHAR2,
                             PI_TIPO_CANJE    IN VARCHAR2,
                             PI_ID_SOCIO      IN VARCHAR2,
                             PI_DESC_ERR_LATAM IN VARCHAR2,
                             PO_COD_ERR       OUT VARCHAR2,
                             PO_DES_ERR       OUT VARCHAR2);

PROCEDURE SYSFSU_LOTE_CANJE_SOCIO(PI_ID_LOTE     IN NUMBER,
                                  PI_EST_REG_SOC IN VARCHAR2,
                                  PI_USUARIO     IN VARCHAR2,
                                  PO_COD_ERR     OUT VARCHAR2,
                                  PO_DES_ERR     OUT VARCHAR2);
END PKG_CC_CANJE_LATAM;
/