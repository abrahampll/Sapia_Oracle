DECLARE 
  CURSOR historico (idEmpleado hr.job_history.employee_id%TYPE) 
  IS
  SELECT start_date, end_date,job_id
  FROM job_history 
  WHERE employee_id > idEmpleado;
  
  
  registroEmpleado historico%ROWTYPE;
BEGIN
  OPEN historico(102);
  LOOP 
    FETCH historico INTO registroEmpleado;
    Dbms_Output.put_line(registroEmpleado.start_date || ' ' ||  registroEmpleado.job_id);
     EXIT WHEN historico%NOTFOUND; -- Último registro.

  END LOOP;
  DBMS_OUTPUT.PUT_LINE
         ('Número de empleados procesados ' || historico%ROWCOUNT);
    CLOSE historico;
END; 


  ---------------------------------------------------------
  
   
----------------------------------


 DECLARE
       CURSOR cursor_empleado(idEmpleado hr.job_history.employee_id%TYPE)  IS 
       SELECT A.FIRST_NAME,A.Last_Name,A.Email 
       FROM employees A
       WHERE employee_id  > idEmpleado;
       cepm_rec cursor_empleado%ROWTYPE; 
       vid NUMBER(10);
     BEGIN
       vid := 102;
       DBMS_OUTPUT.PUT_LINE
         ('Datos de los empleados con id mayores a 102 ' || vid);
       FOR cemp_rec IN cursor_empleado(vid)
       LOOP
         DBMS_OUTPUT.PUT_LINE
           (cemp_rec.FIRST_NAME || ' ' || cemp_rec.Last_Name || ' '|| cemp_rec.Email);
       END LOOP;
     END;
     
--------------------------------------------------

  DECLARE
   CURSOR cursor_empleado(idEmpleado hr.job_history.employee_id%TYPE)  IS
        SELECT A.FIRST_NAME,A.Last_Name,A.Email 
       FROM employees A
       WHERE employee_id  > idEmpleado;
       cepm_rec cursor_empleado%ROWTYPE; 
        vid NUMBER(10); 
     BEGIN
       vid := 102;
       DBMS_OUTPUT.PUT_LINE
         ('Datos de los empleados con id mayores a 102 ' || vid);
       OPEN cursor_empleado(vid);
       LOOP
         FETCH cursor_empleado INTO cepm_rec;
         DBMS_OUTPUT.PUT_LINE(cepm_rec.FIRST_NAME || ' ' || cepm_rec.Last_Name || ' '|| cepm_rec.Email);
         EXIT WHEN cursor_empleado%NOTFOUND; -- Último registro.
       END LOOP;
       DBMS_OUTPUT.PUT_LINE
         ('Número de empleados procesados ' || cursor_empleado%ROWCOUNT);
       CLOSE cursor_empleado;
     END;     