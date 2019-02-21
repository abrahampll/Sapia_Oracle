--****************************************************************
-- Nombre SP           :  CTRLSI_IDENTIFICA_CAMBIOS
-- Propósito           :  Identifica cambios en la base de datos PCLUBDB
-- Input               :  p_flag - Identificador de Query
-- Output              :  v_retorno    --> Descripcion de error (si se presento)
-- Creado por          :  Miguel Neyra
-- Fec Creación        :  11/03/2014
-- Fec Actualización   :
--****************************************************************
create or replace procedure pclub.CTRLSI_IDENTIFICA_CAMBIOS(p_flag    in NUMBER,
                                                      v_retorno out VARCHAR2) is
  INVALID_PARAM exception;  
  TYPE loc_array_type01 IS TABLE OF PCLUB.CTRLT_QUERY_RESULT%ROWTYPE INDEX BY binary_integer;
  TYPE loc_array_type02 IS TABLE OF PCLUB.CTRLT_QUERY_CAB%ROWTYPE INDEX BY binary_integer;
  v_array_post loc_array_type01;
  v_array_pre  loc_array_type01;
  v_array_cab  loc_array_type02;
  v_flag       NUMBER;
  TYPE bin_array IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  data_array       bin_array;  
  v_accion         VARCHAR2(4000);
  v_cont_post      integer := 0;
  v_cont_pre       integer := 0;
  v_scn            VARCHAR2(20);
  v_scnpre         VARCHAR2(20);
  v_scnpost        VARCHAR2(20);
  v_flagexec       NUMBER;
  v_fecha_ins      VARCHAR2(50);
  my_cursor        INTEGER;
  SQLSEN           VARCHAR2(4000);
  FILAS_PROCESADAS INTEGER;
  Lcntr            INTEGER;
  valor            VARCHAR2(100);
  V_CANTIDAD_A     number := 0;
  V_CANTIDAD       number := 0;
  CURSOR R_CAMBIOS(p_scnpre VARCHAR2, p_scnpost VARCHAR2) IS(
    select CTRLV_CODIGO,
           CTRLN_FLAG,
           CTRLV_VALOR04,
           CTRLV_VALOR05,
           CTRLV_VALOR06,
           CTRLV_VALOR07,
           CTRLV_VALOR08,
           CTRLV_VALOR09,
           CTRLV_VALOR010,
           CTRLV_VALOR011,
           CTRLV_VALOR012,
           CTRLV_VALOR013,
           CTRLV_VALOR014,
           CTRLV_VALOR015,
           CTRLV_VALOR016,
           CTRLV_VALOR017,
           CTRLV_VALOR018,
           CTRLV_VALOR019,
           CTRLV_VALOR020,
           CTRLV_VALOR021,
           CTRLV_VALOR022,
           CTRLV_VALOR023,
           CTRLV_VALOR024,
           CTRLV_VALOR025,
           CTRLV_VALOR026,
           CTRLV_VALOR027,
           CTRLV_VALOR028,
           CTRLV_VALOR029,
           CTRLV_VALOR030,
           CTRLV_VALOR031,
           CTRLV_VALOR032,
           CTRLV_VALOR033,
           CTRLV_VALOR034,
           CTRLV_VALOR035,
           CTRLV_VALOR036,
           CTRLV_VALOR037,
           CTRLV_VALOR038,
           CTRLV_VALOR039,
           CTRLV_VALOR040,
           CTRLV_VALOR041,
           CTRLV_VALOR042,
           CTRLV_VALOR043,
           CTRLV_VALOR044,
           CTRLV_VALOR045,
           CTRLV_VALOR046,
           CTRLV_VALOR047,
           CTRLV_VALOR048,
           CTRLV_VALOR049,
           CTRLV_VALOR050
      from PCLUB.CTRLT_QUERY_RESULT R
     where R.CTRLV_SCNREG = p_scnpost
       and R.CTRLN_FLAG = v_flag
    MINUS
    select CTRLV_CODIGO,
           CTRLN_FLAG,
           CTRLV_VALOR04,
           CTRLV_VALOR05,
           CTRLV_VALOR06,
           CTRLV_VALOR07,
           CTRLV_VALOR08,
           CTRLV_VALOR09,
           CTRLV_VALOR010,
           CTRLV_VALOR011,
           CTRLV_VALOR012,
           CTRLV_VALOR013,
           CTRLV_VALOR014,
           CTRLV_VALOR015,
           CTRLV_VALOR016,
           CTRLV_VALOR017,
           CTRLV_VALOR018,
           CTRLV_VALOR019,
           CTRLV_VALOR020,
           CTRLV_VALOR021,
           CTRLV_VALOR022,
           CTRLV_VALOR023,
           CTRLV_VALOR024,
           CTRLV_VALOR025,
           CTRLV_VALOR026,
           CTRLV_VALOR027,
           CTRLV_VALOR028,
           CTRLV_VALOR029,
           CTRLV_VALOR030,
           CTRLV_VALOR031,
           CTRLV_VALOR032,
           CTRLV_VALOR033,
           CTRLV_VALOR034,
           CTRLV_VALOR035,
           CTRLV_VALOR036,
           CTRLV_VALOR037,
           CTRLV_VALOR038,
           CTRLV_VALOR039,
           CTRLV_VALOR040,
           CTRLV_VALOR041,
           CTRLV_VALOR042,
           CTRLV_VALOR043,
           CTRLV_VALOR044,
           CTRLV_VALOR045,
           CTRLV_VALOR046,
           CTRLV_VALOR047,
           CTRLV_VALOR048,
           CTRLV_VALOR049,
           CTRLV_VALOR050
      from PCLUB.CTRLT_QUERY_RESULT R
     where R.CTRLV_SCNREG = p_scnpre
       and r.CTRLN_FLAG = v_flag)
    UNION (select CTRLV_CODIGO,
                  CTRLN_FLAG,
                  CTRLV_VALOR04,
                  CTRLV_VALOR05,
                  CTRLV_VALOR06,
                  CTRLV_VALOR07,
                  CTRLV_VALOR08,
                  CTRLV_VALOR09,
                  CTRLV_VALOR010,
                  CTRLV_VALOR011,
                  CTRLV_VALOR012,
                  CTRLV_VALOR013,
                  CTRLV_VALOR014,
                  CTRLV_VALOR015,
                  CTRLV_VALOR016,
                  CTRLV_VALOR017,
                  CTRLV_VALOR018,
                  CTRLV_VALOR019,
                  CTRLV_VALOR020,
                  CTRLV_VALOR021,
                  CTRLV_VALOR022,
                  CTRLV_VALOR023,
                  CTRLV_VALOR024,
                  CTRLV_VALOR025,
                  CTRLV_VALOR026,
                  CTRLV_VALOR027,
                  CTRLV_VALOR028,
                  CTRLV_VALOR029,
                  CTRLV_VALOR030,
                  CTRLV_VALOR031,
                  CTRLV_VALOR032,
                  CTRLV_VALOR033,
                  CTRLV_VALOR034,
                  CTRLV_VALOR035,
                  CTRLV_VALOR036,
                  CTRLV_VALOR037,
                  CTRLV_VALOR038,
                  CTRLV_VALOR039,
                  CTRLV_VALOR040,
                  CTRLV_VALOR041,
                  CTRLV_VALOR042,
                  CTRLV_VALOR043,
                  CTRLV_VALOR044,
                  CTRLV_VALOR045,
                  CTRLV_VALOR046,
                  CTRLV_VALOR047,
                  CTRLV_VALOR048,
                  CTRLV_VALOR049,
                  CTRLV_VALOR050
             from PCLUB.CTRLT_QUERY_RESULT R
            where R.CTRLV_SCNREG = p_scnpre
              and r.CTRLN_FLAG = v_flag
           MINUS
           select CTRLV_CODIGO,
                  CTRLN_FLAG,
                  CTRLV_VALOR04,
                  CTRLV_VALOR05,
                  CTRLV_VALOR06,
                  CTRLV_VALOR07,
                  CTRLV_VALOR08,
                  CTRLV_VALOR09,
                  CTRLV_VALOR010,
                  CTRLV_VALOR011,
                  CTRLV_VALOR012,
                  CTRLV_VALOR013,
                  CTRLV_VALOR014,
                  CTRLV_VALOR015,
                  CTRLV_VALOR016,
                  CTRLV_VALOR017,
                  CTRLV_VALOR018,
                  CTRLV_VALOR019,
                  CTRLV_VALOR020,
                  CTRLV_VALOR021,
                  CTRLV_VALOR022,
                  CTRLV_VALOR023,
                  CTRLV_VALOR024,
                  CTRLV_VALOR025,
                  CTRLV_VALOR026,
                  CTRLV_VALOR027,
                  CTRLV_VALOR028,
                  CTRLV_VALOR029,
                  CTRLV_VALOR030,
                  CTRLV_VALOR031,
                  CTRLV_VALOR032,
                  CTRLV_VALOR033,
                  CTRLV_VALOR034,
                  CTRLV_VALOR035,
                  CTRLV_VALOR036,
                  CTRLV_VALOR037,
                  CTRLV_VALOR038,
                  CTRLV_VALOR039,
                  CTRLV_VALOR040,
                  CTRLV_VALOR041,
                  CTRLV_VALOR042,
                  CTRLV_VALOR043,
                  CTRLV_VALOR044,
                  CTRLV_VALOR045,
                  CTRLV_VALOR046,
                  CTRLV_VALOR047,
                  CTRLV_VALOR048,
                  CTRLV_VALOR049,
                  CTRLV_VALOR050
             from PCLUB.CTRLT_QUERY_RESULT R
            where R.CTRLV_SCNREG = p_scnpost
              and r.CTRLN_FLAG = v_flag);

