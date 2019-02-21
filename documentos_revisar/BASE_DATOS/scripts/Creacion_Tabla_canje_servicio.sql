create table PCLUB.ADMPT_CANJE_SERVICIO
( ADMPV_COD_SERV NUMBER,
  ADMPV_DES_SERV VARCHAR2(120),
  ADMPV_USU_CREACION VARCHAR2(10),
  ADMPV_FEC_CREACION DATE,
  ADMPV_USU_MODIFICA VARCHAR2(10),
  ADMPV_FEC_MODIFICA DATE,
  ADMPV_ESTADO VARCHAR2(1),
  ADMPV_FLG_ACTIVO VARCHAR2(1)
  )  
  TABLESPACE PCLUB_DATA
  PCTUSED    40
  PCTFREE    10
  INITRANS   1
  MAXTRANS   255
  STORAGE    (
        INITIAL          64K
        NEXT             1M
        MINEXTENTS       1
        MAXEXTENTS       UNLIMITED
        PCTINCREASE      0
        FREELISTS        1
        FREELIST GROUPS  1
        BUFFER_POOL      DEFAULT
         );

comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_COD_SERV
  is 'Código del servicio';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_DES_SERV
  is 'Descripción del servicio';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_USU_CREACION
  is 'Usuario de creación';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_FEC_CREACION
  is 'Fecha de creación';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_USU_MODIFICA
  is 'Usuario de modificación';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_FEC_MODIFICA
  is 'Fecha de modificación';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_ESTADO
  is 'Estado del registro';
comment on column PCLUB.ADMPT_CANJE_SERVICIO.ADMPV_FLG_ACTIVO
  is 'Servicio principal obligatorio';
commit;
