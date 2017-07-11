-- DROP TABLE IF ALREADY EXISTS
DROP TABLE if exists Highschooler;
DROP TABLE if exists Friend;
DROP TABLE if exists Likes;

-- CREATE TABLE SCHEMA
CREATE TABLE Highschooler(ID int, name text, grade int);
CREATE TABLE Friend(ID1 int, ID2 int);
CREATE TABLE Likes(ID1 int, ID2 int);

-- INSERT SPECIFIC DATA INTO TABLES
INSERT INTO Highschooler values (1510, 'Jordan', 9);
INSERT INTO Highschooler values (1689, 'Gabriel', 9);
INSERT INTO Highschooler values (1381, 'Tiffany', 9);
INSERT INTO Highschooler values (1709, 'Cassandra', 9);
INSERT INTO Highschooler values (1101, 'Haley', 10);
INSERT INTO Highschooler values (1782, 'Andrew', 10);
INSERT INTO Highschooler values (1468, 'Kris', 10);
INSERT INTO Highschooler values (1641, 'Brittany', 10);
INSERT INTO Highschooler values (1247, 'Alexis', 11);
INSERT INTO Highschooler values (1316, 'Austin', 11);
INSERT INTO Highschooler values (1911, 'Gabriel', 11);
INSERT INTO Highschooler values (1501, 'Jessica', 11);
INSERT INTO Highschooler values (1304, 'Jordan', 12);
INSERT INTO Highschooler values (1025, 'John', 12);
INSERT INTO Highschooler values (1934, 'Kyle', 12);
INSERT INTO Highschooler values (1661, 'Logan', 12);

INSERT INTO Friend values (1510, 1381);
INSERT INTO Friend values (1510, 1689);
INSERT INTO Friend values (1689, 1709);
INSERT INTO Friend values (1381, 1247);
INSERT INTO Friend values (1709, 1247);
INSERT INTO Friend values (1689, 1782);
INSERT INTO Friend values (1782, 1468);
INSERT INTO Friend values (1782, 1316);
INSERT INTO Friend values (1782, 1304);
INSERT INTO Friend values (1468, 1101);
INSERT INTO Friend values (1468, 1641);
INSERT INTO Friend values (1101, 1641);
INSERT INTO Friend values (1247, 1911);
INSERT INTO Friend values (1247, 1501);
INSERT INTO Friend values (1911, 1501);
INSERT INTO Friend values (1501, 1934);
INSERT INTO Friend values (1316, 1934);
INSERT INTO Friend values (1934, 1304);
INSERT INTO Friend values (1304, 1661);
INSERT INTO Friend values (1661, 1025);
INSERT INTO Friend select ID2, ID1 from Friend;

INSERT INTO Likes values(1689, 1709);
INSERT INTO Likes values(1709, 1689);
INSERT INTO Likes values(1782, 1709);
INSERT INTO Likes values(1911, 1247);
INSERT INTO Likes values(1247, 1468);
INSERT INTO Likes values(1641, 1468);
INSERT INTO Likes values(1316, 1304);
INSERT INTO Likes values(1501, 1934);
INSERT INTO Likes values(1934, 1501);
INSERT INTO Likes values(1025, 1101);

-- SQL Social Network Data Query Exercises

-- Q1 Find the names of all students who are friends with someone named Gabriel. 
SELECT name
FROM highschooler
WHERE id IN (SELECT ID1
             FROM friend
             WHERE ID2 in (SELECT id
                           FROM highschooler
                           WHERE name = 'Gabriel'));

-- Q2 For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.  
SELECT DISTINCT sName, sGrade, lName, lGrade
FROM (SELECT h1.name as sName, h1.grade sGrade, h2.name as lName, h2.grade as lGrade, h1.grade-h2.grade as gradeDiff 
      FROM Highschooler h1, Likes, Highschooler h2
      WHERE h1.ID=ID1 and h2.ID=ID2)
WHERE gradeDiff > 1;

