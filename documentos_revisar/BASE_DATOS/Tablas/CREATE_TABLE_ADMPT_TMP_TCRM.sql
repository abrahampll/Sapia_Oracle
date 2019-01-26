-- Create table
create table PCLUB.ADMPT_TMP_TCRM
(
  bscsinvoicenumber         VARCHAR2(20),
  billingaccountid          NUMBER,
  cod_id                    VARCHAR2(40) not null,
  suscription               VARCHAR2(40),
  paymentdate               DATE,
  paidamount                NUMBER,
  invoiceexpirationdate     DATE,
  invoiceissuancedate       DATE,
  additionalpointsindicator NUMBER,
  codigoerror               NUMBER,
  descerror                 VARCHAR2(40),
  fec_opera                 DATE,
  estado                    VARCHAR2(20),
  flag                      CHAR(1)
)
tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_TMP_TCRM.bscsinvoicenumber
  is 'BSC NUMERO DE FACTURA';
comment on column PCLUB.ADMPT_TMP_TCRM.billingaccountid
  is 'ID DE CUENTA DE FACTURACION';
comment on column PCLUB.ADMPT_TMP_TCRM.cod_id
  is 'CODIGO DE CONTRATO DE SUSCRIPCION';
comment on column PCLUB.ADMPT_TMP_TCRM.suscription
  is 'NOMBRE DEL SERVICIO';
comment on column PCLUB.ADMPT_TMP_TCRM.paymentdate
  is 'FECHA DE PAGO';
comment on column PCLUB.ADMPT_TMP_TCRM.paidamount
  is 'MONTO DE PAGO';
comment on column PCLUB.ADMPT_TMP_TCRM.invoiceexpirationdate
  is 'FECHA DE VENCIMIENTO DE LA FACTURA';
comment on column PCLUB.ADMPT_TMP_TCRM.invoiceissuancedate
  is 'FECHA DE EMISION DE LA FACTURA';
comment on column PCLUB.ADMPT_TMP_TCRM.additionalpointsindicator
  is 'ENTERO QUE DETERMINA EL MOTIVO PARA ACUMULAR';
comment on column PCLUB.ADMPT_TMP_TCRM.estado
  is 'PENDIENTE / PROCESADO';
comment on column PCLUB.ADMPT_TMP_TCRM.flag
  is 'M = MOVIL / F = FIJO';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_TMP_TCRM
  add constraint PK_ADMPT_TMP_TCRM primary key (COD_ID)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Grant/Revoke object privileges 
grant select, insert, update, references, alter, index on PCLUB.ADMPT_TMP_TCRM to USRPCLUB;