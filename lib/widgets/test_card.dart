import 'package:flutter/material.dart';
import '../models/test.dart';

class TestCard extends StatelessWidget {
  final Test test;
  final Function(Test) onUpdate;
  final Function(Test) onDelete;

  const TestCard({
    Key? key,
    required this.test,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Type: ${test.type}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => onUpdate(test),
                      tooltip: 'Edit Test',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(test),
                      tooltip: 'Delete Test',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Value: ${test.value}'),
            Text('Date: ${test.date.toLocal().toString().split('.')[0]}'),
          ],
        ),
      ),
    );
  }
}
