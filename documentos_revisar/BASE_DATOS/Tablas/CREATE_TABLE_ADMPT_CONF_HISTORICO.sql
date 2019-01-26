-- Create table
create table PCLUB.ADMPT_CONF_HISTORICO
(
  ID_ESTADO_PROC     INTEGER not null,
  ESTADO_PROCESO     CHAR(1),
  DESCRIPCION_ESTADO VARCHAR2(100),
  FECHA_REGIST  DATE,
  ESTADO_EJECUCION   VARCHAR2(10)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );