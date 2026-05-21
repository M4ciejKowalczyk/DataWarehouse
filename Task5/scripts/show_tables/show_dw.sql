USE DW_FitnessClub;
GO

SELECT * FROM Dim_Sala ORDER BY ID_Sala;
SELECT * FROM Dim_TypZajec ORDER BY ID_TypZajec;
SELECT * FROM Dim_Czlonek ORDER BY ID_Czlonek;
SELECT * FROM Dim_Instruktor ORDER BY ID_Instruktor;
SELECT * FROM Dim_Data ORDER BY ID_Data;
SELECT * FROM Dim_Czas ORDER BY ID_Czas;
SELECT * FROM Dim_Ocena ORDER BY ID_Ocena;
SELECT * FROM Dim_Uczestnictwo_Junk ORDER BY ID_Junk;

SELECT * FROM Fact_PrzeprowadzenieZajec ORDER BY ID_PrzeprowadzenieZajec;
SELECT * FROM Fact_Uczestnictwo ORDER BY ID_Uczestnictwo;