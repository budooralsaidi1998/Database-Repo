use iti 

SELECT 
    Ins_Name AS InstructorName,
    (SELECT Dept_Name 
     FROM Department 
     WHERE Dept_Id = (SELECT Dept_Id 
                   FROM Instructor 
                   WHERE Ins_Name = i.Ins_Name)
    ) AS DepartmentName
FROM 
   Instructor i;

--Display student full name and the name of the course he is taking
--For only courses which have a grade  


   SELECT 
    (SELECT CONCAT(St_Fname, ' ', St_Lname) 
     FROM Student 
     WHERE St_Id = sc.St_Id) AS FullName,
    (SELECT Crs_Name 
     FROM Course 
     WHERE Crs_Id = sc.Crs_Id) AS CourseName
FROM 
   Stud_Course sc
WHERE 
    sc.Grade IS NOT NULL; 

	--Display number of courses for each topic name

	SELECT 
    Top_Name AS TopicName,
    (SELECT COUNT(*) 
     FROM Course 
     WHERE Top_Id = t.Top_Id) AS NumberOfCourses
FROM 
  Topic t;

  --Display max and min salary for instructors
  SELECT 
    MAX(Salary) AS MaxSalary,
    MIN(Salary) AS MinSalary
FROM 
Instructor;

--Display the Department name that contains the instructor who receives the minimum salary.
SELECT 
    (SELECT Dept_Name 
     FROM Department 
     WHERE Dept_Id = (SELECT Dept_Id 
                   FROM Instructor 
                   WHERE Salary = (SELECT MIN(Salary) FROM Instructor))
    ) AS DepartmentName;

	WITH RankedSalaries AS (
    SELECT 
        i.Ins_Name,
        i.Salary,
        d.Dept_Name,
        RANK() OVER (PARTITION BY d.Dept_Name ORDER BY i.Salary DESC) AS SalaryRank
    FROM 
        Instructor i
    JOIN 
      Department d ON i.Dept_Id = d.Dept_Id
    WHERE 
        i.Salary IS NOT NULL
)SELECT 
    Ins_Name,
    Salary,
    Dept_Name
FROM 
    RankedSalaries
WHERE 
    SalaryRank <= 2
ORDER BY 
    Dept_Name, Salary DESC

	--Write a query to select a random  student from each department.  “using one of Ranking Functions”
	WITH RandomStudents AS (
    SELECT 
        St_Id,
        St_Fname,
        St_Lname,
        Dept_Id,
        ROW_NUMBER() OVER (PARTITION BY Dept_Id ORDER BY NEWID()) AS RandomRank
    FROM 
        
		Student
)

SELECT 
    St_Id,
    St_Fname,
    St_Lname,
    Dept_Id
FROM 
    RandomStudents
WHERE 
    RandomRank = 1;


