Embeds
======

Description
---

**An embed is a 'view' of the content in the system.**

These are called 'Hubs' in the client.

Routes
---

HTTP Verb   | Endpoint         | Description
----------- | ---------------- | ----------------------------------------
GET         | `/embeds`        | Responds with all entities from an embed.
GET         | `/embeds/:id`    | Responds with all entities from an embed that are waiting for manual approval.
POST        | `/embeds`        | Creates a new embed.
PUT         | `/embeds/:id`    | Removes the given entity from the list of approved entities for that embed.
DELETE      | `/embeds/:id`    | Entirely removes the given entity from the given embed.

Params
---


Name        | Type             | Description
----------- | ---------------- | ----------------------------------------
name        | String           | -
colorscheme | String           | Encoded color scheme, used for generating the embed code.
layout      | String           | Encoded layout, used for generating the embed code.


Embed > Entities
================

Description
---
**Used to expose entities linked to an embed to the client.**

It's used to show various views of data in an embed. It shows
approved and waitlisted entities and allows manipulation of
those entities (manually approving or hiding content, or entirely
removing them).

Routes
---

HTTP Verb   | Endpoint                                    | Description
----------- | ------------------------------------------- | ----------------------------------------
GET         | `/embeds/:embed_id/entities`                | Responds with all entities from an embed
GET         | `/embeds/:embed_id/entities/approved`       | Responds with all approved entities from an embed
GET         | `/embeds/:embed_id/entities/waitlisted`     | Responds with all entities from an embed that are waiting for manual approval
GET         | `/embeds/:embed_id/entities/:id`            | Responds with details of the given entity.
PUT         | `/embeds/:embed_id/entities/:id/aprove`     | Adds the given entity to the list of approved entities for that embed.
PUT         | `/embeds/:embed_id/entities/:id/disaprove`  | Removes the given entity from the list of approved entities for that embed.
DELETE      | `/embeds/:embed_id/entities/:id`            | Entirely removes the given entity from the given embed.


Embed > Filters
===============

Description
---
**Used to definine moderation rules for incoming data.**

Only one blocking and one moderating filter can be
defined for each embed. 

The blocking filter prevents saving the incoming data,
and the moderating filter automatically approves an entity
if it satisfies the appropriate conditions.

Filters consist of queries which can be combined. A filter
can either be conjunctive (AND) or disjunctive (OR). Queries
in a filter have a sentence-like appearance.

A few examples of queries:

- Content contains 'javascript'
- Tagged with 'canjs'
- Feed name is twitter

Routes
---

HTTP Verb  | Endpoint                                    | Description
---------- | ------------------------------------------- | ---------------------------------------
GET        | `/embeds/:embed_id/filters`                 | responds with all filters for a given embed
GET        | `/embeds/:embed_id/filters/:id`             | responds with details of the given filter
POST       | `/embeds/:embed_id/filters`                 | creates a new filter for a given embed
PUT        | `/embeds/:embed_id/filters/:id`             | updates the existing filter for a given embed
DELETE     | `/embeds/:embed_id/filters/:id`             | destroys a filter

Params
---

Name            | Type             | Description
-----------     | ---------------- | ----------------------------------------
is_conj         | String           | Determines whether the filter predicates are combined conjunctively.
classification  | String           | Determines whether the filter is approving or blocking.
natlang_queries | Array[Object]    | Query definitions, example JSON below.


Natlang queries JSON example:

```
[{
	is_negated: false,
	attr: 'content',
	op: 'contains',
	val: 'canjs'
}, {
	is_negated: true,
	attr: '',
	op: 'tagged_with',
	val: 'canjs'
}, {
	is_negated: false,
	attr: 'feed_name',
	op: 'is',
	val: 'twitter'
}]
```

Embed > Services
================

**Used to define configuration for a given feed.**

Each feed, for example Github, Facebook and Twitter, has to be 
configured so as to enable the crawler fetch data from those
feeds.

This configuration usually comes in the form of access tokens,
along with feed specific settings. For example, repositories to follow for
Github, Pages to follow for Facebook, user handles to follow for
Twitter

Routes:

HTTP Verb  | Endpoint                                    | Description
---------- | ------------------------------------------- | ---------------------------------------
GET        | `/embeds/:embed_id/services`                 | responds with all filters for a given embed
GET        | `/embeds/:embed_id/services/:id`             | responds with details of the given filter
POST       | `/embeds/:embed_id/services`                 | creates a new filter for a given embed
PUT        | `/embeds/:embed_id/services/:id`             | updates the existing filter for a given embed
DELETE     | `/embeds/:embed_id/services/:id`             | destroys a filter

Params:

Name        | Type             | Description
----------- | ---------------- | ----------------------------------------
feed_name   | String           | Feed source, for example Twitter.
type_name   | String           | Type of the service for the given feed, for example @handle or #hashtag.
config      | Object           | Service configuration.

Service variants: feeds and types

Twitter
-------

User timeline:

```
{
	feed_name: "twitter",
	type_name: "user_timeline",
	config: { handle: "canjs" }
}
```


Followers:

```
{
	feed_name: "twitter",
	type_name: "followers",
	config: { handle: "bitovi" }
}
```

Hashtag:

```
{
	feed_name: "twitter",
	type_name: "hashtag",
	config: { hashtag: "canjs" }
}
```

Hashtag:

```
{
	feed_name: "twitter",
	type_name: "search",
	config: { term: "canjs is best" }
}
```


Disqus
------

Forum:

```
{
	feed_name: "disqus",
	type_name: "forum",
	config: { url: "pltconfusion.com" }
}
```

Facebook:
---

Page: 

```
{
	feed_name: "facebook",
	type_name: "page",
	config: { id: "24356776342"}
}
```

Forsquare
---

Venue:

```
{
	feed_name: "foursquare",
	type_name: "venue",
	config: { id: "283jehren"}
}
```

Instagram
---

User: 

```
{
	feed_name: "instagram",
	type_name: "user",
	config: { id: "id"}
}
```

Tag: 

```
{
	feed_name: "foursquare",
	type_name: "tag",
	config: { tag: "blago"}
}
```

Meetup
---

Group:

```
{
	feed_name: "meetup",
	type_name: "group",
	config: { id: "id"}
}
```

Github
---

Repo:

```
{
	feed_name: "github",
	type_name: "repo",
	config: {
		name: "retro/apitizer",
		tracking: {
			activity: true,
			issues: true,
			pull_req: false,
			code: true
		}
	}
}
```

Organization:

```
{
	feed_name: "github",
	type_name: "org",
	config: { name: "bitovi" }
}
```

Stackexchange
---

Tags (questions and answers):

```
{
	feed_name: "stackexchange",
	type_name: "tags",
	config: { tags: ["canjs", "jquerypp", "javascriptmvc"] }
}
```

Tumblr
---

Blog:

```
{
	feed_name: "tumblr",
	type_name: "blog",
	config: { hostname: 'peacecorps.tumblr.com'}
}
```

Tags:

```
{
	feed_name: "tumblr",
	type_name: "tags",
	config: { tags: ["braclets", "diy", "gosling"] }
}
```

RSS
---

Site:

```
{
	feed_name: "rss",
	type_name: "site",
	config: { url: "pltconfusion.com/feed" }
}
```

