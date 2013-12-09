class CreateLeaderboardMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
      create materialized view leaderboard
      as
      SELECT
        users.id as user_id,
        users.name as user_name,
        users.email as user_email,
        props -> 'avatar_url' as user_gravatar_url,

        (
          (SELECT coalesce(sum(rules.authorship_value),0)
            from events, rules
            where events.rule_id = rules.id
            and events.author_id = users.id)
          +
          (SELECT coalesce(sum(upvotes.value),0) from events, upvotes
            where upvotes.applies_to_id = events.id
            and events.author_id = users.id)
          +
          (SELECT coalesce(sum(awards.value),0) from events, awards
            where awards.applies_to_id = events.id
            and events.author_id = users.id)
          +
          (SELECT coalesce(sum(internals.value),0) from internals
            where internals.receiver_id = users.id)
          -
          (SELECT coalesce(sum(anteups.value),0) from anteups
            where anteups.actor_id = users.id
            and anteups.fullfilled = true)
        ) as user_score

      from users left join users_roles on users.id = users_roles.user_id
      where name is not null
      and role_id is null or role_id not in (SELECT id from roles where name = 'bitovian' or name = 'admin')
      order by user_score desc;
    SQL
  end

  def down
    execute "drop materialized view leaderboard;"
  end
end
