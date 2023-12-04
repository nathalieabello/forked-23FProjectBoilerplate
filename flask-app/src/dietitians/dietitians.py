from flask import Blueprint, request, jsonify
from src import dao, db

dietitians = Blueprint('dietitians', __name__)


# Get all the dietitians from Shmoop
@dietitians.route('/dietitians', methods=['GET'])
def get_dietitians():
    query = """
    SELECT Dietitian.username, firstName, lastName, qualifiedSince, birthday, dateJoined, 
    email, phone, sex, street, state, zip, country, height, weight
    FROM GeneralUser JOIN Dietitian
    """
    data = dao.retrieve(query)
    return jsonify(data)


def get_ingredients():
    query = f"""
    SELECT name, calories, protein, carbs, fat, cholesterol
    FROM Ingredient
    """
    data = dao.retrieve(query)
    return jsonify(data)


def add_ingredient(name, calories, protein, carbs, fat, cholesterol):
    query = f"""
    INSERT INTO Ingredient (name, calories, protein, carbs, fat, cholesterol)
    VALUES ('{name}', {calories}, {protein}, {carbs}, {fat}, {cholesterol})
    """
    dao.execute(query)


#### get and create ingredients from the db
@dietitians.route('/ingredients', methods=['GET', 'POST'])
def ingredients():
    if request.method == 'GET':
        return get_ingredients()
    else:
        name = request.json.get('name')
        calories = request.json.get('calories')
        protein = request.json.get('protein')
        carbs = request.json.get('carbs')
        fat = request.json.get('fat')
        cholesterol = request.json.get('cholesterol')
        add_ingredient(name, calories, protein, carbs, fat, cholesterol);
        return 'Success'


def get_ingredient(name):
    query = f"""
    SELECT name, calories, protein, carbs, fat, cholesterol
    FROM Ingredient
    WHERE name = '{name}'
    """
    data = dao.retrieve(query)
    return jsonify(data)


def update_ingredient(name, calories, protein, carbs, fat, cholesterol):
    # Check if the ingredient exists
    check_query = f"SELECT COUNT(*) FROM Ingredient WHERE name = '{name}'"
    result = dao.execute_query(check_query)
    exists = result.fetchone()[0]

    if exists > 0:
        # Ingredient exists, perform the update
        update_query = f"""
        UPDATE Ingredient
        SET calories = {calories}, protein = {protein}, carbs = {carbs}, fat = {fat}, cholesterol = {cholesterol}
        WHERE name = '{name}'
        """
        dao.execute(update_query)
        return "Ingredient updated successfully."
    else:
        # Ingredient does not exist, handle accordingly (e.g., insert or raise an exception)
        return "Ingredient not found in the database."


def remove_ingredient(name):
    # Check if the ingredient exists (case-insensitive)
    check_query = f"SELECT COUNT(*) FROM Ingredient WHERE LOWER(name) = LOWER('{name}')"
    result = dao.execute_query(check_query)
    exists = result.fetchone()[0]

    if exists > 0:
        # Ingredient exists, perform the deletion
        delete_query = f"DELETE FROM Ingredient WHERE LOWER(name) = LOWER('{name}')"
        dao.execute(delete_query)
        return "Ingredient removed successfully."
    else:
        # Ingredient does not exist, handle accordingly (e.g., raise an exception)
        return "Ingredient not found in the database."


#### get, update, and delete ingredient from the db
@dietitians.route('/ingredient/<name>', methods=['GET', 'PUT', 'DELETE'])
def ingredient(name):
    if request.method == 'GET':
        return get_ingredient(name)
    elif request.method == 'UPDATE':
        calories = request.json.get('calories')
        protein = request.json.get('protein')
        carbs = request.json.get('carbs')
        fat = request.json.get('fat')
        cholesterol = request.json.get('cholesterol')
        update_ingredient(name, calories, protein, carbs, fat, cholesterol)
        return 'Success'
    else:
        return remove_ingredient(name)


def get_recipes():
    query = f"""
    SELECT title, directions, cookTime
    FROM Recipe
    """
    data = dao.retrieve(query)
    return jsonify(data)


def add_recipe(title, directions, cooktime):
    query = f"""
    INSERT INTO Recipe (title, directions, cookTime)
    VALUES ('{title}', {directions}, {cooktime})
    """
    dao.execute(query)


#### get and create recipes from the db
@dietitians.route('/recipes', methods=['GET', 'POST'])
def recipes():
    if request.method == 'GET':
        return get_recipes()
    else:
        title = request.json.get('title')
        directions = request.json.get('directions')
        cooktime = request.json.get('cooktime')
        add_recipe(title, directions, cooktime);
        return 'Success'


def get_recipe(id):
    query = f"""
    SELECT title, directions, cookTime
    FROM Recipe
    WHERE recipeID = '{id}'
    """
    data = dao.retrieve(query)
    return jsonify(data)


def update_recipe(id, title, directions, cooktime):
    # Check if the ingredient exists
    check_query = f"SELECT COUNT(*) FROM Recipe WHERE recipeID = '{id}'"
    result = dao.execute_query(check_query)
    exists = result.fetchone()[0]

    if exists > 0:
        # Recipe exists, perform the update
        update_query = f"""
        UPDATE Recipe
        SET title = '{title}', directions = '{directions}', cookTime = '{cooktime}'
        WHERE recipeID = '{id}'
        """
        dao.execute(update_query)
        return "Recipe updated successfully."
    else:
        # Recipe does not exist, handle accordingly (e.g., insert or raise an exception)
        return "Recipe not found in the database."


def remove_recipe(recipeID):
    # Check if the ingredient exists (case-insensitive)
    check_query = f"SELECT COUNT(*) FROM Recipe WHERE recipeID = '{recipeID}'"
    result = dao.execute_query(check_query)
    exists = result.fetchone()[0]

    if exists > 0:
        # Ingredient exists, perform the deletion
        delete_query = f"DELETE FROM Recipe WHERE recipeID = '{recipeID}'"
        dao.execute(delete_query)
        return "Recipe removed successfully."
    else:
        # Ingredient does not exist, handle accordingly (e.g., raise an exception)
        return "Recipe not found in the database."


#### get, update, and delete recipe from the db
@dietitians.route('/recipe/<id>', methods=['GET', 'PUT', 'DELETE'])
def recipe(id):
    if request.method == 'GET':
        return get_recipe(id)
    elif request.method == 'UPDATE':
        title = request.json.get('title')
        directions = request.json.get('directions')
        cooktime = request.json.get('cooktime')
        update_recipe(id, title, directions, cooktime)
        return 'Success'
    else:
        return remove_ingredient(id)


#### get, update, and delete clients from a Dietitian
@dietitians.route('/<username>/clients', methods=['GET', 'PUT', 'DELETE'])
def clients(username):
    query = f"""
    SELECT clientUsername
    FROM DietitianClient
    WHERE dietitianUsername = '{username}'
    """
    data = dao.retrieve(query)
    return jsonify(data)

