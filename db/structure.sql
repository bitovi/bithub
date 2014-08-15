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
-- Name: bitovi; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA bitovi;


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


SET search_path = bitovi, pg_catalog;

--
-- Name: account_roles_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE account_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: achievements; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
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
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE achievements_id_seq OWNED BY achievements.id;


--
-- Name: api_cache; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE api_cache (
    id integer NOT NULL,
    provider character varying(255),
    name character varying(255),
    uid character varying(255)
);


--
-- Name: api_cache_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE api_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE api_cache_id_seq OWNED BY api_cache.id;


--
-- Name: awards; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE awards (
    id integer NOT NULL,
    applies_to_id integer NOT NULL,
    actor_id integer NOT NULL,
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: awards_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE awards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: awards_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE awards_id_seq OWNED BY awards.id;


--
-- Name: brand_identities_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE brand_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE brands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_users_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE brands_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE entities (
    id integer NOT NULL,
    title text,
    url text,
    body text,
    origin_id character varying(255),
    feed_name character varying(255),
    type_name character varying(255),
    scoring_rule_id integer NOT NULL,
    feed_id integer NOT NULL,
    type_id integer NOT NULL,
    parent_id integer,
    origin_ts timestamp without time zone NOT NULL,
    thread_updated_ts timestamp without time zone NOT NULL,
    image character varying(255),
    cached_tag_list character varying(255),
    total_upvotes integer,
    props public.hstore DEFAULT ''::public.hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE entities_id_seq OWNED BY entities.id;


--
-- Name: taggings; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
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
-- Name: tags; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    aliases character varying(255)[] DEFAULT '{}'::character varying[],
    props public.hstore DEFAULT ''::public.hstore,
    taggings_count integer DEFAULT 0
);


--
-- Name: entity_aggregated_tag_list; Type: VIEW; Schema: bitovi; Owner: -
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
-- Name: entity_refs; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE entity_refs (
    id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL
);


--
-- Name: entity_refs_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE entity_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_refs_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE entity_refs_id_seq OWNED BY entity_refs.id;


--
-- Name: upvotes; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE upvotes (
    id integer NOT NULL,
    applies_to_id integer NOT NULL,
    actor_id integer NOT NULL,
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: entity_total_upvotes; Type: VIEW; Schema: bitovi; Owner: -
--

CREATE VIEW entity_total_upvotes AS
 SELECT e.id AS entity_id, 
    sum(u.value) AS upvotes_sum
   FROM entities e, 
    upvotes u
  WHERE (e.id = u.applies_to_id)
  GROUP BY e.id;


--
-- Name: events; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    type_name character varying(255),
    feed_name character varying(255),
    content_digest character varying(255),
    props public.hstore DEFAULT ''::public.hstore,
    entity_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    source_data json
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: feed_configs_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE feed_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnel_constraints; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE funnel_constraints (
    id integer NOT NULL,
    feed_name character varying(255),
    type_name character varying(255),
    tags character varying(255)[] DEFAULT '{}'::character varying[]
);


--
-- Name: funnel_constraints_funnels; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE funnel_constraints_funnels (
    funnel_id integer,
    funnel_constraint_id integer
);


--
-- Name: funnel_constraints_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE funnel_constraints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnel_constraints_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE funnel_constraints_id_seq OWNED BY funnel_constraints.id;


--
-- Name: funnels; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE funnels (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    tags character varying(255)[] DEFAULT '{}'::character varying[],
    props public.hstore DEFAULT ''::public.hstore,
    "position" integer
);


--
-- Name: funnels_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE funnels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnels_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE funnels_id_seq OWNED BY funnels.id;


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internals; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE internals (
    id integer NOT NULL,
    actor_id integer,
    receiver_id integer NOT NULL,
    applies_to_id integer,
    variant character varying(255),
    comment character varying(255),
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: internals_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE internals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internals_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE internals_id_seq OWNED BY internals.id;


--
-- Name: ownerships; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE ownerships (
    id integer NOT NULL,
    owner_id integer,
    entity_id integer,
    value integer,
    ownership_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ownerships_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE ownerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ownerships_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE ownerships_id_seq OWNED BY ownerships.id;


--
-- Name: pagination; Type: MATERIALIZED VIEW; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW pagination AS
 SELECT e.thread_updated_ts AS ts, 
    e.id, 
    (string_to_array((e.cached_tag_list)::text, ', '::text))::character varying[] AS tags, 
    funnels.name AS funnel
   FROM (entities e
   LEFT JOIN ( SELECT f.name, 
            fc.feed_name, 
            fc.type_name, 
            f.tags
           FROM ((funnels f
      LEFT JOIN funnel_constraints_funnels fcf ON ((fcf.funnel_id = f.id)))
   LEFT JOIN funnel_constraints fc ON ((fcf.funnel_constraint_id = fc.id)))) funnels ON (((((e.feed_name)::text = (funnels.feed_name)::text) AND ((e.type_name)::text = (funnels.type_name)::text)) AND ((funnels.tags = '{}'::character varying[]) OR (funnels.tags && (string_to_array((e.cached_tag_list)::text, ', '::text))::character varying[])))))
  WHERE (e.parent_id IS NULL)
  ORDER BY e.thread_updated_ts DESC
  WITH NO DATA;


--
-- Name: rewards; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    title character varying(255),
    description text,
    point_minimum integer,
    image character varying(255),
    disabled_ts timestamp without time zone,
    props public.hstore DEFAULT ''::public.hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scoring_rules; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE scoring_rules (
    id integer NOT NULL,
    name character varying(255),
    required_tags public.hstore DEFAULT ''::public.hstore,
    authorship_value integer DEFAULT 0,
    award_value integer DEFAULT 0,
    upvote_value integer DEFAULT 0,
    props public.hstore DEFAULT ''::public.hstore,
    "position" integer,
    valid_until timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: scoring_rules_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE scoring_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scoring_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE scoring_rules_id_seq OWNED BY scoring_rules.id;


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: upvotes_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE upvotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upvotes_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE upvotes_id_seq OWNED BY upvotes.id;


--
-- Name: user_activities; Type: MATERIALIZED VIEW; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW user_activities AS
        (         SELECT 'Entity'::text AS model_name, 
                    entities.id, 
                    ownerships.owner_id AS user_id, 
                    ownerships.ownership_type, 
                    entities.title, 
                    (entities.total_upvotes + scoring_rules.authorship_value) AS value, 
                    entities.origin_ts AS ts, 
                    entities.cached_tag_list AS tags
                   FROM ((entities
              JOIN ownerships ON ((ownerships.entity_id = entities.id)))
         JOIN scoring_rules ON ((scoring_rules.id = entities.scoring_rule_id)))
        UNION 
                 SELECT 'Internal'::text AS model_name, 
                    internals.id, 
                    internals.receiver_id AS user_id, 
                    NULL::character varying AS ownership_type, 
                    internals.comment AS title, 
                    internals.value, 
                    internals.created_at AS ts, 
                    ''::character varying AS tags
                   FROM internals)
UNION 
         SELECT 'Upvote'::text AS model_name, 
            upvotes.id, 
            upvotes.actor_id AS user_id, 
            NULL::character varying AS ownership_type, 
            entities.title, 
            0 AS value, 
            upvotes.created_at AS ts, 
            ''::character varying AS tags
           FROM (upvotes
      JOIN entities ON ((upvotes.applies_to_id = entities.id)))
  WITH NO DATA;


--
-- Name: user_roles; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    name character varying(255),
    resource_id integer,
    resource_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: bitovi; Owner: -
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


SET search_path = public, pg_catalog;

--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    address character varying(255),
    address2 character varying(255),
    city character varying(255),
    postal character varying(255),
    state character varying(255),
    props hstore DEFAULT ''::hstore,
    total_score integer DEFAULT 0,
    country_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255)
);


SET search_path = bitovi, pg_catalog;

--
-- Name: user_total_score; Type: VIEW; Schema: bitovi; Owner: -
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
   FROM public.users;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: bitovi; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_roles; Type: TABLE; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE TABLE users_user_roles (
    user_id integer,
    user_role_id integer
);


SET search_path = public, pg_catalog;

--
-- Name: account_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_roles (
    id integer NOT NULL,
    name character varying(255),
    resource_id integer,
    resource_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: account_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_roles_id_seq OWNED BY account_roles.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    name character varying(255),
    props hstore DEFAULT ''::hstore,
    brand_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255)
);


--
-- Name: accounts_account_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts_account_roles (
    account_id integer,
    account_role_id integer
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


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
-- Name: api_cache; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_cache (
    id integer NOT NULL,
    provider character varying(255),
    name character varying(255),
    uid character varying(255)
);


--
-- Name: api_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_cache_id_seq OWNED BY api_cache.id;


--
-- Name: awards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE awards (
    id integer NOT NULL,
    applies_to_id integer NOT NULL,
    actor_id integer NOT NULL,
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: brand_identities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brand_identities (
    id integer NOT NULL,
    provider character varying(255),
    uid character varying(255),
    source_data json DEFAULT '{}'::json,
    brand_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: brand_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brand_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brand_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brand_identities_id_seq OWNED BY brand_identities.id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brands (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    keywords character varying(255)[] DEFAULT '{}'::character varying[],
    props hstore DEFAULT ''::hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tenant_name character varying(255)
);


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brands_id_seq OWNED BY brands.id;


--
-- Name: brands_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brands_users (
    id integer NOT NULL,
    user_id integer,
    brand_id integer,
    total_score integer DEFAULT 0,
    props hstore DEFAULT ''::hstore
);


--
-- Name: brands_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brands_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brands_users_id_seq OWNED BY brands_users.id;


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
-- Name: entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entities (
    id integer NOT NULL,
    title text,
    url text,
    body text,
    origin_id character varying(255),
    feed_name character varying(255),
    type_name character varying(255),
    scoring_rule_id integer NOT NULL,
    feed_id integer NOT NULL,
    type_id integer NOT NULL,
    parent_id integer,
    origin_ts timestamp without time zone NOT NULL,
    thread_updated_ts timestamp without time zone NOT NULL,
    image character varying(255),
    cached_tag_list character varying(255),
    total_upvotes integer,
    props hstore DEFAULT ''::hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    aliases character varying(255)[] DEFAULT '{}'::character varying[],
    props hstore DEFAULT ''::hstore,
    taggings_count integer DEFAULT 0
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    type_name character varying(255),
    feed_name character varying(255),
    content_digest character varying(255),
    props hstore DEFAULT ''::hstore,
    source_data json,
    entity_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: feed_configs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feed_configs (
    id integer NOT NULL,
    brand_id integer,
    feed_name character varying(255),
    config json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: feed_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feed_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feed_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feed_configs_id_seq OWNED BY feed_configs.id;


--
-- Name: funnel_constraints; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE funnel_constraints (
    id integer NOT NULL,
    feed_name character varying(255),
    type_name character varying(255),
    tags character varying(255)[] DEFAULT '{}'::character varying[]
);


--
-- Name: funnel_constraints_funnels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE funnel_constraints_funnels (
    funnel_id integer,
    funnel_constraint_id integer
);


--
-- Name: funnel_constraints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE funnel_constraints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnel_constraints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE funnel_constraints_id_seq OWNED BY funnel_constraints.id;


--
-- Name: funnels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE funnels (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    tags character varying(255)[] DEFAULT '{}'::character varying[],
    props hstore DEFAULT ''::hstore,
    "position" integer
);


--
-- Name: funnels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE funnels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE funnels_id_seq OWNED BY funnels.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE identities (
    id integer NOT NULL,
    provider character varying(255),
    source_data json DEFAULT '{}'::json,
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
    variant character varying(255),
    comment character varying(255),
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
    (string_to_array((e.cached_tag_list)::text, ', '::text))::character varying[] AS tags, 
    funnels.name AS funnel
   FROM (entities e
   LEFT JOIN ( SELECT f.name, 
            fc.feed_name, 
            fc.type_name, 
            f.tags
           FROM ((funnels f
      LEFT JOIN funnel_constraints_funnels fcf ON ((fcf.funnel_id = f.id)))
   LEFT JOIN funnel_constraints fc ON ((fcf.funnel_constraint_id = fc.id)))) funnels ON (((((e.feed_name)::text = (funnels.feed_name)::text) AND ((e.type_name)::text = (funnels.type_name)::text)) AND ((funnels.tags = '{}'::character varying[]) OR (funnels.tags && (string_to_array((e.cached_tag_list)::text, ', '::text))::character varying[])))))
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
    image character varying(255),
    disabled_ts timestamp without time zone,
    props hstore DEFAULT ''::hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scoring_rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scoring_rules (
    id integer NOT NULL,
    name character varying(255),
    required_tags hstore DEFAULT ''::hstore,
    authorship_value integer DEFAULT 0,
    award_value integer DEFAULT 0,
    upvote_value integer DEFAULT 0,
    props hstore DEFAULT ''::hstore,
    "position" integer,
    valid_until timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: scoring_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scoring_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scoring_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scoring_rules_id_seq OWNED BY scoring_rules.id;


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
-- Name: user_activities; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW user_activities AS
        (         SELECT 'Entity'::text AS model_name, 
                    entities.id, 
                    ownerships.owner_id AS user_id, 
                    ownerships.ownership_type, 
                    entities.title, 
                    (entities.total_upvotes + scoring_rules.authorship_value) AS value, 
                    entities.origin_ts AS ts, 
                    entities.cached_tag_list AS tags
                   FROM ((entities
              JOIN ownerships ON ((ownerships.entity_id = entities.id)))
         JOIN scoring_rules ON ((scoring_rules.id = entities.scoring_rule_id)))
        UNION 
                 SELECT 'Internal'::text AS model_name, 
                    internals.id, 
                    internals.receiver_id AS user_id, 
                    NULL::character varying AS ownership_type, 
                    internals.comment AS title, 
                    internals.value, 
                    internals.created_at AS ts, 
                    ''::character varying AS tags
                   FROM internals)
UNION 
         SELECT 'Upvote'::text AS model_name, 
            upvotes.id, 
            upvotes.actor_id AS user_id, 
            NULL::character varying AS ownership_type, 
            entities.title, 
            0 AS value, 
            upvotes.created_at AS ts, 
            ''::character varying AS tags
           FROM (upvotes
      JOIN entities ON ((upvotes.applies_to_id = entities.id)))
  WITH NO DATA;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    name character varying(255),
    resource_id integer,
    resource_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


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
-- Name: users_user_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users_user_roles (
    user_id integer,
    user_role_id integer
);


SET search_path = bitovi, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY achievements ALTER COLUMN id SET DEFAULT nextval('achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY api_cache ALTER COLUMN id SET DEFAULT nextval('api_cache_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY awards ALTER COLUMN id SET DEFAULT nextval('awards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY entities ALTER COLUMN id SET DEFAULT nextval('entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY entity_refs ALTER COLUMN id SET DEFAULT nextval('entity_refs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY funnel_constraints ALTER COLUMN id SET DEFAULT nextval('funnel_constraints_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY funnels ALTER COLUMN id SET DEFAULT nextval('funnels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY internals ALTER COLUMN id SET DEFAULT nextval('internals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY ownerships ALTER COLUMN id SET DEFAULT nextval('ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY scoring_rules ALTER COLUMN id SET DEFAULT nextval('scoring_rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY upvotes ALTER COLUMN id SET DEFAULT nextval('upvotes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_roles ALTER COLUMN id SET DEFAULT nextval('account_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements ALTER COLUMN id SET DEFAULT nextval('achievements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_cache ALTER COLUMN id SET DEFAULT nextval('api_cache_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards ALTER COLUMN id SET DEFAULT nextval('awards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brand_identities ALTER COLUMN id SET DEFAULT nextval('brand_identities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands ALTER COLUMN id SET DEFAULT nextval('brands_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands_users ALTER COLUMN id SET DEFAULT nextval('brands_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


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

ALTER TABLE ONLY feed_configs ALTER COLUMN id SET DEFAULT nextval('feed_configs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY funnel_constraints ALTER COLUMN id SET DEFAULT nextval('funnel_constraints_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY funnels ALTER COLUMN id SET DEFAULT nextval('funnels_id_seq'::regclass);


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

ALTER TABLE ONLY ownerships ALTER COLUMN id SET DEFAULT nextval('ownerships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scoring_rules ALTER COLUMN id SET DEFAULT nextval('scoring_rules_id_seq'::regclass);


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

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


SET search_path = bitovi, pg_catalog;

--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: api_cache_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_cache
    ADD CONSTRAINT api_cache_pkey PRIMARY KEY (id);


--
-- Name: awards_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_pkey PRIMARY KEY (id);


--
-- Name: entities_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: entity_refs_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entity_refs
    ADD CONSTRAINT entity_refs_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: funnel_constraints_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY funnel_constraints
    ADD CONSTRAINT funnel_constraints_pkey PRIMARY KEY (id);


--
-- Name: funnels_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY funnels
    ADD CONSTRAINT funnels_pkey PRIMARY KEY (id);


--
-- Name: internals_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_pkey PRIMARY KEY (id);


--
-- Name: ownerships_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: scoring_rules_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scoring_rules
    ADD CONSTRAINT scoring_rules_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: upvotes_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT upvotes_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: bitovi; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: account_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_roles
    ADD CONSTRAINT account_roles_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: api_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_cache
    ADD CONSTRAINT api_cache_pkey PRIMARY KEY (id);


--
-- Name: awards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_pkey PRIMARY KEY (id);


--
-- Name: brand_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brand_identities
    ADD CONSTRAINT brand_identities_pkey PRIMARY KEY (id);


--
-- Name: brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: brands_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brands_users
    ADD CONSTRAINT brands_users_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


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
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: feed_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feed_configs
    ADD CONSTRAINT feed_configs_pkey PRIMARY KEY (id);


--
-- Name: funnel_constraints_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY funnel_constraints
    ADD CONSTRAINT funnel_constraints_pkey PRIMARY KEY (id);


--
-- Name: funnels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY funnels
    ADD CONSTRAINT funnels_pkey PRIMARY KEY (id);


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
-- Name: scoring_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scoring_rules
    ADD CONSTRAINT scoring_rules_pkey PRIMARY KEY (id);


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
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


SET search_path = bitovi, pg_catalog;

--
-- Name: index_achievements_on_reward_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_achievements_on_reward_id ON achievements USING btree (reward_id);


--
-- Name: index_achievements_on_user_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_achievements_on_user_id ON achievements USING btree (user_id);


--
-- Name: index_api_cache_on_uid_and_provider; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_api_cache_on_uid_and_provider ON api_cache USING btree (uid, provider);


--
-- Name: index_awards_on_actor_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_awards_on_actor_id ON awards USING btree (actor_id);


--
-- Name: index_awards_on_applies_to_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_awards_on_applies_to_id ON awards USING btree (applies_to_id);


--
-- Name: index_entities_on_feed_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_feed_id ON entities USING btree (feed_id);


--
-- Name: index_entities_on_scoring_rule_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_scoring_rule_id ON entities USING btree (scoring_rule_id);


--
-- Name: index_entities_on_type_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_type_id ON entities USING btree (type_id);


--
-- Name: index_entity_refs_on_from_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_refs_on_from_id ON entity_refs USING btree (from_id);


--
-- Name: index_entity_refs_on_from_id_and_to_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_entity_refs_on_from_id_and_to_id ON entity_refs USING btree (from_id, to_id);


--
-- Name: index_entity_refs_on_to_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_refs_on_to_id ON entity_refs USING btree (to_id);


--
-- Name: index_events_on_content_digest; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_content_digest ON events USING btree (content_digest);


--
-- Name: index_funnel_constraints_funnels_on_funnel_constraint_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_funnel_constraints_funnels_on_funnel_constraint_id ON funnel_constraints_funnels USING btree (funnel_constraint_id);


--
-- Name: index_funnel_constraints_funnels_on_funnel_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_funnel_constraints_funnels_on_funnel_id ON funnel_constraints_funnels USING btree (funnel_id);


--
-- Name: index_internals_on_actor_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_internals_on_actor_id ON internals USING btree (actor_id);


--
-- Name: index_internals_on_receiver_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_internals_on_receiver_id ON internals USING btree (receiver_id);


--
-- Name: index_ownerships_on_entity_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_ownerships_on_entity_id ON ownerships USING btree (entity_id);


--
-- Name: index_ownerships_on_owner_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_ownerships_on_owner_id ON ownerships USING btree (owner_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_upvotes_on_actor_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_upvotes_on_actor_id ON upvotes USING btree (actor_id);


--
-- Name: index_upvotes_on_applies_to_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_upvotes_on_applies_to_id ON upvotes USING btree (applies_to_id);


--
-- Name: index_user_roles_on_name; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_user_roles_on_name ON user_roles USING btree (name);


--
-- Name: index_user_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_user_roles_on_name_and_resource_type_and_resource_id ON user_roles USING btree (name, resource_type, resource_id);


--
-- Name: index_users_user_roles_on_user_id_and_user_role_id; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE INDEX index_users_user_roles_on_user_id_and_user_role_id ON users_user_roles USING btree (user_id, user_role_id);


--
-- Name: taggings_idx; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX taggings_idx ON taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: bitovi; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = public, pg_catalog;

--
-- Name: index_account_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_roles_on_name ON account_roles USING btree (name);


--
-- Name: index_account_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_roles_on_name_and_resource_type_and_resource_id ON account_roles USING btree (name, resource_type, resource_id);


--
-- Name: index_accounts_account_roles_on_account_id_and_account_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_account_roles_on_account_id_and_account_role_id ON accounts_account_roles USING btree (account_id, account_role_id);


--
-- Name: index_accounts_on_brand_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_brand_id ON accounts USING btree (brand_id);


--
-- Name: index_accounts_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_email ON accounts USING btree (email);


--
-- Name: index_accounts_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_reset_password_token ON accounts USING btree (reset_password_token);


--
-- Name: index_achievements_on_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_achievements_on_reward_id ON achievements USING btree (reward_id);


--
-- Name: index_achievements_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_achievements_on_user_id ON achievements USING btree (user_id);


--
-- Name: index_api_cache_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_cache_on_uid_and_provider ON api_cache USING btree (uid, provider);


--
-- Name: index_awards_on_actor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_awards_on_actor_id ON awards USING btree (actor_id);


--
-- Name: index_awards_on_applies_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_awards_on_applies_to_id ON awards USING btree (applies_to_id);


--
-- Name: index_brand_identities_on_brand_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brand_identities_on_brand_id ON brand_identities USING btree (brand_id);


--
-- Name: index_brands_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_brands_on_name ON brands USING btree (name);


--
-- Name: index_brands_on_tenant_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_brands_on_tenant_name ON brands USING btree (tenant_name);


--
-- Name: index_brands_users_on_brand_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brands_users_on_brand_id ON brands_users USING btree (brand_id);


--
-- Name: index_brands_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brands_users_on_user_id ON brands_users USING btree (user_id);


--
-- Name: index_entities_on_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_feed_id ON entities USING btree (feed_id);


--
-- Name: index_entities_on_scoring_rule_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_scoring_rule_id ON entities USING btree (scoring_rule_id);


--
-- Name: index_entities_on_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_type_id ON entities USING btree (type_id);


--
-- Name: index_entity_refs_on_from_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_refs_on_from_id ON entity_refs USING btree (from_id);


--
-- Name: index_entity_refs_on_from_id_and_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_entity_refs_on_from_id_and_to_id ON entity_refs USING btree (from_id, to_id);


--
-- Name: index_entity_refs_on_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_refs_on_to_id ON entity_refs USING btree (to_id);


--
-- Name: index_events_on_content_digest; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_content_digest ON events USING btree (content_digest);


--
-- Name: index_feed_configs_on_brand_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feed_configs_on_brand_id ON feed_configs USING btree (brand_id);


--
-- Name: index_funnel_constraints_funnels_on_funnel_constraint_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_funnel_constraints_funnels_on_funnel_constraint_id ON funnel_constraints_funnels USING btree (funnel_constraint_id);


--
-- Name: index_funnel_constraints_funnels_on_funnel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_funnel_constraints_funnels_on_funnel_id ON funnel_constraints_funnels USING btree (funnel_id);


--
-- Name: index_identities_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_identities_on_provider_and_uid ON identities USING btree (provider, uid);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_identities_on_user_id ON identities USING btree (user_id);


--
-- Name: index_internals_on_actor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_internals_on_actor_id ON internals USING btree (actor_id);


--
-- Name: index_internals_on_receiver_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_internals_on_receiver_id ON internals USING btree (receiver_id);


--
-- Name: index_ownerships_on_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ownerships_on_entity_id ON ownerships USING btree (entity_id);


--
-- Name: index_ownerships_on_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ownerships_on_owner_id ON ownerships USING btree (owner_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_upvotes_on_actor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_upvotes_on_actor_id ON upvotes USING btree (actor_id);


--
-- Name: index_upvotes_on_applies_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_upvotes_on_applies_to_id ON upvotes USING btree (applies_to_id);


--
-- Name: index_user_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_roles_on_name ON user_roles USING btree (name);


--
-- Name: index_user_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_roles_on_name_and_resource_type_and_resource_id ON user_roles USING btree (name, resource_type, resource_id);


--
-- Name: index_users_on_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_country_id ON users USING btree (country_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_user_roles_on_user_id_and_user_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_user_roles_on_user_id_and_user_role_id ON users_user_roles USING btree (user_id, user_role_id);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX taggings_idx ON taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = bitovi, pg_catalog;

--
-- Name: achievements_reward_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_reward_id_fk FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE;


--
-- Name: achievements_user_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: awards_actor_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_actor_id_fk FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: awards_applies_to_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_applies_to_id_fk FOREIGN KEY (applies_to_id) REFERENCES entities(id) ON DELETE CASCADE;


--
-- Name: entities_feed_tags_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_feed_tags_fk FOREIGN KEY (feed_id) REFERENCES tags(id);


--
-- Name: entities_scoring_rule_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_scoring_rule_id_fk FOREIGN KEY (scoring_rule_id) REFERENCES scoring_rules(id);


--
-- Name: entities_type_tags_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_type_tags_fk FOREIGN KEY (type_id) REFERENCES tags(id);


--
-- Name: funnel_constraints_funnels_funnel_constraint_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY funnel_constraints_funnels
    ADD CONSTRAINT funnel_constraints_funnels_funnel_constraint_id_fk FOREIGN KEY (funnel_constraint_id) REFERENCES funnel_constraints(id);


--
-- Name: funnel_constraints_funnels_funnel_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY funnel_constraints_funnels
    ADD CONSTRAINT funnel_constraints_funnels_funnel_id_fk FOREIGN KEY (funnel_id) REFERENCES funnels(id) ON DELETE CASCADE;


--
-- Name: internals_actor_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_actor_id_fk FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: internals_receiver_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_receiver_id_fk FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ownerships_entity_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_entity_id_fk FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;


--
-- Name: ownerships_owner_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_owner_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: upvotes_actor_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT upvotes_actor_id_fk FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: upvotes_applies_to_id_fk; Type: FK CONSTRAINT; Schema: bitovi; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT upvotes_applies_to_id_fk FOREIGN KEY (applies_to_id) REFERENCES entities(id) ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- Name: accounts_brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_brand_id_fk FOREIGN KEY (brand_id) REFERENCES brands(id);


--
-- Name: achievements_reward_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_reward_id_fk FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE;


--
-- Name: achievements_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY achievements
    ADD CONSTRAINT achievements_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: awards_actor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_actor_id_fk FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: awards_applies_to_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY awards
    ADD CONSTRAINT awards_applies_to_id_fk FOREIGN KEY (applies_to_id) REFERENCES entities(id) ON DELETE CASCADE;


--
-- Name: brand_identities_brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brand_identities
    ADD CONSTRAINT brand_identities_brand_id_fk FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE;


--
-- Name: brands_users_brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands_users
    ADD CONSTRAINT brands_users_brand_id_fk FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE;


--
-- Name: brands_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brands_users
    ADD CONSTRAINT brands_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: entities_feed_tags_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_feed_tags_fk FOREIGN KEY (feed_id) REFERENCES tags(id);


--
-- Name: entities_scoring_rule_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_scoring_rule_id_fk FOREIGN KEY (scoring_rule_id) REFERENCES scoring_rules(id);


--
-- Name: entities_type_tags_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_type_tags_fk FOREIGN KEY (type_id) REFERENCES tags(id);


--
-- Name: feed_configs_brand_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_configs
    ADD CONSTRAINT feed_configs_brand_id_fk FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE;


--
-- Name: funnel_constraints_funnels_funnel_constraint_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY funnel_constraints_funnels
    ADD CONSTRAINT funnel_constraints_funnels_funnel_constraint_id_fk FOREIGN KEY (funnel_constraint_id) REFERENCES funnel_constraints(id);


--
-- Name: funnel_constraints_funnels_funnel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY funnel_constraints_funnels
    ADD CONSTRAINT funnel_constraints_funnels_funnel_id_fk FOREIGN KEY (funnel_id) REFERENCES funnels(id) ON DELETE CASCADE;


--
-- Name: internals_actor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_actor_id_fk FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: internals_receiver_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY internals
    ADD CONSTRAINT internals_receiver_id_fk FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: ownerships_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_entity_id_fk FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;


--
-- Name: ownerships_owner_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_owner_id_fk FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: upvotes_actor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT upvotes_actor_id_fk FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: upvotes_applies_to_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY upvotes
    ADD CONSTRAINT upvotes_applies_to_id_fk FOREIGN KEY (applies_to_id) REFERENCES entities(id) ON DELETE CASCADE;


--
-- Name: users_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_country_id_fk FOREIGN KEY (country_id) REFERENCES countries(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "public", "public";

INSERT INTO schema_migrations (version) VALUES ('10000');

INSERT INTO schema_migrations (version) VALUES ('10010');

INSERT INTO schema_migrations (version) VALUES ('10011');

INSERT INTO schema_migrations (version) VALUES ('10012');

INSERT INTO schema_migrations (version) VALUES ('10013');

INSERT INTO schema_migrations (version) VALUES ('10020');

INSERT INTO schema_migrations (version) VALUES ('11000');

INSERT INTO schema_migrations (version) VALUES ('11001');

INSERT INTO schema_migrations (version) VALUES ('11002');

INSERT INTO schema_migrations (version) VALUES ('11003');

INSERT INTO schema_migrations (version) VALUES ('11004');

INSERT INTO schema_migrations (version) VALUES ('11005');

INSERT INTO schema_migrations (version) VALUES ('11006');

INSERT INTO schema_migrations (version) VALUES ('11007');

INSERT INTO schema_migrations (version) VALUES ('11008');

INSERT INTO schema_migrations (version) VALUES ('11009');

INSERT INTO schema_migrations (version) VALUES ('11010');

INSERT INTO schema_migrations (version) VALUES ('11011');

INSERT INTO schema_migrations (version) VALUES ('11012');

INSERT INTO schema_migrations (version) VALUES ('11013');

INSERT INTO schema_migrations (version) VALUES ('11014');

INSERT INTO schema_migrations (version) VALUES ('11015');

INSERT INTO schema_migrations (version) VALUES ('11016');

INSERT INTO schema_migrations (version) VALUES ('11017');

INSERT INTO schema_migrations (version) VALUES ('11018');

INSERT INTO schema_migrations (version) VALUES ('12001');

INSERT INTO schema_migrations (version) VALUES ('12002');

INSERT INTO schema_migrations (version) VALUES ('12003');

INSERT INTO schema_migrations (version) VALUES ('12004');

INSERT INTO schema_migrations (version) VALUES ('13001');

INSERT INTO schema_migrations (version) VALUES ('13002');

INSERT INTO schema_migrations (version) VALUES ('14002');

INSERT INTO schema_migrations (version) VALUES ('14003');

INSERT INTO schema_migrations (version) VALUES ('14004');

INSERT INTO schema_migrations (version) VALUES ('14005');

INSERT INTO schema_migrations (version) VALUES ('14006');

INSERT INTO schema_migrations (version) VALUES ('20140722110137');

INSERT INTO schema_migrations (version) VALUES ('20140728140956');

INSERT INTO schema_migrations (version) VALUES ('20140728141259');

