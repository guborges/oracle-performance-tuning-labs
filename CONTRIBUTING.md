# Guia de Contribuição

Obrigado por considerar contribuir com o Oracle Performance Tuning Labs! 🎉

## 📋 Como Contribuir

### Reportando Bugs

Se você encontrou um bug, por favor abra uma [issue](https://github.com/SEU_USUARIO/oracle-performance-tuning-labs/issues) incluindo:

- **Descrição clara** do problema
- **Passos para reproduzir** o erro
- **Versão do Oracle** que você está usando
- **Mensagem de erro** completa (se houver)
- **Execution plan** (se relevante)

### Sugerindo Melhorias

Adoramos receber sugestões! Para propor uma melhoria:

1. Verifique se já não existe uma issue similar
2. Abra uma nova issue com o título começando com `[MELHORIA]`
3. Descreva detalhadamente sua sugestão
4. Explique por que seria útil

### Contribuindo com Código

#### 1. Fork e Clone

```bash
# Fork o repositório no GitHub
# Clone seu fork
git clone https://github.com/SEU_USUARIO/oracle-performance-tuning-labs.git
cd oracle-performance-tuning-labs
```

#### 2. Crie uma Branch

```bash
git checkout -b feature/nome-da-sua-feature
```

**Convenção de nomenclatura:**
- `feature/` - Nova funcionalidade
- `fix/` - Correção de bug
- `docs/` - Melhorias na documentação
- `refactor/` - Refatoração de código

#### 3. Faça suas Alterações

- Siga o padrão de código existente
- Comente código complexo
- Teste suas alterações
- Atualize a documentação se necessário

#### 4. Commit

```bash
git add .
git commit -m "Add: Descrição clara do que foi adicionado"
```

**Convenção de mensagens de commit:**
- `Add:` - Adicionar nova funcionalidade
- `Fix:` - Corrigir bug
- `Update:` - Atualizar funcionalidade existente
- `Docs:` - Mudanças na documentação
- `Refactor:` - Refatoração de código
- `Test:` - Adicionar ou modificar testes

#### 5. Push e Pull Request

```bash
git push origin feature/nome-da-sua-feature
```

Depois abra um Pull Request no GitHub com:
- Título descritivo
- Descrição detalhada das mudanças
- Referência a issues relacionadas (se houver)

## 🎨 Padrões de Código

### SQL Scripts

```sql
--------------------------------------------------------------------------------
-- Nome do Script
-- Objetivo: Breve descrição
-- Schema: SH
-- Dificuldade: ⭐⭐⭐
--------------------------------------------------------------------------------

set tab OFF
set echo ON
set timing ON
set linesize 200
set pagesize 1000

-- Comentários claros e descritivos
-- Usar hints apenas quando necessário e documentá-los

PROMPT ========================================
PROMPT Seção Descritiva
PROMPT ========================================
```

### Documentação

- Use Markdown para documentação
- Mantenha linhas com no máximo 80-100 caracteres
- Inclua exemplos práticos
- Use emojis com moderação 😊

## 📚 Áreas Para Contribuir

### Novos Labs

Ideias para novos laboratórios:

- [ ] Particionamento de Tabelas
- [ ] Materialized Views
- [ ] Result Cache
- [ ] In-Memory Column Store
- [ ] SQL Plan Management
- [ ] Adaptive Query Optimization
- [ ] Exadata Smart Scans
- [ ] PL/SQL Performance
- [ ] Parallel Execution Tuning
- [ ] RAC-specific tuning

### Melhorias na Documentação

- Tradução para outros idiomas
- Mais exemplos práticos
- Vídeos tutoriais
- Diagramas e visualizações
- FAQ (Perguntas Frequentes)

### Ferramentas Auxiliares

- Scripts de diagnóstico
- Geradores de carga
- Ferramentas de análise
- Dashboards de monitoramento

## ✅ Checklist do Pull Request

Antes de submeter seu PR, verifique:

- [ ] Código testado em Oracle Database
- [ ] Documentação atualizada
- [ ] Exemplos funcionando
- [ ] Sem erros SQL
- [ ] Comentários adicionados onde necessário
- [ ] README atualizado (se necessário)
- [ ] Sem conflitos com a branch main

## 🧪 Testando

### Ambiente de Teste

Recomendamos testar em:
- Oracle Database 19c ou superior
- Schema SH instalado e populado
- Pelo menos 2GB de SGA disponível

### Comandos de Teste

```sql
-- Verificar sintaxe
@script_novo.sql

-- Verificar resultados
SELECT COUNT(*) FROM resultado_esperado;

-- Verificar performance
SET TIMING ON
@script_novo.sql
```

## 💬 Dúvidas?

Se tiver dúvidas sobre como contribuir:

1. Verifique a [documentação](README.md)
2. Procure em [issues fechadas](https://github.com/SEU_USUARIO/oracle-performance-tuning-labs/issues?q=is%3Aissue+is%3Aclosed)
3. Abra uma nova issue com tag `[DÚVIDA]`

## 🎯 Código de Conduta

Esperamos que todos os contribuidores:

- Sejam respeitosos e inclusivos
- Aceitem críticas construtivas
- Foquem no que é melhor para a comunidade
- Demonstrem empatia com outros membros

## 📄 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a [Licença MIT](LICENSE).

---

**Obrigado por contribuir! 🙏**

Cada contribuição, por menor que seja, ajuda a tornar este projeto melhor para todos!
