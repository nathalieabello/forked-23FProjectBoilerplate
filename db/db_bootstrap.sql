-- This file is to bootstrap a database for the CS3200 project.

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith
-- data source creation.
DROP DATABASE IF EXISTS Shmoop;
CREATE DATABASE IF NOT EXISTS Shmoop;

-- Via the Docker Compose file, a special user called webapp will
-- be created in MySQL. We are going to grant that user
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
    dateJoined DATETIME     NOT NULL,
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
    qualifiedSince DATE NOT NULL,
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
-- -- mock user data
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

INSERT INTO GeneralUser (username, firstName, lastName, birthday, dateJoined, email, phone, sex, street, state, zip,
                         country, height, weight)
VALUES ('rissitt0', 'Ronnie', 'Issitt', '1976-02-20', '2008-06-12 02:26:23', 'rissitt0@disqus.com', '7147543417', 'F',
        '5609 Kim Drive', 'CA', '95128', 'United States', 53, 396),
       ('sparkes1', 'Stacee', 'Parkes', '1947-11-04', '2018-06-22 11:30:39', 'sparkes1@globo.com', '3042835336', 'F',
        '1128 Arkansas Street', 'WV', '25356', 'United States', 69, 330),
       ('jmoring2', 'Josefa', 'Moring', '2001-07-05', '2015-12-01 14:26:19', 'jmoring2@icq.com', '2812693377', 'F',
        '74619 Old Shore Point', 'TX', '77346', 'United States', 80, 258),
       ('rbernade3', 'Rudie', 'Bernade', '1976-04-17', '2007-12-07 13:06:07', 'rbernade3@geocities.com', '2124556551',
        'M', '15 Fairview Court', 'NY', '10131', 'United States', 75, 399),
       ('emion4', 'Emmey', 'Mion', '1998-04-18', '2010-09-17 03:32:15', 'emion4@nasa.gov', '8039546180', 'F',
        '9604 Brown Road', 'SC', '29240', 'United States', 77, 295),
       ('egillbanks5', 'Evvie', 'Gillbanks', '1969-12-08', '2014-02-09 09:41:28', 'egillbanks5@bandcamp.com',
        '8085935264', 'F', '602 Mcguire Point', 'HI', '96815', 'United States', 63, 296),
       ('bwhymark6', 'Bret', 'Whymark', '1992-11-03', '2011-06-03 16:31:19', 'bwhymark6@seesaa.net', '6125319903', 'M',
        '220 Hoard Lane', 'MN', '55436', 'United States', 64, 153),
       ('mmercey7', 'Monti', 'Mercey', '1953-12-13', '2015-03-27 15:45:24', 'mmercey7@cdc.gov', '6463350784', 'M',
        '8284 Autumn Leaf Hill', 'NY', '10175', 'United States', 84, 310),
       ('xmaldin8', 'Xever', 'Maldin', '1963-05-11', '2016-04-27 15:57:36', 'xmaldin8@vinaora.com', '8014343378', 'M',
        '54736 Corry Alley', 'UT', '84145', 'United States', 65, 376),
       ('lcanaan9', 'Ludvig', 'Canaan', '1942-11-13', '2021-08-07 00:27:59', 'lcanaan9@dagondesign.com', '4806715410',
        'M', '77 Nevada Point', 'AZ', '85219', 'United States', 82, 312),
       ('oguitton11', 'Obed', 'Guitton', '1996-08-19', '2013-08-26 10:40:38', 'oguitton11@dmoz.org', '2146827719', 'M',
        '371 Rockefeller Road', 'TX', '75358', 'United States', 77, 86),
       ('lkenton12', 'Lonnie', 'Kenton', '1943-02-24', '2012-02-04 04:28:05', 'lkenton12@whitehouse.gov', '6145194602',
        'F', '095 Dottie Center', 'OH', '43231', 'United States', 52, 117),
       ('dedwick13', 'Dieter', 'Edwick', '1995-05-13', '2018-04-23 09:22:00', 'dedwick13@gravatar.com', '7275280298',
        'M', '75159 Barby Road', 'FL', '33710', 'United States', 72, 104),
       ('lmidghall14', 'Loydie', 'Midghall', '1993-07-22', '2023-02-03 09:21:53', 'lmidghall14@vinaora.com',
        '6099123721', 'M', '79 School Terrace', 'NJ', '08638', 'United States', 64, 184),
       ('lvobes15', 'Lexy', 'Vobes', '1958-08-31', '2014-03-11 08:08:49', 'lvobes15@nyu.edu', '2023075752', 'F',
        '22726 Rutledge Court', 'DC', '20397', 'United States', 77, 302),
       ('ataverner16', 'Abagael', 'Taverner', '1986-03-27', '2014-07-25 22:57:27', 'ataverner16@joomla.org',
        '7138433884', 'F', '71 Scofield Place', 'TX', '77386', 'United States', 63, 330),
       ('wriba17', 'Woodie', 'Riba', '1946-10-20', '2022-08-04 16:00:09', 'wriba17@wsj.com', '4062605349', 'M',
        '14 Huxley Terrace', 'MT', '59623', 'United States', 69, 211),
       ('grisen18', 'Glad', 'Risen', '1947-10-19', '2021-08-18 14:32:50', 'grisen18@cornell.edu', '2025923175', 'F',
        '958 Hoffman Terrace', 'DC', '20503', 'United States', 52, 177),
       ('lpatman19', 'Linoel', 'Patman', '1960-06-26', '2010-05-12 06:13:22', 'lpatman19@google.de', '9701818420', 'M',
        '2653 8th Place', 'CO', '80638', 'United States', 50, 362),
       ('wfarguhar1a', 'Wynnie', 'Farguhar', '1950-01-19', '2022-11-22 09:27:32', 'wfarguhar1a@etsy.com', '2124836229',
        'F', '0467 Morning Court', 'NY', '10079', 'United States', 56, 333),
       ('cfeirn1b', 'Carissa', 'Feirn', '2003-07-09', '2014-06-01 00:32:18', 'cfeirn1b@reuters.com', '9527618658', 'F',
        '742 Crest Line Plaza', 'MN', '55579', 'United States', 69, 323),
       ('tghirigori1c', 'Tonnie', 'Ghirigori', '1955-06-21', '2023-02-27 06:17:57', 'tghirigori1c@youtube.com',
        '2126090590', 'M', '36745 Sachs Court', 'NY', '11231', 'United States', 61, 179),
       ('bcapner1d', 'Brewster', 'Capner', '1970-03-22', '2020-03-17 03:22:52', 'bcapner1d@vimeo.com', '8039311572',
        'M', '0610 Sauthoff Terrace', 'SC', '29805', 'United States', 58, 173),
       ('npratton1e', 'Nelli', 'Pratton', '1969-05-23', '2005-10-19 09:35:33', 'npratton1e@ebay.com', '7735667378', 'F',
        '751 Doe Crossing Trail', 'IL', '60619', 'United States', 79, 335),
       ('mmacfarlane1f', 'Michel', 'MacFarlane', '1961-04-24', '2006-11-01 03:18:12', 'mmacfarlane1f@auda.org.au',
        '3057202232', 'F', '871 Sloan Trail', 'FL', '33261', 'United States', 53, 83),
       ('kbaudinot1g', 'Kippy', 'Baudinot', '1984-03-22', '2020-06-23 00:25:28', 'kbaudinot1g@friendfeed.com',
        '3028362867', 'M', '74 Bellgrove Terrace', 'DE', '19892', 'United States', 56, 281),
       ('lprior1h', 'Lina', 'Prior', '1935-06-21', '2016-03-11 09:20:22', 'lprior1h@etsy.com', '6084904768', 'F',
        '22 Lotheville Court', 'WI', '53716', 'United States', 69, 249),
       ('drosenbaum1i', 'Dewie', 'Rosenbaum', '2004-09-24', '2022-01-17 05:12:04', 'drosenbaum1i@zdnet.com',
        '2021776719', 'M', '0029 Caliangt Drive', 'DC', '20319', 'United States', 55, 208),
       ('lcaffery1j', 'Loydie', 'Caffery', '1969-02-07', '2021-09-10 03:25:46', 'lcaffery1j@w3.org', '4064545731', 'M',
        '8 Trailsway Lane', 'MT', '59623', 'United States', 79, 311),
       ('etompkin1k', 'Eartha', 'Tompkin', '1964-09-11', '2014-12-27 00:34:16', 'etompkin1k@patch.com', '5592063370',
        'F', '1 Raven Parkway', 'CA', '93778', 'United States', 82, 260),
       ('cpetry1l', 'Crissy', 'Petry', '1941-02-03', '2017-09-18 23:28:53', 'cpetry1l@wufoo.com', '2168003487', 'F',
        '3 Hudson Trail', 'OH', '44130', 'United States', 55, 199),
       ('hclemo1m', 'Hewet', 'Clemo', '1948-10-02', '2009-09-16 23:49:18', 'hclemo1m@prnewswire.com', '4175249506', 'M',
        '465 Mallory Court', 'MO', '65898', 'United States', 52, 321),
       ('hhindrich1y', 'Hedvig', 'Hindrich', '1981-02-02', '2009-09-16 19:21:34', 'hhindrich1y@nih.gov', '2038542534',
        'F', '8279 Mandrake Junction', 'CT', '06105', 'United States', 68, 111),
       ('tstollberg1z', 'Terry', 'Stollberg', '1939-11-20', '2011-04-02 15:57:09', 'tstollberg1z@uiuc.edu',
        '7579895663', 'M', '4134 Mayfield Plaza', 'VA', '23612', 'United States', 49, 358),
       ('bnapoleone20', 'Blinnie', 'Napoleone', '1973-11-13', '2009-12-28 01:41:40', 'bnapoleone20@unc.edu',
        '5746378072', 'F', '0360 Evergreen Place', 'IN', '46614', 'United States', 62, 344),
       ('hhuggard21', 'Hartley', 'Huggard', '2002-02-26', '2007-09-10 07:56:57', 'hhuggard21@economist.com',
        '3525615491', 'M', '45005 Independence Plaza', 'FL', '32627', 'United States', 60, 363),
       ('rmarklund22', 'Raffaello', 'Marklund', '1930-12-19', '2010-10-08 01:55:16', 'rmarklund22@nbcnews.com',
        '8501881072', 'M', '07 Moulton Street', 'FL', '32511', 'United States', 67, 187),
       ('ssavory23', 'Syd', 'Savory', '2004-05-17', '2020-06-14 08:54:19', 'ssavory23@auda.org.au', '3011533178', 'M',
        '2330 Drewry Place', 'MD', '20910', 'United States', 76, 354),
       ('kdahlback24', 'Kit', 'Dahlback', '1997-05-19', '2012-12-05 10:00:58', 'kdahlback24@tinypic.com', '5712922478',
        'F', '246 1st Road', 'VA', '22119', 'United States', 50, 154),
       ('gphilip25', 'Guido', 'Philip', '1946-04-30', '2017-05-08 08:51:36', 'gphilip25@sciencedirect.com',
        '2129958526', 'M', '4244 Bayside Junction', 'NY', '10292', 'United States', 80, 277),
       ('omccheyne26', 'Ortensia', 'McCheyne', '1970-04-14', '2012-01-22 15:22:19', 'omccheyne26@sciencedirect.com',
        '2028612057', 'F', '196 Burrows Alley', 'DC', '20226', 'United States', 54, 334),
       ('qsinkin27', 'Quincy', 'Sinkin', '1956-03-23', '2013-08-30 15:53:35', 'qsinkin27@networksolutions.com',
        '4192728295', 'M', '4073 Old Gate Pass', 'OH', '43666', 'United States', 63, 254),
       ('elamburn28', 'Elia', 'Lamburn', '1941-10-16', '2010-12-14 22:17:02', 'elamburn28@csmonitor.com', '5053032822',
        'M', '3778 Express Street', 'NM', '87190', 'United States', 68, 218),
       ('ahallworth7o', 'Almeda', 'Hallworth', '1979-01-17', '2011-09-10 04:03:12', 'ahallworth7o@ehow.com',
        '2102113236', 'F', '114 Bellgrove Place', 'TX', '78250', 'United States', 84, 388),
       ('swretham7z', 'Stafford', 'Wretham', '1951-07-03', '2017-01-15 07:58:32', 'swretham7z@apple.com', '3166032186',
        'M', '4590 Nevada Trail', 'KS', '67220', 'United States', 75, 184),
       ('keva80', 'Kevin', 'Eva', '1980-04-07', '2011-09-12 04:24:54', 'keva80@exblog.jp', '7194170442', 'M',
        '23 American Park', 'CO', '80951', 'United States', 81, 366),
       ('msevers81', 'Munroe', 'Severs', '1969-02-21', '2012-12-14 11:37:05', 'msevers81@plala.or.jp', '2024230585',
        'M', '90 Maryland Street', 'DC', '20525', 'United States', 80, 214),
       ('lgreguoli82', 'Leena', 'Greguoli', '1963-04-14', '2016-04-03 05:57:53', 'lgreguoli82@guardian.co.uk',
        '4083233613', 'F', '1 David Center', 'CA', '95133', 'United States', 49, 372),
       ('scoysh83', 'Sherye', 'Coysh', '1993-09-17', '2015-02-10 11:39:34', 'scoysh83@abc.net.au', '3309708226', 'F',
        '96551 Hoffman Trail', 'OH', '44329', 'United States', 50, 140),
       ('fnial84', 'Franklyn', 'Nial', '1939-05-17', '2008-09-21 06:28:54', 'fnial84@geocities.jp', '6146252030', 'M',
        '5 Kropf Alley', 'OH', '43268', 'United States', 79, 375),
       ('mbeckitt85', 'Mahmud', 'Beckitt', '1962-08-28', '2008-08-19 10:56:10', 'mbeckitt85@nsw.gov.au', '3375641634',
        'M', '75050 Forest Dale Hill', 'LA', '70593', 'United States', 71, 156),
       ('bbarzen86', 'Ban', 'Barzen', '1972-03-14', '2015-02-03 08:05:23', 'bbarzen86@google.co.jp', '5041193726', 'M',
        '00 Fieldstone Terrace', 'LA', '70149', 'United States', 71, 81),
       ('cstrelitzer87', 'Carrie', 'Strelitzer', '1968-10-03', '2016-09-27 01:49:03', 'cstrelitzer87@alibaba.com',
        '5029864405', 'F', '3425 Bluejay Pass', 'KY', '40256', 'United States', 72, 383),
       ('gbunt88', 'Gregorius', 'Bunt', '1961-02-23', '2010-05-07 00:06:46', 'gbunt88@salon.com', '7859364265', 'M',
        '69 Milwaukee Park', 'KS', '66699', 'United States', 74, 261),
       ('rsell89', 'Roderigo', 'Sell', '1970-02-03', '2006-12-17 22:37:50', 'rsell89@japanpost.jp', '3139714506', 'M',
        '804 Brown Way', 'MI', '48217', 'United States', 78, 200),
       ('tviegas8a', 'Timothy', 'Viegas', '1969-09-03', '2012-10-04 14:40:47', 'tviegas8a@rediff.com', '2196562745',
        'M', '93 Bluejay Alley', 'IN', '46406', 'United States', 52, 131),
       ('kfautly8b', 'Korry', 'Fautly', '1990-03-17', '2013-03-31 22:52:58', 'kfautly8b@yahoo.co.jp', '3342361261', 'F',
        '64 Gateway Center', 'AL', '36119', 'United States', 72, 340);

