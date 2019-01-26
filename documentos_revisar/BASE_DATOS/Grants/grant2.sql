CREATE SYNONYM USRPCLUB.admpt_serv_pend FOR PCLUB.admpt_serv_pend;
GRANT SELECT, INSERT, DELETE, UPDATE  ON PCLUB.admpt_serv_pend TO USRPCLUB;
CREATE SYNONYM USRPCLUB.admpt_serv_pen_sq FOR PCLUB.admpt_serv_pen_sq;
GRANT SELECT ON PCLUB.admpt_serv_pen_sq TO USRPCLUB;

