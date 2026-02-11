import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTarget = ref.watch(dailyTargetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Semantics(
        label: 'Settings screen',
        child: ListView(
          children: [
            dailyTarget.when(
              data: (target) => ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Daily Target'),
                subtitle: Text('$target ml'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Full editor coming in D5
                },
              ),
              loading: () => const ListTile(
                leading: Icon(Icons.flag_outlined),
                title: Text('Daily Target'),
                subtitle: Text('Loading...'),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Daily Target'),
                subtitle: Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
