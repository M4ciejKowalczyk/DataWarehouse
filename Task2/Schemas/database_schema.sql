CREATE DATABASE FitnessClub;
GO

USE FitnessClub;
GO

CREATE TABLE Sala (
	NumerSali INTEGER PRIMARY KEY,
	LimitMiejsc INTEGER NOT NULL
); 
GO

CREATE TABLE TypZajec (
	TypZajecID INTEGER PRIMARY KEY,
	Nazwa VARCHAR(50) NOT NULL,
); 
GO

CREATE TABLE Instruktor (
	NumerPracownika VARCHAR(10) PRIMARY KEY,
	Imie VARCHAR(30) NOT NULL,
	Nazwisko VARCHAR(30) NOT NULL,
	Specjalizacja VARCHAR(50) NOT NULL
); 
GO

CREATE TABLE Czlonek (
	NumerKartyCzlonkowskiej VARCHAR(10) PRIMARY KEY,
	Imie VARCHAR(30) NOT NULL,
	Nazwisko VARCHAR(30) NOT NULL,
	Email VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Zajecia (
	ZajeciaID INTEGER PRIMARY KEY,
	NumerSali INTEGER FOREIGN KEY REFERENCES Sala,
	NumerPracownika VARCHAR(10) FOREIGN KEY REFERENCES Instruktor,
	TypZajecID INTEGER FOREIGN KEY REFERENCES TypZajec,
	CzasTrwania INTEGER NOT NULL,
	DataZajec DATE NOT NULL,
	Godzina TIME NOT NULL
);
GO

CREATE TABLE Zapis (
	NumerKartyCzlonkowskiej VARCHAR(10) FOREIGN KEY REFERENCES Czlonek,
	ZajeciaID INTEGER FOREIGN KEY REFERENCES Zajecia,
	PRIMARY KEY (NumerKartyCzlonkowskiej, ZajeciaID),
	DataZapisu DATE NOT NULL,
	StatusZapisu VARCHAR(20) NOT NULL,
	Obecny BIT NOT NULL
);
GO