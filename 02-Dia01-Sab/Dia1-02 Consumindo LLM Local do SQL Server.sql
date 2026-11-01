/***************************************************************************
 Workshop SQL Server Expert 6ª edição
 Construa Soluções com IA no SQL Server 2025

 Hands On: Consumindo LLM Local Ollama + Caddy

 Autor: Landry Duailibe
****************************************************************************/
use AdventureWorks_RAG
go

/******************************************************************
 Chamada Chat com LLM Local
 - Execute o Proxy Local Caddy antes
 c:\caddy\caddy_windows_amd64.exe run --config c:\caddy\Caddyfile
*******************************************************************/
go
DECLARE @pSystem nvarchar(max) = 'Você é um professor especializado em Microsoft SQL Server.
Explique os conceitos em português, utilizando linguagem clara e objetiva.
Sempre que possível, utilize exemplos relacionados ao trabalho de DBAs e desenvolvedores SQL.'

DECLARE @pUser nvarchar(max) = '
Explique o que é o banco de dados de sistema TempDB para um desenvolvedor SQL iniciante.

Inclua:
- sua finalidade;
- os principais objetos armazenados;
- exemplos de uso;
- cuidados básicos de configuração.

Organize a resposta em tópicos e finalize com um resumo.'

DECLARE @Modelo nvarchar(200) = N'llama3.2:1b'
DECLARE @Temp nvarchar(4) = N'0.3'
DECLARE @Timeout int = 230

DECLARE @payload nvarchar(MAX) = N'{
    "model": "' + STRING_ESCAPE(@Modelo, 'json') + N'",
    "options": {"temperature":' + @Temp + N'},
    "messages": [
        {"role": "system", "content": "' + STRING_ESCAPE(@pSystem, 'json') + N'"},
        {"role": "user",   "content": "' + STRING_ESCAPE(@pUser, 'json') + N'"}
    ],
    "stream": false
}'

DECLARE @response nvarchar(MAX)

EXEC sp_invoke_external_rest_endpoint
@url      = 'https://localhost/api/chat',
@method   = 'POST',
@headers  = '{"Content-Type":"application/json"}',
@payload  = @payload,
@timeout  = @Timeout,
@response = @response OUTPUT

SELECT JSON_VALUE(@response, '$.result.message.content') AS Resposta
go 


/*********************************************************
 Stored Procedure que encapsula chamada a LLM Local
**********************************************************/
go
CREATE or ALTER PROC dbo.spAI_Chat_Ollama
@pSystem nvarchar(max),
@pUser nvarchar(max),
@Modelo nvarchar(200) = N'llama3.2:1b',
@Temp nvarchar(4) = N'0.3',
@Timeout int = 230
as
set nocount on

DECLARE @payload nvarchar(MAX) = N'{
    "model": "' + STRING_ESCAPE(@Modelo, 'json') + N'",
    "options": {"temperature":' + @Temp + N'},
    "messages": [
        {"role": "system", "content": "' + STRING_ESCAPE(@pSystem, 'json') + N'"},
        {"role": "user",   "content": "' + STRING_ESCAPE(@pUser, 'json') + N'"}
    ],
    "stream": false
}'

DECLARE @response nvarchar(MAX)

EXEC sp_invoke_external_rest_endpoint
@url      = 'https://localhost/api/chat',
@method   = 'POST',
@headers  = '{"Content-Type":"application/json"}',
@payload  = @payload,
@timeout  = @Timeout,
@response = @response OUTPUT

SELECT JSON_VALUE(@response, '$.result.message.content') AS Resposta
go
/*********************************** FIM SP **************************************/


-- Testa Stored Procedure
EXEC dbo.spAI_Chat_Ollama
@pSystem = '
Você é um professor especializado em Microsoft SQL Server.
Explique os conceitos em português, utilizando linguagem clara e objetiva.
Sempre que possível, utilize exemplos relacionados ao trabalho de DBAs e desenvolvedores SQL.',

@pUser = '
Explique o que é o banco de dados de sistema TempDB para um desenvolvedor SQL iniciante.

Inclua:
- sua finalidade;
- os principais objetos armazenados;
- exemplos de uso;
- cuidados básicos de configuração.

Organize a resposta em tópicos e finalize com um resumo.'



