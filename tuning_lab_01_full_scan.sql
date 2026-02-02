--------------------------------------------------------------------------------
-- LAB 01 - Análise de Full Table Scan vs Index Scan
-- Objetivo: Entender quando usar índices e quando não usar
-- Schema: SH
-- Dificuldade: ⭐ Básico
--------------------------------------------------------------------------------

set tab OFF
set echo ON
set timing ON
set linesize 200
set pagesize 1000

alter session set statistics_level=all;

PROMPT ========================================
PROMPT LAB 01 - Full Table Scan vs Index Scan
PROMPT ========================================
PROMPT
PROMPT Cenário: Consulta buscando vendas de um produto específico
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 1: SEM ÍNDICE - Deve fazer FULL TABLE SCAN
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 1: Busca de produto SEM índice
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB01_Q1 */
       s.prod_id,
       p.prod_name,
       COUNT(*) as num_vendas,
       SUM(s.amount_sold) as total_vendido,
       AVG(s.amount_sold) as media_venda
  FROM sales s
  JOIN products p ON s.prod_id = p.prod_id
 WHERE s.prod_id = 13
 GROUP BY s.prod_id, p.prod_name;
/

column sql_id new_value m_sql_id
column child_number new_value m_child_no

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB01_Q1%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 1 (SEM índice)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- Agora vamos CRIAR UM ÍNDICE e ver a diferença
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Criando índice em SALES(PROD_ID)...
PROMPT ========================================

CREATE INDEX sh_sales_prod_id_idx ON sales(prod_id);

-- Coletar estatísticas do índice
EXEC DBMS_STATS.GATHER_INDEX_STATS(ownname => 'SH', indname => 'SH_SALES_PROD_ID_IDX');

PROMPT ✓ Índice criado!
PROMPT

---------------------------------------------------------------------------------------
-- QUERY 2: COM ÍNDICE - Deve fazer INDEX RANGE SCAN
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 2: MESMA busca COM índice
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB01_Q2 */
       s.prod_id,
       p.prod_name,
       COUNT(*) as num_vendas,
       SUM(s.amount_sold) as total_vendido,
       AVG(s.amount_sold) as media_venda
  FROM sales s
  JOIN products p ON s.prod_id = p.prod_id
 WHERE s.prod_id = 13
 GROUP BY s.prod_id, p.prod_name;
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB01_Q2%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 2 (COM índice)
PROMPT ========================================
SELECT * FROM TABLE(dbms_xplan.display_cursor('&m_sql_id', &m_child_no, 'ADVANCED ALLSTATS LAST'));

---------------------------------------------------------------------------------------
-- QUERY 3: Busca com ALTA SELETIVIDADE (muitos registros) - Índice pode não ajudar!
---------------------------------------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT QUERY 3: Busca com BAIXA seletividade
PROMPT (buscando 50% da tabela - índice NÃO deve ser usado)
PROMPT ========================================
PROMPT

SELECT /* TUNING_LAB01_Q3 */
       COUNT(*) as total_vendas,
       SUM(s.amount_sold) as total_vendido
  FROM sales s
 WHERE s.prod_id BETWEEN 1 AND 36;  -- Metade dos produtos
/

SELECT sql_id, child_number 
FROM v$sql 
WHERE sql_text LIKE '%TUNING_LAB01_Q3%' 
  AND sql_text NOT LIKE '%v$sql%';

PROMPT
PROMPT ========================================
PROMPT EXECUTION PLAN - Query 3
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
PROMPT 1. Compare os planos de execução das Query 1 e Query 2
PROMPT    - Qual operação mudou? (TABLE ACCESS FULL vs INDEX RANGE SCAN)
PROMPT    - Olhe a coluna A-Rows (actual rows) e compare com E-Rows (estimated)
PROMPT    - Qual foi mais rápida? Veja Elapsed Time
PROMPT
PROMPT 2. Na Query 3, o Oracle usou o índice ou fez FULL TABLE SCAN?
PROMPT    - Por que isso aconteceu?
PROMPT    - Dica: Quando você busca >5-10% da tabela, FULL SCAN é mais eficiente
PROMPT
PROMPT 3. DESAFIO: Teste outras queries variando o PROD_ID
PROMPT    - Tente prod_id = 50, depois prod_id IN (10,20,30)
PROMPT    - Observe quando o Oracle decide usar ou não o índice
PROMPT
PROMPT 4. Veja as estatísticas do índice:
PROMPT    SELECT index_name, blevel, leaf_blocks, num_rows, distinct_keys
PROMPT    FROM user_indexes WHERE index_name = 'SH_SALES_PROD_ID_IDX';
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT Próximo Lab: tuning_lab_02_join_methods.sql
PROMPT

-- Opcional: Limpar o índice criado (descomente se quiser)
-- DROP INDEX sh_sales_prod_id_idx;
