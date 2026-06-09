# 🏠 Pipeline de Dados: Imposto sobre Transmissão de Bens Imóveis - ITBI (Recife)

> **Projeto da Disciplina de Banco de Dados (2025.2) - CIn/UFPE**

Este projeto implementa e compara duas arquiteturas fundamentais de Engenharia de Dados, o **ETL Clássico** (Python/Pandas) e o **ELT Moderno** (dbt/SQL) para processar, higienizar e modelar dados públicos de transações imobiliárias com recolhimento de ITBI no município do Recife.

O resultado final é uma **Modelagem Dimensional (Esquema Estrela)** que transforma registros brutos de três anos consecutivos em um Data Warehouse otimizado para análises de Business Intelligence (BI).

---

## 🎯 Objetivo e Desafio

O objetivo foi integrar dados dispersos temporalmente para permitir análises históricas do mercado imobiliário recifense.

- **Fonte:** [Portal de Dados Abertos do Recife](https://dados.recife.pe.gov.br/pt_PT/dataset/imposto-sobre-transmissao-de-bens-imoveis-itbi)
- **Dados Brutos:** Arquivos CSV separados por ano (2023, 2024 e 2025) contendo registros de transações imobiliárias com recolhimento de ITBI, incluindo características dos imóveis e informações sobre as operações.
- **Desafio Principal:** Os dados possuíam inconsistências de encoding (UTF-8/latin-1), abreviações inconsistentes em logradouros, separadores decimais misturados, informações distintas comprimidas em uma única coluna (`complemento`) e ausência de chaves primárias confiáveis.

---

## 📄 Relatório do Projeto

A documentação completa do projeto pode ser acessada através do relatório técnico:

📑 **[Acessar Relatório Completo](https://docs.google.com/document/d/18oq8vQ65WMu9GECNWZ7LxznStrxrsmG9vRCwPo0DeBU/edit?tab=t.0)**

---

## 🏗️ Arquitetura da Solução

O projeto constrói o mesmo modelo dimensional através de dois caminhos distintos para fins de comparação:

### 1. Abordagem ETL (Python Driven)

- **Extração:** Leitura dos três CSVs anuais a partir do portal oficial.
- **Transformação:** Limpeza, padronização, deduplicação e modelagem dimensional realizadas inteiramente em memória usando **Pandas** - tratamento de encoding corrompido, expansão de abreviações em logradouros, separação da coluna `complemento` em `complemento_numero` e `nome_edificio`, normalização de tipos e remoção de outliers.
- **Carga:** Inserção das tabelas de dimensão e fato no PostgreSQL (Supabase) via SQLAlchemy.

### 2. Abordagem ELT (Modern Data Stack)

- **Extração & Carga (EL):** Python é usado exclusivamente para carregar os dados brutos no schema `staging` do banco, sem nenhum tratamento prévio.
- **Transformação (T):** O **dbt (data build tool)** orquestra todas as transformações diretamente no banco de dados usando SQL:
  - **Staging:** Unificação e limpeza inicial dos dados brutos (`stg_itbi_raw.sql`).
  - **Dimensions:** Criação das tabelas dimensão com surrogate keys e atributos derivados.
  - **Facts:** Construção da tabela fato via joins com as dimensões.

---

## ⭐ Modelagem de Dados (Esquema Estrela)

Ao final do pipeline, os dados são organizados em um modelo dimensional para facilitar análises de mercado imobiliário:

| Tabela | Tipo | Descrição |
|:---|:---|:---|
| **`fato_transacao_itbi`** | **Fato** | Registro de cada transação imobiliária. Contém métricas (valor de avaliação, áreas, valor/m², idade do imóvel) e chaves estrangeiras (SKs) para as dimensões. |
| **`dim_tempo`** | Dimensão | Calendário detalhado (dia, mês, trimestre, ano, dia da semana) derivado da data de transação. |
| **`dim_localizacao`** | Dimensão | Endereço físico do imóvel (logradouro, número, bairro) com código oficial de logradouro para deduplicação. |
| **`dim_imovel`** | Dimensão | Características físicas do imóvel (complemento, nome do edifício, ano e década de construção). |
| **`dim_caracteristica`** | Dimensão | Atributos qualitativos agrupados como junction dimension (tipo de imóvel, tipo de construção, padrão de acabamento, estado de conservação, tipo de ocupação). |

> A granularidade da tabela fato é **uma linha por transação de ITBI**. Todas as dimensões utilizam surrogate keys inteiras geradas no momento da carga, independentes das chaves naturais da fonte.

---

## 🛠️ Tecnologias Utilizadas

- 🐍 **Python 3.10+** - Scripting e manipulação de dados (Pandas)
- 🐘 **PostgreSQL / Supabase** - Data Warehouse
- 🔧 **dbt Core** - Orquestração de transformações SQL, testes de dados e documentação de linhagem
- 🔌 **SQLAlchemy & Psycopg2** - Conectores de banco de dados
- 📓 **Google Colab** - Ambiente de desenvolvimento dos notebooks
- 🐙 **Git / GitHub** - Versionamento de código e colaboração

---

## 📂 Estrutura do Repositório

```
Grupo1-BD-Int.-de-dados/
│
├── dbt_project/                        # Projeto dbt (Pipeline ELT: Transformação)
│   ├── macros/
│   │   └── generate_schema_name.sql    # Macro para geração de nomes de schema
│   ├── models/
│   │   ├── dimensions/                 # Modelos das tabelas dimensão
│   │   │   ├── dim_caracteristica.sql
│   │   │   ├── dim_imovel.sql
│   │   │   ├── dim_localizacao.sql
│   │   │   └── dim_tempo.sql
│   │   ├── facts/                      # Modelo da tabela fato
│   │   │   └── fato_transacao_itbi.sql
│   │   └── staging/                    # Unificação e limpeza dos dados brutos
│   │       └── stg_itbi_raw.sql
│   ├── dbt_project.yml                 # Configuração do projeto dbt
│   └── profiles.yml                    # Credenciais de conexão (não versionado)
│
├── insights/                           # Análises e insights sobre o Data Warehouse
│   └── insights.ipynb                  # Queries analíticas sobre o modelo estrela (top bairros, evolução temporal, padrão de acabamento)
│
├── notebooks/                          # Notebooks do pipeline
│   ├── create_dw_etl.ipynb             # Pipeline 1: ETL completo em Python/Pandas
│   └── uniao.ipynb                     # Unificação dos CSVs brutos
│
├── Planilhas/                          # Dados de entrada
│   ├── anos/                           # CSVs originais por ano (2023, 2024, 2025)
│   ├── dicionario-de-dados-itbi.json   # Dicionário de dados da fonte original
│   └── imoveis_unificado.csv           # CSV consolidado após unificação
│
├── Tratamento/                         # Notebooks de tratamento e carga
│   ├── ELT.ipynb                       # Pipeline 2: Carga bruta + transformação SQL
│   └── ETL.ipynb                       # Notebooks individuais de tratamento por coluna
│
├── .env.example                        # Exemplo de variáveis de ambiente
├── .gitignore
└── README.md
```

---

## 🚀 Como Executar

### Pré-requisitos

1. Instale Python 3.10+ e tenha acesso a um banco PostgreSQL (local ou Supabase).
2. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/Grupo1-BD-Int.-de-dados.git
   cd Grupo1-BD-Int.-de-dados
   ```
3. Instale as dependências:
   ```bash
   pip install pandas sqlalchemy psycopg2-binary dbt-postgres python-dotenv
   ```
4. Copie o arquivo de exemplo de variáveis de ambiente e preencha com suas credenciais:
   ```bash
   cp .env.example .env
   ```

---

### Pipeline 1 - ETL (Python/Pandas)

Execute os notebooks na seguinte ordem no Google Colab ou Jupyter:

1. `notebooks/uniao.ipynb` - unifica os três CSVs anuais em `imoveis_unificado.csv`
2. `Tratamento/ETL.ipynb` - aplica todas as transformações e gera as dimensões e fato em memória
3. `notebooks/create_dw_etl.ipynb` - carrega o modelo estrela no PostgreSQL

---

### Pipeline 2 - ELT (Python + dbt)

**Passo 1 - Carga Inicial (EL)**

Execute o notebook `Tratamento/ELT.ipynb`. Ele lerá os CSVs da pasta `Planilhas/anos/` e criará a tabela `staging.itbi_raw` no banco com os dados brutos dos três anos.

**Passo 2 - Configuração do dbt**

Configure o arquivo `profiles.yml` dentro de `dbt_project/` com as credenciais do seu PostgreSQL:

```yaml
itbi_dw:
  target: dev
  outputs:
    dev:
      type: postgres
      host: db.<seu-projeto>.supabase.co
      port: 5432
      user: postgres
      password: <sua-senha>
      dbname: postgres
      schema: dw
      threads: 4
```

Teste a conexão:
```bash
cd dbt_project
dbt debug
```

**Passo 3 - Execução das Transformações**

```bash
# Constrói todos os modelos (staging → dimensões → fato)
dbt run

# Executa os testes de qualidade (not_null, unique, relationships)
dbt test

# Abre documentação interativa com o grafo de linhagem
dbt docs generate
dbt docs serve
```

---

## 📊 Análises e Insights

As queries analíticas estão implementadas no notebook `analysis/insights.ipynb`, executado após o `dbt run` sobre o schema `dw_elt` já populado. As análises disponíveis são:

1. **Top 10 bairros por valor médio de avaliação** - ranking dos bairros com maior valor médio de avaliação e valor médio por m² construído, cruzando `fato_transacao_itbi` com `dim_localizacao`.
2. **Evolução anual e trimestral do volume de transações** - série temporal com contagem de transações e valor médio de avaliação por ano e trimestre, via `dim_tempo`.
3. **Valor médio por padrão de acabamento e tipo de imóvel** - comparativo de valor médio e valor/m² segmentado por padrão (Simples, Médio, Superior) e tipo de imóvel, via `dim_caracteristica`.

> O notebook carrega as credenciais automaticamente a partir do arquivo `.env` - configure-o antes de executar.

---

## 👥 Equipe

| Login | Nome |
|:---|:---|
| agan | Antonio Gonçalves de Albuquerque Neto |
| dcms3 | Daniel Cavalcanti da Motta Silveira |
| fam3 | Felipe de Aquino Mulato |
| gmtbn | Gabriel Mezzalira Teixeira Batista do Nascimento |
| iccs | Iago Coutinho da Costa e Silva |
| laco | Leonardo Alves Cavalcanti de Oliveira |

---
Relatório final do projeto: https://docs.google.com/document/d/18oq8vQ65WMu9GECNWZ7LxznStrxrsmG9vRCwPo0DeBU/edit?tab=t.0
  
> *Projeto desenvolvido para a disciplina de Banco de Dados - CIn/UFPE, 2025.2. Dados obtidos exclusivamente do [Portal de Dados Abertos da Prefeitura do Recife](https://dados.recife.pe.gov.br), garantindo veracidade e conformidade com a Lei de Acesso à Informação (LAI).*