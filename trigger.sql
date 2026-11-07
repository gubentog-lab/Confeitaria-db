USE lucakess_db;

DELIMITER $$

-- =========================================================
-- A) HISTORICO_INGREDIENTE
-- =========================================================
CREATE TRIGGER trg_hi_before_insert
BEFORE INSERT ON historico_ingrediente
FOR EACH ROW
BEGIN
    DECLARE v_atual DECIMAL(10,3);

    IF NEW.motivo NOT IN ('Compra','Devolução','Ajuste Entrada',
                          'Produção','Perda','Ajuste Saída') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Motivo inválido para histórico de ingrediente';
    END IF;

    IF NEW.motivo IN ('Produção','Perda','Ajuste Saída') THEN
        SELECT quantidade INTO v_atual
          FROM ingrediente
         WHERE id_ingrediente = NEW.id_ingrediente;

        IF v_atual < NEW.quantidade THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Estoque de ingrediente insuficiente';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_hi_after_insert
AFTER INSERT ON historico_ingrediente
FOR EACH ROW
BEGIN
    IF NEW.motivo IN ('Compra','Devolução','Ajuste Entrada') THEN
        UPDATE ingrediente
           SET quantidade = quantidade + NEW.quantidade
         WHERE id_ingrediente = NEW.id_ingrediente;
    ELSE
        UPDATE ingrediente
           SET quantidade = quantidade - NEW.quantidade
         WHERE id_ingrediente = NEW.id_ingrediente;
    END IF;
END$$

-- =========================================================
-- B) HISTORICO_ESTOQUE (produtos)
-- =========================================================
CREATE TRIGGER trg_he_before_insert
BEFORE INSERT ON historico_estoque
FOR EACH ROW
BEGIN
    DECLARE v_atual INT;

    IF NEW.motivo NOT IN ('Produção','Devolução','Ajuste Entrada',
                          'Venda','Descarte','Degustação','Ajuste Saída') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Motivo inválido para histórico de estoque';
    END IF;

    IF NEW.motivo IN ('Venda','Descarte','Degustação','Ajuste Saída') THEN
        SELECT quantidade INTO v_atual
          FROM produtos
         WHERE id_produto = NEW.id_produto;

        IF v_atual < NEW.quantidade THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Estoque de produto insuficiente';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_he_after_insert
AFTER INSERT ON historico_estoque
FOR EACH ROW
BEGIN
    IF NEW.motivo IN ('Produção','Devolução','Ajuste Entrada') THEN
        UPDATE produtos
           SET quantidade = quantidade + NEW.quantidade
         WHERE id_produto = NEW.id_produto;
    ELSE
        UPDATE produtos
           SET quantidade = quantidade - NEW.quantidade
         WHERE id_produto = NEW.id_produto;
    END IF;

    -- Produzir um produto consome os ingredientes da receita
    IF NEW.motivo = 'Produção' THEN
        INSERT INTO historico_ingrediente
               (id_ingrediente, quantidade, data_h, motivo, obs)
        SELECT pi.id_ingrediente,
               pi.quantidade * NEW.quantidade,
               NEW.data_h,
               'Produção',
               CONCAT('Consumo automático - produto ', NEW.id_produto)
          FROM produto_ingrediente pi
         WHERE pi.id_produto = NEW.id_produto;
    END IF;
END$$

-- =========================================================
-- C) ITEM_VENDA
-- =========================================================
CREATE TRIGGER trg_iv_after_insert
AFTER INSERT ON item_venda
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produto, quantidade, motivo, obs)
    VALUES (NEW.id_produto, NEW.quantidade, 'Venda',
            CONCAT('Venda ', NEW.id_venda));

    UPDATE venda
       SET valor_total = (SELECT COALESCE(SUM(quantidade * preco_unidade), 0)
                            FROM item_venda
                           WHERE id_venda = NEW.id_venda)
     WHERE id_venda = NEW.id_venda;
END$$

CREATE TRIGGER trg_iv_after_update
AFTER UPDATE ON item_venda
FOR EACH ROW
BEGIN
    -- Ajusta o estoque se a quantidade mudou (mesmo produto)
    IF OLD.id_produto = NEW.id_produto AND NEW.quantidade > OLD.quantidade THEN
        INSERT INTO historico_estoque (id_produto, quantidade, motivo, obs)
        VALUES (NEW.id_produto, NEW.quantidade - OLD.quantidade, 'Venda',
                CONCAT('Ajuste na venda ', NEW.id_venda));
    ELSEIF OLD.id_produto = NEW.id_produto AND NEW.quantidade < OLD.quantidade THEN
        INSERT INTO historico_estoque (id_produto, quantidade, motivo, obs)
        VALUES (NEW.id_produto, OLD.quantidade - NEW.quantidade, 'Devolução',
                CONCAT('Ajuste na venda ', NEW.id_venda));
    END IF;

    UPDATE venda
       SET valor_total = (SELECT COALESCE(SUM(quantidade * preco_unidade), 0)
                            FROM item_venda
                           WHERE id_venda = NEW.id_venda)
     WHERE id_venda = NEW.id_venda;
END$$

CREATE TRIGGER trg_iv_after_delete
AFTER DELETE ON item_venda
FOR EACH ROW
BEGIN
    INSERT INTO historico_estoque (id_produto, quantidade, motivo, obs)
    VALUES (OLD.id_produto, OLD.quantidade, 'Devolução',
            CONCAT('Item removido da venda ', OLD.id_venda));

    UPDATE venda
       SET valor_total = (SELECT COALESCE(SUM(quantidade * preco_unidade), 0)
                            FROM item_venda
                           WHERE id_venda = OLD.id_venda)
     WHERE id_venda = OLD.id_venda;
END$$

-- =========================================================
-- D) ITEM_PEDIDO (só recalcula o total; pedido não baixa estoque)
-- =========================================================
CREATE TRIGGER trg_ip_after_insert
AFTER INSERT ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE pedido
       SET valor_total = (SELECT COALESCE(SUM(quantidade * preco_unidade), 0)
                            FROM item_pedido
                           WHERE id_pedido = NEW.id_pedido)
     WHERE id_pedido = NEW.id_pedido;
END$$

CREATE TRIGGER trg_ip_after_update
AFTER UPDATE ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE pedido
       SET valor_total = (SELECT COALESCE(SUM(quantidade * preco_unidade), 0)
                            FROM item_pedido
                           WHERE id_pedido = NEW.id_pedido)
     WHERE id_pedido = NEW.id_pedido;
END$$

CREATE TRIGGER trg_ip_after_delete
AFTER DELETE ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE pedido
       SET valor_total = (SELECT COALESCE(SUM(quantidade * preco_unidade), 0)
                            FROM item_pedido
                           WHERE id_pedido = OLD.id_pedido)
     WHERE id_pedido = OLD.id_pedido;
END$$

DELIMITER ;
