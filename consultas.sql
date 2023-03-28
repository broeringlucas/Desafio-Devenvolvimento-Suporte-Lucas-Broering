-- Esse arquivo toma conta das consultas solicitadas pelo desafio, tentei cumprir todas as exigências;

-- 1. Listar todos os produtos com nome, descrição e preço em ordem alfabética crescente;

SELECT p.nome_produto, p.descrição, p.preço_tabela, p.preço_importação
FROM tb_produtos p 
ORDER BY p.nome_produto ASC;

-- 2. Listar todas as categorias com nome e número de produtos associados, em ordem alfabética crescente;

SELECT p.categoria, COUNT(*) AS produtos_associados
FROM tb_produtos p 
GROUP BY p.categoria
ORDER BY p.categoria ASC;

-- 3. Listar todos os pedidos com data, endereço de entrega e total do pedido (soma dos preços dos itens), em ordem decrescente de data;

-- Essa consulta aparentemnte retorna menos registros, porém como o banco foi moldado um pedido so tem realmente preço e quantidade quando existi as 
-- informações do mesmo na tabela_info_pedido, por isso ele retorna menos registros. Foi o jeito em que pensei para contornar a relação
-- Muitos para Muitos entre Pedido e Produto. Como os dados são aleatório isso acaba ocorrendo, em uma situação real não aconteceria

SELECT p.Id_pedido, p.data_pedido, c.logradouro, c.bairro, c.cidade, c.cep, 
	   c.uf, SUM(info.preço_venda_unid) AS preço_unitario_total, SUM(info.quant_prod_pedido) AS quantidade_total,
	   (SUM(info.preço_venda_unid) * SUM(info.quant_prod_pedido)) AS Total
FROM tb_pedidos p 
JOIN tb_info_pedidos info ON p.Id_pedido = info.Id_pedido
JOIN tb_clientes c ON p.Id_cliente = c.Id_cliente
GROUP by p.Id_pedido, p.data_pedido, c.logradouro, c.bairro, c.cidade, c.cep, c.uf
ORDER BY p.data_pedido DESC;

-- 4. Listar todos os produtos que já foram vendidos em pelo menos um pedido, com nome, descrição, preço e quantidade total vendida, em ordem decrescente de
-- quantidade total vendida;

SELECT p.nome_produto, p.descrição, p.preço_tabela, p.preço_importação, info.preço_venda_unid , SUM(info.quant_prod_pedido) AS quantidade_total_vendida
FROM tb_produtos p 
JOIN tb_info_pedidos info ON p.Id_produto = info.Id_produto
GROUP BY p.nome_produto, p.descrição, p.preço_tabela, p.preço_importação, info.preço_venda_unid 
ORDER BY quantidade_total_vendida DESC;

-- 5. Listar todos os pedidos feitos por um determinado cliente, filtrando-os por um determinado período, em ordem alfabética crescente do nome do cliente e ordem
--crescente da data do pedido;

-- Essa função recebe 3 paramêtros, id do cliente(id_c), data_inicial e data_final, e o id do cliente e todos os pedidos realizados 
-- nesse intervalo de tempo determinado por quem chamou a função;

-- Deleta função;
DROP FUNCTION pedidos_c(id_c INTEGER, data_i varchar, data_f varchar);
-- Cria função;
CREATE FUNCTION pedidos_c(id_c INTEGER, data_i varchar, data_f varchar)
RETURNS TABLE (nome_cliente varchar(40),
			   sobrenome_cliente varchar(40),
			   Id_pedido INTEGER,
			   data_pedido varchar(30),
			   prazo_entrega smallint,
			   id_cliente INTEGER,
			   preço_unitario_total NUMERIC,
			   quantidade_total bigint) AS $$
BEGIN
  RETURN QUERY
	SELECT c.nome_cliente, c.sobrenome_cliente, p.Id_pedido, p.data_pedido, p.prazo_entrega, 
		   p.id_cliente , SUM(info.preço_venda_unid) AS preço_unitario_total, SUM(info.quant_prod_pedido) AS quantidade_total
	FROM tb_pedidos p 
	JOIN tb_info_pedidos info ON p.Id_pedido = info.Id_pedido
	JOIN tb_clientes c ON p.Id_cliente = c.Id_cliente
	WHERE p.id_cliente = id_c AND p.data_pedido >= data_i AND p.data_pedido <= data_f 
	GROUP BY c.nome_cliente, c.sobrenome_cliente, p.Id_pedido, p.data_pedido, p.prazo_entrega, p.id_cliente 
	ORDER BY c.nome_cliente, c.sobrenome_cliente, p.data_pedido ASC;
END;
$$ LANGUAGE plpgsql;

-- Utilizando os registros feitos manualmente, consegue-se ver a diferença entre as consultas e que a função funciona;
SELECT * FROM pedidos_c(10, '2017-08-20', '2022-04-15');
SELECT * FROM pedidos_c(10, '2017-08-20', '2022-12-15');

-- Um exemplo utilizando os dados gerados aleatóriamente pelas funções, isso depende dos dados
-- gerados, mas o formato é esse;

-- SELECT * FROM pedidos_c(3, 'Data_pedido1', 'Data_pedido90');

--6. Listar possíveis produtos com nome replicado e a quantidade de replicações, em
--ordem decrescente de quantidade de replicações;

SELECT p.nome_produto, COUNT(*) AS quantidade_replicações
FROM tb_produtos p 
GROUP BY p.nome_produto
ORDER BY quantidade_replicações DESC;

-- Apenas para verificar se as tabelas foram preenchidas
-- Seleciona toda a tabela de produtos;
SELECT * FROM tb_produtos;
-- Seleciona toda a tabela de pedidos;
SELECT * FROM tb_pedidos;
-- Seleciona toda a tabela de clientes;
SELECT * FROM tb_clientes;
-- Seleciona toda a tabela de info_pedidos;
SELECT * FROM tb_info_pedidos;