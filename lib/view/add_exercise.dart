import 'package:flutter/material.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      // Process the data, e.g., save to a database or state management
      print('Exercise Name: ${_nameController.text}');
      print('Description: ${_descriptionController.text}');
      print('Weight: ${_weightController.text}');
      print('Reps: ${_repsController.text}');
      print('Distance: ${_distanceController.text}');
      print('Time: ${_timeController.text}');
      // Navigate back to the home screen or show a success message
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time'),
                keyboardType: TextInputType.datetime, // Or appropriate type for time input
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: _saveExercise,
                  child: const Text('Save Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
