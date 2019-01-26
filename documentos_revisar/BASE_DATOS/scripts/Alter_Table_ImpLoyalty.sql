/************** ADMPT_KARDEX **********************/
alter table pclub.ADMPT_KARDEX
add ADMPV_IDTRANSLOY VARCHAR2(18);


alter table pclub.ADMPT_CLIENTE modify ADMPV_NOM_CLI varchar2(80);

alter table pclub.ADMPT_CLIENTE modify ADMPV_APE_CLI varchar2(80);

alter table pclub.ADMPT_CLIENTE modify ADMPV_EMAIL varchar2(100);