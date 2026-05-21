from faker import Faker
import csv, random
import pandas as pd
from unidecode import unidecode
from datetime import date, timedelta
import time

fake = Faker('pl_PL')
random.seed(int(time.time()))

LICZBA_CZLONKOW = 25
LICZBA_INSTRUKTOROW = 10
SALE = 10
TYPY_ZAJEC = ["Pilates","Zumba","Stretch","Yoga","Cross","Cardio","Siłownia","Fitness"]
DOMENY = ["gmail.com", "yahoo.com", "wp.pl", "outlook.com", "onet.pl", "test.com", "o2.pl", "amazon.com"]
LICZBA_ZAJEC = 40
LICZBA_ZAPISOW = 40
DATA_POCZATKOWA = date(2022, 1, 1)
DATA_KONCOWA   = date(2025, 10, 31)

NEGATYWNE = [
    "Sala za mała, było zbyt tłoczno i duszno.",
    "Instruktor mówił zbyt cicho, trudno było zrozumieć polecenia.",
    "Sprzęt w złym stanie, kilka mat było podartych.",
    "Zajęcia rozpoczęły się z dużym opóźnieniem.",
    "Za dużo osób w grupie, brakowało indywidualnego podejścia."
]

POZYTYWNE = [
    "Świetny instruktor, zajęcia bardzo motywujące!",
    "Super atmosfera i dobrze dobrane tempo ćwiczeń.",
    "Sala czysta, sprzęt w doskonałym stanie – polecam!",
    "Instruktor tłumaczy wszystko bardzo jasno i z uśmiechem.",
    "Zajęcia idealne na początek dnia, dużo energii i pozytywnej muzyki."
]

def write_csv(path, header, rows):
    with open (path, "w", newline="", encoding="utf-8") as file:
        w = csv.writer(file)
        w.writerow(header)
        w.writerows(rows)

def write_excel(path, header, rows):
    df = pd.DataFrame(rows, columns=header)
    df.to_excel(path, sheet_name="Opinie", index=False)


def random_date(start_date, end_date):
    days = (end_date - start_date).days
    return start_date + timedelta(days=random.randint(0, days))

def losuj_komentarz(ocena):
    if ocena <= 3:
        return random.choice(NEGATYWNE)
    else:
        return random.choice(POZYTYWNE)

def generuj_typ_zajec(typy_zajec):
    wiersze = [[id + 1, typ_zajec] for id, typ_zajec in enumerate(typy_zajec)]
    return wiersze

def generuj_sale(liczba_sal):
    wiersze = []
    for i in range(liczba_sal):
        limit = random.randint(10, 30)
        wiersze.append([i + 1, limit])
    return wiersze

def generuj_imie(gender):
    return fake.first_name_male() if gender == "M" else fake.first_name_female()

def generuj_nazwisko(gender):
    return fake.last_name_male() if gender == "M" else fake.last_name_female()

def generuj_email(imie, nazwisko, domeny):
    imie = unidecode(imie.lower())
    nazwisko = unidecode(nazwisko.lower())
    domena = random.choice(domeny)
    return f"{imie}.{nazwisko}@{domena}"

def generuj_numer_czlonka_klubu(imie, nazwisko):
    return "MC" + unidecode(imie[:2].upper()) + unidecode(nazwisko[:2].upper()) + str(random.randint(1000, 9999))

def generuj_numer_pracownika(imie, nazwisko):
    return "WN" + unidecode(imie[:2].upper()) + unidecode(nazwisko[:2].upper()) + str(random.randint(1000, 9999))

def generuj_czlonkow(liczba_czlonkow):
    wiersze = []
    klucze = set()
    
    while len(wiersze) < liczba_czlonkow:
        gender = random.choice(["M","F"])
        imie, nazwisko = generuj_imie(gender), generuj_nazwisko(gender)
        numer_czlonka = generuj_numer_czlonka_klubu(imie, nazwisko)

        if numer_czlonka in klucze:
            continue
        klucze.add(numer_czlonka)

        wiersze.append([numer_czlonka, imie, nazwisko, generuj_email(imie, nazwisko, DOMENY)])

    return wiersze

def generuj_instruktorow(liczba_instruktorow, typy_zajec):
    wiersze = []
    klucze = set()

    while len(wiersze) < liczba_instruktorow:
        gender = random.choice(["M","F"])
        imie, nazwisko = generuj_imie(gender), generuj_nazwisko(gender)
        numer_pracownika = generuj_numer_pracownika(imie, nazwisko)

        if numer_pracownika in klucze:
            continue
        klucze.add(numer_pracownika)

        wiersze.append([numer_pracownika, imie, nazwisko, random.choice(typy_zajec)])
    
    return wiersze

