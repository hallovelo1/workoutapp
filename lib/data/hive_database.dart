import 'package:hive_flutter/hive_flutter.dart';
import 'package:workouttutorial/datetime/date_time.dart';

import 'package:workouttutorial/models/exercise.dart';
import 'package:workouttutorial/models/workout.dart';

class HiveDatabase {
  // reference out hive box
  final _myBox = Hive.box('workout_database5');

  // check if there is already data stored, if not, recored the start date
  bool previousDataExists() {
    if (_myBox.isEmpty) {
      print('previous data doea NOT exist');
      _myBox.put('START_DATE', todaysDateYYYYMMDD());
      return false;
    } else {
      print('previous data exists');
      return true;
    }
  }

  // return start date as yyyymmdd
  String getStartDate() {
    return _myBox.get('START_DATE');
  }

  // write data
  void saveToDatabase(List<Workout> workouts) {
    // convert objects into lists of strings so that we can save in hive
    final workoutList = convertObjectToWorkoutList(workouts);
    final exerciseList = convertObjectToExerciseList(workouts);

    if (exerciseCompleted(workouts)) {
      _myBox.put('COMPLETION_STATUS_${todaysDateYYYYMMDD()}', 1);
    } else {
      _myBox.put('COMPLETION_STATUS_${todaysDateYYYYMMDD()}', 0);
    }

    // save into hive
    _myBox.put('WORKOUTS', workoutList);
    _myBox.put('EXERCISES', exerciseList);
  }

  // read data, and return a list of workouts
  List<Workout> readFromDatabase() {
    List<Workout> mySavedWorkouts = [];

    List<String> workoutNames = _myBox.get('WORKOUTS');
    final exerciseDetails = _myBox.get('EXERCISES');

    // create workout objects
    for (int i = 0; i < workoutNames.length; i++) {
      // each workout can have multiple exercises
      List<Exercise> exercisesInEachWorkout = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        // so add each exercise into a list
        exercisesInEachWorkout.add(
          Exercise(
            name: exerciseDetails[i][j][0],
            weight: exerciseDetails[i][j][1],
            reps: exerciseDetails[i][j][2],
            sets: exerciseDetails[i][j][3],
            isCompleted: exerciseDetails[i][j][4] == 'true' ? true : false,
          ),
        );
      }

      // create individual workout
      Workout workout =
          Workout(name: workoutNames[i], exercises: exercisesInEachWorkout);

      // add individual workout to overall list
      mySavedWorkouts.add(workout);
    }
    return mySavedWorkouts;
  }

// check if any exercises have been done
  bool exerciseCompleted(List<Workout> workouts) {
    // go trough each workout
    for (var workout in workouts) {
      // go trough each exercise in workout
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  // return completion status of a given date yyyymmdd
  int getCompletedStatus(String yyyymmdd) {
    // returns 0 or 1, if null then return 0
    int completionStatus = _myBox.get('COMPLETION_STATUS_$yyyymmdd') ?? 0;
    return completionStatus;
  }
}

// ------------------------------------------------------------------------

// converts workout objects into a list
List<String> convertObjectToWorkoutList(List<Workout> workouts) {
  List<String> workoutList = [
    // e.g. [lowerbody, upperbody]
  ];

  for (int i = 0; i < workouts.length; i++) {
    // in eachworkout, add the name
    workoutList.add(
      workouts[i].name,
    );
  }

  return workoutList;
}

// converts the exercises in a workout object into a list of strings
List<List<List<String>>> convertObjectToExerciseList(List<Workout> workouts) {
  List<List<List<String>>> exerciseList = [
    // Exercises
  ];

  // go trough each workout
  for (int i = 0; i < workouts.length; i++) {
    // get exercises from each workout
    List<Exercise> exercisesInWorkout = workouts[i].exercises;

    List<List<String>> individualWorkout = [
      // [biceps, 10kg, 23 reps, 34 sets], [triceps, 30kg, 12 reps, 3 sets]
    ];

    // go trough each exercise in exercise List
    for (int j = 0; j < exercisesInWorkout.length; j++) {
      List<String> individualExercise = [
        // [biceps, 10kg, 23 reps, 34 sets]
      ];
      individualExercise.addAll(
        [
          exercisesInWorkout[j].name,
          exercisesInWorkout[j].weight,
          exercisesInWorkout[j].reps,
          exercisesInWorkout[j].sets,
          exercisesInWorkout[j].isCompleted.toString(),
        ],
      );
      individualWorkout.add(individualExercise);
    }

    exerciseList.add(individualWorkout);
  }

  return exerciseList;
}
