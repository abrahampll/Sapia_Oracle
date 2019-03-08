WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RRRR';

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_maestra_cust_acc_id');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_deuda_2');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_recfac');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_deuda_3');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_DEUDA');


END;
/

CREATE TABLE DM.DW_spss2_maestra_cust_acc_id NOLOGGING AS
SELECT DISTINCT b.customer_account_id
,b.cust_account
FROM dwo.dw_m_customer_account b
WHERE EXISTS(SELECT 1 FROM DwM.DW_maestra_postpago m WHERE m.customer_id=b.cust_account AND m.mes='&1');

create table DM.DW_spss2_deuda_2 nologging parallel 2 as 
select periodo, customer_id,bill_id,
case when (last_day(to_date('&1','yyyymm')) - due_date)<0 then 0 else (last_day(to_date('&1', 'YYYYMM'))) - due_date) end  as vf2_160 from
(
select '&1' as periodo, a.cust_account as customer_id, b.due_date,b.bill_id,
row_number() over (partition by cust_account order by b.due_date asc) rw from dwo.dw_m_cob_balance b
inner join DM.DW_spss2_maestra_cust_acc_id a on a.customer_account_id=b.customer_account_id 
where bill_type_id=9716 and status_id in (1019,281601,1016,1014)  and period_debt>='201401' and period_debt<='&1')
where rw=1;

create table DM.DW_spss2_recfac nologging as
select '&1' as periodo, a.cust_account as customer_id, b.due_date as fec_ven,b.bill_id,
row_number() over (partition by cust_account order by b.due_date asc) rw from dwo.dw_m_customer_bill b
inner join DM.DW_spss2_maestra_cust_acc_id a on a.customer_account_id=b.customer_account_id
where b.bill_type_id=9716
and b.due_date between to_date('&1','yyyymm') and last_day(to_date('&1','yyyymm'))
and not exists (select 1 from DM.DW_spss2_deuda_2 c where c.bill_id=b.bill_id and c.periodo='&1');

create table DM.DW_spss2_deuda_3 nologging as
select periodo, customer_id, bill_id,
case when fec_ven<applied_date and applied_date > last_day(to_date('&1','yyyymm')) then last_day(to_date('&1','yyyymm')) - fec_ven  else 0 end vf2_160
from
(select b.periodo, b.customer_id, b.bill_id,c.applied_date, b.fec_ven,
row_number() over (partition by c.bill_id order by c.applied_date desc) rw
from DM.DW_spss2_recfac b
inner join dwo.payment_applied_bill c on b.bill_id=c.bill_id )
where rw=1;

create table DM.DW_SPSS2_DEUDA
(
periodo     CHAR(6),
customer_id VARCHAR2(254),
bill_id     NUMBER(15),
vf2_160     NUMBER
) nologging;

insert /*+ append nologging*/ into DM.DW_spss2_deuda
select periodo, customer_id,bill_id, vf2_160 from
(
select periodo, customer_id,bill_id, vf2_160, row_number() over(partition by customer_id order by vf2_160 desc )rw
from
(
select * from DM.DW_spss2_deuda_2
union 
select * from DM.DW_spss2_deuda_3
)) where rw=1 ;
commit;

INSERT INTO DWM.DW_spss2_deuda SELECT * FROM DM.DW_spss2_deuda; 
COMMIT;

DROP TABLE DM.DW_spss2_maestra_cust_acc_id PURGE;
DROP TABLE DM.DW_spss2_deuda_2 PURGE;
DROP TABLE DM.DW_spss2_recfac PURGE;
DROP TABLE DM.DW_spss2_deuda_3 PURGE;
DROP TABLE DM.DW_SPSS2_DEUDA PURGE;

EXIT;