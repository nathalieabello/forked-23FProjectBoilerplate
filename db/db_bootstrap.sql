-- This file is to bootstrap a database for the CS3200 project.

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith
-- data source creation.
DROP DATABASE IF EXISTS Shmoop;
CREATE DATABASE IF NOT EXISTS Shmoop;

-- Via the Docker Compose file, a special users called webapp will
-- be created in MySQL. We are going to grant that users
-- all privilages to the new database we just created.
-- TODO: If you changed the name of the database above, you need
-- to change it here too.
grant all privileges on Shmoop.* to 'webapp'@'%';
flush privileges;

-- Move into the database we just created.
-- TODO: If you changed the name of the database above, you need to
-- change it here too.
USE Shmoop;

-- Put your DDL
CREATE TABLE IF NOT EXISTS GeneralUser
(
    username   VARCHAR(255) PRIMARY KEY,
    firstName  VARCHAR(255) NOT NULL,
    lastName   VARCHAR(255) NOT NULL,
    birthday   DATE         NOT NULL,
    dateJoined DATETIME DEFAULT NOW(),
    email      VARCHAR(255) NOT NULL,
    phone      VARCHAR(10)  NOT NULL,
    sex        CHAR(1)      NOT NULL,
    street     VARCHAR(128) NOT NULL,
    state      CHAR(2)      NOT NULL,
    zip        CHAR(5)      NOT NULL,
    country    VARCHAR(128) NOT NULL,
    height     INTEGER      NOT NULL,
    weight     INTEGER      NOT NULL
);

CREATE TABLE IF NOT EXISTS UserMedicalHistory
(
    username VARCHAR(255) NOT NULL,
    injury   VARCHAR(255) NOT NULL,
    occurred DATE         NOT NULL,
    PRIMARY KEY (username, injury, occurred),
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE cascade
        ON DELETE restrict
);

CREATE TABLE IF NOT EXISTS UserAllergies
(
    username VARCHAR(255) NOT NULL,
    allergy  VARCHAR(255) NOT NULL,
    PRIMARY KEY (username, allergy),
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE cascade
        ON DELETE restrict
);

CREATE TABLE IF NOT EXISTS Goal
(
    id          INTEGER PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(255) NOT NULL,
    status      VARCHAR(128) NOT NULL,
    username    VARCHAR(255) NOT NULL,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE cascade
        ON DELETE restrict
);

CREATE TABLE IF NOT EXISTS DailySteps
(
    id        INTEGER PRIMARY KEY AUTO_INCREMENT,
    date      DATE         NOT NULL,
    stepCount INTEGER      NOT NULL,
    username  VARCHAR(255) NOT NULL,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE cascade
        ON DELETE restrict
);

CREATE TABLE IF NOT EXISTS DailyMacros
(
    id           INTEGER PRIMARY KEY AUTO_INCREMENT,
    date         DATE         NOT NULL,
    calorieCount INTEGER      NOT NULL,
    proteinCount INTEGER      NULL,
    carbCount    INTEGER      NULL,
    fatCount     INTEGER      NULL,
    username     VARCHAR(255) NOT NULL,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE cascade
        ON DELETE restrict
);

CREATE TABLE IF NOT EXISTS SleepInfo
(
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    datetimeStarted DATETIME     NOT NULL,
    datetimeEnded   DATETIME     NOT NULL,
    REMTime         INTEGER      NOT NULL,
    NREMTime        INTEGER      NOT NULL,
    username        VARCHAR(255) NOT NULL,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE cascade
        ON DELETE restrict
);

