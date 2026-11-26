-- Oturum 2 | Hazırlık
-- Pazartesi kurulan iki tabloyu herkes için aynı hale getirir: ham_ocak ve lake.bronze.toplu_ulasim.
-- make sql ile açılan DuckDB'de çalışır: .read oturumlar/02/hazirlik.sql
-- Tablolar doğruysa dosya hiçbir şeyi değiştirmez ve birkaç saniyede biter.
-- Eksik tablo kurulur; eksik ya da iki kez yüklenmiş dosya yeniden yüklenir. Bu durumda dosya bir dakika kadar sürer.

-- 1. Ham tablo: yoksa Ocak dosyasından kurulur
CREATE TABLE IF NOT EXISTS ham_ocak AS
SELECT * FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz');

-- 2. Bronze tablosu: yoksa ay partition'ıyla ve Ocak dosyasıyla kurulur
CREATE TABLE IF NOT EXISTS lake.bronze.toplu_ulasim
PARTITIONED BY (month(transition_date)) AS
SELECT * EXCLUDE (filename),
       parse_filename(filename) AS _kaynak_dosya,
       now() AS _yukleme_zamani
FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz', filename = true);

-- 3. Ocak dosyası tabloda tam bir kez bulunur
BEGIN TRANSACTION;
DELETE FROM lake.bronze.toplu_ulasim
WHERE _kaynak_dosya = 'toplu_ulasim_2024_01.csv.gz'
  AND (SELECT count(*) FROM lake.bronze.toplu_ulasim
       WHERE _kaynak_dosya = 'toplu_ulasim_2024_01.csv.gz') <> 17283355;
INSERT INTO lake.bronze.toplu_ulasim
SELECT * EXCLUDE (filename), parse_filename(filename), now()
FROM read_csv('veri/toplu_ulasim_2024_01.csv.gz', filename = true)
WHERE NOT EXISTS (SELECT 1 FROM lake.bronze.toplu_ulasim
                  WHERE _kaynak_dosya = 'toplu_ulasim_2024_01.csv.gz');
COMMIT;

-- 4. Şubat dosyası tabloda tam bir kez bulunur
BEGIN TRANSACTION;
DELETE FROM lake.bronze.toplu_ulasim
WHERE _kaynak_dosya = 'toplu_ulasim_2024_02.csv.gz'
  AND (SELECT count(*) FROM lake.bronze.toplu_ulasim
       WHERE _kaynak_dosya = 'toplu_ulasim_2024_02.csv.gz') <> 16958106;
INSERT INTO lake.bronze.toplu_ulasim
SELECT * EXCLUDE (filename), parse_filename(filename), now()
FROM read_csv('veri/toplu_ulasim_2024_02.csv.gz', filename = true)
WHERE NOT EXISTS (SELECT 1 FROM lake.bronze.toplu_ulasim
                  WHERE _kaynak_dosya = 'toplu_ulasim_2024_02.csv.gz');
COMMIT;

-- 5. Sonuç: tek satır
SELECT CASE
         WHEN (SELECT count(*) FROM ham_ocak) = 17283355
          AND (SELECT count(*) FROM lake.bronze.toplu_ulasim) = 34241461
         THEN 'HAZIR: ham_ocak 17.283.355 satır, bronze tablosu 34.241.461 satır'
         ELSE 'EKSİK: tablo sayıları beklenenden farklı, sohbete yazın'
       END AS durum;
