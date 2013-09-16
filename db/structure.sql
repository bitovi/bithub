--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
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
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    iso character varying(255) NOT NULL
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
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    hash_key character varying(255) NOT NULL,
    title text,
    url text,
    body text,
    author_id integer,
    rule_id integer NOT NULL,
    parent_id integer,
    feed_id integer NOT NULL,
    category_id integer NOT NULL,
    origin_ts timestamp without time zone NOT NULL,
    origin_date date NOT NULL,
    props hstore,
    source_data text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image character varying(255),
    thread_updated_at timestamp without time zone,
    thread_updated_date date
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
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE identities_id_seq OWNED BY identities.id;


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
-- Name: leaderboard; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE leaderboard (
    user_id integer,
    user_name character varying(255),
    user_email character varying(255),
    user_gravatar_url character varying(255),
    user_score integer
);


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
-- Name: rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rules (
    id integer NOT NULL,
    required_tags character varying(255)[],
    authorship_value integer,
    award_value integer,
    upvote_value integer,
    priority integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


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

ALTER SEQUENCE rules_id_seq OWNED BY rules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


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
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    aliases character varying[],
    priority integer
);


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
    last_sign_in_ip character varying(255)
);


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
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_roles (
    user_id integer,
    role_id integer
);


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

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY identities ALTER COLUMN id SET DEFAULT nextval('identities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY internals ALTER COLUMN id SET DEFAULT nextval('internals_id_seq'::regclass);


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

ALTER TABLE ONLY rules ALTER COLUMN id SET DEFAULT nextval('rules_id_seq'::regclass);


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
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: internals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_pkey PRIMARY KEY (id);


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

ALTER TABLE ONLY rules
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
-- Name: unique_uid_provider_combination; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY identities
    ADD CONSTRAINT unique_uid_provider_combination UNIQUE (provider, uid);


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
-- Name: index_events_on_thread_updated_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_thread_updated_date ON events USING btree (thread_updated_date);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_identities_on_user_id ON identities USING btree (user_id);


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

CREATE UNIQUE INDEX unique_hash_key ON events USING btree (hash_key);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_anteups_events; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY anteups
    ADD CONSTRAINT fk_anteups_events FOREIGN KEY (applies_to_id) REFERENCES events(id);


--
-- Name: fk_anteups_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY anteups
    ADD CONSTRAINT fk_anteups_users FOREIGN KEY (actor_id) REFERENCES users(id);


--
-- Name: fk_awards_events; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT fk_awards_events FOREIGN KEY (applies_to_id) REFERENCES events(id);


--
-- Name: fk_awards_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT fk_awards_users FOREIGN KEY (actor_id) REFERENCES users(id);


--
-- Name: fk_events_category_tags; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_events_category_tags FOREIGN KEY (category_id) REFERENCES tags(id);


--
-- Name: fk_events_feed_tags; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_events_feed_tags FOREIGN KEY (feed_id) REFERENCES tags(id);


--
-- Name: fk_events_rules; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_events_rules FOREIGN KEY (rule_id) REFERENCES rules(id);


--
-- Name: fk_events_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_events_users FOREIGN KEY (author_id) REFERENCES users(id);


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
-- Name: fk_upvotes_events; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT fk_upvotes_events FOREIGN KEY (applies_to_id) REFERENCES events(id);


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

INSERT INTO schema_migrations (version) VALUES ('20130510181611');

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