create index PCLUB.IX_ENCUESTA_01 on PCLUB.ADMPT_ENCUESTA (ADMPV_NOMBRE, ADMPC_ESTADO)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_ENCUESTA_02 on PCLUB.ADMPT_ENCUESTA (ADMPC_ESTADO)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_PREGUNTA_01 on PCLUB.ADMPT_PREGUNTA (ADMPN_IDENC, ADMPV_PREGUNTA)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_PREGUNTA_02 on PCLUB.ADMPT_PREGUNTA (ADMPN_IDENC, ADMPV_ORDEN)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_RESPUESTA_01 on PCLUB.ADMPT_RESPUESTA (ADMPN_IDPREGUNTA, ADMPV_RESPUESTA)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_RESPUESTA_02 on PCLUB.ADMPT_RESPUESTA (ADMPN_IDPREGUNTA, ADMPV_OPCION)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_CABENCUESTA_01 on PCLUB.ADMPT_CABENCUESTA (ADMPC_ESTADO, ADMPC_TIPO_CANJE, ADMPD_FECINIENC)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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
  
create index PCLUB.IX_CABENCUESTA_02 on PCLUB.ADMPT_CABENCUESTA (ADMPV_TELEFONO, ADMPC_ESTADO, ADMPD_FECENVIO)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_CABENCUESTA_03 on PCLUB.ADMPT_CABENCUESTA (ADMPV_TIPO_DOC, ADMPV_NUM_DOC, ADMPD_FECINIENC)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_MOVENCUESTA_01 on PCLUB.ADMPT_MOVENCUESTA (ADMPC_ESTADO_PRE)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_MOVENCUESTA_02 on PCLUB.ADMPT_MOVENCUESTA (ADMPV_TELEFONO)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

create index PCLUB.IX_MOVENCUESTA_03 on PCLUB.ADMPT_MOVENCUESTA (ADMPN_IDCABENC,ADMPC_ESTADO_PRE)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

