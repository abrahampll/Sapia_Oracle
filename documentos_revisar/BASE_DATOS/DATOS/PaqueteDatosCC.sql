--SCRIPTS    :  INSERCION DE DATOS TABLA ADMPT_TIPO_PREMIO Y ADMPT_PREMIO
--AUTOR      :  SUSANA RAMOS G
--PROPOSITO  :  INSERCION DE DATOS

/*------------ DATOS TIPO DE PREMIO----------*/

insert into PCLUB.admpt_tipo_premio(admpv_cod_tpopr,admpv_desc,admpc_estado,admpn_orden)
values('20','Paquete GPRS Postpago','A',10);

/*------------ DATOS PREMIO----------------*/
insert into PCLUB.admpt_premio(admpv_id_procla,admpv_cod_tpopr,admpv_desc,admpn_puntos,admpn_pago,admpc_estado,ADMPN_COD_SERVC,admpn_mnt_recar,admpc_apl_punto,
                         admpv_campana,admpv_clave,ADMPN_MNTDCTO,admpv_cod_paqdat)
values('PAQINT100MB','20','Paquete 100 MB',75,0,'A',NULL,0,'T','Oct-11',NULL,NULL,'40-100007');                      

insert into PCLUB.admpt_premio(admpv_id_procla,admpv_cod_tpopr,admpv_desc,admpn_puntos,admpn_pago,admpc_estado,ADMPN_COD_SERVC,admpn_mnt_recar,admpc_apl_punto,
                         admpv_campana,admpv_clave,ADMPN_MNTDCTO,admpv_cod_paqdat)
values('PAQINT200MB','20','Paquete 200 MB',110,0,'A',NULL,0,'T','Oct-11',NULL,NULL,'44-100008');     

insert into PCLUB.admpt_premio(admpv_id_procla,admpv_cod_tpopr,admpv_desc,admpn_puntos,admpn_pago,admpc_estado,ADMPN_COD_SERVC,admpn_mnt_recar,admpc_apl_punto,
                         admpv_campana,admpv_clave,ADMPN_MNTDCTO,admpv_cod_paqdat)
values('PAQINT100MBPRE','12','Paquete 100 MB',75,0,'A',NULL,0,'T','Oct-11',NULL,NULL,'ICPCX30D100M');     

insert into PCLUB.admpt_premio(admpv_id_procla,admpv_cod_tpopr,admpv_desc,admpn_puntos,admpn_pago,admpc_estado,ADMPN_COD_SERVC,admpn_mnt_recar,admpc_apl_punto,
                         admpv_campana,admpv_clave,ADMPN_MNTDCTO,admpv_cod_paqdat)
values('PAQINT200MBPRE','12','Paquete 200 MB',100,0,'A',NULL,0,'T','Oct-11',NULL,NULL,'ICPCX30D200M');

/*------------ DATOS TIPO PREMIO POR TIPO DE CLIENTE----------------*/

INSERT INTO PCLUB.ADMPT_TIPO_PREMCLIE(ADMPV_COD_TPOPR,ADMPV_COD_TPOCL)
VALUES('20','2');     

COMMIT;









