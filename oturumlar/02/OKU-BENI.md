# Oturum 2 | Çalışma dosyası

Bugünün bütün uygulamaları aynı beş adımla yapılır:

1. Dosyayı soldaki gezginde `oturumlar/02` klasöründen açıyorsunuz.
2. `___` ile işaretli boşlukları dolduruyorsunuz. Her boşluğun yanındaki not ne yazılacağını söyler.
3. Dosyayı Ctrl+S (Mac'te Cmd+S) ile kaydediyorsunuz.
4. Dosyayı DuckDB'de `.read` ve dosyanın yoluyla çalıştırıyorsunuz.
5. Çıktıyı okuyorsunuz.

Sorgular dosyada hazır gelir; en önemli parçasını siz yazarsınız. Böylece vakit yazım hatalarına değil, sorgunun ne yaptığını anlamaya gider. Sorgunun dosyada durması da düzeltip yeniden çalıştırmayı kolaylaştırır.

Doldurulmamış bir boşluk hata verir ve hata mesajı boşluğun yerini `^^^` işaretiyle gösterir. Boşluğu doldurup dosyayı kaydettikten sonra dosya yeniden çalıştırılır.

## Terminal mi, DuckDB mi?

| Satırın başı | Program | Buraya yazılanlar |
|---|---|---|
| `$` ile biter | Terminal | `make` ve `git` komutları |
| `calisma D` ile başlar | DuckDB | SQL sorguları, `.read` ve `.quit` |

- DuckDB terminalde `make sql` komutuyla açılır, `.quit` komutuyla kapanır.
- Uzun süren bir sorgu Ctrl+C ile durur.
- SQL sorgusu `;` ile biter. Enter'dan sonra imleç yeni satıra geçiyorsa sorgunun sonuna `;` yazıp Enter'a basıyorsunuz.

## Hazırlık

Terminalde:

```
make oturum N=02
make sql
```

DuckDB'de:

```
.read oturumlar/02/hazirlik.sql
```

Son satır `HAZIR: ham_ocak 17.283.355 satır, bronze tablosu 34.241.461 satır` yazar. Tablolar doğruysa dosya birkaç saniyede biter. Eksik tablo ya da iki kez yüklenmiş dosya varsa dosya onu düzeltir ve bir dakika kadar sürer. Son satırda `EKSİK` ya da bir hata görürseniz o satırı sohbete kopyalıyorsunuz.

## Blok 1 | SQL'in temeli

Amaç: aylık hat raporunun sorusunu SQL'le cevaplamak. Bir satır tek bir yolculuk değil, bir yolculuk sayısı taşır; rapor bu yüzden satırları saymaz, `number_of_passage` kolonunu toplar. `WHERE` satırları süzer: metin tek tırnakla, tarih `DATE '2024-01-03'` biçiminde ve değer verideki yazılışıyla yazılır. `GROUP BY` her grup için bir satır bırakır; `SELECT`'te toplanmayan kolon `GROUP BY`'da da yazılır.

Örnekler: `.read oturumlar/02/b1_ornekler.sql`

**Uygulama 1: M2'nin en kalabalık günleri (18 dakika)**

- Dosya: `oturumlar/02/u2_1_hat_raporu.sql`
- ① `sum` fonksiyonuna yolculuk sayısını taşıyan kolonun adını yazıyorsunuz.
- ② Sonuçta her gün bir satır olması için satırların gruplanacağı kolonun adını yazıyorsunuz.
- Çalıştırma: `.read oturumlar/02/u2_1_hat_raporu.sql`
- Sohbete: en üstteki gün ve yolculuğu.
- İleri görev: dosyanın sonundaki sorgu kullandığınız bir hattın en kalabalık günlerini gösterir. `/*` ve `*/` satırlarını silip ③ numaralı boşluğa hattın kodunu tek tırnak içinde yazıyorsunuz: `'M4'`, `'MARMARAY'`, `'34'`.

## Blok 2 | Window fonksiyonları

Amaç: tuhaf bir günü rapora girmeden yakalamak. Bir sayı tek başına doğrulanamaz; geçen haftanın aynı günüyle karşılaştırılır, çünkü hafta içi ile hafta sonu çok farklıdır. Window fonksiyonları bu karşılaştırmayı bütün günler için tek sorguda yapar.

Örnekler: `.read oturumlar/02/b2_ornekler.sql`

**Uygulama 2: geçen haftayla karşılaştırma (18 dakika)**

- Dosya: `oturumlar/02/u2_2_gecen_hafta.sql`
- ① `lag` fonksiyonuna bir hafta önceki günün kaç satır yukarıda olduğunu yazıyorsunuz.
- ② Sonucu en büyük farka göre sıralayan kolonun adını yazıyorsunuz.
- Çalıştırma: `.read oturumlar/02/u2_2_gecen_hafta.sql`
- Sohbete: en üstteki gün ve fark.
- İleri görev: dosyanın sonundaki sorgu farkı yüzde olarak gösterir. `/*` ve `*/` satırlarını silip ③ numaralı boşluğu dolduruyorsunuz.

## Blok 3 | Tekrar eden veri

Amaç: raporu şişiren fazlalığı çıkarmak, gerçek yolculuğu silmeden. Bu veride her kolonu aynı satır çoğu zaman ayrı bir yolculuktur; `DISTINCT` bu satırları da siler. Tekrar satırdan değil günden anlaşılır: iki kez gelen günün satır sayısı geçen haftanın iki katıdır.

Örnekler: `.read oturumlar/02/b3_ornekler.sql`

**Uygulama 3: tekrar gönderilen günler (18 dakika)**

- Dosya: `oturumlar/02/u2_3_tekrar_gunu.sql`
- Önce yalnızca ① numaralı boşluğu dolduruyorsunuz: Uygulama 2'deki sayı. Dosyayı kaydedip çalıştırıyorsunuz. Adım 1 tekrar gönderilen günleri gösterir, ardından dosya ② numaralı boşlukta durur.
- ② numaralı boşluğa Adım 1'in bulduğu Şubat gününü `YYYY-AA-GG` biçiminde yazıyorsunuz. Dosyayı kaydedip yeniden çalıştırıyorsunuz.
- Çalıştırma: `.read oturumlar/02/u2_3_tekrar_gunu.sql`
- Sohbete: Şubat'taki gün ve o günün düzeltilmiş yolculuğu.
- İleri görev: dosyanın sonundaki sorgu Mart dosyasındaki tekrar gönderilen günü bulur. `/*` ve `*/` satırlarını silip ③ numaralı boşluğa Mart dosyasının adını yazıyorsunuz.

## Ödev (30 Kasım Pazartesi'ye kadar, 60-90 dakika)

Amaç: aylık hat raporunun okuyacağı ilk silver tablosunu ve platformun ikinci kaynağı olan trafik verisinin bronze tablosunu kurmak.

- `sql/bronze/trafik.sql`: trafik verisinin Ocak dosyasını bronze katmanına yükler. İki boşluk: tarih kolonunun adı ve dosyanın adı.
- `sql/silver/toplu_ulasim.sql`: ilk silver tablosunu kurar; parça satırları toplar ve tekrar gönderilen günleri ikiye böler. İki boşluk: tarih kolonu ve Şubat'ta tekrar gönderilen gün.
- İki dosya DuckDB'de `.read` ile çalışır. Kontrol için DuckDB'den `.quit` ile çıkıp terminalde `make odev-kontrol N=02` yazıyorsunuz.
- Adımların tamamı ve teslim ödev belgesinde anlatılır.

## Ortam çalışmazsa

Uygulamalar eğitmen ekranından izlenir ve aynı dosyalar oturumdan sonra çalıştırılır.
