from flask import Blueprint, request, jsonify, current_app
from src import db, dao
from src.errors import NotFoundException

users = Blueprint('users', __name__)


# gets users from db
def get_users():
    query = """
    SELECT username, firstName, lastName, birthday, dateJoined, email, phone, sex, street, state, zip, country, height, weight
    FROM GeneralUser
    """
    data = dao.retrieve(query)
    return jsonify(data)


# adds a user to the db
def add_user(req):
    # collecting data from the request object
    the_data = req.json
    current_app.logger.info(the_data)

    # extracting the variable
    username = the_data['username']
    firstName = the_data['first_name']
    lastName = the_data['last_name']
    birthday = the_data['birthday']
    email = the_data['email']
    phone = the_data['phone']
    sex = the_data['sex']
    street = the_data['street']
    state = the_data['state']
    zip = the_data['zip']
    country = the_data['country']
    height = the_data['height']
    weight = the_data['weight']

    # Constructing the query
    query = ('INSERT INTO GeneralUser (username, firstName, lastName, birthday, '
             ' email, phone, sex, street, state, zip, country, height, weight) '
             ' VALUES ("')
    query += username + '", "'
    query += firstName + '", "'
    query += lastName + '", "'
    query += birthday + '", "'
    query += email + '", "'
    query += phone + '", "'
    query += sex + '", "'
    query += street + '", "'
    query += state + '", "'
    query += zip + '", "'
    query += country + '", "'
    query += str(height) + '", '
    query += str(weight) + ')'
    current_app.logger.info(query)

    # executing and committing the insert statement
    dao.execute(query)
    return 'Success!'


# Get all the users from Shmoop
@users.route('/users', methods=['GET', 'POST'])
def handle_users():
    if request.method == 'GET':
        return get_users()
    elif request.method == 'POST':
        return add_user(request)


# given a username, gets the user from the db and returns it
def get_user(username):
    query = ('SELECT username, firstName, lastName, birthday, dateJoined,'
             ' email, phone, sex, street, state, zip, country, height, weight FROM GeneralUser '
             f'WHERE username = \'{username}\'')
    data = dao.retrieve(query)
    if len(data) != 1:
        raise NotFoundException("User not found")
    return jsonify(data[0])


# given a username, updates that user's info
def update_user(username, req):
    data = req.json
    updates_dict = {
        "firstName": f"'{data['first_name']}'" if 'first_name' in data else None,
        "lastName": f"'{data['last_name']}'" if 'last_name' in data else None,
        "birthday": f"'{data['birthday']}'" if 'birthday' in data else None,
        "email": f"'{data['email']}'" if 'email' in data else None,
        "phone": f"'{data['phone']}'" if 'phone' in data else None,
        "sex": f"'{data['sex']}'" if 'sex' in data else None,
        "street": f"'{data['street']}'" if 'street' in data else None,
        "state": f"'{data['state']}'" if 'state' in data else None,
        "zip": f"'{data['zip']}'" if 'zip' in data else None,
        "country": f"'{data['country']}'" if 'country' in data else None,
        "height": data.get('height'),
        "weight": data.get('weight')
    }
    updates = [f"{key} = {value}" for key, value in updates_dict.items() if value is not None]

    query = f"""
    UPDATE GeneralUser
    SET {", ".join(updates)}
    WHERE username = '{username}'
    """
    dao.execute(query)
    return 'Success'


#### get users given username
@users.route('/users/<username>', methods=['GET', 'PUT'])
def handle_user(username):
    if request.method == 'GET':
        return get_user(username)
    else:
        return update_user(username, request)


# given a username, gets steps for that user
def get_steps(username):
    query = f"""
    SELECT id, date, stepCount
    FROM DailySteps
    WHERE username = '{username}'
    ORDER BY date ASC
    """
    data = dao.retrieve(query)
    return jsonify(data)


