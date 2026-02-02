--------------------------------------------------------------------------------
-- LAB 05 - Otimização de Agregações e GROUP BY
-- Objetivo: HASH GROUP BY vs SORT GROUP BY, Parallel Query, Materialized Views
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
PROMPT LAB 05 - Otimização de GROUP BY
PROMPT ========================================
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 1: GROUP BY simples (HASH GROUP BY)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 1: GROUP BY com HASH (padrão para grandes volumes)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q1 */
       prod_id,
       COUNT(*) as num_vendas,
       SUM(amount_sold) as total_vendido,
       AVG(amount_sold) as media_venda,
       MAX(amount_sold) as maior_venda
  FROM sales
 GROUP BY prod_id
 ORDER BY total_vendido DESC;
/

column sql_id new_value m_sql_id
column child_number new_value m_child_no

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q1%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 1
PROMPT Procure por: HASH GROUP BY
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 2: Forçar SORT GROUP BY com hint
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 2: GROUP BY com SORT (forçado com hint)
PROMPT ========================================
PROMPT

SELECT /*+ NO_USE_HASH_AGGREGATION */ /* TUNING_LAB05_Q2 */
       prod_id,
       COUNT(*) as num_vendas,
       SUM(amount_sold) as total_vendido,
       AVG(amount_sold) as media_venda,
       MAX(amount_sold) as maior_venda
  FROM sales
 GROUP BY prod_id
 ORDER BY total_vendido DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q2%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 2
PROMPT Procure por: SORT GROUP BY
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 3: GROUP BY com JOIN (mais complexo)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 3: GROUP BY com JOIN (vendas por categoria)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q3 */
       p.prod_category,
       COUNT(DISTINCT s.cust_id) as num_clientes,
       COUNT(*) as num_vendas,
       SUM(s.amount_sold) as total_vendido,
       ROUND(AVG(s.amount_sold), 2) as media_venda
  FROM sales s
  JOIN products p ON s.prod_id = p.prod_id
 GROUP BY p.prod_category
 ORDER BY total_vendido DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q3%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 3
PROMPT Observe a ordem: JOIN primeiro, depois GROUP BY
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 4: GROUP BY com HAVING (filtro após agregação)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 4: GROUP BY com HAVING (filtro pós-agregação)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q4 */
       cust_id,
       COUNT(*) as num_compras,
       SUM(amount_sold) as total_gasto
  FROM sales
 GROUP BY cust_id
HAVING SUM(amount_sold) > 50000  -- Filtro APÓS agregação
 ORDER BY total_gasto DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q4%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 4
PROMPT HAVING é aplicado APÓS o GROUP BY
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 5: WHERE vs HAVING (performance)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 5: WHERE (filtro ANTES da agregação - melhor!)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q5 */
       cust_id,
       COUNT(*) as num_compras,
       SUM(amount_sold) as total_gasto
  FROM sales
 WHERE amount_sold > 1000  -- Filtro ANTES da agregação
 GROUP BY cust_id
HAVING COUNT(*) > 10
 ORDER BY total_gasto DESC
 FETCH FIRST 20 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q5%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 5
PROMPT WHERE filtra ANTES, reduzindo linhas para o GROUP BY
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 6: Múltiplas agregações (pode ser otimizado)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 6: Múltiplos níveis de agregação (INEFICIENTE)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q6 */
       prod_category,
       total_vendido,
       (SELECT SUM(total_vendido) FROM (
           SELECT p2.prod_category, SUM(s2.amount_sold) as total_vendido
             FROM sales s2
             JOIN products p2 ON s2.prod_id = p2.prod_id
            GROUP BY p2.prod_category
       )) as grand_total,
       ROUND(total_vendido / (SELECT SUM(total_vendido) FROM (
           SELECT p2.prod_category, SUM(s2.amount_sold) as total_vendido
             FROM sales s2
             JOIN products p2 ON s2.prod_id = p2.prod_id
            GROUP BY p2.prod_category
       )) * 100, 2) as percentual
  FROM (
    SELECT p.prod_category, SUM(s.amount_sold) as total_vendido
      FROM sales s
      JOIN products p ON s.prod_id = p.prod_id
     GROUP BY p.prod_category
  )
 ORDER BY total_vendido DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q6%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 6
