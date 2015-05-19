<<<<<<< HEAD
update entities set searchable_title = trim(regexp_replace(regexp_replace(title, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g'));
update entities set searchable_body = trim(regexp_replace(regexp_replace(body, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g'));
update entities set searchable_content = coalesce(searchable_title, '') || ' ' || coalesce(searchable_body, '') || ' ' || coalesce(url, '');
update entities set searchable_author = props -> 'origin_author_name';
=======
update entities
set searchable_body = (select trim(regexp_replace(regexp_replace(body, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g'))
	from entities as inner_entities
	where inner_entities.id = entities.id
);
>>>>>>> dev

drop table if exists latest_events;

<<<<<<< HEAD
create temp table latest_events as
select entity_id, twitter_name, instagram_name, youtube_name
from (select entity_id,
		coalesce((source_data -> 'user' -> 'name')::text, '') || ' ' || coalesce((source_data -> 'user' -> 'screen_name')::text, '') as twitter_name,
		coalesce((source_data -> 'user' -> 'full_name')::text, '') || ' ' || coalesce((source_data -> 'user' -> 'username')::text, '') as instagram_name,
		coalesce((events.source_data -> 'snippet' -> 'channelTitle')::text, '') as youtube_name,	
		row_number() over (partition by entity_id order by created_at desc) as rn
		from events
	) as le
where le.entity_id is not null and le.rn = 1;

update entities set searchable_author = instagram_name
from latest_events where latest_events.entity_id = entities.id
and feed_name = 'instagram' and type_name = 'media';

update entities set searchable_author = twitter_name
from latest_events where latest_events.entity_id = entities.id
and feed_name = 'twitter' and type_name = 'tweet';

update entities set searchable_author = youtube_name
from latest_events where latest_events.entity_id = entities.id
and feed_name = 'youtube';

drop table if exists latest_events;

update entities set searchable_author = regexp_replace(searchable_author, '"', '', 'g');
=======
update entities
set searchable_title = (
	select trim(regexp_replace(regexp_replace(title, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g')) || ' ' || trim(regexp_replace(regexp_replace(body, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g')) || ' ' || url
	from entities as inner_entities
	where inner_entities.id = entities.id
);
>>>>>>> dev
