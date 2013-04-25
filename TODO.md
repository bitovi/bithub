TODO:
=====

* meetup.com integration
* extract ScopeApplier to /lib
* ensure that all create/update/destroy API calls are secured
* fine tune the API
	- mainly, optimize acts_as_taggable b/c its causing the N+1 query problem
	- optimize other possibly slow SQL queries
* separate admin interface (/admin)
	- an overview section for users,events etc.
	- rule definition section
* apply defined rules to migrated events
