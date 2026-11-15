import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/flashcard_model.dart';
import '../../services/api_service.dart';

class FlashcardsScreen extends StatefulWidget {
  final String? initialCourse;
  final List<Flashcard>? generatedCards;

  const FlashcardsScreen({
    super.key,
    this.initialCourse,
    this.generatedCards,
  });

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;
  int _currentIndex = 0;
  String _selectedCourse = 'Tüm Dersler';
  bool _onlyDueToday = false;

  final List<String> _courseFilterList = [
    'Tüm Dersler',
    'Mobil Programlama (Flutter)',
    'Yapay Zekâ ve Veri Bilimi',
    'Veri Tabanı Yönetim Sistemleri',
    'Yazılım Mimarisi ve Tasarımı',
  ];

  late List<Flashcard> _allCards;

  @override
  void initState() {
    super.initState();
    _allCards = [
      Flashcard(
        id: '1',
        course: 'Mobil Programlama (Flutter)',
        topic: 'Widget Mimarisi',
        question:
            'StatelessWidget ile StatefulWidget arasındaki temel fark nedir?',
        answer:
            'StatelessWidget, durumu zaman içinde değişmeyen statik arayüzler içindir (örneğin sabit metin veya simgeler).\n\nStatefulWidget ise kullanıcı etkileşimi, API yanıtı veya setState() çağrısı ile çalışma anında durumu dinamik olarak güncellenen yapılar içindir.',
        repetitions: 1,
        interval: 1,
      ),
      Flashcard(
        id: '2',
        course: 'Mobil Programlama (Flutter)',
        topic: 'Geliştirme Araçları',
        question: 'Hot Reload ile Hot Restart arasındaki fark nedir?',
        answer:
            'Hot Reload, uygulama durumunu (state) kaybetmeden yalnızca değişen UI kodunu anında günceller (~1 saniye).\n\nHot Restart ise tüm widget ağacını ve uygulama durumunu sıfırlayarak en baştan başlatır (~3-5 saniye).',
        repetitions: 2,
        interval: 6,
      ),
      Flashcard(
        id: '3',
        course: 'Mobil Programlama (Flutter)',
        topic: 'State Management',
        question:
            'Bloc (Business Logic Component) mimarisinin temel mantığı nedir?',
        answer:
            'Bloc, arayüz (UI) ile iş mantığını tamamen ayırır.\n\nUI katmanı Bloc\'a "Event" (Olay) gönderir. Bloc bu olayı işler ve geriye yeni bir "State" (Durum) yayar (Stream/Rx). Bu sayede test edilebilirlik ve yeniden kullanılabilirlik maksimize edilir.',
        repetitions: 0,
        interval: 1,
      ),
      Flashcard(
        id: '4',
        course: 'Yapay Zekâ ve Veri Bilimi',
        topic: 'Makine Öğrenmesi',
        question: 'Overfitting (Aşırı Uyum) nedir ve nasıl engellenir?',
        answer:
            'Modelin eğitim verisini ezberlemesi ve yeni gelen test verilerinde kötü performans göstermesidir.\n\nEngellemek için:\n1. Regularization (L1/L2)\n2. Dropout tekniği\n3. Veri artırma (Data Augmentation)\n4. Early Stopping (Erken durdurma) kullanılır.',
        repetitions: 1,
        interval: 1,
      ),
      Flashcard(
        id: '5',
        course: 'Veri Tabanı Yönetim Sistemleri',
        topic: 'İlişkisel Veri Tabanı',
        question: 'ACID prensipleri neleri ifade eder?',
        answer:
            'A - Atomicity (Ya hep ya hiç)\nC - Consistency (Tutarlılık)\nI - Isolation (İzolasyon / Bağımsızlık)\nD - Durability (Kalıcılık / Dayanıklılık)\n\nVeri tabanında işlemlerin güvenli şekilde tamamlanmasını garanti eder.',
        repetitions: 0,
        interval: 1,
      ),
      Flashcard(
        id: '6',
        course: 'Yazılım Mimarisi ve Tasarımı',
        topic: 'SOLID Prensipleri',
        question: 'Single Responsibility (Tek Sorumluluk) Prensibi nedir?',
        answer:
            'Bir sınıfın veya modülün yalnızca tek bir değişim sebebi ve tek bir işlevi olmalıdır. Bu ilke kodun bakımını kolaylaştırır ve spagetti kod oluşmasını engeller.',
        repetitions: 2,
        interval: 6,
      ),
    ];

    if (widget.generatedCards != null && widget.generatedCards!.isNotEmpty) {
      _allCards.insertAll(0, widget.generatedCards!);
    }

    if (widget.initialCourse != null &&
        _courseFilterList.contains(widget.initialCourse)) {
      _selectedCourse = widget.initialCourse!;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  List<Flashcard> get _filteredCards {
    List<Flashcard> list = _allCards;
    if (_selectedCourse != 'Tüm Dersler') {
      list = list.where((c) => c.course == _selectedCourse).toList();
    }
    if (_onlyDueToday) {
      list = list.where((c) => c.isDueToday).toList();
    }
    return list;
  }

  void _flipCard() {
    if (_animController.isAnimating) return;
    if (_isFront) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _nextCard() {
    final cards = _filteredCards;
    if (_currentIndex < cards.length - 1) {
      if (!_isFront) {
        _animController.reverse();
        _isFront = true;
      }
      setState(() => _currentIndex++);
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      if (!_isFront) {
        _animController.reverse();
        _isFront = true;
      }
      setState(() => _currentIndex--);
    }
  }

  // SM-2 Aralıklı Tekrar Değerlendirmesi
  void _applySm2Quality(int quality) {
    final cards = _filteredCards;
    if (cards.isEmpty || _currentIndex >= cards.length) return;

    final card = cards[_currentIndex];
    setState(() {
      card.applySm2(quality);
    });

    String qualityText;
    switch (quality) {
      case 1:
        qualityText = 'Tekrar Et (1 gün sonra)';
        break;
      case 3:
        qualityText = 'Zor (${card.interval} gün sonra)';
        break;
      case 4:
        qualityText = 'İyi (${card.interval} gün sonra)';
        break;
      case 5:
        qualityText = 'Kolay (${card.interval} gün sonra)';
        break;
      default:
        qualityText = 'Kaydedildi';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.alarm_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('SM-2: $qualityText'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    _nextCard();
  }

  void _showGenerateCardsDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
            SizedBox(width: 8),
            Text('AI Flashcard Üret', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Not veya konu metnini girin, Ollama kartlara dönüştürsün:',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Örn: Veri Tabanı Normalizasyon kuralları...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              final newCards = await N8nApiService.generateFlashcards(
                course: _selectedCourse == 'Tüm Dersler' ? 'Genel' : _selectedCourse,
                content: text,
                count: 3,
              );
              setState(() {
                _allCards.insertAll(0, newCards);
                _currentIndex = 0;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Yeni bilgi kartları eklendi!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
            child: const Text('Kartları Üret', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _filteredCards;
    final learnedCount = cards.where((c) => c.isLearned).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Akıllı Bilgi Kartları (SM-2)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF7C3AED)),
            tooltip: 'Yeni Kart Üret',
            onPressed: _showGenerateCardsDialog,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.style_outlined, size: 54, color: AppTheme.textMutedColor),
                  const SizedBox(height: 12),
                  const Text('Bu kritere uygun kart bulunamadı.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _onlyDueToday = false),
                    child: const Text('Tüm Kartları Göster'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Filtreleme & Bugün Tekrar Barı
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_list_rounded,
                              size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCourse,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: AppTheme.primaryColor),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                                items: _courseFilterList.map((course) {
                                  return DropdownMenuItem<String>(
                                    value: course,
                                    child: Text(course, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCourse = val;
                                      _currentIndex = 0;
                                      if (!_isFront) {
                                        _animController.reset();
                                        _isFront = true;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Bugün Tekrar Oturumu Toggle
                          FilterChip(
                            label: const Text('Bugün Tekrar', style: TextStyle(fontSize: 11)),
                            selected: _onlyDueToday,
                            onSelected: (val) => setState(() {
                              _onlyDueToday = val;
                              _currentIndex = 0;
                            }),
                            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                            checkmarkColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // İlerleme Barı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kart: ${_currentIndex + 1} / ${cards.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          Text(
                            'Öğrenildi: $learnedCount / ${cards.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: cards.isEmpty ? 0 : (_currentIndex + 1) / cards.length,
                          backgroundColor: AppTheme.borderColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.borderColor),

                // 3D Flip Animasyonlu Bilgi Kartı
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final angle = _flipAnimation.value * pi;
                            final isUnder = _flipAnimation.value > 0.5;
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              alignment: Alignment.center,
                              child: isUnder
                                  ? Transform(
                                      transform: Matrix4.identity()..rotateY(pi),
                                      alignment: Alignment.center,
                                      child: _buildBackCard(cards[_currentIndex]),
                                    )
                                  : _buildFrontCard(cards[_currentIndex]),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // SM-2 Aralıklı Tekrar Butonları Barı
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SM-2 Hatırlama Derecesi (Aralıklı Tekrar):',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSm2Btn('Tekrar', '0', const Color(0xFFEF4444), () => _applySm2Quality(1)),
                          _buildSm2Btn('Zor', '3', const Color(0xFFF59E0B), () => _applySm2Quality(3)),
                          _buildSm2Btn('İyi', '4', const Color(0xFF0284C7), () => _applySm2Quality(4)),
                          _buildSm2Btn('Kolay', '5', const Color(0xFF10B981), () => _applySm2Quality(5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Önceki / Sonraki Kart Butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _currentIndex > 0 ? _prevCard : null,
                            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                          ),
                          TextButton.icon(
                            onPressed: _flipCard,
                            icon: const Icon(Icons.flip_rounded, size: 16),
                            label: Text(_isFront ? 'Cevabı Gör' : 'Soruya Dön'),
                          ),
                          IconButton(
                            onPressed: _currentIndex < cards.length - 1 ? _nextCard : null,
                            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSm2Btn(String label, String quality, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Derece $quality', style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard(Flashcard card) {
    return Container(
      constraints: const BoxConstraints(minHeight: 280, maxWidth: 380),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.topic,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textMutedColor),
                  const SizedBox(width: 4),
                  Text(
                    'Aralık: ${card.interval} gün',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMutedColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            card.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              height: 1.45,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cevabı görmek için karta dokunun 👆',
            style: TextStyle(fontSize: 11, color: AppTheme.textMutedColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(Flashcard card) {
    return Container(
      constraints: const BoxConstraints(minHeight: 280, maxWidth: 380),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cevap & Açıklama',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.successColor),
                ),
              ),
              Text(
                card.course,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMutedColor),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            card.answer,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.55,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Aşağıdan hatırlama derecesini seçin 👇',
              style: TextStyle(fontSize: 11, color: AppTheme.textMutedColor),
            ),
          ),
        ],
      ),
    );
  }
}
