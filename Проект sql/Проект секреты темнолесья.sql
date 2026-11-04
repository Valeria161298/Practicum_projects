/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: 
 * Дата: 
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков

-- 1.1. Доля платящих пользователей по всем данным:
-- Напишите ваш запрос здесь
SELECT COUNT(id) AS count_users,--количсетво зарегистрированных игроков
	   SUM(payer) AS sum_paid,--количество платящих игроков
	   ROUND(AVG(payer),2) AS perc_paid_user--доля платящих игроков
FROM fantasy.users;
-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
-- Напишите ваш запрос здесь
SELECT r.race,
	   SUM(u.payer) AS count_paid,--количество платящих игроков расы
	   COUNT(u.id) AS count_users,--общее количество зарегистрированных игроков расы
	   round(SUM(u.payer)/COUNT(u.id)::numeric,2) AS perc_paid_user--доля платящих игроков среди всех зарегистрированных игроков расы
FROM fantasy.users AS u LEFT JOIN fantasy.race AS r USING (race_id)
GROUP BY r.race 
ORDER BY count_paid DESC ;
-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
-- Напишите ваш запрос здесь
SELECT COUNT(transaction_id) AS count_amount,--общее количество покупок
	   SUM(amount) AS sum_amount,--суммарная стоимость всех покупок
	   MIN(amount) AS min_amount,--минимальная стоимость покупки
	   MAX(amount) AS max_amount,--максимальная стоимость покупки
	   ROUND(AVG(amount::NUMERIC),1) AS avg_amount,--средняя стоимость покупок
	   PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY amount),--медиана
	   ROUND(STDDEV(amount::NUMERIC),0) AS stddev_amount--стандартное отклонение стоимости покупки
FROM fantasy.events ;
-- 2.2: Аномальные нулевые покупки:
-- Напишите ваш запрос здесь
	WITH amount_zero AS 
	(SELECT COUNT(transaction_id) AS count_zero--количество нулевых покупок
	FROM events e 
	WHERE amount=0),
	all_amount AS 
	(SELECT COUNT(transaction_id) AS count_all--общее количество покупок
	FROM events e )
SELECT count_zero,
	   count_zero/count_all::numeric AS perc_zero_amount--доля нулевых покупок
FROM amount_zero,all_amount;

        ,
-- 2.3: Популярные эпические предметы:
-- Напишите ваш запрос здесь
         WITH items AS --продажи каждого предмета
        (SELECT game_items,
        	    COUNT(DISTINCT id) AS unique_user,--количсетво клиентов, которые покупали предмет
        	    COUNT(transaction_id) AS count_transaction_item--количество продаж кажого прдемета
         FROM events e LEFT JOIN users u USING(id) LEFT JOIN items i USING(item_code)
     
         GROUP BY  game_items),
        	 all_transaction AS--все продажи
        (SELECT COUNT(transaction_id) AS count_transaction,--все продажи
        	    COUNT(DISTINCT id) AS all_user--количество уникальных клиентов
         FROM events e
         WHERE amount<>0)
        SELECT game_items,
        	   count_transaction_item,
        	   count_transaction_item/count_transaction::NUMERIC AS perc_transaction, --доля продаж каждого предмета от всех продаж
        	   unique_user/all_user::NUMERIC AS perc_user--доля игроков, которые покупали предмет от общего числа внутриигровых покуателей
        FROM items,all_transaction
        ORDER BY count_transaction_item DESC;
  --1. Результаты исследовательского анализа данных:
