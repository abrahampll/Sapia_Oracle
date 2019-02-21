create or replace package PCLUB.PKG_CC_ALINEACION_PTO is

PROCEDURE ADMPSI_ACT_SLDO_INI(K_HILOS IN NUMBER,
                              K_FECHA IN DATE,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ACT_SLDO_PROCE(K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);


PROCEDURE ADMPSI_ACT_SLDO_PROCE_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ACT_SLDO_INI_BON(K_HILOS IN NUMBER,
                              K_FECHA IN DATE,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ACT_SLDO_PROCE_BON(K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ACT_SLDO_PROC_BON_CNF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ACT_SLDO_INI_IB(K_HILOS IN NUMBER,
                              K_FECHA IN DATE,
                              K_CODERROR     OUT NUMBER,
                              K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ACT_SLDO_PROCE_IB(K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);


PROCEDURE ADMPSI_ACT_SLDO_PROC_IB_CNF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2);


PROCEDURE ADMPSI_ALIN_SLD_CARGA(K_FECHA IN DATE,
                                K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_CATEG(K_HILOS        IN NUMBER,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_PROCE(K_FECHA        IN DATE,
                                K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_PROCE_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2);



PROCEDURE ADMPSI_ALIN_SLD_CARGA_BON(K_FECHA IN DATE,
                                K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_CATEG_BON(K_HILOS        IN NUMBER,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_PROCE_BON(K_FECHA        IN DATE,
                                K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

FUNCTION ADMPSI_ALIN_SLD_PROCE_BON_PRLL (V_CURRENT_DATE IN date,
                                             c_cursor IN SYS_REFCURSOR)
                                             RETURN varchar2
                                             PARALLEL_ENABLE (PARTITION c_cursor BY ANY);

PROCEDURE ADMPSI_ALIN_SLD_PROCE_BON_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_CARGA_IB(K_FECHA IN DATE,
                                K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);




PROCEDURE ADMPSI_ALIN_SLD_CATEG_IB(K_HILOS        IN NUMBER,
                                K_FECHA        IN DATE,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_PROCE_IB(K_FECHA        IN DATE,
                                K_PROC         IN NUMBER,
                                K_CODERROR     OUT NUMBER,
                                K_DESCERROR    OUT VARCHAR2);

PROCEDURE ADMPSI_ALIN_SLD_PROCE_IB_CONF(K_PROC        IN NUMBER,
                                     K_COUNT       OUT NUMBER,
                                     K_CODERROR     OUT NUMBER,
                                     K_DESCERROR    OUT VARCHAR2);
PROCEDURE ADMPSI_LIMP_TEMP_ALIN_INI
                                (
                                    K_RESULTADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2
                                );

PROCEDURE ADMPSI_LIMP_TMP_ALIN_INI_BONO
                                (
                                    K_RESULTADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2
                                );

PROCEDURE ADMPSI_LIMP_TMP_ALIN_INI_IB
                                (
                                    K_RESULTADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2
                                );

PROCEDURE ADMPSI_ALIN_SLD_LIMP
                                (
                                    K_RESULTADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2
                                );

PROCEDURE ADMPSI_ALIN_SLD_LIMP_BONO
                                (
                                    K_RESULTADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2
                                );

PROCEDURE ADMPSI_ALIN_SLD_LIMP_IB
                                (
                                    K_RESULTADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2
                                );

end PKG_CC_ALINEACION_PTO;
/