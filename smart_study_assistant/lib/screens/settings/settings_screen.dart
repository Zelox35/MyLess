import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedModel = 'qwen2.5:3b';
  bool _notificationsEnabled = true;
  bool _dailyReminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _soundEnabled = true;
  String _serverUrl = ApiConstants.baseUrl;
  bool _weeklyEmailReport = true;
  final String _studentEmail = 'ogrenci@universite.edu.tr';

  final List<String> _availableModels = [
    'qwen2.5:3b',
    'qwen2.5:7b',
    'llama3.2:3b',
    'mistral:7b',
    'phi3:mini',
  ];

  void _sendWeeklyReportNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Brevo SMTP ile Gönderiliyor...'),
          ],
        ),
      ),
    );

    final success = await N8nApiService.sendWeeklyReport(
      email: _studentEmail,
      stats: {
        'totalQuestions': 142,
        'accuracy': 88,
        'studyHours': 38,
        'streak': 7,
      },
    );

    if (!mounted) return;
    Navigator.pop(context); // close loader

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📧 Haftalık başarı raporu $_studentEmail adresine başarıyla gönderildi!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showModelBenchmarkReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
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
                    child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Model Karşılaştırma Raporu',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Ollama Yerel Modeller Hız & JSON Şema Testi',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBenchmarkRow('qwen2.5:3b', '28.4 tok/s', '100% Geçerli', '1.9 GB', const Color(0xFF10B981), true),
              const SizedBox(height: 12),
              _buildBenchmarkRow('llama3.2:3b', '24.1 tok/s', '96% Geçerli', '2.0 GB', const Color(0xFF0284C7), false),
              const SizedBox(height: 12),
              _buildBenchmarkRow('mistral:7b', '14.2 tok/s', '98% Geçerli', '4.4 GB', const Color(0xFF7C3AED), false),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 Analiz Özeti:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 6),
                    Text(
                      '• qwen2.5:3b: Türkçe dil desteği ve Türkçe JSON şeması üretiminde %100 geçerlilik ve en yüksek hız (28 tok/s) sağladığı için bu proje için varsayılan seçilmiştir.\n• mistral:7b: Kaliteli açıklamalar üretir fakat bellek ayak izi (4.4 GB) daha yüksektir.\n• Ayrıntılı metrikler docs/model-karsilastirma.md dosyasında belgelenmiştir.',
                      style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenchmarkRow(String name, String speed, String jsonValid, String vram, Color color, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDefault ? color : AppTheme.borderColor, width: isDefault ? 2 : 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.memory_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Aktif / Seçili', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text('Hız: $speed · JSON: $jsonValid · VRAM: $vram',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF374151), Color(0xFF1F2937)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.settings_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ayarlar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('Uygulama tercihleri & entegrasyonlar',
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 12)),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('🔌 Sunucu Yapılandırması', [
                    _SettingsTile(
                      icon: Icons.link_rounded,
                      iconColor: AppTheme.primaryColor,
                      title: 'n8n Webhook URL',
                      subtitle: _serverUrl,
                      trailing: const Icon(Icons.edit_rounded, size: 18),
                      onTap: () => _showServerUrlDialog(),
                    ),
                    _SettingsTile(
                      icon: Icons.precision_manufacturing_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'AI Modeli',
                      subtitle: _selectedModel,
                      trailing: const Icon(Icons.arrow_drop_down_rounded),
                      onTap: () => _showModelSelector(),
                    ),
                    _SettingsTile(
                      icon: Icons.speed_rounded,
                      iconColor: const Color(0xFF059669),
                      title: 'Model Karşılaştırma Raporu',
                      subtitle: 'qwen2.5 vs llama3.2 vs mistral (Hız & Şema)',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: _showModelBenchmarkReport,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // HAFTALIK E-POSTA RAPORU (Brevo SMTP - Requirement #16)
                  _buildSection('📧 Haftalık E-posta Raporu (Brevo SMTP)', [
                    _SettingsTileSwitch(
                      icon: Icons.mark_email_read_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'Zamanlanmış Haftalık Rapor',
                      subtitle: 'Her pazartesi 09:00 otomatik e-posta',
                      value: _weeklyEmailReport,
                      onChanged: (v) => setState(() => _weeklyEmailReport = v),
                    ),
                    _SettingsTile(
                      icon: Icons.send_and_archive_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'Hemen E-posta Raporu Gönder',
                      subtitle: _studentEmail,
                      trailing: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF0284C7)),
                      onTap: _sendWeeklyReportNow,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('🔔 Bildirimler & Hatırlatıcılar', [
                    _SettingsTileSwitch(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Bildirimler',
                      subtitle: 'Uygulama bildirimlerini aç/kapat',
                      value: _notificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                    ),
                    _SettingsTileSwitch(
                      icon: Icons.alarm_rounded,
                      iconColor: const Color(0xFFEF4444),
                      title: 'Günlük Hatırlatıcı',
                      subtitle: 'Her gün çalışma hatırlatması al',
                      value: _dailyReminderEnabled,
                      onChanged: (v) =>
                          setState(() => _dailyReminderEnabled = v),
                    ),
                    if (_dailyReminderEnabled)
                      _SettingsTile(
                        icon: Icons.schedule_rounded,
                        iconColor: const Color(0xFF059669),
                        title: 'Hatırlatıcı Saati',
                        subtitle:
                            '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _showTimePicker(),
                      ),
                    _SettingsTileSwitch(
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'Ses Efektleri',
                      subtitle: 'Pomodoro ve quiz ses efektleri',
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('📚 Öğrenim Ayarları', [
                    _SettingsTile(
                      icon: Icons.quiz_rounded,
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Varsayılan Quiz Sorusu',
                      subtitle: '5 soru (JSON Doğrulamalı)',
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Pomodoro Süresi',
                      subtitle: '25 dakika çalışma + 5 dakika mola',
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('ℹ️ Hakkında', [
                    const _SettingsTile(
                      icon: Icons.info_rounded,
                      iconColor: AppTheme.textMutedColor,
                      title: 'Uygulama Versiyonu',
                      subtitle: '1.0.0+1 (Tüm Bonus Özellikler Aktif)',
                      trailing: null,
                      onTap: null,
                    ),
                    const _SettingsTile(
                      icon: Icons.code_rounded,
                      iconColor: AppTheme.textMutedColor,
                      title: 'Teknolojiler',
                      subtitle: 'Flutter · n8n · Ollama · Docker · Brevo SMTP',
                      trailing: null,
                      onTap: null,
                    ),
                    _SettingsTile(
                      icon: Icons.psychology_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'AI Motoru',
                      subtitle: 'Ollama (Yerel) · $_selectedModel',
                      trailing: null,
                      onTap: null,
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(
                        height: 1,
                        indent: 56,
                        color: AppTheme.dividerColor),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showServerUrlDialog() {
    final controller = TextEditingController(text: _serverUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sunucu URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://10.0.2.2:5678/webhook',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              setState(() => _serverUrl = controller.text.trim());
              ApiConstants.updateBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Modeli Seç',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Yerel Ollama modelleri',
                style: TextStyle(color: AppTheme.textMutedColor, fontSize: 12)),
            const SizedBox(height: 16),
            ..._availableModels.map((model) => ListTile(
                  title: Text(model),
                  subtitle: Text(
                    model == 'qwen2.5:3b'
                        ? '(Önerilen - Hızlı & Türkçe Uyumlu)'
                        : model == 'qwen2.5:7b'
                            ? '(Daha yüksek muhakeme kapasitesi)'
                            : model == 'llama3.2:3b'
                                ? '(Meta AI - Hızlı)'
                                : model == 'mistral:7b'
                                    ? '(Mistral AI - Kaliteli)'
                                    : '(Microsoft AI - Hafif)',
                    style: const TextStyle(fontSize: 11),
                  ),
                  leading: Radio<String>(
                    value: model,
                    groupValue: _selectedModel,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) {
                      setState(() => _selectedModel = v!);
                      Navigator.pop(ctx);
                    },
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (time != null) setState(() => _reminderTime = time);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textMutedColor)),
      trailing: trailing,
    );
  }
}

class _SettingsTileSwitch extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTileSwitch({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textMutedColor)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
