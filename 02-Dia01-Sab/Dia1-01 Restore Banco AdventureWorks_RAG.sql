/***************************************************************************
 Workshop SQL Server Expert 6ª edição
 Construa Soluções com IA no SQL Server 2025

 Hands On: Banco AdventureWorks_RAG que será utilizado no Workshop

 Autor: Landry Duailibe
****************************************************************************/
use master
go

-- Habilitar as Funcionalidades de AI
EXECUTE sp_configure 'external AI runtimes enabled', 1
RECONFIGURE WITH OVERRIDE

EXECUTE sp_configure 'external rest endpoint enabled', 1
RECONFIGURE WITH OVERRIDE


-- Restore banco AdventureWorks_RAG
RESTORE DATABASE AdventureWorks_RAG FROM DISK = 'D:\Backup\AdventureWorks_RAG_Inicial.bak' WITH recovery,stats=5,
MOVE 'AdventureWorks_RAG' TO 'D:\MSSQL_Data\AdventureWorks_RAG.mdf',
MOVE 'AdventureWorks_RAG_log' TO 'D:\MSSQL_Data\AdventureWorks_RAG_log.ldf'
go


use AdventureWorks_RAG
go

SELECT top 20 * FROM dbo.Produto_En

SELECT top 20 * FROM dbo.Produto

-- Habilitar preview features (necessário no SQL Server 2025)
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON




