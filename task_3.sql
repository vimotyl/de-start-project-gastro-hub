/* Задание 3
 * топ-3 заведения, где чаще всего 
 * менялся менеджер за весь период */

WITH
/* считаем, сколько раз менялся менеджер в каждом заведении */
number_of_change AS (
	SELECT
		restaurant_uuid,
		COUNT(manager_uuid) AS change_manager
	FROM cafe.restaurant_manager_work_dates
	GROUP BY restaurant_uuid
),
/* нумеруем строки по убыванию количества изменений в каждом ресторане:
 * - если несколько ресторанов имеют одинаковое количество
 * изменений, то присваиваем им одинаковый номер
 * - если два ресторана имеют номер 1, то следующий номер присваиваем 3,
 * то есть пропускаем второй номер */
sorted_number_of_change AS (
	SELECT
		r."name",
		n.change_manager,
		RANK() OVER (ORDER BY n.change_manager DESC) AS sequence_number
	FROM number_of_change n
	JOIN cafe.restaurants r USING (restaurant_uuid)
)
/* выводим все строки с номерами 1, 2, 3.
 * строк может получиться больше трех, если:
 * - три и более ресторана получили номер 1, выводим всех 
 * - один ресторан получил номер 1, два и более ресторана
 * получили номер 2, выводим всех 
 * - два ресторана получили номер 1, один и более ресторана
 * получили номер 3 (номер 2 пропустили), выводим всех */
SELECT
	name,
	change_manager
FROM sorted_number_of_change
WHERE sequence_number <= 3;
