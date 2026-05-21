USE auxiliary;
GO

DELETE FROM dbo.Ocena;
GO

BULK INSERT dbo.Ocena
FROM 'C:\Users\Sered\Desktop\HD\data_generator\T1\Opinie.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO