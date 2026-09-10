use bank_loan_analytics;
select*from loan_data;
select loan_id, count(*) as dublicate_rows
from loan_data 
group by loan_id
having dublicate_rows > 1;

CREATE TABLE loan_data_clean AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY loan_id
               ORDER BY customer_id
           ) AS rn
    FROM loan_data
) AS temp
WHERE rn = 1;

SELECT COUNT(*) AS total_rows
FROM loan_data_clean;

DESCRIBE loan_data_clean;
ALTER TABLE loan_data_clean
DROP COLUMN rn;

SELECT COUNT(*) AS total_rows
FROM loan_data_clean;

UPDATE loan_data_clean
SET
	gender = NULLIF(gender, ''),
    employment_type = NULLIF(employment_type, ''),
    default_status = NULLIF(default_status, '');
    
    SELECT
    SUM(TRIM(gender) = '') AS gender_blank,
    SUM(TRIM(employment_type) = '') AS employment_type_blank,
    SUM(TRIM(default_status) = '') AS default_status_blank
FROM loan_data_clean;

UPDATE loan_data_clean
SET
    gender = NULLIF(TRIM(gender), ''),
    employment_type = NULLIF(TRIM(employment_type), ''),
    default_status = NULLIF(TRIM(default_status), '');
    
    SELECT
    SUM(gender IS NULL) AS gender_null,
    SUM(employment_type IS NULL) AS employment_type_null,
    SUM(default_status IS NULL) AS default_status_null
FROM loan_data_clean;


select max(age) as min_age
from loan_data_clean;

select*from loan_data_clean;
select count(*) as total_rows
from loan_data_clean;
										-- Bank_loan_analysis --
 -- Q1 Total loan applications kitni hain?
 
 select count(*) as total_applications
 from loan_data_clean;
 
 -- Q2 Humein total loan amount kitna approve/apply hua hai, yani loan_amount ka overall total kitna hai.?
 
 select sum(loan_amount) as total_loan_amount
 from loan_data_clean;
 
 -- Q3 Hamare loan applications ka status-wise breakdown kya hai?
 
  select loan_status, count(*) as total_status
  from loan_data_clean
  group by loan_status;
  
  -- Q4 Customers sabse zyada kis type ka loan le rahe hain.?
  
  select loan_type, count(loan_type) as total_loan
  from loan_data_clean 
  group by loan_type
  order by total_loan desc;
  
  -- Q5 Average mein customers kitne amount ka loan le rahe hain.?
  select avg(loan_amount) as avg_amount
  from loan_data_clean;
  
  -- Q6 Kis city se sabse zyada loan applications aa rahi hain.?
  
  select city, count(*) as total_city
  from loan_data_clean
  group by city
  order by total_city desc
  limit 1;
  
 -- Q7 “Company ne total kitne amount ke loans approve kiye hain
 
 select sum(loan_amount) 
 from loan_data_clean 
 where loan_status = 'Approved';
 
 
 -- Q8 “Hamare customers ki average annual income kitni hai.?
 
 select  round(avg(annual_income))as avg_income
 from loan_data_clean;
 
 -- Q9 Kis employment type ke customers sabse zyada loans le rahe hain.?
 
 select employment_type, count(employment_type) as maximam_loan
 from loan_data_clean
 group by employment_type
 order by  maximam_loan desc;
 
 -- Q10 Loan applications mein Approved, Rejected, Pending aur Under Review ka percentage distribution kya hai?
 select loan_status, 
 count(loan_status) as total_status,
 round((count(loan_status) /3395) *100, 2)as total_percentage
 from loan_data_clean
 group by loan_status;
 
 -- Q11 Har loan type ki approval rate kya hai.?
 SELECT 
    loan_type,
    COUNT(*) AS total_applications,
    COUNT(CASE 
        WHEN loan_status = 'Approved' THEN 1 
    END) AS approved_applications,
    ROUND(
        COUNT(CASE 
            WHEN loan_status = 'Approved' THEN 1 
        END) / COUNT(*) * 100, 
        2
    ) AS approval_rate
FROM loan_data_clean
GROUP BY loan_type
ORDER BY approval_rate DESC;

--  Q12 Kis city mein average loan amount sabse zyada hai.?

select city ,  avg(loan_amount) as avg_amount
from loan_data_clean
group by city 
order by avg_amount desc
limit 1;

-- Q13 Income level ke according loan applications aur average loan amount mein kya difference hai.?

SELECT
    CASE
        WHEN annual_income < 500000 THEN 'Low'
        WHEN annual_income <= 1000000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    COUNT(*) AS total_applications,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM loan_data_clean
GROUP BY income_group
ORDER BY avg_loan_amount DESC;

-- Q14 Kaunse Top 5 cities mein default rate sabse zyada hai.?
select city,
     count(*) as total_applications,
 count(case
        when default_status = 'yes' then 1
          end) as total_stataus,
ROUND(
        COUNT(CASE 
            WHEN default_status = 'yes' THEN 1 
        END) / COUNT(*) * 100, 
        2
    ) AS default_rate
from loan_data_clean
group by  city
order by default_rate desc
limit 5;

-- Q15 Har loan type ke andar top 3 customers kaun hain jinhone sabse bada loan amount liya hai?
  
   with ranked_loans as(
        select 
            customer_id,
            customer_name,
            loan_type,
            loan_amount,
            ROW_NUMBER() OVER(
            PARTITION BY loan_type
            order by loan_amount desc
            )
               as loan_rank
         from loan_data_clean
   )
   select*
   from ranked_loans
   where loan_rank<=3
   order by loan_type, loan_amount;
   
   -- complete analysis--