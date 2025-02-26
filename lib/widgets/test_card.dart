import 'package:flutter/material.dart';
import '../models/test.dart';

class TestCard extends StatelessWidget {
  final Test test;

  const TestCard({Key? key, required this.test}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${test.type}',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Text('Value: ${test.value}'),
            Text('Date: ${test.date.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
