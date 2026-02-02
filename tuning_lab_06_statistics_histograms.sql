--------------------------------------------------------------------------------
-- LAB 06 - Estatísticas e Histogramas (Data Skew)
-- Objetivo: Entender como estatísticas afetam planos de execução
-- Schema: SH
-- Dificuldade: ⭐⭐⭐⭐ Expert
--------------------------------------------------------------------------------

set tab OFF
set echo ON
set timing ON
set linesize 200
set pagesize 1000

alter session set statistics_level=all;

PROMPT ========================================
PROMPT LAB 06 - Estatísticas e Histogramas
PROMPT ========================================
PROMPT
PROMPT Cenário: Data Skew - dados distribuídos de forma desigual
PROMPT

---------------------------------------------------------------------------------------
-- Verificar distribuição dos dados
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Analisando distribuição de COUNTRY_ID
PROMPT ========================================
PROMPT

SELECT country_id, 
       COUNT(*) as num_clientes,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
  FROM customers
 GROUP BY country_id
 ORDER BY num_clientes DESC
 FETCH FIRST 15 ROWS ONLY;

PROMPT
PROMPT Note: Alguns países têm MUITO mais clientes que outros (Data Skew!)
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 1: País com MUITOS clientes (sem estatísticas adequadas)
---------------------------------------------------------------------------------------

-- Primeiro, deletar estatísticas antigas
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'SH', tabname => 'CUSTOMERS');

PROMPT
PROMPT ========================================
PROMPT QUERY 1: SEM estatísticas (Oracle vai "chutar")
PROMPT País com MUITOS clientes
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB06_Q1 */
       c.cust_id,
       c.cust_last_name,
       COUNT(*) as num_compras
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790  -- País com muitos clientes
 GROUP BY c.cust_id, c.cust_last_name
 ORDER BY num_compras DESC
 FETCH FIRST 10 ROWS ONLY;
/

column sql_id new_value m_sql_id
column child_number new_value m_child_no

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB06_Q1%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 1 (SEM estatísticas)
PROMPT Observe E-Rows (estimate) vs A-Rows (actual) - grande diferença!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- Coletar estatísticas BÁSICAS (sem histograma)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Coletando estatísticas BÁSICAS (sem histograma)
PROMPT ========================================
PROMPT

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'SH',
    tabname => 'CUSTOMERS',
    estimate_percent => 100,
    method_opt => 'FOR ALL COLUMNS SIZE 1',  -- SIZE 1 = sem histograma
    cascade => TRUE
  );
END;
/

PROMPT ✓ Estatísticas básicas coletadas!
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 2: Mesma query COM estatísticas básicas (mas sem histograma)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 2: COM estatísticas básicas (mas sem histograma)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB06_Q2 */
       c.cust_id,
       c.cust_last_name,
       COUNT(*) as num_compras
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790
 GROUP BY c.cust_id, c.cust_last_name
 ORDER BY num_compras DESC
 FETCH FIRST 10 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB06_Q2%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 2
PROMPT Ainda pode ter estimativa ruim por causa do Data Skew
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- Coletar estatísticas COM HISTOGRAMA
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Coletando estatísticas COM HISTOGRAMA
PROMPT ========================================
PROMPT

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'SH',
    tabname => 'CUSTOMERS',
    estimate_percent => 100,
    method_opt => 'FOR ALL COLUMNS SIZE AUTO',  -- AUTO = Oracle decide se precisa histograma
    cascade => TRUE
  );
END;
/

PROMPT ✓ Estatísticas com histograma coletadas!
PROMPT

-- Verificar se histograma foi criado
PROMPT
PROMPT ========================================
PROMPT Verificando histogramas criados
PROMPT ========================================
PROMPT

SELECT column_name, 
       num_distinct,
       num_buckets,
       histogram
  FROM user_tab_col_statistics
 WHERE table_name = 'CUSTOMERS'
   AND histogram <> 'NONE'
 ORDER BY column_name;

---------------------------------------------------------------------------------------
-- QUERY 3: Mesma query COM HISTOGRAMA
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 3: COM histograma (estimativa precisa!)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB06_Q3 */
       c.cust_id,
       c.cust_last_name,
       COUNT(*) as num_compras
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790
 GROUP BY c.cust_id, c.cust_last_name
 ORDER BY num_compras DESC
 FETCH FIRST 10 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB06_Q3%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 3
PROMPT Agora E-Rows deve estar próximo de A-Rows!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 4: Comparar país com POUCOS clientes
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 4: País com POUCOS clientes
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB06_Q4 */
       c.cust_id,
       c.cust_last_name,
       COUNT(*) as num_compras
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52787  -- País com poucos clientes
 GROUP BY c.cust_id, c.cust_last_name
 ORDER BY num_compras DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB06_Q4%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 4
