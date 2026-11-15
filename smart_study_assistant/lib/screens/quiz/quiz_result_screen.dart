import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_evaluation.dart';
import '../../models/quiz_question.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';
import 'quiz_screen.dart';
import 'practice_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final String quizTitle;
  final QuizEvaluation evaluation;
  final List<QuizQuestion> questions;

  const QuizResultScreen({
    super.key,
    required this.quizTitle,
    required this.evaluation,
    required this.questions,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isGeneratingFocusQuiz = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<QuizQuestion> get _wrongQuestions {
    final list = <QuizQuestion>[];
    for (final res in widget.evaluation.detailedResults) {
      if (!res.isCorrect && res.questionIndex < widget.questions.length) {
        list.add(widget.questions[res.questionIndex]);
      }
    }
    return list;
  }

  Future<void> _generateFocusTopicQuiz() async {
    setState(() => _isGeneratingFocusQuiz = true);
    try {
      final questions = await N8nApiService.generateQuiz(
        content: 'Eksik konular ve öneriler: ${widget.evaluation.recommendations}',
        count: 5,
        difficulty: 'medium',
        focusTopic: 'Eksik Konu Tekrarı',
      );

      if (!mounted) return;
      setState(() => _isGeneratingFocusQuiz = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            quizTitle: '🎯 Odaklı Pekiştirme Testi (focusTopic)',
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingFocusQuiz = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test üretilemedi: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.evaluation.score;
    final isPass = score >= 50;
    final isExcellent = score >= 80;
    final wrongList = _wrongQuestions;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sınav Değerlendirme Raporu'),
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Skor & Başarı Durumu Hero Kartı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderColor),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    children: [
                      // Skor Çemberi
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 124,
                            height: 124,
                            child: CircularProgressIndicator(
                              value: widget.evaluation.totalQuestions > 0
                                  ? widget.evaluation.correctCount /
                                      widget.evaluation.totalQuestions
                                  : 0,
                              strokeWidth: 10,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isExcellent
                                    ? AppTheme.successColor
                                    : (isPass
                                        ? AppTheme.warningColor
                                        : AppTheme.errorColor),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '%$score',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const Text(
                                'Başarı Skoru',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Durum Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isExcellent
                                  ? AppTheme.successColor
                                  : (isPass
                                      ? AppTheme.warningColor
                                      : AppTheme.errorColor))
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isExcellent
                              ? '🏆 Mükemmel Başarı!'
                              : (isPass
                                  ? '📈 İyi İlerleme, Konuları Pekiştirin'
                                  : '⚠️ Konu Tekrarı Önerilir'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isExcellent
                                ? AppTheme.successColor
                                : (isPass
                                    ? AppTheme.warningColor
                                    : AppTheme.errorColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // İstatistik Sayaçları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            label: 'Doğru',
                            count: widget.evaluation.correctCount,
                            color: AppTheme.successColor,
                            icon: Icons.check_circle_rounded,
                          ),
                          Container(
                              width: 1, height: 44, color: AppTheme.dividerColor),
                          _buildStatItem(
                            label: 'Yanlış',
                            count: widget.evaluation.wrongCount,
                            color: AppTheme.errorColor,
                            icon: Icons.cancel_rounded,
                          ),
                          Container(
                              width: 1, height: 44, color: AppTheme.dividerColor),
                          _buildStatItem(
                            label: 'Toplam Soru',
                            count: widget.evaluation.totalQuestions,
                            color: AppTheme.primaryColor,
                            icon: Icons.help_outline_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // YANLIŞLARI TEKRAR ÇÖZ (Flutter PracticeScreen) BUTONU
                if (wrongList.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeScreen(
                              title: widget.quizTitle,
                              wrongQuestions: wrongList,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.fitness_center_rounded,
                          color: Colors.white, size: 22),
                      label: Text(
                        'Yanlışları Tekrar Çöz (${wrongList.length} Soru - Pratik Modu)',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // EKSİK KONUDAN YENİ TEST ÜRET (focusTopic) BUTONU
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.aiBadgeGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        _isGeneratingFocusQuiz ? null : _generateFocusTopicQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: _isGeneratingFocusQuiz
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 20),
                    label: Text(
                      _isGeneratingFocusQuiz
                          ? 'Odaklı Test Hazırlanıyor...'
                          : '🎯 Eksik Konudan Yeni Test Üret (focusTopic)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Yapay Zekâ Kişiselleştirilmiş Tavsiye Bölümü
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.08),
                        AppTheme.accentColor.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.25)),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppTheme.aiBadgeGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.psychology_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ollama Kişisel Çalışma Önerisi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Yanlış cevaplarınıza göre özel olarak üretildi',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          widget.evaluation.recommendations,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Soru Analizi & Doğru Cevaplar
                const Row(
                  children: [
                    Icon(Icons.checklist_rounded,
                        color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Soru Bazında Detaylı Analiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Soru Listesi
                ...widget.evaluation.detailedResults.map((result) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: result.isCorrect
                            ? AppTheme.successColor.withValues(alpha: 0.3)
                            : AppTheme.errorColor.withValues(alpha: 0.3),
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (result.isCorrect
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                result.isCorrect
                                    ? Icons.check
                                    : Icons.close_rounded,
                                color: result.isCorrect
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Soru ${result.questionIndex + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: result.isCorrect
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          result.question,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sizin Cevabınız: ${result.selectedOption ?? "Boş"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: result.isCorrect
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!result.isCorrect) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Doğru Cevap: ${result.correctAnswer}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Açıklama: ${result.explanation}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondaryColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Eylem Butonları
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                quizTitle: widget.quizTitle,
                                questions: widget.questions,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('Tekrar Çöz'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          icon: const Icon(Icons.home_rounded,
                              size: 18, color: Colors.white),
                          label: const Text(
                            'Ana Sayfa',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
