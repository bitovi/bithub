API endpoints
=============

Hubs
------

Path: `/api/hubs`

**An hub is a 'view' of the content in the system.**

These are called 'Hubs' in the client.

### Routes

HTTP Verb   | Endpoint         | Description
----------- | ---------------- | ----------------------------------------
GET         | `/hubs`        | Responds with all bits from an hub.
GET         | `/hubs/:id`    | Responds with all bits from an hub that are waiting for manual approval.
POST        | `/hubs`        | Creates a new hub.
PUT         | `/hubs/:id`    | Removes the given bit from the list of approved bits for that hub.
DELETE      | `/hubs/:id`    | Entirely removes the given bit from the given hub.

### Params

Name        | Type             | Description
----------- | ---------------- | ----------------------------------------
name        | String           | -
colorscheme | String           | Encoded color scheme, used for generating the hub code.
layout      | String           | Encoded layout, used for generating the hub code.


Hub bits
--------------

Path: `/api/hubs/:hub_id/bits`

**Used to expose bits linked to an hub to the client.**

It's used to show various views of data in an hub. It shows
approved and waitlisted bits and allows manipulation of
those bits (manually approving or hiding content, or entirely
removing them).

### Routes

HTTP Verb   | Endpoint                                    | Description
----------- | ------------------------------------------- | ----------------------------------------
GET         | `/hubs/:hub_id/bits`                | Responds with all bits from an hub
GET         | `/hubs/:hub_id/bits/approved`       | Responds with all approved bits from an hub
GET         | `/hubs/:hub_id/bits/waitlisted`     | Responds with all bits from an hub that are waiting for manual approval
GET         | `/hubs/:hub_id/bits/:id`            | Responds with details of the given bit.
PUT         | `/hubs/:hub_id/bits/:id/aprove`     | Adds the given bit to the list of approved bits for that hub.
PUT         | `/hubs/:hub_id/bits/:id/disaprove`  | Removes the given bit from the list of approved bits for that hub.
DELETE      | `/hubs/:hub_id/bits/:id`            | Entirely removes the given bit from the given hub.


Hub filters
-------------

Path: `/api/hubs/:hub_id/filters`

**Used to definine moderation rules for incoming data.**

Only one blocking and one moderating filter can be
defined for each hub.

The blocking filter prevents saving the incoming data,
and the moderating filter automatically approves an bit
if it satisfies the appropriate conditions.

Filters consist of queries which can be combined. A filter
can either be conjunctive (AND) or disjunctive (OR). Queries
in a filter have a sentence-like appearance.

A few examples of queries:

- Content contains 'javascript'
- Tagged with 'canjs'
- Feed name is twitter

### Routes

HTTP Verb  | Endpoint                                    | Description
---------- | ------------------------------------------- | ---------------------------------------
GET        | `/hubs/:hub_id/filters`                 | responds with all filters for a given hub
GET        | `/hubs/:hub_id/filters/:id`             | responds with details of the given filter
POST       | `/hubs/:hub_id/filters`                 | creates a new filter for a given hub
PUT        | `/hubs/:hub_id/filters/:id`             | updates the existing filter for a given hub
DELETE     | `/hubs/:hub_id/filters/:id`             | destroys a filter

### Params

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

Hub services
--------------

Path: `/api/hubs/:hub_id/services`

**Used to define configuration for a given feed.**

Each feed, for example Github, Facebook and Twitter, has to be
configured so as to enable the crawler fetch data from those
feeds.

This configuration usually comes in the form of access tokens,
along with feed specific settings. For example, repositories to follow for
Github, Pages to follow for Facebook, user handles to follow for
Twitter

### Routes

HTTP Verb  | Endpoint                                     | Description
---------- | -------------------------------------------- | ---------------------------------------
GET        | `/hubs/:hub_id/services`                 | responds with all filters for a given hub
GET        | `/hubs/:hub_id/services/:id`             | responds with details of the given filter
POST       | `/hubs/:hub_id/services`                 | creates a new filter for a given hub
PUT        | `/hubs/:hub_id/services/:id`             | updates the existing filter for a given hub
DELETE     | `/hubs/:hub_id/services/:id`             | destroys a filter

### Params

Name        | Type             | Description
----------- | ---------------- | ----------------------------------------
feed_name   | String           | Feed source, for example Twitter.
type_name   | String           | Type of the service for the given feed, for example @handle or #hashtag.
config      | Object           | Service configuration.

Service variants: feeds and types

### Types of services

#### Twitter

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
	config: { hashtag: "bitovi" }
}
```


#### Disqus

Forum:

```
{
	feed_name: "disqus",
	type_name: "forum",
	config: { url: "pltconfusion.com" }
}
```

#### Facebook:

Page:

```
{
	feed_name: "facebook",
	type_name: "page",
	config: { id: "24356776342"}
}
```

#### Forsquare

Venue:

```
{
	feed_name: "foursquare",
	type_name: "venue",
	config: { id: "283jehren"}
}
```

#### Meetup

Group:

```
{
	feed_name: "meetup",
	type_name: "group",
	config: { id: "id"}
}
```

#### Github

Repo:

```
{
	feed_name: "github",
	type_name: "repo",
	config: {
		name: "retro/apitizer",
		tracking: {
			issues: true,
			pull_requests: false
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

#### Stackexchange

Tags (questions and answers):

```
{
	feed_name: "stackexchange",
	type_name: "tags",
	config: { tags: ["canjs", "jquerypp", "javascriptmvc"] }
}
```

#### Tumblr

Blog:

```
{
	feed_name: "tumblr",
	type_name: "blog",
	config: { hostname: 'peacecorps.tumblr.com'}
}
```

Tag:

```
{
	feed_name: "tumblr",
	type_name: "tag",
	config: { tag: "braclets" }
}
```

#### Instagram

User:

```
{
	feed_name: "instagram",
	type_name: "user",
	config: { id: "id" }
}
```

Tag:

```
{
	feed_name: "instagram",
	type_name: "tag",
	config: { tag: "braclets" }
}
```

Location:

```
{
	feed_name: "instagram",
	type_name: "location",
	config: { id: "12345" }
}
```

Geography:

```
{
	feed_name: "instagram",
	type_name: "geography",
	config: { lat: "35.657872", lng: "139.70232", radius: "1000" }
}
```

#### RSS

Site:

```
{
	feed_name: "rss",
	type_name: "site",
	config: {
		tag_with: "blog",
		url: "pltconfusion.com/feed"
	}
}
```
