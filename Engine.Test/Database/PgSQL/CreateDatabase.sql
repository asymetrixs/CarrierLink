SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3713 (class 1262 OID 25858)
-- Name: voip; Type: DATABASE; Schema: -; Owner: postgres
--
CREATE DATABASE voiptest WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';

ALTER DATABASE voiptest SET search_path=domain,public;
ALTER DATABASE voiptest OWNER TO postgres;

GRANT CONNECT, TEMP ON DATABASE voiptest TO cl_controller_group;