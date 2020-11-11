------------------------------------------------------
-- YATE CONFIG
------------------------------------------------------

--COPYPARAMS IN YATE CONFIG (remove anything old!)
--
--clnodeid
--clcustomerid
--clcustomeripid
--cltrackingid
--clprocessingtime
--clcustomerpriceid
--clcustomerpricepermin
--clcustomercurrency
--cldialcodemasterid
--clwaitingtime
--clgatewayid
--clgatewayaccountid
--clgatewayipid
--cltechcalled
--clgatewaypriceid
--clgatewaypricepermin
--clgatewaycurrency

--CHECK: rtp_forward ?is it there automatically?



-- "(dash)(dash)GO" IS USED TO SPLIT THE COMMANDS AND RUN THEM ONE AFTER THE OTHER, PostgreSQL will ignore it on copy+paste


--- FOR TESTING
--insert into controller (id, name) values (1, 'CS1');
--insert into node (id, name, online, enabled, deleted, is_in_maintenance_mode, cs_ip, cs_port) values (30, 'test', true, true, false, false, '127.0.0.1', 15001);
--insert into controller_connection (controller_id, node_id, status, enabled, auto_connect) values(1, 30, 0, true, true);
---


------------------------------------------------------
-- SQL COMMANDS
------------------------------------------------------

-- DROP COLUMNS / FUNCTIONS / VIEWS
SET search_path = domain;

-- DROP all triggers for price calculation on cdr-tables
DO
$$
	DECLARE i_table TEXT;
		i_price_up TEXT = 't_price_update';
		i_year INT = 2012;
		i_week INT = 0;
BEGIN
	WHILE i_year <= DATE_PART('year'::TEXT, CURRENT_TIMESTAMP) LOOP

		WHILE i_week < 55 LOOP 

			IF i_week < 10 THEN
				i_table = CONCAT('cdr_', i_year, '_0', i_week);
			ELSE
				i_table = CONCAT('cdr_', i_year, '_', i_week);
			END IF;
			
			PERFORM * FROM pg_catalog.pg_class WHERE relname::TEXT = i_table;

			IF FOUND THEN

				EXECUTE CONCAT('DROP TRIGGER ', i_price_up, ' ON domain.', i_table, ';');
				raise notice '%', CONCAT('DROP TRIGGER ', i_price_up, ' ON domain.', i_table, ';');

			END IF;

			i_week := i_week + 1;
		END LOOP;

		i_week := 0;
		i_year = i_year + 1;
	END LOOP;
END;
$$;

--GO

ALTER TABLE ONLY gateway
    DROP CONSTRAINT fk_gateway_number_modification_group;
--GO 

ALTER TABLE ONLY gateway
    ADD CONSTRAINT fk_gateway_number_modification_group FOREIGN KEY (number_modification_group_id) REFERENCES number_modification_group(id);

ALTER TABLE domain.gateway DROP COLUMN add_zeros;		-- was not used, is covered by NumberModificationGroup
ALTER TABLE domain.gateway_account DROP COLUMN server;	-- never used
ALTER TABLE domain.cdr DROP COLUMN cache_hit;			-- not used anymore
DROP FUNCTION tr_price_update() CASCADE;
--GO
DROP VIEW view_cache_route;
DROP TABLE cache_route;
--GO
ALTER TABLE context ADD COLUMN timeout INT NOT NULL DEFAULT 7200000; -- VALUE IN MILLISECONDS
ALTER TABLE cdr ADD COLUMN responsetime INT;
ALTER TABLE cdr ADD COLUMN routing_processing_time INT;
ALTER TABLE cdr ADD COLUMN routing_waiting_time INT;
ALTER TABLE cdr ADD COLUMN rtp_forward BOOLEAN;
ALTER TABLE domain.incorrect_callername RENAME commentary TO comment;
ALTER TABLE route ADD COLUMN ignore_missing_rate BOOLEAN DEFAULT false NOT NULL;
ALTER TABLE route ADD COLUMN fallback_to_lcr BOOLEAN DEFAULT false NOT NULL;
ALTER TABLE customer DROP COLUMN all_destinations;
ALTER TABLE context ADD COLUMN enable_lcr_without_rate BOOLEAN NOT NULL DEFAULT FALSE;
--GO
------------------------------------------------------
-- ADD COLUMNS / TABLES / PROCEDURES / FUNCTIONS
-- IP und Port ueber den sich Core.Service per TCP mit Yate verbinden kann, exmodule
------------------------------------------------------

ALTER TABLE domain.node ADD COLUMN cs_ip TEXT DEFAULT '127.0.0.1';
ALTER TABLE domain.node ADD COLUMN cs_port INT DEFAULT 10000;
--GO

