show tables;
desc likes;

-- Фукнкция для триггера проверки ВК

DROP FUNCTION IF EXISTS is_row_exists;
DELIMITER //

CREATE FUNCTION is_row_exists (target_id INT, target_type VARCHAR(50))
RETURNS BOOLEAN READS SQL DATA

BEGIN
  CASE target_type
    WHEN 'messages' THEN
      RETURN EXISTS(SELECT 1 FROM messages WHERE id = target_id);
    WHEN 'users' THEN 
      RETURN EXISTS(SELECT 1 FROM users WHERE id = target_id);
    WHEN 'media' THEN
      RETURN EXISTS(SELECT 1 FROM media WHERE id = target_id);
    WHEN 'posts' THEN
      RETURN EXISTS(SELECT 1 FROM posts WHERE id = target_id);
    ELSE 
      RETURN FALSE;
  END CASE;
END//

DELIMITER ;

select is_row_exists(51,'users');

-- Триггер

DROP TRIGGER IF EXISTS likes_validation;
DELIMITER //

CREATE TRIGGER likes_validation BEFORE INSERT ON likes

FOR EACH ROW BEGIN
  IF NOT is_row_exists(NEW.target_id, NEW.target_type) THEN
    SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Error adding like! Target table doesn't contain row id provided!";
  END IF;
END//

DELIMITER ;

insert into likes (user_id, target_id, target_type)
	values (34, 45, 'users');
	
insert into likes (user_id, target_id, target_type)
	values (34, 455, 'users');
	
SHOW FUNCTION STATUS LIKE 'is_row_exists';
SHOW CREATE FUNCTION is_row_exists;
SHOW PROCEDURE STATUS LIKE 'posts_analysis';

-- Домашнее задание

-- 1. Проанализировать какие запросы могут выполняться наиболее
-- часто в процессе работы приложения и добавить необходимые индексы.
show tables;

show index from users;
create index users_lastname on users(last_name);
create index users_firstname on users(first_name);

show index from cities;
desc cities;
create index cities_name on cities(name);

desc communities;
show index from communities;

desc media;
show index from media;
create index media_filename on media(filename);

desc messages;
show index from messages;
create index messages_body on messages(body); -- ошибка 42000 BLOB/TEXT column 'body' used in key specification without a key length

desc posts;
show index from posts;
create index posts_head on posts(head);

-- 2 Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- (сумма количестива пользователей во всех группах делённая на количество групп)
-- самый молодой пользователь в группе (желательно вывести имя и фамилию)
-- самый старший пользователь в группе (желательно вывести имя и фамилию)
-- количество пользователей в группе
-- всего пользователей в системе (количество пользователей в таблице users)
-- отношение в процентах для последних двух значений 
-- (общее количество пользователей в группе / всего пользователей в системе) * 100
select * from communities;
select * from communities_users;


-- разобрал решение из 12 урока
SELECT DISTINCT 
  communities.name AS group_name,
  COUNT(communities_users.user_id) OVER() 
    / (SELECT COUNT(*) FROM communities) AS avg_users_in_groups,
  FIRST_VALUE(CONCAT_WS(" ", users.first_name, users.last_name)) 
    OVER (w_community ORDER BY profiles.birthday DESC) AS youngest,
  FIRST_VALUE(CONCAT_WS(" ", users.first_name, users.last_name)) 
    OVER (w_community ORDER BY profiles.birthday ASC) AS oldest,
  COUNT(communities_users.user_id) OVER w_community AS users_in_group,
  (SELECT COUNT(*) FROM users) AS users_total,
  COUNT(communities_users.user_id) OVER w_community / (SELECT COUNT(*) FROM users) *100 AS '%%'
    FROM communities
      LEFT JOIN communities_users 
        ON communities_users.community_id = communities.id
      LEFT JOIN users 
        ON communities_users.user_id = users.id
      LEFT JOIN profiles 
        ON profiles.user_id = users.id
      WINDOW w_community AS (PARTITION BY communities.id);    