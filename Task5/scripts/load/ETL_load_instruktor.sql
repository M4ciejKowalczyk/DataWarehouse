USE DW_FitnessClub;
GO

IF OBJECT_ID('vETLDim_Instruktor') IS NOT NULL DROP VIEW vETLDim_Instruktor;
GO

CREATE VIEW vETLDim_Instruktor AS

WITH StazInstruktora AS (
	SELECT
		NumerPracownika,
		MIN(DataZajec) AS PierwszeZajecia
	FROM
		FitnessClub.dbo.Zajecia
	GROUP BY NumerPracownika
),

InstruktorT AS (
    SELECT
        I.NumerPracownika,
        CAST(I.Imie + ' ' + I.Nazwisko AS NVARCHAR(60)) AS ImieINazwisko,
        I.Specjalizacja,
        CAST(
            ISNULL(DATEDIFF(DAY, si.PierwszeZajecia, '2025-10-31') / 365.25, 0)
        AS DECIMAL(5, 2)) AS StazLat,
        1 AS IsCurrent
    FROM
        FitnessClub.dbo.Instruktor AS I
    LEFT JOIN
        StazInstruktora AS si ON I.NumerPracownika = si.NumerPracownika
)

SELECT
    NumerPracownika,
    ImieINazwisko,
    Specjalizacja,
    CASE
        WHEN StazLat < 1.0 THEN 'Poczatkujacy'
        WHEN StazLat < 3.0 THEN 'Srednio doswiadczony'
        ELSE 'Doswiadczony'
    END AS KategoriaStazu,
    IsCurrent
FROM
    InstruktorT;
GO

/*
INSERT INTO Dim_Instruktor
    (NumerPracownika, ImieINazwisko, Specjalizacja, KategoriaStazu, IsCurrent)
SELECT 
    NumerPracownika,
    ImieINazwisko,
    Specjalizacja,
    KategoriaStazu,
    IsCurrent
FROM vETLDim_Instruktor;
GO */

MERGE INTO Dim_Instruktor AS TT
    USING vETLDim_Instruktor AS ST
        ON TT.NumerPracownika = ST.NumerPracownika
            WHEN NOT MATCHED
                THEN
                    INSERT (NumerPracownika, ImieINazwisko, Specjalizacja, KategoriaStazu, IsCurrent)
                    VALUES (ST.NumerPracownika, ST.ImieINazwisko, ST.Specjalizacja, ST.KategoriaStazu, 1)
            WHEN MATCHED
                AND (ST.Specjalizacja <> TT.Specjalizacja
                OR ST.KategoriaStazu <> TT.KategoriaStazu)
            THEN
                UPDATE SET TT.IsCurrent = 0;

INSERT INTO Dim_Instruktor (NumerPracownika, ImieINazwisko, Specjalizacja, KategoriaStazu, IsCurrent)
SELECT NumerPracownika, ImieINazwisko, Specjalizacja, KategoriaStazu, 1
FROM vETLDim_Instruktor
EXCEPT
SELECT NumerPracownika, ImieINazwisko, Specjalizacja, KategoriaStazu, 1
FROM Dim_Instruktor;

DROP VIEW vETLDim_Instruktor;
GO