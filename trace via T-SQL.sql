DECLARE @TraceID INT
DECLARE @MaxSize BIGINT
    SET @MaxSize = 4096 -- tamanho em MB
DECLARE @spid INT
SELECT @spid = @@spid
DECLARE @loginName VARCHAR(20)
SELECT @loginName = USER_NAME()

/*Filtro de tempo*/
DECLARE @Duration bigint
 SELECT @Duration = 500000
DECLARE @filename NVARCHAR(500)
    SET @filename = 'c:\'
    -- Alterar a gravação para o diretório mais conveniente (o diretório
    -- com permissoes de gravação deve existir)
    + REPLACE(CONVERT(NVARCHAR(20), @loginName),'\','')
    + '_d'
    + REPLACE(CONVERT(VARCHAR, GETDATE(),111),'/','') -- data
    + REPLACE(CONVERT(VARCHAR, GETDATE(),108),':','') -- horario

print @filename

EXECUTE sp_trace_create @TraceID OUTPUT,
                        @options     = 0, -- muda o arquivo assim que o MaxSize é atingido
                        @tracefile   = @filename, -- nome do arquivo de trace
                        @maxfilesize = @MaxSize -- tamanho máximo do arquivo em MB

-- Eventos
DECLARE @on bit
    SET @on = 1
-- RPC:Completed
EXEC sp_trace_setevent @TraceID, 10, 1,  @on -- TextData
EXEC sp_trace_setevent @TraceID, 10, 12, @on -- SPID
EXEC sp_trace_setevent @TraceID, 10, 13, @on -- Duration
EXEC sp_trace_setevent @TraceID, 10, 14, @on -- StartTime
EXEC sp_trace_setevent @TraceID, 10, 15, @on -- EndTime
EXEC sp_trace_setevent @TraceID, 10, 16, @on -- Reads
EXEC sp_trace_setevent @TraceID, 10, 17, @on -- Writes
EXEC sp_trace_setevent @TraceID, 10, 18, @on -- CPU
EXEC sp_trace_setevent @TraceID, 10, 34, @on -- ObjectName
EXEC sp_trace_setevent @TraceID, 10, 35, @on -- DataBaseName
EXEC sp_trace_setevent @TraceID, 10, 11, @on -- LoginName
EXEC sp_trace_setevent @TraceID, 10, 3, @on -- DatabaseID


-- Filtro
DECLARE @intfilter INT
DECLARE @bigintfilter BIGINT

-- Filtro
/* Filtra pelo DB   
   
select *
from sysdatabases
   
*/

EXEC sp_trace_setfilter @TraceID, 3, 1, 0, 9 --ID DO DB

-- Inicia o trace
EXEC sp_trace_setstatus @TraceID, 1

-- Exibe TraceID para uso futuro
SELECT @TraceID as TraceID

-- Para o Trace
EXEC sp_trace_setstatus 2, 0

select * from sys.traces

--Lendo nosso arquivo de trace através de Transact-SQL
SELECT  
 TextData,DatabaseID,LoginName,SPID,ServerName,ObjectName,DatabaseName
FROM ::fn_trace_gettable('c:\dbo_d20170505085108.trc', default)
where DatabaseID is not null



--Não ler legal o arquivo de trace esse método
--Lendo nosso arquivo de trace através de Transact-SQL
SELECT  
  Convert(VARCHAR(50), textdata) AS comando,
  Sum(cpu)                  AS total_cpu,
  Sum(reads)                AS total_reads,
  Sum(duration)             AS total_time,
  Count(*)                  AS qtde
FROM ::fn_trace_gettable('c:\dbo_d20161104112447.trc', default)
GROUP BY Convert(VARCHAR(50), textdata)
ORDER BY total_cpu DESC

