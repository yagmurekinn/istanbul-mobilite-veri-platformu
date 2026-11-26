-- Oturum 2 ödevi | Görev 2: tekrarsız toplu ulaşım tablosu (silver)
-- ___ yazan iki yeri doldurun, kaydedin ve DuckDB'de çalıştırın: .read sql/silver/toplu_ulasim.sql
-- Dosya her çalıştığında tablo silinir ve baştan kurulur; iki çalıştırma aynı tabloyu verir.
DROP TABLE IF EXISTS lake.silver.toplu_ulasim;

-- 1. Parça satırlar toplanır: yolculuk ve yolcu dışındaki kolonları aynı olan satırlar tek satır olur.
--    ::BIGINT toplamı tablonun saklayabileceği tam sayı türüne çevirir.
CREATE TABLE lake.silver.toplu_ulasim
PARTITIONED BY (month(transition_date)) AS                  -- ① Bronze tablosundaki tarih kolonu
SELECT * EXCLUDE (number_of_passage, number_of_passenger, _kaynak_dosya, _yukleme_zamani),
       sum(number_of_passage)::BIGINT AS number_of_passage,
       sum(number_of_passenger)::BIGINT AS number_of_passenger
FROM lake.bronze.toplu_ulasim
GROUP BY ALL;

-- 2. Tekrar gönderilen günlerin toplamları ikiye bölünür
UPDATE lake.silver.toplu_ulasim
SET number_of_passage = number_of_passage // 2,
    number_of_passenger = number_of_passenger // 2
WHERE transition_date IN (DATE '2024-01-10', DATE '2024-02-14');   -- ② Uygulama 3'te bulunan Şubat günü

-- Kontrol: dört çarşambanın yolculuğu
SELECT transition_date AS gun, sum(number_of_passage) AS yolculuk
FROM lake.silver.toplu_ulasim
WHERE transition_date IN (DATE '2024-01-03', DATE '2024-01-10', DATE '2024-02-07', DATE '2024-02-14')
GROUP BY ALL
ORDER BY gun;
