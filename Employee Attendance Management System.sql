CREATE DATABASE EmployeeDB;

CREATE TABLE Departmen (
    dept_id INT PRIMARY KEY IDENTITY(1,1),
    dept_name VARCHAR(100) NOT NULL
);

select * from Departmen

CREATE TABLE Roles (
    role_id INT PRIMARY KEY IDENTITY(1,1),
    role_name VARCHAR(100) NOT NULL,
    base_salary DECIMAL(10,2)
);

select * from roles

CREATE TABLE Employe (
    emp_id INT PRIMARY KEY IDENTITY(1001,1),
    emp_name VARCHAR(100),
    gender VARCHAR(10),
    dept_id INT,
    role_id INT,
    hire_date DATE DEFAULT GETDATE(),
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (dept_id) REFERENCES Departmen(dept_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);



select * from Employe

CREATE TABLE Attendan (
    att_id INT PRIMARY KEY IDENTITY(1,1),
    emp_id INT FOREIGN KEY REFERENCES Employe(emp_id),
    check_in DATETIME,
    check_out DATETIME,
    work_hours AS DATEDIFF(HOUR, check_in, check_out),
    status VARCHAR(20)
);

select * from Attendan

-- Departments
INSERT INTO Departmen (dept_name)
VALUES ('HR'), ('IT'), ('Finance'), ('Sales'), ('Support');

select * from departmen

-- Roles
INSERT INTO Roles (role_name, base_salary)
VALUES ('Manager', 75000.00),
       ('Developer', 50000.00),
       ('Accountant', 45000.00),
       ('Sales Executive', 40000.00),
       ('Support Staff', 35000.00);

select * from roles

INSERT INTO Employe (emp_name, gender, dept_id, role_id)
VALUES 
('Amit Kumar', 'Male', 2, 2),
('Neha Sharma', 'Female', 1, 1),
('Ravi Patel', 'Male', 3, 3),
('Sneha Reddy', 'Female', 4, 4),
('Karan Mehta', 'Male', 5, 5);

select * from Employe

INSERT INTO Attendan (emp_id, check_in, check_out, status)
VALUES
(1001, '2025-10-01 09:05:00', '2025-10-01 17:30:00', 'Present'),
(1002, '2025-10-01 09:45:00', '2025-10-01 18:00:00', 'Late'),
(1003, '2025-10-01 08:55:00', '2025-10-01 17:10:00', 'Present'),
(1004, '2025-10-01 09:35:00', '2025-10-01 17:50:00', 'Late'),
(1005, '2025-10-01 09:10:00', '2025-10-01 17:20:00', 'Present');

select * from Attendan

Trigger to Auto-Set Check-In Status

CREATE TRIGGER trg_AttendanStatus
ON Attendan
AFTER INSERT
AS
BEGIN
    UPDATE Attendan
    SET status = CASE 
                    WHEN DATEPART(HOUR, check_in) >= 9 AND DATEPART(MINUTE, check_in) > 15 THEN 'Late'
                    ELSE 'Present'
                 END
    WHERE att_id IN (SELECT att_id FROM inserted);
END;

Function to Calculate Total Hours for a Given Employee and Month

CREATE FUNCTION fn_TotalWorkHours (@emp_id INT, @month INT, @year INT)
RETURNS INT
AS
BEGIN
    DECLARE @totalHours INT;
    SELECT @totalHours = SUM(work_hours)
    FROM Attendan
    WHERE emp_id = @emp_id 
      AND MONTH(check_in) = @month
      AND YEAR(check_in) = @year;

    RETURN ISNULL(@totalHours, 0);
END;

Usage:

SELECT dbo.fn_TotalWorkHours(1001, 10, 2025) AS TotalHours;

1️⃣ Monthly Attendance Summary

SELECT 
    e.emp_name,
    COUNT(a.att_id) AS total_days,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_days,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days
FROM Attendan a
JOIN Employe e ON a.emp_id = e.emp_id
WHERE MONTH(a.check_in) = 10 AND YEAR(a.check_in) = 2025
GROUP BY e.emp_name
ORDER BY late_days DESC;

Department-wise Attendance Count

SELECT 
    d.dept_name,
    COUNT(a.att_id) AS total_attendan
FROM Attendan a
JOIN Employe e ON a.emp_id = e.emp_id
JOIN Departmen d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total_attendan DESC;

3️⃣ Identify Late Comers

SELECT 
    e.emp_name,
    a.check_in,
    a.status
FROM Attendan a
JOIN Employe e ON a.emp_id = e.emp_id
WHERE a.status = 'Late';

4️⃣ Average Work Hours per Department

SELECT 
    d.dept_name,
    AVG(a.work_hours) AS avg_work_hours
FROM Attendan a
JOIN Employe e ON a.emp_id = e.emp_id
JOIN Departmen d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING AVG(a.work_hours) < 8; 





