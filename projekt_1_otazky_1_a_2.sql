
/*
* projekt: první projekt do Engeto Online Datová Akademie
* author: Stanislav Weissmann
* email: stana.ws@gmail.com
* discord: Standa W.
* 
* Výzkumné otázky 1 a 2 
*/




/*
 * Výzkumná otázka č. 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 */



-- průměrná mzda na přepočtený a fyzický počet zaměstnanců - ukázka pro odvětví A a rok 2000

SELECT 
	industry_branch_code, 
	calculation_code ,
	payroll_year ,
	payroll_quarter,
	value 
FROM czechia_payroll cp 
WHERE value_type_code = 5958 AND industry_branch_code = 'A' AND payroll_year = 2000
ORDER BY 
	payroll_quarter ;


-- vývoj ve všech odvětvích

SELECT
	cpib.*,
	sel_1.year_current,
	sel_1.avg_wages,
	sel_2.year_previous,
	sel_2.avg_wages,
	round ((sel_1.avg_wages - sel_2.avg_wages)/sel_2.avg_wages * 100, 2) AS wages_growth_percent
FROM			
(SELECT 															-- současný rok
	cp.industry_branch_code, 
	cp.payroll_year AS year_current, 
	avg(cp.value) AS avg_wages
FROM czechia_payroll cp 
WHERE cp.value_type_code = 5958 AND cp.calculation_code = 200 AND cp.industry_branch_code IS NOT NULL 
GROUP BY 
	cp.industry_branch_code ,
	cp.payroll_year) AS sel_1
JOIN
(SELECT 															-- předcházející rok	
	cp2.industry_branch_code, 
	cp2.payroll_year AS year_previous, 
	avg(cp2.value) AS avg_wages
FROM czechia_payroll cp2 
WHERE cp2.value_type_code = 5958 AND cp2.calculation_code = 200 AND cp2.industry_branch_code IS NOT NULL 
GROUP BY 
	cp2.industry_branch_code ,
	cp2.payroll_year) AS sel_2 
	ON sel_1.year_current = sel_2.year_previous + 1 AND 
	sel_1.industry_branch_code = sel_2.industry_branch_code	
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON sel_1.industry_branch_code = cpib.code;


-- případy, kdy pokles mezd 

SELECT
	cpib.name,
	sel_1.year_current,
	sel_1.avg_wages,
	sel_2.year_previous,
	sel_2.avg_wages,
	round ((sel_1.avg_wages - sel_2.avg_wages)/sel_2.avg_wages * 100, 2) AS wages_growth_percent
FROM
(SELECT 																--	současný rok
	cp.industry_branch_code, 
	cp.payroll_year AS year_current, 
	avg(cp.value) AS avg_wages
FROM czechia_payroll cp 
WHERE cp.value_type_code = 5958 AND cp.calculation_code = 200 AND cp.industry_branch_code IS NOT NULL 
GROUP BY 
	cp.industry_branch_code ,
	cp.payroll_year) AS sel_1	
JOIN
(SELECT 																-- předcházející rok
	cp2.industry_branch_code, 
	cp2.payroll_year AS year_previous, 
	avg(cp2.value) AS avg_wages
FROM czechia_payroll cp2 
WHERE cp2.value_type_code = 5958 AND cp2.calculation_code = 200 AND cp2.industry_branch_code IS NOT NULL 
GROUP BY 
	cp2.industry_branch_code ,
	cp2.payroll_year) AS sel_2 
	ON sel_1.year_current = sel_2.year_previous + 1 AND 
	sel_1.industry_branch_code = sel_2.industry_branch_code
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON sel_1.industry_branch_code = cpib.code
WHERE (sel_1.avg_wages - sel_2.avg_wages)/sel_2.avg_wages < 0			--	pokles mezd
ORDER BY
(sel_1.avg_wages - sel_2.avg_wages)/sel_2.avg_wages * 100 ASC;




/*
 * Výzkumná otázka č. 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první 
 * a poslední srovnatelné období v dostupných datech cen a mezd?
 */



-- pomocný dotaz na vyhledání kategorie pro chléb a mléko 

SELECT *    
FROM czechia_price_category cpc
ORDER BY name DESC ;

-- 111301	Chléb konzumní kmínový	1.0	kg
-- 114201	Mléko polotučné pasterované	1.0	l


-- pomocný dotaz na průměrné ceny - region_code IS NOT NULL, výsledek = 50,4483 CZK

SELECT 
	avg(value)
FROM czechia_price cp 
WHERE region_code IS NOT NULL ; 

-- pomocný dotaz na průměrné ceny - bez filtru na region_code, výsledek = 50,4484 CZK

SELECT 
	avg(value)
FROM czechia_price cp ;


-- dotaz na mléko a chléb v r. 2006 a 2018

SELECT 
	cpc.name,
	sel_1.at_year,
	round(sel_1.avg_wage,2) AS avg_wage,
	round(sel_2.avg_price,2) AS avg_price,
	round(avg_wage/avg_price,0) AS quantity
FROM 
(SELECT   													 		-- průměrné mzdy 2006 a 2018
	payroll_year AS at_year,
	avg(value) AS avg_wage
	FROM czechia_payroll cp
WHERE value_type_code = 5958 AND payroll_year IN (2006, 2018) AND calculation_code = 200
GROUP BY payroll_year) AS sel_1
JOIN
(SELECT    															-- průměrné ceny mléka a chleba 2006 a 2018
	category_code, 
	year(date_from) AS at_year,
	avg(value) AS avg_price
FROM czechia_price cp
WHERE category_code  IN(111301, 114201) AND year(date_from) IN (2006, 2018) AND region_code IS NOT NULL
GROUP BY 
	category_code , 
	year(date_from)) AS sel_2
	ON sel_1.at_year = sel_2.at_year 
JOIN     															-- označení mléka a chleba
czechia_price_category cpc 
	ON sel_2.category_code = cpc.code ;


