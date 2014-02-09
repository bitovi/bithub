--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: intarray; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE achievements (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer NOT NULL,
    note character varying(255),
    achieved_at timestamp without time zone,
    shipped_at timestamp without time zone
);


--
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE achievements_id_seq OWNED BY achievements.id;


--
-- Name: anteups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE anteups (
    id integer NOT NULL,
    applies_to_id integer NOT NULL,
    actor_id integer NOT NULL,
    value integer,
    fullfilled boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: anteups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE anteups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anteups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE anteups_id_seq OWNED BY anteups.id;


--
-- Name: awards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE awards (
    id integer NOT NULL,
    applies_to_id integer NOT NULL,
    actor_id integer NOT NULL,
    value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: awards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE awards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: awards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE awards_id_seq OWNED BY awards.id;


--
-- Name: category_determination_rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE category_determination_rules (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    scorings hstore
);


--
-- Name: category_determination_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE category_determination_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_determination_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE category_determination_rules_id_seq OWNED BY category_determination_rules.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    iso character varying(255) NOT NULL,
    priority integer DEFAULT 0
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entities (
    id integer NOT NULL,
    title text,
    url text,
    body text,
    scoring_rule_id integer NOT NULL,
    feed_id integer NOT NULL,
    category_id integer NOT NULL,
    parent_id integer,
    origin_ts timestamp without time zone NOT NULL,
    thread_updated_ts timestamp without time zone NOT NULL,
    image character varying(255),
    cached_tag_list character varying(255),
    total_upvotes integer,
    props hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    feed_name character varying(255),
    type_name character varying(255),
    category_name character varying(255),
    type_id integer,
    origin_id character varying(255)
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entities_id_seq OWNED BY entities.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255),
    tagger_id integer,
    tagger_type character varying(255),
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    aliases character varying[],
    props hstore
);


--
-- Name: entity_aggregated_tag_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW entity_aggregated_tag_list AS
 SELECT e.id AS entity_id,
    string_agg((t.name)::text, ','::text) AS tag_list
   FROM entities e,
    tags t,
    taggings e_t
  WHERE ((e.id = e_t.taggable_id) AND (e_t.tag_id = t.id))
  GROUP BY e.id;


--
-- Name: entity_refs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entity_refs (
    id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL
);


--
-- Name: entity_refs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entity_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entity_refs_id_seq OWNED BY entity_refs.id;


--
-- Name: upvotes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE upvotes (
    id integer NOT NULL,
    applies_to_id integer NOT NULL,
    actor_id integer NOT NULL,
    value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: entity_total_upvotes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW entity_total_upvotes AS
 SELECT e.id AS entity_id,
    sum(u.value) AS upvotes_sum
   FROM entities e,
    upvotes u
  WHERE (e.id = u.applies_to_id)
  GROUP BY e.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    content_digest character varying(255) NOT NULL,
    props hstore,
    source_data text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type_name character varying(255),
    feed_name character varying(255),
    entity_id integer
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE identities (
    id integer NOT NULL,
    provider character varying(255),
    source_data text,
    user_id integer,
    uid bigint
);


--
-- Name: internals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE internals (
    id integer NOT NULL,
    actor_id integer,
    receiver_id integer NOT NULL,
    applies_to_id integer,
    value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    comment character varying(255)
);


--
-- Name: internals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE internals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE internals_id_seq OWNED BY internals.id;


--
-- Name: ownerships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ownerships (
    id integer NOT NULL,
    owner_id integer,
    entity_id integer,
    value integer,
    ownership_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    resource_id integer,
    resource_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: scoring_rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scoring_rules (
    id integer NOT NULL,
    required_tags character varying(255)[],
    authorship_value integer,
    award_value integer,
    upvote_value integer,
    priority integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_until timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    address character varying(255),
    city character varying(255),
    postal character varying(255),
    state character varying(255),
    props hstore,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    total_score integer DEFAULT 0
);


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_roles (
    user_id integer,
    role_id integer
);


--
-- Name: leaderboard; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW leaderboard AS
 SELECT users.id AS user_id,
    users.name AS user_name,
    users.email AS user_email,
    (users.props -> 'avatar_url'::text) AS user_gravatar_url,
    (((( SELECT COALESCE(sum(r.authorship_value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            scoring_rules r
          WHERE (((r.id = e.scoring_rule_id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id))) + ( SELECT COALESCE(sum(u.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            upvotes u
          WHERE (((u.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(a.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            awards a
          WHERE (((a.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(internals.value), (0)::bigint) AS "coalesce"
           FROM internals
          WHERE (internals.receiver_id = users.id))) AS user_score
   FROM (users
   JOIN users_roles ON ((users.id = users_roles.user_id)))
  WHERE ((users.name IS NOT NULL) AND ((users_roles.role_id IS NULL) OR (NOT (users_roles.role_id IN ( SELECT roles.id
      FROM roles
     WHERE (((roles.name)::text = 'bitovian'::text) OR ((roles.name)::text = 'admin'::text)))))))
  ORDER BY (((( SELECT COALESCE(sum(r.authorship_value), (0)::bigint) AS "coalesce"
      FROM entities e,
       ownerships o,
       scoring_rules r
     WHERE (((r.id = e.scoring_rule_id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id))) + ( SELECT COALESCE(sum(u.value), (0)::bigint) AS "coalesce"
      FROM entities e,
       ownerships o,
       upvotes u
     WHERE (((u.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(a.value), (0)::bigint) AS "coalesce"
      FROM entities e,
       ownerships o,
       awards a
     WHERE (((a.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(internals.value), (0)::bigint) AS "coalesce"
      FROM internals
     WHERE (internals.receiver_id = users.id))) DESC
  WITH NO DATA;


--
-- Name: ownerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ownerships_id_seq OWNED BY ownerships.id;


--
-- Name: pagination; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW pagination AS
 SELECT e.thread_updated_ts AS ts,
    e.id,
    categories.name AS category,
    ARRAY( SELECT t.name
           FROM taggings tt,
            tags t
          WHERE ((((tt.taggable_type)::text = 'Entity'::text) AND (tt.tag_id = t.id)) AND (tt.taggable_id = e.id))) AS tags
   FROM (entities e
   LEFT JOIN tags categories ON ((e.category_id = categories.id)))
  WHERE (e.parent_id IS NULL)
  ORDER BY e.thread_updated_ts DESC
  WITH NO DATA;


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    title character varying(255),
    description text,
    point_minimum integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image character varying(255),
    display_point_minimum character varying(255) DEFAULT ''::character varying,
    disabled_ts timestamp without time zone
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rules_id_seq OWNED BY scoring_rules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: upvotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE upvotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upvotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE upvotes_id_seq OWNED BY upvotes.id;


--
-- Name: user_total_score; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_total_score AS
 SELECT users.id AS user_id,
    (((( SELECT COALESCE(sum(o.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o
          WHERE ((e.id = o.entity_id) AND (o.owner_id = users.id))) + ( SELECT COALESCE(sum(u.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            upvotes u
          WHERE (((u.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(a.value), (0)::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            awards a
          WHERE (((a.applies_to_id = e.id) AND (e.id = o.entity_id)) AND (o.owner_id = users.id)))) + ( SELECT COALESCE(sum(i.value), (0)::bigint) AS "coalesce"
           FROM internals i
          WHERE (i.receiver_id = users.id))) AS score_sum
   FROM users;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements ALTER COLUMN id SET DEFAULT nextval('achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY anteups ALTER COLUMN id SET DEFAULT nextval('anteups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards ALTER COLUMN id SET DEFAULT nextval('awards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_determination_rules ALTER COLUMN id SET DEFAULT nextval('category_determination_rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities ALTER COLUMN id SET DEFAULT nextval('entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY entity_refs ALTER COLUMN id SET DEFAULT nextval('entity_refs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY internals ALTER COLUMN id SET DEFAULT nextval('internals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ownerships ALTER COLUMN id SET DEFAULT nextval('ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scoring_rules ALTER COLUMN id SET DEFAULT nextval('rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY upvotes ALTER COLUMN id SET DEFAULT nextval('upvotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: anteups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY anteups
    ADD CONSTRAINT anteups_pkey PRIMARY KEY (id);


--
-- Name: awards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_pkey PRIMARY KEY (id);


--
-- Name: category_determination_rules_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY category_determination_rules
    ADD CONSTRAINT category_determination_rules_name_key UNIQUE (name);


--
-- Name: category_determination_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY category_determination_rules
    ADD CONSTRAINT category_determination_rules_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: entity_refs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entity_refs
    ADD CONSTRAINT entity_refs_pkey PRIMARY KEY (id);


--
-- Name: entity_refs_unique_from_to; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entity_refs
    ADD CONSTRAINT entity_refs_unique_from_to UNIQUE (from_id, to_id);


--
-- Name: events_hash_key_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_hash_key_key UNIQUE (content_digest);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: internals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_pkey PRIMARY KEY (id);


--
-- Name: ownerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scoring_rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: upvotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT upvotes_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: entity_refs_on_from_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX entity_refs_on_from_id ON entity_refs USING btree (from_id);


--
-- Name: entity_refs_on_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX entity_refs_on_to_id ON entity_refs USING btree (to_id);


--
-- Name: index_events_on_props; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_props ON events USING gist (props);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON roles USING btree (name, resource_type, resource_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_upvotes_on_applies_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_upvotes_on_applies_to_id ON upvotes USING btree (applies_to_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON users_roles USING btree (user_id, role_id);


--
-- Name: unique_hash_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_hash_key ON events USING btree (content_digest);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_anteups_entities; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY anteups
    ADD CONSTRAINT fk_anteups_entities FOREIGN KEY (applies_to_id) REFERENCES entities(id);


--
-- Name: fk_anteups_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY anteups
    ADD CONSTRAINT fk_anteups_users FOREIGN KEY (actor_id) REFERENCES users(id);


--
-- Name: fk_awards_entities; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT fk_awards_entities FOREIGN KEY (applies_to_id) REFERENCES entities(id);


--
-- Name: fk_awards_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT fk_awards_users FOREIGN KEY (actor_id) REFERENCES users(id);


--
-- Name: fk_entities_category_tags; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT fk_entities_category_tags FOREIGN KEY (category_id) REFERENCES tags(id);


--
-- Name: fk_entities_feed_tags; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT fk_entities_feed_tags FOREIGN KEY (feed_id) REFERENCES tags(id);


--
-- Name: fk_entities_scoring_rules; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT fk_entities_scoring_rules FOREIGN KEY (scoring_rule_id) REFERENCES scoring_rules(id);


--
-- Name: fk_entities_type_tags; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT fk_entities_type_tags FOREIGN KEY (type_id) REFERENCES tags(id);


--
-- Name: fk_internals_actor_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT fk_internals_actor_users FOREIGN KEY (actor_id) REFERENCES users(id);


--
-- Name: fk_internals_receiver_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT fk_internals_receiver_users FOREIGN KEY (receiver_id) REFERENCES users(id);


--
-- Name: fk_ownerships_entities; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT fk_ownerships_entities FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: fk_ownerships_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT fk_ownerships_users FOREIGN KEY (owner_id) REFERENCES users(id);


--
-- Name: fk_upvotes_entities; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT fk_upvotes_entities FOREIGN KEY (applies_to_id) REFERENCES entities(id);


--
-- Name: fk_upvotes_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT fk_upvotes_users FOREIGN KEY (actor_id) REFERENCES users(id);


--
-- Name: fk_users_countries; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_countries FOREIGN KEY (country_id) REFERENCES countries(id);


--
-- Name: fk_users_rewards_rewards; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT fk_users_rewards_rewards FOREIGN KEY (reward_id) REFERENCES rewards(id);


--
-- Name: fk_users_rewards_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT fk_users_rewards_users FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130126192030');

INSERT INTO schema_migrations (version) VALUES ('20130226163527');

INSERT INTO schema_migrations (version) VALUES ('20130226163634');

INSERT INTO schema_migrations (version) VALUES ('20130226164246');

INSERT INTO schema_migrations (version) VALUES ('20130226172229');

INSERT INTO schema_migrations (version) VALUES ('20130226172258');

INSERT INTO schema_migrations (version) VALUES ('20130226172558');

INSERT INTO schema_migrations (version) VALUES ('20130226172658');

INSERT INTO schema_migrations (version) VALUES ('20130226172928');

INSERT INTO schema_migrations (version) VALUES ('20130226173857');

INSERT INTO schema_migrations (version) VALUES ('20130226174642');

INSERT INTO schema_migrations (version) VALUES ('20130226200831');

INSERT INTO schema_migrations (version) VALUES ('20130304111726');

INSERT INTO schema_migrations (version) VALUES ('20130304122257');

INSERT INTO schema_migrations (version) VALUES ('20130305172111');

INSERT INTO schema_migrations (version) VALUES ('20130429181415');

INSERT INTO schema_migrations (version) VALUES ('20130429201314');

INSERT INTO schema_migrations (version) VALUES ('20130520040320');

INSERT INTO schema_migrations (version) VALUES ('20130607045446');

INSERT INTO schema_migrations (version) VALUES ('20130617164515');

INSERT INTO schema_migrations (version) VALUES ('20130618110729');

INSERT INTO schema_migrations (version) VALUES ('20130716113111');

INSERT INTO schema_migrations (version) VALUES ('20130723090829');

INSERT INTO schema_migrations (version) VALUES ('20130726125946');

INSERT INTO schema_migrations (version) VALUES ('20130805155441');

INSERT INTO schema_migrations (version) VALUES ('20130805160253');

INSERT INTO schema_migrations (version) VALUES ('20130905102324');

INSERT INTO schema_migrations (version) VALUES ('20130905102701');

INSERT INTO schema_migrations (version) VALUES ('20130905142638');

INSERT INTO schema_migrations (version) VALUES ('20130910111148');

INSERT INTO schema_migrations (version) VALUES ('20130916130332');

INSERT INTO schema_migrations (version) VALUES ('20130924211203');

INSERT INTO schema_migrations (version) VALUES ('20130926121052');

INSERT INTO schema_migrations (version) VALUES ('20131018093050');

INSERT INTO schema_migrations (version) VALUES ('20131121163548');

INSERT INTO schema_migrations (version) VALUES ('20131126091928');

INSERT INTO schema_migrations (version) VALUES ('20131126103121');

INSERT INTO schema_migrations (version) VALUES ('20131126103556');

INSERT INTO schema_migrations (version) VALUES ('20131127171009');

INSERT INTO schema_migrations (version) VALUES ('20131203191031');

INSERT INTO schema_migrations (version) VALUES ('20131206133159');

INSERT INTO schema_migrations (version) VALUES ('20131208111213');

INSERT INTO schema_migrations (version) VALUES ('20131209113732');

INSERT INTO schema_migrations (version) VALUES ('20131209113804');

INSERT INTO schema_migrations (version) VALUES ('20131212151917');

INSERT INTO schema_migrations (version) VALUES ('20131212151919');

INSERT INTO schema_migrations (version) VALUES ('20131212152143');

INSERT INTO schema_migrations (version) VALUES ('20131212152203');

INSERT INTO schema_migrations (version) VALUES ('20131212152452');

INSERT INTO schema_migrations (version) VALUES ('20140119061002');

INSERT INTO schema_migrations (version) VALUES ('20140123003102');

INSERT INTO schema_migrations (version) VALUES ('20140123003458');

INSERT INTO schema_migrations (version) VALUES ('20140123005015');

INSERT INTO schema_migrations (version) VALUES ('20140123185242');

INSERT INTO schema_migrations (version) VALUES ('20140130154056');

INSERT INTO schema_migrations (version) VALUES ('20140130162354');

INSERT INTO schema_migrations (version) VALUES ('20140203135744');

INSERT INTO schema_migrations (version) VALUES ('20151212162518');

INSERT INTO schema_migrations (version) VALUES ('20151212162523');

INSERT INTO schema_migrations (version) VALUES ('20151212162524');