def generuj_zajecia(liczba_zajec, instruktorzy, sale, typy_zajec, start_id=1):
    wiersze = []
    mapa_zajec = {}
    for i in range(liczba_zajec):
        zajecia_id = start_id + i
        numer_pracownika = random.choice(instruktorzy)[0]
        typ_id = random.randint(1, len(typy_zajec))
        sala_id = random.randint(1, len(sale))
        czas_trwania = random.choice([45, 60, 75, 90])
        data = random_date(DATA_POCZATKOWA, DATA_KONCOWA)
        godzina = f"{random.choice([6, 8, 10, 12, 16, 18, 20]):02}:00"
        wiersze.append([zajecia_id, sala_id, numer_pracownika, typ_id, czas_trwania, str(data), godzina])
        mapa_zajec[zajecia_id] = [sala_id, data, godzina]
    
    return wiersze, mapa_zajec

def generuj_zapis(czlonkowie, zajecia_rows, mapa_zajec, liczba_zapisow):
    id_czlonkow = [c[0] for c in czlonkowie]         
    id_zajec = [z[0] for z in zajecia_rows]    

    wiersze = []
    klucze = set()
    while len(wiersze) < liczba_zapisow:
        numer_karty_czlonkowskiej = random.choice(id_czlonkow)
        zajecia_id = random.choice(id_zajec)
        para = (numer_karty_czlonkowskiej, zajecia_id)
        
        if para in klucze:
            continue
        klucze.add(para)

        data_zajec = mapa_zajec[zajecia_id][1]
        data_zapisu = data_zajec - timedelta(days=random.randint(1, 30))
        if data_zapisu < DATA_POCZATKOWA:
            data_zapisu = DATA_POCZATKOWA
        status = random.choices(["Aktywny", "Anulowany"], weights=[0.85, 0.15])[0]
        obecny = 0 if status == "Anulowany" else random.choices([0, 1], weights=[0.1, 0.9])[0]
        wiersze.append([numer_karty_czlonkowskiej, zajecia_id, str(data_zapisu), status, obecny])
    
    return wiersze

def generuj_oceny(zapis, mapa_zajec):    
    wiersze = []
    obecni_czlonkowie = [wiersz for wiersz in zapis if wiersz[4] == 1]
    
    for i in range(len(obecni_czlonkowie)):
        numer_karty_czlonkowskiej = obecni_czlonkowie[i][0]
        zajecia_id = obecni_czlonkowie[i][1]
        numer_sali, data_zajec, godzina = mapa_zajec[zajecia_id]
        ocena = random.randint(1,5)
        komentarz = losuj_komentarz(ocena)
        wiersze.append([numer_karty_czlonkowskiej, numer_sali, str(data_zajec), godzina, ocena, komentarz])
    
    return wiersze

czlonkowie = generuj_czlonkow(LICZBA_CZLONKOW)
instruktorzy = generuj_instruktorow(LICZBA_INSTRUKTOROW, TYPY_ZAJEC)
sale = generuj_sale(SALE)
typZajec = generuj_typ_zajec(TYPY_ZAJEC)
zajecia, mapa_zajec = generuj_zajecia(LICZBA_ZAJEC, instruktorzy, sale, TYPY_ZAJEC)
zapis = generuj_zapis(czlonkowie, zajecia, mapa_zajec, LICZBA_ZAPISOW)
opinie = generuj_oceny(zapis, mapa_zajec)

def generuj_T1(czlonkowie, instruktorzy, sale, typZajec, zajecia, zapis, opinie):
    write_csv("T1/Czlonek.csv",["NumerKartyCzlonkowskiej","Imie","Nazwisko","Email"], czlonkowie)
    write_csv("T1/Instruktor.csv",["NumerPracownika","Imie","Nazwisko","Specjalizacja"], instruktorzy)
    write_csv("T1/Sala.csv",["NumerSali","LimitMiejsc"], sale)
    write_csv("T1/TypZajec.csv",["TypZajecID","Nazwa"], typZajec)
    write_csv("T1/Zajecia.csv",["ZajeciaID","NumerSali","NumerPracownika","TypZajecID","CzasTrwania","DataZajec","Godzina"], zajecia)
    write_csv("T1/Zapis.csv",["NumerKartyCzlonkowskiej","ZajeciaID","DataZapisu","StatusZapisu","Obecny"], zapis)
    write_excel("T1/Opinie.xlsx", ["NumerKartyCzlonkowskiej","NumerSali","DataZajec","Godzina","Ocena","Komentarz"], opinie)
