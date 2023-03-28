-- Considerei que um banco de dados ja estaria criado, aqui estão os scripts para criar as tabelas do banco;
-- Criei o Database utilizando pgAdmin 4 e sua interface;

-- Todoas as primary keys das tabelas estão com auto incremento, porém no planejamento do esquema,
-- faz sentido ter mais caracteres, numeros e letras, para ser mais parecido com o mundo real. FIz dessa forma,
-- com auto incremento para ser mais didático;

-- O número de caracteres no varchar, eu optei por escolher um número alto, para evitar erros nos testes, é aconselhavél
-- fazer um estudo breve com a ánalise de negócio para escolher um número mais proxímo do que será utlizado;

-- Verifica se as tabelas ja existem no banco e se sim, elas são deletadas;

DROP TABLE IF EXISTS tb_clientes CASCADE;
DROP TABLE IF EXISTS tb_pedidos CASCADE;
DROP TABLE IF EXISTS tb_produtos CASCADE;
DROP TABLE IF EXISTS tb_info_pedidos;

-- Cria a tabela clientes, possui os atributos da entidade Cliente, exemplificada no DER; 
-- A variável Data_nasimento a princinpio é para ser do tipo DATE, porém para facilitar no script para gerar dados eu optei por deixar varchar;

CREATE TABLE tb_clientes (
	ID_cliente SERIAL PRIMARY KEY,
	Nome_cliente varchar(255) NOT NULL,
	Sobrenome_cliente varchar(255) NOT NULL,
	Data_nascimento varchar(255) NOT NULL, 
	CPF varchar(255) NOT NULL UNIQUE, 
	UF char(255) NOT NULL, 
	CEP varchar(255) NOT NULL, 
	Logradouro varchar(255) NOT NULL, 
	Bairro varchar(255) NOT NULL, 
	Cidade varchar(255) NOT NULL,
	Telefone varchar(255) NOT NULL,
	Email varchar(255) NOT NULL
);

-- Cria a tabela pedidos, possui os atributos da entidade Pedido, exemplificada no DER; 
-- A variável Data_pedido a princinpio é para ser do tipo DATE, porém para facilitar no script para gerar dados eu optei por deixar varchar;

CREATE TABLE tb_pedidos (
	ID_pedido SERIAL PRIMARY KEY,
	Data_pedido varchar(255) NOT NULL, 
	Prazo_entrega smallint NOT NULL,
	ID_cliente integer NOT NULL,
	FOREIGN KEY (ID_cliente)
	   REFERENCES tb_clientes (ID_cliente)
);

-- Cria a tabela produtos, possui os atributos da entidade Produto, exemplificada no DER; 

CREATE TABLE tb_produtos (
	ID_produto SERIAL PRIMARY KEY,
	Nome_produto varchar(255) NOT NULL,
	Descrição text, 
	Quantidade_estoque smallint NOT NULL, 
	Categoria varchar(255) NOT NULL, 
	Preço_tabela decimal(12,2) NOT NULL,
	Preço_importação decimal(12,2) NOT NULL
);

-- Cria a tabela informação dos pedidos, possui os atributos da entidade Pedido-Produto, exemplificada no DER; 

-- A primary key dessa tabela e composta, ou seja e um conjunto de valores do id_pedido e id_produto 
-- Exemplo: Um pedido 1 pode ter produtos 3 e 5; então 1 e 3 são a primary key de um registro e 1 e 5 de outro;

CREATE TABLE tb_info_pedidos (
	ID_pedido integer NOT NULL,
	ID_produto integer NOT NULL,
	FOREIGN KEY (ID_pedido)
	   REFERENCES tb_pedidos (ID_pedido),
	FOREIGN KEY (ID_produto)
	   REFERENCES tb_produtos (ID_produto),
	PRIMARY KEY (ID_pedido, ID_produto), 
	Preço_venda_unid decimal(12,2) NOT NULL, 
	Quant_prod_pedido smallint NOT NULL