USE DW_FitnessClub;
GO

BULK INSERT Dim_Data
FROM 'C:\Users\Sered\Desktop\HD\data_warehouse_implementation\Csv\Dim_Data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK,
	CODEPAGE = '65001'
);

BULK INSERT Dim_Czas
FROM 'C:\Users\Sered\Desktop\HD\data_warehouse_implementation\Csv\Dim_Czas.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK,
	CODEPAGE = '65001'
);