from flask import Blueprint, request, jsonify, current_app
from src import db
from src import dao

dietitians = Blueprint('dietitians', __name__)


# Get all the users from Shmoop
@dietitians.route('/dietitians', methods=['GET'])
def get_users():
    query = """
    SELECT username, firstName, lastName, qualifiedSince, birthday, dateJoined, email, phone, sex, street, state, zip, country, height, weight
    FROM GeneralUser JOIN Dietitian
    """
    data = dao.retrieve(query)
    return jsonify(data)


#### get users given username
@dietitians.route('/users/<username>', methods=['GET'])
def get_user(username):
    query = ('SELECT username, firstName, lastName, birthday, dateJoined,'
             ' email, phone, sex, street, state, zip, country, height, weight FROM GeneralUser '
             f'WHERE username = \'{username}\'')
    data = dao.retrieve(query)
    if len(data) != 1:
        raise Exception(code=404, description="User not found")
    return jsonify(data[0])


#### add a users to users
@dietitians.route('/newDietitian', methods=['POST'])
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
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    return 'Success!'