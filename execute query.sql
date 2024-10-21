use Company_SD

select Pname,SUM(Hours)
from Project join Works_for
ON Pno = Pnumber
group by Pname 

select Dname,max(salary)as mmaxsalary ,min(salary) as minsalary,avg(salary) as avgsalary
from Departments
join Employee on Dnum = Dno
group by Dname