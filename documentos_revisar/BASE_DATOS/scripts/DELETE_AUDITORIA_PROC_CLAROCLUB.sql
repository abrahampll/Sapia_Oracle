delete from  PCLUB.AUDITORIA_PROC_CLAROCLUB A
WHERE TO_DATE(TO_CHAR(A.Aud_Fecha_Registro, 'MM/DD/YYYY'), 'MM/DD/YYYY') >='01/06/2017' -- esta fecha es referencial, es configurable a solicitud del soap
and   TO_DATE(TO_CHAR(A.Aud_Fecha_Registro, 'MM/DD/YYYY'), 'MM/DD/YYYY') <='30/04/2017'; -- esta fecha es referencial, es configurable a solicitud del soap
commit ;
