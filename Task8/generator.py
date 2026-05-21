from faker import Faker
import csv, random
import pandas as pd
from unidecode import unidecode
from datetime import date, timedelta
import time

fake = Faker('pl_PL')
#random.seed(int(time.time()))
random.seed(42)

LICZBA_CZLONKOW = 300
LICZBA_INSTRUKTOROW = 12
SALE = 10

# >1.0 = zyskuje popularnosc, <1.0 traci zainteresowanie
TYPY_ZAJEC_TRENDY = {
    "Pilates": 1.1,
    "Zumba": 0.9,
    "Stretch": 1.0,
    "Yoga": 1.3,
    "Cross": 1.2,
    "Cardio": 1.0,
    "Siłownia": 1.0,
    "Fitness": 0.8
}
TYPY_ZAJEC = list(TYPY_ZAJEC_TRENDY.keys())
DOMENY = ["gmail.com", "yahoo.com", "wp.pl", "outlook.com", "onet.pl", "test.com", "o2.pl", "amazon.com"]
LICZBA_ZAJEC = 6000
LICZBA_ZAPISOW = 80000
DATA_POCZATKOWA_T1 = date(2022, 1, 1)
DATA_KONCOWA_T1   = date(2025, 10, 31)
DATA_POCZATKOWA_T2 = date(2025, 11, 1)
DATA_KONCOWA_T2   = date(2026, 10, 31)


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

limity_sal = {} # ID -> int
jakosc_instruktora = {} # ID -> float (0.0, 1.0)


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

def czynnik_miesiaca(dzien):
    miesiac = dzien.month
    if miesiac in [1,2,3]: return 1.3
    if miesiac in [4,5,6,9,10,11]: return 1.0
    if miesiac in [7,8]: return 0.8
    if miesiac in [12]: return 0.9
    return 1.0

def czynnik_dnia_tygodnia(dzien):
    dt = dzien.weekday()
    if dt == 0: return 1.2
    if dt == 1: return 1.1
    if dt >= 4: return 0.8
    return 1.0

def generuj_typ_zajec(typy_zajec):
    wiersze = [[id + 1, typ_zajec] for id, typ_zajec in enumerate(typy_zajec)]
    return wiersze

def generuj_sale(liczba_sal):
    wiersze = []
    for i in range(liczba_sal):
        limit = random.randint(8, 30)
        wiersze.append([i + 1, limit])
        limity_sal[i + 1] = limit
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

    jakosc = [0.95, 0.90, 0.45, 0.50] + [random.uniform(0.6, 0.8) for _ in range(liczba_instruktorow - 4)]
    i=0

    while len(wiersze) < liczba_instruktorow:
        gender = random.choice(["M","F"])
        imie, nazwisko = generuj_imie(gender), generuj_nazwisko(gender)
        numer_pracownika = generuj_numer_pracownika(imie, nazwisko)

        if numer_pracownika in klucze:
            continue
        klucze.add(numer_pracownika)

        wiersze.append([numer_pracownika, imie, nazwisko, random.choice(typy_zajec)])

        jakosc_instruktora[numer_pracownika] = jakosc[i]
        i += 1
    
    return wiersze

def generuj_zajecia(liczba_zajec, instruktorzy, sale, typy_zajec, start_id=1, start_date=DATA_POCZATKOWA_T1, end_date=DATA_KONCOWA_T1):
    wiersze = []
    mapa_zajec = {}
    for i in range(liczba_zajec):
        zajecia_id = start_id + i
        instruktor = random.choice(instruktorzy)
        numer_pracownika = instruktor[0]
        # Instruktor najczesciej prowadzi zajecia zgodne ze specjalizacja
        if random.random() > 0.2:
            typ_nazwa = instruktor[3]
            typ_id = typy_zajec.index(typ_nazwa) + 1
        else:
            typ_id = random.randint(1, len(typy_zajec))
            typ_nazwa = typy_zajec[typ_id - 1]

        sala_id = random.randint(1, len(sale))
        czas_trwania = random.choice([45, 60, 75, 90])
        data = random_date(start_date, end_date)
        godzina = f"{random.choice([6, 8, 10, 12, 16, 18, 20]):02}:00"

        wiersze.append([zajecia_id, sala_id, numer_pracownika, typ_id, czas_trwania, str(data), godzina])
        mapa_zajec[zajecia_id] = [sala_id, data, godzina, typ_nazwa, numer_pracownika]
    
    return wiersze, mapa_zajec

