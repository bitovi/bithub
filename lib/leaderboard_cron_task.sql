delete from leaderboard;
insert into leaderboard
(
	select users.id, users.name, users.email, props -> 'avatar_url' as avatar_url,
	(
		(select coalesce(sum(rules.authorship_value),0)
			from events, rules
			where events.rule_id = rules.id
			and events.author_id = users.id)
		+
		(select coalesce(sum(upvotes.value),0) from events, upvotes
			where upvotes.applies_to_id = events.id
			and events.author_id = users.id)
		+
		(select coalesce(sum(awards.value),0) from events, awards
			where awards.applies_to_id = events.id
			and events.author_id = users.id)
		+
		(select coalesce(sum(internals.value),0) from internals
			where internals.receiver_id = users.id)
		-
		(select coalesce(sum(anteups.value),0) from anteups
			where anteups.actor_id = users.id
			and anteups.fullfilled = true)
	) as total_score
	from users left join users_roles on users.id = users_roles.user_id
	where name is not null
	and role_id is null or role_id not in (select id from roles where name = 'bitovian' or name = 'admin')
	order by total_score desc);
