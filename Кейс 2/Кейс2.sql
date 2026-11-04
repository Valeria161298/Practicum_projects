--Определим диапазон заработных плат в категориях "от" и "до", а также средние значения
SELECT MIN(salary_from) AS min_salary_from,--минимум заработной платы в категории "от"
	   MAX(salary_from) AS max_salary_from,--максимум заработной платы в категории "от"
	   MIN(salary_to) AS min_salary_to,--минимум заработной платы в категории "до"
	   MAX(salary_to) AS max_salary_to,--максимум заработной платы в категории "до"
	   round(AVG(salary_from),2) AS avg_salary_from,--средняя заработная плата в категории "от"
	   round(AVG(salary_to),2) AS avg_salary_to--средняя заработная плата в категории "до"
FROM public.parcing_table   

--Выявим регионы, в которых сосредоточено наибольшее число вакансий
SELECT area,
	   count(id) AS count_vacansy
FROM public.parcing_table
GROUP BY area
ORDER BY count_vacansy DESC
LIMIT 5

--Москва	1247
--Санкт-Петербург	181
--Екатеринбург	51
--Нижний Новгород	33
--Новосибирск	33

LIMIT 10
--Выявим компании, в которых сосредоточено наибольшее число вакансий
SELECT employer,
	   count(id) AS count_vacansy
FROM public.parcing_table
GROUP BY employer
ORDER BY count_vacansy DESC
LIMIT 10

--СБЕР	243
--WILDBERRIES	43
--Ozon	34
--Банк ВТБ (ПАО)	28
--Т1	26
--МАГНИТ, Розничная сеть	24
--МТС	22
--Okko	19
--Центральный банк Российской Федерации	16
--Правительство Москвы	15

-- преобладающие графики работ
SELECT schedule,
	   count(id) AS count_vacancy
FROM public.parcing_table
GROUP BY schedule
ORDER BY count_vacancy DESC 

--Полный день	1441
--Удаленная работа	310
--Гибкий график	41
--Сменный график	9

--Преобладающие типы занятости 
SELECT employment,
	   count(id) AS count_vacancy
FROM public.parcing_table
GROUP BY employment
ORDER BY count_vacancy DESC 

--Полная занятость	1764
--Частичная занятость	16
--Стажировка	16
--Проектная работа	5


-- Определение доли грейдов среди вакансий аналитиков

-- Чтобы это сделать, нам понадобится два запроса:

-- 1) Сначала нужно вычислить общее количество вакансий вручную:

SELECT COUNT(*) 
FROM public.parcing_table 
WHERE name LIKE '%Аналитик данных%' 
   OR name LIKE '%аналитик данных%'
   OR name LIKE '%Системный аналитик%'
   OR name LIKE '%системный аналитик%';

-- Результат - 1326. 
-- 2) Теперь используем это число чтобы рассчитать доли:

SELECT experience,
       COUNT(*) AS num_vacancies,
       ROUND(COUNT(*) * 100.0 / 1326, 2) AS percent_vacancies
FROM public.parcing_table
WHERE name LIKE '%Аналитик данных%' 
   OR name LIKE '%аналитик данных%'
   OR name LIKE '%Системный аналитик%'
   OR name LIKE '%системный аналитик%'
GROUP BY experience
ORDER BY percent_vacancies DESC;

--Junior+ (1-3 years)	854	64.40
--Middle (3-6 years)	345	26.02
--Junior (no experince)	121	9.13
--Senior (6+ years)	     6	0.45

--Основные работодатели, предлагаемые зарплаты и условия
SELECT employer,
	   round(AVG(salary_from ),2) AS avg_salary_from,
	   round(AVG(salary_to),2) AS avg_salary_to,
	   count(id) AS count_vacancy,
	   employment,
	   schedule
FROM public.parcing_table
WHERE name LIKE '%Аналитик данных%' OR name LIKE '%аналитик данных%' OR name LIKE '%Системный аналитик%' OR name LIKE '%системный аналитик%'
GROUP BY employer,
	   employment,
	   schedule
ORDER BY count_vacancy DESC
LIMIT 5

--СБЕР		      	117	
--Банк ВТБ (ПАО)	27	
--Ozon			    23	
--Т1			    17	
--Центральный банк Российской Федерации			15	


--Наиболее востребованные навыки для ky_skills_1
SELECT key_skills_1,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5

--Анализ данных	312
--SQL	161
--Документация	89
--MS SQL	87

SELECT key_skills_2,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5

--SQL	318
--Python	142
--Коммуникация	64
--Анализ данных	62

SELECT key_skills_3,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5 

--SQL	220
--Python	130
--Power BI	62
--Документация	61


SELECT key_skills_4,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5 
	
--Python	113
--SQL	61
--Работа с большим объемом информации	47
--Документация	47

SELECT soft_skills_1,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5 
	
--Документация	234
--Коммуникация	181
--Аналитическое мышление	109
--Проактивность	37

SELECT soft_skills_2,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5 

 --Документация	46
 --Аналитическое мышление	32
 --Проактивность	13
 --Переговоры	9

SELECT soft_skills_3,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5 
	
 --Аналитическое мышление	9
 --Проактивность	3
 --Переговоры	3
 --Креативность	3


SELECT soft_skills_4,
	   count(id) AS count_skills
FROM public.parcing_table
GROUP BY 1
ORDER BY count_skills DESC
LIMIT 5

 --Внимание к деталям	3
--Аналитическое мышление	2
--