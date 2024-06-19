-- create schema
create schema netflix_analysis;
use netflix_analysis;

-- import data using table data import wizard
-- imported 2 tables - 1. credits 2. titles
-- viewing of records
select * from credits;
select * from titles;

-- Count of Movies and TV Shows
select type, count(*) as count
	from titles group by type;
    
-- Most Popular Genres
select genres, count(*) as count
	from titles group by genres
		order by count desc 
			limit 10;
            
-- Top Rated Movies and TV Shows
select title,type,imdb_score
	from titles order by imdb_score desc
		limit 10;
        
-- Movies and TV Shows by Year
select release_year, count(*) as count
	from titles group by release_year
		order by release_year;
        
-- Actors/Directors with Most Titles
select name, role, count(*) as count
	from credits group by name, role
		order by count desc limit 10;
        
-- Average IMDb Score by Genre
select genres, avg(imdb_score) as avg_imdb_score
	from titles group by genres
		order by avg_imdb_score desc;
        
-- Correlation between Runtime and IMDb Score
select runtime,imdb_score from titles
	where imdb_score is not null and runtime is not null;

-- Popular Production Countrie
select production_countries, COUNT(*) as count
	from titles
		group by production_countries
			order by count desc limit 10;
            
-- Titles with Actor Names
select t.title, c.name as actor_name, c.character
	from titles t join credits c on t.id = c.id
		where c.role = 'Actor';
        
-- Top Directors by IMDb Score
select c.name as director_name, avg(t.imdb_score) as avg_imdb_score
	from titles t join credits c on t.id = c.id
		where c.role = 'Director'
			group by c.name
				order by avg_imdb_score desc limit 10;
                
-- Check for Null or Invalid Values
SELECT *
FROM titles
WHERE id IS NULL 
   OR title IS NULL 
   OR type IS NULL 
   OR release_year IS NULL 
   OR imdb_score IS NULL 
   OR id = '' 
   OR title = '' 
   OR type = '' 
   OR release_year < 1900 -- Assuming 1900 as the earliest valid year
   OR imdb_score < 0 
   OR imdb_score > 10; -- Assuming IMDb scores are between 0 and 10
   
SELECT *
FROM credits
WHERE person_id IS NULL 
   OR id IS NULL 
   OR name IS NULL 
   OR role IS NULL 
   OR person_id = 0 
   OR id = '' 
   OR name = '' 
   OR role = '';

-- Standardize the genres and production countries for consistency
update titles
	set genres = LOWER(TRIM(genres));
    
update titles
	set production_countries = LOWER(TRIM(production_countries));
    
-- Handle cases where a title might have multiple genres or production countries listed
-- Split multiple genres into separate rows (using a temporary table)
create temporary table temp_genres (
    id text,
    genre text
);

create temporary table temp_production_countries (
    id text,
    country text
);

-- Create Stored Procedures for Splitting Strings
delimiter //

drop procedure if exists split_genres;

create procedure split_genres()
begin
    declare done int default false;
    declare genre_string text;
    declare title_id text;
    declare genre text;
    declare cur cursor for select id, genres from titles;
    declare continue handler for not found set done = true;

    open cur;

    read_loop: loop
        fetch cur into title_id, genre_string;
        if done then
            leave read_loop;
        end if;

        repeat
            set genre = substring_index(genre_string, ',', 1);
            set genre_string = trim(both ',' from substring(genre_string, length(genre) + 2));
            insert into temp_genres (id, genre) values (title_id, trim(genre));
        until genre_string = ''
        end repeat;
    end loop;

    close cur;
end //

delimiter ;

delimiter //

drop procedure if exists split_production_countries;

create procedure split_production_countries()
begin
    declare done int default false;
    declare country_string text;
    declare title_id text;
    declare country text;
    declare cur cursor for select id, production_countries from titles;
    declare continue handler for not found set done = true;

    open cur;

    read_loop: loop
        fetch cur into title_id, country_string;
        if done then
            leave read_loop;
        end if;

        repeat
            set country = substring_index(country_string, ',', 1);
            set country_string = trim(both ',' from substring(country_string, length(country) + 2));
            insert into temp_production_countries (id, country) values (title_id, trim(country));
        until country_string = ''
        end repeat;
    end loop;

    close cur;
end //

delimiter ;

-- Call the Stored Procedures
call split_genres();
call split_production_countries();

-- Create Standardized Tables
create table standardized_genres as
	select distinct id, genre
		from temp_genres;

create table standardized_production_countries as
	select distinct id, country
		from temp_production_countries;
        
-- Create a View for Cleaned Titles
create view cleaned_titles as
select t.id, t.title, t.type, t.description, t.release_year, t.age_certification, t.runtime, 
       t.imdb_id, t.imdb_score, t.imdb_votes, t.tmdb_popularity, t.tmdb_score, 
       sg.genre, spc.country
from titles t
left join standardized_genres sg on t.id = sg.id
left join standardized_production_countries spc on t.id = spc.id;

select * from cleaned_titles limit 10;

select t.id, sg.id as genre_id, spc.id as country_id
from titles t
left join standardized_genres sg on t.id = sg.id
left join standardized_production_countries spc on t.id = spc.id
where sg.id is null or spc.id is null
limit 10;

-- What were the top 10 movies according to IMDB score?
select title, 
       type, 
       imdb_score
from netflix_analysis.titles
where imdb_score >= 8.0
  and type = 'movie'
order by imdb_score desc
limit 10;

-- What were the top 10 shows according to IMDB score?
select title, 
       type, 
       imdb_score
