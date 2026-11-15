import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../models/quiz_question.dart';
import '../notes/notes_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../chat/chat_screen.dart';
import '../study_plan/study_plan_screen.dart';
import '../quiz/practice_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Pomodoro
  static const int _pomoDuration = 25 * 60;
  static const int _breakDuration = 5 * 60;
  int _pomodoroSeconds = _pomoDuration;
  bool _pomodoroRunning = false;
  bool _isBreak = false;
  int _pomodoroCount = 0;
  Timer? _pomodoroTimer;

  // Günün sorusu — rotasyonlu
  int _questionOfDayIndex = 0;
  final List<Map<String, String>> _questionsOfDay = [
    {
      'q': 'Flutter\'da Widget ağacı (Widget Tree) ne anlama gelir?',
      'a': 'UI\'ı oluşturan iç içe geçmiş widget\'ların hiyerarşik yapısıdır.',
      'course': 'BIL401',
    },
    {
      'q': 'SQL\'de INNER JOIN ile LEFT JOIN arasındaki fark nedir?',
      'a': 'INNER JOIN yalnızca her iki tabloda eşleşen satırları döndürür; LEFT JOIN sol tablonun tüm satırlarını döndürür.',
      'course': 'BIL204',
    },
    {
      'q': 'Yapay sinir ağlarında "aktivasyon fonksiyonu" ne işe yarar?',
      'a': 'Nöronun çıktısını belirli bir aralığa sıkıştırarak doğrusal olmayan öğrenme sağlar (ReLU, Sigmoid, Tanh).',
      'course': 'BIL302',
    },
    {
      'q': 'SOLID prensiplerinden "S" neyi temsil eder?',
      'a': 'Single Responsibility Principle: Her sınıfın yalnızca bir değişme sebebi olmalıdır.',
      'course': 'BIL405',
    },
    {
      'q': 'REST API\'de HTTP PUT ve PATCH arasındaki fark nedir?',
      'a': 'PUT tüm kaynağı değiştirir; PATCH yalnızca belirtilen alanları günceller.',
      'course': 'BIL405',
    },
  ];

  bool _questionAnswerVisible = false;

  // Final countdown
  final DateTime _examDate = DateTime(2026, 12, 20, 9, 0);

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Mobil Programlama (Flutter)',
      'code': 'BIL401',
      'icon': Icons.flutter_dash,
      'gradient': const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]),
      'color': const Color(0xFF0284C7),
      'notesCount': 8,
      'quizCount': 4,
      'progress': 0.85,
    },
    {
      'title': 'Yapay Zeka ve Veri Bilimi',
      'code': 'BIL302',
      'icon': Icons.psychology_rounded,
      'gradient': const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
      'color': const Color(0xFF7C3AED),
      'notesCount': 6,
      'quizCount': 3,
      'progress': 0.65,
    },
    {
      'title': 'Veri Tabanı Yönetim Sistemleri',
      'code': 'BIL204',
      'icon': Icons.storage_rounded,
      'gradient': const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
      'color': const Color(0xFF059669),
      'notesCount': 5,
      'quizCount': 2,
      'progress': 0.50,
    },
    {
      'title': 'Yazılım Mimarisi ve Tasarımı',
      'code': 'BIL405',
      'icon': Icons.architecture_rounded,
      'gradient': const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]),
      'color': const Color(0xFFD97706),
      'notesCount': 4,
      'quizCount': 2,
      'progress': 0.40,
    },
  ];

  final List<Map<String, dynamic>> _recentActivity = [
    {
      'icon': Icons.quiz_rounded,
      'color': const Color(0xFF4F46E5),
      'title': 'Flutter Test Çözdü',
      'subtitle': '8/10 doğru · BIL401',
      'time': '2 saat önce',
    },
    {
      'icon': Icons.summarize_rounded,
      'color': const Color(0xFF059669),
      'title': 'Not Özetledi',
      'subtitle': 'SQL JOIN konusu · BIL204',
      'time': '5 saat önce',
    },
    {
      'icon': Icons.style_rounded,
      'color': const Color(0xFF7C3AED),
      'title': 'Flashcard Tekrarı',
      'subtitle': '12/15 kart · BIL302',
      'time': 'Dün',
    },
    {
      'icon': Icons.smart_toy_rounded,
      'color': const Color(0xFF0284C7),
      'title': 'AI Sohbet',
      'subtitle': 'State Management soruları',
      'time': 'Dün',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    // Günün sorusu indeksi
    _questionOfDayIndex = DateTime.now().day % _questionsOfDay.length;
  }

  @override
  void dispose() {
    _animController.dispose();
    _pomodoroTimer?.cancel();
    super.dispose();
  }

  void _togglePomodoro() {
    if (_pomodoroRunning) {
      _pomodoroTimer?.cancel();
      setState(() => _pomodoroRunning = false);
    } else {
      _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          if (_pomodoroSeconds > 0) {
            _pomodoroSeconds--;
          } else {
            _pomodoroTimer?.cancel();
            _pomodoroRunning = false;
            if (!_isBreak) {
              _pomodoroCount++;
              _isBreak = true;
              _pomodoroSeconds = _breakDuration;
              _showPomodoroNotification('Mola zamanı! 🎉', '5 dakika dinlen.');
            } else {
              _isBreak = false;
              _pomodoroSeconds = _pomoDuration;
              _showPomodoroNotification('Çalışma zamanı! 📚', 'Yeni Pomodoro başlıyor.');
            }
          }
        });
      });
      setState(() => _pomodoroRunning = true);
    }
  }

  void _resetPomodoro() {
    _pomodoroTimer?.cancel();
    setState(() {
      _pomodoroRunning = false;
      _isBreak = false;
      _pomodoroSeconds = _pomoDuration;
    });
  }

  void _showPomodoroNotification(String title, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('⏰', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(msg, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatPomodoro(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _daysToExam {
    final now = DateTime.now();
    return _examDate.difference(now).inDays.clamp(0, 999);
  }

  void _showServerSettingsDialog() {
    final controller = TextEditingController(text: ApiConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.settings_ethernet_rounded, color: AppTheme.primaryColor),
          SizedBox(width: 10),
          Text('Sunucu Yapılandırması',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'n8n Webhook sunucu adresi:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'http://10.0.2.2:5678/webhook',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              ApiConstants.updateBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sunucu adresi güncellendi ✓')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),
                    // Quick action row
                    _buildQuickActionsRow(),
                    const SizedBox(height: 20),
                    // Pomodoro + Exam countdown
                    Row(
                      children: [
                        Expanded(child: _buildPomodoroCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildExamCountdownCard()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Question of the Day
                    _buildQuestionOfDay(),
                    const SizedBox(height: 20),
                    // AI Tools Grid
                    _buildSectionHeader('🤖 AI Araçları', null),
                    const SizedBox(height: 12),
                    _buildAiToolsGrid(),
                    const SizedBox(height: 20),
                    // Courses
                    _buildSectionHeader('📚 Derslerim', 'Tümünü Gör'),
                    const SizedBox(height: 12),
                    _buildCoursesList(),
                    const SizedBox(height: 20),
                    // Recent Activity
                    _buildSectionHeader('🕐 Son Aktiviteler', null),
                    const SizedBox(height: 12),
                    _buildActivityFeed(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: AppTheme.backgroundColor,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Myless',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: AppTheme.textPrimaryColor)),
              Text('Merhaba, Semih 👋',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textSecondaryColor)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showServerSettingsDialog,
          icon: const Icon(Icons.settings_ethernet_rounded,
              color: AppTheme.textSecondaryColor),
          tooltip: 'Sunucu Ayarları',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bu Hafta', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  Text('38 saat çalışma 🔥',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text('7 gün seri',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _HeroStat(label: 'Soru Çözüldü', value: '142', icon: Icons.quiz_rounded),
              SizedBox(width: 16),
              _HeroStat(label: 'Not Özetlendi', value: '24', icon: Icons.summarize_rounded),
              SizedBox(width: 16),
              _HeroStat(label: 'Flashcard', value: '89', icon: Icons.style_rounded),
            ],
          ),
          const SizedBox(height: 16),
          // AI Server status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text('AI Aktif · Ollama qwen2.5:3b',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final actions = [
      {
        'label': 'Yanlış Çöz',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFEF4444),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PracticeScreen(
              title: 'Hızlı Pratik Modu',
              wrongQuestions: [
                QuizQuestion(
                  question: 'Flutter\'da StatefulWidget ne zaman tercih edilir?',
                  options: [
                    'Zamanla veya kullanıcı etkileşimiyle değişen durumlarda',
                    'Sadece statik metin gösterirken',
                    'Uygulama ikonu belirlerken',
                    'Sadece asset resim yüklerken',
                  ],
                  correctAnswer: 'Zamanla veya kullanıcı etkileşimiyle değişen durumlarda',
                  explanation: 'StatefulWidget, dinamik veri akışı veya setState() çağrıları ile UI güncellenmesi gereken yerlerde kullanılır.',
                ),
                QuizQuestion(
                  question: 'SQL JOIN işlemlerinde kesişim kümesini getiren hangisidir?',
                  options: ['INNER JOIN', 'FULL OUTER JOIN', 'CROSS JOIN', 'LEFT JOIN'],
                  correctAnswer: 'INNER JOIN',
                  explanation: 'INNER JOIN yalnızca iki tabloda eşleşen kayıtları getirir.',
                ),
              ],
            ),
          ),
        ),
      },
      {
        'label': 'Hızlı Quiz',
        'icon': Icons.flash_on_rounded,
        'color': const Color(0xFF4F46E5),
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NotesScreen())),
      },
      {
        'label': 'Not Özetle',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFF059669),
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NotesScreen())),
      },
      {
        'label': 'Flashcard',
        'icon': Icons.style_rounded,
        'color': const Color(0xFF7C3AED),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FlashcardsScreen())),
      },
      {
        'label': 'AI Sohbet',
        'icon': Icons.smart_toy_rounded,
        'color': const Color(0xFF0284C7),
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatScreen())),
      },
      {
        'label': 'Haftalık Plan',
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFFD97706),
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudyPlanScreen())),
      },
    ];

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: a['onTap'] as VoidCallback,
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (a['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: (a['color'] as Color).withValues(alpha: 0.3)),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: a['color'] as Color, size: 24),
                ),
                const SizedBox(height: 4),
                Text(a['label'] as String,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPomodoroCard() {
    final progressRatio = _isBreak
        ? 1 - _pomodoroSeconds / _breakDuration
        : 1 - _pomodoroSeconds / _pomoDuration;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                _isBreak ? 'Mola' : 'Pomodoro',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor),
              ),
              const Spacer(),
              if (_pomodoroCount > 0)
                Text('$_pomodoroCount 🍅',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMutedColor)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  value: progressRatio,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isBreak ? AppTheme.successColor : AppTheme.primaryColor,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                _formatPomodoro(_pomodoroSeconds),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _togglePomodoro,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      gradient: _pomodoroRunning
                          ? const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _pomodoroRunning ? '⏸ Dur' : '▶ Başla',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _resetPomodoro,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      size: 14, color: AppTheme.textSecondaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Final Sınavı',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$_daysToExam',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
          const Text('gün kaldı',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('20 Aralık 2026',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
          const SizedBox(height: 6),
          _buildExamProgressBar(),
        ],
      ),
    );
  }

  Widget _buildExamProgressBar() {
    final semesterStart = DateTime(2026, 9, 20);
    final total = _examDate.difference(semesterStart).inDays;
    final elapsed = DateTime.now().difference(semesterStart).inDays;
    final progress = (elapsed / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dönem ilerleme',
            style: TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionOfDay() {
    final question = _questionsOfDay[_questionOfDayIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.aiBadgeGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('💡 Günün Sorusu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(question['course']!,
                    style: const TextStyle(
                        color: AppTheme.primaryColor, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question['q']!,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
                height: 1.4),
          ),
          if (_questionAnswerVisible) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '✅ ${question['a']!}',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.successColor,
                    height: 1.4),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => _questionAnswerVisible = !_questionAnswerVisible),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _questionAnswerVisible
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _questionAnswerVisible ? '✓ Cevabı Gizle' : '👁 Cevabı Gör',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _questionAnswerVisible = false;
                    _questionOfDayIndex =
                        (_questionOfDayIndex + 1) % _questionsOfDay.length;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Sonraki →',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor)),
        if (action != null)
          Text(action,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAiToolsGrid() {
    final tools = [
      {
        'title': 'AI Sohbet',
        'subtitle': 'Ders soruları sor',
        'icon': Icons.smart_toy_rounded,
        'gradient': AppTheme.primaryGradient,
        'screen': const ChatScreen(),
      },
      {
        'title': 'Not Özetle',
        'subtitle': 'Notlarını özetle',
        'icon': Icons.auto_awesome,
        'gradient': AppTheme.successGradient,
        'screen': const NotesScreen(),
      },
      {
        'title': 'Quiz Çöz',
        'subtitle': 'Kendini sına',
        'icon': Icons.quiz_rounded,
        'gradient': AppTheme.heroGradient,
        'screen': const NotesScreen(),
      },
      {
        'title': 'Flashcard',
        'subtitle': 'Kartlarla öğren',
        'icon': Icons.style_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        'screen': const FlashcardsScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: tools.length,
      itemBuilder: (context, i) {
        final tool = tools[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tool['screen'] as Widget),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: tool['gradient'] as LinearGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(tool['icon'] as IconData, color: Colors.white, size: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tool['title'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(tool['subtitle'] as String,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoursesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final course = _courses[i];
        return _CourseCard(
          course: course,
          onQuiz: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NotesScreen())),
          onFlashcard: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      FlashcardsScreen(initialCourse: course['title'] as String))),
          onChat: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        );
      },
    );
  }

  Widget _buildActivityFeed() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: _recentActivity.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (a['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a['icon'] as IconData,
                        color: a['color'] as Color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['title'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textPrimaryColor)),
                        Text(a['subtitle'] as String,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor)),
                      ],
                    ),
                  ),
                  Text(a['time'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMutedColor)),
                ],
              ),
              if (i < _recentActivity.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: AppTheme.dividerColor),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onQuiz;
  final VoidCallback onFlashcard;
  final VoidCallback onChat;

  const _CourseCard({
    required this.course,
    required this.onQuiz,
    required this.onFlashcard,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final progress = course['progress'] as double;
    final color = course['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(course['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course['title'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textPrimaryColor),
                        overflow: TextOverflow.ellipsis),
                    Text(course['code'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMutedColor)),
                  ],
                ),
              ),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniChip(
                  label: '${course['notesCount']} Not',
                  icon: Icons.description_rounded,
                  color: color),
              const SizedBox(width: 6),
              _MiniChip(
                  label: '${course['quizCount']} Quiz',
                  icon: Icons.quiz_rounded,
                  color: color),
              const Spacer(),
              _IconBtn(icon: Icons.quiz_rounded, color: color, onTap: onQuiz),
              const SizedBox(width: 4),
              _IconBtn(icon: Icons.style_rounded, color: color, onTap: onFlashcard),
              const SizedBox(width: 4),
              _IconBtn(icon: Icons.smart_toy_rounded, color: color, onTap: onChat),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _MiniChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
