📋 Projenin Amacı ve Yöntemi
Türkiye'de e-sporun başlangıçta olumsuz olan algısının, zamanla nasıl bir evrim geçirdiğini veriye dayalı olarak incelemek hedeflenmiştir. Bu amaçla, aşağıdaki yöntemler ve teknolojiler kullanılmıştır:



Yöntem: Metin Madenciliği, İçerik Analizi, Duygu Analizi.


Programlama Dili: Analizler, büyük veri setlerini etkin bir şekilde işleyebilme kabiliyeti nedeniyle R programlama dili ve RStudio ortamında gerçekleştirilmiştir.

🛠️ Kullanılan Teknolojiler ve Kütüphaneler
Programlama Dili: R

API'lar:


YouTube Data API v3: Yorum verilerini çekmek için kullanıldı.


Google Cloud Natural Language API: Yorumların duygu analizini (pozitif, negatif, nötr) yapmak için kullanıldı.


Temel R Kütüphaneleri:

Veri Manipülasyonu: 

dplyr , 

stringr , 

tm 

Görselleştirme: 

ggplot2 , 

wordcloud , 

RColorBrewer 

API İletişimi: 

httr 

🚀 Proje Adımları
Proje, baştan sona aşağıdaki adımlar izlenerek tamamlanmıştır:


Veri Çekme: Belirlenen bir YouTube videosundan, YouTube API kullanılarak yorumlar R ortamına çekildi.

Veri Temizleme: Çekilen metin verileri; linkler, noktalama işaretleri ve sayılar gibi analiz için gürültü yaratacak unsurlardan arındırıldı. Tüm metin küçük harfe çevrildi.


Metin İşleme: Temizlenen yorumlar kelimelere ayrıştırıldı ve analiz sonucunu yanıltabilecek "ve", "gibi", "ama" gibi anlamsal değeri düşük "Stop Words" (etkisiz kelimeler) özel bir liste kullanılarak metinden çıkarıldı.

Analiz ve Görselleştirme:


Frekans Analizi: En çok tekrar eden kelimeler belirlendi ve bir çubuk grafiği ile görselleştirildi.


Kelime Bulutu: En sık kullanılan kelimelerle bir kelime bulutu oluşturuldu.


Duygu Analizi: Google Cloud API ile her bir yorum pozitif, negatif veya nötr olarak sınıflandırıldı ve sonuçlar bir grafik üzerinde gösterildi.


📊 Bulgular ve Sonuçlar
Yapılan analizler sonucunda toplam 

3,063 yorum incelenmiştir.

Duygu Analizi Sonuçları:

✅ 

Pozitif: 2,302 Yorum (%75.2) 

❌ 

Negatif: 451 Yorum (%14.7) 

➖ 

Nötr: 30 Yorum (%1) 


Frekans Analizi Sonuçları: Yorumlarda en çok tekrar eden kelimelerin "spor", "oyun", "güzel" ve "lol" olduğu tespit edilmiştir.

Elde edilen bulgular, Türkiye'de e-spora yönelik genel algının, başlangıçtaki olumsuz yargıların aksine, günümüzde büyük ölçüde 

pozitif olduğunu göstermektedir.


🖼️ Görselleştirmeler
(Bu kısma kendi oluşturduğunuz görselleri images adında bir klasör açıp içine yükledikten sonra ekleyebilirsiniz.)

En Çok Tekrar Eden 20 Kelime

Duygu Analizi Sonuçları

Kelime Bulutu

⚙️ Kurulum ve Çalıştırma
Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

Bu depoyu bilgisayarınıza klonlayın.

R ve RStudio'nun bilgisayarınızda kurulu olduğundan emin olun.

Analiz script'ini (.R dosyası) çalıştırmadan önce gerekli kütüphaneleri yüklemek için aşağıdaki komutları R konsolunda çalıştırın:

R

install.packages(c("plyr", "dplyr", "RColorBrewer", "stringr", "text", "wordcloud", "ggplot2", "httr", "tm", "googleLanguager", "tidytext"))
Not: Proje, YouTube ve Google Cloud API anahtarları ile çalışmaktadır. Kendi API anahtarlarınızı kod içerisindeki ilgili alanlara eklemeniz gerekmektedir.

📜 Lisans
Bu proje, MIT Lisansı ile lisanslanmıştır.
