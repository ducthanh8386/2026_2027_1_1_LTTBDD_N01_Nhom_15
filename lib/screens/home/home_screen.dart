import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/plan_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/stat_card.dart';
import '../progress/add_weight_sheet.dart';
import 'main_shell.dart';

/// The primary HomeScreen of FitTrack (Phase A08).
///
/// Features:
/// - Personalized greeting according to time of day and user name.
/// - 3 StatCards: Weekly sessions, Weekly volume, and Calories today.
/// - "Today's Workout" card: displays active session with resume action,
///   or next workout from user plans with quick start, or free workout option.
/// - Quick actions: Scan barcode (Open Food Facts) and Log weight (AddWeightSheet).
/// - Pull-to-refresh via RefreshIndicator loading weekly stats and nutrition diary.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didInitialLoad = false;
  WorkoutPlanFull? _suggestedPlanFull;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialFetch();
      });
    }
  }

  Future<void> _initialFetch() async {
    if (!mounted) return;
    final user = context.read<AuthProvider>().currentUser;
    final progress = context.read<ProgressProvider>();
    final nutrition = context.read<NutritionProvider>();
    final plan = context.read<PlanProvider>();

    progress.loadWeekly();
    nutrition.loadDiary();

    if (user?.id != null) {
      await plan.loadPlans(user!.id!);
      _loadFirstPlanDetails();
    }
  }

  Future<void> _loadFirstPlanDetails() async {
    if (!mounted) return;
    final plan = context.read<PlanProvider>();
    if (plan.plans.isNotEmpty) {
      try {
        final full = await plan.loadPlanDetails(plan.plans.first.id!);
        if (mounted) {
          setState(() {
            _suggestedPlanFull = full;
          });
        }
      } catch (_) {}
    } else {
      if (mounted) {
        setState(() {
          _suggestedPlanFull = null;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    final user = context.read<AuthProvider>().currentUser;
    final progress = context.read<ProgressProvider>();
    final nutrition = context.read<NutritionProvider>();
    final plan = context.read<PlanProvider>();

    final tasks = <Future>[
      progress.loadWeekly(),
      nutrition.loadDiary(),
    ];
    if (user?.id != null) {
      tasks.add(plan.loadPlans(user!.id!));
      tasks.add(progress.reload());
    }
    await Future.wait(tasks);
    await _loadFirstPlanDetails();
  }

  String _getGreeting(AppLocalizations l10n, String? name) {
    final displayName = (name != null && name.trim().isNotEmpty) ? name.trim() : '';
    final hour = DateTime.now().hour;

    if (displayName.isEmpty) {
      return l10n.welcome;
    }

    if (hour < 12) {
      return l10n.homeGreetingMorning(displayName);
    } else if (hour < 18) {
      return l10n.homeGreetingAfternoon(displayName);
    } else {
      return l10n.homeGreetingEvening(displayName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final progress = context.watch<ProgressProvider>();
    final nutrition = context.watch<NutritionProvider>();
    final workout = context.watch<WorkoutProvider>();
    final plan = context.watch<PlanProvider>();

    final weekly = progress.weeklySummary;
    final weeklySessions = weekly?.sessions ?? 0;
    final weeklyVolume = weekly?.totalVolume ?? 0.0;
    final todayKcal = nutrition.dailyTotals.kcal;
    final targetKcal = nutrition.dailyTarget;

    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMMEEEEd(locale);
    final todayFormatted = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: l10n.profile,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.logout,
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ================= 1. USER GREETING HEADER =================
            _buildGreetingHeader(theme, l10n, user, todayFormatted),
            const SizedBox(height: 20),

            // ================= 2. THREE STAT CARDS =================
            _buildStatCards(
              context: context,
              theme: theme,
              l10n: l10n,
              weeklySessions: weeklySessions,
              weeklyVolume: weeklyVolume,
              todayKcal: todayKcal,
              targetKcal: targetKcal,
            ),
            const SizedBox(height: 24),

            // ================= 3. TODAY'S WORKOUT CARD =================
            _buildTodayWorkoutCard(
              context: context,
              theme: theme,
              l10n: l10n,
              user: user,
              workout: workout,
              plan: plan,
            ),
            const SizedBox(height: 24),

            // ================= 4. QUICK ACTIONS =================
            _buildQuickActions(context: context, theme: theme, l10n: l10n),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(
    ThemeData theme,
    AppLocalizations l10n,
    dynamic user,
    String todayFormatted,
  ) {
    final userName = user?.name as String?;
    final initial = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim()[0].toUpperCase()
        : 'U';

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.profile);
          },
          child: CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(l10n, userName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                todayFormatted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required int weeklySessions,
    required double weeklyVolume,
    required double todayKcal,
    required double targetKcal,
  }) {
    final volumeFormatter = NumberFormat.compact();
    final volumeString = '${volumeFormatter.format(weeklyVolume.round())} kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeWeeklyOverview,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 1: Buổi tập tuần
            Expanded(
              child: StatCard(
                title: l10n.homeWeeklySessions,
                value: '$weeklySessions ${l10n.homeUnitSessions}',
                subtitle: l10n.homeWeeklyOverview,
                icon: Icons.fitness_center_rounded,
                color: theme.colorScheme.primary,
                onTap: () {
                  MainShell.switchTab(context, 1);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Card 2: Khối lượng tuần
            Expanded(
              child: StatCard(
                title: l10n.homeWeeklyVolume,
                value: volumeString,
                subtitle: 'kg',
                icon: Icons.trending_up_rounded,
                color: Colors.purple,
                onTap: () {
                  MainShell.switchTab(context, 2);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Card 3: Calo hôm nay
            Expanded(
              child: StatCard(
                title: l10n.homeTodayCalories,
                value: '${todayKcal.round()} kcal',
                subtitle: l10n.homeTarget('${targetKcal.round()}'),
                icon: Icons.local_fire_department_rounded,
                color: Colors.deepOrange,
                onTap: () {
                  MainShell.switchTab(context, 3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayWorkoutCard({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required dynamic user,
    required WorkoutProvider workout,
    required PlanProvider plan,
  }) {
    // 1. If an active session is currently running
    if (workout.isSessionActive) {
      final sessionName = workout.activeDayFull?.day.name ??
          workout.activeSession?.planDayName ??
          l10n.freeWorkout;

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.homeActiveSessionRunning,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    workout.formattedDuration,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sessionName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.workoutSession);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.homeContinueWorkout),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. If user has plans and a suggested plan is loaded
    if (plan.plans.isNotEmpty) {
      final suggestedDay = (_suggestedPlanFull?.days.isNotEmpty == true)
          ? _suggestedPlanFull!.days.first
          : null;
      final planName = _suggestedPlanFull?.plan.name ?? plan.plans.first.name;
      final dayName = suggestedDay?.day.name ?? l10n.dayName;
      final exerciseCount = suggestedDay?.exercises.length ?? 0;

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.homeTodayWorkout,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      MainShell.switchTab(context, 1);
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(l10n.homeViewAllPlans),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$planName • $dayName',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$exerciseCount ${l10n.totalExercises.toLowerCase()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (user?.id == null) return;
                        await workout.startWorkoutSession(
                          userId: user.id!,
                          planDayFull: suggestedDay,
                          planFull: _suggestedPlanFull,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pushNamed(AppRoutes.workoutSession);
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.homeStartWorkout),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      if (user?.id == null) return;
                      await workout.startWorkoutSession(userId: user.id!);
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(AppRoutes.workoutSession);
                      }
                    },
                    child: Text(l10n.freeWorkout),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 3. If user has no plans yet
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.homeTodayWorkout,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.homeNoPlanYet,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeNoPlanSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (user?.id == null) return;
                      await workout.startWorkoutSession(userId: user.id!);
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(AppRoutes.workoutSession);
                      }
                    },
                    icon: const Icon(Icons.bolt_rounded),
                    label: Text(l10n.homeFreeWorkoutPrompt),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    MainShell.switchTab(context, 1);
                  },
                  child: Text(l10n.createPlan),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeQuickActions,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Quick Action 1: Quét mã vạch
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.barcodeScan);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 20,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.homeQuickScanBarcode,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Quick Action 2: Ghi cân nặng
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    AddWeightSheet.show(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.monitor_weight_outlined,
                            size: 20,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.homeQuickLogWeight,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
