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
        '64 Gateway Center', 'AL', '36119', 'United States', 72, 340),
       ('tjoncic0', 'Teresina', 'Joncic', '2002-03-15', '2017-02-26 00:58:07', 'tjoncic0@multiply.com', '8178915847',
        'F', '4188 Susan Park', 'TX', '76129', 'United States', 49, 149),
       ('sfosse1', 'Sherry', 'Fosse', '2003-05-13', '2019-05-04 21:24:32', 'sfosse1@bloomberg.com', '6611561107', 'F',
        '39 Lake View Court', 'CA', '91505', 'United States', 69, 261),
       ('pdilliway2', 'Papageno', 'Dilliway', '1994-05-02', '2011-06-21 21:22:30', 'pdilliway2@cornell.edu',
        '7703160918', 'M', '681 Milwaukee Plaza', 'GA', '30066', 'United States', 64, 187),
       ('rpuckham3', 'Rock', 'Puckham', '1999-10-01', '2011-03-12 07:16:51', 'rpuckham3@hatena.ne.jp', '8043542579',
        'M', '6 Sutteridge Junction', 'VA', '23208', 'United States', 79, 290),
       ('gbanister4', 'Grayce', 'Banister', '2003-01-13', '2012-07-27 16:58:08', 'gbanister4@amazon.co.jp',
        '8011261052', 'F', '39934 Hooker Road', 'UT', '84199', 'United States', 69, 221),
       ('nburtwhistle5', 'Nolana', 'Burtwhistle', '1978-06-08', '2011-03-28 19:59:05', 'nburtwhistle5@cbsnews.com',
        '3369386659', 'F', '728 Gina Crossing', 'NC', '27499', 'United States', 83, 208),
       ('mscoggan6', 'Mab', 'Scoggan', '1992-01-12', '2012-12-22 10:56:59', 'mscoggan6@mit.edu', '9154411236', 'F',
        '570 Westerfield Center', 'TX', '79923', 'United States', 83, 299),
       ('thigounet7', 'Tomasina', 'Higounet', '2008-03-19', '2023-12-06 18:36:34', 'thigounet7@wordpress.com',
        '3614578454', 'F', '540 Pankratz Parkway', 'TX', '78426', 'United States', 75, 262),
       ('cnabarro8', 'Cristionna', 'Nabarro', '1997-10-11', '2009-07-16 21:47:51', 'cnabarro8@hud.gov', '9049176423',
        'F', '2 Larry Alley', 'FL', '32236', 'United States', 54, 264),
       ('ncoolbear9', 'Noelani', 'Coolbear', '2010-01-11', '2011-02-25 08:23:07', 'ncoolbear9@imageshack.us',
        '5159891074', 'F', '143 Pawling Park', 'IA', '50369', 'United States', 51, 286),
       ('atrowela', 'Anstice', 'Trowel', '1982-11-19', '2021-05-01 01:31:07', 'atrowela@github.com', '5022667018', 'F',
        '36 Jenna Street', 'KY', '41905', 'United States', 73, 103),
       ('ccurdellb', 'Courtney', 'Curdell', '2000-01-17', '2014-01-02 18:31:36', 'ccurdellb@slideshare.net',
        '9159878862', 'M', '8573 Melody Terrace', 'TX', '88584', 'United States', 59, 234),
       ('bhowarthc', 'Bambie', 'Howarth', '1991-03-24', '2010-09-25 07:17:21', 'bhowarthc@skype.com', '3155385528', 'F',
        '41752 Homewood Junction', 'NY', '13217', 'United States', 59, 271),
       ('bboytond', 'Bogart', 'Boyton', '2002-05-08', '2020-11-26 21:18:36', 'bboytond@jalbum.net', '3396396406', 'M',
        '436 Tomscot Trail', 'MA', '01813', 'United States', 73, 288),
       ('jwante', 'Jeramie', 'Want', '1990-11-16', '2020-01-07 18:24:06', 'jwante@netlog.com', '5591257417', 'M',
        '61687 Farwell Lane', 'CA', '93704', 'United States', 58, 294),
       ('credingtonf', 'Cletus', 'Redington', '1980-12-10', '2008-10-24 04:34:12', 'credingtonf@mozilla.com',
        '6019141640', 'M', '4 Armistice Drive', 'MS', '39210', 'United States', 74, 141),
       ('ygageng', 'Yovonnda', 'Gagen', '1989-02-21', '2019-07-28 10:12:27', 'ygageng@example.com', '9195100880', 'F',
        '00659 International Parkway', 'NC', '27690', 'United States', 67, 234),
       ('chumbellh', 'Claudian', 'Humbell', '1988-10-20', '2016-05-09 17:47:16', 'chumbellh@epa.gov', '8131780554', 'M',
        '026 Arapahoe Road', 'FL', '33694', 'United States', 52, 112),
       ('cbrauningeri', 'Caz', 'Brauninger', '1989-11-16', '2017-05-19 23:59:17', 'cbrauningeri@w3.org', '9372134133',
        'M', '31 Forest Drive', 'OH', '45414', 'United States', 52, 230),
       ('tgoakesj', 'Trenton', 'Goakes', '1987-08-27', '2017-09-06 07:33:43', 'tgoakesj@about.me', '6036042571', 'M',
        '61032 Forest Run Drive', 'NH', '03804', 'United States', 48, 176),
       ('eheeneyk', 'Ermina', 'Heeney', '1986-11-17', '2019-04-09 00:26:20', 'eheeneyk@arstechnica.com', '2251439250',
        'F', '13 Debra Point', 'LA', '70820', 'United States', 58, 107),
       ('wgurnelll', 'Winnie', 'Gurnell', '1978-07-04', '2021-04-09 23:17:41', 'wgurnelll@ox.ac.uk', '6028379951', 'M',
        '4354 Green Terrace', 'AZ', '85311', 'United States', 53, 164),
       ('kbrewoodm', 'Kareem', 'Brewood', '1998-01-05', '2022-12-21 15:32:31', 'kbrewoodm@dropbox.com', '4327085331',
        'M', '035 Marcy Junction', 'TX', '79705', 'United States', 64, 105),
       ('wsandilandsn', 'Westbrooke', 'Sandilands', '1999-05-04', '2023-04-23 22:54:01', 'wsandilandsn@edublogs.org',
        '3156246771', 'M', '44 Fuller Terrace', 'NY', '13251', 'United States', 80, 211),
       ('jmcpakeo', 'Jammal', 'McPake', '2003-01-21', '2015-11-17 07:17:48', 'jmcpakeo@answers.com', '8599413911', 'M',
        '103 Lawn Place', 'KY', '40505', 'United States', 72, 114),
       ('rsedgemondp', 'Riordan', 'Sedgemond', '1979-06-19', '2014-02-22 00:45:52', 'rsedgemondp@amazonaws.com',
        '7148803646', 'M', '72 Longview Junction', 'CA', '92822', 'United States', 76, 252),
       ('lparradiceq', 'Lock', 'Parradice', '1984-11-01', '2012-09-24 08:03:34', 'lparradiceq@patch.com', '9165723298',
        'M', '4 Glendale Lane', 'CA', '95865', 'United States', 57, 165),
       ('tcornillir', 'Tonia', 'Cornilli', '1999-01-03', '2009-04-01 18:20:06', 'tcornillir@tinyurl.com', '2543251430',
        'F', '4364 Sutherland Park', 'TX', '76505', 'United States', 75, 151),
       ('sdowdalls', 'Sydel', 'Dowdall', '1996-08-07', '2016-12-08 09:09:55', 'sdowdalls@timesonline.co.uk',
        '8306773585', 'F', '34 Darwin Crossing', 'TX', '78260', 'United States', 71, 296),
       ('dpickovert', 'Delores', 'Pickover', '1983-05-03', '2011-04-21 12:02:15', 'dpickovert@rakuten.co.jp',
        '9168648543', 'F', '35 Forest Run Place', 'CA', '94297', 'United States', 72, 159),
       ('lmartynikhinu', 'Levon', 'Martynikhin', '1998-09-21', '2009-07-31 05:59:35', 'lmartynikhinu@cnet.com',
        '4124202431', 'M', '6645 Lotheville Park', 'PA', '15230', 'United States', 56, 253),
       ('bdooneyv', 'Benton', 'Dooney', '1984-01-20', '2023-10-02 16:20:23', 'bdooneyv@stumbleupon.com', '8321971802',
        'M', '91165 Bashford Lane', 'TX', '77055', 'United States', 65, 273),
       ('estorekw', 'Elisabeth', 'Storek', '1981-05-11', '2008-07-24 00:08:48', 'estorekw@newsvine.com', '9544400260',
        'F', '2402 Golf Course Avenue', 'FL', '33305', 'United States', 79, 156),
       ('mmcgirlx', 'Margareta', 'McGirl', '2008-04-29', '2017-08-28 06:47:32', 'mmcgirlx@list-manage.com',
        '6022728835', 'F', '3199 Commercial Circle', 'AZ', '85067', 'United States', 79, 272),
       ('emckeaneyy', 'Eamon', 'McKeaney', '2002-12-25', '2019-02-26 23:30:38', 'emckeaneyy@nba.com', '2543227648', 'M',
        '606 Northview Avenue', 'TX', '76711', 'United States', 79, 111),
       ('abrithmanz', 'Alfredo', 'Brithman', '2001-10-11', '2014-03-11 03:52:28', 'abrithmanz@xinhuanet.com',
        '9176278270', 'M', '49 Dottie Road', 'NY', '10034', 'United States', 82, 268),
       ('jagett10', 'Jarid', 'Agett', '1982-12-21', '2014-04-12 02:04:04', 'jagett10@comsenz.com', '3373374068', 'M',
        '38266 Schiller Alley', 'LA', '70505', 'United States', 66, 111),
       ('kfenge11', 'Karita', 'Fenge', '1990-04-25', '2022-12-14 21:14:53', 'kfenge11@unicef.org', '8599303786', 'F',
        '53284 Di Loreto Place', 'KY', '40596', 'United States', 79, 258),
       ('mmerigot12', 'Mitch', 'Merigot', '2007-12-20', '2015-12-09 06:45:35', 'mmerigot12@geocities.com', '7029339632',
        'M', '63 Summit Plaza', 'NV', '89150', 'United States', 70, 252),
       ('rbridat13', 'Rois', 'Bridat', '1988-09-02', '2021-09-30 03:26:21', 'rbridat13@apache.org', '3182000334', 'F',
        '3510 Mccormick Park', 'LA', '71166', 'United States', 78, 181),
       ('ogrindley14', 'Orella', 'Grindley', '1981-11-10', '2008-11-02 17:20:36', 'ogrindley14@kickstarter.com',
        '7856337384', 'F', '92 Crowley Plaza', 'KS', '66606', 'United States', 56, 156),
       ('eburdikin15', 'Elwyn', 'Burdikin', '1999-10-28', '2013-06-27 01:07:24', 'eburdikin15@last.fm', '7732545495',
        'M', '0483 Blaine Center', 'IL', '60657', 'United States', 66, 121),
       ('stedahl16', 'Skylar', 'Tedahl', '1989-12-31', '2010-01-02 12:19:51', 'stedahl16@slate.com', '3047875830', 'M',
        '11 Miller Alley', 'WV', '25721', 'United States', 78, 296),
       ('zantonin17', 'Zane', 'Antonin', '1999-03-02', '2021-03-02 13:46:34', 'zantonin17@fda.gov', '2513484000', 'M',
        '36088 Southridge Avenue', 'AL', '36622', 'United States', 61, 169),
       ('vjochen18', 'Val', 'Jochen', '1994-05-03', '2013-01-06 04:34:26', 'vjochen18@tripod.com', '5732594662', 'M',
        '4048 Bartelt Place', 'MO', '65211', 'United States', 48, 116),
       ('hdillingston19', 'Heinrick', 'Dillingston', '1987-04-05', '2010-08-28 02:04:34', 'hdillingston19@t.co',
        '7632192084', 'M', '81776 Grim Alley', 'MN', '55585', 'United States', 72, 199),
       ('cmogg1a', 'Conway', 'Mogg', '1976-03-09', '2024-04-04 19:59:36', 'cmogg1a@seattletimes.com', '5125266791', 'M',
        '14252 Myrtle Hill', 'TX', '78682', 'United States', 68, 240),
       ('mmaycock1b', 'Merle', 'Maycock', '2008-01-25', '2022-04-05 10:56:50', 'mmaycock1b@netlog.com', '5132071218',
        'M', '0820 Harbort Terrace', 'OH', '45208', 'United States', 76, 262),
       ('iobell1c', 'Israel', 'Obell', '2006-09-01', '2009-02-02 13:19:17', 'iobell1c@example.com', '8046661878', 'M',
        '08 Huxley Plaza', 'VA', '23213', 'United States', 80, 120),
       ('kgooderick1d', 'Kettie', 'Gooderick', '1999-09-29', '2009-08-26 08:26:32', 'kgooderick1d@4shared.com',
        '7578913818', 'F', '1 Caliangt Pass', 'VA', '23705', 'United States', 80, 149),
       ('tshemmin1e', 'Thurston', 'Shemmin', '1996-04-06', '2016-08-27 02:01:52', 'tshemmin1e@etsy.com', '9016742378',
        'M', '404 Esch Alley', 'TN', '38168', 'United States', 73, 127),
       ('bwyant1f', 'Brita', 'Wyant', '1989-03-16', '2023-09-27 06:54:43', 'bwyant1f@dot.gov', '2029980890', 'F',
        '8232 Orin Lane', 'DC', '20530', 'United States', 61, 206),
       ('rsearl1g', 'Rosemaria', 'Searl', '1983-08-26', '2024-03-18 09:19:59', 'rsearl1g@geocities.com', '7061657377',
        'F', '1566 Eastwood Point', 'GA', '31914', 'United States', 80, 221),
       ('tfinan1h', 'Tyrus', 'Finan', '1984-06-04', '2024-05-25 02:27:28', 'tfinan1h@github.com', '8169067697', 'M',
        '5566 Manley Road', 'MO', '64187', 'United States', 71, 142),
       ('cbousfield1i', 'Correy', 'Bousfield', '1990-05-01', '2018-05-11 07:38:36', 'cbousfield1i@cloudflare.com',
        '5615911798', 'M', '85400 Northwestern Court', 'FL', '33432', 'United States', 57, 158),
       ('cdelascy1j', 'Carmela', 'De Lascy', '2008-01-21', '2009-03-07 14:48:39', 'cdelascy1j@linkedin.com',
        '4022497832', 'F', '93 Pearson Way', 'NE', '68124', 'United States', 57, 126),
       ('greckus1k', 'Giorgia', 'Reckus', '1995-02-20', '2016-08-02 12:21:25', 'greckus1k@lulu.com', '8137216974', 'F',
        '09 Everett Parkway', 'FL', '33758', 'United States', 68, 157),
       ('casif1l', 'Corabelle', 'Asif', '1984-01-25', '2018-07-10 08:59:28', 'casif1l@gizmodo.com', '5055742548', 'F',
        '77422 Mallard Parkway', 'NM', '87195', 'United States', 76, 141),
       ('ghabben1m', 'Gisela', 'Habben', '1977-07-15', '2024-01-14 17:12:11', 'ghabben1m@163.com', '2038128416', 'F',
        '53278 Hazelcrest Court', 'CT', '06505', 'United States', 62, 127),
       ('mivachyov1n', 'Mike', 'Ivachyov', '1978-08-21', '2022-12-09 06:54:24', 'mivachyov1n@friendfeed.com',
        '9528100647', 'M', '1 Glendale Circle', 'MN', '55579', 'United States', 64, 164),
       ('calsina1o', 'Celisse', 'Alsina', '1983-11-04', '2022-09-15 23:16:49', 'calsina1o@multiply.com', '7021019485',
        'F', '20 Nevada Road', 'NV', '89125', 'United States', 55, 297),
       ('tbowlands1p', 'Trueman', 'Bowlands', '2008-12-15', '2013-03-20 14:51:57', 'tbowlands1p@edublogs.org',
        '4028702938', 'M', '162 Kim Park', 'NE', '68105', 'United States', 56, 239),
       ('hsalandino1q', 'Hieronymus', 'Salandino', '2005-02-11', '2010-09-15 06:42:32', 'hsalandino1q@ft.com',
        '7132232078', 'M', '17558 Lighthouse Bay Pass', 'TX', '77045', 'United States', 68, 101),
       ('whatt1r', 'Wesley', 'Hatt', '1989-07-16', '2017-04-02 09:06:11', 'whatt1r@google.it', '3309150429', 'M',
        '0167 Kinsman Drive', 'OH', '44329', 'United States', 82, 137),
       ('vfranzschoninger1s', 'Verina', 'Franz-Schoninger', '1981-11-20', '2013-01-07 09:15:20',
        'vfranzschoninger1s@hp.com', '6262980389', 'F', '02473 Thackeray Drive', 'CA', '90025', 'United States', 56,
        188),
       ('iseer1t', 'Iris', 'Seer', '1993-12-25', '2021-06-21 01:15:27', 'iseer1t@yahoo.co.jp', '5099322846', 'F',
        '27 Dakota Street', 'WA', '99260', 'United States', 48, 252),
       ('alangtry1u', 'Ambrosi', 'Langtry', '2000-12-29', '2014-01-25 05:48:38', 'alangtry1u@desdev.cn', '3302477429',
        'M', '35815 Northwestern Alley', 'OH', '44720', 'United States', 83, 193),
       ('kcharkham1v', 'Kurtis', 'Charkham', '2000-10-14', '2018-03-08 02:54:36', 'kcharkham1v@cdbaby.com',
        '7131533626', 'M', '780 Arizona Circle', 'TX', '77260', 'United States', 59, 105),
       ('kwoodman1w', 'Korrie', 'Woodman', '1985-01-19', '2019-12-20 03:44:04', 'kwoodman1w@sfgate.com', '6023700875',
        'F', '32420 Saint Paul Parkway', 'AZ', '85205', 'United States', 48, 262),
       ('ljarvie1x', 'Lorrie', 'Jarvie', '2005-09-13', '2017-10-29 15:38:55', 'ljarvie1x@wikimedia.org', '8063125968',
        'F', '5 Melvin Point', 'TX', '79118', 'United States', 67, 231),
       ('aeggerton1y', 'Alon', 'Eggerton', '1980-06-06', '2012-10-01 23:20:14', 'aeggerton1y@friendfeed.com',
        '4076859017', 'M', '29 Arizona Park', 'FL', '32118', 'United States', 50, 128),
       ('tfessions1z', 'Tonnie', 'Fessions', '1987-02-26', '2015-08-22 03:52:05', 'tfessions1z@pagesperso-orange.fr',
        '6506426922', 'M', '854 Erie Circle', 'CA', '95113', 'United States', 64, 244),
       ('rgianulli20', 'Roi', 'Gianulli', '1992-01-26', '2017-07-22 00:19:31', 'rgianulli20@webnode.com', '2124164047',
        'M', '8737 Spaight Place', 'NY', '10090', 'United States', 75, 128),
       ('pduffil21', 'Paola', 'Duffil', '2001-11-18', '2019-09-28 17:40:33', 'pduffil21@hatena.ne.jp', '8588850464',
        'F', '68 Ludington Junction', 'CA', '92145', 'United States', 73, 198),
       ('pculverhouse22', 'Pooh', 'Culverhouse', '1984-10-27', '2024-06-07 23:12:07', 'pculverhouse22@skyrock.com',
        '2341842067', 'F', '52 Bonner Way', 'OH', '44393', 'United States', 55, 149),
       ('rmacdearmid23', 'Rafi', 'MacDearmid', '1985-01-14', '2013-10-25 19:32:02', 'rmacdearmid23@arizona.edu',
        '3301416478', 'M', '328 Graceland Park', 'OH', '44511', 'United States', 54, 162),
       ('ltomasino24', 'Lyndsay', 'Tomasino', '2006-08-06', '2016-12-06 00:47:09', 'ltomasino24@yahoo.co.jp',
        '8045469970', 'F', '1 Surrey Avenue', 'VA', '23242', 'United States', 76, 268),
       ('thabble25', 'Trstram', 'Habble', '1976-09-11', '2016-07-22 12:10:39', 'thabble25@virginia.edu', '4237758954',
        'M', '9 Straubel Parkway', 'TN', '37405', 'United States', 83, 157),
       ('gbeeres26', 'Gleda', 'Beeres', '1979-12-23', '2024-05-06 07:14:50', 'gbeeres26@accuweather.com', '9549097787',
        'F', '756 Eagle Crest Road', 'FL', '33305', 'United States', 71, 161),
       ('rmeeland27', 'Roxy', 'Meeland', '1988-03-10', '2020-02-06 08:26:48', 'rmeeland27@unc.edu', '8126536516', 'F',
        '67 Ludington Circle', 'IN', '47747', 'United States', 68, 192),
       ('deastup28', 'Dareen', 'Eastup', '1979-12-29', '2010-10-16 22:29:03', 'deastup28@facebook.com', '9728068120',
        'F', '102 Ridgeview Drive', 'TX', '75216', 'United States', 73, 286),
       ('gshawl29', 'Giraud', 'Shawl', '1991-08-30', '2010-11-28 04:59:19', 'gshawl29@narod.ru', '3178713572', 'M',
        '95506 Lillian Hill', 'IN', '46239', 'United States', 76, 280),
       ('njandl2a', 'Natasha', 'Jandl', '2004-04-21', '2010-11-04 19:46:17', 'njandl2a@themeforest.net', '8305628922',
        'F', '9080 Hagan Drive', 'TX', '78255', 'United States', 50, 154),
       ('kgiacobini2b', 'Kirstin', 'Giacobini', '1995-03-06', '2010-08-24 16:50:16', 'kgiacobini2b@imgur.com',
        '5022483358', 'F', '6 Thierer Way', 'KY', '40225', 'United States', 48, 204),
       ('rtalby2c', 'Rosco', 'Talby', '1995-06-25', '2021-06-04 10:00:08', 'rtalby2c@dailymail.co.uk', '8644961212',
        'M', '196 Fisk Lane', 'SC', '29605', 'United States', 50, 266),
       ('kmaclardie2d', 'Krista', 'MacLardie', '2006-12-17', '2016-06-13 12:25:05', 'kmaclardie2d@ocn.ne.jp',
        '8047722683', 'F', '7948 Waywood Hill', 'VA', '23260', 'United States', 49, 233),
       ('rstrathe2e', 'Rafaelita', 'Strathe', '1993-07-20', '2021-04-19 14:05:30', 'rstrathe2e@cbc.ca', '5613061359',
        'F', '5906 Warrior Trail', 'FL', '33421', 'United States', 55, 288),
       ('svalenssmith2f', 'Steffie', 'Valens-Smith', '2002-05-20', '2013-06-28 16:06:09',
        'svalenssmith2f@soundcloud.com', '3126974973', 'F', '751 Fordem Alley', 'IL', '60614', 'United States', 67,
        152),
       ('lhurich2g', 'Lari', 'Hurich', '1983-01-30', '2020-03-29 06:44:28', 'lhurich2g@bloglines.com', '5634126932',
        'F', '948 Bobwhite Point', 'IA', '52809', 'United States', 71, 243),
       ('mwestgate2h', 'Mariquilla', 'Westgate', '1982-11-20', '2009-11-02 12:07:29', 'mwestgate2h@nhs.uk',
        '9194035828', 'F', '7205 Debra Lane', 'NC', '27658', 'United States', 66, 171),
       ('aurquhart2i', 'Andi', 'Urquhart', '1985-03-15', '2018-08-20 19:36:09', 'aurquhart2i@wikipedia.org',
        '2811841321', 'F', '07646 Hallows Plaza', 'TX', '77015', 'United States', 58, 119),
       ('jsemered2j', 'Jourdan', 'Semered', '1988-11-05', '2022-03-18 12:54:17', 'jsemered2j@shutterfly.com',
        '7576168232', 'F', '87120 Rusk Hill', 'VA', '23324', 'United States', 80, 215),
       ('tjosskoviz2k', 'Tymon', 'Josskoviz', '1982-11-06', '2023-04-19 16:28:08', 'tjosskoviz2k@quantcast.com',
        '6027244950', 'M', '12 Corben Pass', 'AZ', '85010', 'United States', 70, 293),
       ('ccliff2l', 'Corissa', 'Cliff', '1983-02-17', '2018-04-13 02:47:58', 'ccliff2l@epa.gov', '8644417774', 'F',
        '22 4th Alley', 'SC', '29319', 'United States', 65, 251),
       ('kheifer2m', 'Kassie', 'Heifer', '1989-12-31', '2023-01-26 16:28:39', 'kheifer2m@g.co', '3041025562', 'F',
        '8549 Mockingbird Junction', 'WV', '25389', 'United States', 63, 128),
       ('cgoddman2n', 'Christophe', 'Goddman', '1988-08-27', '2011-03-08 11:05:06', 'cgoddman2n@google.pl',
        '2015512483', 'M', '78090 Waubesa Pass', 'NJ', '07522', 'United States', 65, 102),
       ('pschimon2o', 'Parry', 'Schimon', '1988-12-14', '2017-10-23 10:33:07', 'pschimon2o@myspace.com', '9716785399',
        'M', '42422 Stephen Court', 'OR', '97255', 'United States', 79, 164),
       ('lpeye2p', 'Lorrie', 'Peye', '1988-11-13', '2016-11-13 00:04:01', 'lpeye2p@webeden.co.uk', '5187672979', 'F',
        '895 Kipling Avenue', 'NY', '12325', 'United States', 58, 290),
       ('relvey2q', 'Roderigo', 'Elvey', '1996-02-11', '2014-04-04 13:50:10', 'relvey2q@delicious.com', '9516832582',
        'M', '869 Birchwood Court', 'CA', '92513', 'United States', 82, 252),
       ('hdoumerque2r', 'Hussein', 'Doumerque', '1986-04-04', '2019-06-27 10:36:00', 'hdoumerque2r@house.gov',
        '2124387139', 'M', '707 Mifflin Alley', 'NY', '10280', 'United States', 64, 182),
       ('aalflat2s', 'Albie', 'Alflat', '1983-11-14', '2013-11-16 00:04:34', 'aalflat2s@ed.gov', '9122447980', 'M',
        '9636 Spohn Road', 'GA', '31422', 'United States', 57, 124),
       ('dkryszka2t', 'Donalt', 'Kryszka', '1980-05-11', '2023-03-22 07:27:27', 'dkryszka2t@boston.com', '9716439319',
        'M', '505 Victoria Lane', 'OR', '97312', 'United States', 49, 138),
       ('kblumson2u', 'Katine', 'Blumson', '1999-11-22', '2020-08-25 11:12:14', 'kblumson2u@fotki.com', '7199709361',
        'F', '5 Canary Point', 'CO', '80920', 'United States', 83, 202),
       ('astubbings2v', 'Aurel', 'Stubbings', '2009-12-03', '2021-07-02 13:11:55', 'astubbings2v@last.fm', '9362659016',
        'F', '94907 Service Junction', 'TX', '77305', 'United States', 66, 172),
       ('lmillimoe2w', 'Lawrence', 'Millimoe', '1994-05-20', '2008-07-05 17:55:29', 'lmillimoe2w@japanpost.jp',
        '5128254352', 'M', '9316 Charing Cross Center', 'TX', '78778', 'United States', 55, 221),
       ('jgrinston2x', 'Jeramie', 'Grinston', '2005-10-14', '2013-10-02 04:58:39', 'jgrinston2x@squidoo.com',
        '2814972865', 'M', '987 Ryan Avenue', 'TX', '77040', 'United States', 58, 146),
       ('amcgowan2y', 'Aymer', 'McGowan', '1992-01-16', '2011-11-20 19:58:43', 'amcgowan2y@cdc.gov', '5167860735', 'M',
        '96 Kim Crossing', 'NY', '11044', 'United States', 73, 282),
       ('vgouley2z', 'Virginia', 'Gouley', '1989-06-29', '2009-10-19 19:03:13', 'vgouley2z@blog.com', '8165355098', 'F',
        '207 Comanche Lane', 'MO', '64190', 'United States', 75, 148),
       ('cmcparlin30', 'Cassy', 'McParlin', '1982-09-29', '2012-02-12 02:53:52', 'cmcparlin30@over-blog.com',
        '3147880163', 'F', '76821 Straubel Parkway', 'MO', '63158', 'United States', 64, 222),
       ('mcogger31', 'Merrilee', 'Cogger', '1983-07-04', '2011-02-13 22:28:48', 'mcogger31@yelp.com', '9415584112', 'F',
        '412 Chinook Lane', 'FL', '33982', 'United States', 52, 229),
       ('jkolyagin32', 'Jemie', 'Kolyagin', '1993-01-01', '2020-05-11 03:15:53', 'jkolyagin32@g.co', '9109642630', 'F',
        '14150 Fisk Circle', 'NC', '28314', 'United States', 48, 107),
       ('ashrawley33', 'Alessandro', 'Shrawley', '1985-01-08', '2021-03-31 01:22:39', 'ashrawley33@google.es',
        '8174261000', 'M', '13180 Westridge Lane', 'TX', '76129', 'United States', 66, 137),
       ('gwitheford34', 'Germaine', 'Witheford', '2005-06-18', '2023-06-06 11:50:19', 'gwitheford34@toplist.cz',
        '8145524421', 'M', '943 Eagle Crest Place', 'PA', '16550', 'United States', 66, 178),
       ('trandles35', 'Tani', 'Randles', '1991-09-03', '2010-10-06 11:22:46', 'trandles35@xinhuanet.com', '2605604789',
        'F', '9375 Nevada Court', 'IN', '46862', 'United States', 77, 216),
       ('tgauthorpp36', 'Tallia', 'Gauthorpp', '2000-08-06', '2024-03-06 18:14:23', 'tgauthorpp36@cisco.com',
        '7859871530', 'F', '77 Trailsway Parkway', 'KS', '66667', 'United States', 71, 126),
       ('vmoxted37', 'Vania', 'Moxted', '2000-02-06', '2010-06-18 06:27:29', 'vmoxted37@amazonaws.com', '3135062520',
        'F', '3 Iowa Crossing', 'MI', '48295', 'United States', 76, 261),
       ('vgisburne38', 'Viviana', 'Gisburne', '1983-05-11', '2017-06-06 21:52:01', 'vgisburne38@apache.org',
        '7727722553', 'F', '39520 Kenwood Pass', 'FL', '34949', 'United States', 80, 192),
       ('gmendez39', 'Gay', 'Mendez', '1978-08-12', '2023-03-07 22:32:17', 'gmendez39@cpanel.net', '6783174494', 'M',
        '0 Hansons Lane', 'GA', '30328', 'United States', 78, 108),
       ('smartinek3a', 'Sauveur', 'Martinek', '1983-04-14', '2017-04-11 11:27:35', 'smartinek3a@stumbleupon.com',
        '6145321328', 'M', '29 Utah Place', 'OH', '43204', 'United States', 48, 292),
       ('ppuckinghorne3b', 'Pamella', 'Puckinghorne', '1992-10-28', '2009-11-13 17:24:48', 'ppuckinghorne3b@uiuc.edu',
        '9712740962', 'F', '73 Tomscot Place', 'OR', '97201', 'United States', 67, 185),
       ('lstallwood3c', 'Luelle', 'Stallwood', '1991-12-13', '2018-02-26 02:12:48', 'lstallwood3c@printfriendly.com',
        '9186212607', 'F', '965 Glendale Junction', 'OK', '74116', 'United States', 80, 257),
       ('htrimble3d', 'Holly', 'Trimble', '1979-04-03', '2016-01-02 03:41:49', 'htrimble3d@elpais.com', '3209097322',
        'M', '54682 Brickson Park Junction', 'MN', '56372', 'United States', 65, 210),
       ('omelbury3e', 'Ole', 'Melbury', '1981-03-27', '2017-02-28 02:45:54', 'omelbury3e@acquirethisname.com',
        '9048674615', 'M', '2 Bluejay Park', 'FL', '32092', 'United States', 54, 134),
       ('pgiovanardi3f', 'Paolina', 'Giovanardi', '2007-08-19', '2024-02-12 11:22:22', 'pgiovanardi3f@prweb.com',
        '2025440755', 'F', '4 Spenser Center', 'DC', '20456', 'United States', 63, 158),
       ('kvercruysse3g', 'Kip', 'Vercruysse', '2002-08-24', '2010-12-02 12:46:42', 'kvercruysse3g@sbwire.com',
        '3129093712', 'M', '696 Little Fleur Center', 'IL', '60674', 'United States', 67, 258),
       ('ifruser3h', 'Ingamar', 'Fruser', '2009-11-24', '2016-06-16 09:31:16', 'ifruser3h@a8.net', '3091455018', 'M',
        '7298 Continental Park', 'IL', '61605', 'United States', 82, 101),
       ('bwhitnall3i', 'Brockie', 'Whitnall', '2001-09-04', '2019-03-22 18:39:41', 'bwhitnall3i@xinhuanet.com',
        '3346928150', 'M', '614 Duke Street', 'AL', '36195', 'United States', 60, 128),
       ('wflather3j', 'Willa', 'Flather', '1999-09-17', '2011-02-08 22:09:19', 'wflather3j@ezinearticles.com',
        '9011556712', 'F', '61 Armistice Street', 'TN', '38136', 'United States', 53, 157),
       ('abernaldo3k', 'Alaster', 'Bernaldo', '2004-09-03', '2018-02-09 23:37:15', 'abernaldo3k@taobao.com',
        '3155521734', 'M', '38439 Mallory Circle', 'NY', '13251', 'United States', 48, 107),
       ('aashdown3l', 'Anjanette', 'Ashdown', '1989-02-02', '2018-06-30 03:15:05', 'aashdown3l@tripadvisor.com',
        '4133451042', 'F', '88 Laurel Crossing', 'MA', '01114', 'United States', 67, 143),
       ('khaggerty3m', 'Katey', 'Haggerty', '1982-04-03', '2014-03-16 12:51:41', 'khaggerty3m@bbc.co.uk', '7751427771',
        'F', '148 Debs Place', 'NV', '89505', 'United States', 78, 246),
       ('ebreadon3n', 'Erick', 'Breadon', '1981-01-12', '2008-07-23 07:22:50', 'ebreadon3n@examiner.com', '4134967377',
        'M', '7489 Vahlen Park', 'MA', '01129', 'United States', 70, 243),
       ('ieberz3o', 'Isidor', 'Eberz', '1982-06-23', '2015-03-19 05:38:22', 'ieberz3o@hhs.gov', '7049716221', 'M',
        '3 Dorton Alley', 'NC', '28215', 'United States', 69, 114),
       ('bhandlin3p', 'Benoite', 'Handlin', '2002-12-07', '2019-09-23 15:40:41', 'bhandlin3p@newyorker.com',
        '2129303945', 'F', '75 Fairview Place', 'NY', '11247', 'United States', 74, 238),
       ('kperet3q', 'Kristien', 'Peret', '2003-06-06', '2016-06-26 15:03:35', 'kperet3q@issuu.com', '9373403450', 'F',
        '2042 Dovetail Court', 'OH', '45414', 'United States', 66, 124),
       ('bmccreery3r', 'Bryn', 'McCreery', '1978-09-12', '2015-01-27 11:26:10', 'bmccreery3r@google.de', '9798548387',
        'M', '17 Warbler Crossing', 'TX', '77806', 'United States', 58, 210),
       ('ejuett3s', 'Eirena', 'Juett', '1978-03-24', '2011-10-13 05:13:01', 'ejuett3s@drupal.org', '4145688571', 'F',
        '30 Everett Point', 'WI', '53220', 'United States', 69, 182),
       ('dedinburough3t', 'Dewie', 'Edinburough', '1998-07-04', '2019-08-20 18:06:34', 'dedinburough3t@ted.com',
        '3125824127', 'M', '71989 Red Cloud Junction', 'IL', '60669', 'United States', 72, 275),
       ('jkeyser3u', 'Josephine', 'Keyser', '1992-06-13', '2022-06-02 08:40:01', 'jkeyser3u@devhub.com', '3042963884',
        'F', '61 Parkside Lane', 'WV', '25709', 'United States', 60, 223),
       ('jbarbrook3v', 'Joete', 'Barbrook', '1984-11-13', '2012-06-12 20:36:29', 'jbarbrook3v@ucsd.edu', '4104319331',
        'F', '57470 Troy Crossing', 'MD', '21216', 'United States', 53, 190),
       ('rchichgar3w', 'Rob', 'Chichgar', '2001-01-16', '2017-07-09 11:40:50', 'rchichgar3w@ucsd.edu', '5404025890',
        'M', '23112 Lotheville Hill', 'VA', '22405', 'United States', 77, 103),
       ('rsiemens3x', 'Roscoe', 'Siemens', '1992-11-19', '2009-03-30 16:20:16', 'rsiemens3x@xrea.com', '3187866796',
        'M', '030 Larry Street', 'MA', '02104', 'United States', 62, 272),
       ('rgajewski3y', 'Reginauld', 'Gajewski', '2004-04-09', '2010-06-23 06:13:16', 'rgajewski3y@marriott.com',
        '3174755989', 'M', '0717 Sunbrook Plaza', 'IN', '46216', 'United States', 60, 225),
       ('fhasluck3z', 'Fin', 'Hasluck', '2008-07-23', '2022-09-23 00:32:53', 'fhasluck3z@xinhuanet.com', '6014152768',
        'M', '9097 Southridge Point', 'MS', '39296', 'United States', 53, 248),
       ('lrustman40', 'Luca', 'Rustman', '1997-04-01', '2010-12-04 06:45:32', 'lrustman40@sitemeter.com', '9797021203',
        'M', '85600 Utah Lane', 'TX', '77844', 'United States', 59, 201),
       ('mizak41', 'Moore', 'Izak', '2006-09-30', '2011-12-14 00:02:22', 'mizak41@tripadvisor.com', '5627039844', 'M',
        '2398 Superior Crossing', 'CA', '90831', 'United States', 48, 146),
       ('alamke42', 'Andria', 'Lamke', '2004-07-04', '2008-08-27 00:06:42', 'alamke42@1688.com', '7606281907', 'F',
        '613 Schlimgen Terrace', 'CA', '92013', 'United States', 66, 249),
       ('jrobichon43', 'Jena', 'Robichon', '1988-12-03', '2013-05-31 00:54:46', 'jrobichon43@google.de', '4802942637',
        'F', '575 John Wall Road', 'AZ', '85255', 'United States', 56, 195),
       ('locarran44', 'Loralie', 'O''Carran', '2001-04-17', '2014-04-07 05:22:49', 'locarran44@examiner.com',
        '2085789171', 'F', '0 Harbort Point', 'ID', '83757', 'United States', 48, 142),
       ('jitzhayek45', 'Jane', 'Itzhayek', '2001-01-27', '2018-03-23 04:00:08', 'jitzhayek45@geocities.com',
        '2057685287', 'F', '4 Cordelia Parkway', 'AL', '35242', 'United States', 83, 208);;

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


INSERT INTO Influencer (followerCount, bio, username)
VALUES
  (51, 'Persistent national time-frame', 'lparradiceq'),
  (26, 'Stand-alone leading edge migration', 'tbowlands1p'),
  (1, 'Public-key composite success', 'pduffil21'),
  (22, 'Mandatory mobile budgetary management', 'gbanister4'),
  (100, 'Visionary radical moratorium', 'ebreadon3n'),
  (41, 'Versatile transitional implementation', 'ejuett3s'),
  (58, 'Organized dynamic capacity', 'gbunt88'),
  (8, 'Re-contextualized local superstructure', 'kfenge11'),
  (28, 'Up-sized responsive initiative', 'lcaffery1j'),
  (90, 'Phased 24/7 definition', 'hhuggard21'),
  (64, 'Horizontal bi-directional complexity', 'mizak41'),
  (38, 'Extended bandwidth-monitored matrices', 'janedoe'),
  (5, 'Synchronized mission-critical installation', 'dkryszka2t'),
  (79, 'Sharable systematic project', 'gbanister4'),
  (50, 'Fully-configurable clear-thinking framework', 'wsandilandsn'),
  (2, 'Integrated multi-state conglomeration', 'stedahl16'),
  (87, 'Vision-oriented user-facing parallelism', 'greckus1k'),
  (11, 'Monitored directional access', 'pschimon2o'),
  (3, 'Adaptive 24/7 project', 'tcornillir'),
  (25, 'User-friendly zero defect internet solution', 'rgianulli20'),
  (68, 'Optional encompassing strategy', 'bdooneyv'),
  (44, 'Distributed optimal forecast', 'thigounet7'),
  (84, 'Progressive multimedia forecast', 'keva80'),
  (62, 'Stand-alone multimedia collaboration', 'mscoggan6'),
  (67, 'Enterprise-wide upward-trending pricing structure', 'wriba17'),
  (95, 'Extended cohesive circuit', 'tviegas8a'),
  (54, 'Integrated asynchronous paradigm', 'astubbings2v'),
  (59, 'Synergized maximized firmware', 'aashdown3l'),
  (50, 'Managed methodical access', 'kvercruysse3g'),
  (52, 'Total bottom-line customer loyalty', 'oguitton11');

