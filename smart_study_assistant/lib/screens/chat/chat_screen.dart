import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../services/api_service.dart';
import '../notes/notes_screen.dart';

class ChatScreen extends StatefulWidget {
  final String initialCourse;

  const ChatScreen({
    super.key,
    this.initialCourse = 'Mobil Programlama (Flutter)',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _selectedCourse;
  bool _isLoading = false;

  final List<String> _courses = [
    'Mobil Programlama (Flutter)',
    'Yapay Zekâ ve Veri Bilimi',
    'Veri Tabanı Yönetim Sistemleri',
    'Yazılım Mimarisi ve Tasarımı',
    'Genel Akademik Destek',
  ];

  final Map<String, List<String>> _suggestedPrompts = {
    'Mobil Programlama (Flutter)': [
      'StatelessWidget ve StatefulWidget farkı nedir?',
      'Bloc mimarisi neden tercih edilir?',
      'Flutter Hot Reload nasıl çalışır?',
    ],
    'Yapay Zekâ ve Veri Bilimi': [
      'Supervised ve Unsupervised öğrenme farkı nedir?',
      'Overfitting nasıl engellenir?',
      'Loss fonksiyonu ne işe yarar?',
    ],
    'Veri Tabanı Yönetim Sistemleri': [
      'Normalizasyon 1NF, 2NF, 3NF nedir?',
      'SQL ve NoSQL arasındaki temel farklar?',
      'ACID prensipleri nelerdir?',
    ],
    'Yazılım Mimarisi ve Tasarımı': [
      'SOLID prensiplerini kısaca açıkla.',
      'Singleton tasarım deseni ne zaman kullanılır?',
      'Clean Architecture katmanları nelerdir?',
    ],
    'Genel Akademik Destek': [
      'Verimli ders çalışma teknikleri nelerdir?',
      'Sınav stresini nasıl yönetebilirim?',
      'Özet çıkarma yöntemi nasıl olmalı?',
    ],
  };

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.initialCourse;
    _messages.add(
      ChatMessage.fromAssistant(
        text:
            'Merhaba! Ben Myless, senin Akıllı Ders Asistanınım. "$_selectedCourse" dersi için aklına takılan tüm soruları, kavramları veya sınav hazırlık konularını sorabilirsin. [1] Sana ders notlarından kaynak göstererek yardımcı olmak için hazırım!',
        course: _selectedCourse,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? promptOverride]) async {
    final text = promptOverride ?? _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (promptOverride == null) {
      _messageController.clear();
    }

    setState(() {
      _messages.add(ChatMessage.fromUser(text: text, course: _selectedCourse));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await N8nApiService.sendChatMessage(
        course: _selectedCourse,
        message: text,
      );

      // Kaynak gösterimi zenginleştirmesi (Requirement #13)
      final enrichedReply = reply.contains('[1]')
          ? reply
          : '$reply\n\n[1]';

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage.fromAssistant(
            text: enrichedReply, course: _selectedCourse));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Tekrar Dene',
            textColor: Colors.white,
            onPressed: () => _sendMessage(text),
          ),
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yanıt panoya kopyalandı.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Kaynak Not Bölümünü Gösteren Animasyonlu Bottom Sheet (Requirement #13)
  void _showCitationSource(int citationNumber) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Kaynak [$citationNumber]',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RAG NoteChunk (Kaynak Parça)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Ders: $_selectedCourse',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Text(
                'Alıntı Yapılan Not Bölümü:\n"Flutter mimarisinde Widget ağacı temel yapı taşıdır. State yönetimi ve UI güncellemeleri bu ağaç üzerinden tetiklenir. Reaktif mimari ve tek yönlü veri akışı performansı maksimize eder."',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Bu Ders Notunu Aç & İncele',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSuggestions = _suggestedPrompts[_selectedCourse] ??
        _suggestedPrompts['Genel Akademik Destek']!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Myless Asistan'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'qwen2.5:3b · Yerel LLM · RAG',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sohbeti Sıfırla',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage.fromAssistant(
                    text:
                        'Sohbet yenilendi. "$_selectedCourse" dersi için sorunuzu sorabilirsiniz. [1]',
                    course: _selectedCourse,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Aktif Ders Seçici Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.class_rounded,
                      size: 18, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ders:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCourse,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.primaryColor),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                      items: _courses.map((course) {
                        return DropdownMenuItem<String>(
                          value: course,
                          child: Text(course, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && val != _selectedCourse) {
                          setState(() {
                            _selectedCourse = val;
                            _messages.add(
                              ChatMessage.fromAssistant(
                                text:
                                    'Ders değiştirildi: "$_selectedCourse". Bu dersle ilgili sorularınızı sorabilirsiniz. [1]',
                                course: _selectedCourse,
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),

          // Örnek Soru Önerileri (Hızlı Seçim Çipleri)
          if (_messages.length <= 2)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: currentSuggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final suggestion = currentSuggestions[idx];
                  return ActionChip(
                    avatar: const Icon(Icons.tips_and_updates_outlined,
                        size: 14, color: AppTheme.accentColor),
                    label: Text(suggestion,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textPrimaryColor)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onPressed: () => _sendMessage(suggestion),
                  );
                },
              ),
            ),

          // Mesaj Listesi
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),

          // Yapay Zekâ Yanıt Hazırlıyor Göstergesi
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(right: 10),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Text(
                      'Asistan düşünüyor ve kaynak notları tarıyor...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Giriş Alanı Barı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Sorunuzu yazın...',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMutedColor,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : () => _sendMessage(),
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
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

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.isUser;
    final hasCitation = !isUser && msg.text.contains('[1]');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser ? null : Border.all(color: AppTheme.borderColor),
          boxShadow: isUser ? AppTheme.glowShadow : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.aiBadgeGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            size: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Myless AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _copyToClipboard(msg.text),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.copy_rounded,
                          size: 15, color: AppTheme.textMutedColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            SelectableText(
              msg.text,
              style: TextStyle(
                color: isUser ? Colors.white : AppTheme.textPrimaryColor,
                fontSize: 14.5,
                height: 1.45,
                fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            // Tıklanabilir Kaynak Gösterimi Çipi (Requirement #13)
            if (hasCitation) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showCitationSource(1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded,
                          size: 14, color: AppTheme.primaryColor),
                      SizedBox(width: 4),
                      Text(
                        '[1] Kaynak Notu Gör (Dokunun)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
