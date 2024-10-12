-- * DATA PREPARATION *

-- creating database
Create Database Project;

Use Project;

select * from hr;


-- * DATA CLEANING *

-- renaming the ID column
Alter table hr
change column ï»¿id emp_ID varchar(20) null;

Describe hr;


-- checking for duplicates
select emp_ID, count(*)
from hr
group by emp_ID
having count(*) > 1;


-- checking the gender column
SELECT DISTINCT(gender)
FROM hr;

-- checking the race column
SELECT DISTINCT(race)
FROM hr;

-- checking for empty values in gender and race column
SELECT *
FROM hr
WHERE race IS NULL
 OR gender IS NULL;


Select birthdate from hr;

set sql_safe_updates = 0;


-- changing birth date data type
update hr
set birthdate = case
when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
else null
end;

Alter table hr
Modify column birthdate date;

select birthdate from hr;


-- changing hire date data type
Update hr
set hire_date = case
when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
else null
end;

Alter table hr
Modify column hire_date date;


-- changing term date data type
select termdate from hr;

Update hr
Set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;


SET sql_mode = 'ALLOW_INVALID_DATES';
	
Alter table hr
Modify column termdate date;


-- adding a new column age
Alter table hr
Add column age int; 

Update hr
Set age = timestampdiff(YEAR,birthdate,CURDATE());

Select age from hr;

-- checking minimum and maximum ages of employees
Select 
min(age) as youngest,
max(age) as oldest
from hr;

-- subtracting 100 years from birthdates which are greater than the current date
UPDATE hr
SET birthdate = DATE_SUB(birthdate, INTERVAL 100 YEAR)
WHERE birthdate >= '2060-01-01' AND birthdate < '2070-01-01';
		
select age from hr;



-- * DATA ANALYSIS *

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

Select gender, count(*) as count
from hr   
where termdate = '0000-00-00'
Group by gender;


-- 2. What is the race / ethnicity  breakdown of employees in the company?

Select race, count(*) as count
from hr
Where termdate = '0000-00-00'
Group by race
Order by count(*) DESC;


-- 3. What is the age distribution of employees in the company?

Select 
   Case 
	When age >= 22 And age <= 29 Then '22-29'
    When age >= 30 And age <= 39 Then '30-39'
    When age >= 40 And age <= 49 Then '40-49'
    When age >= 50 And age <= 59 Then '50-59'
    Else '60+'
    End as age_group, gender,
    count(*) as count
    from hr
    Where termdate = '0000-00-00'
    Group by age_group, gender
    Order by age_group, gender;
    
     
-- 4. How many employees work at headquarters versus remote locations?
   
   Select location, count(*) as count
   from hr 
   Where termdate = '0000-00-00'
   Group by location;
   
   
-- 5. What is the average length of employment of employees who have been terminated?
   
   Select 
   round(avg(datediff(termdate,hire_date))/365,0) as avg_length_employment
   from hr
   Where termdate <= curdate() and termdate <> '0000-00-00';
   
   
-- 6. How does the gender distribution vary across departments?
   
   Select department, gender, count(*) as count
   from hr 
   Where termdate = '0000-00-00'
   Group by department, gender
   Order by department;
   
   
-- 7. What is the distribution of job titles across the company? 

Select jobtitle, count(*) as count
from hr
Where termdate = '0000-00-00'
Group by jobtitle
Order by jobtitle DESC
limit 10; 

		
-- 8. What is the Turnover rate across departments ?

Select department,
    total_count,
    terminated_count,
    Concat(round(terminated_count/total_count*100, 0),'%') as termination_rate
From(
   Select department,
	count(*) as total_count,
    sum(Case When termdate <> '0000-00-00' and termdate <= curdate() Then 1 Else 0 End) as terminated_count
from hr
group by department
) as subquery
Order by termination_rate desc;  


-- 9. What is the Turnover rate across jobtitles ?

select jobtitle,
    total_count,
    terminated_count,
    Concat(round(terminated_count/total_count*100, 0),'%') as termination_rate
From(
   Select jobtitle,
	count(*) as total_count,
    sum(Case When termdate <> '0000-00-00' and termdate <= curdate() Then 1 Else 0 End) as terminated_count
from hr
group by jobtitle
) as subquery
Order by termination_rate desc;


-- 10. What is the distribution of employees across locations by state?

Select location_state, count(*) as count
from hr
Where termdate = '0000-00-00'
Group by location_state
Order by count DESC;   


-- 11. How have turnover rates changed each year?

SELECT 
    year,
    hires,
    terminations,
    round((terminations / hires) * 100, 2) AS turnover_rate_percent
FROM (
    SELECT 
        year(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    GROUP BY year(hire_date)
) AS subquery
ORDER BY year ASC;
      
      
-- 12. What is the tenure distribution for each department?

Select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
Where termdate <= curdate() and termdate <> '0000-00-00' 
Group by department;

        
-- 13. What is the Gender Turnover rate across departments ?

Select department,
     gender,
    total_count,
    terminated_count,
    Concat(round(terminated_count/total_count*100, 0),'%') as termination_rate
From(
   Select department,
   gender,
	count(*) as total_count,
    sum(Case When termdate <> '0000-00-00' and termdate <= curdate() Then 1 Else 0 End) as terminated_count
from hr
group by department, gender
) as subquery
Order by department ;   