BEGIN
  --
  v_retorno := 'ERROR';
  
  IF p_flag IS NULL OR p_flag < 1 THEN
    RAISE INVALID_PARAM;
  END IF;

  v_flag := p_flag;

  SELECT T.CTRLN_FLAGEXEC
    INTO v_flagexec
    FROM PCLUB.CTRLT_QUERY T
   WHERE T.CTRLN_FLAG = v_flag;

  IF v_flagexec = 0 THEN
    SELECT T.CTRLV_SCNPRE, T.CTRLV_SCNPOST
      INTO v_scnpre, v_scnpost
      FROM PCLUB.CTRLT_QUERY T
     WHERE T.CTRLN_FLAG = v_flag;
  
    IF v_scnpre IS NOT NULL THEN
      DELETE FROM PCLUB.CTRLT_QUERY_RESULT R
       WHERE R.CTRLN_FLAG = v_flag
         AND R.CTRLV_SCNREG = v_scnpost;
    
      UPDATE PCLUB.CTRLT_QUERY R
         SET R.CTRLV_SCNPRE = NULL, R.CTRLV_SCNPOST = v_scnpre
       WHERE R.CTRLN_FLAG = v_flag;
    
      COMMIT;
    END IF;
  ELSE
    UPDATE PCLUB.CTRLT_QUERY T
       SET T.CTRLN_FLAGEXEC = 0
     WHERE T.CTRLN_FLAG = v_flag;
    COMMIT;
  END IF;

  --INICIO: REGISTRAR COPIA RESULTADO QUERY
  SELECT count(C.CTRLV_CAMPO)
    INTO V_CANTIDAD_A
    FROM PCLUB.CTRLT_QUERY_CAB C
   where C.CTRLN_FLAG = v_flag;

  V_CANTIDAD := V_CANTIDAD_A - 3;

  SELECT * BULK COLLECT
    INTO v_array_cab
    FROM PCLUB.CTRLT_QUERY_CAB C
   WHERE C.CTRLN_ORDEN > 3
     and C.CTRLN_FLAG = v_flag
   order by C.CTRLN_ORDEN;

  v_scn := to_char(sysdate, 'ddmmyyyyHH24MISS');

  SELECT T.CTRLB_QUERY, T.CTRLV_SCNPOST
    INTO SQLSEN, v_scnpost
    FROM PCLUB.CTRLT_QUERY T
   WHERE T.CTRLN_FLAG = v_flag;

  if (v_scnpost is not null) then
    UPDATE PCLUB.CTRLT_QUERY T
       SET T.CTRLV_SCNPRE = v_scnpost, T.CTRLV_SCNPOST = v_scn
     WHERE T.CTRLN_FLAG = v_flag;
    COMMIT;
  else
    UPDATE PCLUB.CTRLT_QUERY T
       SET T.CTRLV_SCNPOST = v_scn
     WHERE T.CTRLN_FLAG = v_flag;
    COMMIT;
  end if;

  my_cursor := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE(my_cursor, SQLSEN, DBMS_SQL.NATIVE);

  FOR Lcntr IN 1 .. 50 LOOP
    data_array(Lcntr) := NULL;
  END LOOP;

  FOR Lcntr IN 1 .. V_CANTIDAD_A LOOP
    DBMS_SQL.DEFINE_COLUMN(my_cursor, Lcntr, valor, 100);
  END LOOP;

  FILAS_PROCESADAS := DBMS_SQL.EXECUTE(my_cursor);

  LOOP
    IF DBMS_SQL.FETCH_ROWS(my_cursor) <> 0 THEN
      FOR Lcntr IN 1 .. V_CANTIDAD_A LOOP
        DBMS_SQL.COLUMN_VALUE(my_cursor, Lcntr, data_array(Lcntr));
      END LOOP;
    
      INSERT INTO PCLUB.CTRLT_QUERY_RESULT
        (CTRLV_CODIGO,
         CTRLV_SCNREG,
         CTRLN_FLAG,
         CTRLV_VALOR04,
         CTRLV_VALOR05,
         CTRLV_VALOR06,
         CTRLV_VALOR07,
         CTRLV_VALOR08,
         CTRLV_VALOR09,
         CTRLV_VALOR010,
         CTRLV_VALOR011,
         CTRLV_VALOR012,
         CTRLV_VALOR013,
         CTRLV_VALOR014,
         CTRLV_VALOR015,
         CTRLV_VALOR016,
         CTRLV_VALOR017,
         CTRLV_VALOR018,
         CTRLV_VALOR019,
         CTRLV_VALOR020,
         CTRLV_VALOR021,
         CTRLV_VALOR022,
         CTRLV_VALOR023,
         CTRLV_VALOR024,
         CTRLV_VALOR025,
         CTRLV_VALOR026,
         CTRLV_VALOR027,
         CTRLV_VALOR028,
         CTRLV_VALOR029,
         CTRLV_VALOR030,
         CTRLV_VALOR031,
         CTRLV_VALOR032,
         CTRLV_VALOR033,
         CTRLV_VALOR034,
         CTRLV_VALOR035,
         CTRLV_VALOR036,
         CTRLV_VALOR037,
         CTRLV_VALOR038,
         CTRLV_VALOR039,
         CTRLV_VALOR040,
         CTRLV_VALOR041,
         CTRLV_VALOR042,
         CTRLV_VALOR043,
         CTRLV_VALOR044,
         CTRLV_VALOR045,
         CTRLV_VALOR046,
         CTRLV_VALOR047,
         CTRLV_VALOR048,
         CTRLV_VALOR049,
         CTRLV_VALOR050)
      VALUES
        (data_array(1),
         v_scn,
         data_array(3),
         data_array(4),
         data_array(5),
         data_array(6),
         data_array(7),
         data_array(8),
         data_array(9),
         data_array(10),
         data_array(11),
         data_array(12),
         data_array(13),
         data_array(14),
         data_array(15),
         data_array(16),
         data_array(17),
         data_array(18),
         data_array(19),
         data_array(20),
         data_array(21),
         data_array(22),
         data_array(23),
         data_array(24),
         data_array(25),
         data_array(26),
         data_array(27),
         data_array(28),
         data_array(29),
         data_array(30),
         data_array(31),
         data_array(32),
         data_array(33),
         data_array(34),
         data_array(35),
         data_array(36),
         data_array(37),
         data_array(38),
         data_array(39),
         data_array(40),
         data_array(41),
         data_array(42),
         data_array(43),
         data_array(44),
         data_array(45),
         data_array(46),
         data_array(47),
         data_array(48),
         data_array(49),
         data_array(50));
    
      commit;
    ELSE
      EXIT;
    END IF;
  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(my_cursor);
  --FIN: REGISTRAR COPIA RESULTADO QUERY

  select T.CTRLV_SCNPRE, T.CTRLV_SCNPOST
    into v_scnpre, v_scnpost
    from PCLUB.CTRLT_QUERY T
   where T.CTRLN_FLAG = v_flag;

  IF v_scnpre IS NOT NULL then
    --identificar cambios
    FOR R IN R_CAMBIOS(v_scnpre, v_scnpost) LOOP
      v_accion := NULL;
      --consultar si elemento se encuentra en el conjunto ANTES DEL CAMBIO
      SELECT count(1)
        INTO v_cont_pre
        from PCLUB.CTRLT_QUERY_RESULT QR
       where QR.CTRLN_FLAG = v_flag
         and QR.CTRLV_SCNREG = v_scnpre
         and QR.CTRLV_CODIGO = R.CTRLV_CODIGO;
    
      --consultar si elemento se encuentra en el conjunto DESPUES DEL CAMBIO
      SELECT count(1)
        INTO v_cont_post
        from PCLUB.CTRLT_QUERY_RESULT QR
       where QR.CTRLN_FLAG = v_flag
         and QR.CTRLV_SCNREG = v_scnpost
         and QR.CTRLV_CODIGO = R.CTRLV_CODIGO;
    
      if v_cont_post = 0 and v_cont_pre = 1 then
        -- Tipo de cambio: Se ha eliminado un registro
        v_accion    := 'DELETE';
        v_fecha_ins := v_scnpre;
      elsif v_cont_post = 1 and v_cont_pre = 0 then
        -- Tipo de cambio: Se ha insertado un registro
        v_accion    := 'INSERT';
        v_fecha_ins := v_scnpost;
      elsif v_cont_post = 1 and v_cont_pre = 1 then
        -- Tipo de cambio: Se ha actualizado un registro
        v_accion := 'UPDATE';
      
        SELECT * BULK COLLECT
          INTO v_array_post
          from PCLUB.CTRLT_QUERY_RESULT QR
         where QR.CTRLN_FLAG = v_flag
           and QR.CTRLV_SCNREG = v_scnpost
           and QR.CTRLV_CODIGO = R.CTRLV_CODIGO;
      
        SELECT * BULK COLLECT
          INTO v_array_pre
          from PCLUB.CTRLT_QUERY_RESULT QR
         where QR.CTRLN_FLAG = v_flag
           and QR.CTRLV_SCNREG = v_scnpre
           and QR.CTRLV_CODIGO = R.CTRLV_CODIGO;
      
        if 1 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR04, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor04, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(1)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR04, NULL) ||
                           ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor04, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR04, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor04, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(1)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR04, NULL) ||
                           ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor04, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 2 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR05, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor05, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(2)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR05, NULL) ||
                           ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor05, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR05, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor05, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(2)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR05, NULL) ||
                           ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor05, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 3 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR06, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor06, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(3)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR06, NULL) ||
                           ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor06, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR06, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor06, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(3)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR06, NULL) ||
                           ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor06, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 4 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR07, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor07, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(4)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR07, NULL) ||
                           ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor07, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR07, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor07, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(4)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR07, NULL) ||
                           ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor07, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 5 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR08, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor08, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(5)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR08, NULL) ||
                           ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor08, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR08, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor08, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(5)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR08, NULL) ||
                           ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor08, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 6 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR09, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor09, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(6)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR09, NULL) ||
                           ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor09, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR09, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR09, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(6)
                          .CTRLV_CAMPO || ':' || nvl(R.CTRLV_VALOR09, NULL) ||
                           ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor09, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 7 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR010, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor010, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(7)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR010, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor010, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR010, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor010, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(7)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR010, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor010, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 8 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR011, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor011, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(8)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR011, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor011, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR011, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor011, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(8)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR011, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor011, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 9 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR012, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor012, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(9)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR012, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor012, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR012, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor012, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(9)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR012, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor012, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 10 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR013, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor013, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(10)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR013, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor013, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR013, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor013, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(10)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR013, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor013, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 11 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR014, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR014, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(11)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR014, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor014, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR014, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR014, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(11)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR014, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor014, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 12 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR015, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor015, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(12)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR015, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor015, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR015, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor015, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(12)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR015, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor015, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 13 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR016, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR016, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(13)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR016, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor016, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR016, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR016, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(13)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR016, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor016, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 14 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR017, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor017, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(14)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR017, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor017, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR017, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor017, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(14)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR017, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor017, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 15 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR018, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor018, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(15)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR018, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor018, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR018, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor018, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(15)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR018, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor018, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 16 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR019, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor019, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(16)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR019, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor019, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR019, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor019, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(16)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR019, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor019, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 17 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR020, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor020, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(17)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR020, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor020, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR020, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor020, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(17)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR020, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor020, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 18 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR021, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor021, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(18)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR021, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor021, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR021, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor021, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(18)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR021, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor021, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 19 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR022, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_valor022, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(19)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR022, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR022, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR022, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor022, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(19)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR022, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR022, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 20 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR023, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR023, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(20)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR023, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_valor023, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR023, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_valor023, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(20)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR023, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_valor023, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 21 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR024, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR024, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(21)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR024, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR024, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR024, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR024, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(21)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR024, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR024, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 22 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR025, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR025, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(22)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR025, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR025, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR025, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR025, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(22)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR025, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR025, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 23 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR026, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR026, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(23)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR026, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR026, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR026, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR026, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(23)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR026, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR026, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 24 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR027, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR027, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(24)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR027, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR027, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR027, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR027, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(24)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR027, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR027, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 25 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR028, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR028, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(25)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR028, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR028, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR028, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR028, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(25)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR028, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR028, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 26 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR029, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR029, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(26)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR029, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR029, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR029, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR029, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(26)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR029, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR029, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 27 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR030, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR030, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(27)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR030, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR030, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR030, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR030, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(27)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR030, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR030, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 28 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR031, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR031, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(28)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR031, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR031, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR031, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR031, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(28)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR031, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR031, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 29 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR032, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR032, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(29)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR032, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR032, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR032, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR032, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(29)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR032, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR032, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 30 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR033, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR033, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(30)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR033, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR033, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR033, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR033, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(30)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR033, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR033, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 31 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR034, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR034, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(31)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR034, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR034, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR034, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR034, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(31)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR034, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR034, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 32 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR035, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR035, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(32)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR035, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR035, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR035, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR035, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(32)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR035, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR035, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 33 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR036, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR036, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(33)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR036, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR036, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR036, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR036, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(33)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR036, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR036, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 34 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR037, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR037, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(34)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR037, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR037, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR037, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR037, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(34)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR037, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR037, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 35 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR038, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR038, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(35)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR038, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR038, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR038, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR038, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(35)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR038, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR038, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 36 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR039, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR039, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(36)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR039, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR039, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR039, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR039, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(36)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR039, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR039, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 37 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR040, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR040, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(37)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR040, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR040, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR040, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR040, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(37)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR040, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR040, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 38 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR041, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR041, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(38)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR041, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR041, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR041, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR041, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(38)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR041, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR041, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 39 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR042, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR042, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(39)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR042, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR042, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR042, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR042, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(39)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR042, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR042, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 40 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR043, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR043, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(40)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR043, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR043, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR043, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR043, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(40)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR043, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR043, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 41 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR044, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR044, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(41)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR044, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR044, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR044, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR044, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(41)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR044, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR044, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 42 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR045, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR045, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(42)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR045, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR045, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR045, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR045, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(42)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR045, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR045, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 43 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR046, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR046, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(43)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR046, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR046, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR046, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR046, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(43)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR046, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR046, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 44 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR047, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR047, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(44)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR047, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR047, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR047, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR047, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(44)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR047, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR047, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 45 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR048, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR048, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(45)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR048, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR048, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR048, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR048, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(45)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR048, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR048, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 46 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR049, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR049, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(46)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR049, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR049, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR049, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR049, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(46)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR049, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR049, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if 47 <= v_cantidad then
          if trim(NVL(R.CTRLV_VALOR050, '*')) <>
             trim(NVL(v_array_post(1).CTRLV_VALOR050, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(47)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR050, NULL) || ' por ' ||
                           nvl(v_array_post(1).CTRLV_VALOR050, NULL);
            v_fecha_ins := v_array_pre(1).CTRLV_SCNREG;
          elsif trim(NVL(R.CTRLV_VALOR050, '*')) <>
                trim(NVL(v_array_pre(1).CTRLV_VALOR050, '*')) then
            v_accion    := v_accion || ' - ' || v_array_cab(47)
                          .CTRLV_CAMPO || ':' ||
                           nvl(R.CTRLV_VALOR050, NULL) || ' por ' ||
                           nvl(v_array_pre(1).CTRLV_VALOR050, NULL);
            v_fecha_ins := v_array_post(1).CTRLV_SCNREG;
          end if;
        end if;
      
        if v_fecha_ins != v_scn then
          v_accion := NULL;
        end if;
      
      end if;
    
      INSERT INTO PCLUB.CTRLT_CAMBIOS
        (CTRLV_CODIGO,
         CTRLN_FLAG,
         CTRLV_SCNREG,
         CTRLV_VALOR04,
         CTRLV_VALOR05,
         CTRLV_VALOR06,
         CTRLV_VALOR07,
         CTRLV_VALOR08,
         CTRLV_VALOR09,
         CTRLV_VALOR10,
         CTRLV_VALOR11,
         CTRLV_VALOR12,
         CTRLV_VALOR13,
         CTRLV_VALOR14,
         CTRLV_VALOR15,
         CTRLV_VALOR16,
         CTRLV_VALOR17,
         CTRLV_VALOR18,
         CTRLV_VALOR19,
         CTRLV_VALOR20,
         CTRLV_VALOR21,
         CTRLV_VALOR22,
         CTRLV_VALOR23,
         CTRLV_VALOR24,
         CTRLV_VALOR25,
         CTRLV_VALOR26,
         CTRLV_VALOR27,
         CTRLV_VALOR28,
         CTRLV_VALOR29,
         CTRLV_VALOR30,
         CTRLV_VALOR31,
         CTRLV_VALOR32,
         CTRLV_VALOR33,
         CTRLV_VALOR34,
         CTRLV_VALOR35,
         CTRLV_VALOR36,
         CTRLV_VALOR37,
         CTRLV_VALOR38,
         CTRLV_VALOR39,
         CTRLV_VALOR40,
         CTRLV_VALOR41,
         CTRLV_VALOR42,
         CTRLV_VALOR43,
         CTRLV_VALOR44,
         CTRLV_VALOR45,
         CTRLV_VALOR46,
         CTRLV_VALOR47,
         CTRLV_VALOR48,
         CTRLV_VALOR49,
         CTRLV_VALOR50,
         CTRLV_MENSAJE)
      VALUES
        (R.CTRLV_CODIGO,
         R.CTRLN_FLAG,
         v_fecha_ins,
         R.CTRLV_VALOR04,
         R.CTRLV_VALOR05,
         R.CTRLV_VALOR06,
         R.CTRLV_VALOR07,
         R.CTRLV_VALOR08,
         R.CTRLV_VALOR09,
         R.CTRLV_VALOR010,
         R.CTRLV_VALOR011,
         R.CTRLV_VALOR012,
         R.CTRLV_VALOR013,
         R.CTRLV_VALOR014,
         R.CTRLV_VALOR015,
         R.CTRLV_VALOR016,
         R.CTRLV_VALOR017,
         R.CTRLV_VALOR018,
         R.CTRLV_VALOR019,
         R.CTRLV_VALOR020,
         R.CTRLV_VALOR021,
         R.CTRLV_VALOR022,
         R.CTRLV_VALOR023,
         R.CTRLV_VALOR024,
         R.CTRLV_VALOR025,
         R.CTRLV_VALOR026,
         R.CTRLV_VALOR027,
         R.CTRLV_VALOR028,
         R.CTRLV_VALOR029,
         R.CTRLV_VALOR030,
         R.CTRLV_VALOR031,
         R.CTRLV_VALOR032,
         R.CTRLV_VALOR033,
         R.CTRLV_VALOR034,
         R.CTRLV_VALOR035,
         R.CTRLV_VALOR036,
         R.CTRLV_VALOR037,
         R.CTRLV_VALOR038,
         R.CTRLV_VALOR039,
         R.CTRLV_VALOR040,
         R.CTRLV_VALOR041,
         R.CTRLV_VALOR042,
         R.CTRLV_VALOR043,
         R.CTRLV_VALOR044,
         R.CTRLV_VALOR045,
         R.CTRLV_VALOR046,
         R.CTRLV_VALOR047,
         R.CTRLV_VALOR048,
         R.CTRLV_VALOR049,
         R.CTRLV_VALOR050,
         v_accion);
    
      COMMIT;
    END LOOP;
  
    DELETE FROM PCLUB.CTRLT_QUERY_RESULT A
     WHERE A.CTRLV_SCNREG = v_scnpre
       AND A.CTRLN_FLAG = v_flag;
  
    COMMIT;
  
  END IF;

  UPDATE PCLUB.CTRLT_QUERY T
     SET T.CTRLN_FLAGEXEC = 1
   WHERE T.CTRLN_FLAG = v_flag;

  COMMIT;

  v_retorno := '1';

EXCEPTION
  WHEN INVALID_PARAM THEN
    v_retorno := 'ERROR: Parámetro [p_flag] incorrecto o vacio.';
    RAISE;
  WHEN OTHERS THEN
    UPDATE PCLUB.CTRLT_QUERY T
       SET T.CTRLN_FLAGEXEC = 0
     WHERE T.CTRLN_FLAG = v_flag;
    COMMIT;
    v_retorno := 'ERROR: Identificar cambios [v_flag]=' || v_flag;
    RAISE;
END CTRLSI_IDENTIFICA_CAMBIOS;
/