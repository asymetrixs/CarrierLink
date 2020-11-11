
CREATE OR REPLACE FUNCTION domain.controller_info(IN p_controller_id integer)
  RETURNS TABLE(cpu1m integer, cpu5m integer) AS
$BODY$
BEGIN

	RETURN QUERY SELECT cpu_1m_threshold, cpu_5m_threshold FROM domain.controller WHERE id = p_controller_id;

END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT
  COST 100
  ROWS 1;
ALTER FUNCTION domain.controller_info(integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_info(integer) TO public;
GRANT EXECUTE ON FUNCTION domain.controller_info(integer) TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_info(integer) TO cl_controller_group;



CREATE OR REPLACE FUNCTION domain.controller_node_info(IN p_node_id integer)
  RETURNS TABLE(load integer) AS
$BODY$
BEGIN

	RETURN QUERY SELECT critical_load FROM domain.node WHERE id = p_node_id;

END;
$BODY$
  LANGUAGE plpgsql STABLE STRICT
  COST 100
  ROWS 1;
ALTER FUNCTION domain.controller_node_info(integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_node_info(integer) TO public;
GRANT EXECUTE ON FUNCTION domain.controller_node_info(integer) TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_node_info(integer) TO cl_controller_group;


-- Function: domain.controller_get_rates_for_gateways(text[], integer[], timestamp with time zone)

-- DROP FUNCTION domain.controller_get_rates_for_gateways(text[], integer[], timestamp with time zone);

CREATE OR REPLACE FUNCTION domain.controller_get_rates_for_gateways(
    IN p_number text[],
    IN p_gateway_ids integer[],
    IN p_timestamp timestamp with time zone)
  RETURNS TABLE(id bigint, rate numeric, currency character, rate_normalized numeric, timeband text, gateway_id integer, valid_from timestamp with time zone, valid_to timestamp with time zone, number text) AS
$BODY$
	DECLARE i_id BIGINT;
		i_rate NUMERIC;
		i_currency CHARACTER(3);
		i_rate_normalized NUMERIC;
		i_timeband RATE_TIMEBAND;
		i_gateway_id INT;
		i_validfrom TIMESTAMPTZ;
		i_validto TIMESTAMPTZ;
		i_number TEXT;
BEGIN
	CREATE TEMPORARY TABLE i_result (id BIGINT, rate NUMERIC, currency CHARACTER(3), rate_normalized NUMERIC, timeband TEXT,
		gateway_id INT, valid_to TIMESTAMPTZ, valid_from TIMESTAMPTZ, number TEXT) ON COMMIT DROP;

	FOREACH i_gateway_id IN ARRAY p_gateway_ids
	LOOP

		-- cache query gateway routing price flat
		SELECT cache_gateway_price.id, cache_gateway_price.price, cache_gateway_price.currency, cache_gateway_price.price_normalized, cache_gateway_price.timeband,
				cache_gateway_price.valid_from, cache_gateway_price.valid_to, cache_gateway_price.number
			INTO i_id, i_rate, i_currency, i_rate_normalized, i_timeband, i_validfrom, i_validto, i_number
			FROM cache_gateway_price 
			WHERE cache_gateway_price.number = ANY (p_number)
				AND cache_gateway_price.gateway_id = i_gateway_id
				AND cache_gateway_price.timeband = 'Flat'::rate_timeband
				AND p_timestamp BETWEEN cache_gateway_price.valid_from AND cache_gateway_price.valid_to
			ORDER BY numberlength DESC LIMIT 1;

		IF NOT FOUND THEN
			-- cache query gateway routing price non flat
			SELECT cache_gateway_price.id, cache_gateway_price.price, cache_gateway_price.currency, cache_gateway_price.price_normalized, cache_gateway_price.timeband,
				cache_gateway_price.valid_from, cache_gateway_price.valid_to, cache_gateway_price.number
				INTO i_id, i_rate, i_currency, i_rate_normalized, i_timeband, i_validfrom, i_validto, i_number
				FROM cache_gateway_price
				WHERE cache_gateway_price.number = ANY (p_number)
					AND p_timestamp BETWEEN cache_gateway_price.valid_from AND cache_gateway_price.valid_to
					AND cache_gateway_price.gateway_id = i_gateway_id AND 
					cache_gateway_price.timeband::rate_timeband IN (
						SELECT gateway_timeband.timeband FROM gateway_timeband
							WHERE p_timestamp BETWEEN gateway_timeband.valid_from AND gateway_timeband.valid_to
								AND p_timestamp::TIME BETWEEN gateway_timeband.time_from AND gateway_timeband.time_to
								AND day_of_week = extract('dow' from p_timestamp)
								AND gateway_timeband.gateway_id = i_gateway_id
									AND dialcode_master_id = (SELECT dialcode_master.id FROM dialcode_master
										WHERE dialcode = ANY (p_number)
										ORDER BY LENGTH(dialcode) DESC LIMIT 1)
										)
				ORDER BY numberlength DESC, price ASC LIMIT 1;

		END IF;

		IF i_id IS NOT NULL THEN
			INSERT INTO i_result (id, rate, currency, rate_normalized, timeband, gateway_id, valid_from, valid_to, number) 
			VALUES (i_id, i_rate, i_currency, i_rate_normalized, i_timeband, i_gateway_id, i_validfrom, i_validto, i_number);

			i_id := NULL;
		END IF;
	END LOOP;

	
	RETURN QUERY SELECT i_result.id, i_result.rate, i_result.currency, i_result.rate_normalized, i_result.timeband::TEXT,
		i_result.gateway_id, i_result.valid_from, i_result.valid_to, i_result.number
		FROM i_result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION domain.controller_get_rates_for_gateways(text[], integer[], timestamp with time zone)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_get_rates_for_gateways(text[], integer[], timestamp with time zone) TO cl_controller_group;




CREATE OR REPLACE FUNCTION domain.controller_get_number_gateway_statistic(
    IN p_number text[],
    IN p_gateway_ids integer[])
  RETURNS TABLE(id integer, asr numeric) AS
$BODY$
BEGIN
	RETURN QUERY SELECT DISTINCT ON (a.id) a.id, COALESCE(cngs.asr, 100)
		FROM (SELECT UNNEST(p_gateway_ids) AS id) a
		LEFT JOIN cache_number_gateway_statistics cngs ON cngs.gateway_id = a.id
			AND number = ANY(p_number)
		ORDER BY a.id, number DESC;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE LEAKPROOF STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION domain.controller_get_number_gateway_statistic(text[], integer[])
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_get_number_gateway_statistic(text[], integer[]) TO public;
GRANT EXECUTE ON FUNCTION domain.controller_get_number_gateway_statistic(text[], integer[]) TO postgres;
GRANT EXECUTE ON FUNCTION domain.controller_get_number_gateway_statistic(text[], integer[]) TO cl_controller_group;


CREATE UNIQUE INDEX ix_cngs_id ON domain.cache_number_gateway_statistics (id);


-- ##########################################
-- #########	Blending
-- ##########################################

ALTER TABLE domain.route ADD COLUMN blend_percentage INT;
ALTER TABLE domain.route ADD COLUMN blend_to_context_id INT;
ALTER TABLE domain.route ADD CONSTRAINT fk_route_blend_context FOREIGN KEY (blend_to_context_id) REFERENCES context (id);
ALTER TABLE domain.route ADD CONSTRAINT route_blend CHECK ( (blend_percentage IS NULL AND blend_to_context_id IS NULL)
													OR (blend_percentage IS NOT NULL AND blend_to_context_id IS NOT NULL) );


ALTER TABLE domain.context ADD COLUMN lcr_blend_percentage INT;
ALTER TABLE domain.context ADD COLUMN lcr_blend_to_context_id INT;
ALTER TABLE domain.context ADD CONSTRAINT fk_context_lcr_blend_context FOREIGN KEY (lcr_blend_to_context_id) REFERENCES context (id);
ALTER TABLE domain.context ADD CONSTRAINT context_lcr_blend CHECK ( (lcr_blend_percentage IS NULL AND lcr_blend_to_context_id IS NULL)
													OR (lcr_blend_percentage IS NOT NULL AND lcr_blend_to_context_id IS NOT NULL) );

DROP FUNCTION domain.controller_get_route_cache ();
CREATE FUNCTION domain.controller_get_route_cache ()
	RETURNS TABLE (id INT, context_id INT, pattern TEXT, action TEXT, sort INT, did BOOLEAN, caller TEXT, callername TEXT, ignore_missing_rate BOOLEAN,
		fallback_to_lcr BOOLEAN, timeout INT, blend_percentage INT, blend_to_context_id INT)
	LANGUAGE plpgsql STABLE LEAKPROOF STRICT ROWS 1
AS
$$
BEGIN
	RETURN QUERY SELECT DISTINCT route.id, route.context_id, route.pattern, route.action, route.sort, route.did, COALESCE(route.caller, '') AS caller,
				COALESCE(route.callername, '') AS callername, route.ignore_missing_rate, route.fallback_to_lcr, context.timeout,
				route.blend_percentage, route.blend_to_context_id
			FROM route
			LEFT JOIN route_to_target ON route_to_target.route_id = route.id
			LEFT JOIN gateway ON gateway.id = route_to_target.gateway_id AND gateway.enabled = true
			INNER JOIN context ON context.id = route.context_id
			WHERE route.enabled = true AND context.enabled = true
			ORDER BY context_id, sort DESC;
END;
$$;
GRANT EXECUTE ON FUNCTION domain.controller_get_route_cache () TO cl_controller_group;


DROP FUNCTION domain.controller_get_context_cache();
CREATE FUNCTION domain.controller_get_context_cache()
RETURNS TABLE (id INTEGER, least_cost_routing BOOLEAN, timeout INTEGER, enable_lcr_without_rate BOOLEAN, fork_connect_behavior SMALLINT,
	fork_connect_behavior_timeout INT, lcr_blend_percentage INT, lcr_blend_to_context_id INT)
AS
$$
BEGIN

	RETURN QUERY SELECT context.id, context.least_cost_routing, context.timeout, context.enable_lcr_without_rate,
		context.fork_connect_behavior, context.fork_connect_behavior_timeout,
		context.lcr_blend_percentage, context.lcr_blend_to_context_id
		FROM context
		WHERE deleted = false AND enabled = true;

END;
$$
LANGUAGE plpgsql STABLE STRICT;
GRANT EXECUTE ON FUNCTION domain.controller_get_context_cache() TO cl_controller_group;