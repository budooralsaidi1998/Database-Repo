use ITI
-- Create a view that displays student full name, course name if the student has a grade more than 50. 
CREATE VIEW StudentCourseView AS
SELECT 
    CONCAT(St_Fname, ' ', St_Lname) AS FullName,
    (SELECT Crs_Name 
     FROM Course 
     WHERE Crs_Id IN (
         SELECT Crs_Id 
         FROM Stud_Course 
         WHERE St_Id = s.St_Id AND Grade > 50
     )) AS Crs_Name
FROM 
    Student s
WHERE 
    s.St_Id IN (
        SELECT St_Id 
        FROM Stud_Course 
        WHERE Grade > 50
    )
select *  from StudentCourseView 

-- Create an Encrypted view that displays manager names and the topics they teach. 
CREATE VIEW EncryptedManagerTopics
WITH ENCRYPTION
AS
SELECT 
    (SELECT Dept_Manager 
     FROM Department 
     WHERE Dept_Id IN (
         SELECT Dept_Id 
         FROM Instructor 
         WHERE Ins_Id IN (
             SELECT TOP (1) Ins_Id 
             FROM Topic 
             WHERE Top_Id IS NOT NULL  -- Adjust this condition as needed
         )
     )) AS ManagerName,
    (SELECT Top_Name 
     FROM Topic 
     WHERE Top_Id IS NOT NULL  -- Adjust this condition as needed
     
    ) AS TopicName

	SELECT * FROM EncryptedManagerTopics;

	--Create a view that will display Instructor Name, Department Name for the ‘SD’ or ‘Java’ Department  

CREATE VIEW InstructorDepartmentView AS
SELECT 
    Ins_Name AS InstructorName,
    (SELECT Dept_Name 
     FROM Department 
     WHERE Dept_Id = (SELECT Dept_Id 
                      FROM Instructor 
                      WHERE Ins_Name = i.Ins_Name) 
     AND Dept_Name IN ('SD', 'Java')) AS DepartmentName
FROM 
   Instructor i
WHERE  
    (SELECT Dept_Name 
     FROM Department 
     WHERE Dept_Id = (SELECT Dept_Id 
                      FROM Instructor 
                      WHERE Ins_Name = i.Ins_Name)) IN ('SD', 'Java');

 SELECT * FROM InstructorDepartmentView;

--Create a view that will display the project name and the number of employees work on it. “Use Company DB”

use Company_SD
CREATE VIEW ProjectEmployeeCount AS
SELECT 
    Pname AS ProjectName,
    (SELECT COUNT(*)
     FROM Employee e
     WHERE e.Dno = p.Pnumber) AS EmployeeCount
FROM 
   dbo.Project p;

   SELECT * FROM ProjectEmployeeCount;

   --Try to generate script from DB ITI that describes all tables and views in this DB (Self Search)


   CREATE SCHEMA Company;

CREATE TABLE Company.Department (
    Dnum INT PRIMARY KEY,
    Dname VARCHAR(100),
    MGRSSN INT,
    MGRStartDate DATE
);


CREATE TABLE Company.Project (
    Pnumber INT PRIMARY KEY,
    Pname VARCHAR(100),
    Plocation VARCHAR(100),
    City VARCHAR(100),
    Dnum INT,
    FOREIGN KEY (Dnum) REFERENCES Company.Department(Dnum)
);
CREATE SCHEMA HumanResource;
-- Create the Employee table in the Human Resource schema
CREATE TABLE HumanResource.Employee (
    SSN INT PRIMARY KEY,
    Fname VARCHAR(100),
    Lname VARCHAR(100),
    Bdate DATE,
    Address VARCHAR(255),
    Sex CHAR(1),
    Salary DECIMAL(10, 2),
    Superssn INT,
    Dno INT, 
    FOREIGN KEY (Dno) REFERENCES Company.Department(Dnum) 
);