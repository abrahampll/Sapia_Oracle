/*-------------------------TABLAS-------------------------------*/

alter table PCLUB.ADMPT_CANJE modify ADMPV_MENSAJE VARCHAR2(500);
alter table PCLUB.ADMPT_CANJE_DETALLE add ADMPV_COD_PAQDAT VARCHAR2(50);
alter table PCLUB.ADMPT_CANJE_DETALLE add ADMPV_CODTXPAQDAT VARCHAR2(50);
alter table PCLUB.ADMPT_PRCANJTMP add ADMPV_COD_PAQDAT VARCHAR2(50);
alter table PCLUB.ADMPT_PRCANJTMP add ADMPV_CODTXPAQDAT VARCHAR2(50);
alter table PCLUB.ADMPT_PREMIO add ADMPV_COD_PAQDAT VARCHAR2(50);
-- Add comments to the columns 
comment on column PCLUB.ADMPT_PREMIO.ADMPV_COD_PAQDAT
  is 'Primer Dato RICE y Segundo Dato Janus';
  
/*-------MODIFICACION EN TIPO DE DATOS-------*/

DROP TYPE PCLUB.LISTA_PEDIDO;

DROP TYPE PCLUB.PEDIDO;

CREATE OR REPLACE TYPE PCLUB.PEDIDO  AS OBJECT
( ProdId          VARCHAR2(15),
  Campana         VARCHAR2(200),
  Puntos          NUMBER,
  Pago            NUMBER,
  Cantidad        NUMBER,
  TipoPremio      VARCHAR2(2),
  ServComercial   NUMBER,
  MontoRecarga    Number,
  CodPaqDat       VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE PCLUB.LISTA_PEDIDO AS VARRAY(100) OF PCLUB.PEDIDO;
/