--------------- Creacion de indices --------------- 
create index PCLUB.INX_AUDITORIA_PROC_CLAROCLUB on PCLUB.AUDITORIA_PROC_CLAROCLUB
  (AUD_ID_PROCESO,
  AUD_FECHA_REGISTRO,
  AUD_ID_EJEC_PROCESO,
  AUD_USUARIOREG)
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

