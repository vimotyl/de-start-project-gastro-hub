/* Задание 2 */
/* как изменяется средний чек для каждого заведения 
 * от года к году за все года за исключением 2023 года */

CREATE MATERIALIZED VIEW v_changes_avg_check_by_year AS
	
	/* считаем средний чек по каждому заведению
	 * отдельно по каждому году, кроме 2023 */
	WITH
	avg_of_year AS (
		SELECT
			restaurant_uuid,
			EXTRACT(YEAR FROM date) AS "year",
			ROUND(AVG(avg_check), 2) AS avg
		FROM cafe.sales
		WHERE EXTRACT(YEAR FROM date) <> 2023
		GROUP BY restaurant_uuid, "year"
		ORDER BY restaurant_uuid, "year"
	)
	/* получаем значение среднего чека предыдущего года
	 * для каждого ресторана и считаем изменение в % */
	SELECT
		a."year",
		r.name,
		r."type",
		a.avg AS avg_of_current_year,
		LAG(a.avg) OVER(PARTITION BY r.name 
			ORDER BY a."year") AS avg_of_previous_year,
		ROUND((1 - (LAG(a.avg) OVER(PARTITION BY r.name 
			ORDER BY a."year") / a.avg)) * 100, 2) 
				AS change_of_percent
	FROM avg_of_year a
	JOIN cafe.restaurants r USING (restaurant_uuid);

/* выводим полученный список из представления */
SELECT * FROM v_changes_avg_check_by_year;
