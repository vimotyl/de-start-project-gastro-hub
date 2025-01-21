/* ЗАПОЛНЕНИЕ ТАБЛИЦ ДАННЫМИ ИЗ ДАМПА */

/* заполнение таблицы restaurants
 * - название и тип заведения получаем из raw_data.sales
 * - меню каждого заведения получаем из raw_data.menu
 * - uuid генерируем */
WITH
all_restaurants AS (
	SELECT
		DISTINCT
		cafe_name,
		type	
	FROM raw_data.sales
)
INSERT INTO cafe.restaurants (name, type, menu)
(
	SELECT
		a.cafe_name,
		a.type::cafe.restaurant_type,
		s.menu
	FROM raw_data.menu s
	JOIN all_restaurants a USING (cafe_name)
);




/* заполнение таблицы managers
 * шаг 1 - привели номер телефона к единому формату
 * и сохранили его в отдельном поле clear_phone
 * в таблице raw_data.sales */

ALTER TABLE raw_data.sales ADD COLUMN clear_phone TEXT;

/* удаляем все символы, кроме цифр, +7 меняем на 8 */
UPDATE raw_data.sales
SET clear_phone = 
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(manager_phone, ' ', ''),
						'(',
						''
						), 
					')',
					''
					), 
				'-',
				''
			),
			'+7',
			'8'
		);

/* добавляем пробелы и скобки на нужные позиции */
UPDATE raw_data.sales
SET clear_phone = 
		SUBSTR(clear_phone, 1, 1) || ' (' || SUBSTR(clear_phone, 2, 3) || ') ' 
			|| SUBSTR(clear_phone, 5, 3) || '-' || SUBSTR(clear_phone, 8, 2) || '-' 
				|| SUBSTR(clear_phone, 10, 2);

			
/* шаг 2 - заполнение таблицы managers
 * - обновленный номер телефона и имя менеджера
 * получаем из raw_data.sales,
 * - uuid генерируем */
INSERT INTO cafe.managers (name, phone)
(
	SELECT
		DISTINCT
		manager,
		clear_phone
	FROM raw_data.sales
);



	
/* заполнение таблицы restaurant_manager_work_dates
 * - имя менеджера, название заведения, дату начала работы (мин дата)
 * дату окончания работы (макс дата) получаем из raw_data.menu
 * - uuid ресторана получаем из уже заполненной таблицы restaurants 
 * - uuid менеджера получаем из уже заполненной таблицы managers */
WITH
manager_dates AS (
	SELECT
		manager,
		cafe_name,
		MIN(report_date) AS min_date,
		MAX(report_date) AS max_date
	FROM raw_data.sales
	GROUP BY manager, cafe_name
)
INSERT INTO cafe.restaurant_manager_work_dates (restaurant_uuid, manager_uuid, employment_date, dismissal_date)
(
	SELECT
		r.restaurant_uuid,
		m.manager_uuid,
		md.min_date,
		md.max_date
	FROM manager_dates md
	LEFT JOIN cafe.managers m ON m.name = md.manager
	LEFT JOIN cafe.restaurants r ON r.name = md.cafe_name
);




/* заполнение таблицы sales
 * - дату, средний чек получаем из raw_data.sales
 * - uuid ресторана получаем из уже заполненной таблицы restaurants */
INSERT INTO cafe.sales (date, restaurant_uuid, avg_check)
(
	SELECT
		s.report_date,
		r.restaurant_uuid,
		s.avg_check
	FROM raw_data.sales s
	JOIN cafe.restaurants r ON r.name = s.cafe_name
);