-- personal trainer
CREATE TABLE IF NOT EXISTS PersonalTrainer
(
    username       VARCHAR(255) PRIMARY KEY,
    qualifiedSince DATETIME DEFAULT NOW(),
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS PersonalTrainerClient
(
    trainerUsername VARCHAR(255) NOT NULL,
    clientUsername  VARCHAR(255) NOT NULL,
    PRIMARY KEY (trainerUsername, clientUsername),
    FOREIGN KEY (trainerUsername) REFERENCES PersonalTrainer (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (clientUsername) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Workout
(
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(255) NOT NULL,
    trainerUsername VARCHAR(255) NOT NULL,
    FOREIGN KEY (trainerUsername) REFERENCES PersonalTrainer (username)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Exercise
(
    id          INTEGER PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(255) NOT NULL,
    description VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS MuscleGroup
(
    name VARCHAR(255) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS ExerciseMuscleGroup
(
    exerciseId      INTEGER      NOT NULL,
    muscleGroupName VARCHAR(255) NOT NULL,
    PRIMARY KEY (exerciseId, muscleGroupName),
    FOREIGN KEY (exerciseId) REFERENCES Exercise (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (muscleGroupName) REFERENCES MuscleGroup (name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS WorkoutExercise
(
    workoutId  INTEGER NOT NULL,
    exerciseId INTEGER NOT NULL,
    sets       INTEGER NOT NULL,
    reps       INTEGER NOT NULL,
    PRIMARY KEY (workoutId, exerciseId),
    FOREIGN KEY (workoutId) REFERENCES Workout (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (exerciseId) REFERENCES Exercise (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Session
(
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    trainerUsername VARCHAR(255) NOT NULL,
    clientUsername  VARCHAR(255) NOT NULL,
    workoutId       INTEGER      NOT NULL,
    date            DATETIME     NOT NULL,
    duration        INTEGER      NOT NULL,
    FOREIGN KEY (trainerUsername) REFERENCES PersonalTrainer (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (clientUsername) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (workoutId) REFERENCES Workout (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- dietitian
CREATE TABLE IF NOT EXISTS Dietitian
(
    qualifiedSince DATE NOT NULL,
    username       VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS DietitianClient
(
    dietitianUsername VARCHAR(255) NOT NULL,
    clientUsername    VARCHAR(255) NOT NULL,
    PRIMARY KEY (dietitianUsername, clientUsername),
    FOREIGN KEY (dietitianUsername) REFERENCES Dietitian (username)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (clientUsername) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Recipe
(
    recipeID   INTEGER AUTO_INCREMENT PRIMARY KEY,
    title      VARCHAR(255) NOT NULL,
    directions MEDIUMTEXT   NOT NULL,
    cookTime   INTEGER      NOT NULL
);

CREATE TABLE IF NOT EXISTS RecipeRecommendation
(
    dietitianUsername VARCHAR(255) NOT NULL,
    username          VARCHAR(255) NOT NULL,
    recipeID          INTEGER      NOT NULL,
    PRIMARY KEY (dietitianUsername, username, recipeID),
    FOREIGN KEY (dietitianUsername) REFERENCES Dietitian (username)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (recipeID) REFERENCES Recipe (recipeID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Ingredient
(
    name        VARCHAR(255) PRIMARY KEY,
    calories    INTEGER NOT NULL,
    protein     INTEGER NULL,
    carbs       INTEGER NULL,
    fat         INTEGER NULL,
    cholesterol INTEGER NULL
);

CREATE TABLE IF NOT EXISTS Diet
(
    dietName VARCHAR(255) NOT NULL,
    recipeID INTEGER      NOT NULL,
    PRIMARY KEY (dietName, recipeID),
    FOREIGN KEY (recipeID) REFERENCES Recipe (recipeID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Allergen
(
    allergenName   VARCHAR(255) NOT NULL,
    ingredientName VARCHAR(255) NOT NULL,
    PRIMARY KEY (allergenName, ingredientName),
    FOREIGN KEY (ingredientName) REFERENCES Ingredient (name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Amount
(
    servings       INTEGER      NOT NULL,
    measurement    VARCHAR(128) NOT NULL,
    recipeID       INTEGER      NOT NULL,
    ingredientName VARCHAR(255) NOT NULL,
    PRIMARY KEY (recipeID, ingredientName),
    FOREIGN KEY (recipeID) REFERENCES Recipe (recipeID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (ingredientName) REFERENCES Ingredient (name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- influencer
CREATE TABLE IF NOT EXISTS Influencer
(
    followerCount INTEGER      NULL,
    bio           VARCHAR(255) NUll,
    username      VARCHAR(255) PRIMARY KEY,
    FOREIGN KEY (username) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS InfluencerFollower
(
    influencerusername VARCHAR(255) NOT NULL,
    followerUsername   VARCHAR(255) NOT NULL,
    PRIMARY KEY (influencerusername, followerUsername),
    FOREIGN KEY (influencerusername) REFERENCES Influencer (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (followerUsername) REFERENCES GeneralUser (username)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Brand
(
    name VARCHAR(255) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS Video
(
    id        INTEGER PRIMARY KEY AUTO_INCREMENT,
    comments  INTEGER      NULL,
    likes     INTEGER      NULL,
    shares    INTEGER      NULL,
    duration  INTEGER      NOT NULL,
    caption   VARCHAR(255) NULL,
    brandName VARCHAR(255) NULL,
    FOREIGN KEY (brandName) REFERENCES Brand (name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Posts
(
    id                 INTEGER PRIMARY KEY AUTO_INCREMENT,
    influencerUsername VARCHAR(255) NOT NULL,
    videoId            INTEGER      NOT NULL,
    FOREIGN KEY (influencerUsername) REFERENCES Influencer (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (videoId) REFERENCES Video (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


-- Add sample data.
-- -- mock users data
INSERT INTO GeneralUser
(username, firstName, lastName, birthday, dateJoined, email, phone, sex, street, state, zip, country, height, weight)
VALUES ('aniceberg', 'Aidan', 'Niceberg', '2002-07-28', '2023-11-02', 'aniceberg@gmail.com', '9876655432', 'M',
        '1 Main Street', 'NJ', '07940', 'USA', 74, 200),
       ('nabello', 'Nathalie', 'Abello', '2004-05-06', '2023-10-31', 'nabello@aol.com', '0000000000', 'F',
        '2 Main Street', 'NJ', '39456', 'USA', 75, 100),
       ('tari', 'Tarun', 'Ari', '2003-11-26', '2023-09-01', 'tari@optonline.net', '1234567890', 'M', '3 Main Street',
        'NJ', '87654', 'USA', 73, 150),
       ('ewiser', 'Ella', 'Wiser', '2002-11-26', '2022-05-06', 'ewiser@outlook.com', '9998887777', 'F',
        '170 Leland Creek', 'CO', '80482', 'USA', 40, 45),
       ('mfontenot', 'Mark', 'Fontenot', '1999-08-10', '2021-02-05', 'mfontenot@gmail.com', '9988776655', 'M',
        '10 Cool Street', 'TX', '12345', 'USA', 71, 180),
       ('jdoe', 'John', 'Doe', '2000-12-25', '2023-06-07', 'jdoe@hotmail.com', '1212121212', 'M', '76 Alleghany Street',
        'MA', 'USA', '09876', 65, 140),
       ('janedoe', 'Jane', 'Doe', '2000-12-25', '2022-06-08', 'janedoe@hotmail.com', '2323232323', 'F',
        '76 Alleghany Street', 'MA', 'USA', '09876', 55, 120);

INSERT INTO UserMedicalHistory
    (username, injury, occurred)
VALUES ('aniceberg', 'Broken Arm', '2023-01-20'),
       ('tari', 'Fractured Wrist', '2022-07-15'),
       ('mfontenot', 'Sprained Ankle', '2020-03-01'),
       ('janedoe', 'Concussion', '2019-06-10');

INSERT INTO UserAllergies
    (username, allergy)
VALUES ('aniceberg', 'peanut'),
       ('aniceberg', 'olive'),
       ('aniceberg', 'fish'),
       ('nabello', 'pollen'),
       ('nabello', 'apple'),
       ('tari', 'corn'),
       ('ewiser', 'strawberry'),
       ('ewiser', 'pollen'),
       ('mfontenot', 'banana'),
       ('jdoe', 'walnut'),
       ('jdoe', 'cat'),
       ('janedoe', 'peanut');

INSERT INTO Goal
    (description, status, username)
VALUES ('lose weight', 'in progress', 'jdoe'),
       ('gain weight', 'in progress', 'mfontenot'),
       ('increase mobility', 'achieved', 'nabello'),
       ('sleep longer', 'in progress', 'ewiser');

INSERT INTO DailySteps
    (date, stepCount, username)
VALUES ('2023-02-15', 5000, 'aniceberg'),
       ('2022-03-25', 3000, 'tari'),
       ('2023-04-17', 13000, 'nabello'),
       ('2023-05-21', 20000, 'ewiser'),
       ('2023-06-04', 7000, 'janedoe'),
       ('2023-03-07', 14000, 'jdoe'),
       ('2023-10-10', 2500, 'mfontenot');

INSERT INTO DailyMacros
    (date, calorieCount, proteinCount, carbCount, fatCount, username)
VALUES ('2023-01-01', 2000, 100, 300, 50, 'aniceberg'),
       ('2023-02-05', 3000, 120, 200, 40, 'tari'),
       ('2023-03-10', 1500, 60, 150, 60, 'nabello'),
       ('2023-04-15', 2100, 80, 250, 50, 'ewiser'),
       ('2023-05-20', 2400, 90, 225, 35, 'mfontenot'),
       ('2023-06-25', 3200, 105, 310, 55, 'janedoe'),
       ('2023-07-30', 3600, 135, 450, 70, 'jdoe');

INSERT INTO SleepInfo
    (datetimeStarted, datetimeEnded, REMTime, NREMTime, username)
VALUES ('2023-12-04 22:30:00', '2023-12-05 08:30:00', 1, 10, 'aniceberg'),
       ('2023-10-07 23:00:00', '2023-10-08 09:15:00', 2, 11, 'tari'),
       ('2023-11-09 21:45:00', '2023-11-10 10:15:00', 3, 12, 'nabello'),
       ('2023-09-13 23:30:00', '2023-09-14 06:45:00', 4, 9, 'ewiser'),
       ('2023-08-06 01:15:00', '2023-08-06 11:00:00', 3, 7, 'mfontenot'),
       ('2023-08-12 23:15:00', '2023-08-13 07:45:00', 4, 8, 'janedoe'),
       ('2023-09-25 22:45:00', '2023-09-26 08:15:00', 2, 10, 'jdoe');

-- -- mock trainer data
INSERT INTO PersonalTrainer
    (qualifiedSince, username)
VALUES ('2021-07-28', 'aniceberg'),
       ('2022-01-01', 'ewiser');

INSERT INTO PersonalTrainerClient
    (trainerUsername, clientUsername)
VALUES ('aniceberg', 'jdoe'),
       ('aniceberg', 'janedoe');

INSERT INTO Exercise
    (name, description)
VALUES ('Bench Press', 'Lay on bench, push barbell from chest'),
       ('Pull Up', 'Grab handles with hands, pull yourself up until chin goes over the bar'),
       ('Squat', 'Put barbell on your back, drop knees until they are parallel with ground, push back up'),
       ('Shoulder Press', 'Push dumbbells from your ears to over your head');

INSERT INTO MuscleGroup
    (name)
VALUES ('back'),
       ('legs'),
       ('chest'),
       ('triceps'),
       ('biceps'),
       ('shoulders');

INSERT INTO ExerciseMuscleGroup
    (exerciseId, muscleGroupName)
VALUES (1, 'chest'),
       (1, 'triceps'),
       (1, 'shoulders'),
       (2, 'back'),
       (3, 'legs'),
       (4, 'shoulders');

INSERT INTO Workout
    (name, trainerUsername)
VALUES ('Aidan Workout 1', 'aniceberg'),
       ('Aidan Workout 2 Upper Body', 'aniceberg');

INSERT INTO WorkoutExercise
    (workoutId, exerciseId, sets, reps)
VALUES (1, 1, 4, 8),
       (1, 2, 4, 6),
       (1, 3, 5, 8),
       (2, 1, 4, 5),
       (2, 2, 4, 5),
       (2, 4, 4, 12);

INSERT INTO Session
    (trainerUsername, clientUsername, workoutId, date, duration)
VALUES ('aniceberg', 'jdoe', 1, '2023-11-25', 60),
       ('aniceberg', 'janedoe', 2, '2023-11-30', 45);

-- -- mock dietitian data
INSERT INTO Dietitian(qualifiedSince, username)
VALUES ('2023-11-24', 'nabello'),
       ('2023-10-01', 'jdoe');

INSERT INTO DietitianClient(dietitianUsername, clientUsername)
VALUES ('nabello', 'ewiser'),
       ('jdoe', 'aniceberg');

INSERT INTO Ingredient(name, calories)
VALUES ('tomato', 20);
INSERT INTO Ingredient(name, calories, protein, carbs, cholesterol)
VALUES ('dough', 100, 8, 20, 30);
INSERT INTO Ingredient(name, calories, protein, carbs, fat, cholesterol)
VALUES ('cheese', 120, 12, 5, 20, 20);
INSERT INTO Ingredient(name, calories, carbs)
VALUES ('strawberry', 10, 4);
INSERT INTO Ingredient(name, calories, carbs, cholesterol)
VALUES ('banana', 80, 15, 4);
INSERT INTO Ingredient(name, calories, protein, carbs, fat, cholesterol)
VALUES ('peanut butter', 140, 6, 2, 3, 30);
INSERT INTO Ingredient(name, calories, protein, carbs, fat, cholesterol)
VALUES ('milk', 40, 3, 30, 5, 20);

INSERT INTO Allergen(allergenName, ingredientName)
VALUES ('lactose', 'cheese'),
       ('gluten', 'dough'),
       ('peanuts', 'peanut butter'),
       ('lactose', 'milk');
INSERT INTO Recipe(title, directions, cookTime)
VALUES ('pizza',
        'First, roast your tomatoes for 20 min and blend.
Then, spread out your dough, cover it in your tomato sauce, and sprinkle the cheese on top.
Feel free to add any toppings of your choice.', 20);
INSERT INTO Recipe(title, directions, cookTime)
VALUES ('fruity smoothie',
        'First, put your peanut butter, strawberries, milk, and bananas in your blender. Then blend until smooth.', 3);

INSERT INTO Diet(dietName, recipeID)
VALUES ('high-protein', 1),
       ('low-carb', 1),
       ('high-protein', 2);

INSERT INTO Amount(servings, measurement, recipeID, ingredientName)
VALUES (4, 'whole tomatoes', 1, 'tomato'),
       (2, 'Trader Joes packs', 1, 'dough'),
       (1, 'block', 1, 'cheese');
INSERT INTO Amount(servings, measurement, recipeID, ingredientName)
VALUES (6, 'whole strawberries', 2, 'strawberry'),
       (1, 'cups', 2, 'milk'),
       (1, 'whole bananas', 2, 'banana'),
       (3, 'spoonfuls', 2, 'peanut butter');

INSERT INTO RecipeRecommendation(dietitianUsername, username, recipeID)
VALUES ('nabello', 'ewiser', 1),
       ('jdoe', 'aniceberg', 2),
       ('nabello', 'ewiser', 2);

-- -- mock influencer data
INSERT INTO Influencer
    (followerCount, bio, username)
VALUES ('100', 'Empowering lives through fitness', 'ewiser'),
       ('50', 'Passionate trainer & motivator. Transforming bodies, inspiring souls. #FitLife #WellnessWarrior',
        'mfontenot');


INSERT INTO InfluencerFollower (influencerusername, followerUsername)
VALUES ('ewiser', 'janedoe'),
       ('mfontenot', 'jdoe');

INSERT INTO Brand (name)
VALUES ('Nike'),
       ('Alo'),
       ('Lululemon');

INSERT INTO Video (comments, likes, shares, duration, caption, brandName)
VALUES (120, 5000, 2000, 180, 'Morning Workout Motivation', 'Nike'),
       (80, 3000, 1500, 120, 'Running in the City', NULL),
       (150, 7000, 3000, 240, 'Fitness Challenge Accepted!', 'Nike'),
       (60, 2000, 1000, 90, 'Lululemon Lifestyle', 'Lululemon'),
       (100, 4000, 1800, 150, 'At home hot yoga', 'Alo');

INSERT INTO Posts (influencerUsername, videoId)
VALUES ('ewiser', 1),
       ('ewiser', 2),
       ('ewiser', 4),
       ('mfontenot', 1),
       ('mfontenot', 3),
       ('mfontenot', 5),
       ('mfontenot', 4);