# given a username, adds a step entry to the db for that user
def add_steps(username, date, count):
    query = f"""
    INSERT INTO DailySteps (username, date, stepCount)
    VALUES ('{username}', '{date}', {count})
    """
    dao.execute(query)


# add or retrieve step info
@users.route('/users/<username>/steps', methods=['GET', 'POST'])
def steps(username):
    if request.method == 'GET':
        return get_steps(username)
    else:
        date = request.json.get('date')
        count = request.json.get('stepCount')
        add_steps(username, date, count)
        return 'Success'


# given an id, updates a step
def update_steps(username, id, date = None, stepCount = None):
    updates = ""
    if date and stepCount:
        updates += f"date = '{date}', stepCount = {stepCount}"
    elif date:
        updates += f"date = '{date}'"
    elif stepCount:
        updates += f"stepCount = {stepCount}"
    
    query = f"""
    UPDATE DailySteps
    SET {updates}
    WHERE username = '{username}' AND id = {id}
    """

    dao.execute(query)

# given an id, deletes a step
def delete_steps(username, id):
    query = f"DELETE FROM DailySteps WHERE username = '{username}' AND id = {id}"
    dao.execute(query)

# given an id, updates or deletes that daily steps entry
@users.route('/users/<username>/steps/<id>', methods=['PUT', 'DELETE'])
def step(username, id):
    if request.method == 'PUT':
        date = request.json.get('date')
        stepCount = request.json.get('stepCount')
        update_steps(username, id, date, stepCount)
        return 'Success'
    elif request.method == 'DELETE':
        delete_steps(username, id)

# given a username, gets all daily macros information for that user
def get_macros(username):
    query = f"""
    SELECT id, date, calorieCount, proteinCount, carbCount, fatCount
    FROM DailyMacros
    WHERE username = '{username}'
    ORDER BY date ASC
    """
    data = dao.retrieve(query)
    return jsonify(data)


# given a username, adds a daily macros entry to the db for that user
def add_macros(username, date, calorieCount, proteinCount, carbCount, fatCount):
    query = f"""
    INSERT INTO DailyMacros (username, date, calorieCount, proteinCount, carbCount, fatCount)
    VALUES ('{username}', '{date}', {calorieCount}, {proteinCount}, {carbCount}, {fatCount})
    """
    dao.execute(query)


# add and retreive daily macro information for a user
@users.route('/users/<username>/macros', methods=['GET', 'POST'])
def macros(username):
    if request.method == 'GET':
        return get_macros(username)
    else:
        date = request.json.get('date')
        calories = request.json.get('calorieCount')
        protein = request.json.get('proteinCount')
        carbs = request.json.get('carbCount')
        fats = request.json.get('fatCount')
        add_macros(username, date, calories, protein, carbs, fats)
        return 'Success'

# given an id, updates a step
def update_macros(username, id, date = None, calories = None, protein = None, carbs = None, fats = None):
    if date:
        date = f"'{date}'"
    updates = list(filter(lambda x: True if x is not None else False, [date, calories, protein, carbs, fats]))
    query = f"""
    UPDATE DailyMacros
    SET {", ".join(updates)}
    WHERE username = '{username}' AND id = {id}
    """
    dao.execute(query)

# given an id, deletes a step
def delete_macros(username, id):
    query = f"DELETE FROM DailyMacros WHERE username = '{username}' AND id = {id}"
    dao.execute(query)

# given an id, updates or deletes that daily steps entry
@users.route('/users/<username>/macros/<id>', methods=['PUT', 'DELETE'])
def macro(username, id):
    if request.method == 'PUT':
        date = request.json.get('date')
        calories = request.json.get('calorieCount')
        protein = request.json.get('proteinCount')
        carbs = request.json.get('carbCount')
        fats = request.json.get('fatCount')
        update_macros(username, id, date, calories, protein, carbs, fats)
        return 'Success'
    elif request.method == 'DELETE':
        delete_macros(username, id)
        return 'Success'

