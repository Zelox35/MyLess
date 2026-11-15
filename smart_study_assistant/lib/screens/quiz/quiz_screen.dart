import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_question.dart';
import '../../services/api_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String quizTitle;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.quizTitle,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isEvaluating = false;

  void _selectOption(String option) {
    setState(() {
      _userAnswers[_currentIndex] = option;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Future<void> _submitQuiz() async {
    if (_userAnswers.length < widget.questions.length) {
      final unansweredCount = widget.questions.length - _userAnswers.length;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
              SizedBox(width: 10),
              Text('Cevaplanmamış Sorular Var', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            '$unansweredCount adet soruyu henüz cevaplamadınız. Testi bitirip yapay zekâ değerlendirmesi almak istiyor musunuz?',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Sorulara Dön'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Yine de Bitir'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isEvaluating = true);

    try {
      final evaluation = await N8nApiService.evaluateQuiz(
        questions: widget.questions,
        userAnswers: _userAnswers,
      );

      if (!mounted) return;
      setState(() => _isEvaluating = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            quizTitle: widget.quizTitle,
            evaluation: evaluation,
            questions: widget.questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isEvaluating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text('Çözülecek test sorusu bulunamadı.')),
      );
    }

    final currentQuestion = widget.questions[_currentIndex];
    final selectedOption = _userAnswers[_currentIndex];
    final totalQuestions = widget.questions.length;
    final progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.quizTitle),
      ),
      body: _isEvaluating
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Sınavınız Değerlendiriliyor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ollama yerel yapay zekâ modeli cevaplarınızı analiz ediyor ve eksik olduğunuz konulara özel çalışma tavsiyesi üretiyor...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // İlerleme Barı
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 5,
                ),

                // Soru ve Cevap Durumu Bilgi Çubuğu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Soru ${_currentIndex + 1} / $totalQuestions',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          '${_userAnswers.length} / $totalQuestions İşaretlendi',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Soru ve Seçenekler
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Soru Kartı
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.borderColor),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.5,
                              letterSpacing: -0.3,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Seçenek Kartları
                        ...List.generate(currentQuestion.options.length, (optIdx) {
                          final option = currentQuestion.options[optIdx];
                          final isSelected = selectedOption == option;
                          final optionLetters = ['A', 'B', 'C', 'D', 'E'];
                          final letter = optIdx < optionLetters.length ? optionLetters[optIdx] : '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _selectOption(option),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withValues(alpha: 0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                                    width: isSelected ? 2 : 1.2,
                                  ),
                                  boxShadow: isSelected ? AppTheme.cardShadow : AppTheme.softShadow,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.textPrimaryColor,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppTheme.primaryColor, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Alt Navigasyon Barı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: AppTheme.borderColor)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (_currentIndex > 0)
                          OutlinedButton.icon(
                            onPressed: _previousQuestion,
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text('Önceki'),
                          ),
                        const Spacer(),
                        if (_currentIndex < totalQuestions - 1)
                          ElevatedButton.icon(
                            onPressed: _nextQuestion,
                            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                            label: const Text('Sonraki Soru'),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.successGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _submitQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              icon: const Icon(Icons.check_circle_outline_rounded,
                                  size: 20, color: Colors.white),
                              label: const Text(
                                'Testi Bitir',
                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
