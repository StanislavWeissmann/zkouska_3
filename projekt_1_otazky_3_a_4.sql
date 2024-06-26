
/*
* projekt: první projekt do Engeto Online Datová Akademie
* author: Stanislav Weissmann
* email: stana.ws@gmail.com
* discord: Standa W.
* 
* Výzkumné otázky 3 a 4 
*/




/*
 * Výzkumná otázka č. 3 - Která kategorie potravin zdražuje nejpomaleji 
 * (je u ní nejnižší percentuální meziroční nárůst)?
 */


-- tabulka vývoje ročního pohybu cen podle jednotlivých kategorií - 2007 až 2018

CREATE TABLE t_zdrazovani_rocne AS 
SELECT 
	sel_1.category_code,
	cpc.name,
	sel_1.year_current,
	sel_1.avg_price_current,
	sel_2.year_previous,
	sel_2.avg_price_previous,
	round((sel_1.avg_price_current - sel_2.avg_price_previous)/sel_2.avg_price_previous * 100,2)  AS growth_price_percent
FROM 
(SELECT 																			--	současný rok
	cp.category_code,
	year(cp.date_from) AS year_current, 
	avg(cp.value) AS avg_price_current
FROM czechia_price cp 
GROUP BY
	cp.category_code,
	year(cp.date_from)) AS sel_1
JOIN
(SELECT     																		-- předcházející rok
	cp2.category_code,
	year(cp2.date_from) AS year_previous, 
	avg(cp2.value) AS avg_price_previous
FROM czechia_price cp2 
GROUP BY
	cp2.category_code,
	year(cp2.date_from)) AS sel_2
	ON sel_1.category_code = sel_2.category_code AND (sel_1.year_current = sel_2.year_previous+1)
JOIN czechia_price_category cpc 
	ON sel_1.category_code = cpc.code ;


-- kontrola vytvořené tabulky

SELECT * 
FROM t_zdrazovani_rocne tzr;


-- průměr průměrných cen jednotlivých kategorií 

SELECT 
	name,
	round(avg(growth_price_percent),2)
FROM t_zdrazovani_rocne tzr 
GROUP BY 
	name 
ORDER BY 
	avg(growth_price_percent) ASC;


-- kontrola vývoje průměrných cen cukru

SELECT *
FROM t_zdrazovani_rocne tzr
WHERE name = 'cukr krystalový';



/*
 * Výzkumná otázka č. 4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */


-- pomocná tabulka - vývoj mezd

CREATE TABLE t_pomocna_tabulka_mzdy AS
SELECT 
	sel_1.payroll_year,
	(avg_cp - avg_cp2)/avg_cp2 * 100 AS index_mzdy
FROM
(SELECT 																			-- současný rok
	cp.payroll_year, 
	avg(cp.value) AS avg_cp
FROM czechia_payroll cp 
WHERE cp.value_type_code = 5958 AND cp.calculation_code = 200
GROUP BY 
	cp.payroll_year) AS sel_1
JOIN
(SELECT 																			-- předcházející rok
	cp2.payroll_year, 
	avg(cp2.value) AS avg_cp2
FROM czechia_payroll cp2 
WHERE cp2.value_type_code = 5958 AND cp2.calculation_code = 200 
GROUP BY 
	cp2.payroll_year) AS sel_2 
	ON sel_1.payroll_year = sel_2.payroll_year + 1;


--- kontrola tabulky

SELECT *
FROM t_pomocna_tabulka_mzdy ;


-- pomocná tabulka - zdražování celkem

CREATE TABLE t_pomocna_tabulka_zdrazovani_celkem AS
SELECT
	sel_1.year_1,
	(avg_1  - avg_2)/avg_2 * 100 AS index_cp
FROM 
(SELECT 																			--	současný rok
	year(cp.date_from) AS year_1, 
	avg(cp.value) AS avg_1
FROM czechia_price cp 
GROUP BY
	year(cp.date_from)) AS sel_1
JOIN
(SELECT    																			-- předcházející rok 
	year(cp2.date_from) AS year_2, 
	avg(cp2.value) AS avg_2
FROM czechia_price cp2 
GROUP BY
	year(cp2.date_from)) AS sel_2
	ON sel_1.year_1 = sel_2.year_2+1;


-- kontrola tabulky

SELECT *
FROM t_pomocna_tabulka_zdrazovani_celkem ;


-- dotaz - rozdíl vývoje mezd a cen

SELECT 
	ptm.payroll_year AS at_year,
	round(ptm.index_mzdy,2) AS growth_wages_percent,
	round(ptz.index_cp, 2) AS growth_price_percent,
	round(ptz.index_cp - ptm.index_mzdy,2) AS difference
FROM t_pomocna_tabulka_mzdy ptm 
JOIN
t_pomocna_tabulka_zdrazovani_celkem ptz
ON ptm.payroll_year = ptz.year_1
ORDER BY difference DESC  ; 


