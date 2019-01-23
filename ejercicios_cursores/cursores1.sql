 DECLARE
   CURSOR cursor_empleado IS
     SELECT A.FIRST_NAME, A.Last_Name, A.Email FROM employees A;
   cepm_emp cursor_empleado%ROWTYPE;
 BEGIN
   FOR cepm_emp IN cursor_empleado LOOP
     DBMS_OUTPUT.PUT_LINE(cepm_emp.FIRST_NAME || '  ' ||
                          cepm_emp.Last_Name || '  ' || cepm_emp.Email);
   END LOOP;
   --DBMS_OUTPUT.PUT_LINE('Número de empleados procesados ' ||  cepm_emp%ROWCOUNT);
 END;
