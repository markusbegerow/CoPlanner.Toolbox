/*
#########################################################
Author:			Markus Begerow
Created on:		01.03.2022
Description:	Import ECB rates into CoPlanner
Version:		1.0.0
#########################################################
*/

Declare @Object as Int; 
Declare @Url as Varchar(MAX); 
DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX))
Declare @MyText as nvarchar(max)
Declare @XmlResponse as xml; 

-- Last day: https://www.ecb.int/stats/eurofxref/eurofxref-daily.xml
-- Last 90 days: https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml
-- All: https://www.ecb.int/stats/eurofxref/eurofxref-hist.xml

SET @Url = ' https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml' 
	
Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT; 
Exec sp_OAMethod @Object, 'open', NULL, 'get', @Url, 'false' 
Exec sp_OAMethod @Object, 'send' 
INSERT into @json (Json_Table) EXEC sp_OAGetProperty @Object, 'responseText'
Exec sp_OADestroy @Object  

Set @MyText = (SELECT convert(nvarchar(max),Json_Table)   FROM @json)
Set @XmlResponse = (select CAST(REPLACE(@MyText, 'encoding="UTF-8"', '') as XML))

    
;WITH XMLNAMESPACES('http://www.gesmes.org/xml/2002-08-01' AS gesmes,
    'http://www.ecb.int/vocabulary/2002-08-01/eurofxref' as ns)

SELECT T.X.value('(.)[1]/@currency','varchar(500)') AS [currency]
     ,T.X.value('(.)[1]/@rate','varchar(500)') AS [rate]
     ,T.X.value('(..)[1]/@time','varchar(500)') AS [time]
into #MyTable
FROM @XmlResponse.nodes('/gesmes:Envelope/ns:Cube/ns:Cube/ns:Cube') AS T(X)

Select * from #MyTable
DROP TABLE #MyTable
