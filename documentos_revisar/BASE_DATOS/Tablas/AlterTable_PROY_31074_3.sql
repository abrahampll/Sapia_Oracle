-- Add/modify columns 
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_NOM_ARCHIVO VARCHAR2(60);
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLCKCN_IDKARDEX number;
-- Add/modify columns 
alter table pclub.SYSFT_LATAM_CANJE_KM_CC_PROD add SYLCKCPN_ID_KARDEX number;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC_PROD add SYLCKCPN_PUNTOS number;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC_PROD add SYLCKCPN_ID_KRDX_ANULA number;
-- Add comments to the columns  
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_NOM_ARCHIVO
  is 'Nombre del archivo con el que registro el canje';
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_IDKARDEX
  is 'IdKardex de proceso de acreditación';
-- Add comments to the columns 
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPN_ID_KARDEX
  is 'Identificador del Kardex';
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPN_PUNTOS
  is 'Puntos canjeados';
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPN_ID_KRDX_ANULA
  is 'Identificador del Kardex con el que se anula la transaccion';