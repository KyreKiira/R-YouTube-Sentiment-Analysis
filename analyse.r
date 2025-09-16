# Kullanılan Kütüphaneler
install.packages("plyr")
install.packages("dplyr")
install.packages("RColorBrewer")
install.packages("stringr")
install.packages("text")
install.packages("wordcloud")
install.packages("ggplot2")
install.packages("httr")
install.packages("tm")
install.packages("googleLanguageR")

# Kütüphaneleri kullanıma hazır hale getiren kodlar
library(plyr)
library(dplyr)
library(RColorBrewer)
library(stringr)
library(text)
library(tidytext)
library(wordcloud)
library(ggplot2)
library(httr)
library(tm)
library(googleLanguageR)



# YouTube API ayarları
api_key_youtube <- "YOUR_API_KEY"
video_id <- "gqKfG0izuwI"

# Fonksiyon: Google Cloud Natural Language API ile duygu analizi yap
analyze_sentiment_google <- function(text) {
  # API anahtarı ve URL'si
  api_key_google <- "YOUR_API_KEY"
  url_google <- "https://language.googleapis.com/v1/documents:analyzeSentiment?key="
  
  # JSON verisi oluştur
  json_data <- list(
    document = list(
      content = text,
      type = "PLAIN_TEXT"
    )
  )
  
  # API çağrısı
  response <- httr::POST(
    url = paste0(url_google, api_key_google),
    body = json_data,
    encode = "json"
  )
  
  # Cevap
  result <- httr::content(response)
  
  if (!is.null(result$documentSentiment)) {
    return(result$documentSentiment$score)
  } else {
    return(NA)
  }
}

# Fonksiyon: YouTube API ile yorumları çek
get_youtube_comments <- function(api_key_youtube, video_id) {
  all_comments_df <- data.frame(Comment = character(), stringsAsFactors = FALSE)
  
  # İlk sayfa için YouTube API isteği oluşturun
  response <- GET(paste0("https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=", video_id, "&key=", api_key_youtube))
  
  # İlk sayfa veriyi al
  comments_data <- content(response, "parsed")
  
  # İlk sayfadaki yorumları veri çerçevesine ekle
  for (i in 1:length(comments_data$items)) {
    comment <- comments_data$items[[i]]$snippet$topLevelComment
    all_comments_df <- rbind(all_comments_df, data.frame(Yorumlar = comment$snippet$textDisplay, stringsAsFactors = FALSE))
  }
  
  # Sayfalar arasında döngü oluşturarak tüm yorumları al
  while ("nextPageToken" %in% names(comments_data)) {
    next_page_token <- comments_data$nextPageToken
    next_page_url <- paste0("https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=", video_id, "&key=", api_key_youtube, "&pageToken=", next_page_token)
    response <- GET(next_page_url)
    comments_data <- content(response, "parsed")
    for (i in 1:length(comments_data$items)) {
      comment <- comments_data$items[[i]]$snippet$topLevelComment
      all_comments_df <- rbind(all_comments_df, data.frame(Yorumlar = comment$snippet$textDisplay, stringsAsFactors = FALSE))
    }
  }
  
  return(all_comments_df)
}

# YouTube yorumlarını çek
youtube_comments_df <- get_youtube_comments(api_key_youtube, video_id)
# Yorumlardan linkleri temizle
youtube_comments_df$Yorumlar <- str_replace_all(youtube_comments_df$Yorumlar, "http\\S+|www\\S+|\\S+\\.com\\S+|\\S+\\.\\S+", "")
# Yorumlardan noktalama işaretlerini kaldır
youtube_comments_df$Yorumlar <- stringr::str_replace_all(youtube_comments_df$Yorumlar, "[[:punct:]]", "")
# Tüm harfleri küçük harfe dönüştür
youtube_comments_df$Yorumlar <- tolower(youtube_comments_df$Yorumlar)
# Sayıları temizle
youtube_comments_df$Yorumlar <- gsub("\\d+", "", youtube_comments_df$Yorumlar)

# Temizlenmiş, küçük harfe dönüştürülmüş ve sayıları temizlenmiş yorumları listele
print(youtube_comments_df)

# Özel Türkçe stop words listesi tanımla
custom_stopwords <- c("her","değil","abi","bu","biri","yani",
                      "baris","buna","sana","sonu","tüyler","tek",
                      "beni","hakkında","veya","efsane","adam","helal",
                      "göre","oldu","olmak","allah","hatta","adamsın","lütfen",
                      "bunu","sonda","olur","efsaneler","mu","asla","videoyu",    "kendi","yok","büyük","olsun","it","It","it","yine","evet",
                      "ederim","öyle", "hocam", "ve", "gibi", "için", "ama", "şu"   ,"shahshshs","gerçekten","cok","eline","830twyao2rs","www","com",
                      "ben","çok","bne","bir","hiç","de","ya","en","hep","hem","ile",
                      "3m34s","ilj","ılk","ilj","ilk","1","br","daha","39","da",
                      "daha","a","3","href","tüylerim","It","ise","ölmez","  süleymanoğlu","değildir","seni","www.youtube.com","t",
                      "tl","ki","bi","i","mi","o","d","mı","zaten","falan","eğer"
                      ,"diye","bile", "barış","video","diken","ne","var","sen",
                      "kadar","sadece","bence","naim","never","die","saat","olarak"
                      ,"olmuş","özcan","of","videonun","şey","k","ıt","senin","be",    "benim","artık","çünkü","böyle")  # Kendi ihtiyacınıza göre genişletebilirsiniz


