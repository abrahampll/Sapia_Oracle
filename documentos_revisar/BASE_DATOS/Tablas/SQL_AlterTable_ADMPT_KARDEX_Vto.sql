-- Add/modify columns 
alter table PCLUB.ADMPT_KARDEX add ADMPN_ID_KRDX_VTO number;
alter table PCLUB.ADMPT_KARDEX add ADMPN_ULTM_SLD_PTO number;
-- Add comments to the columns
comment on column PCLUB.ADMPT_KARDEX.ADMPN_ID_KRDX_VTO
  is 'Id Kardex del movimiento con el que vence este registro';
comment on column PCLUB.ADMPT_KARDEX.ADMPN_ULTM_SLD_PTO
  is 'Saldo de vencimiento';
