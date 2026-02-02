--------------------------------------------------------------------------------
-- MASTER SCRIPT - Performance Tuning Labs
-- Execute este script para rodar TODOS os labs em sequência
-- Schema: SH
-- Tempo estimado: 15-30 minutos
--------------------------------------------------------------------------------

set tab OFF
set echo ON
set timing ON
set linesize 200
set pagesize 1000

PROMPT
PROMPT ================================================================================
PROMPT           ORACLE PERFORMANCE TUNING - LABORATÓRIOS PRÁTICOS
PROMPT ================================================================================
PROMPT
PROMPT Este script executará 6 laboratórios de tuning em sequência:
PROMPT
PROMPT   LAB 01 ⭐     - Full Table Scan vs Index Scan
PROMPT   LAB 02 ⭐⭐    - Join Methods (Nested Loop, Hash, Merge)
PROMPT   LAB 03 ⭐⭐⭐   - Subquery Optimization
PROMPT   LAB 04 ⭐⭐⭐   - Advanced Index Strategies
PROMPT   LAB 05 ⭐⭐⭐   - GROUP BY Optimization
PROMPT   LAB 06 ⭐⭐⭐⭐  - Statistics & Histograms
PROMPT
PROMPT Tempo estimado: 15-30 minutos
PROMPT
PROMPT ================================================================================
PROMPT

ACCEPT continue_script PROMPT 'Deseja continuar? (S/N): '

SET TERMOUT OFF
COLUMN continue_check NEW_VALUE continue_val
SELECT CASE WHEN UPPER('&continue_script') = 'S' THEN 'OK' ELSE 'CANCEL' END AS continue_check FROM dual;
SET TERMOUT ON

WHENEVER SQLERROR EXIT SQL.SQLCODE

-- Verificar se usuário confirmou
PROMPT
PROMPT Iniciando laboratórios...
PROMPT

-- Criar diretório para logs
host mkdir -p ~/tuning_labs_logs 2>/dev/null || mkdir %USERPROFILE%\tuning_labs_logs 2>NUL

-- Definir arquivo de spool
SPOOL ~/tuning_labs_logs/master_tuning_labs.log

PROMPT
PROMPT ================================================================================
PROMPT LAB 01 - Full Table Scan vs Index Scan
PROMPT ================================================================================
PROMPT
@@tuning_lab_01_full_scan.sql

PROMPT
PROMPT ================================================================================
PROMPT LAB 02 - Join Methods
PROMPT ================================================================================
PROMPT
@@tuning_lab_02_join_methods.sql

PROMPT
PROMPT ================================================================================
PROMPT LAB 03 - Subquery Optimization
PROMPT ================================================================================
PROMPT
@@tuning_lab_03_subquery_optimization.sql

PROMPT
PROMPT ================================================================================
PROMPT LAB 04 - Index Strategies
PROMPT ================================================================================
PROMPT
@@tuning_lab_04_index_strategies.sql

PROMPT
PROMPT ================================================================================
PROMPT LAB 05 - GROUP BY Optimization
PROMPT ================================================================================
PROMPT
@@tuning_lab_05_agregacoes_group_by.sql

PROMPT
PROMPT ================================================================================
PROMPT LAB 06 - Statistics & Histograms
PROMPT ================================================================================
PROMPT
@@tuning_lab_06_statistics_histograms.sql

SPOOL OFF

PROMPT
PROMPT ================================================================================
PROMPT                         LABORATÓRIOS CONCLUÍDOS!
PROMPT ================================================================================
PROMPT
PROMPT Log completo salvo em: ~/tuning_labs_logs/master_tuning_labs.log
PROMPT
PROMPT PRÓXIMOS PASSOS:
PROMPT
PROMPT 1. Revise os planos de execução no log
PROMPT 2. Compare E-Rows (estimate) vs A-Rows (actual)
PROMPT 3. Analise os "Buffers" (logical reads)
PROMPT 4. Veja o "A-Time" (actual time) de cada operação
PROMPT
PROMPT 5. Consulte o guia de referência: tuning_reference_guide.sql
PROMPT
PROMPT 6. Pratique modificando as queries:
PROMPT    - Mude os filtros (WHERE)
PROMPT    - Teste diferentes hints
PROMPT    - Crie/remova índices
PROMPT    - Compare os resultados
PROMPT
PROMPT ================================================================================
PROMPT
PROMPT Para limpar TODOS os índices criados nos labs:
PROMPT @@tuning_cleanup.sql
PROMPT
PROMPT ================================================================================
