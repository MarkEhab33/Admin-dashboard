import 'package:flutter/material.dart';
import '../Theme.dart';
import 'create_quiz_screen.dart';

class QuizzesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Manage Quizzes',
              style: AppTheme.headingLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),  // Make icon white
              label: const Text('Create New Quiz'),
              style: AppTheme.primaryButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateQuizScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
