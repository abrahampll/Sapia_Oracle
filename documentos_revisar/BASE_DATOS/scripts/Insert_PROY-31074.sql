INSERT INTO PCLUB.ADMPT_PARAMSIST (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
VALUES ((SELECT MAX(TO_NUMBER(ADMPC_COD_PARAM)) + 1 FROM PCLUB.ADMPT_PARAMSIST), 'LATAM DIA MADRE CANT DIAS VENCIDO', '5');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (1, 3, 'E95', '000000000070025915', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (2, 3, 'E95', '000000000070025916', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (3, 3, 'E95', '000000000070025167', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (4, 3, 'E95', '000000000070025168', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (5, 3, 'E95', '000000000070024844', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (6, 3, 'E95', '000000000070024845', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (7, 3, 'F07', '000000000070025915', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (8, 3, 'F07', '000000000070025916', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (9, 3, 'F07', '000000000070025167', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (10, 3, 'F07', '000000000070025168', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (11, 3, 'F07', '000000000070024844', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (12, 3, 'F07', '000000000070024845', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (13, 3, 'F07', '000000000070025829', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (14, 3, 'F07', '000000000070025833', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (15, 3, 'F07', '000000000070025165', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (16, 3, 'F07', '000000000070026159', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (17, 3, 'F07', '000000000070026442', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (18, 3, 'F07', '000000000070027752', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (19, 3, 'F06', '000000000070025915', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (20, 3, 'F06', '000000000070025916', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (21, 3, 'F06', '000000000070025167', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (22, 3, 'F06', '000000000070025168', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (23, 3, 'F06', '000000000070024844', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (24, 3, 'F06', '000000000070024845', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (25, 3, 'F06', '000000000070025829', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (26, 3, 'F06', '000000000070025833', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (27, 3, 'F06', '000000000070025165', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (28, 3, 'F06', '000000000070026159', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (29, 3, 'F06', '000000000070026442', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (30, 3, 'F06', '000000000070027752', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (31, 3, 'F06', '000000000070027720', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (32, 3, 'F06', '000000000070025979', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (33, 3, 'F06', '000000000070026718', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (34, 3, 'F06', '000000000070026186', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (35, 3, 'F06', '000000000070026187', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (36, 3, 'F06', '000000000070026327', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (37, 3, 'F06', '000000000070027937', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (38, 3, 'F06', '000000000070027977', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (39, 3, 'H15', '000000000070025915', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (40, 3, 'H15', '000000000070025916', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (41, 3, 'H15', '000000000070025167', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (42, 3, 'H15', '000000000070025168', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (43, 3, 'H15', '000000000070024844', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (44, 3, 'H15', '000000000070024845', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (45, 3, 'H15', '000000000070025829', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (46, 3, 'H15', '000000000070025833', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (47, 3, 'H15', '000000000070025165', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (48, 3, 'H15', '000000000070026159', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (49, 3, 'H15', '000000000070026442', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (50, 3, 'H15', '000000000070027752', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (51, 3, 'H15', '000000000070027720', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (52, 3, 'H15', '000000000070025979', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (53, 3, 'H15', '000000000070026718', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (54, 3, 'H15', '000000000070026186', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (55, 3, 'H15', '000000000070026187', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (56, 3, 'H15', '000000000070026327', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (57, 3, 'H15', '000000000070027937', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (58, 3, 'H15', '000000000070027977', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (59, 3, 'H15', '000000000070025668', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (60, 3, 'H15', '000000000070025669', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (61, 3, 'H15', '000000000070025670', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (62, 3, 'H15', '000000000070025964', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (63, 3, 'H15', '000000000070025965', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (64, 3, 'H15', '000000000070027979', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (65, 3, 'H15', '000000000070027980', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (66, 3, 'F13', '000000000070025915', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (67, 3, 'F13', '000000000070025916', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (68, 3, 'F13', '000000000070025167', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (69, 3, 'F13', '000000000070025168', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (70, 3, 'F13', '000000000070024844', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (71, 3, 'F13', '000000000070024845', 1000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (72, 3, 'F13', '000000000070025829', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (73, 3, 'F13', '000000000070025833', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (74, 3, 'F13', '000000000070025165', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (75, 3, 'F13', '000000000070026159', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (76, 3, 'F13', '000000000070026442', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (77, 3, 'F13', '000000000070027752', 1500, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (78, 3, 'F13', '000000000070027720', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (79, 3, 'F13', '000000000070025979', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (80, 3, 'F13', '000000000070026718', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (81, 3, 'F13', '000000000070026186', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (82, 3, 'F13', '000000000070026187', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (83, 3, 'F13', '000000000070026327', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (84, 3, 'F13', '000000000070027937', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (85, 3, 'F13', '000000000070027977', 2000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (86, 3, 'F13', '000000000070025668', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (87, 3, 'F13', '000000000070025669', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (88, 3, 'F13', '000000000070025670', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (89, 3, 'F13', '000000000070025964', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (90, 3, 'F13', '000000000070025965', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (91, 3, 'F13', '000000000070027979', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (92, 3, 'F13', '000000000070027980', 3000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (93, 3, 'F13', '000000000070028002', 4000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (94, 3, 'F13', '000000000070026981', 4000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (95, 3, 'F13', '000000000070026982', 4000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (96, 3, 'F13', '000000000070027100', 4000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_PLANES_MILLAS (SYLPMN_IDENTIFICADOR, SYLCN_IDENTIFICADOR, SYMPV_PLAN, SYMPV_MODELO, SYMPN_MILLAS, SYMPC_ESTADO, SYMPD_FEC_REG, SYMPV_USU_REG, SYMPD_FEC_MOD, SYMPV_USU_MOD)
values (97, 3, 'F13', '000000000070027101', 4000, 'A', to_date('25-04-2018', 'dd-mm-yyyy'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_CAMPANA (SYLCN_IDENTIFICADOR, SYLCV_COD_CAMPANA, SYLCV_DESCRIPCION, SYLCD_FECHA_INI, SYLCD_FECHA_FIN, SYLCC_ESTADO, SYLCD_FEC_REG, SYLCV_USU_REG, SYLCD_FEC_MOD, SYLCV_USU_MOD)
values (1, 'CK', 'De Claro Puntos a Millas', to_date('01-01-2018', 'dd-mm-yyyy'), to_date('31-12-2018', 'dd-mm-yyyy'), 'A', to_date('24-04-2018 19:09:16', 'dd-mm-yyyy hh24:mi:ss'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_CAMPANA (SYLCN_IDENTIFICADOR, SYLCV_COD_CAMPANA, SYLCV_DESCRIPCION, SYLCD_FECHA_INI, SYLCD_FECHA_FIN, SYLCC_ESTADO, SYLCD_FEC_REG, SYLCV_USU_REG, SYLCD_FEC_MOD, SYLCV_USU_MOD)
values (2, 'KC', 'De Millas a Claro Puntos', to_date('01-01-2018', 'dd-mm-yyyy'), to_date('31-12-2018', 'dd-mm-yyyy'), 'A', to_date('24-04-2018 19:09:16', 'dd-mm-yyyy hh24:mi:ss'), 'CARINI', null, '');

insert into PCLUB.SYSFT_LATAM_CAMPANA (SYLCN_IDENTIFICADOR, SYLCV_COD_CAMPANA, SYLCV_DESCRIPCION, SYLCD_FECHA_INI, SYLCD_FECHA_FIN, SYLCC_ESTADO, SYLCD_FEC_REG, SYLCV_USU_REG, SYLCD_FEC_MOD, SYLCV_USU_MOD)
values (3, 'DM2018', 'Dia de la Madre 2018', to_date('19-04-2018', 'dd-mm-yyyy'), to_date('13-05-2018', 'dd-mm-yyyy'), 'A', to_date('24-04-2018 19:09:16', 'dd-mm-yyyy hh24:mi:ss'), 'CARINI', null, '');

COMMIT;