/* Задание 5 */
/* самая дорогая пицца для каждой пиццерии */

WITH
/* определяем заведения с типом "Пиццерия"
 * и формируем отдельный список пицц и их стомости
 * в меню для каждого ресторана */
only_pizza AS (
	SELECT
		name,
		(json_each_text(menu -> 'Пицца')).key AS pizza,
		(json_each_text(menu -> 'Пицца')).value::integer AS price
	FROM cafe.restaurants
	WHERE "type" = 'pizzeria'
),
/* ранжируем пиццы по стоимости в порядке убывания
 * отдельно для каждой пиццерии */
cost_of_pizza AS (
	SELECT
		name AS name_of_restaurant,
		pizza,
		price,
		DENSE_RANK() OVER (PARTITION BY name ORDER BY price DESC) AS place
	FROM only_pizza
)
/* выводим самую дорогую пиццу для каждого заведения */
SELECT
	name_of_restaurant,
	'Пицца' AS type_of_food,
	pizza,
	price
FROM cost_of_pizza
WHERE place = 1;
