/* Задание 7 */
/* изменить номер телефона менеджеров */

/* блокируем таблицу managers в режиме EXCLUSIVE,
 * чтобы другие транзации не смогли вносить
 * изменения в таблицу и наше обновление прошло успешно
 * 
 * при этом другие транзакции смогут читать данные
 * из таблицы и они будут актуальными, так как старый
 * номер телефона менеджера по-прежнему остался актуальным */

BEGIN;

/* блокируем таблицу managers */
LOCK TABLE cafe.managers IN EXCLUSIVE MODE;

/* добавляем поле all_phones - текстовый массив,
 * в котором будем хранить старый и новый номера телефонов */
ALTER TABLE cafe.managers
	ADD COLUMN all_phones text[];



WITH
/* - генерируем новый номер телефона, оканчивающийся
 * на уникальное число для каждого менеджера, начиная с номера 100
 * - добавляем новый и старый номер в массив */
generate_phones AS (
	SELECT
		manager_uuid,
		STRING_TO_ARRAY('8-800-2500-' || 
						99 + COUNT(manager_uuid) OVER(ORDER BY name) ||
						', ' || phone,
						', ') AS array_of_phones
	FROM cafe.managers
)
/* загружаем массив с номерами телефонов в таблицу managers */
UPDATE cafe.managers m
SET all_phones = array_of_phones
FROM generate_phones g
WHERE m.manager_uuid = g.manager_uuid;

/* удаляем поле phone со старым номером телефона */
ALTER TABLE cafe.managers
	DROP COLUMN phone;

COMMIT;
