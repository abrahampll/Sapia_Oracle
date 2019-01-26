create table PCLUB.T_ADMPT_PARAM
(
  PARN_NUM_ARCH NUMBER,
  PARV_NOM_ARCH VARCHAR2(30),
  PARN_DIA_EJEC NUMBER,
  PARD_FEC_CRE  DATE default sysdate,
  PARV_USU_CRE  VARCHAR2(30) default user,
  PARD_FEC_MOD  DATE default sysdate,
  PARV_USU_MOD  VARCHAR2(30) default user
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
comment on table PCLUB.T_ADMPT_PARAM is 'Tabla de configuracion del Shell SH080_PUNTOS_PREPAGO.sh';
comment on column PCLUB.T_ADMPT_PARAM.PARN_NUM_ARCH    is 'Identificador del archivo';
comment on column PCLUB.T_ADMPT_PARAM.PARV_NOM_ARCH    is 'Nombre del archivo de entrada';
comment on column PCLUB.T_ADMPT_PARAM.PARN_DIA_EJEC    is 'Dia de ejecucion del archivo de entrada';
comment on column PCLUB.T_ADMPT_PARAM.PARD_FEC_CRE     is 'Fecha de creacion del archivo';
comment on column PCLUB.T_ADMPT_PARAM.PARV_USU_CRE     is 'Usuario de creacion del archivo';
comment on column PCLUB.T_ADMPT_PARAM.PARD_FEC_MOD     is 'Fecha de modificacion del archivo';
comment on column PCLUB.T_ADMPT_PARAM.PARV_USU_MOD     is 'Usuario de modificacion del archivo';