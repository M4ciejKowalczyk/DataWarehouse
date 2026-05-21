USE DW_FitnessClub;
GO

IF (OBJECT_ID('vETLFPrzeprowadzenieZajec') IS NOT NULL)
    DROP VIEW vETLFPrzeprowadzenieZajec;
GO

CREATE VIEW vETLFPrzeprowadzenieZajec
AS
WITH
	ZapisyAggr AS(
		SELECT
			ZajeciaID,
			COUNT(*) AS LiczbaZapisanych,
			SUM(CASE WHEN Obecny = 1 THEN 1 ELSE 0 END) AS LiczbaObecnych
		FROM
			FitnessClub.dbo.Zapis
		GROUP BY
			ZajeciaID
	),

	OcenyAggr AS (
		SELECT
			z.ZajeciaID,
			AVG(CAST(o.Ocena AS DECIMAL(3,2))) AS SredniaOcena
		FROM auxiliary.dbo.Ocena AS o
		JOIN FitnessClub.dbo.Zajecia AS z ON o.NumerSali = z.NumerSali
										AND o.DataZajec = z.DataZajec
										AND LEFT(CAST(o.Godzina AS VARCHAR(16)), 5) = LEFT(CAST(z.Godzina AS VARCHAR(16)), 5)
		WHERE
			o.Ocena IS NOT NULL
		GROUP BY
			z.ZajeciaID
	),

	StazInstruktora AS (
		SELECT 
			NumerPracownika,
			MIN(DataZajec) AS PierwszeZajecia
		FROM
			FitnessClub.dbo.Zajecia
		GROUP BY
			NumerPracownika
	),

	StazUczestnika AS (
		SELECT
			z.NumerKartyCzlonkowskiej,
			MIN(zj.DataZajec) AS PierwszeZajecia
		FROM FitnessClub.dbo.Zapis AS z
		JOIN FitnessCLub.dbo.Zajecia AS zj ON z.ZajeciaID = zj.ZajeciaID
		WHERE z.Obecny = 1
		GROUP BY z.NumerKartyCzlonkowskiej
	),

	SredniStazNaZajeciach AS (
		SELECT
			z.ZajeciaID,
			AVG(CAST(DATEDIFF(DAY, su.PierwszeZajecia, zj.DataZajec) AS DECIMAL(10,2))/365.25
			) AS SredniStazUczestnikow
			FROM FitnessClub.dbo.Zapis AS z
			JOIN FitnessClub.dbo.Zajecia AS zj ON z.ZajeciaID = zj.ZajeciaID
			JOIN StazUczestnika AS su ON z.NumerKartyCzlonkowskiej = su.NumerKartyCzlonkowskiej
			WHERE z.Obecny = 1
			GROUP BY z.ZajeciaID 
	)


SELECT
	di.ID_Instruktor,
	dtz.ID_TypZajec,
	ds.ID_Sala,
	dd.ID_Data,
	dc.ID_Czas,

	s.LimitMiejsc,
	z.CzasTrwania AS CzasTrwaniaMin,

	ISNULL(za.LiczbaZapisanych, 0) AS LiczbaZapisanych,
    ISNULL(za.LiczbaObecnych, 0) AS LiczbaObecnych,
    oa.SredniaOcena,

	CASE
		WHEN ISNULL(za.LiczbaZapisanych, 0) > 0
		THEN ISNULL(za.LiczbaObecnych, 0) * 100.0 / za.LiczbaZapisanych
		ELSE 0
	END AS Frekwencja,

	CASE
		WHEN s.LimitMiejsc > 0
		THEN ISNULL(za.LiczbaZapisanych, 0) * 100.0 / s.LimitMiejsc
		ELSE 0
	END AS ProcentZapelnienia,

	CASE 
        WHEN si.PierwszeZajecia IS NOT NULL
        THEN CAST(DATEDIFF(DAY, si.PierwszeZajecia, z.DataZajec) AS DECIMAL(10, 2)) / 365.25
        ELSE 0
    END AS StazWKlubieInstruktor,

	ssz.SredniStazUczestnikow

