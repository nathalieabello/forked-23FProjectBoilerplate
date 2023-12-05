from flask import Blueprint, request, jsonify, current_app
from src import db, dao
from src.errors import NotFoundException

influencers = Blueprint('influencers', __name__)

# get all followers for a given influencer
@influencers.route('/influencers/<username>/followers', methods=['GET'])
def get_followers(username):
    query = f"""
    SELECT * FROM InfluencerFollower
    JOIN GeneralUser ON InfluencerFollower.followerUsername = GeneralUser.username
    WHERE InfluencerFollower.influencerusername = '{username}'
    """
    data = dao.retrieve(query)
    return jsonify(data)

def add_follower(username, followerUsername):
    query = f"""
    INSERT INTO InfluencerFollower (influencerusername, followerUsername)
    VALUES ('{username}', '{followerUsername}')
    """
    dao.execute(query)

def remove_follower(username, followerUsername):
    query = f"""
    DELETE FROM InfluencerFollower
    WHERE influencerusername = '{username}' AND followerUsername = '{followerUsername}'
    """
    dao.execute(query)

# add or remove a follower to/from an influencer
@influencers.route('/influencers/<username>/followers/<followerUsername>', methods=['POST', 'DELETE'])
def follower(username, followerUsername):
    if request.method == 'POST':
        add_follower(username, followerUsername)
    elif request.method == 'DELETE':
        remove_follower(username, followerUsername)

    # Add a return statement here
    return 'Success'


# get aggregate post interactions for a given influencer
@influencers.route('/influencers/<username>/interactions', methods=['GET'])
def interactions(username):
    query = f"""
    SELECT SUM(Video.comments) as totalComments, SUM(Video.likes) as totalLikes, SUM(Video.shares) as totalShares
    FROM Video
    JOIN Posts ON Video.id = Posts.videoId
    GROUP BY Posts.influencerUsername
    HAVING Posts.influencerUsername = '{username}'
    """
    data = dao.retrieve(query)
    totals = data[0]
    return jsonify({
            'totalComments': totals['totalComments'],
            'totalLikes': totals['totalLikes'],
            'totalShares': totals['totalShares']
        })


# get post interactions for a given influencer's post
@influencers.route('/influencers/<username>/interactions/<postId>', methods=['GET'])
def interaction(username, postId):
    query = f"""
    SELECT Video.comments, Video.likes, Video.shares
    FROM Video
    JOIN Posts on Video.id = Posts.videoId
    WHERE Video.id = {postId} AND Posts.influencerUsername = '{username}'
    """
    data = dao.retrieve(query)
    if len(data) != 1:
        raise NotFoundException('Post not found')
    return jsonify(data)


# gets all influencers from db
def get_influencers():
    query = f"""
    SELECT * FROM Influencer
    JOIN GeneralUser ON Influencer.username = GeneralUser.username
    """
    data = dao.retrieve(query)
    return jsonify(data)

# creates a new influencer
def add_influencer(username = "", bio = ""):
    query = f"""
    INSERT INTO Influencer (username, bio, followerCount)
    VALUES ('{username}', '{bio}', 0)
    """
    dao.execute(query)
    

# get all influencers
@influencers.route('/influencers', methods=['GET', 'POST'])
def get_or_add_influencers():
    if request.method == 'GET':
        return get_influencers()
    elif request.method == 'POST':
        username = request.json.get('username')
        bio = request.json.get('bio')
        bio = f"'{bio}'" if bio else ""
        add_influencer(username, bio)
        return 'Success'

# removes an influencer from the db
def remove_influencer(username):
    queryFollowers = f"""
    DELETE FROM InfluencerFollower
    WHERE influencerusername = '{username}';
    """
    queryVideos = f"""
    DELETE Video FROM Video
    JOIN Posts ON Video.id = Posts.videoId
    WHERE Posts.influencerUsername = '{username}';
    """
    queryPosts = f"""
    DELETE FROM Posts
    WHERE influencerUsername = '{username}';
    """
    queryInfluencer = f"""
    DELETE FROM Influencer
    WHERE username = '{username}';
    """
    query = "\n".join([queryFollowers, queryVideos, queryPosts, queryInfluencer])
    dao.execute(query)

# updates an influencer's information
def update_influencer(username, bio = None, followerCount = None):
    updates = ""
    if bio and followerCount:
        updates = f"bio = '{bio}', followerCount = {followerCount}"
    elif bio:
        updates = f"bio = '{bio}'"
    elif followerCount:
        updates = f"followerCount = {followerCount}"
    query = f"""
    UPDATE Influencer
    SET {updates}
    WHERE username = '{username}'
    """
    dao.execute(query)

# deletes an influencer
@influencers.route('/influencers/<username>', methods=['PUT', 'DELETE'])
def edit_influencer(username):
    if request.method == 'PUT':
        bio = request.json.get('bio')
        followerCount = request.json.get('followerCount')
        update_influencer(username, bio, followerCount)
        return 'Success'
    elif request.method == 'DELETE':
        remove_influencer(username)
        return 'Success'


## get incluencer bio
@influencers.route('/influencers/<username>/bio', methods=['GET'])
def get_influencer_bio(username):
    query = f"""
    SELECT bio FROM Influencer
    WHERE username = '{username}'
    """
    data = dao.retrieve(query)

    # Extract bio from the result
    bio = data[0].get('bio', '')

    return jsonify({'bio': bio})