SELECT username
FROM GeneralUser;

INSERT INTO UserMedicalHistory(username, injury, occurred)
VALUES ('cstrelitzer87', 'Broken nose', '2023-01-20'),
       ('cfeirn1b', 'Repetitive strain injury (RSI)', '2023-01-20'),
       ('hclemo1m', 'Achilles tendonitis', '2023-01-20'),
       ('hhindrich1y', 'Rib fracture', '2023-01-20'),
       ('rbernade3', 'Repetitive strain injury (RSI)', '2023-01-20'),
       ('scoysh83', 'Burns', '2023-01-20'),
       ('aniceberg', 'Repetitive strain injury (RSI)', '2023-01-20'),
       ('gbunt88', 'Frostbite', '2023-01-20'),
       ('mbeckitt85', 'Broken nose', '2023-01-20'),
       ('wfarguhar1a', 'Frostbite', '2023-01-20'),
       ('tari', 'Concussion', '2023-01-20'),
       ('bbarzen86', 'Repetitive strain injury (RSI)', '2023-01-20'),
       ('ahallworth7o', 'Torn ACL', '2023-01-20'),
       ('mfontenot', 'Sprained ankle', '2023-01-20'),
       ('rissitt0', 'Burns', '2023-01-20'),
       ('wfarguhar1a', 'Dislocated jaw', '2023-01-20'),
       ('rissitt0', 'Rib fracture', '2023-01-20'),
       ('lmidghall14', 'Herniated disc', '2023-01-20'),
       ('gbunt88', 'Burns', '2023-01-20'),
       ('rissitt0', 'Whiplash', '2023-01-20'),
       ('rsell89', 'Repetitive strain injury (RSI)', '2023-01-20'),
       ('lgreguoli82', 'Dislocated knee', '2023-01-20'),
       ('bwhymark6', 'Stress fracture', '2023-01-20'),
       ('hclemo1m', 'Torn ACL', '2023-01-20'),
       ('ataverner16', 'Torn ACL', '2023-01-20'),
       ('bcapner1d', 'Broken leg', '2023-01-20'),
       ('etompkin1k', 'Broken collarbone', '2023-01-20'),
       ('lmidghall14', 'Shin splints', '2023-01-20'),
       ('cfeirn1b', 'Pulled hamstring', '2023-01-20'),
       ('bbarzen86', 'Dislocated jaw', '2023-01-20'),
       ('bnapoleone20', 'Concussion', '2023-01-20'),
       ('keva80', 'Hyperextension injury', '2023-01-20'),
       ('kbaudinot1g', 'Fractured wrist', '2023-01-20'),
       ('gphilip25', 'Burns', '2023-01-20'),
       ('tghirigori1c', 'Shin splints', '2023-01-20'),
       ('tghirigori1c', 'Burns', '2023-01-20'),
       ('omccheyne26', 'Nerve damage', '2023-01-20'),
       ('rsell89', 'Nerve damage', '2023-01-20'),
       ('msevers81', 'Dislocated shoulder', '2023-01-20'),
       ('elamburn28', 'Sprained ankle', '2023-01-20');

