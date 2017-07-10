-- DROP TABLE IF ALREADY EXISTS
DROP TABLE if exists Movie;
DROP TABLE if exists Reviewer;
DROP TABLE if exists Rating;

-- CREATE TABLE SCHEMA
CREATE TABLE Movie(mID int, title text, year int, director text);
CREATE TABLE Reviewer(rID int, name text);
CREATE TABLE Rating(rID int, mID int, stars int, ratingDate date);

-- INSERT SPECIFIC DATA INTO TABLES
INSERT INTO Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
INSERT INTO Movie values(102, 'Star Wars', 1977, 'George Lucas');
INSERT INTO Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
INSERT INTO Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
INSERT INTO Movie values(105, 'Titanic', 1997, 'James Cameron');
INSERT INTO Movie values(106, 'Snow White', 1937, null);
INSERT INTO Movie values(107, 'Avatar', 2009, 'James Cameron');
INSERT INTO Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

INSERT INTO Reviewer values(201, 'Sarah Martinez');
INSERT INTO Reviewer values(202, 'Daniel Lewis');
INSERT INTO Reviewer values(203, 'Brittany Harris');
INSERT INTO Reviewer values(204, 'Mike Anderson');
INSERT INTO Reviewer values(205, 'Chris Jackson');
INSERT INTO Reviewer values(206, 'Elizabeth Thomas');
INSERT INTO Reviewer values(207, 'James Cameron');
INSERT INTO Reviewer values(208, 'Ashley White');

INSERT INTO Rating values(201, 101, 2, '2011-01-22');
INSERT INTO Rating values(201, 101, 4, '2011-01-27');
INSERT INTO Rating values(202, 106, 4, null);
INSERT INTO Rating values(203, 103, 2, '2011-01-20');
INSERT INTO Rating values(203, 108, 4, '2011-01-12');
INSERT INTO Rating values(203, 108, 2, '2011-01-30');
INSERT INTO Rating values(204, 101, 3, '2011-01-09');
INSERT INTO Rating values(205, 103, 3, '2011-01-27');
INSERT INTO Rating values(205, 104, 2, '2011-01-22');
INSERT INTO Rating values(205, 108, 4, null);
INSERT INTO Rating values(206, 107, 3, '2011-01-15');
INSERT INTO Rating values(206, 106, 5, '2011-01-19');
INSERT INTO Rating values(207, 107, 5, '2011-01-20');
INSERT INTO Rating values(208, 104, 3, '2011-01-02');

-- SQL Movie-Rating Query Exercises

-- Q1 Find the titles of all movies directed by Steven Spielberg.  
SELECT title
FROM movie
WHERE director = "Steven Spielberg";

-- Q2 Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
SELECT distinct year
FROM movie, rating using(mid)
WHERE rating.stars > 3
ORDER BY year asc;

-- Q3 Find the titles of all movies that have no ratings. 
SELECT title
FROM movie
WHERE mid NOT IN (SELECT mid FROM rating);

-- Q4 Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
SELECT distinct name
FROM reviewer, rating using(rid)
WHERE ratingDate IS NULL;

-- Q5 Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
SELECT name, title, stars, ratingdate
FROM movie, rating using(mid), reviewer using(rid)
ORDER BY name, title, stars;

-- Q6 For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
SELECT name, title
FROM movie,
  rating R1 using(mid),
  rating R2 using(rid),
  reviewer using (rid)
WHERE r1.rid = r2.rid
  AND r1.mid = r2.mid
  AND r1.ratingdate < r2.ratingdate
  AND r1.stars < r2.stars;

-- Q7 For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
SELECT title, max(stars)
FROM rating, movie using(mid)
GROUP BY title
ORDER BY title;

-- Q8 For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
SELECT title, max(stars) - min(stars) as Rating_Spread
FROM movie, rating using(mid)
GROUP BY title
ORDER BY Rating_Spread desc, title;

-- Q9 Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 
SELECT avg(pre1980.avg)- avg(post1980.avg)
FROM
  (SELECT avg(stars) as avg
   FROM rating, movie using(mid)
   WHERE movie.year < 1980
   GROUP BY title) as pre1980,
  (SELECT avg(stars) as avg
   FROM rating, movie using(mid)
   WHERE movie.year > 1980
   GROUP BY title) as post1980;


-- SQL Movie-Rating Query Exercises (Extras)

-- Q1(E) Find the names of all reviewers who rated Gone with the Wind. 
SELECT distinct name
FROM reviewer, rating using(rid), movie using (mid)
WHERE title = 'Gone with the Wind';

-- Q2(E) For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
SELECT name, title, stars
FROM reviewer,
  rating using(rid),
  movie using (mid)
WHERE name = director;

-- Q3(E) Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 
SELECT name FROM reviewer
UNION
SELECT title FROM movie;

-- Q4(E) Find the titles of all movies not reviewed by Chris Jackson. 
SELECT title
FROM movie
WHERE mid NOT IN
  (SELECT mid
   FROM rating, reviewer using(rid)
   WHERE name = 'Chris Jackson');

-- Q5(E) For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
SELECT distinct re1.name, re2.name
FROM Rating R1, Rating R2, Reviewer Re1, Reviewer Re2
  WHERE R1.mID = R2.mID
  AND R1.rID = Re1.rID
  AND R2.rID = Re2.rID
  AND Re1.name < Re2.name
ORDER BY Re1.name, Re2.name;

-- Q6(E) For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 
SELECT name, title, stars
FROM reviewer,
  rating using(rid),
  movie using(mid)
WHERE stars = (SELECT min(stars) FROM rating);

-- Q7(E) List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 
SELECT title, avg(stars) as average
FROM movie, rating using(mid)
GROUP BY mid
ORDER BY average desc, title;

-- Q8(E) Find the names of all reviewers who have contributed three or more ratings.
SELECT name
FROM reviewer, rating using(rid)
GROUP BY name
HAVING count(*) >= 3;

-- Q9(E) Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. 
SELECT M1.title, director
FROM Movie M1, Movie M2 using(director)
GROUP BY M1.mId
HAVING COUNT(*) > 1
ORDER BY director, M1.title;

-- Q10(E) Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
SELECT title, avg(stars) as average
FROM movie, rating using(mid)
GROUP BY mid
HAVING average = (SELECT max(averagestars)
                  FROM(SELECT title, avg(stars) as averagestars
                       FROM movie, rating using(mid)
                       GROUP BY mid));