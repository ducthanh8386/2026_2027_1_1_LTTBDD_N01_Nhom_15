import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PlanListScreen extends StatelessWidget {
  const PlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navWorkout),
      ),
      body: Center(
        child: Text('${l10n.navWorkout} (A05)'),
      ),
    );
  }
}
