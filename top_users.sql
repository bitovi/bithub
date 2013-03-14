SELECT users.id, SUM(as_affected.) - SUM(as

FROM users
LEFT JOIN activities AS as_affected ON users.id = as_affected.affected_id
LEFT JOIN activities AS as_actor ON users.id = actor.actor_id


activities
==========

actor: nikica | affected: nikica | applies_to: thread_starter | cost: 0  | value: 50       | ident: authorship (bug raise)
actor: veljko | affected: nikica | applies_to: thread_starter | cost: 0  | value: 1        | ident: upvote
actor: david  | affected: nikica | applies_to: thread_starter | cost: 0  | value: 1        | ident: upvote
actor: veljko | affected: veljko | applies_to: thread_starter | cost: 25 | value: 0        | ident: stake_claim
actor: justin | affected: justin | applies_to: thread_reply   | cost: 0  | value: 0        | ident: authorship (helpful reply)
actor: david  | affected: justin | applies_to: thread_reply   | cost: 0  | value: 1        | ident: upvote
actor: alexis | affected: justin | applies_to: thread_reply   | cost: 0  | value: 1        | ident: upvote
actor: brian  | affected: justin | applies_to: thread_reply   | cost: 0  | value: 1        | ident: upvote
actor: admin  | affected: justin | applies_to: thread_reply   | cost: 0  | value: 25+2+100 | ident: award (bug fix)
