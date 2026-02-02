--------------------------------------------------------------------------------
-- LAB 04 - Estratégias Avançadas de Indexação
-- Objetivo: Index Skip Scan, Composite Index, Index-Only Access
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
PROMPT LAB 04 - Estratégias de Indexação
PROMPT ========================================
PROMPT

---------------------------------------------------------------------------------------
-- PARTE 1: INDEX SKIP SCAN
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT PARTE 1: INDEX SKIP SCAN
PROMPT ========================================
PROMPT

-- Criar índice composto (time_id, prod_id)
CREATE INDEX sh_sales_time_prod_idx ON sales(time_id, prod_id);
EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_TIME_PROD_IDX');

PROMPT ✓ Índice composto criado: (time_id, prod_id)
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 1: Buscando pelo SEGUNDO campo do índice (prod_id)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 1: Busca pelo 2º campo do índice (INDEX SKIP SCAN)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q1 */
       prod_id,
       COUNT(*) as num_vendas,
       SUM(amount_sold) as total
  FROM sales
 WHERE prod_id = 13  -- Não usa time_id (1ª coluna do índice)
 GROUP BY prod_id;
/

column sql_id new_value m_sql_id
column child_number new_value m_child_no

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q1%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 1
PROMPT Procure por: INDEX SKIP SCAN
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 2: Buscando pelos DOIS campos (INDEX RANGE SCAN)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 2: Busca pelos 2 campos (INDEX RANGE SCAN - mais eficiente)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q2 */
       prod_id,
       COUNT(*) as num_vendas,
       SUM(amount_sold) as total
  FROM sales
 WHERE time_id = DATE '1998-01-10'
   AND prod_id = 13
 GROUP BY prod_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q2%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 2
PROMPT Procure por: INDEX RANGE SCAN (mais eficiente que SKIP SCAN)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- PARTE 2: COVERING INDEX (Index-Only Access)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT PARTE 2: COVERING INDEX (Index que contém todos os dados)
PROMPT ========================================
PROMPT

-- Criar índice que cobre todas as colunas da query
CREATE INDEX sh_sales_covering_idx ON sales(cust_id, prod_id, amount_sold);
EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_COVERING_IDX');

PROMPT ✓ Covering Index criado: (cust_id, prod_id, amount_sold)
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 3: Usando apenas colunas do índice (sem acesso à tabela)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 3: Index-Only Access (não precisa acessar a tabela!)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q3 */
       cust_id,
       prod_id,
       SUM(amount_sold) as total
  FROM sales
 WHERE cust_id = 100
 GROUP BY cust_id, prod_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q3%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 3
PROMPT Observe: Não deve ter TABLE ACCESS BY INDEX ROWID!
PROMPT Apenas INDEX RANGE SCAN ou INDEX FAST FULL SCAN
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 4: Mesma query, mas buscando coluna FORA do índice
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 4: Buscando coluna fora do índice (precisa acessar tabela)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q4 */
       cust_id,
       prod_id,
       SUM(amount_sold) as total,
       SUM(quantity_sold) as qtd  -- quantity_sold NÃO está no índice!
  FROM sales
 WHERE cust_id = 100
 GROUP BY cust_id, prod_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q4%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 4
PROMPT Observe: Agora TEM "TABLE ACCESS BY INDEX ROWID"
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- PARTE 3: ORDEM DAS COLUNAS NO ÍNDICE COMPOSTO
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT PARTE 3: Ordem das colunas no índice composto
PROMPT ========================================
PROMPT

-- Criar 2 índices com ordens diferentes
CREATE INDEX sh_sales_idx_a ON sales(prod_id, time_id);
CREATE INDEX sh_sales_idx_b ON sales(time_id, prod_id);

EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_IDX_A');
EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_IDX_B');

PROMPT ✓ Índices criados:
PROMPT   - sh_sales_idx_a (prod_id, time_id)
PROMPT   - sh_sales_idx_b (time_id, prod_id)
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 5: Filtro por prod_id (vai usar sh_sales_idx_a)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 5: Filtro por PROD_ID primeiro
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q5 */
       prod_id,
       COUNT(*) as vendas
  FROM sales
 WHERE prod_id BETWEEN 10 AND 15
 GROUP BY prod_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q5%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 5
