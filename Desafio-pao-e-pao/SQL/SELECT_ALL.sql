-- 1) Total gasto por cada cliente

SELECT
    v.cliente_nome,
    SUM(m.preco) AS total_gasto
FROM vendas v
JOIN menu m ON m.item_id = v.produto_item_id
GROUP BY v.cliente_nome
ORDER BY total_gasto DESC;


-- 2) Quantos dias cada cliente realizou ao menos um pedido

SELECT
    cliente_nome,
    COUNT(DISTINCT data_venda) AS dias_com_pedido
FROM vendas
GROUP BY cliente_nome;


-- 3) Primeiro pedido de cada cliente

SELECT
    v.cliente_nome,
    MIN(v.data_venda) AS primeiro_pedido
FROM vendas v
GROUP BY v.cliente_nome;


-- 4) Item mais pedido do cardápio + quantidade

SELECT TOP 1
    m.produto,
    COUNT(*) AS vezes_pedido
FROM vendas v
JOIN menu m ON m.item_id = v.produto_item_id
GROUP BY m.produto
ORDER BY vezes_pedido DESC;


-- 5) Item mais pedido por cada cliente

WITH pedidos AS (
    SELECT
        v.cliente_nome,
        m.produto,
        COUNT(*) AS total
    FROM vendas v
    JOIN menu m ON m.item_id = v.produto_item_id
    GROUP BY v.cliente_nome, m.produto
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cliente_nome ORDER BY total DESC) AS rn
    FROM pedidos
)
SELECT
    cliente_nome,
    produto,
    total
FROM ranked
WHERE rn = 1;


-- 6) Primeiro item pedido após se tornar membro

WITH pedidos AS (
    SELECT
        c.nome,
        m2.produto,
        v.data_venda,
        ROW_NUMBER() OVER (
            PARTITION BY c.id
            ORDER BY v.data_venda
        ) AS rn
    FROM membros mb
    JOIN clientes c        ON c.id = mb.cliente_id
    JOIN vendas v          ON v.cliente_nome = c.nome
    JOIN menu m2           ON m2.item_id = v.produto_item_id
    WHERE v.data_venda >= CAST(mb.dt_inicio_assinatura AS DATE)
)
SELECT
    nome,
    produto,
    data_venda
FROM pedidos
WHERE rn = 1;



-- 7) Último item pedido antes de se tornar membro

WITH pedidos AS (
    SELECT
        c.nome,
        m2.produto,
        v.data_venda,
        ROW_NUMBER() OVER (
            PARTITION BY c.id
            ORDER BY v.data_venda DESC
        ) AS rn
    FROM membros mb
    JOIN clientes c        ON c.id = mb.cliente_id
    JOIN vendas v          ON v.cliente_nome = c.nome
    JOIN menu m2           ON m2.item_id = v.produto_item_id
    WHERE v.data_venda < CAST(mb.dt_inicio_assinatura AS DATE)
)
SELECT
    nome,
    produto,
    data_venda
FROM pedidos
WHERE rn = 1;



-- 8) Total de itens pedidos antes de se tornar membro

SELECT
    c.nome,
    COUNT(*) AS total_itens_antes
FROM membros mb
JOIN clientes c ON c.id = mb.cliente_id
JOIN vendas v ON v.cliente_nome = c.nome
WHERE v.data_venda < CAST(mb.dt_inicio_assinatura AS DATE)
GROUP BY c.nome;


-- 9) Total gasto antes de se tornar membro

SELECT
    c.nome,
    SUM(m.preco) AS total_gasto_antes
FROM membros mb
JOIN clientes c ON c.id = mb.cliente_id
JOIN vendas v ON v.cliente_nome = c.nome
JOIN menu m ON m.item_id = v.produto_item_id
WHERE v.data_venda < CAST(mb.dt_inicio_assinatura AS DATE)
GROUP BY c.nome;


-- 10) Pontos por cliente

SELECT
    v.cliente_nome,
    SUM(
        m.preco * 10 *
        CASE
            WHEN m.produto = 'Pão de Queijo un.' THEN 2
            ELSE 1
        END
    ) AS pontos
FROM vendas v
JOIN menu m ON m.item_id = v.produto_item_id
GROUP BY v.cliente_nome;


-- 11) Pontos de Samuel e Daniel até final de fevereiro

SELECT
    c.nome,
    SUM(
        m.preco * 10 *
        CASE
            WHEN v.data_venda BETWEEN
                 CAST(mb.dt_inicio_assinatura AS DATE)
                 AND DATEADD(DAY, 6, CAST(mb.dt_inicio_assinatura AS DATE))
            THEN 2
            ELSE 1
        END
    ) AS pontos
FROM membros mb
JOIN clientes c ON c.id = mb.cliente_id
JOIN vendas v ON v.cliente_nome = c.nome
JOIN menu m ON m.item_id = v.produto_item_id
WHERE c.nome IN ('Samuel', 'Daniel')
  AND v.data_venda <= '2025-02-28'
GROUP BY c.nome;
