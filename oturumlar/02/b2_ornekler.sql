-- Oturum 2 | Blok 2 örnekleri: window fonksiyonları
-- DuckDB'de çalışır: .read oturumlar/02/b2_ornekler.sql
-- Dosya önce iki küçük tablo kurar, sonra anlatımdaki dört örneği sırayla çalıştırır.

-- Ocak'ın günlük yolculuk toplamı: 31 satır, her gün bir satır
CREATE OR REPLACE TABLE gunluk AS
SELECT transition_date AS gun,
       ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'][dayofweek(transition_date) + 1] AS gun_adi,
       sum(number_of_passage) AS yolculuk
FROM ham_ocak
GROUP BY ALL;

-- Üç hattın günlük yolculuk toplamı: 93 satır, her hat ve gün bir satır
CREATE OR REPLACE TABLE hat_gunluk AS
SELECT transition_date AS gun, line_name AS hat, sum(number_of_passage) AS yolculuk
FROM ham_ocak
WHERE line_name IN ('M2', 'M4', 'MARMARAY')
GROUP BY ALL;

-- Örnek 1: her günün yanında ayın toplamı
SELECT gun, gun_adi, yolculuk,
       sum(yolculuk) OVER () AS ay_toplami
FROM gunluk
ORDER BY gun
LIMIT 5;

-- Örnek 2: günlerin kalabalık sırası
SELECT gun, gun_adi, yolculuk,
       row_number() OVER (ORDER BY yolculuk DESC) AS sira
FROM gunluk
ORDER BY sira
LIMIT 5;

-- Örnek 3: her hattın en kalabalık iki günü
SELECT hat, gun, yolculuk,
       row_number() OVER (PARTITION BY hat ORDER BY yolculuk DESC) AS sira
FROM hat_gunluk
QUALIFY sira <= 2
ORDER BY hat, sira;

-- Örnek 4: bir önceki günün yolculuğu
SELECT gun, gun_adi, yolculuk,
       lag(yolculuk) OVER (ORDER BY gun) AS onceki_gun
FROM gunluk
ORDER BY gun
LIMIT 5;
