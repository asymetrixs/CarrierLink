--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

-- Started on 2016-04-28 17:08:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 1239070)
-- Name: domain; Type: SCHEMA; Schema: -; Owner: -
--
--GO

CREATE SCHEMA domain;

--GO

SET search_path = domain, pg_catalog;

--
-- TOC entry 912 (class 1247 OID 1239090)
-- Name: direction; Type: TYPE; Schema: domain; Owner: -
--

CREATE TYPE direction AS ENUM (
	'incoming',
	'outgoing'
);


--
-- TOC entry 915 (class 1247 OID 1239096)
-- Name: gatewaytype; Type: TYPE; Schema: domain; Owner: -
--

CREATE TYPE gatewaytype AS ENUM (
	'Account',
	'IP'
);


--
-- TOC entry 918 (class 1247 OID 1239102)
-- Name: gender; Type: TYPE; Schema: domain; Owner: -
--

CREATE TYPE gender AS ENUM (
	'Male',
	'Female'
);


--
-- TOC entry 921 (class 1247 OID 1239108)
-- Name: timeband; Type: TYPE; Schema: domain; Owner: -
--

CREATE TYPE timeband AS ENUM (
	'Peak',
	'OffPeak',
	'Weekend',
	'Flat'
);

--
-- TOC entry 187 (class 1259 OID 1239372)
-- Name: blacklist; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE blacklist (
	id integer NOT NULL,
	pattern text NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	comment text
);


--
-- TOC entry 188 (class 1259 OID 1239380)
-- Name: blacklist_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE blacklist_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 188
-- Name: blacklist_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE blacklist_id_seq OWNED BY blacklist.id;


--
-- TOC entry 189 (class 1259 OID 1239382)
-- Name: cache_number_gateway_statistic; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE cache_number_gateway_statistic (
	id bigint NOT NULL,
	gateway_id integer NOT NULL,
	number text NOT NULL,
	asr numeric(5,2) NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	working bigint NOT NULL,
	total bigint NOT NULL
);


--
-- TOC entry 190 (class 1259 OID 1239389)
-- Name: cache_number_gateway_statistic_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE cache_number_gateway_statistic_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 190
-- Name: cache_number_gateway_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE cache_number_gateway_statistic_id_seq OWNED BY cache_number_gateway_statistic.id;


--
-- TOC entry 183 (class 1259 OID 1239146)
-- Name: view_callto_result; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_callto_result AS
 SELECT ''::text AS error,
	''::text AS reason,
	''::text AS location,
	''::text AS called,
	''::text AS caller,
	''::text AS callername,
	''::text AS format,
	''::text AS formats,
	''::text AS line,
	''::text AS maxcall,
	''::text AS "osip_P-Asserted-Identity",
	''::text AS "osip_Gateway-ID",
	''::text AS "osip_Tracking-ID",
	''::text AS rtp_addr,
	''::text AS rtp_forward,
	''::text AS oconnection_id,
	''::text AS rtp_port,
	''::text AS timeout,
	''::text AS scgatewayid,
	''::text AS scgatewayaccountid,
	''::text AS scgatewayipid,
	''::text AS sctechcalled,
	false AS immediately,
	false AS sccachehit;


--
-- TOC entry 307 (class 1259 OID 1239942)
-- Name: test_view_callto_result; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW test_view_callto_result AS
 SELECT ''::text AS error,
	''::text AS reason,
	''::text AS location,
	''::text AS called,
	''::text AS caller,
	''::text AS callername,
	''::text AS format,
	''::text AS formats,
	''::text AS line,
	''::text AS maxcall,
	''::text AS "osip_P-Asserted-Identity",
	''::text AS "osip_Gateway-ID",
	''::text AS "osip_Tracking-ID",
	''::text AS rtp_addr,
	''::text AS rtp_forward,
	''::text AS oconnection_id,
	''::text AS rtp_port,
	''::text AS timeout,
	''::text AS scgatewayid,
	''::text AS scgatewayaccountid,
	''::text AS scgatewayipid,
	''::text AS sctechcalled,
	false AS immediately,
	false AS sccachehit;


--
-- TOC entry 191 (class 1259 OID 1239391)
-- Name: cache_route; Type: TABLE; Schema: domain; Owner: -
--

CREATE UNLOGGED TABLE cache_route (
	id bigint NOT NULL,
	series bigint NOT NULL,
	node_id integer NOT NULL,
	target text NOT NULL,
	target_node_id integer,
	target_gateway_id integer,
	action view_callto_result NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT cache_route_target_check CHECK (((target = 'Node'::text) OR (target = 'Gateway'::text)))
);


--
-- TOC entry 192 (class 1259 OID 1239399)
-- Name: cache_route_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE cache_route_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 192
-- Name: cache_route_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE cache_route_id_seq OWNED BY cache_route.id;


--
-- TOC entry 193 (class 1259 OID 1239401)
-- Name: cache_series_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE cache_series_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 500
	CYCLE;


--
-- TOC entry 194 (class 1259 OID 1239403)
-- Name: carrier; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE carrier (
	id integer NOT NULL,
	country_id integer NOT NULL,
	name text NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 195 (class 1259 OID 1239410)
-- Name: carrier_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE carrier_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 195
-- Name: carrier_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE carrier_id_seq OWNED BY carrier.id;


--
-- TOC entry 196 (class 1259 OID 1239412)
-- Name: carrier_name_fix; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE carrier_name_fix (
	id integer NOT NULL,
	wrong_name text NOT NULL,
	carrier_id integer NOT NULL
);


--
-- TOC entry 197 (class 1259 OID 1239418)
-- Name: carrier_name_fix_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE carrier_name_fix_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 197
-- Name: carrier_name_fix_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE carrier_name_fix_id_seq OWNED BY carrier_name_fix.id;


--
-- TOC entry 182 (class 1259 OID 1239129)
-- Name: gateway; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway (
	id integer NOT NULL,
	name text NOT NULL,
	type gatewaytype DEFAULT 'Account'::gatewaytype NOT NULL,
	company_id integer NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	remove_country_code boolean DEFAULT false NOT NULL,
	add_zeros boolean DEFAULT false NOT NULL,
	number_modification_group_id integer,
	format_id integer NOT NULL,
	number_block text,
	error_min_warning_level integer DEFAULT 0 NOT NULL,
	credit_remaining numeric(12,4),
	concurrent_lines_limit integer,
	credit_remaining_warning numeric(12,4),
	concurrent_connection_attempts integer DEFAULT 1 NOT NULL,
	prefix text,
	hour_limit bigint,
	hour_limit_warning bigint,
	comment text DEFAULT ''::text,
	modified timestamp with time zone DEFAULT now() NOT NULL
)
WITH (fillfactor='10');

--
-- TOC entry 198 (class 1259 OID 1239420)
-- Name: cdr; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE cdr (
	id bigint NOT NULL,
	sqltime timestamp with time zone DEFAULT now() NOT NULL,
	yatetime numeric(14,3) NOT NULL,
	billid text NOT NULL,
	chan text,
	address inet,
	port integer,
	caller text,
	callername text,
	called text,
	status text,
	reason text,
	ended boolean DEFAULT false NOT NULL,
	gateway_account_id integer,
	gateway_ip_id integer,
	customer_ip_id integer,
	gateway_price_per_min numeric(13,8),
	gateway_price_total numeric(13,8),
	gateway_currency character(3),
	gateway_price_id bigint,
	customer_price_per_min numeric(13,8),
	customer_price_total numeric(13,8),
	customer_currency character(3),
	customer_price_id bigint,
	dialcode_id integer,
	node_id integer NOT NULL,
	billed_on timestamp with time zone,
	gateway_id integer,
	customer_id integer,
	format text,
	formats text,
	rtp_addr text,
	sqltime_end timestamp with time zone,
	tech_called text,
	rtp_port integer,
	trackingid text,
	billtime bigint,
	ringtime bigint,
	duration bigint,
	direction direction NOT NULL,
	cause_q931 text,
	preroute_duration bigint,
	route_duration bigint,
	cache_hit boolean DEFAULT false NOT NULL,
	error text,
	cause_sip text,
	sip_user_agent text,
	sip_x_asterisk_hangupcause text,
	sip_x_asterisk_hangupcausecode text
)
WITH (autovacuum_vacuum_threshold='10000', autovacuum_vacuum_scale_factor='0.01', autovacuum_analyze_threshold='10000', autovacuum_analyze_scale_factor='0.03', fillfactor='25');


--
-- TOC entry 319 (class 1259 OID 1243605)
-- Name: cdr_2016_09; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE cdr_2016_09 (
	CONSTRAINT cdr_2016_09_sqltime_check CHECK (((sqltime >= '2016-02-28 16:00:00-08'::timestamp with time zone) AND (sqltime < '2016-03-06 16:00:00-08'::timestamp with time zone)))
)
INHERITS (cdr)
WITH (fillfactor='20', autovacuum_vacuum_threshold='50000', autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_threshold='50000', autovacuum_analyze_scale_factor='0.1');


--
-- TOC entry 199 (class 1259 OID 1239429)
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE cdr_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 500;


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 199
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE cdr_id_seq OWNED BY cdr.id;


--
-- TOC entry 200 (class 1259 OID 1239431)
-- Name: company; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE company (
	id integer NOT NULL,
	name text NOT NULL,
	street text,
	street_no text,
	city text,
	zip text,
	country_id integer,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	po_box text,
	floor text,
	phone_number text,
	fax_number text,
	email text,
	noc_phone_1 text,
	noc_phone_2 text,
	noc_email text,
	noc_icq text,
	noc_msn text,
	noc_skype text,
	registration_number text,
	vat_number text,
	web_url text,
	portal_url text,
	portal_user text,
	portal_password text,
	acquisition_status integer DEFAULT 1 NOT NULL,
	billing integer,
	rates_email text DEFAULT 'change@menow!.com'::text,
	invoice_email text DEFAULT 'change@menow!.com'::text,
	tax boolean DEFAULT false NOT NULL,
	billing_time_zone text DEFAULT 'UTC'::text NOT NULL,
	paypal_email text
);


--
-- TOC entry 201 (class 1259 OID 1239444)
-- Name: company_address; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE company_address (
	id integer NOT NULL,
	company_id integer NOT NULL,
	type integer NOT NULL,
	address text NOT NULL,
	country text NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	phone text,
	fax text
);


--
-- TOC entry 202 (class 1259 OID 1239452)
-- Name: company_address_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE company_address_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 202
-- Name: company_address_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE company_address_id_seq OWNED BY company_address.id;


--
-- TOC entry 203 (class 1259 OID 1239454)
-- Name: company_bankaccount; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE company_bankaccount (
	id integer NOT NULL,
	company_id integer NOT NULL,
	beneficiary_name text NOT NULL,
	bank_name text NOT NULL,
	bank_address text,
	account text,
	swift text,
	iban text,
	rtn text,
	minimum_amount_per_txn integer,
	minimum_amount_per_txn_currency text DEFAULT 0 NOT NULL,
	contact_name text,
	contact_address text,
	contact_phone text,
	contact_fax text,
	contact_email text,
	deleted boolean DEFAULT false NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	bank_pobox text,
	bank_phone text,
	bank_fax text,
	notice_email text
);


--
-- TOC entry 204 (class 1259 OID 1239463)
-- Name: company_bankaccount_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE company_bankaccount_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 204
-- Name: company_bankaccount_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE company_bankaccount_id_seq OWNED BY company_bankaccount.id;


--
-- TOC entry 205 (class 1259 OID 1239465)
-- Name: user; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE "user" (
	id integer NOT NULL,
	givenname text,
	surname text,
	email text,
	company_id integer NOT NULL,
	gender text DEFAULT 'Male'::gender NOT NULL,
	preferred_locale character(5) DEFAULT 'en-US'::character varying NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	login text,
	password character(40) DEFAULT '*'::bpchar NOT NULL,
	last_successful_login_date timestamp with time zone,
	last_successful_login_ip inet,
	last_unsuccessful_login_date timestamp with time zone,
	last_unsuccessful_login_attempts smallint DEFAULT 0 NOT NULL,
	is_account_locked boolean DEFAULT false NOT NULL,
	last_unsuccessful_login_ip inet,
	is_admin boolean DEFAULT false NOT NULL,
	responsibility_id integer,
	office_phone_number text,
	notes text,
	mobile_phone_number text,
	last_action_performed_on timestamp with time zone,
	last_password_change_date timestamp with time zone,
	last_account_locked_date timestamp with time zone,
	deleted boolean DEFAULT false NOT NULL,
	msn text,
	icq text,
	skype text,
	role integer DEFAULT 0 NOT NULL,
	jabber_name text,
	jabber_server text,
	irc_name text,
	irc_server text,
	google_hangout text,
	yahoo_messanger text
);


--
-- TOC entry 206 (class 1259 OID 1239480)
-- Name: company_contact_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE company_contact_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 206
-- Name: company_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE company_contact_id_seq OWNED BY "user".id;


--
-- TOC entry 207 (class 1259 OID 1239482)
-- Name: company_document; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE company_document (
	id integer NOT NULL,
	company_id integer NOT NULL,
	name text NOT NULL,
	description text,
	data bytea NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	filename text NOT NULL,
	content_type text NOT NULL
);


--
-- TOC entry 208 (class 1259 OID 1239490)
-- Name: company_document_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE company_document_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 208
-- Name: company_document_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE company_document_id_seq OWNED BY company_document.id;


--
-- TOC entry 209 (class 1259 OID 1239492)
-- Name: company_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE company_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 209
-- Name: company_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE company_id_seq OWNED BY company.id;


--
-- TOC entry 210 (class 1259 OID 1239494)
-- Name: company_news; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE company_news (
	news_id integer NOT NULL,
	company_id integer NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 1239497)
-- Name: context; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE context (
	id integer NOT NULL,
	name text NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	least_cost_routing boolean DEFAULT false NOT NULL,
	next integer DEFAULT 10 NOT NULL,
	modified timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 1239509)
-- Name: context_gateway; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE context_gateway (
	context_id integer NOT NULL,
	gateway_id integer NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 1239512)
-- Name: country; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE country (
	id integer NOT NULL,
	iso3 text
);


--
-- TOC entry 214 (class 1259 OID 1239518)
-- Name: country_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE country_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 214
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE country_id_seq OWNED BY country.id;


--
-- TOC entry 215 (class 1259 OID 1239520)
-- Name: customer; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer (
	id integer NOT NULL,
	company_id integer NOT NULL,
	name text NOT NULL,
	context_id integer NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	error_min_warning_level integer DEFAULT 0 NOT NULL,
	all_destinations boolean DEFAULT false NOT NULL,
	credit_remaining numeric(12,4),
	concurrent_lines_limit integer,
	credit_remaining_warning numeric(12,4),
	hour_limit bigint,
	hour_limit_warning bigint,
	fake_ringing boolean DEFAULT false NOT NULL,
	invoice_days integer,
	payment_days integer,
	tax boolean DEFAULT false NOT NULL,
	comment text DEFAULT ''::text,
	prefix text
)
WITH (fillfactor='10');


--
-- TOC entry 216 (class 1259 OID 1239534)
-- Name: customer_credit; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_credit (
	id integer NOT NULL,
	customer_id integer NOT NULL,
	description text,
	user_id integer NOT NULL,
	amount numeric(12,4) NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 1239541)
-- Name: customer_credit_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_credit_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 217
-- Name: customer_credit_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE customer_credit_id_seq OWNED BY customer_credit.id;


--
-- TOC entry 218 (class 1259 OID 1239543)
-- Name: customer_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 218
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE customer_id_seq OWNED BY customer.id;


--
-- TOC entry 219 (class 1259 OID 1239545)
-- Name: customer_invoice; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_invoice (
	id integer NOT NULL,
	number text NOT NULL,
	customer_id integer NOT NULL,
	invoice_data bytea NOT NULL,
	calls integer NOT NULL,
	price numeric(10,2) NOT NULL,
	billtime bigint,
	period_from timestamp with time zone NOT NULL,
	period_to timestamp with time zone NOT NULL,
	payed_on timestamp with time zone,
	created timestamp with time zone DEFAULT now() NOT NULL,
	payment_ack_by integer,
	raw_data text NOT NULL,
	cdr_data bytea NOT NULL,
	currency text,
	cdr_summary_data bytea NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 1239552)
-- Name: customer_invoice_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_invoice_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 220
-- Name: customer_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE customer_invoice_id_seq OWNED BY customer_invoice.id;


--
-- TOC entry 221 (class 1259 OID 1239554)
-- Name: customer_ip; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_ip (
	id integer NOT NULL,
	customer_id integer NOT NULL,
	address inet NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	sip boolean DEFAULT false NOT NULL,
	iax boolean DEFAULT false NOT NULL,
	h323 boolean DEFAULT false NOT NULL,
	rtp boolean DEFAULT false NOT NULL,
	sig boolean DEFAULT false NOT NULL,
	delete_requested_on timestamp with time zone,
	delete_requested_by integer,
	memo text
);


--
-- TOC entry 222 (class 1259 OID 1239568)
-- Name: customer_ip_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_ip_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 222
-- Name: customer_ip_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE customer_ip_id_seq OWNED BY customer_ip.id;


--
-- TOC entry 223 (class 1259 OID 1239570)
-- Name: customer_ip_statistic_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_ip_statistic_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 224 (class 1259 OID 1239572)
-- Name: customer_ip_statistic; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_ip_statistic (
	id integer DEFAULT nextval('customer_ip_statistic_id_seq'::regclass) NOT NULL,
	customer_ip_id integer NOT NULL,
	node_id integer NOT NULL,
	date date DEFAULT ('now'::text)::date NOT NULL,
	concurrent_calls integer DEFAULT 0 NOT NULL,
	calls_total integer DEFAULT 0 NOT NULL,
	calls_failed integer DEFAULT 0 NOT NULL,
	billtime bigint,
	balance_db_load smallint DEFAULT 0 NOT NULL
)
WITH (fillfactor='10');


--
-- TOC entry 225 (class 1259 OID 1239581)
-- Name: customer_node; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_node (
	node_id integer NOT NULL,
	customer_id integer NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 1239584)
-- Name: customer_price; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_price (
	id bigint NOT NULL,
	customer_id integer NOT NULL,
	valid_from timestamp with time zone NOT NULL,
	valid_to timestamp with time zone NOT NULL,
	price numeric(10,7) NOT NULL,
	currency character(3),
	created timestamp with time zone DEFAULT now() NOT NULL,
	number text NOT NULL,
	customer_pricelist_id integer NOT NULL,
	outdated boolean DEFAULT false NOT NULL,
	indicator text DEFAULT 'Unknown'::text NOT NULL,
	first_billing_increment integer DEFAULT 1 NOT NULL,
	next_billing_increment integer DEFAULT 1 NOT NULL,
	CONSTRAINT customer_price_price_check CHECK ((price > (0)::numeric))
)
WITH (fillfactor='50');


--
-- TOC entry 227 (class 1259 OID 1239596)
-- Name: customer_price_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_price_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 500;


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 227
-- Name: customer_price_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE customer_price_id_seq OWNED BY customer_price.id;


--
-- TOC entry 228 (class 1259 OID 1239598)
-- Name: customer_pricelist_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE customer_pricelist_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 229 (class 1259 OID 1239600)
-- Name: customer_pricelist; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE customer_pricelist (
	id integer DEFAULT nextval('customer_pricelist_id_seq'::regclass) NOT NULL,
	date timestamp with time zone NOT NULL,
	currency character(3) NOT NULL,
	customer_id integer NOT NULL
);


--
-- TOC entry 230 (class 1259 OID 1239604)
-- Name: dialcode; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE dialcode (
	id integer NOT NULL,
	carrier_id integer NOT NULL,
	number text NOT NULL,
	valid_from timestamp with time zone NOT NULL,
	valid_to timestamp with time zone NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	is_mobile boolean DEFAULT false NOT NULL
);


--
-- TOC entry 231 (class 1259 OID 1239612)
-- Name: dialcode_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE dialcode_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 231
-- Name: dialcode_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE dialcode_id_seq OWNED BY dialcode.id;


--
-- TOC entry 232 (class 1259 OID 1239614)
-- Name: error; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE error (
	id integer NOT NULL,
	code text NOT NULL,
	description text
);


--
-- TOC entry 233 (class 1259 OID 1239620)
-- Name: error_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE error_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 233
-- Name: error_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE error_id_seq OWNED BY error.id;


--
-- TOC entry 234 (class 1259 OID 1239622)
-- Name: exchange_rate_to_usd; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE exchange_rate_to_usd (
	id integer NOT NULL,
	currency character(3) NOT NULL,
	multiplier numeric(8,4) NOT NULL
);


--
-- TOC entry 235 (class 1259 OID 1239625)
-- Name: exchange_rate_to_usd_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE exchange_rate_to_usd_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 235
-- Name: exchange_rate_to_usd_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE exchange_rate_to_usd_id_seq OWNED BY exchange_rate_to_usd.id;


--
-- TOC entry 236 (class 1259 OID 1239627)
-- Name: format; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE format (
	id integer NOT NULL,
	name text NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 1239633)
-- Name: format_gateway; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE format_gateway (
	format_id integer NOT NULL,
	gateway_id integer NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 1239636)
-- Name: format_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE format_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 238
-- Name: format_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE format_id_seq OWNED BY format.id;


--
-- TOC entry 239 (class 1259 OID 1239638)
-- Name: gateway_account; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_account (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	account text,
	username text,
	authname text,
	pw text,
	protocol text,
	server text,
	domain text,
	number text,
	local_address text,
	"interval" integer,
	description text,
	new_callername text DEFAULT NULL::character varying,
	node_id integer NOT NULL,
	enabled boolean DEFAULT true,
	created timestamp with time zone DEFAULT now() NOT NULL,
	status text,
	last_polled timestamp with time zone,
	deleted boolean DEFAULT false NOT NULL,
	registrar text,
	outbound text,
	gatekeeper text,
	gateway text,
	modified boolean DEFAULT false NOT NULL,
	reason text,
	comment text,
	node_old_id integer,
	new_caller text
)
WITH (fillfactor='50');


--
-- TOC entry 240 (class 1259 OID 1239649)
-- Name: gateway_account_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_account_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 240
-- Name: gateway_account_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_account_id_seq OWNED BY gateway_account.id;


--
-- TOC entry 241 (class 1259 OID 1239651)
-- Name: gateway_account_resolved; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_account_resolved (
	id integer NOT NULL,
	address inet NOT NULL,
	gateway_account_id integer NOT NULL
);


--
-- TOC entry 242 (class 1259 OID 1239657)
-- Name: gateway_account_resolved_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_account_resolved_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 242
-- Name: gateway_account_resolved_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_account_resolved_id_seq OWNED BY gateway_account_resolved.id;


--
-- TOC entry 243 (class 1259 OID 1239659)
-- Name: gateway_account_statistic_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_account_statistic_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 244 (class 1259 OID 1239661)
-- Name: gateway_account_statistic; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_account_statistic (
	id integer DEFAULT nextval('gateway_account_statistic_id_seq'::regclass) NOT NULL,
	gateway_account_id integer NOT NULL,
	node_id integer NOT NULL,
	date date DEFAULT ('now'::text)::date NOT NULL,
	concurrent_calls integer DEFAULT 0 NOT NULL,
	calls_total integer DEFAULT 0 NOT NULL,
	calls_failed integer DEFAULT 0 NOT NULL,
	billtime bigint,
	balance_db_load smallint DEFAULT 0 NOT NULL
)
WITH (fillfactor='10');


--
-- TOC entry 245 (class 1259 OID 1239670)
-- Name: gateway_credit; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_credit (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	description text,
	user_id integer NOT NULL,
	amount numeric(12,4) NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 246 (class 1259 OID 1239677)
-- Name: gateway_credit_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_credit_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 246
-- Name: gateway_credit_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_credit_id_seq OWNED BY gateway_credit.id;


--
-- TOC entry 247 (class 1259 OID 1239679)
-- Name: gateway_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 247
-- Name: gateway_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_id_seq OWNED BY gateway.id;


--
-- TOC entry 248 (class 1259 OID 1239681)
-- Name: gateway_ip; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_ip (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	address text NOT NULL,
	port integer NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	caller text,
	callername text,
	sip_p_asserted_identity text,
	rtp_addr text,
	rtp_port integer,
	rtp_forward boolean DEFAULT false NOT NULL,
	protocol text DEFAULT 'sip'::text NOT NULL,
	delete_requested_on timestamp with time zone,
	delete_requested_by integer,
	memo text,
	modified timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 249 (class 1259 OID 1239693)
-- Name: gateway_ip_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_ip_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 249
-- Name: gateway_ip_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_ip_id_seq OWNED BY gateway_ip.id;


--
-- TOC entry 250 (class 1259 OID 1239695)
-- Name: gateway_ip_node; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_ip_node (
	gateway_ip_id integer NOT NULL,
	node_id integer NOT NULL
);


--
-- TOC entry 251 (class 1259 OID 1239698)
-- Name: gateway_ip_resolved; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_ip_resolved (
	id integer NOT NULL,
	address inet NOT NULL,
	gateway_ip_id integer NOT NULL
);


--
-- TOC entry 252 (class 1259 OID 1239704)
-- Name: gateway_ip_resolved_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_ip_resolved_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 252
-- Name: gateway_ip_resolved_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_ip_resolved_id_seq OWNED BY gateway_ip_resolved.id;


--
-- TOC entry 253 (class 1259 OID 1239706)
-- Name: gateway_ip_statistic_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_ip_statistic_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 254 (class 1259 OID 1239708)
-- Name: gateway_ip_statistic; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_ip_statistic (
	id integer DEFAULT nextval('gateway_ip_statistic_id_seq'::regclass) NOT NULL,
	gateway_ip_id integer NOT NULL,
	node_id integer NOT NULL,
	date date DEFAULT ('now'::text)::date NOT NULL,
	concurrent_calls integer DEFAULT 0 NOT NULL,
	calls_total integer DEFAULT 0 NOT NULL,
	calls_failed integer DEFAULT 0 NOT NULL,
	billtime bigint,
	balance_db_load smallint DEFAULT 0 NOT NULL
)
WITH (fillfactor='10');


--
-- TOC entry 255 (class 1259 OID 1239717)
-- Name: gateway_price; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_price (
	id bigint NOT NULL,
	gateway_id integer NOT NULL,
	timeband timeband NOT NULL,
	price numeric(10,7) NOT NULL,
	currency character(3) NOT NULL,
	valid_to timestamp with time zone,
	valid_from timestamp with time zone,
	created timestamp with time zone DEFAULT now() NOT NULL,
	number text NOT NULL,
	gateway_pricelist_id integer NOT NULL,
	outdated boolean DEFAULT false NOT NULL,
	indicator text DEFAULT 'Unknown'::text NOT NULL,
	first_billing_increment integer DEFAULT 1 NOT NULL,
	next_billing_increment integer DEFAULT 1 NOT NULL,
	CONSTRAINT gateway_price_price_check CHECK ((price > (0)::numeric))
)
WITH (fillfactor='50');


--
-- TOC entry 256 (class 1259 OID 1239729)
-- Name: gateway_price_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_price_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 500;


--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 256
-- Name: gateway_price_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_price_id_seq OWNED BY gateway_price.id;


--
-- TOC entry 257 (class 1259 OID 1239731)
-- Name: gateway_pricelist_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_pricelist_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 258 (class 1259 OID 1239733)
-- Name: gateway_pricelist; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_pricelist (
	id integer DEFAULT nextval('gateway_pricelist_id_seq'::regclass) NOT NULL,
	date timestamp with time zone NOT NULL,
	currency character(3) NOT NULL,
	gateway_id integer NOT NULL
);


--
-- TOC entry 259 (class 1259 OID 1239737)
-- Name: gateway_timeband; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE gateway_timeband (
	id integer NOT NULL,
	carrier_id integer NOT NULL,
	gateway_id integer NOT NULL,
	day_of_week smallint NOT NULL,
	timeband timeband NOT NULL,
	time_from time with time zone NOT NULL,
	time_to time with time zone NOT NULL,
	valid_from timestamp with time zone NOT NULL,
	valid_to timestamp with time zone NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	gateway_pricelist_id integer NOT NULL,
	CONSTRAINT gateway_timeband_time_check CHECK ((time_from < time_to)),
	CONSTRAINT gateway_timeband_validity_check CHECK ((valid_from < valid_to))
);


--
-- TOC entry 260 (class 1259 OID 1239743)
-- Name: gateway_timeband_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE gateway_timeband_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 260
-- Name: gateway_timeband_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE gateway_timeband_id_seq OWNED BY gateway_timeband.id;


--
-- TOC entry 261 (class 1259 OID 1239745)
-- Name: history_customer_billtime; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_customer_billtime (
	id integer NOT NULL,
	customer_id integer NOT NULL,
	node_id integer NOT NULL,
	country_id integer,
	is_mobile boolean,
	calls integer NOT NULL,
	billtime bigint NOT NULL,
	date date NOT NULL
);


--
-- TOC entry 262 (class 1259 OID 1239748)
-- Name: history_customer_billtime_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_customer_billtime_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 262
-- Name: history_customer_billtime_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_customer_billtime_id_seq OWNED BY history_customer_billtime.id;


--
-- TOC entry 263 (class 1259 OID 1239750)
-- Name: history_customer_cc; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_customer_cc (
	id integer NOT NULL,
	customer_id integer NOT NULL,
	node_id integer NOT NULL,
	calls integer NOT NULL,
	datetime timestamp with time zone NOT NULL
);


--
-- TOC entry 264 (class 1259 OID 1239753)
-- Name: history_customer_cc_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_customer_cc_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 264
-- Name: history_customer_cc_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_customer_cc_id_seq OWNED BY history_customer_cc.id;


--
-- TOC entry 265 (class 1259 OID 1239755)
-- Name: history_customer_cpm; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_customer_cpm (
	id integer NOT NULL,
	customer_id integer NOT NULL,
	node_id integer NOT NULL,
	calls integer NOT NULL,
	datetime timestamp with time zone NOT NULL
);


--
-- TOC entry 266 (class 1259 OID 1239758)
-- Name: history_customer_cpm_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_customer_cpm_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 266
-- Name: history_customer_cpm_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_customer_cpm_id_seq OWNED BY history_customer_cpm.id;


--
-- TOC entry 267 (class 1259 OID 1239760)
-- Name: history_customer_reason; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_customer_reason (
	id integer NOT NULL,
	customer_id integer NOT NULL,
	node_id integer NOT NULL,
	country_id integer,
	is_mobile boolean,
	calls integer NOT NULL,
	reason text,
	date date NOT NULL
);


--
-- TOC entry 268 (class 1259 OID 1239766)
-- Name: history_customer_reason_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_customer_reason_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 268
-- Name: history_customer_reason_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_customer_reason_id_seq OWNED BY history_customer_reason.id;


--
-- TOC entry 269 (class 1259 OID 1239768)
-- Name: history_gateway_billtime; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_gateway_billtime (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	node_id integer NOT NULL,
	country_id integer,
	is_mobile boolean,
	calls integer NOT NULL,
	billtime bigint NOT NULL,
	date date NOT NULL
);


--
-- TOC entry 270 (class 1259 OID 1239771)
-- Name: history_gateway_billtime_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_gateway_billtime_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 270
-- Name: history_gateway_billtime_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_gateway_billtime_id_seq OWNED BY history_gateway_billtime.id;


--
-- TOC entry 271 (class 1259 OID 1239773)
-- Name: history_gateway_cc; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_gateway_cc (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	node_id integer NOT NULL,
	calls integer NOT NULL,
	datetime timestamp with time zone NOT NULL
);


--
-- TOC entry 272 (class 1259 OID 1239776)
-- Name: history_gateway_cc_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_gateway_cc_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 272
-- Name: history_gateway_cc_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_gateway_cc_id_seq OWNED BY history_gateway_cc.id;


--
-- TOC entry 273 (class 1259 OID 1239778)
-- Name: history_gateway_cpm; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_gateway_cpm (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	node_id integer NOT NULL,
	calls integer NOT NULL,
	datetime timestamp with time zone NOT NULL
);


--
-- TOC entry 274 (class 1259 OID 1239781)
-- Name: history_gateway_cpm_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_gateway_cpm_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 274
-- Name: history_gateway_cpm_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_gateway_cpm_id_seq OWNED BY history_gateway_cpm.id;


--
-- TOC entry 275 (class 1259 OID 1239783)
-- Name: history_gateway_reason; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_gateway_reason (
	id integer NOT NULL,
	gateway_id integer NOT NULL,
	node_id integer NOT NULL,
	country_id integer,
	is_mobile boolean,
	calls integer NOT NULL,
	reason text,
	date date NOT NULL
);


--
-- TOC entry 276 (class 1259 OID 1239789)
-- Name: history_gateway_reason_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE history_gateway_reason_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 276
-- Name: history_gateway_reason_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE history_gateway_reason_id_seq OWNED BY history_gateway_reason.id;


--
-- TOC entry 277 (class 1259 OID 1239791)
-- Name: history_outgoing; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE history_outgoing (
	sqltime timestamp with time zone NOT NULL,
	trackingid text NOT NULL,
	country_id integer NOT NULL,
	total integer DEFAULT 1 NOT NULL
);


--
-- TOC entry 278 (class 1259 OID 1239798)
-- Name: i_amount; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE i_amount (
	reltuples bigint
);


--
-- TOC entry 279 (class 1259 OID 1239801)
-- Name: incorrect_callername; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE incorrect_callername (
	id integer NOT NULL,
	name text NOT NULL,
	commentary text DEFAULT ''::character varying NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	replacement text NOT NULL,
	deleted boolean DEFAULT false NOT NULL
);


--
-- TOC entry 280 (class 1259 OID 1239810)
-- Name: incorrect_callername_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE incorrect_callername_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 280
-- Name: incorrect_callername_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE incorrect_callername_id_seq OWNED BY incorrect_callername.id;


--
-- TOC entry 281 (class 1259 OID 1239812)
-- Name: news; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE news (
	id integer NOT NULL,
	author_id integer NOT NULL,
	headline text NOT NULL,
	content text NOT NULL,
	visible boolean DEFAULT true NOT NULL,
	visible_on timestamp with time zone,
	deleted boolean DEFAULT false NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 282 (class 1259 OID 1239821)
-- Name: news_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE news_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 282
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE news_id_seq OWNED BY news.id;


--
-- TOC entry 283 (class 1259 OID 1239823)
-- Name: node; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE node (
	id integer NOT NULL,
	name text NOT NULL,
	online boolean DEFAULT true NOT NULL,
	online_since timestamp with time zone,
	offline_since timestamp with time zone,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	is_in_maintenance_mode boolean DEFAULT false NOT NULL,
	last_start timestamp with time zone
)
WITH (fillfactor='10');


--
-- TOC entry 284 (class 1259 OID 1239834)
-- Name: node_format; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE node_format (
	node_id integer NOT NULL,
	format_id integer NOT NULL
);


--
-- TOC entry 285 (class 1259 OID 1239837)
-- Name: node_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE node_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 285
-- Name: node_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE node_id_seq OWNED BY node.id;


--
-- TOC entry 286 (class 1259 OID 1239839)
-- Name: node_ip; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE node_ip (
	id integer NOT NULL,
	address inet NOT NULL,
	node_id integer NOT NULL,
	port integer NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	network text NOT NULL
);


--
-- TOC entry 287 (class 1259 OID 1239848)
-- Name: node_ip_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE node_ip_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 287
-- Name: node_ip_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE node_ip_id_seq OWNED BY node_ip.id;


--
-- TOC entry 288 (class 1259 OID 1239850)
-- Name: node_routing_log; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE node_routing_log (
	id bigint NOT NULL,
	node_id integer NOT NULL,
	action text NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 289 (class 1259 OID 1239857)
-- Name: node_routing_log_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE node_routing_log_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 289
-- Name: node_routing_log_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE node_routing_log_id_seq OWNED BY node_routing_log.id;


--
-- TOC entry 290 (class 1259 OID 1239859)
-- Name: node_statistic_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE node_statistic_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 291 (class 1259 OID 1239861)
-- Name: node_statistic; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE node_statistic (
	id integer DEFAULT nextval('node_statistic_id_seq'::regclass) NOT NULL,
	node_id integer NOT NULL,
	date date DEFAULT ('now'::text)::date NOT NULL,
	concurrent_calls integer DEFAULT 0 NOT NULL,
	calls_total integer DEFAULT 0 NOT NULL,
	calls_failed integer DEFAULT 0 NOT NULL,
	billtime bigint,
	balance_db_load smallint DEFAULT 0 NOT NULL
)
WITH (fillfactor='10');


--
-- TOC entry 292 (class 1259 OID 1239870)
-- Name: number_modification; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE number_modification (
	id integer NOT NULL,
	pattern text NOT NULL,
	remove_prefix text NOT NULL,
	add_prefix text NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	sort integer DEFAULT 1000 NOT NULL
);


--
-- TOC entry 293 (class 1259 OID 1239880)
-- Name: number_modification_group; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE number_modification_group (
	id integer NOT NULL,
	name text NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 294 (class 1259 OID 1239889)
-- Name: number_modification_group_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE number_modification_group_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 294
-- Name: number_modification_group_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE number_modification_group_id_seq OWNED BY number_modification_group.id;


--
-- TOC entry 295 (class 1259 OID 1239891)
-- Name: number_modification_group_number_modification; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE number_modification_group_number_modification (
	number_modification_group_id integer NOT NULL,
	number_modification_id integer NOT NULL
);


--
-- TOC entry 296 (class 1259 OID 1239894)
-- Name: number_modification_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE number_modification_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 296
-- Name: number_modification_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE number_modification_id_seq OWNED BY number_modification.id;


--
-- TOC entry 297 (class 1259 OID 1239896)
-- Name: protocol; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE protocol (
	id bigint NOT NULL,
	action text,
	summary text,
	detail text,
	actor_id integer,
	created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 298 (class 1259 OID 1239903)
-- Name: protocol_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE protocol_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 298
-- Name: protocol_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE protocol_id_seq OWNED BY protocol.id;


--
-- TOC entry 299 (class 1259 OID 1239905)
-- Name: qos_level_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE qos_level_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 299
-- Name: qos_level_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE qos_level_id_seq OWNED BY context.id;


--
-- TOC entry 300 (class 1259 OID 1239907)
-- Name: route; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE route (
	id integer NOT NULL,
	context_id integer NOT NULL,
	callername text,
	caller text,
	action text,
	pattern text,
	timeout integer NOT NULL,
	sort integer DEFAULT 1000 NOT NULL,
	enabled boolean DEFAULT true NOT NULL,
	created timestamp with time zone DEFAULT now() NOT NULL,
	deleted boolean DEFAULT false NOT NULL,
	did boolean DEFAULT false NOT NULL,
	comment text
);


--
-- TOC entry 301 (class 1259 OID 1239918)
-- Name: route_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE route_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 301
-- Name: route_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE route_id_seq OWNED BY route.id;


--
-- TOC entry 302 (class 1259 OID 1239920)
-- Name: route_to_gateway; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE route_to_gateway (
	id integer NOT NULL,
	route_id integer NOT NULL,
	gateway_id integer NOT NULL,
	sort integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 303 (class 1259 OID 1239924)
-- Name: route_to_gateway_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE route_to_gateway_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 303
-- Name: route_to_gateway_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE route_to_gateway_id_seq OWNED BY route_to_gateway.id;


--
-- TOC entry 304 (class 1259 OID 1239926)
-- Name: routing_decision; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE routing_decision (
	id integer NOT NULL,
	price boolean DEFAULT false NOT NULL,
	route boolean DEFAULT false NOT NULL,
	is_lcr boolean DEFAULT false NOT NULL,
	all_destinations boolean DEFAULT false NOT NULL,
	action text DEFAULT 'forbidden'::text NOT NULL,
	CONSTRAINT routing_decision_action_check CHECK (((action = 'forbidden'::text) OR (action = 'route'::text) OR (action = 'lcr'::text)))
);


--
-- TOC entry 305 (class 1259 OID 1239938)
-- Name: routing_decision_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE routing_decision_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 305
-- Name: routing_decision_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE routing_decision_id_seq OWNED BY routing_decision.id;


--
-- TOC entry 306 (class 1259 OID 1239940)
-- Name: syslog_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE syslog_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 10;


--
-- TOC entry 308 (class 1259 OID 1239946)
-- Name: test_view_route_result; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW test_view_route_result AS
 SELECT ''::text AS error,
	''::text AS reason,
	'fork'::text AS location,
	''::text AS scnodeid,
	''::text AS sccustomerid,
	''::text AS sccustomeripid,
	''::text AS sctrackingid,
	'false'::text AS sccachehit,
	''::text AS scrouteduration,
	'scgatewayid,sctechcalled,scgatewayipid,scgatewayaccountid,sccachehit,sctrackingid,scrouteduration,scprerouteduration,sccustomerid'::text AS copyparams,
	''::text AS sccustomerpriceid,
	''::text AS "callto.1.called",
	''::text AS "callto.1.caller",
	''::text AS "callto.1.callername",
	''::text AS "callto.1.format",
	''::text AS "callto.1.formats",
	''::text AS "callto.1.line",
	''::text AS "callto.1",
	''::text AS "callto.1.maxcall",
	''::text AS "callto.1.osip_P-Asserted-Identity",
	''::text AS "callto.1.osip_Gateway-ID",
	''::text AS "callto.1.osip_Tracking-ID",
	''::text AS "callto.1.rtp_addr",
	''::text AS "callto.1.rtp_forward",
	''::text AS "callto.1.oconnection_id",
	''::text AS "callto.1.rtp_port",
	''::text AS "callto.1.timeout",
	''::text AS "callto.1.scgatewayid",
	''::text AS "callto.1.scgatewayaccountid",
	''::text AS "callto.1.scgatewayipid",
	''::text AS "callto.1.sctechcalled",
	''::text AS "callto.2.called",
	''::text AS "callto.2.caller",
	''::text AS "callto.2.callername",
	''::text AS "callto.2.format",
	''::text AS "callto.2.formats",
	''::text AS "callto.2.line",
	''::text AS "callto.2",
	''::text AS "callto.2.maxcall",
	''::text AS "callto.2.osip_P-Asserted-Identity",
	''::text AS "callto.2.osip_Gateway-ID",
	''::text AS "callto.2.osip_Tracking-ID",
	''::text AS "callto.2.rtp_addr",
	''::text AS "callto.2.rtp_forward",
	''::text AS "callto.2.oconnection_id",
	''::text AS "callto.2.rtp_port",
	''::text AS "callto.2.timeout",
	''::text AS "callto.2.scgatewayid",
	''::text AS "callto.2.scgatewayaccountid",
	''::text AS "callto.2.scgatewayipid",
	''::text AS "callto.2.sctechcalled",
	''::text AS "callto.3.called",
	''::text AS "callto.3.caller",
	''::text AS "callto.3.callername",
	''::text AS "callto.3.format",
	''::text AS "callto.3.formats",
	''::text AS "callto.3.line",
	''::text AS "callto.3",
	''::text AS "callto.3.maxcall",
	''::text AS "callto.3.osip_P-Asserted-Identity",
	''::text AS "callto.3.osip_Gateway-ID",
	''::text AS "callto.3.osip_Tracking-ID",
	''::text AS "callto.3.rtp_addr",
	''::text AS "callto.3.rtp_forward",
	''::text AS "callto.3.oconnection_id",
	''::text AS "callto.3.rtp_port",
	''::text AS "callto.3.timeout",
	''::text AS "callto.3.scgatewayid",
	''::text AS "callto.3.scgatewayaccountid",
	''::text AS "callto.3.scgatewayipid",
	''::text AS "callto.3.sctechcalled",
	''::text AS "callto.4.called",
	''::text AS "callto.4.caller",
	''::text AS "callto.4.callername",
	''::text AS "callto.4.format",
	''::text AS "callto.4.formats",
	''::text AS "callto.4.line",
	''::text AS "callto.4",
	''::text AS "callto.4.maxcall",
	''::text AS "callto.4.osip_P-Asserted-Identity",
	''::text AS "callto.4.osip_Gateway-ID",
	''::text AS "callto.4.osip_Tracking-ID",
	''::text AS "callto.4.rtp_addr",
	''::text AS "callto.4.rtp_forward",
	''::text AS "callto.4.oconnection_id",
	''::text AS "callto.4.rtp_port",
	''::text AS "callto.4.timeout",
	''::text AS "callto.4.scgatewayid",
	''::text AS "callto.4.scgatewayaccountid",
	''::text AS "callto.4.scgatewayipid",
	''::text AS "callto.4.sctechcalled",
	''::text AS "callto.5.called",
	''::text AS "callto.5.caller",
	''::text AS "callto.5.callername",
	''::text AS "callto.5.format",
	''::text AS "callto.5.formats",
	''::text AS "callto.5.line",
	''::text AS "callto.5",
	''::text AS "callto.5.maxcall",
	''::text AS "callto.5.osip_P-Asserted-Identity",
	''::text AS "callto.5.osip_Gateway-ID",
	''::text AS "callto.5.osip_Tracking-ID",
	''::text AS "callto.5.rtp_addr",
	''::text AS "callto.5.rtp_forward",
	''::text AS "callto.5.oconnection_id",
	''::text AS "callto.5.rtp_port",
	''::text AS "callto.5.timeout",
	''::text AS "callto.5.scgatewayid",
	''::text AS "callto.5.scgatewayaccountid",
	''::text AS "callto.5.scgatewayipid",
	''::text AS "callto.5.sctechcalled",
	''::text AS "callto.6.called",
	''::text AS "callto.6.caller",
	''::text AS "callto.6.callername",
	''::text AS "callto.6.format",
	''::text AS "callto.6.formats",
	''::text AS "callto.6.line",
	''::text AS "callto.6",
	''::text AS "callto.6.maxcall",
	''::text AS "callto.6.osip_P-Asserted-Identity",
	''::text AS "callto.6.osip_Gateway-ID",
	''::text AS "callto.6.osip_Tracking-ID",
	''::text AS "callto.6.rtp_addr",
	''::text AS "callto.6.rtp_forward",
	''::text AS "callto.6.oconnection_id",
	''::text AS "callto.6.rtp_port",
	''::text AS "callto.6.timeout",
	''::text AS "callto.6.scgatewayid",
	''::text AS "callto.6.scgatewayaccountid",
	''::text AS "callto.6.scgatewayipid",
	''::text AS "callto.6.sctechcalled",
	''::text AS "callto.7.called",
	''::text AS "callto.7.caller",
	''::text AS "callto.7.callername",
	''::text AS "callto.7.format",
	''::text AS "callto.7.formats",
	''::text AS "callto.7.line",
	''::text AS "callto.7",
	''::text AS "callto.7.maxcall",
	''::text AS "callto.7.osip_P-Asserted-Identity",
	''::text AS "callto.7.osip_Gateway-ID",
	''::text AS "callto.7.osip_Tracking-ID",
	''::text AS "callto.7.rtp_addr",
	''::text AS "callto.7.rtp_forward",
	''::text AS "callto.7.oconnection_id",
	''::text AS "callto.7.rtp_port",
	''::text AS "callto.7.timeout",
	''::text AS "callto.7.scgatewayid",
	''::text AS "callto.7.scgatewayaccountid",
	''::text AS "callto.7.scgatewayipid",
	''::text AS "callto.7.sctechcalled",
	''::text AS "callto.8.called",
	''::text AS "callto.8.caller",
	''::text AS "callto.8.callername",
	''::text AS "callto.8.format",
	''::text AS "callto.8.formats",
	''::text AS "callto.8.line",
	''::text AS "callto.8",
	''::text AS "callto.8.maxcall",
	''::text AS "callto.8.osip_P-Asserted-Identity",
	''::text AS "callto.8.osip_Gateway-ID",
	''::text AS "callto.8.osip_Tracking-ID",
	''::text AS "callto.8.rtp_addr",
	''::text AS "callto.8.rtp_forward",
	''::text AS "callto.8.oconnection_id",
	''::text AS "callto.8.rtp_port",
	''::text AS "callto.8.timeout",
	''::text AS "callto.8.scgatewayid",
	''::text AS "callto.8.scgatewayaccountid",
	''::text AS "callto.8.scgatewayipid",
	''::text AS "callto.8.sctechcalled",
	''::text AS "callto.9.called",
	''::text AS "callto.9.caller",
	''::text AS "callto.9.callername",
	''::text AS "callto.9.format",
	''::text AS "callto.9.formats",
	''::text AS "callto.9.line",
	''::text AS "callto.9",
	''::text AS "callto.9.maxcall",
	''::text AS "callto.9.osip_P-Asserted-Identity",
	''::text AS "callto.9.osip_Gateway-ID",
	''::text AS "callto.9.osip_Tracking-ID",
	''::text AS "callto.9.rtp_addr",
	''::text AS "callto.9.rtp_forward",
	''::text AS "callto.9.oconnection_id",
	''::text AS "callto.9.rtp_port",
	''::text AS "callto.9.timeout",
	''::text AS "callto.9.scgatewayid",
	''::text AS "callto.9.scgatewayaccountid",
	''::text AS "callto.9.scgatewayipid",
	''::text AS "callto.9.sctechcalled",
	''::text AS "callto.10.called",
	''::text AS "callto.10.caller",
	''::text AS "callto.10.callername",
	''::text AS "callto.10.format",
	''::text AS "callto.10.formats",
	''::text AS "callto.10.line",
	''::text AS "callto.10",
	''::text AS "callto.10.maxcall",
	''::text AS "callto.10.osip_P-Asserted-Identity",
	''::text AS "callto.10.osip_Gateway-ID",
	''::text AS "callto.10.osip_Tracking-ID",
	''::text AS "callto.10.rtp_addr",
	''::text AS "callto.10.rtp_forward",
	''::text AS "callto.10.oconnection_id",
	''::text AS "callto.10.rtp_port",
	''::text AS "callto.10.timeout",
	''::text AS "callto.10.scgatewayid",
	''::text AS "callto.10.scgatewayaccountid",
	''::text AS "callto.10.scgatewayipid",
	''::text AS "callto.10.sctechcalled",
	''::text AS "callto.1.fork.calltype",
	''::text AS "callto.1.fork.autoring",
	''::text AS "callto.1.fork.automessage";


--
-- TOC entry 309 (class 1259 OID 1239951)
-- Name: tmp_vinculum; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE tmp_vinculum (
	id integer NOT NULL,
	name text,
	calls numeric,
	minutes numeric,
	rate numeric,
	dialcode bigint
);


--
-- TOC entry 310 (class 1259 OID 1239957)
-- Name: tmp_vinculum_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE tmp_vinculum_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 310
-- Name: tmp_vinculum_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE tmp_vinculum_id_seq OWNED BY tmp_vinculum.id;


--
-- TOC entry 311 (class 1259 OID 1239959)
-- Name: tmp_vinculum_name; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE tmp_vinculum_name (
	name text
);


--
-- TOC entry 312 (class 1259 OID 1239965)
-- Name: user_responsibility; Type: TABLE; Schema: domain; Owner: -
--

CREATE TABLE user_responsibility (
	id integer NOT NULL,
	name text NOT NULL
);


--
-- TOC entry 313 (class 1259 OID 1239971)
-- Name: view_cache_route; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_cache_route AS
 SELECT cache_route.id,
	cache_route.series,
	cache_route.node_id,
	cache_route.target,
	cache_route.target_node_id,
	cache_route.target_gateway_id,
	(cache_route.action).error AS action_error,
	(cache_route.action).reason AS action_reason,
	(cache_route.action).location AS action_location,
	(cache_route.action).called AS action_called,
	(cache_route.action).caller AS action_caller,
	(cache_route.action).callername AS action_callername,
	(cache_route.action).format AS action_format,
	(cache_route.action).formats AS action_formats,
	(cache_route.action).line AS action_line,
	(cache_route.action).maxcall AS action_maxcall,
	(cache_route.action)."osip_P-Asserted-Identity" AS "action_osip_P-Asserted-Identity",
	(cache_route.action)."osip_Gateway-ID" AS "action_osip_Gateway-ID",
	(cache_route.action)."osip_Tracking-ID" AS "action_osip_Tracking-ID",
	(cache_route.action).rtp_addr AS action_rtp_addr,
	(cache_route.action).rtp_forward AS action_rtp_forward,
	(cache_route.action).oconnection_id AS action_oconnection_id,
	(cache_route.action).rtp_port AS action_rtp_port,
	(cache_route.action).timeout AS action_timeout,
		CASE
			WHEN ((cache_route.action).scgatewayid = ''::text) THEN NULL::integer
			ELSE ((cache_route.action).scgatewayid)::integer
		END AS action_scgatewayid,
		CASE
			WHEN ((cache_route.action).scgatewayaccountid = ''::text) THEN NULL::integer
			ELSE ((cache_route.action).scgatewayaccountid)::integer
		END AS action_scgatewayaccountid,
		CASE
			WHEN ((cache_route.action).scgatewayipid = ''::text) THEN NULL::integer
			ELSE ((cache_route.action).scgatewayipid)::integer
		END AS action_scgatewayipid,
	(cache_route.action).sctechcalled AS action_sctechcalled,
	(cache_route.action).immediately AS action_immediately,
	(cache_route.action).sccachehit AS action_sccachehit,
	cache_route.created
   FROM cache_route
  ORDER BY cache_route.id DESC;


--
-- TOC entry 314 (class 1259 OID 1239976)
-- Name: view_customer_ip_statistic; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_customer_ip_statistic AS
 SELECT customer_ip_statistic.customer_ip_id,
	customer_ip_statistic.node_id,
	customer_ip_statistic.date,
	(sum(customer_ip_statistic.concurrent_calls))::integer AS concurrent_calls,
	(sum(customer_ip_statistic.calls_total))::integer AS calls_total,
	(sum(customer_ip_statistic.calls_failed))::integer AS calls_failed,
	(sum(customer_ip_statistic.billtime))::bigint AS billtime
   FROM customer_ip_statistic
  GROUP BY customer_ip_statistic.date, customer_ip_statistic.node_id, customer_ip_statistic.customer_ip_id;


--
-- TOC entry 315 (class 1259 OID 1239980)
-- Name: view_gateway_account_statistic; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_gateway_account_statistic AS
 SELECT gateway_account_statistic.gateway_account_id,
	gateway_account_statistic.node_id,
	gateway_account_statistic.date,
	(sum(gateway_account_statistic.concurrent_calls))::integer AS concurrent_calls,
	(sum(gateway_account_statistic.calls_total))::integer AS calls_total,
	(sum(gateway_account_statistic.calls_failed))::integer AS calls_failed,
	(sum(gateway_account_statistic.billtime))::bigint AS billtime
   FROM gateway_account_statistic
  GROUP BY gateway_account_statistic.date, gateway_account_statistic.node_id, gateway_account_statistic.gateway_account_id;


--
-- TOC entry 316 (class 1259 OID 1239984)
-- Name: view_gateway_ip_statistic; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_gateway_ip_statistic AS
 SELECT gateway_ip_statistic.gateway_ip_id,
	gateway_ip_statistic.node_id,
	gateway_ip_statistic.date,
	(sum(gateway_ip_statistic.concurrent_calls))::integer AS concurrent_calls,
	(sum(gateway_ip_statistic.calls_total))::integer AS calls_total,
	(sum(gateway_ip_statistic.calls_failed))::integer AS calls_failed,
	(sum(gateway_ip_statistic.billtime))::bigint AS billtime
   FROM gateway_ip_statistic
  GROUP BY gateway_ip_statistic.date, gateway_ip_statistic.node_id, gateway_ip_statistic.gateway_ip_id;


--
-- TOC entry 317 (class 1259 OID 1239988)
-- Name: view_node_statistic; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_node_statistic AS
 SELECT node_statistic.node_id,
	node_statistic.date,
	(sum(node_statistic.concurrent_calls))::integer AS concurrent_calls,
	(sum(node_statistic.calls_total))::integer AS calls_total,
	(sum(node_statistic.calls_failed))::integer AS calls_failed,
	(sum(node_statistic.billtime))::bigint AS billtime
   FROM node_statistic
  GROUP BY node_statistic.date, node_statistic.node_id;


--
-- TOC entry 318 (class 1259 OID 1239992)
-- Name: web_user_responsibility_id_seq; Type: SEQUENCE; Schema: domain; Owner: -
--

CREATE SEQUENCE web_user_responsibility_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 318
-- Name: web_user_responsibility_id_seq; Type: SEQUENCE OWNED BY; Schema: domain; Owner: -
--

ALTER SEQUENCE web_user_responsibility_id_seq OWNED BY user_responsibility.id;


--
-- TOC entry 2706 (class 2604 OID 1239994)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY blacklist ALTER COLUMN id SET DEFAULT nextval('blacklist_id_seq'::regclass);


--
-- TOC entry 2707 (class 2604 OID 1239995)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cache_number_gateway_statistic ALTER COLUMN id SET DEFAULT nextval('cache_number_gateway_statistic_id_seq'::regclass);


--
-- TOC entry 2709 (class 2604 OID 1239996)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cache_route ALTER COLUMN id SET DEFAULT nextval('cache_route_id_seq'::regclass);


--
-- TOC entry 2712 (class 2604 OID 1239997)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY carrier ALTER COLUMN id SET DEFAULT nextval('carrier_id_seq'::regclass);


--
-- TOC entry 2714 (class 2604 OID 1239998)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY carrier_name_fix ALTER COLUMN id SET DEFAULT nextval('carrier_name_fix_id_seq'::regclass);


--
-- TOC entry 2718 (class 2604 OID 1239999)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2901 (class 2604 OID 1243616)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2902 (class 2604 OID 1243617)
-- Name: sqltime; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09 ALTER COLUMN sqltime SET DEFAULT now();


--
-- TOC entry 2903 (class 2604 OID 1243618)
-- Name: ended; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09 ALTER COLUMN ended SET DEFAULT false;


--
-- TOC entry 2904 (class 2604 OID 1243619)
-- Name: cache_hit; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09 ALTER COLUMN cache_hit SET DEFAULT false;


--
-- TOC entry 2726 (class 2604 OID 1240000)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company ALTER COLUMN id SET DEFAULT nextval('company_id_seq'::regclass);


--
-- TOC entry 2729 (class 2604 OID 1240001)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_address ALTER COLUMN id SET DEFAULT nextval('company_address_id_seq'::regclass);


--
-- TOC entry 2733 (class 2604 OID 1240002)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_bankaccount ALTER COLUMN id SET DEFAULT nextval('company_bankaccount_id_seq'::regclass);


--
-- TOC entry 2746 (class 2604 OID 1240003)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_document ALTER COLUMN id SET DEFAULT nextval('company_document_id_seq'::regclass);


--
-- TOC entry 2753 (class 2604 OID 1240004)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY context ALTER COLUMN id SET DEFAULT nextval('qos_level_id_seq'::regclass);


--
-- TOC entry 2754 (class 2604 OID 1240005)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY country ALTER COLUMN id SET DEFAULT nextval('country_id_seq'::regclass);


--
-- TOC entry 2763 (class 2604 OID 1240006)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer ALTER COLUMN id SET DEFAULT nextval('customer_id_seq'::regclass);


--
-- TOC entry 2764 (class 2604 OID 1240007)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_credit ALTER COLUMN id SET DEFAULT nextval('customer_credit_id_seq'::regclass);


--
-- TOC entry 2766 (class 2604 OID 1240008)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_invoice ALTER COLUMN id SET DEFAULT nextval('customer_invoice_id_seq'::regclass);


--
-- TOC entry 2776 (class 2604 OID 1240009)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_ip ALTER COLUMN id SET DEFAULT nextval('customer_ip_id_seq'::regclass);


--
-- TOC entry 2788 (class 2604 OID 1240010)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_price ALTER COLUMN id SET DEFAULT nextval('customer_price_id_seq'::regclass);


--
-- TOC entry 2793 (class 2604 OID 1240011)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY dialcode ALTER COLUMN id SET DEFAULT nextval('dialcode_id_seq'::regclass);


--
-- TOC entry 2794 (class 2604 OID 1240012)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY error ALTER COLUMN id SET DEFAULT nextval('error_id_seq'::regclass);


--
-- TOC entry 2795 (class 2604 OID 1240013)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY exchange_rate_to_usd ALTER COLUMN id SET DEFAULT nextval('exchange_rate_to_usd_id_seq'::regclass);


--
-- TOC entry 2796 (class 2604 OID 1240014)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY format ALTER COLUMN id SET DEFAULT nextval('format_id_seq'::regclass);


--
-- TOC entry 2703 (class 2604 OID 1240015)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway ALTER COLUMN id SET DEFAULT nextval('gateway_id_seq'::regclass);


--
-- TOC entry 2802 (class 2604 OID 1240016)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account ALTER COLUMN id SET DEFAULT nextval('gateway_account_id_seq'::regclass);


--
-- TOC entry 2803 (class 2604 OID 1240017)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account_resolved ALTER COLUMN id SET DEFAULT nextval('gateway_account_resolved_id_seq'::regclass);


--
-- TOC entry 2810 (class 2604 OID 1240018)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_credit ALTER COLUMN id SET DEFAULT nextval('gateway_credit_id_seq'::regclass);


--
-- TOC entry 2818 (class 2604 OID 1240019)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip ALTER COLUMN id SET DEFAULT nextval('gateway_ip_id_seq'::regclass);


--
-- TOC entry 2819 (class 2604 OID 1240020)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_resolved ALTER COLUMN id SET DEFAULT nextval('gateway_ip_resolved_id_seq'::regclass);


--
-- TOC entry 2831 (class 2604 OID 1240021)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_price ALTER COLUMN id SET DEFAULT nextval('gateway_price_id_seq'::regclass);


--
-- TOC entry 2834 (class 2604 OID 1240022)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_timeband ALTER COLUMN id SET DEFAULT nextval('gateway_timeband_id_seq'::regclass);


--
-- TOC entry 2838 (class 2604 OID 1240023)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_billtime ALTER COLUMN id SET DEFAULT nextval('history_customer_billtime_id_seq'::regclass);


--
-- TOC entry 2839 (class 2604 OID 1240024)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cc ALTER COLUMN id SET DEFAULT nextval('history_customer_cc_id_seq'::regclass);


--
-- TOC entry 2840 (class 2604 OID 1240025)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cpm ALTER COLUMN id SET DEFAULT nextval('history_customer_cpm_id_seq'::regclass);


--
-- TOC entry 2841 (class 2604 OID 1240026)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_reason ALTER COLUMN id SET DEFAULT nextval('history_customer_reason_id_seq'::regclass);


--
-- TOC entry 2842 (class 2604 OID 1240027)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_billtime ALTER COLUMN id SET DEFAULT nextval('history_gateway_billtime_id_seq'::regclass);


--
-- TOC entry 2843 (class 2604 OID 1240028)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cc ALTER COLUMN id SET DEFAULT nextval('history_gateway_cc_id_seq'::regclass);


--
-- TOC entry 2844 (class 2604 OID 1240029)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cpm ALTER COLUMN id SET DEFAULT nextval('history_gateway_cpm_id_seq'::regclass);


--
-- TOC entry 2845 (class 2604 OID 1240030)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_reason ALTER COLUMN id SET DEFAULT nextval('history_gateway_reason_id_seq'::regclass);


--
-- TOC entry 2850 (class 2604 OID 1240031)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY incorrect_callername ALTER COLUMN id SET DEFAULT nextval('incorrect_callername_id_seq'::regclass);


--
-- TOC entry 2854 (class 2604 OID 1240032)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY news ALTER COLUMN id SET DEFAULT nextval('news_id_seq'::regclass);


--
-- TOC entry 2860 (class 2604 OID 1240033)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node ALTER COLUMN id SET DEFAULT nextval('node_id_seq'::regclass);


--
-- TOC entry 2864 (class 2604 OID 1240034)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_ip ALTER COLUMN id SET DEFAULT nextval('node_ip_id_seq'::regclass);


--
-- TOC entry 2865 (class 2604 OID 1240035)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_routing_log ALTER COLUMN id SET DEFAULT nextval('node_routing_log_id_seq'::regclass);


--
-- TOC entry 2877 (class 2604 OID 1240036)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification ALTER COLUMN id SET DEFAULT nextval('number_modification_id_seq'::regclass);


--
-- TOC entry 2881 (class 2604 OID 1240037)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification_group ALTER COLUMN id SET DEFAULT nextval('number_modification_group_id_seq'::regclass);


--
-- TOC entry 2882 (class 2604 OID 1240038)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY protocol ALTER COLUMN id SET DEFAULT nextval('protocol_id_seq'::regclass);


--
-- TOC entry 2889 (class 2604 OID 1240039)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route ALTER COLUMN id SET DEFAULT nextval('route_id_seq'::regclass);


--
-- TOC entry 2890 (class 2604 OID 1240040)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route_to_gateway ALTER COLUMN id SET DEFAULT nextval('route_to_gateway_id_seq'::regclass);


--
-- TOC entry 2897 (class 2604 OID 1240041)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY routing_decision ALTER COLUMN id SET DEFAULT nextval('routing_decision_id_seq'::regclass);


--
-- TOC entry 2899 (class 2604 OID 1240042)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY tmp_vinculum ALTER COLUMN id SET DEFAULT nextval('tmp_vinculum_id_seq'::regclass);


--
-- TOC entry 2743 (class 2604 OID 1240043)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY "user" ALTER COLUMN id SET DEFAULT nextval('company_contact_id_seq'::regclass);


--
-- TOC entry 2900 (class 2604 OID 1240044)
-- Name: id; Type: DEFAULT; Schema: domain; Owner: -
--

ALTER TABLE ONLY user_responsibility ALTER COLUMN id SET DEFAULT nextval('web_user_responsibility_id_seq'::regclass);


--
-- TOC entry 2910 (class 2606 OID 1242882)
-- Name: cache_number_gateway_statistic_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cache_number_gateway_statistic
	ADD CONSTRAINT cache_number_gateway_statistic_pkey PRIMARY KEY (id);


--
-- TOC entry 2941 (class 2606 OID 1242918)
-- Name: company_address_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_address
	ADD CONSTRAINT company_address_pkey PRIMARY KEY (id);


--
-- TOC entry 2944 (class 2606 OID 1242921)
-- Name: company_bankaccount_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_bankaccount
	ADD CONSTRAINT company_bankaccount_pkey PRIMARY KEY (id);


--
-- TOC entry 2949 (class 2606 OID 1242957)
-- Name: company_document_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_document
	ADD CONSTRAINT company_document_pkey PRIMARY KEY (id);


--
-- TOC entry 2965 (class 2606 OID 1242940)
-- Name: customer_credit_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_credit
	ADD CONSTRAINT customer_credit_pkey PRIMARY KEY (id);


--
-- TOC entry 2982 (class 2606 OID 1242954)
-- Name: customer_node_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_node
	ADD CONSTRAINT customer_node_pkey PRIMARY KEY (node_id, customer_id);


--
-- TOC entry 3003 (class 2606 OID 1242972)
-- Name: exchange_rate_to_usd_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY exchange_rate_to_usd
	ADD CONSTRAINT exchange_rate_to_usd_pkey PRIMARY KEY (id);


--
-- TOC entry 3018 (class 2606 OID 1242993)
-- Name: gateway_account_resolved_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account_resolved
	ADD CONSTRAINT gateway_account_resolved_pkey PRIMARY KEY (id);


--
-- TOC entry 3027 (class 2606 OID 1243002)
-- Name: gateway_credit_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_credit
	ADD CONSTRAINT gateway_credit_pkey PRIMARY KEY (id);


--
-- TOC entry 3036 (class 2606 OID 1243013)
-- Name: gateway_ip_resolved_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_resolved
	ADD CONSTRAINT gateway_ip_resolved_pkey PRIMARY KEY (id);


--
-- TOC entry 3058 (class 2606 OID 1243034)
-- Name: history_customer_billtime_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_billtime
	ADD CONSTRAINT history_customer_billtime_pkey PRIMARY KEY (id);


--
-- TOC entry 3066 (class 2606 OID 1243048)
-- Name: history_customer_cc_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cc
	ADD CONSTRAINT history_customer_cc_pkey PRIMARY KEY (id);


--
-- TOC entry 3068 (class 2606 OID 1243060)
-- Name: history_customer_cpm_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cpm
	ADD CONSTRAINT history_customer_cpm_pkey PRIMARY KEY (id);


--
-- TOC entry 3073 (class 2606 OID 1243050)
-- Name: history_customer_reason_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_reason
	ADD CONSTRAINT history_customer_reason_pkey PRIMARY KEY (id);


--
-- TOC entry 3078 (class 2606 OID 1243058)
-- Name: history_gateway_billtime_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_billtime
	ADD CONSTRAINT history_gateway_billtime_pkey PRIMARY KEY (id);


--
-- TOC entry 3086 (class 2606 OID 1243065)
-- Name: history_gateway_cc_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cc
	ADD CONSTRAINT history_gateway_cc_pkey PRIMARY KEY (id);


--
-- TOC entry 3088 (class 2606 OID 1243077)
-- Name: history_gateway_cpm_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cpm
	ADD CONSTRAINT history_gateway_cpm_pkey PRIMARY KEY (id);


--
-- TOC entry 3093 (class 2606 OID 1243074)
-- Name: history_gateway_reason_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_reason
	ADD CONSTRAINT history_gateway_reason_pkey PRIMARY KEY (id);


--
-- TOC entry 3098 (class 2606 OID 1243582)
-- Name: history_outgoing_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_outgoing
	ADD CONSTRAINT history_outgoing_pkey PRIMARY KEY (trackingid);


--
-- TOC entry 3110 (class 2606 OID 1243090)
-- Name: node_format_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_format
	ADD CONSTRAINT node_format_pkey PRIMARY KEY (node_id, format_id);


--
-- TOC entry 3116 (class 2606 OID 1243097)
-- Name: node_routing_log_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_routing_log
	ADD CONSTRAINT node_routing_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3125 (class 2606 OID 1243109)
-- Name: number_modification_group_number_modification_pkey; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification_group_number_modification
	ADD CONSTRAINT number_modification_group_number_modification_pkey PRIMARY KEY (number_modification_group_id, number_modification_id);


--
-- TOC entry 2920 (class 2606 OID 1242914)
-- Name: pk_carrier; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY carrier
	ADD CONSTRAINT pk_carrier PRIMARY KEY (id);


--
-- TOC entry 2935 (class 2606 OID 1242891)
-- Name: pk_cdr; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT pk_cdr PRIMARY KEY (id);


--
-- TOC entry 3154 (class 2606 OID 1243624)
-- Name: pk_cdr_2016_09; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT pk_cdr_2016_09 PRIMARY KEY (id);


--
-- TOC entry 2939 (class 2606 OID 1242910)
-- Name: pk_company; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company
	ADD CONSTRAINT pk_company PRIMARY KEY (id);


--
-- TOC entry 2947 (class 2606 OID 1243126)
-- Name: pk_company_contact; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY "user"
	ADD CONSTRAINT pk_company_contact PRIMARY KEY (id);


--
-- TOC entry 2952 (class 2606 OID 1242924)
-- Name: pk_company_news; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_news
	ADD CONSTRAINT pk_company_news PRIMARY KEY (news_id, company_id);


--
-- TOC entry 2957 (class 2606 OID 1242926)
-- Name: pk_context_gateway; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY context_gateway
	ADD CONSTRAINT pk_context_gateway PRIMARY KEY (gateway_id, context_id);


--
-- TOC entry 2959 (class 2606 OID 1242933)
-- Name: pk_country; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY country
	ADD CONSTRAINT pk_country PRIMARY KEY (id);


--
-- TOC entry 2963 (class 2606 OID 1242935)
-- Name: pk_customer; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer
	ADD CONSTRAINT pk_customer PRIMARY KEY (id);


--
-- TOC entry 2969 (class 2606 OID 1243044)
-- Name: pk_customer_invoice; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_invoice
	ADD CONSTRAINT pk_customer_invoice PRIMARY KEY (id);


--
-- TOC entry 2973 (class 2606 OID 1242942)
-- Name: pk_customer_ip; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_ip
	ADD CONSTRAINT pk_customer_ip PRIMARY KEY (id);


--
-- TOC entry 2979 (class 2606 OID 1242947)
-- Name: pk_customer_ip_statistic; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_ip_statistic
	ADD CONSTRAINT pk_customer_ip_statistic PRIMARY KEY (id);


--
-- TOC entry 2990 (class 2606 OID 1243022)
-- Name: pk_customer_price; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_price
	ADD CONSTRAINT pk_customer_price PRIMARY KEY (id);


--
-- TOC entry 2992 (class 2606 OID 1242960)
-- Name: pk_customer_pricelist; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_pricelist
	ADD CONSTRAINT pk_customer_pricelist PRIMARY KEY (id);


--
-- TOC entry 2997 (class 2606 OID 1242962)
-- Name: pk_dialcode; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY dialcode
	ADD CONSTRAINT pk_dialcode PRIMARY KEY (id);


--
-- TOC entry 2999 (class 2606 OID 1242968)
-- Name: pk_error; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY error
	ADD CONSTRAINT pk_error PRIMARY KEY (id);


--
-- TOC entry 3008 (class 2606 OID 1242977)
-- Name: pk_format; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY format
	ADD CONSTRAINT pk_format PRIMARY KEY (id);


--
-- TOC entry 3012 (class 2606 OID 1242981)
-- Name: pk_format_gateway; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY format_gateway
	ADD CONSTRAINT pk_format_gateway PRIMARY KEY (format_id, gateway_id);


--
-- TOC entry 2908 (class 2606 OID 1242983)
-- Name: pk_gateway; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway
	ADD CONSTRAINT pk_gateway PRIMARY KEY (id);


--
-- TOC entry 3016 (class 2606 OID 1242988)
-- Name: pk_gateway_account; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account
	ADD CONSTRAINT pk_gateway_account PRIMARY KEY (id);


--
-- TOC entry 3024 (class 2606 OID 1242995)
-- Name: pk_gateway_account_statistic; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account_statistic
	ADD CONSTRAINT pk_gateway_account_statistic PRIMARY KEY (id);


--
-- TOC entry 3030 (class 2606 OID 1243004)
-- Name: pk_gateway_ip; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip
	ADD CONSTRAINT pk_gateway_ip PRIMARY KEY (id);


--
-- TOC entry 3034 (class 2606 OID 1243009)
-- Name: pk_gateway_ip_node; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_node
	ADD CONSTRAINT pk_gateway_ip_node PRIMARY KEY (gateway_ip_id, node_id);


--
-- TOC entry 3042 (class 2606 OID 1243015)
-- Name: pk_gateway_ip_statistic; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_statistic
	ADD CONSTRAINT pk_gateway_ip_statistic PRIMARY KEY (id);


--
-- TOC entry 3049 (class 2606 OID 1243406)
-- Name: pk_gateway_price; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_price
	ADD CONSTRAINT pk_gateway_price PRIMARY KEY (id);


--
-- TOC entry 3051 (class 2606 OID 1243027)
-- Name: pk_gateway_pricelist; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_pricelist
	ADD CONSTRAINT pk_gateway_pricelist PRIMARY KEY (id);


--
-- TOC entry 3056 (class 2606 OID 1243029)
-- Name: pk_gateway_timeband; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_timeband
	ADD CONSTRAINT pk_gateway_timeband PRIMARY KEY (id);


--
-- TOC entry 3101 (class 2606 OID 1243081)
-- Name: pk_incorrect_callername; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY incorrect_callername
	ADD CONSTRAINT pk_incorrect_callername PRIMARY KEY (id);


--
-- TOC entry 3104 (class 2606 OID 1243084)
-- Name: pk_news; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY news
	ADD CONSTRAINT pk_news PRIMARY KEY (id);


--
-- TOC entry 3107 (class 2606 OID 1243086)
-- Name: pk_node; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node
	ADD CONSTRAINT pk_node PRIMARY KEY (id);


--
-- TOC entry 3113 (class 2606 OID 1243093)
-- Name: pk_node_ip; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_ip
	ADD CONSTRAINT pk_node_ip PRIMARY KEY (id);


--
-- TOC entry 3118 (class 2606 OID 1243100)
-- Name: pk_node_statistic; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_statistic
	ADD CONSTRAINT pk_node_statistic PRIMARY KEY (id);


--
-- TOC entry 3121 (class 2606 OID 1243103)
-- Name: pk_number_modification; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification
	ADD CONSTRAINT pk_number_modification PRIMARY KEY (id);


--
-- TOC entry 3123 (class 2606 OID 1243106)
-- Name: pk_number_modification_group; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification_group
	ADD CONSTRAINT pk_number_modification_group PRIMARY KEY (id);


--
-- TOC entry 3129 (class 2606 OID 1243111)
-- Name: pk_protocol; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY protocol
	ADD CONSTRAINT pk_protocol PRIMARY KEY (id);


--
-- TOC entry 2955 (class 2606 OID 1242928)
-- Name: pk_qos_level; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY context
	ADD CONSTRAINT pk_qos_level PRIMARY KEY (id);


--
-- TOC entry 3132 (class 2606 OID 1243115)
-- Name: pk_route; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route
	ADD CONSTRAINT pk_route PRIMARY KEY (id);


--
-- TOC entry 3134 (class 2606 OID 1243120)
-- Name: pk_route_to_gateway; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route_to_gateway
	ADD CONSTRAINT pk_route_to_gateway PRIMARY KEY (id);


--
-- TOC entry 3138 (class 2606 OID 1243124)
-- Name: pk_tmp_vin; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY tmp_vinculum
	ADD CONSTRAINT pk_tmp_vin PRIMARY KEY (id);


--
-- TOC entry 3140 (class 2606 OID 1243128)
-- Name: pk_user_responsibility; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY user_responsibility
	ADD CONSTRAINT pk_user_responsibility PRIMARY KEY (id);


--
-- TOC entry 3136 (class 2606 OID 1243122)
-- Name: routing_decision_price_route_is_lcr_all_destinations_key; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY routing_decision
	ADD CONSTRAINT routing_decision_price_route_is_lcr_all_destinations_key UNIQUE (price, route, is_lcr, all_destinations);


--
-- TOC entry 3010 (class 2606 OID 1242979)
-- Name: up_name; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY format
	ADD CONSTRAINT up_name UNIQUE (name);


--
-- TOC entry 2912 (class 2606 OID 1242884)
-- Name: uq_cache_number_gateway_statistic; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cache_number_gateway_statistic
	ADD CONSTRAINT uq_cache_number_gateway_statistic UNIQUE (number, gateway_id);


--
-- TOC entry 3001 (class 2606 OID 1242970)
-- Name: uq_error_code; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY error
	ADD CONSTRAINT uq_error_code UNIQUE (code);


--
-- TOC entry 3005 (class 2606 OID 1242974)
-- Name: uq_exchange_rate; Type: CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY exchange_rate_to_usd
	ADD CONSTRAINT uq_exchange_rate UNIQUE (currency);


--
-- TOC entry 3062 (class 1259 OID 1243051)
-- Name: history_customer_cc_customer_id_idx; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX history_customer_cc_customer_id_idx ON history_customer_cc USING btree (customer_id);


--
-- TOC entry 3063 (class 1259 OID 1243052)
-- Name: history_customer_cc_datetime_idx; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX history_customer_cc_datetime_idx ON history_customer_cc USING btree (datetime);


--
-- TOC entry 3064 (class 1259 OID 1243053)
-- Name: history_customer_cc_node_id_idx; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX history_customer_cc_node_id_idx ON history_customer_cc USING btree (node_id);


--
-- TOC entry 3082 (class 1259 OID 1243070)
-- Name: history_gateway_cc_datetime_idx; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX history_gateway_cc_datetime_idx ON history_gateway_cc USING btree (datetime);


--
-- TOC entry 3083 (class 1259 OID 1243071)
-- Name: history_gateway_cc_gateway_id_idx; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX history_gateway_cc_gateway_id_idx ON history_gateway_cc USING btree (gateway_id);


--
-- TOC entry 3084 (class 1259 OID 1243072)
-- Name: history_gateway_cc_node_id_idx; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX history_gateway_cc_node_id_idx ON history_gateway_cc USING btree (node_id);


--
-- TOC entry 2942 (class 1259 OID 1242919)
-- Name: ix_ca_company; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_ca_company ON company_address USING btree (company_id);


--
-- TOC entry 2913 (class 1259 OID 1242885)
-- Name: ix_cache_route; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cache_route ON cache_route USING btree (target_gateway_id, target, node_id);


--
-- TOC entry 2914 (class 1259 OID 1242886)
-- Name: ix_cache_route_clustered; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cache_route_clustered ON cache_route USING btree (target_node_id, target, node_id);

ALTER TABLE cache_route CLUSTER ON ix_cache_route_clustered;


--
-- TOC entry 2917 (class 1259 OID 1242915)
-- Name: ix_carrier_country; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_carrier_country ON carrier USING btree (country_id);


--
-- TOC entry 2918 (class 1259 OID 1242916)
-- Name: ix_carrier_name; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_carrier_name ON carrier USING btree (name);


--
-- TOC entry 2945 (class 1259 OID 1242922)
-- Name: ix_cb_company; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cb_company ON company_bankaccount USING btree (company_id);


--
-- TOC entry 3141 (class 1259 OID 1243625)
-- Name: ix_cdr_2016_09_cp; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_cp ON cdr_2016_09 USING btree (customer_price_id) WHERE (customer_price_id IS NOT NULL);


--
-- TOC entry 3142 (class 1259 OID 1243626)
-- Name: ix_cdr_2016_09_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_customer ON cdr_2016_09 USING btree (customer_id);


--
-- TOC entry 3143 (class 1259 OID 1243627)
-- Name: ix_cdr_2016_09_dialcode; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_dialcode ON cdr_2016_09 USING btree (dialcode_id);


--
-- TOC entry 3144 (class 1259 OID 1243628)
-- Name: ix_cdr_2016_09_ended_sqltime; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_ended_sqltime ON cdr_2016_09 USING btree (ended, sqltime DESC);


--
-- TOC entry 3145 (class 1259 OID 1243629)
-- Name: ix_cdr_2016_09_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_gateway ON cdr_2016_09 USING btree (gateway_id);


--
-- TOC entry 3146 (class 1259 OID 1243630)
-- Name: ix_cdr_2016_09_gp; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_gp ON cdr_2016_09 USING btree (gateway_price_id) WHERE (gateway_price_id IS NOT NULL);


--
-- TOC entry 3147 (class 1259 OID 1243631)
-- Name: ix_cdr_2016_09_node_ended_for_initialize; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_node_ended_for_initialize ON cdr_2016_09 USING btree (node_id, ended) WHERE (ended = false);


--
-- TOC entry 3148 (class 1259 OID 1243632)
-- Name: ix_cdr_2016_09_rtp; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_rtp ON cdr_2016_09 USING btree (rtp_addr) WHERE ((rtp_addr IS NOT NULL) AND (rtp_addr <> ''::text));


--
-- TOC entry 3149 (class 1259 OID 1243633)
-- Name: ix_cdr_2016_09_sqltime_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_sqltime_customer ON cdr_2016_09 USING btree (sqltime, customer_id);


--
-- TOC entry 3150 (class 1259 OID 1243634)
-- Name: ix_cdr_2016_09_sqltime_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_sqltime_gateway ON cdr_2016_09 USING btree (sqltime, gateway_id);


--
-- TOC entry 3151 (class 1259 OID 1243635)
-- Name: ix_cdr_2016_09_sqltime_gatewayidnotnull; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_sqltime_gatewayidnotnull ON cdr_2016_09 USING btree (sqltime) WHERE (gateway_id IS NOT NULL);


--
-- TOC entry 3152 (class 1259 OID 1243636)
-- Name: ix_cdr_2016_09_sqltime_sqltime_end; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_2016_09_sqltime_sqltime_end ON cdr_2016_09 USING btree (sqltime, sqltime_end);


--
-- TOC entry 2922 (class 1259 OID 1242892)
-- Name: ix_cdr_cp; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_cp ON cdr USING btree (customer_price_id) WHERE (customer_price_id IS NOT NULL);


--
-- TOC entry 2923 (class 1259 OID 1242893)
-- Name: ix_cdr_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_customer ON cdr USING btree (customer_id);


--
-- TOC entry 2924 (class 1259 OID 1242894)
-- Name: ix_cdr_dialcode; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_dialcode ON cdr USING btree (dialcode_id);


--
-- TOC entry 2925 (class 1259 OID 1242895)
-- Name: ix_cdr_ended_sqltime; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_ended_sqltime ON cdr USING btree (ended, sqltime DESC);


--
-- TOC entry 2926 (class 1259 OID 1242896)
-- Name: ix_cdr_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_gateway ON cdr USING btree (gateway_id);


--
-- TOC entry 2927 (class 1259 OID 1242897)
-- Name: ix_cdr_gp; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_gp ON cdr USING btree (gateway_price_id) WHERE (gateway_price_id IS NOT NULL);


--
-- TOC entry 2928 (class 1259 OID 1242898)
-- Name: ix_cdr_node_ended_for_initialize; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_node_ended_for_initialize ON cdr USING btree (node_id, ended) WHERE (ended = false);


--
-- TOC entry 2929 (class 1259 OID 1242899)
-- Name: ix_cdr_rtp; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_rtp ON cdr USING btree (rtp_addr) WHERE ((rtp_addr IS NOT NULL) AND (rtp_addr <> ''::text));


--
-- TOC entry 2930 (class 1259 OID 1242900)
-- Name: ix_cdr_sqltime_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_sqltime_customer ON cdr USING btree (sqltime, customer_id);


--
-- TOC entry 2931 (class 1259 OID 1242901)
-- Name: ix_cdr_sqltime_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_sqltime_gateway ON cdr USING btree (sqltime, gateway_id);


--
-- TOC entry 2932 (class 1259 OID 1242902)
-- Name: ix_cdr_sqltime_gatewayidnotnull; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_sqltime_gatewayidnotnull ON cdr USING btree (sqltime) WHERE (gateway_id IS NOT NULL);


--
-- TOC entry 2933 (class 1259 OID 1242903)
-- Name: ix_cdr_sqltime_sqltime_end; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cdr_sqltime_sqltime_end ON cdr USING btree (sqltime, sqltime_end);


--
-- TOC entry 2966 (class 1259 OID 1243045)
-- Name: ix_ci_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_ci_customer ON customer_invoice USING btree (customer_id);


--
-- TOC entry 2967 (class 1259 OID 1243046)
-- Name: ix_ci_user; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_ci_user ON customer_invoice USING btree (payment_ack_by);


--
-- TOC entry 2974 (class 1259 OID 1242948)
-- Name: ix_cis_customer_ip; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cis_customer_ip ON customer_ip_statistic USING btree (customer_ip_id);


--
-- TOC entry 2975 (class 1259 OID 1242949)
-- Name: ix_cis_date_customer_ip; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cis_date_customer_ip ON customer_ip_statistic USING btree (date, customer_ip_id);


--
-- TOC entry 2976 (class 1259 OID 1242950)
-- Name: ix_cis_date_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cis_date_node ON customer_ip_statistic USING btree (date, node_id);


--
-- TOC entry 2977 (class 1259 OID 1242951)
-- Name: ix_cis_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cis_node ON customer_ip_statistic USING btree (node_id);


--
-- TOC entry 2983 (class 1259 OID 1242955)
-- Name: ix_cn_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cn_customer ON customer_node USING btree (customer_id);


--
-- TOC entry 2921 (class 1259 OID 1242889)
-- Name: ix_cnf_wrong_name; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX ix_cnf_wrong_name ON carrier_name_fix USING btree (wrong_name);


--
-- TOC entry 2937 (class 1259 OID 1242911)
-- Name: ix_company_country; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_company_country ON company USING btree (country_id);


--
-- TOC entry 2953 (class 1259 OID 1242929)
-- Name: ix_context_name; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX ix_context_name ON context USING btree (name);


--
-- TOC entry 2984 (class 1259 OID 1243038)
-- Name: ix_cp_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cp_customer ON customer_price USING btree (customer_id);


--
-- TOC entry 2985 (class 1259 OID 1243039)
-- Name: ix_cp_customer_pricelist; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cp_customer_pricelist ON customer_price USING btree (customer_pricelist_id);


--
-- TOC entry 2986 (class 1259 OID 1243040)
-- Name: ix_cp_customer_subnumber; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cp_customer_subnumber ON customer_price USING btree (customer_id, "substring"(number, 1, 2));


--
-- TOC entry 2987 (class 1259 OID 1243041)
-- Name: ix_cp_number_cpid_valid; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cp_number_cpid_valid ON customer_price USING btree (number, customer_id, valid_from, valid_to);


--
-- TOC entry 2988 (class 1259 OID 1243042)
-- Name: ix_cp_number_valid_from_valid_to; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_cp_number_valid_from_valid_to ON customer_price USING btree (number, valid_from, valid_to);


--
-- TOC entry 2960 (class 1259 OID 1242936)
-- Name: ix_customer_company; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_customer_company ON customer USING btree (company_id);


--
-- TOC entry 2970 (class 1259 OID 1242943)
-- Name: ix_customer_ip_address; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_customer_ip_address ON customer_ip USING btree (address);


--
-- TOC entry 2971 (class 1259 OID 1242944)
-- Name: ix_customer_ip_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_customer_ip_customer ON customer_ip USING btree (customer_id);


--
-- TOC entry 2961 (class 1259 OID 1242937)
-- Name: ix_customer_qos_level; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_customer_qos_level ON customer USING btree (context_id);


--
-- TOC entry 2993 (class 1259 OID 1242963)
-- Name: ix_dc_carrier; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_dc_carrier ON dialcode USING btree (carrier_id);


--
-- TOC entry 2950 (class 1259 OID 1242958)
-- Name: ix_dc_company; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_dc_company ON company_document USING btree (company_id);


--
-- TOC entry 2994 (class 1259 OID 1242964)
-- Name: ix_dc_number_valid; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_dc_number_valid ON dialcode USING btree (number, valid_from, valid_to);


--
-- TOC entry 2995 (class 1259 OID 1242965)
-- Name: ix_dialcode_number; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_dialcode_number ON dialcode USING btree (number, valid_from);


--
-- TOC entry 3019 (class 1259 OID 1242996)
-- Name: ix_gas_date_gateway_account; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gas_date_gateway_account ON gateway_account_statistic USING btree (date, gateway_account_id);


--
-- TOC entry 3020 (class 1259 OID 1242997)
-- Name: ix_gas_date_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gas_date_node ON gateway_account_statistic USING btree (date, node_id);


--
-- TOC entry 3021 (class 1259 OID 1242998)
-- Name: ix_gas_gateway_account; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gas_gateway_account ON gateway_account_statistic USING btree (gateway_account_id);


--
-- TOC entry 3022 (class 1259 OID 1242999)
-- Name: ix_gas_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gas_node ON gateway_account_statistic USING btree (node_id);


--
-- TOC entry 3013 (class 1259 OID 1242989)
-- Name: ix_gateway_account_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gateway_account_gateway ON gateway_account USING btree (gateway_id);


--
-- TOC entry 3014 (class 1259 OID 1242990)
-- Name: ix_gateway_account_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gateway_account_node ON gateway_account USING btree (node_id);


--
-- TOC entry 2906 (class 1259 OID 1242984)
-- Name: ix_gateway_company; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gateway_company ON gateway USING btree (company_id);


--
-- TOC entry 3028 (class 1259 OID 1243005)
-- Name: ix_gateway_ip_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gateway_ip_gateway ON gateway_ip USING btree (gateway_id);


--
-- TOC entry 3031 (class 1259 OID 1243010)
-- Name: ix_gateway_ip_node_gateway_ip; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gateway_ip_node_gateway_ip ON gateway_ip_node USING btree (gateway_ip_id);


--
-- TOC entry 3032 (class 1259 OID 1243011)
-- Name: ix_gateway_ip_node_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gateway_ip_node_node ON gateway_ip_node USING btree (node_id);


--
-- TOC entry 3037 (class 1259 OID 1243016)
-- Name: ix_gid_date_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gid_date_node ON gateway_ip_statistic USING btree (date, node_id);


--
-- TOC entry 3038 (class 1259 OID 1243017)
-- Name: ix_gis_date_gateway_ip2; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gis_date_gateway_ip2 ON gateway_ip_statistic USING btree (date NULLS FIRST, gateway_ip_id NULLS FIRST);


--
-- TOC entry 3039 (class 1259 OID 1243018)
-- Name: ix_gis_gateway_ip; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gis_gateway_ip ON gateway_ip_statistic USING btree (gateway_ip_id);


--
-- TOC entry 3040 (class 1259 OID 1243019)
-- Name: ix_gis_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gis_node ON gateway_ip_statistic USING btree (node_id);


--
-- TOC entry 3044 (class 1259 OID 1243477)
-- Name: ix_gwp_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwp_gateway ON gateway_price USING btree (gateway_id);


--
-- TOC entry 3045 (class 1259 OID 1243478)
-- Name: ix_gwp_gateway_pricelist; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwp_gateway_pricelist ON gateway_price USING btree (gateway_pricelist_id);


--
-- TOC entry 3046 (class 1259 OID 1243479)
-- Name: ix_gwp_gateway_subnumber; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwp_gateway_subnumber ON gateway_price USING btree (gateway_id, "substring"(number, 1, 2));


--
-- TOC entry 3047 (class 1259 OID 1243480)
-- Name: ix_gwp_number_valid; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwp_number_valid ON gateway_price USING btree (number, valid_from, valid_to);


--
-- TOC entry 3052 (class 1259 OID 1243030)
-- Name: ix_gwt_carrier; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwt_carrier ON gateway_timeband USING btree (carrier_id);


--
-- TOC entry 3053 (class 1259 OID 1243031)
-- Name: ix_gwt_gateway_pricelist; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwt_gateway_pricelist ON gateway_timeband USING btree (gateway_pricelist_id);


--
-- TOC entry 3054 (class 1259 OID 1243032)
-- Name: ix_gwt_gateway_valid; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_gwt_gateway_valid ON gateway_timeband USING btree (gateway_id, valid_from, valid_to);


--
-- TOC entry 3059 (class 1259 OID 1243035)
-- Name: ix_hcb_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hcb_customer ON history_customer_billtime USING btree (customer_id);


--
-- TOC entry 3060 (class 1259 OID 1243036)
-- Name: ix_hcb_date; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hcb_date ON history_customer_billtime USING btree (date);


--
-- TOC entry 3061 (class 1259 OID 1243037)
-- Name: ix_hcb_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hcb_node ON history_customer_billtime USING btree (node_id);


--
-- TOC entry 3069 (class 1259 OID 1243067)
-- Name: ix_hccpm_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hccpm_customer ON history_customer_cpm USING btree (customer_id);


--
-- TOC entry 3070 (class 1259 OID 1243068)
-- Name: ix_hccpm_datetime; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hccpm_datetime ON history_customer_cpm USING btree (datetime);


--
-- TOC entry 3071 (class 1259 OID 1243069)
-- Name: ix_hccpm_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hccpm_node ON history_customer_cpm USING btree (node_id);


--
-- TOC entry 3074 (class 1259 OID 1243054)
-- Name: ix_hcr_customer; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hcr_customer ON history_customer_reason USING btree (customer_id);


--
-- TOC entry 3075 (class 1259 OID 1243055)
-- Name: ix_hcr_date; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hcr_date ON history_customer_reason USING btree (date);


--
-- TOC entry 3076 (class 1259 OID 1243056)
-- Name: ix_hcr_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hcr_node ON history_customer_reason USING btree (node_id);


--
-- TOC entry 3079 (class 1259 OID 1243061)
-- Name: ix_hgb_date; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgb_date ON history_gateway_billtime USING btree (date);


--
-- TOC entry 3080 (class 1259 OID 1243062)
-- Name: ix_hgb_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgb_gateway ON history_gateway_billtime USING btree (gateway_id);


--
-- TOC entry 3081 (class 1259 OID 1243063)
-- Name: ix_hgb_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgb_node ON history_gateway_billtime USING btree (node_id);


--
-- TOC entry 3089 (class 1259 OID 1243347)
-- Name: ix_hgcpm_datetime; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgcpm_datetime ON history_gateway_cpm USING btree (datetime);


--
-- TOC entry 3090 (class 1259 OID 1243353)
-- Name: ix_hgcpm_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgcpm_gateway ON history_gateway_cpm USING btree (gateway_id);


--
-- TOC entry 3091 (class 1259 OID 1243354)
-- Name: ix_hgcpm_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgcpm_node ON history_gateway_cpm USING btree (node_id);


--
-- TOC entry 3094 (class 1259 OID 1243075)
-- Name: ix_hgr_date; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgr_date ON history_gateway_reason USING btree (date);


--
-- TOC entry 3095 (class 1259 OID 1243078)
-- Name: ix_hgr_gateway; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgr_gateway ON history_gateway_reason USING btree (gateway_id);


--
-- TOC entry 3096 (class 1259 OID 1243079)
-- Name: ix_hgr_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_hgr_node ON history_gateway_reason USING btree (node_id);


--
-- TOC entry 3099 (class 1259 OID 1243599)
-- Name: ix_ho_sqltime; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_ho_sqltime ON history_outgoing USING btree (sqltime);


--
-- TOC entry 3108 (class 1259 OID 1243091)
-- Name: ix_nf_format; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_nf_format ON node_format USING btree (format_id);


--
-- TOC entry 3111 (class 1259 OID 1243094)
-- Name: ix_node_ip_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_node_ip_node ON node_ip USING btree (node_id);


--
-- TOC entry 3105 (class 1259 OID 1243087)
-- Name: ix_node_name; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX ix_node_name ON node USING btree (name);


--
-- TOC entry 3114 (class 1259 OID 1243098)
-- Name: ix_nr_created_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_nr_created_node ON node_routing_log USING btree (created, node_id);


--
-- TOC entry 3126 (class 1259 OID 1243112)
-- Name: ix_protocol_action; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_protocol_action ON protocol USING btree (action);


--
-- TOC entry 3127 (class 1259 OID 1243113)
-- Name: ix_protocol_web_user; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_protocol_web_user ON protocol USING btree (actor_id);


--
-- TOC entry 3130 (class 1259 OID 1243116)
-- Name: ix_route_qos_level; Type: INDEX; Schema: domain; Owner: -
--

CREATE INDEX ix_route_qos_level ON route USING btree (context_id);


--
-- TOC entry 2915 (class 1259 OID 1242887)
-- Name: pk_cache_route; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX pk_cache_route ON cache_route USING btree (id);


--
-- TOC entry 3155 (class 1259 OID 1243637)
-- Name: uq_cdr_2016_09_billid_chan_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_cdr_2016_09_billid_chan_node ON cdr_2016_09 USING btree (billid, chan, node_id);


--
-- TOC entry 2936 (class 1259 OID 1242904)
-- Name: uq_cdr_billid_chan_node; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_cdr_billid_chan_node ON cdr USING btree (billid, chan, node_id);

ALTER TABLE cdr CLUSTER ON uq_cdr_billid_chan_node;


--
-- TOC entry 2980 (class 1259 OID 1242952)
-- Name: uq_cis_dcn; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_cis_dcn ON customer_ip_statistic USING btree (date, customer_ip_id, node_id, balance_db_load);


--
-- TOC entry 2916 (class 1259 OID 1242888)
-- Name: uq_endpoint; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_endpoint ON cache_route USING btree (node_id, action);


--
-- TOC entry 3006 (class 1259 OID 1242975)
-- Name: uq_exchange_rate_to_usd; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_exchange_rate_to_usd ON exchange_rate_to_usd USING btree (currency);


--
-- TOC entry 3025 (class 1259 OID 1243000)
-- Name: uq_gas_dgn; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_gas_dgn ON gateway_account_statistic USING btree (date, gateway_account_id, node_id, balance_db_load);


--
-- TOC entry 3043 (class 1259 OID 1243020)
-- Name: uq_gis_dgn; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_gis_dgn ON gateway_ip_statistic USING btree (date, gateway_ip_id, node_id, balance_db_load);


--
-- TOC entry 3102 (class 1259 OID 1243082)
-- Name: uq_name; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_name ON incorrect_callername USING btree (name);


--
-- TOC entry 3119 (class 1259 OID 1243101)
-- Name: uq_ns_dn; Type: INDEX; Schema: domain; Owner: -
--

CREATE UNIQUE INDEX uq_ns_dn ON node_statistic USING btree (date, node_id, balance_db_load);


--
-- TOC entry 339 (class 1255 OID 1239117)
-- Name: check_dialcode_time_cover(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION check_dialcode_time_cover() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_count integer;
	BEGIN
		PERFORM * FROM dialcode WHERE NEW.number = number AND (NEW.valid_from BETWEEN valid_from AND valid_to OR NEW.valid_to BETWEEN valid_from AND valid_to);

		IF FOUND THEN
			RAISE EXCEPTION 'Date constraints of number % collide with an existing dialcode!', NEW.number;
			RETURN NULL;
		ELSE
			RETURN NEW;
		END IF;
	END;
$$;


--
-- TOC entry 3268 (class 2620 OID 1242966)
-- Name: t_check_dialcode_time_cover; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER t_check_dialcode_time_cover BEFORE INSERT OR UPDATE ON dialcode FOR EACH ROW EXECUTE PROCEDURE check_dialcode_time_cover();

ALTER TABLE dialcode DISABLE TRIGGER t_check_dialcode_time_cover;


--
-- TOC entry 437 (class 1255 OID 1239246)
-- Name: tr_price_update(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_price_update() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_billtime numeric(13,8);
		i_fbi INTEGER;
		i_nbi INTEGER;
		i_gateway_price_flat_price NUMERIC(10,7)=NULL;
		i_gateway_price_flat_currency CHARACTER(3);
		i_gateway_price_flat_dialcode TEXT;
		i_gateway_price_flat_id BIGINT=NULL;
		i_gateway_price_other_price NUMERIC(10,7)=NULL;
		i_gateway_price_other_currency CHARACTER(3);
		i_gateway_price_other_dialcode TEXT;
		i_gateway_price_other_id BIGINT=NULL;
		i_gateway_price_price NUMERIC(10,7)=NULL;
		i_gateway_price_currency CHARACTER(3);
		i_gateway_price_dialcode TEXT;
		i_gateway_price_id BIGINT=NULL;
		i_tmp TEXT;
		i_min numeric(13,8);
		i_real_billtime BIGINT;
	BEGIN		
		-- CUSTOMER
		IF NEW.customer_price_id IS NOT NULL THEN

			SELECT first_billing_increment, next_billing_increment INTO i_fbi, i_nbi FROM customer_price WHERE id = NEW.customer_price_id;
			
			NEW.customer_price_total := internal_util_total_price(i_fbi, i_nbi, NEW.billtime, NEW.customer_price_per_min);
			
		ELSEIF NEW.customer_id IS NOT NULL THEN
		
			i_tmp := internal_util_delete_prefix(NEW.called);
			i_tmp := (SELECT TRIM(LEADING '0' FROM i_tmp));
			i_tmp := (SELECT TRIM(LEADING '+' FROM i_tmp));
			
			SELECT id, price, currency, first_billing_increment, next_billing_increment 
					INTO NEW.customer_price_id, NEW.customer_price_per_min, NEW.customer_currency, i_fbi, i_nbi
				FROM customer_price
				WHERE number IN (SELECT * FROM internal_util_number_to_table(i_tmp)) AND customer_id = NEW.customer_id
					AND NEW.sqltime BETWEEN valid_from AND valid_to
				ORDER BY LENGTH(number) DESC LIMIT 1;

			NEW.customer_price_total := internal_util_total_price(i_fbi, i_nbi, NEW.billtime, NEW.customer_price_per_min);
					
		ELSEIF NEW.gateway_price_per_min IS NOT NULL THEN

			SELECT first_billing_increment, next_billing_increment INTO i_fbi, i_nbi FROM gateway_price WHERE id = NEW.gateway_price_id;

			NEW.gateway_price_total := internal_util_total_price(i_fbi, i_nbi, NEW.billtime, NEW.gateway_price_per_min);
		
		ELSEIF NEW.direction = 'outgoing' AND NEW.gateway_id IS NOT NULL THEN
			-- IF GATEWAY PRICE WAS NOT CALCULATED IN ROUTING (BECAUSE NO LCR) CALCULATE NOW
			-- FLAT
			SELECT id, price, currency, number, first_billing_increment, next_billing_increment 
					INTO i_gateway_price_flat_id, i_gateway_price_flat_price, i_gateway_price_flat_currency, i_gateway_price_flat_dialcode, i_fbi, i_nbi
				FROM gateway_price
				WHERE number IN (SELECT * FROM internal_util_number_to_table(NEW.called)) AND gateway_id = NEW.gateway_id
					AND NEW.sqltime BETWEEN valid_from AND valid_to AND timeband = 'Flat'
				ORDER BY LENGTH(number) DESC LIMIT 1;
	
			-- NON FLAT IF FLAT NOT FOUND
			IF i_gateway_price_flat_id IS NULL THEN
				SELECT id, price, currency, number, first_billing_increment, next_billing_increment
						INTO i_gateway_price_other_id, i_gateway_price_other_price, i_gateway_price_other_currency, i_gateway_price_other_dialcode, i_fbi, i_nbi
					FROM gateway_price 
					WHERE number IN (SELECT * FROM internal_util_number_to_table(NEW.called)) AND NEW.sqltime BETWEEN valid_from AND valid_to AND
					gateway_id = NEW.gateway_id AND timeband IN
					(
						SELECT timeband FROM gateway_timeband
						WHERE NEW.sqltime BETWEEN gateway_timeband.valid_from AND gateway_timeband.valid_to
							AND "time"(NEW.sqltime) BETWEEN time_from AND time_to
							AND day_of_week = EXTRACT(DOW FROM NEW.sqltime)
							AND gateway_id = NEW.gateway_id
							AND carrier_id = (SELECT carrier_id FROM dialcode
									WHERE "number" IN (SELECT * FROM internal_util_number_to_table(NEW.called))
										AND NEW.sqltime BETWEEN dialcode.valid_from AND dialcode.valid_to
									ORDER BY LENGTH(number) DESC LIMIT 1)
					)
					ORDER BY LENGTH(number) DESC, price ASC LIMIT 1;
				
				IF NOT FOUND THEN
					RETURN NEW;
				END IF;
								
				-- SET NON FLAT PRICING
				NEW.gateway_price_per_min := i_gateway_price_other_price;
				NEW.gateway_currency := i_gateway_price_other_currency;
				NEW.gateway_price_id := i_gateway_price_other_id;
					
			ELSE	-- SET FLAT PRICING
				NEW.gateway_price_per_min := i_gateway_price_flat_price;
				NEW.gateway_currency := i_gateway_price_flat_currency;
				NEW.gateway_price_id := i_gateway_price_flat_id;
			END IF;

			NEW.gateway_price_total := internal_util_total_price(i_fbi, i_nbi, NEW.billtime, NEW.gateway_price_per_min);
			
		END IF;
		
		RETURN NEW;
	END;
$$;


--
-- TOC entry 3259 (class 2620 OID 1242905)
-- Name: t_price_update; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER t_price_update BEFORE INSERT OR UPDATE ON cdr FOR EACH ROW EXECUTE PROCEDURE tr_price_update();

ALTER TABLE cdr DISABLE TRIGGER t_price_update;


--
-- TOC entry 3278 (class 2620 OID 1243638)
-- Name: t_price_update; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER t_price_update BEFORE INSERT OR UPDATE ON cdr_2016_09 FOR EACH ROW EXECUTE PROCEDURE tr_price_update();


--
-- TOC entry 440 (class 1255 OID 1239249)
-- Name: tr_statistic_update(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_statistic_update() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_call_add INTEGER = 0;
		i_call_total_add INTEGER = 0;
		i_call_failed_add INTEGER = 0;
		i_old_billtime BIGINT=0;
		i_gateway_ip_id INTEGER=NULL;
		i_gateway_account_id INTEGER=NULL;
		i_customer_ip_id INTEGER=NULL;
		i_date DATE;
		i_node_id INTEGER;
		i_balancedbload SMALLINT:=(RANDOM()*10)::SMALLINT;
		i_sqltime TIMESTAMPTZ;
		i_country_id INT;
BEGIN
	i_call_failed_add := 0;
	i_call_add := 0;
	
	-- CUSTOMER
	IF NEW.direction = 'incoming' AND NEW.customer_ip_id IS NOT NULL THEN
		
		IF TG_OP = 'INSERT' THEN
			i_date := DATE(NEW.sqltime AT TIME ZONE 'UTC');
			i_customer_ip_id := NEW.customer_ip_id;
			i_node_id := NEW.node_id;
			i_call_total_add := 1;
				
			IF NEW.ended THEN
				i_call_add := 0;

				IF NEW.billtime = 0 THEN
					i_call_failed_add := 1;
				END IF;
			ELSE
				i_call_add := 1;
			END IF;
		ELSEIF TG_OP = 'UPDATE' THEN		
			i_old_billtime := OLD.billtime;
			
			IF i_old_billtime IS NULL THEN
				i_old_billtime := 0;
			END IF;
			
			i_customer_ip_id := NEW.customer_ip_id;
			i_date := DATE(OLD.sqltime AT TIME ZONE 'UTC');
			i_node_id := OLD.node_id;

			IF NEW.ended = false AND OLD.customer_ip_id IS NULL THEN
				i_call_add := 1;			
			ELSEIF NEW.ended THEN
				i_call_add := -1;
	
				IF NEW.billtime = 0 THEN
					i_call_failed_add := 1;
				END IF;
			END IF;
		END IF;

	
		IF i_customer_ip_id IS NOT NULL THEN
			LOOP
				UPDATE customer_ip_statistic SET concurrent_calls = concurrent_calls + i_call_add,
						billtime = billtime + (NEW.billtime - i_old_billtime),
						calls_total = (calls_total + i_call_total_add),
						calls_failed = (calls_failed + i_call_failed_add)
					WHERE customer_ip_statistic.date = i_date AND customer_ip_id = i_customer_ip_id AND node_id = i_node_id AND balance_db_load = i_balancedbload;
				EXIT WHEN FOUND;
				
				BEGIN
					INSERT INTO customer_ip_statistic (customer_ip_id, date, concurrent_calls, billtime, calls_total, calls_failed, node_id, balance_db_load)
						VALUES (i_customer_ip_id, i_date, i_call_add, (NEW.billtime - i_old_billtime), i_call_total_add, i_call_failed_add, i_node_id, i_balancedbload);

					EXIT;
				EXCEPTION WHEN unique_violation THEN
					-- NOTHING
				END;
			END LOOP;
		END IF;
	ELSEIF NEW.direction = 'outgoing' AND (NEW.gateway_ip_id IS NOT NULL OR NEW.gateway_account_id IS NOT NULL) THEN -- GATEWAY
		IF TG_OP = 'INSERT' THEN
			i_gateway_ip_id := NEW.gateway_ip_id;
			i_gateway_account_id := NEW.gateway_account_id;
			i_date := DATE(NEW.sqltime AT TIME ZONE 'UTC');
			i_node_id := NEW.node_id;
			i_call_total_add := 1;
			
			IF NEW.ended THEN
				i_call_add := 0;
								
				IF NEW.billtime = 0 AND NEW.reason <> 'pickup' THEN
					i_call_failed_add := 1;
				END IF;
			ELSE
				i_call_add := 1;
			END IF;
		ELSEIF TG_OP = 'UPDATE' THEN
			i_old_billtime := OLD.billtime;
			i_gateway_ip_id := NEW.gateway_ip_id;
			i_gateway_account_id := NEW.gateway_account_id;
			i_date := DATE(OLD.sqltime AT TIME ZONE 'UTC');
			i_node_id := OLD.node_id;

			IF NEW.ended = FALSE AND OLD.gateway_ip_id IS NULL AND OLD.gateway_account_id IS NULL THEN
				i_call_add := 1;
			ELSEIF NEW.ended THEN
				i_call_add := -1;
	
				IF NEW.billtime = 0 AND NEW.reason <> 'pickup' THEN
					i_call_failed_add := 1;
				END IF;
			END IF;
		END IF;

		IF i_gateway_ip_id IS NOT NULL THEN
			LOOP			
				UPDATE gateway_ip_statistic SET concurrent_calls = concurrent_calls + i_call_add,
						billtime = billtime + (NEW.billtime - i_old_billtime),
						calls_total = (calls_total + i_call_total_add),
						calls_failed = (calls_failed + i_call_failed_add)
					WHERE gateway_ip_statistic.date = i_date AND gateway_ip_id = i_gateway_ip_id AND node_id = i_node_id AND balance_db_load = i_balancedbload;

				EXIT WHEN FOUND;

				BEGIN
					INSERT INTO gateway_ip_statistic (gateway_ip_id, date, concurrent_calls, billtime, calls_total, calls_failed, node_id, balance_db_load)
						VALUES (i_gateway_ip_id, i_date, i_call_add, (NEW.billtime - i_old_billtime), i_call_total_add, i_call_failed_add, i_node_id, i_balancedbload);

					EXIT;
				EXCEPTION WHEN unique_violation THEN
					-- NOTHING
				END;
			END LOOP;
		END IF;
	
	
		IF i_gateway_account_id IS NOT NULL THEN
			LOOP
				UPDATE gateway_account_statistic SET concurrent_calls = concurrent_calls + i_call_add,
						billtime = billtime + (NEW.billtime - i_old_billtime),
						calls_total = (calls_total + i_call_total_add),
						calls_failed = (calls_failed + i_call_failed_add)
					WHERE gateway_account_statistic.date = i_date AND gateway_account_id = i_gateway_account_id AND node_id = i_node_id AND balance_db_load = i_balancedbload;

				EXIT WHEN FOUND;
					
				BEGIN
					INSERT INTO gateway_account_statistic (gateway_account_id, date, concurrent_calls, billtime, calls_total, calls_failed, node_id, balance_db_load)
						VALUES (i_gateway_account_id, i_date, i_call_add, (NEW.billtime - i_old_billtime), i_call_total_add, i_call_failed_add, i_node_id, i_balancedbload);

					EXIT;
				EXCEPTION WHEN unique_violation THEN
					-- NOTHING
				END;
			END LOOP;
		END IF;

		IF TG_OP = 'INSERT' THEN
			LOOP
				-- USING sqltime FILTERING TO MAKE USE OF PARTITIONING
				i_sqltime := (SELECT sqltime FROM cdr WHERE sqltime > (NEW.sqltime - INTERVAL '2 minutes') AND sqltime < NEW.sqltime AND billid = NEW.billid AND direction = 'incoming');
									
				-- IN CASE THAT INCOMING CDR WAS NOT STORED UNTIL NOW
				IF i_sqltime IS NULL THEN
					i_sqltime := NEW.sqltime;
				END IF;
							
				UPDATE history_outgoing SET total = total + 1, sqltime = i_sqltime WHERE trackingid = NEW.trackingid;

				EXIT WHEN FOUND;

				BEGIN
					i_country_id := (SELECT carrier.country_id FROM carrier WHERE carrier.id = (SELECT dialcode.carrier_id FROM dialcode WHERE dialcode.id = NEW.dialcode_id));
					
					INSERT INTO history_outgoing (sqltime, trackingid, total, country_id)
					VALUES (i_sqltime, NEW.trackingid, 1, i_country_id);

					EXIT;
				EXCEPTION WHEN unique_violation THEN
					-- NOTHING
				END;
			END LOOP;
		END IF;
	END IF;

	i_call_failed_add := 0;
	i_call_add := 0;
	
	-- NODE
	IF TG_OP = 'INSERT' THEN
		i_call_total_add := 1;
		i_date := DATE(NEW.sqltime AT TIME ZONE 'UTC');
		i_node_id := NEW.node_id;
		
		IF NEW.ended THEN
			
			i_call_add := 0;
			
			IF NEW.billtime = 0 AND NEW.reason <> 'pickup' THEN
				i_call_failed_add := 1;
			END IF;
		ELSE
			i_call_add := 1;
		END IF;
	
	ELSEIF TG_OP = 'UPDATE' THEN
		i_old_billtime := OLD.billtime;
		i_date := DATE(OLD.sqltime AT TIME ZONE 'UTC');
		i_node_id := OLD.node_id;
		
		IF NEW.ended = true THEN
			i_call_add := -1;

			IF NEW.billtime = 0 AND NEW.reason <> 'pickup' THEN
				i_call_failed_add := 1;
			END IF;
		END IF;

	END IF;
		
	IF i_node_id IS NOT NULL THEN
		LOOP
			UPDATE node_statistic SET concurrent_calls = concurrent_calls + i_call_add,
				billtime = billtime + (NEW.billtime - i_old_billtime),
				calls_total = (calls_total + i_call_total_add),
				calls_failed = (calls_failed + i_call_failed_add)
			WHERE node_statistic.date = i_date AND node_id = i_node_id AND balance_db_load = i_balancedbload;

			EXIT WHEN FOUND;

			BEGIN
				INSERT INTO node_statistic (date, concurrent_calls, billtime, calls_total, calls_failed, node_id, balance_db_load)
					VALUES (i_date, i_call_add, (NEW.billtime - i_old_billtime), i_call_total_add, i_call_failed_add, i_node_id, i_balancedbload);

				EXIT;
			EXCEPTION WHEN unique_violation THEN
					-- NOTHING
			END;
		END LOOP;	
	END IF;
	
	RETURN NEW;
END;
$$;


--
-- TOC entry 3260 (class 2620 OID 1242906)
-- Name: t_statistic_update; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER t_statistic_update AFTER INSERT OR UPDATE ON cdr FOR EACH ROW EXECUTE PROCEDURE tr_statistic_update();

ALTER TABLE cdr DISABLE TRIGGER t_statistic_update;


--
-- TOC entry 3279 (class 2620 OID 1243639)
-- Name: t_statistic_update; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER t_statistic_update AFTER INSERT OR UPDATE ON cdr_2016_09 FOR EACH ROW EXECUTE PROCEDURE tr_statistic_update();


--
-- TOC entry 422 (class 1255 OID 1239232)
-- Name: tr_blacklist_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_blacklist_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;

		NEW.enabled := false;
		RETURN NEW;
	END;
$$;

--
-- TOC entry 427 (class 1255 OID 1239236)
-- Name: tr_context_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_context_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;

		PERFORM * FROM customer WHERE customer.context_id = NEW.id AND customer.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Customer!';
			RETURN NULL;
		END IF;

		PERFORM * FROM route WHERE route.context_id = NEW.id AND route.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Route!';
			RETURN NULL;
		END IF;

		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 428 (class 1255 OID 1239237)
-- Name: tr_customer_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_customer_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
	
		PERFORM * FROM customer_ip WHERE customer_ip.customer_id = NEW.id AND customer_ip.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Customer IP!';
			RETURN NULL;
		END IF;
	
		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 429 (class 1255 OID 1239238)
-- Name: tr_customer_ip_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_customer_ip_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
		
		NEW.enabled := false;
		RETURN NEW;
		
	END;
$$;


--
-- TOC entry 430 (class 1255 OID 1239239)
-- Name: tr_gateway_account_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_gateway_account_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
		
		NEW.enabled := false;
		NEW.modified := true;
		RETURN NEW;
		
	END;
$$;


--
-- TOC entry 431 (class 1255 OID 1239240)
-- Name: tr_gateway_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_gateway_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
	
		PERFORM * FROM gateway_account WHERE gateway_account.gateway_id = NEW.id AND gateway_account.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Gateway Account!';
			RETURN NULL;
		END IF;

		PERFORM * FROM gateway_ip WHERE gateway_ip.gateway_id = NEW.id AND gateway_ip.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Gateway IP!';
			RETURN NULL;
		END IF;
		
		PERFORM * FROM context_gateway WHERE gateway_id = NEW.id;
		
		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Context!';
			RETURN NULL;
		END IF;
		
		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 432 (class 1255 OID 1239241)
-- Name: tr_gateway_ip_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_gateway_ip_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;

		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 433 (class 1255 OID 1239242)
-- Name: tr_node_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_node_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
		
		PERFORM * FROM gateway_account WHERE gateway_account.node_id = NEW.id AND gateway_account.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Gateway Account!';
			RETURN NULL;
		END IF;

		PERFORM * FROM gateway_ip_node
		INNER JOIN gateway_ip ON gateway_ip.id = gateway_ip_node.gateway_ip_id
		WHERE gateway_ip_node.node_id = NEW.id AND gateway_ip.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Gateway IP!';
			RETURN NULL;
		END IF;

		PERFORM * FROM customer_node WHERE customer_node.node_id = NEW.id;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Customer!';
			RETURN NULL;
		END IF;

		PERFORM * FROM node_ip WHERE node_ip.node_id = NEW.id AND node_ip.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Node!';
			RETURN NULL;
		END IF;
		
		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 434 (class 1255 OID 1239243)
-- Name: tr_node_ip_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_node_ip_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;

		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 435 (class 1255 OID 1239244)
-- Name: tr_number_modification_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_number_modification_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
		
		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 436 (class 1255 OID 1239245)
-- Name: tr_number_modification_group_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_number_modification_group_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;

		PERFORM * FROM gateway WHERE gateway.number_modification_group_id = NEW.id AND gateway.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Gateway!';
			RETURN NULL;
		END IF;
		
		PERFORM * FROM number_modification
		INNER JOIN number_modification_group_number_modification ON number_modification_group_number_modification.number_modification_id = number_modification.id AND number_modification_group_number_modification.number_modification_group_id = NEW.id
		WHERE number_modification.deleted = FALSE;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependendies for Number Modification!';
			RETURN NULL;
		END IF;
		
		NEW.enabled := false;
		RETURN NEW;
	END;
$$;


--
-- TOC entry 438 (class 1255 OID 1239247)
-- Name: tr_route_action(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_route_action() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.action = E'\\\\1' THEN
			NEW.action = E'\\1';
		END IF;

		RETURN NEW;
	END;
$$;


--
-- TOC entry 439 (class 1255 OID 1239248)
-- Name: tr_route_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_route_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN

		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
		
		NEW.enabled := false;
		RETURN NEW;
		
	END;
$$;


--
-- TOC entry 441 (class 1255 OID 1239250)
-- Name: tr_update_modified(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_update_modified() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
BEGIN
		NEW.modified = now();
		RETURN NEW;
END;
$$;


--
-- TOC entry 426 (class 1255 OID 1239235)
-- Name: tr_company_delete(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION tr_company_delete() RETURNS trigger
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.deleted = false THEN
			RETURN NEW;
		END IF;
	
		PERFORM * FROM customer WHERE customer.company_id = NEW.id AND customer.deleted = false;

		IF FOUND THEN
			RAISE EXCEPTION 'Check dependencies for Customer!';
			RETURN NULL;
		ELSE
			RETURN NEW;
		END IF;
	END;
$$;


--
-- TOC entry 3263 (class 2620 OID 1242912)
-- Name: tr_company_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_company_delete BEFORE UPDATE ON company FOR EACH ROW EXECUTE PROCEDURE tr_company_delete();


--
-- TOC entry 3264 (class 2620 OID 1242930)
-- Name: tr_context_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_context_delete BEFORE UPDATE ON context FOR EACH ROW EXECUTE PROCEDURE tr_context_delete();


--
-- TOC entry 3266 (class 2620 OID 1242938)
-- Name: tr_customer_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_customer_delete BEFORE UPDATE ON customer FOR EACH ROW EXECUTE PROCEDURE tr_customer_delete();


--
-- TOC entry 3267 (class 2620 OID 1242945)
-- Name: tr_customer_ip_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_customer_ip_delete BEFORE UPDATE ON customer_ip FOR EACH ROW EXECUTE PROCEDURE tr_customer_ip_delete();


--
-- TOC entry 3269 (class 2620 OID 1242991)
-- Name: tr_gateway_account_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_gateway_account_delete BEFORE UPDATE ON gateway_account FOR EACH ROW EXECUTE PROCEDURE tr_gateway_account_delete();


--
-- TOC entry 3257 (class 2620 OID 1242985)
-- Name: tr_gateway_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_gateway_delete BEFORE UPDATE ON gateway FOR EACH ROW EXECUTE PROCEDURE tr_gateway_delete();


--
-- TOC entry 3270 (class 2620 OID 1243006)
-- Name: tr_gateway_ip_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_gateway_ip_delete BEFORE UPDATE ON gateway_ip FOR EACH ROW EXECUTE PROCEDURE tr_gateway_ip_delete();


--
-- TOC entry 3272 (class 2620 OID 1243088)
-- Name: tr_node_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_node_delete BEFORE UPDATE ON node FOR EACH ROW EXECUTE PROCEDURE tr_node_delete();


--
-- TOC entry 3273 (class 2620 OID 1243095)
-- Name: tr_node_ip_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_node_ip_delete BEFORE UPDATE ON node_ip FOR EACH ROW EXECUTE PROCEDURE tr_node_ip_delete();


--
-- TOC entry 3274 (class 2620 OID 1243104)
-- Name: tr_number_modification_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_number_modification_delete BEFORE UPDATE ON number_modification FOR EACH ROW EXECUTE PROCEDURE tr_number_modification_delete();


--
-- TOC entry 3275 (class 2620 OID 1243107)
-- Name: tr_number_modification_group_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_number_modification_group_delete BEFORE UPDATE ON number_modification_group FOR EACH ROW EXECUTE PROCEDURE tr_number_modification_group_delete();


--
-- TOC entry 3276 (class 2620 OID 1243117)
-- Name: tr_route_action; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_route_action BEFORE INSERT OR UPDATE OF action ON route FOR EACH ROW EXECUTE PROCEDURE tr_route_action();


--
-- TOC entry 3277 (class 2620 OID 1243118)
-- Name: tr_route_delete; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_route_delete BEFORE UPDATE ON route FOR EACH ROW EXECUTE PROCEDURE tr_route_delete();


--
-- TOC entry 3265 (class 2620 OID 1242931)
-- Name: tr_update_modified; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_update_modified BEFORE UPDATE ON context FOR EACH ROW EXECUTE PROCEDURE tr_update_modified();


--
-- TOC entry 3258 (class 2620 OID 1242986)
-- Name: tr_update_modified; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_update_modified BEFORE UPDATE ON gateway FOR EACH ROW EXECUTE PROCEDURE tr_update_modified();


--
-- TOC entry 3271 (class 2620 OID 1243007)
-- Name: tr_update_modified; Type: TRIGGER; Schema: domain; Owner: -
--

CREATE TRIGGER tr_update_modified BEFORE UPDATE ON gateway_ip FOR EACH ROW EXECUTE PROCEDURE tr_update_modified();


--
-- TOC entry 3256 (class 2606 OID 1243640)
-- Name: cdr_2016_09_customer_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3255 (class 2606 OID 1243645)
-- Name: cdr_2016_09_customer_ip_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_customer_ip_id_fkey FOREIGN KEY (customer_ip_id) REFERENCES customer_ip(id);


--
-- TOC entry 3254 (class 2606 OID 1243650)
-- Name: cdr_2016_09_customer_price_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_customer_price_id_fkey FOREIGN KEY (customer_price_id) REFERENCES customer_price(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3253 (class 2606 OID 1243655)
-- Name: cdr_2016_09_dialcode_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_dialcode_id_fkey FOREIGN KEY (dialcode_id) REFERENCES dialcode(id);


--
-- TOC entry 3252 (class 2606 OID 1243660)
-- Name: cdr_2016_09_gateway_account_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_gateway_account_id_fkey FOREIGN KEY (gateway_account_id) REFERENCES gateway_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3251 (class 2606 OID 1243665)
-- Name: cdr_2016_09_gateway_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_gateway_id_fkey FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3250 (class 2606 OID 1243670)
-- Name: cdr_2016_09_gateway_ip_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_gateway_ip_id_fkey FOREIGN KEY (gateway_ip_id) REFERENCES gateway_ip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3249 (class 2606 OID 1243675)
-- Name: cdr_2016_09_gateway_price_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_gateway_price_id_fkey FOREIGN KEY (gateway_price_id) REFERENCES gateway_price(id);


--
-- TOC entry 3248 (class 2606 OID 1243680)
-- Name: cdr_2016_09_node_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr_2016_09
	ADD CONSTRAINT cdr_2016_09_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3170 (class 2606 OID 1243129)
-- Name: fk_ca_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_address
	ADD CONSTRAINT fk_ca_company FOREIGN KEY (company_id) REFERENCES company(id);


--
-- TOC entry 3159 (class 2606 OID 1243189)
-- Name: fk_carrier_country; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY carrier
	ADD CONSTRAINT fk_carrier_country FOREIGN KEY (country_id) REFERENCES country(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3171 (class 2606 OID 1243134)
-- Name: fk_cb_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_bankaccount
	ADD CONSTRAINT fk_cb_company FOREIGN KEY (company_id) REFERENCES company(id);


--
-- TOC entry 3174 (class 2606 OID 1243139)
-- Name: fk_cd_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_document
	ADD CONSTRAINT fk_cd_company FOREIGN KEY (company_id) REFERENCES company(id);


--
-- TOC entry 3160 (class 2606 OID 1243219)
-- Name: fk_cdr_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_customer FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3161 (class 2606 OID 1243272)
-- Name: fk_cdr_customer_ip; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_customer_ip FOREIGN KEY (customer_ip_id) REFERENCES customer_ip(id);


--
-- TOC entry 3166 (class 2606 OID 1243417)
-- Name: fk_cdr_customer_price; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_customer_price FOREIGN KEY (customer_price_id) REFERENCES customer_price(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3162 (class 2606 OID 1243287)
-- Name: fk_cdr_dialcode; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_dialcode FOREIGN KEY (dialcode_id) REFERENCES dialcode(id);


--
-- TOC entry 3163 (class 2606 OID 1243307)
-- Name: fk_cdr_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3164 (class 2606 OID 1243370)
-- Name: fk_cdr_gateway_account; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_gateway_account FOREIGN KEY (gateway_account_id) REFERENCES gateway_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3165 (class 2606 OID 1243385)
-- Name: fk_cdr_gateway_ip; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_gateway_ip FOREIGN KEY (gateway_ip_id) REFERENCES gateway_ip(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3168 (class 2606 OID 1243593)
-- Name: fk_cdr_gateway_price; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_gateway_price FOREIGN KEY (gateway_price_id) REFERENCES gateway_price(id);


--
-- TOC entry 3167 (class 2606 OID 1243427)
-- Name: fk_cdr_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY cdr
	ADD CONSTRAINT fk_cdr_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3183 (class 2606 OID 1243224)
-- Name: fk_ci_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_invoice
	ADD CONSTRAINT fk_ci_customer FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3184 (class 2606 OID 1243551)
-- Name: fk_ci_user; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_invoice
	ADD CONSTRAINT fk_ci_user FOREIGN KEY (payment_ack_by) REFERENCES "user"(id);


--
-- TOC entry 3188 (class 2606 OID 1243229)
-- Name: fk_cn_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_node
	ADD CONSTRAINT fk_cn_customer FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3189 (class 2606 OID 1243432)
-- Name: fk_cn_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_node
	ADD CONSTRAINT fk_cn_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3172 (class 2606 OID 1243144)
-- Name: fk_company_contact_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY "user"
	ADD CONSTRAINT fk_company_contact_company FOREIGN KEY (company_id) REFERENCES company(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3169 (class 2606 OID 1243194)
-- Name: fk_company_country; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company
	ADD CONSTRAINT fk_company_country FOREIGN KEY (country_id) REFERENCES country(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3175 (class 2606 OID 1243149)
-- Name: fk_company_news_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_news
	ADD CONSTRAINT fk_company_news_company FOREIGN KEY (company_id) REFERENCES company(id);


--
-- TOC entry 3176 (class 2606 OID 1243422)
-- Name: fk_company_news_news; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY company_news
	ADD CONSTRAINT fk_company_news_news FOREIGN KEY (news_id) REFERENCES news(id);


--
-- TOC entry 3177 (class 2606 OID 1243174)
-- Name: fk_context_gateway_context; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY context_gateway
	ADD CONSTRAINT fk_context_gateway_context FOREIGN KEY (context_id) REFERENCES context(id);


--
-- TOC entry 3178 (class 2606 OID 1243312)
-- Name: fk_context_gateway_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY context_gateway
	ADD CONSTRAINT fk_context_gateway_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3179 (class 2606 OID 1243154)
-- Name: fk_customer_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer
	ADD CONSTRAINT fk_customer_company FOREIGN KEY (company_id) REFERENCES company(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3180 (class 2606 OID 1243179)
-- Name: fk_customer_context; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer
	ADD CONSTRAINT fk_customer_context FOREIGN KEY (context_id) REFERENCES context(id);


--
-- TOC entry 3181 (class 2606 OID 1243234)
-- Name: fk_customer_credit_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_credit
	ADD CONSTRAINT fk_customer_credit_customer FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3182 (class 2606 OID 1243556)
-- Name: fk_customer_credit_web_user; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_credit
	ADD CONSTRAINT fk_customer_credit_web_user FOREIGN KEY (user_id) REFERENCES "user"(id);


--
-- TOC entry 3185 (class 2606 OID 1243239)
-- Name: fk_customer_ip_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_ip
	ADD CONSTRAINT fk_customer_ip_customer FOREIGN KEY (customer_id) REFERENCES customer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3186 (class 2606 OID 1243277)
-- Name: fk_customer_ip_statistic_customer_ip; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_ip_statistic
	ADD CONSTRAINT fk_customer_ip_statistic_customer_ip FOREIGN KEY (customer_ip_id) REFERENCES customer_ip(id);


--
-- TOC entry 3187 (class 2606 OID 1243437)
-- Name: fk_customer_ip_statistic_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_ip_statistic
	ADD CONSTRAINT fk_customer_ip_statistic_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3190 (class 2606 OID 1243244)
-- Name: fk_customer_price_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_price
	ADD CONSTRAINT fk_customer_price_customer FOREIGN KEY (customer_id) REFERENCES customer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3191 (class 2606 OID 1243282)
-- Name: fk_customer_price_customer_pricelist; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY customer_price
	ADD CONSTRAINT fk_customer_price_customer_pricelist FOREIGN KEY (customer_pricelist_id) REFERENCES customer_pricelist(id);


--
-- TOC entry 3192 (class 2606 OID 1243164)
-- Name: fk_dialcode_carrier; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY dialcode
	ADD CONSTRAINT fk_dialcode_carrier FOREIGN KEY (carrier_id) REFERENCES carrier(id);


--
-- TOC entry 3193 (class 2606 OID 1243292)
-- Name: fk_format_gateway_format; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY format_gateway
	ADD CONSTRAINT fk_format_gateway_format FOREIGN KEY (format_id) REFERENCES format(id);


--
-- TOC entry 3194 (class 2606 OID 1243317)
-- Name: fk_format_gateway_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY format_gateway
	ADD CONSTRAINT fk_format_gateway_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3195 (class 2606 OID 1243322)
-- Name: fk_gateway_account_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account
	ADD CONSTRAINT fk_gateway_account_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3196 (class 2606 OID 1243442)
-- Name: fk_gateway_account_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account
	ADD CONSTRAINT fk_gateway_account_node FOREIGN KEY (node_id) REFERENCES node(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3197 (class 2606 OID 1243447)
-- Name: fk_gateway_account_node_old; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account
	ADD CONSTRAINT fk_gateway_account_node_old FOREIGN KEY (node_old_id) REFERENCES node(id);


--
-- TOC entry 3200 (class 2606 OID 1243375)
-- Name: fk_gateway_account_statistic_gateway_account; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account_statistic
	ADD CONSTRAINT fk_gateway_account_statistic_gateway_account FOREIGN KEY (gateway_account_id) REFERENCES gateway_account(id);


--
-- TOC entry 3199 (class 2606 OID 1243452)
-- Name: fk_gateway_account_statistic_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account_statistic
	ADD CONSTRAINT fk_gateway_account_statistic_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3198 (class 2606 OID 1243380)
-- Name: fk_gateway_accr_gateway_account; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_account_resolved
	ADD CONSTRAINT fk_gateway_accr_gateway_account FOREIGN KEY (gateway_account_id) REFERENCES gateway_account(id);


--
-- TOC entry 3156 (class 2606 OID 1243159)
-- Name: fk_gateway_company; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway
	ADD CONSTRAINT fk_gateway_company FOREIGN KEY (company_id) REFERENCES company(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3201 (class 2606 OID 1243327)
-- Name: fk_gateway_credit_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_credit
	ADD CONSTRAINT fk_gateway_credit_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3202 (class 2606 OID 1243561)
-- Name: fk_gateway_credit_web_user; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_credit
	ADD CONSTRAINT fk_gateway_credit_web_user FOREIGN KEY (user_id) REFERENCES "user"(id);


--
-- TOC entry 3157 (class 2606 OID 1243297)
-- Name: fk_gateway_format; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway
	ADD CONSTRAINT fk_gateway_format FOREIGN KEY (format_id) REFERENCES format(id);


--
-- TOC entry 3203 (class 2606 OID 1243332)
-- Name: fk_gateway_ip_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip
	ADD CONSTRAINT fk_gateway_ip_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3205 (class 2606 OID 1243390)
-- Name: fk_gateway_ip_node_gateway_ip; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_node
	ADD CONSTRAINT fk_gateway_ip_node_gateway_ip FOREIGN KEY (gateway_ip_id) REFERENCES gateway_ip(id);


--
-- TOC entry 3204 (class 2606 OID 1243457)
-- Name: fk_gateway_ip_node_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_node
	ADD CONSTRAINT fk_gateway_ip_node_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3208 (class 2606 OID 1243395)
-- Name: fk_gateway_ip_statistic_gateway_ip; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_statistic
	ADD CONSTRAINT fk_gateway_ip_statistic_gateway_ip FOREIGN KEY (gateway_ip_id) REFERENCES gateway_ip(id);


--
-- TOC entry 3207 (class 2606 OID 1243462)
-- Name: fk_gateway_ip_statistic_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_statistic
	ADD CONSTRAINT fk_gateway_ip_statistic_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3206 (class 2606 OID 1243400)
-- Name: fk_gateway_ipr_gateway_ip; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_ip_resolved
	ADD CONSTRAINT fk_gateway_ipr_gateway_ip FOREIGN KEY (gateway_ip_id) REFERENCES gateway_ip(id);


--
-- TOC entry 3158 (class 2606 OID 1243531)
-- Name: fk_gateway_number_modification_group; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway
	ADD CONSTRAINT fk_gateway_number_modification_group FOREIGN KEY (number_modification_group_id) REFERENCES number_modification_group(id);


--
-- TOC entry 3210 (class 2606 OID 1243583)
-- Name: fk_gateway_price_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_price
	ADD CONSTRAINT fk_gateway_price_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3209 (class 2606 OID 1243588)
-- Name: fk_gateway_price_gateway_pricelist; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_price
	ADD CONSTRAINT fk_gateway_price_gateway_pricelist FOREIGN KEY (gateway_pricelist_id) REFERENCES gateway_pricelist(id);


--
-- TOC entry 3211 (class 2606 OID 1243337)
-- Name: fk_gateway_pricelist_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_pricelist
	ADD CONSTRAINT fk_gateway_pricelist_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3212 (class 2606 OID 1243169)
-- Name: fk_gateway_timeband_carrier; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_timeband
	ADD CONSTRAINT fk_gateway_timeband_carrier FOREIGN KEY (carrier_id) REFERENCES carrier(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3213 (class 2606 OID 1243342)
-- Name: fk_gateway_timeband_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_timeband
	ADD CONSTRAINT fk_gateway_timeband_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3214 (class 2606 OID 1243412)
-- Name: fk_gateway_timeband_gateway_pricelist; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY gateway_timeband
	ADD CONSTRAINT fk_gateway_timeband_gateway_pricelist FOREIGN KEY (gateway_pricelist_id) REFERENCES gateway_pricelist(id);


--
-- TOC entry 3218 (class 2606 OID 1243252)
-- Name: fk_hccc_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cc
	ADD CONSTRAINT fk_hccc_customer FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3219 (class 2606 OID 1243467)
-- Name: fk_hccc_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cc
	ADD CONSTRAINT fk_hccc_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3220 (class 2606 OID 1243257)
-- Name: fk_hccpm_customer; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cpm
	ADD CONSTRAINT fk_hccpm_customer FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3221 (class 2606 OID 1243472)
-- Name: fk_hccpm_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_cpm
	ADD CONSTRAINT fk_hccpm_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3228 (class 2606 OID 1243348)
-- Name: fk_hgcc_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cc
	ADD CONSTRAINT fk_hgcc_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3229 (class 2606 OID 1243481)
-- Name: fk_hgcc_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cc
	ADD CONSTRAINT fk_hgcc_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3231 (class 2606 OID 1243407)
-- Name: fk_hgcpm_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cpm
	ADD CONSTRAINT fk_hgcpm_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3230 (class 2606 OID 1243486)
-- Name: fk_hgcpm_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_cpm
	ADD CONSTRAINT fk_hgcpm_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3235 (class 2606 OID 1243600)
-- Name: fk_hot_country; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_outgoing
	ADD CONSTRAINT fk_hot_country FOREIGN KEY (country_id) REFERENCES country(id);


--
-- TOC entry 3236 (class 2606 OID 1243566)
-- Name: fk_news_web_user; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY news
	ADD CONSTRAINT fk_news_web_user FOREIGN KEY (author_id) REFERENCES "user"(id);


--
-- TOC entry 3237 (class 2606 OID 1243302)
-- Name: fk_nf_format; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_format
	ADD CONSTRAINT fk_nf_format FOREIGN KEY (format_id) REFERENCES format(id);


--
-- TOC entry 3238 (class 2606 OID 1243491)
-- Name: fk_nf_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_format
	ADD CONSTRAINT fk_nf_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3239 (class 2606 OID 1243496)
-- Name: fk_node_ip_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_ip
	ADD CONSTRAINT fk_node_ip_node FOREIGN KEY (node_id) REFERENCES node(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3241 (class 2606 OID 1243501)
-- Name: fk_node_statistic_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_statistic
	ADD CONSTRAINT fk_node_statistic_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3240 (class 2606 OID 1243506)
-- Name: fk_nr_node; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY node_routing_log
	ADD CONSTRAINT fk_nr_node FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3243 (class 2606 OID 1243536)
-- Name: fk_number_modification_group_number_modification; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification_group_number_modification
	ADD CONSTRAINT fk_number_modification_group_number_modification FOREIGN KEY (number_modification_id) REFERENCES number_modification(id);


--
-- TOC entry 3242 (class 2606 OID 1243541)
-- Name: fk_number_modification_group_number_modification_group; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY number_modification_group_number_modification
	ADD CONSTRAINT fk_number_modification_group_number_modification_group FOREIGN KEY (number_modification_group_id) REFERENCES number_modification_group(id);


--
-- TOC entry 3244 (class 2606 OID 1243571)
-- Name: fk_protocol_web_user; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY protocol
	ADD CONSTRAINT fk_protocol_web_user FOREIGN KEY (actor_id) REFERENCES "user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3245 (class 2606 OID 1243184)
-- Name: fk_route_context; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route
	ADD CONSTRAINT fk_route_context FOREIGN KEY (context_id) REFERENCES context(id);


--
-- TOC entry 3247 (class 2606 OID 1243355)
-- Name: fk_rtg_gateway; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route_to_gateway
	ADD CONSTRAINT fk_rtg_gateway FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3246 (class 2606 OID 1243546)
-- Name: fk_rtg_route; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY route_to_gateway
	ADD CONSTRAINT fk_rtg_route FOREIGN KEY (route_id) REFERENCES route(id);


--
-- TOC entry 3173 (class 2606 OID 1243576)
-- Name: fk_user_user_responsibility; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY "user"
	ADD CONSTRAINT fk_user_user_responsibility FOREIGN KEY (responsibility_id) REFERENCES user_responsibility(id);


--
-- TOC entry 3215 (class 2606 OID 1243199)
-- Name: history_customer_billtime_country_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_billtime
	ADD CONSTRAINT history_customer_billtime_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- TOC entry 3216 (class 2606 OID 1243262)
-- Name: history_customer_billtime_customer_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_billtime
	ADD CONSTRAINT history_customer_billtime_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3217 (class 2606 OID 1243511)
-- Name: history_customer_billtime_node_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_billtime
	ADD CONSTRAINT history_customer_billtime_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3222 (class 2606 OID 1243204)
-- Name: history_customer_reason_country_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_reason
	ADD CONSTRAINT history_customer_reason_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- TOC entry 3223 (class 2606 OID 1243267)
-- Name: history_customer_reason_customer_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_reason
	ADD CONSTRAINT history_customer_reason_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id);


--
-- TOC entry 3224 (class 2606 OID 1243516)
-- Name: history_customer_reason_node_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_customer_reason
	ADD CONSTRAINT history_customer_reason_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3225 (class 2606 OID 1243209)
-- Name: history_gateway_billtime_country_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_billtime
	ADD CONSTRAINT history_gateway_billtime_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- TOC entry 3226 (class 2606 OID 1243360)
-- Name: history_gateway_billtime_gateway_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_billtime
	ADD CONSTRAINT history_gateway_billtime_gateway_id_fkey FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3227 (class 2606 OID 1243521)
-- Name: history_gateway_billtime_node_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_billtime
	ADD CONSTRAINT history_gateway_billtime_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(id);


--
-- TOC entry 3232 (class 2606 OID 1243214)
-- Name: history_gateway_reason_country_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_reason
	ADD CONSTRAINT history_gateway_reason_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- TOC entry 3233 (class 2606 OID 1243365)
-- Name: history_gateway_reason_gateway_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_reason
	ADD CONSTRAINT history_gateway_reason_gateway_id_fkey FOREIGN KEY (gateway_id) REFERENCES gateway(id);


--
-- TOC entry 3234 (class 2606 OID 1243526)
-- Name: history_gateway_reason_node_id_fkey; Type: FK CONSTRAINT; Schema: domain; Owner: -
--

ALTER TABLE ONLY history_gateway_reason
	ADD CONSTRAINT history_gateway_reason_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(id);



--
-- TOC entry 340 (class 1255 OID 1239118)
-- Name: cron_cleanup(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION cron_cleanup() RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	--DELETE FROM cdr WHERE sqltime < CURRENT_DATE - INTERVAL '3 month';
	--DELETE FROM gateway_price WHERE valid_to < CURRENT_DATE - INTERVAL '3 month';
	--DELETE FROM gateway_timeband WHERE valid_to < CURRENT_DATE - INTERVAL '3 month';
	--DELETE FROM gateway_pricelist WHERE id NOT IN (SELECT DISTINCT gateway_pricelist_id FROM gateway_price) AND id NOT IN (SELECT DISTINCT gateway_pricelist_id FROM gateway_timeband);
	--DELETE FROM customer_price WHERE valid_to < CURRENT_DATE - INTERVAL '3 month';
	--DELETE FROM customer_pricelist WHERE id NOT IN (SELECT DISTINCT customer_pricelist_id FROM customer_price);
END
$$;


--
-- TOC entry 341 (class 1255 OID 1239119)
-- Name: cron_end_obsolete_calls(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION cron_end_obsolete_calls() RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	UPDATE cdr SET ended = true WHERE ended = false AND sqltime < NOW() - INTERVAL '2 hours 15 minutes';

END;
$$;


--
-- TOC entry 342 (class 1255 OID 1239120)
-- Name: cron_history(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION cron_history() RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE i_date TIMESTAMPTZ;
		i_end_date TIMESTAMPTZ;
		cfound bool;
		gfound bool;
		i_date_tmp1 TIMESTAMPTZ;
		i_date_tmp2 TIMESTAMPTZ;
		i_was_found BOOL := FALSE;
		i_rowcount INTEGER;
BEGIN
	i_was_found := false;
	-- START WHERE history OR tmp history ENDED FOR CC
	IF (SELECT MAX(datetime) FROM history_customer_cc) IS NULL AND (SELECT MAX(datetime) FROM history_gateway_cc) IS NULL THEN
		i_date := (SELECT MIN(sqltime) FROM cdr);
		
		IF i_date IS NULL THEN
			RETURN;
		END IF;
	ELSE
		i_date_tmp1 := (SELECT MAX(datetime) FROM history_customer_cc);
		i_date_tmp2 := (SELECT MAX(datetime) FROM history_gateway_cc);

		IF i_date_tmp1 > i_date_tmp2 THEN
			i_date := i_date_tmp1;
		ELSE
			i_date := i_date_tmp2;
		END IF;
		i_date := i_date + INTERVAL '1 minute';
	END IF;

	-- CLEAN seconds/milliseconds/microseconds
	IF extract(millisecond from i_date)::TEXT <> '' THEN
		i_date := i_date - CONCAT(extract(millisecond from i_date)::TEXT, ' milliseconds')::INTERVAL;
	END IF;
	i_end_date := i_date + INTERVAL '1 hour';

	IF i_end_date > NOW() THEN
		i_end_date := NOW() - INTERVAL '1 minute';
	END IF;

	IF i_date >= i_end_date THEN
		RETURN;
	END IF;
	
	WHILE i_date < i_end_date OR (NOT i_was_found AND i_date < NOW() - INTERVAL '1 minute') LOOP
		cfound := false;
		gfound := false;
		
		-- GATEWAY CONCURRENT
		INSERT INTO history_gateway_cc (gateway_id, node_id, calls, datetime)
		SELECT gateway_id, node_id, COUNT(*) AS calls, i_date AS datetime FROM cdr
		INNER JOIN gateway ON gateway.id = cdr.gateway_id
		WHERE sqltime > i_date - INTERVAL '3 hours' AND sqltime <= i_date AND ((sqltime_end >= i_date + INTERVAL '1 minute' AND billtime >= 60000) OR (ended = false AND sqltime < i_date - INTERVAL '1 minute'))
		GROUP BY gateway_id, node_id;
		GET DIAGNOSTICS i_rowcount = ROW_COUNT;
		gfound := (i_rowcount > 0);
		
		-- CUSTOMER CONCURRENT
		INSERT INTO history_customer_cc (customer_id, node_id, calls, datetime)
		SELECT customer_id, node_id, COUNT(*) AS calls, i_date AS datetime FROM cdr
		INNER JOIN customer ON customer.id = cdr.customer_id
		WHERE sqltime > i_date - INTERVAL '3 hours' AND sqltime <= i_date AND ((sqltime_end >= i_date + INTERVAL '1 minute' AND billtime >= 60000) OR (ended = false AND sqltime < i_date - INTERVAL '1 minute'))
		GROUP BY customer_id, node_id;
		GET DIAGNOSTICS i_rowcount = ROW_COUNT;
		cfound := (i_rowcount > 0);		
		
		i_date := i_date + INTERVAL '1 minute';

		IF NOT i_was_found THEN
			i_was_found := gfound OR cfound;
		END IF;
	END LOOP;

	-- HISTORY GATEWAY CPM
	i_date := (SELECT MAX(datetime) + INTERVAL '1 minute' FROM history_gateway_cpm);
	IF i_date IS NULL THEN
		i_date := date_trunc('minute', NOW() - INTERVAL '30 minutes');
	END IF;

	i_end_date := date_trunc('minute', (NOW() - INTERVAL '2 minutes')); -- 2 minutes buffer to give yate time to write the outgoing CDRs

	INSERT INTO history_gateway_cpm (gateway_id, node_id, calls, datetime)
	SELECT gateway_id, node_id, COUNT(*) AS calls, date_trunc('minute', sqltime) datetime FROM cdr
	INNER JOIN gateway ON gateway.id = cdr.gateway_id
	WHERE sqltime >= i_date AND sqltime < i_end_date
	GROUP BY gateway_id, node_id, date_trunc('minute', sqltime)	
	ORDER BY datetime;

	-- HISTORY CUSTOMER CPM
	i_date := (SELECT MAX(datetime) + INTERVAL '1 minute' FROM history_customer_cpm);
	IF i_date IS NULL THEN
		i_date := date_trunc('minute', NOW() - INTERVAL '30 minutes');
	END IF;

	i_end_date := date_trunc('minute', (NOW() - INTERVAL '2 minutes')); -- 2 minutes buffer to give yate time to write the outgoing CDRs

	INSERT INTO history_customer_cpm (customer_id, node_id, calls, datetime)
	SELECT customer_id, node_id, COUNT(*) AS calls, date_trunc('minute', sqltime) datetime FROM cdr
	INNER JOIN customer ON customer.id = cdr.customer_id
	WHERE sqltime >= i_date AND sqltime < i_end_date
	GROUP BY customer_id, node_id, date_trunc('minute', sqltime)
	ORDER BY datetime;
END;
$$;


--
-- TOC entry 343 (class 1255 OID 1239121)
-- Name: cron_history_daily(date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION cron_history_daily(p_date date) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE i_end_date DATE;
BEGIN
	i_end_date := p_date + INTERVAL '1 day';

	-- GATEWAY BILLTIME
	INSERT INTO history_gateway_billtime (gateway_id, node_id, country_id, is_mobile, calls, billtime, date)
	SELECT gateway_id, node_id, country_id, is_mobile, COUNT(*), SUM(billtime)::bigint, sqltime::DATE FROM cdr
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
	LEFT JOIN country ON country.id = carrier.country_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND gateway_id IS NOT NULL
	GROUP BY gateway_id, node_id, country.iso3, country_id, is_mobile, sqltime::DATE;

	-- GATEWAY REASON
	INSERT INTO history_gateway_reason (gateway_id, node_id, country_id, is_mobile, calls, reason, date)
	SELECT gateway_id, node_id, country_id, is_mobile, COUNT(*), reason, sqltime::DATE FROM cdr
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
	LEFT JOIN country ON country.id = carrier.country_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND gateway_id IS NOT NULL
	GROUP BY gateway_id, node_id, country.iso3, country_id, is_mobile, reason, sqltime::DATE;

	-- CUSTOMER BILLTIME
	INSERT INTO history_customer_billtime(customer_id, node_id, country_id, is_mobile, calls, billtime, date)
	SELECT customer_id, node_id, country_id, is_mobile, COUNT(*), SUM(billtime)::bigint, sqltime::DATE FROM cdr
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
	LEFT JOIN country ON country.id = carrier.country_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND customer_id IS NOT NULL
	GROUP BY customer_id, node_id, country.iso3, country_id, is_mobile, sqltime::DATE;
	
	-- CUSTOMER REASON
	INSERT INTO history_customer_reason (customer_id, node_id, country_id, is_mobile, calls, reason, date)
	SELECT customer_id, node_id, country_id, is_mobile, COUNT(*), reason, sqltime::DATE FROM cdr
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
	LEFT JOIN country ON country.id = carrier.country_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND customer_id IS NOT NULL
	GROUP BY customer_id, node_id, country.iso3, country_id, is_mobile, reason, sqltime::DATE;
END;
$$;


--
-- TOC entry 345 (class 1255 OID 1239123)
-- Name: cron_number_gateway_statistic(interval); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION cron_number_gateway_statistic(p_last interval) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	DELETE FROM cache_number_gateway_statistic;
	
	INSERT INTO cache_number_gateway_statistic (number, gateway_id, asr, working, total)
	SELECT a.number, a.gateway_id, 100 * working / total as asr, working, total FROM (
		SELECT gateway_price.number, cdr.gateway_id, COUNT(*)::numeric as working FROM cdr
		INNER JOIN gateway_price ON gateway_price.id = cdr.gateway_price_id
		WHERE sqltime BETWEEN NOW() - p_last AND now() AND billtime >= 1000
		GROUP BY gateway_price.number, cdr.gateway_id
	) a,
	(
		SELECT gateway_price.number, cdr.gateway_id, COUNT(*)::numeric as total FROM cdr
		INNER JOIN gateway_price ON gateway_price.id = cdr.gateway_price_id
		WHERE sqltime BETWEEN NOW() - p_last AND now()
		GROUP BY gateway_price.number, cdr.gateway_id
	)b
	WHERE a.gateway_id = b.gateway_id AND a.number = b.number;
END;
$$;


--
-- TOC entry 346 (class 1255 OID 1239124)
-- Name: cron_remove_old_routes(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION cron_remove_old_routes() RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	DELETE FROM cache_route WHERE created < NOW() - INTERVAL '5 minutes';
END;
$$;


--
-- TOC entry 348 (class 1255 OID 1239125)
-- Name: customer_node_statistic_update(text, numeric, boolean, numeric); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION customer_node_statistic_update(p_node text, p_yatetime numeric, p_ended boolean, p_billtime numeric) RETURNS void
	LANGUAGE plpgsql
	AS $$
	DECLARE i_date DATE;
		i_balancedbload SMALLINT:=(RANDOM()*10)::SMALLINT;
		i_node_id INTEGER;
		i_id_load INTEGER;
		i_billtime BIGINT;
		i_failed INTEGER=0;
BEGIN
	i_date := ('1970-01-01'::timestamptz + (p_yatetime::text || ' seconds')::interval)::DATE;
	i_node_id := (SELECT id FROM node WHERE name = p_node AND deleted = false);
	i_billtime := (p_billtime * 1000)::BIGINT;

	LOOP
		SELECT id, calls_failed INTO i_id_load, i_failed FROM node_statistic WHERE node_id = i_node_id AND date = i_date AND balance_db_load = i_balancedbload FOR UPDATE;
		
		IF p_ended AND i_billtime < 1000 THEN
			IF i_failed IS NULL THEN -- FOR INSERT PART
				i_failed := 1;
			ELSE
				i_failed := i_failed + 1;
			END IF;
		END IF;

		IF i_failed IS NULL THEN
			i_failed := 0;
		END IF;
		
		IF i_id_load IS NOT NULL THEN
			IF p_ended THEN			
				UPDATE node_statistic SET concurrent_calls = concurrent_calls - 1, calls_failed = i_failed, billtime = billtime + i_billtime WHERE id = i_id_load;
			ELSE
				UPDATE node_statistic SET concurrent_calls = concurrent_calls + 1, calls_total = calls_total + 1 WHERE id = i_id_load;
			END IF;
			
			RETURN;
		ELSE
			BEGIN
				IF p_ended THEN
					INSERT INTO node_statistic (node_id, date, concurrent_calls, calls_total, calls_failed, billtime, balance_db_load)
						VALUES (i_node_id, i_date, -1, 0, i_failed, i_billtime, i_balancedbload);
				ELSE
					INSERT INTO node_statistic (node_id, date, concurrent_calls, calls_total, calls_failed, billtime, balance_db_load)
						VALUES (i_node_id, i_date, 1, 1, 0, 0, i_balancedbload);
				END IF;

				RETURN;
			EXCEPTION WHEN unique_violation THEN
				-- NOTHING, LOOP AGAIN
			END;
		END IF;
	END LOOP;
END;
$$;


--
-- TOC entry 349 (class 1255 OID 1239126)
-- Name: end_date(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION end_date() RETURNS timestamp with time zone
	LANGUAGE plpgsql IMMUTABLE STRICT
	AS $$
BEGIN
	RETURN '2099-12-31 23:59:59+0'::timestamp with time zone;
END;
$$;


--
-- TOC entry 350 (class 1255 OID 1239127)
-- Name: firewall_get_customers(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION firewall_get_customers() RETURNS text
	LANGUAGE plpgsql STABLE STRICT
	AS $_$
	DECLARE
	entry RECORD;
	ips RECORD;
	i_text text;
	i_ips text;
BEGIN
	i_text := '';
	FOR entry IN SELECT * FROM domain.customer WHERE customer.deleted = false AND customer.enabled = true ORDER BY customer.name
	LOOP
	i_text := i_text || '# Customer: ' || entry.name || E' \n';
	i_ips := '';
	FOR ips IN SELECT DISTINCT ON (customer_ip.address) * FROM domain.customer_ip WHERE customer_ip.deleted = false AND customer_ip.enabled = true AND customer_ip.customer_id = entry.id ORDER BY customer_ip.address
	LOOP	
		i_ips := i_ips || 'ACCEPT net:' || ips.address || E' $FW \n';
	END LOOP;
	i_text := i_text || i_ips;
	i_text := i_text || E'# -- end -- \n\n';
	END LOOP;
	RETURN i_text;
END;
$_$;


--
-- TOC entry 351 (class 1255 OID 1239128)
-- Name: firewall_get_gateways(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION firewall_get_gateways() RETURNS text
	LANGUAGE plpgsql STABLE STRICT
	AS $_$
	DECLARE
	entry RECORD;
	ips RECORD;
	i_text text;
	i_ips text;
BEGIN
	i_text := '';
	FOR entry IN SELECT * FROM domain.gateway WHERE gateway.deleted = false AND gateway.enabled = true ORDER BY gateway.name
	LOOP
	i_text := i_text || '# Gateway: ' || entry.name || E' \n';
	i_ips := '';
	FOR ips IN SELECT DISTINCT ON (gateway_ip.address) * FROM domain.gateway_ip WHERE gateway_ip.deleted = false AND gateway_ip.enabled = true AND gateway_ip.gateway_id = entry.id ORDER BY gateway_ip.address
	LOOP	
		i_ips := i_ips || 'ACCEPT net:' || ips.address || E' $FW \n';
	END LOOP;
	i_text := i_text || i_ips;
	i_text := i_text || E'# -- end -- \n\n';
	END LOOP;
	RETURN i_text;
END;
$_$;


SET default_with_oids = false;


--
-- TOC entry 352 (class 1255 OID 1239145)
-- Name: gateway_formats(gateway); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION gateway_formats(gateway) RETURNS character varying
	LANGUAGE plpgsql STABLE STRICT
	AS $_$
BEGIN        
		RETURN (SELECT string_agg(name, ',') FROM format_gateway
			INNER JOIN format ON format.id = format_gateway.format_id
			WHERE format_gateway.gateway_id = ($1).id);
END;
$_$;



--
-- TOC entry 353 (class 1255 OID 1239150)
-- Name: internal_gateway_lcr_route(integer, integer, integer, text, text, text, integer, text, bigint); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_gateway_lcr_route(p_node_id integer, p_customer_id integer, p_context_id integer, p_caller text, p_callername text, p_called text, p_timeout integer, p_trackingid text, p_customer_price_id bigint) RETURNS SETOF view_callto_result
	LANGUAGE plpgsql
	AS $$
	DECLARE		
		i_callto_result view_callto_result%rowtype;
		i_called TEXT;
		i_gateways INTEGER=0;
		i_current_gateway INTEGER=0;
		i_firstrun BOOLEAN;
		i_wait_action view_callto_result%rowtype;
		i_action view_callto_result%rowtype;
		i_target TEXT;
		i_target_node_id INTEGER;
		i_target_gateway_id INTEGER;
		i_id BIGINT;
		i_immediately BOOLEAN;
		i_gateway_price_flat_price NUMERIC(13,8)=NULL;
		i_gateway_price_flat_currency CHARACTER(3);
		i_gateway_price_flat_dialcode TEXT;
		i_gateway_price_flat_id BIGINT=NULL;
		i_gateway_price_other_price NUMERIC(13,8)=NULL;
		i_gateway_price_other_currency CHARACTER(3);
		i_gateway_price_other_dialcode TEXT;
		i_gateway_price_other_id BIGINT=NULL;
		i_gateway_price_price NUMERIC(13,8)=NULL;
		i_gateway_price_currency CHARACTER(3);
		i_gateway_price_dialcode TEXT;
		i_gateway_price_id BIGINT=NULL;
		i_customer_price NUMERIC(13,8)=NULL;
		i_customer_price_currency CHARACTER(3);
		i_customer_dialcode TEXT;
		i_cached BOOLEAN;
		i_qlgw_gateway_id INTEGER;
		i_lcr_gateway_id INTEGER;
		i_gateway_country_asr NUMERIC(8,2);
		i_series BIGINT;
		i_lcr_node_id INTEGER;
		i_asr_prio NUMERIC(2,1)=1.0;
BEGIN
	SELECT INTO i_callto_result * FROM view_callto_result;
	SELECT INTO i_wait_action * FROM view_callto_result;
	SELECT INTO i_action * FROM view_callto_result;
	
	--i_wait_action.location := '|next=10000';

	i_wait_action.location := (SELECT CONCAT('|next=', context.next*1000) FROM context WHERE id = p_context_id);
	
	-- get customer price
	i_called := p_called;
	i_firstrun := true;
		
	SELECT price, currency, number INTO i_customer_price, i_customer_price_currency, i_customer_dialcode FROM customer_price WHERE id = p_customer_price_id;

	-- NORMALIZE PRICE TO USD IF NECESSARY
	IF i_customer_price IS NOT NULL THEN
		i_customer_price := (internal_util_normalize_to_usd(i_customer_price, i_customer_price_currency));
	END IF;

	CREATE TEMP TABLE tmp_gateway (id INTEGER, price NUMERIC(13,8), asr NUMERIC(5,2), asr_prio NUMERIC(2,1)) ON COMMIT DROP;

	-- find context gateways and get id, type, price, asr
	FOR i_qlgw_gateway_id IN SELECT gateway_id FROM context_gateway, gateway
		WHERE context_id = p_context_id AND
			gateway.id = context_gateway.gateway_id AND
			gateway.enabled = true
	LOOP
		i_gateway_price_price := NULL;
		i_gateway_price_currency := NULL;

		-- check limit first
		IF internal_limit_of_gateway_reached(i_qlgw_gateway_id) THEN
			-- limit consumed, skip gateway
			CONTINUE;
		END IF;

		-- FLAT
		SELECT id, price, currency, number INTO i_gateway_price_flat_id, i_gateway_price_flat_price, i_gateway_price_flat_currency, i_gateway_price_flat_dialcode FROM gateway_price
			WHERE number IN (SELECT * FROM internal_util_number_to_table(p_called)) AND gateway_id = i_qlgw_gateway_id
				AND NOW() BETWEEN valid_from AND valid_to AND timeband = 'Flat'
			ORDER BY LENGTH(number) DESC LIMIT 1;

		-- NON FLAT IF FLAT NOT FOUND
		IF NOT FOUND THEN
			SELECT id, price, currency, number INTO i_gateway_price_other_id, i_gateway_price_other_price, i_gateway_price_other_currency, i_gateway_price_other_dialcode FROM gateway_price 
				WHERE number IN (SELECT * FROM internal_util_number_to_table(p_called)) AND NOW() BETWEEN valid_from AND valid_to AND
				gateway_id = i_qlgw_gateway_id AND timeband IN
				(
					SELECT timeband FROM gateway_timeband
					WHERE NOW() BETWEEN gateway_timeband.valid_from AND gateway_timeband.valid_to
						AND "time"(NOW()) BETWEEN time_from AND time_to
						AND day_of_week = EXTRACT(DOW FROM NOW())
						AND gateway_id = i_qlgw_gateway_id
						AND carrier_id = (SELECT carrier_id FROM dialcode
								WHERE "number" IN (SELECT * FROM internal_util_number_to_table(p_called))
								AND NOW() BETWEEN dialcode.valid_from AND dialcode.valid_to
								ORDER BY LENGTH(number) DESC LIMIT 1)
				)
				ORDER BY LENGTH(number) DESC, price ASC LIMIT 1;
			
				-- IF NON FLAT ALSO NOT FOUND, CONTINUE
				IF NOT FOUND THEN
					CONTINUE;
				END IF;
				
				-- SET NON FLAT PRICING
				i_gateway_price_price := i_gateway_price_other_price;
				i_gateway_price_currency := i_gateway_price_other_currency;
				i_gateway_price_dialcode := i_gateway_price_other_dialcode;
				i_gateway_price_id := i_gateway_price_other_id;
				
		ELSE	-- SET FLAT PRICING
			i_gateway_price_price := i_gateway_price_flat_price;
			i_gateway_price_currency := i_gateway_price_flat_currency;
			i_gateway_price_dialcode := i_gateway_price_flat_dialcode;
			i_gateway_price_id := i_gateway_price_flat_id;		
		END IF;
		
		
		i_gateway_price_price := (internal_util_normalize_to_usd(i_gateway_price_price, i_gateway_price_currency));

		-- CHECK IF GATEWAY PRICE IS LOWER THAN CUSTOMER PRICE
		IF i_customer_price IS NULL OR (i_gateway_price_price < i_customer_price) THEN

			-- GET COUNTRY ASR
			SELECT asr INTO i_gateway_country_asr FROM cache_number_gateway_statistic
			WHERE number IN (SELECT * FROM internal_util_number_to_table(i_called)) AND cache_number_gateway_statistic.gateway_id = i_qlgw_gateway_id
			ORDER BY LENGTH(number) DESC LIMIT 1;

			IF i_gateway_country_asr IS NULL THEN
				i_gateway_country_asr := 100; -- ASSUME BEST IF NOT FOUND
			END IF;

			
			INSERT INTO tmp_gateway(id, price, asr, asr_prio)
			VALUES (i_qlgw_gateway_id, i_gateway_price_price, i_gateway_country_asr, i_asr_prio);

			i_asr_prio := (i_asr_prio + 0.1);
		END IF;
	
	END LOOP;

	CREATE TEMP TABLE tmp_lcr_route (node_id INTEGER, gateway_id INTEGER, price NUMERIC, asr NUMERIC, sort NUMERIC) ON COMMIT DROP;

	-- REMOVE NODES THAT ARE NOT ONLINE, ENABLED OR IN MAINTENANCE MODE
	INSERT INTO tmp_lcr_route (node_id, gateway_id, price, asr, sort)
	SELECT DISTINCT a.node_id, a.id, a.price, a.asr, a.rating FROM (
		SELECT DISTINCT node_id, tmp_gateway.id, tmp_gateway.price, tmp_gateway.asr, /*1 / tmp_gateway.price * tmp_gateway.asr*/ tmp_gateway.asr/tmp_gateway.asr_prio AS rating FROM tmp_gateway
		INNER JOIN gateway_ip ON gateway_ip.gateway_id = tmp_gateway.id
		INNER JOIN gateway_ip_node ON gateway_ip_node.gateway_ip_id = gateway_ip.id
		INNER JOIN node ON node.id = gateway_ip_node.node_id AND node.online = true AND node.enabled = true AND node.is_in_maintenance_mode = false
	) a
	ORDER BY a.rating DESC;
	
	CREATE TEMP TABLE tmp_lcr_route2 (node_id INTEGER, gateway_id INTEGER, price NUMERIC, asr NUMERIC, sort NUMERIC, price_id BIGINT) ON COMMIT DROP;

	INSERT INTO tmp_lcr_route2(node_id, gateway_id, price, asr, sort)
	SELECT node_id, gateway_id, price, asr, sort FROM tmp_lcr_route;

	-- REMOVE DUPLICATED GATEWAYS FOR CURRENT NODE, PREFER CURRENT NODE TO AVOID INTERNAL HOPS
	FOR i_lcr_gateway_id IN SELECT gateway_id FROM tmp_lcr_route WHERE node_id = p_node_id LOOP

		-- CHECK IF CURRENT NODE IS ATTACHED TO GATEWAY
		PERFORM * FROM tmp_lcr_route2 WHERE node_id = p_node_id AND gateway_id = i_lcr_gateway_id;
		
		-- IF SO, REMOVE OTHER NODES
		IF FOUND THEN
			DELETE FROM tmp_lcr_route2 WHERE gateway_id = i_lcr_gateway_id AND node_id <> p_node_id;
		END IF;

	END LOOP;

	-- REMOVE DUPLICATED GATEWAYS ON OTHER NODES
	FOR i_lcr_gateway_id IN SELECT gateway_id FROM tmp_lcr_route WHERE node_id <> p_node_id ORDER BY sort DESC LOOP

		-- USE NODE WITH FEWEST LOAD
		DELETE FROM tmp_lcr_route2 WHERE gateway_id = i_lcr_gateway_id AND node_id <> p_node_id AND node_id <> (
			SELECT node.id FROM node
				LEFT JOIN node_statistic ON node_statistic.node_id = node.id AND date = current_date 
				WHERE node.id IN (SELECT node_id FROM tmp_lcr_route2 WHERE gateway_id = i_lcr_gateway_id AND node_id <> p_node_id)
					AND node.id <> p_node_id
				ORDER BY concurrent_calls ASC LIMIT 1);
	END LOOP;

	PERFORM * FROM tmp_lcr_route2;

	-- GATEWAYS LEFT?
	IF NOT FOUND THEN
		i_callto_result.error := '403';
		i_callto_result.reason := 'Forbidden';
		
		RETURN NEXT i_callto_result;
		RETURN;
	END IF;

	-- ASSIGN ROUTES TO SAME SERIES (USED FOR DELETING)
	i_firstrun := true;

	i_gateways := (SELECT COUNT(*) FROM tmp_lcr_route2);
	i_current_gateway := 0;
	FOR i_lcr_node_id, i_lcr_gateway_id IN SELECT node_id, gateway_id FROM tmp_lcr_route2 ORDER BY sort DESC LOOP
		i_firstrun := true;
		i_current_gateway := i_current_gateway + 1;
		
		IF i_lcr_node_id = p_node_id THEN

			-- CHECK CACHE
			PERFORM * FROM cache_route
				WHERE node_id = p_node_id AND target = 'Gateway' AND target_gateway_id = i_lcr_gateway_id;

			IF FOUND THEN --GET FROM CACHE
			
				FOR i_action IN SELECT (action).* FROM cache_route WHERE node_id = p_node_id AND target = 'Gateway' AND target_gateway_id = i_lcr_gateway_id LOOP

					IF i_firstrun = false AND i_immediately = FALSE THEN
						RETURN NEXT i_wait_action;
					END IF;

					-- CREATE CONNECTIONSTRING
					i_action := internal_route_send_to_gateway_replace(i_action, p_caller, p_callername, p_called, i_lcr_gateway_id, p_timeout);
					i_action.sccachehit := true;
					
					RETURN NEXT i_action;					
				END LOOP;
			ELSE -- CREATE NEW
				i_series := nextval('cache_series_seq');
				
				FOR i_action IN SELECT * FROM internal_route_send_to_gateway(i_lcr_gateway_id, p_node_id) a LOOP

					IF i_firstrun = false AND i_immediately = FALSE THEN
						RETURN NEXT i_wait_action;
					END IF;

					-- CACHE IF NOT IN CACHE
					BEGIN
						INSERT INTO cache_route (node_id, target, target_gateway_id, action, series)
							VALUES(p_node_id, 'Gateway', i_lcr_gateway_id, i_action, i_series);
					EXCEPTION WHEN unique_violation THEN
						-- DO NOTHING
					END;
					
					-- CREATE CONNECTIONSTRING
					i_action := internal_route_send_to_gateway_replace(i_action, p_caller, p_callername, p_called, i_lcr_gateway_id, p_timeout);

					RETURN NEXT i_action;
				END LOOP;
			END IF;

		ELSE
			i_action := internal_route_send_to_node(p_node_id, i_lcr_node_id);

			-- FOR NODE
			i_action := internal_route_send_to_node_replace(i_action, p_caller, p_callername, p_called, i_lcr_gateway_id, p_timeout, p_trackingid);

			RETURN NEXT i_action;
		END IF;
		
		-- ADD FIELD FOR WAITING BETWEEN TRYING TO ACCESS GATEWAYS
		IF i_current_gateway < i_gateways THEN
			RETURN NEXT i_wait_action;
		END IF;
	END LOOP;

	--SELECT * INTO i_callto_result FROM view_callto_result;
	--i_callto_result.location := '|drop=25000';
	--RETURN NEXT i_callto_result;
	
	RETURN;
END;
$$;


--
-- TOC entry 354 (class 1255 OID 1239152)
-- Name: internal_gateway_number_modification(integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_gateway_number_modification(p_number_modification_group_id integer, p_called text) RETURNS character varying
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_number_modification_removeprefix text;
		i_number_modification_addprefix text;
BEGIN
	
	SELECT remove_prefix, add_prefix INTO i_number_modification_removeprefix, i_number_modification_addprefix FROM number_modification
	INNER JOIN number_modification_group_number_modification ON number_modification_group_number_modification.number_modification_group_id = p_number_modification_group_id AND number_modification_group_number_modification.number_modification_id = number_modification.id
	INNER JOIN number_modification_group ON number_modification_group.id = number_modification_group_number_modification.number_modification_group_id AND number_modification_group.enabled = true
	WHERE p_called ~ pattern AND number_modification.enabled = true 
	ORDER BY sort DESC
	LIMIT 1;

	IF LENGTH(i_number_modification_removeprefix) > 0 THEN
		p_called := (SELECT SUBSTRING(p_called, LENGTH(i_number_modification_removeprefix) + 1));
	END IF;

	p_called := (SELECT TRIM(leading '0' FROM p_called));

	IF LENGTH(i_number_modification_addprefix) > 0 THEN
		p_called := i_number_modification_addprefix || p_called;
	END IF;

	RETURN p_called;
END;
$$;


--
-- TOC entry 355 (class 1255 OID 1239153)
-- Name: internal_limit_of_customer_reached(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_limit_of_customer_reached(p_customer_id integer) RETURNS boolean
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_credit_remaining NUMERIC(12,4);
		i_hour_limit BIGINT;
		i_concurrent_lines_limit INTEGER;
		i_concurrent_lines_in_used INTEGER;
		i_todays_billtime BIGINT;
BEGIN
	
	SELECT credit_remaining, hour_limit, concurrent_lines_limit INTO i_credit_remaining, i_hour_limit, i_concurrent_lines_limit FROM customer WHERE id = p_customer_id;

	IF i_credit_remaining IS NOT NULL AND i_credit_remaining <= 0 THEN
		RETURN TRUE;
	END IF;

	SELECT SUM(billtime), SUM(concurrent_calls) INTO i_todays_billtime, i_concurrent_lines_in_used FROM customer_ip_statistic
		INNER JOIN customer_ip ON customer_ip.id = customer_ip_statistic.customer_ip_id
		WHERE customer_ip.customer_id = p_customer_id AND date = DATE(now() AT TIME ZONE 'UTC');

	IF i_hour_limit IS NOT NULL AND i_hour_limit > 0 AND i_todays_billtime IS NOT NULL AND i_todays_billtime >= i_hour_limit THEN
		RETURN TRUE;
	END IF;

	IF i_concurrent_lines_limit IS NOT NULL AND i_concurrent_lines_in_used >= i_concurrent_lines_limit THEN
		RETURN TRUE;
	END IF;

	RETURN FALSE;
END;
$$;


--
-- TOC entry 357 (class 1255 OID 1239154)
-- Name: internal_limit_of_gateway_reached(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_limit_of_gateway_reached(p_gateway_id integer) RETURNS boolean
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_credit_remaining NUMERIC(12,4);
		i_hour_limit BIGINT;
		i_todays_billtime BIGINT;
		i_concurrent_lines_limit INTEGER;
		i_concurrent_lines_used INTEGER;
BEGIN	
	SELECT hour_limit, credit_remaining, concurrent_lines_limit INTO i_hour_limit, i_credit_remaining, i_concurrent_lines_limit FROM gateway WHERE id = p_gateway_id;

	IF i_credit_remaining IS NOT NULL AND i_credit_remaining <= 0 THEN
		RETURN TRUE;
	END IF;

	-- Account
	IF (SELECT type FROM gateway WHERE id = p_gateway_id) = 'Account'::gatewaytype THEN

		SELECT SUM(billtime), SUM(concurrent_calls) INTO i_todays_billtime, i_concurrent_lines_used FROM gateway_account_statistic
			INNER JOIN gateway_account ON gateway_account.id = gateway_account_statistic.gateway_account_id
			WHERE gateway_account.gateway_id = p_gateway_id AND date = DATE(now() AT TIME ZONE 'UTC');

	ELSE -- IP

		SELECT SUM(billtime), SUM(concurrent_calls) INTO i_todays_billtime, i_concurrent_lines_used FROM gateway_ip_statistic
			INNER JOIN gateway_ip ON gateway_ip.id = gateway_ip_statistic.gateway_ip_id
			WHERE gateway_ip.gateway_id = p_gateway_id AND date = DATE(now() AT TIME ZONE 'UTC');
		
	END IF;

	IF i_hour_limit IS NOT NULL AND i_hour_limit > 0 AND i_todays_billtime IS NOT NULL AND i_todays_billtime >= i_hour_limit THEN
		RETURN TRUE;
	END IF;

	IF i_concurrent_lines_limit IS NOT NULL AND i_concurrent_lines_used >= i_concurrent_lines_limit THEN
		RETURN TRUE;
	END IF;

	RETURN FALSE;
END;
$$;


--
-- TOC entry 184 (class 1259 OID 1239155)
-- Name: view_preroute_result; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_preroute_result AS
 SELECT ''::text AS error,
	''::text AS reason,
	''::text AS context,
	''::text AS scnodeid,
	''::text AS scsender,
	''::text AS scsenderid,
	''::text AS sccustomerid,
	''::text AS sccustomeripid,
	''::text AS scprerouteduration,
	''::text AS scrouteduration,
	''::text AS sccachehit,
	''::text AS scgatewayid,
	''::text AS sctrackingid,
	'scnodeid,scsender,scsenderid,sccustomerid,sccustomeripid,scprerouteduration,scrouteduration,sccachehit,scgatewayid,sctrackingid,called'::text AS copyparams,
	''::text AS called;


--
-- TOC entry 358 (class 1255 OID 1239159)
-- Name: internal_preroute(text, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_preroute(p_address text, p_node text, p_called text) RETURNS view_preroute_result
	LANGUAGE plpgsql STABLE STRICT
	AS $$
DECLARE
		i_sender_ip INET;
		i_sender_ip_id INTEGER;
		i_sender_id INTEGER;
		i_customer_check BOOLEAN;
		i_context_id INTEGER;
		i_node_id INTEGER;
		i_preroute_result view_preroute_result%rowtype;
		i_prefix TEXT;
		i_context_enabled BOOL;
BEGIN
	SELECT * INTO i_preroute_result FROM view_preroute_result;
	i_preroute_result.called		:=		p_called;

	-- SET CURRENT NODE ID
	i_node_id := (SELECT id::TEXT FROM node WHERE name = p_node);
	i_preroute_result.scnodeid := i_node_id;
	
	IF i_preroute_result.scnodeid IS NULL THEN
		i_preroute_result.error 	:=		'500';
		i_preroute_result.reason	:=		'Internal Server Error';
		i_preroute_result.scprerouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
		RETURN i_preroute_result;
	END IF;
	
	-- CHECK IF CALLED IS COMPLETE
	IF LENGTH(internal_util_delete_prefix(p_called)) < 6 THEN
		i_preroute_result.error		:=		'484';
		i_preroute_result.reason	:=		'Address Incomplete';
		i_preroute_result.scprerouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
		RETURN i_preroute_result;
	END IF;

	i_sender_ip := SUBSTRING(p_address FROM 0 FOR POSITION(':' in p_address))::inet;
	
	
	-- CHECK IF SENDER IS NODE
	SELECT id, node_id INTO i_sender_ip_id, i_sender_id FROM node_ip WHERE address = i_sender_ip AND node_ip.enabled = true AND node_ip.network = 'Intern';
	IF FOUND THEN
	
		i_preroute_result.scsender 	:=		'node';
		i_preroute_result.scsenderid 	:=		i_sender_id::TEXT;
			
	ELSE -- CHECK IF IS CUSTOMER
	
		SELECT sender_ip_id, sender_id, called, customer_check, context_id, context_enabled
			INTO i_sender_ip_id, i_sender_id, p_called, i_customer_check, i_context_id, i_context_enabled
			FROM internal_resolve_customer(i_sender_ip, p_called);
		
		i_preroute_result.sccustomerid 		:=		i_sender_id::TEXT;
		i_preroute_result.sccustomeripid 	:=		i_sender_ip_id::TEXT;		
		i_preroute_result.scsender 		:=		'customer';
		i_preroute_result.scsenderid 		:=		i_sender_id::TEXT;
		i_preroute_result.called		:=		p_called;
		
		-- CHECK IF CUSTOMER EXISTS	
		IF i_sender_id IS NULL OR i_customer_check = false THEN
			i_preroute_result.error 	:=		'403';
			i_preroute_result.reason 	:=		'Forbidden';
			i_preroute_result.scprerouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
			RETURN i_preroute_result;
		END IF;
				
		-- CHECK IF CONTEXT EXISTS
		IF i_context_id IS NULL OR i_context_enabled = FALSE THEN
			i_preroute_result.error 	:=		'801';
			i_preroute_result.reason 	:=		'Bad Context';
			i_preroute_result.scprerouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
			RETURN i_preroute_result;
		END IF;
	
		-- CHECK IF LIMIT IS GOOD
		IF internal_limit_of_customer_reached(i_sender_id) THEN
			i_preroute_result.error 	:=		'480';
			i_preroute_result.reason	:=		'Temporarily Unavailable';
			i_preroute_result.scprerouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
			RETURN i_preroute_result;
		END IF;
	
		-- EVERYTHING OK
		i_preroute_result.context :=		i_context_id::TEXT;
	END IF;
	
	i_preroute_result.scprerouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
	
	RETURN i_preroute_result;
END;
$$;


--
-- TOC entry 186 (class 1259 OID 1239176)
-- Name: view_routing_rules_result; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_routing_rules_result AS
 SELECT ''::text AS decision,
	false AS has_price,
	false AS has_route,
	false AS is_lcr,
	false AS all_destinations,
	false AS fake_ringing,
	7200000 AS timeout,
	''::text AS action,
	ARRAY[NULL::integer] AS gateway_ids,
	false AS did,
	NULL::integer AS route_id,
	NULL::integer AS sccustomerpriceid,
	''::text AS new_caller,
	''::text AS new_callername;


--
-- TOC entry 359 (class 1255 OID 1239160)
-- Name: internal_resolve_customer(inet, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_resolve_customer(p_sender_ip inet, p_called text) RETURNS TABLE(sender_ip_id integer, sender_id integer, called text, customer_check boolean, context_id integer, context_enabled boolean)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE
		i_sender_ip_id INTEGER;
		i_sender_id INTEGER;
		i_customer_check BOOLEAN;
		i_context_id INTEGER;
		i_prefix TEXT;
		i_context_enabled BOOL;
BEGIN
	FOR i_sender_ip_id, i_sender_id, i_prefix, i_customer_check, i_context_id, i_context_enabled IN SELECT customer_ip.id, customer.id, prefix, customer.enabled, context.id, context.enabled FROM customer_ip
													INNER JOIN customer ON customer.id = customer_ip.customer_id
													LEFT JOIN context ON context.id = customer.context_id
													WHERE address = p_sender_ip AND customer_ip.enabled = true ORDER BY prefix DESC NULLS LAST LOOP

		IF i_prefix IS NOT NULL AND i_prefix != '' THEN
			IF i_prefix = SUBSTRING(p_called FROM 1 FOR LENGTH(i_prefix)) THEN
				p_called := SUBSTRING(p_called FROM LENGTH(i_prefix) + 1);
				EXIT;
			END IF;
		ELSE
			EXIT;
		END IF;

		i_sender_ip_id := NULL;
		i_sender_id := NULL;
		i_prefix := NULL;

	END LOOP;

	RETURN QUERY SELECT i_sender_ip_id, i_sender_id, p_called, i_customer_check, i_context_id, i_context_enabled;
END;
$$;


--
-- TOC entry 185 (class 1259 OID 1239161)
-- Name: view_route_result; Type: VIEW; Schema: domain; Owner: -
--

CREATE VIEW view_route_result AS
 SELECT ''::text AS error,
	''::text AS reason,
	'fork'::text AS location,
	''::text AS "fork.calltype",
	''::text AS "fork.autoring",
	''::text AS "fork.automessage",
	''::text AS "fork.ringer",
	''::text AS scnodeid,
	''::text AS sccustomerid,
	''::text AS sccustomeripid,
	''::text AS sctrackingid,
	'false'::text AS sccachehit,
	''::text AS scrouteduration,
	'scgatewayid,sctechcalled,scgatewayipid,scgatewayaccountid,sccachehit,sctrackingid,scrouteduration,scprerouteduration,sccustomerid,rtp_addr,rtp_port'::text AS copyparams,
	''::text AS sccustomerpriceid,
	''::text AS "callto.1.called",
	''::text AS "callto.1.caller",
	''::text AS "callto.1.callername",
	''::text AS "callto.1.format",
	''::text AS "callto.1.formats",
	''::text AS "callto.1.line",
	''::text AS "callto.1",
	''::text AS "callto.1.maxcall",
	''::text AS "callto.1.osip_P-Asserted-Identity",
	''::text AS "callto.1.osip_Gateway-ID",
	''::text AS "callto.1.osip_Tracking-ID",
	''::text AS "callto.1.rtp_addr",
	''::text AS "callto.1.rtp_forward",
	''::text AS "callto.1.oconnection_id",
	''::text AS "callto.1.rtp_port",
	''::text AS "callto.1.timeout",
	''::text AS "callto.1.scgatewayid",
	''::text AS "callto.1.scgatewayaccountid",
	''::text AS "callto.1.scgatewayipid",
	''::text AS "callto.1.sctechcalled",
	''::text AS "callto.2.called",
	''::text AS "callto.2.caller",
	''::text AS "callto.2.callername",
	''::text AS "callto.2.format",
	''::text AS "callto.2.formats",
	''::text AS "callto.2.line",
	''::text AS "callto.2",
	''::text AS "callto.2.maxcall",
	''::text AS "callto.2.osip_P-Asserted-Identity",
	''::text AS "callto.2.osip_Gateway-ID",
	''::text AS "callto.2.osip_Tracking-ID",
	''::text AS "callto.2.rtp_addr",
	''::text AS "callto.2.rtp_forward",
	''::text AS "callto.2.oconnection_id",
	''::text AS "callto.2.rtp_port",
	''::text AS "callto.2.timeout",
	''::text AS "callto.2.scgatewayid",
	''::text AS "callto.2.scgatewayaccountid",
	''::text AS "callto.2.scgatewayipid",
	''::text AS "callto.2.sctechcalled",
	''::text AS "callto.3.called",
	''::text AS "callto.3.caller",
	''::text AS "callto.3.callername",
	''::text AS "callto.3.format",
	''::text AS "callto.3.formats",
	''::text AS "callto.3.line",
	''::text AS "callto.3",
	''::text AS "callto.3.maxcall",
	''::text AS "callto.3.osip_P-Asserted-Identity",
	''::text AS "callto.3.osip_Gateway-ID",
	''::text AS "callto.3.osip_Tracking-ID",
	''::text AS "callto.3.rtp_addr",
	''::text AS "callto.3.rtp_forward",
	''::text AS "callto.3.oconnection_id",
	''::text AS "callto.3.rtp_port",
	''::text AS "callto.3.timeout",
	''::text AS "callto.3.scgatewayid",
	''::text AS "callto.3.scgatewayaccountid",
	''::text AS "callto.3.scgatewayipid",
	''::text AS "callto.3.sctechcalled",
	''::text AS "callto.4.called",
	''::text AS "callto.4.caller",
	''::text AS "callto.4.callername",
	''::text AS "callto.4.format",
	''::text AS "callto.4.formats",
	''::text AS "callto.4.line",
	''::text AS "callto.4",
	''::text AS "callto.4.maxcall",
	''::text AS "callto.4.osip_P-Asserted-Identity",
	''::text AS "callto.4.osip_Gateway-ID",
	''::text AS "callto.4.osip_Tracking-ID",
	''::text AS "callto.4.rtp_addr",
	''::text AS "callto.4.rtp_forward",
	''::text AS "callto.4.oconnection_id",
	''::text AS "callto.4.rtp_port",
	''::text AS "callto.4.timeout",
	''::text AS "callto.4.scgatewayid",
	''::text AS "callto.4.scgatewayaccountid",
	''::text AS "callto.4.scgatewayipid",
	''::text AS "callto.4.sctechcalled",
	''::text AS "callto.5.called",
	''::text AS "callto.5.caller",
	''::text AS "callto.5.callername",
	''::text AS "callto.5.format",
	''::text AS "callto.5.formats",
	''::text AS "callto.5.line",
	''::text AS "callto.5",
	''::text AS "callto.5.maxcall",
	''::text AS "callto.5.osip_P-Asserted-Identity",
	''::text AS "callto.5.osip_Gateway-ID",
	''::text AS "callto.5.osip_Tracking-ID",
	''::text AS "callto.5.rtp_addr",
	''::text AS "callto.5.rtp_forward",
	''::text AS "callto.5.oconnection_id",
	''::text AS "callto.5.rtp_port",
	''::text AS "callto.5.timeout",
	''::text AS "callto.5.scgatewayid",
	''::text AS "callto.5.scgatewayaccountid",
	''::text AS "callto.5.scgatewayipid",
	''::text AS "callto.5.sctechcalled",
	''::text AS "callto.6.called",
	''::text AS "callto.6.caller",
	''::text AS "callto.6.callername",
	''::text AS "callto.6.format",
	''::text AS "callto.6.formats",
	''::text AS "callto.6.line",
	''::text AS "callto.6",
	''::text AS "callto.6.maxcall",
	''::text AS "callto.6.osip_P-Asserted-Identity",
	''::text AS "callto.6.osip_Gateway-ID",
	''::text AS "callto.6.osip_Tracking-ID",
	''::text AS "callto.6.rtp_addr",
	''::text AS "callto.6.rtp_forward",
	''::text AS "callto.6.oconnection_id",
	''::text AS "callto.6.rtp_port",
	''::text AS "callto.6.timeout",
	''::text AS "callto.6.scgatewayid",
	''::text AS "callto.6.scgatewayaccountid",
	''::text AS "callto.6.scgatewayipid",
	''::text AS "callto.6.sctechcalled",
	''::text AS "callto.7.called",
	''::text AS "callto.7.caller",
	''::text AS "callto.7.callername",
	''::text AS "callto.7.format",
	''::text AS "callto.7.formats",
	''::text AS "callto.7.line",
	''::text AS "callto.7",
	''::text AS "callto.7.maxcall",
	''::text AS "callto.7.osip_P-Asserted-Identity",
	''::text AS "callto.7.osip_Gateway-ID",
	''::text AS "callto.7.osip_Tracking-ID",
	''::text AS "callto.7.rtp_addr",
	''::text AS "callto.7.rtp_forward",
	''::text AS "callto.7.oconnection_id",
	''::text AS "callto.7.rtp_port",
	''::text AS "callto.7.timeout",
	''::text AS "callto.7.scgatewayid",
	''::text AS "callto.7.scgatewayaccountid",
	''::text AS "callto.7.scgatewayipid",
	''::text AS "callto.7.sctechcalled",
	''::text AS "callto.8.called",
	''::text AS "callto.8.caller",
	''::text AS "callto.8.callername",
	''::text AS "callto.8.format",
	''::text AS "callto.8.formats",
	''::text AS "callto.8.line",
	''::text AS "callto.8",
	''::text AS "callto.8.maxcall",
	''::text AS "callto.8.osip_P-Asserted-Identity",
	''::text AS "callto.8.osip_Gateway-ID",
	''::text AS "callto.8.osip_Tracking-ID",
	''::text AS "callto.8.rtp_addr",
	''::text AS "callto.8.rtp_forward",
	''::text AS "callto.8.oconnection_id",
	''::text AS "callto.8.rtp_port",
	''::text AS "callto.8.timeout",
	''::text AS "callto.8.scgatewayid",
	''::text AS "callto.8.scgatewayaccountid",
	''::text AS "callto.8.scgatewayipid",
	''::text AS "callto.8.sctechcalled",
	''::text AS "callto.9.called",
	''::text AS "callto.9.caller",
	''::text AS "callto.9.callername",
	''::text AS "callto.9.format",
	''::text AS "callto.9.formats",
	''::text AS "callto.9.line",
	''::text AS "callto.9",
	''::text AS "callto.9.maxcall",
	''::text AS "callto.9.osip_P-Asserted-Identity",
	''::text AS "callto.9.osip_Gateway-ID",
	''::text AS "callto.9.osip_Tracking-ID",
	''::text AS "callto.9.rtp_addr",
	''::text AS "callto.9.rtp_forward",
	''::text AS "callto.9.oconnection_id",
	''::text AS "callto.9.rtp_port",
	''::text AS "callto.9.timeout",
	''::text AS "callto.9.scgatewayid",
	''::text AS "callto.9.scgatewayaccountid",
	''::text AS "callto.9.scgatewayipid",
	''::text AS "callto.9.sctechcalled",
	''::text AS "callto.10.called",
	''::text AS "callto.10.caller",
	''::text AS "callto.10.callername",
	''::text AS "callto.10.format",
	''::text AS "callto.10.formats",
	''::text AS "callto.10.line",
	''::text AS "callto.10",
	''::text AS "callto.10.maxcall",
	''::text AS "callto.10.osip_P-Asserted-Identity",
	''::text AS "callto.10.osip_Gateway-ID",
	''::text AS "callto.10.osip_Tracking-ID",
	''::text AS "callto.10.rtp_addr",
	''::text AS "callto.10.rtp_forward",
	''::text AS "callto.10.oconnection_id",
	''::text AS "callto.10.rtp_port",
	''::text AS "callto.10.timeout",
	''::text AS "callto.10.scgatewayid",
	''::text AS "callto.10.scgatewayaccountid",
	''::text AS "callto.10.scgatewayipid",
	''::text AS "callto.10.sctechcalled";


--
-- TOC entry 360 (class 1255 OID 1239166)
-- Name: internal_route(text, text, text, text, text, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route(p_error text, p_reason text, p_node_id text, p_context text, p_sender text, p_sender_id text, p_caller text, p_callername text, p_called text, p_sip_trackingid text, p_sip_gatewayid text, p_sccustomerid text, p_sccustomeripid text, p_billid text) RETURNS view_route_result
	LANGUAGE plpgsql
	AS $$
	DECLARE i_node_id INTEGER;
		i_gateway_id INTEGER;
		i_gateway_current INTEGER = 0;
		i_gateway_total INTEGER;
		i_routing_to_gateway BOOLEAN;
		i_context_id INTEGER;
		i_sender_id INTEGER;
		i_trackingid TEXT;
		i_series BIGINT;
		i_callto_record view_callto_result%rowtype;
		i_count INTEGER=0;
		i_route_result view_route_result%rowtype;
		i_blacklist_error TEXT;
		i_customer_id INTEGER;
		i_view_routing_rules_result view_routing_rules_result%rowtype;
		i_wait_duration TEXT;
BEGIN
	i_node_id := p_node_id::INTEGER;
	
	SELECT INTO i_route_result * FROM view_route_result;
	
	i_route_result.scnodeid = p_node_id::TEXT;
	i_route_result.sccustomerid = p_sccustomerid;
	i_route_result.sccustomeripid = p_sccustomeripid;
		
	-- CHECK FOR ERROR
	IF p_error <> '' AND p_error IS NOT NULL THEN
	
		i_route_result.error :=		p_error;
		i_route_result.reason :=	p_reason;
		i_route_result.location := 	'';
		
		i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
		RETURN i_route_result;
	END IF;
	
	i_sender_id := p_sender_id::INTEGER;
	
	i_series := nextval('cache_series_seq');
		
	-- NORMALIZE CALLED, DELETE PREFIX, TRIM LEADING 0, TRIM LEADING +, REMOVE CRAP AT THE END
	p_called := internal_util_clean_number(p_called);

	-- CHECK IF BLACKLISTED
	PERFORM * FROM blacklist WHERE p_called ~ pattern AND enabled = true;

	IF FOUND THEN
		i_route_result.error :=		'403';
		i_route_result.reason :=	'Forbidden';
		i_route_result.location := 	'';
		
		i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		
		RETURN i_route_result;
	END IF;
	
	-- CHECK IF CALL IS ROUTED INTERNALLY
	IF p_sender = 'node' AND isdigit(p_sip_gatewayid) THEN
		-- GET AND SET TRACKING ID
		i_trackingid := p_sip_trackingid;

		i_route_result.sctrackingid := p_sip_trackingid;

		FOR i_callto_record IN SELECT * FROM internal_route_node_to_gateway(i_node_id, p_sip_gatewayid::INTEGER, 7200000, p_caller, p_callername, p_called, i_series, p_sip_trackingid) LOOP
		
			i_count := i_count + 1;

			i_route_result := internal_route_prepare_result(i_callto_record, i_route_result, i_count);
	
		END LOOP;

		i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
		-- ROUTE
		RETURN i_route_result;
	
	ELSE -- COMING FROM EXTERN
		-- SET TRACKING ID
		i_trackingid := p_billid;
		i_route_result.sctrackingid := i_trackingid;
		
		-- CHECK FOR ERROR
		IF p_context = '' OR p_context IS NULL THEN
		
			i_route_result.error :=		'503';
			i_route_result.reason :=	'Service Unavailable';
			i_route_result.location := 	'';
			i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
			
			RETURN i_route_result;
		END IF;

		
		i_context_id := p_context::INTEGER;
		i_wait_duration := (SELECT CONCAT('|next=', context.next*1000) FROM context WHERE id = i_context_id);
		
		i_customer_id := p_sccustomerid::INTEGER;

		i_view_routing_rules_result := internal_routing_rules(i_customer_id, p_called);

		i_route_result.sccustomerpriceid := i_view_routing_rules_result.sccustomerpriceid::TEXT;
		
		-- CHECK IF FAKE RINGING
		i_count := 0;
		IF i_view_routing_rules_result.fake_ringing THEN
			i_route_result."callto.1" := 'tone/ring';
			i_route_result."fork.calltype" := 'persistent';
			i_route_result."fork.autoring" := 'true';
			i_route_result."fork.automessage" := 'call.progress';
			i_route_result."fork.ringer"	:= 'true';

			i_count := 1;
		END IF;
		
		IF i_view_routing_rules_result.decision = 'route' THEN -- DO ROUTING
			
			IF i_view_routing_rules_result.action = 'error' THEN
				i_route_result."callto.1" := 'error';
				i_route_result.location := 	'';
				i_route_result.reason := 	'Temporarily Unavailable';
				i_route_result.error := 	'480';
				i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;	 		
				
				RETURN i_route_result;
			END IF;

			-- CHECK DID ACTION
			IF i_view_routing_rules_result.did THEN
				p_called := i_view_routing_rules_result.action;
			ELSE
				p_called := REPLACE(i_view_routing_rules_result.action, E'\\1', p_called);				
			END IF;

			-- CHECK ALL GATEWAYS
			i_gateway_total := (SELECT array_length(i_view_routing_rules_result.gateway_ids, 1));
			FOREACH i_gateway_id IN ARRAY i_view_routing_rules_result.gateway_ids LOOP
				i_gateway_current := i_gateway_current + 1;
				IF internal_limit_of_gateway_reached(i_gateway_id) THEN
					CONTINUE;
				END IF;

				FOR i_callto_record IN SELECT * FROM internal_route_node_to_gateway(i_node_id, i_gateway_id, i_view_routing_rules_result.timeout, p_caller, p_callername, p_called, i_series, i_trackingid) LOOP
					i_count := i_count + 1;
					
					-- CHECK CALLER, CALLERNAME
					i_callto_record.caller := p_caller;
					IF i_view_routing_rules_result.new_caller IS NOT NULL AND i_view_routing_rules_result.new_caller <> '' THEN
						i_callto_record.caller := i_view_routing_rules_result.new_caller;
					END IF;

					IF i_view_routing_rules_result.new_callername IS NOT NULL AND i_view_routing_rules_result.new_callername <> '' THEN
						IF i_view_routing_rules_result.new_callername = E'\\1' THEN
							i_callto_record.callername := i_callto_record.caller;
						ELSE
							i_callto_record.callername := i_view_routing_rules_result.new_callername;
						END IF;
					END IF;
					
					i_route_result := internal_route_prepare_result(i_callto_record, i_route_result, i_count);
				END LOOP;

				IF i_gateway_current < i_gateway_total THEN
					SELECT * INTO i_callto_record FROM view_callto_result;
					i_count := i_count + 1;
					i_callto_record.location := i_wait_duration;
					i_route_result := internal_route_prepare_result(i_callto_record, i_route_result, i_count);
				END IF;
				
				i_routing_to_gateway := TRUE;
			END LOOP;

			--i_count := i_count + 1;
			--SELECT * INTO i_callto_record FROM view_callto_result;
			--i_callto_record.location := '|drop=25000';
			--i_route_result := internal_route_prepare_result(i_callto_record, i_route_result, i_count);
	
			i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
			
			RETURN i_route_result;
			
		ELSEIF i_view_routing_rules_result.decision = 'lcr' THEN -- DO LCR
		
			FOR i_callto_record IN SELECT * FROM internal_gateway_lcr_route(i_node_id, i_sender_id, i_context_id, p_caller, p_callername, p_called, 7200000, i_trackingid, i_view_routing_rules_result.sccustomerpriceid) LOOP
				i_count := i_count + 1;
		
				i_route_result := internal_route_prepare_result(i_callto_record, i_route_result, i_count);
			END LOOP;
		
			i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;
	
			RETURN i_route_result;
			
		ELSEIF i_view_routing_rules_result.decision = 'forbidden' THEN -- DO FORBIDDEN
		
			i_route_result.error := 	'403';
			i_route_result.reason := 	'Forbidden';
			i_route_result.location := 	'';
			i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;	 		
			
			RETURN i_route_result;
			
		ELSE -- ALWAYS FORBID
		
			i_route_result.error := 	'403';
			i_route_result.reason := 	'Forbidden';
			i_route_result.location := 	'';
			i_route_result.scrouteduration := ROUND(EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - NOW()))*1000000)::TEXT;	 		
			
			RETURN i_route_result;
			
		END IF;
		
	END IF;  
	
END;
$$;


--
-- TOC entry 361 (class 1255 OID 1239168)
-- Name: internal_route_node_to_gateway(integer, integer, integer, text, text, text, bigint, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_node_to_gateway(p_node_id integer, p_gateway_id integer, p_timeout integer, p_caller text, p_callername text, p_called text, p_series bigint, p_trackingid text) RETURNS SETOF view_callto_result
	LANGUAGE plpgsql
	AS $$
	DECLARE i_callto_record view_callto_result%rowtype;
		i_tmp_connectionstring view_callto_result%rowtype;
		i_target_node_id INTEGER;
		i_gateway_is_accessible BOOLEAN;
		i_gateway_type gatewaytype;
BEGIN
	i_gateway_is_accessible :=	false;
	
	SELECT type INTO i_gateway_type FROM gateway WHERE id = p_gateway_id;
	
	IF i_gateway_type = 'Account'::gatewaytype THEN

		-- CHECK IF GATEWAY ACCOUNT IS ACCESSIBLE BY THIS NODE
		PERFORM * FROM gateway_account
			WHERE gateway_account.node_id = p_node_id
				AND gateway_id = p_gateway_id
				AND enabled = true;
		
		IF FOUND THEN
			i_gateway_is_accessible := true;
		ELSE
			i_gateway_is_accessible := false;
		END IF;
		
	ELSE -- IP
	
		-- CHECK IF GATEWAY IP IS ACCESSIBLE BY THIS NODE
		PERFORM * FROM gateway_ip
			INNER JOIN gateway_ip_node ON gateway_ip_node.gateway_ip_id = gateway_ip.id
			WHERE gateway_id = p_gateway_id AND enabled = true
				AND gateway_ip_node.node_id = p_node_id;
	
		IF FOUND THEN
			i_gateway_is_accessible := true;
		ELSE
			i_gateway_is_accessible := false;
		END IF;
	
	END IF;	
	
	-- ROUTE TO GATEWAY
	IF i_gateway_is_accessible THEN
		
		-- CHECK CACHE
		PERFORM * FROM cache_route
		WHERE node_id = p_node_id AND target = 'Gateway' AND target_gateway_id = p_gateway_id;

		IF FOUND THEN --GET FROM CACHE
			
			FOR i_callto_record IN SELECT (action).* FROM cache_route WHERE node_id = p_node_id AND target = 'Gateway' AND target_gateway_id = p_gateway_id LOOP

				-- CREATE CONNECTIONSTRING
				i_callto_record := internal_route_send_to_gateway_replace(i_callto_record, p_caller, p_callername, p_called, p_gateway_id, p_timeout);
				i_callto_record.sccachehit := true;
				
				RETURN NEXT i_callto_record;
			END LOOP;
		ELSE -- CREATE NEW

			FOR i_callto_record IN SELECT * FROM internal_route_send_to_gateway(p_gateway_id, p_node_id) a LOOP
				
				-- CACHE TEMPLATE
				BEGIN
					INSERT INTO cache_route (node_id, target, target_gateway_id, action, series)
						VALUES(p_node_id, 'Gateway', p_gateway_id, i_callto_record, p_series);
				EXCEPTION WHEN unique_violation THEN
					-- DO NOTHING
				END;
								
				-- CREATE CONNECTIONSTRING
				i_callto_record := internal_route_send_to_gateway_replace(i_callto_record, p_caller, p_callername, p_called, p_gateway_id, p_timeout);
				
				RETURN NEXT i_callto_record;
			END LOOP;
		END IF;
	
	ELSE -- INTERNAL ROUTING
	
		IF i_gateway_type = 'Account'::gatewaytype THEN
		
			SELECT node.id INTO i_target_node_id FROM gateway_account
				INNER JOIN node_ip ON node_ip.node_id = gateway_account.node_id
				INNER JOIN node ON node.id = node_ip.node_id
				WHERE gateway_id = p_gateway_id AND node.enabled = true AND node_ip.enabled AND node.online = true
					AND node.is_in_maintenance_mode = FALSE AND gateway_account.enabled = true AND node_ip.network = 'Intern'
				ORDER BY RANDOM()
				LIMIT 1;
		ELSE -- IP
		
			SELECT node.id INTO i_target_node_id FROM gateway_ip
				INNER JOIN node_ip ON node_ip.node_id IN (SELECT node_id FROM gateway_ip_node WHERE gateway_ip_node.gateway_ip_id = gateway_ip.id)
				INNER JOIN node ON node.id = node_ip.node_id
				WHERE gateway_id = p_gateway_id AND node.enabled = true AND node_ip.enabled AND node.online = true
					AND node_ip.network = 'Intern' AND node.is_in_maintenance_mode = FALSE
				ORDER BY RANDOM()
				LIMIT 1;
		
		END IF;

		IF i_target_node_id IS NULL THEN

			i_callto_record.error :=	'480';
			i_callto_record.reason :=	'Temporarily Unavailable';
			
			RETURN NEXT i_callto_record;
			RETURN;
		END IF;

		-- CHECK CACHE
		SELECT (action).* INTO i_callto_record FROM cache_route
			WHERE node_id = p_node_id AND target = 'Node' AND target_node_id = i_target_node_id;
		
		IF NOT FOUND THEN
			
			i_callto_record := internal_route_send_to_node(p_node_id, i_target_node_id);
			-- ADD NEW
			BEGIN
				INSERT INTO cache_route (node_id, target, target_node_id, action, series)
					VALUES(p_node_id, 'Node', i_target_node_id, i_callto_record, p_series);
			EXCEPTION WHEN unique_violation THEN
				-- DO NOTHING
			END;
			
			i_callto_record := internal_route_send_to_node_replace(i_callto_record, p_caller, p_callername, p_called, p_gateway_id, p_timeout, p_trackingid);
			
			RETURN NEXT i_callto_record;
		ELSE
 
			i_callto_record := internal_route_send_to_node_replace(i_callto_record, p_caller, p_callername, p_called, p_gateway_id, p_timeout, p_trackingid);
			i_callto_record.sccachehit := true;
			
			RETURN NEXT i_callto_record;
		END IF;		

	END IF;
	
	RETURN;
END;
$$;


--
-- TOC entry 364 (class 1255 OID 1239169)
-- Name: internal_route_prepare_result(view_callto_result, view_route_result, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_prepare_result(p_call_result view_callto_result, p_route_result view_route_result, p_order integer) RETURNS view_route_result
	LANGUAGE plpgsql
	AS $$
BEGIN
	
	IF p_call_result.error <> '' AND p_call_result.reason <> '' AND p_call_result.reason IS NOT NULL AND p_call_result.error IS NOT NULL THEN
		p_route_result.error := p_call_result.error;
		p_route_result.reason := p_call_result.reason;
		p_route_result.location := '';
				
		RETURN p_route_result;
	END IF;
	
	IF p_order = 1 THEN
		-- ALWAYS YES OR NO, SO ADD FIRST AND ONLY ONCE
		p_route_result.sccachehit := p_call_result.sccachehit::TEXT;

		p_route_result."callto.1.called" := p_call_result.called;
		p_route_result."callto.1.caller" := p_call_result.caller;
		p_route_result."callto.1.callername" := p_call_result.callername;
		p_route_result."callto.1.format" := p_call_result.format;
		p_route_result."callto.1.formats" := p_call_result.formats;
		p_route_result."callto.1.line" := p_call_result.line;
		p_route_result."callto.1" := p_call_result.location;
		p_route_result."callto.1.maxcall" := p_call_result.maxcall;
		p_route_result."callto.1.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.1.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.1.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.1.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.1.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.1.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.1.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.1.timeout" := p_call_result.timeout;
		p_route_result."callto.1.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.1.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.1.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.1.sctechcalled" := p_call_result.sctechcalled;

	ELSEIF p_order = 2 THEN

		p_route_result."callto.2.called" := p_call_result.called;
		p_route_result."callto.2.caller" := p_call_result.caller;
		p_route_result."callto.2.callername" := p_call_result.callername;
		p_route_result."callto.2.format" := p_call_result.format;
		p_route_result."callto.2.formats" := p_call_result.formats;
		p_route_result."callto.2.line" := p_call_result.line;
		p_route_result."callto.2" := p_call_result.location;
		p_route_result."callto.2.maxcall" := p_call_result.maxcall;
		p_route_result."callto.2.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.2.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.2.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.2.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.2.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.2.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.2.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.2.timeout" := p_call_result.timeout;
		p_route_result."callto.2.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.2.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.2.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.2.sctechcalled" := p_call_result.sctechcalled;

	ELSEIF p_order = 3 THEN

		p_route_result."callto.3.called" := p_call_result.called;
		p_route_result."callto.3.caller" := p_call_result.caller;
		p_route_result."callto.3.callername" := p_call_result.callername;
		p_route_result."callto.3.format" := p_call_result.format;
		p_route_result."callto.3.formats" := p_call_result.formats;
		p_route_result."callto.3.line" := p_call_result.line;
		p_route_result."callto.3" := p_call_result.location;
		p_route_result."callto.3.maxcall" := p_call_result.maxcall;
		p_route_result."callto.3.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.3.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.3.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.3.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.3.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.3.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.3.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.3.timeout" := p_call_result.timeout;
		p_route_result."callto.3.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.3.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.3.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.3.sctechcalled" := p_call_result.sctechcalled;

	ELSEIF p_order = 4 THEN

		p_route_result."callto.4.called" := p_call_result.called;
		p_route_result."callto.4.caller" := p_call_result.caller;
		p_route_result."callto.4.callername" := p_call_result.callername;
		p_route_result."callto.4.format" := p_call_result.format;
		p_route_result."callto.4.formats" := p_call_result.formats;
		p_route_result."callto.4.line" := p_call_result.line;
		p_route_result."callto.4" := p_call_result.location;
		p_route_result."callto.4.maxcall" := p_call_result.maxcall;
		p_route_result."callto.4.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.4.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.4.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.4.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.4.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.4.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.4.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.4.timeout" := p_call_result.timeout;
		p_route_result."callto.4.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.4.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.4.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.4.sctechcalled" := p_call_result.sctechcalled;
		
	ELSEIF p_order = 5 THEN

		p_route_result."callto.5.called" := p_call_result.called;
		p_route_result."callto.5.caller" := p_call_result.caller;
		p_route_result."callto.5.callername" := p_call_result.callername;
		p_route_result."callto.5.format" := p_call_result.format;
		p_route_result."callto.5.formats" := p_call_result.formats;
		p_route_result."callto.5.line" := p_call_result.line;
		p_route_result."callto.5" := p_call_result.location;
		p_route_result."callto.5.maxcall" := p_call_result.maxcall;
		p_route_result."callto.5.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.5.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.5.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.5.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.5.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.5.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.5.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.5.timeout" := p_call_result.timeout;
		p_route_result."callto.5.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.5.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.5.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.5.sctechcalled" := p_call_result.sctechcalled;

	ELSEIF p_order = 6 THEN

		p_route_result."callto.6.called" := p_call_result.called;
		p_route_result."callto.6.caller" := p_call_result.caller;
		p_route_result."callto.6.callername" := p_call_result.callername;
		p_route_result."callto.6.format" := p_call_result.format;
		p_route_result."callto.6.formats" := p_call_result.formats;
		p_route_result."callto.6.line" := p_call_result.line;
		p_route_result."callto.6" := p_call_result.location;
		p_route_result."callto.6.maxcall" := p_call_result.maxcall;
		p_route_result."callto.6.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.6.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.6.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.6.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.6.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.6.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.6.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.6.timeout" := p_call_result.timeout;
		p_route_result."callto.6.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.6.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.6.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.6.sctechcalled" := p_call_result.sctechcalled;

	ELSEIF p_order = 7 THEN

		p_route_result."callto.7.called" := p_call_result.called;
		p_route_result."callto.7.caller" := p_call_result.caller;
		p_route_result."callto.7.callername" := p_call_result.callername;
		p_route_result."callto.7.format" := p_call_result.format;
		p_route_result."callto.7.formats" := p_call_result.formats;
		p_route_result."callto.7.line" := p_call_result.line;
		p_route_result."callto.7" := p_call_result.location;
		p_route_result."callto.7.maxcall" := p_call_result.maxcall;
		p_route_result."callto.7.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.7.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.7.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.7.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.7.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.7.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.7.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.7.timeout" := p_call_result.timeout;
		p_route_result."callto.7.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.7.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.7.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.7.sctechcalled" := p_call_result.sctechcalled;
		
	ELSEIF p_order = 8 THEN

		p_route_result."callto.8.called" := p_call_result.called;
		p_route_result."callto.8.caller" := p_call_result.caller;
		p_route_result."callto.8.callername" := p_call_result.callername;
		p_route_result."callto.8.format" := p_call_result.format;
		p_route_result."callto.8.formats" := p_call_result.formats;
		p_route_result."callto.8.line" := p_call_result.line;
		p_route_result."callto.8" := p_call_result.location;
		p_route_result."callto.8.maxcall" := p_call_result.maxcall;
		p_route_result."callto.8.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.8.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.8.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.8.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.8.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.8.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.8.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.8.timeout" := p_call_result.timeout;
		p_route_result."callto.8.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.8.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.8.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.8.sctechcalled" := p_call_result.sctechcalled;
	
	ELSEIF p_order = 9 THEN

		p_route_result."callto.9.called" := p_call_result.called;
		p_route_result."callto.9.caller" := p_call_result.caller;
		p_route_result."callto.9.callername" := p_call_result.callername;
		p_route_result."callto.9.format" := p_call_result.format;
		p_route_result."callto.9.formats" := p_call_result.formats;
		p_route_result."callto.9.line" := p_call_result.line;
		p_route_result."callto.9" := p_call_result.location;
		p_route_result."callto.9.maxcall" := p_call_result.maxcall;
		p_route_result."callto.9.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.9.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.9.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.9.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.9.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.9.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.9.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.9.timeout" := p_call_result.timeout;
		p_route_result."callto.9.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.9.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.9.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.9.sctechcalled" := p_call_result.sctechcalled;
	
	ELSEIF p_order = 10 THEN

		p_route_result."callto.10.called" := p_call_result.called;
		p_route_result."callto.10.caller" := p_call_result.caller;
		p_route_result."callto.10.callername" := p_call_result.callername;
		p_route_result."callto.10.format" := p_call_result.format;
		p_route_result."callto.10.formats" := p_call_result.formats;
		p_route_result."callto.10.line" := p_call_result.line;
		p_route_result."callto.10" := p_call_result.location;
		p_route_result."callto.10.maxcall" := p_call_result.maxcall;
		p_route_result."callto.10.osip_P-Asserted-Identity" := p_call_result."osip_P-Asserted-Identity";
		p_route_result."callto.10.osip_Gateway-ID" := p_call_result."osip_Gateway-ID";
		p_route_result."callto.10.osip_Tracking-ID" := p_call_result."osip_Tracking-ID";
		p_route_result."callto.10.rtp_addr" := p_call_result.rtp_addr;
		p_route_result."callto.10.rtp_forward" := p_call_result.rtp_forward;
		p_route_result."callto.10.oconnection_id" := p_call_result.oconnection_id;
		p_route_result."callto.10.rtp_port" := p_call_result.rtp_port;
		p_route_result."callto.10.timeout" := p_call_result.timeout;
		p_route_result."callto.10.scgatewayid" := p_call_result.scgatewayid;
		p_route_result."callto.10.scgatewayaccountid" := p_call_result.scgatewayaccountid;
		p_route_result."callto.10.scgatewayipid" := p_call_result.scgatewayipid;
		p_route_result."callto.10.sctechcalled" := p_call_result.sctechcalled;
	
	END IF;

	-- FOR MORE THAN 10 NOTHING IS DONE

	RETURN p_route_result;
END;
$$;


--
-- TOC entry 365 (class 1255 OID 1239170)
-- Name: internal_route_result_records(view_route_result); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_result_records(p_route_result view_route_result) RETURNS TABLE(error text, reason text, location text, scnodeid text, sccustomerid text, sccustomeripid text, sctrackingid text, sccachehit text, scrouteduration text, copyparams text, sccustomerpriceid text, fork_autoring text, fork_automessage text, fork_ringer text, fork_calltype text, callto_called text, callto_caller text, callto_callername text, callto_format text, callto_formats text, callto_line text, callto text, callto_maxcall text, "callto_osip_P_Asserted_Identity" text, "callto_osip_Gateway_ID" text, "callto_osip_Tracking_ID" text, callto_rtp_addr text, callto_rtp_forward text, callto_oconnection_id text, callto_rtp_port text, callto_timeout text, callto_scgatewayid text, callto_scgatewayaccountid text, callto_scgatewayipid text, callto_sctechcalled text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	CREATE TEMPORARY TABLE tmp (
		error text,
		reason text,
		location text,
		scnodeid text,
		sccustomerid text,
		sccustomeripid text,
		sctrackingid text,
		sccachehit text,
		scrouteduration text,
		copyparams text,
		sccustomerpriceid text,
		fork_autoring text default '',
		fork_automessage text default '',
		fork_ringer text default '',
		fork_calltype text default '',
		"callto.called" text,
		"callto.caller" text,
		"callto.callername" text,
		"callto.format" text,
		"callto.formats" text,
		"callto.line" text,
		"callto" text,
		"callto.maxcall" text,
		"callto.osip_P-Asserted-Identity" text,
		"callto.osip_Gateway-ID" text,
		"callto.osip_Tracking-ID" text,
		"callto.rtp_addr" text,
		"callto.rtp_forward" text,
		"callto.oconnection_id" text,
		"callto.rtp_port" text,
		"callto.timeout" text,
		"callto.scgatewayid" text,
		"callto.scgatewayaccountid" text,
		"callto.scgatewayipid" text,
		"callto.sctechcalled" text
	) ON COMMIT DROP;
	
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid, fork_autoring, fork_automessage, fork_ringer, fork_calltype,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."fork.autoring", p_route_result."fork.automessage", p_route_result."fork.ringer", p_route_result."fork.calltype",
		p_route_result."callto.1.called",
		p_route_result."callto.1.caller",
		p_route_result."callto.1.callername",
		p_route_result."callto.1.format",
		p_route_result."callto.1.formats",
		p_route_result."callto.1.line",
		p_route_result."callto.1",
		p_route_result."callto.1.maxcall",
		p_route_result."callto.1.osip_P-Asserted-Identity",
		p_route_result."callto.1.osip_Gateway-ID",
		p_route_result."callto.1.osip_Tracking-ID",
		p_route_result."callto.1.rtp_addr",
		p_route_result."callto.1.rtp_forward",
		p_route_result."callto.1.oconnection_id",
		p_route_result."callto.1.rtp_port",
		p_route_result."callto.1.timeout",
		p_route_result."callto.1.scgatewayid",
		p_route_result."callto.1.scgatewayaccountid",
		p_route_result."callto.1.scgatewayipid",
		p_route_result."callto.1.sctechcalled");


	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.2.called",
		p_route_result."callto.2.caller",
		p_route_result."callto.2.callername",
		p_route_result."callto.2.format",
		p_route_result."callto.2.formats",
		p_route_result."callto.2.line",
		p_route_result."callto.2",
		p_route_result."callto.2.maxcall",
		p_route_result."callto.2.osip_P-Asserted-Identity",
		p_route_result."callto.2.osip_Gateway-ID",
		p_route_result."callto.2.osip_Tracking-ID",
		p_route_result."callto.2.rtp_addr",
		p_route_result."callto.2.rtp_forward",
		p_route_result."callto.2.oconnection_id",
		p_route_result."callto.2.rtp_port",
		p_route_result."callto.2.timeout",
		p_route_result."callto.2.scgatewayid",
		p_route_result."callto.2.scgatewayaccountid",
		p_route_result."callto.2.scgatewayipid",
		p_route_result."callto.2.sctechcalled");
		
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.3.called",
		p_route_result."callto.3.caller",
		p_route_result."callto.3.callername",
		p_route_result."callto.3.format",
		p_route_result."callto.3.formats",
		p_route_result."callto.3.line",
		p_route_result."callto.3",
		p_route_result."callto.3.maxcall",
		p_route_result."callto.3.osip_P-Asserted-Identity",
		p_route_result."callto.3.osip_Gateway-ID",
		p_route_result."callto.3.osip_Tracking-ID",
		p_route_result."callto.3.rtp_addr",
		p_route_result."callto.3.rtp_forward",
		p_route_result."callto.3.oconnection_id",
		p_route_result."callto.3.rtp_port",
		p_route_result."callto.3.timeout",
		p_route_result."callto.3.scgatewayid",
		p_route_result."callto.3.scgatewayaccountid",
		p_route_result."callto.3.scgatewayipid",
		p_route_result."callto.3.sctechcalled");
		
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.4.called",
		p_route_result."callto.4.caller",
		p_route_result."callto.4.callername",
		p_route_result."callto.4.format",
		p_route_result."callto.4.formats",
		p_route_result."callto.4.line",
		p_route_result."callto.4",
		p_route_result."callto.4.maxcall",
		p_route_result."callto.4.osip_P-Asserted-Identity",
		p_route_result."callto.4.osip_Gateway-ID",
		p_route_result."callto.4.osip_Tracking-ID",
		p_route_result."callto.4.rtp_addr",
		p_route_result."callto.4.rtp_forward",
		p_route_result."callto.4.oconnection_id",
		p_route_result."callto.4.rtp_port",
		p_route_result."callto.4.timeout",
		p_route_result."callto.4.scgatewayid",
		p_route_result."callto.4.scgatewayaccountid",
		p_route_result."callto.4.scgatewayipid",
		p_route_result."callto.4.sctechcalled");
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.5.called",
		p_route_result."callto.5.caller",
		p_route_result."callto.5.callername",
		p_route_result."callto.5.format",
		p_route_result."callto.5.formats",
		p_route_result."callto.5.line",
		p_route_result."callto.5",
		p_route_result."callto.5.maxcall",
		p_route_result."callto.5.osip_P-Asserted-Identity",
		p_route_result."callto.5.osip_Gateway-ID",
		p_route_result."callto.5.osip_Tracking-ID",
		p_route_result."callto.5.rtp_addr",
		p_route_result."callto.5.rtp_forward",
		p_route_result."callto.5.oconnection_id",
		p_route_result."callto.5.rtp_port",
		p_route_result."callto.5.timeout",
		p_route_result."callto.5.scgatewayid",
		p_route_result."callto.5.scgatewayaccountid",
		p_route_result."callto.5.scgatewayipid",
		p_route_result."callto.5.sctechcalled");
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.6.called",
		p_route_result."callto.6.caller",
		p_route_result."callto.6.callername",
		p_route_result."callto.6.format",
		p_route_result."callto.6.formats",
		p_route_result."callto.6.line",
		p_route_result."callto.6",
		p_route_result."callto.6.maxcall",
		p_route_result."callto.6.osip_P-Asserted-Identity",
		p_route_result."callto.6.osip_Gateway-ID",
		p_route_result."callto.6.osip_Tracking-ID",
		p_route_result."callto.6.rtp_addr",
		p_route_result."callto.6.rtp_forward",
		p_route_result."callto.6.oconnection_id",
		p_route_result."callto.6.rtp_port",
		p_route_result."callto.6.timeout",
		p_route_result."callto.6.scgatewayid",
		p_route_result."callto.6.scgatewayaccountid",
		p_route_result."callto.6.scgatewayipid",
		p_route_result."callto.6.sctechcalled");
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.7.called",
		p_route_result."callto.7.caller",
		p_route_result."callto.7.callername",
		p_route_result."callto.7.format",
		p_route_result."callto.7.formats",
		p_route_result."callto.7.line",
		p_route_result."callto.7",
		p_route_result."callto.7.maxcall",
		p_route_result."callto.7.osip_P-Asserted-Identity",
		p_route_result."callto.7.osip_Gateway-ID",
		p_route_result."callto.7.osip_Tracking-ID",
		p_route_result."callto.7.rtp_addr",
		p_route_result."callto.7.rtp_forward",
		p_route_result."callto.7.oconnection_id",
		p_route_result."callto.7.rtp_port",
		p_route_result."callto.7.timeout",
		p_route_result."callto.7.scgatewayid",
		p_route_result."callto.7.scgatewayaccountid",
		p_route_result."callto.7.scgatewayipid",
		p_route_result."callto.7.sctechcalled");
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.8.called",
		p_route_result."callto.8.caller",
		p_route_result."callto.8.callername",
		p_route_result."callto.8.format",
		p_route_result."callto.8.formats",
		p_route_result."callto.8.line",
		p_route_result."callto.8",
		p_route_result."callto.8.maxcall",
		p_route_result."callto.8.osip_P-Asserted-Identity",
		p_route_result."callto.8.osip_Gateway-ID",
		p_route_result."callto.8.osip_Tracking-ID",
		p_route_result."callto.8.rtp_addr",
		p_route_result."callto.8.rtp_forward",
		p_route_result."callto.8.oconnection_id",
		p_route_result."callto.8.rtp_port",
		p_route_result."callto.8.timeout",
		p_route_result."callto.8.scgatewayid",
		p_route_result."callto.8.scgatewayaccountid",
		p_route_result."callto.8.scgatewayipid",
		p_route_result."callto.8.sctechcalled");
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.9.called",
		p_route_result."callto.9.caller",
		p_route_result."callto.9.callername",
		p_route_result."callto.9.format",
		p_route_result."callto.9.formats",
		p_route_result."callto.9.line",
		p_route_result."callto.9",
		p_route_result."callto.9.maxcall",
		p_route_result."callto.9.osip_P-Asserted-Identity",
		p_route_result."callto.9.osip_Gateway-ID",
		p_route_result."callto.9.osip_Tracking-ID",
		p_route_result."callto.9.rtp_addr",
		p_route_result."callto.9.rtp_forward",
		p_route_result."callto.9.oconnection_id",
		p_route_result."callto.9.rtp_port",
		p_route_result."callto.9.timeout",
		p_route_result."callto.9.scgatewayid",
		p_route_result."callto.9.scgatewayaccountid",
		p_route_result."callto.9.scgatewayipid",
		p_route_result."callto.9.sctechcalled");
	INSERT INTO tmp (error, reason, location, scnodeid, sccustomerid, sccustomeripid, sctrackingid, sccachehit, scrouteduration, copyparams, sccustomerpriceid,
		"callto.called",
		"callto.caller",
		"callto.callername",
		"callto.format",
		"callto.formats",
		"callto.line",
		"callto",
		"callto.maxcall",
		"callto.osip_P-Asserted-Identity",
		"callto.osip_Gateway-ID",
		"callto.osip_Tracking-ID",
		"callto.rtp_addr",
		"callto.rtp_forward",
		"callto.oconnection_id",
		"callto.rtp_port",
		"callto.timeout",
		"callto.scgatewayid",
		"callto.scgatewayaccountid",
		"callto.scgatewayipid",
		"callto.sctechcalled")
	VALUES (
		p_route_result.error, p_route_result.reason, p_route_result.location, p_route_result.scnodeid, p_route_result.sccustomerid, p_route_result.sccustomeripid, p_route_result.sctrackingid, p_route_result.sccachehit,
		p_route_result.scrouteduration, p_route_result.copyparams, p_route_result.sccustomerpriceid,
		p_route_result."callto.10.called",
		p_route_result."callto.10.caller",
		p_route_result."callto.10.callername",
		p_route_result."callto.10.format",
		p_route_result."callto.10.formats",
		p_route_result."callto.10.line",
		p_route_result."callto.10",
		p_route_result."callto.10.maxcall",
		p_route_result."callto.10.osip_P-Asserted-Identity",
		p_route_result."callto.10.osip_Gateway-ID",
		p_route_result."callto.10.osip_Tracking-ID",
		p_route_result."callto.10.rtp_addr",
		p_route_result."callto.10.rtp_forward",
		p_route_result."callto.10.oconnection_id",
		p_route_result."callto.10.rtp_port",
		p_route_result."callto.10.timeout",
		p_route_result."callto.10.scgatewayid",
		p_route_result."callto.10.scgatewayaccountid",
		p_route_result."callto.10.scgatewayipid",
		p_route_result."callto.10.sctechcalled");

	RETURN QUERY SELECT * FROM tmp;

END;
$$;


--
-- TOC entry 366 (class 1255 OID 1239172)
-- Name: internal_route_send_to_gateway(integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_send_to_gateway(p_gateway_id integer, p_node_id integer) RETURNS SETOF view_callto_result
	LANGUAGE plpgsql
	AS $$
	DECLARE i_protocol TEXT;
		i_format TEXT;
		i_formats TEXT;
		i_gateway_type gatewaytype;
		i_destination TEXT;
		i_line TEXT;
		i_new_callername TEXT;
		i_new_caller TEXT;
		i_caller TEXT;
		i_callername TEXT;
		i_action TEXT;
		i_rtp_addr TEXT;
		i_rtp_port TEXT;
		i_rtp_forward TEXT;
		i_prefix TEXT;
		i_concurrent_connection_attempts INTEGER;
		i_endpoint_id INTEGER;
		i_immediately BOOL;
		i_sippassertedidentity TEXT;
		-- STANDARD
		i_callto_record view_callto_result%rowtype;
BEGIN
	i_concurrent_connection_attempts = 0;
	i_immediately := false;

	SELECT * INTO i_callto_record FROM view_callto_result;

	i_callto_record.maxcall := '';
	i_callto_record.scgatewayid := p_gateway_id::TEXT;
	
	-- GENERAL GATEWAY INFORMATION
	SELECT format.name, gateway.gateway_formats, gateway.type, coalesce(prefix, ''), concurrent_connection_attempts
		INTO i_format, i_formats, i_gateway_type, i_prefix, i_concurrent_connection_attempts, i_sippassertedidentity FROM gateway
	INNER JOIN format ON format.id = gateway.format_id WHERE gateway.id = p_gateway_id;

	i_callto_record.format := i_format;
	i_callto_record.formats := i_formats;
	i_callto_record.oconnection_id := 'general';

	
	-- SPECIFIC GATEWAY INFORMATION
	IF i_gateway_type = 'Account'::gatewaytype THEN

		--SETUP 
		i_callto_record.caller := 		'';
		i_callto_record.callername := 		'';
		i_callto_record.called := 		'';
		i_callto_record.timeout := 		'';
		i_callto_record.rtp_addr := 		'';
		i_callto_record.rtp_port := 		'';

		SELECT gateway_account.id, server, new_callername, account, protocol, new_caller INTO i_endpoint_id, i_destination, i_new_callername, i_line, i_protocol, i_new_caller FROM gateway_account
		LEFT JOIN gateway_account_statistic ON gateway_account_statistic.gateway_account_id = gateway_account.id AND date = current_date
		WHERE gateway_account.node_id = p_node_id
			AND gateway_account.gateway_id = p_gateway_id
			AND gateway_account.enabled = true
		ORDER BY gateway_account_statistic.billtime ASC
		LIMIT 1;

		-- check callername and caller
		IF i_new_callername IS NOT NULL AND i_new_callername <> '' THEN
			i_callto_record.callername := i_new_callername;
		END IF;
		IF i_new_caller IS NOT NULL AND i_new_caller <> '' THEN
			i_callto_record.caller := i_new_caller;
		END IF;

		i_callto_record.location := 		i_protocol || '/' || i_protocol || ':' || i_prefix || '{loccalled}';
		i_callto_record.line :=			i_line;
		i_callto_record.rtp_forward := 	'no'::TEXT;
		i_callto_record.scgatewayaccountid := 	i_endpoint_id::TEXT;
		i_callto_record.immediately :=		false;
		
		RETURN NEXT i_callto_record;

	ELSE
	
		FOR i_endpoint_id, i_destination, i_protocol, i_rtp_addr, i_rtp_port, i_rtp_forward, i_sippassertedidentity  IN SELECT DISTINCT id, ap, protocol, rtp_addr, rtp_port, rtpfw, sip_p_asserted_identity FROM
																(SELECT gateway_ip.id, address || ':' || port AS ap, protocol, rtp_addr, rtp_port::TEXT, CASE WHEN rtp_forward THEN 'yes' ELSE 'no' END AS rtpfw, sip_p_asserted_identity
																	FROM gateway_ip
																	INNER JOIN gateway_ip_node ON gateway_ip_node.gateway_ip_id = gateway_ip.id
																	LEFT JOIN gateway_ip_statistic ON gateway_ip_statistic.gateway_ip_id = gateway_ip.id AND date = current_date
																	WHERE gateway_id = p_gateway_id AND enabled = true
																		AND gateway_ip_node.node_id = p_node_id
																	ORDER BY billtime) a
																	LIMIT i_concurrent_connection_attempts LOOP
			
		
			i_callto_record.caller := 			i_caller;
			i_callto_record.callername :=			i_callername;
			i_callto_record.location := 			i_protocol || '/' || i_protocol || ':' || i_prefix || '{loccalled}@' || i_destination;
			i_callto_record.rtp_addr :=			i_rtp_addr;
			i_callto_record.rtp_port :=			i_rtp_port;
			i_callto_record.rtp_forward :=			i_rtp_forward;
			i_callto_record.scgatewayipid :=		i_endpoint_id::TEXT;
			i_callto_record."osip_P-Asserted-Identity" :=	i_sippassertedidentity;
			i_callto_record.immediately :=			i_immediately;

			RETURN NEXT i_callto_record;
			
			i_immediately := true;
		END LOOP;
	END IF;

	RETURN;
END;
$$;


--
-- TOC entry 367 (class 1255 OID 1239173)
-- Name: internal_route_send_to_gateway_replace(view_callto_result, text, text, text, integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_send_to_gateway_replace(p_target view_callto_result, p_caller text, p_callername text, p_called text, p_gateway_id integer, p_timeout integer) RETURNS view_callto_result
	LANGUAGE plpgsql
	AS $$
	DECLARE i_number_modification_group_id INTEGER;
		i_called TEXT;
BEGIN
	i_called := p_called;
	-- CHECK NUMBER MODIFICATION
	SELECT number_modification_group_id INTO i_number_modification_group_id FROM gateway WHERE id = p_gateway_id;

	IF i_number_modification_group_id IS NOT NULL THEN
		i_called := (internal_gateway_number_modification(i_number_modification_group_id, i_called));
	END IF;

	SELECT a.callername, a.caller INTO p_callername, p_caller FROM internal_util_incorrect_callername(p_callername, p_caller) a;

	IF p_target.caller = '' OR p_target.caller IS NULL THEN
		p_target.caller := p_caller;
	END IF;

	IF p_target.callername = '' OR p_target.callername IS NULL THEN
		p_target.callername := p_callername;
	END IF;

	p_target.location :=		REPLACE(p_target.location, '{loccalled}', i_called);
	p_target.sctechcalled :=	p_target.location;
	p_target.called :=		p_called;
	p_target.timeout :=		p_timeout::TEXT;
	p_target.maxcall := 		'20000';
	RETURN p_target;
END;
$$;


--
-- TOC entry 368 (class 1255 OID 1239174)
-- Name: internal_route_send_to_node(integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_send_to_node(p_node_id integer, p_target_node_id integer) RETURNS view_callto_result
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_node_ip TEXT;
		i_port TEXT;
		i_action  TEXT;
		i_callto_record view_callto_result%rowtype;
BEGIN
	SELECT * INTO i_callto_record FROM view_callto_result;

	SELECT host(node_ip.address), port::TEXT INTO i_node_ip, i_port FROM node_ip WHERE node_id = p_target_node_id AND network = 'Intern' AND enabled = true AND deleted = false ORDER BY id DESC LIMIT 1;

	i_callto_record.format := 'g729';
	i_callto_record.formats := 'g729';
	i_callto_record.rtp_forward := 'no';
	i_callto_record.maxcall := '';
	i_callto_record.oconnection_id := 'intern';
	i_callto_record.location = 'sip/sip:{called}@' || i_node_ip || ':' || i_port;

	RETURN i_callto_record;
END;
$$;


--
-- TOC entry 369 (class 1255 OID 1239175)
-- Name: internal_route_send_to_node_replace(view_callto_result, text, text, text, integer, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_route_send_to_node_replace(p_target view_callto_result, p_caller text, p_callername text, p_called text, p_gateway_id integer, p_timeout integer, p_trackingid text) RETURNS view_callto_result
	LANGUAGE plpgsql
	AS $$
BEGIN
	p_target.caller := p_caller;
	p_target.callername := p_callername;
	p_target.called := p_called;
	p_target.timeout := p_timeout;
	p_target.location := REPLACE(p_target.location, '{called}', p_called);
	p_target."osip_Gateway-ID" := p_gateway_id::TEXT;
	p_target."osip_Tracking-ID" := p_trackingid;
	p_target.sctechcalled := p_target.location;
	p_target.rtp_forward := 'no'::TEXT;
			
	RETURN p_target;

END;
$$;


--
-- TOC entry 347 (class 1255 OID 1239180)
-- Name: internal_routing_rules(integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_routing_rules(p_customer_id integer, p_called text) RETURNS view_routing_rules_result
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE i_result view_routing_rules_result%rowtype;
		i_gateway_id INTEGER;
		i_count INTEGER = 1;
BEGIN
	SELECT * INTO i_result FROM view_routing_rules_result;

	-- GET CUSTOMER PRICE
	SELECT id INTO i_result.sccustomerpriceid FROM customer_price
		WHERE customer_price.customer_id = p_customer_id AND number IN (SELECT * FROM internal_util_number_to_table(p_called)) AND NOW() BETWEEN valid_from AND valid_to
		ORDER BY LENGTH(number) DESC LIMIT 1;

	IF i_result.sccustomerpriceid IS NOT NULL THEN
		i_result.has_price := TRUE;
	END IF;

	-- CHECK IF MAY SEND TO ALL DESTINATIONS
	SELECT all_destinations, fake_ringing INTO i_result.all_destinations, i_result.fake_ringing FROM customer WHERE customer.id = p_customer_id;
	
	-- CHECK ITS DESTINATION
	SELECT route.timeout, CASE WHEN coalesce(route.action, '') = E'\\1' THEN p_called ELSE coalesce(route.action, '') END, route.did, route.id, route.caller, route.callername
			INTO i_result.timeout, i_result.action, i_result.did, i_result.route_id, i_result.new_caller, i_result.new_callername FROM route
	LEFT JOIN route_to_gateway ON route_to_gateway.route_id = route.id
	LEFT JOIN gateway ON gateway.id = route_to_gateway.gateway_id AND gateway.enabled = true
	WHERE route.context_id = (SELECT context_id FROM customer WHERE id = p_customer_id)
		AND route.enabled = true
		AND p_called ~ pattern
	ORDER BY route.sort DESC
	LIMIT 1;
	
	IF FOUND THEN
		i_result.has_route := true;
	END IF;

	FOR i_gateway_id IN SELECT gateway_id FROM route_to_gateway WHERE route_id = i_result.route_id ORDER BY sort ASC LOOP
		i_result.gateway_ids[i_count] := i_gateway_id;
		i_count := i_count + 1;
	END LOOP;

	i_result.is_lcr := (SELECT least_cost_routing FROM context WHERE id = (SELECT context_id FROM customer WHERE id = p_customer_id));
	
	i_result.decision := (SELECT action FROM routing_decision WHERE price = i_result.has_price AND route = i_result.has_route AND is_lcr = i_result.is_lcr AND all_destinations = i_result.all_destinations);
	
	RETURN i_result;
END;
$$;


--
-- TOC entry 356 (class 1255 OID 1239181)
-- Name: internal_util_clean_number(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_clean_number(p_number text) RETURNS text
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	p_number := internal_util_delete_prefix(p_number);
	p_number := (SELECT TRIM(LEADING '0' FROM p_number));
	p_number := (SELECT TRIM(LEADING '+' FROM p_number));
	p_number := (SELECT TRIM(LEADING '0' FROM p_number));
	p_number := (SELECT SUBSTRING(p_number, E'^[\\d]+'));

	return p_number;
END;
$$;


--
-- TOC entry 362 (class 1255 OID 1239182)
-- Name: internal_util_delete_prefix(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_delete_prefix(p_value text) RETURNS text
	LANGUAGE plpgsql IMMUTABLE STRICT
	AS $$

BEGIN
	WHILE position('#' in p_value) > 0 LOOP

		p_value = substring(p_value from position('#' in p_value) + 1);

	END LOOP;

	RETURN p_value;
END;
$$;


--
-- TOC entry 371 (class 1255 OID 1239183)
-- Name: internal_util_incorrect_callername(text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_incorrect_callername(p_callername text, p_caller text) RETURNS TABLE(callername text, caller text)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE
		i_replacement text;
BEGIN

	IF strpos(p_caller, '[') > 0 OR strpos(p_callername, '[') > 0 THEN
		p_caller := 'anonymous';
		p_callername := 'anonymous';
	END IF;

	i_replacement := (SELECT replacement FROM incorrect_callername WHERE name = p_callername OR name = p_caller ORDER BY id DESC LIMIT 1);

	IF i_replacement IS NOT NULL AND i_replacement <> '' THEN

		p_callername := i_replacement;
		p_caller := i_replacement;

	END IF;

	p_callername := replace(p_callername, ' ', '');
	p_caller := replace(p_caller, ' ', '');
	
	IF p_caller = '' THEN
		p_caller := 'anonymous';
	ELSE 
		p_caller := (SELECT * FROM internal_util_clean_number(p_caller));
	END IF;

	IF p_callername = '' THEN
		p_callername := 'anonymous';
	ELSE 
		p_callername := (SELECT * FROM internal_util_clean_number(p_callername));
	END IF;

	RETURN QUERY SELECT p_callername, p_caller;
	
END;
$$;


--
-- TOC entry 372 (class 1255 OID 1239184)
-- Name: internal_util_incorrect_callername_originale(text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_incorrect_callername_originale(p_callername text, p_caller text) RETURNS TABLE(callername text, caller text)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE
		i_replacement text;
BEGIN

	IF strpos(p_caller, '[') > 0 OR strpos(p_callername, '[') > 0 THEN
		p_caller := 'anonymous';
		p_callername := 'anonymous';
	END IF;

	i_replacement := (SELECT replacement FROM incorrect_callername WHERE name = p_callername OR name = p_caller ORDER BY id DESC LIMIT 1);

	IF i_replacement IS NOT NULL AND i_replacement <> '' THEN

		p_callername := i_replacement;
		p_caller := i_replacement;

	END IF;

	p_callername := replace(p_callername, ' ', '');
	p_caller := replace(p_caller, ' ', '');

	IF p_caller = '' THEN
		p_caller := 'anonymous';
	END IF;

	IF p_callername = '' THEN
		p_callername := 'anonymous';
	END IF;

	RETURN QUERY SELECT p_callername, p_caller;
	
END;
$$;


--
-- TOC entry 373 (class 1255 OID 1239185)
-- Name: internal_util_normalize_to_usd(numeric, character); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_normalize_to_usd(p_price numeric, p_currency character) RETURNS numeric
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN

	IF p_currency <> 'USD' THEN

		p_price = (SELECT p_price * multiplier FROM exchange_rate_to_usd WHERE currency = p_currency);

		-- check if rate exchange was successful
		IF p_price IS NULL THEN
			RETURN 10000;
		END IF;

	END IF;

	RETURN p_price;
END;
$$;


--
-- TOC entry 374 (class 1255 OID 1239186)
-- Name: internal_util_number_to_table(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_number_to_table(p_number text) RETURNS SETOF text
	LANGUAGE plpgsql IMMUTABLE
	AS $$
	DECLARE i_take INTEGER;
			i_length INTEGER=0;
BEGIN
	i_take := 1;
	i_length := LENGTH(p_number);
	WHILE i_take <= i_length LOOP

		RETURN NEXT SUBSTRING(p_number FROM 1 FOR i_take);

		i_take := i_take + 1;
	END LOOP;
	
	RETURN;
END;
$$;


--
-- TOC entry 375 (class 1255 OID 1239187)
-- Name: internal_util_total_price(integer, integer, bigint, numeric); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION internal_util_total_price(p_firstdialingincrement integer, p_nextdialingincrement integer, p_billtime bigint, p_price numeric) RETURNS numeric
	LANGUAGE plpgsql IMMUTABLE STRICT
	AS $$
	DECLARE i_total_price NUMERIC;
BEGIN
	IF p_billtime < 1000 THEN
		RETURN 0;
	END IF;

	p_billtime := CEIL(p_billtime/1000::NUMERIC)::BIGINT;

	-- FIRST DIALING INCREMENT
	i_total_price := p_firstdialingincrement * p_price / 60;

	p_billtime := p_billtime - p_firstdialingincrement;

	-- CHECK IF REST
	IF p_billtime <= 0 THEN
		RETURN i_total_price;
	END IF;

	i_total_price := i_total_price + CEIL(p_billtime::NUMERIC / p_nextdialingincrement) * p_nextdialingincrement * p_price / 60::numeric;

	RETURN i_total_price;

END;
$$;


--
-- TOC entry 376 (class 1255 OID 1239188)
-- Name: isdigit(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION isdigit(p_text text) RETURNS boolean
	LANGUAGE plpgsql IMMUTABLE STRICT
	AS $_$
BEGIN
	IF p_text IS NULL THEN
		RETURN false AS result;
	END IF;

	RETURN p_text ~ '^(-)?[0-9]+$' AS result;
END;
$_$;


--
-- TOC entry 377 (class 1255 OID 1239189)
-- Name: job_customer_invoice(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION job_customer_invoice() RETURNS SETOF integer
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_customer_id INTEGER;
		i_billing INTEGER;
		i_invoice_days INTEGER;
		i_last_invoice_date DATE;
		i_billtime BIGINT;
		i_date date;
BEGIN
	i_date := CURRENT_DATE;

	CREATE TEMP TABLE tmp_customer (id INTEGER) ON COMMIT DROP;

	FOR i_customer_id, i_billing IN SELECT customer.id, company.billing FROM customer
		INNER JOIN company ON company.id = customer.company_id WHERE billing IS NOT NULL LOOP

		CASE i_billing
			WHEN 1 THEN
				i_invoice_days := 7;
			WHEN 2 THEN
				i_invoice_days := 7;
			WHEN 3 THEN
				i_invoice_days := 14;
			WHEN 4 THEN
				i_invoice_days := 14;
			WHEN 5 THEN
				i_invoice_days := -1;
			WHEN 6 THEN
				i_invoice_days := -1;
			ELSE
				CONTINUE;
		END CASE;	

		-- CONTINUE LOOP IF invoice days = -1 AND TODAY IS NOT FIRST DAY OF MONTH
		IF i_invoice_days = -1 AND EXTRACT('day' FROM i_date) <> 1 THEN
			CONTINUE;
		ELSEIF i_invoice_days <> -1 AND EXTRACT(dow FROM i_date) <> 1 THEN
			-- CONTINUE IF BILLING IS 7 OR 14 AND TODAY IS NOT MONDAY
			CONTINUE;
		END IF;

		i_last_invoice_date := (SELECT period_to::DATE FROM customer_invoice WHERE customer_id = i_customer_id ORDER BY customer_invoice.id DESC LIMIT 1);

		i_billtime := 0;
		-- CHECK IF monthly BILLING
		IF i_invoice_days = -1 THEN
			-- CHECK IF CUSTOMER HAS HAD CALLS LAST MONTH, IF NOT WE DONT NEED AN INVOICE
			i_billtime := (SELECT cdri.billtime FROM cdr cdri, cdr cdro
					WHERE cdri.id <> cdro.id
					AND cdri.billid = cdro.billid
					AND cdri.sqltime BETWEEN (i_date - INTERVAL '1 month')::TIMESTAMPTZ AND (i_date - INTERVAL '1 microsecond')::TIMESTAMPTZ
					AND cdri.customer_id = i_customer_id
					AND cdro.billtime > 1000 ORDER BY cdri.sqltime LIMIT 1);

		-- NO INVOICE OR INVOICE invoice days OR MORE PASSED
		ELSEIF i_last_invoice_date IS NULL OR i_last_invoice_date + CONCAT(i_invoice_days + 1, ' days')::INTERVAL <= i_date THEN

			-- CHECK IF CUSTOMER HAVE HAD CALLS ON TODAY-invoice days (FIRST DAY OF INVOICE PERIOD), IF NOT WE DONT NEED AN INVOICE
			i_billtime := (SELECT cdri.billtime FROM cdr cdri, cdr cdro
					WHERE cdri.id <> cdro.id
					AND cdri.billid = cdro.billid
					AND cdri.sqltime BETWEEN i_date - CONCAT(i_invoice_days, ' days')::INTERVAL AND i_date - '1 microsecond'::INTERVAL
					AND cdri.customer_id = i_customer_id
					AND cdro.billtime > 1000 ORDER BY cdri.sqltime LIMIT 1);
		END IF;


		IF i_billtime > 1000 THEN
			INSERT INTO tmp_customer (id) VALUES (i_customer_id);
		END IF;
	END LOOP;

	RETURN QUERY SELECT * FROM tmp_customer;
END;
$$;


--
-- TOC entry 378 (class 1255 OID 1239190)
-- Name: job_customer_invoice(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION job_customer_invoice(p_start date, p_end date) RETURNS SETOF integer
	LANGUAGE plpgsql
	AS $$
BEGIN
	p_end := p_end + INTERVAL '1 day';

	RETURN QUERY SELECT DISTINCT(customer_id) FROM cdr
		WHERE sqltime >= p_start AND sqltime < p_end AND customer_id IS NOT NULL AND billtime > 1000;
END;
$$;


--
-- TOC entry 379 (class 1255 OID 1239191)
-- Name: job_daily_performance(date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION job_daily_performance(p_date date) RETURNS TABLE(type text, name text, billtime bigint, value numeric, currency character)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE i_start TIMESTAMPTZ;
		i_end TIMESTAMPTZ;
BEGIN
	i_start := p_date::TIMESTAMPTZ;
	i_end := i_start + INTERVAL '1 day' - INTERVAL '1 microsecond';

	RETURN QUERY SELECT 'customer', customer.name, SUM(cdr.billtime)::bigint, SUM(cdr.customer_price_total) price, cdr.customer_currency FROM cdr
		RIGHT JOIN customer ON customer.id = cdr.customer_id
		WHERE cdr.sqltime BETWEEN i_start AND i_end AND cdr.billtime > 0
		GROUP BY customer.name, cdr.customer_currency
		HAVING SUM(cdr.billtime)::bigint / 1000 / 60 > 1 OR SUM(cdr.gateway_price_total) IS NOT NULL AND SUM(cdr.gateway_price_total) > 0
		UNION
		SELECT 'gateway', gateway.name, SUM(cdr.billtime)::bigint, SUM(cdr.gateway_price_total) price, cdr.gateway_currency FROM cdr
		RIGHT JOIN gateway ON gateway.id = cdr.gateway_id
		WHERE cdr.sqltime BETWEEN i_start AND i_end AND cdr.billtime > 0
		GROUP BY gateway.name, cdr.gateway_currency
		HAVING SUM(cdr.billtime)::bigint / 1000 / 60 > 1 OR SUM(cdr.gateway_price_total) IS NOT NULL AND SUM(cdr.gateway_price_total) > 0;
END;
$$;


--
-- TOC entry 370 (class 1255 OID 1239192)
-- Name: job_gateway_daily_report(date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION job_gateway_daily_report(p_date date, p_gateway_id integer) RETURNS TABLE(name text, amount bigint, billtime bigint)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE i_date_end TIMESTAMPTZ;
BEGIN

	i_date_end := p_date::TIMESTAMPTZ + interval '1 day' - interval '1 microsecond';
	
	RETURN QUERY SELECT carrier.name, count(*) AS ccount, SUM(cdr.billtime)::bigint AS bsum FROM cdr
			LEFT JOIN dialcode ON cdr.dialcode_id = dialcode.id
			LEFT JOIN carrier ON dialcode.carrier_id = carrier.id
			WHERE gateway_id = p_gateway_id AND sqltime BETWEEN p_date::TIMESTAMPTZ AND i_date_end
			GROUP BY carrier.name
			ORDER BY bsum DESC, ccount DESC
			LIMIT 10;
END;
$$;


--
-- TOC entry 381 (class 1255 OID 1239193)
-- Name: monitor_carrier_incoming(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_carrier_incoming(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id IS NOT NULL
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 382 (class 1255 OID 1239194)
-- Name: monitor_carrier_outgoing(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_carrier_outgoing(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.gateway_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id IS NOT NULL
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 383 (class 1255 OID 1239195)
-- Name: monitor_countries_incoming(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_countries_incoming(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id IS NOT NULL
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
	GROUP BY 
		country.iso3 
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 384 (class 1255 OID 1239196)
-- Name: monitor_countries_outgoing(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_countries_outgoing(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.gateway_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id IS NOT NULL
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
	GROUP BY 
		country.iso3 
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 385 (class 1255 OID 1239197)
-- Name: monitor_country_carriers_incoming(text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_country_carriers_incoming(p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id IS NOT NULL
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		carrier.name,
		dialcode.is_mobile
	ORDER BY carrier.name;
END;
$$;


--
-- TOC entry 387 (class 1255 OID 1239198)
-- Name: monitor_country_carriers_outgoing(text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_country_carriers_outgoing(p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id IS NOT NULL
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		carrier.name,
		dialcode.is_mobile
	ORDER BY carrier.name;
END;
$$;


--
-- TOC entry 388 (class 1255 OID 1239199)
-- Name: monitor_country_cutsomers(text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_country_cutsomers(p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT cdr.customer_id AS "ID", 
		customer.name AS "Customer", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN customer ON customer.id = cdr.customer_id
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND cdr.customer_id IS NOT NULL
		AND cdr.direction = 'incoming'
		AND country.iso3 = p_iso
	GROUP BY 
		cdr.customer_id, 
		customer.name
	ORDER BY customer.name;
END;
$$;


--
-- TOC entry 389 (class 1255 OID 1239200)
-- Name: monitor_country_dialcodes_incoming(text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_country_dialcodes_incoming(p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id IS NOT NULL
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		dialcode.number,
		carrier.name,
		dialcode.is_mobile
	ORDER BY dialcode.number;
END;
$$;


--
-- TOC entry 390 (class 1255 OID 1239201)
-- Name: monitor_country_dialcodes_outgoing(text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_country_dialcodes_outgoing(p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id IS NOT NULL
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		dialcode.number,
		carrier.name,
		dialcode.is_mobile
	ORDER BY dialcode.number;
END;
$$;


--
-- TOC entry 391 (class 1255 OID 1239202)
-- Name: monitor_country_gateways(text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_country_gateways(p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT cdr.gateway_id AS "ID", 
		gateway.name AS "Gateway", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN gateway ON gateway.id = cdr.gateway_id
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND cdr.gateway_id IS NOT NULL
		AND cdr.direction = 'outgoing'
		AND country.iso3 = p_iso
	GROUP BY 
		cdr.gateway_id, 
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 392 (class 1255 OID 1239203)
-- Name: monitor_customer_countries(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_customer_countries(p_id integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id = p_id
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
	GROUP BY 
		country.iso3 
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 393 (class 1255 OID 1239204)
-- Name: monitor_customer_country_carrier(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_customer_country_carrier(p_id integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id = p_id
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		carrier.name,
		dialcode.is_mobile
	ORDER BY carrier.name;
END;
$$;


--
-- TOC entry 394 (class 1255 OID 1239205)
-- Name: monitor_customer_country_dialcodes(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_customer_country_dialcodes(p_id integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id = p_id
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		dialcode.number,
		carrier.name,
		dialcode.is_mobile
	ORDER BY dialcode.number;
END;
$$;


--
-- TOC entry 395 (class 1255 OID 1239206)
-- Name: monitor_customer_country_gateways(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_customer_country_gateways(p_id integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		B.gateway_id, 
		gateway.name,
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(B.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	LEFT JOIN dialcode ON dialcode.id = A.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	INNER JOIN gateway ON B.gateway_id = gateway.id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.customer_id = p_id
		AND B.direction = 'outgoing'
		AND B.gateway_id IS NOT NULL
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		B.gateway_id,
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 396 (class 1255 OID 1239207)
-- Name: monitor_customer_details(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_customer_details(p_id integer) RETURNS TABLE("ID" integer, "Name" text, "Company" text)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT customer.id, customer.name, company.name FROM customer
	LEFT JOIN company ON customer.company_id = company.id
	WHERE customer.id = p_id
	ORDER BY customer.name;
END;
$$;


--
-- TOC entry 397 (class 1255 OID 1239208)
-- Name: monitor_customer_gateways(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_customer_gateways(p_id integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Gateway" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT B.gateway_id, 
		gateway.name,
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(B.gateway_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	INNER JOIN gateway ON B.gateway_id = gateway.id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.customer_id = p_id
		AND B.direction = 'outgoing'
		AND B.gateway_id IS NOT NULL
	GROUP BY 
		B.gateway_id,
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 398 (class 1255 OID 1239209)
-- Name: monitor_cutsomers(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_cutsomers(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT cdr.customer_id AS "ID", 
		customer.name AS "Customer", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN customer ON customer.id = cdr.customer_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND cdr.customer_id IS NOT NULL
		AND cdr.direction = 'incoming'
	GROUP BY 
		cdr.customer_id, 
		customer.name
	ORDER BY customer.name;
END;
$$;


--
-- TOC entry 400 (class 1255 OID 1239210)
-- Name: monitor_dialcodes_incoming(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_dialcodes_incoming(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id IS NOT NULL
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile,
		dialcode.number
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 401 (class 1255 OID 1239211)
-- Name: monitor_dialcodes_outgoing(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_dialcodes_outgoing(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.gateway_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id IS NOT NULL
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile,
		dialcode.number
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 402 (class 1255 OID 1239212)
-- Name: monitor_gateway_countries(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateway_countries(p_id integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id = p_id
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
	GROUP BY 
		country.iso3 
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 403 (class 1255 OID 1239213)
-- Name: monitor_gateway_country_carrier(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateway_country_carrier(p_id integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id = p_id
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		carrier.name,
		dialcode.is_mobile
	ORDER BY carrier.name;
END;
$$;


--
-- TOC entry 404 (class 1255 OID 1239214)
-- Name: monitor_gateway_country_customers(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateway_country_customers(p_id integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		B.customer_id, 
		customer.name,
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(B.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	LEFT JOIN dialcode ON dialcode.id = A.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	INNER JOIN customer ON B.customer_id = customer.id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.gateway_id = p_id
		AND B.direction = 'incoming'
		AND B.customer_id IS NOT NULL
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		B.customer_id,
		customer.name
	ORDER BY customer.name;
END;
$$;


--
-- TOC entry 406 (class 1255 OID 1239215)
-- Name: monitor_gateway_country_dialcodes(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateway_country_dialcodes(p_id integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "Carrier" text, "Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		p_iso AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id = p_id
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
		AND country.iso3 = p_iso
	GROUP BY 
		dialcode.number,
		carrier.name,
		dialcode.is_mobile
	ORDER BY dialcode.number;
END;
$$;


--
-- TOC entry 407 (class 1255 OID 1239216)
-- Name: monitor_gateway_customers(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateway_customers(p_id integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT B.customer_id, 
		customer.name,
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(B.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	INNER JOIN customer ON B.customer_id = customer.id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.gateway_id = p_id
		AND B.direction = 'incoming'
		AND B.customer_id IS NOT NULL
	GROUP BY 
		B.customer_id,
		customer.name
	ORDER BY customer.name;
END;
$$;


--
-- TOC entry 408 (class 1255 OID 1239217)
-- Name: monitor_gateway_details(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateway_details(p_id integer) RETURNS TABLE("ID" integer, "Name" text, "Company" text)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT gateway.id, gateway.name, company.name FROM gateway
	LEFT JOIN company ON gateway.company_id = company.id
	WHERE gateway.id = p_id
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 409 (class 1255 OID 1239218)
-- Name: monitor_gateways(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_gateways(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Gateway" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT cdr.gateway_id AS "ID", 
		gateway.name AS Gateway, 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.gateway_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN gateway ON gateway.id = cdr.gateway_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND cdr.gateway_id IS NOT NULL
		AND cdr.direction = 'outgoing'
	GROUP BY 
		cdr.gateway_id, 
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 410 (class 1255 OID 1239219)
-- Name: monitor_mobile_incoming(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_mobile_incoming(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.is_mobile AS "Mobile", 
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.customer_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id IS NOT NULL
		AND direction = 'incoming'
		AND dialcode.valid_to > p_start
	GROUP BY 
		country.iso3, 
		dialcode.is_mobile
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 412 (class 1255 OID 1239220)
-- Name: monitor_mobile_outgoing(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION monitor_mobile_outgoing(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Mobile" boolean, "ISO3" text, "Calls" bigint, "Billtime" text, "Balance" numeric, "ALOC0" text, "ALOC10" text, "ALOC30" text, "ASR0" numeric, "ASR10" numeric, "ASR30" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.is_mobile AS "Mobile", 
		country.iso3 AS "ISO3",
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		sum(cdr.gateway_price_total)::numeric(6,2) AS "Balance",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(6,2) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id IS NOT NULL
		AND direction = 'outgoing'
		AND dialcode.valid_to > p_start
	GROUP BY 
		country.iso3, 
		dialcode.is_mobile
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 413 (class 1255 OID 1239221)
-- Name: sams_customer_limit_check(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION sams_customer_limit_check() RETURNS TABLE(id integer, name text, call_limit bigint, warning bigint, current bigint)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT customer.id, customer.name, customer.hour_limit AS call_limit, customer.hour_limit_warning AS warning, SUM(customer_ip_statistic.billtime)::bigint AS current FROM customer_ip_statistic
		INNER JOIN customer_ip ON customer_ip.id = customer_ip_statistic.customer_ip_id
		INNER JOIN customer ON customer.id = customer_ip.customer_id
		WHERE customer_ip_statistic.date = DATE(now()) AND customer.hour_limit_warning IS NOT NULL AND customer.hour_limit_warning > 0
		GROUP BY customer.id, customer.name, customer.hour_limit, customer.hour_limit_warning
		HAVING customer.hour_limit_warning < SUM(customer_ip_statistic.billtime);
END;
$$;


--
-- TOC entry 414 (class 1255 OID 1239222)
-- Name: sams_gateway_limit_check(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION sams_gateway_limit_check() RETURNS TABLE(id integer, name text, call_limit bigint, warning bigint, current bigint)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT gateway.id, gateway.name, gateway.hour_limit AS call_limit, gateway.hour_limit_warning AS warning, SUM(gateway_ip_statistic.billtime)::bigint AS current FROM gateway_ip_statistic
		INNER JOIN gateway_ip ON gateway_ip.id = gateway_ip_statistic.gateway_ip_id
		INNER JOIN gateway ON gateway.id = gateway_ip.gateway_id
		WHERE gateway_ip_statistic.date = DATE(now()) AND gateway.hour_limit_warning IS NOT NULL AND gateway.hour_limit_warning > 0
		GROUP BY gateway.id, gateway.name, gateway.hour_limit, gateway.hour_limit_warning
		HAVING (gateway.hour_limit_warning) < SUM(gateway_ip_statistic.billtime)
		UNION
		SELECT gateway.id, gateway.name, gateway.hour_limit AS call_limit, gateway.hour_limit_warning AS warning, SUM(gateway_account_statistic.billtime)::bigint AS current FROM gateway_account_statistic
		INNER JOIN gateway_account ON gateway_account.id = gateway_account_statistic.gateway_account_id
		INNER JOIN gateway ON gateway.id = gateway_account.gateway_id
		WHERE gateway_account_statistic.date = DATE(now()) AND gateway.hour_limit_warning IS NOT NULL AND gateway.hour_limit_warning > 0
		GROUP BY gateway.id, gateway.name, gateway.hour_limit, gateway.hour_limit_warning
		HAVING (gateway.hour_limit_warning) < SUM(gateway_account_statistic.billtime);
END;
$$;


--
-- TOC entry 415 (class 1255 OID 1239223)
-- Name: sams_voip_error_check(interval); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION sams_voip_error_check(p_interval interval) RETURNS TABLE(type text, name text, amount bigint, reason text)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	-- COLLECT REASONS
	RETURN QUERY SELECT a.type, a.name, a.amount, a.reason FROM (
			SELECT 'Gateway' AS type, gateway.name, COUNT(*) AS amount, cdr.reason FROM cdr
			INNER JOIN gateway_ip ON gateway_ip.id = cdr.gateway_ip_id
			INNER JOIN gateway ON gateway.id = gateway_ip.gateway_id
			WHERE sqltime BETWEEN (now() - p_interval) AND now()
			GROUP BY gateway.name, cdr.reason
			UNION
			SELECT 'Customer' AS type, customer.name, COUNT(*) AS amount, cdr.reason FROM cdr
			INNER JOIN customer_ip ON customer_ip.id = cdr.customer_ip_id
			INNER JOIN customer ON customer.id = customer_ip.customer_id
			WHERE sqltime BETWEEN (now() - p_interval) AND now()
			GROUP BY customer.name, cdr.reason
			UNION
			SELECT 'Incoming', 'Unknown', COUNT(*) AS amount, cdr.reason FROM cdr
			WHERE sqltime BETWEEN (now() - p_interval) and now() 
				AND gateway_id IS NULL
				AND customer_id IS NULL
				AND direction = 'incoming'
				AND address NOT IN (SELECT address FROM node_ip WHERE enabled = true)
			GROUP BY cdr.reason
		) a
		ORDER BY a.type, a.name, a.amount desc;
END;
$$;


--
-- TOC entry 416 (class 1255 OID 1239224)
-- Name: sams_yate_service_check(interval); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION sams_yate_service_check(p_response_limit interval) RETURNS TABLE(id integer, name text, enabled boolean, is_in_maintenance_mode boolean)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT a.id, a.name, a.enabled, a.is_in_maintenance_mode FROM (
		SELECT node.id, node.name, node.enabled, node.is_in_maintenance_mode, node.online_since as online_since 
		FROM node
		WHERE deleted = false
		GROUP BY node.id, node.name, node.enabled, node.is_in_maintenance_mode, node.online_since
	)a
	WHERE a.online_since < (now() - p_response_limit);

END;
$$;


--
-- TOC entry 417 (class 1255 OID 1239225)
-- Name: stats_interval_customer_countries(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_customer_countries(p_customer integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "ISO3" text, "Carrier" text, "Mobile" boolean, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT 
		dialcode.number AS "Code",
		country.iso3 AS "ISO3",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND customer_id = p_customer
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile,
		dialcode.number
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 405 (class 1255 OID 1239226)
-- Name: stats_interval_customer_country_gateways(integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_customer_country_gateways(p_customer integer, p_iso text, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Gateway" text, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT B.gateway_id, 
		gateway.name,
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	LEFT JOIN dialcode ON dialcode.id = B.dialcode_id
	INNER JOIN gateway ON B.gateway_id = gateway.id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.customer_id = p_customer
		AND B.direction = 'outgoing'
		AND B.gateway_id IS NOT NULL
		AND country.iso3 = p_iso
	GROUP BY 
		B.gateway_id,
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 411 (class 1255 OID 1239227)
-- Name: stats_interval_customer_gateway_countries(integer, integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_customer_gateway_countries(p_customer integer, p_gateway integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "ISO3" text, "Carrier" text, "Mobile" boolean, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT
		dialcode.number AS "Code",
		country.iso3 AS "ISO3",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile",
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	LEFT JOIN dialcode ON dialcode.id = B.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.customer_id = p_customer
		AND B.direction = 'outgoing'
		AND B.gateway_id = p_gateway
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile,
		dialcode.number
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 418 (class 1255 OID 1239228)
-- Name: stats_interval_customer_gateways(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_customer_gateways(p_customer integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Gateway" text, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT B.gateway_id, 
		gateway.name,
		count(B) AS "Calls [#]",
		to_char(((sum(B.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN B.billtime > 0 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN B.billtime > 10000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN B.billtime > 30000 THEN B.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN B.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 0 [%]",
		(count(CASE WHEN B.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 10 [%]",
		(count(CASE WHEN B.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 30 [%]"
	FROM cdr A
	LEFT JOIN cdr B ON A.billid = B.billid
	INNER JOIN gateway ON B.gateway_id = gateway.id
	WHERE 
		A.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND B.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND A.customer_id = p_customer
		AND B.direction = 'outgoing'
		AND B.gateway_id IS NOT NULL
	GROUP BY 
		B.gateway_id,
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 419 (class 1255 OID 1239229)
-- Name: stats_interval_customers_total(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_customers_total(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Customer" text, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT cdr.customer_id AS "ID", 
		customer.name AS "Customer", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3,1) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3,1) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3,1) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN customer ON customer.id = cdr.customer_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND cdr.customer_id IS NOT NULL
	GROUP BY 
		cdr.customer_id, 
		customer.name
	ORDER BY customer.name;
END;
$$;


--
-- TOC entry 420 (class 1255 OID 1239230)
-- Name: stats_interval_gateway_countries(integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_gateway_countries(p_gateway integer, p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("Dialcode" text, "ISO3" text, "Carrier" text, "Mobile" boolean, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT 
		dialcode.number AS "Code",
		country.iso3 AS "ISO3",
		carrier.name AS "Carrier",
		dialcode.is_mobile AS "Mobile", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
	INNER JOIN carrier ON carrier.id = dialcode.carrier_id
	INNER JOIN country ON country.id = carrier.country_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND gateway_id = p_gateway
	GROUP BY 
		carrier.name,
		country.iso3, 
		dialcode.is_mobile,
		dialcode.number
	ORDER BY country.iso3;
END;
$$;


--
-- TOC entry 421 (class 1255 OID 1239231)
-- Name: stats_interval_gateways_total(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION stats_interval_gateways_total(p_start timestamp without time zone, p_end timestamp without time zone) RETURNS TABLE("ID" integer, "Gateway" text, "Calls [#]" bigint, "Billtime [h]" text, "ALOC 0 [m]" text, "ALOC 10 [m]" text, "ALOC 30 [m]" text, "ASR 0 [%]" numeric, "ASR 10 [%]" numeric, "ASR 30 [%]" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT cdr.gateway_id AS "ID", 
		gateway.name AS "Gateway", 
		count(*) AS "Calls [#]",
		to_char(((sum(cdr.billtime) / 1000 ) || ' second')::interval, 'HH24:MI:SS') AS "Billtime [h]",
		to_char(((avg(CASE WHEN cdr.billtime > 0 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 0 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 10000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 10 [m]",
		to_char(((avg(CASE WHEN cdr.billtime > 30000 THEN cdr.billtime END) / 1000 ) || ' second')::interval, 'MI:SS') AS "ALOC 30 [m]",
		(count(CASE WHEN cdr.billtime > 0 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3,1) AS "ASR 0 [%]",
		(count(CASE WHEN cdr.billtime > 10000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3,1) AS "ASR 10 [%]",
		(count(CASE WHEN cdr.billtime > 30000 THEN 1 ELSE null END)::numeric / count(*)::numeric * 100)::numeric(3,1) AS "ASR 30 [%]"
	FROM cdr 
	LEFT JOIN gateway ON gateway.id = cdr.gateway_id
	WHERE 
		cdr.sqltime BETWEEN (to_char(p_start, 'YYYY-MM-DD')  || ' 00:00:00+00')::timestamp 
		AND (to_char(p_end, 'YYYY-MM-DD')  || ' 23:59:59+00')::timestamp 
		AND cdr.gateway_id IS NOT NULL
	GROUP BY 
		cdr.gateway_id, 
		gateway.name
	ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 442 (class 1255 OID 1239251)
-- Name: web_active_countries(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_active_countries(p_start date, p_end date) RETURNS TABLE(id integer, name text)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	IF p_start < CURRENT_DATE AND p_end < CURRENT_DATE THEN
		RETURN QUERY SELECT DISTINCT a.country_id, country.iso3 FROM (
					SELECT country_id FROM history_gateway_billtime
						WHERE date >= p_start AND date <= p_end
					UNION
					SELECT country_id FROM history_customer_billtime
						WHERE date >= p_start AND date <= p_end
				) a
				INNER JOIN country ON country.id = a.country_id;
		RETURN;
	ELSE
		RETURN QUERY SELECT DISTINCT country.id, country.iso3 FROM history_outgoing
					INNER JOIN country ON country.id = history_outgoing.country_id
					WHERE sqltime BETWEEN p_start AND (p_end + INTERVAL '1 day' - INTERVAL '1 microsecond');
	END IF;

END;
$$;


--
-- TOC entry 443 (class 1255 OID 1239252)
-- Name: web_active_customers(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_active_customers(p_start date, p_end date) RETURNS TABLE(id integer, name text, company text)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	IF p_start < CURRENT_DATE AND p_end < CURRENT_DATE THEN
		RETURN QUERY SELECT DISTINCT customer.id, customer.name, company.name FROM customer
			INNER JOIN company ON company.id = customer.company_id
			INNER JOIN history_customer_cpm hccpm ON hccpm.customer_id = customer.id
			WHERE hccpm.datetime >= p_start AND hccpm.datetime <= (p_end + interval '1 day' - interval '1 millisecond');
	ELSE
		RETURN QUERY SELECT DISTINCT customer.id, customer.name, company.name FROM cdr
			INNER JOIN customer ON customer.id = cdr.customer_id
			INNER JOIN company ON company.id = customer.company_id
			WHERE cdr.sqltime BETWEEN p_start AND (p_end + interval '1 day' - interval '1 millisecond') AND customer_id IS NOT NULL;
	END IF;
END;
$$;


--
-- TOC entry 444 (class 1255 OID 1239253)
-- Name: web_active_gateways(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_active_gateways(p_start date, p_end date) RETURNS TABLE(id integer, name text, company text)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	IF p_start < CURRENT_DATE AND p_end < CURRENT_DATE THEN
		RETURN QUERY SELECT DISTINCT gateway.id, gateway.name, company.name FROM gateway
			INNER JOIN company ON company.id = gateway.company_id
			INNER JOIN history_gateway_cpm hgcpm ON hgcpm.gateway_id = gateway.id
			WHERE hgcpm.datetime >= p_start AND hgcpm.datetime <= (p_end + interval '1 day' - interval '1 millisecond');
	ELSE
		RETURN QUERY SELECT DISTINCT gateway.id, gateway.name, company.name FROM cdr
			INNER JOIN gateway ON gateway.id = cdr.gateway_id
			INNER JOIN company ON company.id = gateway.company_id
			WHERE cdr.sqltime BETWEEN p_start AND (p_end + interval '1 day' - interval '1 millisecond') AND gateway_id IS NOT NULL;
	END IF;
END;
$$;


--
-- TOC entry 446 (class 1255 OID 1239254)
-- Name: web_active_nodes(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_active_nodes(p_start date, p_end date) RETURNS TABLE(id integer, name text, company text)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	-- IF p_start < CURRENT_DATE AND p_end < CURRENT_DATE THEN
-- 		RETURN QUERY SELECT DISTINCT a.id, a.name, '' FROM (
-- 			SELECT node.id, node.name, '' FROM node
-- 				INNER JOIN history_customer_cpm hccpm ON hccpm.node_id = node.id
-- 				WHERE hccpm.datetime >= p_start AND hccpm.datetime <= (p_end + interval '1 day' - interval '1 millisecond')
-- 			UNION
-- 			SELECT node.id, node.name, '' FROM node
-- 				INNER JOIN history_gateway_cpm hgcpm ON hgcpm.node_id = node.id
-- 				WHERE hgcpm.datetime >= p_start AND hgcpm.datetime <= (p_end + interval '1 day' - interval '1 millisecond')
-- 			) a;
-- 	ELSE
-- 		RETURN QUERY SELECT DISTINCT node.id, node.name, '' FROM cdr
-- 				INNER JOIN node ON node.id = cdr.node_id
-- 				WHERE cdr.sqltime BETWEEN p_start AND (p_end + interval '1 day' - interval '1 millisecond');
-- 	END IF;
	RETURN QUERY SELECT DISTINCT node.id, node.name, '' FROM node
		INNER JOIN history_customer_cpm hcpm ON hcpm.node_id = node.id
		WHERE hcpm.datetime >= p_start AND hcpm.datetime <= p_end + INTERVAL '1 day'
		UNION
		SELECT DISTINCT node.id, node.name, '' FROM node
		INNER JOIN history_gateway_cpm hgpm ON hgpm.node_id = node.id
		WHERE hgpm.datetime >= p_start AND hgpm.datetime <= p_end + INTERVAL '1 day';
END;
$$;


--
-- TOC entry 447 (class 1255 OID 1239255)
-- Name: web_adm_active_calls_node_total(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_active_calls_node_total(p_date_start timestamp with time zone, p_date_end timestamp with time zone) RETURNS TABLE(id bigint, start timestamp with time zone, duration bigint, endtime timestamp with time zone)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT cdr.id, date_trunc('minute', sqltime), cdr.duration, date_trunc('minute', cdr.sqltime_end) FROM cdr
		WHERE sqltime BETWEEN p_date_start AND p_date_end AND cdr.direction = 'outgoing';
END;
$$;


--
-- TOC entry 448 (class 1255 OID 1239256)
-- Name: web_adm_active_calls_per_company(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_active_calls_per_company(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer) RETURNS TABLE(id bigint, start timestamp with time zone, duration bigint, calc_end timestamp with time zone)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT cdr.id, date_trunc('minute', sqltime), cdr.duration, date_trunc('minute', cdr.sqltime_end) FROM cdr
		INNER JOIN customer ON customer.id = cdr.customer_id
		WHERE sqltime BETWEEN p_date_start AND p_date_end AND customer.company_id = p_company_id;
END;
$$;


--
-- TOC entry 449 (class 1255 OID 1239257)
-- Name: web_adm_active_calls_per_node(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_active_calls_per_node(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_node_id integer) RETURNS TABLE(id bigint, start timestamp with time zone, duration bigint, calc_end timestamp with time zone)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT cdr.id, date_trunc('minute', sqltime), cdr.duration, date_trunc('minute', cdr.sqltime_end) FROM cdr
		WHERE sqltime BETWEEN p_date_start AND p_date_end AND node_id = p_node_id AND cdr.direction = 'outgoing';
END;
$$;


--
-- TOC entry 450 (class 1255 OID 1239258)
-- Name: web_adm_calls_and_billtime_by_country(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_calls_and_billtime_by_country(p_date_start timestamp with time zone, p_date_end timestamp with time zone) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, country text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, country.iso3 FROM cdr
		INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		INNER JOIN country ON country.id = carrier.country_id
		WHERE sqltime BETWEEN p_date_start AND p_date_end
			AND gateway_id IS NOT NULL
		GROUP BY country.id;
END;
$$;


--
-- TOC entry 451 (class 1255 OID 1239259)
-- Name: web_adm_calls_and_billtime_by_day(timestamp with time zone, timestamp with time zone, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_calls_and_billtime_by_day(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_accumulation text, p_endpoint text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, date date)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_endpoint = 'Customer' THEN

		IF p_accumulation = 'Sum' THEN

			RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, CAST(sqltime AS date) AS date FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND customer_id IS NOT NULL
				GROUP BY CAST(sqltime AS date)
				ORDER BY date;
		ELSE

			RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
					SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, CAST(sqltime AS date) AS date FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
							AND customer_id IS NOT NULL
						GROUP BY CAST(sqltime AS date), DATE_PART('hour', sqltime)
						ORDER BY date
				) a
				GROUP BY a.date;
		END IF;

	ELSEIF p_endpoint = 'Gateway' THEN

			IF p_accumulation = 'Sum' THEN

				RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, CAST(sqltime AS date) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND gateway_id IS NOT NULL
					GROUP BY CAST(sqltime AS date)
					ORDER BY date;
			ELSE

				RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
						SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, CAST(sqltime AS date) AS date FROM cdr
							WHERE sqltime BETWEEN p_date_start AND p_date_end
								AND gateway_id IS NOT NULL
							GROUP BY CAST(sqltime AS date), DATE_PART('hour', sqltime)
							ORDER BY date
					) a
					GROUP BY a.date;
			END IF;

	ELSE

		IF p_accumulation = 'Sum' THEN

			RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, CAST(sqltime AS date) AS date FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
				GROUP BY CAST(sqltime AS date)
				ORDER BY date;
		ELSE

			RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
					SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, CAST(sqltime AS date) AS date FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
						GROUP BY CAST(sqltime AS date), DATE_PART('hour', sqltime)
						ORDER BY date
				) a
				GROUP BY a.date;
		END IF;

	END IF;

END;
$$;


--
-- TOC entry 452 (class 1255 OID 1239260)
-- Name: web_adm_calls_and_billtime_by_gateway(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_calls_and_billtime_by_gateway(p_date_start timestamp with time zone, p_date_end timestamp with time zone) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, gateway text, company text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, gateway.name, company.name FROM cdr
		INNER JOIN gateway ON gateway.id = cdr.gateway_id
		INNER JOIN company ON company.id = gateway.company_id
		WHERE sqltime BETWEEN p_date_start AND p_date_end
		GROUP BY gateway.name, company.name;
END;
$$;


--
-- TOC entry 453 (class 1255 OID 1239261)
-- Name: web_adm_calls_and_billtime_by_hour(timestamp with time zone, timestamp with time zone, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_calls_and_billtime_by_hour(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_accumulation text, p_endpoint text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, hour double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_endpoint = 'Customer' THEN

		IF p_accumulation = 'Sum' THEN

			RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND cdr.customer_id IS NOT NULL
				GROUP BY DATE_PART('hour', sqltime)
				ORDER BY hour;

		ELSE

			RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
					SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
							AND cdr.customer_id IS NOT NULL
						GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
						ORDER BY hour
					) a
					GROUP BY a.hour;

		END IF;

	ELSEIF p_endpoint = 'Gateway' THEN
	
			IF p_accumulation = 'Sum' THEN

				RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.gateway_id IS NOT NULL
					GROUP BY DATE_PART('hour', sqltime)
					ORDER BY hour;

			ELSE

				RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
						SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
							WHERE sqltime BETWEEN p_date_start AND p_date_end
								AND cdr.gateway_id IS NOT NULL
							GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
							ORDER BY hour
						) a
						GROUP BY a.hour;

			END IF;

	ELSE

		IF p_accumulation = 'Sum' THEN

			RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
				GROUP BY DATE_PART('hour', sqltime)
				ORDER BY hour;

		ELSE

			RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
					SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
						GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
						ORDER BY hour
					) a
					GROUP BY a.hour;

		END IF;
		
	END IF;

END;
$$;


--
-- TOC entry 454 (class 1255 OID 1239262)
-- Name: web_adm_calls_and_billtime_by_month(timestamp with time zone, timestamp with time zone, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_calls_and_billtime_by_month(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_accumulation text, p_endpoint text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, yearmonth character)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_endpoint = 'Customer' THEN

		IF p_accumulation = 'Sum' THEN
		
			RETURN QUERY SELECT calls, billtime, CAST(EXTRACT(year FROM date) || '-' || EXTRACT(month FROM date) AS character(7)) AS period FROM (
						SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
							AND cdr.customer_id IS NOT NULL
						GROUP BY date_trunc('month',sqltime)
					) AS a;
		ELSE

			RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
						SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
							AND cdr.customer_id IS NOT NULL
						GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
					) AS a
					GROUP BY period;

		END IF;

	ELSEIF p_endpoint = 'Gateway' THEN

			IF p_accumulation = 'Sum' THEN
			
				RETURN QUERY SELECT calls, billtime, CAST(EXTRACT(year FROM date) || '-' || EXTRACT(month FROM date) AS character(7)) AS period FROM (
							SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
							WHERE sqltime BETWEEN p_date_start AND p_date_end
								AND cdr.gateway_id IS NOT NULL
							GROUP BY date_trunc('month',sqltime)
						) AS a;
			ELSE

				RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
							SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
							WHERE sqltime BETWEEN p_date_start AND p_date_end
								AND cdr.gateway_id IS NOT NULL
							GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
						) AS a
						GROUP BY period;

			END IF;

	ELSE

		IF p_accumulation = 'Sum' THEN
		
			RETURN QUERY SELECT calls, billtime, CAST(EXTRACT(year FROM date) || '-' || EXTRACT(month FROM date) AS character(7)) AS period FROM (
						SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
						GROUP BY date_trunc('month',sqltime)
					) AS a;
		ELSE

			RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
						SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
						GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
					) AS a
					GROUP BY period;

		END IF;

	END IF;

END;
$$;


--
-- TOC entry 423 (class 1255 OID 1239263)
-- Name: web_adm_calls_and_billtime_by_year(timestamp with time zone, timestamp with time zone, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_calls_and_billtime_by_year(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_accumulation text, p_endpoint text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, year double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_endpoint = 'Customer'  THEN

		IF p_accumulation = 'Sum' THEN
		
			RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('year', sqltime) AS year FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND customer_id IS NOT NULL
				GROUP BY DATE_PART('year', sqltime)
				ORDER BY year;
		ELSE
			RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND customer_id IS NOT NULL
					GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
					ORDER BY year
				) a
				GROUP BY a.year;
		END IF;

	ELSEIF p_endpoint = 'Gateway' THEN

			IF p_accumulation = 'Sum' THEN
			
				RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('year', sqltime) AS year FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND gateway_id IS NOT NULL
					GROUP BY DATE_PART('year', sqltime)
					ORDER BY year;
			ELSE
				RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
					SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
						WHERE sqltime BETWEEN p_date_start AND p_date_end
							AND gateway_id IS NOT NULL
						GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
						ORDER BY year
					) a
					GROUP BY a.year;
			END IF;

	ELSE
		IF p_accumulation = 'Sum' THEN
		
			RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('year', sqltime) AS year FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
				GROUP BY DATE_PART('year', sqltime)
				ORDER BY year;
		ELSE
			RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
					GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
					ORDER BY year
				) a
				GROUP BY a.year;
		END IF;

	END IF;

END;
$$;


--
-- TOC entry 456 (class 1255 OID 1239264)
-- Name: web_adm_company_concurrent_calls(timestamp with time zone, timestamp with time zone, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_company_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_accumulation text) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN
	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND customer_id IS NOT NULL
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(asd), time_start FROM (
		SELECT COUNT(*) asd, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -count(*) asd , time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;

END;
$$;


--
-- TOC entry 457 (class 1255 OID 1239265)
-- Name: web_adm_country_and_main_dialcode(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_country_and_main_dialcode() RETURNS TABLE("ISO3" text, "Number" text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT ON (country.iso3) country.iso3, dialcode.number FROM country
		INNER JOIN carrier ON carrier.country_id = country.id
		INNER JOIN dialcode ON dialcode.carrier_id = carrier.id
		WHERE NOW() BETWEEN dialcode.valid_from AND valid_to
		ORDER BY country.iso3 ASC, dialcode.number ASC;
END;
$$;


--
-- TOC entry 458 (class 1255 OID 1239266)
-- Name: web_adm_country_dialcodes(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_country_dialcodes(p_country_id integer) RETURNS TABLE(dialcode text, carrier text, is_mobile boolean, dialcode_id integer, carrier_id integer)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT number, carrier.name, dialcode.is_mobile, dialcode.id, dialcode.carrier_id FROM dialcode
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		WHERE country_id = p_country_id AND NOW() BETWEEN dialcode.valid_from AND dialcode.valid_to
		ORDER BY number, carrier.name, is_mobile;
END;
$$;


--
-- TOC entry 459 (class 1255 OID 1239267)
-- Name: web_adm_country_main_dialcode(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_country_main_dialcode(p_country_id integer) RETURNS text
	LANGUAGE sql
	AS $_$
SELECT MIN(dialcode.number) FROM country
	INNER JOIN carrier ON carrier.country_id = country.id
	INNER JOIN dialcode ON dialcode.carrier_id = carrier.id
	WHERE country.id = $1 AND NOW() BETWEEN dialcode.valid_from AND dialcode.valid_to
$_$;


--
-- TOC entry 460 (class 1255 OID 1239268)
-- Name: web_adm_country_stats(timestamp with time zone, timestamp with time zone, bigint, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_country_stats(p_start timestamp with time zone, p_end timestamp with time zone, p_min_length bigint, p_min_calls integer) RETURNS TABLE(id integer, country text, aloc bigint, asr numeric, sum bigint, calls bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT a.country_id, a.iso3, a.aloc::bigint, b.asr, a.sum::bigint, a.calls FROM (
			SELECT country_id, country.iso3, AVG(NULLIF(billtime,0)) AS aloc, SUM(billtime) as sum, COUNT(*) as calls FROM cdr
				LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				INNER JOIN country ON country.id = carrier.country_id
				WHERE cdr.billtime >= p_min_length AND direction = 'outgoing' AND sqltime BETWEEN p_start AND p_end
				GROUP BY country_id, iso3
				HAVING COUNT(*) > p_min_calls
			) a,
		(
			SELECT a.country_id, 100 * working / total as asr FROM (
				SELECT country_id, COUNT(*)::numeric as working FROM cdr
				INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				WHERE sqltime BETWEEN p_start AND p_end AND billtime >= 1000
				GROUP BY country_id
			) a,
			(
				SELECT country_id, COUNT(*)::numeric as total FROM cdr
				INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				WHERE sqltime BETWEEN p_start AND p_end
				GROUP BY country_id
			)b
			WHERE a.country_id = b.country_id
		) b
		WHERE a.country_id = b.country_id;
END;
$$;


--
-- TOC entry 461 (class 1255 OID 1239269)
-- Name: web_adm_customer_cc_candle(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_customer_cc_candle(p_start date, p_end date) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_customer_cc
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day' AND calls > 5
		GROUP BY datetime::DATE;
END;
$$;


--
-- TOC entry 462 (class 1255 OID 1239270)
-- Name: web_adm_customer_cpm_candle(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_customer_cpm_candle(p_start date, p_end date) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_customer_cpm
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day'
		GROUP BY datetime::DATE;
END;
$$;


--
-- TOC entry 463 (class 1255 OID 1239271)
-- Name: web_adm_customer_overview_select(date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_customer_overview_select(p_date date) RETURNS TABLE(concurrent_calls bigint, billtime bigint, calls_total bigint, calls_failed bigint, customer_name text, company_name text, customer_id integer, cpm bigint)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_date TIMESTAMPTZ;
BEGIN
	i_date := NOW();

	IF CURRENT_DATE <> p_date THEN
		i_date := end_date();
	END IF;

	RETURN QUERY SELECT a.CC::BIGINT, b.B::BIGINT, b.CT::BIGINT, b.CF::BIGINT, b.customer_name, b.company_name, b.customer_id, c.cpm FROM (
		-- show all active calls (today and maybe some from yesterday)
		SELECT SUM(cis.concurrent_calls) as CC, customer.id AS customer_id FROM customer
			INNER JOIN company ON company.id = customer.company_id
			LEFT JOIN customer_ip ON customer_ip.customer_id = customer.id
			LEFT JOIN view_customer_ip_statistic cis ON cis.customer_ip_id = customer_ip.id AND (cis.date = p_date OR cis.date = (p_date - INTERVAL '1 day')::DATE)
			WHERE customer.enabled = TRUE
			GROUP BY customer.id, customer.name, company.name) a, (	
		-- show other stats only from today
		SELECT SUM(cis.billtime)::BIGINT as B, SUM(cis.calls_total) as CT, SUM(cis.calls_failed) as CF, customer.name AS customer_name, company.name AS company_name, customer.id AS customer_id FROM customer
			INNER JOIN company ON company.id = customer.company_id
			LEFT JOIN customer_ip ON customer_ip.customer_id = customer.id
			LEFT JOIN view_customer_ip_statistic cis ON cis.customer_ip_id = customer_ip.id AND cis.date = p_date
			WHERE customer.enabled = TRUE
			GROUP BY customer.id, customer.name, company.name) b, (
		SELECT customer.id AS customer_id, COUNT(cdr.*) AS cpm FROM customer
			LEFT JOIN cdr ON customer.id = cdr.customer_id AND cdr.sqltime BETWEEN i_date - INTERVAL '1 minute' AND i_date
			WHERE customer.enabled = TRUE
			GROUP BY customer.id) c 
		WHERE a.customer_id = b.customer_id and a.customer_id = c.customer_id
		ORDER BY company_name, customer_name;
END;
$$;


--
-- TOC entry 464 (class 1255 OID 1239272)
-- Name: web_adm_estimate_cdr_count(); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_estimate_cdr_count() RETURNS bigint
	LANGUAGE sql STABLE STRICT
	AS $$SELECT SUM(reltuples)::BIGINT FROM pg_catalog.pg_class WHERE relname LIKE 'cdr_%';$$;


--
-- TOC entry 465 (class 1255 OID 1239273)
-- Name: web_adm_gateway_cc_candle(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_gateway_cc_candle(p_start date, p_end date) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_gateway_cc
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day' AND calls > 5
		GROUP BY datetime::DATE;
END;
$$;


--
-- TOC entry 466 (class 1255 OID 1239274)
-- Name: web_adm_gateway_concurrent_calls(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_gateway_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN
	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND gateway_id IS NOT NULL
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(anz), time_start FROM (
		SELECT COUNT(*) anz, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -COUNT(*) anz , time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;
END;
$$;


--
-- TOC entry 467 (class 1255 OID 1239275)
-- Name: web_adm_gateway_cpm_candle(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_gateway_cpm_candle(p_start date, p_end date) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_gateway_cpm
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day'
		GROUP BY datetime::DATE;
END;
$$;


--
-- TOC entry 468 (class 1255 OID 1239276)
-- Name: web_adm_gateway_overview_select(date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_gateway_overview_select(p_date date) RETURNS TABLE(concurrent_calls bigint, billtime bigint, calls_total bigint, calls_failed bigint, gateway_name text, company_name text, gateway_id integer, cpm bigint)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_date TIMESTAMPTZ;
BEGIN
	i_date := NOW();

	IF CURRENT_DATE <> p_date THEN
		i_date := end_date();
	END IF;

	RETURN QUERY SELECT SUM(f.concurrent_calls)::BIGINT, SUM(f.billtime)::BIGINT, SUM(f.calls_total)::BIGINT, SUM(f.calls_failed)::BIGINT, f.gateway_name, f.company_name, f.gateway_id, SUM(f.cpm)::BIGINT FROM (
		SELECT a.concurrent_calls, b.billtime, b.calls_total, b.calls_failed, b.gateway_name, b.company_name, b.gateway_id, c.cpm FROM (
			SELECT SUM(gas.concurrent_calls) as concurrent_calls, gateway.id as gateway_id, gateway.name as gateway_name, company.name as company_name FROM gateway
				LEFT JOIN gateway_account ON gateway_account.gateway_id = gateway.id AND gateway_account.enabled = true
				INNER JOIN company ON company.id = gateway.company_id
				LEFT JOIN view_gateway_account_statistic gas ON gas.gateway_account_id = gateway_account.id AND (gas.date = p_date OR gas.date = (p_date - INTERVAL '1 day')::DATE)
				WHERE gateway.enabled = true
				GROUP BY gateway.id, gateway_name, company_name )a, (
			SELECT SUM(gas.billtime) as billtime, SUM(gas.calls_total) as calls_total, SUM(gas.calls_failed) as calls_failed, gateway.name as gateway_name, company.name as company_name, gateway.id as gateway_id FROM gateway
				LEFT JOIN gateway_account ON gateway_account.gateway_id = gateway.id AND gateway_account.enabled = true
				INNER JOIN company ON company.id = gateway.company_id
				LEFT JOIN view_gateway_account_statistic gas ON gas.gateway_account_id = gateway_account.id AND gas.date = p_date
				WHERE gateway.enabled = true
				GROUP BY gateway.id, gateway_name, company_name) b, (
			SELECT gateway.id AS gateway_id, COUNT(cdr.*) AS cpm FROM gateway
				LEFT JOIN cdr ON gateway.id = cdr.gateway_id AND cdr.sqltime BETWEEN i_date - INTERVAL '1 minute' AND i_date
				WHERE gateway.enabled = TRUE
				GROUP BY gateway.id) c 
			WHERE a.gateway_id = b.gateway_id AND a.gateway_id = c.gateway_id		
		UNION
		SELECT c.concurrent_calls, d.billtime, d.calls_total, d.calls_failed, d.gateway_name, d.company_name, d.gateway_id, e.cpm FROM (
			SELECT SUM(gis.concurrent_calls) as concurrent_calls, gateway.name as gateway_name, company.name as company_name, gateway.id as gateway_id FROM gateway
				LEFT JOIN gateway_ip ON gateway_ip.gateway_id = gateway.id AND gateway_ip.enabled = true
				INNER JOIN company ON company.id = gateway.company_id
				LEFT JOIN view_gateway_ip_statistic gis ON gis.gateway_ip_id = gateway_ip.id AND (gis.date = p_date OR gis.date = (p_date - INTERVAL '1 day')::DATE)
				WHERE gateway.enabled = true
				GROUP BY gateway.id, gateway_name, company_name) c, (
			SELECT SUM(gis.billtime)::bigint as billtime, SUM(gis.calls_total) as calls_total, SUM(gis.calls_failed) as calls_failed, gateway.name as gateway_name, company.name as company_name, gateway.id as gateway_id FROM gateway
				LEFT JOIN gateway_ip ON gateway_ip.gateway_id = gateway.id AND gateway_ip.enabled = true
				INNER JOIN company ON company.id = gateway.company_id
				LEFT JOIN view_gateway_ip_statistic gis ON gis.gateway_ip_id = gateway_ip.id AND gis.date = p_date
				WHERE gateway.enabled = true
				GROUP BY gateway.id, gateway_name, company_name) d, (
			SELECT gateway.id AS gateway_id, COUNT(cdr.*) AS cpm FROM gateway
				LEFT JOIN cdr ON gateway.id = cdr.gateway_id AND cdr.sqltime BETWEEN i_date - INTERVAL '1 minute' AND i_date
				WHERE gateway.enabled = TRUE
				GROUP BY gateway.id) e 
			WHERE c.gateway_id = d.gateway_id AND c.gateway_id = e.gateway_id
		) f
		GROUP BY f.gateway_id, f.gateway_name, f.company_name
		ORDER BY f.gateway_name; 
END;
$$;


--
-- TOC entry 469 (class 1255 OID 1239277)
-- Name: web_adm_head_overview(date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_head_overview(p_date date) RETURNS TABLE(inward bigint, outward bigint, totalbilltime bigint, avgbilltime bigint, activecalls bigint, outwardtotal bigint, cpm integer)
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_in_total_calls bigint;
		i_out_total_calls bigint;
		i_out_distinct_calls bigint;
		i_total_billtime bigint;
		i_avg_billtime bigint;
		i_active_calls bigint;
		i_start timestamp;
		i_end timestamp;
		i_cpm int;
		i_cpm_s TIMESTAMPTZ;
		i_cpm_e TIMESTAMPTZ;
BEGIN
	i_start := p_date;
	i_end := p_date + interval '1 day';

	i_in_total_calls := 0;
	i_out_total_calls := 0;
	i_out_distinct_calls := 0;
	i_total_billtime := 0;

	SELECT SUM(a.billtime), SUM(a.ct) INTO i_total_billtime, i_out_total_calls FROM (
		SELECT SUM(view_gateway_ip_statistic.billtime) as billtime, SUM(calls_total) AS ct FROM view_gateway_ip_statistic
		WHERE date = p_date
		UNION
		SELECT SUM(view_gateway_account_statistic.billtime), SUM(calls_total) AS ct FROM view_gateway_account_statistic
		WHERE date = p_date)a ;

	i_active_calls := (SELECT COUNT(*) FROM cdr WHERE direction = 'incoming'::direction AND ended = FALSE AND sqltime BETWEEN p_date - INTERVAL '1 day' AND p_date + INTERVAL '1 day');

	i_avg_billtime := (SELECT CASE WHEN SUM(calls_total-calls_failed) = 0 THEN 0 ELSE SUM(billtime) / SUM(calls_total-calls_failed) END FROM view_customer_ip_statistic WHERE date = p_date)::INTEGER;

	i_out_distinct_calls := (SELECT COUNT(*) FROM history_outgoing WHERE sqltime >= i_start AND sqltime < i_end);

	i_in_total_calls := (SELECT SUM(calls_total) FROM view_customer_ip_statistic WHERE date = p_date);

	i_cpm_s := (NOW() - INTERVAL '1 minute');
	i_cpm_e := NOW();

	i_cpm := (SELECT COUNT(*) FROM cdr WHERE customer_id IS NOT NULL AND sqltime > i_cpm_s AND sqltime <= i_cpm_e);

	RETURN QUERY SELECT i_in_total_calls, i_out_distinct_calls, i_total_billtime, i_avg_billtime, i_active_calls, i_out_total_calls, i_cpm;

END;
$$;


--
-- TOC entry 470 (class 1255 OID 1239278)
-- Name: web_adm_move_carrier(integer, integer, boolean); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_move_carrier(p_source_id integer, p_destination_id integer, p_delete_source boolean) RETURNS void
	LANGUAGE plpgsql
	AS $$
BEGIN
	UPDATE dialcode SET carrier_id = p_destination_id WHERE carrier_id = p_source_id;

	IF p_delete_source = TRUE THEN
		DELETE FROM carrier WHERE id = p_source_id;
	END IF;
END;
$$;


--
-- TOC entry 471 (class 1255 OID 1239279)
-- Name: web_adm_node_calls_per_second(integer, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_node_calls_per_second(p_node_id integer, p_date date) RETURNS TABLE(marker time without time zone, amount bigint)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_end DATE;
BEGIN
	i_end := p_date + INTERVAL '1 day';
	
	RETURN QUERY SELECT (EXTRACT(hour FROM sqltime)::TEXT || ':' || 
			CASE WHEN EXTRACT(minute FROM sqltime) > 9 THEN EXTRACT(minute FROM sqltime)::TEXT ELSE '0' || EXTRACT(minute FROM sqltime)::TEXT END || ':' || 
			CASE WHEN FLOOR(EXTRACT(second FROM sqltime)) > 9 THEN FLOOR(EXTRACT(second FROM sqltime))::TEXT ELSE '0' || FLOOR(EXTRACT(second FROM sqltime)) END)::TIME AS marker,
			COUNT(*) AS amount FROM cdr
			WHERE cdr.direction = 'incoming' AND cdr.node_id = p_node_id AND sqltime BETWEEN p_date AND i_end
			GROUP BY marker ORDER BY marker;
END;
$$;


--
-- TOC entry 472 (class 1255 OID 1239280)
-- Name: web_adm_node_concurrent_calls(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_node_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN

	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND node_id IS NOT NULL
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(anz), time_start FROM (
		SELECT COUNT(*) anz, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -COUNT(*) anz, time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;
END;
$$;


--
-- TOC entry 475 (class 1255 OID 1239281)
-- Name: web_adm_node_overview_select(date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_node_overview_select(p_date date) RETURNS TABLE(name text, id integer, concurrent_calls bigint, billtime bigint, calls_total bigint, calls_failed bigint, online_since timestamp with time zone, is_in_maintenance_mode boolean, last_start timestamp with time zone, cpm bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT DISTINCT ON (node.name, node.id, ns.concurrent_calls, ns.billtime, ns.calls_total, ns.calls_failed,
		node.online_since,
		node.is_in_maintenance_mode, node.last_start )
		node.name, node.id, ns.concurrent_calls::bigint, ns.billtime::bigint, ns.calls_total::bigint, ns.calls_failed::bigint,
		node.online_since as online_since,
		node.is_in_maintenance_mode, node.last_start, COUNT(cdr.*)
		FROM node
		LEFT JOIN view_node_statistic ns ON ns.node_id = node.id AND date = p_date
		LEFT JOIN cdr ON cdr.direction = 'incoming' AND cdr.sqltime BETWEEN NOW() - interval '60 seconds' AND now() AND node.id = cdr.node_id
	WHERE node.enabled = true
	group by node.name, node.id, ns.concurrent_calls, ns.billtime, ns.calls_total, ns.calls_failed,
		node.online_since,
		node.is_in_maintenance_mode, node.last_start
	ORDER BY node.name;
END;
$$;


--
-- TOC entry 476 (class 1255 OID 1239282)
-- Name: web_adm_single_node(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_adm_single_node(p_id integer) RETURNS TABLE(name text, id integer, concurrent_calls bigint, billtime bigint, calls_total bigint, calls_failed bigint, online_since timestamp with time zone, is_in_maintenance_mode boolean, last_start timestamp with time zone, cpm bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT DISTINCT node.name, node.id, SUM(DISTINCT ns.concurrent_calls), SUM(DISTINCT ns.billtime)::bigint, SUM(DISTINCT ns.calls_total), SUM(DISTINCT ns.calls_failed),
		node.online_since as online_since,
		node.is_in_maintenance_mode, node.last_start, COUNT(cdr.*)
		FROM node
		LEFT JOIN node_statistic ns ON ns.node_id = node.id AND date = CURRENT_DATE
		LEFT JOIN cdr ON cdr.direction = 'incoming' AND cdr.sqltime BETWEEN NOW() - interval '60 seconds' AND now() AND node.id = cdr.node_id
	WHERE node.id = p_id
	GROUP BY node.name, node.id, node.online_since, node.is_in_maintenance_mode, node.last_start
	ORDER BY node.name;
END;
$$;


--
-- TOC entry 477 (class 1255 OID 1239283)
-- Name: web_billing_adm_company_cdr_export(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_adm_company_cdr_export(p_date_start date, p_date_end date) RETURNS TABLE(sqltime timestamp with time zone, country text, billid text, caller text, called text, duration bigint, billtime bigint, price_per_min numeric, price_total numeric, price_currency character, customer_id integer, dialcode text, ipaddress text, nodename text, is_mobile boolean, gateway_name text, gateway_ip text, gateway_price_per_min numeric, gateway_price_total numeric, gateway_currency character, customer_name text, gbilltime bigint, customer_dialcode text, gateway_dialcode text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	p_date_end := p_date_end + INTERVAL '1 day' - INTERVAL '1 microsecond';

	RETURN QUERY SELECT DISTINCT ON (a.sqltime, iso3, billid, caller, called, duration, billtime, customer_price_per_min, customer_price_total, customer_currency, customer_id, dnumber, chost, node_name, is_mobile) * FROM (
	SELECT cdr.sqltime, country.iso3, cdr.billid, cdr.caller, cdr.called, cdr.duration, cdr.billtime, cdr.customer_price_per_min, cdr.customer_price_total,
	cdr.customer_currency, cdr.customer_id, CASE WHEN dialcode.number IS NULL THEN '' ELSE dialcode.number END AS dnumber, host(cdr.address) chost, node.name node_name, dialcode.is_mobile,
	gateway.name gateway_name, host(cdrOUT.address) ghost, cdrOUT.gateway_price_per_min, cdrOUT.gateway_price_total, cdrOUT.gateway_currency, customer.name, cdrOUT.billtime gbilltime, customer_price.number AS cnumber,
	gateway_price.number AS gnumber FROM cdr
		LEFT JOIN node ON node.id = cdr.node_id
		LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
		LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
		LEFT JOIN country ON country.id = carrier.country_id
		LEFT JOIN cdr AS cdrOUT ON cdr.billid = cdrOUT.billid AND cdrOUT.direction = 'outgoing'
		LEFT JOIN gateway ON cdrOUT.gateway_id = gateway.id
		LEFT JOIN customer_price ON cdr.customer_price_id = customer_price.id
		LEFT JOIN gateway_price ON cdr.gateway_price_id = gateway_price.id
		LEFT JOIN customer ON cdr.customer_id = customer.id
		WHERE cdr.ended = true
			AND cdr.customer_id IS NOT NULL
			AND cdr.sqltime >= p_date_start AND cdr.sqltime < p_date_end
		) a
		ORDER BY a.sqltime, iso3, billid, caller, called, duration, billtime, customer_price_per_min, customer_price_total, customer_currency, customer_id, dnumber, chost, node_name, is_mobile, gbilltime DESC NULLS LAST;

END;
$$;


--
-- TOC entry 478 (class 1255 OID 1239284)
-- Name: web_billing_adm_gateway_cdr_export(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_adm_gateway_cdr_export(p_date_start date, p_date_end date) RETURNS TABLE(sqltime timestamp with time zone, country text, billid text, caller text, called text, duration bigint, billtime bigint, price_per_min numeric, price_total numeric, price_currency character, customer_id integer, dialcode text, ipaddress text, nodename text, is_mobile boolean, gateway_name text, gateway_ip text, gateway_price_per_min numeric, gateway_price_total numeric, gateway_currency character, customer_name text, customer_dialcode text, gateway_dialcode text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	p_date_end := p_date_end + INTERVAL '1 day' - INTERVAL '1 microsecond';
	
	RETURN QUERY SELECT cdr.sqltime, country.iso3, cdr.billid, cdr.caller, cdr.called, cdr.duration, cdr.billtime, cdrIN.customer_price_per_min, cdrIN.customer_price_total, cdrIN.customer_currency,
	cdrIN.customer_id, CASE WHEN dialcode.number IS NULL THEN '' ELSE dialcode.number END AS dnumber, host(cdrIN.address), node.name, dialcode.is_mobile, gateway.name, host(cdr.address), cdr.gateway_price_per_min,
	cdr.gateway_price_total, cdr.gateway_currency, customer.name, customer_price.number AS cnumber, gateway_price.number AS gnumber FROM cdr
		LEFT JOIN node ON node.id = cdr.node_id
		LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
		LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
		LEFT JOIN country ON country.id = carrier.country_id
		LEFT JOIN cdr AS cdrIN ON cdr.billid = cdrIN.billid AND cdrIN.direction = 'incoming'
		LEFT JOIN customer ON cdrIN.customer_id = customer.id
		LEFT JOIN gateway ON cdr.gateway_id = gateway.id
		LEFT JOIN customer_price ON cdr.customer_price_id = customer_price.id
		LEFT JOIN gateway_price ON cdr.gateway_price_id = gateway_price.id
		WHERE cdr.ended = true
			AND cdr.gateway_id IS NOT NULL
			AND cdr.sqltime >= p_date_start AND cdr.sqltime < p_date_end
		ORDER BY cdr.billid ASC;
END;
$$;


--
-- TOC entry 479 (class 1255 OID 1239285)
-- Name: web_billing_check_customer_prices_not_covered_by_dialcodes(timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_check_customer_prices_not_covered_by_dialcodes(p_effective_date timestamp with time zone) RETURNS TABLE(number text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT customer_price.number FROM customer_price
		WHERE p_effective_date BETWEEN valid_from AND valid_to
			AND customer_price.number NOT IN (SELECT dialcode.number FROM dialcode WHERE p_effective_date BETWEEN valid_from AND valid_to)
		ORDER BY customer_price.number;
END;
$$;


--
-- TOC entry 480 (class 1255 OID 1239286)
-- Name: web_billing_check_gateway_prices_not_covered_by_dialcodes(timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_check_gateway_prices_not_covered_by_dialcodes(p_effective_date timestamp with time zone) RETURNS TABLE(number text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT gateway_price.number FROM gateway_price
		WHERE p_effective_date BETWEEN valid_from AND valid_to
			AND gateway_price.number NOT IN (SELECT dialcode.number FROM dialcode WHERE p_effective_date BETWEEN valid_from AND valid_to)
		ORDER BY gateway_price.number;
END;
$$;


--
-- TOC entry 483 (class 1255 OID 1239287)
-- Name: web_billing_customer_add_price(text, text, text, timestamp with time zone, numeric, integer, character, integer, boolean, boolean, text, integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_add_price(p_country text, p_carrier text, p_number text, p_effective_date timestamp with time zone, p_price numeric, p_customer_id integer, p_currency character, p_pricelist_id integer, p_is_mobile boolean, p_is_complete_list boolean, p_indicator text, p_fbi integer, p_nbi integer) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE i_carrier_id INTEGER;
		i_country_id INTEGER;
BEGIN
	IF p_is_complete_list THEN
		UPDATE customer_price SET valid_to = p_effective_date - INTERVAL '1 microsecond', outdated = TRUE
			WHERE valid_to >= p_effective_date AND substring(number,1,2) = substring(p_number,1,2) AND (number = p_number OR number LIKE CONCAT(p_number, '%')) AND customer_id = p_customer_id AND customer_pricelist_id <> p_pricelist_id AND outdated = FALSE;
	ELSE
		UPDATE customer_price SET valid_to = p_effective_date - INTERVAL '1 microsecond', outdated = TRUE
			WHERE valid_to >= p_effective_date AND number = p_number AND customer_id = p_customer_id AND customer_pricelist_id = p_pricelist_id AND outdated = FALSE;
	END IF;

	INSERT INTO customer_price (customer_id, price, currency, valid_from, valid_to, number, customer_pricelist_id, indicator, first_billing_increment, next_billing_increment)
		VALUES (p_customer_id, p_price, p_currency, p_effective_date, end_date(), p_number, p_pricelist_id, p_indicator, p_fbi, p_nbi);

	PERFORM * FROM web_billing_dialcode_update(p_country, p_carrier, p_number, p_effective_date, p_is_mobile);
END;
$$;


--
-- TOC entry 484 (class 1255 OID 1239288)
-- Name: web_billing_customer_cdr_export(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_cdr_export(p_date_start date, p_date_end date, p_customer_id integer) RETURNS TABLE(sqltime timestamp with time zone, country text, billid text, caller text, called text, duration bigint, billtime bigint, price_per_min numeric, price_total numeric, price_currency character, customer_id integer, dialcode text, ipaddress text, nodename text, is_mobile boolean, gateway_name text, gateway_ip text, gateway_price_per_min numeric, gateway_price_total numeric, gateway_currency character, customer_name text, gateway_billtime bigint, customer_dialcode text, gateway_dialcode text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	p_date_end := p_date_end + INTERVAL '1 day';

	RETURN QUERY SELECT DISTINCT ON (a.sqltime, a.iso3, a.billid, a.caller, a.called, a.duration, a.billtime, a.customer_price_per_min, a.customer_price_total, a.customer_currency, a.customer_id, a.dnumber, a.chost,
			a.node_name, a.is_mobile) * FROM (
		SELECT cdr.sqltime, country.iso3, cdr.billid, cdr.caller, cdr.called, cdr.duration, cdr.billtime, cdr.customer_price_per_min, cdr.customer_price_total,
		cdr.customer_currency, cdr.customer_id, CASE WHEN dialcode.number IS NULL THEN '' ELSE dialcode.number END as dnumber, host(cdr.address) chost, node.name node_name, dialcode.is_mobile,
		gateway.name gateway_name, host(cdrOUT.address) ghost, cdrOUT.gateway_price_per_min, cdrOUT.gateway_price_total, cdrOUT.gateway_currency, customer.name, cdrOUT.billtime gbilltime, customer_price.number AS cnumber,
		gateway_price.number AS gnumber
		FROM cdr
			LEFT JOIN node ON node.id = cdr.node_id
			LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
			LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
			LEFT JOIN country ON country.id = carrier.country_id
			LEFT JOIN cdr AS cdrOUT ON cdr.billid = cdrOUT.billid AND cdrOUT.direction = 'outgoing' AND cdrOUT.sqltime >= p_date_start - INTERVAL '5 minutes' AND cdrOUT.sqltime < p_date_end + INTERVAL '5 minutes'
			LEFT JOIN gateway ON cdrOUT.gateway_id = gateway.id
			LEFT JOIN customer ON cdr.customer_id = customer.id
			LEFT JOIN customer_price ON cdr.customer_price_id = customer_price.id
			LEFT JOIN gateway_price ON cdr.gateway_price_id = gateway_price.id
			WHERE cdr.ended = true
				AND cdr.customer_id = p_customer_id
				AND cdr.sqltime >= p_date_start AND cdr.sqltime < p_date_end
			) a
		ORDER BY a.sqltime, a.iso3, a.billid, a.caller, a.called, a.duration, a.billtime, a.customer_price_per_min, a.customer_price_total, a.customer_currency, a.customer_id, a.dnumber, a.chost, a.node_name, a.is_mobile,
			a.gbilltime DESC NULLS LAST;
END;
$$;


--
-- TOC entry 485 (class 1255 OID 1239289)
-- Name: web_billing_customer_cdr_export_new(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_cdr_export_new(p_date_start date, p_date_end date, p_customer_id integer) RETURNS TABLE(sqltime timestamp with time zone, country text, billid text, caller text, called text, duration bigint, billtime bigint, price_per_min numeric, price_total numeric, price_currency character, customer_id integer, dialcode text, ipaddress text, nodename text, is_mobile boolean, gateway_name text, gateway_ip text, gateway_price_per_min numeric, gateway_price_total numeric, gateway_currency character, customer_name text, gateway_billtime bigint, customer_dialcode text, gateway_dialcode text)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_min_cdrid BIGINT;
				i_max_cdrid BIGINT;
				i_tablename TEXT;
				i_week INT;         
BEGIN
		p_date_end := p_date_end + INTERVAL '1 day';
 
		--i_min_cdrid := (SELECT MIN(id) FROM cdr WHERE sqltime >= p_date_start ORDER BY id DESC);
		--i_max_cdrid := (SELECT MAX(id) FROM cdr WHERE sqltime <= p_date_end ORDER BY id DESC);

		-- get smallest ID
	i_week := EXTRACT(week FROM p_date_start);
	IF i_week < 10 THEN
		i_tablename := CONCAT('cdr_', EXTRACT(year FROM p_date_start), '_0', EXTRACT(week FROM p_date_start));
	ELSE
		i_tablename := CONCAT('cdr_', EXTRACT(year FROM p_date_start), '_', EXTRACT(week FROM p_date_start));
	END IF;
	
	EXECUTE CONCAT('SELECT MIN(id) FROM ONLY ', i_tablename, ' WHERE sqltime >= ''', p_date_start::TEXT, '''::DATE;') INTO i_min_cdrid;
	
	i_week := EXTRACT(week FROM p_date_end);
	IF i_week < 10 THEN
		i_tablename := CONCAT('cdr_', EXTRACT(year FROM p_date_end), '_0', EXTRACT(week FROM p_date_end));
	ELSE
		i_tablename := CONCAT('cdr_', EXTRACT(year FROM p_date_end), '_', EXTRACT(week FROM p_date_end));
	END IF;
	
	EXECUTE CONCAT('SELECT MAX(id) FROM ONLY ', i_tablename, ' WHERE sqltime <= ''', p_date_end::TEXT, '''::DATE;') INTO i_max_cdrid;

	RAISE NOTICE '%', i_min_cdrid;
	RAISE NOTICE '%', i_max_cdrid;

	RAISE EXCEPTION 'hold';
 
		RETURN QUERY SELECT DISTINCT ON (a.sqltime, a.iso3, a.billid, a.caller, a.called, a.duration, a.billtime, a.customer_price_per_min, a.customer_price_total, a.customer_currency, a.customer_id, a.dnumber, a.chost,
						a.node_name, a.is_mobile) * FROM (
				SELECT cdr.sqltime, country.iso3, cdr.billid, cdr.caller, cdr.called, cdr.duration, cdr.billtime, cdr.customer_price_per_min, cdr.customer_price_total,
				cdr.customer_currency, cdr.customer_id, CASE WHEN dialcode.NUMBER IS NULL THEN '' ELSE dialcode.NUMBER END AS dnumber, host(cdr.address) chost, node.name node_name, dialcode.is_mobile,
				gateway.name gateway_name, host(cdrOUT.address) ghost, cdrOUT.gateway_price_per_min, cdrOUT.gateway_price_total, cdrOUT.gateway_currency, customer.name, cdrOUT.billtime gbilltime, customer_price.NUMBER AS cnumber,
				gateway_price.NUMBER AS gnumber
				FROM cdr
						LEFT JOIN node ON node.id = cdr.node_id
						LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
						LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
						LEFT JOIN country ON country.id = carrier.country_id
						LEFT JOIN cdr AS cdrOUT ON cdr.billid = cdrOUT.billid AND cdrOUT.direction = 'outgoing'
						LEFT JOIN gateway ON cdrOUT.gateway_id = gateway.id
						LEFT JOIN customer ON cdr.customer_id = customer.id
						LEFT JOIN customer_price ON cdr.customer_price_id = customer_price.id
						LEFT JOIN gateway_price ON cdr.gateway_price_id = gateway_price.id
						WHERE cdr.ended = TRUE
								AND cdr.customer_id = p_customer_id
								AND cdr.id >= i_min_cdrid AND cdr.id < i_max_cdrid
						) a
				ORDER BY a.sqltime, a.iso3, a.billid, a.caller, a.called, a.duration, a.billtime, a.customer_price_per_min, a.customer_price_total, a.customer_currency, a.customer_id, a.dnumber, a.chost, a.node_name, a.is_mobile,
						a.gbilltime DESC NULLS LAST;
END;
$$;


--
-- TOC entry 486 (class 1255 OID 1239290)
-- Name: web_billing_customer_cdr_export_new2(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_cdr_export_new2(p_date_start date, p_date_end date, p_customer_id integer) RETURNS TABLE(sqltime timestamp with time zone, country text, billid text, caller text, called text, duration bigint, billtime bigint, price_per_min numeric, price_total numeric, price_currency character, customer_id integer, dialcode text, ipaddress text, nodename text, is_mobile boolean, gateway_name text, gateway_ip text, gateway_price_per_min numeric, gateway_price_total numeric, gateway_currency character, customer_name text, gateway_billtime bigint, customer_dialcode text, gateway_dialcode text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	p_date_end := p_date_end + INTERVAL '1 day';

	RETURN QUERY SELECT DISTINCT ON (a.sqltime, a.iso3, a.billid, a.caller, a.called, a.duration, a.billtime, a.customer_price_per_min, a.customer_price_total, a.customer_currency, a.customer_id, a.dnumber, a.chost,
			a.node_name, a.is_mobile) * FROM (
		SELECT cdr.sqltime, country.iso3, cdr.billid, cdr.caller, cdr.called, cdr.duration, cdr.billtime, cdr.customer_price_per_min, cdr.customer_price_total,
		cdr.customer_currency, cdr.customer_id, CASE WHEN dialcode.number IS NULL THEN '' ELSE dialcode.number END as dnumber, host(cdr.address) chost, node.name node_name, dialcode.is_mobile,
		gateway.name gateway_name, host(cdrOUT.address) ghost, cdrOUT.gateway_price_per_min, cdrOUT.gateway_price_total, cdrOUT.gateway_currency, customer.name, cdrOUT.billtime gbilltime, customer_price.number AS cnumber,
		gateway_price.number AS gnumber
		FROM cdr
			LEFT JOIN node ON node.id = cdr.node_id
			LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
			LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
			LEFT JOIN country ON country.id = carrier.country_id
			LEFT JOIN cdr AS cdrOUT ON cdr.billid = cdrOUT.billid AND cdrOUT.direction = 'outgoing' AND cdrOUT.sqltime >= p_date_start AND cdrOUT.sqltime <= p_date_end + INTERVAL '1 hour'
			LEFT JOIN gateway ON cdrOUT.gateway_id = gateway.id
			LEFT JOIN customer ON cdr.customer_id = customer.id
			LEFT JOIN customer_price ON cdr.customer_price_id = customer_price.id
			LEFT JOIN gateway_price ON cdr.gateway_price_id = gateway_price.id
			WHERE cdr.ended = true
				AND cdr.customer_id = p_customer_id
				AND cdr.sqltime >= p_date_start AND cdr.sqltime < p_date_end
			) a
		ORDER BY a.sqltime, a.iso3, a.billid, a.caller, a.called, a.duration, a.billtime, a.customer_price_per_min, a.customer_price_total, a.customer_currency, a.customer_id, a.dnumber, a.chost, a.node_name, a.is_mobile,
			a.gbilltime DESC NULLS LAST;
END;
$$;


--
-- TOC entry 487 (class 1255 OID 1239291)
-- Name: web_billing_customer_cdr_export_summary(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_cdr_export_summary(p_date_start date, p_date_end date, p_customer_id integer) RETURNS TABLE(calls bigint, billtime bigint, price numeric, dialcode text, country text)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY 
	SELECT COUNT(*), SUM(a.billtime)::bigint, SUM(a.price_total), a.dialcode, a.country FROM (
		SELECT wbcce.billtime, CASE WHEN wbcce.customer_dialcode IS NULL OR wbcce.customer_dialcode = '' THEN wbcce.dialcode ELSE wbcce.customer_dialcode END AS dialcode, wbcce.country, wbcce.price_total
		FROM web_billing_customer_cdr_export(p_date_start, p_date_end, p_customer_id) wbcce
	) a GROUP BY a.dialcode, a.country ORDER BY a.dialcode, a.country;
END;
$$;


--
-- TOC entry 445 (class 1255 OID 1239292)
-- Name: web_billing_customer_cdr_summary(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_cdr_summary(p_date_start date, p_date_end date, p_customer_id integer) RETURNS TABLE(calls bigint, bt bigint, pt numeric, pc character)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT count(*), SUM(billtime)::bigint, SUM(price_total), price_currency FROM web_billing_customer_cdr_export(p_date_start, p_date_end, p_customer_id)
		WHERE price_per_min IS NOT NULL
		GROUP BY price_currency
		UNION
		SELECT count(*), SUM(billtime)::bigint, SUM(price_total), price_currency FROM web_billing_customer_cdr_export(p_date_start, p_date_end, p_customer_id)
		WHERE price_per_min IS NULL
		GROUP BY price_currency;
END;
$$;


--
-- TOC entry 455 (class 1255 OID 1239293)
-- Name: web_billing_customer_create_pricelist(timestamp with time zone, character, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_create_pricelist(p_effective_date timestamp with time zone, p_currency character, p_customer_id integer) RETURNS integer
	LANGUAGE plpgsql
	AS $$
	DECLARE i_pricelist_id INTEGER;
BEGIN
	INSERT INTO customer_pricelist (date, currency, customer_id)
		VALUES (p_effective_date, p_currency, p_customer_id)
		RETURNING id INTO i_pricelist_id;
		
	RETURN i_pricelist_id;
END;
$$;


--
-- TOC entry 473 (class 1255 OID 1239294)
-- Name: web_billing_customer_delete_pricelist(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_delete_pricelist(p_pricelist_id integer) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	DELETE FROM customer_price WHERE customer_pricelist_id = p_pricelist_id;
	DELETE FROM customer_pricelist WHERE id = p_pricelist_id;
END;
$$;


--
-- TOC entry 481 (class 1255 OID 1239295)
-- Name: web_billing_customer_disable_previous_pricelist(integer, integer, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_disable_previous_pricelist(p_pricelist_id integer, p_customer_id integer, p_effective_date timestamp with time zone) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE	i_last INTEGER;
BEGIN
	i_last := (SELECT id FROM customer_pricelist WHERE customer_id = p_customer_id AND id <> p_pricelist_id ORDER BY id DESC LIMIT 1);
	
	IF i_last IS NOT NULL THEN
		UPDATE customer_price SET valid_to = p_effective_date - INTERVAL '1 microsecond', outdated = TRUE WHERE customer_pricelist_id = i_last AND outdated = FALSE;
	END IF;
END;
$$;


--
-- TOC entry 488 (class 1255 OID 1239296)
-- Name: web_billing_customer_pricelist_prices(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_customer_pricelist_prices(p_pricelist_id integer) RETURNS TABLE(customer_price_id bigint, customer_id integer, price numeric, currency character, customer_price_valid_from timestamp with time zone, customer_price_valid_te timestamp with time zone, customer_price_created timestamp with time zone, customer_price_number text, carrier_id integer, carrier_name text, country_id integer, iso3 text, is_mobile boolean, indicator text, fbi integer, nbi integer)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT DISTINCT ON (customer_price.id)
		customer_price.id AS customer_price_id,
		customer_price.customer_id,
		customer_price.price,
		customer_price.currency,
		customer_price.valid_from AS customer_price_valid_from,
		customer_price.valid_to AS customer_price_valid_to,
		customer_price.created AS customer_price_created,
		customer_price.number AS customer_price_number,
		carrier.id AS carrier_id,
		carrier.name AS carrier_name,
		country.id AS country_id,
		country.iso3,
		dialcode.is_mobile,
		customer_price.indicator,
		customer_price.first_billing_increment,
		customer_price.next_billing_increment
	FROM customer_price
	LEFT JOIN dialcode ON dialcode.number = customer_price.number
	LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
	LEFT JOIN country ON country.id = carrier.country_id
	WHERE customer_price.customer_pricelist_id = p_pricelist_id
	ORDER BY customer_price.id DESC, dialcode.valid_from DESC, customer_price.number ASC;
END;
$$;


--
-- TOC entry 489 (class 1255 OID 1239297)
-- Name: web_billing_dialcode_add_new(text, text, text, timestamp with time zone, boolean); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_dialcode_add_new(p_country text, p_carrier text, p_dialcode_number text, p_effective_date timestamp with time zone, p_is_mobile boolean) RETURNS void
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_country_id integer;
		i_tmp integer;
		i_carrier_id integer;
BEGIN
	-- CHECK IF COUNTRY NAME IS VALID OR HAS TO BE REPLACED
	i_country_id := (SELECT country_id FROM country_internal_name_fix WHERE wrong_name = p_country);

	IF i_country_id IS NULL THEN
		-- get country id
		i_country_id := (SELECT id FROM country WHERE internal_name = p_country);

		IF i_country_id IS NULL THEN
			INSERT INTO country (display_name, internal_name) VALUES (p_country, p_country) RETURNING id INTO i_country_id;
		END IF;
	END IF;

	i_carrier_id := (SELECT carrier_id FROM carrier_name_fix WHERE wrong_name = p_carrier ORDER BY wrong_name ASC LIMIT 1);

	IF i_carrier_id IS NULL THEN
		-- GET CARRIER ID
		i_carrier_id := (SELECT id FROM carrier WHERE name = p_carrier AND country_id = i_country_id);

		IF i_carrier_id IS NULL THEN
			INSERT INTO carrier (country_id, name) VALUES (i_country_id, p_carrier) RETURNING id INTO i_carrier_id;
		END IF;
	END IF;

	-- ADD DIALCODE
	INSERT INTO dialcode (carrier_id, number, valid_from, valid_to, is_mobile) VALUES (i_carrier_id, p_dialcode_number, p_effective_date, end_date(), p_is_mobile);
END;
$$;


--
-- TOC entry 490 (class 1255 OID 1239298)
-- Name: web_billing_dialcode_end_old(timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_dialcode_end_old(p_effective_date timestamp with time zone) RETURNS void
	LANGUAGE plpgsql
	AS $$
BEGIN
	UPDATE dialcode SET valid_to = p_effective_date - INTERVAL '1 microsecond' WHERE valid_to = end_date();
END;
$$;


--
-- TOC entry 491 (class 1255 OID 1239299)
-- Name: web_billing_dialcode_update(text, text, text, timestamp with time zone, boolean); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_dialcode_update(p_country text, p_carrier text, p_number text, p_effective_date timestamp with time zone, p_is_mobile boolean) RETURNS void
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_country_id integer;
		i_carrier_id integer;
BEGIN
	i_country_id := (SELECT id FROM country WHERE iso3 = p_country);

	i_carrier_id := (SELECT id FROM carrier WHERE name = p_carrier AND country_id = i_country_id);

	IF i_carrier_id IS NULL THEN
		INSERT INTO carrier (country_id, name) VALUES (i_country_id, p_carrier) RETURNING id INTO i_carrier_id;
	END IF;
	
	-- ADD DIALCODE
	PERFORM * FROM dialcode WHERE number = p_number AND carrier_id = i_carrier_id AND is_mobile = p_is_mobile AND p_effective_date >= valid_from AND valid_to = end_date();

	IF NOT FOUND THEN
		UPDATE dialcode SET valid_to = p_effective_date - INTERVAL '1 microsecond' WHERE number = p_number AND p_effective_date >= valid_from AND p_effective_date < valid_to;
		
		INSERT INTO dialcode (carrier_id, number, valid_from, valid_to, is_mobile) VALUES (i_carrier_id, p_number, p_effective_date, end_date(), p_is_mobile);
	END IF;
END;
$$;


--
-- TOC entry 492 (class 1255 OID 1239300)
-- Name: web_billing_gateway_add_price(text, text, text, timestamp with time zone, numeric, integer, character, integer, boolean, boolean, text, integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_add_price(p_country text, p_carrier text, p_number text, p_effective_date timestamp with time zone, p_price numeric, p_gateway_id integer, p_currency character, p_pricelist_id integer, p_is_mobile boolean, p_is_complete_list boolean, p_indicator text, p_fbi integer, p_nbi integer) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE i_carrier_id INTEGER;
		i_country_id INTEGER;
BEGIN
	IF p_is_complete_list THEN
		UPDATE gateway_price SET valid_to = p_effective_date - INTERVAL '1 microsecond', outdated = TRUE
			WHERE valid_to >= p_effective_date AND substring(number,1,2) = substring(p_number,1,2) AND (number = p_number OR number LIKE CONCAT(p_number, '%')) AND gateway_id = p_gateway_id AND gateway_pricelist_id <> p_pricelist_id AND outdated = FALSE;
	ELSE
		UPDATE gateway_price SET valid_to = p_effective_date - INTERVAL '1 microsecond', outdated = TRUE
			WHERE valid_to >= p_effective_date AND number = p_number AND gateway_id = p_gateway_id AND gateway_pricelist_id = p_pricelist_id AND outdated = FALSE;
	END IF;

	INSERT INTO gateway_price (gateway_id, price, currency, valid_from, valid_to, number, gateway_pricelist_id, timeband, indicator, first_billing_increment, next_billing_increment)
		VALUES (p_gateway_id, p_price, p_currency, p_effective_date, end_date(), p_number, p_pricelist_id, 'Flat'::timeband, p_indicator, p_fbi, p_nbi);

	PERFORM * FROM web_billing_dialcode_update(p_country, p_carrier, p_number, p_effective_date, p_is_mobile);
END;
$$;


--
-- TOC entry 493 (class 1255 OID 1239301)
-- Name: web_billing_gateway_cdr_export(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_cdr_export(p_date_start date, p_date_end date, p_gateway_id integer) RETURNS TABLE(sqltime timestamp with time zone, country text, billid text, caller text, called text, duration bigint, billtime bigint, price_per_min numeric, price_total numeric, price_currency character, customer_id integer, dialcode text, ipaddress text, nodename text, is_mobile boolean, gateway_name text, gateway_ip text, gateway_price_per_min numeric, gateway_price_total numeric, gateway_currency character, customer_name text, customer_dialcode text, gateway_dialcode text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	p_date_end := p_date_end + INTERVAL '1 day';

	RETURN QUERY SELECT cdr.sqltime, country.iso3, cdr.billid, cdr.caller, cdr.called, cdr.duration, cdr.billtime, cdrIN.customer_price_per_min, cdrIN.customer_price_total, cdrIN.customer_currency,
	cdrIN.customer_id, CASE WHEN dialcode.number IS NULL THEN '' ELSE dialcode.number END AS dnumber, coalesce(host(cdrIN.address), ''), node.name, dialcode.is_mobile, gateway.name, host(cdr.address),
	cdr.gateway_price_per_min, cdr.gateway_price_total, cdr.gateway_currency, coalesce(customer.name, ''), customer_price.number AS cnumber, gateway_price.number AS gnumber FROM cdr
		LEFT JOIN node ON node.id = cdr.node_id
		LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
		LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
		LEFT JOIN country ON country.id = carrier.country_id
		LEFT JOIN cdr AS cdrIN ON cdr.billid = cdrIN.billid AND cdrIN.direction = 'incoming' AND cdrIN.sqltime >= p_date_start - INTERVAL '5 minutes' AND cdrIN.sqltime < p_date_end + INTERVAL '5 minutes'
		LEFT JOIN customer ON cdrIN.customer_id = customer.id
		LEFT JOIN customer_price ON cdr.customer_price_id = customer_price.id
		LEFT JOIN gateway_price ON cdr.gateway_price_id = gateway_price.id
		INNER JOIN gateway ON gateway.id = cdr.gateway_id
		WHERE cdr.ended = true
			AND gateway.id = p_gateway_id
			AND cdr.sqltime >= p_date_start AND cdr.sqltime < p_date_end
			AND cdr.billtime > 0
		ORDER BY cdr.billid ASC;
END;
$$;


--
-- TOC entry 363 (class 1255 OID 1239302)
-- Name: web_billing_gateway_cdr_summary(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_cdr_summary(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer) RETURNS TABLE(calls bigint, bt bigint, pt numeric, pc character)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, SUM(gateway_price_total), gateway_currency FROM cdr
		WHERE sqltime BETWEEN p_date_start AND p_date_end and gateway_id = p_gateway_id
		GROUP BY gateway_currency;
END;
$$;


--
-- TOC entry 380 (class 1255 OID 1239303)
-- Name: web_billing_gateway_create_pricelist(timestamp with time zone, character, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_create_pricelist(p_effective_date timestamp with time zone, p_currency character, p_gateway_id integer) RETURNS integer
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_pricelist_id integer;
BEGIN
	INSERT INTO gateway_pricelist (date, currency, gateway_id)
		VALUES (p_effective_date, p_currency, p_gateway_id)
		RETURNING id INTO i_pricelist_id;

	RETURN i_pricelist_id;
END;
$$;


--
-- TOC entry 386 (class 1255 OID 1239304)
-- Name: web_billing_gateway_delete_pricelist(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_delete_pricelist(p_pricelist_id integer) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	DELETE FROM gateway_price WHERE gateway_pricelist_id = p_pricelist_id;
	DELETE FROM gateway_pricelist WHERE id = p_pricelist_id;
END;
$$;


--
-- TOC entry 399 (class 1255 OID 1239306)
-- Name: web_billing_gateway_disable_previous_pricelist(integer, integer, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_disable_previous_pricelist(p_pricelist_id integer, p_gateway_id integer, p_effective_date timestamp with time zone) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE	i_last INTEGER;
BEGIN
	i_last := (SELECT id FROM gateway_pricelist WHERE gateway_id = p_gateway_id AND id <> p_pricelist_id ORDER BY id DESC LIMIT 1);
	
	IF i_last IS NOT NULL THEN
		UPDATE gateway_price SET valid_to = p_effective_date - INTERVAL '1 microsecond', outdated = TRUE WHERE gateway_pricelist_id = i_last AND outdated = FALSE;
	END IF;
END;
$$;


--
-- TOC entry 494 (class 1255 OID 1239307)
-- Name: web_billing_gateway_pricelist_prices(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_pricelist_prices(p_pricelist_id integer) RETURNS TABLE(gateway_price_id bigint, gateway_id integer, timeband text, price numeric, currency character, gateway_price_valid_from timestamp with time zone, gateway_price_valid_to timestamp with time zone, gateway_price_created timestamp with time zone, gateway_price_number text, carrier_id integer, carrier_name text, country_id integer, iso3 text, day_of_week smallint, time_from time with time zone, time_to time with time zone, is_mobile boolean, indicator text, fbi integer, nbi integer)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_effective_date TIMESTAMPTZ;
BEGIN
	i_effective_date := (SELECT date FROM gateway_pricelist WHERE id = p_pricelist_id);

	RETURN QUERY SELECT DISTINCT ON (gateway_price.id)
			gateway_price.id AS gateway_price_id,
			gateway_price.gateway_id,
			gateway_price.timeband::text,
			gateway_price.price,
			gateway_price.currency,
			gateway_price.valid_from AS gateway_price_valid_from,
			gateway_price.valid_to AS gateway_price_valid_to,
			gateway_price.created AS gateway_price_created,
			gateway_price.number AS gateway_price_number,
			carrier.id AS carrier_id,
			carrier.name AS carrier_name,
			country.id AS country_id,
			country.iso3,
			gateway_timeband.day_of_week,
			gateway_timeband.time_from,
			gateway_timeband.time_to,
			dialcode.is_mobile,
			gateway_price.indicator,
			gateway_price.first_billing_increment,
			gateway_price.next_billing_increment
		FROM gateway_price
		LEFT JOIN dialcode ON dialcode.number = gateway_price.number
		LEFT JOIN carrier ON carrier.id = dialcode.carrier_id
		LEFT JOIN country ON country.id = carrier.country_id
		LEFT JOIN gateway_timeband ON gateway_timeband.carrier_id = carrier.id AND gateway_timeband.gateway_pricelist_id = p_pricelist_id and i_effective_date between gateway_timeband.valid_from and gateway_timeband.valid_to
		WHERE gateway_price.gateway_pricelist_id = p_pricelist_id
		ORDER BY gateway_price.id DESC, dialcode.valid_from DESC, gateway_price.number ASC;
END;
$$;


--
-- TOC entry 495 (class 1255 OID 1239308)
-- Name: web_billing_gateway_timeband_update(text, text, text, integer, time with time zone, time with time zone, integer, timestamp with time zone, integer, boolean); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_billing_gateway_timeband_update(p_country text, p_carrier text, p_timeband text, p_day_of_week integer, p_time_from time with time zone, p_time_to time with time zone, p_gateway_id integer, p_effective_date timestamp with time zone, p_pricelist_id integer, p_is_complete_list boolean) RETURNS void
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_country_id integer;
		i_carrier_id integer;
BEGIN

	-- CHECK IF COUNTRY NAME IS VALID OR HAS TO BE REPLACED
	i_country_id := (SELECT country_id FROM country_internal_name_fix WHERE wrong_name = p_country);

	IF i_country_id IS NULL THEN
		-- get country id
		i_country_id := (SELECT id FROM country WHERE internal_name = p_country);

		IF i_country_id IS NULL THEN
			INSERT INTO country (display_name, internal_name) VALUES (p_country, p_country) RETURNING id INTO i_country_id;
		END IF;
	END IF;


	i_carrier_id := (SELECT carrier_id FROM carrier_name_fix WHERE wrong_name = p_carrier ORDER BY wrong_name ASC LIMIT 1);

	IF i_carrier_id IS NULL THEN
		-- GET CARRIER ID
		i_carrier_id := (SELECT id FROM carrier WHERE name = p_carrier);

		IF i_carrier_id IS NULL THEN
			INSERT INTO carrier (country_id, name) VALUES (i_country_id, p_carrier) RETURNING id INTO i_carrier_id;
		END IF;
	END IF;
	
	IF p_is_complete_list = FALSE THEN
		UPDATE gateway_timeband SET valid_to = p_effective_date - INTERVAL '1 microsecond'
			WHERE gateway_pricelist_id = p_pricelist_id AND day_of_week = p_day_of_week AND timeband = CAST(p_timeband AS timeband) AND carrier_id = i_carrier_id;
	END IF;
	
	-- INSERT NEW
	INSERT INTO gateway_timeband (carrier_id, gateway_id, day_of_week, timeband, time_from, time_to, valid_from, valid_to, gateway_pricelist_id) VALUES 
		(i_carrier_id, p_gateway_id, p_day_of_week, CAST(p_timeband AS timeband), p_time_from, p_time_to, p_effective_date, end_date(), p_pricelist_id);
END;
$$;


--
-- TOC entry 496 (class 1255 OID 1239309)
-- Name: web_carrier_active_dialcodes(timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_carrier_active_dialcodes(p_date_start timestamp with time zone, p_carrier_id integer) RETURNS TABLE(dialcode text, is_mobile boolean)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT dialcode.number, dialcode.is_mobile FROM dialcode WHERE carrier_id = p_carrier_id AND valid_from <= p_date_start;
END;
$$;


--
-- TOC entry 497 (class 1255 OID 1239310)
-- Name: web_company_active_calls(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_active_calls(p_company_id integer) RETURNS TABLE(billid text, caller text, called text, sqltime timestamp with time zone, country text, address text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT cdr.billid, cdr.caller, cdr2.called, cdr.sqltime, country.iso3, host(cdr.address) FROM cdr
		INNER JOIN cdr AS cdr2 ON cdr2.billid = cdr.billid AND cdr2.id <> cdr.id
		LEFT JOIN dialcode ON dialcode.id = cdr2.dialcode_id
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		INNER JOIN country ON country.id = carrier.country_id
		INNER JOIN customer ON customer.id = cdr.customer_id
		WHERE cdr.ended = false
			AND company_id = p_company_id
		ORDER BY cdr.sqltime DESC;
END;
$$;


--
-- TOC entry 498 (class 1255 OID 1239311)
-- Name: web_company_calls_and_billtime_by_country(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_calls_and_billtime_by_country(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer) RETURNS TABLE(calls bigint, billtime bigint, country text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*), SUM(cdr.billtime)::BIGINT, country.iso3 FROM cdr
		LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		INNER JOIN country ON country.id = carrier.country_id
		WHERE customer_id IN (SELECT id FROM customer WHERE company_id = p_company_id) AND sqltime BETWEEN p_date_start AND p_date_end
		GROUP BY country.iso3;

END;
$$;


--
-- TOC entry 499 (class 1255 OID 1239312)
-- Name: web_company_calls_and_billtime_by_day(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_calls_and_billtime_by_day(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, date date)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, CAST(sqltime AS date) AS date FROM cdr
			INNER JOIN customer ON customer.id = cdr.customer_id
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND customer.company_id = p_company_id
			GROUP BY CAST(sqltime AS date)
			ORDER BY date;

	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) billtime, CAST(sqltime AS date) AS date FROM cdr
					INNER JOIN customer ON customer.id = cdr.customer_id
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND customer.company_id = p_company_id
					GROUP BY CAST(sqltime AS date), DATE_PART('hour', sqltime)
					ORDER BY date
			) a
			GROUP BY a.date;

	END IF;
END;
$$;


--
-- TOC entry 500 (class 1255 OID 1239313)
-- Name: web_company_calls_and_billtime_by_gateway(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_calls_and_billtime_by_gateway(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, gateway text, company text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, gateway.name, company.name FROM cdr
		INNER JOIN customer ON customer.id = cdr.customer_id
		INNER JOIN company ON company.id = customer.company_id
		INNER JOIN gateway ON gateway.id = cdr.gateway_id
		WHERE sqltime BETWEEN p_date_start AND p_date_end
			AND gateway.company_id = p_company_id
		GROUP BY gateway.name, company.name;
END;
$$;


--
-- TOC entry 502 (class 1255 OID 1239314)
-- Name: web_company_calls_and_billtime_by_hour(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_calls_and_billtime_by_hour(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, hour double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
			INNER JOIN customer ON customer.id = cdr.customer_id
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND customer.company_id = p_company_id
			GROUP BY DATE_PART('hour', sqltime)
			ORDER BY hour;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
					INNER JOIN customer ON customer.id = cdr.customer_id
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND customer.company_id = p_company_id
					GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
				ORDER BY hour
			)a
			GROUP BY a.hour;

	END IF;
END;
$$;


--
-- TOC entry 503 (class 1255 OID 1239315)
-- Name: web_company_calls_and_billtime_by_month(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_calls_and_billtime_by_month(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, yearmonth character)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN

		RETURN QUERY SELECT calls, billtime, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
					INNER JOIN customer ON customer.id = cdr.customer_id
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND customer.company_id = p_company_id
					GROUP BY date_trunc('month',sqltime)
				) AS a;

	ELSE


		RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
					INNER JOIN customer ON customer.id = cdr.customer_id
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND customer.company_id = p_company_id
					GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
				) AS a
				GROUP BY period;
		

	END IF;

END;
$$;


--
-- TOC entry 504 (class 1255 OID 1239316)
-- Name: web_company_calls_and_billtime_by_year(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_calls_and_billtime_by_year(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, year double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, DATE_PART('year', sqltime) AS year FROM cdr
			INNER JOIN customer ON customer.id = cdr.customer_id
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND customer.company_id = p_company_id
			GROUP BY DATE_PART('year', sqltime)
			ORDER BY year;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
			SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
				INNER JOIN customer ON customer.id = cdr.customer_id
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND customer.company_id = p_company_id
				GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
				ORDER BY year
			) a
			GROUP BY a.year;

	END IF;
END;
$$;


--
-- TOC entry 505 (class 1255 OID 1239317)
-- Name: web_company_concurrent_calls(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN

	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			INNER JOIN customer ON customer.id = cdr.customer_id
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND company_id  = p_company_id
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(asd), time_start FROM (
		SELECT COUNT(*) asd, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -count(*) asd , time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;
END;
$$;


--
-- TOC entry 506 (class 1255 OID 1239318)
-- Name: web_company_concurrent_calls_by_country(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_concurrent_calls_by_country(p_company_id integer) RETURNS TABLE(iso3 text, current_calls bigint, billtime bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN
	
	RETURN QUERY SELECT country.iso3, COUNT(*), SUM(cdr.billtime)::bigint AS time FROM cdr
		INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		INNER JOIN country ON country.id = carrier.country_id
		INNER JOIN customer ON customer.id = cdr.customer_id
		WHERE cdr.sqltime BETWEEN current_date::timestamptz AND now()
			AND customer.company_id = p_company_id
		GROUP BY country.iso3
		ORDER BY time DESC LIMIT 20;
END;
$$;


--
-- TOC entry 507 (class 1255 OID 1239319)
-- Name: web_company_head_overview(date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_head_overview(p_date date, p_company_id integer) RETURNS TABLE(inward bigint, totalbilltime bigint, avgbilltime bigint, activecalls bigint, failrate integer)
	LANGUAGE plpgsql
	AS $$
	DECLARE
		i_in_total_calls bigint=0;
		i_total_billtime bigint=0;
		i_avg_billtime bigint=0;
		i_active_calls bigint=0;
		i_failrate integer=0;
		i_start timestamp;
		i_end timestamp;
BEGIN
	i_start := p_date;
	i_end := p_date + interval '1 day' - interval '1 microsecond';

	-- IN and OUT
	SELECT SUM(calls_total)::bigint, SUM(billtime)::bigint, (SUM(calls_failed) * 100 / SUM(calls_total))::integer,
		(CASE WHEN SUM(calls_total-calls_failed) = 0 THEN 0 ELSE (SUM(billtime)/SUM(calls_total-calls_failed)) END)::bigint,
		SUM(concurrent_calls)
			INTO i_in_total_calls, i_total_billtime, i_failrate, i_avg_billtime, i_active_calls
		FROM customer_ip_statistic
		INNER JOIN customer_ip ON customer_ip.id = customer_ip_statistic.customer_ip_id
		INNER JOIN customer ON customer.id = customer_ip.customer_id
		WHERE customer.company_id = p_company_id AND customer_ip_statistic.date = p_date;

	IF i_in_total_calls IS NULL THEN
		i_in_total_calls := 0;
		i_total_billtime := 0;
		i_avg_billtime := 0;
		i_active_calls := 0;
		i_failrate :=0;
	END IF;

	RETURN QUERY SELECT i_in_total_calls, i_total_billtime, i_avg_billtime, i_active_calls, i_failrate;
END;
$$;


--
-- TOC entry 474 (class 1255 OID 1239320)
-- Name: web_company_invoice_count(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_invoice_count(p_company_id integer) RETURNS integer
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	RETURN (SELECT COUNT(customer_invoice.id) FROM customer_invoice
		INNER JOIN customer ON customer.id = customer_invoice.customer_id
		WHERE customer.company_id = p_company_id);

END;
$$;


--
-- TOC entry 482 (class 1255 OID 1239321)
-- Name: web_company_total_call_time_and_calls(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_company_total_call_time_and_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_company_id integer) RETURNS TABLE(totalbilltime bigint, totalcalls bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT SUM(billtime)::bigint AS TotalBillTime, COUNT(*) AS TotalCalls FROM cdr
		INNER JOIN customer ON customer.id = cdr.customer_id
		WHERE sqltime BETWEEN p_date_start AND p_date_end
			AND customer.company_id = p_company_id;
END;
$$;


--
-- TOC entry 508 (class 1255 OID 1239322)
-- Name: web_currently_matching_gateway_prices_select(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_currently_matching_gateway_prices_select(p_number text) RETURNS TABLE("Gateway" text, "Number" text, "Price" numeric, "Currency" text, "Timeband" text, "ValidFrom" timestamp with time zone, "ValidTo" timestamp with time zone, "Carrier" text, "IsMobile" boolean)
	LANGUAGE plpgsql
	AS $$
BEGIN

	p_number := (SELECT TRIM(leading '+' FROM p_number));
	p_number := (SELECT TRIM(leading '0' FROM p_number));


	RETURN QUERY SELECT b."Gateway", b."Number", b."Price", b."Currency", b."Timeband", b."ValidFrom", b."ValidTo", carrier.name, dialcode.is_mobile FROM (
			SELECT DISTINCT a."Gateway", a."Number", a."Price", a."Currency", a."Timeband", a."ValidFrom", a."ValidTo" FROM (
				SELECT g.name::TEXT AS "Gateway", gwp.number::TEXT AS "Number", gwp.price AS "Price", gwp.currency::TEXT AS "Currency",
					gwp.timeband::TEXT AS "Timeband", gwp.valid_from AT TIME ZONE 'UTC' AS "ValidFrom", gwp.valid_to AT TIME ZONE 'UTC' AS "ValidTo"
				FROM gateway_price gwp
				INNER JOIN gateway g ON g.id = gwp.gateway_id
				WHERE p_number = substr(gwp.number, 1, length(p_number))
							AND NOW() < gwp.valid_to
				UNION		
				SELECT g.name::TEXT AS "Gateway", gwp.number::TEXT AS "Number", gwp.price AS "Price", gwp.currency::TEXT AS "Currency",
					gwp.timeband::TEXT AS "Timeband", gwp.valid_from AS "ValidFrom", gwp.valid_to AS "ValidTo"
				FROM gateway_price gwp
				INNER JOIN gateway g ON g.id = gwp.gateway_id
				WHERE (gwp.number IN (SELECT * FROM internal_util_number_to_table(p_number))
					OR p_number = substr(gwp.number, 1, length(p_number)))
					AND gwp.valid_to > NOW()) a
				) b
			LEFT JOIN dialcode ON b."Number" = dialcode.number AND NOW() BETWEEN dialcode.valid_from AND dialcode.valid_to
			INNER JOIN carrier ON dialcode.carrier_id = carrier.id
			ORDER BY LENGTH(b."Number") DESC, b."Number" DESC;
	

END;
$$;


--
-- TOC entry 509 (class 1255 OID 1239323)
-- Name: web_customer_billing_active_ratesheet(integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_billing_active_ratesheet(p_customer_id integer) RETURNS TABLE(min_date timestamp with time zone, pricelist_id integer)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT DISTINCT ON (min(valid_from), customer_pricelist_id) min(valid_from), customer_pricelist_id from customer_price 
	WHERE customer_id = p_customer_id AND valid_to > CURRENT_TIMESTAMP
	GROUP BY id
	ORDER BY min;
END;
$$;


--
-- TOC entry 510 (class 1255 OID 1239324)
-- Name: web_customer_calls_and_billtime_by_country(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_calls_and_billtime_by_country(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, country text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*) AS anz, SUM(cdr.billtime)::bigint, country.iso3 FROM cdr
		INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		INNER JOIN country ON country.id = carrier.country_id
		WHERE cdr.sqltime BETWEEN p_date_start AND p_date_end
			AND cdr.customer_id = p_customer_id
		GROUP BY country.iso3
		ORDER BY anz;
END;
$$;


--
-- TOC entry 511 (class 1255 OID 1239325)
-- Name: web_customer_calls_and_billtime_by_day(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_calls_and_billtime_by_day(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, date date)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, CAST(sqltime AS date) AS date FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.customer_id = p_customer_id
			GROUP BY CAST(sqltime AS date)
			ORDER BY date;

	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) billtime, CAST(sqltime AS date) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.customer_id = p_customer_id
					GROUP BY CAST(sqltime AS date), DATE_PART('hour', sqltime)
					ORDER BY date
			) a
			GROUP BY a.date;

	END IF;
END;
$$;


--
-- TOC entry 512 (class 1255 OID 1239326)
-- Name: web_customer_calls_and_billtime_by_hour(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_calls_and_billtime_by_hour(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, hour double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.customer_id = p_customer_id
			GROUP BY DATE_PART('hour', sqltime)
			ORDER BY hour;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
					INNER JOIN customer ON customer.id = cdr.customer_id
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.customer_id = p_customer_id
					GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
				ORDER BY hour
			)a
			GROUP BY a.hour;

	END IF;
END;
$$;


--
-- TOC entry 513 (class 1255 OID 1239327)
-- Name: web_customer_calls_and_billtime_by_month(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_calls_and_billtime_by_month(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, yearmonth character)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN

		RETURN QUERY SELECT calls, billtime, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.customer_id = p_customer_id
					GROUP BY date_trunc('month',sqltime)
				) AS a;

	ELSE


		RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.customer_id = p_customer_id
					GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
				) AS a
				GROUP BY period;
		

	END IF;

END;
$$;


--
-- TOC entry 514 (class 1255 OID 1239328)
-- Name: web_customer_calls_and_billtime_by_year(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_calls_and_billtime_by_year(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, year double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, DATE_PART('year', sqltime) AS year FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.customer_id = p_customer_id
			GROUP BY DATE_PART('year', sqltime)
			ORDER BY year;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
			SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND cdr.customer_id = p_customer_id
				GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
				ORDER BY year
			) a
			GROUP BY a.year;

	END IF;
END;
$$;


--
-- TOC entry 501 (class 1255 OID 1239329)
-- Name: web_customer_cc_candle(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_cc_candle(p_start date, p_end date, p_customer_id integer) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_customer_cc
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day' AND customer_id = p_customer_id AND calls > 5
		GROUP BY datetime::DATE;

END;
$$;


--
-- TOC entry 515 (class 1255 OID 1239330)
-- Name: web_customer_check_for_dialcode_collision(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_check_for_dialcode_collision(p_prefix text) RETURNS text
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE i_dialcode TEXT;
BEGIN

	SELECT number INTO i_dialcode FROM customer_price WHERE SUBSTRING(p_prefix FROM 1 FOR 2) = SUBSTRING(number FROM 1 FOR 2) AND p_prefix LIKE CONCAT(number, '%') LIMIT 1;

	-- PERFORM BOTH CHECKS JUST TO MAKE SURE
	IF i_dialcode IS NULL THEN
		SELECT number INTO i_dialcode FROM gateway_price WHERE SUBSTRING(p_prefix FROM 1 FOR 2) = SUBSTRING(number FROM 1 FOR 2) AND p_prefix LIKE CONCAT(number, '%') LIMIT 1;
	END IF;

	RETURN i_dialcode;
END;
$$;


--
-- TOC entry 516 (class 1255 OID 1239331)
-- Name: web_customer_concurrent(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_concurrent(p_start date, p_end date, p_customer_id integer) RETURNS TABLE("Date" date, "Low" numeric, "Open" numeric, "Line" numeric, "Close" numeric, "High" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT date, SUM(CASE WHEN low IS NULL THEN 0 ELSE low END)::numeric, SUM(open)::numeric, SUM(line)::numeric, SUM(CASE WHEN close IS NULL THEN high ELSE close END)::numeric, SUM(high)::numeric
			FROM history_customer_cc
			WHERE date >= p_start AND date < p_end + INTERVAL '1 day' AND customer_id = p_customer_id
			GROUP BY date
			ORDER BY date;
END;
$$;


--
-- TOC entry 517 (class 1255 OID 1239332)
-- Name: web_customer_concurrent_calls(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN

	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND customer_id  = p_customer_id
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(asd), time_start FROM (
		SELECT COUNT(*) asd, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -count(*) asd , time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;
END;
$$;


--
-- TOC entry 518 (class 1255 OID 1239333)
-- Name: web_customer_country_stats(timestamp with time zone, timestamp with time zone, bigint, integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_country_stats(p_start timestamp with time zone, p_end timestamp with time zone, p_min_length bigint, p_min_calls integer, p_customer_id integer) RETURNS TABLE(id integer, country text, aloc bigint, asr numeric, sum bigint, calls bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT a.country_id, a.iso3, a.aloc::bigint, b.asr, a.sum::bigint, a.calls FROM (
			SELECT country_id, country.iso3, AVG(NULLIF(billtime, 0)) AS aloc, SUM(billtime) as sum, COUNT(*) as calls FROM cdr
				LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				INNER JOIN country ON country.id = carrier.country_id
				WHERE cdr.billtime >= p_min_length AND direction = 'incoming' AND sqltime BETWEEN p_start AND p_end AND cdr.customer_id = p_customer_id
				GROUP BY country_id, country.iso3
				HAVING COUNT(*) > p_min_calls
			) a,
		(
			SELECT a.country_id, 100 * working / total as asr FROM (
				SELECT country_id, COUNT(*)::numeric as working FROM cdr
				INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				WHERE sqltime BETWEEN p_start AND p_end AND billtime >= 1000 AND cdr.customer_id = p_customer_id
				GROUP BY country_id
			) a,
			(
				SELECT country_id, COUNT(*)::numeric as total FROM cdr
				INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				WHERE sqltime BETWEEN p_start AND p_end AND cdr.customer_id = p_customer_id
				GROUP BY country_id
			)b
			WHERE a.country_id = b.country_id
		) b
		WHERE a.country_id = b.country_id;
END;
$$;


--
-- TOC entry 519 (class 1255 OID 1239334)
-- Name: web_customer_cpm_candle(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_cpm_candle(p_start date, p_end date, p_customer_id integer) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_customer_cpm
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day' AND customer_id = p_customer_id
		GROUP BY datetime::DATE;

END;
$$;


--
-- TOC entry 520 (class 1255 OID 1239335)
-- Name: web_customer_reasons(timestamp with time zone, timestamp with time zone, integer, text, bigint, bigint); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_customer_reasons(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_customer_id integer, p_length_type text, p_length_start_val bigint, p_length_end_val bigint) RETURNS TABLE(amount bigint, reason text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_length_type = '' THEN
		RETURN QUERY SELECT COUNT(*), cdr.reason FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end AND customer_id = p_customer_id
			GROUP BY cdr.reason
			ORDER BY COUNT(*) desc;
	END IF;

	IF p_length_type = 'b' THEN
		RETURN QUERY SELECT COUNT(*), cdr.reason FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end AND customer_id = p_customer_id AND billtime BETWEEN p_length_start_val AND p_length_end_val
			GROUP BY cdr.reason
			ORDER BY COUNT(*) desc;
	END IF;

	IF p_length_type = 'd' THEN
		RETURN QUERY SELECT COUNT(*), cdr.reason FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end AND customer_id = p_customer_id AND duration BETWEEN p_length_start_val AND p_length_end_val
			GROUP BY cdr.reason
			ORDER BY COUNT(*) desc;
	END IF;
END;
$$;


--
-- TOC entry 521 (class 1255 OID 1239336)
-- Name: web_dialcodes_matching_pattern(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_dialcodes_matching_pattern(p_pattern text) RETURNS TABLE("ISO3" text, "Carrier" text, "Dialcode" text, "IsMobile" boolean)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT co.iso3::TEXT AS "ISO3", ca.name::TEXT AS "Carrier", d.number::TEXT AS "Number", d.is_mobile AS "IsMobile" FROM dialcode d
		INNER JOIN carrier AS ca ON ca.id = d.carrier_id
		INNER JOIN country AS co ON co.id = ca.country_id
		WHERE d.number ~ p_pattern AND d.valid_to >= now() ORDER BY LENGTH(d.number) DESC;

END;
$$;


--
-- TOC entry 522 (class 1255 OID 1239337)
-- Name: web_gateway_calls_and_billtime_by_country(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_calls_and_billtime_by_country(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, country text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*) AS anz, SUM(cdr.billtime)::bigint, country.iso3 FROM cdr
		INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
		INNER JOIN carrier ON carrier.id = dialcode.carrier_id
		INNER JOIN country ON country.id = carrier.country_id
		WHERE cdr.sqltime BETWEEN p_date_start AND p_date_end
			AND cdr.gateway_id = p_gateway_id
		GROUP BY country.iso3
		ORDER BY anz;
END;
$$;


--
-- TOC entry 523 (class 1255 OID 1239338)
-- Name: web_gateway_calls_and_billtime_by_day(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_calls_and_billtime_by_day(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, date date)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, CAST(sqltime AS date) AS date FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.gateway_id = p_gateway_id
			GROUP BY CAST(sqltime AS date)
			ORDER BY date;

	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) billtime, CAST(sqltime AS date) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.gateway_id = p_gateway_id
					GROUP BY CAST(sqltime AS date), DATE_PART('hour', sqltime)
					ORDER BY date
			) a
			GROUP BY a.date;

	END IF;
END;
$$;


--
-- TOC entry 524 (class 1255 OID 1239339)
-- Name: web_gateway_calls_and_billtime_by_hour(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_calls_and_billtime_by_hour(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, hour double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.gateway_id = p_gateway_id
			GROUP BY DATE_PART('hour', sqltime)
			ORDER BY hour;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.gateway_id = p_gateway_id
					GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
				ORDER BY hour
			)a
			GROUP BY a.hour;

	END IF;
END;
$$;


--
-- TOC entry 525 (class 1255 OID 1239340)
-- Name: web_gateway_calls_and_billtime_by_month(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_calls_and_billtime_by_month(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, yearmonth character)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN

		RETURN QUERY SELECT calls, billtime, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.gateway_id = p_gateway_id
					GROUP BY date_trunc('month',sqltime)
				) AS a;

	ELSE


		RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.gateway_id = p_gateway_id
					GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
				) AS a
				GROUP BY period;
		

	END IF;

END;
$$;


--
-- TOC entry 526 (class 1255 OID 1239341)
-- Name: web_gateway_calls_and_billtime_by_year(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_calls_and_billtime_by_year(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, year double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, DATE_PART('year', sqltime) AS year FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.gateway_id = p_gateway_id
			GROUP BY DATE_PART('year', sqltime)
			ORDER BY year;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
			SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND cdr.gateway_id = p_gateway_id
				GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
				ORDER BY year
			) a
			GROUP BY a.year;

	END IF;
END;
$$;


--
-- TOC entry 527 (class 1255 OID 1239342)
-- Name: web_gateway_cc_candle(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_cc_candle(p_start date, p_end date, p_gateway_id integer) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_gateway_cc
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day' AND gateway_id = p_gateway_id AND calls > 5
		GROUP BY datetime::DATE;

END;
$$;


--
-- TOC entry 528 (class 1255 OID 1239343)
-- Name: web_gateway_concurrent(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_concurrent(p_start date, p_end date, p_gateway_id integer) RETURNS TABLE("Date" date, "Low" numeric, "Open" numeric, "Line" numeric, "Close" numeric, "High" numeric)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT date, SUM(CASE WHEN low IS NULL THEN 0 ELSE low END)::numeric, SUM(open)::numeric, SUM(line)::numeric, SUM(CASE WHEN close IS NULL THEN high ELSE close END)::numeric, SUM(high)::numeric
			FROM history_gateway_cc
			WHERE date >= p_start AND date < p_end + INTERVAL '1 day' AND gateway_id = p_gateway_id
			GROUP BY date
			ORDER BY date;
END;
$$;


--
-- TOC entry 529 (class 1255 OID 1239344)
-- Name: web_gateway_concurrent_calls(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN

	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND gateway_id  = p_gateway_id
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(asd), time_start FROM (
		SELECT COUNT(*) asd, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -count(*) asd , time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;
END;
$$;


--
-- TOC entry 530 (class 1255 OID 1239345)
-- Name: web_gateway_country_stats(timestamp with time zone, timestamp with time zone, bigint, integer, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_country_stats(p_start timestamp with time zone, p_end timestamp with time zone, p_min_length bigint, p_min_calls integer, p_gateway_id integer) RETURNS TABLE(id integer, country text, aloc bigint, asr numeric, sum bigint, calls bigint)
	LANGUAGE plpgsql
	AS $$
BEGIN
	RETURN QUERY SELECT a.country_id, a.iso3, a.aloc::bigint, b.asr, a.sum::bigint, a.calls FROM (
			SELECT country_id, country.iso3, AVG(NULLIF(billtime, 0)) AS aloc, SUM(billtime) as sum, COUNT(*) as calls FROM cdr
				LEFT JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				INNER JOIN country ON country.id = carrier.country_id
				WHERE cdr.billtime >= p_min_length AND direction = 'outgoing' AND sqltime BETWEEN p_start AND p_end AND cdr.gateway_id = p_gateway_id
				GROUP BY country_id, iso3
				HAVING COUNT(*) > p_min_calls
			) a,
		(
			SELECT a.country_id, 100 * working / total as asr FROM (
				SELECT country_id, COUNT(*)::numeric as working FROM cdr
				INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				WHERE sqltime BETWEEN p_start AND p_end AND billtime >= 1000 AND cdr.gateway_id = p_gateway_id
				GROUP BY country_id
			) a,
			(
				SELECT country_id, COUNT(*)::numeric as total FROM cdr
				INNER JOIN dialcode ON dialcode.id = cdr.dialcode_id
				INNER JOIN carrier ON carrier.id = dialcode.carrier_id
				WHERE sqltime BETWEEN p_start AND p_end AND cdr.gateway_id = p_gateway_id
				GROUP BY country_id
			)b
			WHERE a.country_id = b.country_id
		) b
		WHERE a.country_id = b.country_id;
END;
$$;


--
-- TOC entry 531 (class 1255 OID 1239346)
-- Name: web_gateway_cpm_candle(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_cpm_candle(p_start date, p_end date, p_gateway_id integer) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT MIN(calls), AVG(calls) - STDDEV(calls), AVG(calls) + STDDEV(calls), MAX(calls), datetime::DATE FROM history_gateway_cpm
		WHERE datetime >= p_start AND datetime < p_end + INTERVAL '1 day' AND gateway_id = p_gateway_id
		GROUP BY datetime::DATE;

END;
$$;


--
-- TOC entry 532 (class 1255 OID 1239347)
-- Name: web_gateway_reasons(timestamp with time zone, timestamp with time zone, integer, text, bigint, bigint); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_gateway_reasons(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_gateway_id integer, p_length_type text, p_length_start_val bigint, p_length_end_val bigint) RETURNS TABLE(count bigint, reason text)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_length_type = '' THEN
		RETURN QUERY SELECT COUNT(*), cdr.reason FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end AND gateway_id = p_gateway_id
			GROUP BY cdr.reason
			ORDER BY COUNT(*) desc;
	END IF;

	IF p_length_type = 'b' THEN
		RETURN QUERY SELECT COUNT(*), cdr.reason FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end AND gateway_id = p_gateway_id AND billtime BETWEEN p_length_start_val AND p_length_end_val
			GROUP BY cdr.reason
			ORDER BY COUNT(*) desc;
	END IF;

	IF p_length_type = 'd' THEN
		RETURN QUERY SELECT COUNT(*), cdr.reason FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end AND gateway_id = p_gateway_id AND duration BETWEEN p_length_start_val AND p_length_end_val
			GROUP BY cdr.reason
			ORDER BY COUNT(*) desc;
	END IF;
END;
$$;


--
-- TOC entry 533 (class 1255 OID 1239348)
-- Name: web_history_customer_billtime_avg_select(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_history_customer_billtime_avg_select(p_start date, p_end date) RETURNS TABLE(billtime bigint, calls bigint, date date, name text, id integer)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT AVG(a.billtime)::bigint, AVG(a.calls)::bigint, a.date::DATE, ''::TEXT, 0 FROM (
				SELECT SUM(hcb.billtime)::bigint billtime, SUM(hcb.calls) calls, hcb.date::DATE date, hcb.customer_id FROM history_customer_billtime hcb
					WHERE hcb.date >= p_start AND hcb.date <= p_end
					GROUP BY customer_id, hcb.date::DATE) a
			GROUP BY a.date::DATE;
END;
$$;


--
-- TOC entry 534 (class 1255 OID 1239349)
-- Name: web_history_customer_billtime_select(date, date, integer[]); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_history_customer_billtime_select(p_start date, p_end date, p_customers integer[]) RETURNS TABLE(billtime bigint, calls bigint, date date, name text, id integer)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT SUM(hcb.billtime)::bigint, SUM(hcb.calls), hcb.date::DATE, customer.name, customer.ID FROM history_customer_billtime hcb
		INNER JOIN customer ON customer.id = hcb.customer_id
		WHERE hcb.date >= p_start AND hcb.date <= p_end AND hcb.customer_id = ANY(p_customers)
		GROUP BY customer.name, customer.id, hcb.date::DATE;
END;
$$;


--
-- TOC entry 535 (class 1255 OID 1239350)
-- Name: web_history_gateway_billtime_avg_select(date, date); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_history_gateway_billtime_avg_select(p_start date, p_end date) RETURNS TABLE(billtime bigint, calls bigint, date date, name text, id integer)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT AVG(a.billtime)::bigint, AVG(a.calls)::bigint, a.date::DATE, ''::TEXT, 0 FROM (
				SELECT SUM(hgb.billtime)::bigint billtime, SUM(hgb.calls) calls, hgb.date::DATE date, hgb.gateway_id FROM history_gateway_billtime hgb
					WHERE hgb.date >= p_start AND hgb.date <= p_end
					GROUP BY gateway_id, hgb.date::DATE) a
			GROUP BY a.date::DATE;
END;
$$;


--
-- TOC entry 536 (class 1255 OID 1239351)
-- Name: web_history_gateway_billtime_select(date, date, integer[]); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_history_gateway_billtime_select(p_start date, p_end date, p_gateways integer[]) RETURNS TABLE(billtime bigint, calls bigint, date date, name text, id integer)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN
	RETURN QUERY SELECT SUM(hgb.billtime)::bigint, SUM(hgb.calls), hgb.date::DATE, gateway.name, gateway.ID FROM history_gateway_billtime hgb
		INNER JOIN gateway ON gateway.id = hgb.gateway_id
		WHERE hgb.date >= p_start AND hgb.date <= p_end AND hgb.gateway_id = ANY(p_gateways)
		GROUP BY gateway.name, gateway.id, hgb.date::DATE;
END;
$$;


--
-- TOC entry 537 (class 1255 OID 1239352)
-- Name: web_node_call_and_billtime_by_gateway(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_call_and_billtime_by_gateway(p_date_start timestamp with time zone, p_date_end timestamp with time zone) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, gateway text, company text)
	LANGUAGE plpgsql
	AS $$
BEGIN

	RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, gateway.name, company.name FROM cdr
		INNER JOIN gateway ON gateway.id = cdr.gateway_id
		INNER JOIN company ON company.id = gateway.company_id
		WHERE sqltime BETWEEN p_date_start AND p_date_end
		GROUP BY  gateway.name, company.name;
END;
$$;


--
-- TOC entry 539 (class 1255 OID 1239353)
-- Name: web_node_calls_and_billtime_by_day(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_calls_and_billtime_by_day(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_node_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, date date)
	LANGUAGE plpgsql
	AS $$
BEGIN
	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, CAST(sqltime AS date) AS date FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.node_id = p_node_id
			GROUP BY sqltime::date
			ORDER BY date;

	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.date FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) billtime, CAST(sqltime AS date) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.node_id = p_node_id
					GROUP BY sqltime::date, DATE_PART('hour', sqltime)
					ORDER BY date
			) a
			GROUP BY a.date;

	END IF;
END;
$$;


--
-- TOC entry 540 (class 1255 OID 1239354)
-- Name: web_node_calls_and_billtime_by_hour(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_calls_and_billtime_by_hour(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_node_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, hour double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*), SUM(billtime)::bigint, DATE_PART('hour', sqltime) AS hour FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.node_id = p_node_id
			GROUP BY DATE_PART('hour', sqltime)
			ORDER BY hour;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.hour FROM (
				SELECT COUNT(*) AS anz, SUM(billtime) AS billtime, DATE_PART('hour', sqltime) AS hour FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.node_id = p_node_id
					GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime), DATE_PART('day', sqltime), DATE_PART('hour', sqltime)
				ORDER BY hour
			)a
			GROUP BY a.hour;

	END IF;
END;
$$;


--
-- TOC entry 541 (class 1255 OID 1239355)
-- Name: web_node_calls_and_billtime_by_month(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_calls_and_billtime_by_month(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_node_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, yearmonth character)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN

		RETURN QUERY SELECT calls, billtime, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime)::bigint billtime, date_trunc('month',sqltime) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.node_id = p_node_id
					GROUP BY date_trunc('month',sqltime)
				) AS a;

	ELSE


		RETURN QUERY SELECT AVG(calls)::bigint, AVG(billtime)::bigint, CAST(extract(year from date) || '-' || extract(month from date) AS character(7)) AS period FROM (
					SELECT COUNT(*) AS calls, SUM(billtime) billtime, date_trunc('month',sqltime) AS date FROM cdr
					WHERE sqltime BETWEEN p_date_start AND p_date_end
						AND cdr.node_id = p_node_id
					GROUP BY date_trunc('month',sqltime), date_trunc('day',sqltime)
				) AS a
				GROUP BY period;
		

	END IF;

END;
$$;


--
-- TOC entry 542 (class 1255 OID 1239356)
-- Name: web_node_calls_and_billtime_by_year(timestamp with time zone, timestamp with time zone, integer, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_calls_and_billtime_by_year(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_node_id integer, p_accumulation text) RETURNS TABLE(totalcalls bigint, totalbilltime bigint, year double precision)
	LANGUAGE plpgsql
	AS $$
BEGIN

	IF p_accumulation = 'Sum' THEN
	
		RETURN QUERY SELECT COUNT(*) AS totalcalls, SUM(billtime)::bigint totalbilltime, DATE_PART('year', sqltime) AS year FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND cdr.node_id = p_node_id
			GROUP BY DATE_PART('year', sqltime)
			ORDER BY year;
	ELSE
		RETURN QUERY SELECT AVG(anz)::bigint, AVG(billtime)::bigint, a.year FROM (
			SELECT COUNT(*) AS anz, SUM(billtime) billtime, DATE_PART('year', sqltime) AS year FROM cdr
				WHERE sqltime BETWEEN p_date_start AND p_date_end
					AND cdr.node_id = p_node_id
				GROUP BY DATE_PART('year', sqltime), DATE_PART('month', sqltime)
				ORDER BY year
			) a
			GROUP BY a.year;

	END IF;
END;
$$;


--
-- TOC entry 543 (class 1255 OID 1239357)
-- Name: web_node_cc_candle(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_cc_candle(p_start date, p_end date, p_node_id integer) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT * FROM web_adm_customer_cc_candle(p_start, p_end);

END;
$$;


--
-- TOC entry 544 (class 1255 OID 1239358)
-- Name: web_node_concurrent_calls(timestamp with time zone, timestamp with time zone, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_concurrent_calls(p_date_start timestamp with time zone, p_date_end timestamp with time zone, p_node_id integer) RETURNS TABLE(amount numeric, the_time numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN

	CREATE TEMP TABLE tmp_store (time_start numeric(3,1), time_end numeric(3,1)) ON COMMIT DROP;

	INSERT INTO tmp_store
	SELECT 	extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) AS time_start,
			extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1) AS time_end FROM cdr
			WHERE sqltime BETWEEN p_date_start AND p_date_end
				AND node_id  = p_node_id
				AND extract('hour' from sqltime) + (round((extract('minute' from date_trunc('minute', sqltime)) / 60)::numeric, 1))::numeric(3,1) < extract('hour' from sqltime_end) + (round((extract('minute' from date_trunc('minute', cdr.sqltime_end)) / 60)::numeric, 1))::numeric(3,1);


	RETURN QUERY SELECT SUM(asd), time_start FROM (
		SELECT COUNT(*) asd, time_start FROM (
				SELECT time_start FROM tmp_store
			) a
			GROUP BY time_start
		UNION
		SELECT -count(*) asd , time_end FROM (
				SELECT time_end FROM tmp_store
			) a
			GROUP BY time_end
		) b
		GROUP BY time_start
		ORDER BY time_start;
END;
$$;


--
-- TOC entry 545 (class 1255 OID 1239359)
-- Name: web_node_cpm_candle(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_cpm_candle(p_start date, p_end date, p_node_id integer) RETURNS TABLE(low integer, open numeric, close numeric, high integer, date date)
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	RETURN QUERY SELECT * FROM web_adm_customer_cpm_candle(p_start, p_end);

END;
$$;


--
-- TOC entry 546 (class 1255 OID 1239360)
-- Name: web_node_customer(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_customer(p_start date, p_end date, p_node_id integer) RETURNS TABLE(name text, amount bigint, billtime bigint)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_start TIMESTAMPTZ;
		i_end TIMESTAMPTZ;
BEGIN
	i_start := p_start::TIMESTAMPTZ;
	i_end := p_end::TIMESTAMPTZ + INTERVAL '1 day' - INTERVAL '1 microsecond';

	RETURN QUERY SELECT customer.name, count(*), sum(cdr.billtime)::bigint from cdr
			INNER JOIN customer ON customer.id = cdr.customer_id
			WHERE sqltime BETWEEN i_start AND i_end
				AND node_id = p_node_id
			GROUP BY customer.name
			ORDER BY customer.name;
END;
$$;


--
-- TOC entry 538 (class 1255 OID 1239361)
-- Name: web_node_gateway(date, date, integer); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_node_gateway(p_start date, p_end date, p_node_id integer) RETURNS TABLE(name text, amount bigint, billtime bigint)
	LANGUAGE plpgsql
	AS $$
	DECLARE i_start TIMESTAMPTZ;
		i_end TIMESTAMPTZ;
BEGIN
	i_start := p_start::TIMESTAMPTZ;
	i_end := p_end::TIMESTAMPTZ + INTERVAL '1 day' - INTERVAL '1 microsecond';

	RETURN QUERY SELECT gateway.name, count(*), sum(cdr.billtime)::bigint from cdr
			INNER JOIN gateway ON gateway.id = cdr.gateway_id
			WHERE sqltime BETWEEN i_start AND i_end
				AND node_id = p_node_id
			GROUP BY gateway.name
			ORDER BY gateway.name;
END;
$$;


--
-- TOC entry 547 (class 1255 OID 1239362)
-- Name: web_test_regularexpression(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION web_test_regularexpression(p_expression text) RETURNS void
	LANGUAGE plpgsql STABLE STRICT
	AS $$
BEGIN

	PERFORM 'abc' ~ p_expression;

END;
$$;


--
-- TOC entry 548 (class 1255 OID 1239363)
-- Name: yate_account_init_select(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_account_init_select(p_node text) RETURNS TABLE(description text, account text, operation text, protocol text, username text, "interval" text, authname text, password text, number text, domain text, registrar text, localaddress text, outbound text, gatekeeper text, gateway text, server text)
	LANGUAGE plpgsql STABLE STRICT
	AS $$
	DECLARE
		i_node_id integer;
BEGIN

	-- get node id
	i_node_id := (SELECT id FROM node WHERE name = p_node);

	RETURN QUERY SELECT gateway_account.description, gateway_account.account,
		'login'::text,
		gateway_account.protocol, 
		gateway_account.username, 
		gateway_account.interval::text, 
		gateway_account.authname,
		gateway_account.pw, 
		gateway_account.number,
		gateway_account.domain,
		gateway_account.registrar, 
		gateway_account.local_address,
		gateway_account.outbound,
		gateway_account.gatekeeper,
		gateway_account.gateway,
		gateway_account.server
		FROM gateway_account WHERE gateway_account.node_id = i_node_id AND gateway_account.enabled = true;

END;
$$;


--
-- TOC entry 549 (class 1255 OID 1239364)
-- Name: yate_account_status_update(text, text, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_account_status_update(p_status text, p_account text, p_node text, p_reason text) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE
		i_node_id integer;
BEGIN

	-- get node id
	i_node_id := (SELECT id FROM node WHERE name = p_node);

	UPDATE gateway_account SET status = p_status, reason = p_reason WHERE account = p_account AND node_id = i_node_id;

END;
$$;


--
-- TOC entry 550 (class 1255 OID 1239365)
-- Name: yate_account_timer_update(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_account_timer_update(p_node text) RETURNS TABLE(description text, account text, operation text, protocol text, username text, "interval" text, authname text, password text, number text, domain text, registrar text, localaddress text, outbound text, gatekeeper text, gateway text, server text)
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE
		i_node_id integer;
BEGIN

	-- get node id
	i_node_id := (SELECT id FROM node WHERE name = p_node);

	UPDATE gateway_account SET last_polled = current_timestamp WHERE node_id = i_node_id;

	RETURN QUERY SELECT gateway_account.description, gateway_account.account,
		CASE WHEN gateway_account.enabled THEN 'login'::text ELSE 'logout'::text END,
		gateway_account.protocol, 
		gateway_account.username, 
		gateway_account.interval::text, 
		gateway_account.authname,
		gateway_account.pw,
		gateway_account.number,
		gateway_account.domain,
		gateway_account.registrar, 
		gateway_account.local_address,
		gateway_account.outbound,
		gateway_account.gatekeeper,
		gateway_account.gateway,
		gateway_account.server
		FROM gateway_account WHERE gateway_account.node_id = i_node_id AND gateway_account.modified = true
		UNION
		SELECT gateway_account.description, gateway_account.account,
		'logout'::text,
		gateway_account.protocol, 
		gateway_account.username, 
		gateway_account.interval::text, 
		gateway_account.authname,
		gateway_account.pw,
		gateway_account.number,
		gateway_account.domain,
		gateway_account.registrar, 
		gateway_account.local_address,
		gateway_account.outbound,
		gateway_account.gatekeeper,
		gateway_account.gateway,
		gateway_account.server
		FROM gateway_account WHERE gateway_account.node_old_id = i_node_id;

	UPDATE gateway_account SET modified = false WHERE gateway_account.node_id = i_node_id;
	UPDATE gateway_account SET node_old_id = NULL WHERE gateway_account.node_old_id = i_node_id;
END;
$$;


--
-- TOC entry 551 (class 1255 OID 1239366)
-- Name: yate_cdr_initialize_update(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_cdr_initialize_update(p_node text) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
	DECLARE
		i_node_id integer;
BEGIN

	i_node_id := (SELECT id FROM node WHERE name = p_node);

	INSERT INTO protocol (action, summary, detail, actor_id, created)
		VALUES ('NodeStart', 'Starting Node: ' || p_node, '', null, now());

	UPDATE node SET last_start = now() WHERE id = i_node_id;

	UPDATE cdr SET ended = true WHERE ended = false AND node_id = i_node_id;

END;
$$;


--
-- TOC entry 552 (class 1255 OID 1239367)
-- Name: yate_cdr_upsert(text, numeric, text, text, text, text, text, text, numeric, numeric, numeric, text, text, text, text, text, text, text, text, text, text, text, text, text, text, boolean, text, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_cdr_upsert(p_node text, p_yatetime numeric, p_billid text, p_chan text, p_address text, p_caller text, p_callername text, p_called text, p_billtime numeric, p_ringtime numeric, p_duration numeric, p_direction text, p_status text, p_reason text, p_error text, p_cause_q931 text, p_gateway_id text, p_gateway_account_id text, p_gateway_ip_id text, p_format text, p_formats text, p_customer_id text, p_rtp_addr text, p_rtp_port text, p_trackingid text, p_ended boolean, p_techcalled text, p_prerouteduration text, p_routeduration text, p_cachehit text, p_customer_ip_id text, p_cause_sip text, p_sip_server text, p_sip_user_agent text, p_sip_x_asterisk_hangupcause text, p_sip_x_asterisk_hangupcausecode text) RETURNS void
	LANGUAGE plpgsql
	AS $$
		DECLARE
			i_address inet = NULL;
			i_port integer = 5060;
			i_billtime bigint;
			i_ringtime bigint;
			i_duration bigint;
			i_gateway_id integer = NULL;
			i_gateway_ip_id integer = NULL;
			i_gateway_account_id integer = NULL;
			i_customer_id integer = NULL;
			i_customer_ip_id integer = NULL;
			i_rtp_addr CHARACTER VARYING(15)=NULL;
			i_rtp_port INTEGER=NULL;
			i_trackingid TEXT;
			i_record_ended BOOL;
			i_sqltime_end TIMESTAMPTZ;
			i_dialcode_id INTEGER;
			i_node_id INTEGER;
			i_prerouteduration BIGINT=NULL;
			i_routeduration BIGINT=NULL;
			i_cachehit BOOL=NULL;
			i_id BIGINT;
			i_sip_user_agent TEXT;
BEGIN
	i_node_id := (SELECT id FROM node WHERE name = p_node);
	
	IF isdigit(p_prerouteduration) THEN
		i_prerouteduration := p_prerouteduration::BIGINT;
	END IF;
	
	IF isdigit(p_routeduration) THEN
		i_routeduration := p_routeduration::BIGINT;
	END IF;
	
	IF p_cachehit = 'true' THEN
		i_cachehit := true;
	ELSE
		i_cachehit := false;
	END IF;

	IF p_sip_server IS NULL OR p_sip_server = '' THEN
		i_sip_user_agent := p_sip_user_agent;
	ELSE
		i_sip_user_agent := p_sip_server;
	END IF;
	
	-- CONVERT TIME TO MS
	i_billtime := (p_billtime * 1000)::BIGINT;
	i_ringtime := (p_ringtime * 1000)::BIGINT;
	i_duration := (p_duration * 1000)::BIGINT;
	
	-- SPLIT ADDRESS AND PORT
	IF (p_address IS NOT NULL AND p_address <> '') THEN
		i_address := SUBSTRING(p_address FROM 0 FOR POSITION(':' in p_address))::inet;
		i_port := SUBSTRING(p_address FROM POSITION(':' in p_address) + 1)::integer;
	END IF;

	-- CUSTOMER
	IF p_direction = 'incoming' THEN

		IF p_customer_id IS NOT NULL AND p_customer_id <> '' THEN
			i_customer_id := p_customer_id::INTEGER;
		ELSE
			IF p_customer_ip_id IS NULL OR p_customer_ip_id = '' THEN
				--SELECT customer_id, id INTO i_customer_id, i_customer_ip_id FROM customer_ip WHERE address = i_address AND enabled = true AND deleted = false ORDER BY id ASC LIMIT 1;
				SELECT sender_ip_id, sender_id
					INTO i_customer_ip_id, i_customer_id
					FROM internal_resolve_customer(i_address, p_called);
			ELSE
				i_customer_ip_id := p_customer_ip_id::INTEGER;
			END IF;
		END IF;

		IF i_customer_ip_id IS NULL THEN
			IF p_customer_ip_id IS NOT NULL AND p_customer_ip_id <> '' THEN
				i_customer_ip_id := p_customer_ip_id::INTEGER;
			ELSE
				--SELECT id INTO i_customer_ip_id FROM customer_ip WHERE address = i_address AND enabled = true AND deleted = false ORDER BY id ASC LIMIT 1;
				SELECT sender_ip_id
					INTO i_customer_ip_id
					FROM internal_resolve_customer(i_address, p_called);
			END IF;
		END IF;
		
		i_gateway_id := NULL;		
	END IF;
	
	-- GATEWAY
	IF p_direction = 'outgoing' AND p_gateway_id <> '' THEN

		IF p_gateway_id IS NULL OR p_gateway_id = '' THEN
			i_gateway_id := (SELECT gateway_id FROM gateway_ip WHERE address = i_address AND enabled = true ORDER BY id ASC LIMIT 1);
		ELSE
			i_gateway_id := p_gateway_id::INTEGER;
		END IF;
		
		IF isdigit(p_gateway_account_id) THEN
			i_gateway_account_id := p_gateway_account_id::INTEGER;
			
			IF (host(i_address) <> (SELECT server FROM gateway_account WHERE id = i_gateway_account_id)) AND 0 = (SELECT COUNT(*) FROM gateway_account_resolved WHERE address = i_address AND gateway_account_id = i_gateway_account_id) THEN
				INSERT INTO gateway_account_resolved (address, gateway_account_id)
					VALUES (i_address, i_gateway_account_id);
			END IF;
			
		ELSEIF isdigit(p_gateway_ip_id) THEN
			i_gateway_ip_id := p_gateway_ip_id::INTEGER;
							
			IF (host(i_address) <> (SELECT address FROM gateway_ip WHERE id = i_gateway_ip_id)) AND 0 = (SELECT COUNT(*) FROM gateway_ip_resolved WHERE address = i_address AND gateway_ip_id = i_gateway_ip_id) THEN
				INSERT INTO gateway_ip_resolved (address, gateway_ip_id)
					VALUES (i_address, i_gateway_ip_id);
			END IF;
			
		END IF;
					
		i_customer_id := NULL;
		
	END IF;
	
	-- RTP ADDR
	IF p_rtp_addr <> '' THEN
		i_rtp_addr := p_rtp_addr;
	END IF;
	
	-- RTP PORT
	IF isdigit(p_rtp_port) THEN
		i_rtp_port := p_rtp_port::INTEGER;
	END IF;
	
	-- TRACKING ID
	IF p_trackingid = '' OR p_trackingid IS NULL THEN
		i_trackingid := p_billid;
	ELSE
		i_trackingid := p_trackingid;
	END IF;
	
	
	-- GET DIALCODE ID
	SELECT id INTO i_dialcode_id FROM dialcode WHERE number IN (SELECT * FROM internal_util_number_to_table(internal_util_clean_number(p_called))) AND NOW() BETWEEN valid_from AND valid_to
	ORDER BY LENGTH(number) DESC LIMIT 1;

	LOOP
		-- GET STATE OF RECORD
		SELECT id, ended INTO i_id, i_record_ended FROM cdr WHERE node_id = i_node_id AND billid = p_billid AND chan = p_chan FOR UPDATE;
		
		
		-- CHECK IF RECORD IS PRESENT AND STILL OPEN
		IF i_id IS NOT NULL THEN
			-- CHECK IF OPEN AND UPDATE (ELSE DO NOTHING BECAUSE FINALIZE ALREADY RUN)
			IF i_record_ended = false THEN

				-- UPDATE RECORD
				UPDATE cdr SET duration = i_duration, billtime = i_billtime, ringtime = i_ringtime, status = p_status, reason = p_reason, ended = p_ended,
					format = p_format, formats = p_formats, sqltime_end = (sqltime + p_duration * INTERVAL '1 second'), cause_q931 = p_cause_q931, error = p_error, preroute_duration = i_prerouteduration,
					route_duration = i_routeduration, cache_hit = i_cachehit, customer_id = i_customer_id, customer_ip_id = i_customer_ip_id, gateway_id = i_gateway_id, trackingid = i_trackingid,
					rtp_port = i_rtp_port, rtp_addr = i_rtp_addr, gateway_ip_id = i_gateway_ip_id, gateway_account_id = i_gateway_account_id, caller = p_caller, callername = p_callername, called = p_called,
					dialcode_id = i_dialcode_id, address = i_address, port = i_port, direction = p_direction::direction, cause_sip = p_cause_sip, sip_user_agent = i_sip_user_agent,
					sip_x_asterisk_hangupcause = p_sip_x_asterisk_hangupcause, sip_x_asterisk_hangupcausecode = p_sip_x_asterisk_hangupcausecode
				WHERE id = i_id;
				
			END IF;

			RETURN;			
		ELSE -- NOT FOUND, INSERT
		
			-- CALC END
			i_sqltime_end := ('1970-01-01'::timestamptz + (p_yatetime::text || ' seconds')::interval + p_duration * INTERVAL '1 second');

			BEGIN
				-- TRY TO INSERT
				INSERT INTO cdr (sqltime, node_id, yatetime, billid, chan, address, port, caller, callername, called, billtime, ringtime, duration, direction, status, reason, gateway_id, gateway_account_id,
					gateway_ip_id, format, formats, customer_id, rtp_addr, rtp_port, trackingid, sqltime_end, tech_called, dialcode_id, cause_q931, error, preroute_duration, route_duration, cache_hit,
					customer_ip_id, ended, cause_sip, sip_user_agent, sip_x_asterisk_hangupcause, sip_x_asterisk_hangupcausecode)
					VALUES ('1970-01-01'::timestamptz + (p_yatetime::text || ' seconds')::interval, i_node_id, p_yatetime, p_billid, p_chan, i_address, i_port, p_caller, p_callername, p_called, i_billtime,
					i_ringtime, i_duration, p_direction::direction, p_status, p_reason, i_gateway_id, i_gateway_account_id, i_gateway_ip_id, p_format, p_formats, i_customer_id, i_rtp_addr, i_rtp_port, i_trackingid,
					i_sqltime_end, p_techcalled, i_dialcode_id, p_cause_q931, p_error, i_prerouteduration, i_routeduration, i_cachehit, i_customer_ip_id, p_ended, p_cause_sip, i_sip_user_agent,
					p_sip_x_asterisk_hangupcause, p_sip_x_asterisk_hangupcausecode);
				RETURN;
			EXCEPTION WHEN unique_violation THEN
				-- DO NOTHING, LOOP AND TRY THE UPDATE AGAIN
			END;
		END IF;
	END LOOP;
END;
	$$;


--
-- TOC entry 553 (class 1255 OID 1239369)
-- Name: yate_enginetimer_update(text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_enginetimer_update(p_node text) RETURNS void
	LANGUAGE plpgsql STRICT
	AS $$
BEGIN

	UPDATE node SET online = true, online_since = current_timestamp WHERE name = p_node;

END;
$$;


--
-- TOC entry 554 (class 1255 OID 1239370)
-- Name: yate_preroute(text, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_preroute(p_address text, p_node text, p_called text) RETURNS view_preroute_result
	LANGUAGE plpgsql STABLE STRICT
	AS $$
DECLARE
	i_preroute_result view_preroute_result%rowtype;
BEGIN	
	SELECT INTO i_preroute_result * FROM internal_preroute(p_address, p_node, p_called);
	
	RETURN i_preroute_result;
END;
$$;


--
-- TOC entry 555 (class 1255 OID 1239371)
-- Name: yate_route(text, text, text, text, text, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: domain; Owner: -
--

CREATE FUNCTION yate_route(p_error text, p_reason text, p_node_id text, p_context text, p_sender text, p_sender_id text, p_caller text, p_callername text, p_called text, p_sip_trackingid text, p_sip_gatewayid text, p_sccustomerid text, p_sccustomeripid text, p_billid text) RETURNS view_route_result
	LANGUAGE plpgsql
	AS $$
	DECLARE i_node_id INTEGER;
		i_route_result view_route_result%rowtype;
BEGIN
	SELECT INTO i_route_result * FROM view_route_result;

	i_node_id := p_node_id::INTEGER;
	--INSERT INTO node_routing_log(action,node_id) VALUES('route', i_node_id);
	
	SELECT INTO i_route_result * FROM internal_route(p_error, p_reason, p_node_id, p_context, p_sender, p_sender_id, p_caller, p_callername, p_called, p_sip_trackingid, p_sip_gatewayid, p_sccustomerid, p_sccustomeripid, p_billid);

	RETURN i_route_result;
	
END;
$$;


-- Completed on 2016-04-28 17:08:22

--
-- PostgreSQL database dump complete
--

