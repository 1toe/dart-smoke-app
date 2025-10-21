import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../services/local_data_service.dart';
import '../../providers/theme_provider.dart';
import './widgets/data_export_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsProfile extends StatefulWidget {
  const SettingsProfile({Key? key}) : super(key: key);

  @override
  State<SettingsProfile> createState() => _SettingsProfileState();
}

class _SettingsProfileState extends State<SettingsProfile> {
  final LocalDataService _dataService = LocalDataService();

  // User profile data - loaded from local storage
  Map<String, dynamic> userProfile = {};
  Map<String, dynamic> appSettings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      userProfile = await _dataService.getUserProfile() ?? {};
      appSettings = await _dataService.getSettings();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      await _dataService.updateSetting(key, value);
      setState(() {
        appSettings[key] = value;
      });
      
      // If dark mode is toggled, update the theme provider
      if (key == 'darkMode' && mounted) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        await themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
      }
      
      _showSuccessMessage('Configuración actualizada');
    } catch (e) {
      _showErrorMessage('Error al actualizar configuración');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(3.w),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(3.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Configuración'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Configuración',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 6.w,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        child: Column(
          children: [
            // Profile Header with improved responsive design
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: ProfileHeaderWidget(
                userName: userProfile['name'] as String? ?? 'Usuario',
                userEmail: userProfile['email'] as String? ?? 'usuario@ejemplo.com',
                profileImageUrl: userProfile['profileImage'] as String?,
                onImageChanged: (String imagePath) {
                  // Handle image change
                  userProfile['profileImage'] = imagePath;
                },
              ),
            ),

            // Language Selector with better spacing
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: LanguageSelectorWidget(
                currentLanguage: appSettings['language'] ?? 'es',
                onLanguageChanged: (language) {
                  _updateSetting('language', language);
                },
              ),
            ),

            // Notifications Settings with improved layout
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: SettingsSectionWidget(
                title: 'Notificaciones',
                items: [
                  SettingsItem(
                    title: 'Notificaciones push',
                    subtitle: 'Recibir notificaciones del progreso',
                    hasSwitch: true,
                    switchValue: appSettings['notifications'] ?? true,
                    onSwitchChanged: (value) {
                      _updateSetting('notifications', value);
                    },
                    showChevron: false,
                  ),
                  SettingsItem(
                    title: 'Recordatorios',
                    subtitle: 'Recordatorios para registrar datos',
                    hasSwitch: true,
                    switchValue: appSettings['reminders'] ?? true,
                    onSwitchChanged: (value) {
                      _updateSetting('reminders', value);
                    },
                    showChevron: false,
                  ),
                ],
              ),
            ),

            // Privacy Settings
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: SettingsSectionWidget(
                title: 'Privacidad',
                items: [
                  SettingsItem(
                    title: 'Compartir progreso',
                    subtitle: 'Permitir compartir logros localmente',
                    hasSwitch: true,
                    switchValue: appSettings['progressSharing'] ?? false,
                    onSwitchChanged: (value) {
                      _updateSetting('progressSharing', value);
                    },
                    showChevron: false,
                  ),
                  SettingsItem(
                    title: 'Modo oscuro',
                    subtitle: 'Activar tema oscuro',
                    hasSwitch: true,
                    switchValue: appSettings['darkMode'] ?? false,
                    onSwitchChanged: (value) {
                      _updateSetting('darkMode', value);
                    },
                    showChevron: false,
                  ),
                ],
              ),
            ),

            // Data Export with improved responsive design
            Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: DataExportWidget(),
            ),

            // App Information with better layout
            SettingsSectionWidget(
              title: 'Información de la App',
              items: [
                SettingsItem(
                  title: 'Acerca de',
                  subtitle: 'Versión 1.0.0 - Completamente local',
                  iconName: 'info',
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                SettingsItem(
                  title: 'Ayuda y soporte',
                  subtitle: 'Guía local de uso',
                  iconName: 'help',
                  onTap: () {
                    _showLocalHelpDialog();
                  },
                ),
                SettingsItem(
                  title: 'Almacenamiento local',
                  subtitle: 'Gestionar datos del dispositivo',
                  iconName: 'storage',
                  onTap: () {
                    _showStorageInfo();
                  },
                ),
              ],
            ),

            SizedBox(height: 8.h), // Better spacing for navigation
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        currentIndex: 4, // Settings tab is selected
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-home');
              break;
            case 1:
              Navigator.pushNamed(context, '/progress-analytics');
              break;
            case 2:
              Navigator.pushNamed(context, '/quit-timer');
              break;
            case 3:
              Navigator.pushNamed(context, '/craving-management');
              break;
            case 4:
              // Already on settings
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            ),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'timer',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'timer',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            ),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'psychology',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'psychology',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            ),
            label: 'Antojos',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Future<void> _exportUserData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exportar datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona el formato de exportación:'),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final csvData = await _dataService.exportDataAsCSV();
                        _showExportResult('CSV', csvData.length);
                      } catch (e) {
                        _showErrorMessage('Error al exportar CSV');
                      }
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('CSV'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        final jsonData = await _dataService.exportDataAsJSON();
                        _showExportResult('JSON', jsonData.length);
                      } catch (e) {
                        _showErrorMessage('Error al exportar JSON');
                      }
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('JSON'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showExportResult(String format, int dataSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Exportación $format Exitosa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Datos exportados correctamente\n'
              'Tamaño: ${(dataSize / 1024).toStringAsFixed(1)} KB\n\n'
              'En una aplicación real, estos datos se guardarían en tu dispositivo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚠️ Eliminar todos los datos'),
        content: const Text(
          'Esta acción eliminará permanentemente todos tus datos locales:\n\n'
          '• Historial de seguimiento\n'
          '• Configuraciones personalizadas\n'
          '• Logros obtenidos\n'
          '• Perfil de usuario\n\n'
          'Esta acción no se puede deshacer. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _dataService.clearAllData();
                _showSuccessMessage('Todos los datos eliminados correctamente');
                // Restart the app to reload default data
                await _loadData();
              } catch (e) {
                _showErrorMessage('Error al eliminar los datos');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'SmokeTracker',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 SmokeTracker App',
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: const Text(
            '🚭 Una aplicación completamente LOCAL diseñada para ayudarte a dejar de fumar '
            'y mantener un estilo de vida más saludable.\n\n'
            '✅ Sin conexión a internet requerida\n'
            '✅ Todos tus datos se mantienen en tu dispositivo\n'
            '✅ Privacidad total garantizada\n'
            '✅ Funciona offline en todo momento',
          ),
        ),
      ],
    );
  }

  void _showLocalHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🆘 Ayuda Local'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cómo usar SmokeTracker:\n\n'
                '🏠 INICIO: Ve tu progreso diario y registra eventos\n\n'
                '📊 PROGRESO: Analiza tus patrones y estadísticas\n\n'
                '⏰ TIMER: Cronómetro desde que dejaste de fumar\n\n'
                '🧠 ANTOJOS: Técnicas para superar momentos difíciles\n\n'
                '⚙️ CONFIGURACIÓN: Personaliza la aplicación\n\n'
                '💡 CONSEJOS:\n'
                '• Registra cada evento para mejor análisis\n'
                '• Usa las técnicas de manejo cuando sientas antojos\n'
                '• Revisa tu progreso regularmente para motivarte\n'
                '• Exporta tus datos para compartir con profesionales',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('📱 Almacenamiento Local'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información sobre tus datos:\n\n'
              '🔒 PRIVACIDAD TOTAL:\n'
              '• Todos tus datos se guardan solo en tu dispositivo\n'
              '• No se envía información a servidores externos\n'
              '• Funciona completamente sin internet\n\n'
              '💾 DATOS ALMACENADOS:\n'
              '• Historial de seguimiento\n'
              '• Configuraciones personales\n'
              '• Logros y estadísticas\n'
              '• Perfil de usuario\n\n'
              '🔧 GESTIÓN:\n'
              '• Puedes exportar tus datos en cualquier momento\n'
              '• Opción de eliminar todos los datos si es necesario\n'
              '• Los datos persisten entre sesiones de la aplicación',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}