import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/local_data_service.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/craving_management_card_widget.dart';
import './widgets/greeting_card_widget.dart';
import './widgets/health_metrics_card_widget.dart';
import './widgets/today_smoking_card_widget.dart';
import './widgets/weekly_progress_chart_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final LocalDataService _dataService = LocalDataService();

  // Data loaded from local storage
  List<Map<String, dynamic>> smokingData = [];
  List<Map<String, dynamic>> weeklyData = [];
  List<Map<String, dynamic>> achievements = [];
  List<String> healthBenefits = [];
  Map<String, dynamic> statistics = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Load all local data
      smokingData = await _dataService.getSmokingData();
      achievements = await _dataService.getAchievements();
      healthBenefits = _dataService.getHealthBenefits();
      weeklyData = _dataService.getWeeklyProgressData();
      statistics = _dataService.calculateStatistics();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final daysSinceQuit = statistics['daysSinceQuit'] ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          color: AppTheme.lightTheme.primaryColor,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingCardWidget(
                        userName: "María",
                        currentStreak: daysSinceQuit,
                        streakType: daysSinceQuit == 1
                            ? "día sin fumar"
                            : "días sin fumar",
                      ),
                      SizedBox(height: 2.h),
                      TodaySmokingCardWidget(
                        todayCount: smokingData.where((entry) {
                          final entryDate = DateTime.parse(entry['timestamp']);
                          final today = DateTime.now();
                          return entryDate.year == today.year &&
                              entryDate.month == today.month &&
                              entryDate.day == today.day;
                        }).length,
                        dailyGoal: 0, // Goal is 0 since we're quitting
                        onAddCigarette: _addCigarette,
                        onEditEntry: _editEntry,
                        onDeleteEntry: _deleteEntry,
                        onAddNote: _addNote,
                      ),
                      SizedBox(height: 2.h),
                      HealthMetricsCardWidget(
                        moneySaved: (statistics['moneySaved'] ?? 0).toDouble(),
                        timeRegained: statistics['timeRegained'] ?? 0,
                        healthBenefits: healthBenefits,
                        onTap: () => _navigateToAnalytics(),
                      ),
                      SizedBox(height: 2.h),
                      WeeklyProgressChartWidget(
                        weeklyData: weeklyData,
                        onTap: () => _navigateToAnalytics(),
                      ),
                      SizedBox(height: 2.h),
                      CravingManagementCardWidget(
                        techniques: mockTechniques,
                        onTechniqueSelected: _startTechnique,
                        onViewAll: () => _navigateToCravingManagement(),
                      ),
                      SizedBox(height: 2.h),
                      AchievementBadgesWidget(
                        achievements: achievements
                            .where((a) => a['isUnlocked'] == true)
                            .toList(),
                        onViewAll: () => _showAllAchievements(),
                      ),
                      SizedBox(
                          height: 8.h), // Reduced space for better scrolling
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCigarette,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 6.w,
        ),
        label: Text(
          'Registrar cigarrillo',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.lightTheme.cardColor,
          selectedItemColor: AppTheme.lightTheme.primaryColor,
          unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'home',
                color: _selectedIndex == 0
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'analytics',
                color: _selectedIndex == 1
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              label: 'Análisis',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'timer',
                color: _selectedIndex == 2
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              label: 'Cronómetro',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'psychology',
                color: _selectedIndex == 3
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              label: 'Antojos',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'person',
                color: _selectedIndex == 4
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home, do nothing
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
        Navigator.pushNamed(context, '/settings-profile');
        break;
    }
  }

  void _addCigarette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 4.w,
          right: 4.w,
          top: 2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Registrar evento',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            // Form fields with better responsive design
            TextField(
              decoration: InputDecoration(
                labelText: 'Ubicación (opcional)',
                hintText: 'Ej: Casa, oficina, café...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              ),
              onChanged: (value) => _currentLocation = value,
            ),
            SizedBox(height: 1.5.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Desencadenante (opcional)',
                hintText: 'Ej: Estrés, aburrimiento, social...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              ),
              onChanged: (value) => _currentTrigger = value,
            ),
            SizedBox(height: 1.5.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Cualquier observación adicional...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              ),
              maxLines: 2,
              onChanged: (value) => _currentNote = value,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSmokingEntry,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Registrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Form data variables
  String _currentLocation = '';
  String _currentTrigger = '';
  String _currentNote = '';

  Future<void> _saveSmokingEntry() async {
    try {
      await _dataService.addSmokingEntry({
        'location': _currentLocation,
        'trigger': _currentTrigger,
        'note': _currentNote,
        'intensity': 5, // Default intensity
      });

      Navigator.pop(context);
      _showSuccessMessage('Evento registrado correctamente');
      await _loadData(); // Reload data

      // Reset form data
      _currentLocation = '';
      _currentTrigger = '';
      _currentNote = '';
    } catch (e) {
      _showErrorMessage('Error al registrar el evento');
    }
  }

  void _editEntry(int index) {
    _showSuccessMessage('Función de edición próximamente');
  }

  Future<void> _deleteEntry(int index) async {
    if (index < smokingData.length) {
      try {
        await _dataService.deleteSmokingEntry(smokingData[index]['id']);
        _showSuccessMessage('Entrada eliminada');
        await _loadData(); // Reload data
      } catch (e) {
        _showErrorMessage('Error al eliminar la entrada');
      }
    }
  }

  void _addNote(int index) {
    _showSuccessMessage('Función de notas próximamente');
  }

  void _navigateToAnalytics() {
    Navigator.pushNamed(context, '/progress-analytics');
  }

  void _navigateToCravingManagement() {
    Navigator.pushNamed(context, '/craving-management');
  }

  void _startTechnique(String techniqueId) {
    final technique = mockTechniques.firstWhere(
      (t) => t["id"] == techniqueId,
      orElse: () => mockTechniques.first,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(technique["name"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(technique["description"]),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text('Duración: ${technique["duration"]} minutos'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/craving-management');
            },
            child: const Text('Comenzar'),
          ),
        ],
      ),
    );
  }

  void _showAllAchievements() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 80.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Todos los logros',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return ListTile(
                    leading: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: achievement["icon"],
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                    title: Text(achievement["name"]),
                    subtitle: Text(achievement["description"]),
                    trailing: Chip(
                      label: Text(achievement["level"]),
                      backgroundColor: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
