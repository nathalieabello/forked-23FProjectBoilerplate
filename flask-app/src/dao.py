from src import db

"""
Executes a query on the db and returns the results as a list of dictionaries
"""
def retrieve(query):
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database
    cursor.execute(query)

    # grab the column headers from the returned data
    column_headers = [x[0] for x in cursor.description]

    # create an empty dictionary object to use in
    # putting column headers together with data
    json_data = []

    # fetch all the data from the cursor
    theData = cursor.fetchall()

    # for each of the rows, zip the data elements together with
    # the column headers.
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))
    
    return json_data

"""
Executes a query on the db
"""
def execute(query):
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()

"""
Inserts a single entity into the db and returns the id of the newly created entity
"""
def insert(query):
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    return cursor.lastrowid
