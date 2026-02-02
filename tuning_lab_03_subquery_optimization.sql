--------------------------------------------------------------------------------
-- LAB 03 - Otimização de Subqueries
-- Objetivo: Entender transformações de queries (subquery unnesting, view merging)
-- Schema: SH
-- Dificuldade: ⭐⭐⭐ Avançado
--------------------------------------------------------------------------------

set tab OFF
set echo ON
set timing ON
set linesize 200
set pagesize 1000

alter session set statistics_level=all;

PROMPT ========================================
PROMPT LAB 03 - Otimização de Subqueries
PROMPT ========================================
PROMPT
PROMPT Cenário: Encontrar clientes que compraram produtos específicos
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 1: Subquery com EXISTS (forma recomendada)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 1: Usando EXISTS (Semi-Join)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q1 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name,
       c.country_id
  FROM customers c
 WHERE EXISTS (
   SELECT 1
     FROM sales s
     JOIN products p ON s.prod_id = p.prod_id
    WHERE s.cust_id = c.cust_id
      AND p.prod_category = 'Electronics'
      AND s.amount_sold > 1000
 )
 ORDER BY c.cust_id
 FETCH FIRST 20 ROWS ONLY;
/

column sql_id new_value m_sql_id
column child_number new_value m_child_no

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q1%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 1 (EXISTS)
PROMPT Observe: SEMI JOIN
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 2: Subquery com IN (pode ser transformada)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 2: Usando IN (também vira Semi-Join)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q2 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name,
       c.country_id
  FROM customers c
 WHERE c.cust_id IN (
   SELECT s.cust_id
     FROM sales s
     JOIN products p ON s.prod_id = p.prod_id
    WHERE p.prod_category = 'Electronics'
      AND s.amount_sold > 1000
 )
 ORDER BY c.cust_id
 FETCH FIRST 20 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q2%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 2 (IN)
PROMPT Compare com Query 1
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 3: Subquery INEFICIENTE (correlacionada no SELECT)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 3: Subquery INEFICIENTE (correlacionada no SELECT)
PROMPT ATENÇÃO: Esta query é LENTA!
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q3 */
       c.cust_id,
       c.cust_last_name,
       (SELECT COUNT(*)
          FROM sales s
         WHERE s.cust_id = c.cust_id) as total_compras,
       (SELECT SUM(s.amount_sold)
          FROM sales s
         WHERE s.cust_id = c.cust_id) as total_gasto
  FROM customers c
 WHERE c.country_id = 52790
 ORDER BY c.cust_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q3%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 3 (Subquery Correlacionada)
PROMPT Veja quantas vezes a subquery foi executada! (Starts)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 4: OTIMIZADA - Transformada em JOIN
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 4: OTIMIZADA - Usando JOIN ao invés de subquery
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q4 */
       c.cust_id,
       c.cust_last_name,
       COUNT(*) as total_compras,
       SUM(s.amount_sold) as total_gasto
  FROM customers c
  LEFT JOIN sales s ON s.cust_id = c.cust_id
 WHERE c.country_id = 52790
 GROUP BY c.cust_id, c.cust_last_name
 ORDER BY c.cust_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q4%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 4 (JOIN Otimizado)
PROMPT Compare o tempo com Query 3!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 5: NOT EXISTS vs NOT IN
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 5: Clientes que NUNCA compraram (NOT EXISTS)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q5 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name
  FROM customers c
 WHERE NOT EXISTS (
   SELECT 1
     FROM sales s
    WHERE s.cust_id = c.cust_id
 )
 FETCH FIRST 20 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q5%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 5 (NOT EXISTS)
PROMPT Observe: ANTI JOIN
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 6: NOT IN (CUIDADO com NULLs!)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 6: Usando NOT IN (pode ser problemático com NULLs)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q6 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name
  FROM customers c
 WHERE c.cust_id NOT IN (
   SELECT s.cust_id
     FROM sales s
    WHERE s.cust_id IS NOT NULL  -- IMPORTANTE: Filtrar NULLs!
 )
 FETCH FIRST 20 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q6%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 6 (NOT IN)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 7: View Merging - Oracle pode mesclar views
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 7: Usando VIEW inline (pode ser mesclada)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB03_Q7 */
       v.cust_id,
       v.total_compras,
       c.cust_last_name
  FROM (
    SELECT cust_id, COUNT(*) as total_compras
      FROM sales
     GROUP BY cust_id
     HAVING COUNT(*) > 100
  ) v
  JOIN customers c ON v.cust_id = c.cust_id
 ORDER BY v.total_compras DESC
 FETCH FIRST 10 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB03_Q7%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 7
PROMPT Note: Veja se VIEW foi mesclada (MERGE) ou materializada (TEMP TABLE)
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
PROMPT 1. Compare Query 3 (subquery correlacionada) vs Query 4 (JOIN)
PROMPT    - Qual foi MUITO mais rápida?
PROMPT    - Na Query 3, veja a coluna "Starts" na subquery - executou quantas vezes?
PROMPT    - Regra: NUNCA use subquery correlacionada no SELECT se puder usar JOIN!
PROMPT
PROMPT 2. Compare Query 1 (EXISTS) vs Query 2 (IN)
PROMPT    - Os planos são iguais ou similares? (Oracle otimiza IN para EXISTS)
PROMPT    - Ambos viram SEMI JOIN
PROMPT
PROMPT 3. Compare Query 5 (NOT EXISTS) vs Query 6 (NOT IN)
PROMPT    - Ambos viram ANTI JOIN
PROMPT    - CUIDADO: NOT IN com NULLs pode retornar resultados errados!
PROMPT    - Sempre use NOT EXISTS ou filtre NULLs no NOT IN
PROMPT
PROMPT 4. Query 7 - View Merging
PROMPT    - A view inline foi "merged" (mesclada) ou materializada?
PROMPT    - Procure por "VIEW" no plano de execução
PROMPT
PROMPT 5. DESAFIO: Reescreva suas queries
PROMPT    - Pegue uma query com subquery correlacionada e transforme em JOIN
PROMPT    - Compare o tempo de execução
PROMPT
PROMPT 6. Veja transformações aplicadas pelo Oracle:
PROMPT    No plano, procure por:
PROMPT    - "Query Block Name / Object Alias"
PROMPT    - Note "Predicate Information" mostrando transformações
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT Próximo Lab: tuning_lab_04_index_strategies.sql
PROMPT
