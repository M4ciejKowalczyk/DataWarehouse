import pandas as pd
import datetime

# ============================================================
#   FUNKCJE DO WYLICZANIA ŚWIĄT RUCHOMYCH
# ============================================================

def easter_date(year):
    """Obliczanie daty Wielkanocy (algorytm Meeusa)."""
    a = year % 19
    b = year // 100
    c = year % 100
    d = b // 4
    e = b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i = c // 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    month = (h + l - 7 * m + 114) // 31
    day = ((h + l - 7 * m + 114) % 31) + 1
    return datetime.date(year, month, day)

def holidays_poland(year):
    """Zwraca dict: data → nazwa święta."""
    easter = easter_date(year)
    easter_monday = easter + datetime.timedelta(days=1)
    pentecost = easter + datetime.timedelta(days=49)
    corpus_christi = easter + datetime.timedelta(days=60)

    return {
        datetime.date(year, 1, 1): "Nowy Rok",
        datetime.date(year, 1, 6): "Święto Trzech Króli",
        datetime.date(year, 5, 1): "Święto Pracy",
        datetime.date(year, 5, 3): "Święto Konstytucji 3 Maja",
        datetime.date(year, 8, 15): "Wniebowstąpienie NMP",
        datetime.date(year, 11, 1): "Wszystkich Świętych",
        datetime.date(year, 11, 11): "Święto Niepodległości",
        datetime.date(year, 12, 24): "Wigilia",
        datetime.date(year, 12, 25): "Pierwszy Dzień Bożego Narodzenia",
        datetime.date(year, 12, 26): "Drugi Dzień Bożego Narodzenia",
        easter: "Wielkanoc",
        easter_monday: "Poniedziałek Wielkanocny",
        pentecost: "Zielone Świątki",
        corpus_christi: "Boże Ciało"
    }

# ============================================================
#   GENEROWANIE Dim_Data
# ============================================================

start_date = datetime.date(2022, 1, 1)
end_date = datetime.date(2026, 10, 31)

rows = []
id_counter = 1

current = start_date
holidays_cache = {}

while current <= end_date:
    year = current.year

    # Cache świąt dla roku
    if year not in holidays_cache:
        holidays_cache[year] = holidays_poland(year)

    swieto = holidays_cache[year].get(current, "brak święta")

    # Angielskie nazwy dni/miesięcy
    rok = current.year
    miesiac = current.strftime("%B")
    numer_miesiaca = current.month
    dzien = current.day
    dzien_tygodnia = current.strftime("%A")
    numer_dnia_tygodnia = current.isoweekday()

    weekend = "weekend" if numer_dnia_tygodnia >= 6 else "dzień pracujący"

    # Wakacje (prosty model)
    if current.month in (7, 8):
        wakacje = "wakacje letnie"
    elif current.month == 2 and current.day <= 15:
        wakacje = "ferie zimowe"
    else:
        wakacje = "brak wakacji"

    rows.append([
        id_counter,
        current,
        rok,
        miesiac,
        numer_miesiaca,
        dzien,
        dzien_tygodnia,
        numer_dnia_tygodnia,
        weekend,
        swieto,
        wakacje
    ])

    id_counter += 1
    current += datetime.timedelta(days=1)

df = pd.DataFrame(rows, columns=[
    "ID_Data","Data","Rok","Miesiac","NumerMiesiaca","Dzien",
    "DzienTygodnia","NumerDniaTygodnia","Weekend","Swieto","Wakacje"
])

df.to_csv("Dim_Data.csv", sep=";", index=False, encoding="utf-8-sig")
print("Generated Dim_Data.csv")

# ============================================================
#   GENEROWANIE Dim_Czas
# ============================================================

rows = []
for h in range(24):
    if 0 <= h < 8:
        pora = "noc/rano"
    elif 8 <= h < 12:
        pora = "rano"
    elif 12 <= h < 16:
        pora = "popołudnie"
    elif 16 <= h < 20:
        pora = "wieczór"
    else:
        pora = "noc"

    rows.append([h + 1, f"{h:02d}:00", pora])

df = pd.DataFrame(rows, columns=["ID_Czas","Godzina","PoraDnia"])
df.to_csv("Dim_Czas.csv", sep=";", index=False, encoding = "utf-8-sig")
print("Generated Dim_Czas.csv")

