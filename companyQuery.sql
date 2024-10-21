use Company_SD

--1⦁	Display all the employees Data
select * from Employee

--2⦁	Display the employee First name, last name, Salary and Department number.
select fname, lname, salary, Dno from Employee

--3⦁	Display all the projects names, locations and the department which is responsible about it.
select Pname, Plocation, Dnum from Project

--4⦁	If you know that the company policy is to pay an annual commission for each employee with specific percent equals 10% of his/her annual salary
--.Display each employee full name and his annual commission in an ANNUAL COMM column (alias).
select Fname+''+Lname as full_name , Salary*12*10/100 as ANNUAL_Comm  from Employee


--⦁	Display the employees Id, name who earns more than 1000 LE monthly.

select  SSN ,Fname+''+Lname as fullname
from Employee
where Salary>1000

--⦁	Display the employees Id, name who earns more than 10000 LE annually.
select  SSN ,Fname+''+Lname as fullname
from Employee
where Salary>10000

--⦁	Display the names and salaries of the female employees 
select Fname+''+Lname as fullname , Salary
from Employee
where Sex='F'

--⦁	Display each department id, name which managed by a manager with id equals 968574

select  SSN ,Fname+''+Lname as fullname
from Employee
where Superssn=968574

--⦁	Dispaly the ids, names and locations of  the pojects which controled with department 10

select Pname, Plocation, Pnumber 
from Project
where Dnum=10

--⦁	Insert your personal data to the employee table as a new employee in department number 30, SSN = 102672, Superssn = 112233, salary=3000.
insert into Employee (Fname, Lname, SSN, Bdate,  Sex, Salary, Superssn, Dno)
values('budoor', 'rashid', 102672, 17-02-1998,  'F', 250, 112233, 30)

--⦁	Insert another employee with personal data your friend as new employee
--in department number 30, SSN = 102660, but don’t enter any value for salary or supervisor number to him.
insert into Employee (Fname, Lname, SSN, Bdate, Sex, Salary, Superssn, Dno)
values('said', 'saif', 102660, 15-12-1996, 'M', null, null,30)

--⦁	Upgrade your salary by 20 % of its last value
update Employee
set Salary = Salary*0.2
where SSN=102672