1.1. Какая доля платящих игроков характерна для всей игры и как раса персонажа влияет на изменение этого показателя?
Доля платящих игроков составляет 0.18, значит только 18% от общего количества зарегистрированных игроков пользуются платными услугами.
В разрезе рас доля платящих примерно одинаковая, из чего следует, что от расы не зависит использует игрок платные услуги или нет.
1.2. Сколько было совершено внутриигровых покупок и что можно сказать об их стоимости (минимум и максимум, есть ли различие между средним значением и медианой, какой разброс данных)?
Всего было совершено 1 307 678 покупок на общую стоимость 686 615 040 в валюте “райские лепестки”. Минимальная стоимость покупки равняются 0, что скорее всего является ошибкой. Разброс данных равняется максимальному значению стоимости покупки 486615.1. Среднее арифметическое равняется 525.7 и  отличается от медианной стоимости равной 74.86 , следовательно пользователей, потративших большую сумму на покупку меньше, чем пользователей, потративших небольшие суммы(если учитывать значение 0).
1.3. Есть ли аномальные покупки по стоимости? Если есть, то сколько их?
Количество покупок с нулевой стоимостью составляет 907, относительно общего количества покупок это не является весомым, но в расчетах лучше не учитывать эти покупки, так как из-за них неверные показатели среднее арифметическое и медиана. Процент аномальных покупок составляет 0,06 %.
1.4. Есть ли среди эпических предметов популярные, которые покупают чаще всего? 
.
Самым популярным предметом является “Book of Legends”, процент продаж этого предмета от общего числа продаж составляет 76%, а процент игроков, которые приобретают его - 88% от общего числа внутриигровых покупателей. Возможно, этот предмет улучшает скиллы для всех классов персонажей. На втором месте по популярности стоит “Bag of Holding”, составляет 20% от общего числа продаж.      	   

-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
-- Напишите ваш запрос здесь
   WITH all_users AS 
   (SELECT r.race,
   		  COUNT(DISTINCT u.id) AS count_users, --общее количество зарегистрированных игроков
   		  COUNT(DISTINCT e.id) AS count_transaction_users, --количество игроков, которые совершают внутриигровые покупки
  		  ROUND(COUNT(DISTINCT e.id)/COUNT(DISTINCT u.id)::NUMERIC,4) AS perc_transaction_users, --доля игроков, которые совершают внутриигровые покупки от от общего количества зарегистрированных игроков
  		  COUNT(DISTINCT CASE WHEN u.payer=1 AND e.id IS NOT NULL THEN u.id END) AS sum_users,--количество платящих игроков среди игроков, которые совершили внутриигровые покупки
  		  ROUND(COUNT(DISTINCT CASE WHEN u.payer=1 AND e.id IS NOT NULL THEN u.id END)/COUNT(DISTINCT CASE WHEN e.id IS NOT NULL THEN u.id END)::NUMERIC,3) AS perc_paid_users--доля  платящих игроков среди игроков, которые совершили внутриигровые покупки
 
  		  FROM users u  LEFT JOIN events e USING (id) LEFT JOIN race AS r USING (race_id)
  		     GROUP BY r.race),
  id_transaction AS 
  (SELECT id,
  		  COUNT(transaction_id) AS id_transaction,--количество покупок для каждого игрока
  		  SUM(amount) AS sum_amount -- общая стоимсоть покупок
  FROM events
  WHERE amount > 0 
  GROUP BY id)
  SELECT r.race,
  	     au.count_users,--общее количество зарегистрированных игроков
  	     au.count_transaction_users,--количество игроков, которые совершают внутриигровые покупки
  	     au.perc_transaction_users, --доля игроков, которые совершают внутриигровые покупки от от общего количества зарегистрированных игроков
  	     au.perc_paid_users,--доля платящих игроков среди игроков, которые совершили внутриигровые покупки
  		 ROUND(AVG(it.id_transaction)::NUMERIC,2) AS avg_transaction, --среднее количество покупок на одного игрока, совершившего внутриигровые покупки
  		 ROUND(AVG(it.sum_amount/it.id_transaction)::NUMERIC,2) AS avg_amount_user, -- средняя стоимость одной покупки на одного игрока, совершившего внутриигровые покупки
  		 ROUND((SUM(it.sum_amount)/au.count_transaction_users)::NUMERIC,2) AS avg_amount--средняя суммарная стоимость всех покупок на одного игрока, совершившего внутриигровые покупки 
  FROM id_transaction it LEFT JOIN users u ON it.id = u.id LEFT JOIN race r ON u.race_id = r.race_id LEFT JOIN all_users au ON r.race = au.race
  GROUP BY r.race,au.count_users,au.count_transaction_users,au.perc_transaction_users,au.perc_paid_users;
  	     
   	-- Среднее количество покупок на одного игра в разрезе рас отличается. Самое большое среднее количество покупок составляет в расах «Human» и «Angel». Следовательно, для этих рас необходима покупка большего количества предметов для успешного прохождения игры.
--Необходимо направить развитие и рекламу на то, чтобы выбор между расами для игроков падал на Angel или Human. Также можно сделать акцент рекламы на других предметах, кроме “Book of Legends”, чтобы выровнять процент продаж между предметами.
   	
   	
   
   