from netflix_analysis.titles
where imdb_score >= 8.0
  and type = 'show'
order by imdb_score desc
limit 10;

-- What were the bottom 10 movies according to IMDB score?
select title, 
       type, 
       imdb_score
from netflix_analysis.titles
where type = 'movie'
order by imdb_score asc
limit 10;

-- What were the bottom 10 shows according to IMDB score?
select title, 
       type, 
       imdb_score
from netflix_analysis.titles
where type = 'show'
order by imdb_score asc
limit 10;

-- What were the average IMDB and TMDB scores for shows and movies?
select distinct type, 
       round(avg(imdb_score), 2) as avg_imdb_score,
       round(avg(tmdb_score), 2) as avg_tmdb_score
from netflix_analysis.titles
group by type;

-- Count of movies and shows in each decade
select concat(floor(release_year / 10) * 10, 's') as decade,
       count(*) as movies_shows_count
from netflix_analysis.titles
where release_year >= 1940
group by concat(floor(release_year / 10) * 10, 's')
order by decade;

-- What were the average IMDB and TMDB scores for each production country?
select distinct production_countries, 
       round(avg(imdb_score), 2) as avg_imdb_score,
       round(avg(tmdb_score), 2) as avg_tmdb_score
from netflix_analysis.titles
group by production_countries
order by avg_imdb_score desc;

-- What were the average IMDB and TMDB scores for each age certification for shows and movies?
select distinct age_certification, 
       round(avg(imdb_score), 2) as avg_imdb_score,
       round(avg(tmdb_score), 2) as avg_tmdb_score
from netflix_analysis.titles
group by age_certification
order by avg_imdb_score desc;

-- What were the 5 most common age certifications for movies?
select age_certification, 
       count(*) as certification_count
from netflix_analysis.titles
where type = 'movie' 
  and age_certification != 'N/A'
group by age_certification
order by certification_count desc
limit 5;

-- Who were the top 20 actors that appeared the most in movies/shows?
select distinct name as actor, 
       count(*) as number_of_appearances 
from netflix_analysis.credits
where role = 'actor'
group by name
order by number_of_appearances desc
limit 20;

-- Who were the top 20 directors that directed the most movies/shows?
select distinct name as director, 
       count(*) as number_of_appearances 
from netflix_analysis.credits
where role = 'director'
group by name
order by number_of_appearances desc
limit 20;

-- Calculating the average runtime of movies and TV shows separately
select 'Movies' as content_type,
       round(avg(runtime), 2) as avg_runtime_min
from netflix_analysis.titles
where type = 'movie'
union all
select 'Show' as content_type,
       round(avg(runtime), 2) as avg_runtime_min
from netflix_analysis.titles
where type = 'show';

-- Finding the titles and directors of movies released on or after 2010
select distinct t.title, 
                c.name as director, 
                release_year
from netflix_analysis.titles as t
join netflix_analysis.credits as c 
on t.id = c.id
where t.type = 'movie' 
  and t.release_year >= 2010 
  and c.role = 'director'
order by release_year desc;

-- Which shows on Netflix have the most seasons?
select title, 
       sum(seasons) as total_seasons
from netflix_analysis.titles 
where type = 'show'
group by title
order by total_seasons desc
limit 10;

-- Which genres had the most movies? 
select genres, 
       count(*) as title_count
from netflix_analysis.titles 
where type = 'movie'
group by genres
order by title_count desc
limit 10;

-- Which genres had the most shows? 
select genres, 
       count(*) as title_count
from netflix_analysis.titles 
where type = 'show'
group by genres
order by title_count desc
limit 10;

-- Titles and Directors of movies with high IMDB scores (>7.5) and high TMDB popularity scores (>80) 
select t.title, 
       c.name as director
from netflix_analysis.titles as t
join netflix_analysis.credits as c 
on t.id = c.id
where t.type = 'movie' 
  and t.imdb_score > 7.5 
  and t.tmdb_popularity > 80 
  and c.role = 'director';

-- What were the total number of titles for each year? 
select release_year, 
       count(*) as title_count
from netflix_analysis.titles 
group by release_year
order by release_year desc;

-- Actors who have starred in the most highly rated movies or shows
select c.name as actor, 
       count(*) as num_highly_rated_titles
from netflix_analysis.credits as c
join netflix_analysis.titles as t 
on c.id = t.id
where c.role = 'actor'
  and (t.type = 'movie' or t.type = 'show')
  and t.imdb_score > 8.0
  and t.tmdb_score > 8.0
group by c.name
order by num_highly_rated_titles desc;

-- Which actors/actresses played the same character in multiple movies or TV shows? 
select c.name as actor_actress, 
       c.character, 
       count(distinct t.title) as num_titles
from netflix_analysis.credits as c
join netflix_analysis.titles as t 
on c.id = t.id
where c.role = 'actor' or c.role = 'actress'
group by c.name, c.character
having count(distinct t.title) > 1;

-- What were the top 3 most common genres?
select t.genres, 
       count(*) as genre_count
from netflix_analysis.titles as t
where t.type = 'movie'
group by t.genres
order by genre_count desc
limit 3;

-- Average IMDB score for leading actors/actresses in movies or shows 
select c.name as actor_actress, 
       round(avg(t.imdb_score), 2) as average_imdb_score
from netflix_analysis.credits as c
join netflix_analysis.titles as t 
on c.id = t.id
where c.role = 'actor' or c.role = 'actress'
  and c.character = 'leading role'
group by c.name
order by average_imdb_score desc;