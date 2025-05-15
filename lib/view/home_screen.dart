import 'package:flutter/material.dart';
import 'package:myapp/view/add_exercise.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double buttonWidth = constraints.maxWidth * 0.4;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Añadir ejercicio',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: buttonWidth,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to routines screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Añadir rutina',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