CREATE TABLE domain.controller
(
	id serial NOT NULL PRIMARY KEY,
	name TEXT NOT NULL,
	online BOOLEAN NOT NULL DEFAULT false,
	last_seen TIMESTAMPTZ,
	enabled BOOLEAN NOT NULL DEFAULT true,
	created TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE domain.controller_log
(
	id serial NOT NULL PRIMARY KEY,
	controller_id INTEGER NOT NULL,
	action TEXT NOT NULL,
	created TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_csl_cs FOREIGN KEY (controller_id) REFERENCES domain.controller (id)
);

--GO
CREATE INDEX ix_csl_csid ON domain.controller_log (controller_id);

CREATE TABLE domain.controller_connection
(
	id serial NOT NULL,
	controller_id INTEGER NOT NULL,
	node_id INTEGER NOT NULL,
	status INTEGER NOT NULL DEFAULT 0,
	enabled BOOLEAN NOT NULL DEFAULT true,
	auto_connect BOOLEAN NOT NULL DEFAULT false,
	created TIMESTAMPTZ DEFAULT NOW(),
	modified TIMESTAMPTZ DEFAULT NOW(),
	CONSTRAINT fk_csc_cs FOREIGN KEY (controller_id) REFERENCES domain.controller (id),
	CONSTRAINT pk_controller_connection PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_controller_connection ON domain.controller_connection (controller_id, node_id);
CREATE INDEX ix_controller_connection_nodeid ON domain.controller_connection (node_id);
--GO

CREATE OR REPLACE FUNCTION domain.controller_startup (p_controller TEXT)
	RETURNS INT AS
$$
	DECLARE i_controller_id INT;
BEGIN

	SELECT id INTO i_controller_id FROM controller WHERE name = p_controller;
	
	IF i_controller_id IS NOT NULL THEN
		UPDATE controller_connection SET status = 0 WHERE controller_id = i_controller_id;
	END IF;

	RETURN i_controller_id;
END;
$$
LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION domain.controller_shutdown (p_controller_id INT)
	RETURNS void AS
$$
BEGIN

	UPDATE controller SET online = false, last_seen = NOW() WHERE id = p_controller_id;

END;
$$
LANGUAGE plpgsql STRICT VOLATILE;

--GO

CREATE OR REPLACE FUNCTION domain.controller_is_alive (p_controller_id INT)
	RETURNS void AS
$$
BEGIN
	UPDATE controller SET last_seen = NOW(), online = true WHERE id = p_controller_id;
END;
$$
LANGUAGE plpgsql VOLATILE STRICT;


CREATE OR REPLACE FUNCTION domain.controller_log (p_controller_id INT, p_action TEXT)
	RETURNS void AS
$$
BEGIN

	INSERT INTO controller_log (controller_id, action) VALUES (p_controller_id, p_action);

END;
$$
LANGUAGE plpgsql VOLATILE STRICT;

--GO

CREATE OR REPLACE FUNCTION domain.controller_connections (p_controller_id INT)
	RETURNS TABLE (node_id INT, status INT, auto_connect BOOLEAN) AS
$$
BEGIN

	RETURN QUERY SELECT csc.node_id, csc.status, csc.auto_connect FROM controller_connection csc
		WHERE controller_id = p_controller_id AND enabled = true;

END;
$$
LANGUAGE plpgsql STRICT STABLE;

CREATE OR REPLACE FUNCTION domain.controller_connection_status_update(p_controller_id INT, p_node_id INT, p_status INT)
	RETURNS void AS
$$
BEGIN

	UPDATE controller_connection SET status = p_status, modified = now() WHERE controller_id = p_controller_id AND node_id = p_node_id;

END;
$$
LANGUAGE plpgsql STRICT VOLATILE;

--GO

CREATE OR REPLACE FUNCTION domain.controller_cdr_upsert(p_nodeid INT, p_sqltime TIMESTAMPTZ, p_yatetime BIGINT, p_billid TEXT, p_chan TEXT, p_address INET,
	p_port INT, p_caller TEXT, p_callername TEXT, p_called TEXT, p_ringtime BIGINT, p_billtime BIGINT, p_duration BIGINT, p_direction TEXT,
	p_status TEXT, p_reason TEXT, p_error TEXT, p_dialcodemasterid INT, p_causeq931 TEXT, p_causesip TEXT, p_gatewayid INT, p_gatewayaccountid INT,
	p_gatewayipid INT, p_format TEXT, p_formats TEXT, p_customerid INT, p_customeripid INT, p_rtpaddress INET, p_rtpport INT, p_trackingid TEXT,
	p_ended BOOLEAN, p_techcalled TEXT, p_gatewayrateid BIGINT, p_gatewayratepermin NUMERIC(13,8), p_gatewayratetotal NUMERIC(13,8),
	p_gatewaycurrency CHAR(3), p_customerrateid BIGINT, p_customerratepermin NUMERIC(13,8), p_customerratetotal NUMERIC(13,8),
	p_customercurrency CHAR(3), p_routingwaitingtime INT, p_routingprocessingtime INT, p_sipuseragent TEXT, p_sipxasteriskhangupcause TEXT,
	p_sipxasteriskhangupcausecode TEXT, p_rtpforward BOOLEAN, p_routingtree JSONB) RETURNS void AS
$$
	DECLARE
		i_id BIGINT;
		i_record_ended BOOLEAN;
BEGIN
	LOOP
		-- GET STATE OF RECORD
		SELECT id, ended INTO i_id, i_record_ended FROM cdr WHERE node_id = p_nodeid AND billid = p_billid AND chan = p_chan FOR UPDATE;
		
		-- CHECK IF RECORD IS PRESENT AND STILL OPEN
		IF i_id IS NOT NULL THEN
			-- CHECK IF OPEN AND UPDATE (ELSE DO NOTHING BECAUSE FINALIZE ALREADY RUN)
			IF i_record_ended = false THEN

				-- UPDATE RECORD
				UPDATE cdr SET address = p_address, port = p_port, caller = p_caller, callername = p_callername, called = p_called, ringtime = p_ringtime, billtime = p_billtime,
					duration = p_duration, responsetime = p_duration - p_ringtime - p_billtime, status = p_status, reason = p_reason, error = p_error, dialcode_master_id = p_dialcodemasterid, cause_q931 = p_causeq931, cause_sip = p_causesip,
					gateway_id = p_gatewayid, gateway_account_id = p_gatewayaccountid, gateway_ip_id = p_gatewayipid, format = p_format, formats = p_formats,
					customer_id = p_customerid, customer_ip_id = p_customeripid, rtp_address = p_rtpaddress, rtp_port = p_rtpport, trackingid = p_trackingid, ended = p_ended, tech_called = p_techcalled,
					gateway_price_id = p_gatewayrateid, gateway_price_per_min = p_gatewayratepermin, gateway_price_total = p_gatewayratetotal, gateway_currency = p_gatewaycurrency,
					customer_price_id = p_customerrateid, customer_price_per_min = p_customerratepermin, customer_price_total = p_customerratetotal, customer_currency = p_customercurrency,
					routing_waiting_time = p_routingwaitingtime, routing_processing_time = p_routingprocessingtime, sip_user_agent = p_sipuseragent,
					sip_x_asterisk_hangupcause = p_sipxasteriskhangupcause, sip_x_asterisk_hangupcausecode = p_sipxasteriskhangupcausecode, 
					sqltime_end = (p_sqltime + p_duration * INTERVAL '1 second'), rtp_forward = p_rtpforward, routing_tree = p_routingtree
				WHERE id = i_id;
				
			END IF;

			RETURN;			
		ELSE -- NOT FOUND, INSERT
		
			BEGIN
				-- TRY TO INSERT
				INSERT INTO cdr (sqltime, node_id, yatetime, billid, chan, address, port, caller, callername, called, ringtime, billtime, duration,
						direction, status, reason, error, dialcode_master_id, cause_q931,
						cause_sip, gateway_id, gateway_account_id, gateway_ip_id, format, formats, customer_id, customer_ip_id,
						rtp_address, rtp_port, trackingid, ended, tech_called,
						gateway_price_id, gateway_price_per_min, gateway_price_total, gateway_currency, responsetime,
						customer_price_id, customer_price_per_min, customer_price_total, customer_currency,
						routing_waiting_time, routing_processing_time, sip_user_agent, sip_x_asterisk_hangupcause, sip_x_asterisk_hangupcausecode,
						sqltime_end, rtp_forward, routing_tree)
					VALUES (p_sqltime, p_nodeid, p_yatetime, p_billid, p_chan, p_address, p_port, p_caller, p_callername, p_called, p_ringtime, p_billtime, p_duration,
						p_direction::direction, p_status, p_reason, p_error, p_dialcodemasterid, p_causeq931, p_causesip, p_gatewayid, p_gatewayaccountid, p_gatewayipid,
						p_format, p_formats, p_customerid, p_customeripid, p_rtpaddress, p_rtpport, p_trackingid, p_ended, p_techcalled,
						p_gatewayrateid, p_gatewayratepermin, p_gatewayratetotal, p_gatewaycurrency, p_duration - p_ringtime - p_billtime,
						p_customerrateid, p_customerratepermin, p_customerratetotal, p_customercurrency,
						p_routingwaitingtime, p_routingprocessingtime, p_sipuseragent, p_sipxasteriskhangupcause, p_sipxasteriskhangupcausecode,
						(p_sqltime + p_duration * INTERVAL '1 second'), p_rtpforward, p_routingtree);
					
				RETURN;
			EXCEPTION WHEN unique_violation THEN
			    -- DO NOTHING, LOOP AND TRY THE UPDATE AGAIN
			END;
		END IF;
	END LOOP;
END;
$$
LANGUAGE plpgsql VOLATILE;

--GO
-- RTP Stats

ALTER TABLE cdr ADD COLUMN rtp_packets_sent BIGINT;
ALTER TABLE cdr ADD COLUMN rtp_octets_sent BIGINT;
ALTER TABLE cdr ADD COLUMN rtp_packets_received BIGINT;
ALTER TABLE cdr ADD COLUMN rtp_octets_received BIGINT;
ALTER TABLE cdr ADD COLUMN rtp_packet_loss BIGINT;
ALTER TABLE cdr DROP COLUMN rtp_addr;
ALTER TABLE cdr ADD COLUMN rtp_address INET;

CREATE OR REPLACE FUNCTION domain.controller_add_rtp_stats(p_billid TEXT, p_chan TEXT, p_node_id INT, p_packets_sent BIGINT, p_octets_sent BIGINT, p_packets_received BIGINT, p_octets_received BIGINT, p_packet_loss BIGINT, p_rtp_address INET, p_rtp_port INT)
RETURNS void AS
$$
BEGIN
		UPDATE cdr SET rtp_packets_sent = p_packets_sent, rtp_octets_sent = p_octets_sent, rtp_packets_received = p_packets_received,
			rtp_octets_received = p_octets_received, rtp_packet_loss = p_packet_loss, rtp_address = p_rtp_address, rtp_port = p_rtp_port
		WHERE chan = p_chan AND node_id = p_node_id AND billid = p_billid;
END;
$$
LANGUAGE plpgsql VOLATILE;



--GO




--=============================================
--
--
--		NEW CHANGES 27.04.2016
--
--
--=============================================

-- CUSTOMER CREDIT
ALTER TABLE customer_credit DROP COLUMN created; -- ADDED AT THE END
ALTER TABLE customer_credit ADD COLUMN payment_transaction_data TEXT;
ALTER TABLE customer_credit ADD COLUMN payment_transaction_type INT;
ALTER TABLE customer_credit ADD COLUMN payment_description TEXT;
ALTER TABLE customer_credit ADD COLUMN payment_method INT;
ALTER TABLE customer_credit ADD COLUMN payment_reference_id TEXT;
ALTER TABLE customer_credit RENAME amount TO charged_credit;
ALTER TABLE customer_credit ADD COLUMN created TIMESTAMP NOT NULL DEFAULT NOW();
--GO


-- DROP MATERIALIZED VIEW cache_customer_price;  DROPPED BECAUSE CREATED EARLIER - BUT NOW MOVED TO THE BOTTOM OF THIS SCRIPT SO NO NEED TO DROP IF RUN ON ORIGINAL DATABASE
-- DROP MATERIALIZED VIEW cache_gateway_price;  DROPPED BECAUSE CREATED EARLIER - BUT NOW MOVED TO THE BOTTOM OF THIS SCRIPT SO NO NEED TO DROP IF RUN ON ORIGINAL DATABASE
-- DROP MATERIALIZED VIEW cache_number_gateway_statistics;   DROPPED BECAUSE CREATED EARLIER - BUT NOW MOVED TO THE BOTTOM OF THIS SCRIPT SO NO NEED TO DROP IF RUN ON ORIGINAL DATABASE

-- REMOVE numeric scaling (PostgreSQL does that automatically)
-- CORRECTING COLUMN DATA TYPES
ALTER TABLE customer_price ALTER COLUMN price TYPE numeric; -- just to modify following column
ALTER TABLE gateway_price ALTER COLUMN price TYPE numeric; -- just to modify following column
ALTER TABLE cdr ALTER COLUMN gateway_price_per_min TYPE numeric; -- just to modify following column
ALTER TABLE cdr ALTER COLUMN gateway_price_total TYPE numeric; -- just to modify following column
ALTER TABLE cdr ALTER COLUMN customer_price_per_min TYPE numeric; -- just to modify following column
ALTER TABLE cdr ALTER COLUMN customer_price_total TYPE numeric; -- just to modify following column
ALTER TABLE exchange_rate_to_usd ALTER COLUMN multiplier TYPE numeric; -- just to modify following column
ALTER TABLE cache_number_gateway_statistic ALTER COLUMN asr TYPE numeric; -- just to modify following column
ALTER TABLE customer ALTER COLUMN credit_remaining TYPE numeric; -- just to modify following column
--GO
ALTER TABLE customer RENAME COLUMN credit_remaining TO remaining_credit; -- RENAMING
ALTER TABLE customer RENAME COLUMN credit_remaining_warning TO remaining_credit_warning; -- RENAMING
ALTER TABLE gateway RENAME COLUMN credit_remaining_warning TO remaining_credit_warning; -- RENAMING
ALTER TABLE gateway_credit RENAME COLUMN amount TO charged_credit; -- RENAMING
ALTER TABLE gateway RENAME COLUMN credit_remaining TO remaining_credit; -- RENAMING
--GO
ALTER TABLE customer ALTER COLUMN remaining_credit_warning TYPE int; -- just to modify following column
ALTER TABLE customer_invoice ALTER COLUMN price TYPE numeric; -- just to modify following column
ALTER TABLE gateway ALTER COLUMN remaining_credit TYPE numeric; -- just to modify following column
ALTER TABLE gateway ALTER COLUMN remaining_credit_warning TYPE INT; -- just to modify following column
ALTER TABLE gateway_credit ALTER COLUMN charged_credit TYPE numeric; -- just to modify following column
--GO

-- ADD/DROP UNNEEDED COLUMNS
ALTER TABLE customer ADD COLUMN currency CHARACTER(3) NOT NULL DEFAULT 'USD';
ALTER TABLE gateway ADD COLUMN currency CHARACTER(3) NOT NULL DEFAULT 'USD';

--GO

UPDATE gateway SET currency = 'EUR' WHERE id IN (47,72,54,10,36,70);
UPDATE customer SET currency = 'EUS' WHERE id IN (44,51,54);

--GO
ALTER TABLE customer_invoice DROP COLUMN currency;
ALTER TABLE customer_pricelist DROP COLUMN currency;
ALTER TABLE customer_price DROP COLUMN currency;
ALTER TABLE gateway_pricelist DROP COLUMN currency;
ALTER TABLE gateway_price DROP COLUMN currency;

--GO


CREATE TABLE domain.customer_credit_statistic
(
	id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	date DATE NOT NULL DEFAULT NOW(),
	used_credit NUMERIC NOT NULL DEFAULT 0,
	last_polls_used_credit NUMERIC NOT NULL DEFAULT 0,
	balance_db_load SMALLINT NOT NULL DEFAULT 0,
	CONSTRAINT fk_ccs_c FOREIGN KEY (customer_id) REFERENCES customer (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX ix_ccs_dc ON customer_credit_statistic (date, customer_id);
--GO
--- UPDATE TRIGGER

CREATE OR REPLACE FUNCTION domain.tr_statistic_update()
  RETURNS trigger AS
$BODY$
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
		i_customer_price_total NUMERIC=0;
		i_gateway_price_total NUMERIC=0;
BEGIN
	i_call_failed_add := 0;
	i_call_add := 0;

	IF TG_OP = 'INSERT' THEN
		i_date := DATE(NEW.sqltime AT TIME ZONE 'UTC');
		i_node_id := NEW.node_id;
	ELSEIF TG_OP = 'UPDATE' THEN
		i_date := DATE(OLD.sqltime AT TIME ZONE 'UTC');
		i_node_id := OLD.node_id;
	END IF;
	
	-- CUSTOMER
	IF NEW.direction = 'incoming' AND NEW.customer_ip_id IS NOT NULL THEN
		
		IF TG_OP = 'INSERT' THEN			
			i_customer_ip_id := NEW.customer_ip_id;			
			i_call_total_add := 1;
				
			IF NEW.ended THEN
				i_call_add := 0;

				IF NEW.billtime = 0 THEN
					i_call_failed_add := 1;
				END IF;
			ELSE
				i_call_add := 1;
			END IF;

			i_customer_price_total = COALESCE(NEW.customer_price_total, 0);
			
		ELSEIF TG_OP = 'UPDATE' THEN		
			i_old_billtime := OLD.billtime;
			
			IF i_old_billtime IS NULL THEN
				i_old_billtime := 0;
			END IF;
			
			i_customer_ip_id := NEW.customer_ip_id;			

			IF NEW.ended = false AND OLD.customer_ip_id IS NULL THEN
				i_call_add := 1;			
			ELSEIF NEW.ended THEN
				i_call_add := -1;
	
				IF NEW.billtime = 0 THEN
					i_call_failed_add := 1;
				END IF;
			END IF;

			i_customer_price_total = COALESCE(NEW.customer_price_total, 0) - COALESCE(OLD.customer_price_total, 0);
			IF i_customer_price_total < 0 THEN
				i_customer_price_total = 0;
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

		IF i_customer_price_total IS NOT NULL AND i_customer_price_total > 0 THEN
			LOOP
				UPDATE customer_credit_statistic SET used_credit = used_credit + i_customer_price_total						
					WHERE customer_credit_statistic.date = i_date AND customer_id = NEW.customer_id AND balance_db_load = i_balancedbload;
				EXIT WHEN FOUND;
				
				BEGIN
					INSERT INTO customer_credit_statistic (customer_id, date, used_credit, balance_db_load)
						VALUES (NEW.customer_id, i_date, i_customer_price_total,i_balancedbload);

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
			i_call_total_add := 1;
			
			IF NEW.ended THEN
				i_call_add := 0;
								
				IF NEW.billtime = 0 AND NEW.reason <> 'pickup' THEN
					i_call_failed_add := 1;
				END IF;
			ELSE
				i_call_add := 1;
			END IF;

			i_gateway_price_total = COALESCE(NEW.gateway_price_total, 0);
			
		ELSEIF TG_OP = 'UPDATE' THEN
			i_old_billtime := OLD.billtime;
			i_gateway_ip_id := NEW.gateway_ip_id;
			i_gateway_account_id := NEW.gateway_account_id;

			IF NEW.ended = FALSE AND OLD.gateway_ip_id IS NULL AND OLD.gateway_account_id IS NULL THEN
				i_call_add := 1;
			ELSEIF NEW.ended THEN
				i_call_add := -1;
	
				IF NEW.billtime = 0 AND NEW.reason <> 'pickup' THEN
					i_call_failed_add := 1;
				END IF;
			END IF;

			i_gateway_price_total = COALESCE(NEW.gateway_price_total, 0) - COALESCE(OLD.gateway_price_total, 0);
			IF i_gateway_price_total < 0 THEN
				i_gateway_price_total = 0;
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
					INSERT INTO history_outgoing (sqltime, trackingid, total, dialcode_master_id)
					VALUES (i_sqltime, NEW.trackingid, 1, NEW.dialcode_master_id);

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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION domain.tr_statistic_update()
  OWNER TO postgres;

--GO

CREATE FUNCTION controller_endpoint_credit_update()
RETURNS void AS
$$
	DECLARE i_customer_id INT;
		i_used_credit NUMERIC;
		i_record_id INT;
BEGIN

	FOR i_record_id IN (SELECT id FROM customer_credit_statistic
					WHERE date > NOW() - INTERVAL '2 days'
						AND (used_credit <> last_polls_used_credit OR last_polls_used_credit IS NULL))
	LOOP

		FOR i_customer_id, i_used_credit IN (SELECT customer_id, used_credit - COALESCE(last_polls_used_credit, 0) FROM customer_credit_statistic
							WHERE id = i_record_id)
		LOOP
			-- UPDATE CUSTOMER REMAINING CREDIT
			UPDATE customer SET remaining_credit = remaining_credit - i_used_credit WHERE id = i_customer_id;

			-- UPDATE CREDIT STATISTIC TO FLAG AS PROCESSED
			UPDATE customer_credit_statistic SET last_polls_used_credit = used_credit WHERE id = i_record_id;

		END LOOP;
		
	END LOOP;
	RETURN;
END;
$$
LANGUAGE plpgsql VOLATILE STRICT;

--GO

CREATE OR REPLACE FUNCTION domain.controller_internal_limit_of_customer_reached(p_customer_id integer)
  RETURNS boolean AS
$BODY$
	DECLARE
		i_remaining_credit NUMERIC;
		i_hour_limit BIGINT;
		i_concurrent_lines_limit INTEGER;
		i_concurrent_lines_in_used INTEGER;
		i_todays_billtime BIGINT;
BEGIN
	
	SELECT remaining_credit, hour_limit, concurrent_lines_limit INTO i_remaining_credit, i_hour_limit, i_concurrent_lines_limit
		FROM customer WHERE id = p_customer_id;

	IF i_remaining_credit IS NOT NULL AND i_remaining_credit <= 0 THEN
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION domain.controller_internal_limit_of_customer_reached(integer)
  OWNER TO postgres;

  
--GO



DROP FUNCTION domain.yate_enginetimer_update(text);

ALTER TABLE node RENAME COLUMN online_since TO last_contact;
ALTER TABLE node ALTER COLUMN last_contact TYPE TIMESTAMP;
ALTER TABLE node ALTER COLUMN offline_since TYPE TIMESTAMP;
ALTER TABLE node ALTER COLUMN last_start TYPE TIMESTAMP;


CREATE OR REPLACE FUNCTION domain.controller_node_keepalive(p_id INT, p_timestamp timestamp)
  RETURNS void AS
$BODY$
BEGIN

	UPDATE node SET online = true, last_contact = p_timestamp WHERE id = p_id;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION domain.controller_node_keepalive(INT,timestamp)
  OWNER TO postgres;


-- ### QUERIES in functions

CREATE OR REPLACE FUNCTION domain.controller_get_customer_cache()
RETURNS TABLE (identifier TEXT, id INTEGER, ip_id INTEGER, context_id INTEGER, limit_exceeded BOOLEAN, fake_ringing BOOLEAN, host TEXT, prefix TEXT, qos_group_id INT, company_id INT)
AS
$$
BEGIN
	RETURN QUERY SELECT CONCAT(customer_ip.address, '#',COALESCE(customer.prefix, '')) AS identifier, customer.id, customer_ip.id, customer.context_id,
				controller_internal_limit_of_customer_reached(customer.id), customer.fake_ringing, host(customer_ip.address), customer.prefix,
				customer.qos_group_id, customer.company_id
			FROM customer
			INNER JOIN customer_ip ON customer_ip.customer_id = customer.id AND customer_ip.enabled = true AND customer_ip.deleted = false
			WHERE customer.enabled = true AND customer.deleted = false
			ORDER BY customer_ip.address, prefix DESC NULLS LAST;
END;
$$
LANGUAGE plpgsql STRICT STABLE;


CREATE OR REPLACE FUNCTION domain.controller_get_context_gateway_cache()
RETURNS TABLE (context_id INTEGER, gateway_id INTEGER)
AS
$$
BEGIN
	RETURN QUERY SELECT context_gateway.context_id, context_gateway.gateway_id
			FROM context_gateway
			INNER JOIN gateway ON gateway.id = context_gateway.gateway_id
			INNER JOIN context ON context.id = context_gateway.context_id
			WHERE gateway.enabled = true AND context.enabled = true
			ORDER BY context_id, gateway_id;
END;
$$
LANGUAGE plpgsql STRICT STABLE;

CREATE OR REPLACE FUNCTION domain.controller_get_node_connection_info(p_id INTEGER)
RETURNS TABLE (cs_ip TEXT, cs_port INTEGER, critical_load INTEGER)
AS
$$
BEGIN
	RETURN QUERY SELECT node.cs_ip, node.cs_port, node.critical_load FROM node WHERE id = p_id;
END;
$$
LANGUAGE plpgsql STRICT STABLE;


CREATE OR REPLACE FUNCTION domain.controller_get_gateway_account_cache()
RETURNS TABLE (gateway_account_id INTEGER, account TEXT, protocol TEXT, new_caller TEXT, new_callername TEXT, billtime BIGINT, id INTEGER)
AS
$$
BEGIN
	RETURN QUERY SELECT DISTINCT gateway_account.id, gateway_account.account, gateway_account.protocol, gateway_account.new_caller, gateway_account.new_callername,
				CASE WHEN gateway_account_statistic.billtime IS NULL THEN 0 ELSE gateway_account_statistic.billtime END, gateway.id
			FROM gateway_account
			LEFT JOIN gateway_account_statistic ON gateway_account_statistic.gateway_account_id = gateway_account.id AND date = CURRENT_DATE
			INNER JOIN gateway ON gateway.id = gateway_account.gateway_id AND gateway_account.enabled = true AND gateway.enabled = true
			ORDER BY gateway.id ASC;
END;
$$
LANGUAGE plpgsql STRICT STABLE;


CREATE OR REPLACE FUNCTION domain.controller_get_gateway_ip_cache()
RETURNS TABLE (gateway_ip_id INTEGER, address TEXT, port INTEGER, protocol TEXT, rtp_address TEXT, rtp_port INTEGER, rtp_forward BOOLEAN, sip_p_asserted_identity TEXT, billtime BIGINT, id INTEGER)
AS
$$
BEGIN

	RETURN QUERY SELECT DISTINCT gateway_ip.id, gateway_ip.address, gateway_ip.port, gateway_ip.protocol::TEXT, host(gateway_ip.rtp_address), gateway_ip.rtp_port, gateway_ip.rtp_forward, gateway_ip.sip_p_asserted_identity,
				CASE WHEN gateway_ip_statistic.billtime IS NULL THEN 0 ELSE gateway_ip_statistic.billtime END, gateway.id
			FROM gateway_ip
			INNER JOIN gateway_ip_node ON gateway_ip_node.gateway_ip_id = gateway_ip.id
			INNER JOIN gateway ON gateway.id = gateway_ip.gateway_id
			LEFT JOIN gateway_ip_statistic ON gateway_ip_statistic.gateway_ip_id = gateway_ip.id AND date = CURRENT_DATE
			WHERE gateway_ip.enabled = true AND gateway.enabled = true
			ORDER BY gateway.id ASC;

END;
$$
LANGUAGE plpgsql STRICT STABLE;


CREATE OR REPLACE FUNCTION domain.controller_get_gateway_cache()
  RETURNS TABLE(type text, id integer, remove_country_code boolean, number_modification_group_id integer, concurrent_lines_limit integer, prefix text, format text, formats text, oconnectionid text, qos_group_id INT, company_id INT) AS
$BODY$
BEGIN

	RETURN QUERY SELECT gateway.type::text, gateway.id, gateway.remove_country_code, gateway.number_modification_group_id, gateway.concurrent_lines_limit,
				gateway.prefix, format.name as format, gateway.controller_gateway_formats, 'general'::text as oconnectionid, gateway.qos_group_id, gateway.company_id
			FROM gateway
			INNER JOIN format ON format.id = gateway.format_id
			WHERE gateway.enabled = true;
	
END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT;


CREATE OR REPLACE FUNCTION domain.controller_get_nodes_accessible_by_gateway_cache()
RETURNS TABLE (gateway_id INTEGER, node_id INTEGER)
AS
$$
BEGIN

	RETURN QUERY SELECT a.gateway_id, a.node_id
		FROM (SELECT gateway_account.gateway_id, node_ip.node_id
			FROM gateway_account
			INNER JOIN node_ip ON node_ip.node_id = gateway_account.node_id
			INNER JOIN node ON node.id = node_ip.node_id
			INNER JOIN gateway ON gateway.id = gateway_account.gateway_id
			WHERE node.enabled = TRUE AND node_ip.enabled AND node.online = TRUE AND node.is_in_maintenance_mode = FALSE AND gateway_account.enabled = TRUE AND node_ip.network = 'Intern' AND gateway.enabled = TRUE
		      UNION
		      SELECT gateway_ip.gateway_id , node_ip.node_id
			FROM gateway_ip_node
			INNER JOIN node ON node.id = gateway_ip_node.node_id
			INNER JOIN node_ip ON node_ip.node_id = node.id
			INNER JOIN gateway_ip ON gateway_ip.id = gateway_ip_node.gateway_ip_id AND gateway_ip.enabled = TRUE
			INNER JOIN gateway ON gateway.id = gateway_ip.gateway_id AND gateway.enabled = TRUE
			WHERE node.enabled = TRUE AND node_ip.enabled AND node.online = TRUE AND node_ip.network = 'Intern' AND node.is_in_maintenance_mode = FALSE
		      )a
		ORDER BY a.gateway_id;

END;
$$
LANGUAGE plpgsql STABLE STRICT;

CREATE OR REPLACE FUNCTION domain.controller_get_gateway_limit_exceeded_cache()
RETURNS TABLE(gateway_id INTEGER, limit_exceeded BOOLEAN)
AS
$$
BEGIN

	RETURN QUERY SELECT gateway_ip.gateway_id, (hour_limit*0.95 - SUM(billtime) < 0) AS limit_exceeded
			FROM gateway_ip_statistic
			INNER JOIN gateway_ip ON gateway_ip.id = gateway_ip_statistic.gateway_ip_id
			INNER JOIN gateway ON gateway.id = gateway_ip.gateway_id
			WHERE date = CURRENT_DATE AND hour_limit IS NOT NULL AND gateway.enabled = true
			GROUP BY gateway_ip.gateway_id, hour_limit;
	
END;
$$
LANGUAGE plpgsql STABLE STRICT;

CREATE OR REPLACE FUNCTION domain.controller_get_context_cache()
RETURNS TABLE (id INTEGER, least_cost_routing BOOLEAN, timeout INTEGER, enable_lcr_without_rate BOOLEAN, fork_connect_behavior SMALLINT, fork_connect_behavior_timeout INT)
AS
$$
BEGIN

	RETURN QUERY SELECT context.id, context.least_cost_routing, context.timeout, context.enable_lcr_without_rate,
		context.fork_connect_behavior, context.fork_connect_behavior_timeout
		FROM context
		WHERE deleted = false AND enabled = true;

END;
$$
LANGUAGE plpgsql STABLE STRICT;

--GO
CREATE OR REPLACE FUNCTION domain.controller_get_incorrect_callername_cache()
RETURNS TABLE (name TEXT, replacement TEXT)
AS
$$
BEGIN
	RETURN QUERY SELECT ic.name, ic.replacement FROM incorrect_callername ic WHERE deleted = FALSE;
END;
$$
LANGUAGE plpgsql STRICT STABLE;
--GO

CREATE OR REPLACE FUNCTION domain.controller_get_number_modification_policies_cache()
RETURNS TABLE (id INTEGER, pattern TEXT, remove_prefix TEXT, add_prefix TEXT, sort INTEGER)
AS
$$
BEGIN
	RETURN QUERY SELECT nmg.id, nm.pattern, nm.remove_prefix, nm.add_prefix, nm.sort
			FROM number_modification nm
			INNER JOIN number_modification_group_number_modification nmgnm ON nmgnm.number_modification_id = nm.id
			INNER JOIN number_modification_group nmg ON nmg.id = nmgnm.number_modification_group_id AND nmg.enabled = true AND nmg.deleted = false
			WHERE nm.enabled = true AND nm.deleted = false
			ORDER BY nmg.name, nm.sort DESC;

END;
$$
LANGUAGE plpgsql STRICT STABLE;


CREATE OR REPLACE FUNCTION domain.controller_get_node_cache()
RETURNS TABLE (id INTEGER, address INET)
AS
$$
BEGIN
	RETURN QUERY SELECT node.id, node_ip.address
			FROM node
			INNER JOIN node_ip ON node_ip.node_id = node.id AND node_ip.network = 'Intern' AND node_ip.deleted = FALSE AND node_ip.enabled = TRUE
			WHERE node.enabled = TRUE AND node.deleted = FALSE AND node.is_in_maintenance_mode = FALSE;
END;
$$
LANGUAGE plpgsql STRICT STABLE;

CREATE OR REPLACE FUNCTION domain.controller_get_internal_node_ip_cache()
RETURNS TABLE (node_id INTEGER, host TEXT, port INTEGER)
AS
$$
BEGIN

	RETURN QUERY SELECT node_ip.node_id, host(node_ip.address), node_ip.port
			FROM node_ip
			INNER JOIN node ON node.id = node_ip.node_id AND node.enabled = TRUE AND node.is_in_maintenance_mode = FALSE
			WHERE network = 'Intern' AND node_ip.enabled = TRUE;

END;
$$
LANGUAGE plpgsql STRICT STABLE;



CREATE OR REPLACE FUNCTION domain.controller_get_blacklist_cache()
RETURNS TABLE (pattern TEXT)
AS
$$
BEGIN

	RETURN QUERY SELECT blacklist.pattern FROM blacklist WHERE enabled = TRUE AND deleted = FALSE;

END;
$$
LANGUAGE plpgsql STRICT STABLE;

CREATE OR REPLACE FUNCTION domain.controller_get_targets_for_route_cache()
RETURNS TABLE(route_id INTEGER, gateway_id INTEGER, context_id INTEGER)
AS
$$
BEGIN

	RETURN QUERY SELECT sub.route_id, sub.gateway_id, sub.context_id FROM
			(
				SELECT rtt.route_id, rtt.sort, rtt.gateway_id, rtt.context_id
					FROM route_to_target rtt
					INNER JOIN gateway ON gateway.id = rtt.gateway_id
					WHERE gateway.enabled = TRUE
				UNION
				SELECT rtt.route_id, rtt.sort, rtt.gateway_id, rtt.context_id
					FROM route_to_target rtt
					INNER JOIN context ON context.id = rtt.context_id
					WHERE context.enabled = TRUE
			) sub
			ORDER BY sub.route_id, sub.sort ASC;	
END;
$$
LANGUAGE plpgsql STRICT STABLE;



CREATE OR REPLACE FUNCTION domain.controller_get_gateways_accessible_by_node_cache()
  RETURNS TABLE(node_id integer, gateway_id integer) AS
$BODY$
BEGIN
	RETURN QUERY (SELECT gateway_ip_node.node_id, gateway_ip.gateway_id
			FROM gateway_ip_node
			INNER JOIN node ON node.id = gateway_ip_node.node_id
			INNER JOIN gateway_ip ON gateway_ip.id = gateway_ip_node.gateway_ip_id
			INNER JOIN gateway ON gateway.id = gateway_ip.gateway_id
			WHERE gateway.enabled = TRUE AND gateway_ip.enabled = TRUE AND node.enabled = TRUE)
		     UNION
		     (SELECT gateway_account.node_id, gateway_account.gateway_id
			FROM gateway_account
			INNER JOIN gateway ON gateway.id = gateway_account.gateway_id
			WHERE gateway.enabled = TRUE AND gateway_account.enabled = TRUE)
		     ORDER BY node_id ASC;


END;
$BODY$
  LANGUAGE plpgsql STABLE LEAKPROOF STRICT;


  
CREATE OR REPLACE FUNCTION domain.controller_gateway_formats(gateway)
  RETURNS text AS
$BODY$
BEGIN        
        RETURN (SELECT string_agg(name, ',')::TEXT FROM format_gateway
			INNER JOIN format ON format.id = format_gateway.format_id
			WHERE format_gateway.gateway_id = ($1).id);
END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT;



--################# GET NUMBER INFO

CREATE OR REPLACE FUNCTION domain.controller_get_dialcode_master_cache ()
	RETURNS TABLE (dialcode_master_id INT, is_mobile BOOLEAN, dialcode TEXT)
	LANGUAGE plpgsql STABLE LEAKPROOF STRICT
AS
$$
BEGIN
	RETURN QUERY SELECT dialcode_master.id, dialcode_master.is_mobile, dialcode_master.dialcode
			FROM dialcode_master;			
END;
$$;


--GO

--### MATERIALIZED VIEW ###

-- ##################################

--################ CUSTOMER PRICE

CREATE MATERIALIZED VIEW cache_customer_price AS
	SELECT cp.id, customer_id, number, price, c.currency, CASE WHEN multiplier IS NULL AND c.currency = 'USD' THEN price ELSE price*multiplier END AS price_normalized,
		valid_from, valid_to, length(number) as numberlength
	FROM customer_price cp
	INNER JOIN customer c ON c.id = cp.customer_id
	LEFT JOIN exchange_rate_to_usd ex ON c.currency = ex.currency
	WHERE NOW() BETWEEN valid_from AND valid_to OR valid_from > NOW();
CREATE INDEX customer_price_pvfvt ON cache_customer_price (number DESC, customer_id, valid_from, valid_to);


CREATE OR REPLACE FUNCTION domain.controller_get_rate_for_customer (p_number TEXT[], p_customer_id INT, p_timestamp TIMESTAMPTZ)
	RETURNS TABLE (id BIGINT, price NUMERIC, currency CHARACTER(3), price_normalized NUMERIC)
AS
$$
BEGIN
	RETURN QUERY SELECT cache_customer_price.id, cache_customer_price.price, cache_customer_price.currency, cache_customer_price.price_normalized
			FROM cache_customer_price
			WHERE customer_id = p_customer_id
				AND number = ANY(p_number)
				AND p_timestamp BETWEEN valid_from AND valid_to
			ORDER BY numberlength DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE STRICT ROWS 1;

--###############

--GO

--############### GATEWAY PRICE

CREATE MATERIALIZED VIEW cache_gateway_price AS 
	SELECT gp.id, gateway_id, number, price, g.currency, CASE WHEN multiplier IS NULL AND g.currency = 'USD' THEN price ELSE price*multiplier END AS price_normalized,
		valid_from, valid_to, length(number) as numberlength, timeband
	FROM gateway_price gp
	INNER JOIN gateway g ON g.id = gp.gateway_id
	LEFT JOIN exchange_rate_to_usd ex ON g.currency = ex.currency
	WHERE NOW() BETWEEN valid_from AND valid_to OR valid_from > NOW();
CREATE INDEX gateway_price_pvfvt ON cache_gateway_price (number DESC, gateway_id, valid_from, valid_to);


CREATE OR REPLACE FUNCTION controller_get_rates_for_gateways(p_number text[], p_gateway_ids integer[], p_timestamp timestamp with time zone)
	RETURNS TABLE(id bigint, rate numeric, currency character, rate_normalized numeric, timeband TEXT, gateway_id integer)
    AS $$
	DECLARE i_id BIGINT;
		i_rate NUMERIC;
		i_currency CHARACTER(3);
		i_rate_normalized NUMERIC;
		i_timeband RATE_TIMEBAND;
		i_gateway_id INT;
BEGIN
	CREATE TEMPORARY TABLE i_result (id BIGINT, rate NUMERIC, currency CHARACTER(3), rate_normalized NUMERIC, timeband TEXT, gateway_id INT) ON COMMIT DROP;

	FOREACH i_gateway_id IN ARRAY p_gateway_ids
	LOOP

		-- cache query gateway routing price flat
		SELECT cache_gateway_price.id, cache_gateway_price.price, cache_gateway_price.currency, cache_gateway_price.price_normalized, cache_gateway_price.timeband
			INTO i_id, i_rate, i_currency, i_rate_normalized, i_timeband
			FROM cache_gateway_price 
			WHERE number = ANY (p_number)
				AND cache_gateway_price.gateway_id = i_gateway_id
				AND cache_gateway_price.timeband = 'Flat'::rate_timeband
				AND p_timestamp BETWEEN valid_from AND valid_to
			ORDER BY numberlength DESC LIMIT 1;

		IF NOT FOUND THEN
			-- cache query gateway routing price non flat
			SELECT cache_gateway_price.id, cache_gateway_price.price, cache_gateway_price.currency, cache_gateway_price.price_normalized, cache_gateway_price.timeband
				INTO i_id, i_rate, i_currency, i_rate_normalized, i_timeband
				FROM cache_gateway_price
				WHERE number = ANY (p_number)
					AND p_timestamp BETWEEN valid_from AND valid_to
					AND cache_gateway_price.gateway_id = i_gateway_id AND 
					cache_gateway_price.timeband::rate_timeband IN (
						SELECT gateway_timeband.timeband FROM gateway_timeband
							WHERE p_timestamp BETWEEN gateway_timeband.valid_from AND gateway_timeband.valid_to
								AND p_timestamp::TIME BETWEEN time_from AND time_to
								AND day_of_week = extract('dow' from p_timestamp)
								AND gateway_timeband.gateway_id = i_gateway_id
									AND dialcode_master_id = (SELECT dialcode_master.id FROM dialcode_master
										WHERE dialcode = ANY (p_number)
										ORDER BY LENGTH(dialcode) DESC LIMIT 1)
										)
				ORDER BY numberlength DESC, price ASC LIMIT 1;

		END IF;

		IF i_id IS NOT NULL THEN
			INSERT INTO i_result (id, rate, currency, rate_normalized, timeband, gateway_id) VALUES (i_id, i_rate, i_currency, i_rate_normalized, i_timeband, i_gateway_id);

			i_id := NULL;
		END IF;
	END LOOP;

	
	RETURN QUERY SELECT i_result.id, i_result.rate, i_result.currency, i_result.rate_normalized, i_result.timeband::TEXT, i_result.gateway_id FROM i_result;	
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1;


--##############

--GO

--############# NUMBER GATEWAY STATISTICS

CREATE MATERIALIZED VIEW cache_number_gateway_statistics AS
	SELECT id, gateway_id, asr, created, number
	FROM cache_number_gateway_statistic
	ORDER BY number, gateway_id;
CREATE INDEX number_gateway_statistic_ng ON cache_number_gateway_statistics (number, gateway_id);

CREATE  OR REPLACE FUNCTION controller_get_number_gateway_statistic(p_number text[], p_gateway_ids integer[]) RETURNS TABLE(id integer, asr numeric)
    LANGUAGE plpgsql STRICT LEAKPROOF
    AS $$
	DECLARE i_asr NUMERIC;
			i_gateway_id INT;
BEGIN
	CREATE TEMPORARY TABLE i_result (gateway_id INT, asr NUMERIC) ON COMMIT DROP;

	FOREACH i_gateway_id IN ARRAY p_gateway_ids
	LOOP
		-- cache number gateway statistic
		SELECT cache_number_gateway_statistics.asr INTO i_asr FROM cache_number_gateway_statistics
			WHERE gateway_id = i_gateway_id AND number = ANY(p_number)
			ORDER BY number DESC LIMIT 1;

		INSERT INTO i_result (gateway_id, asr) VALUES (i_gateway_id, COALESCE(i_asr, 100));

		i_asr := NULL;

	END LOOP;

	RETURN QUERY SELECT i_result.gateway_id, i_result.asr FROM i_result;
END;
$$;

--## QoS Groups
CREATE TABLE qos_group (
	id serial primary key,
	name text not null,
	displayname text not null,
	deleted boolean not null default false	
);

ALTER TABLE gateway ADD COLUMN qos_group_id INTEGER;
ALTER TABLE customer ADD COLUMN qos_group_id INTEGER;
ALTER TABLE gateway ADD CONSTRAINT fk_g_qg FOREIGN KEY (qos_group_id) REFERENCES qos_group (id);
ALTER TABLE customer ADD CONSTRAINT fk_c_qg FOREIGN KEY (qos_group_id) REFERENCES qos_group (id);

--GO
INSERT INTO qos_group (name, displayname) values ('Std', 'Standard');
INSERT INTO qos_group (name, displayname) values ('Calling Line Identification', 'Cli');
INSERT INTO qos_group (name, displayname) values ('Premium', 'Pre');
UPDATE gateway SET qos_group_id = 1;
UPDATE customer SET qos_group_id = 1;
--GO
ALTER TABLE gateway ALTER COLUMN qos_group_id SET NOT NULL;
ALTER TABLE customer ALTER COLUMN qos_group_id SET NOT NULL;

--GO
UPDATE context SET next = 10000;
ALTER TABLE context ALTER COLUMN next SET DEFAULT 10000;
ALTER TABLE context ADD COLUMN fork_connect_behavior SMALLINT DEFAULT 1 NOT NULL;
ALTER TABLE context RENAME COLUMN next TO fork_connect_behavior_timeout;

-- DROP concurrent_connection_attempts
ALTER TABLE gateway DROP COLUMN concurrent_connection_attempts;


--GO

-- RENAME gateway_ip.rtp_addr TO rtp_address

ALTER TABLE gateway_ip ADD COLUMN rtp_address INET;
--GO
UPDATE gateway_ip SET rtp_address = CASE WHEN rtp_addr = '' THEN NULL ELSE rtp_addr::INET END;
--GO
ALTER TABLE gateway_ip DROP COLUMN rtp_addr;

--GO

--### DIALCODE MASTER


CREATE TABLE domain.dialcode_master
(
  id serial NOT NULL primary key,
  destination text NOT NULL,
  iso3 text NOT NULL,
  carrier text,
  is_mobile boolean NOT NULL DEFAULT false,
  dialcode text NOT NULL,
  dialcode_length INT NOT NULL
);
CREATE UNIQUE INDEX uq_dm_dialcode ON domain.dialcode_master (dialcode);

--GO
TRUNCATE TABLE history_gateway_reason;
ALTER TABLE history_gateway_reason DROP COLUMN country_id;
ALTER TABLE history_gateway_reason ADD COLUMN dialcode_master_id INT;
ALTER TABLE history_gateway_reason ADD CONSTRAINT fk_hgr_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master(id);
CREATE INDEX ix_hgr_dm ON domain.history_gateway_reason (dialcode_master_id);
--GO
TRUNCATE TABLE history_customer_reason;
ALTER TABLE history_customer_reason DROP COLUMN country_id;
ALTER TABLE history_customer_reason ADD COLUMN dialcode_master_id INT;
ALTER TABLE history_customer_Reason ADD CONSTRAINT fk_hcr_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master(id);
CREATE INDEX ix_hcr_dm ON domain.history_customer_Reason(dialcode_master_id);
--GO
TRUNCATE TABLE history_gateway_billtime;
ALTER TABLE history_gateway_billtime DROP COLUMN country_id;
ALTER TABLE history_gateway_billtime ADD COLUMN dialcode_master_id INT;
ALTER TABLE history_gateway_billtime ADD CONSTRAINT fk_hgb_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master(id);
CREATE INDEX ix_hgb_dm ON domain.history_gateway_billtime(dialcode_master_id);
--GO
TRUNCATE TABLE history_customer_billtime;
ALTER TABLE history_customer_billtime DROP COLUMN country_id;
ALTER TABLE history_customer_billtime ADD COLUMN dialcode_master_id INT;
ALTER TABLE history_customer_billtime ADD CONSTRAINT fk_hcb_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master(id);
CREATE INDEX ix_hcb_dm ON domain.history_customer_billtime(dialcode_master_id);
--GO
ALTER TABLE company DROP COLUMN country_id;
--GO
TRUNCATE TABLE history_outgoing;
ALTER TABLE history_outgoing DROP COLUMN country_id;
ALTER TABLE history_outgoing ADD COLUMN dialcode_master_id INT;
ALTER TABLE history_outgoing ADD CONSTRAINT fk_ho_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master(id);
CREATE INDEX ix_ho_dm ON domain.history_outgoing (dialcode_master_id);
--GO
TRUNCATE TABLE history_customer_cc;
TRUNCATE TABLE history_customer_cpm;
TRUNCATE TABLE history_gateway_cc;
TRUNCATE TABLE history_gateway_cpm;
--GO
ALTER TABLE gateway_timeband DROP COLUMN carrier_id;

TRUNCATE TABLE cdr;
ALTER TABLE cdr DROP COLUMN dialcode_id;
ALTER TABLE cdr ADD COLUMN dialcode_master_id INT;
ALTER TABLE cdr ADD CONSTRAINT fk_c_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master (id);
CREATE INDEX ix_cdr_dm ON domain.cdr (dialcode_master_id);

ALTER TABLE gateway_timeband ADD COLUMN dialcode_master_id INT NOT NULL;
ALTER TABLE gateway_timeband ADD CONSTRAINT fk_gt_dm FOREIGN KEY (dialcode_master_id) REFERENCES dialcode_master (id);
CREATE INDEX ix_gt_dm ON domain.gateway_timeband (dialcode_master_id);

--GO
DROP TABLE dialcode;

DROP TABLE carrier;

DROP TABLE country;



--GO

-- ROUTE TO CONTEXT

ALTER TABLE route_to_gateway RENAME TO route_to_target;
ALTER TABLE route_to_target ADD COLUMN context_id INT;
ALTER TABLE route_to_target ADD CONSTRAINT fk_rtt_c FOREIGN KEY (context_id) REFERENCES context(id);
ALTER TABLE route_to_target ALTER COLUMN gateway_id DROP NOT NULL;
ALTER TABLE route_to_target ADD CONSTRAINT route_to_target_check CHECK (
	(gateway_id IS NULL AND context_id IS NOT NULL)
	OR
	(gateway_id IS NOT NULL AND context_id IS NULL)
);
CREATE INDEX ix_rtt_co ON route_to_target(context_id);

--GO

--GO
CREATE OR REPLACE FUNCTION domain.controller_get_route_cache ()
	RETURNS TABLE (id INT, context_id INT, pattern TEXT, action TEXT, sort INT, did BOOLEAN, caller TEXT, callername TEXT, ignore_missing_rate BOOLEAN, fallback_to_lcr BOOLEAN, timeout INT)
	LANGUAGE plpgsql STABLE LEAKPROOF STRICT ROWS 1
AS
$$
BEGIN
	RETURN QUERY SELECT DISTINCT route.id, route.context_id, route.pattern, route.action, route.sort, route.did, COALESCE(route.caller, '') AS caller,
				COALESCE(route.callername, '') AS callername, route.ignore_missing_rate, route.fallback_to_lcr, context.timeout
			FROM route
			LEFT JOIN route_to_target ON route_to_target.route_id = route.id
			LEFT JOIN gateway ON gateway.id = route_to_target.gateway_id AND gateway.enabled = true
			INNER JOIN context ON context.id = route.context_id
			WHERE route.enabled = true AND context.enabled = true
			ORDER BY context_id, sort DESC;
END;
$$;



--GO

ALTER TABLE route DROP COLUMN timeout;

ALTER TABLE node ADD COLUMN critical_load INT DEFAULT 70 NOT NULL;


--########################
--########################
--########################	HISTORY TABLES / PROCEDURES
--########################
--########################

-- // TODO check from where called

CREATE OR REPLACE FUNCTION domain.cron_history_daily(p_date date)
  RETURNS void AS
$BODY$
	DECLARE i_end_date DATE;
BEGIN
	i_end_date := p_date + INTERVAL '1 day';

	-- GATEWAY BILLTIME
	INSERT INTO history_gateway_billtime (gateway_id, node_id, dialcode_master_id, is_mobile, calls, billtime, date)
	SELECT gateway_id, node_id, dialcode_master_id, is_mobile, COUNT(*), SUM(billtime)::bigint, sqltime::DATE FROM cdr
	INNER JOIN dialcode_master ON dialcode_master.id = cdr.dialcode_master_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND gateway_id IS NOT NULL
	GROUP BY gateway_id, node_id, dialcode_master_id, is_mobile, sqltime::DATE;

	-- GATEWAY REASON
	INSERT INTO history_gateway_reason (gateway_id, node_id, dialcode_master_id, is_mobile, calls, reason, date)
	SELECT gateway_id, node_id, dialcode_master_id, is_mobile, COUNT(*), reason, sqltime::DATE FROM cdr
	INNER JOIN dialcode_master ON dialcode_master.id = cdr.dialcode_master_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND gateway_id IS NOT NULL
	GROUP BY gateway_id, node_id, dialcode_master_id, is_mobile, reason, sqltime::DATE;

	-- CUSTOMER BILLTIME
	INSERT INTO history_customer_billtime(customer_id, node_id, dialcode_master_id, is_mobile, calls, billtime, date)
	SELECT customer_id, node_id, dialcode_master_id, is_mobile, COUNT(*), SUM(billtime)::bigint, sqltime::DATE FROM cdr
	INNER JOIN dialcode_master ON dialcode_master.id = cdr.dialcode_master_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND customer_id IS NOT NULL
	GROUP BY customer_id, node_id, dialcode_master_id, is_mobile, sqltime::DATE;
	
	-- CUSTOMER REASON
	INSERT INTO history_customer_reason (customer_id, node_id, dialcode_master_id, is_mobile, calls, reason, date)
	SELECT customer_id, node_id, dialcode_master_id, is_mobile, COUNT(*), reason, sqltime::DATE FROM cdr
	INNER JOIN dialcode_master ON dialcode_master.id = cdr.dialcode_master_id
	WHERE sqltime >= p_date AND sqltime < i_end_date AND customer_id IS NOT NULL
	GROUP BY customer_id, node_id, dialcode_master_id, is_mobile, reason, sqltime::DATE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION domain.cron_history_daily(date)
  OWNER TO postgres;

-- // TODO: Check from where called
  
CREATE OR REPLACE FUNCTION domain.cron_history()
  RETURNS void AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION domain.cron_history()
  OWNER TO postgres;


  -- // TODO: Check from where called
  
CREATE OR REPLACE FUNCTION domain.cron_new_cdr_table()
  RETURNS void AS
$BODY$
	DECLARE i_week INT=1;
		i_new_table_name TEXT;
		i_index_def TEXT;
		i_constraint_def TEXT;
		i_trigger_def TEXT;
		i_date_start DATE;
		i_date_end DATE;
		i_count INT=1;
		i_start_date DATE = CURRENT_DATE;
BEGIN
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
		IF i_week < 10 THEN
			IF i_week = 1 AND EXTRACT(year FROM i_date_start) <> EXTRACT(year FROM i_date_end) THEN
				i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_end), '_0', i_week::text);
			ELSE
				i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_start), '_0', i_week::text);
			END IF;
		ELSE
			i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_start), '_', i_week::text);
		END IF;

