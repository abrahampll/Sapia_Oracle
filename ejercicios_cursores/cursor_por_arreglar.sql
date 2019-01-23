DECLARE 
  CURSOR historico (idEmpleado hr.job_history.employee_id%TYPE) 
  IS
  SELECT start_date, end_date,job_id
  FROM job_history 
  WHERE employee_id  <> idEmpleado;
  
  registroEmpleado historico%ROWTYPE;
BEGIN
  OPEN historico(1);

  FETCH historico INTO registroEmpleado;
    Dbms_Output.put_line(registroEmpleado.start_date || '' || registroEmpleado.end_date);
  CLOSE historico;
  
  /*FOR registroEmpleado IN historico
    LOOP
      DBMS_OUTPUT.put_line(registroEmpleado.start_date || '' registroEmpleado.end_date);
    END LOOP;
  */
END; 