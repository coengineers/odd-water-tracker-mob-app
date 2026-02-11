import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily'),
      ),
      body: Semantics(
        label: 'Daily screen',
        child: const Center(
          child: Text('Daily'),
        ),
      ),
    );
  }
}
