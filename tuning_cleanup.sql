--------------------------------------------------------------------------------
-- CLEANUP SCRIPT - Remove índices criados nos laboratórios
-- Execute este script para limpar os índices de teste
--------------------------------------------------------------------------------

set echo ON
set feedback ON

PROMPT ========================================
PROMPT Removendo índices criados nos labs...
PROMPT ========================================
PROMPT

-- Lab 01
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_prod_id_idx';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_prod_id_idx removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_prod_id_idx não existe');
    ELSE
      RAISE;
    END IF;
END;
/

-- Lab 02
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_cust_country_idx';
  DBMS_OUTPUT.PUT_LINE('✓ sh_cust_country_idx removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_cust_country_idx não existe');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_cust_idx';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_cust_idx removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_cust_idx não existe');
    END IF;
END;
/

-- Lab 04
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_time_prod_idx';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_time_prod_idx removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_time_prod_idx não existe');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_covering_idx';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_covering_idx removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_covering_idx não existe');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_idx_a';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_idx_a removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_idx_a não existe');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_idx_b';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_idx_b removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_idx_b não existe');
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX sh_sales_time_trunc_idx';
  DBMS_OUTPUT.PUT_LINE('✓ sh_sales_time_trunc_idx removido');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1418 THEN
      DBMS_OUTPUT.PUT_LINE('- sh_sales_time_trunc_idx não existe');
    END IF;
END;
/

PROMPT
PROMPT ========================================
PROMPT Limpeza concluída!
PROMPT ========================================
PROMPT
PROMPT Índices do schema SH:
SELECT index_name, table_name, uniqueness
  FROM user_indexes
 WHERE table_name IN ('SALES', 'CUSTOMERS', 'PRODUCTS')
 ORDER BY table_name, index_name;

PROMPT
PROMPT Para recriar os índices, execute os labs novamente.
PROMPT
