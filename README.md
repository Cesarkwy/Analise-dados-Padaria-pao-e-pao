# Desafio – Analista de Dados - Padaria Pão & Pão

Este projeto realiza a extração, transformação e carga (ETL) de dados provenientes de múltiplas fontes, armazena-os em um banco de dados SQL Server e gera métricas e visualizações no Power BI.

## Arquitetura da Solução

### Fontes de Dados
- `clientes.json` (HTTP Request)
- `membros.json` (HTTP Request)
- `menu.csv` (HTTP Request)
- `Vendas.html` (Web Scraping)

### Tecnologias Utilizadas
- **ETL**: Python
- **Banco de Dados**: SQL Server (Docker + Extensão mssql VsCode)
- **Visualização**: Power BI

## Estrutura do Projeto

```
Desafio-pao-e-pao/
├── dados/
│   ├── clientes.json
│   ├── membros.json
│   ├── menu.csv
│   └── Vendas.html
├── dashboard/
│   └── Desafio_Analista_Dados_Pao_e_Pao.pbix
├── ETL/
│   ├── etl_pao_e_pao.py
│   └── teste_connection.py
├── sql/
│   ├── create_tables.sql
│   └── SELECT_ALL.sql
├── sql-server-container/
│   └── docker-compose.yml
└── README.md
```

## Pré-requisitos

- Docker instalado
- Docker Desktop em execução
- Python 3.7+

## Como Executar

### 1. Subindo o SQL Server com Docker

Na pasta que contém o docker-compose.yml

```bash
docker compose up -d
```

### 2. Criação do Banco e das Tabelas

Conecte-se ao SQL Server usando a extensão SQL Server (mssql) no VS Code:
Todos definidos no (`docker-compose.yml`).
- **Servidor**: localhost
- **Usuário**: sa
- **Senha**: definida no Docker
- **Porta**: 1433

Crie o banco de dados:

```sql
CREATE DATABASE pao_e_pao;
GO
```

Execute o script de criação das tabelas (`SQL/create_tables.sql`):

```sql
CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    deletado BIT NOT NULL,
    dt_delete DATETIME NULL
);

CREATE TABLE membros (
    id INT PRIMARY KEY,
    cliente_id INT NOT NULL,
    dt_inicio_assinatura DATETIME NOT NULL,
    dt_fim_assinatura DATETIME NULL,
    CONSTRAINT fk_membros_clientes
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE menu (
    item_id INT PRIMARY KEY,
    produto NVARCHAR(150) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

CREATE TABLE vendas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    data_venda DATE NOT NULL,
    cliente_nome NVARCHAR(100) NOT NULL,
    produto_item_id INT NOT NULL,
    CONSTRAINT fk_vendas_menu
        FOREIGN KEY (produto_item_id) REFERENCES menu(item_id)
);
```

### 3. Servindo os arquivos via HTTP

Na pasta `dados/`, execute:

```bash
python -m http.server 8000
```

Os arquivos estarão disponíveis em:
- `http://localhost:8000/clientes.json`
- `http://localhost:8000/membros.json`
- `http://localhost:8000/menu.csv`
- `http://localhost:8000/Vendas.html`

### 4. Testando a Conexão com o Banco

```bash
python ETL/teste_connection.py
```

**Saída esperada**: `Conexão realizada com sucesso!`

### 5. Execução do ETL

```bash
python ETL/etl_pao_e_pao.py
```

O script realiza:
- HTTP requests para JSON e CSV
- Web scraping da página Vendas.html
- Tratamento de tipos de dados
- Inserção no SQL Server
- Prevenção de duplicatas

**Saída esperada**:
```
Clientes inseridos
Membros inseridos
Menu inserido
Vendas inseridas
ETL concluido com sucesso.
```

### 6. Verificação dos Dados

```sql
SELECT * FROM clientes;
SELECT * FROM membros;
SELECT * FROM menu;
SELECT * FROM vendas;
```
Outras consultas disponíveis em (`SQL/SELECT_ALL.sql`)


### 7. Dashboard com PowerBI

- Dados do banco de dados inseridos no Power BI
- Dashboard criado e disponível em `dashboard/Desafio_Analista_Dados_Pao_e_Pao.pbix`

<img width="1499" height="841" alt="image" src="https://github.com/user-attachments/assets/058bc899-9a9d-442b-baec-b930f9f92df4" />
