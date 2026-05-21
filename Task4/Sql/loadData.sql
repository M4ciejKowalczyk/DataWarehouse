USE DwSchema;
GO

DELETE FROM Fact_Uczestnictwo;
DELETE FROM Fact_PrzeprowadzenieZajec;

DELETE FROM Dim_Uczestnictwo_Junk;
DELETE FROM Dim_Ocena;
DELETE FROM Dim_TypZajec;
DELETE FROM Dim_Sala;
DELETE FROM Dim_Instruktor;
DELETE FROM Dim_Czlonek;
DELETE FROM Dim_Data;
DELETE FROM Dim_Czas;

DBCC CHECKIDENT ('Dim_Uczestnictwo_Junk', RESEED, 0);
DBCC CHECKIDENT ('Dim_Ocena', RESEED, 0);
DBCC CHECKIDENT ('Dim_TypZajec', RESEED, 0);
DBCC CHECKIDENT ('Dim_Sala', RESEED, 0);
DBCC CHECKIDENT ('Dim_Instruktor', RESEED, 0);
DBCC CHECKIDENT ('Dim_Czlonek', RESEED, 0);
DBCC CHECKIDENT ('Dim_Data', RESEED, 0);
DBCC CHECKIDENT ('Dim_Czas', RESEED, 0);
DBCC CHECKIDENT ('Fact_PrzeprowadzenieZajec', RESEED, 0);
DBCC CHECKIDENT ('Fact_Uczestnictwo', RESEED, 0);

GO



BULK INSERT Dim_Data
FROM 'C:\Users\Maciej\Studia\Sem_V\HD\DW_Implementation\Dim_Data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK,
	CODEPAGE = '65001'
);

BULK INSERT Dim_Czas
FROM 'C:\Users\Maciej\Studia\Sem_V\HD\DW_Implementation\Dim_Czas.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK,
	CODEPAGE = '65001'
);


INSERT INTO Dim_Uczestnictwo_Junk (Obecny) VALUES 
(1), (0);

INSERT INTO Dim_Ocena (Ocena, Komentarz) VALUES
('5', 'Œwietne zajêcia'),
('4', 'Dobre'),
('3', 'Œrednie'),
('2', 'S³abe'),
('brak oceny', 'Brak komentarza');

INSERT INTO Dim_TypZajec (Nazwa, KategoriaCzasuTrwania) VALUES
('Joga', 'œrednie'),
('CrossFit', 'd³ugie'),
('Pilates', 'œrednie'),
('Zumba', 'krótkie');

INSERT INTO Dim_Sala (NumerSali, KategoriaWielkosci) VALUES
(101, 'ma³a'),
(202, 'du¿a'),
(305, 'œrednia');

INSERT INTO Dim_Czlonek (NumerKartyCzlonkowskiej, ImieINazwisko, Email, KategoriaStazu, IsCurrent) VALUES
('K100', 'Jan Kowalski', 'jan@example.com', 'nowy', 1),
('K101', 'Anna Nowak', 'anna@example.com', 'œredni', 1),
('K102', 'Piotr Zieliñski', 'piotr@example.com', 'doœwiadczony', 1),
('K103', 'Maria Lewandowska', 'maria@example.com', 'nowy', 1);

INSERT INTO Dim_Instruktor (NumerPracownika, ImieINazwisko, Specjalizacja, KategoriaStazu, IsCurrent) VALUES
('I001', 'Marek Trener', 'Joga', 'œredni', 1),
('I002', 'Ewa Fitness', 'CrossFit', 'doœwiadczony', 1),
('I003', 'Kasia Pilates', 'Pilates', 'nowy', 1);



INSERT INTO Fact_PrzeprowadzenieZajec
(ID_Instruktor, ID_TypZajec, ID_Sala, ID_Data, ID_Czas,
 LimitMiejsc, LiczbaZapisanych, LiczbaObecnych, Frekwencja,
 CzasTrwaniaMin, SredniaOcena, ProcentZapelnienia,
 StazWKlubieInstruktor, SredniStazUczestnikow)
