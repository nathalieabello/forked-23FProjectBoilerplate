from flask import Blueprint, request, jsonify, current_app
from src import db, dao
from src.errors import NotFoundException

trainers = Blueprint('trainers', __name__)

# given a trainer's username, gets all of that trainer's workouts
def get_workouts(username):
    query = f"""
    SELECT Workout.id as id, Workout.name as name, Workout.trainerUsername as trainerUsername,
    WorkoutExercise.sets as sets, WorkoutExercise.reps as reps, Exercise.id as exerciseId,
    Exercise.name as exerciseName, Exercise.description as exerciseDescription
    FROM Workout
    JOIN WorkoutExercise ON Workout.id = WorkoutExercise.workoutId 
    JOIN Exercise ON Exercise.id = WorkoutExercise.workoutId
    WHERE Workout.trainerUsername = '{username}'
    """
    data = dao.retrieve(query)
    workouts = {}
    for entry in data:
        id = entry.get('id')
        if id not in workouts:
            workouts[id] = {
                "name": entry['name'],
                "exercises": []
            }
        next_exercise = {
            "name": entry.get('exerciseName'),
            "id": entry.get('exerciseId'),
            "description": entry.get('exerciseDescription'),
            "sets": entry.get('sets'),
            "reps": entry.get('reps'),
        }
        workouts[id]['exercises'].append(next_exercise)
    return jsonify(list(workouts.values()))


@trainers.route('/trainers/<username>/workouts', methods=['GET', 'POST'])
def workouts(username):
    if request.method == 'GET':
        return get_workouts(username)

# gets all exercises
@trainers.route('/trainers/exercises', methods=['GET'])
def exercises():
    query = "SELECT * FROM Exercise"
    data = dao.retrieve(query)
    return jsonify(data)