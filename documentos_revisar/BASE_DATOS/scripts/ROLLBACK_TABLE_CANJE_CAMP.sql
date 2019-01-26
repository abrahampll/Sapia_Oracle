drop sequence PCLUB.EAI_SEQ_SYCAN_IDECANJE; 
drop sequence PCLUB.EAI_SEQ_SYCAN_IDEEVENTO; 
drop sequence PCLUB.EAI_SEQ_SYCAN_IDECAMPANA; 

-- Drop primary, unique and foreign key constraints 
alter table SYSFT_EVENTO
  drop constraint FK_ADMPV_ID_PROCLA;
alter table SYSFT_EVENTO
  drop constraint FK_SYCAN_IDENTIFICADOR;
alter table SYSFT_COD_CANJE
  drop constraint FK0_SYEVN_IDENTIFICADOR;
alter table SYSFT_CAMPANA
  drop constraint PKS_SYCAN_IDENTIFICADOR cascade;
alter table SYSFT_EVENTO
  drop constraint PK_SYEVN_IDENTIFICADOR cascade;
alter table SYSFT_COD_CANJE
  drop constraint PK_SYCCN_IDENTIFICADOR cascade;

drop table PCLUB.SYSFT_COD_CANJE; 
drop table PCLUB.SYSFT_EVENTO;
drop table PCLUB.SYSFT_CAMPANA;

drop package PCLUB.PKG_CC_CANJE_CAMP;
