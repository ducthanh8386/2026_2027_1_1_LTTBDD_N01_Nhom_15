import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/workout_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import 'plan_edit_screen.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlans();
    });
  }

  void _loadPlans() {
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id;
      if (userId != null) {
        context.read<PlanProvider>().loadPlans(userId);
      }
    } catch (_) {}
  }

  Future<void> _confirmDeletePlan(WorkoutPlan plan) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deletePlan),
        content: Text('${l10n.deletePlanConfirm}\n"${plan.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l10n.deletePlan),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id;
      if (userId != null && plan.id != null) {
        final success =
            await context.read<PlanProvider>().deletePlan(plan.id!, userId);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.planDeletedSuccess)),
          );
        }
      }
    }
  }

  void _showSamplePlansBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      l10n.samplePlans,
                      style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'FitTrack cung cấp kế hoạch tập mẫu giúp bạn bắt đầu ngay lập tức mà không cần tự tạo từ đầu.',
                  style: Theme.of(sheetCtx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.fitness_center),
                    ),
                    title: const Text(
                      'Khởi động Toàn thân (Full Body)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      '2 ngày tập • Đầy đủ ngực, vai, tay và chân',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        final auth = context.read<AuthProvider>();
                        final userId = auth.currentUser?.id;
                        if (userId != null) {
                          final ok = await context
                              .read<PlanProvider>()
                              .applySamplePlan(
                                userId,
                                locale: locale.languageCode,
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? l10n.samplePlanApplied
                                      : 'Không tìm thấy kế hoạch mẫu',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(l10n.useSamplePlan),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPlanDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return dateStr;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutPlans),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: l10n.useSamplePlan,
            onPressed: _showSamplePlansBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.historyScreenDisabled,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.historyScreenDisabled)),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlanProvider>(
        builder: (context, planProvider, child) {
          if (planProvider.isLoading && planProvider.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (planProvider.plans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noPlansFound,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noPlansSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createPlan),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlanEditScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(l10n.useSamplePlan),
                      onPressed: _showSamplePlansBottomSheet,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadPlans();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: planProvider.plans.length,
              itemBuilder: (context, index) {
                final plan = planProvider.plans[index];

                return Dismissible(
                  key: ValueKey(plan.id ?? index),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _confirmDeletePlan(plan);
                    return false; // delete is handled inside _confirmDeletePlan
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.fitness_center),
                      ),
                      title: Text(
                        plan.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Tạo ngày: ${_formatPlanDate(plan.createdAt)}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlanEditScreen(planId: plan.id),
                              ),
                            );
                          } else if (value == 'delete') {
                            _confirmDeletePlan(plan);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.editPlan),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.deletePlan,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlanEditScreen(planId: plan.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.createPlan),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlanEditScreen(),
            ),
          );
        },
      ),
    );
  }
}
