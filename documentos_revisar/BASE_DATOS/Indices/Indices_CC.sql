-- Create/Recreate indexes  ADMPT_CLIENTE
create index pclub.IDX_SMS on pclub.ADMPT_CLIENTE (ADMPD_FEC_SMS, ADMPV_EST_SMS)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index pclub.IDX_FEC_REG on pclub.ADMPT_CLIENTE (ADMPD_FEC_REG)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

-- Create/Recreate indexes  ADMPT_SMS_TELEFONOS
create index pclub.IND_FEC_REG on pclub.ADMPT_SMS_TELEFONOS (ADMPV_FECHA_REG)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index pclub.IND_FEC_SMS on pclub.ADMPT_SMS_TELEFONOS (ADMPD_FECHA_SMS)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index pclub.IND_PROCESO on pclub.ADMPT_SMS_TELEFONOS (ADMPV_NOMBRE_PROCESO)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index pclub.IND_USER_REG on pclub.ADMPT_SMS_TELEFONOS (ADMPV_USUARIO_REG)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );