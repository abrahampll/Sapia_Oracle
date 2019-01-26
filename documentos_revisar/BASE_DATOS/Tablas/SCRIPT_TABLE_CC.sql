--SE CREA LOS CAMPOS DE AUDITORIA PARA LAS TABLAS DE CLARO CLUB 
alter table
   pclub.admpt_kardex
add
   (
   ADMPD_FEC_REG date null,
   ADMPD_FEC_MOD DATE NULL
   );
   
alter table
   pclub.admpt_saldos_cliente
add
   (
   ADMPD_FEC_REG date null,
   ADMPD_FEC_MOD DATE NULL
   );
   
alter table 
  pclub.ADMPT_CLIENTE 
add 
 (
  ADMPD_FEC_REG date null,
  ADMPD_FEC_MOD date NULL
 );
  
  
alter table 
  pclub.admpt_clienteib
add 
 (
  ADMPD_FEC_REG date null,
  ADMPD_FEC_MOD date NULL
 );
 
alter table 
  pclub.admpt_canje
add 
 (
  ADMPD_FEC_REG date null,
  ADMPD_FEC_MOD date NULL
 );
 
 alter table 
   pclub.admpt_canje_detalle
add 
 (
  ADMPD_FEC_REG date null,
  ADMPD_FEC_MOD date NULL
 );

