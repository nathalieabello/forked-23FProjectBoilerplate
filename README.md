# MySQL + Flask Boilerplate Project

This repo contains a boilerplate setup for spinning up 3 Docker containers: 
1. A MySQL 8 container for obvious reasons
1. A Python Flask container to implement a REST API
1. A Local AppSmith Server

## How to setup and start the containers
**Important** - you need Docker Desktop installed

1. Clone this repository.  
1. Create a file named `db_root_password.txt` in the `secrets/` folder and put inside of it the root password for MySQL. 
1. Create a file named `db_password.txt` in the `secrets/` folder and put inside of it the password you want to use for the a non-root user named webapp. 
1. In a terminal or command prompt, navigate to the folder with the `docker-compose.yml` file.  
1. Build the images with `docker compose build`
1. Start the containers with `docker compose up`.  To run in detached mode, run `docker compose up -d`. 

## Overview
Oftentimes, people want to get in shape and improve their health, but they run into the problem of not having an easy and accessible way to seek help and track progress. This could discourage people from pursuing these health goals simply because they don’t have a clear path to get started and/or keep going. Shmoop is a health and fitness tracking platform that integrates health monitoring, nutrition management, workout suggestions, and other analytics with a goal of uplifting physical health. Shmoop is intended to help anyone from a fitness beginner to a trained professional in achieving their fitness goals. From keeping tabs on your workouts, optimizing sleep, maintaining a balanced diet, or receiving personalized recommendations, Shmoop offers the tools and data-driven guidance to help users maximize their potential.


### Project Video
[Link Here](https://drive.google.com/file/d/1bSKrFyYnMYz-dyOgJXzB49OSLWuG0cgF/view?usp=sharing)</u>
