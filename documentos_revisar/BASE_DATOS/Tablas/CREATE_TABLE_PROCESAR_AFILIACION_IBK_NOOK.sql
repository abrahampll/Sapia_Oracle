create table PCLUB.PROCESAR_AFILIACION_IBK_NOOK
(
  COD_IBK              NUMBER,
  DNI                  VARCHAR2(25),
  FECHA_REGISTRO       DATE,
  LINEA_NO_REGISTRADA  VARCHAR2(25),
  FECHA_PROCESO        DATE,
  CUENTA               VARCHAR2(50),
  ESTADO_DEL_PROCESO   VARCHAR2(5),
  TIPO_LINEA           VARCHAR2(8),
  MENSAJE              VARCHAR2(1000),
  FECHA_PROCESO_QVIENE DATE
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );