import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/progress_provider.dart';

/// Modal bottom sheet for logging or editing a weight entry.
/// Owned by Partner B (Module B2).
class AddWeightSheet extends StatefulWidget {
  final DateTime? initialDate;
  final double? initialWeight;

  const AddWeightSheet({super.key, this.initialDate, this.initialWeight});

  static Future<void> show(
    BuildContext context, {
    DateTime? date,
    double? weight,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddWeightSheet(initialDate: date, initialWeight: weight),
    );
  }

  @override
  State<AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends State<AddWeightSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _weightController = TextEditingController(
      text: widget.initialWeight != null ? widget.initialWeight.toString() : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);

    try {
      await context.read<ProgressProvider>().addWeight(_selectedDate, weight);
      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.progressWeightSaved ?? 'Weight recorded successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dateDisplay = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.progressAddWeight ?? 'Log Weight',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Date Selector
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n?.progressDateLabel ?? 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  child: Text(
                    dateDisplay,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Weight Input (kg)
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n?.progressWeightInputLabel ?? 'Weight (kg)',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.fieldRequired ?? 'This field is required';
                  }
                  final n = double.tryParse(value.trim().replaceAll(',', '.'));
                  if (n == null || n < 20 || n > 300) {
                    return l10n?.progressInvalidWeight ??
                        'Please enter a valid weight between 20 and 300 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 3. Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n?.progressSaveWeight ?? 'Save Weight',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
