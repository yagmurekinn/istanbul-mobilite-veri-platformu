-- Oturum 2 | Blok 1 örnekleri: SQL'in temeli
-- DuckDB'de çalışır: .read oturumlar/02/b1_ornekler.sql
-- Dört örnek de ham_ocak tablosunu okur: Ocak dosyasının 17.283.355 satırı.

-- Örnek 1: SELECT, FROM ve LIMIT. Beş kolon, tablonun ilk beş satırı.
SELECT transition_date,
       transition_hour,
       line_name, town,
       number_of_passage
FROM ham_ocak
LIMIT 5;

-- Örnek 2: WHERE. 3 Ocak'ta M2 hattının satırlarından beşi.
SELECT transition_date, line_name,
       station_poi_desc_cd,
       number_of_passage
FROM ham_ocak
WHERE line_name = 'M2'
  AND transition_date = DATE '2024-01-03'
LIMIT 5;

-- Örnek 3: count ve sum. Tablonun satır sayısı ve yolculuk toplamı.
SELECT count(*) AS satir,
       sum(number_of_passage) AS yolculuk
FROM ham_ocak;

-- Örnek 4: GROUP BY ve ORDER BY. En çok yolculuk yapılan beş hat.
SELECT line_name AS hat,
       sum(number_of_passage) AS yolculuk
FROM ham_ocak
GROUP BY line_name
ORDER BY yolculuk DESC
LIMIT 5;
