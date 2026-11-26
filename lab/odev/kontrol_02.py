"""Oturum 2'den sonraki görevin kontrolü.

Kullanım: make odev-kontrol N=02
Betik görev dosyalarını, trafik bronze tablosunu ve tekrarsız toplu ulaşım tablosunu sınar. Bütün adımlar TAMAM
olduğunda altı haneli kanıt kodunu yazar. Kod, görev teslimiyle birlikte platforma yüklenir.
"""
import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

LAB_KOK = Path(os.environ.get("LAB_KOK", Path(__file__).resolve().parents[2]))
DURUM = LAB_KOK / ".lab"
DOSYALAR = ["sql/bronze/trafik.sql", "sql/silver/toplu_ulasim.sql"]
TRAFIK = "trafik_2024_01.csv.gz"
BOYUTLAR = ("transition_date, transition_hour, transport_type_id, road_type, line, transfer_type, product_kind, "
            "transaction_type_desc, town, line_name, station_poi_desc_cd")


def baglanti():
    import duckdb
    b = duckdb.connect()
    b.execute((DURUM / "baglan.sql").read_text(encoding="utf-8"))
    return b


def tek(b, sorgu, parametre=None):
    return b.execute(sorgu, parametre or []).fetchall()[0][0]


def tablo_var(b, sema, tablo):
    return tek(b, "SELECT count(*) FROM duckdb_tables() WHERE database_name = 'lake' AND schema_name = ? "
                  "AND table_name = ?", [sema, tablo]) > 0


def yorumsuz(metin):
    """SQL metninden yorumları çıkarır: /* ... */ blokları ve -- ile başlayan satır sonları."""
    metin = re.sub(r"/\*.*?\*/", "", metin, flags=re.S)
    return "\n".join(satir.split("--")[0] for satir in metin.splitlines())


def dosyalar():
    eksik, bos = [], []
    for ad in DOSYALAR:
        yol = LAB_KOK / ad
        if not yol.exists():
            eksik.append(ad)
        elif "___" in yorumsuz(yol.read_text(encoding="utf-8")):
            bos.append(ad)
    if eksik:
        return False, f"dosya bulunamadı: {', '.join(eksik)}"
    if bos:
        return False, f"doldurulmamış boşluk (___) var: {', '.join(bos)}"
    return True, "iki dosya da dolu"


def trafik(b):
    if not tablo_var(b, "bronze", "trafik"):
        return False, "lake.bronze.trafik bulunamadı; sql/bronze/trafik.sql çalıştırılır", 0
    kolonlar = {k[0] for k in b.execute("SELECT * FROM lake.bronze.trafik LIMIT 0").description}
    eksik = {"_kaynak_dosya", "_yukleme_zamani"} - kolonlar
    if eksik:
        return False, f"bronze kararındaki kolonlar eksik: {', '.join(sorted(eksik))}", 0
    tabloda = tek(b, "SELECT count(*) FROM lake.bronze.trafik WHERE _kaynak_dosya = ?", [TRAFIK])
    kaynakta = tek(b, f"SELECT count(*) FROM read_csv('{LAB_KOK / 'veri' / TRAFIK}')")
    toplam = tek(b, "SELECT count(*) FROM lake.bronze.trafik")
    if tabloda != kaynakta or toplam != kaynakta:
        return False, f"tabloda {toplam} satır, {TRAFIK} dosyasında {kaynakta} satır", 0
    return True, f"{toplam} satır", toplam


def silver(b):
    if not tablo_var(b, "silver", "toplu_ulasim"):
        return False, "lake.silver.toplu_ulasim bulunamadı; sql/silver/toplu_ulasim.sql çalıştırılır", 0
    if not tablo_var(b, "bronze", "toplu_ulasim"):
        return False, "lake.bronze.toplu_ulasim bulunamadı; oturumlar/02/hazirlik.sql çalıştırılır", 0
    # Beklenen günlük yolculuk: bronze'daki toplam; satır sayısı geçen haftanın aynı gününün 1,5 katını aşan
    # günlerde (tekrar gönderilen günler) toplamın yarısı.
    beklenen = dict(b.execute(
        "WITH g AS (SELECT transition_date AS gun, count(*) AS satir, sum(number_of_passage) AS yolculuk "
        "FROM lake.bronze.toplu_ulasim GROUP BY ALL) "
        "SELECT gun, CASE WHEN satir > 1.5 * lag(satir, 7) OVER (ORDER BY gun) THEN yolculuk // 2 "
        "ELSE yolculuk END FROM g").fetchall())
    tabloda = dict(b.execute("SELECT transition_date, sum(number_of_passage) FROM lake.silver.toplu_ulasim "
                             "GROUP BY ALL").fetchall())
    for gun in sorted(set(beklenen) | set(tabloda)):
        if tabloda.get(gun) != beklenen.get(gun):
            ayrinti = f"{gun}: tabloda {tabloda.get(gun)} yolculuk, beklenen {beklenen.get(gun)}"
            if tabloda.get(gun) is not None and beklenen.get(gun) and tabloda[gun] == 2 * beklenen[gun]:
                ayrinti += "; bu gün tekrar gönderilmiş, ② numaralı tarih kontrol edilir"
            return False, ayrinti, 0
    satir = tek(b, "SELECT count(*) FROM lake.silver.toplu_ulasim")
    tekil = tek(b, f"SELECT count(*) FROM (SELECT DISTINCT {BOYUTLAR} FROM lake.silver.toplu_ulasim)")
    if satir != tekil:
        return False, f"{satir - tekil} satırın bütün kolonları başka bir satırla aynı; parça satırlar toplanmamış", 0
    toplam = sum(beklenen.values())
    return True, f"{satir} satır, {len(beklenen)} gün, {toplam} yolculuk", toplam


def main():
    print("Oturum 2 görevi sınanıyor.\n")
    sonuclar = []
    tamam1, ayrinti1 = dosyalar()
    sonuclar.append(("Görev dosyaları", tamam1, ayrinti1))
    b = baglanti()
    tamam2, ayrinti2, trafik_satir = trafik(b)
    sonuclar.append(("Trafik bronze tablosu", tamam2, ayrinti2))
    tamam3, ayrinti3, yolculuk = silver(b)
    sonuclar.append(("Toplu ulaşım silver tablosu", tamam3, ayrinti3))
    genislik = max(len(a) for a, _, _ in sonuclar)
    for ad, tamam, ayrinti in sonuclar:
        print(f"  {ad:<{genislik}}  {'TAMAM' if tamam else 'HATA ':5}  {ayrinti}")
    print()
    if all(t for _, t, _ in sonuclar):
        kullanici = os.environ.get("GITHUB_USER") or subprocess.run(["git", "config", "user.name"], capture_output=True,
                                                                    text=True).stdout.strip() or "bilinmiyor"
        kod = hashlib.sha256(f"odev-02|{kullanici}|{trafik_satir}|{yolculuk}".encode()).hexdigest()[:6].upper()
        print(f"Görev tamam. Kanıt kodu: {kod} (GitHub kullanıcısı: {kullanici})")
        sys.exit(0)
    print("Görev tamamlanmadı. HATA satırlarındaki açıklama eksik adımı gösterir.")
    sys.exit(1)


if __name__ == "__main__":
    main()
