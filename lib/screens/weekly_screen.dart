import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: const Center(
          child: Text('Weekly Summary'),
        ),
      ),
    );
  }
}
