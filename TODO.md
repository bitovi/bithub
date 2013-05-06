TODO
====

server/backend
--------------
* Re-enable IRC bot mini-API (for displaying nicks)
* JSONp support
* Some more cleaning up of UsersController (some code was hard to pull out)
* Specs for ActivityDecorator (as it's pretty complex)
* Optimize the API; optimize acts_as_taggable or replace it with acts_as_taggable_on_steroids

client/frontend
---------------
* LRU menu
* Admin manage bar for updating tags and category

manual work
-----------
* Make additional twitter apps (OAuth keys/tokens) for each user stream we follow (CanJS, JqueryPP ..) ; we could just turn off the old bithub connections and transfer them to the new Bithub, but I'd like to keep the old one running one more week, just in case
* Define rules with authorship/award/upvote values 
* Apply defined rules to migrated events
* Bootstrap a staging server
