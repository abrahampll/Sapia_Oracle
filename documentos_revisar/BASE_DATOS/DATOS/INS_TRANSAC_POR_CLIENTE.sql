-- Insert en la tabla de configuracion

INSERT INTO PCLUB.admpt_transac_x_cliente (admpv_transaccion, admpv_cod_tpocl
                                      ,admpd_fec_reg,admpd_fec_mod
                                      ,admpv_usu_reg,admpv_usu_mod)
VALUES ('TRANSACCION_REG_CLIENTE_CC',3,
       NULL,NULL,
       NULL,NULL);

INSERT INTO PCLUB.admpt_transac_x_cliente (admpv_transaccion, admpv_cod_tpocl
                                      ,admpd_fec_reg,admpd_fec_mod
                                      ,admpv_usu_reg,admpv_usu_mod)
VALUES ('TRANSACCION_REG_CLIENTE_CC',8,
        NULL,NULL,
        NULL,NULL);

COMMIT;
