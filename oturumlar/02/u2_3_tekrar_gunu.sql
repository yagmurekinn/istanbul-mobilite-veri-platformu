-- Oturum 2 | Uygulama 3: tekrar gönderilen günleri bulmak ve düzeltmek
-- 1. Önce ① numaralı boşluğu doldurun, kaydedin ve çalıştırın: .read oturumlar/02/u2_3_tekrar_gunu.sql
-- 2. Adım 1'in sonucunda Şubat'taki günü bulun, ② numaralı boşluğa yazın, kaydedin ve dosyayı yeniden çalıştırın.
-- Şubat'taki günü ve o günün düzeltilmiş yolculuğunu sohbete yazın.

-- Adım 1: her günün satır sayısı ve geçen haftanın aynı gününe göre kaç kat olduğu
SELECT gun, satir,
       lag(satir, ___) OVER (ORDER BY gun) AS gecen_hafta,     -- ① Uygulama 2'deki sayı
       round(satir / gecen_hafta, 2) AS kat
FROM (SELECT transition_date AS gun, count(*) AS satir
      FROM lake.bronze.toplu_ulasim
      GROUP BY ALL)
ORDER BY kat DESC
LIMIT 3;

-- Adım 2: Ocak ve Şubat'ın günlük yolculuk toplamı, ayrı bir tabloda
CREATE OR REPLACE TABLE gunluk_bronze AS
SELECT transition_date AS gun, sum(number_of_passage) AS yolculuk
FROM lake.bronze.toplu_ulasim
GROUP BY ALL;

-- Adım 3: tekrar gönderilen günlerin toplamı ikiye bölünür. // tam sayı bölmesidir.
UPDATE gunluk_bronze
SET yolculuk = yolculuk // 2
WHERE gun IN (DATE '2024-01-10', DATE '___');                 -- ② Adım 1'in bulduğu Şubat günü: YYYY-AA-GG

-- Adım 4: iki ayın bütün çarşambaları (dayofweek: 0 pazar, 3 çarşamba)
SELECT gun, yolculuk
FROM gunluk_bronze
WHERE dayofweek(gun) = 3
ORDER BY gun;

-- İleri görev: Mart dosyasında da tekrar gönderilen bir gün var. Aşağıdaki /* ve */ satırlarını silin,
-- ③ numaralı boşluğu doldurun ve günü bulun.
/*
SELECT gun, satir,
       lag(satir, 7) OVER (ORDER BY gun) AS gecen_hafta,
       round(satir / gecen_hafta, 2) AS kat
FROM (SELECT transition_date AS gun, count(*) AS satir
      FROM read_csv('veri/___')                               -- ③ Mart 2024 toplu ulaşım dosyasının adı
      GROUP BY ALL)
ORDER BY kat DESC
LIMIT 3;
*/
