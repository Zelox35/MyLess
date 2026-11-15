class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String course;
  final String topic;
  bool isLearned;

  // SM-2 Aralıklı Tekrar Parametreleri
  int repetitions;
  int interval; // gün cinsinden
  double easeFactor;
  DateTime nextReviewDate;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.course,
    required this.topic,
    this.isLearned = false,
    this.repetitions = 0,
    this.interval = 1,
    this.easeFactor = 2.5,
    DateTime? nextReviewDate,
  }) : nextReviewDate = nextReviewDate ?? DateTime.now();

  // SM-2 Algoritması ile Güncelleme
  // quality: 0-5 (0: Hiç hatırlamadım, 3: Zorlandım, 4: İyi, 5: Çok Kolay)
  void applySm2(int quality) {
    if (quality < 3) {
      repetitions = 0;
      interval = 1;
      isLearned = false;
    } else {
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions++;
      isLearned = true;
    }

    // Ease Factor güncellemesi
    easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) {
      easeFactor = 1.3;
    }

    nextReviewDate = DateTime.now().add(Duration(days: interval));
  }

  bool get isDueToday {
    final now = DateTime.now();
    return nextReviewDate.isBefore(now) ||
        (nextReviewDate.year == now.year &&
            nextReviewDate.month == now.month &&
            nextReviewDate.day == now.day);
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      course: json['course'] as String? ?? 'Genel',
      topic: json['topic'] as String? ?? '',
      isLearned: json['is_learned'] as bool? ?? false,
      repetitions: json['repetitions'] as int? ?? 0,
      interval: json['interval'] as int? ?? 1,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
      nextReviewDate: json['next_review_date'] != null
          ? DateTime.tryParse(json['next_review_date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'course': course,
      'topic': topic,
      'is_learned': isLearned,
      'repetitions': repetitions,
      'interval': interval,
      'ease_factor': easeFactor,
      'next_review_date': nextReviewDate.toIso8601String(),
    };
  }
}
