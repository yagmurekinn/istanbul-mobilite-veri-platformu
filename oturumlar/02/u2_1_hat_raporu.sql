-- Oturum 2 | Uygulama 1: M2'nin en kalabalık günleri
-- 1. ___ yazan iki yeri doldurun.
-- 2. Dosyayı kaydedin: Ctrl+S
-- 3. DuckDB'de çalıştırın: .read oturumlar/02/u2_1_hat_raporu.sql
-- Sonuç M2'de en çok yolculuk yapılan beş günü gösterir. En üstteki günü ve yolculuğu sohbete yazın.

SELECT transition_date AS gun,
       sum(___) AS yolculuk                  -- ① Yolculuk sayısını taşıyan kolon
FROM ham_ocak
WHERE line_name = 'M2'
GROUP BY ___                                 -- ② Sonuçta her gün bir satır olsun: hangi kolona göre gruplanır?
ORDER BY yolculuk DESC
LIMIT 5;

-- İleri görev: kullandığınız bir hattın en kalabalık günleri. Aşağıdaki /* ve */ satırlarını silin,
-- ③ numaralı boşluğa hattın kodunu yazın. Kod tek tırnak içinde ve verideki yazılışıyla yazılır: 'M4', 'MARMARAY', '34'.
/*
SELECT transition_date AS gun,
       sum(number_of_passage) AS yolculuk
FROM ham_ocak
WHERE line_name = ___                        -- ③ Hattın kodu, tek tırnak içinde
GROUP BY transition_date
ORDER BY yolculuk DESC
LIMIT 5;
*/