PROMPT Observe: Tabelas sendo acessadas múltiplas vezes!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 7: Otimizada com Window Function
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 7: OTIMIZADA usando Window Function (uma única varredura!)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q7 */
       prod_category,
       total_vendido,
       SUM(total_vendido) OVER () as grand_total,
       ROUND(RATIO_TO_REPORT(total_vendido) OVER () * 100, 2) as percentual
  FROM (
    SELECT p.prod_category, SUM(s.amount_sold) as total_vendido
      FROM sales s
      JOIN products p ON s.prod_id = p.prod_id
     GROUP BY p.prod_category
  )
 ORDER BY total_vendido DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q7%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 7
PROMPT Observe: Uma única varredura! Muito mais eficiente!
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 8: Parallel Query (para grandes volumes)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 8: Usando PARALLEL QUERY
PROMPT ========================================
PROMPT

SELECT /*+ PARALLEL(4) */ /* TUNING_LAB05_Q8 */
       prod_id,
       COUNT(*) as num_vendas,
       SUM(amount_sold) as total_vendido
  FROM sales
 GROUP BY prod_id
 ORDER BY total_vendido DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q8%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 8
PROMPT Procure por: PX COORDINATOR, PX SEND, PX RECEIVE
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 9: GROUP BY com ROLLUP (subtotais)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 9: GROUP BY com ROLLUP (hierarquia de totais)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB05_Q9 */
       p.prod_category,
       p.prod_subcategory,
       COUNT(*) as num_vendas,
       SUM(s.amount_sold) as total_vendido
  FROM sales s
  JOIN products p ON s.prod_id = p.prod_id
 GROUP BY ROLLUP(p.prod_category, p.prod_subcategory)
 ORDER BY p.prod_category, p.prod_subcategory;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB05_Q9%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 9
PROMPT ROLLUP cria múltiplos níveis de agregação
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
PROMPT 1. HASH vs SORT GROUP BY (Query 1 vs Query 2)
PROMPT    - HASH GROUP BY: Melhor para grandes volumes, não ordenado
PROMPT    - SORT GROUP BY: Melhor quando precisa ORDER BY pela mesma coluna
PROMPT    - Compare "Buffers" e "A-Time"
PROMPT
PROMPT 2. WHERE vs HAVING (Query 4 vs Query 5)
PROMPT    - WHERE filtra ANTES do GROUP BY (reduz linhas processadas)
PROMPT    - HAVING filtra DEPOIS do GROUP BY (mais trabalho)
PROMPT    - Sempre use WHERE quando possível!
PROMPT
PROMPT 3. Múltiplas Agregações (Query 6 vs Query 7)
PROMPT    - Query 6: Múltiplas varreduras da mesma tabela (LENTO!)
PROMPT    - Query 7: Uma única varredura com Window Function (RÁPIDO!)
PROMPT    - Window Functions: SUM() OVER(), RATIO_TO_REPORT(), etc.
PROMPT
PROMPT 4. Parallel Query (Query 8)
PROMPT    - Útil para grandes volumes
PROMPT    - Cuidado: Consome mais recursos
PROMPT    - Veja no plano: quantos processos paralelos foram usados?
PROMPT
PROMPT 5. DESAFIO: Teste diferentes degrees de paralelismo
PROMPT    - PARALLEL(2), PARALLEL(4), PARALLEL(8)
PROMPT    - Qual foi o melhor tempo?
PROMPT    - Nem sempre mais paralelo = mais rápido!
PROMPT
PROMPT 6. GROUP BY Extensions:
PROMPT    - ROLLUP: Cria subtotais hierárquicos
PROMPT    - CUBE: Cria todas as combinações possíveis
PROMPT    - GROUPING SETS: Controle fino sobre agrupamentos
PROMPT
PROMPT 7. Veja estatísticas de agregação:
PROMPT    SELECT sql_id, executions, rows_processed, buffer_gets
PROMPT    FROM v$sql
PROMPT    WHERE sql_text LIKE '%TUNING_LAB05%'
PROMPT      AND sql_text NOT LIKE '%v$sql%'
PROMPT    ORDER BY buffer_gets DESC;
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT Próximo Lab: tuning_lab_06_statistics_histograms.sql
PROMPT
