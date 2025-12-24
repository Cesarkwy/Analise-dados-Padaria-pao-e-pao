import requests
import pandas as pd
import pyodbc
from bs4 import BeautifulSoup
from io import StringIO
from datetime import datetime

# =========================
# CONFIGURAÇÕES
# =========================

BASE_URL = "http://localhost:8000"

URL_CLIENTES = f"{BASE_URL}/clientes.json"
URL_MEMBROS = f"{BASE_URL}/membros.json"
URL_MENU = f"{BASE_URL}/menu.csv"
URL_VENDAS = f"{BASE_URL}/Vendas.html"

CONN_STR = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=localhost,1433;"
    "DATABASE=pao_e_pao;"
    "UID=sa;"
    "PWD=vL589%Gwd[3;"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

conn = pyodbc.connect(CONN_STR)
cursor = conn.cursor()

# =========================
# CLIENTES (HTTP JSON)
# =========================

clientes = requests.get(f"{BASE_URL}/clientes.json").json()

for c in clientes:
    cursor.execute("""
        IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = ?)
        INSERT INTO clientes (id, nome, deletado, dt_delete)
        VALUES (?, ?, ?, ?)
    """,
    c["id"],
    c["id"],
    c["nome"],
    int(c["deletado"]),
    c["dt_delete"]
)

conn.commit()
print("Clientes inseridos")

# =========================
# MEMBROS (HTTP JSON)
# =========================

membros = requests.get(f"{BASE_URL}/membros.json").json()

for m in membros:
    cursor.execute("""
        IF NOT EXISTS (SELECT 1 FROM membros WHERE id = ?)
        INSERT INTO membros (id, cliente_id, dt_inicio_assinatura, dt_fim_assinatura)
        VALUES (?, ?, ?, ?)
    """,
    m["id"],
    m["id"],
    m["cliente_id"],
    m["dt_inicio_assinatura"],
    m["dt_fim_assinatura"]
)

conn.commit()
print("Membros inseridos")

# =========================
# MENU (DOWNLOAD CSV via HTTP)
# =========================

csv_text = requests.get(f"{BASE_URL}/menu.csv").content.decode("utf-8-sig")
df_menu = pd.read_csv(StringIO(csv_text), sep=";")

for _, row in df_menu.iterrows():
    cursor.execute("""
        IF NOT EXISTS (SELECT 1 FROM menu WHERE item_id = ?)
        INSERT INTO menu (item_id, produto, preco)
        VALUES (?, ?, ?)
    """,
    int(row["ITEM_ID"]),
    int(row["ITEM_ID"]),
    row["ITEM_NOME"],
    float(row["ITEM_PRECO_CENTS"]) / 100)

conn.commit()
print("Menu inserido")

# =========================
# VENDAS (WEB SCRAPING)
# =========================

html = requests.get(f"{BASE_URL}/Vendas.html").text
soup = BeautifulSoup(html, "html.parser")

table = soup.find("table")
rows = table.find_all("tr")[1:]  # pula cabeçalho

for r in rows:
    cols = [c.text.strip() for c in r.find_all("td")]

    cliente_nome = cols[0]
    produto_item_id = int(cols[1])
    data_venda_str = cols[2]

    # Exemplo: "01/01/2025 as 09h43"
    data_venda_str = data_venda_str.replace(" as ", " ")
    data_venda_str = data_venda_str.replace("h", ":")

    data_venda = datetime.strptime(
        data_venda_str, "%d/%m/%Y %H:%M"
    )

    cursor.execute("""
        INSERT INTO vendas (data_venda, cliente_nome, produto_item_id)
        VALUES (?, ?, ?)
    """,
    data_venda, cliente_nome, produto_item_id)

conn.commit()
print("Vendas inseridas")
# =========================
# FINALIZAÇÃO
# =========================

cursor.close()
conn.close()

print("ETL concluido com sucesso.")