VALUES
(1, 1, 1, 1, 10, 10, 8, 7, 87.50, 60, 4.80, 80.00, 2.5, 1.8),
(2, 2, 2, 2, 18, 20, 18, 16, 88.88, 90, 4.50, 90.00, 3.0, 2.2),
(3, 3, 3, 3, 12, 15, 12, 10, 83.33, 45, 4.20, 80.00, 0.5, 1.0),
(1, 1, 1, 4, 11, 12, 10, 9, 90.0, 60, 4.6, 90, 2.5, 1.7),
(2, 2, 2, 5, 18, 18, 15, 14, 93.3, 90, 4.3, 93, 3.0, 2.4),
(3, 3, 3, 6, 12, 20, 18, 17, 94.4, 45, 4.8, 90, 1.0, 1.8),
(1, 4, 1, 7, 14, 25, 20, 18, 90.0, 50, 4.1, 80, 2.8, 2.1),
(2, 1, 3, 8, 15, 10, 8, 7, 87.5, 60, 4.7, 80, 3.4, 1.9),
(3, 4, 2, 202, 10, 30, 25, 23, 92.0, 50, 4.5, 83, 0.6, 1.2),
(1, 2, 1, 277, 9, 18, 14, 13, 92.8, 90, 4.4, 77, 2.6, 1.4),
(2, 3, 2, 298, 11, 12, 11, 10, 91.0, 45, 4.2, 91, 3.1, 1.7),
(3, 1, 3, 312, 8, 20, 19, 17, 89.5, 60, 4.9, 95, 0.7, 1.1),
(1, 2, 1, 320, 7, 25, 22, 20, 90.9, 90, 4.3, 88, 2.3, 2.0),
(2, 4, 2, 325, 8, 15, 13, 12, 92.3, 50, 4.0, 86, 3.6, 2.3),
(3, 2, 3, 695, 10, 30, 28, 26, 92.8, 60, 4.6, 93, 0.8, 1.5),
(1, 3, 1, 700, 12, 18, 16, 15, 93.7, 45, 4.4, 89, 2.1, 1.3),
(2, 1, 2, 717, 17, 10, 9, 8, 88.8, 60, 4.2, 90, 3.3, 1.9),
(3, 4, 3, 1018, 18, 20, 18, 16, 88.8, 50, 4.3, 80, 0.9, 1.0),
(1, 1, 1, 1019, 9, 15, 14, 13, 92.8, 60, 4.5, 85, 2.2, 1.6),
(2, 2, 2, 1020, 11, 10, 8, 8, 100.0, 90, 4.1, 80, 3.0, 2.0),
(3, 3, 3, 1351, 12, 22, 20, 16, 80.0, 45, 4.0, 72, 1.2, 1.3),
(1, 4, 1, 1369, 15, 28, 26, 25, 96.1, 50, 4.7, 93, 2.7, 1.9),
(2, 1, 2, 1385, 18, 18, 16, 15, 93.7, 60, 4.2, 88, 3.2, 2.1),
(3, 2, 3, 1390, 10, 14, 13, 11, 84.6, 90, 4.6, 86, 0.8, 1.4),
(1, 3, 1, 1398, 12, 30, 27, 25, 92.5, 45, 4.8, 90, 2.0, 1.7);


INSERT INTO Fact_Uczestnictwo
(ID_PrzeprowadzenieZajec, ID_Czlonek, ID_Ocena, ID_Junk, Ocena, StazWKlubie)
VALUES
-- ID 1
(1, 1, 1, 1, 5.00, 1.20),
(1, 2, 2, 1, 4.00, 0.80),
(1, 3, 5, 2, NULL, 2.50),

-- ID 2
(2, 2, 1, 1, 5.00, 1.50),
(2, 3, 3, 1, 3.00, 3.20),
(2, 4, 5, 2, NULL, 0.30),

