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
  CodPaqDat       VARCHAR2(50),
  ValSegmento     VARCHAR2(5),
  PuntosDscto     NUMBER
);
/

CREATE OR REPLACE TYPE PCLUB.LISTA_PEDIDO AS VARRAY(100) OF PCLUB.PEDIDO;
/

DROP TYPE PCLUB.LISTA_PEDIDO_HFC;
DROP TYPE PCLUB.PEDIDO_HFC;


CREATE OR REPLACE TYPE PCLUB.PEDIDO_HFC  AS OBJECT
( ProdId          VARCHAR2(15),
  Campana         VARCHAR2(200),
  Puntos          NUMBER,
  Pago            NUMBER,
  Cantidad        NUMBER,
  TipoPremio      VARCHAR2(2),
  ServComercial   NUMBER,
  MontoRecarga    Number,
  CodPaqDat       VARCHAR2(50),
  CodServTV        VARCHAR2(20),
  ValSegmento     VARCHAR2(5),
  PuntosDscto     NUMBER  
);
/

CREATE OR REPLACE TYPE PCLUB.LISTA_PEDIDO_HFC AS VARRAY(100) OF PCLUB.PEDIDO_HFC;
/