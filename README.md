# 📊 World Tech Layoffs: Data Cleaning & Exploratory Data Analysis (EDA) in SQL

## 📌 Project Overview
This project demonstrates an end-to-end data pipeline using **MySQL**, involving comprehensive **Data Cleaning** and **Exploratory Data Analysis (EDA)** on a real-world dataset of global company layoffs. The goal is to transform messy, unstandardized raw data into a reliable format and extract actionable insights regarding layoff trends, time-series progression, and company rankings.

---

## 📂 Dataset Summary
- **Total Records:** 2,361 rows
- **Columns:** 9 features (`company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`)
- **Scope:** Global tech layoffs across various industries, funding stages, and geographic locations.

---

## 🛠️ Phase 1: Data Cleaning & Transformation

### 1. Removing Duplicates
- Created a staging table (`layoffs_staging`) to preserve raw data.
- Leveraged `ROW_NUMBER()` combined with `PARTITION BY` across all relevant columns to identify duplicate records.
- Built `layoffs_staging3` with an extra `row_num` column to safely filter out and `DELETE` rows where `row_num > 1`.

### 2. Standardizing Data
- **Text Trimming:** Cleaned leading and trailing whitespace from the `company` field using `TRIM()`.
- **String Unification:** Fixed trailing punctuation issues in geographic entries (e.g., standardizing `'United States.'` to `'United States'`).
- **Date Format Conversion:** Transformed text-based dates into native SQL `DATE` types (`YYYY-MM-DD`) using `STR_TO_DATE()` and updated column data types with `ALTER TABLE`.

### 3. Null & Missing Value Handling
- Identified null and blank entries across key attributes.
- Manually imputed missing `industry` data using specific contextual updates (e.g., populating `Carvana` as `'Transportation'`).
- Dropped the temporary `row_num` column after processing to clean up schema structure.

---

## 📈 Phase 2: Exploratory Data Analysis (EDA)

Key business questions answered through SQL queries:

1. **Max Extremes:** Identified maximum single-event layoffs (`MAX(total_laid_off)`) and workforce reduction rates (`MAX(percentage_laid_off)`).
2. **Yearly & Stage Impact:** Aggregated total layoffs grouped by `YEAR(date)` and investment `stage`.
3. **Company Severity:** Computed average percentage workforce reduction (`AVG(percentage_laid_off)`) per company.
4. **Monthly Rolling Total (Time Series Analysis):**
   Utilized CTEs and Window Functions (`SUM() OVER()`) to compute cumulative monthly layoff trends:
   ```sql
   WITH rolling_total AS (
       SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS TLO
       FROM layoffs_staging3
       WHERE `date` IS NOT NULL
       GROUP BY `month`
       ORDER BY 1 ASC 
   )
   SELECT `month`, TLO, SUM(TLO) OVER(ORDER BY `month`) AS Rolling_Total
   FROM rolling_total;
