-- TABLA: pclub.SYSFT_LATAM_CANJE_KM_CC  
-- Add/modify columns 
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLCKCC_EST_REG_SOC char(1) default 'P';
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLCKCN_ID_LOTE_SOC NUMBER;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLEKCD_FEC_MOD_SOC date;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLEKCV_USU_MOD_SOC VARCHAR2(10);
alter table pclub.SYSFT_LATAM_CANJE_KM_CC add SYLCKCV_DESC_ERR_LATAM VARCHAR2(200);
-- Add comments to the columns 
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLCKCC_EST_REG_SOC
  is 'Estado de registro de Afiliacion de Socio: P (Pendiente); E (Enviado); F (Finalizado)';
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_ID_LOTE_SOC
  is 'Identificador de Lote de Afiliación de Socio';
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLEKCD_FEC_MOD_SOC
  is 'Fecha de Modificación de Afiliación de Socio';
comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLEKCV_USU_MOD_SOC
  is 'Usuario de Modificación de Afiliación de Socio';
  comment on column pclub.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_DESC_ERR_LATAM
  is 'Descripción error enviado por Latam';

-- Add/modify columns 
alter table pclub.SYSFT_LATAM_CANJE_KM_CC modify SYLCKCV_COD_ERR_LATAM VARCHAR2(20);  
  
  
-- TABLA: pclub.sysft_latam_portareno_equipo
-- Add/modify columns 
alter table pclub.sysft_latam_portareno_equipo add SYPEV_APE_PAT VARCHAR2(30);
alter table pclub.sysft_latam_portareno_equipo add SYPEV_APE_MAT VARCHAR2(30);
alter table pclub.sysft_latam_portareno_equipo add SYPEV_TIP_DOC VARCHAR2(20);
alter table pclub.sysft_latam_portareno_equipo add SYPED_FEC_NAC date;
alter table pclub.sysft_latam_portareno_equipo add SYPEC_GENERO  char(1);
alter table pclub.sysft_latam_portareno_equipo add SYPEV_EMAIL VARCHAR2(80);
alter table pclub.sysft_latam_portareno_equipo add SYPEV_PAIS_RESID VARCHAR2(80);

-- Add comments to the columns 
comment on column pclub.sysft_latam_portareno_equipo.SYPEV_APE_PAT
  is 'Apellido Paterno del Cliente';
  
comment on column pclub.sysft_latam_portareno_equipo.SYPEV_APE_MAT
  is 'Apellido Materno del Cliente';
comment on column pclub.sysft_latam_portareno_equipo.SYPEV_TIP_DOC
  is 'Tipo de Documento del Cliente';
comment on column pclub.sysft_latam_portareno_equipo.SYPED_FEC_NAC
  is 'Fecha de Nacimiento del Cliente';
comment on column pclub.sysft_latam_portareno_equipo.SYPEC_GENERO
  is 'Genero del Cliente (M, F)';
comment on column pclub.sysft_latam_portareno_equipo.SYPEV_EMAIL
  is 'Correo Electronico del Cliente';
comment on column pclub.sysft_latam_portareno_equipo.SYPEV_PAIS_RESID
  is 'Pais de Residencia';          


-- TABLA: pclub.SYSFT_LATAM_ERROR_ACREDITA
-- Add/modify columns 
alter table pclub.SYSFT_LATAM_ERROR_ACREDITA modify SYLEAV_COD_ERR VARCHAR2(20);
