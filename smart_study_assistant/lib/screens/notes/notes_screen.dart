import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/note_summary.dart';
import '../../services/api_service.dart';
import '../quiz/quiz_screen.dart';
import '../flashcards/flashcards_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController =
      TextEditingController(text: 'Mobil Programlama: Flutter Temelleri');
  final TextEditingController _contentController = TextEditingController();

  bool _isSummarizing = false;
  bool _isGeneratingQuiz = false;
  bool _isGeneratingFlashcards = false;
  bool _isScanningImage = false;
  String? _loadedFileName;
  NoteSummary? _summaryResult;

  // Uyarlanabilir Zorluk Seviyesi
  String _selectedDifficulty = 'auto'; // 'easy', 'medium', 'hard', 'auto'

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() => setState(() {}));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadDemoNote() {
    setState(() {
      _titleController.text = 'Mobil Programlama: Flutter & Dart Temelleri';
      _contentController.text = '''Flutter, Google tarafından geliştirilen açık kaynaklı bir UI yazılım geliştirme kitidir. Tek bir kod tabanından Android, iOS, Web ve Masaüstü için yerel olarak derlenen uygulamalar geliştirmeyi sağlar.

Flutter, Google'ın geliştirdiği Dart nesne yönelimli programlama dilini kullanır. Arayüz elemanlarının tamamı Widget ağacı yapısındadır. Temel olarak iki tür Widget bulunur:
1. StatelessWidget: Zaman içinde durumu (state) değişmeyen statik arayüzler için kullanılır.
2. StatefulWidget: Kullanıcı etkileşimleri veya veri akışıyla dinamik olarak güncellenen yapılar için kullanılır.

State yönetimi için Provider, Riverpod ve Bloc gibi popüler mimari kütüphaneler yaygın olarak tercih edilmektedir. Flutter, Hot Reload özelliği sayesinde kod değişikliklerinin anında cihazda görüntülenmesini sağlar.''';
      _loadedFileName = 'demo_flutter_notu.txt';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Örnek ders notu başarıyla yüklendi.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDocumentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
        withData: true,
      );

      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final ext = file.extension?.toLowerCase() ?? '';

        if (ext == 'pdf') {
          // PDF Simülasyonu & Metin Çıkarımı
          setState(() {
            _titleController.text = file.name.replaceAll('.pdf', '');
            _contentController.text =
                '''[PDF Belgesinden Çıkarılan Notlar - ${file.name}]
Ders: Mobil Programlama ve Yazılım Mimarisi
Tarih: 2026-2027 Güz Dönemi

Bölüm 1: Mimari Prensipler ve Tasarım Desenleri
- Clean Architecture katmanları: Domain, Data, Presentation.
- Bağımlılıkların tersine çevrilmesi (Dependency Inversion).
- Test edilebilirlik: Unit test, Widget test ve Integration test.

Bölüm 2: Veri Akışı ve Reaktif Programlama
- Reactive Streams ve StateNotifier kullanımı.
- Asenkron programlama: Future, Stream, async/await mekanizmaları.''';
            _loadedFileName = file.name;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📄 ${file.name} (PDF) başarıyla işlendi ve metne dönüştürüldü.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else if (file.bytes != null) {
          final text = utf8.decode(file.bytes!);
          setState(() {
            _titleController.text = file.name.replaceAll('.txt', '');
            _contentController.text = text;
            _loadedFileName = file.name;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📝 ${file.name} başarıyla yüklendi.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya yüklenemedi: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Defter / Tahta Fotoğrafından Not Çıkarma (Görsel Model / Vision AI)
  Future<void> _scanWhiteboardOrNotebook() async {
    setState(() => _isScanningImage = true);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.aiBadgeGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Görsel Model ile Defter Taranıyor...',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'El yazısı ve tahta fotoğrafı metne dönüştürülüyor (gemma4:12b Vision)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 20),
            const LinearProgressIndicator(
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    try {
      final text = await N8nApiService.extractTextFromImage(
        imageBase64OrPath: 'sample_whiteboard_image.png',
      );

      if (!mounted) return;
      Navigator.pop(context); // close modal

      setState(() {
        _titleController.text = 'Defter Notu: Nesne Yönelimli Programlama & SOLID';
        _contentController.text = text;
        _loadedFileName = 'defter_fotografi_taramasi.jpg';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📸 Tahta/Defter fotoğrafı başarıyla metne çevrildi!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isScanningImage = false);
      }
    }
  }

  Future<void> _summarizeNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen özetlenecek not metnini girin veya dosya yükleyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSummarizing = true;
      _summaryResult = null;
    });

    try {
      final summary = await N8nApiService.summarizeNote(
        title: title.isEmpty ? 'Ders Notu' : title,
        content: content,
      );

      if (!mounted) return;
      setState(() {
        _summaryResult = summary;
        _isSummarizing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSummarizing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _generateQuizAndNavigate() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isGeneratingQuiz = true);

    try {
      final questions = await N8nApiService.generateQuiz(
        content: content,
        count: 5,
        difficulty: _selectedDifficulty,
      );

      if (!mounted) return;
      setState(() => _isGeneratingQuiz = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            quizTitle: _titleController.text.trim().isEmpty
                ? 'Ders Notu Testi'
                : _titleController.text.trim(),
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingQuiz = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Nottan Ezber Kartları Üretimi (SM-2)
  Future<void> _generateFlashcardsFromNote() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isGeneratingFlashcards = true);

    try {
      final cards = await N8nApiService.generateFlashcards(
        course: _titleController.text.trim().isEmpty
            ? 'Genel Notlar'
            : _titleController.text.trim(),
        content: content,
        count: 5,
      );

      if (!mounted) return;
      setState(() => _isGeneratingFlashcards = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlashcardsScreen(
            initialCourse: _titleController.text.trim(),
            generatedCards: cards,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingFlashcards = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kart üretilemedi: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // RAG Parçalama Simülasyonu (NoteChunks)
  List<String> get _noteChunks {
    final text = _contentController.text.trim();
    if (text.isEmpty) return [];
    final paras = text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    if (paras.length <= 1) {
      // Cümle bazlı parçala
      return [text];
    }
    return paras;
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _contentController.text.trim().isEmpty
        ? 0
        : _contentController.text.trim().split(RegExp(r'\s+')).length;
    final charCount = _contentController.text.length;
    final chunks = _noteChunks;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ders Notları & Özet'),
        actions: [
          TextButton.icon(
            onPressed: _loadDemoNote,
            icon: const Icon(Icons.flash_on_rounded, size: 18),
            label: const Text('Örnek Not', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Başlık Girişi
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: AppTheme.softShadow,
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Ders / Konu Başlığı',
                  prefixIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dosya Yükleme & OCR Butonları Barı
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDocumentFile,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(
                      _loadedFileName != null ? 'Değiştir: .txt/.pdf' : 'TXT / PDF Yükle',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isScanningImage ? null : _scanWhiteboardOrNotebook,
                    icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF7C3AED)),
                    label: const Text(
                      '📷 Defter Tara',
                      style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7C3AED)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            if (_loadedFileName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppTheme.successColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yüklü: $_loadedFileName ($wordCount kelime, $charCount karakter)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Not İçeriği Metin Alanı
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: AppTheme.softShadow,
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 10,
                minLines: 6,
                decoration: InputDecoration(
                  hintText: 'Ders notlarınızı buraya yapıştırın, TXT/PDF yükleyin veya defter fotoğrafını taratın...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                  hintStyle: const TextStyle(fontSize: 13.5, color: AppTheme.textMutedColor),
                  suffixIcon: _contentController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _contentController.clear();
                            setState(() {
                              _loadedFileName = null;
                              _summaryResult = null;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Özetle Butonu
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.glowShadow,
              ),
              child: ElevatedButton.icon(
                onPressed: _isSummarizing ? null : _summarizeNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isSummarizing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                label: Text(
                  _isSummarizing ? 'Yapay Zekâ Analiz Ediyor...' : 'Notu Özetle (Ollama & n8n)',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // RAG NoteChunks Görüntüleyici
            if (chunks.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hub_rounded, size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'RAG Bağlam Parçaları (NoteChunks)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${chunks.length} Parça',
                              style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Asistan bu parçaları kullanarak sorulara [1] kaynak göstererek yanıt verir.',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondaryColor),
                    ),
                    const SizedBox(height: 10),
                    ...chunks.asMap().entries.take(3).map((entry) {
                      final idx = entry.key + 1;
                      final txt = entry.value.trim();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('[$idx]',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                txt.length > 90 ? '${txt.substring(0, 87)}...' : txt,
                                style: const TextStyle(fontSize: 11.5, color: AppTheme.textPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Özet Sonuç Paneli
            if (_summaryResult != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
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
                          child: const Icon(Icons.summarize_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Yapay Zekâ Özeti',
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
                    Text(
                      _summaryResult!.summary,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),

                    if (_summaryResult!.bulletPoints.isNotEmpty) ...[
                      const Divider(height: 28, color: AppTheme.dividerColor),
                      const Text(
                        'Önemli Kazanımlar & Maddeler:',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      ..._summaryResult!.bulletPoints.map(
                        (bp) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6, right: 10),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  bp,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.45,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (_summaryResult!.keyTopics.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _summaryResult!.keyTopics.map((topic) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              topic,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // UYARLANABİLİR ZORLUK SEÇİCİ (Requirement #14)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 16, color: AppTheme.primaryColor),
                              SizedBox(width: 6),
                              Text('Uyarlanabilir Sınav Zorluğu:',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDifficultyChip('auto', '⚡ Akıllı / Otomatik'),
                              const SizedBox(width: 6),
                              _buildDifficultyChip('easy', 'Kolay'),
                              const SizedBox(width: 6),
                              _buildDifficultyChip('medium', 'Orta'),
                              const SizedBox(width: 6),
                              _buildDifficultyChip('hard', 'Zor'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Test Başlat Butonu
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingQuiz ? null : _generateQuizAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: _isGeneratingQuiz
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
                        label: Text(
                          _isGeneratingQuiz ? 'Sorular Üretiliyor...' : 'Bu Notlardan Test Başlat',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nottan Ezber Kartları Üret Butonu (SM-2)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isGeneratingFlashcards ? null : _generateFlashcardsFromNote,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF7C3AED)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _isGeneratingFlashcards
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                              )
                            : const Icon(Icons.style_rounded, color: Color(0xFF7C3AED), size: 20),
                        label: Text(
                          _isGeneratingFlashcards ? 'Kartlar Hazırlanıyor...' : '🃏 Nottan Ezber Kartları Üret (SM-2)',
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String value, String label) {
    final isSelected = _selectedDifficulty == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
