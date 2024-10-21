create database courseinstructore
use courseinstructore

create table course
(
cid int PRIMARY KEY identity(1,1) ,
cname varchar(50) not null,
duration int not null,
)

create Table Instructor
(
	Id int primary key identity(1,1 ),
	firstN nvarchar(20)NOT NULL,
	LastN nvarchar(20) NOT NULL,
	BD date,
	Salary int  CONSTRAINT S_Salary check(Salary Between 1000 and 5000) default 3000,
	overTime int unique NOT NULL,
	NetSalary as (Salary+OverTime),
	Age as (year(getdate())-year(BD)) ,
	hiredate date default getdate(),
	aaddress nvarchar(50) CHECK (aaddress IN ('cairo ', 'alex ')),
	
)

create Table Lab
(
    LId int primary key identity(1,1 ),
	Location nvarchar(50) NOT NULL,
	Capacity int check (capacity <20),
	CId int NOT NULL,
	foreign key (CId) references Course(CId)
)

create Table Instructor_Course
(   Id int NOT NULL,
    CId int NOT NULL,
	Foreign key (Id) references Instructor(Id),
	Foreign key (CId) references Course(CId),
	primary key (Id, CId)
)