create or replace package PCLUB.PKG_COMUNIDAD_CLARO is
  
  PROCEDURE MICLSS_DATOS_CLIENTE(PI_TIPO_DOCUMENTO     IN PCLUB.admpt_cliente.ADMPV_TIPO_DOC%TYPE,
                                 PI_NUMERO_DOCUMENTO   IN PCLUB.admpt_cliente.admpv_num_doc%TYPE,
                                 PI_CODIGO_CLIENTE     IN PCLUB.admpt_cliente.ADMPV_COD_CLI%TYPE,
                                 PO_CODIGO_ERROR     OUT NUMBER,
                                 PO_MENSAJE_ERROR    OUT VARCHAR2,
                                 PO_CURSOR_CLIENTE   OUT SYS_REFCURSOR);

end PKG_COMUNIDAD_CLARO;
/
