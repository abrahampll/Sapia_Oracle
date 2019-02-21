CREATE OR REPLACE PACKAGE USRSRVCC.PKG_CC_SERV AS

/******************************************************************************
   NAME:        PKG_CC_SERV
   PURPOSE:     Realiza los procesos de inserción, actualización y eliminación de movimientos,
                así como la consulta de premios.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/02/2013  Oscar Paucar     1. Created this package.
******************************************************************************/

PROCEDURE ADMPSI_REGMOVIMIENTO(K_ID_PREMIO IN VARCHAR2,
                               K_LINEA IN VARCHAR2,
                               K_TIPDOC IN VARCHAR2,
                               K_NUMDOC IN VARCHAR2,
                               K_ID_CLIENTE IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_CONPREMIO(K_ID_PREMIO IN VARCHAR2,
                           K_ID_TIPOPREMIO VARCHAR2,
                           K_DESC VARCHAR2,
                           K_ESTADO VARCHAR2,
                           K_CURSORPREMIO OUT SYS_REFCURSOR,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);

END PKG_CC_SERV;
/