def generuj_zapis(czlonkowie, zajecia_rows, mapa_zajec, liczba_zapisow, poprawa_jakosci=0.0):
    id_czlonkow = [c[0] for c in czlonkowie]         
    id_zajec = [z[0] for z in zajecia_rows]    

    wiersze = []
    klucze = set()

    weights = []
    for zid in id_zajec:
        sala, dzien, godzina, typ, instruktor = mapa_zajec[zid]
        jakosc = jakosc_instruktora.get(instruktor)
        # dla T2, zeby uzyskac poprawe
        jakosc = min(1.0, jakosc + poprawa_jakosci)
        trend_typu = TYPY_ZAJEC_TRENDY.get(typ)
        miesiac = czynnik_miesiaca(dzien)
        dzien_tygodnia = czynnik_dnia_tygodnia(dzien)

        weight = jakosc * trend_typu * miesiac * dzien_tygodnia
        weights.append(weight)

    #print("Generowanie zapisow")
    wybrane_zajecia = random.choices(id_zajec, weights=weights, k=liczba_zapisow)

    for zid in wybrane_zajecia:
        numer_karty_czlonkowskiej = random.choice(id_czlonkow)

        para = (numer_karty_czlonkowskiej, zid)

        if para in klucze:
            continue
        klucze.add(para)

        sala_id = mapa_zajec[zid][0]
        limit = limity_sal[sala_id]

        data_zajec = mapa_zajec[zid][1]
        data_zapisu = data_zajec - timedelta(days=random.randint(1, 30))
        if data_zapisu < DATA_POCZATKOWA_T1:
            data_zapisu = DATA_POCZATKOWA_T1

        status = "Aktywny"

        instruktor = mapa_zajec[zid][4]
        jakosc = jakosc_instruktora.get(instruktor)
        # Szansa anulawania zalezna od jakosci insturuktora
        if random.random() < (0.25 - (jakosc*0.2)):
            status = "Anulowany"

        obecny = 0
        if status == "Aktywny":
            szansa_obecnosci = 0.6 + (jakosc * 0.35) + poprawa_jakosci
            if random.random() < szansa_obecnosci:
                obecny = 1

        wiersze.append([numer_karty_czlonkowskiej, zid, str(data_zapisu), status, obecny])
    
    return wiersze

def generuj_oceny(zapis, mapa_zajec, poprawa_jakosci=0.0):
    wiersze = []
    zajecia_count = {}
    for z in zapis:
        if z[3] == "Aktywny":
            zid = z[1]
            zajecia_count[zid] = zajecia_count.get(zid, 0) + 1

    obecni_czlonkowie = [wiersz for wiersz in zapis if wiersz[4] == 1]
    
    for wiersz in obecni_czlonkowie:
        numer_karty_czlonkowskiej = wiersz[0]
        zid = wiersz[1]
        numer_sali, data_zajec, godzina, typ, instruktor = mapa_zajec[zid]
        jakosc = jakosc_instruktora.get(instruktor)

        limit = limity_sal[numer_sali]
        uczestnicy = zajecia_count.get(zid, 0)
        zapelnienie = uczestnicy / limit

        bazowa_ocena = 1.0 + (jakosc * 4.0)

        ocena = random.gauss(bazowa_ocena, 0.75)

        ocena += poprawa_jakosci

        ocena = max(1, min(5, round(ocena)))

        komentarz = losuj_komentarz(ocena)

        if random.random() < 0.6:
            wiersze.append([numer_karty_czlonkowskiej, numer_sali, str(data_zajec), godzina, ocena, komentarz])
    
    return wiersze

 # GENEROWANIE DANYCH T1
czlonkowie = generuj_czlonkow(LICZBA_CZLONKOW)
instruktorzy = generuj_instruktorow(LICZBA_INSTRUKTOROW, TYPY_ZAJEC)
sale = generuj_sale(SALE)
typZajec = generuj_typ_zajec(TYPY_ZAJEC)
zajecia, mapa_zajec = generuj_zajecia(LICZBA_ZAJEC, instruktorzy, sale, TYPY_ZAJEC,
                                      start_id=1, start_date=DATA_POCZATKOWA_T1, end_date=DATA_KONCOWA_T1)
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
    write_csv("T1/Opinie.csv", ["NumerKartyCzlonkowskiej", "NumerSali", "DataZajec", "Godzina", "Ocena", "Komentarz"], opinie)

generuj_T1(czlonkowie, instruktorzy, sale, typZajec, zajecia, zapis, opinie)

## T2 ## 

NOWE_ZAJECIA = 2000
NOWE_ZAPISY = 35000
NOWI_CZLONKOWIE = 120
NOWI_INSTRUKTORZY = 5

