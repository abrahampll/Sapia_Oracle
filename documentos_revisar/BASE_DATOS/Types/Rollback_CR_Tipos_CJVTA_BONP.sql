DROP TYPE PCLUB.T_TBLSALDOXTIPOCLIE;
DROP TYPE PCLUB.T_SALDOXTIPOCLIE;

CREATE OR REPLACE TYPE PCLUB.T_SALDOXTIPOCLIE AS OBJECT
(COD_CLI      VARCHAR2(40),
 COD_CLI_PROD VARCHAR2(40),
 COD_TPOCL    VARCHAR2(2),
 DES_TIPO     VARCHAR2(20),
 PRVENTA      VARCHAR2(2),
 TBLCLIENTE   CHAR(1),
 SALDO_CC     NUMBER,
 SALDO_IB     NUMBER,
 SALDO_TOTAL  NUMBER,
 EQUIV_SOLES  NUMBER
);
/

CREATE OR REPLACE TYPE PCLUB.T_TBLSALDOXTIPOCLIE AS TABLE OF PCLUB.T_SALDOXTIPOCLIE;
/