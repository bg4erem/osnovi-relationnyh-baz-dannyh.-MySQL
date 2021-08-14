show databases;

use shop;
show tables;
select * from users;

use sample;
show tables;
select * from users;
desc users;
alter table users modify name char(100);

-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. 
-- Используйте транзакции.

start transaction;
insert into sample.users 
	select id, name from shop.users where id = 1;
delete from shop.users where id = 1;
commit;

-- Создайте представление, которое выводит название name товарной позиции из таблицы products
-- и соответствующее название каталога name из таблицы catalogs.

use shop;
show tables;
select * from products;
select * from catalogs;

create view shop_products as
	select products.name, catalogs.name as category 
	from products join catalogs 
	where catalogs.id = products.catalog_id;
select * from shop_products;

-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
-- в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

select hour(now());

delimiter //

create function hello ()
returns varchar(255) not deterministic
	begin
		declare currenth int; 
		declare hellotext varchar(255);
	
		select hour(now()) into currenth;
		case
			when currenth >= 6  and currenth < 12  then set hellotext = 'Доброе утро';
			when currenth >= 12 and currenth < 18  then set hellotext = 'Добрый день';
			when currenth >= 18 and currenth <= 23 then set hellotext = 'Добрый вечер';
			when currenth >= 0  and currenth < 6   then set hellotext = 'Доброй ночи';
		end case;
		return hellotext;
	end;

SET GLOBAL log_bin_trust_function_creators = 1;
select hello ();

/* В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
При попытке присвоить полям NULL-значение необходимо отменить операцию. */

select * from products;

drop trigger if exists products_insert_validator;
create trigger products_insert_validator before insert on products
for each row 
	begin
	case 
		when new.name = null then signal sqlstate '45000' set message_text = 'insertion cancelled, null name';
		when new.description = null then signal sqlstate '45000' set message_text = 'insertiona cancelled, null description';
	end case;
	end;

insert into products (name, description, price, catalog_id) values 
	('Intel i9-9000', null, 200, 3);

-- кажется не получается, выходит ошибка case not found for case statement

