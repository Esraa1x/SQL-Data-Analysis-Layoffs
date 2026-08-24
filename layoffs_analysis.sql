-- Step 1: Remove Duplicates
select *
from layoffs
;

create table layoffs_staging
like layoffs; 

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

select *, 
row_number() over(
PARTITION BY company, industry, total_laid_off,percentage_laid_off,`date`) as row_num
from layoffs_staging;

with duplicate_ctes as
(
select *, 
row_number() over(
PARTITION BY company, location, total_laid_off,percentage_laid_off,
`date`,stage, country,funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_ctes
where row_num>1
;

select *
from layoffs_staging
where company = 'Cazoo'
;


CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging3
select *, 
row_number() over(
PARTITION BY company, location, total_laid_off,percentage_laid_off,
`date`,stage, country,funds_raised_millions) as row_num
from layoffs_staging;

SET SQL_SAFE_UPDATES = 0;

delete 
from layoffs_staging3
where row_num >1;


select *
from layoffs_staging3
where row_num > 1 ;

-- Step 2: Standardize Data

update layoffs_staging3
set company =  trim(company);

SELECT @@autocommit;

select distinct country
from layoffs_staging3
where country like 'United%';

UPDATE layoffs_staging3
SET country = 'United States'
WHERE country IN ('United States.');

select country
from layoffs_staging3
where industry like 'Crypto%';

select `date`,
str_to_date( `date` , '%m/%d/%Y')
from layoffs_staging3;

update layoffs_staging3
set `date` = str_to_date( `date` , '%m/%d/%Y');

alter table layoffs_staging3
modify column `date` date;

-- Step 3: Handle Null Values

select *
from layoffs_staging3
where industry is null or industry = ''; -- I found 4 null values

SELECT *
FROM layoffs_staging3
WHERE company = 'Carvana';

select *
from layoffs_staging3
where total_laid_off is null
and percentage_laid_off is null;

UPDATE layoffs_staging3 -- here i repeat this code for all null industry value except one
SET industry = 'Transportation'
WHERE company = 'Carvana'
;

select industry
from layoffs_staging3
order by 1;

alter table layoffs_staging3
drop column row_num;

SELECT *
FROM layoffs_staging3;

-- Exploratory Data Analysis 

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging3;

select year(`date`) , sum(total_laid_off)
from layoffs_staging3
group by year(`date`)
order by 1 desc;

select stage , sum(total_laid_off)
from layoffs_staging3
group by stage
order by 1 desc;

select company , avg(percentage_laid_off)
from layoffs_staging3
group by company
order by 2 desc;

select substring(`date`,6,2) as `month`
from layoffs_staging3;

select substring(`date`,6,2) as `month` , sum(total_laid_off)
from layoffs_staging3
group by `month`;

select substring(`date`,1,7) as `month` , sum(total_laid_off)
from layoffs_staging3
where `date` is not null
group by `month`
order by 1 asc ;

select `date`
from layoffs_staging3;

with rolling_total as
(
select substring(`date`,1,7) as `month` , sum(total_laid_off) as TLO
from layoffs_staging3
where `date` is not null
group by `month`
order by 1 asc 
)
select `month` , TLO
,sum(TLO) over(order by `month`) as Roling_Total
from rolling_total;

select company , year(`date`), sum(total_laid_off)
from layoffs_staging3
group by company, year(`date`)
order by 1 asc;

with company_year (company , years , total_laid)as
(
select company , year(`date`), sum(total_laid_off)
from layoffs_staging3
group by company, year(`date`)
), company_year_rank as
(
select *, dense_rank() over(partition by years order by total_laid desc ) as ranking
from company_year
where years is not null
) select * 
from company_year_rank
where ranking <=5;


