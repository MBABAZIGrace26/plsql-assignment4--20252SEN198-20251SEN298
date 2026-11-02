CREATE OR REPLACE PROCEDURE benchmark_bulk_vs_loop (p_rows IN PLS_INTEGER DEFAULT 10000)
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  TYPE t_id_tab  IS TABLE OF perf_test.id%TYPE    INDEX BY PLS_INTEGER;
  TYPE t_lbl_tab IS TABLE OF perf_test.label%TYPE INDEX BY PLS_INTEGER;
  v_ids   t_id_tab;
  v_lbls  t_lbl_tab;
  v_start PLS_INTEGER;
  v_loop_cs PLS_INTEGER;
  v_bulk_cs PLS_INTEGER;
BEGIN
  IF p_rows IS NULL OR p_rows NOT BETWEEN 1 AND 1000000 THEN
    RAISE_APPLICATION_ERROR(-20050, 'p_rows must be between 1 and 1,000,000.');
  END IF;

  FOR i IN 1 .. p_rows LOOP
    v_ids(i)  := i;
    v_lbls(i) := 'ROW_' || i;
  END LOOP;

  DELETE FROM perf_test;
  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP                         -- row by row
    INSERT INTO perf_test (id, label) VALUES (v_ids(i), v_lbls(i));
  END LOOP;
  v_loop_cs := DBMS_UTILITY.GET_TIME - v_start;

  DELETE FROM perf_test;
  v_start := DBMS_UTILITY.GET_TIME;
  FORALL i IN 1 .. p_rows                           -- bulk
    INSERT INTO perf_test (id, label) VALUES (v_ids(i), v_lbls(i));
  v_bulk_cs := DBMS_UTILITY.GET_TIME - v_start;

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('Rows: ' || p_rows);
  DBMS_OUTPUT.PUT_LINE('Row-by-row loop : ' || v_loop_cs || ' centiseconds');
  DBMS_OUTPUT.PUT_LINE('FORALL bulk     : ' || v_bulk_cs || ' centiseconds');
  IF v_bulk_cs > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Speed-up        : ~' || ROUND(v_loop_cs / v_bulk_cs, 1) || 'x');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      DBMS_OUTPUT.PUT_LINE('benchmark unexpected error: ' || SQLERRM);
    END IF;
    RAISE;
END benchmark_bulk_vs_loop;
/
SHOW ERRORS

SET SERVEROUTPUT ON;

BEGIN
    benchmark_bulk_vs_loop(1000);
END;
/