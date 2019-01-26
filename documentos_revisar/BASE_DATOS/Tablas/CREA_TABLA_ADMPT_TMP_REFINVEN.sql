 CREATE TABLE  PCLUB.ADMPT_TMP_REFINVEN(
   ADMPV_NOMBRES  varchar2(80),
   ADMPV_APELLIDOS  varchar2(80),
   ADMPV_TIPO_DOC char(2),
   ADMPV_NUM_DOC varchar2(20),
   ADMPV_NUM_LINEA varchar2(20),
   ADMPV_NUM_REFER varchar2(20),
   ADMPC_COD_ERROR varchar2(5),
   ADMPV_MSJE_ERROR varchar2(120)
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
  
create sequence PCLUB.ADMPT_TMP_REFINVEN 
minvalue 1 
maxvalue 999999999999999999999999999 
start with 141 
increment by 1 
cache 20; 