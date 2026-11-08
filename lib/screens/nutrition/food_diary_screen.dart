import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/repositories/food_log_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nutrition_provider.dart';

class FoodDiaryScreen extends StatelessWidget {
  const FoodDiaryScreen({super.key});

  void _showAddFoodBottomSheet(BuildContext context, [String? mealType]) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.addFood,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                ),
                title: Text(l10n.scanBarcode),
                subtitle: const Text('Quét mã vạch bằng camera'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.barcodeScan,
                    arguments: mealType,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_note, color: Colors.green),
                ),
                title: Text(l10n.manualEntry),
                subtitle: const Text('Nhập tên và dinh dưỡng món ăn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.manualFood,
                    arguments: {
                      'mealType': mealType,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGramsDialog(BuildContext context, FoodLogWithFood item) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: item.entry.grams.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editGrams),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.food?.name ?? 'Món ăn',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.servingSize,
                suffixText: 'g',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final newGrams = double.tryParse(controller.text.replaceAll(',', '.'));
              if (newGrams != null && newGrams > 0) {
                Navigator.pop(ctx);
                await context.read<NutritionProvider>().updateEntryGrams(
                      item: item,
                      newGrams: newGrams,
                    );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<NutritionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.scanBarcode,
            onPressed: () => _showAddFoodBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadDiary(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Date Navigation Bar
              _buildDateNavigator(context, provider, l10n),
              const SizedBox(height: 16),

              // 2. Calorie Summary & Macro Card
              _buildSummaryCard(context, provider, l10n, theme),
              const SizedBox(height: 20),

              // 3. Four Meals Sections
              _buildMealSection(
                context: context,
                provider: provider,
                l10n: l10n,
                mealKey: 'breakfast',
                mealTitle: l10n.mealBreakfast,
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.amber,
              ),
              const SizedBox(height: 12),
              _buildMealSection(
                context: context,
                provider: provider,
                l10n: l10n,
                mealKey: 'lunch',
                mealTitle: l10n.mealLunch,
                icon: Icons.light_mode,
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildMealSection(
                context: context,
                provider: provider,
                l10n: l10n,
                mealKey: 'dinner',
                mealTitle: l10n.mealDinner,
                icon: Icons.nights_stay_outlined,
                iconColor: Colors.indigo,
              ),
              const SizedBox(height: 12),
              _buildMealSection(
                context: context,
                provider: provider,
                l10n: l10n,
                mealKey: 'snack',
                mealTitle: l10n.mealSnack,
                icon: Icons.coffee_outlined,
                iconColor: Colors.teal,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'food_diary_fab',
        onPressed: () => _showAddFoodBottomSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addFood),
      ),
    );
  }

  Widget _buildDateNavigator(
    BuildContext context,
    NutritionProvider provider,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final isToday = provider.selectedDate.year == now.year &&
        provider.selectedDate.month == now.month &&
        provider.selectedDate.day == now.day;

    final dateText = isToday
        ? '${l10n.today}, ${provider.selectedDate.day.toString().padLeft(2, '0')}/${provider.selectedDate.month.toString().padLeft(2, '0')}/${provider.selectedDate.year}'
        : '${provider.selectedDate.day.toString().padLeft(2, '0')}/${provider.selectedDate.month.toString().padLeft(2, '0')}/${provider.selectedDate.year}';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => provider.previousDay(),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: provider.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  provider.setDate(picked);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      dateText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => provider.nextDay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    NutritionProvider provider,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final consumed = provider.dailyTotals.kcal;
    final target = provider.dailyTarget;
    final remaining = provider.remainingKcal;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCalorieColumn('Mục tiêu', '${target.round()}', Colors.grey.shade700),
                Text('-', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                _buildCalorieColumn('Đã nạp', '${consumed.round()}', theme.colorScheme.primary),
                Text('=', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                _buildCalorieColumn('Còn lại', '${remaining.round()}', Colors.green.shade700),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  consumed > target ? Colors.deepOrange : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroSummary('Protein', '${provider.dailyTotals.protein.toStringAsFixed(1)}g', Colors.blue),
                _buildMacroSummary('Carbs', '${provider.dailyTotals.carbs.toStringAsFixed(1)}g', Colors.orange),
                _buildMacroSummary('Fat', '${provider.dailyTotals.fat.toStringAsFixed(1)}g', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMacroSummary(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealSection({
    required BuildContext context,
    required NutritionProvider provider,
    required AppLocalizations l10n,
    required String mealKey,
    required String mealTitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final items = provider.entriesByMeal[mealKey] ?? [];
    final totalKcal = items.fold<double>(0.0, (sum, i) => sum + i.entry.kcal);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: iconColor),
        title: Text(
          mealTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${totalKcal.round()} kcal',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              tooltip: l10n.addFood,
              onPressed: () => _showAddFoodBottomSheet(context, mealKey),
            ),
          ],
        ),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.noFoodInMeal,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final item = items[index];
                final foodName = item.food?.name ?? 'Món ăn';
                final grams = item.entry.grams;
                final kcal = item.entry.kcal;
                final p = item.entry.protein;
                final c = item.entry.carbs;
                final f = item.entry.fat;

                return Dismissible(
                  key: ValueKey('food_entry_${item.entry.id}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (dir) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(l10n.deleteFoodEntry),
                            content: Text(l10n.deleteFoodConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: Text(l10n.deleteFoodEntry),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    provider.deleteEntry(item.entry.id!);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      foodName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${grams.round()}g  •  P: ${p.toStringAsFixed(1)}g  C: ${c.toStringAsFixed(1)}g  F: ${f.toStringAsFixed(1)}g',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${kcal.round()} kcal',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _showEditGramsDialog(context, item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
