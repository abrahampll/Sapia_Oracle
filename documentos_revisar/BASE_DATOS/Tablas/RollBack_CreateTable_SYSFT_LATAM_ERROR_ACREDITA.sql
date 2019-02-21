-- Drop primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_LATAM_ERROR_ACREDITA
  drop constraint PK_SLEA cascade;

DROP table PCLUB.SYSFT_LATAM_ERROR_ACREDITA;
