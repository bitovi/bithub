
# Query Logic #

### Features ###

1. filtering
  - nested objects
  - null and existance
2. ordering
  - by nested objects
3. iteration & pagination
2. grouping
  - by nested objects

### Syntax rules (proposal) ###


```
params    = <param> *("&" <param>)
param     = <equation> / <embed> / <order> / <group> / <limit> / <offset>
          ; "embed", "order", "group", "limit" and "offset" are reserved keywords

equation  = <attribute> "=" [!] <value>
embed     = "embed" ["[]"] "=" <attribute>
order     = "order" ["[]"] "=" <attribute> [":asc" / ":desc"] ; ":asc" by default
group     = "group" ["[]"] "=" <attribute>
limit     = "limit=" 1*DIGIT
offset    = "offset=" 1*DIGIT

attribute = 1*(ALPHANUM / ".")

value     = "null" / "exists" / <input> / <range> / <or> / <func>
          ; "null" and "exists" are reserved keywords
range     = (<input> ".." <input>) / (<input> "..") / (".." <input>)
or        = <input> *("|" <input>)
func      = <funcname> "(" *<args> ")"
input     = 1*("%" / ALPHANUM)
          ; "%" is reserved keyword for sequence of characters (hint: SQL LIKE)
		  ; todo: "%" is already used for escaping!
          ; todo: think about valid characters

ALPHANUM  = ALPHA / DIGIT

```

### Examples ###

#### Models ####

__Question model__
- id
- question
- explanation
- user_id
- created_at
- accepted_id

__Answer model__
- id
- question_id
- answer
- user_id
- accepted

__User model__
- id
- name
- email

#### Queries ####

__Filtering__

Find by id:
`/questions?id=123`

Filter by param:
`/questions?question=foobar`

Filter by matching param:
`/questions?question=%foobar%`

Filter by range:
`/questions?id=100..`
`/questions?id=100..200`
`/questions?id=..200`

Joining: (embed)
`/questions?embed=users`
`/questions?embed[]=users&embed[]=answers&embed[]=answers.users`

Accessing nested objects:
`/questions?embed=users&user.name=veljko`

Negation:
`/questions?question=!%foobar%`

__Existance__

NULL awareness, NULL should be reservered keyword
`/questions?accepted_id=null`
`/questions?accepted_id=!null`

hstore and json support for existance, find out other way than using 'exists'
`/questions?accepted_id=exists`
`/questions?accepted_id=!exists`

__Ordering__

asc:
`/questions?order=name`
`/questions?order=name:asc`

desc:
`/questions?order=name:desc`

nested:
`/questions?order=user.name:desc`

multiple parmas:
`/questions?order[]=user.name:asc&order[]=created_at:desc`

__Iteration and pagination__

`/questions?limit=50&offset=100`
... or via headers? -> http://tools.ietf.org/html/rfc5988#page-6


__Versioning__
