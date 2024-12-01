import 'dart:async'; // For Timer
import 'package:flutter/material.dart';

void main() {
  runApp(FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FitnessDashboard(),
    );
  }
}

class FitnessDashboard extends StatefulWidget {
  @override
  _FitnessDashboardState createState() => _FitnessDashboardState();
}

class _FitnessDashboardState extends State<FitnessDashboard> {
  int steps = 5000;
  double calories = 250.0;
  double distance = 3.5;

  int dailyStepGoal = 10000;
  double dailyCalorieGoal = 500.0;
  double dailyDistanceGoal = 8.0;

  late Timer _timer;
  bool isWalking = false; // Track walking state

  int? filteredSteps;
  double? filteredCalories;
  double? filteredDistance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Timer function to update stats periodically (simulate walking)
  void _startWalking() {
    if (!isWalking) {
      setState(() {
        isWalking = true;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          steps += 10; // Simulate walking by adding 10 steps every second
          calories += 0.5; // Simulate calories burned
          distance += 0.01; // Simulate distance walked (in kilometers)
        });
      });
    }
  }

  // Stop the walking timer
  void _stopWalking() {
    if (isWalking) {
      setState(() {
        isWalking = false;
      });
      _timer.cancel(); // Cancel the timer when walking is stopped
    }
  }

  void _updateGoals(int steps, double calories, double distance) {
    setState(() {
      dailyStepGoal = steps;
      dailyCalorieGoal = calories;
      dailyDistanceGoal = distance;
    });
  }

  void _applyFilter(int? steps, double? calories, double? distance) {
    setState(() {
      filteredSteps = steps;
      filteredCalories = calories;
      filteredDistance = distance;
    });
  }

  @override
  Widget build(BuildContext context) {
    double stepProgress = steps / dailyStepGoal.toDouble();
    double calorieProgress = calories / dailyCalorieGoal;
    double distanceProgress = distance / dailyDistanceGoal;

    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracker'),
        centerTitle: true,
        actions: [
          // Filter Button
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterDialog(
                  onApplyFilter: _applyFilter,
                ),
              );
            },
          ),
          // Settings Button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalSettingScreen(
                    dailyStepGoal: dailyStepGoal,
                    dailyCalorieGoal: dailyCalorieGoal,
                    dailyDistanceGoal: dailyDistanceGoal,
                    onSave: _updateGoals,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: stepProgress > 0.5
                ? [Colors.green.shade400, Colors.blue.shade600]
                : [Colors.orange.shade300, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(),
              SizedBox(height: 20),
              FitnessCard(
                title: 'Steps',
                value: '${filteredSteps ?? steps}',
                unit: 'steps',
                icon: Icons.directions_walk,
                progress: (filteredSteps ?? steps) / dailyStepGoal.toDouble(),
              ),
              FitnessCard(
                title: 'Calories',
                value: (filteredCalories ?? calories).toStringAsFixed(1),
                unit: 'kcal',
                icon: Icons.local_fire_department,
                progress: (filteredCalories ?? calories) / dailyCalorieGoal,
              ),
              FitnessCard(
                title: 'Distance',
                value: (filteredDistance ?? distance).toStringAsFixed(1),
                unit: 'km',
                icon: Icons.directions_run,
                progress: (filteredDistance ?? distance) / dailyDistanceGoal,
              ),
              Spacer(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isWalking) {
                    _stopWalking(); // Stop walking when clicked
                  } else {
                    _startWalking(); // Start walking when clicked
                  }
                },
                child: Text(isWalking ? 'Stop Walking' : 'Start Walking'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(fontSize: 18),
                  primary: isWalking ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Steps', steps.toDouble(), dailyStepGoal.toDouble()),
                _buildSummaryItem('Calories', calories, dailyCalorieGoal),
                _buildSummaryItem('Distance', distance, dailyDistanceGoal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, double goal) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class FitnessCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final double progress;

  const FitnessCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            Icon(icon, size: 40, color: Colors.black87),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$value $unit',
          style: TextStyle(fontSize: 16),
        ),
        trailing: Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final Function(int?, double?, double?) onApplyFilter;

  const FilterDialog({Key? key, required this.onApplyFilter}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  int? filteredSteps;
  double? filteredCalories;
  double? filteredDistance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter Goals'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Steps',
                hintText: 'Enter step goal',
              ),
              onChanged: (value) {
                setState(() {
                  filteredSteps = int.tryParse(value);
                });
              },
            ),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                hintText: 'Enter calorie goal',
              ),
              onChanged: (value) {
                setState(() {
                  filteredCalories = double.tryParse(value);
                });
              },
            ),
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Distance',
                hintText: 'Enter distance goal',
              ),
              onChanged: (value) {
                setState(() {
                  filteredDistance = double.tryParse(value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onApplyFilter(filteredSteps, filteredCalories, filteredDistance);
            Navigator.of(context).pop();
          },
          child: Text('Apply Filter'),
        ),
      ],
    );
  }
}

class GoalSettingScreen extends StatelessWidget {
  final int dailyStepGoal;
  final double dailyCalorieGoal;
  final double dailyDistanceGoal;
  final Function(int, double, double) onSave;

  GoalSettingScreen({
    required this.dailyStepGoal,
    required this.dailyCalorieGoal,
    required this.dailyDistanceGoal,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _stepGoalController = TextEditingController(text: dailyStepGoal.toString());
    final TextEditingController _calorieGoalController = TextEditingController(text: dailyCalorieGoal.toStringAsFixed(1));
    final TextEditingController _distanceGoalController = TextEditingController(text: dailyDistanceGoal.toStringAsFixed(1));

    return Scaffold(
      appBar: AppBar(title: Text('Goal Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _stepGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Daily Steps Goal'),
            ),
            TextField(
              controller: _calorieGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Daily Calories Goal'),
            ),
            TextField(
              controller: _distanceGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Daily Distance Goal'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onSave(
                  int.parse(_stepGoalController.text),
                  double.parse(_calorieGoalController.text),
                  double.parse(_distanceGoalController.text),
                );
                Navigator.of(context).pop();
              },
              child: Text('Save Goals'),
            ),
          ],
        ),
      ),
    );
  }
}