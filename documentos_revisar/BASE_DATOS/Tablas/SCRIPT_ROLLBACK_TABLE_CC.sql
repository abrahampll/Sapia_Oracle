alter table
    pclub.admpt_kardex
drop
   (ADMPD_FEC_REG,
   ADMPD_FEC_MOD);
   
alter table
  pclub.admpt_saldos_cliente
drop
   (ADMPD_FEC_REG, 
   ADMPD_FEC_MOD );
   
alter table
    pclub.ADMPT_CLIENTE 
drop
   (ADMPD_FEC_REG,
   ADMPD_FEC_MOD);
   
alter table
   pclub.admpt_clienteib
drop
   (ADMPD_FEC_REG,
   ADMPD_FEC_MOD);
   
alter table
  pclub.admpt_canje
drop
   (ADMPD_FEC_REG,
   ADMPD_FEC_MOD);
   
alter table
   pclub.admpt_canje_detalle
drop
   (ADMPD_FEC_REG,
   ADMPD_FEC_MOD);