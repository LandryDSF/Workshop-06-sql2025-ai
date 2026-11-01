/***************************************************************************
 Workshop SQL Server Expert 6ª edição
 Construa Soluções com IA no SQL Server 2025

 Hands On: Busta Vetoria

 Objetivo:
 Demonstrar como executar Busta Vetoria exata e aproximada utilizando
 índice vetorial.

 Autor: Landry Duailibe
****************************************************************************/
use AdventureWorks_RAG
go


/*******************************************************************
 Índice Vetorial

 ALLOW_STALE_VECTOR_INDEX
 - Na versão do índice disponível no SQL Server 2025, 
   a tabela fica somente leitura.

 - No Azure SQL Database, a versão mais recente do índice 
   permite alterações e manutenção automática.
********************************************************************/
DROP INDEX IF EXISTS IX_dbo_Produto_Embedding ON dbo.Produto_Embedding
go
CREATE VECTOR INDEX IX_dbo_Produto_Embedding
ON dbo.Produto_Embedding (Embedding)
WITH (METRIC = 'cosine', TYPE = 'diskann')
go

-- Verificar a criação do índice vetorial
SELECT i.[name] as Nome_Indice,
i.[type_desc] as Tipo,
vi.distance_metric as Metrica,
vi.vector_index_type as Algoritmo,
vi.build_parameters as Parametros
FROM sys.indexes i
JOIN sys.vector_indexes vi ON vi.object_id = i.object_id AND vi.index_id  = i.index_id
WHERE object_name(i.object_id) like 'Produto%'

/**************************************
 Busca Vetorial
***************************************/
go
DECLARE @Pergunta varchar(2000) = 'Roupa fresquinha para pedalar no calor sem ficar encharcado de suor, com lugar nas costas para levar o celular'
DECLARE @VetorPergunta vector(768) = AI_GENERATE_EMBEDDINGS(@Pergunta USE MODEL EmbeddingGemma)
DECLARE @Top int = 50

-- Busca Vetorial Exata
SELECT TOP (@Top) *, VECTOR_DISTANCE('cosine', Embedding, @VetorPergunta) as Distancia
FROM dbo.Produto_Embedding
ORDER BY Distancia ASC

-- Busca Vetorial Aproximada
SELECT *
FROM VECTOR_SEARCH(
TABLE = dbo.Produto_Embedding as bc,
COLUMN = Embedding,
SIMILAR_TO = @VetorPergunta,
METRIC = 'cosine',
TOP_N  = @Top
) as vs
go

/*********************************************
 Retornando o texto utilizado no Embedding
**********************************************/
-- Busca Vetorial Exata
go
DECLARE @Pergunta varchar(2000) = 'Roupa fresquinha para pedalar no calor sem ficar encharcado de suor, com lugar nas costas para levar o celular'
DECLARE @VetorPergunta vector(768) = AI_GENERATE_EMBEDDINGS(@Pergunta USE MODEL EmbeddingGemma)
DECLARE @Top int = 5

SELECT TOP (@Top) e.Produto_ID, p.Embedding_Texto, p.Descricao, 
VECTOR_DISTANCE('cosine', Embedding, @VetorPergunta) as Distancia
FROM dbo.Produto_Embedding e
JOIN dbo.Produto p on p.Produto_ID = e.Produto_ID
ORDER BY Distancia ASC


-- Busca Vetorial Aproximada
go
DECLARE @Pergunta varchar(2000) = 'Roupa fresquinha para pedalar no calor sem ficar encharcado de suor, com lugar nas costas para levar o celular'
DECLARE @VetorPergunta vector(768) = AI_GENERATE_EMBEDDINGS(@Pergunta USE MODEL EmbeddingGemma)
DECLARE @Top int = 5

SELECT e.Produto_ID, p.Embedding_Texto, p.Descricao ,vs.distance as Distancia
FROM VECTOR_SEARCH(
TABLE = dbo.Produto_Embedding as e,
COLUMN = Embedding,
SIMILAR_TO = @VetorPergunta,
METRIC = 'cosine',
TOP_N  = @Top
) as vs

