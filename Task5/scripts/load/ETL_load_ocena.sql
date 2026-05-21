USE DW_FitnessClub
GO

MERGE DW_FitnessClub.dbo.Dim_Ocena AS T
USING (
    -- 1. Prawdziwe oceny ze źródła
    SELECT DISTINCT
        CAST(Ocena AS varchar(20)) AS Ocena,
        Komentarz
    FROM auxiliary.dbo.Ocena
    WHERE Ocena IS NOT NULL

    UNION ALL

    SELECT 
        'brak oceny' AS Ocena,
        NULL AS Komentarz
) AS S
ON T.Ocena = S.Ocena
AND ISNULL(T.Komentarz,'') = ISNULL(S.Komentarz,'')

WHEN NOT MATCHED BY TARGET THEN
    INSERT (Ocena, Komentarz)
    VALUES (S.Ocena, S.Komentarz);
GO