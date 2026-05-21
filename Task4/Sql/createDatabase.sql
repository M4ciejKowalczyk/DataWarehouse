CREATE database DwSchema
GO

use DwSchema

CREATE TABLE Dim_Data (
    ID_Data INT IDENTITY(1,1) PRIMARY KEY,
    Data DATE NOT NULL,
    Rok INT NOT NULL,
    Miesiac NVARCHAR(20) NOT NULL,
    NumerMiesiaca INT NOT NULL,
    Dzien INT NOT NULL,
    DzienTygodnia NVARCHAR(20) NOT NULL,
    NumerDniaTygodnia INT NOT NULL,
    Weekend NVARCHAR(20) NOT NULL,
    Swieto NVARCHAR(50) NOT NULL,
    Wakacje NVARCHAR(20) NOT NULL
);
GO

CREATE TABLE Dim_Czas (
    ID_Czas INT IDENTITY(1,1) PRIMARY KEY,
    Godzina TIME(0) NOT NULL,
    PoraDnia NVARCHAR(20) NOT NULL
);
GO

CREATE TABLE Dim_Uczestnictwo_Junk (
    ID_Junk INT IDENTITY(1,1) PRIMARY KEY,
    Obecny BIT NOT NULL
);
GO

CREATE TABLE Dim_TypZajec (
    ID_TypZajec INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(50) NOT NULL,
    KategoriaCzasuTrwania NVARCHAR(10) NULL,
);
GO

CREATE TABLE Dim_Sala (
    ID_Sala INT IDENTITY(1,1) PRIMARY KEY,
    NumerSali INT NOT NULL,
    KategoriaWielkosci NVARCHAR(20) NULL
);
GO

CREATE TABLE Dim_Czlonek (
    ID_Czlonek INT IDENTITY(1,1) PRIMARY KEY,
    NumerKartyCzlonkowskiej NVARCHAR(20) NULL,
    ImieINazwisko NVARCHAR(60) NULL,
    Email NVARCHAR(100) NULL,
    KategoriaStazu NVARCHAR(20) NULL,
    IsCurrent BIT NOT NULL DEFAULT(1) 
);
GO

CREATE TABLE Dim_Instruktor (
    ID_Instruktor INT IDENTITY(1,1) PRIMARY KEY,
    NumerPracownika NVARCHAR(20) NULL,
    ImieINazwisko NVARCHAR(60) NULL,
    Specjalizacja NVARCHAR(50) NULL,
    KategoriaStazu NVARCHAR(20) NULL,
    IsCurrent BIT NOT NULL DEFAULT(1)
);
GO

CREATE TABLE Dim_Ocena (
    ID_Ocena INT IDENTITY(1,1) PRIMARY KEY,
    Ocena NVARCHAR(10) NOT NULL,
    Komentarz NVARCHAR(100) NULL
);
GO

CREATE TABLE Fact_PrzeprowadzenieZajec (
    ID_PrzeprowadzenieZajec INT IDENTITY(1,1) PRIMARY KEY,
    ID_Instruktor INT NOT NULL,
    ID_TypZajec INT NOT NULL,
    ID_Sala INT NOT NULL,
    ID_Data INT NOT NULL,
    ID_Czas INT NOT NULL,
    LimitMiejsc INT NULL,
    LiczbaZapisanych INT NULL,
    LiczbaObecnych INT NULL,
    Frekwencja DECIMAL(5,2) NULL,
    CzasTrwaniaMin INT NULL,
    SredniaOcena DECIMAL(3,2) NULL,      
    ProcentZapelnienia DECIMAL(5,2) NULL,
    StazWKlubieInstruktor DECIMAL(5,2) NULL,
    SredniStazUczestnikow DECIMAL(5,2) NULL,
    CONSTRAINT FK_Fact_Prze_Instruktor FOREIGN KEY (ID_Instruktor) REFERENCES Dim_Instruktor(ID_Instruktor),
    CONSTRAINT FK_Fact_Prze_TypZajec FOREIGN KEY (ID_TypZajec) REFERENCES Dim_TypZajec(ID_TypZajec),
    CONSTRAINT FK_Fact_Prze_Sala FOREIGN KEY (ID_Sala) REFERENCES Dim_Sala(ID_Sala),
    CONSTRAINT FK_Fact_Prze_Data FOREIGN KEY (ID_Data) REFERENCES Dim_Data(ID_Data),
    CONSTRAINT FK_Fact_Prze_Czas FOREIGN KEY (ID_Czas) REFERENCES Dim_Czas(ID_Czas)
);
GO

CREATE TABLE Fact_Uczestnictwo (
    ID_Uczestnictwo INT IDENTITY(1,1) PRIMARY KEY,
    ID_PrzeprowadzenieZajec INT NOT NULL,
    ID_Czlonek INT NOT NULL,
    ID_Ocena INT NULL,
    ID_Junk INT NULL,
    Ocena DECIMAL(3,2) NULL,
    StazWKlubie DECIMAL(5,2) NULL,
    CONSTRAINT FK_Fact_Ucz_Prze FOREIGN KEY (ID_PrzeprowadzenieZajec) REFERENCES Fact_PrzeprowadzenieZajec(ID_PrzeprowadzenieZajec),
    CONSTRAINT FK_Fact_Ucz_Czlonek FOREIGN KEY (ID_Czlonek) REFERENCES Dim_Czlonek(ID_Czlonek),
    CONSTRAINT FK_Fact_Ucz_Ocena FOREIGN KEY (ID_Ocena) REFERENCES Dim_Ocena(ID_Ocena),
    CONSTRAINT FK_Fact_Ucz_Junk FOREIGN KEY (ID_Junk) REFERENCES Dim_Uczestnictwo_Junk(ID_Junk)
);
GO