JOIN dbo.Produto p ON p.Produto_ID = e.Produto_ID
ORDER BY vs.distance

/* Roupa fresquinha para pedalar no calor sem ficar encharcado de suor, com lugar nas costas para levar o celular
883	# Produto: Camisa Clássica Manga Curta, G. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
881	# Produto: Camisa Clássica Manga Curta, P. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
852	# Produto: Calça de Ciclismo Feminina, P. # Modelo: Calça de Ciclismo Feminina. # Categoria: Vestuário. # Subcategoria: Calças de Ciclismo. # Cor: Preto. # Descrição: Calça térmica de elastano para pedalar no inverno; forro (chamois) sem costuras que elimina pontos de pressão.
854	# Produto: Calça de Ciclismo Feminina, G. # Modelo: Calça de Ciclismo Feminina. # Categoria: Vestuário. # Subcategoria: Calças de Ciclismo. # Cor: Preto. # Descrição: Calça térmica de elastano para pedalar no inverno; forro (chamois) sem costuras que elimina pontos de pressão.
882	# Produto: Camisa Clássica Manga Curta, M. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
*/

/* Qual a melhor bicipleta para pedalar no meio do mato, em caminhos de terra e pedra
992	# Produto: Mountain-500 Preto, 48. # Modelo: Mountain-500. # Categoria: Bicicletas. # Subcategoria: Mountain Bikes. # Cor: Preto. # Descrição: Ideal para qualquer tipo de pedalada, no asfalto ou fora dele. Cabe em qualquer orçamento. Trocas de marcha suaves e pedalada confortável.
989	# Produto: Mountain-500 Preto, 40. # Modelo: Mountain-500. # Categoria: Bicicletas. # Subcategoria: Mountain Bikes. # Cor: Preto. # Descrição: Ideal para qualquer tipo de pedalada, no asfalto ou fora dele. Cabe em qualquer orçamento. Trocas de marcha suaves e pedalada confortável.
991	# Produto: Mountain-500 Preto, 44. # Modelo: Mountain-500. # Categoria: Bicicletas. # Subcategoria: Mountain Bikes. # Cor: Preto. # Descrição: Ideal para qualquer tipo de pedalada, no asfalto ou fora dele. Cabe em qualquer orçamento. Trocas de marcha suaves e pedalada confortável.
785	# Produto: Mountain-300 Preto, 38. # Modelo: Mountain-300. # Categoria: Bicicletas. # Subcategoria: Mountain Bikes. # Cor: Preto. # Descrição: Para os verdadeiros viciados em trilha. Uma bike extremamente resistente que vai a qualquer lugar e mantém você no controle em terrenos desafiadores - sem estourar o orçamento.
788	# Produto: Mountain-300 Preto, 48. # Modelo: Mountain-300. # Categoria: Bicicletas. # Subcategoria: Mountain Bikes. # Cor: Preto. # Descrição: Para os verdadeiros viciados em trilha. Uma bike extremamente resistente que vai a qualquer lugar e mantém você no controle em terrenos desafiadores - sem estourar o orçamento.
*/

/* Blusa para pedal de verão na cor de amarelada
881	# Produto: Camisa Clássica Manga Curta, P. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
883	# Produto: Camisa Clássica Manga Curta, G. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
882	# Produto: Camisa Clássica Manga Curta, M. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
976	# Produto: Road-350-W Amarelo, 48. # Modelo: Road-350-W. # Categoria: Bicicletas. # Subcategoria: Bicicletas de Estrada. # Cor: Amarelo. # Descrição: Treine, compita ou simplesmente passeie com os amigos em uma bike elegante e aerodinâmica, projetada para mulheres. A tecnologia avançada do selim garante conforto o dia todo.
884	# Produto: Camisa Clássica Manga Curta, GG. # Modelo: Camisa Clássica Manga Curta. # Categoria: Vestuário. # Subcategoria: Camisas de Ciclismo. # Cor: Amarelo. # Descrição: Camisa clássica de manga curta, respirável, com controle de umidade superior, zíper frontal e 3 bolsos traseiros.
*/



