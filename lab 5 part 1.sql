use iti

CREATE PROCEDURE ShowStudentCountPerDepartment
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.Dept_Name,
        (SELECT COUNT(*)
         FROM Student s
         WHERE s.Dept_Id = d.Dept_Id) AS StudentCount
    FROM 
        Department d;
END;


EXEC ShowStudentCountPerDepartment;

use Company_SD

CREATE PROCEDURE CheckEmployeesInProjectP1
AS
BEGIN
    

    DECLARE @EmployeeCount INT;

    -- Count the number of employees in project p1
    SELECT @EmployeeCount = COUNT(*)
    FROM Employee e
    WHERE e.Dno = (SELECT p.Pnumber FROM Project p WHERE Pname = 'p1');

    -- Check the count and print the appropriate message
    IF @EmployeeCount >= 3
    BEGIN
        select 'The number of employees in the project p1 is 3 or more';
    END
    ELSE
    BEGIN
        select 'The following employees work for the project p1:';
        
        -- Display the names of the employees
        SELECT 
            Fname, 
            Lname 
        FROM 
            Employee e
        WHERE 
            e.Dno = (SELECT Pnumber FROM Project WHERE Pname = 'p1');
    END
END;


EXEC CheckEmployeesInProjectP1;



CREATE PROCEDURE UpdateEmployeeInProject
    @OldEmpNo INT,
    @NewEmpNo INT,
    @ProjectNo INT
AS
BEGIN


    -- Check if the old employee is assigned to the project
    IF EXISTS (
        SELECT 1 
        FROM works_for 
        WHERE  essn = @OldEmpNo AND Pno = @ProjectNo
    )
    BEGIN
        -- Remove the old employee from the project
        DELETE FROM Works_for
        WHERE essn = @OldEmpNo AND Pno = @ProjectNo;

        -- Add the new employee to the project
        INSERT INTO works_for (essn, Pno)
        VALUES (@NewEmpNo, @ProjectNo);

        select 'Employee updated successfully.';
    END
    ELSE
    BEGIN
        select 'The old employee is not assigned to this project.';
    END
END;
EXEC UpdateEmployeeInProject @OldEmpNo = 101, @NewEmpNo = 102, @ProjectNo = 1;

CREATE TRIGGER PreventDepartmentInsert
ON Department
INSTEAD OF INSERT
AS
BEGIN
    select 'You cannot insert a new record in the Department table.';
    
END;

INSERT INTO Department (Dept_Name, Dept_Desc) VALUES ('New Department', 'Description');



CREATE TRIGGER PreventEmployeeInsertInMarch
ON Employee
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CurrentDate DATE = GETDATE();

    -- Check if the current month is March (month 3)
    IF MONTH(@CurrentDate) = 3
    BEGIN
        PRINT 'Insertion into the Employee table is not allowed in March.';
        -- Optionally, raise an error
        -- RAISERROR('Insertion into the Employee table is not allowed in March.', 16, 1);
    END
    ELSE
    BEGIN
        -- If it's not March, allow the insert operation
        INSERT INTO Company_SD.dbo.Employee (Fname, Lname, SSN, Bdate, Address, Sex, Salary, Superssn, Dno)
        SELECT Fname, Lname, SSN, Bdate, Address, Sex, Salary, Superssn, Dno
        FROM inserted;
    END
END;

INSERT INTO Company_SD.dbo.Employee (Fname, Lname, SSN, Bdate, Address, Sex, Salary, Superssn, Dno)
VALUES ('John', 'Doe', '123-45-6789', '1980-01-01', '123 Main St', 'M', 50000, NULL, 1);



CREATE TRIGGER InsteadOfDeleteStudent
ON Student
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @Username NVARCHAR(128) = SUSER_SNAME(); -- Get the server username
    DECLARE @CurrentDate DATETIME = GETDATE(); -- Get the current date and time
    DECLARE @KeyValue INT;

    -- Get the Key Value from the deleted row
    SELECT @KeyValue = St_Id FROM deleted;

    -- Insert a record into the StudentAudit table
    INSERT INTO StudentAudit (ServerUserName, Date, Note)
    VALUES (@Username, @CurrentDate, 
            @Username + ' tried to delete Row with Key=' + CAST(@KeyValue AS NVARCHAR(10)));
    
    -- Optionally, if you want to actually delete the row, you can uncomment the following line
    -- DELETE FROM ITI.dbo.Student WHERE St_Id = @KeyValue;
END;
