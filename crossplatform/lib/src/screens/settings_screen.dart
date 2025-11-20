import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/settings_item.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoRefreshEnabled = true;
  int _refreshInterval = 30;
  String _selectedLanguage = 'ru';
  String _selectedTheme = 'dark';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('⚙️ Настройки'),
        backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.darkTheme.appBarTheme.foregroundColor,
        elevation: 1,
      ),
      body: ListView(
        children: [
          // Connection Settings
          SettingsSection(
            title: '🔗 Подключение',
            children: [
              SettingsItem(
                title: 'URL API сервера',
                subtitle: 'http://localhost:8000',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showApiUrlDialog,
              ),
              SettingsItem(
                title: 'WebSocket соединение',
                subtitle: 'Подключено',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    _showSnackBar('WebSocket ${value ? 'включен' : 'отключен'}');
                  },
                ),
              ),
              SettingsItem(
                title: 'Таймаут запросов',
                subtitle: '10 секунд',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showTimeoutDialog,
              ),
            ],
          ),

          // Display Settings
          SettingsSection(
            title: '🎨 Внешний вид',
            children: [
              SettingsItem(
                title: 'Тема оформления',
                subtitle: _getThemeDisplayName(_selectedTheme),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showThemeDialog,
              ),
              SettingsItem(
                title: 'Язык интерфейса',
                subtitle: _getLanguageDisplayName(_selectedLanguage),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLanguageDialog,
              ),
              SettingsItem(
                title: 'Размер шрифта',
                subtitle: 'Стандартный',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showFontSizeDialog,
              ),
            ],
          ),

          // Data Settings
          SettingsSection(
            title: '📊 Данные',
            children: [
              SettingsItem(
                title: 'Автообновление',
                subtitle: 'Каждые $_refreshInterval секунд',
                trailing: Switch(
                  value: _autoRefreshEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoRefreshEnabled = value;
                    });
                    _showSnackBar('Автообновление ${value ? 'включено' : 'отключено'}');
                  },
                ),
              ),
              SettingsItem(
                title: 'История данных',
                subtitle: '24 часа',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showHistoryDialog,
              ),
              SettingsItem(
                title: 'Кэширование',
                subtitle: 'Включено',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    _showSnackBar('Кэширование ${value ? 'включено' : 'отключено'}');
                  },
                ),
              ),
            ],
          ),

          // Notification Settings
          SettingsSection(
            title: '🔔 Уведомления',
            children: [
              SettingsItem(
                title: 'Уведомления',
                subtitle: _notificationsEnabled ? 'Включены' : 'Отключены',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _showSnackBar('Уведомления ${value ? 'включены' : 'отключены'}');
                  },
                ),
              ),
              SettingsItem(
                title: 'Критические аварии',
                subtitle: 'Звук и вибрация',
                trailing: const Icon(Icons.chevron_right),
                onTap: _notificationsEnabled ? _showCriticalAlertsDialog : null,
              ),
              SettingsItem(
                title: 'Обычные аварии',
                subtitle: 'Только уведомления',
                trailing: const Icon(Icons.chevron_right),
                onTap: _notificationsEnabled ? _showNormalAlertsDialog : null,
              ),
            ],
          ),

          // Security Settings
          SettingsSection(
            title: '🔐 Безопасность',
            children: [
              SettingsItem(
                title: 'Аутентификация',
                subtitle: 'Требуется пароль',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAuthDialog,
              ),
              SettingsItem(
                title: 'Шифрование данных',
                subtitle: 'Включено',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    _showSnackBar('Шифрование ${value ? 'включено' : 'отключено'}');
                  },
                ),
              ),
              SettingsItem(
                title: 'Автовыход',
                subtitle: 'Через 30 минут',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showAutoLogoutDialog,
              ),
            ],
          ),

          // About Section
          SettingsSection(
            title: 'ℹ️ О приложении',
            children: [
              SettingsItem(
                title: 'Версия приложения',
                subtitle: '1.0.0',
                trailing: const Icon(Icons.info_outline),
                onTap: _showVersionInfo,
              ),
              SettingsItem(
                title: 'Лицензия',
                subtitle: 'MIT License',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLicense,
              ),
              SettingsItem(
                title: 'Политика конфиденциальности',
                subtitle: '',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPrivacyPolicy,
              ),
              SettingsItem(
                title: 'Сброс настроек',
                subtitle: 'Восстановить настройки по умолчанию',
                trailing: Icon(
                  Icons.restore,
                  color: AppTheme.criticalColor,
                ),
                onTap: _showResetDialog,
              ),
            ],
          ),

          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showApiUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL API сервера'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: 'http://localhost:8000',
              decoration: const InputDecoration(
                labelText: 'URL сервера',
                hintText: 'Введите URL API сервера',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Укажите адрес вашего SCADA сервера',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('URL сервера обновлен');
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Таймаут запросов'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите время ожидания ответа от сервера:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: 10,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 секунд')),
                DropdownMenuItem(value: 10, child: Text('10 секунд')),
                DropdownMenuItem(value: 30, child: Text('30 секунд')),
                DropdownMenuItem(value: 60, child: Text('60 секунд')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Таймаут обновлен');
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тема оформления'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('dark', 'Темная', Icons.dark_mode),
            _buildThemeOption('light', 'Светлая', Icons.light_mode),
            _buildThemeOption('auto', 'Авто', Icons.brightness_auto),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String value, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: _selectedTheme == value ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          _selectedTheme = value;
        });
        Navigator.pop(context);
        _showSnackBar('Тема изменена на "$title"');
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Язык интерфейса'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('ru', 'Русский', '🇷🇺'),
            _buildLanguageOption('en', 'English', '🇺🇸'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String value, String title, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(title),
      trailing: _selectedLanguage == value ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
        Navigator.pop(context);
        _showSnackBar('Язык изменен на "$title"');
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Размер шрифта'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('small', 'Мелкий'),
            _buildFontSizeOption('medium', 'Стандартный'),
            _buildFontSizeOption('large', 'Крупный'),
            _buildFontSizeOption('xlarge', 'Очень крупный'),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String value, String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.check), // Would show based on current selection
      onTap: () {
        Navigator.pop(context);
        _showSnackBar('Размер шрифта изменен на "$title"');
      },
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('История данных'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите период хранения истории:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: '24 часа',
              items: const [
                DropdownMenuItem(value: '1 час', child: Text('1 час')),
                DropdownMenuItem(value: '6 часов', child: Text('6 часов')),
                DropdownMenuItem(value: '24 часа', child: Text('24 часа')),
                DropdownMenuItem(value: '7 дней', child: Text('7 дней')),
                DropdownMenuItem(value: '30 дней', child: Text('30 дней')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Период истории обновлен');
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showCriticalAlertsDialog() {
    _showAlertSettingsDialog('Критические аварии', [
      'Пуш-уведомления',
      'Звуковой сигнал',
      'Вибрация',
      'Мигание экрана',
    ]);
  }

  void _showNormalAlertsDialog() {
    _showAlertSettingsDialog('Обычные аварии', [
      'Пуш-уведомления',
      'Звуковой сигнал',
    ]);
  }

  void _showAlertSettingsDialog(String title, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) => CheckboxListTile(
                title: Text(option),
                value: true, // Would track individual settings
                onChanged: (value) {},
              )).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackBar('Настройки уведомлений обновлены');
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Аутентификация'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Настройки безопасности доступа:'),
            SizedBox(height: 16),
            // Would include actual auth settings
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAutoLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Автовыход'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите время до автоматического выхода:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: '30 минут',
              items: const [
                DropdownMenuItem(value: '5 минут', child: Text('5 минут')),
                DropdownMenuItem(value: '15 минут', child: Text('15 минут')),
                DropdownMenuItem(value: '30 минут', child: Text('30 минут')),
                DropdownMenuItem(value: '1 час', child: Text('1 час')),
                DropdownMenuItem(value: 'Никогда', child: Text('Никогда')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Настройки автовыхода обновлены');
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SCADA System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Версия: 1.0.0'),
            const Text('Сборка: 2024.01.001'),
            const SizedBox(height: 16),
            const Text('Кроссплатформенная SCADA система для мониторинга нефтепровода.'),
            const SizedBox(height: 8),
            Text('Платформа: ${_getPlatformName()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showLicense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Лицензия'),
        content: const SingleChildScrollView(
          child: Text(
            'MIT License\n\nCopyright (c) 2024 SCADA System\n\nPermission is hereby granted...',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const SingleChildScrollView(
          child: Text(
            'Политика конфиденциальности SCADA System...',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс настроек'),
        content: const Text('Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
              _showSnackBar('Настройки сброшены');
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _notificationsEnabled = true;
      _darkModeEnabled = true;
      _autoRefreshEnabled = true;
      _refreshInterval = 30;
      _selectedLanguage = 'ru';
      _selectedTheme = 'dark';
    });
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'dark': return 'Темная';
      case 'light': return 'Светлая';
      case 'auto': return 'Авто';
      default: return theme;
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'ru': return 'Русский';
      case 'en': return 'English';
      default: return language;
    }
  }

  String _getPlatformName() {
    // This would be determined dynamically in a real app
    return 'Flutter (Кроссплатформенное)';
  }
}