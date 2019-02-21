/************** admpt_tipo_premio **********************/

alter table pclub.admpt_tipo_premio
add admpn_orden number;

/************** ADMPT_TIPO_PREMCLIE **********************/

alter table pclub.ADMPT_TIPO_PREMCLIE
  add constraint FK_ADMPT_TIPO_PREMCLIE_TIP_CLI foreign key (ADMPV_COD_TPOCL)
  references pclub.ADMPT_TIPO_CLIENTE (ADMPV_COD_TPOCL);
alter table pclub.ADMPT_TIPO_PREMCLIE
  add constraint FK_ADMPT_TIPO_PREMCLIE_TIP_PRE foreign key (ADMPV_COD_TPOPR)
  references pclub.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR);

/************** KARDEX   **********************/

alter table pclub.ADMPT_KARDEX
  add constraint FK_ADMPT_KARDEX_CONCEPTO foreign key (ADMPV_COD_CPTO)
  references pclub.ADMPT_CONCEPTO (ADMPV_COD_CPTO);


/************** PREMIO ************************/
  
alter table pclub.ADMPT_PREMIO
ADD ADMPV_CAMPANA VARCHAR2(150);

ALTER TABLE pclub.admpt_premio
ADD ADMPV_CLAVE VARCHAR2(50) ;

alter table pclub.ADMPT_PREMIO 
ADD ADMPN_MNTDCTO NUMBER;

alter table pclub.admpt_premio
drop column admpv_cod_tpocl;  

alter table pclub.ADMPT_PREMIO
  add constraint FK_ADMPT_PREMIO_TIPO_PREMIO foreign key (ADMPV_COD_TPOPR)
  references pclub.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR);
  
alter table pclub.admpt_premio modify admpv_desc varchar2(150);

/************** cliente ************************/
alter table pclub.ADMPT_CLIENTE
  add constraint FK_ADMPT_CLIENTE_CAT_CLIENTE foreign key (ADMPN_COD_CATCLI)
  references pclub.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI);



