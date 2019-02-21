-- Create table
create table PCLUB.ADMPT_PUNTO_VENTA
(
  admpv_id_canje      NUMBER(10) not null,
  admpv_pto_venta     VARCHAR2(10),
  admpv_pto_venta_des VARCHAR2(40),
  admpv_desc          VARCHAR2(50)
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
-- Add comments to the columns 
comment on column PCLUB.ADMPT_PUNTO_VENTA.admpv_id_canje
  is 'ID DE CANJE';
comment on column PCLUB.ADMPT_PUNTO_VENTA.admpv_pto_venta
  is 'CODIGO DE PUNTO DE VENTA';
comment on column PCLUB.ADMPT_PUNTO_VENTA.admpv_pto_venta_des
  is 'NOMBRE DE PUNTO DE VENTA';
comment on column PCLUB.ADMPT_PUNTO_VENTA.admpv_desc
  is 'DESCRIPCION DEL CANJE';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_PUNTO_VENTA
  add constraint PK_ADMPT_PUNTO_VENTA primary key (ADMPV_ID_CANJE)
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
-- Grant/Revoke object privileges 
grant select, insert, update, references, alter, index on PCLUB.ADMPT_PUNTO_VENTA to USRPCLUB;