INSERT INTO Brand (name) VALUES
('Eimbee'),
('Flipbug'),
('Realmix'),
('Blogtag'),
('Eadel'),
('Pixonyx'),
('Skimia'),
('Rhynoodle'),
('Wikizz'),
('Zoombeat'),
('Skipstorm'),
('Bubblebox'),
('Yotz'),
('Zazio'),
('Tavu'),
('Leexo'),
('Brightdog'),
('Mita'),
('Divape'),
('Livetube'),
('Dabfeed'),
('Roomm'),
('Wordpedia'),
('Livefish'),
('Meetz'),
('Trilia'),
('Mycat'),
('Lajo'),
('Trudeo'),
('Geba');

INSERT INTO InfluencerFollower (influencerUsername, followerUsername) VALUES
  ('wsandilandsn', 'aeggerton1y'),
  ('ebreadon3n', 'bhandlin3p'),
  ('bdooneyv', 'ashrawley33'),
  ('ejuett3s', 'wsandilandsn'),
  ('wriba17', 'iobell1c'),
  ('bdooneyv', 'ejuett3s'),
  ('ejuett3s', 'ncoolbear9'),
  ('lparradiceq', 'tfinan1h'),
  ('bdooneyv', 'mmaycock1b'),
  ('greckus1k', 'aeggerton1y'),
  ('keva80', 'casif1l'),
  ('mscoggan6', 'htrimble3d'),
  ('gbunt88', 'fhasluck3z'),
  ('rgianulli20', 'wflather3j'),
  ('aashdown3l', 'thigounet7'),
  ('tcornillir', 'lpatman19'),
  ('mizak41', 'htrimble3d'),
  ('wsandilandsn', 'cnabarro8'),
  ('lparradiceq', 'vfranzschoninger1s'),
  ('wriba17', 'ssavory23'),
  ('dkryszka2t', 'vmoxted37'),
  ('pschimon2o', 'deastup28'),
  ('wsandilandsn', 'pschimon2o'),
  ('hhuggard21', 'bhowarthc'),
  ('tviegas8a', 'cmogg1a'),
  ('thigounet7', 'aalflat2s'),
  ('astubbings2v', 'gbeeres26'),
  ('gbanister4', 'tshemmin1e'),
  ('gbanister4', 'alangtry1u'),
  ('lcaffery1j', 'oguitton11'),
  ('stedahl16', 'bwhitnall3i'),
  ('greckus1k', 'xmaldin8'),
  ('lparradiceq', 'ewiser'),
  ('tcornillir', 'vgouley2z'),
  ('mizak41', 'jdoe'),
  ('dkryszka2t', 'gwitheford34'),
  ('ejuett3s', 'pduffil21'),
  ('greckus1k', 'rgajewski3y'),
  ('lparradiceq', 'ccliff2l'),
  ('wsandilandsn', 'rtalby2c'),
  ('kfenge11', 'lmidghall14'),
  ('wsandilandsn', 'estorekw'),
  ('dkryszka2t', 'tfinan1h'),
  ('lparradiceq', 'iobell1c'),
  ('ebreadon3n', 'rbernade3'),
  ('mizak41', 'tstollberg1z'),
  ('mscoggan6', 'wflather3j'),
  ('dkryszka2t', 'iobell1c'),
  ('wriba17', 'kgooderick1d'),
  ('tcornillir', 'hsalandino1q'),
  ('mscoggan6', 'kgiacobini2b'),
  ('thigounet7', 'gbunt88'),
  ('pschimon2o', 'jagett10'),
  ('bdooneyv', 'lvobes15'),
  ('janedoe', 'jwante'),
  ('tviegas8a', 'rbridat13'),
  ('mizak41', 'htrimble3d'),
  ('kvercruysse3g', 'lpatman19'),
  ('bdooneyv', 'kbaudinot1g'),
  ('keva80', 'keva80'),
  ('thigounet7', 'njandl2a'),
  ('mizak41', 'pdilliway2'),
  ('rgianulli20', 'bwhymark6'),
  ('ebreadon3n', 'rtalby2c'),
  ('tviegas8a', 'atrowela'),
  ('greckus1k', 'omccheyne26'),
  ('ebreadon3n', 'swretham7z'),
  ('mizak41', 'sparkes1'),
  ('astubbings2v', 'jsemered2j'),
  ('pschimon2o', 'vjochen18'),
  ('oguitton11', 'lparradiceq'),
  ('astubbings2v', 'rgianulli20'),
  ('kfenge11', 'kheifer2m'),
  ('astubbings2v', 'cmogg1a'),
  ('tcornillir', 'eburdikin15'),
  ('kvercruysse3g', 'aurquhart2i'),
  ('pschimon2o', 'cnabarro8'),
  ('janedoe', 'rbridat13'),
  ('bdooneyv', 'kblumson2u'),
  ('tviegas8a', 'rsell89'),
  ('kfenge11', 'mbeckitt85'),
  ('ebreadon3n', 'tjoncic0'),
  ('aashdown3l', 'rissitt0'),
  ('ejuett3s', 'tshemmin1e'),
  ('greckus1k', 'kwoodman1w'),
  ('lparradiceq', 'kvercruysse3g'),
  ('mizak41', 'lmillimoe2w'),
  ('tbowlands1p', 'tbowlands1p'),
  ('thigounet7', 'kvercruysse3g'),
  ('keva80', 'smartinek3a'),
  ('thigounet7', 'fhasluck3z'),
  ('mscoggan6', 'wsandilandsn'),
  ('gbanister4', 'drosenbaum1i'),
  ('wsandilandsn', 'hhindrich1y'),
  ('thigounet7', 'rtalby2c'),
  ('tviegas8a', 'kbaudinot1g'),
  ('greckus1k', 'bcapner1d'),
  ('thigounet7', 'vjochen18'),
  ('astubbings2v', 'xmaldin8'),
  ('kvercruysse3g', 'rsell89'),
  ('kfenge11', 'kvercruysse3g'),
  ('oguitton11', 'janedoe'),
  ('stedahl16', 'casif1l'),
  ('lcaffery1j', 'mcogger31'),
  ('keva80', 'cbousfield1i'),
  ('aashdown3l', 'iobell1c'),
  ('ejuett3s', 'elamburn28'),
  ('oguitton11', 'etompkin1k'),
  ('tcornillir', 'gmendez39'),
  ('janedoe', 'vmoxted37'),
  ('keva80', 'rmeeland27'),
  ('bdooneyv', 'trandles35'),
  ('kvercruysse3g', 'lkenton12'),
  ('thigounet7', 'mbeckitt85'),
  ('lparradiceq', 'gshawl29'),
  ('bdooneyv', 'lmartynikhinu'),
  ('bdooneyv', 'lcaffery1j'),
  ('hhuggard21', 'ataverner16'),
  ('oguitton11', 'pschimon2o'),
  ('pschimon2o', 'calsina1o'),
  ('kfenge11', 'keva80'),
  ('pschimon2o', 'gbunt88'),
  ('lcaffery1j', 'wriba17'),
  ('lcaffery1j', 'bmccreery3r'),
  ('kvercruysse3g', 'swretham7z'),
  ('rgianulli20', 'smartinek3a'),
  ('pduffil21', 'rsearl1g'),
  ('lcaffery1j', 'janedoe'),
  ('gbanister4', 'alamke42'),
  ('tviegas8a', 'aeggerton1y'),
  ('lparradiceq', 'tstollberg1z'),
  ('gbanister4', 'tshemmin1e'),
  ('wsandilandsn', 'cbousfield1i'),
  ('tviegas8a', 'scoysh83'),
  ('mizak41', 'wgurnelll'),
  ('tcornillir', 'sfosse1'),
  ('bdooneyv', 'cgoddman2n'),
  ('greckus1k', 'dedwick13'),
  ('gbanister4', 'ifruser3h'),
  ('gbanister4', 'tstollberg1z'),
  ('tviegas8a', 'jkolyagin32'),
  ('janedoe', 'lmidghall14'),
  ('gbunt88', 'kblumson2u'),
  ('lcaffery1j', 'mmaycock1b'),
  ('astubbings2v', 'bdooneyv'),
  ('mizak41', 'tfessions1z'),
  ('dkryszka2t', 'aurquhart2i'),
  ('mizak41', 'ccliff2l'),
  ('mizak41', 'jbarbrook3v'),
  ('pduffil21', 'kfenge11'),
  ('tbowlands1p', 'dpickovert'),
  ('tbowlands1p', 'mizak41'),
  ('dkryszka2t', 'vjochen18'),
  ('pduffil21', 'ygageng'),
  ('gbunt88', 'thigounet7'),
  ('pduffil21', 'tghirigori1c'),
  ('hhuggard21', 'dedwick13'),
  ('mizak41', 'kblumson2u'),
  ('gbanister4', 'vjochen18'),
  ('ebreadon3n', 'bwhitnall3i'),
  ('tviegas8a', 'sfosse1'),
  ('janedoe', 'pduffil21'),
  ('oguitton11', 'vgouley2z'),
  ('gbanister4', 'aurquhart2i'),
  ('pschimon2o', 'gbunt88'),
  ('lcaffery1j', 'kblumson2u'),
  ('bdooneyv', 'tfinan1h'),
  ('lparradiceq', 'greckus1k'),
  ('tbowlands1p', 'ppuckinghorne3b'),
  ('wriba17', 'trandles35'),
  ('dkryszka2t', 'svalenssmith2f'),
  ('mscoggan6', 'wflather3j'),
  ('pduffil21', 'kwoodman1w'),
  ('wriba17', 'rchichgar3w'),
  ('janedoe', 'emion4'),
  ('keva80', 'keva80'),
  ('astubbings2v', 'rmarklund22'),
  ('bdooneyv', 'lcanaan9'),
  ('tbowlands1p', 'credingtonf'),
  ('pschimon2o', 'oguitton11'),
  ('kvercruysse3g', 'bwyant1f'),
  ('keva80', 'qsinkin27'),
  ('mscoggan6', 'bhandlin3p'),
  ('pduffil21', 'hclemo1m'),
  ('gbunt88', 'cpetry1l'),
  ('pduffil21', 'pdilliway2'),
  ('kfenge11', 'ccurdellb'),
  ('ejuett3s', 'kwoodman1w'),
  ('aashdown3l', 'bhandlin3p'),
  ('astubbings2v', 'sparkes1'),
  ('kvercruysse3g', 'thigounet7'),
  ('hhuggard21', 'cbrauningeri'),
  ('gbunt88', 'mcogger31'),
  ('gbanister4', 'lrustman40'),
  ('aashdown3l', 'bnapoleone20'),
  ('janedoe', 'cbrauningeri'),
  ('keva80', 'ljarvie1x'),
  ('mizak41', 'tbowlands1p'),
  ('greckus1k', 'rsearl1g'),
  ('dkryszka2t', 'pduffil21');

