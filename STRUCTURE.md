# Estrutura de Diretórios Sugerida para o Repositório

```
oracle-performance-tuning-labs/
│
├── README.md                          # README principal do GitHub
├── LICENSE                            # Licença MIT
├── CONTRIBUTING.md                    # Guia de contribuição
├── .gitignore                         # Arquivos a serem ignorados
│
├── labs/                              # Diretório dos laboratórios
│   ├── lab_01_full_scan/
│   │   ├── tuning_lab_01_full_scan.sql
│   │   └── README.md                 # Explicação específica do lab
│   │
│   ├── lab_02_join_methods/
│   │   ├── tuning_lab_02_join_methods.sql
│   │   └── README.md
│   │
│   ├── lab_03_subquery_optimization/
│   │   ├── tuning_lab_03_subquery_optimization.sql
│   │   └── README.md
│   │
│   ├── lab_04_index_strategies/
│   │   ├── tuning_lab_04_index_strategies.sql
│   │   └── README.md
│   │
│   ├── lab_05_agregacoes_group_by/
│   │   ├── tuning_lab_05_agregacoes_group_by.sql
│   │   └── README.md
│   │
│   └── lab_06_statistics_histograms/
│       ├── tuning_lab_06_statistics_histograms.sql
│       └── README.md
│
├── scripts/                           # Scripts auxiliares
│   ├── tuning_master.sql             # Executa todos os labs
│   ├── tuning_cleanup.sql            # Limpeza de índices
│   └── setup/
│       ├── verify_schema.sql         # Verifica instalação do SH
│       └── create_test_data.sql      # Dados adicionais (opcional)
│
├── docs/                              # Documentação adicional
│   ├── tuning_reference_guide.md     # Guia de referência
│   ├── execution_plan_guide.md       # Como ler execution plans
│   ├── statistics_guide.md           # Guia de estatísticas
│   └── images/                       # Imagens para documentação
│       ├── execution_plan_example.png
│       └── architecture_diagram.png
│
├── examples/                          # Exemplos práticos extras
│   ├── real_world_case_01.sql       # Caso real de otimização
│   ├── real_world_case_02.sql
│   └── benchmark_queries.sql         # Queries para benchmark
│
├── resources/                         # Recursos adicionais
│   ├── oracle_docs_links.md          # Links úteis
│   ├── recommended_reading.md        # Leitura recomendada
│   └── video_tutorials.md            # Vídeos tutoriais
│
└── tests/                            # Testes (opcional)
    ├── test_lab_01.sql
    ├── test_lab_02.sql
    └── run_all_tests.sql
```

## 📝 Descrição dos Diretórios

### `/labs`
Contém todos os laboratórios práticos. Cada lab tem seu próprio diretório com:
- Script SQL principal
- README específico explicando objetivos e conceitos

### `/scripts`
Scripts utilitários e de automação:
- Script master para executar todos os labs
- Script de limpeza
- Scripts de setup e verificação

### `/docs`
Documentação completa do projeto:
- Guias de referência
- Tutoriais
- Imagens e diagramas

### `/examples`
Exemplos práticos adicionais:
- Casos reais de otimização
- Queries de benchmark
- Cenários do mundo real

### `/resources`
Materiais de apoio:
- Links para documentação Oracle
- Livros e artigos recomendados
- Vídeos tutoriais

### `/tests`
Scripts de teste para validar os labs (opcional):
- Testes unitários dos labs
- Validação de resultados

## 🚀 Como Organizar Seus Arquivos

### Opção 1: Estrutura Simples (Atual)

```
oracle-performance-tuning-labs/
├── README.md
├── LICENSE
├── tuning_master.sql
├── tuning_cleanup.sql
├── tuning_reference_guide.txt
├── tuning_lab_01_full_scan.sql
├── tuning_lab_02_join_methods.sql
├── tuning_lab_03_subquery_optimization.sql
├── tuning_lab_04_index_strategies.sql
├── tuning_lab_05_agregacoes_group_by.sql
└── tuning_lab_06_statistics_histograms.sql
```

**Vantagens:**
- Simples de navegar
- Fácil de fazer download
- Ótimo para começar

**Desvantagens:**
- Pode ficar desorganizado com muitos arquivos
- Difícil de escalar com novos conteúdos

### Opção 2: Estrutura Organizada (Recomendada)

Use a estrutura completa mostrada acima quando:
- Você adicionar mais labs
- Quiser incluir documentação extensa
- Planeja aceitar contribuições
- Quer profissionalizar o repositório

## 📦 Comandos Git Sugeridos

```bash
# Estrutura inicial
mkdir -p labs/{lab_01_full_scan,lab_02_join_methods,lab_03_subquery_optimization,lab_04_index_strategies,lab_05_agregacoes_group_by,lab_06_statistics_histograms}
mkdir -p scripts/setup
mkdir -p docs/images
mkdir -p examples
mkdir -p resources

# Mover arquivos para estrutura organizada
mv tuning_lab_01_full_scan.sql labs/lab_01_full_scan/
mv tuning_lab_02_join_methods.sql labs/lab_02_join_methods/
# ... e assim por diante

mv tuning_master.sql scripts/
mv tuning_cleanup.sql scripts/
mv tuning_reference_guide.txt docs/tuning_reference_guide.md

# Adicionar tudo ao Git
git add .
git commit -m "Initial commit: Oracle Performance Tuning Labs"
git push origin main
```

## 📋 Checklist de Publicação

Antes de publicar no GitHub:

- [ ] README.md completo e revisado
- [ ] LICENSE adicionado
- [ ] CONTRIBUTING.md criado
- [ ] .gitignore configurado
- [ ] Todos os scripts testados
- [ ] Documentação revisada
- [ ] Badges adicionados (opcional)
- [ ] Screenshots/imagens (se houver)
- [ ] Links verificados
- [ ] Informações de contato atualizadas

## 🎨 Dicas de Organização

1. **Mantenha consistência** nos nomes de arquivos
2. **Use README.md** em cada diretório importante
3. **Documente tudo** - quanto mais, melhor!
4. **Versione corretamente** usando tags Git
5. **Organize por complexidade** - do básico ao avançado

## 🔖 Versionamento Semântico

Sugestão de tags:
- `v1.0.0` - Release inicial com 6 labs
- `v1.1.0` - Adição de novo lab
- `v1.1.1` - Correção de bugs
- `v2.0.0` - Mudança significativa na estrutura

```bash
git tag -a v1.0.0 -m "Release inicial: 6 labs de Performance Tuning"
git push origin v1.0.0
```

---

**Esta estrutura é flexível! Adapte conforme suas necessidades.** 🚀
