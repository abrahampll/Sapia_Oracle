-- Create table
create table PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE
(
  SEGMV_CODIGO_DET VARCHAR2(2) not null,
  SEGMV_CODIGO     VARCHAR2(2) not null,
  SEGMV_REC_MIN    NUMBER not null,
  SEGMV_REC_MAX    NUMBER not null,
  SEGMV_ANT_MIN    NUMBER not null,
  SEGMV_ANT_MAX    NUMBER not null
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
  
-- Create/Recreate indexes 
create unique index PK_SEGM_CODIGO_DET on PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO)
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
  
 --------------------------------------------- 
  -- Create table
create table PCLUB.CC_PERIODO_EVALUACION
(
  SEGMV_CODIGO_PERIODO VARCHAR2(4) not null,
  SEGMV_FECHA_INICIO   DATE,
  SEGMV_FECHA_FIN      DATE,
  SEGMV_FECHA_PRO      DATE
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
  
  --------------------------------------------- 
  -- Create table
create table PCLUB.CC_DETALLE_PERIODO
(
  SEGMV_CODIGO_PERIODO  VARCHAR2(4),
  SEGMV_DET_INICIO      DATE,
  SEGMV_DET_FIN         DATE,
  SEGMV_DET_DESCRIPCION VARCHAR2(200)
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
  
  --------------------------------------------- 
  -- Create table
create table PCLUB.CC_PLANES_PERMITIDOS
(
  SEGMV_PLAN_ID NUMBER
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