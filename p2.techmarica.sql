DROP DATABASE IF EXISTS techmarica;
CREATE DATABASE techmarica;
USE techmarica;

CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_interno VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    responsavel_tecnico VARCHAR(100) NOT NULL,
    custo_producao DECIMAL(10,2) NOT NULL,
    data_criacao DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE funcionarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    area VARCHAR(50) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE maquinas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    setor VARCHAR(50) NOT NULL
);

CREATE TABLE ordens_producao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    maquina_id INT NOT NULL,
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_conclusao TIMESTAMP NULL,
    status VARCHAR(20) DEFAULT 'EM PRODUÇÃO',
    FOREIGN KEY (produto_id) REFERENCES produtos(id),
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id),
    FOREIGN KEY (maquina_id) REFERENCES maquinas(id)
);

INSERT INTO produtos (codigo_interno, nome, responsavel_tecnico, custo_producao)
VALUES 
('P001', 'Sensor Térmico X1', 'Carlos Souza', 120.50),
('P002', 'Placa Controladora Z3', 'Ana Lima', 250.00),
('P003', 'Módulo Wi-Fi MK2', 'João Mendes', 180.75),
('P004', 'Sensor de Luminosidade L2', 'Ana Lima', 90.00),
('P005', 'Unidade Lógica R9', 'Carlos Souza', 300.00);

INSERT INTO funcionarios (nome, area, ativo)
VALUES
('Marcos Silva', 'Montagem', TRUE),
('Fernanda Costa', 'Qualidade', TRUE),
('Rogério Almeida', 'Manutenção', FALSE),
('Patrícia Nunes', 'Montagem', TRUE),
('Luiz Fernando', 'Produção', TRUE);

INSERT INTO maquinas (nome, setor)
VALUES
('Fresadora MX-100', 'Usinagem'),
('Soldadora ST-55', 'Montagem'),
('Impressora 3D P900', 'Protótipos');

INSERT INTO ordens_producao (produto_id, funcionario_id, maquina_id)
VALUES
(1, 1, 2),
(3, 4, 3),
(5, 2, 1);

SELECT op.id, p.nome AS produto, m.nome AS maquina,
       f.nome AS funcionario, op.data_inicio, op.data_conclusao, op.status
FROM ordens_producao op
INNER JOIN produtos p ON op.produto_id = p.id
INNER JOIN maquinas m ON op.maquina_id = m.id
INNER JOIN funcionarios f ON op.funcionario_id = f.id
ORDER BY op.data_inicio DESC;

SELECT * FROM funcionarios WHERE ativo = FALSE;

SELECT responsavel_tecnico, COUNT(*) AS total_produtos
FROM produtos
GROUP BY responsavel_tecnico;

SELECT * FROM produtos
WHERE nome LIKE 'S%';

SELECT 
    nome,
    data_criacao,
    TIMESTAMPDIFF(YEAR, data_criacao, CURRENT_DATE) AS idade_anos
FROM produtos;

CREATE OR REPLACE VIEW producao_resumo AS
SELECT 
    op.id AS ordem_id,
    p.nome AS produto,
    m.nome AS maquina,
    f.nome AS funcionario,
    op.data_inicio,
    op.data_conclusao,
    op.status
FROM ordens_producao op
INNER JOIN produtos p ON op.produto_id = p.id
INNER JOIN maquinas m ON op.maquina_id = m.id
INNER JOIN funcionarios f ON op.funcionario_id = f.id;

DELIMITER $$

CREATE PROCEDURE registrar_ordem_producao (
    IN p_produto_id INT,
    IN p_funcionario_id INT,
    IN p_maquina_id INT
)
BEGIN
    INSERT INTO ordens_producao (produto_id, funcionario_id, maquina_id, status)
    VALUES (p_produto_id, p_funcionario_id, p_maquina_id, 'EM PRODUÇÃO');

    SELECT CONCAT('Ordem registrada com sucesso! ID: ', LAST_INSERT_ID()) AS mensagem;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER finaliza_ordem
BEFORE UPDATE ON ordens_producao
FOR EACH ROW
BEGIN
    IF NEW.data_conclusao IS NOT NULL AND OLD.data_conclusao IS NULL THEN
        SET NEW.status = 'FINALIZADA';
    END IF;
END $$

DELIMITER ;

