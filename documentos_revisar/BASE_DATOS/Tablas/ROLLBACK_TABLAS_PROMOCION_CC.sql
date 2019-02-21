--SCRIPTS  		:	ROLLBACK DE TABLAS
--AUTOR			:	HENRY HERRERA CH
--PROPOCISITO	:	ELIMINACION DE INDICES, CLAVES PK  Y ESTRUCTURAS TABLAS


--*--*--*--*--*--*--*--*--*--*--*--*
--ADMPT_ALFANUMERICO

ALTER TABLE PCLUB.ADMPT_ALFANUMERICO   DROP CONSTRAINT PK_ALFANUMERICO_CORRELATIVO ;
ALTER TABLE PCLUB.ADMPT_ALFANUMERICO   DROP CONSTRAINT UNX_ALFANUMERICO_PROMO;
DROP INDEX IDX_ALFANUMERICO_DISPONIBLE;
DROP INDEX IDX_ALFANUMERICO_PROMO;
DROP TABLE PCLUB.ADMPT_ALFANUMERICO;

--*--*--*--*--*--*--*--*--*--*--*--*
--ADMPT_PROMOCION
ALTER TABLE PCLUB.ADMPT_PROMOCION   DROP CONSTRAINT PK_PROMOCION;
ALTER TABLE PCLUB.ADMPT_PROMOCION   DROP CONSTRAINT CHK_ESTADO_NOTNULL  ;
ALTER TABLE PCLUB.ADMPT_PROMOCION   DROP CONSTRAINT CHK_FECHAFIN_NOTNULL;
ALTER TABLE PCLUB.ADMPT_PROMOCION   DROP CONSTRAINT CHK_FECHAINI_NOTNULL;
ALTER TABLE PCLUB.ADMPT_PROMOCION   DROP CONSTRAINT CHK_IDPROMO_NOTNULL ;
DROP  INDEX IDX_PROMOCION;
DROP TABLE PCLUB.ADMPT_PROMOCION;

--*--*--*--*--*--*--*--*--*--*--*--*
--ADMPT_PREMIO_PROMO

ALTER TABLE PCLUB.ADMPT_PREMIO_PROMO	DROP  CONSTRAINT PK_PREMIOPROMO;
ALTER TABLE PCLUB.ADMPT_PREMIO_PROMO	DROP  CONSTRAINT CHK_DESPREMIO_NOTNULL;
DROP INDEX IDX_PREMIOPROMO_TPREMIO;
DROP  TABLE PCLUB.ADMPT_PREMIO_PROMO;

--*--*--*--*--*--*--*--*--*--*--*--*
--ADMPT_TIP_PREMIOPROMO

ALTER TABLE PCLUB.ADMPT_TIP_PREMIOPROMO  DROP CONSTRAINT PK_ADMPT_TIP_PREMIO;
DROP  INDEX IDX_ADMPT_TIP_PREMIO;
DROP  TABLE PCLUB.ADMPT_TIP_PREMIOPROMO;

--*--*--*--*--*--*--*--*--*--*--*--*
--ADMPT_MOV_PROMOCION

ALTER TABLE PCLUB.ADMPT_MOV_PROMOCION	DROP CONSTRAINT PK_MOV_PROMOCION_CORRE;
DROP  INDEX IDX_MOVPROMOCION_CORRE;
DROP  TABLE PCLUB.ADMPT_MOV_PROMOCION;

--*--*--*--*--*--*--*--*--*--*--*--*
--ADMPT_AUD_PROMOCION
ALTER TABLE PCLUB.ADMPT_AUD_PROMOCION	  DROP  CONSTRAINT PK_AUD_PROMOCION_IDPROMO;
DROP  INDEX IDX_AUD_PROMOCION_IDPROMO ;
DROP TABLE PCLUB.ADMPT_AUD_PROMOCION;

---------------------------------------------------------------   
---------------------------------------------------------------
--ALTER TABLE A TABLAS EXISTENTES

ALTER TABLE PCLUB.ADMPT_KARDEX DROP ( ADMPV_DESC_PROM );
