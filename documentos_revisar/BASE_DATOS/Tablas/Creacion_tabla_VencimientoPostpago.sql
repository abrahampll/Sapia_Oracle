create table PCLUB.AUX_VENC_PUNTOS_POSTPAGO_CC
(
cod_concepto varchar2(10),
vigencia number
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
  
create table PCLUB.AUX_VENC_PUNTOS_POSTPAGO_IB
(
cod_concepto varchar2(10),
tipo_punto char(5),
vigencia number
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
  
-- Create table
create table PCLUB.AUDITORIACLAROCLUB
(
  numregistro   NUMBER,
  fecharegistro DATE
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