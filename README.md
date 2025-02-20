# Strategic Workforce Analysis: An HR Data Exploration


Improving employee experience starts with **HR analytics**, which taps into the potential of the workforce. 

So, what exactly is HR analytics?

It’s the process of collecting workforce data and metrics to gain insights that inform better hiring and management decisions. 

In this article, I’ll explore HR analytics by examining workforce diversity and turnover rates using SQL.                               

Let’s dive into the project.

### TABLE OF CONTENTS

- [Project Overview](#project-overview)
- [Tools Used](#tools-used)
- [Data Preparation](#data-preparation)
- [Data Cleaning](#data-cleaning)
- [Analysis](#analysis)
- [Insights](#insights)
- [Recommendations](#recommendations)



### PROJECT OVERVIEW

In this project, I represent a fictional company focused on increasing employee diversity and improving retention. To achieve this, HR executives need a clear understanding of employee demographics and turnover patterns over the past years. These are the key questions and metrics they’re interested in:

1. What is the gender breakdown of Employees in the company?
2. What is the ethnicity breakdown of Employees in the company?
3. What is the age distribution of Employees in the company?
4. How many employees work at headquarters versus remote locations?
5. What is the average length of employment of employees who have been terminated?
6. How does the gender distribution vary across departments?
7. What is the distribution of job titles across the company?
8. Which department has the highest turnover rate?
9. What is the Turnover rate across jobtitles?
10. What is the distribution of employees across locations by state?
11. How have turnover rates changed each year?
12. What is the tenure distribution for each department?
13. What is the Gender Turnover rate across departments ?

Understanding the above metrics helps executives make data-driven decisions. 

### TOOLS USED

•	MySQL - Data Cleaning, Data Analysis

•	Power BI - Creating Reports

This report will show you my interpretations and queries for each question. I will also provide some insights and recommendations based on my analysis.


### DATA PREPARATION

I downloaded the dataset from Kaggle.com. The website has various fictitious datasets for data projects. I previewed the dataset in Excel Sheets to see the numbers of rows and columns. The dataset originally had 13 columns, 22214 rows, and consists of employees’ details from 2000 to 2020. I proceeded to import the data to MySQL by creating a database first, followed by creating a table for the data to get stored. 

<br>

Here is a quick look of the data:

![Screenshot 2025-02-20 202731](https://github.com/user-attachments/assets/551779be-8440-4bbe-92cc-89507461e259)


<br>

I created a table named **“hr”** within the project database. To do this, I utilized the **Table Data Import Wizard** feature, where I imported data from the Excel file. During the process, I mapped the columns from the Excel file to the corresponding fields in the table and assigned appropriate data types, such as VARCHAR for text fields and INT for numeric fields. This method helped me efficiently structure the data for subsequent analysis.


### DATA CLEANING

After importing my data, I started the cleaning process. Cleaning is an essential step in data analysis, it improves the quality of data and makes it suitable for use. I summarized the process below:

Firstly, I **renamed** the ï»¿id column to emp_ID.

``` sql
-- renaming the ID column
Alter table hr
change column ï»¿id emp_ID varchar(20) null;
```

I checked if there were any **duplicate** rows by using the ID column, as each employee should have a unique ID. No duplicates detected.

``` sql
-- checking for duplicates
select emp_ID, count(*)
from hr
group by emp_ID
having count(*) > 1;
```

Then I checked the race and gender columns for **nulls** and **unique values**. No empty row was found and all values were properly inputted

``` sql
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
```

Then, I changed the **date format** and **data types** of some columns using the queries below:

##### Birthdate

``` sql
-- changing birth date data type
update hr
set birthdate = case
when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
else null
end;

Alter table hr
Modify column birthdate date;
```

#### Hiredate

``` sql
-- changing hire date data type
Update hr
set hire_date = case
when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
else null
end;

Alter table hr
Modify column hire_date date;
```

#### Termdate

``` sql
-- changing term date data type
select termdate from hr;

Update hr
Set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

Alter table hr
Modify column termdate date;
```

I checked for empty values in all other columns. None was found except in the “term_date” column which means the employee is still in the company. To answer the question on age distribution, I created a new column **“age”** by subtracting the birth date from the current date.

``` sql
-- adding a new column age
Alter table hr
Add column age int; 

Update hr
Set age = timestampdiff(YEAR,birthdate,CURDATE());
```

I checked for the **minimum** and **maximum** ages of employees. And found that some values were negative with birth dates greater than today’s date for eg. 2060, so I assumed that there might have been an error in the dataset, where, instead of 1960 the birth year was written as 2060.

``` sql
-- checking minimum and maximum ages of employees
Select 
min(age) as youngest,
max(age) as oldest
from hr;
```

So, to address this issue I **subtracted 100 years** from such values:

``` sql
-- subtracting 100 years from birthdates which are greater than the current date
UPDATE hr
SET birthdate = DATE_SUB(birthdate, INTERVAL 100 YEAR)
WHERE birthdate >= '2060-01-01' AND birthdate < '2070-01-01';
```

I will be working with **22214 rows** and **14 columns** throughout my analysis.


### ANALYSIS

Now that I have the data ready, I can start writing queries to answer the questions and metrics that the HR executives are interested in.

#### Gender and Race Distribution
I calculated gender and race distribution by using the **GROUP BY** statement and **Count()** function to get the count of employees in each category.

``` sql
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
```

#### Age Distribution
I checked the minimum and maximum ages which are 22 and 58 respectively. Then, I used the **CASE expression** to create age groups and counted the employees in each group.

``` sql
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
```

#### Work Location
I used the **GROUP BY** statement to calculate the number of employees working remotely or in the headquarters.

``` sql
-- 4. How many employees work at headquarters versus remote locations?
   
   Select location, count(*) as count
   from hr 
   Where termdate = '0000-00-00'
   Group by location;
```

#### Average Employee Tenure
This is the average length of time an employee has worked for the company. I calculated the average tenure for all employees who have been terminated by finding the difference between termination and hire year.

``` sql 
-- 5. What is the average length of employment of employees who have been terminated?
   
   Select 
   round(avg(datediff(termdate,hire_date))/365,0) as avg_length_employment
   from hr
   Where termdate <= curdate() and termdate <> '0000-00-00';
   ```

#### Gender distribution across departments
I calculated the number of employees in each department by gender.

``` sql
-- 6. How does the gender distribution vary across departments?
   
   Select department, gender, count(*) as count
   from hr 
   Where termdate = '0000-00-00'
   Group by department, gender
   Order by department;
```

#### Job titles across the company
Here, I calculated the number of employees across job titles regardless of gender and limited it to the top 10.

``` sql
-- 7. What is the distribution of job titles across the company? 

Select jobtitle, count(*) as count
from hr
Where termdate = '0000-00-00'
Group by jobtitle
Order by jobtitle DESC
limit 10;
```

#### Turnover rate in each Department
Employee Turnover rate is the percentage of employees who have left the company over a certain period. I calculated the turnover rate for each department by dividing the number of terminated employees by the total number of employees. And then sorted the departments in descending order of turnover rate to identify the department with the highest turnover.

``` sql
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
```
	
#### Turnover rate per Job title
I calculated the turnover rate per title using queries similar to the above.

``` sql
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
```

#### Employee distribution by state
I calculated the number of employees in each state.

``` sql
-- 10. What is the distribution of employees across locations by state?

Select location_state, count(*) as count
from hr
Where termdate = '0000-00-00'
Group by location_state
Order by count DESC;
```

#### Turnover rates per year
I calculated the turnover rate per year using the queries below:

``` sql
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
```

#### Average Tenure for each department 
I calculated the average tenure of employees as per each department in the company.

``` sql
-- 12. What is the tenure distribution for each department?

Select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
Where termdate <= curdate() and termdate <> '0000-00-00' 
Group by department;
```

#### Gender Turnover rate across departments
I calculated the turnover rate of each gender for all the departments.	

``` sql
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
```


### INSIGHTS
I imported my data to **Power BI** for ease of communication. I grouped my findings under Employee Diversity and Turnover rate.

#### Employee Diversity

- The total number of **Current Employees** in the company is 18,285, out of which 13,710 work from the **headquarters**. This means that 25% of employees work **remotely**.

- 51.01% of people hired are **Male**, 46.24% **female**, and 2.75% **non-conforming**. The company has more employees between the ages of **30 to 49**.

- 14,788 employees (80.87%) live in **Ohio** while **Wisconsin** has the least employees. This correlates with the above insight since the headquarters is located in Ohio. 

- 5,214 of the employees hired are **White** and this is the race with the highest employees.

- The **Engineering department** has the most employees. The company hired more **Research Assistant II** followed by **Business Analyst** and **Human Resources Analyst II**.

![Employee Distribution report](https://github.com/user-attachments/assets/21db98c8-8f7e-4bf7-8b13-938e227b62d7)


#### Employee Turnover 

- The number of Employees that have **left** the company between 2020 and now is 3,929. The **turnover rate** is 12%, which means that 12% of all employees hired have left the company.

- The **average length of employment** of an employee in the company is **8** years.

- The year **2001** had the highest turnover rate with 18.09% while **2020** had the lowest turnover rate with 3.66% of employees hired leaving the company.

- The department and position with the highest turnover rate are **Auditing** and **Executive Secretary, Statistician III and Statistician IV** respectively. **17%** of the employees hired in the Auditing department and **50%** of the three positions left the department.

- **Non-conforming** employees have the highest turnover rate in **Research and Development** (20%), while **female** employees face notable turnover in **Legal** (15%) and Training (14%). **Male** turnover is relatively balanced across departments but peaks in **Auditing** (25%), indicating significant retention challenges in this department for male employees.



![Employee Turnover report](https://github.com/user-attachments/assets/b9f31bc6-d0a5-49f2-bd02-9289b0cbfead)



### RECOMMENDATIONS

Here are a few recommendations that will help the company to increase employee diversity and reduce the turnover rates

1.	Gender inclusiveness should be embraced especially for the non-conforming. Also, hire more people from the age of 20 to 29.
	
2.	Create an enabling environment for employees to work remotely, hence employing more people living outside of Ohio. Ask questions like can fewer employees work from the headquarters? Employees can also be allowed to work hybrid.
   
3.	The turnover rate has reduced over the years and this is impressive but there are positions with over 20% turnover rate. The company should have discussions with employees in those positions, conduct surveys to understand the factors influencing turnovers, and take actions.


### NOTE:
In the analysis, the job title **Office Assistant II** was excluded from the visualization of the top 10 highest turnover rates. This position had a **100% turnover rate**, as it was held by a single employee who left the company. To maintain the accuracy and relevance of the analysis, I focused on job titles with multiple employees, ensuring the results reflect meaningful trends rather than isolated cases.








