use Company_SD
--⦁	Display the Department id, name and id and the name of its manager
SELECT  Dnum , Dname, SSN,Lname
from Employee e join Departments d on e.SSN = d.MGRSSN

--⦁	Display the name of the departments and the name of the projects under its control
SELECT   Dname, Pname
from Project p join Departments d on p.Dnum = d.Dnum

--⦁	Display the full data about all the dependence
--associated with the name of the employee 
--they depend on him/her.
select d.*,e.Fname
from Dependent d join Employee e on e.SSN = d.Essn

--⦁	Display the Id, name and location of the projects in Cairo or Alex city.

select p.Pnumber ,p.Pname , p.Plocation
from Project p
where p.City IN('Cairo', 'Alex ')

--⦁Display the Projects full data of the projects with a name 
--starts with "a" letter.
select *
from Project p
where p.Pname like'a%'

--⦁	display all the employees in department 30 whose salary
--from 1000 to 2000 LE monthly


select * 
from Employee 
where Dno=30 and Salary between 1000 and 2000
 
--7⦁	Retrieve the names of all employees in department 10 who works more than or equal10 hours per week on "AL Rabwah" project
select  Fname+''+Lname as fullNAme 

from Employee inner join Works_for on   SSN = ESSn  
   			  inner join Project   on	Pno=Pnumber	

where Pname = 'Al rabwah' and Hours>=10 and Dno =10

--8⦁	Find the names of the employees who directly supervised with Kamel Mohamed
select X.Fname+''+X.Lname as EmpName
from Employee X inner join Employee Y  on Y.SSN=X.Superssn
where y.Fname='kamel' and y.Lname='mohamed'

--9⦁	Retrieve the names of all employees and the names of the projects they are working on, sorted by the project name.

select Fname ,Pname 
from Employee inner join Works_for on ESSn = SSN
              inner join project   on  Pno = Pnumber
order by Pname

--10⦁	For each project located in Cairo City , find the project number, the controlling department name ,the department manager last name ,address and birthdate.
select Pnumber , Dname, Lname, Address, Bdate
from employee inner join Departments D on ssn = MGRSSN
              inner join Project P     on P.Dnum = D.Dnum 
where city = 'cairo'

--11⦁	Display All Data of the managers
select M.* 
from employee m inner join Departments d on m.SSN = d.MGRSSN

--12⦁	Display All Employees data and the data of their dependents even if they have no dependents
select * 
from employee e left join Dependent d on e.ssn=d.ESSN
