-- ROLLBACK ALTER TABLE

-- CANJE
ALTER TABLE PCLUB.ADMPT_CANJE
DROP COLUMN ADMPV_CODSEGMENTO;

ALTER TABLE PCLUB.ADMPT_CANJE
DROP COLUMN ADMPV_USU_ASEG;

-- CANJE DETALLE
ALTER TABLE PCLUB.ADMPT_CANJE_DETALLE
DROP COLUMN ADMPN_VALSEGMENTO;

ALTER TABLE PCLUB.ADMPT_CANJE_DETALLE
DROP COLUMN ADMPN_PUNTOSDSCTO;

-- CANJE FIJA
ALTER TABLE PCLUB.ADMPT_CANJEFIJA
DROP COLUMN ADMPV_CODSEGMENTO;

ALTER TABLE PCLUB.ADMPT_CANJEFIJA
DROP COLUMN ADMPV_USU_ASEG;

-- CANJE DETALLE FIJA
ALTER TABLE PCLUB.ADMPT_CANJE_DETALLEFIJA
DROP COLUMN ADMPN_VALSEGMENTO;

ALTER TABLE PCLUB.ADMPT_CANJE_DETALLEFIJA
DROP COLUMN ADMPN_PUNTOSDSCTO;

COMMIT;