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

-- SQL Movie-Rating Data Modification Exercises

-- Q1 Add the reviewer Roger Ebert to your database, with an rID of 209.  
INSERT INTO reviewer values('209', 'Roger Ebert');

-- Q2 Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 
INSERT INTO Rating  
  SELECT rID, mID, 5, null
  FROM reviewer, movie
  WHERE name="James Cameron";

-- Q3 For all movies that have an average rating of 4 stars or higher, add 25 to the release year.
UPDATE movie
SET year = year + 25
WHERE mid in
    (SELECT mid
     FROM
       (SELECT avg(stars) as avgstar, mid
        FROM rating, movie using(mid)
        GROUP BY mid
        HAVING avgstar>=4));

-- Q4 Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
DELETE FROM rating
WHERE mid IN
  (SELECT mid
   FROM movie
   WHERE year <1970 or year > 2000)
   AND stars < 4;