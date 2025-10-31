
-- =======================
-- Criar banco de dados se não existir
-- =======================
CREATE DATABASE IF NOT EXISTS `biblioteca`;
USE `biblioteca`;

-- =======================
-- Criar tabelas se não existirem
-- =======================
CREATE TABLE IF NOT EXISTS `Autores` (
  `Id` INT AUTO_INCREMENT PRIMARY KEY,
  `Nome` VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS `Livros` (
  `Id` INT AUTO_INCREMENT PRIMARY KEY,
  `Titulo` VARCHAR(255) NOT NULL,
  `AutorId` INT NULL,
  CONSTRAINT `FK_Livros_Autores`
    FOREIGN KEY (`AutorId`)
    REFERENCES `Autores`(`Id`)
    ON DELETE SET NULL
);

-- =======================
-- Criar índice se não existir
-- =======================
DELIMITER $$

CREATE PROCEDURE `CreateIndexIfNotExists`()  
BEGIN
  DECLARE index_exists INT DEFAULT 0;

  SELECT COUNT(1)
  INTO index_exists
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE table_schema = DATABASE()
    AND table_name = 'Livros'
    AND index_name = 'IX_Livros_AutorId';

  IF index_exists = 0 THEN
    CREATE INDEX `IX_Livros_AutorId` ON `Livros` (`AutorId`);
  END IF;
END $$

DELIMITER ;

CALL `CreateIndexIfNotExists`();

DROP PROCEDURE IF EXISTS `CreateIndexIfNotExists`;
