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
       ('amunkleya', 'Alexandrina', 'Munkley', '1976-08-27', '2017-08-21 09:30:22', 'amunkleya@baidu.com', '3105676389',
        'F', '10859 Ryan Street', 'CA', '90505', 'United States', 69, 320),
       ('rmogridgeb', 'Roma', 'Mogridge', '1984-08-08', '2007-12-12 20:33:50', 'rmogridgeb@sitemeter.com', '4024430773',
        'M', '21 Boyd Avenue', 'NE', '68505', 'United States', 80, 323),
       ('foglesc', 'Faustina', 'Ogles', '2000-04-30', '2013-12-27 13:03:05', 'foglesc@gnu.org', '7575980792', 'F',
        '3570 Center Road', 'VA', '23514', 'United States', 62, 147),
       ('aswanboroughd', 'Allan', 'Swanborough', '1966-06-30', '2014-01-07 18:43:57', 'aswanboroughd@cocolog-nifty.com',
        '8169907845', 'M', '564 Eggendart Center', 'MO', '64153', 'United States', 51, 118),
       ('cformiglie', 'Constantia', 'Formigli', '2005-05-02', '2016-09-28 23:44:09', 'cformiglie@ucsd.edu',
        '7575134719', 'F', '48 Independence Trail', 'VA', '23471', 'United States', 50, 129),
       ('bklimkiewichf', 'Briana', 'Klimkiewich', '1963-07-29', '2020-05-19 04:32:39', 'bklimkiewichf@odnoklassniki.ru',
        '9411854561', 'F', '997 Melvin Terrace', 'FL', '34642', 'United States', 63, 121),
       ('rmcgrawg', 'Renard', 'McGraw', '1937-11-26', '2007-08-17 19:35:37', 'rmcgrawg@columbia.edu', '5626729659', 'M',
        '443 Sullivan Trail', 'CA', '90847', 'United States', 83, 177),
       ('mletcherh', 'Modestine', 'Letcher', '1969-11-23', '2007-09-28 04:12:33', 'mletcherh@dedecms.com', '2037864415',
        'F', '6 Monument Center', 'CT', '06854', 'United States', 56, 136),
       ('pglandersi', 'Pen', 'Glanders', '1934-05-16', '2019-10-01 22:18:45', 'pglandersi@hubpages.com', '5623088930',
        'F', '37 Waubesa Center', 'CA', '90005', 'United States', 84, 344),
       ('hridsdalej', 'Honor', 'Ridsdale', '1952-09-28', '2005-11-13 15:42:56', 'hridsdalej@prlog.org', '2816820958',
        'F', '47 Anthes Street', 'TX', '77388', 'United States', 84, 338),
       ('wbosmak', 'Wayland', 'Bosma', '1964-08-11', '2019-01-13 10:14:13', 'wbosmak@samsung.com', '7136565203', 'M',
        '3942 Merry Parkway', 'TX', '77260', 'United States', 66, 163),
       ('rgrahamslawl', 'Rockwell', 'Grahamslaw', '1937-07-20', '2019-10-22 10:42:11', 'rgrahamslawl@freewebs.com',
        '5158635563', 'M', '79176 Debs Avenue', 'IA', '50310', 'United States', 70, 112),
       ('sbembrickm', 'Spike', 'Bembrick', '1977-02-23', '2015-10-10 10:36:37', 'sbembrickm@imdb.com', '8308286596',
        'M', '2896 Canary Pass', 'TX', '78255', 'United States', 64, 106),
       ('eregusn', 'Ermanno', 'Regus', '1973-12-31', '2013-02-20 14:45:16', 'eregusn@webmd.com', '8165328419', 'M',
        '193 Namekagon Center', 'MO', '64179', 'United States', 77, 307),
       ('dsheirlawo', 'Dilan', 'Sheirlaw', '1947-10-24', '2014-04-19 15:32:05', 'dsheirlawo@craigslist.org',
        '3231265245', 'M', '5 Schurz Hill', 'CA', '90076', 'United States', 71, 191),
       ('sgreallyp', 'Sander', 'Greally', '1977-12-20', '2007-10-12 07:49:20', 'sgreallyp@dell.com', '3214293268', 'M',
        '23494 Tennyson Drive', 'FL', '32941', 'United States', 53, 232),
       ('aandreixq', 'Alexandr', 'Andreix', '1946-09-07', '2023-07-01 10:53:22', 'aandreixq@ucoz.com', '8082653346',
        'M', '8 Norway Maple Terrace', 'HI', '96825', 'United States', 70, 243),
       ('adastr', 'Angeline', 'Dast', '1986-03-04', '2006-11-02 18:29:53', 'adastr@mayoclinic.com', '2123097297', 'F',
        '1727 Melvin Court', 'NY', '11499', 'United States', 50, 128),
       ('egatuss', 'Etheline', 'Gatus', '1995-08-08', '2019-02-02 08:44:47', 'egatuss@ox.ac.uk', '8059196957', 'F',
        '0 Schmedeman Parkway', 'CA', '93106', 'United States', 78, 135),
       ('lcoret', 'Lavina', 'Core', '2005-12-03', '2019-02-18 13:58:04', 'lcoret@kickstarter.com', '9492817241', 'F',
        '33 Ronald Regan Place', 'CA', '92662', 'United States', 57, 97),
       ('snegalu', 'Shelia', 'Negal', '1947-07-29', '2010-08-24 05:37:11', 'snegalu@etsy.com', '7135022928', 'F',
        '6 Autumn Leaf Avenue', 'TX', '77080', 'United States', 83, 224),
       ('dgaskv', 'Davine', 'Gask', '2006-10-10', '2020-12-18 20:55:00', 'dgaskv@bandcamp.com', '3152410570', 'F',
        '97957 Jenifer Circle', 'NY', '14614', 'United States', 80, 237),
       ('fhendrickxw', 'Ferrel', 'Hendrickx', '1961-02-15', '2021-05-01 23:45:38', 'fhendrickxw@intel.com',
        '4052988863', 'M', '3975 Twin Pines Lane', 'OK', '73114', 'United States', 81, 220),
       ('kandriollix', 'Krishnah', 'Andriolli', '1947-03-20', '2012-12-13 23:24:50', 'kandriollix@reddit.com',
        '8087704752', 'M', '7696 Warner Trail', 'HI', '96840', 'United States', 48, 341),
       ('mgorckey', 'Madelin', 'Gorcke', '1955-03-31', '2016-01-22 18:24:32', 'mgorckey@wikia.com', '5159277014', 'F',
        '25756 Transport Street', 'IA', '50362', 'United States', 69, 224),
       ('hskillingsz', 'Halsy', 'Skillings', '1941-02-26', '2020-02-25 21:32:49', 'hskillingsz@hubpages.com',
        '6055808966', 'M', '35287 Prairie Rose Alley', 'SD', '57198', 'United States', 53, 265),
       ('chug10', 'Clarance', 'Hug', '1944-09-07', '2021-09-01 05:32:21', 'chug10@flickr.com', '4156589644', 'M',
        '585 Clove Road', 'CA', '94177', 'United States', 51, 371),
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
       ('smayhead1n', 'Sergei', 'Mayhead', '1979-08-25', '2013-07-13 17:15:19', 'smayhead1n@cocolog-nifty.com',
        '3147752814', 'M', '6087 Westend Junction', 'MO', '63143', 'United States', 59, 361),
       ('ebrosnan1o', 'Ebenezer', 'Brosnan', '1981-01-16', '2012-12-04 16:19:34', 'ebrosnan1o@mapquest.com',
        '7047737549', 'M', '7450 Glendale Park', 'NC', '28235', 'United States', 60, 398),
       ('nfonzo1p', 'Nanny', 'Fonzo', '1980-03-31', '2008-09-14 00:50:51', 'nfonzo1p@berkeley.edu', '4128016894', 'F',
        '89 Spohn Court', 'PA', '15255', 'United States', 66, 254),
       ('fdimbylow1q', 'Filide', 'Dimbylow', '1934-06-01', '2007-04-04 08:44:56', 'fdimbylow1q@kickstarter.com',
        '6098686465', 'F', '6 Transport Avenue', 'NJ', '08695', 'United States', 52, 288),
       ('jandriulis1r', 'Josiah', 'Andriulis', '1930-03-15', '2009-12-29 04:03:42', 'jandriulis1r@economist.com',
        '7208787524', 'M', '4 Ridgeview Road', 'CO', '80223', 'United States', 55, 195),
       ('paries1s', 'Parker', 'Aries', '1964-07-26', '2017-12-21 14:13:32', 'paries1s@miibeian.gov.cn', '4145155830',
        'M', '7906 Hazelcrest Circle', 'WI', '53234', 'United States', 67, 84),
       ('hboyne1t', 'Herta', 'Boyne', '1944-07-24', '2009-04-27 21:14:26', 'hboyne1t@moonfruit.com', '5743008033', 'F',
        '512 Birchwood Park', 'IN', '46699', 'United States', 76, 383),
       ('ltwatt1u', 'Leicester', 'Twatt', '2002-06-17', '2011-04-07 15:56:58', 'ltwatt1u@multiply.com', '3305412068',
        'M', '00 Coolidge Park', 'OH', '44315', 'United States', 49, 400),
       ('vbrickstock1v', 'Vanda', 'Brickstock', '1932-07-16', '2022-04-01 16:48:16', 'vbrickstock1v@gmpg.org',
        '5137550018', 'F', '47 Northview Center', 'OH', '43215', 'United States', 71, 235),
       ('ohellens1w', 'Onfre', 'Hellens', '1958-06-25', '2007-01-06 19:36:47', 'ohellens1w@surveymonkey.com',
        '6468884560', 'M', '95169 Heffernan Junction', 'NY', '10099', 'United States', 76, 201),
       ('jwhitcomb1x', 'Jayme', 'Whitcomb', '1941-11-14', '2016-02-26 19:37:49', 'jwhitcomb1x@youku.com', '9079598582',
        'M', '8322 Petterle Place', 'AK', '99522', 'United States', 57, 262),
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
       ('hkundt29', 'Humphrey', 'Kundt', '1999-09-26', '2013-10-14 00:47:41', 'hkundt29@forbes.com', '3137753372', 'M',
        '57003 Beilfuss Drive', 'MI', '48232', 'United States', 56, 399),
       ('asoff2a', 'Alric', 'Soff', '1938-09-24', '2008-05-11 14:55:50', 'asoff2a@prweb.com', '4122535186', 'M',
        '1197 Bultman Trail', 'PA', '15230', 'United States', 83, 243),
       ('mstanbra2b', 'Mattie', 'Stanbra', '1979-09-27', '2021-04-21 22:40:58', 'mstanbra2b@webs.com', '9405434930',
        'M', '969 Dwight Center', 'TX', '76310', 'United States', 55, 218),
       ('hbyllam2c', 'Helga', 'Byllam', '1962-01-14', '2020-12-10 14:51:59', 'hbyllam2c@liveinternet.ru', '5402928129',
        'F', '4435 Sachtjen Plaza', 'VA', '24048', 'United States', 52, 250),
       ('varmer2d', 'Vinny', 'Armer', '1969-09-11', '2012-01-04 23:24:32', 'varmer2d@amazonaws.com', '3308270095', 'M',
        '06 Birchwood Terrace', 'OH', '44305', 'United States', 67, 170),
       ('bcyples2e', 'Bertina', 'Cyples', '1994-07-23', '2013-10-01 19:49:35', 'bcyples2e@npr.org', '8168991392', 'F',
        '9 Blue Bill Park Street', 'MO', '64142', 'United States', 78, 288),
       ('csetch2f', 'Carrol', 'Setch', '1976-01-19', '2022-06-15 12:13:29', 'csetch2f@desdev.cn', '3348318962', 'M',
        '06305 Rigney Road', 'AL', '36134', 'United States', 55, 141),
       ('zsole2g', 'Zeke', 'Sole', '1958-05-11', '2013-11-27 08:28:08', 'zsole2g@boston.com', '8637670576', 'M',
        '232 East Point', 'FL', '33811', 'United States', 76, 194),
       ('sfrancillo2h', 'Saraann', 'Francillo', '1932-08-14', '2010-06-19 15:38:09', 'sfrancillo2h@csmonitor.com',
        '7652262278', 'F', '584 Haas Junction', 'IN', '47905', 'United States', 52, 164),
       ('babbey2i', 'Brucie', 'Abbey', '1969-01-16', '2013-03-28 22:23:54', 'babbey2i@joomla.org', '7141426254', 'M',
        '7845 Commercial Street', 'CA', '92710', 'United States', 65, 222),
       ('wpechacek2j', 'Worthington', 'Pechacek', '1948-02-12', '2021-03-12 18:14:49', 'wpechacek2j@prlog.org',
        '2022317776', 'M', '48 Eastwood Place', 'DC', '20319', 'United States', 49, 196),
       ('obeilby2k', 'Oralle', 'Beilby', '1976-05-18', '2009-09-21 03:00:20', 'obeilby2k@chicagotribune.com',
        '8604073926', 'F', '24188 Fairview Terrace', 'CT', '06183', 'United States', 69, 178),
       ('keisig2l', 'Kerby', 'Eisig', '1983-05-22', '2005-05-04 11:45:08', 'keisig2l@aol.com', '3107199216', 'M',
        '1 Novick Alley', 'CA', '90398', 'United States', 56, 366),
       ('erany2m', 'Eberhard', 'Rany', '1998-06-20', '2022-04-06 18:46:24', 'erany2m@mapquest.com', '2024976788', 'M',
        '5 Sugar Park', 'DC', '20580', 'United States', 64, 207),
       ('mcrennell2n', 'Micky', 'Crennell', '1953-07-21', '2010-06-28 20:52:23', 'mcrennell2n@qq.com', '5127838477',
        'M', '041 Anhalt Parkway', 'TX', '78759', 'United States', 81, 277),
       ('mscotchmer2o', 'Marshal', 'Scotchmer', '2005-09-03', '2019-04-30 20:11:57', 'mscotchmer2o@sphinn.com',
        '8502883245', 'M', '49 Melvin Parkway', 'FL', '32405', 'United States', 66, 136),
       ('vivashinnikov2p', 'Veriee', 'Ivashinnikov', '1997-05-23', '2020-05-05 20:15:26', 'vivashinnikov2p@nymag.com',
        '6019176444', 'F', '0 Sachtjen Junction', 'MS', '39216', 'United States', 68, 365),
       ('etrude2q', 'Erhart', 'Trude', '1997-03-11', '2018-03-19 04:48:52', 'etrude2q@chronoengine.com', '8063591138',
        'M', '36944 Portage Court', 'TX', '79405', 'United States', 48, 342),
       ('sarchibold2r', 'Shelley', 'Archibold', '1954-05-28', '2014-03-06 01:40:08', 'sarchibold2r@nature.com',
        '8173514772', 'M', '84844 Kenwood Terrace', 'TX', '75062', 'United States', 56, 113),
       ('hsimmans2s', 'Hyacinthie', 'Simmans', '1992-11-23', '2012-03-11 04:37:30', 'hsimmans2s@i2i.jp', '3058486425',
        'F', '8 Hansons Junction', 'FL', '33283', 'United States', 68, 246),
       ('mstaner2t', 'Marc', 'Staner', '1989-11-19', '2015-08-17 10:18:54', 'mstaner2t@multiply.com', '7734250796', 'M',
        '406 Arizona Lane', 'IL', '60657', 'United States', 81, 257),
       ('lavann2u', 'Lenee', 'Avann', '1938-12-24', '2005-05-08 17:49:11', 'lavann2u@columbia.edu', '9164205827', 'F',
        '5379 Farragut Trail', 'CA', '94273', 'United States', 49, 273),
       ('krichard2v', 'Karlee', 'Richard', '1970-03-15', '2018-10-28 04:16:23', 'krichard2v@house.gov', '3368849471',
        'F', '6943 Hudson Court', 'NC', '27425', 'United States', 84, 119),
       ('gcapponeer2w', 'Giordano', 'Capponeer', '1988-08-31', '2013-05-11 22:58:52', 'gcapponeer2w@seesaa.net',
        '5595833753', 'M', '661 Delaware Junction', 'CA', '93778', 'United States', 52, 285),
       ('chooks2x', 'Chet', 'Hooks', '1998-05-04', '2005-06-03 17:30:31', 'chooks2x@paypal.com', '5021806259', 'M',
        '91 Goodland Hill', 'KY', '40256', 'United States', 81, 281),
       ('barnau2y', 'Becky', 'Arnau', '1989-03-17', '2017-12-01 07:19:05', 'barnau2y@sbwire.com', '2028469877', 'F',
        '4 Sage Place', 'DC', '20268', 'United States', 74, 377),
       ('jmarjanovic2z', 'Julina', 'Marjanovic', '1985-05-27', '2023-05-05 18:07:08', 'jmarjanovic2z@odnoklassniki.ru',
        '6193272282', 'F', '6397 Forster Center', 'CA', '92186', 'United States', 69, 90),
       ('pstrivens30', 'Peyton', 'Strivens', '1954-12-27', '2015-05-12 11:07:27', 'pstrivens30@wp.com', '2405551418',
        'M', '3129 Prentice Crossing', 'MD', '20719', 'United States', 66, 176),
       ('anockells31', 'Alene', 'Nockells', '1958-11-02', '2015-12-17 21:53:11', 'anockells31@canalblog.com',
        '2023592735', 'F', '1 Spenser Street', 'DC', '20397', 'United States', 81, 200),
       ('ajossum32', 'Aylmar', 'Jossum', '1983-12-20', '2007-03-21 21:49:46', 'ajossum32@usgs.gov', '2025244214', 'M',
        '68537 Namekagon Street', 'DC', '20535', 'United States', 52, 360),
       ('kdavydzenko33', 'Kristien', 'Davydzenko', '1974-03-01', '2021-01-10 11:52:38', 'kdavydzenko33@dagondesign.com',
        '8167873594', 'F', '4905 Bartillon Drive', 'KS', '66112', 'United States', 59, 248),
       ('rmoran34', 'Roshelle', 'Moran', '1930-04-18', '2012-04-17 23:14:04', 'rmoran34@desdev.cn', '4055756967', 'F',
        '085 Milwaukee Center', 'OK', '73179', 'United States', 82, 123),
       ('pbaynes35', 'Pepillo', 'Baynes', '1941-05-07', '2017-06-07 12:10:21', 'pbaynes35@unblog.fr', '9419051931', 'M',
        '78 Spenser Pass', 'FL', '34205', 'United States', 53, 335),
       ('kaberdein36', 'Kennith', 'Aberdein', '1996-12-24', '2022-11-02 15:52:34', 'kaberdein36@loc.gov', '7638496845',
        'M', '9032 Sunfield Hill', 'MN', '55565', 'United States', 50, 347),
       ('mscourgie37', 'Michail', 'Scourgie', '1997-03-03', '2008-03-14 10:32:00', 'mscourgie37@earthlink.net',
        '5123096363', 'M', '7736 Continental Park', 'TX', '78726', 'United States', 58, 188),
       ('kparamor38', 'Karla', 'Paramor', '1989-04-07', '2009-04-16 14:33:03', 'kparamor38@apache.org', '2125304852',
        'F', '896 Reinke Junction', 'NY', '10160', 'United States', 70, 266),
       ('dfurmonger39', 'Davis', 'Furmonger', '1988-02-14', '2010-05-14 05:04:03', 'dfurmonger39@symantec.com',
        '7069860086', 'M', '64331 Anzinger Plaza', 'GA', '30130', 'United States', 76, 249),
       ('ddevas3a', 'Derrick', 'Devas', '1996-12-08', '2020-02-16 07:31:52', 'ddevas3a@google.de', '3612465483', 'M',
        '62 Crescent Oaks Plaza', 'TX', '78470', 'United States', 74, 313),
       ('bockwell3b', 'Bert', 'Ockwell', '1938-06-26', '2016-06-05 10:35:16', 'bockwell3b@aol.com', '2137744345', 'F',
        '301 Meadow Vale Parkway', 'CA', '91616', 'United States', 84, 114),
       ('rderbyshire3c', 'Rowen', 'Derbyshire', '1986-04-15', '2013-10-08 00:52:35', 'rderbyshire3c@jiathis.com',
        '3302137320', 'M', '37 Arrowood Center', 'OH', '44305', 'United States', 80, 186),
       ('cedgecumbe3d', 'Corine', 'Edgecumbe', '1991-11-13', '2017-04-01 23:56:36', 'cedgecumbe3d@themeforest.net',
        '7851814363', 'F', '7 Rowland Circle', 'KS', '66622', 'United States', 60, 253),
       ('adowyer3e', 'Amye', 'Dowyer', '1941-06-15', '2008-07-22 08:14:43', 'adowyer3e@jimdo.com', '5712827257', 'F',
        '53984 Duke Park', 'VA', '22244', 'United States', 78, 265),
       ('rskeggs3f', 'Reinaldos', 'Skeggs', '2005-06-03', '2018-08-13 06:05:11', 'rskeggs3f@smh.com.au', '5402606819',
        'M', '75797 Russell Plaza', 'VA', '24009', 'United States', 62, 268),
       ('afrank3g', 'Arnuad', 'Frank', '1970-02-01', '2020-07-13 01:28:11', 'afrank3g@shareasale.com', '8645149827',
        'M', '890 Grasskamp Lane', 'SC', '29305', 'United States', 63, 108),
       ('gspeares3h', 'Giorgi', 'Speares', '1983-11-05', '2016-06-25 12:52:43', 'gspeares3h@nps.gov', '4842842739', 'M',
        '63 Boyd Court', 'PA', '19610', 'United States', 69, 133),
       ('mmauger3i', 'Mead', 'Mauger', '1998-09-12', '2010-11-05 08:18:35', 'mmauger3i@geocities.jp', '5403267399', 'M',
        '26654 Northwestern Circle', 'VA', '24029', 'United States', 77, 148),
       ('bchatelain3j', 'Bart', 'Chatelain', '1941-01-26', '2023-05-31 15:20:02', 'bchatelain3j@furl.net', '5012029820',
        'M', '67 Almo Park', 'AR', '72209', 'United States', 81, 246),
       ('snolleau3k', 'Shadow', 'Nolleau', '1989-10-04', '2020-12-15 17:30:21', 'snolleau3k@psu.edu', '4158028809', 'M',
        '37427 Golf Terrace', 'CA', '94116', 'United States', 80, 378),
       ('clenz3l', 'Carce', 'Lenz', '1979-04-28', '2012-08-16 11:22:25', 'clenz3l@blinklist.com', '2029445413', 'M',
        '25927 Meadow Ridge Point', 'DC', '20078', 'United States', 83, 160),
       ('alightbourn3m', 'Alfons', 'Lightbourn', '1959-09-12', '2017-03-09 17:48:27', 'alightbourn3m@is.gd',
        '2546171028', 'M', '56851 Caliangt Place', 'TX', '76544', 'United States', 60, 387),
       ('wtailour3n', 'Winston', 'Tailour', '1941-12-15', '2011-09-11 20:40:41', 'wtailour3n@china.com.cn',
        '9202153011', 'M', '42868 Dunning Point', 'WI', '54915', 'United States', 53, 202),
       ('mdegan3o', 'Martynne', 'Degan', '1981-06-25', '2006-01-12 23:59:08', 'mdegan3o@mozilla.com', '2025401205', 'F',
        '197 Fisk Street', 'DC', '20022', 'United States', 76, 296),
       ('jsibbons3p', 'James', 'Sibbons', '1940-12-05', '2019-04-20 07:01:42', 'jsibbons3p@nationalgeographic.com',
        '3187944026', 'M', '809 Bartillon Park', 'MA', '02104', 'United States', 77, 250),
       ('tledram3q', 'Toddy', 'Ledram', '1970-07-22', '2021-10-23 22:19:13', 'tledram3q@wordpress.org', '9415891653',
        'M', '278 Blackbird Park', 'FL', '34210', 'United States', 71, 207),
       ('jstroban3r', 'Jameson', 'Stroban', '1976-05-04', '2008-09-09 20:58:10', 'jstroban3r@marketwatch.com',
        '8651667663', 'M', '19536 Ohio Alley', 'TN', '37931', 'United States', 75, 90),
       ('erawes3s', 'Early', 'Rawes', '1941-12-19', '2005-07-04 01:44:25', 'erawes3s@patch.com', '2602780768', 'M',
        '01616 Oak Valley Junction', 'IN', '46852', 'United States', 67, 363),
       ('esinnett3t', 'Egan', 'Sinnett', '1950-05-28', '2022-02-06 00:40:00', 'esinnett3t@mozilla.org', '8127840885',
        'M', '7 International Alley', 'IN', '47705', 'United States', 51, 257),
       ('emacneillie3u', 'Elna', 'MacNeillie', '2001-10-28', '2011-11-23 10:34:59', 'emacneillie3u@chron.com',
        '9156266904', 'F', '840 Heffernan Center', 'TX', '88569', 'United States', 59, 307),
       ('aiglesiaz3v', 'Ashia', 'Iglesiaz', '1967-09-18', '2014-01-12 11:24:03', 'aiglesiaz3v@pen.io', '7039639619',
        'F', '304 Comanche Plaza', 'VA', '20195', 'United States', 69, 192),
       ('rdyett3w', 'Ricky', 'Dyett', '1978-12-31', '2007-02-09 06:52:58', 'rdyett3w@cloudflare.com', '8505991876', 'F',
        '01 Mesta Circle', 'FL', '32590', 'United States', 73, 102),
       ('kshalcros3x', 'Kameko', 'Shalcros', '1982-07-14', '2008-10-10 16:32:28', 'kshalcros3x@kickstarter.com',
        '2813011364', 'F', '007 Melby Plaza', 'TX', '77050', 'United States', 60, 337),
       ('spedden3y', 'Stanislas', 'Pedden', '1988-11-24', '2019-02-24 01:26:49', 'spedden3y@altervista.org',
        '4019648021', 'M', '00 Elka Junction', 'RI', '02912', 'United States', 75, 223),
       ('qabbison3z', 'Quinlan', 'Abbison', '1997-08-01', '2007-10-19 07:31:33', 'qabbison3z@instagram.com',
        '3189486230', 'M', '4240 4th Place', 'LA', '71166', 'United States', 63, 310),
       ('athynn40', 'Annabell', 'Thynn', '1934-05-12', '2016-12-25 07:30:32', 'athynn40@yellowpages.com', '2181248930',
        'F', '7518 Harbort Point', 'MN', '55805', 'United States', 80, 100),
       ('iyateman41', 'Ibbie', 'Yateman', '1994-09-18', '2023-03-08 23:03:30', 'iyateman41@blogger.com', '2027001023',
        'F', '30 Beilfuss Parkway', 'DC', '20530', 'United States', 65, 206),
       ('ysharple42', 'Ysabel', 'Sharple', '1981-10-08', '2015-10-07 19:35:18', 'ysharple42@cpanel.net', '7132674390',
        'F', '37464 Dakota Center', 'TX', '77030', 'United States', 57, 253),
       ('cdyos43', 'Cecilia', 'Dyos', '1932-09-15', '2023-02-26 00:20:36', 'cdyos43@last.fm', '8045678653', 'F',
        '6 Kings Terrace', 'VA', '23289', 'United States', 70, 276),
       ('ssimonaitis44', 'Simeon', 'Simonaitis', '2005-05-21', '2009-06-25 19:42:06', 'ssimonaitis44@domainmarket.com',
        '2816521668', 'M', '6 Rutledge Alley', 'TX', '77030', 'United States', 53, 389),
       ('zhindrick45', 'Zachery', 'Hindrick', '1968-02-01', '2011-07-30 23:00:28', 'zhindrick45@ft.com', '7705472708',
        'M', '1 Welch Road', 'GA', '30092', 'United States', 64, 90),
       ('nslipper46', 'Natka', 'Slipper', '1973-01-02', '2007-01-05 23:28:47', 'nslipper46@diigo.com', '3308199092',
        'F', '875 Twin Pines Park', 'OH', '44710', 'United States', 73, 271),
       ('choyt47', 'Candi', 'Hoyt', '1930-10-20', '2011-03-13 08:40:01', 'choyt47@mediafire.com', '5172035314', 'F',
        '995 Merry Road', 'MI', '48919', 'United States', 59, 226),
       ('krealy48', 'Karleen', 'Realy', '2004-03-11', '2019-05-09 20:53:34', 'krealy48@jugem.jp', '6094297712', 'F',
        '0 Northview Circle', 'NJ', '08638', 'United States', 80, 161),
       ('rbeaty49', 'Robinet', 'Beaty', '1967-02-18', '2014-03-04 03:30:04', 'rbeaty49@bizjournals.com', '8131353651',
        'F', '860 Westport Crossing', 'FL', '33605', 'United States', 51, 276),
       ('gcobbing4a', 'Guillemette', 'Cobbing', '1940-01-09', '2008-06-13 00:56:30', 'gcobbing4a@columbia.edu',
        '3152337049', 'F', '30468 Florence Place', 'NY', '13505', 'United States', 60, 95),
       ('karnull4b', 'Krissy', 'Arnull', '1982-06-28', '2013-05-14 09:27:04', 'karnull4b@ucoz.ru', '6069910792', 'F',
        '2 Cody Court', 'KY', '40745', 'United States', 66, 365),
       ('wsidebotham4c', 'Waneta', 'Sidebotham', '1944-11-09', '2006-12-11 23:10:31', 'wsidebotham4c@4shared.com',
        '2105621648', 'F', '3 Magdeline Hill', 'TX', '78205', 'United States', 70, 379),
       ('oforsard4d', 'Olenolin', 'Forsard', '1942-08-19', '2022-12-16 14:28:40', 'oforsard4d@aboutads.info',
        '3234742008', 'M', '2638 Mallory Point', 'CA', '90076', 'United States', 71, 315),
       ('ceverest4e', 'Consalve', 'Everest', '1932-05-29', '2021-03-03 17:10:06', 'ceverest4e@creativecommons.org',
        '2148420230', 'M', '0517 Arapahoe Terrace', 'TX', '75323', 'United States', 74, 284),
       ('showlings4f', 'Sherman', 'Howlings', '1952-08-01', '2020-08-23 04:40:56', 'showlings4f@yellowbook.com',
        '3043286862', 'M', '15 Elka Park', 'WV', '25305', 'United States', 58, 205),
       ('halven4g', 'Honoria', 'Alven', '1961-07-19', '2005-07-29 02:29:06', 'halven4g@cpanel.net', '5187515788', 'F',
        '30 Bluejay Place', 'NY', '12262', 'United States', 82, 141),
       ('pgladwin4h', 'Pyotr', 'Gladwin', '1960-02-07', '2007-08-16 12:34:47', 'pgladwin4h@fotki.com', '3375336786',
        'M', '7 Marcy Drive', 'LA', '70593', 'United States', 70, 131),
       ('nsleany4i', 'Neala', 'Sleany', '1962-05-18', '2020-06-12 19:20:38', 'nsleany4i@disqus.com', '8087121597', 'F',
        '8 Kipling Court', 'HI', '96820', 'United States', 78, 112),
       ('dbockh4j', 'Duff', 'Bockh', '1998-07-21', '2009-04-08 22:09:49', 'dbockh4j@rakuten.co.jp', '4156967173', 'M',
        '18044 Stone Corner Alley', 'CA', '94913', 'United States', 77, 219),
       ('kbernath4k', 'Karina', 'Bernath', '1953-12-02', '2008-11-21 01:58:11', 'kbernath4k@google.de', '8044133718',
        'F', '25 Birchwood Terrace', 'VA', '23260', 'United States', 59, 233),
       ('edevany4l', 'Edyth', 'Devany', '1935-07-31', '2013-11-19 22:37:08', 'edevany4l@fastcompany.com', '6014478999',
        'F', '61036 Emmet Alley', 'MS', '39236', 'United States', 60, 233),
       ('jbowland4m', 'Jehu', 'Bowland', '1954-01-12', '2011-12-30 01:06:58', 'jbowland4m@merriam-webster.com',
        '9165752296', 'M', '968 Vidon Trail', 'CA', '94245', 'United States', 61, 278),
       ('owingeat4n', 'Oberon', 'Wingeat', '1992-06-09', '2016-03-26 07:49:54', 'owingeat4n@altervista.org',
        '6618206399', 'M', '4069 Eagan Lane', 'CA', '93386', 'United States', 75, 156),
       ('mstorry4o', 'Marissa', 'Storry', '1948-01-22', '2011-11-28 13:35:03', 'mstorry4o@g.co', '3238032186', 'F',
        '74094 High Crossing Road', 'CA', '90094', 'United States', 69, 114),
       ('crobertot4p', 'Claudius', 'Robertot', '2001-08-13', '2015-07-08 11:27:39', 'crobertot4p@deliciousdays.com',
        '8066996844', 'M', '57 Hintze Alley', 'TX', '79116', 'United States', 84, 322),
       ('cchurcher4q', 'Carlos', 'Churcher', '1992-12-12', '2008-11-24 02:37:26', 'cchurcher4q@reference.com',
        '2055918362', 'M', '54052 Golf Place', 'AL', '35487', 'United States', 59, 282),
       ('gswinford4r', 'Gerek', 'Swinford', '2001-06-17', '2007-01-09 15:10:12', 'gswinford4r@state.gov', '9496556160',
        'M', '84691 Atwood Lane', 'CA', '92648', 'United States', 65, 218),
       ('mgives4s', 'Marisa', 'Gives', '1933-08-30', '2008-05-12 11:50:58', 'mgives4s@mapquest.com', '3188837370', 'F',
        '175 Helena Hill', 'LA', '71161', 'United States', 57, 90),
       ('kbearfoot4t', 'Kelvin', 'Bearfoot', '1951-04-13', '2007-01-28 02:55:08', 'kbearfoot4t@g.co', '9194210761', 'M',
        '2343 Thompson Park', 'NC', '27690', 'United States', 72, 107),
       ('gsamwyse4u', 'Gwenore', 'Samwyse', '1933-04-12', '2018-04-13 08:35:45', 'gsamwyse4u@smh.com.au', '4025588438',
        'F', '7 Lakeland Circle', 'NE', '68164', 'United States', 81, 359),
       ('kcurrao4v', 'Kaylee', 'Currao', '1946-02-08', '2014-01-12 10:56:57', 'kcurrao4v@etsy.com', '3602206747', 'F',
        '476 Donald Junction', 'WA', '98506', 'United States', 76, 210),
       ('alatorre4w', 'Aurea', 'La Torre', '1978-07-09', '2007-08-19 02:19:36', 'alatorre4w@flickr.com', '5402097459',
        'F', '86 Shasta Center', 'VA', '22903', 'United States', 50, 253),
       ('gnulty4x', 'Gawain', 'Nulty', '1945-03-29', '2009-09-12 03:44:29', 'gnulty4x@surveymonkey.com', '6827256487',
        'M', '6 Crest Line Pass', 'TX', '76178', 'United States', 64, 151),
       ('lmoffett4y', 'Lindsey', 'Moffett', '1980-12-29', '2019-07-21 03:12:43', 'lmoffett4y@prweb.com', '7276601802',
        'M', '714 Northwestern Avenue', 'FL', '33710', 'United States', 57, 171),
       ('lgriston4z', 'Lawton', 'Griston', '1946-02-23', '2020-05-21 04:58:18', 'lgriston4z@cnbc.com', '3186737353',
        'M', '2497 Calypso Way', 'MA', '02104', 'United States', 58, 326),
       ('lmunroe50', 'Linn', 'Munroe', '1953-01-21', '2011-02-24 18:34:33', 'lmunroe50@youtu.be', '4158477480', 'F',
        '882 Doe Crossing Lane', 'CA', '94147', 'United States', 49, 173),
       ('idavydenko51', 'Idell', 'Davydenko', '1950-09-07', '2017-12-09 05:48:46', 'idavydenko51@i2i.jp', '4051464377',
        'F', '32 Beilfuss Street', 'OK', '73104', 'United States', 76, 147),
       ('rwaghorne52', 'Randi', 'Waghorne', '1943-03-11', '2021-07-18 02:58:33', 'rwaghorne52@yandex.ru', '9149066625',
        'M', '1590 Carey Center', 'NY', '10633', 'United States', 77, 121),
       ('lmawman53', 'Lishe', 'Mawman', '1934-07-24', '2015-08-01 19:39:35', 'lmawman53@networkadvertising.org',
        '9498864978', 'F', '27 Sutherland Plaza', 'CA', '92805', 'United States', 84, 308),
       ('dbennington54', 'Dredi', 'Bennington', '1980-03-29', '2022-04-11 20:54:22', 'dbennington54@timesonline.co.uk',
        '2532974026', 'F', '6 Muir Junction', 'WA', '98442', 'United States', 73, 95),
       ('asivyour55', 'Ami', 'Sivyour', '1984-01-20', '2020-05-16 20:11:25', 'asivyour55@hubpages.com', '2405242654',
        'F', '59 Eagan Road', 'MD', '20918', 'United States', 55, 400),
       ('ogalia56', 'Ogdan', 'Galia', '1946-03-09', '2010-05-02 08:33:17', 'ogalia56@dailymotion.com', '7135642464',
        'M', '7718 Elka Court', 'TX', '77281', 'United States', 75, 299),
       ('bduckwith57', 'Bendite', 'Duckwith', '1974-06-20', '2010-12-05 19:18:48', 'bduckwith57@ihg.com', '6141717554',
        'F', '2125 Havey Park', 'OH', '43215', 'United States', 58, 280),
       ('xphysick58', 'Xylia', 'Physick', '1958-01-16', '2010-03-17 03:14:46', 'xphysick58@berkeley.edu', '6024946621',
        'F', '1649 Iowa Plaza', 'AZ', '85284', 'United States', 52, 120),
       ('kterzo59', 'Kipper', 'Terzo', '2002-12-12', '2008-01-19 13:44:34', 'kterzo59@google.cn', '8045311122', 'M',
        '6 Badeau Hill', 'VA', '23272', 'United States', 61, 184),
       ('enorthern5a', 'Edita', 'Northern', '1943-10-20', '2020-05-05 18:14:59', 'enorthern5a@globo.com', '9188677351',
        'F', '63 Westend Alley', 'OK', '74108', 'United States', 70, 215),
       ('kbrighouse5b', 'Karrie', 'Brighouse', '1943-07-04', '2014-06-06 04:30:11', 'kbrighouse5b@imageshack.us',
        '6052737785', 'F', '10834 Hauk Crossing', 'SD', '57188', 'United States', 56, 278),
       ('dhitzschke5c', 'Dominique', 'Hitzschke', '1995-03-30', '2021-08-24 01:31:44', 'dhitzschke5c@fotki.com',
        '6022704756', 'F', '76 Texas Hill', 'AZ', '85083', 'United States', 73, 341),
       ('ralam5d', 'Ricki', 'Alam', '1978-08-17', '2006-07-01 20:56:00', 'ralam5d@youku.com', '2025972569', 'F',
        '4017 Morningstar Parkway', 'DC', '20557', 'United States', 49, 308),
       ('lpettyfar5e', 'Leonidas', 'Pettyfar', '1946-10-16', '2012-08-14 15:45:07', 'lpettyfar5e@hc360.com',
        '4199645588', 'M', '765 Upham Court', 'OH', '45807', 'United States', 60, 259),
       ('bblyde5f', 'Bordie', 'Blyde', '1937-05-05', '2007-07-01 14:49:59', 'bblyde5f@1und1.de', '5014785826', 'M',
        '63 Oakridge Park', 'AR', '72199', 'United States', 60, 334),
       ('gkingsnode5g', 'Glenden', 'Kingsnode', '1955-07-20', '2010-04-15 06:12:36', 'gkingsnode5g@nifty.com',
        '8164794813', 'M', '5 Norway Maple Center', 'MO', '64190', 'United States', 52, 186),
       ('gdenziloe5h', 'Griswold', 'Denziloe', '1986-09-17', '2022-03-14 02:30:40', 'gdenziloe5h@salon.com',
        '2092793968', 'M', '925 Sheridan Drive', 'CA', '93726', 'United States', 74, 86),
       ('scorteis5i', 'Sonnie', 'Corteis', '1980-08-14', '2017-12-07 19:33:36', 'scorteis5i@ed.gov', '9019592515', 'F',
        '62 Sullivan Alley', 'TN', '38181', 'United States', 78, 207),
       ('fgrigoryov5j', 'Felicity', 'Grigoryov', '1999-11-14', '2013-03-21 18:31:40', 'fgrigoryov5j@usnews.com',
        '9725279203', 'F', '4 Killdeer Road', 'TX', '75221', 'United States', 64, 226),
       ('mpontain5k', 'Morgen', 'Pontain', '1937-08-24', '2017-01-07 07:25:28', 'mpontain5k@com.com', '8067965424', 'F',
        '32 Russell Lane', 'TX', '79176', 'United States', 78, 305),
       ('afalcus5l', 'Ahmed', 'Falcus', '1933-07-07', '2018-01-08 03:26:16', 'afalcus5l@goo.ne.jp', '8169609176', 'M',
        '4 Utah Park', 'MO', '64130', 'United States', 62, 321),
       ('hknight5m', 'Hilary', 'Knight', '2004-05-14', '2016-12-27 16:54:17', 'hknight5m@indiatimes.com', '2121616195',
        'F', '26 Arkansas Court', 'NY', '10260', 'United States', 52, 83),
       ('gjosofovitz5n', 'Gertruda', 'Josofovitz', '1952-01-16', '2006-06-21 17:32:05', 'gjosofovitz5n@google.com.br',
        '7199358801', 'F', '8 Kings Junction', 'CO', '80951', 'United States', 78, 141),
       ('gkeyse5o', 'Gian', 'Keyse', '1956-12-08', '2023-03-13 05:49:08', 'gkeyse5o@youtu.be', '9524513769', 'M',
        '30769 Marcy Drive', 'MN', '55573', 'United States', 51, 359),
       ('wberks5p', 'Wilie', 'Berks', '1934-01-16', '2010-08-05 11:31:30', 'wberks5p@devhub.com', '8125500869', 'F',
        '92918 Pennsylvania Pass', 'IN', '47812', 'United States', 76, 211),
       ('rsima5q', 'Riordan', 'Sima', '1932-03-22', '2022-06-19 11:18:15', 'rsima5q@free.fr', '7636138359', 'M',
        '53 New Castle Court', 'MN', '55446', 'United States', 69, 141),
       ('tdeniske5r', 'Tonnie', 'Deniske', '1948-05-19', '2008-05-23 12:12:07', 'tdeniske5r@ocn.ne.jp', '8479100433',
        'M', '6 Eastlawn Court', 'IL', '60208', 'United States', 66, 208),
       ('iference5s', 'Isis', 'Ference', '1932-08-08', '2012-07-24 22:29:30', 'iference5s@mozilla.com', '9417754436',
        'F', '69 Sutherland Junction', 'FL', '34233', 'United States', 63, 82),
       ('mbyrcher5t', 'Melantha', 'Byrcher', '1959-01-15', '2010-10-14 05:05:02', 'mbyrcher5t@godaddy.com',
        '3033896432', 'F', '470 Victoria Road', 'CO', '80217', 'United States', 59, 133),
       ('fconnett5u', 'Frederic', 'Connett', '1948-10-15', '2005-03-21 20:06:06', 'fconnett5u@go.com', '9417060159',
        'M', '28262 Marquette Terrace', 'FL', '33982', 'United States', 73, 326),
       ('swisdom5v', 'Saba', 'Wisdom', '1981-04-11', '2014-12-20 11:46:16', 'swisdom5v@state.gov', '7023415445', 'F',
        '7936 Hooker Junction', 'NV', '89135', 'United States', 72, 203),
       ('rgirault5w', 'Rozele', 'Girault', '2006-07-25', '2014-09-28 23:05:18', 'rgirault5w@sourceforge.net',
        '2609111520', 'F', '9212 Mesta Way', 'IN', '46857', 'United States', 66, 398),
       ('aanderer5x', 'Alard', 'Anderer', '1932-03-24', '2012-03-11 12:33:19', 'aanderer5x@canalblog.com', '8189376501',
        'M', '79 Hazelcrest Crossing', 'CA', '91109', 'United States', 73, 136),
       ('mcorbie5y', 'Moss', 'Corbie', '1963-12-22', '2013-09-01 14:06:08', 'mcorbie5y@goodreads.com', '8321128409',
        'M', '2 2nd Point', 'TX', '77266', 'United States', 49, 205),
       ('babatelli5z', 'Bartie', 'Abatelli', '1981-10-31', '2023-05-04 20:58:44', 'babatelli5z@google.co.uk',
        '7192317129', 'M', '36811 Ilene Crossing', 'CO', '80920', 'United States', 73, 162),
       ('rbuntin60', 'Rosana', 'Buntin', '1975-09-15', '2020-08-20 18:13:36', 'rbuntin60@npr.org', '8636357739', 'F',
        '3671 Arizona Hill', 'FL', '33884', 'United States', 64, 199),
       ('tdecarteret61', 'Talbot', 'De Carteret', '1997-11-07', '2020-08-19 20:56:01', 'tdecarteret61@myspace.com',
        '2033579139', 'M', '5 Pawling Lane', 'CT', '06505', 'United States', 61, 101),
       ('sdubois62', 'Sunny', 'Dubois', '1939-01-19', '2005-08-05 23:44:02', 'sdubois62@biglobe.ne.jp', '5022980997',
        'M', '78 Rutledge Point', 'KY', '41905', 'United States', 79, 178),
       ('lpurser63', 'Larina', 'Purser', '1948-09-07', '2012-07-01 08:16:40', 'lpurser63@hhs.gov', '2483102886', 'F',
        '5174 Shelley Drive', 'MI', '48335', 'United States', 72, 245),
       ('mantonescu64', 'Mirna', 'Antonescu', '1936-05-30', '2010-04-18 03:18:51', 'mantonescu64@i2i.jp', '7138814613',
        'F', '09700 Springview Hill', 'TX', '77245', 'United States', 57, 123),
       ('cyakushkin65', 'Cull', 'Yakushkin', '1965-02-20', '2022-03-20 08:54:22', 'cyakushkin65@bbb.org', '5613292791',
        'M', '5659 Erie Alley', 'FL', '33467', 'United States', 57, 287),
       ('apech66', 'Agathe', 'Pech', '1939-04-16', '2019-02-05 06:42:20', 'apech66@ox.ac.uk', '9153560362', 'F',
        '44553 Colorado Drive', 'TX', '79945', 'United States', 60, 222),
       ('fhelder67', 'Fredra', 'Helder', '1979-05-22', '2010-12-21 01:29:48', 'fhelder67@nasa.gov', '2159417371', 'F',
        '5 Messerschmidt Plaza', 'PA', '19125', 'United States', 64, 109),
       ('lrunciman68', 'Leanor', 'Runciman', '1934-03-28', '2008-06-02 16:23:19', 'lrunciman68@gnu.org', '2023619447',
        'F', '9803 Milwaukee Street', 'DC', '20530', 'United States', 58, 122),
       ('spearne69', 'Stinky', 'Pearne', '1955-01-21', '2009-06-09 08:24:45', 'spearne69@sakura.ne.jp', '6155653968',
        'M', '9533 Parkside Park', 'TN', '37215', 'United States', 55, 127),
       ('gderby6a', 'Georgena', 'Derby', '1976-08-22', '2017-03-01 21:39:34', 'gderby6a@thetimes.co.uk', '8042691787',
        'F', '50201 Harper Point', 'VA', '23260', 'United States', 83, 119),
       ('lgaffney6b', 'Lynsey', 'Gaffney', '2000-03-31', '2013-07-21 02:13:27', 'lgaffney6b@bizjournals.com',
        '5032222691', 'F', '92 Monument Junction', 'OR', '97211', 'United States', 72, 363),
       ('tvaux6c', 'Ted', 'Vaux', '1951-07-05', '2007-12-19 00:26:14', 'tvaux6c@soundcloud.com', '8019640489', 'F',
        '6987 Pleasure Hill', 'UT', '84105', 'United States', 56, 81),
       ('npeers6d', 'Nicholle', 'Peers', '1965-10-08', '2020-10-27 02:47:46', 'npeers6d@tinypic.com', '3045518002', 'F',
        '07277 Arapahoe Parkway', 'WV', '25356', 'United States', 66, 395),
       ('alowne6e', 'Archibald', 'Lowne', '1993-04-19', '2006-08-03 04:32:59', 'alowne6e@apache.org', '7862750969', 'M',
        '695 Packers Junction', 'FL', '33153', 'United States', 60, 380),
       ('sbengough6f', 'Sonya', 'Bengough', '1960-03-27', '2009-09-29 07:36:41', 'sbengough6f@ifeng.com', '5718090319',
        'F', '82 Annamark Drive', 'VA', '20167', 'United States', 76, 335),
       ('hkennea6g', 'Hyman', 'Kennea', '1955-12-14', '2011-12-21 21:12:23', 'hkennea6g@seesaa.net', '9171026406', 'M',
        '63 Lyons Plaza', 'NY', '10474', 'United States', 64, 143),
       ('dcocklie6h', 'Dallas', 'Cocklie', '1955-10-05', '2018-03-10 07:21:20', 'dcocklie6h@vistaprint.com',
        '7853688867', 'M', '04350 Bultman Pass', 'KS', '66611', 'United States', 83, 271),
       ('mdjokic6i', 'Merrie', 'Djokic', '1939-10-05', '2021-06-08 14:46:22', 'mdjokic6i@sciencedirect.com',
        '9153265441', 'F', '06910 Old Shore Drive', 'TX', '79945', 'United States', 58, 177),
       ('tgringley6j', 'Tremaine', 'Gringley', '1998-02-10', '2013-11-21 22:25:04', 'tgringley6j@archive.org',
        '2159741484', 'M', '82 Blaine Road', 'PA', '19115', 'United States', 73, 361),
       ('kmcettigen6k', 'Kylie', 'McEttigen', '1969-06-01', '2019-11-02 16:12:21', 'kmcettigen6k@ed.gov', '5129346657',
        'M', '5 Acker Alley', 'TX', '78726', 'United States', 66, 240),
       ('ifancutt6l', 'Inglis', 'Fancutt', '1989-04-08', '2022-05-04 19:15:51', 'ifancutt6l@dell.com', '8063950362',
        'M', '1501 Pierstorff Point', 'TX', '79188', 'United States', 62, 392),
       ('dvurley6m', 'Deirdre', 'Vurley', '1998-07-22', '2011-05-31 04:55:29', 'dvurley6m@simplemachines.org',
        '3378804036', 'F', '68 Cottonwood Park', 'LA', '70593', 'United States', 50, 205),
       ('dcharle6n', 'Donnell', 'Charle', '1941-04-16', '2016-10-24 18:11:56', 'dcharle6n@narod.ru', '3091537189', 'M',
        '27 Mandrake Trail', 'IL', '61629', 'United States', 75, 124),
       ('wgoudard6o', 'Witty', 'Goudard', '1973-10-29', '2022-03-06 10:06:16', 'wgoudard6o@independent.co.uk',
        '4011975283', 'M', '6 Rusk Alley', 'RI', '02905', 'United States', 75, 288),
       ('gscoyles6p', 'Gwenora', 'Scoyles', '2000-06-05', '2017-09-04 10:03:57', 'gscoyles6p@sogou.com', '7136774967',
        'F', '0 Saint Paul Junction', 'TX', '77218', 'United States', 83, 241),
       ('ceric6q', 'Coleen', 'Eric', '1952-03-29', '2013-02-01 16:41:27', 'ceric6q@gravatar.com', '8124995637', 'F',
        '047 Rowland Point', 'IN', '47712', 'United States', 65, 400),
       ('pmacane6r', 'Penrod', 'MacAne', '1936-09-20', '2013-07-16 05:12:09', 'pmacane6r@umich.edu', '2028893928', 'M',
        '1 Moland Park', 'DC', '20226', 'United States', 61, 97),
       ('kwaddilow6s', 'Karoly', 'Waddilow', '1990-11-23', '2019-01-11 21:43:08', 'kwaddilow6s@google.pl', '9522713636',
        'F', '57 1st Terrace', 'MN', '55557', 'United States', 67, 197),
       ('gbarneveld6t', 'Granville', 'Barneveld', '2005-06-08', '2020-09-17 01:57:08', 'gbarneveld6t@bbb.org',
        '2609099286', 'M', '7489 West Pass', 'IN', '46825', 'United States', 57, 338),
       ('aminchell6u', 'Allyson', 'Minchell', '1988-12-11', '2006-07-02 07:07:04', 'aminchell6u@buzzfeed.com',
        '2064341101', 'F', '2 Sundown Junction', 'WA', '98140', 'United States', 69, 384),
       ('ptretwell6v', 'Putnem', 'Tretwell', '2002-03-31', '2009-07-24 07:39:39', 'ptretwell6v@ning.com', '9165121731',
        'M', '3 Mesta Avenue', 'CA', '94273', 'United States', 73, 254),
       ('wdanielsson6w', 'Whitby', 'Danielsson', '1959-10-30', '2017-02-18 08:33:32', 'wdanielsson6w@alibaba.com',
        '5593552961', 'M', '0809 Service Point', 'CA', '93704', 'United States', 72, 306),
       ('fthorp6x', 'Fallon', 'Thorp', '1967-01-11', '2022-05-22 01:02:12', 'fthorp6x@furl.net', '6164622666', 'F',
        '66 Colorado Terrace', 'MI', '49544', 'United States', 69, 298),
       ('kemmert6y', 'Kristyn', 'Emmert', '1955-03-22', '2017-12-01 00:08:11', 'kemmert6y@webs.com', '4805507638', 'F',
        '9897 Schmedeman Junction', 'AZ', '85015', 'United States', 53, 182),
       ('ogutman6z', 'Odelia', 'Gutman', '1989-01-17', '2019-12-05 02:39:38', 'ogutman6z@is.gd', '9417529941', 'F',
        '33273 Mosinee Plaza', 'FL', '34282', 'United States', 84, 261),
       ('clittle70', 'Candra', 'Little', '1955-11-16', '2014-09-03 02:03:56', 'clittle70@freewebs.com', '6059908166',
        'F', '1573 Knutson Center', 'SD', '57105', 'United States', 79, 344),
       ('cgorini71', 'Clair', 'Gorini', '1939-02-15', '2009-04-13 16:13:50', 'cgorini71@lycos.com', '3239616589', 'M',
        '83 Del Sol Trail', 'CA', '90076', 'United States', 70, 352),
       ('kvoff72', 'Kiley', 'Voff', '1933-08-09', '2023-02-26 21:47:10', 'kvoff72@newyorker.com', '2168662626', 'M',
        '40414 Pawling Terrace', 'OH', '44191', 'United States', 48, 384),
       ('pmazey73', 'Peirce', 'Mazey', '1969-03-14', '2005-04-13 18:32:07', 'pmazey73@wisc.edu', '6192703527', 'M',
        '3381 Ridgeway Crossing', 'CA', '92160', 'United States', 69, 361),
       ('jtabourin74', 'Jasmina', 'Tabourin', '1952-12-02', '2020-08-01 09:53:20', 'jtabourin74@ezinearticles.com',
        '3175583186', 'F', '84 Aberg Plaza', 'IN', '46207', 'United States', 62, 275),
       ('rspurden75', 'Rhianna', 'Spurden', '1955-07-30', '2005-07-28 13:23:32', 'rspurden75@networksolutions.com',
        '5711382761', 'F', '9539 Lakewood Parkway', 'VA', '22234', 'United States', 51, 173),
       ('tbrewse76', 'Tanny', 'Brewse', '1952-10-07', '2006-01-01 21:25:36', 'tbrewse76@cargocollective.com',
        '5406725584', 'M', '408 Lakewood Gardens Drive', 'VA', '24014', 'United States', 53, 168),
       ('chateley77', 'Carling', 'Hateley', '1990-06-06', '2013-06-11 06:40:01', 'chateley77@upenn.edu', '7819211804',
        'M', '28 Crescent Oaks Way', 'MA', '02453', 'United States', 79, 170),
       ('dlahrs78', 'Dorotea', 'Lahrs', '1988-04-05', '2016-07-08 04:06:49', 'dlahrs78@google.fr', '3031619979', 'F',
        '71737 Luster Lane', 'CO', '80243', 'United States', 61, 227),
       ('jtrent79', 'Johnny', 'Trent', '1947-08-08', '2016-11-06 16:24:19', 'jtrent79@so-net.ne.jp', '3611132634', 'M',
        '80382 Grim Park', 'TX', '78426', 'United States', 60, 139),
       ('ebodycombe7a', 'Elicia', 'Bodycombe', '1970-11-03', '2007-05-17 20:10:24', 'ebodycombe7a@ebay.co.uk',
        '9159704811', 'F', '57 Ridge Oak Park', 'TX', '88589', 'United States', 64, 214),
       ('mgouldthorp7b', 'Margette', 'Gouldthorp', '1981-12-09', '2009-07-01 16:13:54',
        'mgouldthorp7b@odnoklassniki.ru', '8083597529', 'F', '9889 Namekagon Lane', 'HI', '96845', 'United States', 65,
        86),
       ('rjeppensen7c', 'Rockwell', 'Jeppensen', '1984-02-13', '2023-01-11 03:40:44', 'rjeppensen7c@yellowbook.com',
        '4808909866', 'M', '8055 Hazelcrest Avenue', 'AZ', '85210', 'United States', 48, 376),
       ('fmaciunas7d', 'Faythe', 'Maciunas', '2001-04-03', '2018-05-12 16:13:26', 'fmaciunas7d@accuweather.com',
        '7147533483', 'F', '7 Brown Crossing', 'CA', '92822', 'United States', 54, 203),
       ('mbog7e', 'Maiga', 'Bog', '1947-02-26', '2016-05-27 07:53:05', 'mbog7e@multiply.com', '6465244949', 'F',
        '1 Miller Way', 'NY', '10009', 'United States', 65, 304),
       ('swashbrook7f', 'Salvatore', 'Washbrook', '1993-05-10', '2013-03-16 21:08:14', 'swashbrook7f@printfriendly.com',
        '5089871408', 'M', '372 Gina Terrace', 'MA', '02162', 'United States', 57, 196),
       ('asalmond7g', 'Aileen', 'Salmond', '1954-02-15', '2014-03-30 13:12:50', 'asalmond7g@umn.edu', '8174568595', 'F',
        '5027 Warrior Street', 'TX', '76129', 'United States', 78, 98),
       ('cshevlin7h', 'Ciro', 'Shevlin', '1971-03-29', '2010-04-19 17:51:25', 'cshevlin7h@ustream.tv', '7065375349',
        'M', '1 Jana Point', 'GA', '31914', 'United States', 61, 212),
       ('ssilversmid7i', 'Seymour', 'Silversmid', '1979-10-07', '2018-11-27 01:02:10', 'ssilversmid7i@illinois.edu',
        '5719153002', 'M', '918 Eagle Crest Junction', 'VA', '22225', 'United States', 83, 104),
       ('ckerr7j', 'Christopher', 'Kerr', '1955-03-15', '2012-11-06 19:15:13', 'ckerr7j@hugedomains.com', '7732156964',
        'M', '69637 Blue Bill Park Avenue', 'IL', '60636', 'United States', 76, 365),
       ('cmcadam7k', 'Collete', 'McAdam', '1976-01-25', '2015-02-12 11:25:05', 'cmcadam7k@ca.gov', '7174030252', 'F',
        '36 Sutherland Avenue', 'PA', '17405', 'United States', 54, 239),
       ('pgorst7l', 'Park', 'Gorst', '1974-01-28', '2009-07-31 16:22:03', 'pgorst7l@umn.edu', '2028423954', 'M',
        '9186 Charing Cross Plaza', 'DC', '20409', 'United States', 74, 358),
       ('klefwich7m', 'Kissie', 'Lefwich', '1953-07-25', '2020-11-30 14:16:29', 'klefwich7m@howstuffworks.com',
        '8578151950', 'F', '872 International Alley', 'MA', '02114', 'United States', 58, 330),
       ('jpretsel7n', 'Jo', 'Pretsel', '1986-08-31', '2011-01-27 22:44:36', 'jpretsel7n@imgur.com', '7865941422', 'M',
        '20408 Farmco Place', 'FL', '33153', 'United States', 50, 122),
       ('ahallworth7o', 'Almeda', 'Hallworth', '1979-01-17', '2011-09-10 04:03:12', 'ahallworth7o@ehow.com',
        '2102113236', 'F', '114 Bellgrove Place', 'TX', '78250', 'United States', 84, 388),
       ('ibow7p', 'Isidor', 'Bow', '1941-12-20', '2006-02-10 01:59:30', 'ibow7p@4shared.com', '2398222413', 'M',
        '918 Meadow Ridge Way', 'FL', '33913', 'United States', 50, 306),
       ('abasham7q', 'Alisha', 'Basham', '1984-12-21', '2018-05-13 00:27:55', 'abasham7q@wordpress.com', '5159802195',
        'F', '2 Cardinal Center', 'IA', '50362', 'United States', 54, 353),
       ('sbartell7r', 'Stephanie', 'Bartell', '1944-05-19', '2016-08-26 02:53:37', 'sbartell7r@webmd.com', '4153134667',
        'F', '24111 Maple Wood Parkway', 'CA', '94611', 'United States', 75, 127),
       ('kgrundle7s', 'Karlee', 'Grundle', '1991-03-24', '2019-03-27 06:36:46', 'kgrundle7s@ibm.com', '8139450014', 'F',
        '05391 Browning Street', 'FL', '33543', 'United States', 58, 82),
       ('nbatcheldor7t', 'Nigel', 'Batcheldor', '1969-10-26', '2020-12-10 22:04:55', 'nbatcheldor7t@exblog.jp',
        '8035823826', 'M', '5 Emmet Plaza', 'SC', '29215', 'United States', 74, 106),
       ('hhurtado7u', 'Herbert', 'Hurtado', '2002-01-06', '2010-04-03 12:16:31', 'hhurtado7u@bloglovin.com',
        '4093445153', 'M', '42 Hoard Road', 'TX', '77388', 'United States', 84, 255),
       ('gcritchard7v', 'Gilberte', 'Critchard', '2005-01-13', '2023-02-08 01:28:16', 'gcritchard7v@walmart.com',
        '9018396833', 'F', '9 Lunder Circle', 'TN', '38161', 'United States', 76, 170),
       ('kdickie7w', 'Kathy', 'Dickie', '1942-10-31', '2007-03-17 11:50:06', 'kdickie7w@alexa.com', '2109765722', 'F',
        '06 Meadow Ridge Junction', 'TX', '78215', 'United States', 54, 369),
       ('bdisbrow7x', 'Bordy', 'Disbrow', '1948-09-17', '2008-06-25 03:20:14', 'bdisbrow7x@skype.com', '9413904030',
        'M', '1605 Starling Way', 'FL', '33982', 'United States', 79, 176),
       ('lfrango7y', 'Llywellyn', 'Frango', '1947-11-18', '2010-05-03 12:37:32', 'lfrango7y@illinois.edu', '4064369444',
        'M', '25609 Burrows Point', 'MT', '59623', 'United States', 50, 159),
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

SELECT * FROM GeneralUser;