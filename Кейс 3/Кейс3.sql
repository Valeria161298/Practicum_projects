--Определить регионы с наибольшим количеством 
--зарегистрированных доноров.
SELECT region,
	   count(id) AS count_registration
FROM donorsearch.user_anon_data
WHERE registration_date IS NOT NULL 
GROUP BY region
ORDER BY count_registration  DESC 
LIMIT 10

--NULL	100574
--Россия, Москва	37819
--Россия, Санкт-Петербург	13137
--Россия, Татарстан, Казань	6610
--Украина, Киевская область, Киев	3541


-- Наибольшее число регистраций с неуказанным регионом - 100574.
-- На втором месте по количеству регистраций Москва - 37819 и на третьем месте Санкт-ППетербург - 13137.
--Это ожидаемый результат, так как в этих городах наибольшее число проживающих людей.

--Изучить динамику общего количества донаций в месяц за 2022 и 2023 годы.
SELECT date_trunc('month',donation_date)::date AS month_donation,
	   count(id) AS count_donation
FROM donorsearch.donation_anon
WHERE donation_date>='2022-01-01' AND donation_date<='2024-01-01'
GROUP BY date_trunc('month',donation_date)
ORDER BY month_donation 

--2022-01-01	1977		
--2022-02-01	2109
--2022-03-01	3002
--2022-04-01	3223
--2022-05-01	2414
--2022-06-01	2792
--2022-07-01	2836
--2022-08-01	2987
--2022-09-01	3089
--2022-10-01	3265
--2022-11-01	3156
--2022-12-01	3303
--2023-01-01	2795
--2023-02-01	3056
--2023-03-01	3523
--2023-04-01	2951
--2023-05-01	2568
--2023-06-01	2651
--2023-07-01	2276
--2023-08-01	2433
--2023-09-01	2240
--2023-10-01	2117
--2023-11-01	1509

--Количество донаций на начало 2022 года было 1977, а на конец - 3303, что говорит об общем увеличении числа донаций за год.
--А в 2023 году ситуация обратная. На начало 2023 года количество донаций составило 2795, а на ноябрь 2023 года - 1509, но скорее всего данные за ноябрь не полные и количество донаций в ноябре будет больше.


--Определить наиболее активных доноров в системе, 
--учитывая только данные о зарегистрированных и подтвержденных донациях.
--SELECT DISTINCT confirmed_donations
--FROM donorsearch.user_anon_data
SELECT id,
	   gender,
	   confirmed_donations AS count_donation
FROM donorsearch.user_anon_data
WHERE confirmed_donations>0 AND registration_date IS NOT NULL 
ORDER BY count_donation DESC
LIMIT 10

--235391	Мужской	361
--273317	Женский	257
--201521	Мужской	236
--211970	Мужской	236
--132946	Мужской	227

--Самым активным пользователем является мужчина с id 235 391, у него 361 донация, а на втором месте женщина с количеством донаций 257.

--Оценить, как система бонусов влияет на зарегистрированные в системе донации.

SELECT CASE WHEN user_bonus_count>0 THEN 'Получили бонусы'
		ELSE 'Не получили бонусы' END AS status_bonus,
		count(id) AS count_donations,
		round(AVG(confirmed_donations),1) AS avg_donations
		FROM (SELECT uad.id,
	    uad.confirmed_donations,
	    uab.user_bonus_count AS user_bonus_count
FROM donorsearch.user_anon_data AS uad LEFT JOIN donorsearch.user_anon_bonus AS uab  ON uad.id = uab.user_id )t1
GROUP BY status_bonus

--Не получили бонусы	256491	0.5
--Получили бонусы		21108	13.9

--Количество пользователей, который не полчили бонусы 256491. Активность пользователей с бонусами гораздо выше 13,9, когда актинвость пользователей без бонусов всего 0,5.
--Исследовать вовлечение новых доноров через 
--социальные сети. 
--Узнать, сколько по каким каналам пришло доноров, 
--и среднее количество донаций по каждому каналу.
SELECT CASE
	WHEN autho_vk THEN 'ВКонтакте'
	WHEN autho_yandex THEN 'Одноклассники'
	WHEN autho_tg THEN 'Телеграм'
	WHEN autho_yandex THEN 'Яндекс'
	WHEN autho_google THEN 'Google-аккаунт'
	ELSE 'Без привязки соцсетей'
END AS social,
	count(id) AS count_donors,
	round(avg(confirmed_donations),1) AS avg_donations
FROM donorsearch.user_anon_data
GROUP BY social 
ORDER BY count_donors desc

--ВКонтакте				127254	0.9
--Без привязки соцсетей	119628	0.7
--Google-аккаунт		14316	1.1
--Одноклассники			4157	1.8
--Телеграм				481		1.2

--Самый большой поток доноров пришел из чоциальный сети Вконтакте - 127254 пользователей,
--также большое количество пользователей - 119628 - не стали привязывать соцсети к своему профилю.
--Самыми активными являются пользователи, у которых к профилю привязаны соцсети Одноклассники, среднее количество их донаций - 1,8.

--Сравнить данные о планируемых донациях с фактическими данными, чтобы оценить эффективность планирования.
WITH active_donation AS (
SELECT user_id,
	   donation_date
FROM donorsearch.donation_anon),
planned_donation AS (
SELECT user_id,
	   donation_type,
	   donation_date
FROM donorsearch.donation_plan),
active_planned AS (
SELECT pd.user_id,
	   pd.donation_type,
	   pd.donation_date,
	   CASE WHEN ad.user_id IS NOT NULL THEN 1 ELSE 0 END AS actual_donation
FROM planned_donation AS pd LEFT JOIN active_donation AS ad ON pd.user_id = ad.user_id AND pd.donation_date =ad.donation_date)
SELECT donation_type,
	   count(user_id) AS count_planned_donation,
	   sum(actual_donation) AS count_actual_donation,
	   round(100*sum(actual_donation)::numeric/count(user_id),2) AS actual_rate
FROM active_planned
GROUP BY donation_type

--Безвозмездно	24362	5280	21.67
--Платно		3470	459		13.23

--Количество фактических донаций составляет 21% от количества запланируемых для типа донации "Безвозмездно".
--Количество фактических донаций составляет 13% от количества запланируемых для типа донации "Платно".
--Это говорит о том, что необходимо повышать вовлечённость доноров, особенно для типа донаций "платно"
