


SELECT [UmsatzLC]																																		as Original
,FORMAT([UmsatzLC], '')																																	as OriginalFormat
,substring(FORMAT([UmsatzLC], ''), 0, CHARINDEX('.',FORMAT([UmsatzLC], '') ,0)+3)																		as OriginalFormatPlusZweiNachkommastellen
,substring(FORMAT([UmsatzLC], ''), CHARINDEX('.',FORMAT([UmsatzLC], '') ,0)+1, LEN(FORMAT([UmsatzLC], ''))-CHARINDEX('.',FORMAT([UmsatzLC], '')))		as OriginalFormatNurNahkommastellen
,len(substring(FORMAT([UmsatzLC], ''), CHARINDEX('.',FORMAT([UmsatzLC], '') ,0)+1, LEN(FORMAT([UmsatzLC], ''))-CHARINDEX('.',FORMAT([UmsatzLC], ''))))	As LaengederNachkommastellen
,CHARINDEX('.',FORMAT([UmsatzLC], '') ,0)																												as LaengeVorNachkommastellen
FROM [TBL_Umsatzerloese_PLAN] 
ORDER BY CHARINDEX('.',FORMAT([UmsatzLC], '') ,0) DESC




