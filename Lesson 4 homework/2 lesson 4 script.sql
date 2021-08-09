show tables;

-- (1) checking users
select * from users limit 10;

-- updated_at must be fixed where updated_at is older than created_at
select * from users where updated_at < created_at;
update users set updated_at = NOW() where updated_at < created_at;

-- (2) checking profiles
select * from profiles limit 10;

-- fixing city_id in profiles
select * from cities; -- reading how many cities. we have 50 cities. i will remove 20 cities so 30 cities will be left
delete from cities where id > 30; -- only 30 cities left
select floor(1 + RAND() * 30);
update profiles set city_id = floor(1 + RAND() * 30);

-- fixing gender to enum type
alter table profiles modify column gender enum('m', 'f');

-- (3) checking countries
select * from countries limit 10;

-- updating countries with real 
create temporary table countries_temp (name varchar(120)); -- temporary table
select * from countries_temp limit 10;

insert into countries_temp values -- inserting real countries to the temporary table
('Russia'),
('USA'),
('Germany'),
('Norway'),
('Japan');

select name from countries_temp order by rand() limit 1;
update countries 
set name = (select name from countries_temp order by rand() limit 1);

-- (4) checking messages
desc messages;
select * from messages limit 10; -- we have to fix from_user_id, to_user_id
update messages set
from_user_id = floor(1 + RAND() * 100),
to_user_id = floor(1 + rand() * 100);

-- (5) checking media
desc media;
alter table media modify column metadata json; -- fixing colummn metadata type
select * from media limit 10;
update media set user_id = floor(1 + rand() * 100); -- fixing user_id
create temporary table extensions (name varchar(10));
insert into extensions values
	('jpeg'),
	('mp3'),
	('avi'),
	('gif'),
	('png'),
	('mov');
select * from extensions;
update media set filename = concat(
	'http://cloudfil.es/ftp/vk/',
	filename,
	'.',
	(select name from extensions order by rand() limit 1)
	); -- fixing filename to make it looks like a real URL
select * from media where size = 0; -- sizes should not be zero. let's fix this
update media set size = floor(1000 + rand() * 10000);
update media set metadata = concat('{"owner":"',
	(select concat(first_name, ' ', last_name) from users where id = media.user_id),
	'"}'
);

-- (6) checking media_types
select * from media_types; -- we have 6 items. let's make 3 items only
delete from media_types where id > 3;
update media_types set name = 'images' where id = 1;
update media_types set name = 'audio' where id = 2;
update media_types set name = 'video' where id = 3;

update media set media_type_id = floor(1 + rand() * 3);

-- (7) checking friendship
select * from friendship limit 10;
update friendship set friend_id = friend_id + 1 where user_id = friend_id;
update friendship set 
	user_id = floor(1 + rand() * 100),
	friend_id = floor(1 + rand() * 100);
	
-- (8) checking friendship_statuses
select * from friendship_statuses;
truncate friendship_statuses;
insert into friendship_statuses (name) values
	('requested'),
	('confirmed'),
	('rejected');
update friendship set friendship_status_id = floor(1+ rand() * 3);

-- (9) checking communities
desc communities;
select * from communities limit 10; -- 40 items

-- (10) checking communities_friends
select * from communities_users;
