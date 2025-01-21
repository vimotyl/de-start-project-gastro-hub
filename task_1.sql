/* Задание 1.
 * Топ-3 заведения внутри каждого типа заведений 
 * по среднему чеку за все даты */

CREATE VIEW v_top_restaurants AS

	/* считаем средний чек
	 * по ресторанам за весь период */
	WITH
	avg_by_restaurant AS (
		SELECT
			restaurant_uuid,
			AVG(avg_check) AS avg_for_period
		FROM cafe.sales
		GROUP BY restaurant_uuid
	),
	/* нумеруем строки внутри каждого типа заведения
	 * по убыванию среднего чека */
	sorted_avg AS (
		SELECT
			r.name,
			r."type",
			avr.avg_for_period,
			ROW_NUMBER() OVER(PARTITION BY r."type" 
				ORDER BY avr.avg_for_period DESC) AS sequence_number
		FROM avg_by_restaurant avr
		JOIN cafe.restaurants r USING(restaurant_uuid)
	)
	/* в каждом типе заведения выбираем по 3 ресторана
	 * с максимальным средним чеком */
	SELECT
		name,
		"type" AS type_of_restaurant,
		ROUND(avg_for_period, 2) AS avg_check
	FROM sorted_avg
	WHERE sequence_number <= 3;

/* выводим полученный список из представления */
SELECT * FROM v_top_restaurants;