FROM
	FitnessClub.dbo.Zajecia AS z
JOIN DW_FitnessClub.dbo.Dim_Instruktor AS di ON z.NumerPracownika = di.NumerPracownika
									AND di.IsCurrent = 1
JOIN FitnessClub.dbo.Sala AS s ON z.NumerSali = s.NumerSali
JOIN DW_FitnessClub.dbo.Dim_Sala AS ds ON s.NumerSali = ds.NumerSali
JOIN DW_FitnessClub.dbo.Dim_Data AS dd ON z.DataZajec = dd.Data
JOIN DW_FitnessClub.dbo.Dim_Czas AS dc ON z.Godzina = dc.Godzina
JOIN FitnessClub.dbo.TypZajec AS tz ON z.TypZajecID = tz.TypZajecID
JOIN DW_FitnessClub.dbo.Dim_TypZajec AS dtz 
    ON tz.Nazwa = dtz.Nazwa
    AND dtz.KategoriaCzasuTrwania = 
        CASE 
            WHEN z.CzasTrwania <= 45 THEN 'krotkie'
            WHEN z.CzasTrwania < 90 THEN 'srednie'
            ELSE 'dlugie'
        END

LEFT JOIN ZapisyAggr AS za ON z.ZajeciaID = za.ZajeciaID
LEFT JOIN OcenyAggr AS oa ON z.ZajeciaID = oa.ZajeciaID
LEFT JOIN StazInstruktora AS si ON z.NumerPracownika = si.NumerPracownika
LEFT JOIN SredniStazNaZajeciach AS ssz ON z.ZajeciaID = ssz.ZajeciaID;
GO

/*
INSERT INTO DW_FitnessClub.dbo.Fact_PrzeprowadzenieZajec (
    ID_Instruktor,
    ID_TypZajec,
    ID_Sala,
    ID_Data,
    ID_Czas,
    LimitMiejsc,
    LiczbaZapisanych,
    LiczbaObecnych,
    Frekwencja,
    CzasTrwaniaMin,
    SredniaOcena,
    ProcentZapelnienia,
    StazWKlubieInstruktor,
    SredniStazUczestnikow
)
SELECT
    ID_Instruktor,
    ID_TypZajec,
    ID_Sala,
    ID_Data,
    ID_Czas,
    LimitMiejsc,
    LiczbaZapisanych,
    LiczbaObecnych,
    Frekwencja,
    CzasTrwaniaMin,
    SredniaOcena,
    ProcentZapelnienia,
    StazWKlubieInstruktor,
    SredniStazUczestnikow
FROM
    vETLFPrzeprowadzenieZajec;
GO */

MERGE INTO DW_FitnessClub.dbo.Fact_PrzeprowadzenieZajec AS TT
	USING vETLFPrzeprowadzenieZajec AS ST
		--ON TT.ID_Instruktor = ST.ID_Instruktor
		--AND TT.ID_TypZajec = ST.ID_TypZajec
		ON TT.ID_Sala = ST.ID_Sala
		AND TT.ID_Data = ST.ID_Data
		AND TT.ID_Czas = ST.ID_Czas
			WHEN NOT MATCHED
				THEN
					INSERT VALUES
					(
						ST.ID_Instruktor,
						ST.ID_TypZajec,
						ST.ID_Sala,
						ST.ID_Data,
						ST.ID_Czas,
						ST.LimitMiejsc,
						ST.LiczbaZapisanych,
						ST.LiczbaObecnych,
						ST.Frekwencja,
						ST.CzasTrwaniaMin,
						ST.SredniaOcena,
						ST.ProcentZapelnienia,
						ST.StazWKlubieInstruktor,
						ST.SredniStazUczestnikow
					);

DROP VIEW vETLFPrzeprowadzenieZajec;
GO