INSERT INTO UserAllergies (username, allergy)
VALUES ('hhindrich1y', 'Pineapple'),
       ('hhuggard21', 'Sunlight (solar urticaria)'),
       ('etompkin1k', 'Heat (heat rash or urticaria)'),
       ('cstrelitzer87', 'Banana'),
       ('hclemo1m', 'Food additives and preservatives'),
       ('lkenton12', 'Sulphites'),
       ('lmidghall14', 'Tree nuts'),
       ('nabello', 'Formaldehyde'),
       ('rmarklund22', 'Wheat'),
       ('lcaffery1j', 'Fish'),
       ('msevers81', 'Formaldehyde'),
       ('hhindrich1y', 'Peanuts'),
       ('wriba17', 'Pollen'),
       ('wriba17', 'Avocado'),
       ('lprior1h', 'Corn'),
       ('hhuggard21', 'Mango'),
       ('etompkin1k', 'Chemicals (contact dermatitis)'),
       ('janedoe', 'Corn'),
       ('cfeirn1b', 'Insect bites'),
       ('aniceberg', 'Soy'),
       ('lmidghall14', 'Shellfish'),
       ('bbarzen86', 'Pineapple'),
       ('lgreguoli82', 'Insect venom'),
       ('kbaudinot1g', 'Red dye'),
       ('bnapoleone20', 'Dust mites'),
       ('swretham7z', 'Food additives and preservatives'),
       ('tstollberg1z', 'Pollen'),
       ('lcaffery1j', 'Chemicals (contact dermatitis)'),
       ('lkenton12', 'Wheat'),
       ('lgreguoli82', 'Chamomile'),
       ('bcapner1d', 'Sulfa drugs'),
       ('qsinkin27', 'Tree nuts'),
       ('kdahlback24', 'Mold'),
       ('lprior1h', 'Penicillin'),
       ('ewiser', 'Gluten'),
       ('cpetry1l', 'Aspirin'),
       ('janedoe', 'Strawberries'),
       ('bbarzen86', 'Corn'),
       ('scoysh83', 'Pineapple'),
       ('nabello', 'Artificial sweeteners');

