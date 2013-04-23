ESTIMATES
=========
NOTE: time estimates are noted in absolute terms (combined, not per person)

* filterbar: filter categories reordering in session (LRU filter) [1 day]
* finish the event list [5 days]
	- indivitual templates for each event type/category
	- awards (awarding an event in a thread)
* profile pages [3 days]
	- user's info (show and edit in place)
	- user's history
* new post form [3 days]
* connecting to the live service from the client (live updating) [not sure, we have a few questions*]
* admin iterface - render on server? [needs discussion]
* check that all create/update/destroy API calls are secured and generally check all API calls [1 day]
* optimize SQL queries [2 days]


\*
mainly, do we just re-render the whole list when something new comes along? can we do some king of smart insertion with canjs? 
