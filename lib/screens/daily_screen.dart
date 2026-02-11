import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/water_providers.dart';
import '../theme/app_spacing.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotal = ref.watch(todayTotalProvider);
    final todayEntries = ref.watch(todayEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily'),
      ),
      body: Semantics(
        label: 'Daily screen',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today total header
              todayTotal.when(
                data: (total) => Text(
                  'Today: $total ml',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: AppSpacing.space4),

              // Entries list
              Expanded(
                child: todayEntries.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Text(
                          'No entries yet today',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final time = entry.entryTs.substring(11, 16);
                        return ListTile(
                          leading: const Icon(Icons.water_drop_outlined),
                          title: Text('${entry.amountMl} ml'),
                          trailing: Text(time),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
