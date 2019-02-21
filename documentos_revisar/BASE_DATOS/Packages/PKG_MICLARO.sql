create or replace package PCLUB.PKG_MICLARO is

  PROCEDURE MICLSS_CLARO_PUNTOS(K_TIP_DOCUMENTO IN VARCHAR2,
                                K_NUM_DOCUMENTO IN VARCHAR2,
                                K_DATOS         OUT SYS_REFCURSOR,
                                K_COD_ERROR     OUT NUMBER,
                                K_MSG_ERROR     OUT VARCHAR2);

end PKG_MICLARO;
/
