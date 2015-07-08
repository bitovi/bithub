Moderation
==========

There are two ways to influence the final approved/blocked state of the card. Those are:

1. Default settings
2. Moderation rules

Default settings
----------------

**Both hubs and services have a "default" setting** which determines the approved/blocked state of incoming items. If there are no moderation rules defined, the default setting is the one that determines the final approved/blocked state of the card.

Hubs can be set to either approve or block by default:

<screenshot>

Services can be either neutral or be set to approve by default:

<screenshot>

The following table defines the interplay between hub and service default settings when there are no moderation rules:

| Hub default | Service default | Final state |
|:-----------:|-----------------|-------------|
| approved    | approved        | approved    |
| approved    | n/a             | approved    |
| blocked     | approved        | approved    |
| blocked     | n/a             | blocked     | 

It has to be noted that if a service is set to approve by default, only items coming from that service will be approved. All other items in a hub will respect the hub's default setting.

Moderation rules
----------------

Moderation rules are essentially filters that either let items pass or the block them. Definition of a rule determines whether a certain item will be caught by that rule, and the type of the rule (either blocking or approving) determines the result.

When there are moderation rules defined, default settings are still respected for all items not caught by any of the rules.

Rules are applied in the following order:

1. All approving (green) rules
2. All blocking (red) rules

Blocking rules take precedence over approving rules, meaning that if something is approved by an approving rule, and blocked by another blocking rule, the resulting state will be 'blocked'.

| Approved by a rule | Blocked by rule | Final state                   |
|--------------------|-----------------|-------------------------------|
| no                 | no              | determined by default setting |
| no                 | yes             | blocked                       |
| yes                | no              | approved                      |
| yes                | yes             | blocked                       |


Example
-------

Defaults: 

* Hub 'Example' set to block by default
* Service 'Tweets containing #freebie' (set to approve by default)
* Service 'Tweets from @company's timeline' (no default)

Rules:

1. Block all items containing a hashtag #selfie.
2. Approve all items from a @customer.

Results:

* Tweet "Hey everyone, I got a nice #freebie" would be approved by service default.
* Tweet "I'm awesome with my new #freebie product #selfie" would be blocked by rule #1.
* Tweet from @customer "I'm liking this new product from @company" would be approved by rule #2.
* Tweet from @customer "This new #product looks bad on me #selfie" would be blocked by rule #1 (precedence over rule #2).
* Tweet "Hey @company, where's my free #product?" would be blocked by hub default.
