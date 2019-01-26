-- TABLA: SYSFT_LATAM_CANJE_KM_CC  
-- Drop columns 
alter table pclub.SYSFT_LATAM_CANJE_KM_CC drop column SYLCKCC_EST_REG_SOC;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC drop column SYLCKCN_ID_LOTE_SOC;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC drop column SYLEKCD_FEC_MOD_SOC;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC drop column SYLEKCV_USU_MOD_SOC;
alter table pclub.SYSFT_LATAM_CANJE_KM_CC drop column SYLCKCV_DESC_ERR_LATAM;

-- modify columns 
alter table pclub.SYSFT_LATAM_CANJE_KM_CC modify SYLCKCV_COD_ERR_LATAM VARCHAR2(10);  


-- TABLA: SYSFT_LATAM_CANJE_KM_CC  
-- Drop columns 
alter table pclub.sysft_latam_portareno_equipo drop column SYPEV_APE_PAT;
alter table pclub.sysft_latam_portareno_equipo drop column SYPEV_APE_MAT;
alter table pclub.sysft_latam_portareno_equipo drop column SYPEV_TIP_DOC;
alter table pclub.sysft_latam_portareno_equipo drop column SYPED_FEC_NAC;
alter table pclub.sysft_latam_portareno_equipo drop column SYPEC_GENERO;
alter table pclub.sysft_latam_portareno_equipo drop column SYPEV_EMAIL;
alter table pclub.sysft_latam_portareno_equipo drop column SYPEV_PAIS_RESID;


-- TABLA: pclub.SYSFT_LATAM_ERROR_ACREDITA
-- modify columns 
alter table pclub.SYSFT_LATAM_ERROR_ACREDITA modify SYLEAV_COD_ERR VARCHAR2(10);
