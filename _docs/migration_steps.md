
### bithub.com data migration to multitenant Bithub ###

**Preparations**

- Remove countries FK on users
- (Remove scoring_rules FK on entities)


**Backup**

Make backup on production, download it and import into newly created db:

1. `./bin/cap prod db:backup`
2. `./bin/cap prod db:download -s version=...`
3. ...restore


**Restore**

Create new tenant named `bitovi`!

Delete prepopulated tables:

1. `SET search_path=bitovi; DELETE FROM taggings; DELETE FROM tags; DELETE FROM scoring_rules;`
2. `SET search_path=public; DELETE FROM countries;`

Dump data and restore into public:

1. `pg_dump -a -x -O -n public -t users -t identities -t countries bithub2 > public.sql`
2. `psql bithub < public.sql`

Migrate some tables manually because of changes in db model:

1. Update search_path to tenant name
2. `psql bithub < scoring_rules.sql`
3. `psql bithub < rewards.sql`

Dump data and restore into tenant/bithub schema:

1. `pg_dump -a -x -O -n public -t tags -t events -t entities -t upvotes -t ownerships -t awards -t internals -t taggings -t user_roles -t achievements bithub2 > tenant.sql`
3. Update search_path to tenant name!!!
4. (change events.source_data type to text)
5. (add entities.category_id and entities.category_name attrs)
6. `psql bithub < tenant.sql`

Revert changes from previous step

1. `ALTER TABLE bitovi.events ALTER COLUMN source_data TYPE JSON USING source_data::JSON;`
2. `ALTER TABLE bitovi.entities DROP COLUMN category_id;`
3. `ALTER TABLE bitovi.entities DROP COLUMN category_name;`

Join users to bitovi brand

1. `User.all.each {|u| u.join_brand(:bitovi); u.save}`

Update imported tags

1. `TENANT=bitovi ./bin/rake data:import_or_update_tags`
2. Connect brand identities and check tags!
3. Change feed_name on forum entites to rss
4. bitovian.user_ids = [3, 33, 2, 14, 298, 94, 144, 59, 30, 214, 37, 168, 142, 309, 64, 47, 141, 60, 66, 25, 61, 589, 35]
=> [3, 33, 2, 14, 298, 94, 144, 59, 30, 214, 37, 168, 142, 309, 64, 47, 141, 60, 66, 25, 61, 589, 35]

Check sequences!!!

Flush redis!!!


**Existing tables on production**

- achievements
- anteups
- api_cache
- awards
- category_determination_rules
- countries
- delayed_jobs
- entities
- entity_refs
- events
- identities
- internals
- ownerships
- rewards
- roles
- schema_migrations
- scoring_rules
- taggings
- tags
- upvotes
- users
- user_roles
