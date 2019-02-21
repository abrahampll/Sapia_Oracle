-- Add/modify columns 
alter table PCLUB.ADMPT_KARDEXFIJA add ADMPD_FEC_VCMTO date;
alter table PCLUB.ADMPT_KARDEXFIJA add ADMPN_ID_KRDX_VTO number;
alter table PCLUB.ADMPT_KARDEXFIJA add ADMPN_ULTM_SLD_PTO number;
-- Add comments to the columns 
comment on column PCLUB.ADMPT_KARDEXFIJA.ADMPD_FEC_VCMTO
  is 'Fecha de Vencimiento';
comment on column PCLUB.ADMPT_KARDEXFIJA.ADMPN_ID_KRDX_VTO
  is 'Id Kardex del movimiento con el que vence este registro';
comment on column PCLUB.ADMPT_KARDEXFIJA.ADMPN_ULTM_SLD_PTO
  is 'Saldo de vencimiento';
