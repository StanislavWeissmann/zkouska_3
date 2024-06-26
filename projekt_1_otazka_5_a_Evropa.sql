
/*
* projekt: první projekt do Engeto Online Datová Akademie
* author: Stanislav Weissmann
* email: stana.ws@gmail.com
* discord: Standa W.
* 
* Výzkumná otázka 5 a dodatečný materiál k evropským zemím 
*/



/*
 *  Výzkumná otázka č. 5 -  Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 * Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
 * ve stejném nebo následujícím roce výraznějším růstem?
 */


-- pomocná tabulka vývoj GDP v ČR

CREATE TABLE t_pomocna_tabulka_vyvoj_GDP AS
SELECT
	sel_1.year_1,
	(sel_1.GDP  - sel_2.GDP)/sel_2.GDP * 100 AS index_GDP
FROM 
(SELECT																		--	současný rok
e.`year` AS year_1,
e. GDP 
FROM economies e
WHERE e.country = 'Czech Republic' AND e.GDP IS NOT NULL) 
	AS sel_1
JOIN
(SELECT																		-- předcházející rok
e_2.`year` AS year_2 ,
e_2. GDP 
FROM economies e_2 
WHERE e_2.country = 'Czech Republic' AND e_2.GDP IS NOT NULL) 
	AS sel_2
ON sel_1.year_1 = sel_2.year_2+1 ;


-- kontrola tabulky

SELECT * 
FROM t_pomocna_tabulka_vyvoj_gdp;


-- vývoj GDP, cen a mezd


SELECT														-- vývoj GDP, cen a mezd v daném (stejném) roce
	gdp.year_1 AS year_GDP,
	gdp.index_GDP AS growth_GDP_percent,
	zdr.year_1 AS year_price,
	zdr.index_cp AS growth_price_percent,
	mzdy.payroll_year AS wages_year,
	mzdy.index_mzdy AS growth_wages_percent
FROM t_pomocna_tabulka_vyvoj_GDP gdp
LEFT JOIN t_pomocna_tabulka_zdrazovani_celkem zdr
	ON gdp.year_1 = zdr.year_1 
LEFT JOIN t_pomocna_tabulka_mzdy mzdy 
	ON zdr.year_1 = mzdy.payroll_year
WHERE (gdp.index_GDP > 5 AND zdr.index_cp > 5) OR (gdp.index_GDP > 5 AND mzdy.index_mzdy > 5)
UNION
SELECT 															-- vývoj GDP v daném roce 
	gdp.year_1 AS year_GDP,										-- a cen a mezd v roce následujícím
	gdp.index_GDP AS growth_GDP_percent,
	zdr.year_1 AS year_price,
	zdr.index_cp AS growth_price_percent,
	mzdy.payroll_year AS wages_year,
	mzdy.index_mzdy AS growth_wages_percent
FROM t_pomocna_tabulka_vyvoj_GDP gdp
LEFT JOIN t_pomocna_tabulka_zdrazovani_celkem zdr
	ON gdp.year_1 = zdr.year_1 - 1
LEFT JOIN t_pomocna_tabulka_mzdy mzdy
	ON gdp.year_1 = mzdy.payroll_year - 1
WHERE (gdp.index_GDP > 5 AND zdr.index_cp > 5) 
OR (gdp.index_GDP > 5 AND mzdy.index_mzdy > 5);


-- růst GDP > 5 %

SELECT *													
FROM t_pomocna_tabulka_vyvoj_GDP gdp
WHERE (gdp.index_GDP > 5);




/*
 * Dodatečný materiál - tabulka s HDP, GINI koeficientem a populací dalších evropských států
 * ve stejném období jako primární přehled pro ČR.
 */

-- přípravný dotaz - ve kterých letech má ČR nenulové hodnoty

SELECT 
e.country,
e.`year` ,
e.GDP,
e.population,
e.gini
FROM economies e
WHERE country = 'Czech Republic' AND e.GDP IS NOT NULL AND e.population IS NOT NULL AND e.gini IS NOT NULL
ORDER BY `year` DESC ;


-- tabulka pro evropské země v letech 2004 až 2018

CREATE TABLE t_stanislav_weissmann_project_SQL_secondary_final AS
SELECT 
e.country ,
e.`year` ,
round(e.GDP) AS total_GDP,
e.population  ,
e.gini ,
round(e.GDP/e.population)  AS GDP_per_1_inhabitant
FROM economies e 
JOIN countries c 
ON e.country = c.country 
WHERE c.continent = 'Europe' AND e.`year` BETWEEN 2004 AND 2018 AND e.GDP IS NOT NULL AND e.population IS NOT NULL;


-- dotaz - uspořádání tabulky podle GDP na 1 obyvatele

SELECT *
FROM t_stanislav_weissmann_project_sql_secondary_final
ORDER BY GDP_per_1_inhabitant  DESC ;
