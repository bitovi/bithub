update entities
set searchable_body = (select trim(regexp_replace(regexp_replace(body, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g'))
	from entities as inner_entities
	where inner_entities.id = entities.id
);

update entities
set searchable_title = (select trim(regexp_replace(regexp_replace(title, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g'))
	from entities as inner_entities
	where inner_entities.id = entities.id
);

update entities
set searchable_title = (
	select trim(regexp_replace(regexp_replace(title, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g')) || ' ' || trim(regexp_replace(regexp_replace(body, E'<.*?>', '', 'g' ), '[\s]+', ' ', 'g')) || ' ' || url
	from entities as inner_entities
	where inner_entities.id = entities.id
);
