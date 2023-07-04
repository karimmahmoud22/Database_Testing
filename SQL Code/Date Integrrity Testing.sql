USE university;

CREATE TABLE courses(
	courseId INT(3) PRIMARY KEY,
    courseName VARCHAR(20) UNIQUE,
    duration INT(2),
    fee INT(3) CHECK(fee BETWEEN 100 AND 500)
);

CREATE TABLE students(
	sid INT(5) PRIMARY KEY,
    sName VARCHAR(20) NOT NULL,
    age INT(2) CHECK( age BETWEEN 15 AND 30),
    doj DATETIME DEFAULT NOW(),
    doc DATETIME,
    courseId INT(3),
    FOREIGN KEY(courseId) REFERENCES courses(courseId) ON DELETE CASCADE
);
/* ---------- COURSES TABLE ---------- */

/* ---------- Validate CourseId ----------*/
INSERT INTO courses 
VALUES ( 111, "Java", 3, 500 );

INSERT INTO courses 
VALUES ( 111, "Python", 2, 300 );

INSERT INTO courses 
VALUES ( null, "Java", 2, 300 );

/* ---------- Validate CourseName ----------*/
INSERT INTO courses 
VALUES ( 222, "Python", 2, 300 );

INSERT INTO courses 
VALUES ( 333, "Python", 2, 300 );

/* ---------- Validate Fee ----------*/
INSERT INTO courses 
VALUES ( 333, "Javascript", 1, 100 );

INSERT INTO courses 
VALUES ( 444, "Typescript", 1, 500 );

INSERT INTO courses 
VALUES ( 555, "vbscript", 1, 50 );

INSERT INTO courses 
VALUES (  555, "vbscript", 1, 600 );

SELECT * FROM courses;

/* ---------- COURSES TABLE ---------- */

/* ---------- Validate SID and SName ----------*/
INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (101, "John", 20, null, 111);

INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (101, "X", 20, null, 111);

INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (102, null, 20, null, 111);

/* ---------- Validate Age ----------*/
INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (102, "Smith", 15, NULL, 111);

INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (103, "Kim", 30, NULL, 111);

INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (104, "Mary", 10, NULL, 111);

INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (104, "Mary", 35, NULL, 111);

/* ---------- Validate Doj ----------*/
SELECT doj FROM students;

/* ---------- Validate CourseId Forgeign Key (References to CourseId in Courses Table) ----------*/
INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (104, "Scott", 30, NULL, 222);

INSERT INTO students ( sid, sName, age, doc, courseId )
VALUES (105, "David", 20, NULL, 555);

/* ---------- Validate Deleting Record from parent table (courses) and check child table (students) record automatically deleted ----------*/
DELETE FROM courses
WHERE courseId = 222;

SELECT * FROM students;
