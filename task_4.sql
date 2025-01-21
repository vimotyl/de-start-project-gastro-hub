/* Задание 4 */
/* пиццерия с самым большим количеством пицц в меню */

WITH
/* определяем заведения с типом "Пиццерия"
 * и формируем отдельный список пицц из меню
 * для каждого ресторана */
only_pizza AS (
	SELECT
		name,
		json_each(menu -> 'Пицца')
	FROM cafe.restaurants
	WHERE "type" = 'pizzeria'
),
/* считаем, сколько пицц указано в меню каждого ресторана */
number_of_pizzas_in_restaurant AS (
	SELECT
		name AS name_of_restaurant,
		COUNT(*) AS number_of_pizzas
	FROM only_pizza
	GROUP BY name
)
/* выводим все пиццерии с наибольшим количеством пицц в меню */
SELECT
	*
FROM number_of_pizzas_in_restaurant
WHERE number_of_pizzas = (
	SELECT MAX(number_of_pizzas)
	FROM number_of_pizzas_in_restaurant
);
