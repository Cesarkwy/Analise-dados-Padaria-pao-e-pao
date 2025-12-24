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