INSERT INTO Goal(description, status, username)
VALUES ('Prioritize mental health through stress management techniques', 'in progress', 'dedwick13'),
       ('Strive for a healthy work-life balance to reduce burnout', 'achieved', 'ataverner16'),
       ('Limit screen time before bedtime for improved sleep quality', 'achieved', 'msevers81'),
       ('Limit processed and sugary foods for better health', 'in progress', 'elamburn28'),
       ('Practice portion control to manage weight effectively', 'not started', 'tari'),
       ('Limit screen time before bedtime for improved sleep quality', 'achieved', 'lprior1h'),
       ('Explore and adopt new forms of physical activity for variety', 'not started', 'tviegas8a'),
       ('Incorporate more fruits and vegetables into daily meals', 'achieved', 'jdoe'),
       ('Explore and adopt new forms of physical activity for variety', 'in progress', 'ssavory23'),
       ('Incorporate more fruits and vegetables into daily meals', 'not started', 'elamburn28'),
       ('Limit screen time before bedtime for improved sleep quality', 'achieved', 'tari'),
       ('Get regular check-ups and screenings for preventive healthcare', 'in progress', 'mmercey7'),
       ('Limit screen time before bedtime for improved sleep quality', 'in progress', 'cpetry1l'),
       ('Incorporate more fruits and vegetables into daily meals', 'not started', 'bnapoleone20'),
       ('Set realistic fitness goals for gradual and sustainable progress', 'in progress', 'grisen18'),
       ('Practice portion control to manage weight effectively', 'in progress', 'gphilip25'),
       ('Strive for a healthy work-life balance to reduce burnout', 'in progress', 'wfarguhar1a'),
       ('Prioritize mental health through stress management techniques', 'in progress', 'nabello'),
       ('Incorporate more fruits and vegetables into daily meals', 'in progress', 'cstrelitzer87'),
       ('Practice mindfulness and meditation for mental well-being', 'not started', 'wriba17'),
       ('Achieve a consistent sleep routine for better rest', 'in progress', 'aniceberg'),
       ('Incorporate more fruits and vegetables into daily meals', 'not started', 'janedoe'),
       ('Achieve a consistent sleep routine for better rest', 'not started', 'mmercey7'),
       ('Practice portion control to manage weight effectively', 'achieved', 'wriba17'),
       ('Limit screen time before bedtime for improved sleep quality', 'not started', 'gbunt88'),
       ('Incorporate more fruits and vegetables into daily meals', 'in progress', 'kdahlback24'),
       ('Limit screen time before bedtime for improved sleep quality', 'not started', 'oguitton11'),
       ('Establish and maintain a regular exercise schedule', 'achieved', 'nabello'),
       ('Strive for a healthy work-life balance to reduce burnout', 'not started', 'bwhymark6'),
       ('Set realistic fitness goals for gradual and sustainable progress', 'not started', 'rsell89'),
       ('Incorporate more fruits and vegetables into daily meals', 'in progress', 'xmaldin8'),
       ('Stay hydrated by drinking an adequate amount of water daily', 'in progress', 'jmoring2'),
       ('Establish and maintain a regular exercise schedule', 'achieved', 'etompkin1k'),
       ('Achieve a consistent sleep routine for better rest', 'achieved', 'npratton1e'),
       ('Prioritize mental health through stress management techniques', 'achieved', 'sparkes1'),
       ('Strive for a healthy work-life balance to reduce burnout', 'not started', 'mbeckitt85'),
       ('Achieve a consistent sleep routine for better rest', 'in progress', 'emion4'),
       ('Strive for a healthy work-life balance to reduce burnout', 'not started', 'egillbanks5'),
       ('Limit screen time before bedtime for improved sleep quality', 'achieved', 'lkenton12'),
       ('Set realistic fitness goals for gradual and sustainable progress', 'achieved', 'scoysh83');

