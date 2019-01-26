
--usuario del aplicativo debe tener acceso para la ejecución del paquete PKG_CC_CUPONERA

REVOKE EXECUTE ON PCLUB.PKG_CC_CUPONERA FROM USRCLAROCLUB;

-- usuario del aplicativo debe tener acceso total sobre la tabla ADMPT_TMP_CUPONERA, ya que la carga desde el aplicativo se hace sobre esa tabla

REVOKE SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_TMP_CUPONERA FROM  USRCLAROCLUB;

--usuario de EAI USREAIPCLUB, debe tener acceso sobre PKG_CC_CUPONERA, ya que ellos ejecutan este paquete para hacer las consultas y movimientos:

REVOKE EXECUTE ON PCLUB.PKG_CC_CUPONERA FROM USREAIPCLUB;

--usuario USRPCLUB(ejecuta las shells), debe tener acceso sobre  PKG_CC_CUPONERA:

REVOKE EXECUTE ON PCLUB.PKG_CC_CUPONERA FROM USRPCLUB;

--acceso total sobre las tablas temporales de carga de datos:

REVOKE SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_TMP_ALTAMASIVACUPONERA FROM  USRPCLUB;
REVOKE SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_AUX_CAMBIOSEG FROM  USRPCLUB;
-- usuario del aplicativo debe tener acceso total sobre la tabla ADMPT_TMP_CAMBIOSEG, ya que la carga desde el aplicativo se hace sobre esa tabla

REVOKE SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_TMP_CAMBIOSEG FROM  USRPCLUB;
