-- ЧАСТЬ 1. Домашнее задание п. 1
show tables;

-- Таблица лайков
drop table if exists likes;
create table likes (
	id int unsigned not null auto_increment primary key,
	user_id int unsigned not null,
	target_id int unsigned not null,
	target_type enum('messages', 'users', 'posts', 'media') not null,
	created_at datetime default current_timestamp
);

drop table if exists target_types;
create table target_types (
	name varchar(100) not null unique
);
insert into target_types (name) values 
	('messages'),
	('users'),
	('posts'),
	('media');

insert into likes 
	select 
		id,
		FLOOR(1 + (RAND() * 100)),
		FLOOR(1 + (RAND() * 100)),
		(select name from target_types order by rand() limit 1),
		current_timestamp
	from messages;

select * from likes order by rand() limit 10;

-- Таблица постов
drop table if exists posts;
create table posts (
	id int unsigned not null auto_increment primary key,
	user_id int unsigned not null,
	community_id int unsigned,
	head varchar(255),
	body text not null,
	media_id int unsigned,
	is_public boolean default true,
	is_archived boolean default false,
	created_at datetime default current_timestamp,
	updated_at datetime default current_timestamp on update current_timestamp
); 


-- Данные будут сгенерированы в фейкере и импортированы через консоль
select * from posts;
select * from posts where updated_at < created_at;
update posts set updated_at = now() where updated_at < created_at;

-- ЧАСТЬ 2. ДОМАШНЕЕ ЗАДАНИЕ п.2

desc profiles;
alter table profiles
	add constraint profiles_user_id_fk
		foreign key (user_id) references users (id)
			on delete cascade;
alter table profiles
	add constraint profiles_city_id_fk
		foreign key (city_id) references cities (id)
			on delete set null;

desc cities;		
alter table cities
	add constraint cities_country_id_fk
		foreign key (country_id) references countries (id)
			on delete set null;

desc messages;
alter table messages
	add constraint messages_from_user_id_fk
		foreign key (from_user_id) references users (id)
			on delete cascade,
	add constraint messages_to_user_id_fk
		foreign key (to_user_id) references users (id)
			on delete cascade;

desc media;
alter table media
	add constraint media_user_id_fk
		foreign key (user_id) references users (id)
			on delete cascade;
alter table media
	add constraint media_media_type_id_fk
		foreign key (media_type_id) references media_types (id)
			on delete restrict;
			
desc friendship;
alter table friendship
	add constraint friendship_user_id_fk
		foreign key (user_id) references users (id)
			on delete cascade,
	add constraint friendship_friend_id_fk
		foreign key (friend_id) references users (id)
			on delete cascade;
alter table friendship
	add constraint friendship_friendship_status_id
		foreign key (friendship_status_id) references friendship_statuses (id)
			on delete restrict; -- хотел поставить NULL но не дает: SQL Error [1830] [HY000]: Column 'friendship_status_id' cannot be NOT NULL: needed in a foreign key constraint 'friendship_friendship_status_id' SET NULL

desc communities_users;
alter table communities_users
	add constraint communities_users_community_id_fk
		foreign key (community_id) references communities (id)
			on delete cascade,
	add constraint communities_users_user_id_fk
		foreign key (user_id) references users (id)
			on delete cascade;
			
desc posts;
alter table posts
	add constraint posts_user_id_fk
		foreign key (user_id) references users (id)
			on delete cascade,
	add constraint posts_community_id_fk
		foreign key (community_id) references communities (id)
			on delete cascade,
	add constraint posts_media_id_fk
		foreign key (media_id) references media (id)
			on delete set null;
			
desc likes;		
alter table likes
	add constraint likes_user_id_fk
		foreign key (user_id) references users (id)
			on delete cascade; 
-- target_id не стал связывать пока, так как кажется надо будет смотреть к какой таблице target_id имеет отношение исходя из значения target_type

-- ЧАСТЬ 3 СЛОЖНЫЕ ЗАПРОСЫ. УРОК
select first_name, last_name, 'city', 'country' from users where id = 7;
select city_id from profiles where user_id = 7;
select name from cities 
	where id = (select city_id from profiles where user_id = 7); -- city