INSERT INTO DailySteps (date, stepCount, username)
VALUES ('2019-11-26', 23425, 'nabello'),
       ('2019-05-19', 7098, 'ewiser'),
       ('2020-05-20', 29019, 'lvobes15'),
       ('2022-09-09', 662, 'jdoe'),
       ('2005-02-25', 19495, 'mmercey7'),
       ('2016-05-26', 17542, 'kdahlback24'),
       ('2020-04-22', 9923, 'egillbanks5'),
       ('2011-10-12', 27474, 'bcapner1d'),
       ('2022-01-23', 10713, 'hhindrich1y'),
       ('2021-11-08', 6224, 'swretham7z'),
       ('2021-08-30', 13478, 'bnapoleone20'),
       ('2017-12-28', 29144, 'xmaldin8'),
       ('2013-11-11', 26773, 'bwhymark6'),
       ('2013-06-19', 563, 'tviegas8a'),
       ('2005-04-27', 14846, 'fnial84'),
       ('2007-03-31', 12435, 'bnapoleone20'),
       ('2017-06-15', 17503, 'keva80'),
       ('2013-12-21', 1430, 'hhindrich1y'),
       ('2018-01-07', 29438, 'ataverner16'),
       ('2016-01-18', 25220, 'drosenbaum1i'),
       ('2022-04-30', 16098, 'lgreguoli82'),
       ('2007-10-29', 11518, 'mbeckitt85'),
       ('2023-06-04', 25007, 'etompkin1k'),
       ('2021-09-22', 18247, 'tghirigori1c'),
       ('2009-04-16', 5563, 'ewiser'),
       ('2005-09-08', 18638, 'mmacfarlane1f'),
       ('2007-05-24', 18548, 'bnapoleone20'),
       ('2005-09-07', 12119, 'tviegas8a'),
       ('2015-12-13', 20586, 'rmarklund22'),
       ('2018-10-31', 25700, 'gbunt88'),
       ('2021-10-30', 21102, 'jdoe'),
       ('2008-04-02', 14598, 'lprior1h'),
       ('2017-04-24', 12913, 'elamburn28'),
       ('2007-07-23', 20353, 'mmercey7'),
       ('2007-02-22', 25754, 'ssavory23'),
       ('2016-10-15', 23818, 'msevers81'),
       ('2008-12-23', 2057, 'tghirigori1c'),
       ('2011-08-22', 4307, 'ewiser'),
       ('2020-12-03', 15093, 'hhuggard21'),
       ('2013-08-10', 27210, 'gphilip25');

