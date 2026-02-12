import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

class EditTargetSheet extends StatefulWidget {
  const EditTargetSheet({super.key, required this.currentTarget});

  final int currentTarget;

  static Future<int?> show(BuildContext context, {required int currentTarget}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditTargetSheet(currentTarget: currentTarget),
    );
  }

  @override
  State<EditTargetSheet> createState() => _EditTargetSheetState();
}

class _EditTargetSheetState extends State<EditTargetSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentTarget}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter an amount');
      return;
    }

    final amount = int.tryParse(text) ?? 0;
    if (amount < 250) {
      setState(() => _errorText = 'Target must be at least 250 ml');
      return;
    }
    if (amount > 10000) {
      setState(() => _errorText = 'Target must be at most 10,000 ml');
      return;
    }

    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Semantics(
      label: 'Edit daily target sheet',
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.space4,
          right: AppSpacing.space4,
          top: AppSpacing.space4,
          bottom: bottomInset + AppSpacing.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Edit Daily Target',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.space4),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter target',
                suffixText: 'ml',
                errorText: _errorText,
              ),
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.space4),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
