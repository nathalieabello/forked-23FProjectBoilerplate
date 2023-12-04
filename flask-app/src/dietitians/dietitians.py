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
@dietitians.route('/<username>/clients', methods=['GET', 'POST', 'DELETE'])
def clients(username):
    if request.method == 'GET':
        return get_clients(username)
    elif request.method == 'DELETE':
        clientUsername = request.json.get('clientUsername')
        return remove_client(username, clientUsername)
    else:
        clientUsername = request.json.get('clientUsername')
        add_client(username, clientUsername)
        return 'Success'


def add_client(dietitianUsername, clientUsername):
    query = f"""
    INSERT INTO DietitianClient (dietitianUsername, clientUsername) VALUES ({dietitianUsername}, {clientUsername})
    """
    dao.execute(query)


def remove_client(dietitianUsername, clientUsername):
    delete_query = f"""
    DELETE FROM DietitianClient
    WHERE dietitianUsername = '{dietitianUsername}' AND clientUsername = '{clientUsername}'
    """
    dao.execute(delete_query)
    return "Ingredient removed successfully."


def get_clients(username):
    query = f"""
    SELECT clientUsername
    FROM DietitianClient
    WHERE dietitianUsername = '{username}'
    """
    data = dao.retrieve(query)
    return jsonify(data)



# ### get, update, and delete clients from a Dietitian
# @dietitians.route('/recipes/<recipe>/ingredients', methods=['GET', 'PUT', 'DELETE'])
# def clients(recipeId):
#     query = f"""
#     SELECT ingredientName
#     FROM Amount
#     WHERE recipeId = '{recipeId}'
#     """
#     data = dao.retrieve(query)
#     return jsonify(data)



def get_diets():
    query = f"""
    SELECT dietName, recipeID
    FROM Diet
    """
    data = dao.retrieve(query)
    return jsonify(data)


def add_diet(dietName, recipeID):
    query = f"""
    INSERT INTO Diet (dietName, recipeID)
    VALUES ('{dietName}', {recipeID})
    """
    dao.execute(query)


#### get and create diet from the db
@dietitians.route('/diets', methods=['GET', 'POST'])
def diets():
    if request.method == 'GET':
        return get_diets()
    else:
        name = request.json.get('dietName')
        recipeid = request.json.get('recipeID')
        add_diet(name, recipeid);
        return 'Success'


def get_diet(name):
    query = f"""
    SELECT dietName, recipeID
    FROM Diet
    WHERE dietName = '{name}'
    """
    data = dao.retrieve(query)
    return jsonify(data)

def remove_diet(name):
    # Check if the ingredient exists (case-insensitive)
    check_query = f"SELECT COUNT(*) FROM Diet WHERE LOWER(dietName) = LOWER('{name}')"
    result = dao.execute_query(check_query)
    exists = result.fetchone()[0]

    if exists > 0:
        # Ingredient exists, perform the deletion
        delete_query = f"DELETE FROM Diet WHERE LOWER(dietName) = LOWER('{name}')"
        dao.execute(delete_query)
        return "Diet removed successfully."
    else:
        # Ingredient does not exist, handle accordingly (e.g., raise an exception)
        return "Diet not found in the database."


#### get, update, and delete recipe from the db
@dietitians.route('/diet/<name>', methods=['GET', 'PUT', 'DELETE'])
def diet(name):
    if request.method == 'GET':
        return get_diet(name)
    else:
        return remove_diet(name)

def get_recipe_and_diets():
    query = """
    SELECT R.title AS recipeName, R.recipeID, R.cookTime, R.directions, D.dietName
    FROM Recipe R
    LEFT JOIN Diet D ON R.recipeID = D.recipeID
    """
    data = dao.retrieve(query)
    return jsonify(data)

@dietitians.route('/recipe_and_diets', methods=['GET'])
def recipe_and_diets():
    return get_recipe_and_diets()

def get_recipe_and_ingredients(recipeID):
    query = f"""
    SELECT ingredientName, recipeID, servings, measurement
    FROM Amount
    WHERE recipeID = '{recipeID}'
    """
    data = dao.retrieve(query)
    return jsonify(data)


@dietitians.route('/recipe_and_ingredients/<recipeID>', methods=['GET'])
def recipe_and_ingredients(recipeID):
    return get_recipe_and_ingredients(recipeID)



def get_ingredient_details(ingredientname):
    query = f"""
    SELECT name, calories, protein, carbs, fat, cholesterol
    FROM Ingredient
    WHERE name = '{ingredientname}'
    """
    data = dao.retrieve(query)
    return jsonify(data)


@dietitians.route('/ingredient_details/<ingredientname>', methods=['GET'])
def ingredient_details(ingredientname):
    return get_ingredient_details(ingredientname)


