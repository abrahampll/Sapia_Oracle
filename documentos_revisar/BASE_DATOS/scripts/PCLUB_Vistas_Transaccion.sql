create or replace view PCLUB.v_equipo as
select cod_equ , des_equ , rownum fila from (
select eq.admpv_cod_equ cod_equ , eq.admpv_dsc_equ des_equ
from pclub.admpt_equipo eq , pclub.admpt_bon_renovespec re
where eq.admpv_cod_equ = re.admpv_cod_equ
  and re.admpv_cod_per = (select admpv_valor from pclub.admpt_paramsist where admpc_cod_param = '102')
  and re.admpv_cod_segm = (select admpv_valor from pclub.admpt_paramsist where admpc_cod_param = '101')
group by eq.admpv_cod_equ , eq.admpv_dsc_equ
order by 2 asc);

create or replace view PCLUB.v_plan as
select cod_plan, des_plan, rownum fila from (
select pl.admpn_cod_plan cod_plan,pl.admpv_des_plan des_plan
from pclub.admpt_tipo_plan pl , pclub.admpt_bon_renovespec re
where pl.admpn_cod_plan = re.admpn_cod_plan
  and re.admpv_cod_per = (select admpv_valor from pclub.admpt_paramsist where admpc_cod_param = '102')
  and re.admpv_cod_segm = (select admpv_valor from pclub.admpt_paramsist where admpc_cod_param = '101')
group by pl.admpn_cod_plan,pl.admpv_des_plan
order by 2 asc);