INSERT INTO DailyMacros (date, calorieCount, proteinCount, carbCount, fatCount, username)
VALUES ('2017-01-09', 2229, 77, 451, 194, 'mmacfarlane1f'),
       ('2010-05-31', 328, 2, 488, 61, 'lcaffery1j'),
       ('2006-01-03', 7495, 55, 55, 269, 'lprior1h'),
       ('2009-03-14', 6046, 3, 261, 189, 'lmidghall14'),
       ('2022-11-17', 6324, 8, 227, 177, 'fnial84'),
       ('2009-07-11', 7530, 55, 155, 256, 'egillbanks5'),
       ('2018-03-26', 6491, 50, 321, 246, 'cpetry1l'),
       ('2022-08-24', 833, 77, 277, 161, 'ewiser'),
       ('2012-05-12', 4563, 9, 58, 1, 'hclemo1m'),
       ('2011-04-15', 900, 9, 97, 270, 'omccheyne26'),
       ('2006-02-04', 1305, 49, 296, 204, 'wriba17'),
       ('2018-12-10', 7934, 52, 407, 129, 'kdahlback24'),
       ('2009-06-04', 833, 60, 288, 132, 'janedoe'),
       ('2009-12-10', 2272, 26, 396, 220, 'hhuggard21'),
       ('2016-10-09', 2968, 43, 440, 213, 'lmidghall14'),
       ('2013-05-22', 5860, 37, 166, 12, 'nabello'),
       ('2010-05-09', 4506, 98, 358, 13, 'nabello'),
       ('2008-06-28', 7954, 87, 189, 72, 'ewiser'),
       ('2013-10-31', 3642, 86, 300, 126, 'gbunt88'),
       ('2008-08-28', 1554, 32, 247, 136, 'nabello'),
       ('2015-08-28', 6616, 56, 475, 55, 'wfarguhar1a'),
       ('2009-02-17', 5070, 6, 487, 8, 'kdahlback24'),
       ('2010-01-22', 490, 47, 23, 69, 'xmaldin8'),
       ('2011-07-31', 2060, 55, 44, 266, 'ahallworth7o'),
       ('2014-08-24', 1552, 37, 44, 223, 'mmacfarlane1f'),
       ('2007-11-27', 6706, 24, 184, 11, 'rbernade3'),
       ('2008-04-26', 1818, 36, 383, 42, 'lprior1h'),
       ('2021-09-11', 5389, 49, 43, 137, 'rsell89'),
       ('2011-10-29', 564, 94, 102, 128, 'lvobes15'),
       ('2015-01-09', 711, 88, 462, 219, 'kdahlback24'),
       ('2022-07-10', 3772, 19, 435, 174, 'rbernade3'),
       ('2019-11-09', 6176, 58, 300, 13, 'bbarzen86'),
       ('2015-09-07', 2518, 13, 200, 112, 'hhuggard21'),
       ('2020-03-02', 3973, 24, 182, 74, 'rissitt0'),
       ('2008-02-27', 4136, 84, 233, 101, 'janedoe'),
       ('2015-08-06', 299, 49, 10, 71, 'tari'),
       ('2010-06-29', 243, 45, 245, 185, 'lkenton12'),
       ('2021-03-01', 5998, 46, 280, 133, 'lmidghall14'),
       ('2011-04-14', 7030, 33, 356, 177, 'lkenton12'),
       ('2016-10-11', 707, 2, 304, 158, 'tghirigori1c');

