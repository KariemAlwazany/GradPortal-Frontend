// package:flutter_project/screens/Student/CompleteSign/Page1.dart
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Student/CompleteSign/type.dart';

const Color primaryColor = Color(0xFF3B4280);

class ProjectTypePage extends StatelessWidget {
  final VoidCallback onNext;
  const ProjectTypePage({required this.onNext, super.key});

  void setType(String type) {
    var typeGP = type;
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 160),
            const Text(
              'Choose Your Project Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () => setType("Software"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Software',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setType("Hardware"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Hardware',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