def czlonkowie_zmiany(czlonkowie, procent_zmiany=0.1):
    nowe_domeny = ["allegro.pl", "example.com", "alibaba.org", "opera.xz", "myspace.online", "xcvz.pl"]
    liczba_zmian = max(1, int(procent_zmiany * len(czlonkowie)))
    zakres_start = max(0, len(czlonkowie) - liczba_zmian * random.randint(2,4))

    for i in range(zakres_start, len(czlonkowie), 1):
        numer_czlonka, imie, nazwisko, _ = czlonkowie[i]
        czlonkowie[i][3] = generuj_email(imie, nazwisko, nowe_domeny)
        #print(f"Zmieniono emial czlonka o nr: {numer_czlonka}")
    return czlonkowie

def instruktorzy_zmiany(instruktorzy, procent_zmiany=0.1):
    liczba_zmian = max(1, int(procent_zmiany * len(instruktorzy)))
    zakres_start = max(0, len(instruktorzy) - liczba_zmian * random.randint(2,4))

    for i in range(zakres_start, len(instruktorzy), 1):
        numer_pracownika = instruktorzy[i][0]
        stara_specjalizacja = instruktorzy[i][3]
        zmiana = [s for s in TYPY_ZAJEC if s != stara_specjalizacja]
        if zmiana:
            instruktorzy[i][3] = random.choice(zmiana)
        #print(f"Zmieniono specjalizacje instruktora o nr: {numer_pracownika}")
    return instruktorzy

def generuj_T2(czlonkowie, instruktorzy, sale, typZajec, zajecia, mapa_zajec, zapis, opinie):
    czlonkowie_T2 = [wiersz[:] for wiersz in czlonkowie]
    instruktorzy_T2 = [wiersz[:] for wiersz in instruktorzy]
    sale_T2 = [wiersz[:] for wiersz in sale]
    typZajec_T2 = [wiersz[:] for wiersz in typZajec]

    czlonkowie_T2 = czlonkowie_zmiany(czlonkowie_T2) + generuj_czlonkow(NOWI_CZLONKOWIE)
    instruktorzy_T2 = instruktorzy_zmiany(instruktorzy_T2) + generuj_instruktorow(NOWI_INSTRUKTORZY, TYPY_ZAJEC)
    
    id = len(zajecia) + 1
    nowe_zajecia, mapa_nowe_zajecia = generuj_zajecia(NOWE_ZAJECIA, instruktorzy_T2, sale_T2, TYPY_ZAJEC, start_id=id, start_date=DATA_POCZATKOWA_T2, end_date=DATA_KONCOWA_T2)
    nowe_zapisy = generuj_zapis(czlonkowie_T2, nowe_zajecia, mapa_nowe_zajecia, NOWE_ZAPISY, poprawa_jakosci=0.1)

    zajecia_T2 = zajecia + nowe_zajecia
    zapis_T2 = zapis + nowe_zapisy
    mapa_zajec_T2 = dict(mapa_zajec)
    mapa_zajec_T2.update(mapa_nowe_zajecia)

    nowe_opinie = generuj_oceny(nowe_zapisy, mapa_zajec_T2, poprawa_jakosci=0.4)
    opinie_T2 = opinie + nowe_opinie

    write_csv("T2/Czlonek.csv", ["NumerKartyCzlonkowskiej","Imie","Nazwisko","Email"], czlonkowie_T2)
    write_csv("T2/Instruktor.csv", ["NumerPracownika","Imie","Nazwisko","Specjalizacja"], instruktorzy_T2)
    write_csv("T2/Sala.csv", ["NumerSali","LimitMiejsc"], sale_T2)
    write_csv("T2/TypZajec.csv", ["TypZajecID","Nazwa"], typZajec_T2)
    write_csv("T2/Zajecia.csv", ["ZajeciaID","NumerSali","NumerPracownika","TypZajecID","CzasTrwania","DataZajec","Godzina"], zajecia_T2)
    write_csv("T2/Zapis.csv", ["NumerKartyCzlonkowskiej","ZajeciaID","DataZapisu","StatusZapisu","Obecny"], zapis_T2)
    write_csv("T2/Opinie.csv", ["NumerKartyCzlonkowskiej", "NumerSali", "DataZajec", "Godzina", "Ocena", "Komentarz"], opinie_T2)
    write_excel("T2/Opinie.xlsx", ["NumerKartyCzlonkowskiej","NumerSali","DataZajec","Godzina","Ocena","Komentarz"], opinie_T2)

generuj_T2(czlonkowie, instruktorzy, sale, typZajec, zajecia, mapa_zajec, zapis, opinie)