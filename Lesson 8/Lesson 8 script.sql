-- ДЗ 8 урока проработка

show databases;
use vk;

show tables;
select * from likes;

-- Определить кто больше поставил лайков (всего) - мужчины или женщины?
-- Изучил решение задания с JOIN  на уроке 10

select profiles.gender, count(likes.id) as total_likes 
	from likes join profiles on likes.user_id = profiles.user_id 
	group by profiles.gender order by total_likes desc limit 1;
	
-- Вывести для каждого пользователя количество созданных сообщений, постов, загруженных медиафайлов и поставленных лайков.

select
	users.first_name,
	users.last_name,
	count(distinct messages.id) as total_messages,
	count(distinct posts.id) as total_posts,
	count(distinct media.id) as total_media,
	count(distinct likes.id) as total_likes
from users 
	left join messages 
		on users.id = messages.from_user_id 
	left join posts 
		on users.id = posts.user_id 
	left join likes
		on users.id = likes.user_id 
	left join media
		on users.id = media.user_id
group by users.id;

-- (по желанию) Подсчитать общее количество лайков, которые получили 10 самых последних сообщений.
SELECT SUM(got_likes) AS total_likes
  FROM (   
    SELECT COUNT(likes.id) AS got_likes 
      FROM messages
        LEFT JOIN likes
          ON likes.target_id = messages.id
            AND target_type = 'messages'
      GROUP BY messages.id
      ORDER BY messages.created_at DESC
      LIMIT 10
) AS last_messages;   