PROMPT Oracle pode escolher plano diferente para poucos registros!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- Problema: Estatísticas desatualizadas
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Simulando estatísticas DESATUALIZADAS
PROMPT ========================================
PROMPT

-- Criar nova tabela de teste
CREATE TABLE sales_test AS SELECT * FROM sales WHERE ROWNUM <= 100000;

-- Coletar estatísticas
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'SH', tabname => 'SALES_TEST');

-- Ver estatísticas
SELECT num_rows, blocks, last_analyzed 
  FROM user_tables 
 WHERE table_name = 'SALES_TEST';

PROMPT
PROMPT Agora vamos INSERIR muitos dados...
PROMPT

-- Inserir muito mais dados
INSERT INTO sales_test SELECT * FROM sales WHERE prod_id < 36;
COMMIT;

-- Verificar quantas linhas temos agora
SELECT COUNT(*) as linhas_reais FROM sales_test;

-- Ver estatísticas (ainda antigas!)
PROMPT
PROMPT ========================================
PROMPT Estatísticas DESATUALIZADAS:
PROMPT ========================================
SELECT num_rows as num_rows_estatistica, 
       blocks, 
       last_analyzed,
       (SELECT COUNT(*) FROM sales_test) as linhas_reais
  FROM user_tables 
 WHERE table_name = 'SALES_TEST';

---------------------------------------------------------------------------------------
-- QUERY 5: Query com estatísticas desatualizadas
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 5: Usando tabela com estatísticas DESATUALIZADAS
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB06_Q5 */
       prod_id,
       COUNT(*) as vendas
  FROM sales_test
 WHERE prod_id = 13
 GROUP BY prod_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB06_Q5%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 5
PROMPT E-Rows muito diferente de A-Rows por causa de estatísticas velhas!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

-- Recoletar estatísticas
PROMPT
PROMPT Recoletando estatísticas...
PROMPT
EXEC DBMS_STATS.GATHER_TABLE_STATS(ownname => 'SH', tabname => 'SALES_TEST');

---------------------------------------------------------------------------------------
-- QUERY 6: Mesma query com estatísticas atualizadas
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 6: Mesma query COM estatísticas atualizadas
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB06_Q6 */
       prod_id,
       COUNT(*) as vendas
  FROM sales_test
 WHERE prod_id = 13
 GROUP BY prod_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB06_Q6%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 6
PROMPT Agora E-Rows está correto!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- ANÁLISE E CONCLUSÕES
---------------------------------------------------------------------------------------
PROMPT
PROMPT ================================================================================
PROMPT EXERCÍCIO PARA VOCÊ:
PROMPT ================================================================================
PROMPT
PROMPT 1. Compare Query 1, 2 e 3 (sem stats, stats básicas, com histograma)
PROMPT    - Veja E-Rows vs A-Rows em cada uma
PROMPT    - O plano de execução mudou?
PROMPT    - Histograma melhorou a estimativa?
PROMPT
PROMPT 2. Data Skew (Query 3 vs Query 4)
PROMPT    - País com muitos clientes: qual método de JOIN?
PROMPT    - País com poucos clientes: qual método de JOIN?
PROMPT    - Oracle escolheu planos diferentes por causa do histograma!
PROMPT
PROMPT 3. Estatísticas Desatualizadas (Query 5 vs Query 6)
PROMPT    - Estimativa errada pode levar a planos ruins
PROMPT    - Importe recoletar estatísticas regularmente!
PROMPT
PROMPT 4. Quando coletar estatísticas:
PROMPT    - Após grandes cargas de dados
PROMPT    - Periodicamente (DBMS_SCHEDULER)
PROMPT    - Quando planos de execução ficam ruins
PROMPT
PROMPT 5. DESAFIO: Analise suas tabelas
PROMPT    SELECT table_name, num_rows, last_analyzed,
PROMPT           ROUND((SYSDATE - last_analyzed)) as dias_desatualizado
PROMPT    FROM user_tables
PROMPT    WHERE num_rows > 0
PROMPT    ORDER BY last_analyzed;
PROMPT
PROMPT 6. Veja detalhes dos histogramas:
PROMPT    SELECT table_name, column_name, histogram, num_buckets
PROMPT    FROM user_tab_col_statistics
PROMPT    WHERE histogram <> 'NONE'
PROMPT    ORDER BY table_name, column_name;
PROMPT
PROMPT 7. Monitore estatísticas desatualizadas:
PROMPT    SELECT table_name, stale_stats
PROMPT    FROM user_tab_statistics
PROMPT    WHERE stale_stats = 'YES';
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT PARABÉNS! Você completou todos os labs de tuning!
PROMPT
PROMPT Próximos passos:
PROMPT - Revise os planos de execução
PROMPT - Pratique com suas próprias queries
PROMPT - Estude AWR Reports para análise de produção
PROMPT
PROMPT ================================================================================

-- Limpar tabela de teste
DROP TABLE sales_test PURGE;
