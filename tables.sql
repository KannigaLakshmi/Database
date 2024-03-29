-- idnr=national identification number (10 digits)
-- Students(_idnr_, name, login, program)
CREATE TABLE Students (
 idnr CHAR(10) PRIMARY KEY, -- Primary key can not be null.
 name TEXT NOT NULL,
 login TEXT NOT NULL UNIQUE,
 program TEXT NOT NULL );

-- UNIQUE constraint making sure a student can not be in two different programs depending on where one looks.
ALTER TABLE Students ADD CONSTRAINT uc_sp UNIQUE (idnr, program);

-- Branches(_name_, _program_)
CREATE TABLE Branches (
 name TEXT,
 program TEXT,
 PRIMARY KEY (name, program) ); -- Primary key can not be null.

-- Courses(_code_, name, credits, department)
CREATE TABLE Courses (
 code CHAR(6) PRIMARY KEY, -- Primary key can not be null.
 name TEXT NOT NULL,
 credits FLOAT NOT NULL CHECK (credits >= 0), -- The number of credits must be non-negative.
 department TEXT NOT NULL );

-- Program(_name_, abbr)
CREATE TABLE Programs (
 name TEXT PRIMARY KEY,
 abbr TEXT NOT NULL );

-- Department(_name_, abbr)
CREATE TABLE Departments (
 name TEXT PRIMARY KEY,
 abbr TEXT NOT NULL UNIQUE );

-- LimitedCourses(_code_, capacity)
-- code → Courses.code
CREATE TABLE LimitedCourses (
 code CHAR(6) PRIMARY KEY REFERENCES Courses, -- When referencing to a primary key one can omit the attribute.
 capacity INTEGER NOT NULL CHECK (capacity >= 0) ); -- The capacity must be non-negative.

-- StudentBranches(_student_, branch, program)
--  student → Students.idnr
--  (branch, program) → Branches.(name, program)
CREATE TABLE StudentBranches (
 student TEXT PRIMARY KEY NOT NULL REFERENCES Students, -- When referencing to a primary key one can omit the attribute.
 branch TEXT NOT NULL,
 program TEXT NOT NULL,
 FOREIGN KEY (student, program) REFERENCES Students(idnr, program) );

-- Classifications(_name_)
CREATE TABLE Classifications (
 name TEXT PRIMARY KEY );

-- Classified(_course_, _classification_)
--  course → courses.code
--  classification → Classifications.name
CREATE TABLE Classified (
 course CHAR(6) REFERENCES Courses,
 classification TEXT REFERENCES Classifications,
 PRIMARY KEY (course, classification) );

-- MandatoryProgram(_course_, _program_)
--  course → Courses.code
CREATE TABLE MandatoryProgram (
 course CHAR(6) REFERENCES Courses,
 program TEXT,
 PRIMARY KEY (course, program) );

-- MandatoryBranch(_course_, _branch_, _program_)
--  course → Courses.code
--  (branch, program) → Branches.(name, program)
CREATE TABLE MandatoryBranch (
 course CHAR(6) REFERENCES Courses,
 branch TEXT NOT NULL,
 program TEXT NOT NULL,
 FOREIGN KEY (branch, program) REFERENCES Branches,
 PRIMARY KEY (course, branch, program) );

-- RecommendedBranch(_course_, _branch_, _program_)
--  course → Courses.code
--  (branch, program) → Branches.(name, program)
CREATE TABLE RecommendedBranch (
 course CHAR(6) REFERENCES Courses,
 branch TEXT NOT NULL,
 program TEXT NOT NULL,
 FOREIGN KEY (branch, program) REFERENCES Branches,
 PRIMARY KEY (course, branch, program) );

-- Registered(_student_, _course_)
--  student → Students.idnr
--  course → Courses.code
CREATE TABLE Registered (
 student CHAR(10) REFERENCES Students,
 course CHAR(6) REFERENCES Courses,
 PRIMARY KEY (student, course) );

-- Prerequisites(_course_, _prereq_)
--  course → Courses.code
--  prereq → Prerequisites.code
CREATE TABLE Prerequisites (
 course CHAR(6) REFERENCES Courses,
 prereq CHAR(6) REFERENCES Courses,
 PRIMARY KEY (course, prereq) );

-- Taken(_student_, _course_, grade)
--  student → Students.idnr
--  course → Courses.code
CREATE TABLE Taken (
 student CHAR(10) REFERENCES Students,
 course CHAR(6) REFERENCES Courses,
 grade CHAR(1) NOT NULL,
 CHECK (grade IN('U', '3', '4', '5')),
 PRIMARY KEY (student, course) );

-- WaitingList(_student_, _course_, position)
--  student → Students.idnr
--  course → Limitedcourses.code
-- Position is either a SERIAL, a TIMESTAMP or the actual position!
-- Used TIMESTAMP and therefore removed the position attribute in inserts.sql.
CREATE TABLE WaitingList (
 student CHAR(10) REFERENCES Students,
 course CHAR(6) REFERENCES LimitedCourses,
 position TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL UNIQUE,
 PRIMARY KEY (student, course) );

-- ProgramDepartment(_program_, department)
--  program → Programs.name
--  department → Departments.name
CREATE TABLE ProgramDepartment (
 program TEXT REFERENCES Programs, -- When referencing to a primary key one can omit the attribute.
 department TEXT REFERENCES Departments,
 PRIMARY KEY (program, department) );
