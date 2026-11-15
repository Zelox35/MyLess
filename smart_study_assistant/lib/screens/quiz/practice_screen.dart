import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_question.dart';

class PracticeScreen extends StatefulWidget {
  final String title;
  final List<QuizQuestion> wrongQuestions;

  const PracticeScreen({
    super.key,
    required this.title,
    required this.wrongQuestions,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _hasAnswered = false;
  int _correctOnFirstTry = 0;

  // Animasyonlar
  late AnimationController _cardAnimController;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;

  late AnimationController _feedbackAnimController;
  late Animation<double> _feedbackScaleAnim;

  late AnimationController _shakeAnimController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.wrongQuestions);

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOutCubic,
    ));

    _feedbackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackScaleAnim = CurvedAnimation(
      parent: _feedbackAnimController,
      curve: Curves.elasticOut,
    );

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeAnimController);

    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _feedbackAnimController.dispose();
    _shakeAnimController.dispose();
    super.dispose();
  }

  void _onOptionSelected(String option) {
    if (_hasAnswered) return;

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = option == currentQuestion.correctAnswer;

    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      if (isCorrect) {
        _correctOnFirstTry++;
      }
    });

    if (isCorrect) {
      _feedbackAnimController.forward(from: 0.0);
    } else {
      _shakeAnimController.forward(from: 0.0).then((_) {
        _shakeAnimController.reverse();
      });
      _feedbackAnimController.forward(from: 0.0);
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _cardAnimController.reverse().then((_) {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
          _hasAnswered = false;
        });
        _cardAnimController.forward();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pratik Tamamlandı! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tüm eksik soruları gözden geçirdin.\nİlk denemede doğru: $_correctOnFirstTry / ${_questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondaryColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Harika, Devam Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yanlışları Tekrar Çöz')),
        body: const Center(
          child: Text('Tekrar edilecek yanlış soru bulunamadı! 🎉'),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final isCorrect = _selectedOption == currentQuestion.correctAnswer;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Pratik Modu (Anında Geri Bildirim)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.borderColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            minHeight: 4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _cardFadeAnim,
          child: SlideTransition(
            position: _cardSlideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Soru Numarası & Rozet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 15,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Yanlış Soru ${_currentIndex + 1} / ${_questions.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '⚡ Pratik Modu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Soru Metni Kartı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Seçenekler
                ...currentQuestion.options.map((option) {
                  final isSelected = _selectedOption == option;
                  final isOptionCorrect = option == currentQuestion.correctAnswer;

                  Color optionBg = Colors.white;
                  Color optionBorder = AppTheme.borderColor;
                  Color optionTextColor = AppTheme.textPrimaryColor;
                  IconData? trailingIcon;
                  Color? trailingIconColor;

                  if (_hasAnswered) {
                    if (isOptionCorrect) {
                      optionBg = AppTheme.successColor.withValues(alpha: 0.12);
                      optionBorder = AppTheme.successColor;
                      optionTextColor = const Color(0xFF065F46);
                      trailingIcon = Icons.check_circle_rounded;
                      trailingIconColor = AppTheme.successColor;
                    } else if (isSelected) {
                      optionBg = AppTheme.errorColor.withValues(alpha: 0.1);
                      optionBorder = AppTheme.errorColor;
                      optionTextColor = const Color(0xFF991B1B);
                      trailingIcon = Icons.cancel_rounded;
                      trailingIconColor = AppTheme.errorColor;
                    }
                  } else if (isSelected) {
                    optionBg = AppTheme.primaryColor.withValues(alpha: 0.08);
                    optionBorder = AppTheme.primaryColor;
                  }

                  return AnimatedBuilder(
                    animation: _shakeAnimController,
                    builder: (context, child) {
                      final offset = (isSelected && !isCorrect && _hasAnswered)
                          ? Offset(_shakeAnim.value, 0)
                          : Offset.zero;
                      return Transform.translate(
                        offset: offset,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _onOptionSelected(option),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: optionBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: optionBorder, width: 1.5),
                            boxShadow: isSelected ? AppTheme.softShadow : [],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: optionTextColor,
                                  ),
                                ),
                              ),
                              if (trailingIcon != null)
                                Icon(
                                  trailingIcon,
                                  color: trailingIconColor,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Anında Geri Bildirim ve Açıklama Paneli
                if (_hasAnswered) ...[
                  const SizedBox(height: 8),
                  ScaleTransition(
                    scale: _feedbackScaleAnim,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppTheme.successLight
                            : AppTheme.errorLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCorrect
                              ? AppTheme.successColor.withValues(alpha: 0.3)
                              : AppTheme.errorColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect
                                    ? Icons.thumb_up_rounded
                                    : Icons.lightbulb_rounded,
                                color: isCorrect
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCorrect
                                    ? 'Tebrikler! Doğru Cevap 🎯'
                                    : 'Açıklama & Doğru Cevap',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isCorrect
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.explanation,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: isCorrect
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF991B1B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sonraki Soru Butonu
                  Container(
                    decoration: BoxDecoration(
                      gradient: isCorrect
                          ? AppTheme.successGradient
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isCorrect
                                  ? AppTheme.successColor
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        _currentIndex < _questions.length - 1
                            ? 'Sonraki Yanlış Soru'
                            : 'Pratiği Bitir',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
