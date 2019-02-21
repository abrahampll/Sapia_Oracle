
-- ******* ADMPT_DSCTO_XSEG_XTCLIE ************

create table PCLUB.ADMPT_DSCTO_XSEG_XTCLIE
(
  ADMPV_CODSEGMENTO    VARCHAR2(5) not null,
  ADMPV_CODTIPOCLIENTE VARCHAR2(5) not null,
  ADMPV_CODTIPOPREMIO  VARCHAR2(5) not null,
  ADMPV_VALORSEGMENTO  VARCHAR2(5),
  ADMPC_ESTADO         CHAR(1),
  ADMPV_USU_REG        VARCHAR2(40),
  ADMPV_USU_MOD        VARCHAR2(40),
  ADMPD_FEC_REG        DATE,
  ADMPD_FEC_MOD        DATE
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
-- Add comments to the columns 
comment on column PCLUB.ADMPT_DSCTO_XSEG_XTCLIE.ADMPV_CODSEGMENTO
  is 'Código del segmento';
comment on column PCLUB.ADMPT_DSCTO_XSEG_XTCLIE.ADMPV_CODTIPOCLIENTE
  is 'Código del Tipo de Cliente';
comment on column PCLUB.ADMPT_DSCTO_XSEG_XTCLIE.ADMPV_CODTIPOPREMIO
  is 'Código del Tipo de Premio';
comment on column PCLUB.ADMPT_DSCTO_XSEG_XTCLIE.ADMPV_VALORSEGMENTO
  is 'Valor del Segmento';
comment on column PCLUB.ADMPT_DSCTO_XSEG_XTCLIE.ADMPC_ESTADO
  is 'Eestado A=Activado B=Desactivado';
  
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_DSCTO_XSEG_XTCLIE
  add constraint PK_ADMPT_DSCTO_XSEG_XTCLIE primary key (ADMPV_CODSEGMENTO, ADMPV_CODTIPOCLIENTE, ADMPV_CODTIPOPREMIO)
  using index 
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
  
 -- ********* ADMPT_SEGMENTO_CC ***********
 
create table PCLUB.ADMPT_SEGMENTO_CC
(
  ADMV_COD_SEG  VARCHAR2(5) not null,
  ADMV_DESC_SEG VARCHAR2(50),
  ADMV_USR_REG  VARCHAR2(40),
  ADMV_USR_MOD  VARCHAR2(40),
  ADMD_FEC_REG  DATE,
  ADMD_FEC_MOD  DATE
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
-- Add comments to the columns 
comment on column PCLUB.ADMPT_SEGMENTO_CC.ADMV_COD_SEG
  is 'Codigo Segmento';
comment on column PCLUB.ADMPT_SEGMENTO_CC.ADMV_DESC_SEG
  is 'Descripción Segmento';

 -- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_SEGMENTO_CC
  add constraint ADMPT_SEGMENTO_CC_PK primary key (ADMV_COD_SEG)
  using index 
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