USE DW_FitnessClub;
GO

IF OBJECT_ID('vETLDim_Czlonek') IS NOT NULL DROP VIEW vETLDim_Czlonek;
GO

CREATE VIEW vETLDim_Czlonek AS

WITH StazCzlonka AS (
	SELECT
		Z.NumerKartyCzlonkowskiej,
		MIN(Zaj.DataZajec) AS PierwszeZajecia
	FROM FitnessClub.dbo.Zapis Z
	JOIN 
        FitnessClub.dbo.Zajecia Zaj ON Zaj.ZajeciaID = Z.ZajeciaID
	WHERE
        Z.Obecny = 1 
	GROUP BY 
        Z.NumerKartyCzlonkowskiej
),

CzlonekT AS (
    SELECT
        C.NumerKartyCzlonkowskiej,
        CAST(C.Imie + ' ' + C.Nazwisko AS NVARCHAR(60)) AS ImieINazwisko,
        C.Email,
        CAST(
            ISNULL(DATEDIFF(DAY, sc.PierwszeZajecia, '2025-10-31') / 365.25, 0)
        AS DECIMAL(5, 2)) AS StazLat,
        1 AS IsCurrent
    FROM
        FitnessClub.dbo.Czlonek AS C
    LEFT JOIN
        StazCzlonka AS sc ON C.NumerKartyCzlonkowskiej = sc.NumerKartyCzlonkowskiej
)
SELECT 
    NumerKartyCzlonkowskiej,
	ImieINazwisko,
	Email,
    CASE
        WHEN StazLat < 0.5
            THEN 'Nowicjusz'
        WHEN StazLat < 2
            THEN 'Zaawansowany'
        ELSE 'Weteran'
    END AS KategoriaStazu,
    1 AS IsCurrent 
FROM CzlonekT

GO

/*
INSERT INTO Dim_Czlonek
    (NumerKartyCzlonkowskiej, ImieINazwisko, Email, KategoriaStazu, IsCurrent)
SELECT 
    NumerKartyCzlonkowskiej,
    ImieINazwisko,
    Email,
    KategoriaStazu,
    IsCurrent
FROM vETLDim_Czlonek;
GO */

MERGE INTO Dim_Czlonek AS TT
    USING vETLDim_Czlonek AS ST
        ON TT.NumerKartyCzlonkowskiej = ST.NumerKartyCzlonkowskiej
            WHEN NOT MATCHED 
                    THEN 
                        INSERT (NumerKartyCzlonkowskiej, ImieINazwisko, Email, KategoriaStazu, IsCurrent)
                        VALUES (ST.NumerKartyCzlonkowskiej, ST.ImieINazwisko, ST.Email, ST.KategoriaStazu, 1)
            WHEN MATCHED
                AND (ST.Email <> TT.Email
                OR ST.KategoriaStazu <> TT.KategoriaStazu)
            THEN 
                UPDATE SET TT.IsCurrent = 0;

INSERT INTO Dim_Czlonek (NumerKartyCzlonkowskiej, ImieINazwisko, Email, KategoriaStazu, IsCurrent)
SELECT NumerKartyCzlonkowskiej, ImieINazwisko, Email, KategoriaStazu, 1
FROM vETLDim_Czlonek
EXCEPT
SELECT NumerKartyCzlonkowskiej, ImieINazwisko, Email, KategoriaStazu, 1
FROM Dim_Czlonek;

DROP VIEW vETLDim_Czlonek;
GO