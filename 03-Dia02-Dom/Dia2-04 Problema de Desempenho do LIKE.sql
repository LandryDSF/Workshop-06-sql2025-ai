
/***************************************************************************
 Workshop SQL Server Expert 6ª edição
 Construa Soluções com IA no SQL Server 2025

 Hands On: Problema de Desempenho do LIKE

 Objetivo:
 Demonstrar como a Busta Vetoria pode ser uma alternativa
 ao problema de desempenho do Like.

 Autor: Landry Duailibe
****************************************************************************/

use AdventureWorks_RAG
go

/****************************************************
 Cria tabela para mostrar comportamento do Like
*****************************************************/
DROP TABLE IF exists dbo.Produto_LIKE
go
CREATE TABLE dbo.Produto_LIKE (
Produto_ID int NOT NULL identity,
Produto_Codigo nvarchar(25) NOT NULL,
Produto nvarchar(150) NOT NULL,
Modelo nvarchar(150) NOT NULL,
Descricao nchar(800) NULL,
SubCategoria nvarchar(150) NULL,
Categoria nvarchar(150) NULL,
Cor nvarchar(100) NULL,
Preco money NULL)
go

set nocount on

-- Carga de dados inicial
INSERT dbo.Produto_LIKE 
(Produto_Codigo, Produto, Modelo, Descricao, SubCategoria, Categoria, Cor, Preco)

SELECT Produto_Codigo, Produto, Modelo, Descricao, SubCategoria, Categoria, Cor, Preco
FROM dbo.Produto
go 400

-- Carga com volume sem a palavra 
INSERT dbo.Produto_LIKE 
(Produto_Codigo, Produto, Modelo, Descricao, SubCategoria, Categoria, Cor, Preco)

SELECT Produto_Codigo, Produto, Modelo, Descricao, SubCategoria, Categoria, Cor, Preco
FROM dbo.Produto
WHERE Produto not like '%Mountain%' 
go 1600

/************** FIM CARGA ***********/

EXEC sp_spaceused 'dbo.Produto_LIKE'
-- 448.800 linhas 900.832 KB

set statistics io off
set statistics io on

--DROP INDEX dbo.Produto_LIKE.ix_Produto_LIKE_Produto
CREATE INDEX ix_Produto_LIKE_Produto ON dbo.Produto_LIKE (Produto)

-- Cria PK Clustered
ALTER TABLE dbo.Produto_LIKE ADD CONSTRAINT pk_Produto_LIKE 
PRIMARY KEY (Produto_ID)

SELECT * 
FROM dbo.Produto_LIKE
WHERE Produto like '%Mountain%'
-- Table Scan -----------> Table 'Produto_LIKE'. Scan count 1, logical reads 112604
-- Clustered Index Scan -> Table 'Produto_LIKE'. Scan count 1, logical reads 112387

-- Total de IO ----------> 112387 pag x 8 kb = 899.096 kb = 878 mb

SELECT * 
FROM dbo.Produto_LIKE
WHERE Produto like 'Mountain%'
-- Index Seek (NonClustered) -> Table 'Produto_LIKE'. Scan count 1, logical reads 39306

-- Total de IO ----------> 39306 pag x 8 kb = 314.448 kb = 307 mb