# Yorumlardan özel stop words'leri temizle
youtube_comments_df$Yorumlar <- sapply(youtube_comments_df$Yorumlar, function(comment) {
  words <- unlist(strsplit(comment, " "))
  words <- words[!(words %in% custom_stopwords)]
  cleaned_comment <- paste(words, collapse = " ")
  return(cleaned_comment)
})

# Temizlenmiş yorumları listele
print(youtube_comments_df)


# yorumları parçalayacağımız için bize alan lazım.bunun için alan oluşturalım.
options(max.print = 10000)


# Türkçe stop words'leri temizleme
cleaned_comments_df <- youtube_comments_df %>%
  rename(Comment = Yorumlar) %>%
  mutate(Comment = as.character(Comment)) %>%
  group_by(Comment) %>%
  mutate(
    linenumber = row_number(),
    chapter = cumsum(str_detect(Comment, regex("^chapter [\\divxlc]", ignore_case = TRUE)))
  ) %>%
  unnest_tokens(kelime, Comment) %>%  # "word" sütununu "kelime" olarak değiştirme
  anti_join(data.frame(kelime = custom_stopwords)) %>%

# Elde edilen veri çerçevesini göster
print(cleaned_comments_df)


# Temizlenmiş yorumları sıralama ve sayma
word_count <- cleaned_comments_df %>%
  count(kelime, sort = TRUE) %>%
  rename(tekrar = n)

# Düzenli tabloyu görüntüleme
print(word_count)


dark_colors <- viridisLite::viridis(25, option = "D")
colorful_colors <- RColorBrewer::brewer.pal(12, "Set3")

# İki paleti birleştir
combined_palette <- c(dark_colors, colorful_colors)
mixed_colors <- sample(combined_palette)
# Temizlenmiş yorumlardan kelime bulutu oluştur
wordcloud(words = word_count$kelime, freq = word_count$tekrar, scale = c(3, 1.1), min.freq = 10,
          max.words = 50, random.order = FALSE, colors = mixed_colors)  # "viridis" paletinden 15 renk tonu

# Temizlenmiş yorumlardan kelime frekanslarını hesapla
worsd_count <- cleaned_comments_df %>%
  count(kelime, sort = TRUE) %>%
  rename(tekrar = n)

# En çok tekrar eden 20 kelimeyi seç
top_words <- head(word_count, 20)

# Çubuk grafiğini oluşturma
word_barplot <- ggplot(top_words, aes(x = reorder(kelime, tekrar), y = tekrar)) +
  geom_bar(stat = "identity", col = "red",fill="blue") +
  coord_flip() +  # x ve y eksenlerini yer değiştirme
  labs(title = "En Çok Tekrar Eden 20 Kelime", x = "Kelime", y = "Tekrar Sayısı") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))  # Y eksen etiketlerini küçültme

# Grafiği görüntüleme
print(word_barplot)


# Analiz sonuçlarını görüntüle
print(youtube_comments_df)
# Duygu analizi yap
youtube_comments_df$Sentiment <- as.numeric(sapply(youtube_comments_df$Yorumlar, analyze_sentiment_google))
# NA değerleri kontrol et ve çıkar
youtube_comments_df <- na.omit(youtube_comments_df)
# Negatif, Nötr ve Pozitif sütunlarını oluştur
youtube_comments_df$Duygu <- ifelse(youtube_comments_df$Sentiment < 0, "Negatif", ifelse(youtube_comments_df$Sentiment == 0, "Nötr", "Pozitif"))

# 0'dan büyükse "Pozitif" olarak güncelle
youtube_comments_df$Duygu[youtube_comments_df$Sentiment > 0] <- "Pozitif"

# Duygu sütununu kullanarak bir barplot oluştur
# ggplot ile bir barplot oluştur
ggplot(youtube_comments_df, aes(x = Duygu, fill = Duygu)) +
  geom_bar(stat = "count", width = 0.7, position = position_dodge(width = 0.8), color = "black") +
  labs(title = "Duygu Analizi", x = "Duygu", y = "Frekans") +
  scale_fill_manual(values = c("red", "gray", "green")) +
  theme_minimal() +
  theme(legend.position = "bottom", # Lejantı alt kısma taşı
        axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"), # X-ekseni yazılarını kalınlaştır
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "yellow3"),
        panel.grid.major = element_line(color = "gray", linetype = "dashed"),
        axis.line = element_line(color = "black"),
        legend.text = element_text(face = "bold")) + # Lejant yazılarını kalınlaştır
  guides(fill = guide_legend(title = NULL)) # Lejant başlığını kaldır


