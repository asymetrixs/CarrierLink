-- Table: domain.cdr

DROP FUNCTION domain.delete_me_cron_new_cdr_table_delete_me();


DROP TABLE domain.cdr;

CREATE TABLE domain.cdr
(
    id bigserial NOT NULL,
    sqltime timestamp NOT NULL DEFAULT now(),
    yatetime numeric(14,3) NOT NULL,
    billid text COLLATE pg_catalog."default" NOT NULL,
    chan text COLLATE pg_catalog."default",
    address inet,
    port integer,
    caller text COLLATE pg_catalog."default",
    callername text COLLATE pg_catalog."default",
    called text COLLATE pg_catalog."default",
    status text COLLATE pg_catalog."default",
    reason text COLLATE pg_catalog."default",
    ended boolean NOT NULL DEFAULT false,
    gateway_account_id integer,
    gateway_ip_id integer,
    customer_ip_id integer,
    gateway_price_per_min numeric,
    gateway_price_total numeric,
    gateway_currency character(3) COLLATE pg_catalog."default",
    gateway_price_id bigint,
    customer_price_per_min numeric,
    customer_price_total numeric,
    customer_currency character(3) COLLATE pg_catalog."default",
    customer_price_id bigint,
    node_id integer NOT NULL,
    billed_on timestamp,
    gateway_id integer,
    customer_id integer,
    format text COLLATE pg_catalog."default",
    formats text COLLATE pg_catalog."default",
    sqltime_end timestamp,
    tech_called text COLLATE pg_catalog."default",
    rtp_port integer,
    trackingid text COLLATE pg_catalog."default",
    billtime bigint,
    ringtime bigint,
    duration bigint,
    direction domain.direction NOT NULL,
    cause_q931 text COLLATE pg_catalog."default",
    preroute_duration bigint,
    route_duration bigint,
    error text COLLATE pg_catalog."default",
    cause_sip text COLLATE pg_catalog."default",
    sip_user_agent text COLLATE pg_catalog."default",
    sip_x_asterisk_hangupcause text COLLATE pg_catalog."default",
    sip_x_asterisk_hangupcausecode text COLLATE pg_catalog."default",
    responsetime integer,
    routing_processing_time integer,
    routing_waiting_time integer,
    rtp_forward boolean,
    rtp_packets_sent bigint,
    rtp_octets_sent bigint,
    rtp_packets_received bigint,
    rtp_octets_received bigint,
    rtp_packet_loss bigint,
    rtp_address inet,
    dialcode_master_id integer,
    routing_tree jsonb,
    CONSTRAINT fk_c_dm FOREIGN KEY (dialcode_master_id)
        REFERENCES domain.dialcode_master (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_cdr_customer FOREIGN KEY (customer_id)
        REFERENCES domain.customer (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_cdr_customer_ip FOREIGN KEY (customer_ip_id)
        REFERENCES domain.customer_ip (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_cdr_customer_price FOREIGN KEY (customer_price_id)
        REFERENCES domain.customer_price (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_cdr_gateway FOREIGN KEY (gateway_id)
        REFERENCES domain.gateway (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_cdr_gateway_account FOREIGN KEY (gateway_account_id)
        REFERENCES domain.gateway_account (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_cdr_gateway_ip FOREIGN KEY (gateway_ip_id)
        REFERENCES domain.gateway_ip (id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_cdr_gateway_price FOREIGN KEY (gateway_price_id)
        REFERENCES domain.gateway_price (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_cdr_node FOREIGN KEY (node_id)
        REFERENCES domain.node (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
PARTITION BY LIST (DATE_PART('year', sqltime))
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE domain.cdr
    OWNER to postgres;

GRANT ALL ON TABLE domain.cdr TO postgres;




CREATE INDEX ix_pk_cdr
    ON domain.cdr USING btree
    (id);

-- Index: ix_cdr_cp

-- DROP INDEX domain.ix_cdr_cp;

CREATE INDEX ix_cdr_cp
    ON domain.cdr USING btree
    (customer_price_id)
    TABLESPACE pg_default    WHERE customer_price_id IS NOT NULL
;

-- Index: ix_cdr_customer

-- DROP INDEX domain.ix_cdr_customer;

CREATE INDEX ix_cdr_customer
    ON domain.cdr USING btree
    (customer_id)
    TABLESPACE pg_default;

-- Index: ix_cdr_dm

-- DROP INDEX domain.ix_cdr_dm;

CREATE INDEX ix_cdr_dm
    ON domain.cdr USING btree
    (dialcode_master_id)
    TABLESPACE pg_default;

-- Index: ix_cdr_ended_sqltime

-- DROP INDEX domain.ix_cdr_ended_sqltime;

CREATE INDEX ix_cdr_ended_sqltime
    ON domain.cdr USING btree
    (ended, sqltime DESC)
    TABLESPACE pg_default;

-- Index: ix_cdr_gateway

-- DROP INDEX domain.ix_cdr_gateway;

CREATE INDEX ix_cdr_gateway
    ON domain.cdr USING btree
    (gateway_id)
    TABLESPACE pg_default;

-- Index: ix_cdr_gp

-- DROP INDEX domain.ix_cdr_gp;

CREATE INDEX ix_cdr_gp
    ON domain.cdr USING btree
    (gateway_price_id)
    TABLESPACE pg_default    WHERE gateway_price_id IS NOT NULL
;

-- Index: ix_cdr_node_ended_for_initialize

-- DROP INDEX domain.ix_cdr_node_ended_for_initialize;

CREATE INDEX ix_cdr_node_ended_for_initialize
    ON domain.cdr USING btree
    (node_id, ended)
    TABLESPACE pg_default    WHERE ended = false
;

-- Index: ix_cdr_sqltime_customer

-- DROP INDEX domain.ix_cdr_sqltime_customer;

CREATE INDEX ix_cdr_sqltime_customer
    ON domain.cdr USING btree
    (sqltime, customer_id)
    TABLESPACE pg_default;

-- Index: ix_cdr_sqltime_gateway

-- DROP INDEX domain.ix_cdr_sqltime_gateway;

CREATE INDEX ix_cdr_sqltime_gateway
    ON domain.cdr USING btree
    (sqltime, gateway_id)
    TABLESPACE pg_default;

-- Index: ix_cdr_sqltime_gatewayidnotnull

-- DROP INDEX domain.ix_cdr_sqltime_gatewayidnotnull;

CREATE INDEX ix_cdr_sqltime_gatewayidnotnull
    ON domain.cdr USING btree
    (sqltime)
    TABLESPACE pg_default    WHERE gateway_id IS NOT NULL
;

-- Index: ix_cdr_sqltime_sqltime_end

-- DROP INDEX domain.ix_cdr_sqltime_sqltime_end;

CREATE INDEX ix_cdr_sqltime_sqltime_end
    ON domain.cdr USING btree
    (sqltime, sqltime_end)
    TABLESPACE pg_default;

-- Index: uq_cdr_billid_chan_node

-- DROP INDEX domain.uq_cdr_billid_chan_node;

CREATE INDEX ix_cdr_billid_chan_node
    ON domain.cdr USING btree
    (billid COLLATE pg_catalog."default", chan COLLATE pg_catalog."default", node_id)
    TABLESPACE pg_default;

-- Trigger: t_statistic_update

-- DROP TRIGGER t_statistic_update ON domain.cdr;

CREATE TRIGGER t_statistic_update
    AFTER INSERT OR UPDATE 
    ON domain.cdr
    FOR EACH ROW
    EXECUTE PROCEDURE domain.tr_statistic_update();

ALTER TABLE domain.cdr
    DISABLE TRIGGER t_statistic_update;


-- DEFAULT CDR TABLE
CREATE TABLE cdr_default PARTITION OF cdr DEFAULT;


-- FUNCTION: domain.cron_new_cdr_table()

-- DROP FUNCTION domain.cron_new_cdr_table();
DROP FUNCTION domain.cron_new_cdr_table();

CREATE OR REPLACE FUNCTION domain.cron_new_cdr_table(
	)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
	DECLARE i_week INT=1;
		i_new_table_name TEXT;
		i_index_def TEXT;
		i_constraint_def TEXT;
		i_trigger_def TEXT;
		i_date_start DATE;
		i_date_end DATE;
		i_count INT=1;
		i_start_date DATE = CURRENT_DATE - INTERVAL '1 week';
		i_record RECORD;
BEGIN
    CREATE TEMP TABLE cdr_tables (name text, year int, week int, sweek text, is_default boolean ) ON COMMIT DROP;

	set search_path = domain;
	WHILE EXTRACT(dow FROM i_start_date) <> 1 LOOP
		i_start_date := i_start_date + INTERVAL '1 day';
	END LOOP;

	--ADD CDR TABLE FOR PLUS 7 WEEKS
	WHILE i_count <= 7 LOOP
	
		i_date_start := (i_start_date + i_count * INTERVAL '1 week')::DATE;
		i_date_end := (i_date_start + INTERVAL '1 week')::DATE;
--raise notice 'start: %', i_date_start;
--raise notice 'end: %', i_date_end;
		i_week := EXTRACT(week FROM i_date_start);

        -- ALWAYS CHECK FOR DEFAULT TABLES - FOR SIMPLICITY
        i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_end));
        INSERT INTO cdr_tables (name, year, week, sweek, is_default)
                VALUES (i_new_table_name, EXTRACT(year from i_date_end), 0, 0::text, true);

		IF i_week < 10 THEN
			IF i_week = 1 AND EXTRACT(year FROM i_date_start) <> EXTRACT(year FROM i_date_end) THEN
				i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_end), '_0', i_week::text);
                INSERT INTO cdr_tables (name, year, week, sweek, is_default)
                    VALUES (i_new_table_name, EXTRACT(year from i_date_end), i_week, i_week::text, false);
			ELSE
				i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_start), '_0', i_week::text);
                INSERT INTO cdr_tables (name, year, week, sweek, is_default)
                    VALUES (i_new_table_name, EXTRACT(year from i_date_start), i_week, i_week::text, false);
			END IF;
		ELSE
			i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_start), '_', i_week::text);
            INSERT INTO cdr_tables (name, year, week, sweek, is_default)
                VALUES (i_new_table_name, EXTRACT(year from i_date_start), i_week, i_week::text, false);
		END IF;
		
		i_count := i_count + 1;
	END LOOP;
--raise notice 'week: %', i_week;
--raise notice 'tbn: %', i_new_table_name;

    FOR i_record IN (SELECT * FROM cdr_tables ORDER BY cdr_tables.name ASC) LOOP

		-- CHECK IF EXISTS
		PERFORM * FROM pg_catalog.pg_class WHERE relname::TEXT = i_record.name;

		IF FOUND THEN
			CONTINUE;
		END IF;

		-- CREATE TABLE
        IF i_record.is_default THEN
            EXECUTE CONCAT('CREATE TABLE ', i_record.name, ' PARTITION OF cdr FOR VALUES IN (', i_record.year, ') PARTITION BY LIST (DATE_PART(''week'', sqltime)) WITH (OIDS=FALSE);');
        ELSE
		    EXECUTE CONCAT('CREATE TABLE ', i_record.name, ' PARTITION OF cdr_', i_record.year, ' FOR VALUES IN (', i_record.week, ') WITH (OIDS=FALSE);');
        END IF;

		-- ADD PERMISSIONS
		EXECUTE CONCAT('GRANT SELECT ON TABLE ', i_record.name, ' TO webuser_group;');
		EXECUTE CONCAT('GRANT SELECT, UPDATE, INSERT, TRIGGER ON TABLE ', i_record.name, ' TO cl_controller_group;');

	END LOOP;
END;
$BODY$;

ALTER FUNCTION domain.cron_new_cdr_table()
    OWNER TO postgres;

select * from cron_new_cdr_table();
