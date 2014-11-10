Endpoints
=========

Embed > Entities endpoint
-------------------------

**An embed is a 'view' of the content in the system.**

When creating an embed, you have to define rules
which govern which kinds of data end up in an embed.

Using those rules, BitHub routes incoming data into
embeds which satisfy the user defined rules.

Once the data has been routed, it can be accessed using
the following API endpoints. All endpoints are scoped 

HTTP Verb   | Endpoint                                    | Description
----------- | ------------------------------------------- | ----------------------------------------
GET         | `/embeds/:embed_id/entities`                | responds with all entities from an embed
GET         | `/embeds/:embed_id/entities/approved`       | responds with all approved entities from an embed
GET         | `/embeds/:embed_id/entities/waitlisted`     | responds with all entities from an embed that are waiting for manual approval
GET         | `/embeds/:embed_id/entities/:id`            | responds with details of the given entity.
PATCH       | `/embeds/:embed_id/entities/:id/disapprove` | removes the given entity from the list of approved entities for that embed.
DELETE      | `/embeds/:embed_id/entities/:id`            | entirely removes the given entity from the given embed.

Embed > Filters endpoint
------------------------

**Filters are used for moderation of incoming data.**

Only one blocking and one moderating filter can be
defined for each embed. 

The blocking filter prevents saving the incoming data,
and the moderating filter automatically approves an entity
if it satisfies the appropriate conditions.

HTTP Verb  | Endpoint                                    | Description
---------- | ------------------------------------------- | ---------------------------------------
GET        | `/embeds/:embed_id/filters`                 | responds with all filters for a given embed
GET        | `/embeds/:embed_id/filters/:id`             | responds with details of the given filter
POST       | `/embeds/:embed_id/filters`                 | creates a new filter for a given embed
PUT        | `/embeds/:embed_id/filters/:id`             | updates the existing filter for a given embed
DELETE     | `/embeds/:embed_id/filters/:id`             | destroys a filter

Embed > Services endpoint
------------------------

**Services represent the configuration for a given feed.**

Each feed, (for example Github, Facebook and Twitter) has to be 
configured so as to enable the crawler fetch data from those
feeds.

This configuration usually comes in the form of access tokens,
along with feed specific settings. For example, repositories to follow for
Github, Pages to follow for Facebook, user handles to follow for
Twitter

HTTP Verb  | Endpoint                                    | Description
---------- | ------------------------------------------- | ---------------------------------------
GET        | `/embeds/:embed_id/services`                 | responds with all filters for a given embed
GET        | `/embeds/:embed_id/services/:id`             | responds with details of the given filter
POST       | `/embeds/:embed_id/services`                 | creates a new filter for a given embed
PUT        | `/embeds/:embed_id/services/:id`             | updates the existing filter for a given embed
DELETE     | `/embeds/:embed_id/services/:id`             | destroys a filter