INSERT INTO Video (comments, likes, shares, duration, caption, brandname)
VALUES  (77224, 40654023, 75578039, 50.28, 'Morbi non quam nec dui luctus rutrum. Nulla tellus.', 'Realbuzz') ,
 (33453, 64780119, 69664266, 48.61, 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.', 'Youfeed') ,
 (86107, 45096690, 27445702, 6.97, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', 'JumpXS') ,
 (14251, 35865266, 9699045, 29.14, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'Zazio') ,
 (32727, 73549372, 54431640, 47.17, 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'Lajo') ,
 (80898, 57873142, 12179535, 8.91, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', 'Trunyx') ,
 (58575, 69750845, 36760840, 1.05, 'Mauris ullamcorper purus sit amet nulla.', 'Innotype') ,
 (69362, 79646618, 75857920, 32.59, 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', 'Skaboo') ,
 (39592, 94261010, 57561843, 49.38, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Duis faucibus accumsan odio. Curabitur convallis.', 'Realmix') ,
 (79800, 7802339, 8477600, 47.74, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 'Skaboo') ,
 (53639, 49842916, 95984830, 55.61, 'In hac habitasse platea dictumst.', 'name') ,
 (37105, 12506148, 51392289, 58.66, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', 'Gabvine') ,
 (62316, 34345618, 96458777, 47.74, 'Curabitur in libero ut massa volutpat convallis.', 'Jabbertype') ,
 (54291, 82957191, 60081555, 48.97, 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', 'Zazio') ,
 (83158, 58323576, 51974163, 47.25, 'Vestibulum ac est lacinia nisi venenatis tristique.', 'Fiveclub') ,
 (69735, 43443202, 8229213, 47.8, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', 'Yodel') ,
 (94401, 91210316, 66012507, 9.94, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', 'Oyondu') ,
 (2796, 73294414, 35985340, 54.36, 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', 'Jabbertype') ,
 (27560, 20885602, 45778003, 25.24, 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.', 'Twitterwire') ,
 (82198, 14786411, 88933767, 21.26, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'Digitube') ,
 (40892, 12000848, 16573260, 37.72, 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', 'Mynte') ,
 (81531, 92641434, 56352160, 35.5, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', 'Oozz') ,
 (48891, 8657616, 85503109, 13.22, 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 'Photobug') ,
 (79134, 29659700, 5044861, 14.87, 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'Lajo') ,
 (39554, 7256691, 8743920, 56.07, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', 'Talane') ,
 (48504, 39476260, 36911872, 22.96, 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', 'Eadel') ,
 (79183, 8110548, 53175681, 11.41, 'Nulla suscipit ligula in lacus.', 'Skiba') ,
 (4516, 90889735, 46675427, 49.91, 'Nam nulla.', 'Skaboo') ,
 (22657, 72042339, 74655789, 4.99, 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'Digitube') ,
 (81191, 82458826, 38836690, 30.29, 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Duis faucibus accumsan odio.', 'Jabbertype') ,
 (31879, 41725047, 10837687, 45.5, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', 'Jabbertype') ,
 (40729, 75918191, 52892736, 27.13, 'Donec quis orci eget orci vehicula condimentum.', 'Talane') ,
 (18579, 91228135, 36163969, 41.66, 'Donec semper sapien a libero. Nam dui.', 'Eadel') ,
 (24445, 81861896, 26490464, 26.76, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'Photojam') ,
 (69866, 21301951, 8018702, 54.38, 'Maecenas pulvinar lobortis est.', 'name') ,
 (88392, 97015389, 92029991, 31.37, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', 'Gabvine') ,
 (841, 11243323, 25554404, 32.14, 'Morbi quis tortor id nulla ultrices aliquet.', 'Skaboo') ,
 (71901, 30423471, 74427526, 25.69, 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', 'Twitterwire') ,
 (53290, 63989076, 41562016, 42.13, 'Aenean sit amet justo. Morbi ut odio.', 'InnoZ') ,
 (84623, 61068529, 59664334, 11.26, 'Quisque ut erat. Curabitur gravida nisi at nibh.', 'Yodel') ,
 (46335, 83496151, 93749102, 24.74, 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', 'Skiba') ,
 (88755, 85543818, 87087532, 30.14, 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'Yakidoo') ,
 (42174, 40906016, 76286434, 46.2, 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'Digitube') ,
 (99641, 93936009, 10100571, 21.29, 'Donec vitae nisi.', 'name') ,
 (79077, 55437006, 79611809, 2.14, 'Duis ac nibh.', 'Talane') ,
 (92698, 34822363, 18009821, 56.65, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', 'Oyondu') ,
 (18296, 12999395, 14548892, 35.9, 'Vivamus tortor.', 'Innotype') ,
 (88587, 42609963, 39814315, 23.4, 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', 'Realbuzz') ,
 (36726, 7666724, 32452408, 24.68, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', 'Photobug') ,
 (54117, 15449465, 12198113, 7.94, 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', 'Fiveclub') ,
 (35517, 37357647, 68011993, 23.21, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', 'Jamia') ,
 (59493, 6771952, 92905190, 39.02, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', 'Skiba') ,
 (67458, 83290894, 12163839, 53.55, 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'Jabbertype') ,
 (14079, 97059658, 80789642, 50.6, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Mauris viverra diam vitae quam. Suspendisse potenti.', 'name') ,
 (47095, 91093440, 39701342, 23.83, 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.', 'JumpXS') ,
 (88460, 77738698, 93456892, 47.2, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 'Gabvine') ,
 (17018, 47616616, 76623524, 19.09, 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae , Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', 'Trunyx') ,
 (81426, 72827213, 24366972, 53.81, 'Vivamus tortor. Duis mattis egestas metus.', 'Jabbertype') ,
 (69810, 75250049, 86215540, 50.45, 'Fusce consequat.', 'Mynte') ,
 (7603, 37145870, 29734035, 32.49, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', 'Twitterwire');

INSERT INTO POSTS (influencerUsername, videoId) VALUES
  ('tviegas8a', 38),
 ('kfenge11', 44),
 ('oguitton11', 57),
 ('wsandilandsn', 40),
 ('pduffil21', 33),
 ('tbowlands1p', 48),
 ('lparradiceq', 11),
 ('janedoe', 34),
 ('greckus1k', 36),
 ('pduffil21', 39),
 ('tbowlands1p', 16),
 ('gbanister4', 44),
 ('aashdown3l', 26),
 ('ejuett3s', 7),
 ('janedoe', 55),
 ('mscoggan6', 21),
 ('tviegas8a', 8),
 ('hhuggard21', 57),
 ('gbanister4', 43),
 ('ejuett3s', 33),
 ('astubbings2v', 33),
 ('hhuggard21', 36),
 ('pschimon2o', 11),
 ('stedahl16', 27),
 ('tviegas8a', 11),
 ('tbowlands1p', 66),
 ('ebreadon3n', 61),
 ('pduffil21', 64),
 ('pschimon2o', 7),
 ('tviegas8a', 41),
 ('janedoe', 20),
 ('tbowlands1p', 6),
 ('greckus1k', 37),
 ('hhuggard21', 65),
 ('gbanister4', 14),
 ('gbanister4', 47),
 ('pschimon2o', 19),
 ('aashdown3l', 36),
 ('pduffil21', 13),
 ('mizak41', 20),
 ('pschimon2o', 45),
 ('tviegas8a', 29),
 ('keva80', 10),
 ('oguitton11', 57),
 ('greckus1k', 53),
 ('gbanister4', 49),
 ('wriba17', 22),
 ('pduffil21', 16),
 ('lcaffery1j', 51),
 ('janedoe', 58),
 ('ebreadon3n', 45),
 ('gbanister4', 52),
 ('oguitton11', 20),
 ('gbanister4', 7),
 ('wsandilandsn', 44),
 ('ebreadon3n', 9),
 ('mizak41', 23),
 ('gbanister4', 54),
 ('thigounet7', 60),
 ('mscoggan6', 43),
 ('ebreadon3n', 60),
 ('ebreadon3n', 36),
 ('lcaffery1j', 59),
 ('lcaffery1j', 51),
 ('keva80', 26),
 ('dkryszka2t', 10),
 ('dkryszka2t', 25),
 ('pschimon2o', 24),
 ('gbanister4', 52),
 ('mscoggan6', 64),
 ('dkryszka2t', 57),
 ('tbowlands1p', 46),
 ('mscoggan6', 14),
 ('pduffil21', 8),
 ('ebreadon3n', 53),
 ('stedahl16', 36),
 ('kfenge11', 37),
 ('wsandilandsn', 59),
 ('astubbings2v', 13),
 ('tviegas8a', 60),
 ('stedahl16', 9),
 ('gbanister4', 41),
 ('bdooneyv', 39),
 ('ebreadon3n', 28),
 ('lcaffery1j', 25),
 ('mizak41', 54),
 ('keva80', 8),
 ('kfenge11', 59),
 ('pduffil21', 60),
 ('tcornillir', 43),
 ('dkryszka2t', 59),
 ('pduffil21', 64),
 ('ejuett3s', 48),
 ('greckus1k', 45),
 ('stedahl16', 35),
 ('kfenge11', 45),
 ('astubbings2v', 64),
 ('mscoggan6', 37),
 ('gbunt88', 30),
 ('lparradiceq', 47),
 ('pschimon2o', 25),
 ('pduffil21', 24),
 ('thigounet7', 54),
 ('gbanister4', 12),
 ('pschimon2o', 46),
 ('thigounet7', 60),
 ('lparradiceq', 25),
 ('gbanister4', 66),
 ('lparradiceq', 57),
 ('stedahl16', 22),
 ('thigounet7', 29),
 ('pschimon2o', 48),
 ('thigounet7', 37),
 ('astubbings2v', 53),
 ('stedahl16', 53),
 ('astubbings2v', 14),
 ('janedoe', 12),
 ('kfenge11', 45),
 ('wsandilandsn', 52),
 ('ejuett3s', 10),
 ('oguitton11', 33),
 ('kvercruysse3g', 43),
 ('wsandilandsn', 45),
 ('tviegas8a', 48),
 ('astubbings2v', 26),
 ('keva80', 23),
 ('janedoe', 29),
 ('dkryszka2t', 64),
 ('greckus1k', 15),
 ('kvercruysse3g', 35),
 ('bdooneyv', 50),
 ('bdooneyv', 38),
 ('keva80', 7),
 ('gbanister4', 62),
 ('gbanister4', 13),
 ('aashdown3l', 23),
 ('dkryszka2t', 50),
 ('astubbings2v', 8),
 ('oguitton11', 13),
 ('ejuett3s', 41),
 ('keva80', 12),
 ('mscoggan6', 19),
 ('pschimon2o', 12),
 ('kvercruysse3g', 64),
 ('tcornillir', 58),
 ('janedoe', 50),
 ('lcaffery1j', 50),
 ('stedahl16', 53),
 ('aashdown3l', 48),
 ('tviegas8a', 7);


