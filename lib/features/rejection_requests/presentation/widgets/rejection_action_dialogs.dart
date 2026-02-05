import 'package:flutter/material.dart';

class ApproveExcuseDialog extends StatefulWidget {
  final String driverName;

  const ApproveExcuseDialog({
    super.key,
    required this.driverName,
  });

  @override
  State<ApproveExcuseDialog> createState() => _ApproveExcuseDialogState();
}

class _ApproveExcuseDialogState extends State<ApproveExcuseDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('قبول الاعتذار'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد قبول اعتذار السائق ${widget.driverName}؟'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'تعليق (اختياري)',
                border: OutlineInputBorder(),
                hintText: 'أضف تعليقاً إن أردت',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('قبول'),
        ),
      ],
    );
  }
}

class RejectExcuseDialog extends StatefulWidget {
  final String driverName;

  const RejectExcuseDialog({
    super.key,
    required this.driverName,
  });

  @override
  State<RejectExcuseDialog> createState() => _RejectExcuseDialogState();
}

class _RejectExcuseDialogState extends State<RejectExcuseDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('رفض الاعتذار'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل تريد رفض اعتذار السائق ${widget.driverName}؟'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'سبب الرفض (مطلوب)',
                  border: OutlineInputBorder(),
                  hintText: 'اكتب سبب رفض الاعتذار',
                ),
                maxLines: 3,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يجب كتابة سبب الرفض';
                  }
                  if (value.trim().length < 10) {
                    return 'السبب يجب أن يكون 10 أحرف على الأقل';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('رفض'),
        ),
      ],
    );
  }
}
