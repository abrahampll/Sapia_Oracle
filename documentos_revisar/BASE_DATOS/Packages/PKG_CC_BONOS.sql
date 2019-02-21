CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_BONOS IS

PROCEDURE ADMPSI_ENTREGA_BONO(K_IDENT     IN NUMBER,
                              K_BONO      IN VARCHAR2,
                              K_LINEA     IN VARCHAR2,
                              K_USUARIO   IN VARCHAR2,
                              K_MSJSMS    OUT VARCHAR2,
                              K_CUR_BONO  OUT SYS_REFCURSOR,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_LINEA(K_BONO IN VARCHAR2,
                           K_IDENT IN NUMBER,
                           K_USUARIO   IN VARCHAR2,
                           K_NUM_LINEA  IN VARCHAR2,
                             K_PROC       IN NUMBER,
                           K_EXITOTRANS OUT NUMBER,
                           K_TIPDOC     OUT VARCHAR2,
                           K_NRODOC     OUT VARCHAR2,
                           K_CODERROR   OUT NUMBER,
                           K_DESCERROR  OUT VARCHAR2);

PROCEDURE ADMPSI_ENTREGA_PTOS(K_LINEA IN VARCHAR2,
                              K_CONCEPTO VARCHAR2,
                              K_PUNTOS VARCHAR2,
                              K_FECVENBONO IN DATE,
                              K_TIPPREMIO VARCHAR2,
                              K_NOMARCH IN VARCHAR2,
                              K_USUARIO IN VARCHAR2,
                              K_IDKARDEX OUT NUMBER,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_AFILXREC(K_NOMARCH IN VARCHAR2,
                          K_USUARIO IN VARCHAR2,
                          K_NUMREGTOT OUT NUMBER,
                          K_NUMREGVAL OUT NUMBER,
                          K_NUMREGERR OUT NUMBER,
                          K_CODERROR  OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSU_AFILXREC_VALIDA(K_NOMBARCH IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_TMP_AFILXREC(K_NOMBARCH IN VARCHAR2,
                              K_NUMREG OUT NUMBER,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_TMP_EAFILXREC(K_NOMARCH IN VARCHAR2,
                                    K_CUR_LISTA OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_OBT_CONFIG(K_BONO IN VARCHAR2,
                            K_IDENT IN NUMBER,
                            K_DESCBONO OUT VARCHAR2,
                            K_CODMSJSMS OUT VARCHAR2,
                            K_CUR_BONOCONFIG OUT SYS_REFCURSOR,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_BONO_KARDEX(K_KARDEX IN VARCHAR2,
                                 K_BONO IN VARCHAR2,
                                 K_LINEA IN VARCHAR2,
                                 K_FECENTBONO IN DATE,
                                 K_FECVENBONO IN DATE,
                                 K_PUNTOS IN NUMBER,
                                 K_DIAS IN NUMBER,
                                 K_TIPPREMIO IN VARCHAR2,
                                 K_TIPDOC IN VARCHAR2,
                                 K_NRODOC IN VARCHAR2,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSU_ENT_BONOFIDEL_VALIDA(K_TIPOFIDEL IN VARCHAR2,
                                      K_NOMBARCH IN VARCHAR2,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_ENTR_BONOFID6M(K_NOMARCH IN VARCHAR2,
                                K_BONO IN VARCHAR2,
                                K_USUARIO IN VARCHAR2,
                                K_NUMREGTOT OUT NUMBER,
                                K_NUMREGVAL OUT NUMBER,
                                K_NUMREGERR OUT NUMBER,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_ENTR_BONOFID6M_V(K_NOMARCH   IN VARCHAR2,
                                  K_BONO      IN VARCHAR2,
                                  K_USUARIO   IN VARCHAR2,
                                  K_NUMREGTOT OUT NUMBER,
                                  K_NUMREGVAL OUT NUMBER,
                                  K_NUMREGERR OUT NUMBER,
                                  K_CODERROR  OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_ENTR_BONOFID12M_V(K_NOM_ARCHIVO IN VARCHAR2,
                                   K_BONO        IN VARCHAR2,
                                   K_USUARIO     IN VARCHAR2,
                                   K_CODERROR    OUT NUMBER,
                                   K_DESCERROR   OUT VARCHAR2,
                                   K_TOT_PROC    OUT NUMBER,
                                   K_TOT_EXI     OUT NUMBER,
                                   K_TOT_ERR     OUT NUMBER);                                                                  

PROCEDURE ADMPSI_ENT_BONO_MASIVO(K_NOMARCH IN VARCHAR2,
                                 K_LINEA IN VARCHAR2,
                                 K_TIPDOC IN VARCHAR2,
                                 K_NRODOC IN VARCHAR2,
                                 K_NOMBRES IN VARCHAR2,
                                 K_APELLIDOS IN VARCHAR2,
                                 K_SEXO IN VARCHAR2,
                                 K_ESTADOCIVIL IN VARCHAR2,
                                 K_EMAIL IN VARCHAR2,
                                 K_DPTO IN VARCHAR2,
                                 K_PROVINCIA IN VARCHAR2,
                                 K_DISTRITO IN VARCHAR2,
                                 K_FECHACTIVACION IN DATE,
                                 K_TBL_BONOCONFIG IN T_TBLBONOCONFIG,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_KARDEX(K_COD_CLI IN VARCHAR2,
                            K_COD_CPTO IN VARCHAR2,
                            K_FEC_TRANS IN DATE,
                            K_PUNTOS IN NUMBER,
                            K_NOM_ARCH IN VARCHAR2,
                            K_TPO_OPER IN VARCHAR2,
                            K_TPO_PUNTO IN VARCHAR2,
                            K_SLD_PUNTO IN NUMBER,
                            K_TIPPREMIO IN VARCHAR2,
                            K_DESC_PROM IN VARCHAR2,
                            K_FEC_VCMTO IN DATE,
                            K_ESTADO IN VARCHAR2,
                            K_USUARIO IN VARCHAR2,
                            K_IDKARDEX OUT NUMBER,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_SALDOS_CLIE(K_COD_CLI IN VARCHAR2,
                                 K_COD_CLI_IB NUMBER,
                                 K_SALDO_CC IN NUMBER,
                                 K_SALDO_IB IN NUMBER,
                                 K_ESTPTO_CC IN VARCHAR2,
                                 K_ESTPTO_IB IN VARCHAR2,
                                 K_IDSALDO OUT NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_CLIENTE(K_COD_CLI IN VARCHAR2,
                             K_COD_SEGCLI VARCHAR2,
                             K_COD_CATCLI IN VARCHAR2,
                             K_TIPO_DOC IN VARCHAR2,
                             K_NUM_DOC IN VARCHAR2,
                             K_NOM_CLI IN VARCHAR2,
                             K_APE_CLI IN VARCHAR2,
                             K_SEXO IN VARCHAR2,
                             K_EST_CIVIL IN VARCHAR2,
                             K_EMAIL IN VARCHAR2,
                             K_DPTO IN VARCHAR2,
                             K_PROVINCIA IN VARCHAR2,
                             K_DISTRITO IN VARCHAR2,
                             K_FEC_ACTIV IN DATE,
                             K_CICL_FACT IN VARCHAR2,
                             K_ESTADO IN VARCHAR2,
                             K_COD_TPOCL IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_IDCLIENTE OUT VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_SALDOS_BONO_CLIE(K_COD_CLI IN VARCHAR2,
                                      K_SALDO IN NUMBER,
                                      K_GRUPO IN VARCHAR2,
                                      K_ESTADO IN VARCHAR2,
                                      K_USUARIO IN VARCHAR2,
                                      K_IDSALDOSBONO OUT NUMBER,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_TMP_BONOFIDEL_PRE(K_TIPOFIDEL IN VARCHAR2,
                                   K_NOMARCH IN VARCHAR2,
                                   K_NUMREG OUT NUMBER,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_TMP_EBONOFIDEL_PRE(K_TIPOFIDEL IN VARCHAR2,
                                    K_NOMARCH IN VARCHAR2,
                                    K_CUR_LISTA OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_ENTR_BONOFID12M(K_NOM_ARCHIVO IN VARCHAR2,
                                 K_BONO IN VARCHAR2,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2,
                                 K_TOT_PROC OUT NUMBER,
                                 K_TOT_EXI OUT NUMBER,
                                 K_TOT_ERR OUT NUMBER);

PROCEDURE ADMPSI_PREVENCPTOBONO(K_USUARIO IN VARCHAR2,
                                K_TOT_PROC OUT NUMBER,
                                K_TOT_EXI OUT NUMBER,
                                K_TOT_ERR OUT NUMBER,
                                K_CODERROR  OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_CONS_BONO(K_TIPOCLIENTE IN VARCHAR2,
                           K_TIPDOC IN VARCHAR2,
                           K_NRODOC IN VARCHAR2,
                           K_LINEA IN VARCHAR2,
                           K_TPO_CONSULTA IN VARCHAR2,
                           K_CUR_BONO_ENT OUT SYS_REFCURSOR,
                           K_CODERROR  OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSI_PROC_ENTREGA_BONO(K_IDENT     IN NUMBER,
                                     K_BONO      IN VARCHAR2,
                                     K_SEQ       IN NUMBER,
                                     K_LINEA     IN VARCHAR2,
                                     K_USUARIO   IN VARCHAR2,
                                     K_MSJSMS    OUT VARCHAR2,
                                     K_CODERROR  OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSI_ENTREGA_BONO_REP(K_IDENT     IN NUMBER,
                                    K_BONO      IN VARCHAR2,
                                    K_LINEA     IN VARCHAR2,
                                    K_USUARIO   IN VARCHAR2,
                                    K_MSJSMS    OUT VARCHAR2,
                                    K_CODERROR  OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSS_LINEAS_NOPROC_BONO(K_CANT_PROC IN NUMBER,
                                      K_CUR_LISTA OUT SYS_REFCURSOR,
                                      K_CODERROR  OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2);


  PROCEDURE ADMPSS_LST_CLIENTE_BONOS( K_USUARIO   IN  VARCHAR2
                                     ,K_REGISTRO  OUT NUMBER
                                     ,K_CODERROR  OUT NUMBER
                                     ,K_DESCERROR OUT VARCHAR2);

   PROCEDURE ADMPSU_UPD_ENTREGA_BONOS( K_NUME_PROCES IN  NUMBER
				      ,K_CANT_PROCES OUT NUMBER
                                      ,K_CANT_EXITOS OUT NUMBER
				      ,K_CANT_ERRADO OUT NUMBER
				      ,K_FLAG_EXITOS OUT NUMBER
				      ,K_MENS_TRANSA OUT VARCHAR2);

  PROCEDURE ADMPSI_QUITA_BONO (K_DE_BONO   IN VARCHAR2,
                               K_ID_BONO   IN NUMBER,
                               K_LINEA     IN VARCHAR2,
                               K_USUARIO   IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);


  PROCEDURE ADMPSI_REG_SALDOS(K_COD_CLI      IN VARCHAR2,
                               K_SALDO        IN NUMBER,
                               K_GRUPO        IN VARCHAR2,
                               K_USUARIO      IN VARCHAR2,
                               K_CODERROR     OUT NUMBER,
                               K_DESCERROR    OUT VARCHAR2);


  PROCEDURE ADMPSS_BONO_CFG(K_BONO           IN VARCHAR2,
                            K_IDENT          IN NUMBER,
                            K_DESCBONO       OUT VARCHAR2,
                            K_CODMSJSMS      OUT VARCHAR2,
                            K_CUR_BONOCONFIG OUT SYS_REFCURSOR,
                            K_CODERROR       OUT NUMBER,
                            K_DESCERROR      OUT VARCHAR2);

END PKG_CC_BONOS;
/