-- Q3 For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 
SELECT h1.name, h1.grade, h2.name, h2.grade
FROM Likes l1, Likes l2, Highschooler h1, Highschooler h2
  WHERE l1.ID1 = l2.ID2
  AND l2.ID1 = l1.ID2
  AND l1.ID1 = h1.ID
  AND l1.ID2 = h2.ID
  AND h1.name < h2.name;

-- Q4 Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
SELECT name, grade
FROM highschooler
WHERE id NOT IN (SELECT id1 FROM likes) AND
      id NOT IN (SELECT id2 FROM likes)
ORDER BY
  grade, name;

-- Q5 For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
SELECT distinct
  H1.name, H1.grade, H2.name, H2.grade
FROM
  likes,
  highschooler H1,
  highschooler H2
WHERE
  H1.ID = likes.ID1 AND
  H2.ID = likes.ID2 AND
  H2.ID NOT IN (SELECT ID1 FROM likes);
  
  -- Q6 Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 
SELECT distinct name, grade
FROM highschooler
WHERE id NOT IN (SELECT id1
                 FROM highschooler H1, highschooler H2, friend
                 WHERE
                   H1.ID=Friend.ID1 AND
                   H2.ID=Friend.ID2 AND
                   H1.grade<>H2.grade)
ORDER BY grade, name;
  
  -- Q7 For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 
SELECT distinct
  H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
    FROM
      highschooler H1,
      highschooler H2,
      highschooler H3,
      friend f1,
      friend f2,
      likes
    WHERE
      H1.ID = likes.ID1 AND
      H1.ID = F1.ID1 AND
      H2.ID = likes.ID2 AND
      H2.ID = F2.ID2 AND
      H3.ID = F2.ID1 AND
      H3.ID = F1.ID2 AND
      H1.ID NOT IN
            (SELECT ID1 FROM friend WHERE ID2 = H2.ID);

  -- Q8 Find the difference between the number of students in the school and the number of different first names.
SELECT COUNT(ID) - COUNT (distinct name)
FROM highschooler;

  -- Q9 Find the name and grade of all students who are liked by more than one other student.
SELECT name, grade
FROM highschooler, likes
WHERE
  highschooler.id = likes.id2
  GROUP BY id2
  HAVING COUNT(id2) > 1;

-- SQL Social Network Data Query Exercises (Extras)

-- Q1(E) For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
SELECT
  h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
FROM
  likes l1,
  likes l2,
  highschooler h1,
  highschooler h2,
  highschooler h3
WHERE
  l1.id2 = l2.id1 AND
  l2.id2 <> l1.id1 AND
  l1.id1 = h1.id AND
  l1.id2 = h2.id AND
  l2.id2 = h3.id;

  -- Q2(E) Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
  SELECT name, grade
FROM Highschooler
WHERE id NOT IN (select h1.ID
                 FROM
                   Highschooler h1,
                   Highschooler h2,
                   Friend f1
                 WHERE
                   h1.ID = f1.ID1 AND
                   h2.ID = f1.ID2 AND
                   h2.grade = h1.grade);

  -- Q3(E) What is the average number of friends per student? (Your result should be just one number.)
  SELECT avg(count)
FROM (SELECT count(ID2) AS count
      FROM friend
      GROUP BY id1);

  -- Q4(E) Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
SELECT count(id2)
FROM friend
WHERE id1 IN (SELECT id2
              FROM friend
              WHERE id1 IN (SELECT id
                            FROM highschooler
                            WHERE name = 'Cassandra'))
AND id1 NOT IN (SELECT id
                FROM highschooler
                WHERE name='Cassandra');

  -- Q5(E) Find the name and grade of the student(s) with the greatest number of friends. 
SELECT highschooler.name, highschooler.grade
FROM highschooler, friend
WHERE
  highschooler.id = friend.id1
GROUP BY friend.id1
HAVING COUNT(friend.id2) = (SELECT max(r.fcount)
                            FROM (select count(id2) AS fcount
                                  FROM friend
                                  GROUP BY id1) as r);