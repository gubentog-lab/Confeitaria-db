CREATE TABLE clientes (
  id_cliente INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100),
  telefone VARCHAR(20),
  endereco VARCHAR(100)
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
  valor_total DECIMAL(10,2)
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
