--****************************************************************
-- Nombre SP           :  AUTHCLAROCLUB
-- Propósito           :  Obtiene la modalidad del cliente
-- Input               :  MSISDN - Telefono del usuario
--                        CLAVE
--
-- Output              :  COD_RETORNO    --> Código de Error (si se presento)
--                        K_MSJERROR     --> Mensaje de Error
--                        MOD_CLIENTE    --> Modalida del Cliente
-- Creado por          :  Miguel Leiva
-- Fec Creación        :  07/10/2010
-- Fec Actualización   :
--****************************************************************
create or replace procedure USRCAE.AUTHCLAROCLUB(
MSISDN IN VARCHAR2,
CLAVE IN VARCHAR2,
COD_RETORNO OUT NUMBER, 
K_MSJERROR OUT VARCHAR2,
MOD_CLIE OUT VARCHAR2) is
NO_CLIENTE      exception;
NO_PARAMETROS       exception;
NO_CLAVE      exception;
V_EXISTE NUMBER:=0; 
V_CLAVE VARCHAR2(30):=''; 
begin  
   if MSISDN is null then
     raise NO_PARAMETROS;
   end if ;
   if CLAVE is null then
     raise NO_PARAMETROS;
   end if ;

 select COUNT(CODIGOUSUARIO) INTO V_EXISTE
 from usuario t
 where TRIM(CODIGOUSUARIO)=MSISDN and ESTADOUSUARIO='A'
 and ((CLIENTE='B2E' AND TIPO='CORPORATIVO') OR 
 (CLIENTE='CONTROL' AND TIPO='CONSUMER') OR
 (CLIENTE='POSTPAGO' AND TIPO='CONSUMER') OR
 (CLIENTE='PREPAGO' AND TIPO='CONSUMER'));
 if V_EXISTE=0 then
     raise NO_CLIENTE;
   end if ;
 
 select TRIM(CLAVE), CLIENTE INTO V_CLAVE, MOD_CLIE
 from usuario t
 where TRIM(CODIGOUSUARIO)=MSISDN and ESTADOUSUARIO='A'
 and ((CLIENTE='B2E' AND TIPO='CORPORATIVO') OR 
 (CLIENTE='CONTROL' AND TIPO='CONSUMER') OR
 (CLIENTE='POSTPAGO' AND TIPO='CONSUMER') OR
 (CLIENTE='PREPAGO' AND TIPO='CONSUMER'));

 if V_CLAVE!=CLAVE then
     raise NO_CLAVE;
   end if ;
   
 COD_RETORNO:=0;
 K_MSJERROR:='Éxito';
exception
    when NO_PARAMETROS then
         COD_RETORNO:=-1;
         K_MSJERROR:='Por errores de BD o conexión, ajenos al proceso de validación en sí';
    when NO_CLIENTE then
         COD_RETORNO:=1;
         K_MSJERROR:='La línea no está registrada en Claro en Línea';
    when NO_CLAVE then
         COD_RETORNO:=2;
         K_MSJERROR:='La clave no pertenece a la línea';
         MOD_CLIE:='';
end AUTHCLAROCLUB;