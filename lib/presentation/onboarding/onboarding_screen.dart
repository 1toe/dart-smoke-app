import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/local_data_service.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final LocalDataService _dataService = LocalDataService();
  
  // User data collection
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime? _quitDate;
  int _cigarettesPerDay = 20;
  double _costPerPack = 5.0;
  int _cigarettesPerPack = 20;

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        _buildWelcomePage(),
        _buildFeaturePage(),
        _buildSetupPage(),
      ],
      onDone: () => _completeOnboarding(),
      onSkip: () => _completeOnboarding(),
      showSkipButton: false,
      showNextButton: true,
      showDoneButton: true,
      next: Icon(Icons.arrow_forward, color: AppTheme.primaryLight),
      done: Text(
        'Comenzar',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryLight,
          fontWeight: FontWeight.bold,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: AppTheme.dividerLight,
        activeColor: AppTheme.primaryLight,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    );
  }

  PageViewModel _buildWelcomePage() {
    return PageViewModel(
      title: '¡Bienvenido a SmokeTracker!',
      body: 'Tu compañero en el viaje hacia una vida libre de humo. '
          'Te ayudaremos a rastrear tu progreso, manejar antojos y celebrar tus logros.',
      image: Center(
        child: Icon(
          Icons.favorite,
          size: 40.w,
          color: AppTheme.primaryLight,
        ),
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageViewModel _buildFeaturePage() {
    return PageViewModel(
      title: 'Características principales',
      bodyWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            _buildFeatureItem(
              Icons.timeline,
              'Seguimiento de progreso',
              'Visualiza tu viaje hacia una vida sin humo',
            ),
            SizedBox(height: 2.h),
            _buildFeatureItem(
              Icons.psychology,
              'Manejo de antojos',
              'Técnicas efectivas cuando necesites apoyo',
            ),
            SizedBox(height: 2.h),
            _buildFeatureItem(
              Icons.emoji_events,
              'Logros y recompensas',
              'Celebra cada hito en tu camino',
            ),
            SizedBox(height: 2.h),
            _buildFeatureItem(
              Icons.savings,
              'Ahorro de dinero',
              'Observa cuánto estás ahorrando',
            ),
          ],
        ),
      ),
      decoration: _getPageDecoration(),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 8.w),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PageViewModel _buildSetupPage() {
    return PageViewModel(
      title: 'Configuración inicial',
      bodyWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Por favor, proporciona algunos detalles básicos:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 3.h),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tu nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value ?? '',
                ),
                SizedBox(height: 2.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today, color: AppTheme.primaryLight),
                  title: Text('Fecha de abandono'),
                  subtitle: Text(
                    _quitDate == null
                        ? 'Selecciona tu fecha'
                        : '${_quitDate!.day}/${_quitDate!.month}/${_quitDate!.year}',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _quitDate = date;
                      });
                    }
                  },
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Cigarrillos por día (antes)',
                    prefixIcon: Icon(Icons.smoking_rooms),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '20',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un número';
                    }
                    return null;
                  },
                  onSaved: (value) => _cigarettesPerDay = int.tryParse(value ?? '20') ?? 20,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Costo por paquete (€)',
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: '5.0',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un precio';
                    }
                    return null;
                  },
                  onSaved: (value) => _costPerPack = double.tryParse(value ?? '5.0') ?? 5.0,
                ),
              ],
            ),
          ),
        ),
      ),
      decoration: _getPageDecoration(),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryLight,
      ),
      bodyTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: AppTheme.textSecondaryLight,
      ),
      imagePadding: EdgeInsets.only(top: 10.h),
      pageColor: AppTheme.backgroundLight,
      contentMargin: EdgeInsets.symmetric(horizontal: 5.w),
    );
  }

  Future<void> _completeOnboarding() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        // Save user profile
        final profile = {
          'name': _name,
          'joinDate': DateTime.now().toIso8601String(),
          'cigarettesPerDay': _cigarettesPerDay,
          'costPerPack': _costPerPack,
          'cigarettesPerPack': _cigarettesPerPack,
        };
        await _dataService.saveUserProfile(profile);

        // Save quit date if provided
        if (_quitDate != null) {
          await _dataService.setQuitDate(_quitDate!);
        }

        // Mark onboarding as completed
        await _dataService.setOnboardingCompleted(true);

        // Navigate to dashboard
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.dashboardHome);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
