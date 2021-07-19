show tables;
describe users;

-- Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»
select * from users;
insert into users (name) value ('Testuser');

update users set -- (1) Заполнение текущей датой и временем полей created_at и updated_at
	created_at = now(),
	updated_at = now();
	

-- (2) Преобразовать дату с varchar на datetime без потери данных
drop table if exists users;
create table users (
id serial primary key,
name varchar (255) comment 'Имя покупателя',
birthday_at date comment 'Дата рождения',
created_at varchar (255),
updated_at varchar (255)
) comment = 'Покупатели';
describe users;
select * from users;
insert into users (name, created_at, updated_at) values (
'Name1',
'20.10.2017 08:10',
'20.10.2018 18:20'
);
update users set 
	created_at = str_to_date(created_at, '%d.%m.%Y %k:%i'),
	updated_at = str_to_date(created_at, '%d.%m.%Y %k:%i');
alter table users change created_at created_at datetime default current_timestamp;
alter table users change updated_at updated_at datetime default current_timestamp on update current_timestamp;
-- решение подсмотрено на уроке 6. самостоятельно что-то не смог додумать ) наверное из-за того что ночью сидел

-- (3) Задание
drop table if exists storehouses_products;
create table storehouses_products(
	id serial primary key,
	storehouse_id int unsigned,
	product_id int unsigned,
	value int unsigned,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp
	) comment = 'Остатки на складах';
select * from storehouses_products;
INSERT INTO
  storehouses_products (storehouse_id, product_id, value)
VALUES
  (1, 543, 0),
  (1, 789, 2500),
  (1, 3432, 0),
  (1, 826, 30),
  (1, 719, 500),
  (1, 638, 1);
select * from storehouses_products order by if(value > 0, 0, 1), value; /* таки осталась непонятной мне эта конструкция
в случае выполнение условия значение > 0 возвращается "ложь", иначе "истина". механизм пока не понятен.
UPD: просмотрел объяснение на уроке 6 еще раз, понял, спасибо */

-- задание 4 понятно, но самостоятельно до урока 6 не было проработано
select name from users where date_format(birthday_at, '%M') in ('may', 'august');

-- задание 5 
select * from catalogs;
insert into catalogs (name) value ('HDD');
insert into catalogs (name) value ('RAM');
select * from catalogs where id in (5, 1, 2) order by field(id, 5, 1, 2);

-- АГРЕГАЦИЯ ДАННЫХ
-- Задание 1
select * from users;
truncate users;
INSERT INTO
  users (name, birthday_at, created_at, updated_at)
VALUES
  ('Геннадий', '1990-10-05', NULL, NULL),
  ('Наталья', '1984-11-12', NULL, NULL),
  ('Александр', '1985-05-20', NULL, NULL),
  ('Сергей', '1988-02-14', NULL, NULL),
  ('Иван', '1998-01-12', NULL, NULL),
  ('Мария', '2006-08-29', NULL, NULL);
 
select avg(timestampdiff(year, birthday_at, now())) as age from users;

-- Задание 2
select 
	date_format(date(concat_ws('-', year(now()), month(birthday_at), day(birthday_at))), '%W') as day,
	count(*) as total
from users group by day order by total desc;
