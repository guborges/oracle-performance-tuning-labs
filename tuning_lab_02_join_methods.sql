--------------------------------------------------------------------------------
-- LAB 02 - Análise de Join Methods
-- Objetivo: Entender NESTED LOOP, HASH JOIN e MERGE JOIN
-- Schema: SH
-- Dificuldade: ⭐⭐ Intermediário
--------------------------------------------------------------------------------

set tab OFF
set echo ON
set timing ON
set linesize 200
set pagesize 1000

alter session set statistics_level=all;

PROMPT ========================================
PROMPT LAB 02 - Join Methods
PROMPT ========================================
PROMPT
PROMPT Cenário: Analisar vendas por cliente em um país específico
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 1: JOIN Natural (Oracle decide) - Poucos registros
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 1: JOIN natural - País específico (poucos clientes)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB02_Q1 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name,
       COUNT(*) as num_compras,
       SUM(s.amount_sold) as total_gasto
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790  -- País com poucos clientes
 GROUP BY c.cust_id, c.cust_last_name, c.cust_first_name
 ORDER BY total_gasto DESC;
/

column sql_id new_value m_sql_id
column child_number new_value m_child_no

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB02_Q1%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 1
PROMPT Observe: Qual método de JOIN foi usado?
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 2: Forçar NESTED LOOP com HINT
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 2: Forçando NESTED LOOP JOIN
PROMPT ========================================
PROMPT

SELECT /*+ USE_NL(s c) LEADING(c s) */ /* TUNING_LAB02_Q2 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name,
       COUNT(*) as num_compras,
       SUM(s.amount_sold) as total_gasto
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790
 GROUP BY c.cust_id, c.cust_last_name, c.cust_first_name
 ORDER BY total_gasto DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB02_Q2%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 2 (NESTED LOOP)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 3: Forçar HASH JOIN com HINT
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 3: Forçando HASH JOIN
PROMPT ========================================
PROMPT

SELECT /*+ USE_HASH(s c) */ /* TUNING_LAB02_Q3 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name,
       COUNT(*) as num_compras,
       SUM(s.amount_sold) as total_gasto
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790
 GROUP BY c.cust_id, c.cust_last_name, c.cust_first_name
 ORDER BY total_gasto DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB02_Q3%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 3 (HASH JOIN)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 4: JOIN com MUITOS registros - Onde HASH JOIN é melhor
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 4: JOIN com MUITOS registros (todos os clientes)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB02_Q4 */
       c.country_id,
       COUNT(DISTINCT c.cust_id) as num_clientes,
       COUNT(*) as num_vendas,
       SUM(s.amount_sold) as total_vendido
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 GROUP BY c.country_id
 ORDER BY total_vendido DESC
 FETCH FIRST 10 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB02_Q4%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 4
PROMPT Observe: Com muitos registros, qual JOIN foi usado?
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- Criar índices para otimizar NESTED LOOP
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Criando índices para otimizar NESTED LOOP
PROMPT ========================================

CREATE INDEX sh_cust_country_idx ON customers(country_id, cust_id);
CREATE INDEX sh_sales_cust_idx ON sales(cust_id);

EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_CUST_COUNTRY_IDX');
EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_CUST_IDX');

PROMPT ✓ Índices criados!
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 5: Mesma query da Q1, mas agora COM índices
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 5: Query 1 repetida COM índices
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB02_Q5 */
       c.cust_id,
       c.cust_last_name,
       c.cust_first_name,
       COUNT(*) as num_compras,
       SUM(s.amount_sold) as total_gasto
  FROM customers c
  JOIN sales s ON c.cust_id = s.cust_id
 WHERE c.country_id = 52790
 GROUP BY c.cust_id, c.cust_last_name, c.cust_first_name
 ORDER BY total_gasto DESC;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB02_Q5%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 5 (COM índices)
PROMPT Compare com Query 1!
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
PROMPT 1. Compare Query 1 vs Query 5 (antes e depois dos índices)
PROMPT    - Qual método de JOIN mudou?
PROMPT    - Qual foi mais rápida?
PROMPT    - Veja o "Buffers" (logical reads) - reduziu?
PROMPT
PROMPT 2. Compare Query 2 (NESTED LOOP) vs Query 3 (HASH JOIN)
PROMPT    - Para poucos registros, qual é melhor?
PROMPT    - Olhe o "A-Time" (actual time) de cada operação
PROMPT
PROMPT 3. Quando usar cada tipo de JOIN:
PROMPT    - NESTED LOOP: Poucos registros + índices na tabela interna
PROMPT    - HASH JOIN: Muitos registros, full table scans
PROMPT    - MERGE JOIN: Tabelas já ordenadas
PROMPT
PROMPT 4. DESAFIO: Teste com outros países
PROMPT    SELECT country_id, COUNT(*) FROM customers GROUP BY country_id;
PROMPT    - Países com poucos clientes: NESTED LOOP
PROMPT    - Países com muitos clientes: HASH JOIN
PROMPT
PROMPT 5. Veja estatísticas de JOIN:
PROMPT    SELECT * FROM v$sql 
PROMPT    WHERE sql_text LIKE '%TUNING_LAB02%' 
PROMPT      AND sql_text NOT LIKE '%v$sql%';
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT Próximo Lab: tuning_lab_03_subquery_optimization.sql
PROMPT

-- Opcional: Limpar índices (descomente se quiser)
-- DROP INDEX sh_cust_country_idx;
-- DROP INDEX sh_sales_cust_idx;
