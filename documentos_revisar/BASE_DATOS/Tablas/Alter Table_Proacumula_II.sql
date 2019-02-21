ALTER TABLE PCLUB.ADMPT_CLIENTE drop constraint FK_ADMPT_CLIENTE_CAT_CLIENTE;

ALTER TABLE PCLUB.ADMPT_CAT_CLIENTE drop constraint PK_ADMPT_CAT_CLIENTE;

ALTER TABLE PCLUB.ADMPT_CAT_CLIENTE
  add constraint PK_ADMPT_CAT_CLIENTE primary key (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  
   alter table PCLUB.ADMPT_CLIENTE
  add constraint FK_ADMPT_CLIENTE_CAT_CLIENTE foreign key (ADMPN_COD_CATCLI,ADMPV_COD_TPOCL)
  references PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL);
  
insert into PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI, ADMPN_PTOANIV)
values (1, '1', 'Premiun', 'T', 12, '4', '5', 2500, 0, 'A', 2, 1.5, 1.5, 180);
insert into PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI, ADMPN_PTOANIV)
values (2, '1', 'Normal', 'T', 12, '4', '3', 2500, 0, 'A', 2.5, 2, 2, 100);
insert into PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI, ADMPN_PTOANIV)
values (1, '2', 'Premiun', 'T', 12, '4', '5', 2500, 0, 'A', 2, 1.5, 1.5, 180);
insert into PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI, ADMPN_PTOANIV)
values (2, '2', 'Normal', 'T', 12, '4', '3', 2500, 0, 'A', 2.5, 2, 2, 100);
commit;