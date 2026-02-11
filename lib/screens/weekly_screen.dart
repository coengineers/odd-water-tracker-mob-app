import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_spacing.dart';

class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summary'),
      ),
      body: Semantics(
        label: 'Weekly summary screen',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            children: [
              Card(
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Weekly bar chart coming in D4',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