generuj_T1(czlonkowie, instruktorzy, sale, typZajec, zajecia, zapis, opinie)

## T2 ## 

NOWE_ZAJECIA = 20
NOWE_ZAPISY = 20
NOWI_CZLONKOWIE = 5
NOWI_INSTRUKTORZY = 5

def czlonkowie_zmiany(czlonkowie, procent_zmiany=0.2):
    nowe_domeny = ["allegro.pl", "example.com", "alibaba.org", "opera.xz", "myspace.online", "xcvz.pl"]
    liczba_zmian = max(1, int(procent_zmiany * len(czlonkowie)))
    zakres_start = max(0, len(czlonkowie) - liczba_zmian)

    for i in range(zakres_start, len(czlonkowie), 1):
        numer_czlonka, imie, nazwisko, _ = czlonkowie[i]
        czlonkowie[i][3] = generuj_email(imie, nazwisko, nowe_domeny)
        print(f"Zmieniono emial czlonka o nr: {numer_czlonka}")
    return czlonkowie

def instruktorzy_zmiany(instruktorzy, procent_zmiany=0.2):
    liczba_zmian = max(1, int(procent_zmiany * len(instruktorzy)))
    zakres_start = max(0, len(instruktorzy) - liczba_zmian)

    for i in range(zakres_start, len(instruktorzy), 1):
        numer_pracownika = instruktorzy[i][0]
        stara_specjalizacja = instruktorzy[i][3]
        zmiana = [s for s in TYPY_ZAJEC if s != stara_specjalizacja]
        if zmiana:
            instruktorzy[i][3] = random.choice(zmiana)
        print(f"Zmieniono specjalizacje instruktora o nr: {numer_pracownika}")
    return instruktorzy

def generuj_T2(czlonkowie, instruktorzy, sale, typZajec, zajecia, mapa_zajec, zapis, opinie):
    czlonkowie_T2 = [wiersz[:] for wiersz in czlonkowie]
    instruktorzy_T2 = [wiersz[:] for wiersz in instruktorzy]
    sale_T2 = [wiersz[:] for wiersz in sale]
    typZajec_T2 = [wiersz[:] for wiersz in typZajec]

    czlonkowie_T2 = czlonkowie_zmiany(czlonkowie_T2) + generuj_czlonkow(NOWI_CZLONKOWIE)
    instruktorzy_T2 = instruktorzy_zmiany(instruktorzy_T2) + generuj_instruktorow(NOWI_INSTRUKTORZY, TYPY_ZAJEC)
    
    id = len(zajecia) + 1
    nowe_zajecia, mapa_nowe_zajecia = generuj_zajecia(NOWE_ZAJECIA, instruktorzy_T2, sale_T2, TYPY_ZAJEC, start_id=id)
    nowe_zapisy = generuj_zapis(czlonkowie_T2, nowe_zajecia, mapa_nowe_zajecia, NOWE_ZAPISY)

    zajecia_T2 = zajecia + nowe_zajecia
    zapis_T2 = zapis + nowe_zapisy
    mapa_zajec_T2 = dict(mapa_zajec)
    mapa_zajec_T2.update(mapa_nowe_zajecia)

    nowe_opinie = generuj_oceny(nowe_zapisy, mapa_zajec_T2)
    opinie_T2 = opinie + nowe_opinie

    write_csv("T2/Czlonek.csv", ["NumerKartyCzlonkowskiej","Imie","Nazwisko","Email"], czlonkowie_T2)
    write_csv("T2/Instruktor.csv", ["NumerPracownika","Imie","Nazwisko","Specjalizacja"], instruktorzy_T2)
    write_csv("T2/Sala.csv", ["NumerSali","LimitMiejsc"], sale_T2)
    write_csv("T2/TypZajec.csv", ["TypZajecID","Nazwa"], typZajec_T2)
    write_csv("T2/Zajecia.csv", ["ZajeciaID","NumerSali","NumerPracownika","TypZajecID","CzasTrwania","DataZajec","Godzina"], zajecia_T2)
    write_csv("T2/Zapis.csv", ["NumerKartyCzlonkowskiej","ZajeciaID","DataZapisu","StatusZapisu","Obecny"], zapis_T2)
    write_excel("T2/Opinie.xlsx", ["NumerKartyCzlonkowskiej","NumerSali","DataZajec","Godzina","Ocena","Komentarz"], opinie_T2)

generuj_T2(czlonkowie, instruktorzy, sale, typZajec, zajecia, mapa_zajec, zapis, opinie)