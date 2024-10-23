use Company_SD

-- The name and the gender of the dependence that's gender is 
--Female and depending on Female Employee
select e.Fname,e.Sex
from Employee e
where e.Sex='F'
Union all
select d.Dependent_name,d.Sex
from Dependent d
where d.Sex='F'

-- And the male dependence that depends on Male Employee.

select e.Fname,e.Sex
from Employee e
where e.Sex='M'
Union all
select d.Dependent_name,d.Sex
from Dependent d
where d.Sex='M'

--For each project, list the project name and the total hours per week (for all employees) spent on that project


select p.Pname,(select sum(w.Hours)
                 from Works_for w 
				 where p.Pnumber = w.Pno) as totalhours
from Project p




--Display the data of the department 
--which has the smallest employee ID over all employees' ID.

SELECT *
FROM departments d
WHERE d.Dnum = (
    SELECT e.Dno
    FROM employee e
    WHERE e.SSN = (SELECT MIN(r.SSN) FROM employee r)
)

--⦁	For each department, retrieve the department name and the max, 
--min and average salary of its employees.
select  d.Dname,
(select max(e.Salary)  from Employee e where e.Dno=d.Dnum ) as msalary ,
(select MIN(salary)   from Employee e where e.Dno=d.Dnum) as minsalary,
(select AVG(salary)  from Employee e where e.Dno=d.Dnum)as avsalary
from Departments d

--⦁	List the full name of all managers who have no dependents.

select e.Fname+''+e.Lname as fullName
from employee e
where e.ssn IS NOT NULL
except
select  e.Fname+''+e.Lname as fullName
from employee e join Dependent d ON d.essn=e.SSN

--⦁	For each department-- if its average salary is less than the average salary of all employees-- display its number,
--name and number of its employees.
SELECT 
    d.Dnum,
    d.Dname,
    (SELECT COUNT(*) FROM employee e WHERE e.Dno = d.Dnum) AS number_of_employees
FROM 
    departments d
WHERE 
    (SELECT AVG(salary) FROM employee e WHERE e.Dno = d.Dnum) < 
    (SELECT AVG(salary) FROM employee);

--⦁	Retrieve a list of employees names and the projects names 
--they are working on ordered by department number and within each department, 
--ordered alphabetically by last name, first name

select e.Fname+''+e.Lname as employee_name,
                                (select p.Pname
								from Project p join Departments d on  p.Dnum=d.Dnum
								where e.Dno=d.Dnum
								)as project_name
from employee e 
order by e.Fname,e.Lname

--⦁	Try to get the max 2 salaries using subquery

SELECT MAX(salary) AS second_highest_salary
FROM employee
WHERE salary < (SELECT MAX(salary) FROM employee);

--⦁	Get the full name of employees that is
--similar to any dependent name
select e.Fname+''+e.Lname as full_name
from employee e
where e.SSN in (   select d.ESSN
                  from Dependent d
				  where e.SSN = d.ESSN)


--⦁	⦁	Display the employee number and name if at least one of them have dependents (use exists keyword) self-search.
SELECT 
    e.SSN,
    CONCAT(e.Fname, ' ', e.Lname) AS employee_name
FROM 
    employee e
WHERE 
    EXISTS (
        SELECT 1
        FROM dependent d
        WHERE d.ESSN = e.SSN
    );

	--⦁	In the department table insert new department
	--called "DEPT IT" , with id 100, employee with 
	--SSN = 112233 as a manager for this department. 
	--The start date for this manager is '1-11-2006'

	INSERT INTO Departments (Dnum, Dname, MGRSSN,[MGRStart Date])
VALUES (100, 'DEPT IT', 112233, '2006-11-01')

--⦁	Do what is required if you know that :
--Mrs.Noha Mohamed(SSN=968574)  moved to be 
--the manager of the new department (id = 100), 
--and they give you(your SSN =102672) her position 
--(Dept. 20 manager)

--⦁	First try to update her record in the department table

UPDATE Departments
SET MGRSSN = 968574
WHERE Dnum = 100;

UPDATE Departments
SET MGRSSN = 102672
WHERE Dnum = 20;

UPDATE employee
SET Superssn = 102672
WHERE ssn = 102660;  

--Unfortunately the company ended the contract with 
--Mr. Kamel Mohamed (SSN=223344) so tr
--to delete his data from your database in case you
--know that you will be temporarily in his position.

DELETE FROM employee
WHERE SSN = 223344;

--⦁	Try to update all salaries of employees
--who work in Project ‘Al Rabwah’ by 30%

UPDATE employee
SET salary = salary * 1.30
WHERE ssn IN (
  .....
)