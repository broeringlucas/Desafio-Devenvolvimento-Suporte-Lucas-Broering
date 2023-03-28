-- Esse arquivo cuida da parte de popular as tabelas com dados genéricos;

-- Na hora de fazer os registros, importante destacar que existem tabelas que dependem de outras então se tentar
-- fazer registros na tabela pedidos antes de ter registros na tabela clientes vai dar erro Pois id_cliente é uma
-- foreign key na tabela pedidos. Assim como acontece na tabela_info_pedidos, com as foreign keys id_pedido e id_produto.

-- Exclui função popular_tb_clientes;

DROP FUNCTION popular_tb_clientes(num_registros INTEGER);

-- Cria função popular_tb_cliente;

-- Essa função recebe um paramêtro num_registros, seria o número de linhas que deseja adicionar, os valores são genéricos;
-- cliente1, cliente1... 

CREATE FUNCTION popular_tb_clientes(num_registros INTEGER)
RETURNS VOID AS $$
BEGIN
  FOR i IN 1..num_registros LOOP
	INSERT INTO tb_clientes(Nome_cliente,
                        	Sobrenome_cliente,
                        	Data_nascimento,
                        	CPF,
                        	UF,
                        	CEP,
                        	Logradouro,
                        	Bairro,
                        	Cidade,
                        	Telefone,
                        	Email)
    VALUES (
		'cliente' || i,
		'Sobrenome' || i, 
		'Data_nascimento' || floor(random() * 200 + 1),
		'CPF' || i,
		'UF' || i, 
		'CEP' || i,
		'Logradouro' || i, 
		'Bairro' || i, 
		'Cidade' || i,
		'Telefone' || i,
		'Email' || i
	);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Exclui a função popular_tb_pedidos;

DROP FUNCTION popular_tb_pedidos(num_registros INTEGER);

-- Cria função popular_tb_pedidos;

-- Essa função recebe um paramêtro num_registros, seria o número de linhas que deseja adicionar, os valores são genéricos
-- Data_pedido1, Data_pedido2...  Também gera um número aleatório para prazo_entrega entre 1 à 31 dias;

-- Na questao da data eu fiz com que ela varia entre 90 datas diferentes, referentes a 3 meses de pedidos;

-- É preciso ter registros na tb_clientes para prencher essa tabela, já que o id_cliente é uma Foreign Key; 

CREATE FUNCTION popular_tb_pedidos(num_registros INTEGER)
RETURNS VOID AS $$
BEGIN
  FOR i IN 1..num_registros LOOP
	INSERT INTO tb_pedidos(Data_pedido,
                           Prazo_entrega,
                           ID_cliente)
    VALUES (
		    'Data_pedido' || floor(random() * 90 + 1),
		    (random() * 30 + 1)::int,
        (SELECT id_cliente FROM tb_clientes ORDER BY random() LIMIT 1)
	);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Exclui a função popular_tb_produtos;

DROP FUNCTION popular_tb_produtos(num_registros INTEGER);

-- Cria a função popular_tb_produtos; 

-- Essa função recebe um paramêtro num_registros, seria o número de linhas que deseja adicionar, os valores são genéricos
-- Produto1, Produto2... Também cria um número aleatório para Quantidade_estoque, Preço_tabela e Preço_importação;

CREATE FUNCTION popular_tb_produtos(num_registros INTEGER)
RETURNS VOID AS $$
BEGIN
  FOR i IN 1..num_registros LOOP
	INSERT INTO tb_produtos(Nome_produto,
                            Descrição,
                            Quantidade_estoque,
                            Categoria,
                            Preço_tabela,
                            Preço_importação)
    VALUES (
	'Produto' || (random() * 100 + 1)::int,
    'Descrição' || i,
    (random() * 3000)::int,
    'Categoria' || (random() * 15 + 1)::int,
	(random() * 6000 + 1),
    (random() * 4000 + 1)
	);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Exclui a função popular_tb_info_pedidos;

DROP FUNCTION popular_tb_info_pedidos(num_registros INTEGER);

-- Cria a função popular_tb_info_pedidos;

-- Essa função recebe um paramêtro num_registros, seria o número de linhas que deseja adicionar, os valores são aleatórios 
-- dentro de um range para o Preço_venda_unid e Quant_prod_pedido. Já para os ID_pedido e ID_produto, foi um pouco complexo fazer
-- pois os dois combinados formam a Primary Key dessa tabela, então não poderia ter combinações iguais. Tive que fazer uma subquary
-- além de juntar os dois valores para depois separa-lós, já que uma subquary não pode retornar duas colunas. Transformo ambos os id
-- em uma coluna e depois separo eles novamente em dois;

-- É preciso ter registros na tb_pedidos e tb_produtos para prencher essa tabela, já o id_pedido e o id_produto são Foreign Keys
-- que juntas formam a Primary Key dessa tabela;

CREATE FUNCTION popular_tb_info_pedidos(num_registros INTEGER)
RETURNS VOID AS $$
BEGIN
  FOR i IN 1..num_registros LOOP
    INSERT INTO tb_info_pedidos(ID_pedido, ID_produto, Preço_venda_unid, Quant_prod_pedido)
    SELECT 
      split_part(combined_id, '_', 1)::int,
      split_part(combined_id, '_', 2)::int,
      (random() * 500 + 1),
      (random() * 10000)::int
    FROM (
      SELECT 
        p.id_pedido || '_' || pro.id_produto as combined_id
      FROM 
        tb_pedidos p, tb_produtos pro
      WHERE 
        NOT EXISTS (
          SELECT 1 FROM tb_info_pedidos info
          WHERE info.id_pedido = p.id_pedido AND info.id_produto = pro.id_produto
        )
      ORDER BY random() LIMIT 1
    ) subquery;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- É preciso criar as funções acima para popular as tabelas, a quantidade de inserts pode ser controlada;

-- Cria 100 registros na tb_clientes;
-- Se você tentar rodas duas vezes seguidas essa função sem exlui os registros 
-- vai dar erro, pois viola a restrição UNIQUE do cpf 
SELECT * FROM popular_tb_clientes(100);

-- Cria 100 registros na tb_pedidos;
SELECT * FROM popular_tb_pedidos(100);

-- Cria 100 registros na tb_produtos;
SELECT * FROM popular_tb_produtos(100);

-- Cria 100 registros na tb_info_pedidos; 
-- Depedendo do número de registros, essa função pode demorar um pouco pois e preciso ter uma combinação 
-- diferente de id_pedido e id_produto para cara registro. Fazer dessa forma demora mas é o jeito certo, 
-- para evitar um relacionamento Muitos para Muitos;
SELECT * FROM popular_tb_info_pedidos(100);