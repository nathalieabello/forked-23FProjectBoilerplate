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
    JOIN Exercise ON Exercise.id = WorkoutExercise.exerciseId
    WHERE Workout.trainerUsername = '{username}'
    """
    data = dao.retrieve(query)
    workouts = {}
    for entry in data:
        id = entry.get('id')
        if id not in workouts:
            workouts[id] = {
                "name": entry['name'],
                "id": id,
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
    return list(workouts.values())

# adds a new workout to the db
def create_workout(username, name, wkt_exercises):
    wkt_query = f"""
    INSERT INTO Workout (name, trainerUsername)
    VALUES ('{name}', '{username}')
    """
    workout_id = dao.insert(wkt_query)
    for exc in wkt_exercises:
        query = f"""
        INSERT INTO WorkoutExercise (workoutId, exerciseId, sets, reps)
        VALUES ({workout_id}, {exc.get('id')}, {exc.get('sets')}, {exc.get('reps')})
        """
        dao.execute(query)

# given a trainer, gets all workouts for the trainer
# or creates a new workout for the trainer
@trainers.route('/trainers/<username>/workouts', methods=['GET', 'POST'])
def workouts(username):
    if request.method == 'GET':
        return jsonify(get_workouts(username))
    elif request.method == 'POST':
        name = request.json.get('name')
        # should take the format of a list of exercises
        # format: [ {id: __, sets: ___, reps: ___}, {...}, ... ]
        wkt_exercises = request.json.get('exercises')
        create_workout(username, name, wkt_exercises)
        return 'Success'

# given a trainer username, gets a specific workout with the given id
def get_workout(username, id):
    for wkt in get_workouts(username):
        if 'id' in wkt and wkt['id'] == int(id):
            return jsonify(wkt)
    raise NotFoundException('Workout not found')

# deletes a workout with the given id
def remove_workout(username, id):
    queryExercises = f"""
    DELETE FROM WorkoutExercise
    WHERE WorkoutExercise.workoutId = {id};
    """
    queryWorkout = f"""
    DELETE FROM Workout
    WHERE trainerUsername = '{username}' AND id = {id};
    """
    query = f"{queryExercises}\n{queryWorkout}"
    dao.execute(query)


# given a trainer username and a workout, updates the workout
def update_workout(username, id, name):
    query = f"""
    UPDATE Workout
    SET name = '{name}'
    WHERE trainerUsername = '{username}' AND id = {id}
    """
    dao.execute(query)


# get, update, or delete a given workout for a given trainer
@trainers.route('/trainers/<username>/workouts/<id>', methods=['GET', 'PUT', 'DELETE'])
def workout(username, id):
    if request.method == 'GET':
        return get_workout(username, id)
    elif request.method == 'PUT':
        name = request.json.get('name')
        update_workout(username, id, name)
        return 'Success'
    elif request.method == 'DELETE':
        remove_workout(username, id)
        return 'Success'

# gets all exercises
@trainers.route('/trainers/exercises', methods=['GET'])
def exercises():
    query = "SELECT * FROM Exercise"
    data = dao.retrieve(query)
    return jsonify(data)
