-- Create table ADMPT_MENSAJE
create table PCLUB.ADMPT_MENSAJE
(
  ADMPN_COD_SMS     NUMBER,
  ADMPV_VALOR       VARCHAR2(40),
  ADMPV_DESCRIPCION VARCHAR2(1000),
  ADMPV_USER_REG    VARCHAR2(20),
  ADMPV_USER_MOD    VARCHAR2(20),
  ADMPD_FECHA_REG   DATE,
  ADMPD_FECHA_MOD   DATE,
  ADMPV_TIPO_MSJ    VARCHAR2(20),
  ADMPV_OBSERVACION VARCHAR2(2000)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 8K
    minextents 1
    maxextents unlimited
  );

-- Create table ADMPT_SMS_TELEFONOS
create table PCLUB.ADMPT_SMS_TELEFONOS
(
  ADMPV_TELEFONO       VARCHAR2(20),
  ADMPC_ESTADO         CHAR(1),
  ADMPD_FECHA_SMS      DATE,
  ADMPV_ESTADO_SMS     VARCHAR2(40),
  ADMPV_NOMBRE_PROCESO VARCHAR2(40),
  ADMPV_USUARIO_REG    VARCHAR2(40),
  ADMPV_USUARIO_MOD    VARCHAR2(40),
  ADMPV_FECHA_REG      DATE,
  ADMPV_FECHA_MOD      DATE,
  ADMPV_COD_CLIENTE    VARCHAR2(40)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

--Modificar la tabla admpt_cliente
ALTER TABLE PCLUB.ADMPT_CLIENTE ADD ADMPV_USU_REG  VARCHAR2(20);
ALTER TABLE PCLUB.ADMPT_CLIENTE ADD ADMPV_USU_MOD  VARCHAR2(20);  
ALTER TABLE PCLUB.ADMPT_CLIENTE ADD ADMPD_FEC_SMS  DATE;  
ALTER TABLE PCLUB.ADMPT_CLIENTE ADD ADMPV_EST_SMS  VARCHAR2(40);   
ALTER TABLE PCLUB.ADMPT_CLIENTE ADD ADMPV_TIPIFICACION  VARCHAR2(40);

