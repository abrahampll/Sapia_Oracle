
--usuario del aplicativo debe tener acceso para la ejecución del paquete PKG_CC_CUPONERA

GRANT EXECUTE ON PCLUB.PKG_CC_CUPONERA TO USRCLAROCLUB;

-- usuario del aplicativo debe tener acceso total sobre la tabla ADMPT_TMP_CUPONERA, ya que la carga desde el aplicativo se hace sobre esa tabla

GRANT SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_TMP_CUPONERA TO  USRCLAROCLUB;
 
--usuario de EAI USREAIPCLUB, debe tener acceso sobre PKG_CC_CUPONERA, ya que ellos ejecutan este paquete para hacer las consultas y movimientos:

GRANT EXECUTE ON PCLUB.PKG_CC_CUPONERA TO USREAIPCLUB;

--usuario USRPCLUB(ejecuta las shells), debe tener acceso sobre  PKG_CC_CUPONERA:

GRANT EXECUTE ON PCLUB.PKG_CC_CUPONERA TO USRPCLUB;

--acceso total sobre las tablas temporales de carga de datos:

GRANT SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_TMP_ALTAMASIVACUPONERA TO  USRPCLUB;
GRANT SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_AUX_CAMBIOSEG TO  USRPCLUB;
-- usuario del aplicativo debe tener acceso total sobre la tabla ADMPT_TMP_CAMBIOSEG, ya que la carga desde el aplicativo se hace sobre esa tabla

GRANT SELECT,INSERT,DELETE,UPDATE ON PCLUB.ADMPT_TMP_CAMBIOSEG TO  USRPCLUB;