-- ID 3
(3, 1, 4, 1, 4.00, 1.20),
(3, 4, 2, 1, 2.00, 0.20),

-- ID 4
(4, 1, 1, 1, 5.00, 1.2),
(4, 2, 2, 1, 4.00, 0.8),
(4, 3, 3, 1, 3.00, 2.5),
(4, 4, 5, 2, NULL, 0.3),

-- ID 5
(5, 1, 4, 1, 4.00, 1.2),
(5, 3, 3, 1, 3.00, 3.2),
(5, 4, 2, 1, 2.00, 0.2),

-- ID 6
(6, 2, 1, 1, 5.00, 1.5),
(6, 3, 4, 1, 4.00, 0.9),
(6, 4, 5, 2, NULL, 0.3),

-- ID 7
(7, 1, 2, 1, 2.00, 1.2),
(7, 2, 3, 1, 3.00, 0.8),
(7, 4, 5, 2, NULL, 0.4),

-- ID 8
(8, 1, 1, 1, 5.00, 1.2),
(8, 2, 4, 1, 4.00, 0.8),
(8, 3, 3, 1, 3.00, 3.1),

-- ID 9
(9, 2, 2, 1, 2.00, 0.8),
(9, 3, 4, 1, 4.00, 1.9),
(9, 4, 5, 2, NULL, 0.3),

-- ID 10
(10, 1, 1, 1, 5.00, 1.2),
(10, 3, 3, 1, 3.00, 2.5),
(10, 4, 5, 2, NULL, 0.3),

-- ID 11
(11, 1, 4, 1, 4.00, 1.2),
(11, 2, 3, 1, 3.00, 1.1),
(11, 4, 2, 1, 2.00, 0.3),

-- ID 12
(12, 3, 1, 1, 5.00, 3.2),
(12, 4, 2, 1, 2.00, 0.3),

-- ID 13
(13, 1, 2, 1, 2.00, 1.2),
(13, 2, 3, 1, 3.00, 0.8),
(13, 3, 4, 1, 4.00, 3.1),

-- ID 14
(14, 4, 1, 1, 5.00, 0.4),
(14, 3, 3, 1, 3.00, 2.2),

-- ID 15
(15, 1, 1, 1, 5.00, 1.2),
(15, 2, 4, 1, 4.00, 0.8),
(15, 3, 3, 1, 3.00, 3.1),

-- ID 16
(16, 1, 4, 1, 4.00, 1.2),
(16, 2, 2, 1, 2.00, 0.8),
(16, 4, 5, 2, NULL, 0.4),

-- ID 17
(17, 1, 1, 1, 5.00, 1.2),
(17, 3, 3, 1, 3.00, 2.4),

-- ID 18
(18, 2, 2, 1, 2.00, 1.5),
(18, 3, 4, 1, 4.00, 0.9),

-- ID 19
(19, 1, 1, 1, 5.00, 1.2),
(19, 2, 2, 1, 2.00, 0.8),
(19, 3, 3, 1, 3.00, 2.5),

-- ID 20
(20, 4, 4, 1, 4.00, 0.3),
(20, 2, 2, 1, 2.00, 0.8),

-- ID 21
(21, 3, 3, 1, 3.00, 2.4),
(21, 1, 1, 1, 5.00, 1.3),

-- ID 22
(22, 1, 4, 1, 4.00, 1.2),
(22, 2, 2, 1, 2.00, 0.8),
(22, 4, 5, 2, NULL, 0.3),

-- ID 23
(23, 3, 3, 1, 3.00, 2.5),
(23, 4, 4, 1, 4.00, 0.4),

-- ID 24
(24, 2, 1, 1, 5.00, 1.2),
(24, 1, 2, 1, 2.00, 0.8),

-- ID 25
(25, 3, 3, 1, 3.00, 2.1),
(25, 4, 2, 1, 2.00, 0.4),
(25, 1, 1, 1, 5.00, 1.3);