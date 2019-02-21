--Actualizar datos de los Clientes
UPDATE PCLUB.ADMPT_CLIENTECUPONERA ACC
   SET ACC.ADMPV_NUM_DOC = UPPER(ADMPV_NUM_DOC),
       ACC.ADMPV_NOM_CLI = UPPER(ADMPV_NOM_CLI),
       ACC.ADMPV_APE_CLI = UPPER(ADMPV_APE_CLI);

--Actualizar datos de los Establecimientos
UPDATE PCLUB.ADMPT_ESTABLECIMIENTO E
   SET E.ADMPV_NOM_ESTABL = UPPER(ADMPV_NOM_ESTABL);

--Actualizar datos de las Cuponeras
UPDATE PCLUB.ADMPT_CUPONERA C 
   SET C.ADMPV_NOM_CUP = UPPER(ADMPV_NOM_CUP);

COMMIT;