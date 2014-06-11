Bithub backend Arhitecture
====

Components
----
* crawler
* web service
* listener
* irc bot
* liveservice

Input stream
----

Listener component connects to RabbitMQ and listens for new messages sent from __Crawler__ component. 

Messages must have payload structure as follows: 

```javacript
{
  meta: {
    brand_name: "bitovi",
    feed_name: "twitter",
    type_name: "tweet"
  },
  source_data: {...},
  content_digest: "..."
}
```

`source data` contains original message fetched from feed, while `content_digest` is unique identifier of each event and is used to prevent data duplication.

New messages are logged and passed to the `Dispatcher`.

Data model
----

__Why events and entities?__
* mutability + lot of different input sources = you're gonna have a bad time
* accountability of changes
* entity and event are abstract classes, each feed/type has it's own implementation and specific tagging, categorization, etc.

To unify and store data we've built double layered system, __events__ and __entities__ (probaby not the best naming).

### Events ###

Events are used to store (unchanged) raw messages from MQ, table structure follows message object structure. Events are kind-of __immutable__, once saved events shouldn't be altered any time afterwards. Basically we can think of events table as kind-of transactional log.

Each event can produce new entity or update existing one! (entity_id ref)

column | data type
:--- | :---
feed_name | string
type_name | string
content_digest | string
source_data | json
entity_id | int
_other_columns_of_some_type_ |

### Entities ###

In entities table we store processed events, to make it clearer, some values like title,body,url are extracted from event's source_data, tags and authors are determined, threads are created, etc.

Entities are actual data that is accessible through API, events aren't, they are only used internaly.

Also, entities shouldn't be altered manually at any time, they should be altered only by creating new event!

column | data type
:--- | :---
title | string
body | string
url | string
origin_id | string
tag_list | string
props | hstore
_other_columns_of_some_type_ |

### Data peristance ###

Our key requirements are data consistency, strong relations with constraints and certain flexibily with table definitions. 

Postgresql 9.3 satisfies our needs, it's open source, very mature and widely used ORDB. It provide us needed level of flexibily with hstore and json data types.

### Multitenancy ###

Multitenacy requires certian level of isolation among data, we use postgresql schemas for that. Data shared among tenats is kept in public schema, while each tenant gets it's own schema after it (e.g. bitovi).

schemas = namespaces for a database (or directory for a database)

(Another approach would be to have additional columns in every table or multiple table recognized by prefixes, but schemas seem as way better approach)

### Other domain models ###

- users and (oauth) identities
- ownerships
- tags and taggings
- upvotes, awards
- rewards and achievements
- accounts, brands and brand identities
- feed and brand configs
- ... and many others

Dispatcher
----

Dispatching received event goes through few steps, at the end an event can be saved or rejected in one of the steps. 

For dispatch to be successful both, events and entity, must be saved within same database transaction. 

Here are the steps for event dispatch:

1. __build__ - wraps raw source_data into object
2. __validate__
3. __persist__ - saves event object to database

After that goes entity dispatch:

1. __procure__ - find existing or create new entity object
2. __update_if_found__ - if existing than update it
3. __validate__
4. __determine__ - determine tags, author, scoring rule, etc
5. __group__ - check if it is part of some kind of thread (e.g. question, answer, comment)
6. __normalize__ - clean up meta data that was generated in previous steps
7. __perists__ - finaly saves entity object to database

If both dispatches are succesful event and entity objects should be saved to database, if something fails the whole transaction is rolled back. (e.g. unknow data type)

API
----

Just to note some basic features:
- responds to CRUD
- pagination (limit/offset params)
- query logic (filtering, ordering, grouping, ...)

