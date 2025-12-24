import pyodbc

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=localhost,1433;"
    "DATABASE=pao_e_pao;"
    "UID=sa;"
    "PWD=vL589%Gwd[3;"
    "TrustServerCertificate=yes;"
)

print("Conexão realizada com sucesso!")
conn.close()
