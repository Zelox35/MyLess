# Akıllı Ders ve Soru Asistanı — API Veri Sözleşmesi (Data Contract)

Bu sözleşme, **Flutter mobil uygulaması** ile **n8n Webhook uç noktaları** arasındaki JSON veri formatlarını ve haberleşme kurallarını belirler.

---

## Genel Kurallar
1. Tüm istekler `POST` metodunu kullanır ve `Content-Type: application/json` başlığıyla gönderilir.
2. Tüm yanıtlar standart olarak `success` (boolean) alanını içerir.
3. Hata durumlarında HTTP durum koduna ek olarak `{ "success": false, "error": "Hata detayı" }` döndürülür.
4. Ollama (`qwen2.5:3b`), `format: "json"` desteğiyle çağrılarak bozuk JSON üretim riski engellenir.

---

## 1. Soru-Cevap (Q&A)

- **Uç Nokta:** `POST http://localhost:5678/webhook/chat`
- **Açıklama:** Öğrencinin derse veya konuya özel sorularını Ollama üzerinden yanıtlar.

### İstek (Request)
```json
{
  "course": "Mobil Programlama",
  "message": "Flutter'da Stateful ve Stateless widget arasındaki fark nedir?"
}
```

### Başarılı Yanıt (Response)
```json
{
  "success": true,
  "reply": "StatelessWidget, durumu zaman içinde değişmeyen arayüz bileşenleri için kullanılırken; StatefulWidget, kullanıcı etkileşimi veya veri güncellemesiyle dinamik olarak değişen durumları (state) yönetmek için kullanılır.",
  "course": "Mobil Programlama"
}
```

---

## 2. Ders Notu Özetleme (Summarize)

- **Uç Nokta:** `POST http://localhost:5678/webhook/summarize`
- **Açıklama:** Yüklenen ders notunu analiz ederek yapılandırılmış özet ve anahtar noktaları çıkarır.

### İstek (Request)
```json
{
  "title": "Flutter Mimarisi",
  "content": "Flutter, Google tarafından geliştirilen açık kaynaklı bir UI yazılım geliştirme kitidir. Tek bir kod tabanından Android, iOS, Linux, macOS, Windows ve web için yerel olarak derlenmiş uygulamalar oluşturmak için kullanılır. Dart dilini kullanır..."
}
```

### Başarılı Yanıt (Response)
```json
{
  "success": true,
  "summary": "Flutter, Google tarafından geliştirilen ve Dart diliyle tek bir kod tabanından çoklu platformda çalışan uygulamalar geliştirmeyi sağlayan modern bir UI kitidir.",
  "bullet_points": [
    "Tek bir kod tabanından çoklu platform derleme desteği",
    "Dart programlama dilinin reaktif yapısı",
    "Zengin widget ağacı ve yüksek performans"
  ],
  "key_topics": [
    "Flutter",
    "Dart",
    "Çoklu Platform",
    "Widget Ağacı"
  ]
}
```

---

## 3. Otomatik Test Oluşturma (Generate Quiz)

- **Uç Nokta:** `POST http://localhost:5678/webhook/generate-quiz`
- **Açıklama:** Ders notu içeriğinden **en az 5 adet** çoktan seçmeli, 4 seçenekli soru üretir.
- **Şema Standardı:** Case Study dokümanı Sayfa 2, Madde 6 ile birebir uyumludur.

### İstek (Request)
```json
{
  "content": "Flutter, Dart dilini kullanan bir framework'tür. State yönetimi için Provider, Riverpod, Bloc gibi çözümler kullanılır...",
  "question_count": 5
}
```

### Başarılı Yanıt (Response)
```json
{
  "success": true,
  "questions": [
    {
      "question": "Flutter hangi programlama dilini kullanır?",
      "options": ["Java", "Dart", "Python", "C#"],
      "correct_answer": "Dart",
      "explanation": "Flutter, Google tarafından geliştirilen Dart programlama dilini kullanır."
    },
    {
      "question": "Aşağıdakilerden hangisi Flutter'da yaygın kullanılan bir state management kütüphanesidir?",
      "options": ["Bloc", "Django", "Spring", "Angular"],
      "correct_answer": "Bloc",
      "explanation": "Bloc (Business Logic Component), Flutter'da durum yönetimi için sıkça tercih edilen bir kütüphanedir."
    }
  ]
}
```

> **Önemli Not:** Mobil arayüzde doğru cevap (`correct_answer`) ve açıklama (`explanation`) öğrenci testi tamamlayıp gönderene kadar gizli tutulmalıdır.

---

## 4. Performans Değerlendirme & Çalışma Önerisi (Evaluate Quiz)

- **Uç Nokta:** `POST http://localhost:5678/webhook/evaluate-quiz`
- **Açıklama:** Öğrencinin test cevaplarını doğrular, başarı oranını hesaplar ve yanlış yapılan sorular için Ollama'dan kişiselleştirilmiş eksik konu önerisi üretir.

### İstek (Request)
```json
{
  "questions": [
    {
      "question": "Flutter hangi programlama dilini kullanır?",
      "options": ["Java", "Dart", "Python", "C#"],
      "correct_answer": "Dart",
      "explanation": "Flutter, Dart dilini kullanır."
    },
    {
      "question": "Flutter'da widget'lar hangi iki temel gruba ayrılır?",
      "options": ["Static - Dynamic", "Stateless - Stateful", "Local - Global", "Single - Multiple"],
      "correct_answer": "Stateless - Stateful",
      "explanation": "Flutter'da widget'lar temel olarak StatelessWidget ve StatefulWidget olarak ikiye ayrılır."
    }
  ],
  "user_answers": [
    {
      "question_index": 0,
      "selected_option": "Java"
    },
    {
      "question_index": 1,
      "selected_option": "Stateless - Stateful"
    }
  ]
}
```

### Başarılı Yanıt (Response)
```json
{
  "success": true,
  "total_questions": 2,
  "correct_count": 1,
  "wrong_count": 1,
  "score": 50.0,
  "detailed_results": [
    {
      "question": "Flutter hangi programlama dilini kullanır?",
      "selected_option": "Java",
      "correct_answer": "Dart",
      "is_correct": false,
      "explanation": "Flutter, Dart dilini kullanır."
    },
    {
      "question": "Flutter'da widget'lar hangi iki temel gruba ayrılır?",
      "selected_option": "Stateless - Stateful",
      "correct_answer": "Stateless - Stateful",
      "is_correct": true,
      "explanation": "Flutter'da widget'lar temel olarak StatelessWidget ve StatefulWidget olarak ikiye ayrılır."
    }
  ],
  "recommendations": "Flutter programlama dili temelleri konusunda eksiğiniz bulunuyor. Dart sözdizimi, nesne yönelimli programlama ve Flutter'ın Dart ile derlenme mimarisine tekrar göz atmanız sınav başarınızı artıracaktır."
}
```
