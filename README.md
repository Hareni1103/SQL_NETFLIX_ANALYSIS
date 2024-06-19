# SQL_NETFLIX_ANALYSIS

This repository contains SQL queries and scripts for analyzing Netflix TV shows and movies data. It includes various analytical queries to extract insights such as top-rated titles, average scores, genre popularity, and more.
Table of Contents

    Introduction
    Queries Overview
    Project Structure
    Setup Instructions
    Usage
    Contributing
    License

Introduction

This project focuses on analyzing Netflix TV shows and movies data using SQL queries. It leverages a database named netflix_analysis containing tables titles and credits. The queries provide insights into various aspects such as:

    Top-rated movies and shows by IMDB score
    Average scores (IMDB and TMDB) for movies and shows
    Count of titles by release year and decade
    Analysis by production countries and age certifications
    Top actors and directors based on appearances
    Genre popularity and more

Queries Overview

The SQL queries in this repository cover a wide range of analyses:

    Top-rated movies and shows
    Average scores for movies and shows
    Count of titles by release year and decade
    Analysis by production countries and age certifications
    Top actors and directors based on appearances
    Genre popularity and common certifications
    Detailed insights on highly rated titles and character appearances

Project Structure

lua

|-- sql_queries/
|   |-- top_movies.sql
|   |-- top_shows.sql
|   |-- average_scores.sql
|   |-- count_by_decade.sql
|   |-- production_countries_analysis.sql
|   |-- age_certification_analysis.sql
|   |-- top_actors.sql
|   |-- top_directors.sql
|   |-- average_runtime.sql
|   |-- recent_movies_directors.sql
|   |-- top_seasons_shows.sql
|   |-- top_genres_movies.sql
|   |-- top_genres_shows.sql
|   |-- high_scores_titles.sql
|   |-- titles_per_year.sql
|   |-- high_rated_actors.sql
|   |-- character_appearances.sql
|   |-- common_genres.sql
|   |-- avg_imdb_leading_actors.sql
|-- README.md

Setup Instructions

To run these SQL queries locally or in your database environment:

    Database Setup:
        Ensure you have a MySQL or PostgreSQL database set up (adjust connection details in queries if necessary).
        Create a database named netflix_analysis and import the schema.

    Run Queries:
        Copy and paste SQL queries from sql_queries/ directory into your SQL client or IDE.
        Execute the queries to analyze the Netflix data and derive insights.

Usage

    Clone this repository: git clone <https://github.com/Hareni1103/SQL_NETFLIX_ANALYSIS/>
    Navigate to the SQL_NETFLIX_ANALYSIS/ directory.
    Open and run the SQL queries in your preferred SQL client (e.g., MySQL Workbench, pgAdmin, etc.).
    Review the results to gain insights into Netflix TV shows and movies.

Contributing

Contributions are welcome! Here's how you can contribute:

    Fork the repository.
    Create a new branch (git checkout -b feature/new-analysis).
    Make your changes.
    Commit your changes (git commit -am 'Add new analysis').
    Push to the branch (git push origin feature/new-analysis).
    Create a new Pull Request.

License

This project is licensed under the MIT License - see the LICENSE file for details.
