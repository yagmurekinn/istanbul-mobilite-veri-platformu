-- Oturum 2 | Uygulama 2: her günü geçen haftanın aynı günüyle karşılaştırmak
-- 1. ___ yazan iki yeri doldurun.
-- 2. Dosyayı kaydedin: Ctrl+S
-- 3. DuckDB'de çalıştırın: .read oturumlar/02/u2_2_gecen_hafta.sql
-- Sonuç farkı en büyük beş günü gösterir. En üstteki günü ve farkı sohbete yazın.

-- Ocak'ın günlük yolculuk toplamı (örnek dosyadaki tabloyla aynı)
CREATE OR REPLACE TABLE gunluk AS
SELECT transition_date AS gun,
       ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'][dayofweek(transition_date) + 1] AS gun_adi,
       sum(number_of_passage) AS yolculuk
FROM ham_ocak
GROUP BY ALL;

SELECT gun, gun_adi, yolculuk,
       lag(yolculuk, ___) OVER (ORDER BY gun) AS gecen_hafta,   -- ① Bir hafta önceki gün kaç satır yukarıda?
       yolculuk - gecen_hafta AS fark
FROM gunluk
ORDER BY ___ DESC                                               -- ② Sonuç hangi kolona göre sıralanmalı?
LIMIT 5;

-- İleri görev: farkı yüzde olarak görmek. Aşağıdaki /* ve */ satırlarını silin, ③ numaralı boşluğu doldurun.
/*
SELECT gun, gun_adi, yolculuk,
       lag(yolculuk, 7) OVER (ORDER BY gun) AS gecen_hafta,
       round(100.0 * (yolculuk - gecen_hafta) / ___, 1) AS yuzde   -- ③ Fark hangi kolona bölünmeli?
FROM gunluk
ORDER BY yuzde DESC
LIMIT 5;
*/
