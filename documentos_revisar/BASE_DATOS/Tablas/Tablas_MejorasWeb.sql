--Creacion de la Tabla

create table PCLUB.ADMPT_TRANSAC_X_CLIENTE
(
  ADMPV_TRANSACCION VARCHAR2(200) not null,
  ADMPV_COD_TPOCL   VARCHAR2(2) not null,
  ADMPD_FEC_REG     DATE,
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_REG     VARCHAR2(20),
  ADMPV_USU_MOD     VARCHAR2(20)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );


--Inserts a la tabla

insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_USU_REG, ADMPV_USU_MOD)
values ('TRANSACCION_ESTADO_CUENTA', '2', sysdate, null, 'T11645', '');

insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_USU_REG, ADMPV_USU_MOD)
values ('TRANSACCION_ESTADO_CUENTA', '3', sysdate, null, 'T11645', '');

commit;