--raise notice 'week: %', i_week;
--raise notice 'tbn: %', i_new_table_name;

		i_count := i_count + 1;
		-- CHECK IF EXISTS
		PERFORM * FROM pg_catalog.pg_class WHERE relname::TEXT = i_new_table_name;

		IF FOUND THEN
			CONTINUE;
		END IF;

		-- CREATE TABLE
		EXECUTE CONCAT('create table ', i_new_table_name, ' (CHECK (sqltime >= ''', i_date_start::timestamptz, ''' AND sqltime < ''', i_date_end::timestamptz, ''')) inherits (cdr) WITH (FILLFACTOR=20,OIDS=FALSE,autovacuum_vacuum_threshold=50000,autovacuum_vacuum_scale_factor=0.1,autovacuum_analyze_threshold=50000,autovacuum_analyze_scale_factor=0.1);');

		-- ADD PERMISSIONS
		EXECUTE CONCAT('GRANT SELECT ON TABLE ', i_new_table_name, ' TO webuser_group;');
		EXECUTE CONCAT('GRANT SELECT, UPDATE, INSERT, TRIGGER ON TABLE ', i_new_table_name, ' TO cl_controller_group;');

		-- ADD PRIMARY KEY
		EXECUTE CONCAT('ALTER TABLE ', i_new_table_name, ' ADD CONSTRAINT pk_', i_new_table_name, ' PRIMARY KEY (id);');

		-- ADD INDICES
		FOR i_index_def IN SELECT pg_get_indexdef(i.indexrelid)
			FROM pg_catalog.pg_class c
			     JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
			     JOIN pg_catalog.pg_class c2 ON i.indrelid = c2.oid
			     LEFT JOIN pg_catalog.pg_user u ON u.usesysid = c.relowner
			     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
			WHERE c.relkind IN ('i','')
			      AND n.nspname NOT IN ('pg_catalog', 'pg_toast')
			      AND n.nspname = 'domain'
			      AND pg_catalog.pg_table_is_visible(c.oid)
			      AND c.relkind = 'i'
			      AND c2.relname = 'cdr' AND indisprimary = false
			ORDER BY 1 LOOP

			-- REPLACE INDEX NAME
			i_index_def := REPLACE(i_index_def, '_cdr_', CONCAT('_', i_new_table_name, '_'));
			-- REPLACE TARGET TABLE
			i_index_def := REPLACE(i_index_def, 'ON cdr USING', CONCAT('ON ', i_new_table_name, ' USING'));
			EXECUTE i_index_def;

		END LOOP;

		-- ADD CONSTRAINTS
		FOR i_constraint_def IN SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE contype = 'f' AND conrelid = (SELECT oid FROM pg_class WHERE relname = 'cdr') LOOP

			EXECUTE CONCAT('ALTER TABLE ', i_new_table_name, ' ADD ', i_constraint_def, ';');

		END LOOP;

		-- ADD TRIGGERS
		FOR i_trigger_def IN SELECT pg_get_triggerdef(oid) FROM pg_trigger WHERE tgrelid = (SELECT oid FROM pg_class WHERE relname = 'cdr') AND tgisinternal = FALSE AND tgname <> 'tr_cdr_insert' AND tgname <> 'tr_cdr_update' LOOP

			EXECUTE REPLACE(i_trigger_def, 'ON cdr FOR', CONCAT('ON ', i_new_table_name, ' FOR'));

		END LOOP;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION domain.cron_new_cdr_table()
  OWNER TO postgres;

-- // TODO: Check from where called

CREATE OR REPLACE FUNCTION domain.cron_number_gateway_statistic(p_last interval)
  RETURNS void AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION domain.cron_number_gateway_statistic(interval)
  OWNER TO postgres;

--GO

ALTER TABLE cdr ADD COLUMN routing_tree jsonb;

--GO

--####################################################################################
--####################################################################################
-- INDICES





--####################################################################################
--####################################################################################
-- PERMISSIONS

--CREATE USER cl_controller ENCRYPTED PASSWORD 'md5a86082cf777d51a63fa4d32831ff9b56'
--  NOINHERIT
   --VALID UNTIL 'infinity';
--ALTER ROLE cl_controller IN DATABASE voip
  --SET search_path = domain, public;

--CREATE ROLE cl_controller_group
  --NOINHERIT
   --VALID UNTIL 'infinity';

--GRANT cl_controller_group TO cl_controller;
--GRANT CONNECT, TEMP ON DATABASE voip TO cl_controller_group;

GRANT USAGE ON SCHEMA domain TO cl_controller_group;

GRANT SELECT, UPDATE ON domain.controller TO cl_controller_group;
GRANT SELECT, UPDATE ON domain.controller_connection TO cl_controller_group;
GRANT INSERT ON domain.controller_log TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.cdr TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.customer_ip_statistic TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.customer_credit_statistic TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.gateway_ip_statistic TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.gateway_account_statistic TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.history_outgoing TO cl_controller_group;
GRANT SELECT, INSERT, UPDATE ON domain.node_statistic TO cl_controller_group;
GRANT SELECT, UPDATE ON domain.customer TO cl_controller_group;
GRANT SELECT ON domain.customer_ip TO cl_controller_group;
GRANT SELECT, UPDATE ON domain.node TO cl_controller_group;
GRANT SELECT ON domain.context_gateway TO cl_controller_group;
GRANT SELECT ON domain.gateway TO cl_controller_group;
GRANT SELECT ON domain.context TO cl_controller_group;
GRANT SELECT ON domain.gateway_account TO cl_controller_group;
GRANT SELECT ON domain.gateway_ip TO cl_controller_group;
GRANT SELECT ON domain.gateway_ip_node TO cl_controller_group;
GRANT SELECT ON domain.format TO cl_controller_group;
GRANT SELECT ON domain.node_ip TO cl_controller_group;
GRANT SELECT ON domain.incorrect_callername TO cl_controller_group;
GRANT SELECT ON domain.number_modification TO cl_controller_group;
GRANT SELECT ON domain.number_modification_group_number_modification TO cl_controller_group;
GRANT SELECT ON domain.number_modification_group TO cl_controller_group;
GRANT SELECT ON domain.blacklist TO cl_controller_group;
GRANT SELECT ON domain.route_to_target TO cl_controller_group;
GRANT SELECT ON domain.format_gateway TO cl_controller_group;
GRANT SELECT ON domain.dialcode_master TO cl_controller_group;
GRANT SELECT ON domain.gateway_timeband TO cl_controller_group;
GRANT SELECT ON domain.route TO cl_controller_group;

-- Sequences
GRANT ALL ON SEQUENCE domain.controller_log_id_seq TO cl_controller_group;
GRANT ALL ON SEQUENCE domain.cdr_id_seq TO cl_controller_group;
GRANT ALL ON SEQUENCE domain.customer_ip_statistic_id_seq TO cl_controller_group;
GRANT ALL ON SEQUENCE domain.customer_credit_statistic_id_seq TO cl_controller_group;
GRANT ALL ON SEQUENCE domain.gateway_ip_statistic_id_seq TO cl_controller_group;
GRANT ALL ON SEQUENCE domain.gateway_account_statistic_id_seq TO cl_controller_group;
GRANT ALL ON SEQUENCE domain.node_statistic_id_seq TO cl_controller_group;

-- Materialized views
GRANT SELECT, UPDATE ON domain.cache_customer_price TO cl_controller_group;
GRANT SELECT, UPDATE ON domain.cache_gateway_price TO cl_controller_group;
GRANT SELECT ON domain.cache_number_gateway_statistics TO cl_controller_group;

-- Functions

GRANT EXECUTE ON FUNCTION domain.controller_startup (TEXT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_shutdown (INT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_is_alive (INT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_log (INT, TEXT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_connections (INT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_connection_status_update(INT, INT, INT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_cdr_upsert(INT, TIMESTAMPTZ, BIGINT, TEXT, TEXT, INET, INT, TEXT, TEXT, TEXT, BIGINT, BIGINT, BIGINT, TEXT,
	TEXT, TEXT, TEXT, INT, TEXT, TEXT, INT, INT, INT, TEXT, TEXT, INT, INT, INET, INT, TEXT, BOOLEAN, TEXT, BIGINT, NUMERIC(13,8), NUMERIC(13,8),
	CHAR(3), BIGINT, NUMERIC(13,8), NUMERIC(13,8), CHAR(3), INT, INT, TEXT, TEXT, TEXT, BOOLEAN, JSONB) TO cl_controller_group;

GRANT EXECUTE ON FUNCTION domain.controller_add_rtp_stats(TEXT, TEXT, INT, BIGINT, BIGINT, BIGINT, BIGINT, BIGINT, INET, INT) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.tr_statistic_update() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION controller_endpoint_credit_update() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_internal_limit_of_customer_reached(integer) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_node_keepalive(INT, timestamp) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_customer_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_context_gateway_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_node_connection_info(INTEGER) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_gateway_account_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_gateway_ip_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_gateway_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_nodes_accessible_by_gateway_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_gateway_limit_exceeded_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_context_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_incorrect_callername_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_number_modification_policies_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_node_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_internal_node_ip_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_blacklist_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_targets_for_route_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_gateways_accessible_by_node_cache() TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_gateway_formats(gateway) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_dialcode_master_cache () TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_rate_for_customer (TEXT[], INT, TIMESTAMPTZ) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION controller_get_rates_for_gateways(text[], integer[], timestamp with time zone) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION controller_get_number_gateway_statistic(text[], integer[]) TO cl_controller_group;
GRANT EXECUTE ON FUNCTION domain.controller_get_route_cache () TO cl_controller_group;

--GO

--// TODO: CHECK MATERIALIZED VIEW CREATION

--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################
--####################################################################################


---- END




CREATE OR REPLACE FUNCTION domain.DELETE_ME_cron_new_cdr_table_DELETE_ME()
  RETURNS void AS
$BODY$
	DECLARE i_week INT=1;
		i_new_table_name TEXT;
		i_index_def TEXT;
		i_constraint_def TEXT;
		i_trigger_def TEXT;
		i_date_start DATE;
		i_date_end DATE;
		i_count INT=1;
		i_start_date DATE = CURRENT_DATE - INTERVAL '3 weeks';
BEGIN
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
		IF i_week < 10 THEN
			IF i_week = 1 AND EXTRACT(year FROM i_date_start) <> EXTRACT(year FROM i_date_end) THEN
				i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_end), '_0', i_week::text);
			ELSE
				i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_start), '_0', i_week::text);
			END IF;
		ELSE
			i_new_table_name := CONCAT('cdr_', EXTRACT(year from i_date_start), '_', i_week::text);
		END IF;

--raise notice 'week: %', i_week;
--raise notice 'tbn: %', i_new_table_name;

		i_count := i_count + 1;
		-- CHECK IF EXISTS
		PERFORM * FROM pg_catalog.pg_class WHERE relname::TEXT = i_new_table_name;

		IF FOUND THEN
			CONTINUE;
		END IF;

		-- CREATE TABLE
		EXECUTE CONCAT('create table ', i_new_table_name, ' (CHECK (sqltime >= ''', i_date_start::timestamptz, ''' AND sqltime < ''', i_date_end::timestamptz, ''')) inherits (cdr) WITH (FILLFACTOR=20,OIDS=FALSE,autovacuum_vacuum_threshold=50000,autovacuum_vacuum_scale_factor=0.1,autovacuum_analyze_threshold=50000,autovacuum_analyze_scale_factor=0.1);');

		-- ADD PERMISSIONS		
		EXECUTE CONCAT('GRANT SELECT, UPDATE, INSERT, TRIGGER ON TABLE ', i_new_table_name, ' TO cl_controller_group;');

		-- ADD PRIMARY KEY
		EXECUTE CONCAT('ALTER TABLE ', i_new_table_name, ' ADD CONSTRAINT pk_', i_new_table_name, ' PRIMARY KEY (id);');

		-- ADD INDICES
		FOR i_index_def IN SELECT pg_get_indexdef(i.indexrelid)
			FROM pg_catalog.pg_class c
			     JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
			     JOIN pg_catalog.pg_class c2 ON i.indrelid = c2.oid
			     LEFT JOIN pg_catalog.pg_user u ON u.usesysid = c.relowner
			     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
			WHERE c.relkind IN ('i','')
			      AND n.nspname NOT IN ('pg_catalog', 'pg_toast')
			      AND n.nspname = 'domain'
			      AND pg_catalog.pg_table_is_visible(c.oid)
			      AND c.relkind = 'i'
			      AND c2.relname = 'cdr' AND indisprimary = false
			ORDER BY 1 LOOP

			-- REPLACE INDEX NAME
			i_index_def := REPLACE(i_index_def, '_cdr_', CONCAT('_', i_new_table_name, '_'));
			-- REPLACE TARGET TABLE
			i_index_def := REPLACE(i_index_def, 'ON cdr USING', CONCAT('ON ', i_new_table_name, ' USING'));
			EXECUTE i_index_def;

		END LOOP;

		-- ADD CONSTRAINTS
		FOR i_constraint_def IN SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE contype = 'f' AND conrelid = (SELECT oid FROM pg_class WHERE relname = 'cdr') LOOP

			EXECUTE CONCAT('ALTER TABLE ', i_new_table_name, ' ADD ', i_constraint_def, ';');

		END LOOP;

		-- ADD TRIGGERS
		FOR i_trigger_def IN SELECT pg_get_triggerdef(oid) FROM pg_trigger WHERE tgrelid = (SELECT oid FROM pg_class WHERE relname = 'cdr') AND tgisinternal = FALSE AND tgname <> 'tr_cdr_insert' AND tgname <> 'tr_cdr_update' LOOP

			EXECUTE REPLACE(i_trigger_def, 'ON cdr FOR', CONCAT('ON ', i_new_table_name, ' FOR'));

		END LOOP;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100;
ALTER FUNCTION domain.DELETE_ME_cron_new_cdr_table_DELETE_ME()
  OWNER TO postgres;



