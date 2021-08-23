show tables;
select * from users;
select * from orders;
insert into orders (user_id) values (floor(1 + rand() * 6));

-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
select name from users where id in (select user_id from orders);
select users.name, orders.id from users join orders on orders.user_id = users.id;


-- Выведите список товаров products и разделов catalogs, который соответствует товару.
select * from catalogs;
select * from products;
insert into products (name, description, price, catalog_id) values
	('Pentium 4', 'Pentium 4 processor for office and entertainment tasks', '100', '1'),
	('i3-7000', 'i3 is a modern processor for a wide range of tasks', '150', '1'),
	('i7-8000', 'i7 is a high-end processor which fits the most difficult calls', '250', '1'),
	('Asus MB10X', 'the basic MB with improved overclock ability', '90', '2'),
	('GIGABYTE X7X', 'X7X from GIGABYTE is the solution for gamers', '190', '2'),
	('Radeon 9000', 'just a videocard', '200', '3'),
	('nVidia RTX3500', 'mine your BTC on this card', '600', '3');
select products.name, products.description, products.price, catalogs.name from products join catalogs on products.catalog_id = catalogs.id;
	
/* (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
 * Поля from, to и label содержат английские названия городов, поле name — русское. 
 * Выведите список рейсов flights с русскими названиями городов. */

drop table if exists flights;
create table flights (
	id int unsigned not null auto_increment primary key,
	`from` varchar(100),
	`to` varchar(100)
	);
select * from flights;
insert into flights (`from`, `to`) values
('moscow', 'omsk'),
('novgorod', 'kazan'),
('irkutsk', 'moscow'),
('omsk', 'irkutsk'),
('moscow', 'kazan');

drop table if exists cities;
create table cities (
	label varchar(100),
	name varchar(100)
	);
select * from cities;
insert into cities (`label`, `name`) values
('moscow', 'Москва'),
('irkutsk', 'Иркутск'),
('novgorod', 'Новгород'),
('kazan', 'Казань'),
('omsk', 'Омск');

select 
	id, 
	(select name from cities where cities.label = flights.from) as 'from', 
	(select name from cities where cities.label = flights.to) as 'to'
from flights;

select 
	flights.id,
	cities.name as 'from',
	cities.name as 'to'
from
	flights join cities
on
	cities.label = flights.from or cities.label = flights.to
order by id; -- ну почти получилось с JOIN, но не понял до конца как убрать дубли