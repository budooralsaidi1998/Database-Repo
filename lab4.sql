
use ITI

--. Create a scalar function that takes date and
--returns Month name of that da
set showplan 
create function dbo.GetMonthName(@date date)
returns varchar(20)
as
begin 
return datename(MONTH , @date)
end

SELECt dbo.GetMonthName('2024-10-22') AS MonthName



-- Create a multi-statements table-valued
--function that takes 2 integers and returns the values 
--between them.
create function dbo.GetTwoInteger(@first int , @second int)
returns @valuetable table (value int)
as
begin 
declare @currentfirst int = @first
while @currentfirst <= @second
begin
insert into @valuetable (value) values (@currentfirst)
set @currentfirst=@currentfirst+1
end
return
end

select * from dbo.GetTwoInteger(1,5)



-- Create inline function that takes
--Student No and returns Department 
--Name with Student full name

create function dbo.GetStudentDepartment(@StudentNo int)
returns TABLE
AS
return
(
    SELECT 
        CONCAT(s.St_Fname, ' ', s.St_Lname) AS FullName,
        d.Dept_Name
    FROM 
        Student s
    JOIN 
        Department d ON s.Dept_Id = d.Dept_Id
    WHERE 
        s.St_Id = @StudentNo
)

SELECT * FROM dbo.GetStudentDepartment(12)


--Create a scalar function that takes Student ID and returns a message to user 
--a. If first name and Last name are null then display 'First name & last name are null'
--b. If First name is null then display 'first name is null'
--c. If Last name is null then display 'last name is null'
--d. Else display 'First name & last name are not null'

CREATE FUNCTION dbo.CheckStudentNames
(
    @StudentID INT
)
returns varchar(100)
AS
BEGIN
--declare the variable
    declare @FirstName varchar(50);
    declare @LastName varchar(50);
    declare @Message varchar(100);

    -- Retrieve the first and last names for the given StudentID
    SELECT 
        @FirstName =s.St_Fname, 
        @LastName = s.St_Lname
    FROM 
        Student s
    where 
        s.St_Id = @StudentID

    -- Check conditions and set the message
    if @FirstName IS NULL AND @LastName IS NULL
    begin
        SET @Message = 'First name & last name are null';
    end
    else if @FirstName IS NULL
    begin
        SET @Message = 'First name is null';
    END
    ELSE IF @LastName IS NULL
    BEGIN
        SET @Message = 'Last name is null';
    END
    ELSE
    BEGIN
        SET @Message = 'First name & last name are not null';
    END

    RETURN @Message;
END;

SELECT dbo.CheckStudentNames(5) AS NameCheckMessage;


--5. Create inline function that takes integer which 
--represents manager ID and displays department 
--name, Manager Name and hiring date

CREATE FUNCTION dbo.GetManagerDetails
(
    @ManagerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.Dept_Name,
        m.Ins_Name,
        d.Manager_hiredate
    FROM 
        Instructor m
    JOIN 
        Department d ON m.Ins_Id = d.Dept_Manager
    WHERE 
        m.Ins_Id = @ManagerID
);

SELECT * 
FROM dbo.GetManagerDetails(1); 


--. Create multi-statements table-valued function that takes a string
 --If string='first name' returns student first name
--If string='last name' returns student last name 
--If string='full name' returns Full Name from student table
--Note: Use “ISNULL” function

create function dbo.GetStudentNameInfo
(
    @StudentID int,
    @NameType varchar(20)
)
returns @NameTable table (NameValue varchar(100))
as
begin
    declare @FirstName VARCHAR(50);
    declare @LastName VARCHAR(50);
    declare @FullName VARCHAR(100);

    -- Retrieve the first and last names for the given StudentID
    SELECT 
        @FirstName = ISNULL(s.St_Fname, 'No First Name'),
        @LastName = ISNULL(s.St_Lname, 'No Last Name')
    FROM 
        Student s
    WHERE 
        s.St_Id = @StudentID;

    -- Construct the full name
    set @FullName = CONCAT(@FirstName, ' ', @LastName);

    -- Check the NameType and insert the appropriate value into the return table
    if @NameType = 'first name'
    begin
        INSERT INTO @NameTable (NameValue) VALUES (@FirstName);
    END
    else if @NameType = 'last name'
    BEGIN
        INSERT INTO @NameTable (NameValue) VALUES (@LastName);
    END
    ELSE IF @NameType = 'full name'
    BEGIN
        INSERT INTO @NameTable (NameValue) VALUES (@FullName);
    END
    ELSE
    BEGIN
        insert INTO @NameTable (NameValue) VALUES ('Invalid Name Type');
    END

    RETURN;
END;

SELECT * 
FROM dbo.GetStudentNameInfo(1, 'full name'); 



use Company_SD
--. Create a cursor for Employee table that increases
--Employee salary by 10% if Salary <3000 
--and increases it by 20% if Salary >=3000. Use company DB

-- Declare variables for cursor
DECLARE @EmployeeID INT;
DECLARE @CurrentSalary DECIMAL(10, 2);
DECLARE @NewSalary DECIMAL(10, 2);

-- Declare the cursor
DECLARE SalaryCursor CURSOR FOR
SELECT e.SSN, Salary
FROM Employee e;

-- Open the cursor
OPEN SalaryCursor

-- Fetch the first row from the cursor
FETCH NEXT FROM SalaryCursor INTO @EmployeeID, @CurrentSalary;

-- Loop through the cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check the salary conditions and calculate the new salary
    IF @CurrentSalary < 3000
    BEGIN
        SET @NewSalary = @CurrentSalary * 1.10;  -- Increase by 10%
    END
    ELSE
    BEGIN
        SET @NewSalary = @CurrentSalary * 1.20;  -- Increase by 20%
    END

    -- Update the employee's salary0.

	
    UPDATE Employee 
    SET Salary = @NewSalary
    WHERE ssn = @EmployeeID;

    -- Fetch the next row from the cursor
    FETCH NEXT FROM SalaryCursor INTO @EmployeeID, @CurrentSalary;
END

-- Close and deallocate the cursor
CLOSE SalaryCursor;
DEALLOCATE SalaryCursor;



-- 8.Display Department name with its manager name using cursor. 
declare @department_name
declare @manager_name
declare @manager_id

declare departmentmanager cursor for
select d.Dname , e.Fname
from Departments d join Employee e
on d.MGRSSN = e.SSN

open departmentmanager

fetch next from departmentmanager into @department_name ,@manager_name

Declare C1 Cursor
for select DName, Fname
    from Departments join Employee
	on MGRSSN = SSN
for read only -- to display or    --update --> this show behavior of cursor
declare @D varchar(20),@E varchar(20)
open C1
Fetch C1 into @D,@E
while @@FETCH_STATUS=0  -->loop
    begin
        select @D,@E
        Fetch C1 into @D,@E --> counter ++
    end
close C1
Deallocate C1
--9--
declare c2 cursor
for select distinct Fname
    from Employee
    where Fname is not null
for read only
declare @name varchar(20),@all_names varchar(300)='' --> initial value
open c2
fetch c2 into @name
while @@FETCH_STATUS=0
    begin
        set @all_names=concat(@all_names,',',@name)
        fetch c2 into @name   --Next Row
    end
select @all_names
close c2
deallocate C2