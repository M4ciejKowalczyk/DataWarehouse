use DW_FitnessClub

If (object_id('vETLFUczestnictwo') is not null) Drop view vETLFUczestnictwo;
go

CREATE VIEW vETLFUczestnictwo
AS
WITH
	StazUczestnika AS (
			SELECT
				z.NumerKartyCzlonkowskiej,
				MIN(zj.DataZajec) AS PierwszeZajecia
			FROM
				FitnessClub.dbo.Zapis AS z
			JOIN
				FitnessClub.dbo.Zajecia AS zj ON z.ZajeciaID = zj.ZajeciaID
			WHERE
				z.Obecny = 1
			GROUP BY
				z.NumerKartyCzlonkowskiej
	)

SELECT
	fpz.ID_PrzeprowadzenieZajec,
    dc.ID_Czlonek,
    doce.ID_Ocena,
    dj.ID_Junk,
    src_oce.Ocena,
    
    CASE 
        WHEN su.PierwszeZajecia IS NULL OR DATEDIFF(DAY, su.PierwszeZajecia, z.DataZajec) < 0
		THEN 0
        ELSE CAST(DATEDIFF(DAY, su.PierwszeZajecia, z.DataZajec) AS DECIMAL(10, 2)) / 365.25
    END AS StazWKlubie

	FROM FitnessClub.dbo.Zapis AS zap
	JOIN FitnessClub.dbo.Zajecia AS z ON zap.ZajeciaID = z.ZajeciaID
	JOIN DW_FitnessClub.dbo.Dim_Czlonek AS dc ON zap.NumerKartyCzlonkowskiej = dc.NumerKartyCzlonkowskiej
										AND dc.IsCurrent = 1
	JOIN DW_FitnessClub.dbo.Dim_Uczestnictwo_Junk AS dj ON zap.Obecny = dj.Obecny 

	JOIN DW_FitnessClub.dbo.Dim_Data AS dd ON z.DataZajec = dd.Data
	JOIN DW_FitnessClub.dbo.Dim_Czas AS dczas ON z.Godzina = dczas.Godzina
	JOIN DW_FitnessClub.dbo.Dim_Sala AS ds ON z.NumerSali = ds.NumerSali
	JOIN DW_FitnessClub.dbo.Dim_Instruktor AS di ON z.NumerPracownika = di.NumerPracownika AND di.IsCurrent = 1
	JOIN FitnessClub.dbo.TypZajec AS tz ON z.TypZajecID = tz.TypZajecID
	JOIN DW_FitnessClub.dbo.Dim_TypZajec AS dtz 
    ON tz.Nazwa = dtz.Nazwa
    AND dtz.KategoriaCzasuTrwania = 
        CASE 
            WHEN z.CzasTrwania <= 45 THEN 'krotkie'
            WHEN z.CzasTrwania < 90 THEN 'srednie'
            ELSE 'dlugie'
        END

	JOIN
		DW_FitnessClub.dbo.Fact_PrzeprowadzenieZajec AS fpz 
			ON fpz.ID_Data = dd.ID_Data
		   AND fpz.ID_Czas = dczas.ID_Czas
		   AND fpz.ID_Sala = ds.ID_Sala
		   --AND fpz.ID_Instruktor = di.ID_Instruktor
		   AND fpz.ID_TypZajec = dtz.ID_TypZajec

	LEFT JOIN
		auxiliary.dbo.Ocena AS src_oce 
			ON zap.NumerKartyCzlonkowskiej = src_oce.NumerKartyCzlonkowskiej
		   AND z.NumerSali = src_oce.NumerSali
		   AND z.DataZajec = src_oce.DataZajec
		   AND z.Godzina = src_oce.Godzina

	LEFT JOIN
		DW_FitnessClub.dbo.Dim_Ocena AS doce 
			ON doce.Ocena = ISNULL(CAST(src_oce.Ocena AS NVARCHAR(10)), 'brak oceny')
		   AND (doce.Komentarz = src_oce.Komentarz OR (doce.Komentarz IS NULL AND src_oce.Komentarz IS NULL))

	
	LEFT JOIN
		StazUczestnika AS su ON zap.NumerKartyCzlonkowskiej = su.NumerKartyCzlonkowskiej

	WHERE NOT EXISTS (
		SELECT 1 
		FROM DW_FitnessClub.dbo.Fact_Uczestnictwo f
		JOIN DW_FitnessClub.dbo.Dim_Czlonek d ON f.ID_Czlonek = d.ID_Czlonek
		WHERE f.ID_PrzeprowadzenieZajec = fpz.ID_PrzeprowadzenieZajec
		  AND d.NumerKartyCzlonkowskiej = zap.NumerKartyCzlonkowskiej
);
	GO



/*
INSERT INTO DW_FitnessClub.dbo.Fact_Uczestnictwo (
    ID_PrzeprowadzenieZajec,
    ID_Czlonek,
    ID_Ocena,
    ID_Junk,
    Ocena,
    StazWKlubie
)
SELECT
    ID_PrzeprowadzenieZajec,
    ID_Czlonek,
    ID_Ocena,
    ID_Junk,
    Ocena,
    StazWKlubie
FROM
    vETLFUczestnictwo;
GO */

MERGE INTO DW_FitnessClub.dbo.Fact_Uczestnictwo AS TT
	USING vETLFUczestnictwo AS ST
		ON TT.ID_PrzeprowadzenieZajec = ST.ID_PrzeprowadzenieZajec
		AND TT.ID_Czlonek = ST.ID_Czlonek
		--AND TT.ID_Ocena = ST.ID_Ocena
		--AND TT.ID_Junk = ST.ID_Junk
			WHEN NOT MATCHED
				THEN 
					INSERT VALUES 
					(
					ST.ID_PrzeprowadzenieZajec, 
					ST.ID_Czlonek, 
					ST.ID_Ocena, 
					ST.ID_Junk,
					ST.Ocena,
					ST.StazWKlubie
					);

DROP VIEW vETLFUczestnictwo;
GO