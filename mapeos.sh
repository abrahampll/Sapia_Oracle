
SH025_IMPREGULA.sh,
SH026_REPREGULA.sh

73|REGULARIZACION HFC|PKG_CC_PTOSFIJA|ADMPSI_REGDTH_HFC|
9|REGULARIZACION CC|PKG_CC_PROCACUMULA|ADMPSI_REGULPTO|

16|VENCIMIENTO DE PUNTOS|PKG_CC_PTOSTFI|ADMPSI_TFIVENCPTO|SH011_REPVENPUNT_modif.sh
33|VENCIMIENTO DE PUNTO PREPAGO|PKG_CC_PREPAGO|ADMPSI_PREVENCPTO|
58|CAMBIO TITULARIDAD HFC|PKG_CC_PTOSFIJA|ADMPSI_CAMBTIT


-------------

/*

33*/


SH012_VENCIMIENTO_PUNTOS.sh 
pero usa el jar VencimientoPuntosSHELLClient.jar
SH006_DESAFILIACION_NOREC.sh	PKG_CC_PREPAGO.ADMPSS_TMP_PRESINRECARGA
pkg_cc_prepago.admpsi_desafi_categ
pkg_cc_prepago.admpsi_desafi_proce


--------------

35|MIGRACIONES POSTPAGO A PREPAGO CC|PKG_CC_MIGRACION|ADMPSI_PREMIGPOS|SH061_MIGRACION_PUNTOSCC.sh
37|PENALIDAD POR MIGRACIONES POSTPAGO A PREPAGO|ADMPSI_PREMIGPOS
41|MIGRACIONES POSTPAGO A PREPAGO IB|PKG_CC_MIGRACION|ADMPSI_PREMIGPOS
-----------------------------------------
69|BAJA CLIENTE HFC|PKG_CC_PTOSFIJA|ADMPSI_BAJA_CC|SH010_BAJACLIENTE.sh
71|INGRESO POR BAJA CLIENTE HFC|PKG_CC_PTOSFIJA|ADMPSI_BAJA_CC|SH010_BAJACLIENTE.sh
80|CAMBIO PLAN HFC|PKG_CC_PTOSFIJA|ADMPSI_CAMBIOPLAN_HFCB|SH011_CAMBIOPLANBS.sh