select country_id from cities 
	where id = (select city_id from profiles where user_id = 7);
select name from countries where id = (
select country_id from cities 
	where id = (select city_id from profiles where user_id = 7)
); -- country

select 
	first_name,
	last_name, 
	(select name from cities 
		where id = (select city_id from profiles where user_id = 7)) as city, 
	(select name from countries where id = (
		select country_id from cities 
			where id = (select city_id from profiles where user_id = 7)
		)
	)as country
from users where id = 7;

select 
	first_name,
	last_name, 
	(select name from cities 
		where id = (select city_id from profiles where profiles.user_id = users.id)) as city, 
	(select name from countries where id = (
		select country_id from cities 
			where id = (select city_id from profiles where profiles.user_id = users.id)
		)
	)as country
from users where id = 7;

select filename from media 
	where user_id = 7
		and media_type_id = (select id from media_types where name = 'images');
		
-- кому принадлежит 10ка больиших файлов
select 
	(select concat(first_name, ' ', last_name) from users where id = media.user_id) as user,
	filename,
	size 
from media order by size desc limit 10;

desc friendship;
select friend_id from friendship where user_id = 7;
select user_id from friendship where friend_id = 7;

select 
	user_id,
	(select concat(first_name, ' ', last_name) from users where users.id = media.user_id) as user,
	sum(size) as total
from media 
	group by user_id
		having total > 1000;
		
SELECT from_user_id, to_user_id, body, created_at 
  FROM messages
    WHERE from_user_id = 7 OR to_user_id = 7
    ORDER BY created_at DESC;
    
SELECT from_user_id, 
  to_user_id, 
  body, 
  IF(is_delivered, 'delivered', 'not delivered') AS status 
    FROM messages
      WHERE (from_user_id = 7 OR to_user_id = 7)
      ORDER BY created_at DESC;
      
 select * from media where user_id = 7;
 select * from likes where target_id = 35;
 select * from likes;
 
-- ДОМАШНЕЕ ЗАДАНИЕ
-- п. 3 Определить кто больше поставил лайков (всего) - мужчины или женщины?
select count(*) from likes 
	where (select gender from profiles where profiles.user_id = likes.user_id) = 'm';

select count(*) from likes
	where (select gender from profiles where profiles.user_id = likes.user_id) = 'f';

-- РЕШЕНИЕ
select if((select count(*) from likes 
	where (select gender from profiles where profiles.user_id = likes.user_id) = 'm') 
	> 
	(select count(*) from likes
	where (select gender from profiles where profiles.user_id = likes.user_id) = 'f'),
'Мужчины', 'Женщины') as 'LIKER';

/* select 
	id,
	user_id,
	(select gender from profiles where profiles.user_id = likes.user_id) as gender
from likes where (select gender from profiles where profiles.user_id = likes.user_id) = 'm'; -- ручной подсчет мужчин

select 
	id,
	user_id,
	(select gender from profiles where profiles.user_id = likes.user_id) as gender
from likes where (select gender from profiles where profiles.user_id = likes.user_id) = 'f'; -- ручной подсчет мужчин
-- к сожалению пока не смог в один запрос скомпоновать чтоб возвращалось m или f в зависимости от того, что больше */

-- 4. Вывести для каждого пользователя количество созданных сообщений, постов,
-- загруженных медиафайлов и поставленных лайков.

(select count(*) from messages where from_user_id = 7)
union
(select count(*) from posts where user_id = 7)
union
(select count(*) from media where user_id = 7)
union
(select count(*) from likes where user_id = 7);
--  пока затрудняюсь самостоятельно сделать в один запрос и так чтоб вручную не прописывать айди пользователя

-- 5. (по желанию) Подсчитать количество лайков которые получили 10 самых последних сообщений. 
select id from messages order by created_at desc limit 10;

select 
	count(*) from likes 
		where target_id 
			in (select id from messages order by created_at desc limit 10) 
			and target_type = 'messages';
-- хотел как-то так реализовать, но возвращается ошибка "SQL Error [1235] [42000]: This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'"
-- другие идеи так и не пришли		