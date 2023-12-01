from flask import Blueprint, request, jsonify, current_app
from src import db, dao
from src.errors import NotFoundException

users = Blueprint('users', __name__)


# Get all the users from Shmoop
@users.route('/users', methods=['GET'])
def get_users():
    query = """
    SELECT username, firstName, lastName, birthday, dateJoined, email, phone, sex, street, state, zip, country, height, weight
    FROM GeneralUser
    """
    data = dao.retrieve(query)
    return jsonify(data)


#### get users given username
@users.route('/users/<username>', methods=['GET'])
def get_user(username):
    query = ('SELECT username, firstName, lastName, birthday, dateJoined,'
             ' email, phone, sex, street, state, zip, country, height, weight FROM GeneralUser '
             f'WHERE username = \'{username}\'')
    data = dao.retrieve(query)
    if len(data) != 1:
        raise NotFoundException("User not found")
    return jsonify(data[0])


#### add a users to users
@users.route('/newUser', methods=['POST'])
def add_user():
    # collecting data from the request object
    the_data = request.json
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
    dao.insert(query)
    return 'Success!'

def get_steps(username):
    query = f"""
    SELECT date, stepCount
    FROM DailySteps
    WHERE username = '{username}'
    ORDER BY date ASC
    """
    data = dao.retrieve(query)
    return jsonify(data)

def add_steps(username, date, count):
    query = f"""
    INSERT INTO DailySteps (username, date, stepCount)
    VALUES ('{username}', '{date}', {count})
    """
    dao.insert(query)

@users.route('/users/<username>/steps', methods=['GET', 'POST'])
def steps(username):
    if request.method == 'GET':
        return get_steps(username)
    else:
        date = request.json.get('date')
        count = request.json.get('stepCount')
        add_steps(username, date, count)
        return 'Success'