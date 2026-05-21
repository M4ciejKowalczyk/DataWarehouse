USE DW_FitnessClub
GO

If (object_id('vETLDIM_SALA') is not null) Drop View vETLDIM_SALA;
go

CREATE VIEW vETLDIM_SALA
AS
SELECT DISTINCT
	[NumerSali],
	CASE
		WHEN [LimitMiejsc] < 10 THEN 'mala'
		WHEN [LimitMiejsc] BETWEEN 10 AND 20 THEN N'srednia'
		ELSE 'duza'
	END AS [KategoriaWielkosci]
FROM [FitnessClub].dbo.[Sala]
;
GO

/*
INSERT INTO Dim_Sala (NumerSali, KategoriaWielkosci)
SELECT 
	[NumerSali],
	[KategoriaWielkosci]
FROM vETLDIM_SALA;
GO */

MERGE INTO Dim_Sala AS TT
	USING vETLDIM_SALA AS ST
		ON TT.NumerSali = ST.NumerSali
		AND TT.KategoriaWielkosci = ST.KategoriaWielkosci
			WHEN NOT MATCHED
				THEN 
					INSERT VALUES 
					(
						ST.NumerSali,
						ST.KategoriaWielkosci
					)
			WHEN NOT MATCHED BY SOURCE
				THEN DELETE;

DROP VIEW vETLDIM_SALA;
GO