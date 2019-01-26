-- Add/modify columns 
alter table PCLUB.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_COD_RESP VARCHAR2(10);
alter table PCLUB.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_MSG_RESP VARCHAR2(500);
alter table PCLUB.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_ID_TRANS VARCHAR2(50);
alter table PCLUB.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_TIP_DOC VARCHAR2(10);
alter table PCLUB.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_NUM_DOC VARCHAR2(20);
-- Add comments to the columns 
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_COD_RESP
  is 'Codigo de respuesta si es registro de error';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_MSG_RESP
  is 'Mensaje de respuesta si es registro de error';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_ID_TRANS
  is 'Id Transaccion si es registro de error';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCC_ESTADO
  is 'Estado de registro: P (Pendiente); E (Enviado); F (Finalizado)
;R(Error)';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_TIP_DOC
  is 'Tipo de Documento Socio';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_NUM_DOC
  is 'Numero de Documento Socio';

