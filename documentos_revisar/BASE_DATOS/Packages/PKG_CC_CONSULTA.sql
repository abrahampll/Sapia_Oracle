CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_CONSULTA IS  

 procedure ADMPSI_ESTADOCTACC(K_TIPOCLIENTE   IN VARCHAR2,
                              K_TIPODOC       IN VARCHAR2,
                              K_NRODOC        IN VARCHAR2,
                              K_FECHAINI      IN DATE,
                              K_FECHAFIN      IN DATE,
                              CURSORESTADOCTA out SYS_REFCURSOR,
                              K_CODERROR      OUT NUMBER,
                              K_DESCERROR     OUT VARCHAR2);

 ---****NUEVOS SP'S****---
 procedure ADMPSI_PTOSACUMULADOS(K_TIPODOC        IN VARCHAR2,
                                 K_NRODOC         IN VARCHAR2,
                                 K_TIPOBOLSA      IN NUMBER,
                                 K_PTOSACUMULADOS OUT NUMBER,
                                 K_CODERROR       OUT NUMBER,
                                 K_DESCERROR      OUT VARCHAR2);

 procedure ADMPSI_PTOSCANJEADOS(K_TIPODOC       IN VARCHAR2,
                                K_NRODOC        IN VARCHAR2,
                                K_TIPOBOLSA     IN NUMBER,
                                K_PTOSCANJEADOS OUT NUMBER,
                                K_CODERROR      OUT NUMBER,
                                K_DESCERROR     OUT VARCHAR2);

 procedure ADMPSI_PTOSELIMXBAJA(K_TIPODOC       IN VARCHAR2,
                                K_NRODOC        IN VARCHAR2,
                                K_TIPOBOLSA     IN NUMBER,
                                K_PTOSELIMXBAJA OUT NUMBER,
                                K_CODERROR      OUT NUMBER,
                                K_DESCERROR     OUT VARCHAR2);

 procedure ADMPSI_PTOSELIMXVIGEN(K_TIPODOC        IN VARCHAR2,
                                 K_NRODOC         IN VARCHAR2,
                                 K_TIPOBOLSA      IN NUMBER,
                                 K_PTOSELIMXVIGEN OUT NUMBER,
                                 K_CODERROR       OUT NUMBER,
                                 K_DESCERROR      OUT VARCHAR2);

 procedure ADMPSI_PTOSTRANSFERENCIA_BC(K_TIPODOC              IN VARCHAR2,
                                       K_NRODOC               IN VARCHAR2,
                                       K_TIPOBOLSA            IN NUMBER,
                                       K_PTOSTRANSFERENCIA_BC OUT NUMBER,
                                       K_CODERROR             OUT NUMBER,
                                       K_DESCERROR            OUT VARCHAR2);

 procedure ADMPSI_PTOSTRANSFERENCIA_CB(K_TIPODOC              IN VARCHAR2,
                                       K_NRODOC               IN VARCHAR2,
                                       K_TIPOBOLSA            IN NUMBER,
                                       K_PTOSTRANSFERENCIA_CB OUT NUMBER,
                                       K_CODERROR             OUT NUMBER,
                                       K_DESCERROR            OUT VARCHAR2);

 procedure ADMPSI_PTOSMIGPREPAPOST(K_TIPODOC          IN VARCHAR2,
                                   K_NRODOC           IN VARCHAR2,
                                   K_TIPOBOLSA        IN NUMBER,
                                   K_PTOSMIGPREPAPOST OUT NUMBER,
                                   K_CODERROR         OUT NUMBER,
                                   K_DESCERROR        OUT VARCHAR2);

 procedure ADMPSI_PTOSBONMIGR(K_TIPODOC     IN VARCHAR2,
                              K_NRODOC      IN VARCHAR2,
                              K_TIPOBOLSA   IN NUMBER,
                              K_PTOSBONMIGR OUT NUMBER,
                              K_CODERROR    OUT NUMBER,
                              K_DESCERROR   OUT VARCHAR2);

 procedure ADMPSI_PTOSTRANSAPOS(K_TIPODOC       IN VARCHAR2,
                                K_NRODOC        IN VARCHAR2,
                                K_TIPOBOLSA     IN NUMBER,
                                K_PTOSTRANSAPOS OUT NUMBER,
                                K_CODERROR      OUT NUMBER,
                                K_DESCERROR     OUT VARCHAR2);

 procedure ADMPSI_PTOSMIGPOSTAPREP(K_TIPODOC          IN VARCHAR2,
                                   K_NRODOC           IN VARCHAR2,
                                   K_TIPOBOLSA        IN NUMBER,
                                   K_PTOSMIGPOSTAPREP OUT NUMBER,
                                   K_CODERROR         OUT NUMBER,
                                   K_DESCERROR        OUT VARCHAR2);

 procedure ADMPSI_PTOSRENOV(K_TIPODOC   IN VARCHAR2,
                            K_NRODOC    IN VARCHAR2,
                            K_TIPOBOLSA IN NUMBER,
                            K_PTOSRENOV OUT NUMBER,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

 procedure ADMPSI_PTOSPENMIGRAPREP(K_TIPODOC          IN VARCHAR2,
                                   K_NRODOC           IN VARCHAR2,
                                   K_TIPOBOLSA        IN NUMBER,
                                   K_PTOSPENMIGRAPREP OUT NUMBER,
                                   K_CODERROR         OUT NUMBER,
                                   K_DESCERROR        OUT VARCHAR2);

 procedure ADMPSI_PTOSACUMIB(K_TIPODOC    IN VARCHAR2,
                             K_NRODOC     IN VARCHAR2,
                             K_PTOSACUMIB OUT NUMBER,
                             K_CODERROR   OUT NUMBER,
                             K_DESCERROR  OUT VARCHAR2);

 procedure ADMPSI_PTOSELIMIBXBAJA(K_TIPODOC         IN VARCHAR2,
                                  K_NRODOC          IN VARCHAR2,
                                  K_PTOSELIMIBXBAJA OUT NUMBER,
                                  K_CODERROR        OUT NUMBER,
                                  K_DESCERROR       OUT VARCHAR2);

 procedure ADMPSI_PTOSIBELIMXVIG(K_TIPODOC        IN VARCHAR2,
                                 K_NRODOC         IN VARCHAR2,
                                 K_PTOSIBELIMXVIG OUT NUMBER,
                                 K_CODERROR       OUT NUMBER,
                                 K_DESCERROR      OUT VARCHAR2);

 procedure ADMPSI_CONCANJES(K_TIPODOC   IN VARCHAR2,
                            K_NRODOC    IN VARCHAR2,
                            K_TIPOBOLSA IN NUMBER,
                            K_CUR_LISTA OUT SYS_REFCURSOR,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);
 procedure ADMPSI_CONDEVOL(K_TIPODOC   IN VARCHAR2,
                           K_NRODOC    IN VARCHAR2,
                           K_TIPOBOLSA IN NUMBER,
                           K_CUR_LISTA OUT SYS_REFCURSOR,
                           K_CODERROR  OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);

 procedure ADMPSI_PTOSPORVENCER2M(K_TIPODOC         IN VARCHAR2,
                                  K_NRODOC          IN VARCHAR2,
                                  K_TIPOBOLSA       IN NUMBER,
                                  K_PTOSPORVENCER2M OUT NUMBER,
                                  K_PTOS1M          OUT NUMBER,
                                  K_PTOS2M          OUT NUMBER,
                                  K_CODERROR        OUT NUMBER,
                                  K_DESCERROR       OUT VARCHAR2);

 procedure ADMPSI_DETALLETRANS_CB(K_TIPODOC   IN VARCHAR2,
                                  K_NRODOC    IN VARCHAR2,
                                  K_TIPOBOLSA IN VARCHAR2,
                                  K_CUR_LISTA OUT SYS_REFCURSOR,
                                  K_CODERROR  OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 procedure ADMPSI_DETALLETRANS_BC(K_TIPODOC   IN VARCHAR2,
                                  K_NRODOC    IN VARCHAR2,
                                  K_TIPOBOLSA IN VARCHAR2,
                                  K_CUR_LISTA OUT SYS_REFCURSOR,
                                  K_CODERROR  OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 procedure ADMPSI_PTOSTRANSFIJA_APOST(K_TIPODOC             IN VARCHAR2,
                                      K_NRODOC              IN VARCHAR2,
                                      K_TIPOBOLSA           IN NUMBER,
                                      K_PTOSTRANSFIJA_APOST OUT NUMBER,
                                      K_CODERROR            OUT NUMBER,
                                      K_DESCERROR           OUT VARCHAR2);

 procedure ADMPSI_PTOSTRANSFIJA_APRE(K_TIPODOC            IN VARCHAR2,
                                     K_NRODOC             IN VARCHAR2,
                                     K_TIPOBOLSA          IN NUMBER,
                                     K_PTOSTRANSFIJA_APRE OUT NUMBER,
                                     K_CODERROR           OUT NUMBER,
                                     K_DESCERROR          OUT VARCHAR2);
 procedure MICLSS_CLARO_PUNTOS(K_TIPODOC         IN VARCHAR2,
                                  K_NRODOC          IN VARCHAR2,
                                  K_PTOSPORVENCER OUT NUMBER,
                                   K_FECHAVENCIMIENTO OUT DATE,
                                  K_CODERROR        OUT NUMBER,
                                  K_DESCERROR       OUT VARCHAR2);
end PKG_CC_CONSULTA;
/