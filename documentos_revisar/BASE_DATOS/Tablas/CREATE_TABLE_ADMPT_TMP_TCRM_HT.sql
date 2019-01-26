-- Create table
create table PCLUB.ADMPT_TMP_TCRM_HT
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
  fec_opera                 DATE,
  estado                    VARCHAR2(20),
  flag                      CHAR(1)
)
tablespace PCLUB_DATA
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
comment on column PCLUB.ADMPT_TMP_TCRM_HT.bscsinvoicenumber
  is 'BSC NUMERO DE FACTURA';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.billingaccountid
  is 'ID DE CUENTA DE FACTURACION';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.cod_id
  is 'CODIGO DE CONTRATO DE SUSCRIPCION';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.suscription
  is 'NOMBRE DEL SERVICIO';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.paymentdate
  is 'FECHA DE PAGO';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.paidamount
  is 'MONTO DE PAGO';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.invoiceexpirationdate
  is 'FECHA DE VENCIMIENTO DE LA FACTURA';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.invoiceissuancedate
  is 'FECHA DE EMISION DE LA FACTURA';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.additionalpointsindicator
  is 'ENTERO QUE DETERMINA EL MOTIVO PARA ACUMULAR';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.estado
  is 'PENDIENTE / PROCESADO';
comment on column PCLUB.ADMPT_TMP_TCRM_HT.flag
  is 'M = MOVIL / F = FIJO';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_TMP_TCRM_HT
  add constraint PK_TMP_TCRM_HT primary key (COD_ID)
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
grant select, insert, update, references, alter, index on PCLUB.ADMPT_TMP_TCRM_HT to USRPCLUB;
