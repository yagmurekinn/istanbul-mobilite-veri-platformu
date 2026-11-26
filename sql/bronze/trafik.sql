-- Oturum 2 ödevi | Görev 1: trafik verisinin Ocak dosyası bronze katmanına
-- ___ yazan iki yeri doldurun, kaydedin ve DuckDB'de çalıştırın: .read sql/bronze/trafik.sql
-- Dosya her çalıştığında tablo silinir ve baştan kurulur; iki çalıştırma aynı tabloyu verir.
-- Kolon adlarını görmek için: DESCRIBE SELECT * FROM read_csv('veri/trafik_2024_01.csv.gz');
DROP TABLE IF EXISTS lake.bronze.trafik;

CREATE TABLE lake.bronze.trafik
PARTITIONED BY (month(DATE_TIME)) AS                  -- ① Trafik dosyasındaki tarih ve saat kolonu
SELECT * EXCLUDE (filename),
       parse_filename(filename) AS _kaynak_dosya,
       now() AS _yukleme_zamani
FROM read_csv('veri/trafik_2024_01.csv.gz', filename = true);     -- ② Ocak 2024 trafik dosyasının adı

-- Kontrol: satır sayısı
SELECT count(*) AS satir FROM lake.bronze.trafik;
