delete from leaderboard;
insert into leaderboard
(
	select users.id, users.name, users.email, 
	( 
		case
			when ((char_length(props -> 'gravatar_url')) > 0) then props -> 'gravatar_url'
			else 'http://bithub.com/bithub/assets/images/icon-user.png'
		end

	) as avatar_url,
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
	from users
	order by total_score desc);
