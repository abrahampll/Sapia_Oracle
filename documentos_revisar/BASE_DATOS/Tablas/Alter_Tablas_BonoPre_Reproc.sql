-- Create table
create table PCLUB.ADMPT_VENCTO_PROC_TMP
(
  admpv_cod_cli    VARCHAR2(40),
  admpn_tip_premio NUMBER,
  admpv_cod_cpto   VARCHAR2(3),
  admpn_sld_punto  NUMBER,
  estado           VARCHAR2(20),
  fechareg         DATE default SYSDATE
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


/* ADMPT_BONOPREP_ERR */
ALTER TABLE PCLUB.ADMPT_BONOPREP_ERR ADD ADMPV_ESTADO VARCHAR2(2) default 'R';
ALTER TABLE PCLUB.ADMPT_BONOPREP_ERR ADD ADMPV_MENSAJE VARCHAR2(200);
ALTER TABLE PCLUB.ADMPT_BONOPREP_ERR ADD ADMPD_FEC_PROC DATE;
ALTER TABLE PCLUB.ADMPT_BONOPREP_ERR ADD ADMPD_FEC_ENVIOSMS DATE;
ALTER TABLE PCLUB.ADMPT_BONOPREP_ERR ADD ADMPV_CONT_PROC NUMBER default 1;

/*COMENTARIOS*/
comment on column PCLUB.ADMPT_BONOPREP_ERR.ADMPV_ESTADO
  is 'Estado del registro R:Registrado/E: Error Procesado/ P:Procesado/S: EnviadoSMS';
comment on column PCLUB.ADMPT_BONOPREP_ERR.ADMPV_MENSAJE
  is 'Mensaje SMS enviado al cliente';
comment on column PCLUB.ADMPT_BONOPREP_ERR.ADMPD_FEC_PROC
  is 'Fecha del último proceso';
comment on column PCLUB.ADMPT_BONOPREP_ERR.ADMPD_FEC_ENVIOSMS
  is 'Fecha Envio SMS';
comment on column PCLUB.ADMPT_BONOPREP_ERR.ADMPV_CONT_PROC
  is 'Contador del proceso';