INSERT INTO SleepInfo (datetimeStarted, datetimeEnded, REMTime, NREMTime, username)
VALUES ('2022-07-01 16:41:54', '2022-07-02 10:07:16', 1, 13, 'aniceberg'),
       ('2022-07-01 22:54:20', '2022-07-02 07:23:00', 3, 7, 'tviegas8a'),
       ('2022-07-01 02:36:29', '2022-07-02 01:30:41', 2, 3, 'lprior1h'),
       ('2022-07-01 20:22:37', '2022-07-02 06:28:08', 3, 4, 'elamburn28'),
       ('2022-07-01 03:07:31', '2022-07-02 11:58:42', 3, 9, 'keva80'),
       ('2022-07-01 15:05:50', '2022-07-02 00:35:23', 2, 3, 'hhuggard21'),
       ('2022-07-01 03:58:46', '2022-07-02 07:46:32', 2, 13, 'fnial84'),
       ('2022-07-01 01:26:43', '2022-07-02 23:19:00', 3, 10, 'rissitt0'),
       ('2022-07-01 10:30:18', '2022-07-02 00:15:30', 3, 9, 'omccheyne26'),
       ('2022-07-01 03:37:13', '2022-07-02 22:22:39', 0, 3, 'bbarzen86'),
       ('2022-05-01 07:14:17', '2022-01-01 05:22:43', 1, 5, 'hhuggard21'),
       ('2022-09-02 20:05:25', '2022-01-01 08:08:52', 3, 3, 'egillbanks5'),
       ('2022-11-06 15:33:42', '2022-01-01 08:03:03', 0, 3, 'bwhymark6'),
       ('2022-05-22 09:16:41', '2022-01-01 05:36:43', 2, 9, 'rbernade3'),
       ('2022-06-09 20:41:51', '2022-01-01 09:27:48', 0, 13, 'wfarguhar1a'),
       ('2022-05-03 01:04:23', '2022-01-01 18:27:00', 2, 6, 'lgreguoli82'),
       ('2022-07-13 01:22:42', '2022-01-01 00:31:36', 0, 11, 'rissitt0'),
       ('2022-03-26 14:59:51', '2022-01-01 23:03:50', 1, 4, 'tstollberg1z'),
       ('2022-04-13 03:19:16', '2022-01-01 09:58:09', 0, 12, 'xmaldin8'),
       ('2022-05-20 18:23:50', '2022-01-01 05:44:10', 2, 11, 'bwhymark6'),
       ('2010-05-06 19:12:47', '2010-05-07 18:04:37', 3, 12, 'qsinkin27'),
       ('2010-05-06 12:34:43', '2010-05-07 23:33:45', 3, 3, 'cpetry1l'),
       ('2010-05-06 13:43:18', '2010-05-07 15:51:38', 0, 13, 'tari'),
       ('2010-05-06 16:24:42', '2010-05-07 18:04:37', 0, 10, 'cstrelitzer87'),
       ('2010-05-06 11:38:48', '2010-05-07 01:24:07', 3, 13, 'keva80'),
       ('2010-05-06 00:00:19', '2010-05-07 09:33:52', 1, 6, 'lmidghall14'),
       ('2010-05-06 19:46:56', '2010-05-07 21:54:24', 0, 3, 'wriba17'),
       ('2010-05-06 06:50:05', '2010-05-07 12:25:37', 1, 14, 'lvobes15'),
       ('2010-05-06 09:43:13', '2010-05-07 02:25:15', 0, 4, 'gbunt88'),
       ('2010-05-06 22:54:35', '2010-05-07 04:08:36', 0, 12, 'bcapner1d'),
       ('2010-05-06 01:28:10', '2010-05-07 13:03:57', 0, 14, 'qsinkin27'),
       ('2010-05-06 17:04:24', '2010-05-07 23:41:11', 3, 6, 'aniceberg'),
       ('2010-05-06 07:29:25', '2010-05-07 16:52:09', 0, 11, 'cstrelitzer87'),
       ('2010-05-06 03:15:45', '2010-05-07 18:57:14', 3, 13, 'bnapoleone20'),
       ('2010-05-06 04:40:32', '2010-05-07 12:46:30', 1, 9, 'xmaldin8'),
       ('2010-05-06 16:52:53', '2010-05-07 12:57:12', 1, 6, 'lgreguoli82'),
       ('2010-05-06 03:49:01', '2010-05-07 03:51:52', 2, 4, 'bwhymark6'),
       ('2010-05-06 14:09:56', '2010-05-07 05:39:40', 0, 3, 'lcanaan9'),
       ('2010-05-06 06:04:52', '2010-05-07 12:15:31', 1, 9, 'drosenbaum1i'),
       ('2010-05-06 09:55:37', '2010-05-07 21:05:54', 2, 3, 'wriba17');

