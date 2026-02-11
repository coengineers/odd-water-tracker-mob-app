import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlyScreen extends ConsumerWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Patterns'),
      ),
      body: Semantics(
        label: 'Monthly patterns screen',
        child: const Center(
          child: Text('Monthly Patterns'),
        ),
      ),
    );
  }
}
