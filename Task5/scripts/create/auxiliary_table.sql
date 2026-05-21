USE auxiliary;

CREATE TABLE Ocena (
    NumerKartyCzlonkowskiej VARCHAR(10) NULL,
    NumerSali INT NULL, 
    DataZajec DATE NULL, 
    Godzina TIME NULL,
    Ocena INT NULL,
    Komentarz NVARCHAR(100) NULL
);
GO