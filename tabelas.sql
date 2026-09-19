CREATE TABLE clientes (
  id_cliente INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100),
  telefone VARCHAR(20),
  endereco VARCHAR(100),
  obs TEXT
);

CREATE TABLE produtos (
  id_produto INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(30),
  descricao TEXT,
  preco DECIMAL(8,2),
  quantidade INT,
  validade DATE
;

CREATE TABLE venda (
  id_venda INT PRIMARY KEY AUTO_INCREMENT,
  data_venda DATETIME,
  valor_total DECIMAL(10,2),
  forma_pagamento VARCHAR(20)
);

CREATE TABLE ingrediente (
  id_ingrediente INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(30),
  quantidade INT,
  validade DATE,
  preco_compra DECIMAL(10,2)
);

CREATE TABLE historico_ingrediente (
  id_historico_ingrediente INT PRIMARY KEY AUTO_INCREMENT,
  id_ingrediente INT FOREIGN KEY,
  quantidade INT,
  data_h DATE,
  motivo VARCHAR(30),
  obs TEXT
);

CREATE TABLE historico_estoque (
  id_historico_estoque INT PRIMARY KEY AUTO_INCREMENT,
  id_produto INT FOREIGN KEY,
  quantidade INT,
  data_h DATE,
  motivo VARCHAR(30),
  obs TEXT
);

CREATE TABLE pedido (
  id_pedido INT PRIMARY KEY AUTO_INCREMENT,
  id_clientes INT FOREIGN KEY,
  data_pedido DATE,
  data_entrega DATETIME
  endereco_entrega  VARCHAR(100),
  tema VARCHAR(30),
  obs TEXT,
  valor_total DECIMAL(10,2),
  status VARCHAR(20)
);

CREATE TABLE item_pedido (
  id_itpedido INT PRIMARY KEY AUTO_INCREMENT,
  id_pedido INT FOREIGN KEY,
  id_produtos INT FOREIGN KEY,
  quantidade  INT(10),
  preco_unidade DECIMAL(10,2),
  total DECIMAL(10,2)
);

CREATE TABLE item_venda (
  id_itvenda INT PRIMARY KEY AUTO_INCREMENT,
  id_venda INT FOREIGN KEY,
  id_produtos INT FOREIGN KEY,
  quantidade  INT(10),
  preco_unidade DECIMAL(10,2),
  total DECIMAL(10,2)
);