PROMPT Qual índice foi usado? sh_sales_idx_a ou sh_sales_idx_b?
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 6: Filtro por time_id (vai usar sh_sales_idx_b)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 6: Filtro por TIME_ID primeiro
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q6 */
       time_id,
       COUNT(*) as vendas
  FROM sales
 WHERE time_id BETWEEN DATE '1998-01-01' AND DATE '1998-01-31'
 GROUP BY time_id;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q6%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 6
PROMPT Qual índice foi usado? sh_sales_idx_a ou sh_sales_idx_b?
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- PARTE 4: FUNÇÃO NO ÍNDICE (FBI - Function-Based Index)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT PARTE 4: Function-Based Index (FBI)
PROMPT ========================================
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 7: Função na coluna SEM índice (não usa índice)
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 7: Função SEM índice (FULL SCAN)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q7 */
       cust_id,
       SUM(amount_sold) as total
  FROM sales
 WHERE TRUNC(time_id, 'MM') = DATE '1998-01-01'  -- Função na coluna!
 GROUP BY cust_id
 FETCH FIRST 10 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q7%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 7
PROMPT Observe: Provavelmente FULL SCAN
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

-- Criar Function-Based Index
CREATE INDEX sh_sales_time_trunc_idx ON sales(TRUNC(time_id, 'MM'));
EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_TIME_TRUNC_IDX');

PROMPT ✓ Function-Based Index criado: TRUNC(time_id, 'MM')
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 8: Mesma função COM índice
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 8: Mesma função COM FBI (usa índice!)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB04_Q8 */
       cust_id,
       SUM(amount_sold) as total
  FROM sales
 WHERE TRUNC(time_id, 'MM') = DATE '1998-01-01'
 GROUP BY cust_id
 FETCH FIRST 10 ROWS ONLY;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB04_Q8%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 8
PROMPT Observe: Agora usa o Function-Based Index!
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
PROMPT 1. INDEX SKIP SCAN (Query 1 vs Query 2)
PROMPT    - Compare o "Buffers" - qual leu mais blocos?
PROMPT    - SKIP SCAN é útil mas menos eficiente que RANGE SCAN
PROMPT    - Regra: Sempre coloque a coluna mais filtrada PRIMEIRO no índice
PROMPT
PROMPT 2. COVERING INDEX (Query 3 vs Query 4)
PROMPT    - Query 3 não acessa a tabela (mais rápido!)
PROMPT    - Query 4 precisa fazer TABLE ACCESS BY INDEX ROWID
PROMPT    - Veja a diferença no "Buffers"
PROMPT
PROMPT 3. ORDEM DAS COLUNAS (Query 5 vs Query 6)
PROMPT    - Oracle escolheu índices diferentes
PROMPT    - Ordem das colunas importa!
PROMPT    - Dica: Coloque primeiro a coluna mais seletiva (menos valores distintos)
PROMPT
PROMPT 4. FUNCTION-BASED INDEX (Query 7 vs Query 8)
PROMPT    - Função na coluna invalida índices normais
PROMPT    - FBI permite indexar o resultado da função
PROMPT    - Use para UPPER(), LOWER(), TRUNC(), etc.
PROMPT
PROMPT 5. DESAFIO: Analise seus índices
PROMPT    SELECT index_name, column_name, column_position
PROMPT    FROM user_ind_columns
PROMPT    WHERE table_name = 'SALES'
PROMPT    ORDER BY index_name, column_position;
PROMPT
PROMPT 6. Veja estatísticas dos índices:
PROMPT    SELECT index_name, blevel, leaf_blocks, distinct_keys, clustering_factor
PROMPT    FROM user_indexes WHERE table_name = 'SALES';
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT Próximo Lab: tuning_lab_05_agregacoes_group_by.sql
PROMPT

-- Opcional: Limpar índices (descomente se quiser)
-- DROP INDEX sh_sales_time_prod_idx;
-- DROP INDEX sh_sales_covering_idx;
-- DROP INDEX sh_sales_idx_a;
-- DROP INDEX sh_sales_idx_b;
-- DROP INDEX sh_sales_time_trunc_idx;