# given a username, gets all daily sleep info for that user
def get_sleep(username):
    query = f"""
    SELECT id, datetimeStarted, datetimeEnded, REMTime, NREMTime
    FROM SleepInfo
    WHERE username = '{username}'
    ORDER BY datetimeStarted ASC
    """
    data = dao.retrieve(query)
    return jsonify(data)


# given a username, adds a daily sleep entry into the db for that user
def add_sleep(username, datetimeStarted, datetimeEnded, REMTime, NREMTime):
    query = f"""
    INSERT INTO SleepInfo (username, datetimeStarted, datetimeEnded, REMTime, NREMTime)
    VALUES ('{username}', '{datetimeStarted}', '{datetimeEnded}', {REMTime}, {NREMTime})
    """
    dao.execute(query)


# add and retrieve sleep information for a given user
@users.route('/users/<username>/sleep', methods=['GET', 'POST'])
def sleep(username):
    if request.method == 'GET':
        return get_sleep(username)
    else:
        datetimeStarted = request.json.get('datetimeStarted')
        datetimeEnded = request.json.get('datetimeEnded')
        REMTime = request.json.get('REMTime')
        NREMTime = request.json.get('NREMTime')
        add_sleep(username, datetimeStarted, datetimeEnded, REMTime, NREMTime)
        return 'Success'


# given a username, gets all goals for that user
def get_goals(username):
    query = f"""
    SELECT id, description, status, username
    FROM Goal
    WHERE username = '{username}'
    """
    data = dao.retrieve(query)
    return jsonify(data)


# given a username, adds a goal entry into the db for that user
def add_goal(username, description, status):
    query = f"""
    INSERT INTO Goal (username, description, status)
    VALUES ('{username}', '{description}', '{status}')
    """
    dao.execute(query)


# add and retrieve goal information for a given user
@users.route('/users/<username>/goals', methods=['GET', 'POST'])
def goals(username):
    if request.method == 'GET':
        return get_goals(username)
    else:
        description = request.json.get('description')
        status = request.json.get('status')
        add_goal(username, description, status)
        return 'Success'


def delete_goal(username, goalID):
    query = f"""
    DELETE FROM Goal
    WHERE id = '{goalID}' AND username = '{username}'
    """
    dao.execute(query)
    return 'Success'


@users.route('/users/<username>/goals/<goalID>', methods=['DELETE'])
def goal(username, goalID):
    if request.method == 'DELETE':
        return delete_goal(username, goalID)


# given a username and an id, updates a sleep info
def update_sleep(username, id, datetimeStarted = None, datetimeEnded = None, REMTime = None, NREMTime = None):
    if datetimeStarted:
        datetimeStarted = f"'{datetimeStarted}'"
    if datetimeEnded:
        datetimeEnded = f"'{datetimeEnded}'"
    updates = list(filter(lambda x: True if x is not None else False, [datetimeStarted, datetimeEnded, REMTime, NREMTime]))
    query = f"""
    UPDATE SleepInfo
    SET {", ".join(updates)}
    WHERE username = '{username}' AND id = {id}
    """
    dao.execute(query)

# given a username and an id, deletes a sleep info
def delete_sleep(username, id):
    query = f"DELETE FROM SleepInfo WHERE username = '{username}' AND id = {id}"
    dao.execute(query)

# given an id, updates or deletes that daily steps entry
@users.route('/users/<username>/macros/<id>', methods=['PUT', 'DELETE'])
def sleep_individual(username, id):
    if request.method == 'PUT':
        datetimeStarted = request.json.get('datetimeStarted')
        datetimeEnded = request.json.get('datetimeEnded')
        REMTime = request.json.get('REMTime')
        NREMTime = request.json.get('NREMTime')
        update_sleep(username, id, datetimeStarted, datetimeEnded, REMTime, NREMTime)
        return 'Success'
    elif request.method == 'DELETE':
        delete_sleep(username, id)
        return 'Success'
