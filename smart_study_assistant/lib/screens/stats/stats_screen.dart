import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/quiz_question.dart';
import '../quiz/practice_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Örnek istatistik verileri
  final int _streakDays = 7;
  final int _totalQuestions = 142;
  final int _correctAnswers = 109;
  final int _studyHours = 38;
  final int _notesSummarized = 24;

  final List<Map<String, dynamic>> _courseStats = [
    {
      'name': 'Mobil Programlama',
      'code': 'BIL401',
      'color': const Color(0xFF0284C7),
      'accuracy': 0.88,
      'questions': 48,
      'hours': 14,
      'icon': Icons.flutter_dash,
    },
    {
      'name': 'Yapay Zeka',
      'code': 'BIL302',
      'color': const Color(0xFF7C3AED),
      'accuracy': 0.72,
      'questions': 36,
      'hours': 10,
      'icon': Icons.psychology_rounded,
    },
    {
      'name': 'Veri Tabanı',
      'code': 'BIL204',
      'color': const Color(0xFF059669),
      'accuracy': 0.65,
      'questions': 32,
      'hours': 8,
      'icon': Icons.storage_rounded,
    },
    {
      'name': 'Yazılım Mimarisi',
      'code': 'BIL405',
      'color': const Color(0xFFD97706),
      'accuracy': 0.80,
      'questions': 26,
      'hours': 6,
      'icon': Icons.architecture_rounded,
    },
  ];

  final List<Map<String, dynamic>> _weeklyActivity = [
    {'day': 'Pzt', 'hours': 2.5, 'questions': 20},
    {'day': 'Sal', 'hours': 1.0, 'questions': 10},
    {'day': 'Çar', 'hours': 3.0, 'questions': 28},
    {'day': 'Per', 'hours': 2.0, 'questions': 18},
    {'day': 'Cum', 'hours': 4.0, 'questions': 35},
    {'day': 'Cmt', 'hours': 1.5, 'questions': 14},
    {'day': 'Paz', 'hours': 0.5, 'questions': 5},
  ];

  final List<String> _strongTopics = [
    'Flutter Widgets', 'SQL JOIN', 'OOP Prensipleri', 'API Entegrasyonu'
  ];
  final List<String> _weakTopics = [
    'Neural Network', 'Design Patterns', 'NoSQL', 'Concurrency'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _overallAccuracy => _correctAnswers / _totalQuestions;
  double get _maxActivityHours =>
      _weeklyActivity.map((e) => e['hours'] as double).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakCard(),
                  const SizedBox(height: 16),
                  _buildEmailReportBanner(),
                  const SizedBox(height: 16),
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildAccuracySection(),
                  const SizedBox(height: 20),
                  _buildWeeklyActivity(),
                  const SizedBox(height: 20),
                  _buildCoursePerformance(),
                  const SizedBox(height: 20),
                  _buildTopicsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bar_chart_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İstatistiklerim',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Öğrenme yolculuğunu takip et',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_streakDays Günlük Seri!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Her gün çalışmaya devam ediyorsun 🎉',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Column(
            children: [
              Text('En İyi',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
              Text('12 gün',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailReportBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF0284C7), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Başarı Raporu (Brevo)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimaryColor),
                ),
                Text(
                  'Her Pazartesi 09:00 otomatik e-posta',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📧 Rapor hazırlanıyor ve Brevo SMTP ile gönderiliyor...'),
                  duration: Duration(seconds: 2),
                ),
              );
              await N8nApiService.sendWeeklyReport(
                email: 'ogrenci@universite.edu.tr',
                stats: {'streak': _streakDays, 'questions': _totalQuestions},
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ E-posta raporu başarıyla ulaştırıldı!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Şimdi Al', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final stats = [
      {
        'label': 'Toplam Soru',
        'value': '$_totalQuestions',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF4F46E5),
        'sub': '${(_overallAccuracy * 100).toInt()}% doğru',
      },
      {
        'label': 'Çalışma Saati',
        'value': '$_studyHours s',
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFF059669),
        'sub': 'Bu ay',
      },
      {
        'label': 'Not Özetlendi',
        'value': '$_notesSummarized',
        'icon': Icons.summarize_rounded,
        'color': const Color(0xFF7C3AED),
        'sub': 'Toplam',
      },
      {
        'label': 'Doğru Cevap',
        'value': '$_correctAnswers',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF0284C7),
        'sub': 'Toplam',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat['icon'] as IconData,
                        color: stat['color'] as Color, size: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: stat['color'] as Color,
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    stat['sub'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMutedColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccuracySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Genel Başarı Oranı',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _overallAccuracy,
                        strokeWidth: 10,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_overallAccuracy * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Text('Başarı',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _AccuracyRow(
                      label: 'Doğru',
                      count: _correctAnswers,
                      total: _totalQuestions,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(height: 10),
                    _AccuracyRow(
                      label: 'Yanlış',
                      count: _totalQuestions - _correctAnswers,
                      total: _totalQuestions,
                      color: AppTheme.errorColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bu Hafta Aktivite',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor)),
          const SizedBox(height: 4),
          const Text('Günlük çalışma süreleri',
              style: TextStyle(fontSize: 12, color: AppTheme.textMutedColor)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weeklyActivity.map((day) {
              final ratio = (day['hours'] as double) / _maxActivityHours;
              final isToday = day['day'] == 'Cum';
              return _ActivityBar(
                day: day['day'] as String,
                ratio: ratio,
                hours: day['hours'] as double,
                questions: day['questions'] as int,
                isToday: isToday,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePerformance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ders Bazlı Performans',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor)),
          const SizedBox(height: 16),
          ..._courseStats.map((course) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CourseStatRow(course: course),
              )),
        ],
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Konu Analizi',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.thumb_up_rounded,
                            color: AppTheme.successColor, size: 16),
                        SizedBox(width: 6),
                        Text('Güçlü Konular',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._strongTopics.map((topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(topic,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.w500)),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build_rounded,
                            color: AppTheme.errorColor, size: 16),
                        SizedBox(width: 6),
                        Text('Çalışılacak',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._weakTopics.map((topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PracticeScreen(
                                    title: 'Hedefli Pratik: $topic',
                                    wrongQuestions: [
                                      QuizQuestion(
                                        question: '$topic konusunda karşılaşılan temel problem ve çözüm nedir?',
                                        options: [
                                          'Sistematik analiz ve doğru mimari prensiplerin uygulanması',
                                          'Tüm gereksinimleri tek bir sınıfta toplamak',
                                          'Veri tabanı indekslerini tamamen kaldırmak',
                                          'State yönetimini devre dışı bırakmak',
                                        ],
                                        correctAnswer: 'Sistematik analiz ve doğru mimari prensiplerin uygulanması',
                                        explanation: '$topic konusunda doğru prensipler uygulanarak performans ve güvenilirlik sağlanır.',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(topic,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.errorColor,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 8, color: AppTheme.errorColor),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccuracyRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _AccuracyRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondaryColor)),
            Text('$count soru',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final String day;
  final double ratio;
  final double hours;
  final int questions;
  final bool isToday;

  const _ActivityBar({
    required this.day,
    required this.ratio,
    required this.hours,
    required this.questions,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$day: $hours saat, $questions soru'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isToday)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${hours}s',
                style: const TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 28,
            height: (ratio * 80).clamp(6.0, 80.0),
            decoration: BoxDecoration(
              gradient: isToday
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.3),
                        AppTheme.primaryColor.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: TextStyle(
              fontSize: 10,
              color: isToday ? AppTheme.primaryColor : AppTheme.textMutedColor,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseStatRow extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseStatRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final accuracy = course['accuracy'] as double;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (course['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(course['icon'] as IconData,
              color: course['color'] as Color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      course['name'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${(accuracy * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: course['color'] as Color),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${course['questions']} soru · ${course['hours']} saat',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textMutedColor),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: accuracy,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      course['color'] as Color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
