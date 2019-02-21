CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_CANJE_CAMP IS

  procedure SYSFSI_CAMPANA(P_SYCAV_DESCRIPCION in VARCHAR2,
                           P_SYCAD_FEC_INICAMP in DATE,
                           P_SYCAD_FEC_FINCAMP in DATE,
                           P_SYCAV_USUARIO_REG in VARCHAR2,
                           o_resultado         out varchar2,
                           o_mensaje           out varchar2);

  procedure SYSFSS_CAMPANA(P_SYCAV_DESCRIPCION in VARCHAR2,
                           P_SYCAV_ESTADO      in VARCHAR2,
                           o_resultado         out varchar2,
                           o_mensaje           out varchar2,
                           o_cursor            out SYS_REFCURSOR);

  procedure SYSFSU_CAMPANA(P_SYCAN_IDENTIFICADOR in VARCHAR2,
                           P_SYCAV_DESCRIPCION   in VARCHAR2,
                           P_SYCAD_FEC_INICAMP   in DATE,
                           P_SYCAD_FEC_FINCAMP   in DATE,
                           P_SYCAV_USUARIO_MOD   in VARCHAR2,
                           o_resultado           out varchar2,
                           o_mensaje             out varchar2);

  procedure SYSFSI_EVENTO(P_SYCAN_IDENTIFICADOR in NUMBER,
                          P_SYEVV_DESCRIPCION   in VARCHAR2,
                          P_SYEVD_FECINI_EVENTO in DATE,
                          P_SYEVD_FECFIN_EVENTO in DATE,
                          P_SYEVV_PALABRA_CLAVE in VARCHAR2,
                          P_SYEVN_PUNTOSCLARO   in NUMBER,
                          P_SYEVN_MONTO_PAGO    in NUMBER,
                          P_SYEVV_USUARIO_REG   in VARCHAR2,
                          P_SYEVD_FEC_REG       in DATE,
                          P_SYEVV_USUARIO_MOD   in VARCHAR2,
                          P_SYEVD_FEC_MOD       in DATE,
                          P_ADMPV_ID_PROCLA     in VARCHAR2,
                          P_ADMPV_DESC          in VARCHAR2,
                          P_ADMPV_CAMPANA       in VARCHAR2,
                          o_resultado           out varchar2,
                          o_mensaje             out varchar2);

  procedure SYSFSS_EVENTO(P_SYEVV_DESCRIPCION   in VARCHAR2,
                          P_SYCAN_IDENTIFICADOR in NUMBER,
                          P_SYEVV_ESTADO        in VARCHAR2,
                          o_resultado           out varchar2,
                          o_mensaje             out varchar2,
                          o_cursor              out SYS_REFCURSOR);

  procedure SYSFSU_EVENTO(P_SYEVN_IDENTIFICADOR in NUMBER,
                          P_SYCAN_IDENTIFICADOR in NUMBER,
                          P_SYEVV_DESCRIPCION   in VARCHAR2,
                          P_SYEVD_FECINI_EVENTO in DATE,
                          P_SYEVD_FECFIN_EVENTO in DATE,
                          P_SYEVV_PALABRA_CLAVE in VARCHAR2,
                          P_SYEVN_PUNTOSCLARO   in NUMBER,
                          P_SYEVN_MONTO_PAGO    in NUMBER,
                          P_SYEVV_USUARIO_REG   in VARCHAR2,
                          P_SYEVD_FEC_REG       in DATE,
                          P_SYEVV_USUARIO_MOD   in VARCHAR2,
                          P_SYEVD_FEC_MOD       in DATE,
                          P_ADMPV_DESC          in VARCHAR2,
                          P_ADMPV_CAMPANA       in VARCHAR2,
                          o_resultado           out varchar2,
                          o_mensaje             out varchar2);

  procedure SYSFSI_COD_CANJE(P_SYEVN_IDENTIFICADOR in NUMBER,
                             P_SYCCC_ESTADO        in VARCHAR2,
                             P_SYCCV_CODIGO_CANJE  in VARCHAR2,
                             P_SYCCV_USUARIO_REG   in VARCHAR2,
                             o_resultado           out varchar2,
                             o_mensaje             out varchar2);

  procedure SYSFSS_COD_CANJE(P_SYCCV_CODIGO_CANJE in VARCHAR2,
                             P_SYCCV_LINEA        in VARCHAR2,
                             P_SYCCC_ESTADO       in VARCHAR2,
                             P_FEC_VIGENCIA       in DATE,
                             o_resultado          out varchar2,
                             o_mensaje            out varchar2,
                             o_cursor             out SYS_REFCURSOR);                                                                                 

  

  PROCEDURE SYSFSU_COD_CANJE(K_EVENTO        IN NUMBER,
                             K_USUARIO_MOD   IN VARCHAR2,
                             K_DESC_TIPODOC  IN VARCHAR2,
                             K_NUMDOC        IN VARCHAR2,
                             K_NOMBRE_TIT    IN VARCHAR2,
                             K_LINEA         IN VARCHAR2,
                             K_TIPO_PROD     IN VARCHAR2,
                             K_IDCANJE       IN VARCHAR2,
                             K_COD_CANJE     OUT VARCHAR2,
                             K_FECFIN_EVENTO OUT VARCHAR2,
                             o_resultado     OUT VARCHAR2,
                             o_mensaje       OUT VARCHAR2);

  PROCEDURE SYSFSS_OBTENER_PUNTOS(P_PALABRA_CLAVE        in VARCHAR2,
                                  o_IDENTIFICADOR_EVENTO out NUMBER,
                                  o_PUNTOSCLARO          out NUMBER,
                                  o_MONTO_PAGO           out NUMBER,
                                  o_ID_PROCLA            out varchar2,
                                  o_DESC_PREMIO          out varchar2,
                                  o_FEC_CAMPANA          out varchar2,
                                  o_DESC_EVENTO          out varchar2,
                                  o_resultado            out varchar2,
                                  o_mensaje              out varchar2);

END;
/