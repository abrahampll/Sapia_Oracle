delete PCLUB.admpt_concepto
where ADMPV_DESC = 'TRANSFERENCIA CLARO A LATAM';

delete PCLUB.admpt_concepto
where ADMPV_DESC = 'TRANSFERENCIA LATAM A CLARO';

commit;
