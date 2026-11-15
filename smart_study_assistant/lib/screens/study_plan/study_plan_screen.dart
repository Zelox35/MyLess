import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGenerating = false;

  final List<String> _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  final List<List<Map<String, dynamic>>> _weekPlan = [
    // Pazartesi
    [
      {'title': 'Flutter Widget Tekrarı', 'course': 'BIL401', 'duration': '45 dk', 'done': true, 'color': const Color(0xFF0284C7), 'type': 'study'},
      {'title': 'State Management Quiz', 'course': 'BIL401', 'duration': '30 dk', 'done': true, 'color': const Color(0xFF0284C7), 'type': 'quiz'},
      {'title': 'SQL JOIN Örnekleri', 'course': 'BIL204', 'duration': '45 dk', 'done': false, 'color': const Color(0xFF059669), 'type': 'study'},
    ],
    // Salı
    [
      {'title': 'Neural Network Nedir?', 'course': 'BIL302', 'duration': '60 dk', 'done': true, 'color': const Color(0xFF7C3AED), 'type': 'study'},
      {'title': 'YZ Flashcard Tekrarı', 'course': 'BIL302', 'duration': '20 dk', 'done': false, 'color': const Color(0xFF7C3AED), 'type': 'flashcard'},
    ],
    // Çarşamba
    [
      {'title': 'REST API Mimarisi', 'course': 'BIL405', 'duration': '45 dk', 'done': true, 'color': const Color(0xFFD97706), 'type': 'study'},
      {'title': 'BIL405 Not Özeti', 'course': 'BIL405', 'duration': '30 dk', 'done': true, 'color': const Color(0xFFD97706), 'type': 'notes'},
      {'title': 'Veri Tabanı Quiz', 'course': 'BIL204', 'duration': '30 dk', 'done': false, 'color': const Color(0xFF059669), 'type': 'quiz'},
      {'title': 'Flutter Navigasyon', 'course': 'BIL401', 'duration': '45 dk', 'done': false, 'color': const Color(0xFF0284C7), 'type': 'study'},
    ],
    // Perşembe
    [
      {'title': 'Design Patterns Tekrarı', 'course': 'BIL405', 'duration': '60 dk', 'done': false, 'color': const Color(0xFFD97706), 'type': 'study'},
      {'title': 'BIL302 Flashcardlar', 'course': 'BIL302', 'duration': '20 dk', 'done': false, 'color': const Color(0xFF7C3AED), 'type': 'flashcard'},
    ],
    // Cuma
    [
      {'title': 'Kapsamlı Quiz - BIL401', 'course': 'BIL401', 'duration': '45 dk', 'done': false, 'color': const Color(0xFF0284C7), 'type': 'quiz'},
      {'title': 'NoSQL Konusu', 'course': 'BIL204', 'duration': '45 dk', 'done': false, 'color': const Color(0xFF059669), 'type': 'study'},
      {'title': 'Haftalık Özet', 'course': 'Genel', 'duration': '30 dk', 'done': false, 'color': const Color(0xFF4F46E5), 'type': 'notes'},
    ],
    // Cumartesi
    [
      {'title': 'Zayıf Konular Tekrarı', 'course': 'Genel', 'duration': '60 dk', 'done': false, 'color': const Color(0xFF4F46E5), 'type': 'study'},
      {'title': 'BIL204 Flashcard', 'course': 'BIL204', 'duration': '20 dk', 'done': false, 'color': const Color(0xFF059669), 'type': 'flashcard'},
    ],
    // Pazar
    [
      {'title': 'Dinlenme + Hafif Tekrar', 'course': 'Genel', 'duration': '30 dk', 'done': false, 'color': const Color(0xFF64748B), 'type': 'study'},
    ],
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0=Pzt
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: todayIndex.clamp(0, 6),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _dayProgress(int dayIndex) {
    final tasks = _weekPlan[dayIndex];
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t['done'] == true).length;
    return done / tasks.length;
  }

  void _toggleTask(int dayIndex, int taskIndex) {
    setState(() {
      final current = _weekPlan[dayIndex][taskIndex]['done'] as bool;
      _weekPlan[dayIndex][taskIndex]['done'] = !current;
    });
  }

  Future<void> _generateAIPlan() async {
    setState(() => _isGenerating = true);
    try {
      final response = await N8nApiService.sendChatMessage(
        course: 'Genel',
        message:
            'Bir öğrenci için haftalık çalışma planı öner. Dersler: Mobil Programlama (Flutter), Yapay Zeka ve Veri Bilimi, Veri Tabanı Yönetim Sistemleri, Yazılım Mimarisi. Her gün için 2-3 aktivite öner (ders çalışma, quiz, flashcard). Türkçe yanıt ver.',
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('AI Çalışma Planı',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SingleChildScrollView(
                      child: Text(
                        response,
                        style: const TextStyle(fontSize: 13, height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tamam', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI plan oluşturulamadı: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 Çalışma Planım',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text('Haftalık program',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateAIPlan,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('AI Plan',
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              tabs: List.generate(7, (i) {
                final progress = _dayProgress(i);
                return Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_days[i]),
                      if (progress > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 8),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: List.generate(7, (dayIndex) {
            final tasks = _weekPlan[dayIndex];
            final progress = _dayProgress(dayIndex);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Progress header
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_days[dayIndex]} Günü Programı',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            '${tasks.where((t) => t['done'] == true).length}/${tasks.length} tamamlandı',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppTheme.borderColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.successColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tasks
                ...tasks.asMap().entries.map((entry) {
                  final taskIndex = entry.key;
                  final task = entry.value;
                  return _TaskCard(
                    task: task,
                    onToggle: () => _toggleTask(dayIndex, taskIndex),
                  );
                }),
                // Add task hint
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.borderColor,
                        style: BorderStyle.solid),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: AppTheme.textMutedColor, size: 18),
                      SizedBox(width: 8),
                      Text('Görev eklemek için AI Plan kullan',
                          style: TextStyle(
                              color: AppTheme.textMutedColor, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggle;

  const _TaskCard({required this.task, required this.onToggle});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz_rounded;
      case 'flashcard':
        return Icons.style_rounded;
      case 'notes':
        return Icons.description_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task['done'] as bool;
    final color = task['color'] as Color;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone ? color.withValues(alpha: 0.3) : AppTheme.borderColor,
          ),
          boxShadow: isDone ? [] : AppTheme.softShadow,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDone ? color : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon(task['type'] as String),
                  color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? AppTheme.textMutedColor
                          : AppTheme.textPrimaryColor,
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    '${task['course']} · ${task['duration']}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMutedColor),
                  ),
                ],
              ),
            ),
            if (isDone)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.successColor, size: 18),
          ],
        ),
      ),
    );
  }
}
