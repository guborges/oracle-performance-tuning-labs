# 🚀 Oracle Performance Tuning Labs

[![Oracle](https://img.shields.io/badge/Oracle-23ai%2F26ai-red?style=flat&logo=oracle)](https://www.oracle.com/database/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> Laboratórios práticos e progressivos para dominar **Performance Tuning** em Oracle Database. Do básico ao avançado, com exemplos reais e análise detalhada de execution plans.

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Estrutura dos Labs](#-estrutura-dos-labs)
- [Como Usar](#-como-usar)
- [Conteúdo dos Labs](#-conteúdo-dos-labs)
- [Referência Rápida](#-referência-rápida)
- [Recursos Adicionais](#-recursos-adicionais)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

---

## 🎯 Sobre o Projeto

Este repositório contém **6 laboratórios progressivos** de Performance Tuning para Oracle Database, desenvolvidos para ajudar DBAs e desenvolvedores a:

- ✅ Entender e analisar **Execution Plans**
- ✅ Otimizar **queries SQL** de forma sistemática
- ✅ Dominar técnicas de **indexação avançada**
- ✅ Compreender **métodos de JOIN** e quando usar cada um
- ✅ Trabalhar com **estatísticas e histogramas**
- ✅ Aplicar **melhores práticas** de tuning

### 🎓 Para Quem é Este Projeto?

- **DBAs** que querem aprofundar conhecimento em tuning
- **Desenvolvedores** que precisam otimizar queries
- **Estudantes** preparando certificações Oracle (OCP)
- **Profissionais** que querem praticar com cenários reais

---

## 📦 Pré-requisitos

### Software Necessário

- **Oracle Database** 12c ou superior (testado em 23ai/26ai)
- **SQL*Plus** ou **SQLcl**
- **Oracle Sample Schemas** (SH - Sales History)

### Conhecimentos Recomendados

- SQL básico (SELECT, JOIN, GROUP BY)
- Conhecimento básico de Oracle Database
- Familiaridade com execution plans (desejável, mas não obrigatório)

---

## 🔧 Instalação

### Passo 1: Instalar Oracle Sample Schemas

Os labs utilizam o schema **SH (Sales History)** da Oracle. Siga as instruções oficiais:

#### Download

```bash
# Opção 1: Clonar repositório
git clone https://github.com/oracle-samples/db-sample-schemas.git
cd db-sample-schemas

# Opção 2: Download direto
wget https://github.com/oracle-samples/db-sample-schemas/archive/refs/tags/v23.3.tar.gz
tar -xzf v23.3.tar.gz
cd db-sample-schemas-23.3
```

#### Instalação do Schema SH

```bash
# Navegar até a pasta sales_history
cd sales_history

# Conectar como usuário privilegiado (SYSTEM ou ADMIN)
sqlplus system/sua_senha@seu_database

# Executar instalação
@sh_install.sql
```

**Importante:** O schema SH precisa estar **populado com dados**. Verifique se as tabelas têm registros:

```sql
SELECT COUNT(*) FROM sh.sales;     -- Deve retornar ~918,000 registros
SELECT COUNT(*) FROM sh.customers; -- Deve retornar ~55,500 registros
```

📚 **Documentação completa:** [Oracle Sample Schemas - GitHub](https://github.com/oracle-samples/db-sample-schemas)

---

### Passo 2: Clonar Este Repositório

```bash
git clone https://github.com/SEU_USUARIO/oracle-performance-tuning-labs.git
cd oracle-performance-tuning-labs
```

### Passo 3: Verificar Instalação

```sql
-- Conectar como usuário SH
sqlplus sh/senha@database

-- Verificar tabelas
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN ('SALES', 'CUSTOMERS', 'PRODUCTS', 'TIMES')
ORDER BY table_name;
```

Se tudo estiver correto, você verá as tabelas com dados populados! ✅

---

## 📚 Estrutura dos Labs

```
oracle-performance-tuning-labs/
│
├── README.md                              # Este arquivo
├── tuning_master.sql                      # Executa todos os labs
├── tuning_cleanup.sql                     # Remove índices de teste
├── tuning_reference_guide.txt             # Guia de referência rápida
│
├── labs/
│   ├── tuning_lab_01_full_scan.sql       # ⭐ Básico
│   ├── tuning_lab_02_join_methods.sql     # ⭐⭐ Intermediário
│   ├── tuning_lab_03_subquery_optimization.sql  # ⭐⭐⭐ Avançado
│   ├── tuning_lab_04_index_strategies.sql       # ⭐⭐⭐ Avançado
│   ├── tuning_lab_05_agregacoes_group_by.sql    # ⭐⭐⭐ Avançado
│   └── tuning_lab_06_statistics_histograms.sql  # ⭐⭐⭐⭐ Expert
│
└── docs/
    └── execution_plan_guide.md            # Como ler execution plans
```

---

## 🚀 Como Usar

### Executar Lab Individual

```bash
# Conectar ao banco como usuário SH
sqlplus sh/senha@database

# Executar um lab específico
@labs/tuning_lab_01_full_scan.sql
```

### Executar Todos os Labs

```bash
sqlplus sh/senha@database
@tuning_master.sql
```

Isso executará todos os 6 labs em sequência e gerará um log completo.

### Após os Exercícios

```bash
# Limpar índices criados durante os labs
@tuning_cleanup.sql
```

---

## 📖 Conteúdo dos Labs

### 🔰 Lab 01: Full Table Scan vs Index Scan

**Nível:** ⭐ Básico | **Duração:** ~5 min

**O que você aprenderá:**
- Diferença entre Full Table Scan e Index Scan
- Quando o Oracle usa índices
- Análise de seletividade
- Como criar índices eficientes

**Conceitos-chave:**
- `TABLE ACCESS FULL`
- `INDEX RANGE SCAN`
- Seletividade de consultas
- Cost-based optimizer

---

### 🔄 Lab 02: Join Methods

**Nível:** ⭐⭐ Intermediário | **Duração:** ~8 min

**O que você aprenderá:**
- Nested Loop Join (para poucos registros)
- Hash Join (para grandes volumes)
- Merge Join (para dados ordenados)
- Como o Oracle escolhe o método de JOIN

**Conceitos-chave:**
- `NESTED LOOPS`
- `HASH JOIN`
- `MERGE JOIN`
- Hints: `USE_NL`, `USE_HASH`, `LEADING`

**Cenários práticos:**
```sql
-- Poucos clientes de um país específico → NESTED LOOP
-- Todos os clientes × vendas → HASH JOIN
```

---

### 🔍 Lab 03: Subquery Optimization

**Nível:** ⭐⭐⭐ Avançado | **Duração:** ~10 min

**O que você aprenderá:**
- EXISTS vs IN (performance)
- NOT EXISTS vs NOT IN (cuidados com NULL!)
- Eliminar subqueries correlacionadas
- Query transformations do Oracle

**Conceitos-chave:**
- `SEMI JOIN` (EXISTS, IN)
- `ANTI JOIN` (NOT EXISTS, NOT IN)
- Subquery unnesting
- View merging

**Ganho de performance:**
```sql
-- ❌ LENTO: Subquery correlacionada no SELECT
SELECT c.name, (SELECT COUNT(*) FROM sales WHERE cust_id = c.cust_id)
FROM customers c;

-- ✅ RÁPIDO: JOIN com agregação
SELECT c.name, COUNT(*)
FROM customers c LEFT JOIN sales s ON c.cust_id = s.cust_id
GROUP BY c.name;
```

---

### 📊 Lab 04: Index Strategies

**Nível:** ⭐⭐⭐ Avançado | **Duração:** ~12 min

**O que você aprenderá:**
- Index Skip Scan (quando não filtra pela primeira coluna)
- Covering Index (index-only access - sem acessar tabela!)
- Composite Index (ordem das colunas importa!)
- Function-Based Index (índices em funções)

**Conceitos-chave:**
- `INDEX SKIP SCAN`
- `INDEX FAST FULL SCAN`
- Covering index
- FBI (Function-Based Index)

**Técnicas avançadas:**
```sql
-- Covering Index: Todas as colunas no índice
CREATE INDEX idx_covering ON sales(cust_id, prod_id, amount_sold);

-- Function-Based Index
CREATE INDEX idx_fbi ON sales(TRUNC(time_id, 'MM'));
```

---

### 📈 Lab 05: GROUP BY Optimization

**Nível:** ⭐⭐⭐ Avançado | **Duração:** ~10 min

**O que você aprenderá:**
- Hash Group By vs Sort Group By
- WHERE vs HAVING (filtrar antes ou depois?)
- Window Functions (evitar múltiplas varreduras!)
- Parallel Query
- GROUP BY ROLLUP e CUBE

**Conceitos-chave:**
- `HASH GROUP BY`
- `SORT GROUP BY`
- Window Functions (`SUM() OVER()`, `RATIO_TO_REPORT`)
- Parallel execution

**Otimização crítica:**
```sql
-- ❌ Múltiplas varreduras da tabela
SELECT prod_id, total,
       (SELECT SUM(total) FROM ...) as grand_total
FROM ...;

-- ✅ Uma única varredura com Window Function
SELECT prod_id, total,
       SUM(total) OVER () as grand_total
FROM ...;
```

---

### 📉 Lab 06: Statistics & Histograms

**Nível:** ⭐⭐⭐⭐ Expert | **Duração:** ~15 min

**O que você aprenderá:**
- Importância das estatísticas
- Data Skew (dados distribuídos de forma desigual)
- Histogramas (quando e como usar)
- E-Rows vs A-Rows (estimativa vs realidade)
- Estatísticas desatualizadas (problema comum!)

**Conceitos-chave:**
- Cardinality estimation
- Histograms (`FREQUENCY`, `HEIGHT BALANCED`)
- `DBMS_STATS.GATHER_TABLE_STATS`
- Data skew

**Problema real:**
```sql
-- País com 50,000 clientes vs país com 10 clientes
-- Oracle precisa escolher planos DIFERENTES!
-- Solução: Histogramas

EXEC DBMS_STATS.GATHER_TABLE_STATS(
  ownname => 'SH',
  tabname => 'CUSTOMERS',
  method_opt => 'FOR ALL COLUMNS SIZE AUTO'  -- Cria histogramas
);
```

---

## 📘 Referência Rápida

### Como Analisar Execution Plans

```sql
-- 1. Executar query com hint
SELECT /* TUNING_TEST */ * FROM sales WHERE prod_id = 13;

-- 2. Obter SQL_ID
SELECT sql_id, child_number FROM v$sql 
WHERE sql_text LIKE '%TUNING_TEST%' 
AND sql_text NOT LIKE '%v$sql%';

-- 3. Ver execution plan
SELECT * FROM TABLE(
  dbms_xplan.display_cursor('&sql_id', &child_number, 'ADVANCED ALLSTATS LAST')
);
```

### Principais Métricas no Plan

| Métrica | Significado | O Que Buscar |
|---------|-------------|--------------|
| **E-Rows** | Estimated Rows (estimativa) | Próximo de A-Rows |
| **A-Rows** | Actual Rows (realidade) | Compara com E-Rows |
| **Buffers** | Logical reads (blocos lidos) | Quanto menor, melhor |
| **A-Time** | Actual Time | Operações lentas |

### Hints Mais Úteis

```sql
/*+ INDEX(t idx_name) */              -- Força uso de índice
/*+ FULL(t) */                         -- Força full table scan
/*+ USE_NL(t1 t2) */                   -- Força nested loop
/*+ USE_HASH(t1 t2) */                 -- Força hash join
/*+ LEADING(t1 t2) */                  -- Define ordem do JOIN
/*+ PARALLEL(4) */                     -- Parallel query (4 processos)
/*+ FIRST_ROWS(10) */                  -- Otimiza primeiras linhas
```

### Comandos Essenciais

```sql
-- Coletar estatísticas
EXEC DBMS_STATS.GATHER_TABLE_STATS('SH', 'SALES', cascade => TRUE);

-- Ver índices
SELECT index_name, column_name, column_position
FROM user_ind_columns WHERE table_name = 'SALES'
ORDER BY index_name, column_position;

-- Ver estatísticas
SELECT table_name, num_rows, last_analyzed FROM user_tables;

-- Queries lentas
SELECT sql_id, elapsed_time/1000000 as secs, sql_text
FROM v$sql WHERE elapsed_time > 5000000 ORDER BY elapsed_time DESC;
```

---

## 🎓 Recursos Adicionais

### Documentação Oracle

- 📖 [Database Performance Tuning Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/tgdba/)
- 📖 [SQL Tuning Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/tgsql/)
- 📖 [DBMS_XPLAN Package](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/DBMS_XPLAN.html)

### Scripts Oracle

```bash
# Gerar AWR Report (Automatic Workload Repository)
@$ORACLE_HOME/rdbms/admin/awrrpt.sql

# Gerar ADDM Report (Automatic Database Diagnostic Monitor)
@$ORACLE_HOME/rdbms/admin/addmrpt.sql

# SQL Tuning Advisor
@$ORACLE_HOME/rdbms/admin/sqltrpt.sql
```

### Ferramentas Recomendadas

- **SQL Developer** - Visualização gráfica de plans
- **SQLcl** - CLI moderna da Oracle
- **Enterprise Manager** - Monitoramento completo
- **SQL Monitor** - Real-time SQL execution analysis

---

## 🤝 Contribuindo

Contribuições são muito bem-vindas! Se você tem ideias para novos labs, correções ou melhorias:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovoLab`)
3. Commit suas mudanças (`git commit -m 'Add: Novo lab sobre particionamento'`)
4. Push para a branch (`git push origin feature/NovoLab`)
5. Abra um Pull Request

### Áreas Para Contribuir

- 📝 Novos labs (particionamento, materialized views, etc.)
- 🐛 Correção de bugs ou erros
- 📚 Melhoria da documentação
- 🌍 Tradução para outros idiomas
- 💡 Exemplos práticos adicionais

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Seu Nome**
- GitHub: [@seu_usuario](https://github.com/seu_usuario)
- LinkedIn: [Seu Perfil](https://linkedin.com/in/seu_perfil)

---

## ⭐ Agradecimentos

- Oracle Corporation pelos [Sample Schemas](https://github.com/oracle-samples/db-sample-schemas)
- Valter Aquino pela metodologia de ensino
- Comunidade Oracle por todo o conhecimento compartilhado

---

## 📊 Estatísticas

![GitHub stars](https://img.shields.io/github/stars/seu_usuario/oracle-performance-tuning-labs?style=social)
![GitHub forks](https://img.shields.io/github/forks/seu_usuario/oracle-performance-tuning-labs?style=social)
![GitHub issues](https://img.shields.io/github/issues/seu_usuario/oracle-performance-tuning-labs)

---

<div align="center">

### 🚀 Bons estudos e feliz tuning! 

**Se este projeto te ajudou, deixe uma ⭐!**

[⬆ Voltar ao topo](#-oracle-performance-tuning-labs)

</div>
