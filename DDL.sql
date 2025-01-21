/* создаем схему cafe */
CREATE SCHEMA IF NOT EXISTS cafe;

/* создаем пользовательский тип - тип заведения */
CREATE TYPE cafe.restaurant_type AS ENUM
	('coffee_shop', 'restaurant', 'bar', 'pizzeria');

/* создаем таблицу restaurants 
 * с информацией о заведениях */
CREATE TABLE cafe.restaurants (
	restaurant_uuid uuid PRIMARY KEY DEFAULT GEN_RANDOM_UUID(),
	name VARCHAR(50) NOT NULL,
	type cafe.restaurant_type NOT NULL,
	menu json
);

/* создаем таблицу managers 
 * с информацией о менеджерах */
CREATE TABLE cafe.managers (
	manager_uuid uuid PRIMARY KEY DEFAULT GEN_RANDOM_UUID(),
	name VARCHAR(100) NOT NULL,
	phone VARCHAR(20)
);

/* создаем таблицу restaurant_manager_work_dates 
 * с информацией о периодах работы менеджеров в ресторанах */
CREATE TABLE cafe.restaurant_manager_work_dates (
	restaurant_uuid uuid
		REFERENCES cafe.restaurants(restaurant_uuid) ON DELETE RESTRICT,
	manager_uuid uuid
		REFERENCES cafe.managers(manager_uuid) ON DELETE RESTRICT,
	employment_date date,     /* дата начала работы в ресторане */
	dismissal_date date,      /* дата окончания работы в ресторане */
	PRIMARY KEY(restaurant_uuid, manager_uuid)
);

/* создаем таблицу sales с информацией
 * о среднем чеке заведений по дням */
CREATE TABLE cafe.sales (
	date date NOT NULL,
	restaurant_uuid uuid
		REFERENCES cafe.restaurants(restaurant_uuid) ON DELETE RESTRICT,
	avg_check NUMERIC(8, 1),
	PRIMARY KEY (date, restaurant_uuid)
);