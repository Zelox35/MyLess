class DetailedQuizResult {
  final int questionIndex;
  final String question;
  final String? selectedOption;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  DetailedQuizResult({
    required this.questionIndex,
    required this.question,
    required this.selectedOption,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  factory DetailedQuizResult.fromJson(Map<String, dynamic> json) {
    return DetailedQuizResult(
      questionIndex: json['question_index'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      selectedOption: json['selected_option'] as String?,
      correctAnswer: json['correct_answer'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class QuizEvaluation {
  final bool success;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int score;
  final List<DetailedQuizResult> detailedResults;
  final String recommendations;

  QuizEvaluation({
    required this.success,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.score,
    required this.detailedResults,
    required this.recommendations,
  });

  factory QuizEvaluation.fromJson(Map<String, dynamic> json) {
    return QuizEvaluation(
      success: json['success'] as bool? ?? false,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
      wrongCount: json['wrong_count'] as int? ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      detailedResults: (json['detailed_results'] as List<dynamic>?)
              ?.map((e) => DetailedQuizResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations: json['recommendations'] as String? ??
          'Eksik konularınızı pekiştirmek için notlarınızı tekrar gözden geçirmeniz önerilir.',
    );
  }
}
