----------- TABLE SCRIPTS -----------
SELECT domain.cron_new_cdr_table();

----------- GLOBAL -------------

INSERT INTO company (id, name) VALUES (1, 'Company1');
INSERT INTO company (id, name) VALUES (2, 'Company2');

INSERT INTO format (id, name) VALUES (1, 'g729');
INSERT INTO format (id, name) VALUES (2, 'alaw');
INSERT INTO format (id, name) VALUES (3, 'mulaw');

INSERT INTO exchange_rate_to_usd (currency, multiplier) VALUES ('EUR', 1.13);


INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (1, 'Deutschland', 'DEU', 'Deutschland Roc', false, '49212312', LENGTH('49212312'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (2, 'Deutschland', 'DEU', 'Deutschland Roc', false, '49', LENGTH('49'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (3, 'United States', 'USA', 'Unites States Roc', false, '1111', LENGTH('1111'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (4, 'Albania', 'ALB', 'Albania Roc', false, '355', LENGTH('355'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (5, 'None', 'NON', 'None Roc', false, '96', LENGTH('96'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (6, 'India', 'IND', 'India Roc', false, '912', LENGTH('912'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (7, 'Kazakhstan', 'KHZ', 'Kazakhstan Roc', false, '778', LENGTH('778'));

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (8, 'China', 'CHN', 'China Roc', false, '8', LENGTH('8'));
	
--GO

------------- PREROUTE ------------------
-- Preroute Test: TestCustomerUnknown
-- NO DATA REQURIED

-- Preroute Test: TestNodeSends
INSERT INTO node (id, name) VALUES (1, 'Yate1');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (1, '10.0.0.1/32'::inet, 1, 10000, 'Intern');
--GO

-- Preroute Test: TestCustomerAddressIncomplete
INSERT INTO context (id, name, enabled, deleted, least_cost_routing, timeout, fork_connect_behavior_timeout, fork_connect_behavior)
	VALUES (2101, 'Context2101', true, false, false, 1000, 10000, 1);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (101, 1, 'Customer101', 2101, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (4101, 101, '218.213.210.201/32'::inet);
--GO

-- Preroute Test: TestCustomerWithoutPrefix
INSERT INTO context (id, name, enabled, deleted, least_cost_routing, timeout, fork_connect_behavior_timeout, fork_connect_behavior)
	VALUES (2, 'Context2', true, false, false, 1000, 10000, 1);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (1, 1, 'Customer1', 2, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (3, 1, '218.213.210.207/32'::inet);
--GO

-- Preroute Test: TestCustomerWithPrefix
INSERT INTO context (id, name, enabled, deleted, least_cost_routing, timeout, fork_connect_behavior_timeout, fork_connect_behavior)
	VALUES (5, 'Context5', true, false, false, 1000, 10000, 1);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (4, 1, 'Customer4', 5, false, '0069#', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (6, 4, '218.213.210.207/32'::inet);
--GO

-- Preroute Test: TestCustomerLimitExceeded
INSERT INTO context (id, name, enabled, deleted, least_cost_routing, timeout, fork_connect_behavior_timeout, fork_connect_behavior)
	VALUES (8, 'Context81', true, false, false, 1000, 10000, 1);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, remaining_credit, qos_group_id)
	VALUES (7, 1, 'Customer7', 8, false, '', 0, 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (9, 7, '218.213.210.202/32'::inet);
--GO

---------- ROUTE --------------

-- Route Test: TestNumberBlacklistedPattern
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (2201, 'Context2201', true, 20000, 1, 1001);
INSERT INTO blacklist (pattern) VALUES ('^91.*$');
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (201, 1, 'Customer201', 2201, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (4201, 201, '218.213.210.5/32'::inet);
--GO

-- Route Test: TestHasPriceHasRouteHasLCRHasAD
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (250, 'Context250', true, 20000, 1, 1001);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50, 1, 'Customer50', 250, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (450, 50, '1.1.1.50/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(550, 'Gateway550', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 550);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 550);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 550);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(650, 550, '11.1.1.50', 5055, 'sip', '11.1.2.50'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (650, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (1, 650);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (150, 250, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (150, 550);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (350, CURRENT_DATE, 50);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (350, 50, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 350, '111150', 350);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (550, CURRENT_DATE, 550);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(27, 550, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111150', 550);
--GO

-- Route Test: TestNoPriceHasRouteNoLCRNoAD
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (262, 'Context262', true, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (100000, 1, 'Customer100000', 262, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (100461, 100000, '8.8.2.61/32'::inet);
--GO

-- Route Test: TestAddZeros, TestRTPEnabled
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (299, 'Context299', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (99, 1, 'Customer99', 299, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (499, 99, '1.1.1.99/32'::inet);
--GO

--  Route Test: TestNumberBlacklistedDirect
INSERT INTO blacklist (pattern) VALUES ('^9698559$');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (2010, 'Context2010', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (10, 1, 'Customer2010', 2010, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (11, 10, '10.10.15.13/32'::inet);
--GO

-- Route Test: TestRouteCausedError
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (2012, 'Context2012', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (12, 1, 'Customer2012', 2012, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (13, 12, '10.10.15.28/32'::inet);
--GO

-- Route Test: TestHasPriceHasRouteHasLCRNoAD
INSERT INTO node (id, name) VALUES (2, 'Yate2');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (2, '10.0.0.2/32'::inet, 2, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (251, 'Context251', true, 10000, 1, 1003);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (51, 1, 'Customer51', 251, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (451, 51, '1.1.1.51/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(551, 'Gateway551', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 551);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 551);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 551);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(651, 551, '11.1.1.51', 5055, 'sip', '11.1.2.51'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (651, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (2, 651);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (151, 251, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (151, 551);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (351, CURRENT_DATE,  51);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (351, 51, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 351, '111151', 351);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (551, CURRENT_DATE, 551);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(3, 551, 'Flat'::timeband, 0.003, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111151', 551);
--GO

-- Route Test: TestHasPriceHasRouteNoLCRHasAD
INSERT INTO node (id, name) VALUES (3, 'Yate3');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (3, '10.0.0.3/32'::inet, 3, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (252, 'Context252', false, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (52, 1, 'Customer52', 252, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (452, 52, '1.1.1.52/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(552, 'Gateway552', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 552);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 552);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 552);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(652, 552, '11.1.1.52', 5055, 'sip', '11.1.2.52'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (652, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (3, 652);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (152, 252, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (152, 552);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (352, CURRENT_DATE, 52);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (352, 52, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 352, '111152', 352);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (552, CURRENT_DATE, 552);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(28, 552, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111152', 552);
--GO

-- Route Test: TestHasPriceHasRouteNoLCRNoAD
INSERT INTO node (id, name) VALUES (4, 'Yate4');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (4, '10.0.0.4/32'::inet, 4, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (253, 'Context253', false, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (53, 1, 'Customer53', 253, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (453, 53, '1.1.1.53/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(553, 'Gateway553', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 553);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 553);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 553);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(653, 553, '11.1.1.53', 5055, 'sip', '11.1.2.53'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (653, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (4, 653);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (153, 253, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (153, 553);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (353, CURRENT_DATE, 53);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (353, 53, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 353, '111153', 353);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (553, CURRENT_DATE, 553);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(3000, 553, 'Flat'::timeband, 0.003, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111153', 553);
--GO

-- Route Test: TestHasPriceNoRouteHasLCRHasAD
INSERT INTO node (id, name) VALUES (5, 'Yate5');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (5, '10.0.0.5/32'::inet, 5, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (254, 'Context254', true, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (54, 1, 'Customer54', 254, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (454, 54, '1.1.1.54/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(555, 'Gateway555', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 555);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 555);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 555);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(655, 555, '11.1.1.55', 5055, 'sip', '11.1.2.55'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (655, 1, 0);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(254, 555);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (5, 655);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (354, CURRENT_DATE, 54);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (354, 54, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 354, '111154', 354);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (555, CURRENT_DATE, 555);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(5, 555, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111154', 555);
--GO

-- Route Test: TestHasPriceNoRouteHasLCRNoAD
INSERT INTO node (id, name) VALUES (6, 'Yate6');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (6, '10.0.0.6/32'::inet, 6, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (255, 'Context255', true, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (55, 1, 'Customer55', 255, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (455, 55, '1.1.1.55/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(556, 'Gateway556', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 556);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 556);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 556);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(656, 556, '11.1.1.56', 5055, 'sip', '11.1.2.56'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (656, 1, 0);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(255, 556);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (6, 656);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (355, CURRENT_DATE, 55);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (355, 55, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 355, '111155', 355);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (556, CURRENT_DATE, '556');
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(4, 556, 'Flat'::timeband, 0.06051, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111155', 556);
--GO

-- Route Test: TestHasPriceNoRouteNoLCRHasAD
INSERT INTO node (id, name) VALUES (7, 'Yate7');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (7, '10.0.0.7/32'::inet, 7, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (256, 'Context256', false, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (56, 1, 'Customer56', 256, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (456, 56, '1.1.1.56/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (356, CURRENT_DATE, 56);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (356, 56, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 356, '111156', 356);
--GO

-- Route Test: TestHasPriceNoRouteNoLCRNoAD
INSERT INTO node (id, name) VALUES (8, 'Yate8');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (8, '10.0.0.8/32'::inet, 8, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (257, 'Context257', false, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (57, 1, 'Customer57', 257, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (457, 57, '1.1.1.57/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (357, CURRENT_DATE, 57);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (357, 57, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 357, '111157', 357);
--GO

-- Route Test: TestNoPriceHasRouteHasLCRHasAD
INSERT INTO node (id, name) VALUES (9, 'Yate9');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (9, '10.0.0.9/32'::inet, 9, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (258, 'Context258', true, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (58, 1, 'Customer58', 258, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (458, 58, '1.1.1.58/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(557, 'Gateway557', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 557);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 557);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 557);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(657, 557, '11.1.1.57', 5055, 'sip', '11.1.2.57'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (657, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (9, 657);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate)
	VALUES (154, 258, '\1', false, '.*', '', '', 0, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (154, 557);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (557, CURRENT_DATE, 557);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(29, 557, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111158', 557);
--GO

-- Route Test: TestNoPriceHasRouteHasLCRNoAD
INSERT INTO node (id, name) VALUES (10, 'Yate10');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (10, '10.0.0.10/32'::inet, 10, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (259, 'Context259', true, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (59, 1, 'Customer59', 259, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (459, 59, '1.1.1.59/32'::inet);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate)
	VALUES (155, 259, '\1', false, '.*', '', '', 0, false);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(558, 'Gateway558', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 558);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 558);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 558);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (155, 558);
--GO

-- Route Test: TestNoPriceHasRouteNoLCRHasAD
INSERT INTO node (id, name) VALUES (11, 'Yate11');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (11, '10.0.0.11/32'::inet, 11, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (260, 'Context260', false, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (60, 1, 'Customer60', 260, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (460, 60, '1.1.1.60/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(559, 'Gateway559', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 559);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 559);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 559);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(658, 559, '11.1.1.60', 5056, 'sip', '11.1.2.60'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (658, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (11, 658);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate)
	VALUES (156, 260, '\1', false, '.*', '', '', 0, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (156, 559);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (559, CURRENT_DATE, 559);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(30, 559, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111160', 559);
--GO

-- Route Test: TestNoPriceHasRouteNoLCRNoAD
INSERT INTO node (id, name) VALUES (12, 'Yate12');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (12, '10.0.0.12/32'::inet, 12, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (261, 'Context261', false, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (61, 1, 'Customer61', 261, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (461, 61, '1.1.1.61/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(561, 'Gateway561', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 561);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 561);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 561);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(660, 561, '11.1.1.62', 5056, 'sip', '11.1.2.62'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (660, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (12, 660);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (157, 261, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (157, 561);
--GO

-- Route Test: TestNoPriceNoRouteHasLCRHasAD
INSERT INTO node (id, name) VALUES (13, 'Yate13');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (13, '10.0.0.13/32'::inet, 13, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout, enable_lcr_without_rate) VALUES (222, 'Context222', true, 10000, 1, 1002, true);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (62, 1, 'Customer62', 222, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (462, 62, '1.1.1.62/32'::inet);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(222, 561);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (561, CURRENT_DATE, 561);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(1, 561, 'Flat'::timeband, 1.02, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111', 561);
INSERT INTO gateway_ip_node(gateway_ip_id, node_id) VALUES (660, 13);
--GO

-- Route Test: TestNoPriceNoRouteHasLCRNoAD
INSERT INTO node (id, name) VALUES (14, 'Yate14');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (14, '10.0.0.14/32'::inet, 14, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (263, 'Context263', true, 10000, 1, 1002);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (63, 1, 'Customer63', 263, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (463, 63, '1.1.1.63/32'::inet);
--GO

-- Route Test: TestNoPriceNoRouteNoLCRHasAD
INSERT INTO node (id, name) VALUES (15, 'Yate15');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (15, '10.0.0.15/32'::inet, 15, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (264, 'Context264', false, 10000, 1, 1082);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (64, 1, 'Customer64', 264, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (464, 64, '1.1.1.64/32'::inet);
--GO

-- Route Test: TestNoPriceNoRouteNoLCRNoAD
INSERT INTO node (id, name) VALUES (16, 'Yate16');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (16, '10.0.0.16/32'::inet, 16, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (265, 'Context265', false, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (65, 1, 'Customer65', 265, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (465, 65, '1.1.1.65/32'::inet);
--GO

-- Route Test: TestWithPrefix
INSERT INTO node (id, name) VALUES (70, 'Yate70');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (70, '10.0.0.70/32'::inet, 70, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (270, 'Context270', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (70, 1, 'Customer70', 270, false, '00', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (470, 70, '1.1.1.70/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(570, 'Gateway570', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 570);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 570);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 570);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(670, 570, '11.1.1.70', 5056, 'sip', '11.1.2.70'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (670, 70, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (70, 670);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (170, 270, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (170, 570);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (370, CURRENT_DATE, 70);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (370, 70, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 370, '111170', 370);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (570, CURRENT_DATE, 570);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(40, 570, 'Flat'::timeband, 0.037, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111170', 570);
--GO

-- Route Test: TestFakeRinging
INSERT INTO node (id, name) VALUES (71, 'Yate71');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (71, '10.0.0.71/32'::inet, 71, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (271, 'Context271', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (71, 1, 'Customer71', 271, true, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (471, 71, '1.1.1.71/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(571, 'Gateway571', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 571);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 571);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 571);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(671, 571, '11.1.1.71', 5056, 'sip', '11.1.2.71'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (671, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (71, 671);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (171, 271, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (171, 571);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (371, CURRENT_DATE, 71);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (371, 71, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 371, '111171', 371);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (571, CURRENT_DATE, 571);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(14, 571, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111171', 571);
--GO

-- Route Test: TestDID
INSERT INTO node (id, name) VALUES (72, 'Yate72');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (72, '10.0.0.72/32'::inet, 72, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (272, 'Context272', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (72, 1, 'Customer72', 272, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (472, 72, '1.1.1.72/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(572, 'Gateway572', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 572);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 572);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 572);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(672, 572, '11.1.1.72', 5056, 'sip', '11.1.2.72'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (672, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (72, 672);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (172, 272, '99999999', true, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (172, 572);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (372, CURRENT_DATE, 72);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (372, 72, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 372, '111172', 372);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (572, CURRENT_DATE, 572);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(13, 572, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111172', 572);
--GO

-- Route Test: TestGatewayLimitExceeded
INSERT INTO node (id, name) VALUES (73, 'Yate73');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (73, '10.0.0.73/32'::inet, 73, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (273, 'Context273', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (73, 1, 'Customer73', 273, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (473, 73, '1.1.1.73/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, hour_limit, qos_group_id)
VALUES(573, 'Gateway573', 'IP'::gatewaytype, 2, 1, '', false, null, null, 10, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 573);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 573);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 573);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(673, 573, '11.1.1.73', 5056, 'sip', '11.1.2.73'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (673, 1, 0);
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (673, 1, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (73, 673);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (173, 273, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (173, 573);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (373, CURRENT_DATE, 73);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (373, 73, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 373, '111173', 373);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (573, CURRENT_DATE, 573);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(159988, 573, 'Flat'::timeband, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111173', 573);
--GO

-- Route Test: TestCorrectCallerBracket
INSERT INTO node (id, name) VALUES (74, 'Yate74');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (74, '10.0.0.74/32'::inet, 74, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (274, 'Context274', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (74, 1, 'Customer74', 274, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (474, 74, '1.1.1.74/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(574, 'Gateway574', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 574);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 574);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 574);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(674, 574, '11.1.1.74', 5056, 'sip', '11.1.2.74'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (674, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (74, 674);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (174, 274, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (174, 574);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (374, CURRENT_DATE, 74);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (374, 74, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 374, '111174', 374);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (574, CURRENT_DATE, 574);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(7, 574, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111174', 574);
--GO

-- Route Test: TestCorrectCallernameBracket
INSERT INTO node (id, name) VALUES (75, 'Yate75');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (75, '10.0.0.75/32'::inet, 75, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (275, 'Context275', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (75, 1, 'Customer75', 275, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (475, 75, '1.1.1.75/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(575, 'Gateway575', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 575);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 575);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 575);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(675, 575, '11.1.1.75', 5056, 'sip', '11.1.2.75'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (675, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (75, 675);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (175, 275, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (175, 575);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (375, CURRENT_DATE, 75);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (375, 75, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 375, '111175', 375);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (575, CURRENT_DATE, 575);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(9, 575, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111175', 575);
--GO

-- Route Test: TestCorrectCallerWhitespace
INSERT INTO node (id, name) VALUES (76, 'Yate76');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (76, '10.0.0.76/32'::inet, 76, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (276, 'Context276', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (76, 1, 'Customer76', 276, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (476, 76, '1.1.1.76/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(576, 'Gateway576', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 576);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 576);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 576);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(676, 576, '11.1.1.76', 5056, 'sip', '11.1.2.76'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (676, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (76, 676);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (176, 276, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (176, 576);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (376, CURRENT_DATE, 76);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (376, 76, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 376, '111176', 376);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (576, CURRENT_DATE, 576);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(12, 576, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111176', 576);
--GO

-- Route Test: TestCorrectCallernameWhitespace
INSERT INTO node (id, name) VALUES (77, 'Yate77');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (77, '10.0.0.77/32'::inet, 77, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (277, 'Context277', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (77, 1, 'Customer77', 277, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (477, 77, '1.1.1.77/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(577, 'Gateway577', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 577);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 577);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 577);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(677, 577, '11.1.1.77', 5056, 'sip', '11.1.2.77'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (677, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (77, 677);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (177, 277, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (177, 577);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (377, CURRENT_DATE, 77);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (377, 77, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 377, '111177', 377);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (577, CURRENT_DATE, 577);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(11, 577, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111177', 577);
--GO

-- Route Test: TestCorrectCallerIncorrect
INSERT INTO node (id, name) VALUES (78, 'Yate78');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (78, '10.0.0.78/32'::inet, 78, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (278, 'Context278', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (78, 1, 'Customer78', 278, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (478, 78, '1.1.1.78/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(578, 'Gateway578', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 578);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 578);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 578);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(678, 578, '11.1.1.78', 5056, 'sip', '11.1.2.78'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (678, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (78, 678);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (178, 278, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (178, 578);
INSERT INTO incorrect_callername (name, replacement) VALUES ('abc', 'anonymous');
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (378, CURRENT_DATE, 78);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (378, 78, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 378, '111178', 378);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (578, CURRENT_DATE, 578);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(8, 578, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111178', 578);
--GO

-- Route Test: TestCorrectCallernameIncorrect
INSERT INTO node (id, name) VALUES (79, 'Yate79');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (79, '10.0.0.79/32'::inet, 79, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (279, 'Context279', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (79, 1, 'Customer79', 279, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (479, 79, '1.1.1.79/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(579, 'Gateway579', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 579);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 579);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 579);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(679, 579, '11.1.1.79', 5056, 'sip', '11.1.2.79'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (679, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (79, 679);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (179, 279, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (179, 579);
INSERT INTO incorrect_callername (name, replacement) VALUES ('009911111', '009911112');
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (379, CURRENT_DATE, 79);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (379, 79, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 379, '111179', 379);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (579, CURRENT_DATE, 579);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(10, 579, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111179', 579);
--GO

-- Route Test: TestGatewayAccount
INSERT INTO node (id, name) VALUES (80, 'Yate80');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (80, '10.0.0.80/32'::inet, 80, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (280, 'Context280', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (80, 1, 'Customer80', 280, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (480, 80, '1.1.1.80/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(580, 'Gateway580', 'Account'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 580);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 580);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 580);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (780, 580, 'acc80', '', '', 'sip', 80);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (780, 1, 80000);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (180, 280, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (180, 580);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (380, CURRENT_DATE, 80);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (380, 80, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 380, '111180', 380);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (580, CURRENT_DATE, 580);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6, 580, 'Flat'::timeband, 0.033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111180', 580);
--GO

-- Route Test: TestGatewayAccountNewCaller
INSERT INTO node (id, name) VALUES (81, 'Yate81');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (81, '10.0.0.81/32'::inet, 81, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (281, 'Context281', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (81, 1, 'Customer81', 281, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (481, 81, '1.1.1.81/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, hour_limit, currency, qos_group_id)
VALUES(581, 'Gateway581', 'Account'::gatewaytype, 2, 1, '', false, null, null, 10, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 581);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 581);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 581);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (781, 581, 'acc81', '002299', '', 'sip', 81);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (781, 1, 80000);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (181, 281, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (181, 581);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (381, CURRENT_DATE, 81);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (381, 81, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 381, '111181', 381);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (581, CURRENT_DATE, 581);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(19, 581, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111181', 581);
--GO

-- Route Test: TestGatewayAccountNewCallername
INSERT INTO node (id, name) VALUES (82, 'Yate82');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (82, '10.0.0.82/32'::inet, 82, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (282, 'Context282', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (82, 1, 'Customer82', 282, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (482, 82, '1.1.1.82/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(582, 'Gateway582', 'Account'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 582);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 582);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 582);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (782, 582, 'acc82', '', '002299', 'sip', 82);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (782, 1, 80000);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (182, 282, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (182, 582);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (382, CURRENT_DATE, 82);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (382, 82, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 382, '111182', 382);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (582, CURRENT_DATE, 582);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(20, 582, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111182', 582);
--GO

-- Route Test: TestNumberModificationGroupBoth
INSERT INTO node (id, name) VALUES (83, 'Yate83');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (83, '10.0.0.83/32'::inet, 83, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (983, 'NMG983');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9831, '^778.*$', '77', '00', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (983, 9831);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (283, 'Context283', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (83, 1, 'Customer83', 283, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (483, 83, '1.1.1.83/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(583, 'Gateway583', 'IP'::gatewaytype, 2, 1, '', false, null, 983, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 583);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 583);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 583);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(683, 583, '11.1.1.83', 5056, 'sip', '11.1.2.83'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (683, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (83, 683);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (183, 283, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (183, 583);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (383, CURRENT_DATE, 83);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (383, 83, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 383, '77811111', 383);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (583, CURRENT_DATE, 583);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(34, 583, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77811111', 583);
--GO

--  Route Test: TestNumberModificationGroupRemovePrefix
INSERT INTO node (id, name) VALUES (84, 'Yate84');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (84, '10.0.0.84/32'::inet, 84, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (984, 'NMG984');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9841, '^778.*$', '77', '', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (984, 9841);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (284, 'Context284', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (84, 1, 'Customer84', 284, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (484, 84, '1.1.1.84/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(584, 'Gateway584', 'IP'::gatewaytype, 2, 1, '', false, null, 984, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 584);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 584);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 584);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(684, 584, '11.1.1.84', 5056, 'sip', '11.1.2.84'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (684, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (84, 684);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (184, 284, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (184, 584);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (384, CURRENT_DATE, 84);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (384, 84, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 384, '77811112', 384);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (584, CURRENT_DATE, 584);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(39, 584, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77811112', 584);
--GO

-- Route Test: TestNumberModificationGroupAddPrefix
INSERT INTO node (id, name) VALUES (85, 'Yate85');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (85, '10.0.0.85/32'::inet, 85, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (985, 'NMG985');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9851, '^778.*$', '', '00', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (985, 9851);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (285, 'Context285', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (85, 1, 'Customer85', 285, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (485, 85, '1.1.1.85/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(585, 'Gateway585', 'IP'::gatewaytype, 2, 1, '', false, null, 985, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 585);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 585);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 585);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(685, 585, '11.1.1.85', 5056, 'sip', '11.1.2.85'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (685, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (85, 685);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (185, 285, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (185, 585);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (385, CURRENT_DATE, 85);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (385, 85, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 385, '77811113', 385);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (585, CURRENT_DATE, 585);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(33, 585, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77811113', 585);
--GO

-- Route Test: TestNumberModificationGroupBoth2
INSERT INTO node (id, name) VALUES (86, 'Yate86');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (86, '10.0.0.86/32'::inet, 86, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (986, 'NMG986');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9861, '^778.*$', '778', '0055', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (986, 9861);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (286, 'Context286', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (86, 1, 'Customer86', 286, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (486, 86, '1.1.1.86/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(586, 'Gateway586', 'IP'::gatewaytype, 2, 1, '', false, null, 986, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 586);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 586);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 586);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(686, 586, '11.1.1.86', 5056, 'sip', '11.1.2.86'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (686, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (86, 686);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (186, 286, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (186, 586);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (386, CURRENT_DATE, 86);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (386, 86, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 386, '77811114', 386);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (586, CURRENT_DATE, 586);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(35, 586, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77811114', 586);
--GO

-- Route Test: TestNumberModificationGroupNotMatching
INSERT INTO node (id, name) VALUES (87, 'Yate87');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (87, '10.0.0.87/32'::inet, 87, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (987, 'NMG987');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9871, '^770.*$', '77', '00', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (987, 9871);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (287, 'Context287', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (87, 1, 'Customer87', 287, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (487, 87, '1.1.1.87/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(587, 'Gateway587', 'IP'::gatewaytype, 2, 1, '', false, null, 987, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 587);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 587);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 587);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(687, 587, '11.1.1.87', 5056, 'sip', '11.1.2.87'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (687, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (87, 687);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (187, 287, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (187, 587);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (387, CURRENT_DATE, 87);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (387, 87, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 387, '77811115', 387);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (587, CURRENT_DATE, 587);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(38, 587, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77811115', 587);
--GO

-- Route Test: TestNumberModificationGroupMultiplePolicies
INSERT INTO node (id, name) VALUES (88, 'Yate88');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (88, '10.0.0.88/32'::inet, 88, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (988, 'NMG988');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9881, '^7781.*$', '77', '0081', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9882, '^7782.*$', '77', '0082', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9883, '^778.*$', '77', '0083', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9884, '^77.*$', '77', '0084', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9885, '^7.*$', '77', '0085', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (988, 9881);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (988, 9882);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (988, 9883);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (988, 9884);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (988, 9885);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (288, 'Context288', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (88, 1, 'Customer88', 288, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (488, 88, '1.1.1.88/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(588, 'Gateway588', 'IP'::gatewaytype, 2, 1, '', false, null, 988, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 588);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 588);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 588);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(688, 588, '11.1.1.88', 5056, 'sip', '11.1.2.88'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (688, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (88, 688);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (188, 288, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (188, 588);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (388, CURRENT_DATE, 88);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (388, 88, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 388, '77801116', 388);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (588, CURRENT_DATE, 588);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(36, 588, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77801116', 588);
--GO

-- Route Test: TestNumberModificationGroupMultiplePoliciesNotMatching
INSERT INTO node (id, name) VALUES (89, 'Yate89');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (89, '10.0.0.89/32'::inet, 89, 10000, 'Public');
INSERT INTO number_modification_group (id, name) VALUES (989, 'NMG988');
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9891, '^7781.*$', '77', '0081', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9892, '^7782.*$', '77', '0082', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9893, '^7783.*$', '77', '0083', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9894, '^75.*$', '77', '0084', 1);
INSERT INTO number_modification (id, pattern, remove_prefix, add_prefix, sort)
	VALUES (9895, '^76.*$', '77', '0085', 1);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (989, 9891);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (989, 9892);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (989, 9893);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (989, 9894);
INSERT INTO number_modification_group_number_modification (number_modification_group_id, number_modification_id)
	VALUES (989, 9895);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (289, 'Context289', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (89, 1, 'Customer89', 289, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (489, 89, '1.1.1.89/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(589, 'Gateway589', 'IP'::gatewaytype, 2, 1, '', false, null, 989, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 589);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 589);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 589);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(689, 589, '11.1.1.89', 5056, 'sip', '11.1.2.89'::inet, 6056, false, '');
--INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
--	VALUES (689, 1, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (89, 689);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (189, 289, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (189, 589);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (389, CURRENT_DATE, 89);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (389, 89, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 389, '77801117', 389);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (589, CURRENT_DATE, 589);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(37, 589, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '77801117', 589);
--GO

-- Route Test: TestGatewayIPThreeIPsOnlyConnectToOneDestination
INSERT INTO node (id, name) VALUES (90, 'Yate90');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (90, '10.0.0.90/32'::inet, 90, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (290, 'Context290', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (90, 1, 'Customer90', 290, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (490, 90, '1.1.1.90/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(590, 'Gateway590', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 590);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 590);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 590);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(690, 590, '11.1.1.90', 5056, 'sip', '11.1.2.90'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (690, 1, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6901, 590, '11.1.3.90', 5056, 'sip', '11.1.2.90'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6901, 1, 2);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (390, CURRENT_DATE, 90);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (390, 90, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 390, '111190', 390);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (590, CURRENT_DATE, 590);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(25, 590, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111190', 590);
INSERT INTO context_gateway (context_id, gateway_id) VALUES (290, 590);
INSERT INTO gateway_ip_node (gateway_ip_id, node_id) VALUES (690, 90);
INSERT INTO gateway_ip_node (gateway_ip_id, node_id) VALUES (6901, 90);
--GO

-- Route Test: TestGatewayAccountTwoAccOnlyConnectToOneDestination
INSERT INTO node (id, name) VALUES (91, 'Yate91');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (91, '10.0.0.91/32'::inet, 91, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (291, 'Context291', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (91, 1, 'Customer91', 291, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (491, 91, '1.1.1.91/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(591, 'Gateway591', 'Account'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 591);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 591);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 591);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7912, 591, 'acc912', '', '', 'sip', 91);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7912, 1, 2);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7911, 591, 'acc911', '', '', 'sip', 91);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7911, 1, 1);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7913, 591, 'acc913', '', '', 'sip', 91);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7913, 1, 3);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (191, 291, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (191, 591);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (391, CURRENT_DATE, 91);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (391, 91, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 391, '111191', 391);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (591, CURRENT_DATE, 591);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(22, 591, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111191', 591);
--GO

-- Route Test: TestGatewayIPThreeIPsConnectLowestBilltime
INSERT INTO node (id, name) VALUES (92, 'Yate92');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (92, '10.0.0.92/32'::inet, 92, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (292, 'Context292', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (92, 1, 'Customer92', 292, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (492, 92, '1.1.1.92/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(592, 'Gateway592', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 592);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 592);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 592);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6923, 592, '11.1.3.92', 5056, 'sip', '11.1.5.92'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6923, 1, 3);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(692, 592, '11.1.1.92', 5056, 'sip', '11.1.2.92'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (692, 1, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6921, 592, '11.1.3.92', 5057, 'sip', '11.1.4.92'::inet, 6057, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6921, 1, 2);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (92, 6923);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (92, 692);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (92, 6921);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (192, 292, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (192, 592);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (392, CURRENT_DATE, 92);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (392, 92, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 392, '111192', 392);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (592, CURRENT_DATE, 592);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(26, 592, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111192', 592);
--GO

-- Route Test: TestGatewayAccountThreeAccOnlyConnectLowestBilltime
INSERT INTO node (id, name) VALUES (93, 'Yate93');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (93, '10.0.0.93/32'::inet, 93, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (293, 'Context293', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (93, 1, 'Customer93', 293, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (493, 93, '1.1.1.93/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(593, 'Gateway593', 'Account'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 593);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 593);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 593);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7932, 593, 'acc932', '', '', 'sip', 93);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7932, 1, 2);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7931, 593, 'acc931', '', '', 'sip', 93);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7931, 1, 1);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7933, 593, 'acc933', '', '', 'sip', 93);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7933, 1, 3);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (193, 293, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (193, 593);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (393, CURRENT_DATE, 93);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price,  number, customer_pricelist_id)
	VALUES (393, 93, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 393, '111193', 393);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (593, CURRENT_DATE, 593);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(21, 593, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111193', 593);
--GO

-- Route Test: TestGatewayAccountIPMixedDrop
INSERT INTO node (id, name) VALUES (94, 'Yate94');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (94, '10.0.0.94/32'::inet, 94, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (294, 'Context294', true, 10000, 2, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (94, 1, 'Customer94', 294, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (494, 94, '1.1.1.94/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(5941, 'Gateway5941', 'Account'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 5941);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 5941);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 5941);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(5942, 'Gateway5942', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 5942);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 5942);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 5942);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (794, 5941, 'acc94', '', '', 'sip', 94);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (794, 1, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(694, 5942, '11.1.1.94', 5056, 'sip', '11.1.2.94'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (694, 1, 3);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (94, 694);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (194, 294, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (194, 5941, 1);
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (194, 5942, 2);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (394, CURRENT_DATE, 94);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (394, 94, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 394, '111194', 394);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (5941, CURRENT_DATE, 5941);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(15, 5941, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111194', 5941);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (5942, CURRENT_DATE, 5942);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(16, 5942, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111194', 5942);
--GO

-- Route Test: TestGatewayAccountSufficientNodes
INSERT INTO node (id, name) VALUES (95, 'Yate95');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (95, '10.0.0.95/32'::inet, 95, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (295, 'Contxt295', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (95, 1, 'Customer95', 295, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (495, 95, '1.1.1.95/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(595, 'Gateway595', 'Account'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 595);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 595);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 595);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7951, 595, 'acc951', '', '', 'sip', 95);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7951, 1, 2);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7952, 595, 'acc952', '', '', 'sip', 95);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7952, 1, 3);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7953, 595, 'acc953', '', '', 'sip', 95);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7953, 1, 1);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (195, 295, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (195, 595);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (395, CURRENT_DATE,  95);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (395, 95, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 395, '111195', 395);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (595, CURRENT_DATE, 595);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(18, 595, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111195', 595);
--GO

-- Route Test: TestGatewayAccountInsufficientNodes
INSERT INTO node (id, name) VALUES (96, 'Yate96');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (96, '10.0.0.96/32'::inet, 96, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (296, 'Context296', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (96, 1, 'Customer96', 296, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (496, 96, '1.1.1.96/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(596, 'Gateway596', 'Account'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 596);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 596);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 596);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7961, 596, 'acc961', '', '', 'sip', 96);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7961, 1, 4);
INSERT INTO gateway_account (id, gateway_id, account, new_caller, new_callername, protocol, node_id)
	VALUES (7962, 596, 'acc962', '', '', 'sip', 96);
INSERT INTO gateway_account_statistic (gateway_account_id, node_id, billtime)
	VALUES (7962, 1, 3);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (196, 296, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (196, 596);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (396, CURRENT_DATE, 96);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (396, 96, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 396,'111196', 396);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (596, CURRENT_DATE, 596);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(17, 596, 'Flat'::timeband, 0.034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111196', 596);
--GO

-- Route Test: TestGatewayIPSufficientNodes
INSERT INTO node (id, name) VALUES (97, 'Yate97');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (97, '10.0.0.97/32'::inet, 97, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (297, 'Context297', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (97, 1, 'Customer97', 297, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (497, 97, '1.1.1.97/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(597, 'Gateway597', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 597);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 597);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 597);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6972, 597, '11.1.7.97', 5056, 'sip', '11.1.6.97'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6972, 1, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6971, 597, '11.1.8.97', 5057, 'sip', '11.1.5.97'::inet, 6057, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6971, 1, 2);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (97, 6972);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (97, 6971);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (197, 297, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (197, 597);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (397, CURRENT_DATE, 97);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (397, 97, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 397, '111197', 397);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (597, CURRENT_DATE, 597);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(24, 597, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111197', 597);
--GO

-- Route Test: TestGatewayIPInsufficientNodes
INSERT INTO node (id, name) VALUES (98, 'Yate98');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (98, '10.0.0.98/32'::inet, 98, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (298, 'Context298', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (98, 1, 'Customer98', 298, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (498, 98, '1.1.1.98/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(598, 'Gateway598', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 598);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 598);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 598);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6982, 598, '11.1.8.92', 5056, 'sip', '11.1.5.92'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6982, 1, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6981, 598, '11.1.7.91', 5057, 'sip', '11.1.6.91'::inet, 6057, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6981, 1, 2);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (98, 6982);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (98, 6981);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (198, 298, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (198, 598);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (398, CURRENT_DATE, 98);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (398, 98, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 398, '111198', 398);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (598, CURRENT_DATE, 598);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(23, 598, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111198', 598);
--GO

-- Route Test: TestRTPEnabled
INSERT INTO node (id, name) VALUES (99, 'Yate99');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (99, '10.0.0.99/32'::inet, 99, 10000, 'Public');
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(599, 'Gateway599', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 599);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 599);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 599);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(699, 599, '11.1.1.99', 5057, 'sip', '11.1.2.99'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (699, 1, 2);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (99, 699);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (199, 299, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (199, 599);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (399, CURRENT_DATE, 99);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (399, 99, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 399, '111199', 399);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (599, CURRENT_DATE, 599);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(32, 599, 'Flat'::timeband, 0.036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111199', 599);
--GO

-- Route Test: TestRouteToNode
INSERT INTO node (id, name) VALUES (1000, 'Yate1000');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (1000, '10.0.0.101/32'::inet, 1000, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (2100, 'Context2100', true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (100, 1, 'Customer100', 2100, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (4100, 100, '1.1.1.100/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, currency, qos_group_id)
VALUES(5100, 'Gateway5100', 'IP'::gatewaytype, 2, 1, '', false, null, null, 'EUR', 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 5100);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 5100);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 5100);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (1100, 2100, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (1100, 5100);
INSERT INTO node_ip (id, node_id, address, port, network) VALUES (100, 1000, '10.0.1.100/32'::INET, 5221, 'Intern');
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100, 5100, '10.10.10.100', 5055, 'sip', '11.11.11.100'::inet, 6055, false, '');
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (1000, 6100);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (3100, CURRENT_DATE, 100);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (3100, 100, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 310, '1111100', 3100);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (5100, CURRENT_DATE, 5100);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(31, 5100, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111100', 5100);
--GO

-- Route Test: TestRouteFromNode
INSERT INTO node (id, name) VALUES (1001, 'Yate1001');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (1001, '10.0.0.102/32'::inet, 1001, 10000, 'Public');
-- incoming node
INSERT INTO node (id, name) VALUES (1010, 'Yate1010');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (1010, '1.1.2.100/32'::inet, 1010, 10000, 'Intern');
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(5101, 'Gateway5101', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 5101);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 5101);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 5101);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6101, 5101, '11.1.1.101', 5057, 'sip', '11.1.2.101'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6101, 1001, 2);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (1001, 6101);
-- // TODO: Kein Gateway Price?
--GO

-- Route Test: TestGatewayLCRWith3Routes
INSERT INTO node (id, name) VALUES (1002, 'Yate1002');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (1002, '10.0.0.198/32'::inet, 1002, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (2102, 'Context2102',true, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (102, 1, 'Customer102', 2102, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (4102, 102, '10.10.10.10/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(51031, 'Gateway51031', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 51031);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 51031);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 51031);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(51032, 'Gateway51032', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 51032);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 51032);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 51032);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(51033, 'Gateway51033', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 51033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 51033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 51033);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6103, 51031, '11.10.10.102', 5057, 'sip', '11.10.20.102'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6103, 1002, 5);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6104, 51032, '11.10.10.103', 5057, 'sip', '11.10.20.103'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6104, 1002, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6105, 51033, '11.10.10.104', 5057, 'sip', '11.10.20.104'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6105, 1002, 4);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(2102, 51031);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(2102, 51032);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(2102, 51033);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (1002, 6103);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (1002, 6104);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (1002, 6105);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (3102, CURRENT_DATE,  102);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (3102, 102, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 312, 1111101, 3102);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (51031, CURRENT_DATE, 51031);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(42, 51031, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 51031);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (51032, CURRENT_DATE, 51032);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(43, 51032, 'Flat'::timeband, 0.03,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 51032);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (51033, CURRENT_DATE, 51033);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(44, 51033, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 51033);
INSERT INTO cache_number_gateway_statistic (gateway_id, number, asr, working, total)
	VALUES (51031, '1111101', 70, 70, 100);
INSERT INTO cache_number_gateway_statistic (gateway_id, number, asr, working, total)
	VALUES (51032, '1111101', 72, 70, 90);
INSERT INTO cache_number_gateway_statistic (gateway_id, number, asr, working, total)
	VALUES (51033, '1111101', 71, 70, 80);

--GO


-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------


------ ROUTING DECISION TESTS

INSERT INTO dialcode_master (id, destination, iso3, carrier, is_mobile, dialcode, dialcode_length)
	VALUES (20000, 'None', 'NON', 'NONE Roc', false, '1000', LENGTH('1000'));

--GO



-- Routing Decision Test: TestDecisionRaRoImrFtlLElwr

INSERT INTO node (id, name) VALUES (30000, 'Yate30000');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31000, '3.1.0.0/32'::inet, 30000, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40000, 'Context40000', true, true, 10001, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50000, 2, 'Customer50000', 40000, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51000, 50000, '5.1.0.0/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52000, CURRENT_DATE, 50000);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53000, 50000, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52000);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60000, 'Gateway60000', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61000, 60000, '6.1.0.0', 5055, 'sip', '6.1.0.0'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61000, 30000, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30000, 61000);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62000, CURRENT_DATE, 60000);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63000, 60000, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60000);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70000, 40000, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70000, 60000);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40000, 60000);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600001, 'Gateway600001', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610001, 600001, '6.1.0.100', 5055, 'sip', '6.1.0.100'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610001, 30000, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30000, 610001);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620001, CURRENT_DATE, 600001);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630001, 600001, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600001);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40000, 600001);

--GO


-- Routing Decision Test: TestDecisionRaRoImrFtlL

INSERT INTO node (id, name) VALUES (30001, 'Yate30001');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31001, '3.1.0.1/32'::inet, 30001, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40001, 'Context40001', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50001, 2, 'Customer50001', 40001, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51001, 50001, '5.1.0.1/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52001, CURRENT_DATE, 50001);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53001, 50001, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52001);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60001, 'Gateway60001', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61001, 60001, '6.1.0.1', 5055, 'sip', '6.1.0.1'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61001, 30001, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30001, 61001);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62001, CURRENT_DATE, 60001);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63001, 60001, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60001);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70001, 40001, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70001, 60001);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600011, 'Gateway600011', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610011, 600011, '6.1.0.101', 5055, 'sip', '6.1.0.101'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610011, 30001, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30001, 610011);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620011, CURRENT_DATE, 600011);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630011, 600011, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620011);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600011);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600011);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600011);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40001, 600011);

--GO


-- Routing Decision Test: TestDecisionRaRoImrFtlElwr

INSERT INTO node (id, name) VALUES (30002, 'Yate30002');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31002, '3.1.0.2/32'::inet, 30002, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40002, 'Context40002', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50002, 2, 'Customer50002', 40002, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51002, 50002, '5.1.0.2/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52002, CURRENT_DATE, 50002);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53002, 50002, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52002);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60002, 'Gateway60002', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61002, 60002, '6.1.0.2', 5055, 'sip', '6.1.0.2'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61002, 30002, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30002, 61002);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62002, CURRENT_DATE, 60002);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63002, 60002, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60002);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70002, 40002, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70002, 60002);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600022, 'Gateway600022', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610022, 600022, '6.1.0.102', 5055, 'sip', '6.1.0.102'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610022, 30002, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30002, 610022);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620022, CURRENT_DATE, 600022);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630022, 600022, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620022);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600022);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600022);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600022);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40002, 600022);

--GO


-- Routing Decision Test: TestDecisionRaRoImrFtl

INSERT INTO node (id, name) VALUES (30003, 'Yate30003');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31003, '3.1.0.3/32'::inet, 30003, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40003, 'Context40003', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50003, 2, 'Customer50003', 40003, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51003, 50003, '5.1.0.3/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52003, CURRENT_DATE, 50003);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53003, 50003, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52003);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60003, 'Gateway60003', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61003, 60003, '6.1.0.3', 5055, 'sip', '6.1.0.3'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61003, 30003, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30003, 61003);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62003, CURRENT_DATE, 60003);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63003, 60003, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60003);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70003, 40003, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70003, 60003);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600033, 'Gateway600033', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610033, 600033, '6.1.0.103', 5055, 'sip', '6.1.0.103'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610033, 30003, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30003, 610033);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620033, CURRENT_DATE, 600033);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630033, 600033, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600033);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40003, 600033);

--GO


-- Routing Decision Test: TestDecisionRaRoImrLElwr


INSERT INTO node (id, name) VALUES (30004, 'Yate30004');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31004, '3.1.0.4/32'::inet, 30004, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40004, 'Context40004', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50004, 2, 'Customer50004', 40004, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51004, 50004, '5.1.0.4/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52004, CURRENT_DATE, 50004);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53004, 50004, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52004);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60004, 'Gateway60004', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61004, 60004, '6.1.0.4', 5055, 'sip', '6.1.0.4'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61004, 30004, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30004, 61004);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62004, CURRENT_DATE, 60004);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63004, 60004, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62004);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60004);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60004);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60004);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70004, 40004, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70004, 60004);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600044, 'Gateway600044', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610044, 600044, '6.1.0.104', 5055, 'sip', '6.1.0.104'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610044, 30004, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30004, 610044);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620044, CURRENT_DATE, 600044);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630044, 600044, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620044);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600044);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600044);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600044);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40004, 600044);

--GO


-- Routing Decision Test: TestDecisionRaRoImrL

INSERT INTO node (id, name) VALUES (30005, 'Yate30005');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31005, '3.1.0.5/32'::inet, 30005, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40005, 'Context40005', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50005, 2, 'Customer50005', 40005, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51005, 50005, '5.1.0.5/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52005, CURRENT_DATE, 50005);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53005, 50005, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52005);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60005, 'Gateway60005', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61005, 60005, '6.1.0.5', 5055, 'sip', '6.1.0.5'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61005, 30005, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30005, 61005);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62005, CURRENT_DATE, 60005);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63005, 60005, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62005);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60005);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60005);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60005);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70005, 40005, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70005, 60005);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600055, 'Gateway600055', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610055, 600055, '6.1.0.105', 5055, 'sip', '6.1.0.105'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610055, 30005, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30005, 610055);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620055, CURRENT_DATE, 600055);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630055, 600055, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620055);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600055);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600055);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600055);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40005, 600055);

--GO


-- Routing Decision Test: TestDecisionRaRoImrElwr

INSERT INTO node (id, name) VALUES (30006, 'Yate30006');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31006, '3.1.0.6/32'::inet, 30006, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40006, 'Context40006', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50006, 2, 'Customer50006', 40006, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51006, 50006, '5.1.0.6/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52006, CURRENT_DATE, 50006);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53006, 50006, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52006);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60006, 'Gateway60006', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61006, 60006, '6.1.0.6', 5055, 'sip', '6.1.0.6'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61006, 30006, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30006, 61006);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62006, CURRENT_DATE, 60006);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63006, 60006, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60006);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70006, 40006, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70006, 60006);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600066, 'Gateway600066', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610066, 600066, '6.1.0.106', 5055, 'sip', '6.1.0.106'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610066, 30006, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30006, 610066);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620066, CURRENT_DATE, 600066);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630066, 600066, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620066);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600066);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600066);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600066);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40006, 600066);

--GO


-- Routing Decision Test: TestDecisionRaRoImr

INSERT INTO node (id, name) VALUES (30007, 'Yate30007');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31007, '3.1.0.7/32'::inet, 30007, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40007, 'Context40007', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50007, 2, 'Customer50007', 40007, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51007, 50007, '5.1.0.7/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52007, CURRENT_DATE, 50007);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53007, 50007, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52007);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60007, 'Gateway60007', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61007, 60007, '6.1.0.7', 5055, 'sip', '6.1.0.7'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61007, 30007, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30007, 61007);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62007, CURRENT_DATE, 60007);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63007, 60007, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60007);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70007, 40007, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70007, 60007);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600077, 'Gateway600077', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610077, 600077, '6.1.0.107', 5055, 'sip', '6.1.0.107'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610077, 30007, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30007, 610077);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620077, CURRENT_DATE, 600077);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630077, 600077, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620077);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600077);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600077);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600077);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40007, 600077);

--GO


-- Route Decision Test: TestDecisionRaRoFtlLElwr

INSERT INTO node (id, name) VALUES (30008, 'Yate30008');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31008, '3.1.0.8/32'::inet, 30008, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40008, 'Context40008', true, true, 10002, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50008, 2, 'Customer50008', 40008, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51008, 50008, '5.1.0.8/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52008, CURRENT_DATE, 50008);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53008, 50008, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52008);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60008, 'Gateway60008', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61008, 60008, '6.1.0.8', 5055, 'sip', '6.1.0.8'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61008, 30008, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30008, 61008);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62008, CURRENT_DATE, 60008);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63008, 60008, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60008);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70008, 40008, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70008, 60008);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600088, 'Gateway600088', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610088, 600088, '6.1.0.108', 5055, 'sip', '6.1.0.108'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610088, 30008, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30008, 610088);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620088, CURRENT_DATE, 600088);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630088, 600088, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620088);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600088);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600088);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600088);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40008, 600088);

--GO


-- Routing Decision Test: TestDecisionRaRoFtlL

INSERT INTO node (id, name) VALUES (30009, 'Yate30009');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31009, '3.1.0.9/32'::inet, 30009, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40009, 'Context40009', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50009, 2, 'Customer50009', 40009, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51009, 50009, '5.1.0.9/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52009, CURRENT_DATE, 50009);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53009, 50009, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52009);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60009, 'Gateway60009', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61009, 60009, '6.1.0.9', 5055, 'sip', '6.1.0.9'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61009, 30009, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30009, 61009);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62009, CURRENT_DATE, 60009);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63009, 60009, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62009);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60009);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60009);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60009);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70009, 40009, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70009, 60009);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600099, 'Gateway600099', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(610099, 600099, '6.1.0.109', 5055, 'sip', '6.1.0.109'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (610099, 30009, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30009, 610099);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (620099, CURRENT_DATE, 600099);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(630099, 600099, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 620099);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600099);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600099);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600099);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40009, 600099);

--GO


-- Routing Decision Test: TestDecisionRaRoFtlElwr

INSERT INTO node (id, name) VALUES (30010, 'Yate30010');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31010, '3.1.0.10/32'::inet, 30010, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40010, 'Context40010', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50010, 2, 'Customer50010', 40010, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51010, 50010, '5.1.0.10/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52010, CURRENT_DATE, 50010);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53010, 50010, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52010);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60010, 'Gateway60010', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61010, 60010, '6.1.0.10', 5055, 'sip', '6.1.0.10'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61010, 30010, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30010, 61010);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62010, CURRENT_DATE, 60010);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63010, 60010, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62010);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60010);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60010);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60010);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70010, 40010, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70010, 60010);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000100, 'Gateway6000100', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100100, 6000100, '6.1.0.110', 5055, 'sip', '6.1.0.110'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100100, 30010, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30010, 6100100);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200100, CURRENT_DATE, 6000100);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300100, 6000100, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200100);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000100);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000100);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000100);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40010, 6000100);

--GO


-- Routing Decision Test: TestDecisionRaRoFtl

INSERT INTO node (id, name) VALUES (30011, 'Yate30011');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31011, '3.1.0.11/32'::inet, 30011, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40011, 'Context40011', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50011, 2, 'Customer50011', 40011, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51011, 50011, '5.1.0.11/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52011, CURRENT_DATE, 50011);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53011, 50011, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52011);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60011, 'Gateway60011', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61011, 60011, '6.1.0.11', 5055, 'sip', '6.1.0.11'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61011, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30011, 61011);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62011, CURRENT_DATE, 60011);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63011, 60011, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62011);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60011);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60011);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60011);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70011, 40011, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70011, 60011);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000110, 'Gateway6000110', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100110, 6000110, '6.1.0.111', 5055, 'sip', '6.1.0.111'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100110, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30011, 6100110);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200110, CURRENT_DATE, 6000110);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300110, 6000110, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200110);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000110);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000110);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000110);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40011, 6000110);

--GO


-- Routing Decision Test: TestDecisionRaRoLElwr

INSERT INTO node (id, name) VALUES (30012, 'Yate30012');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31012, '3.1.0.12/32'::inet, 30012, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40012, 'Context40012', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50012, 2, 'Customer50012', 40012, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51012, 50012, '5.1.0.12/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52012, CURRENT_DATE, 50012);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53012, 50012, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52012);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60012, 'Gateway60012', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61012, 60012, '6.1.0.12', 5055, 'sip', '6.1.0.12'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61012, 30012, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30012, 61012);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62012, CURRENT_DATE, 60012);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63012, 60012, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62012);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60012);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60012);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60012);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70012, 40012, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70012, 60012);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000120, 'Gateway6000120', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100120, 6000120, '6.1.0.112', 5055, 'sip', '6.1.0.112'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100120, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30012, 6100120);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200120, CURRENT_DATE, 6000120);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300120, 6000120, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200120);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000120);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000120);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000120);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40012, 6000120);

--GO


-- Routing Decision Test: TestDecisionRaRoL

INSERT INTO node (id, name) VALUES (30013, 'Yate30013');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31013, '3.1.0.13/32'::inet, 30013, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40013, 'Context40013', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50013, 2, 'Customer50013', 40013, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51013, 50013, '5.1.0.13/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52013, CURRENT_DATE, 50013);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53013, 50013, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52013);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60013, 'Gateway60013', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61013, 60013, '6.1.0.13', 5055, 'sip', '6.1.0.13'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61013, 30013, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30013, 61013);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62013, CURRENT_DATE, 60013);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63013, 60013, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62013);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60013);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60013);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60013);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70013, 40013, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70013, 60013);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000130, 'Gateway6000130', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100130, 6000130, '6.1.0.113', 5055, 'sip', '6.1.0.113'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100130, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30013, 6100130);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200130, CURRENT_DATE, 6000130);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300130, 6000130, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200130);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000130);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000130);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000130);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40013, 6000130);

--GO


-- Routing Decision Test: TestDecisionRaRoElwr 

INSERT INTO node (id, name) VALUES (30014, 'Yate30014');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31014, '3.1.0.14/32'::inet, 30014, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40014, 'Context40014', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50014, 2, 'Customer50014', 40014, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51014, 50014, '5.1.0.14/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52014, CURRENT_DATE, 50014);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53014, 50014, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52014);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60014, 'Gateway60014', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61014, 60014, '6.1.0.14', 5055, 'sip', '6.1.0.14'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61014, 30014, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30014, 61014);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62014, CURRENT_DATE, 60014);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63014, 60014, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62014);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60014);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60014);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60014);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70014, 40014, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70014, 60014);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000140, 'Gateway6000140', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100140, 6000140, '6.1.0.114', 5055, 'sip', '6.1.0.114'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100140, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30014, 6100140);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200140, CURRENT_DATE, 6000140);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300140, 6000140, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200140);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000140);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000140);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000140);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40014, 6000140);

--GO


-- Routing Decision Test: TestDecisionRaRo

INSERT INTO node (id, name) VALUES (30015, 'Yate30015');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31015, '3.1.0.15/32'::inet, 30015, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40015, 'Context40015', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50015, 2, 'Customer50015', 40015, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51015, 50015, '5.1.0.15/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52015, CURRENT_DATE, 50015);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53015, 50015, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52015);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60015, 'Gateway60015', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61015, 60015, '6.1.0.15', 5055, 'sip', '6.1.0.15'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61015, 30015, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30015, 61015);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62015, CURRENT_DATE, 60015);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63015, 60015, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62015);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60015);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60015);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60015);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70015, 40015, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70015, 60015);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000150, 'Gateway6000150', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100150, 6000150, '6.1.0.115', 5055, 'sip', '6.1.0.115'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100150, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30015, 6100150);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200150, CURRENT_DATE, 6000150);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300150, 6000150, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200150);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000150);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000150);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000150);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40015, 6000150);

--GO


-- Routing Decision Test: TestDecisionRaImrFtlLElwr

INSERT INTO node (id, name) VALUES (30016, 'Yate30016');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31016, '3.1.0.16/32'::inet, 30016, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40016, 'Context40016', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50016, 2, 'Customer50016', 40016, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51016, 50016, '5.1.0.16/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52016, CURRENT_DATE, 50016);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53016, 50016, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52016);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000160, 'Gateway6000160', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100160, 6000160, '6.1.0.116', 5055, 'sip', '6.1.0.116'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100160, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30016, 6100160);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200160, CURRENT_DATE, 6000160);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300160, 6000160, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200160);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000160);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000160);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000160);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40016, 6000160);

--GO


-- Routing Decision Test: TestDecisionRaImrFtlL


INSERT INTO node (id, name) VALUES (30017, 'Yate30017');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31017, '3.1.0.17/32'::inet, 30017, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40017, 'Context40017', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50017, 2, 'Customer50017', 40017, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51017, 50017, '5.1.0.17/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52017, CURRENT_DATE, 50017);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53017, 50017, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52017);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000170, 'Gateway6000170', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100170, 6000170, '6.1.0.117', 5055, 'sip', '6.1.0.117'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100170, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30017, 6100170);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200170, CURRENT_DATE, 6000170);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300170, 6000170, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200170);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000170);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000170);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000170);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40017, 6000170);

--GO


-- Routing Decision Test: TestDecisionRaImrFtlElwr

INSERT INTO node (id, name) VALUES (30018, 'Yate30018');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31018, '3.1.0.18/32'::inet, 30018, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40018, 'Context40018', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50018, 2, 'Customer50018', 40018, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51018, 50018, '5.1.0.18/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52018, CURRENT_DATE, 50018);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53018, 50018, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52018);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000180, 'Gateway6000180', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100180, 6000180, '6.1.0.118', 5055, 'sip', '6.1.0.118'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100180, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30018, 6100180);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200180, CURRENT_DATE, 6000180);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300180, 6000180, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200180);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000180);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000180);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000180);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40018, 6000180);

--GO


-- Routing Decision Test: TestDecisionRaImrFtl

INSERT INTO node (id, name) VALUES (30019, 'Yate30019');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31019, '3.1.0.19/32'::inet, 30019, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40019, 'Context40019', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50019, 2, 'Customer50019', 40019, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51019, 50019, '5.1.0.19/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52019, CURRENT_DATE, 50019);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53019, 50019, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '10001', 52019);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000190, 'Gateway6000190', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100190, 6000190, '6.1.0.119', 5055, 'sip', '6.1.0.119'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100190, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30019, 6100190);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200190, CURRENT_DATE, 6000190);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300190, 6000190, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200190);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000190);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000190);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000190);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40019, 6000190);

--GO


-- Routing Decision Test: TestDecisionRaImrLElwt

INSERT INTO node (id, name) VALUES (30020, 'Yate30020');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31020, '3.1.0.20/32'::inet, 30020, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40020, 'Context40020', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50020, 2, 'Customer50020', 40020, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51020, 50020, '5.1.0.20/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52020, CURRENT_DATE, 50020);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53020, 50020, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52020);

-- No Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000200, 'Gateway6000200', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100200, 6000200, '6.1.0.120', 5055, 'sip', '6.1.0.120'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100200, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30020, 6100200);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200200, CURRENT_DATE, 6000200);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300200, 6000200, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200200);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000200);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000200);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000200);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40020, 6000200);

--GO


-- Routing Decision Test: TestDecisionRaImrL

INSERT INTO node (id, name) VALUES (30021, 'Yate30021');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31021, '3.1.0.21/32'::inet, 30021, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40021, 'Context40021', true, false, 11000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50021, 2, 'Customer50021', 40021, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51021, 50021, '5.1.0.21/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52121, CURRENT_DATE, 50021);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53021, 50021, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52121);

-- No Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000210, 'Gateway6000210', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100210, 6000210, '6.1.0.121', 5055, 'sip', '6.1.0.121'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100210, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30021, 6100210);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6210210, CURRENT_DATE, 6000210);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300210, 6000210, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6210210);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000210);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000210);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000210);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40021, 6000210);

--GO


-- Routing Decision Test: TestDecisionRaImrElwr

INSERT INTO node (id, name) VALUES (30022, 'Yate30022');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31022, '3.1.0.22/32'::inet, 30022, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40022, 'Context40022', false, false, 12000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50022, 2, 'Customer50022', 40022, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51022, 50022, '5.1.0.22/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52222, CURRENT_DATE, 50022);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53022, 50022, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52222);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000220, 'Gateway6000220', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100220, 6000220, '6.1.0.122', 5055, 'sip', '6.1.0.122'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100220, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30022, 6100220);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6220220, CURRENT_DATE, 6000220);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300220, 6000220, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6220220);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000220);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000220);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000220);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40022, 6000220);

--GO


-- Routing Decision Test: TestDecisionRaImr

INSERT INTO node (id, name) VALUES (30023, 'Yate30023');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31023, '3.1.0.23/32'::inet, 30023, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40023, 'Context40023', false, false, 13000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50023, 2, 'Customer50023', 40023, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51023, 50023, '5.1.0.23/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52323, CURRENT_DATE, 50023);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53023, 50023, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52323);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000230, 'Gateway6000230', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100230, 6000230, '6.1.0.123', 5055, 'sip', '6.1.0.123'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100230, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30023, 6100230);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6230230, CURRENT_DATE, 6000230);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300230, 6000230, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6230230);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000230);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000230);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000230);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40023, 6000230);

--GO


-- Routing Decision Test: TestDecisionRaFtlLElwr

INSERT INTO node (id, name) VALUES (30024, 'Yate30024');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31024, '3.1.0.24/32'::inet, 30024, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40024, 'Context40024', true, true, 14000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50024, 2, 'Customer50024', 40024, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51024, 50024, '5.1.0.24/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52424, CURRENT_DATE, 50024);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53024, 50024, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52424);

-- No Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000240, 'Gateway6000240', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100240, 6000240, '6.1.0.124', 5055, 'sip', '6.1.0.124'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100240, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30024, 6100240);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6240240, CURRENT_DATE, 6000240);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300240, 6000240, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6240240);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000240);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000240);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000240);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40024, 6000240);

--GO


-- Routing Decision Test: TestDecisionRaFtlL

INSERT INTO node (id, name) VALUES (30025, 'Yate30025');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31025, '3.1.0.25/32'::inet, 30025, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40025, 'Context40025', true, false, 15000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50025, 2, 'Customer50025', 40025, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51025, 50025, '5.1.0.25/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52525, CURRENT_DATE, 50025);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53025, 50025, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52525);

-- No Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000250, 'Gateway6000250', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100250, 6000250, '6.1.0.125', 5055, 'sip', '6.1.0.125'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100250, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30025, 6100250);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6250250, CURRENT_DATE, 6000250);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300250, 6000250, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6250250);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000250);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000250);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000250);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40025, 6000250);

--GO


-- Routing Decision Test: TestDecisionRaFtlElwr

INSERT INTO node (id, name) VALUES (30026, 'Yate30026');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31026, '3.1.0.26/32'::inet, 30026, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40026, 'Context40026', false, false, 16000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50026, 2, 'Customer50026', 40026, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51026, 50026, '5.1.0.26/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52626, CURRENT_DATE, 50026);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53026, 50026, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52626);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000260, 'Gateway6000260', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100260, 6000260, '6.1.0.126', 5055, 'sip', '6.1.0.126'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100260, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30026, 6100260);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6260260, CURRENT_DATE, 6000260);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300260, 6000260, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6260260);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000260);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000260);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000260);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40026, 6000260);

--GO


-- Route Decision Test: TestDecisionRaFtl

INSERT INTO node (id, name) VALUES (30027, 'Yate30027');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31027, '3.1.0.27/32'::inet, 30027, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40027, 'Context40027', false, false, 17000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50027, 2, 'Customer50027', 40027, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51027, 50027, '5.1.0.27/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52727, CURRENT_DATE, 50027);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53027, 50027, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52727);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000270, 'Gateway6000270', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100270, 6000270, '6.1.0.127', 5055, 'sip', '6.1.0.127'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100270, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30027, 6100270);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6270270, CURRENT_DATE, 6000270);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300270, 6000270, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6270270);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000270);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000270);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000270);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40027, 6000270);

--GO


-- Routing Decision Test: TestDecisionRaLElwr

INSERT INTO node (id, name) VALUES (30028, 'Yate30028');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31028, '3.1.0.28/32'::inet, 30028, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40028, 'Context40028', true, true, 18000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50028, 2, 'Customer50028', 40028, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51028, 50028, '5.1.0.28/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52828, CURRENT_DATE, 50028);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53028, 50028, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52828);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000280, 'Gateway6000280', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100280, 6000280, '6.1.0.128', 5055, 'sip', '6.1.0.128'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100280, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30028, 6100280);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6280280, CURRENT_DATE, 6000280);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300280, 6000280, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6280280);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000280);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000280);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000280);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40028, 6000280);

--GO


-- Routing Decision Test: TestDecisionRaL

INSERT INTO node (id, name) VALUES (30029, 'Yate30029');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31029, '3.1.0.29/32'::inet, 30029, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40029, 'Context40029', true, false, 19000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50029, 2, 'Customer50029', 40029, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51029, 50029, '5.1.0.29/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52929, CURRENT_DATE, 50029);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53029, 50029, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 52929);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000290, 'Gateway6000290', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100290, 6000290, '6.1.0.129', 5055, 'sip', '6.1.0.129'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100290, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30029, 6100290);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6290290, CURRENT_DATE, 6000290);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300290, 6000290, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6290290);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000290);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000290);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000290);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40029, 6000290);

--GO


-- Routing Decision Test: TestDecisionRaElwr

INSERT INTO node (id, name) VALUES (30030, 'Yate30030');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31030, '3.1.0.30/32'::inet, 30030, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40030, 'Context40030', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50030, 2, 'Customer50030', 40030, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51030, 50030, '5.1.0.30/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53030, CURRENT_DATE, 50030);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53030, 50030, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 53030);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000300, 'Gateway6000300', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100300, 6000300, '6.1.0.130', 5055, 'sip', '6.1.0.130'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100300, 30011, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30030, 6100300);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6300300, CURRENT_DATE, 6000300);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300300, 6000300, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6300300);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000300);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000300);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000300);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40030, 6000300);

--GO


-- Routing Decision Test: TestDecisionRa

INSERT INTO node (id, name) VALUES (31031, 'Yate31031');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31031, '3.1.0.31/32'::inet, 31031, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40031, 'Context40031', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50031, 2, 'Customer50031', 40031, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51031, 50031, '5.1.0.31/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53131, CURRENT_DATE, 50031);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53131, 50031, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '1000', 53131);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(6000310, 'Gateway6000310', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100310, 6000310, '6.1.0.131', 5055, 'sip', '6.1.0.131'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100310, 31031, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (31031, 6100310);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6310310, CURRENT_DATE, 6000310);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6310310, 6000310, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6310310);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 6000310);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 6000310);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 6000310);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40031, 6000310);

--GO


-- Routing Decision Test: TestDecisionRoImrFtlLElwr

INSERT INTO node (id, name) VALUES (30032, 'Yate30032');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31032, '3.1.0.32/32'::inet, 30032, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40032, 'Context40032', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50032, 2, 'Customer50032', 40032, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51032, 50032, '5.1.0.32/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52032, CURRENT_DATE, 50032);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53032, 50032, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52032);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60032, 'Gateway60032', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61032, 60032, '6.1.0.32', 5055, 'sip', '6.1.0.32'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61032, 30032, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30032, 61032);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62032, CURRENT_DATE, 60032);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63032, 60032, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62032);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60032);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60032);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60032);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70032, 40032, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70032, 60032);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40032, 60032);

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600320, 'Gateway600320', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100320, 600320, '6.1.0.132', 5055, 'sip', '6.1.0.132'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100320, 30032, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30032, 6100320);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200320, CURRENT_DATE, 600320);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300320, 600320, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200320);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600320);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600320);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600320);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40032, 600320);

--GO


-- Routing Decision Test: TestDecisionRoImrFtlL

INSERT INTO node (id, name) VALUES (30033, 'Yate30033');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31033, '3.1.0.33/32'::inet, 30033, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40033, 'Context40033', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50033, 2, 'Customer50033', 40033, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51033, 50033, '5.1.0.33/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52033, CURRENT_DATE, 50033);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53033, 50033, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52033);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60033, 'Gateway60033', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61033, 60033, '6.1.0.33', 5055, 'sip', '6.1.0.33'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61033, 30033, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30033, 61033);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62033, CURRENT_DATE, 60033);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63033, 60033, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60033);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60033);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70033, 40033, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70033, 60033);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40033, 60033);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600330, 'Gateway600330', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100330, 600330, '6.1.0.133', 5055, 'sip', '6.1.0.133'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100330, 30033, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30033, 6100330);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200330, CURRENT_DATE, 600330);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300330, 600330, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200330);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600330);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600330);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600330);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40033, 600330);

--GO


-- Routing Decision Test: TestDecisionRoImrFtlElw

INSERT INTO node (id, name) VALUES (30034, 'Yate30034');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31034, '3.1.0.34/32'::inet, 30034, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40034, 'Context40034', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50034, 2, 'Customer50034', 40034, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51034, 50034, '5.1.0.34/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52034, CURRENT_DATE, 50034);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53034, 50034, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52034);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60034, 'Gateway60034', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61034, 60034, '6.1.0.34', 5055, 'sip', '6.1.0.34'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61034, 30034, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30034, 61034);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62034, CURRENT_DATE, 60034);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63034, 60034, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62034);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60034);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60034);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60034);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70034, 40034, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70034, 60034);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40034, 60034);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600340, 'Gateway600340', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100340, 600340, '6.1.0.134', 5055, 'sip', '6.1.0.134'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100340, 30034, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30034, 6100340);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200340, CURRENT_DATE, 600340);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300340, 600340, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200340);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600340);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600340);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600340);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40034, 600340);

--GO


-- Routing Decision Test: TestDecisionRoImrFtl

INSERT INTO node (id, name) VALUES (30035, 'Yate30035');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31035, '3.1.0.35/32'::inet, 30035, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40035, 'Context40035', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50035, 2, 'Customer50035', 40035, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51035, 50035, '5.1.0.35/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52035, CURRENT_DATE, 50035);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53035, 50035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52035);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60035, 'Gateway60035', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61035, 60035, '6.1.0.35', 5055, 'sip', '6.1.0.35'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61035, 30035, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30035, 61035);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62035, CURRENT_DATE, 60035);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63035, 60035, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62035);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60035);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60035);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60035);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70035, 40035, '\1', false, '.*', '', '', 0, true, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70035, 60035);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40035, 60035);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600350, 'Gateway600350', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100350, 600350, '6.1.0.135', 5055, 'sip', '6.1.0.135'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100350, 30035, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30035, 6100350);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200350, CURRENT_DATE, 600350);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300350, 600350, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200350);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600350);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600350);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600350);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40035, 600350);

--GO


-- Routing Decision Test: TestDecisionRoImrLElwr

INSERT INTO node (id, name) VALUES (30036, 'Yate30036');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31036, '3.1.0.36/32'::inet, 30036, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40036, 'Context40036', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50036, 2, 'Customer50036', 40036, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51036, 50036, '5.1.0.36/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52036, CURRENT_DATE, 50036);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53036, 50036, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52036);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60036, 'Gateway60036', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61036, 60036, '6.1.0.36', 5055, 'sip', '6.1.0.36'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61036, 30036, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30036, 61036);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62036, CURRENT_DATE, 60036);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63036, 60036, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62036);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60036);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60036);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60036);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70036, 40036, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70036, 60036);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40036, 60036);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600360, 'Gateway600360', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100360, 600360, '6.1.0.136', 5055, 'sip', '6.1.0.136'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100360, 30036, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30036, 6100360);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200360, CURRENT_DATE, 600360);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300360, 600360, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200360);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600360);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600360);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600360);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40036, 600360);

--GO


-- Routing Decision Test: TestDecisionRoImrL

INSERT INTO node (id, name) VALUES (30037, 'Yate30037');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31037, '3.1.0.37/32'::inet, 30037, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40037, 'Context40037', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50037, 2, 'Customer50037', 40037, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51037, 50037, '5.1.0.37/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52037, CURRENT_DATE, 50037);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53037, 50037, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52037);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60037, 'Gateway60037', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61037, 60037, '6.1.0.37', 5055, 'sip', '6.1.0.37'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61037, 30037, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30037, 61037);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62037, CURRENT_DATE, 60037);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63037, 60037, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62037);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60037);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60037);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60037);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70037, 40037, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70037, 60037);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40037, 60037);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600370, 'Gateway600370', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100370, 600370, '6.1.0.137', 5055, 'sip', '6.1.0.137'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100370, 30037, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30037, 6100370);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200370, CURRENT_DATE, 600370);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300370, 600370, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200370);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600370);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600370);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600370);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40037, 600370);

--GO


-- Routing Decision Test: TestDecisionRoImrElwr

INSERT INTO node (id, name) VALUES (30038, 'Yate30038');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31038, '3.1.0.38/32'::inet, 30038, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40038, 'Context40038', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50038, 2, 'Customer50038', 40038, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51038, 50038, '5.1.0.38/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52038, CURRENT_DATE, 50038);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53038, 50038, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52038);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60038, 'Gateway60038', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61038, 60038, '6.1.0.38', 5055, 'sip', '6.1.0.38'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61038, 30038, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30038, 61038);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62038, CURRENT_DATE, 60038);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63038, 60038, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62038);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60038);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60038);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60038);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70038, 40038, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70038, 60038);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40038, 60038);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600380, 'Gateway600380', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100380, 600380, '6.1.0.138', 5055, 'sip', '6.1.0.138'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100380, 30038, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30038, 6100380);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200380, CURRENT_DATE, 600380);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300380, 600380, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200380);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600380);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600380);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600380);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40038, 600380);

--GO


-- Routing Decision Test: TestDecisionRoImr

INSERT INTO node (id, name) VALUES (30039, 'Yate30039');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31039, '3.1.0.39/32'::inet, 30039, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40039, 'Context40039', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50039, 2, 'Customer50039', 40039, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51039, 50039, '5.1.0.39/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52039, CURRENT_DATE, 50039);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53039, 50039, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52039);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60039, 'Gateway60039', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61039, 60039, '6.1.0.39', 5055, 'sip', '6.1.0.39'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61039, 30039, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30039, 61039);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62039, CURRENT_DATE, 60039);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63039, 60039, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62039);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60039);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60039);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60039);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70039, 40039, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70039, 60039);

-- this needs to be ignored as gateway is already set in route, so will only appear once in routing
INSERT INTO context_gateway(context_id, gateway_id) VALUES(40039, 60039);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600390, 'Gateway600390', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100390, 600390, '6.1.0.139', 5055, 'sip', '6.1.0.139'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100390, 30039, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30039, 6100390);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200390, CURRENT_DATE, 600390);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300390, 600390, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200390);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600390);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600390);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600390);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40039, 600390);

--GO


-- Routing Decision Test: TestDecisionRoFtlLElwr

INSERT INTO node (id, name) VALUES (30040, 'Yate30040');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31040, '3.1.0.40/32'::inet, 30040, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (40040, 'Context40040', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50040, 2, 'Customer50040', 40040, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51040, 50040, '5.1.0.40/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52040, CURRENT_DATE, 50040);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53040, 50040, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52040);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60040, 'Gateway60040', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61040, 60040, '6.1.0.40', 5055, 'sip', '6.1.0.40'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61040, 30040, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30040, 61040);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62040, CURRENT_DATE, 60040);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63040, 60040, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62040);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60040);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60040);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60040);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70040, 40040, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70040, 60040);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600400, 'Gateway600400', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100400, 600400, '6.1.0.140', 5055, 'sip', '6.1.0.140'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100400, 30040, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30040, 6100400);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200400, CURRENT_DATE, 600400);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300400, 600400, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200400);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600400);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600400);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600400);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(40040, 600400);

--GO


-- Routing Decision Test: TestDecisionRoFtlL

INSERT INTO node (id, name) VALUES (30041, 'Yate30041');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31041, '3.1.0.41/32'::inet, 30041, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (41041, 'Context41041', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50041, 2, 'Customer50041', 41041, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51041, 50041, '5.1.0.41/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52041, CURRENT_DATE, 50041);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53041, 50041, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52041);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60041, 'Gateway60041', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61041, 60041, '6.1.0.41', 5055, 'sip', '6.1.0.41'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61041, 30041, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30041, 61041);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62041, CURRENT_DATE, 60041);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63041, 60041, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62041);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60041);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60041);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60041);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70041, 41041, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70041, 60041);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600410, 'Gateway600410', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100410, 600410, '6.1.0.141', 5055, 'sip', '6.1.0.141'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100410, 30041, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30041, 6100410);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200410, CURRENT_DATE, 600410);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300410, 600410, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200410);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600410);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600410);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600410);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(41041, 600410);

--GO


-- Routing Decision Test: TestDecisionRoFtlElwr

INSERT INTO node (id, name) VALUES (30042, 'Yate30042');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31042, '3.1.0.42/32'::inet, 30042, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42042, 'Context42042', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50042, 2, 'Customer50042', 42042, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51042, 50042, '5.1.0.42/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52042, CURRENT_DATE, 50042);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53042, 50042, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52042);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60042, 'Gateway60042', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61042, 60042, '6.1.0.42', 5055, 'sip', '6.1.0.42'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61042, 30042, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30042, 61042);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62042, CURRENT_DATE, 60042);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63042, 60042, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62042);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60042);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60042);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60042);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70042, 42042, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70042, 60042);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600420, 'Gateway600420', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100420, 600420, '6.1.0.142', 5055, 'sip', '6.1.0.142'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100420, 30042, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30042, 6100420);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200420, CURRENT_DATE, 600420);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300420, 600420, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200420);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600420);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600420);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600420);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42042, 600420);

--GO


-- Routing Decision Test: TestDecisionRoFtl

INSERT INTO node (id, name) VALUES (30043, 'Yate30043');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31043, '3.1.0.43/32'::inet, 30043, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (43043, 'Context43043', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50043, 2, 'Customer50043', 43043, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51043, 50043, '5.1.0.43/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52043, CURRENT_DATE, 50043);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53043, 50043, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52043);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60043, 'Gateway60043', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61043, 60043, '6.1.0.43', 5055, 'sip', '6.1.0.43'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61043, 30043, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30043, 61043);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62043, CURRENT_DATE, 60043);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63043, 60043, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62043);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60043);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60043);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60043);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70043, 43043, '\1', false, '.*', '', '', 0, false, true);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70043, 60043);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600430, 'Gateway600430', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100430, 600430, '6.1.0.143', 5055, 'sip', '6.1.0.143'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100430, 30043, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30043, 6100430);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200430, CURRENT_DATE, 600430);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300430, 600430, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200430);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600430);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600430);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600430);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(43043, 600430);

--GO


-- Routing Decision Test: TestDecisionRoLElwr

INSERT INTO node (id, name) VALUES (30044, 'Yate30044');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31044, '3.1.0.44/32'::inet, 30044, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (44044, 'Context44044', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50044, 2, 'Customer50044', 44044, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51044, 50044, '5.1.0.44/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52044, CURRENT_DATE, 50044);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53044, 50044, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52044);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60044, 'Gateway60044', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61044, 60044, '6.1.0.44', 5055, 'sip', '6.1.0.44'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61044, 30044, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30044, 61044);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62044, CURRENT_DATE, 60044);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63044, 60044, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62044);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60044);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60044);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60044);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70044, 44044, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70044, 60044);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600440, 'Gateway600440', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100440, 600440, '6.1.0.144', 5055, 'sip', '6.1.0.144'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100440, 30044, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30044, 6100440);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200440, CURRENT_DATE, 600440);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300440, 600440, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200440);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600440);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600440);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600440);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(44044, 600440);

--GO


-- Routing Decision Test: TestDecisionRoL

INSERT INTO node (id, name) VALUES (30045, 'Yate30045');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31045, '3.1.0.45/32'::inet, 30045, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (45045, 'Context45045', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50045, 2, 'Customer50045', 45045, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51045, 50045, '5.1.0.45/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52045, CURRENT_DATE, 50045);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53045, 50045, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52045);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60045, 'Gateway60045', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61045, 60045, '6.1.0.45', 5055, 'sip', '6.1.0.45'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61045, 30045, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30045, 61045);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62045, CURRENT_DATE, 60045);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63045, 60045, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62045);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60045);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60045);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60045);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70045, 45045, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70045, 60045);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600450, 'Gateway600450', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100450, 600450, '6.1.0.145', 5055, 'sip', '6.1.0.145'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100450, 30045, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30045, 6100450);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200450, CURRENT_DATE, 600450);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300450, 600450, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200450);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600450);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600450);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600450);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(45045, 600450);

--GO


-- Routing Decision Test: TestDecisionRoElwr

INSERT INTO node (id, name) VALUES (30046, 'Yate30046');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31046, '3.1.0.46/32'::inet, 30046, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (46046, 'Context46046', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50046, 2, 'Customer50046', 46046, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51046, 50046, '5.1.0.46/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52046, CURRENT_DATE, 50046);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53046, 50046, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52046);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60046, 'Gateway60046', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61046, 60046, '6.1.0.46', 5055, 'sip', '6.1.0.46'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61046, 30046, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30046, 61046);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62046, CURRENT_DATE, 60046);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63046, 60046, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62046);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60046);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60046);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60046);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70046, 46046, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70046, 60046);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600460, 'Gateway600460', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100460, 600460, '6.1.0.146', 5055, 'sip', '6.1.0.146'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100460, 30046, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30046, 6100460);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200460, CURRENT_DATE, 600460);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300460, 600460, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200460);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600460);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600460);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600460);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(46046, 600460);

--GO


-- Routing Decision Test: TestDecisionRo

INSERT INTO node (id, name) VALUES (30047, 'Yate30047');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31047, '3.1.0.47/32'::inet, 30047, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (47047, 'Context47047', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50047, 2, 'Customer50047', 47047, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51047, 50047, '5.1.0.47/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52047, CURRENT_DATE, 50047);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53047, 50047, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52047);

-- Route
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60047, 'Gateway60047', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(61047, 60047, '6.1.0.47', 5055, 'sip', '6.1.0.47'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (61047, 30047, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30047, 61047);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (62047, CURRENT_DATE, 60047);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(63047, 60047, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 62047);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60047);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60047);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60047);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (70047, 47047, '\1', false, '.*', '', '', 0, false, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (70047, 60047);

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600470, 'Gateway600470', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100470, 600470, '6.1.0.147', 5055, 'sip', '6.1.0.147'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100470, 30047, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30047, 6100470);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200470, CURRENT_DATE, 600470);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300470, 600470, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200470);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600470);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600470);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600470);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(47047, 600470);

--GO


-- Routing Decision Test: TestDecisionImrFtlLElwr

INSERT INTO node (id, name) VALUES (30048, 'Yate30048');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31048, '3.1.0.48/32'::inet, 30048, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (48048, 'Context48048', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50048, 2, 'Customer50048', 48048, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51048, 50048, '5.1.0.48/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52048, CURRENT_DATE, 50048);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53048, 50048, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52048);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600480, 'Gateway600480', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100480, 600480, '6.1.0.148', 5055, 'sip', '6.1.0.148'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100480, 30048, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30048, 6100480);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200480, CURRENT_DATE, 600480);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300480, 600480, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200480);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600480);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600480);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600480);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(48048, 600480);

--GO


-- Routing Decision Test: TestDecisionImrFtlL

INSERT INTO node (id, name) VALUES (30049, 'Yate30049');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31049, '3.1.0.49/32'::inet, 30049, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (49049, 'Context49049', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50049, 2, 'Customer50049', 49049, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51049, 50049, '5.1.0.49/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52049, CURRENT_DATE, 50049);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53049, 50049, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52049);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600490, 'Gateway600490', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100490, 600490, '6.1.0.149', 5055, 'sip', '6.1.0.149'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100490, 30049, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30049, 6100490);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200490, CURRENT_DATE, 600490);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300490, 600490, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200490);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600490);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600490);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600490);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(49049, 600490);

--GO


-- Routing Decision Test: TestDecisionImrFtlElwr

INSERT INTO node (id, name) VALUES (30050, 'Yate30050');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31050, '3.1.0.50/32'::inet, 30050, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (50050, 'Context50050', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50050, 2, 'Customer50050', 50050, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51050, 50050, '5.1.0.50/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52050, CURRENT_DATE, 50050);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53050, 50050, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52050);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600500, 'Gateway600500', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100500, 600500, '6.1.0.150', 5055, 'sip', '6.1.0.150'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100500, 30050, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30050, 6100500);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200500, CURRENT_DATE, 600500);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300500, 600500, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200500);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600500);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600500);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600500);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(50050, 600500);

--GO


-- Routing Decision Test: TestDecisionImrFtl

INSERT INTO node (id, name) VALUES (30051, 'Yate30051');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31051, '3.1.0.51/32'::inet, 30051, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (51051, 'Context51051', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (51051, 2, 'Customer51051', 51051, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51051, 51051, '5.1.0.51/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52051, CURRENT_DATE, 51051);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53051, 51051, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5510001', 52051);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600510, 'Gateway600510', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100510, 600510, '6.1.0.151', 5155, 'sip', '6.1.0.151'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100510, 30051, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30051, 6100510);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200510, CURRENT_DATE, 600510);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300510, 600510, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200510);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600510);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600510);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600510);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(51051, 600510);

--GO


-- Routing Decision Test: TestDecisionImrLElwr

INSERT INTO node (id, name) VALUES (30052, 'Yate30052');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31052, '3.1.0.52/32'::inet, 30052, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (52052, 'Context52052', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50052, 2, 'Customer50052', 52052, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51052, 50052, '5.1.0.52/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (52052, CURRENT_DATE, 50052);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53052, 50052, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5520001', 52052);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600520, 'Gateway600520', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100520, 600520, '6.1.0.152', 5055, 'sip', '6.1.0.152'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100520, 30052, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30052, 6100520);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200520, CURRENT_DATE, 600520);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300520, 600520, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200520);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600520);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600520);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600520);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(52052, 600520);

--GO


-- Routing Decision Test: TestDecisionImrL

INSERT INTO node (id, name) VALUES (30053, 'Yate30053');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31053, '3.1.0.53/32'::inet, 30053, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (53053, 'Context53053', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50053, 2, 'Customer50053', 53053, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51053, 50053, '5.1.0.53/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53053, CURRENT_DATE, 50053);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53053, 50053, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5530001', 53053);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600530, 'Gateway600530', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100530, 600530, '6.1.0.153', 5055, 'sip', '6.1.0.153'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100530, 30053, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30053, 6100530);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200530, CURRENT_DATE, 600530);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300530, 600530, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200530);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600530);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600530);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600530);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(53053, 600530);

--GO


-- Routing Decision Test: TestDecisionImrElwr

INSERT INTO node (id, name) VALUES (30054, 'Yate30054');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31054, '3.1.0.54/32'::inet, 30054, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (54054, 'Context54054', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50054, 2, 'Customer50054', 54054, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51054, 50054, '5.1.0.54/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53054, CURRENT_DATE, 50054);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53054, 50054, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5540001', 53054);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600540, 'Gateway600540', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100540, 600540, '6.1.0.154', 5055, 'sip', '6.1.0.154'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100540, 30054, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30054, 6100540);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200540, CURRENT_DATE, 600540);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300540, 600540, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200540);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600540);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600540);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600540);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(54054, 600540);

--GO


-- Routing Decision Test: TestDecisionImr

INSERT INTO node (id, name) VALUES (30055, 'Yate30055');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31055, '3.1.0.55/32'::inet, 30055, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (55055, 'Context55055', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50055, 2, 'Customer50055', 55055, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51055, 50055, '5.1.0.55/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53055, CURRENT_DATE, 50055);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53055, 50055, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '5550001', 53055);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600550, 'Gateway600550', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100550, 600550, '6.1.0.155', 5055, 'sip', '6.1.0.155'::inet, 6055, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100550, 30055, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30055, 6100550);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200550, CURRENT_DATE, 600550);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300550, 600550, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200550);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600550);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600550);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600550);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(55055, 600550);

--GO


-- Routing Decision Test: TestDecisionFtlLElwr

INSERT INTO node (id, name) VALUES (30056, 'Yate30056');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31056, '3.1.0.56/32'::inet, 30056, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (56056, 'Context56056', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50056, 2, 'Customer50056', 56056, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51056, 50056, '5.1.0.56/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53056, CURRENT_DATE, 50056);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53056, 50056, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53056);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600560, 'Gateway600560', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100560, 600560, '6.1.0.156', 5056, 'sip', '6.1.0.156'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100560, 30056, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30056, 6100560);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200560, CURRENT_DATE, 600560);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300560, 600560, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200560);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600560);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600560);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600560);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(56056, 600560);

--GO


-- Routing Decision Test: TestDecisionFtlL

INSERT INTO node (id, name) VALUES (30057, 'Yate30057');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31057, '3.1.0.57/32'::inet, 30057, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (57057, 'Context57057', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50057, 2, 'Customer50057', 57057, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51057, 50057, '5.1.0.57/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53057, CURRENT_DATE, 50057);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53057, 50057, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53057);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600570, 'Gateway600570', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100570, 600570, '6.1.0.157', 5056, 'sip', '6.1.0.157'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100570, 30057, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30057, 6100570);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200570, CURRENT_DATE, 600570);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300570, 600570, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200570);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600570);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600570);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600570);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(57057, 600570);

--GO


-- Routing Decision Test: TestDecisionFtlElwr

INSERT INTO node (id, name) VALUES (30058, 'Yate30058');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31058, '3.1.0.58/32'::inet, 30058, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (58058, 'Context58058', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50058, 2, 'Customer50058', 58058, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51058, 50058, '5.1.0.58/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53058, CURRENT_DATE, 50058);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53058, 50058, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53058);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600580, 'Gateway600580', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100580, 600580, '6.1.0.158', 5056, 'sip', '6.1.0.158'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100580, 30058, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30058, 6100580);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200580, CURRENT_DATE, 600580);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300580, 600580, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200580);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600580);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600580);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600580);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(58058, 600580);

--GO


-- Routing Decision Test: TestDecisionFtl

INSERT INTO node (id, name) VALUES (30059, 'Yate30059');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31059, '3.1.0.59/32'::inet, 30059, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (59059, 'Context59059', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50059, 2, 'Customer50059', 59059, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51059, 50059, '5.1.0.59/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53059, CURRENT_DATE, 50059);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53059, 50059, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53059);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600590, 'Gateway600590', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100590, 600590, '6.1.0.159', 5056, 'sip', '6.1.0.159'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100590, 30059, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30059, 6100590);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200590, CURRENT_DATE, 600590);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300590, 600590, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200590);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600590);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600590);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600590);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(59059, 600590);

--GO


-- Routing Decision Test: TestDecisionLElwr

INSERT INTO node (id, name) VALUES (30060, 'Yate30060');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31060, '3.1.0.60/32'::inet, 30060, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (60060, 'Context60060', true, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50060, 2, 'Customer50060', 60060, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51060, 50060, '5.1.0.60/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53060, CURRENT_DATE, 50060);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53060, 50060, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53060);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600600, 'Gateway600600', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100600, 600600, '6.1.0.160', 5056, 'sip', '6.1.0.160'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100600, 30060, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30060, 6100600);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200600, CURRENT_DATE, 600600);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300600, 600600, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200600);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600600);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600600);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600600);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(60060, 600600);

--GO


-- Routing Decision Test: TestDecisionL

INSERT INTO node (id, name) VALUES (30061, 'Yate30061');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31061, '3.1.0.61/32'::inet, 30061, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (61061, 'Context61061', true, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50061, 2, 'Customer50061', 61061, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51061, 50061, '5.1.0.61/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53061, CURRENT_DATE, 50061);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53061, 50061, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53061);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(610610, 'Gateway610610', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6100610, 610610, '6.1.0.161', 5056, 'sip', '6.1.0.161'::inet, 6156, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6100610, 30061, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30061, 6100610);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200610, CURRENT_DATE, 610610);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300610, 610610, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200610);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 610610);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 610610);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 610610);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(61061, 610610);

--GO


-- Routing Decision Test: TestDecisionElwr

INSERT INTO node (id, name) VALUES (30062, 'Yate30062');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31062, '3.1.0.62/32'::inet, 30062, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (62062, 'Context62062', false, true, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50062, 2, 'Customer50062', 62062, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51062, 50062, '5.1.0.62/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53062, CURRENT_DATE, 50062);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53062, 50062, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53062);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(620620, 'Gateway620620', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6200620, 620620, '6.1.0.162', 5056, 'sip', '6.1.0.162'::inet, 6256, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6200620, 30062, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30062, 6200620);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6200620, CURRENT_DATE, 620620);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300620, 620620, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6200620);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 620620);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 620620);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 620620);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(62062, 620620);

--GO


-- Routing Decision Test: TestDecision

INSERT INTO node (id, name) VALUES (30063, 'Yate30063');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (31063, '3.1.0.63/32'::inet, 30063, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (63063, 'Context63063', false, false, 10000, 1, 1001);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (50063, 2, 'Customer50063', 63063, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (51063, 50063, '5.1.0.63/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (53063, CURRENT_DATE, 50063);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (53063, 50063, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '80001', 53063);

-- No Route

-- No LCR (values just to check if flag works)
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(630630, 'Gateway630630', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(6300630, 630630, '6.1.0.163', 5056, 'sip', '6.1.0.163'::inet, 6356, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (6300630, 30063, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (30063, 6300630);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (6300630, CURRENT_DATE, 630630);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(6300630, 630630, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '100', 6300630);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 630630);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 630630);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 630630);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(63063, 630630);


-----------------------------------
----- END OF ROUTING DECISION TESTS
-----------------------------------
--GO

-- Routing Test: TestSameQoSDifferentCompanyLCR

INSERT INTO node (id, name) VALUES (40001, 'Yate40001');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41001, '4.1.0.1/32'::inet, 40001, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42001, 'Context42001', true, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43001, 1, 'Customer43001', 42001, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44001, 43001, '4.4.0.1/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45001, CURRENT_DATE, 44001);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46001, 43001, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45001);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47001, 'Gateway47001', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47101, 47001, '4.7.1.1', 5056, 'sip', '4.7.1.101'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47101, 40001, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40001, 47101);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48001, CURRENT_DATE, 47001);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49001, 47001, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47001);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42001, 47001);

--GO


--  Routing Test: TestDifferentQoSSameCompanyLCR

INSERT INTO node (id, name) VALUES (40002, 'Yate40002');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41002, '4.1.0.2/32'::inet, 40002, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42002, 'Context42002', true, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43002, 1, 'Customer43002', 42002, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44002, 43002, '4.4.0.2/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45002, CURRENT_DATE, 44002);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46002, 43002, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45002);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47002, 'Gateway47002', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47102, 47002, '4.7.1.2', 5056, 'sip', '4.7.1.102'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47102, 40002, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40002, 47102);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48002, CURRENT_DATE, 47002);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49002, 47002, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47002);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42002, 47002);

--GO


-- Routing Test: TestSameQoSSameCompanyLCR

INSERT INTO node (id, name) VALUES (40003, 'Yate40003');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41003, '4.1.0.3/32'::inet, 40003, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42003, 'Context42003', true, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43003, 1, 'Customer43003', 42003, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44003, 43003, '4.4.0.3/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45003, CURRENT_DATE, 44003);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46003, 43003, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45003);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47003, 'Gateway47003', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47103, 47003, '4.7.1.3', 5056, 'sip', '4.7.1.103'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47103, 40003, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40003, 47103);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48003, CURRENT_DATE, 47003);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49003, 47003, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47003);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42003, 47003);

--GO


-- Routing Test: TestDifferentQoSDifferentCompanyLCR

INSERT INTO node (id, name) VALUES (40004, 'Yate40004');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41004, '4.1.0.4/32'::inet, 40004, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42004, 'Context42004', true, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43004, 1, 'Customer43004', 42004, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44004, 43004, '4.4.0.4/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45004, CURRENT_DATE, 44004);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46004, 43004, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45004);

-- No Route

-- LCR
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47004, 'Gateway47004', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47104, 47004, '4.7.1.4', 5056, 'sip', '4.7.1.104'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47104, 40004, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40004, 47104);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48004, CURRENT_DATE, 47004);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49004, 47004, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48004);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47004);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47004);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47004);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42004, 47004);

--GO


-- Routing Test: TestSameQoSDifferentCompanyStandard

INSERT INTO node (id, name) VALUES (40005, 'Yate40005');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41005, '4.1.0.5/32'::inet, 40005, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42005, 'Context42005', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43005, 1, 'Customer43005', 42005, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44005, 43005, '4.4.0.5/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45005, CURRENT_DATE, 44005);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46005, 43005, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45005);

-- Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47005, 'Gateway47005', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47105, 47005, '4.7.1.5', 5056, 'sip', '4.7.1.105'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47105, 40005, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40005, 47105);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48005, CURRENT_DATE, 47005);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49005, 47005, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48005);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47005);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47005);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47005);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42005, 47005);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49505, 42005, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (49505, 47005);

-- No LCR

--GO


-- Routing Test: TestDifferentQoSSameCompanyStandard

INSERT INTO node (id, name) VALUES (40006, 'Yate40006');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41006, '4.1.0.6/32'::inet, 40006, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42006, 'Context42006', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43006, 1, 'Customer43006', 42006, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44006, 43006, '4.4.0.6/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45006, CURRENT_DATE, 44006);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46006, 43006, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45006);

-- Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47006, 'Gateway47006', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47106, 47006, '4.7.1.6', 5056, 'sip', '4.7.1.106'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47106, 40006, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40006, 47106);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48006, CURRENT_DATE, 47006);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49006, 47006, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47006);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42006, 47006);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49506, 42006, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (49506, 47006);

-- No LCR

--GO


-- Routing Test: TestSameQoSSameCompanyStandard

INSERT INTO node (id, name) VALUES (40007, 'Yate40007');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41007, '4.1.0.7/32'::inet, 40007, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42007, 'Context42007', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43007, 1, 'Customer43007', 42007, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44007, 43007, '4.4.0.7/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45007, CURRENT_DATE, 44007);
-- has no price
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46007, 43007, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45007);

-- Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47007, 'Gateway47007', 'IP'::gatewaytype, 1, 1, '', false, 1, null, 2);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47107, 47007, '4.7.1.7', 5056, 'sip', '4.7.1.107'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47107, 40007, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40007, 47107);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48007, CURRENT_DATE, 47007);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49007, 47007, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47007);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42007, 47007);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49507, 42007, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (49507, 47007);

-- No LCR

--GO


-- Routing Test: TestDifferentQoSDifferentCompanyStandard

INSERT INTO node (id, name) VALUES (40008, 'Yate40008');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (41008, '4.1.0.8/32'::inet, 40008, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (42008, 'Context42008', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (43008, 1, 'Customer43008', 42008, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (44008, 43008, '4.4.0.8/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (45008, CURRENT_DATE, 44008);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (46008, 43008, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 45008);

-- Route

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(47008, 'Gateway47008', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(47108, 47008, '4.7.1.8', 5056, 'sip', '4.7.1.108'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (47108, 40008, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (40008, 47108);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (48008, CURRENT_DATE, 47008);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49008, 47008, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 48008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 47008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 47008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 47008);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(42008, 47008);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49508, 42008, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (49508, 47008);

--GO


-- Route Test: TestGatewayPriceHigher
INSERT INTO node (id, name) VALUES (16001, 'Yate16001');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (16002, '16.0.1.0/32'::inet, 16001, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout) VALUES (16003, 'Context16004', true, 10000, 1, 1083);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (16004, 1, 'Customer16004', 16003, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (16005, 16004, '16.0.0.5/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(16006, 'Gateway16006', 'IP'::gatewaytype, 1, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 16006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 16006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 16006);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(16007, 570, '11.1.1.70', 5056, 'sip', '11.1.2.70'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (16007, 16001, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (16001, 16007);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort)
	VALUES (16008, 16003, '\1', false, '.*', '', '', 0);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (16008, 16006);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (16009, CURRENT_DATE, 16004);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (16010, 16004, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '111170', 16009);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (16011, CURRENT_DATE, 16006);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(16012, 16006, 'Flat'::timeband, 0.06, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '111170', 16011);
--GO


-- Route Test: TestRouteFixedGatewayToContextFixedGateway

INSERT INTO node (id, name) VALUES (41000, 'Yate41000');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (42000, '42.0.0.1/32'::inet, 41000, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (43000, 'Context43000', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (44000, 1, 'Customer44000', 43000, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (45000, 44000, '45.0.0.1/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (46000, CURRENT_DATE, 45000);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (47000, 44000, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 46000);

-- 1) Route To Gateway of same Context
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(48000, 'Gateway48000', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(48100, 48000, '48.1.0.1', 5056, 'sip', '48.2.0.1'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (48100, 41000, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (41000, 48100);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (49000, CURRENT_DATE, 48000);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49100, 48000, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 49000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 48000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 48000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 48000);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(43000, 48000);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49500, 43000, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (49500, 48000, 100);

-- 2) Route To Gateway of another Context
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (43500, 'Context43500', false, false, 10000, 1, 10000);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (49500, 43500, 200);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(48500, 'Gateway48000', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(48600, 48500, '48.6.0.1', 5056, 'sip', '48.7.0.1'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (48600, 41000, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (41000, 48600);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (49500, CURRENT_DATE, 48500);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49600, 48500, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 49500);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 48500);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 48500);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 48500);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(43000, 48500);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49501, 43500, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target (route_id, gateway_id) VALUES (49501, 48500);


--GO

-- Route Test: TestMultiRoutes

INSERT INTO node (id, name) VALUES (41001, 'Yate41001');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (42001, '42.0.0.2/32'::inet, 41001, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (43001, 'Context43001', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (44001, 1, 'Customer44001', 43001, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (45001, 44001, '45.0.0.2/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (46001, CURRENT_DATE, 45001);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (47001, 44001, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.06, '492', 46001);

-- 1) Route with multiple routes
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(48001, 'Gateway48001', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(48101, 48001, '48.1.0.2', 5056, 'sip', '48.2.0.2'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (48101, 41001, 0);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (41001, 48101);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (49001, CURRENT_DATE, 48001);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49101, 48001, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '49', 49001);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49102, 48001, 'Flat'::timeband, 0.04, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '492', 49001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 48001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 48001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 48001);

INSERT INTO context_gateway(context_id, gateway_id) VALUES(43001, 48001);

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49701, 43001, '\1', false, '^492.*$', '', '', 100, true, false);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49702, 43001, '\1', false, '^49280.*$', '', '', 110, true, false);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49703, 43001, '\1', false, '^4928000.*$', '', '', 120, true, false);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49704, 43001, '\1', false, '^492800.*$', '', '', 130, true, false);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49705, 43001, '\1', false, '^4925.*$', '', '', 140, true, false);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49706, 43001, '\1', false, '^4928.*$', '', '', 150, true, false);
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (49706, 48001, 100);

--GO


-- Route Test: TestRouteGatewayToContextLCR

INSERT INTO node (id, name) VALUES (41002, 'Yate41002');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (42002, '42.0.0.2/32'::inet, 41002, 10000, 'Public');

INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (43002, 'Context43002', false, false, 10000, 1, 10000);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (44002, 1, 'Customer44002', 43002, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (45002, 44002, '45.0.0.22/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (46002, CURRENT_DATE, 45002);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (47002, 44002, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 46002);

-- 1) Route To Route To Context

INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (49502, 43002, '\1', false, '.*', '', '', 0, true, false);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(48042, 'Gateway48042', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(48182, 48042, '48.1.8.2', 5056, 'sip', null, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (48182, 41002, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (41002, 48182);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (49082, CURRENT_DATE, 48042);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49643, 48042, 'Flat'::timeband, 0.01, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 49082);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 48042);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 48042);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 48042);

INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (49502, 48042, 199);

-- 2) Route To Gateway of another Context
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (43503, 'Context43503', true, true, 10000, 1, 1005);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (49502, 43503, 200);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(48504, 'Gateway48504', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(48604, 48504, '48.6.3.1', 5056, 'sip', '48.7.3.1'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (48604, 41002, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (41002, 48604);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (49504, CURRENT_DATE, 48504);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49604, 48504, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 49504);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 48504);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 48504);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 48504);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(43503, 48504);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(48002, 'Gateway48002', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(48102, 48002, '48.1.0.2', 5056, 'sip', null, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (48102, 41002, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (41002, 48102);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (49002, CURRENT_DATE, 48002);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(49603, 48002, 'Flat'::timeband, 0.02, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 49002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 48002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 48002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 48002);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(43503, 48002);

INSERT INTO cache_number_gateway_statistic (id, gateway_id, asr, created, number, working, total) VALUES (10000, 48002, 100, NOW(), '800', 100, 100);
INSERT INTO cache_number_gateway_statistic (id, gateway_id, asr, created, number, working, total) VALUES (10001, 48504, 30, NOW(), '800', 30, 100);

--GO

------------------------------------------------------------------------------------------

-- Route Test: TestMultiRoutesContextsGateways

-- Context A -> Route B -> Context C -> Route D -> Gateway E
--					   |					   \-> Context F -> Route G -> Gateway H
--					   |									\-> LCR -> Gateway I
--					   |-> Context J -> LCR -> Gateway K
--					   |-> Context L -> Route M -> Context F (ignore, because was routed in B-C-D-F)
--					   |-> Context N -> Route O -> Gateway E (ignore, because was routed in B-C-D-E)
--				       |					   \-> LCR -> Gateway P
--					   |							  \-> Gateway Q
--					   \-> Gateway R


INSERT INTO node (id, name) VALUES (60000, 'Yate41020');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (60001, '6.0.0.1/32'::inet, 60000, 10000, 'Public');

-- Context A
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (60002, 'Context60002', false, false, 10000, 1, 10000);

-- Consumer
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (60003, 1, 'Customer44020', 60002, false, '', 2);
INSERT INTO customer_ip (id, customer_id, address) VALUES (60004, 60003, '45.0.20.2/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id) VALUES (60005, CURRENT_DATE, 60003);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (60004, 60003, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 0.05, '8000', 60005);

-- Route B
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (60006, 60002, '\1', false, '.*', '', '', 0, true, false); -- Context A -> Route B

-- Context C
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (60007, 'Context60007', false, false, 10000, 1, 1005);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (60006, 60007, 200); -- Route B -> Context C

-- Route D
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (60015, 60007, '\1', false, '.*', '', '', 0, true, false); -- Context C -> Route D

-- Gateway E
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60016, 'Gateway60016', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60017, 60016, '6.0.0.17', 5056, 'sip', '6.0.1.17'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60017, 60000, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60017);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60018, CURRENT_DATE, 60016);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60019, 60016, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60018);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60016);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60016);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60016);
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (60015, 60016, 200); -- Route D -> Gateway E

-- Context F
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (60016, 'Context60016', true, true, 10000, 1, 1005);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (60015, 60016, 201); -- Route D -> Context F

-- Route G
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (60020, 60016, '\1', false, '.*', '', '', 0, true, true); -- Context F -> Route G

-- Gateway H
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60021, 'Gateway60021', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60022, 60021, '6.0.0.22', 5056, 'sip', '6.0.1.22'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60022, 60000, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60022);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60023, CURRENT_DATE, 60021);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60024, 60021, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60023);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60021);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60021);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60021);
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (60020, 60021, 200); -- Route G -> Gateway H

-- Gateway I
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60025, 'Gateway60025', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60026, 60025, '6.0.0.26', 5056, 'sip', '6.0.1.26'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60026, 60000, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60026);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60027, CURRENT_DATE, 60025);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60028, 60025, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60027);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60025);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60025);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60025);
INSERT INTO context_gateway (context_id, gateway_id) VALUES (60016, 60025); -- Context F (LCR) -> Gateway I

-- Context J
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (60008, 'Context60008', true, true, 10000, 1, 1005);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (60006, 60008, 201); -- Route B -> Context J

-- Gateway K
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60029, 'Gateway60029', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60030, 60029, '6.0.0.30', 5056, 'sip', '6.0.1.30'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60030, 60000, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60030);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60031, CURRENT_DATE, 60029);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60032, 60029, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60031);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60029);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60029);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60029);
INSERT INTO context_gateway (context_id, gateway_id) VALUES (60008, 60029); -- Context J (LCR) -> Gateway K

-- Context L
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (60009, 'Context60009', false, false, 10000, 1, 1005);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (60006, 60009, 202); -- Route H -> Context D

-- Route M
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (60033, 60009, '\1', false, '.*', '', '', 0, true, false); -- Context L -> Route M
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (60033, 60016, 203); -- Route M -> Context F

-- Context N
INSERT INTO context (id, name, least_cost_routing, enable_lcr_without_rate, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (60010, 'Context60010', true, true, 10000, 1, 1005);
INSERT INTO route_to_target (route_id, context_id, sort) VALUES (60006, 60010, 203); -- Route B -> Context N

-- Route O
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (60034, 60010, '\1', false, '.*', '', '', 0, true, true); -- Context N -> Route O
INSERT INTO route_to_target (route_id, gateway_id, sort) VALUES (60034, 60016, 203); -- Route O -> Gateway E

-- Gateway P
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60050, 'Gateway60050', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60036, 60050, '6.0.0.36', 5056, 'sip', '6.0.1.36'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60036, 60000, 10);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60036);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60037, CURRENT_DATE, 60050);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60038, 60050, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60037);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60050);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60050);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60050);
INSERT INTO context_gateway(context_id, gateway_id) VALUES (60010, 60050); -- Context N (LCR) -> Gateway P
INSERT INTO cache_number_gateway_statistic (id, gateway_id, asr, created, number, working, total) VALUES (60043, 60050, 100, NOW(), '800', 100, 100);

-- Gateway Q
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60051, 'Gateway60051', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60040, 60051, '6.0.0.40', 5056, 'sip', '6.0.1.40'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60040, 60000, 12);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60040);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60041, CURRENT_DATE, 60051);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60042, 60051, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60041);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60051);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60051);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60051);
INSERT INTO context_gateway(context_id, gateway_id) VALUES (60010, 60051); -- Context N (LCR) -> Gateway Q
INSERT INTO cache_number_gateway_statistic (id, gateway_id, asr, created, number, working, total) VALUES (60044, 60051, 30, NOW(), '800', 30, 100);

-- Gateway R
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(60052, 'Gateway60052', 'IP'::gatewaytype, 2, 1, '', false, 1, null, 1);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(60046, 60052, '6.0.0.46', 5056, 'sip', '6.0.1.46'::inet, 6056, false, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (60046, 60000, 12);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (60000, 60046);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (60047, CURRENT_DATE, 60052);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(60048, 60052, 'Flat'::timeband, 0.03, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '8', 60047);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 60052);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 60052);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 60052);
INSERT INTO route_to_target(route_id, gateway_id, sort) VALUES (60006, 60052, 204); -- Route B -> Gateway R



--GO

--######################################
--######################################
-- BLENDING TESTS

-- Route Test: TestBlendingLCR
INSERT INTO node (id, name) VALUES (500000, 'Yate500000');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (500000, '50.0.0.1/32'::inet, 500000, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (500001, 'ContextBlend500001', true, 10000, 1, 1085);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout, lcr_blend_percentage, lcr_blend_to_context_id)
	VALUES (500000, 'Context500000', true, 10000, 1, 1085, 100, 500001);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (500000, 1, 'Customer500000', 500000, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (500000, 500000, '51.0.0.1/32'::inet);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(500000, 'Gateway500000', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 500000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 500000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 500000);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(500000, 500000, '30.0.0.101', 5057, 'sip', '50.0.0.101'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (500000, 500000, 5);
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(500001, 'Gateway500001', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 500001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 500001);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 500001);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(500001, 500001, '30.0.0.102', 5057, 'sip', '50.0.0.102'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (500001, 500000, 2);
--Blending Gateway
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(500002, 'Gateway500002', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 500002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 500002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 500002);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(500002, 500002, '30.0.0.103', 5057, 'sip', '50.0.0.103'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (500002, 500000, 4);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(500000, 500000);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(500000, 500001);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(500001, 500002);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (500000, 500000);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (500000, 500001);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (500000, 500002);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (500000, CURRENT_DATE,  500000);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (500000, 500000, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 30, 1111101, 500000);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (500000, CURRENT_DATE, 500000);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(500000, 500000, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 500000);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (500001, CURRENT_DATE, 500001);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(500001, 500001, 'Flat'::timeband, 0.03,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 500001);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (500002, CURRENT_DATE, 500002);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(500002, 500002, 'Flat'::timeband, 0.035, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 500002);
INSERT INTO cache_number_gateway_statistic (gateway_id, number, asr, working, total)
	VALUES (500000, '1111101', 70, 70, 100);
INSERT INTO cache_number_gateway_statistic (gateway_id, number, asr, working, total)
	VALUES (500001, '1111101', 72, 70, 90);
INSERT INTO cache_number_gateway_statistic (gateway_id, number, asr, working, total)
	VALUES (500002, '1111101', 71, 70, 80);

--GO



-- Route Test: TestBlendingRoute
INSERT INTO node (id, name) VALUES (600000, 'Yate600000');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (600000, '60.0.0.1/32'::inet, 600000, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (600001, 'ContextBlend600001', true, 10000, 1, 1085);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (600000, 'Context600000', false, 10000, 1, 1085);
INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (600000, 1, 'Customer600000', 600000, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (600000, 600000, '61.0.0.1/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (600000, CURRENT_DATE,  600000);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (600000, 600000, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 30, 1111101, 600000);

-- target gateway
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600000, 'Gateway600000', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600000);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600000);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(600000, 600000, '90.0.0.101', 5057, 'sip', '90.0.0.101'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (600000, 600000, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (600000, 600000);

INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (600000, CURRENT_DATE, 600000);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(600000, 600000, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 600000);

-- route
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr, blend_percentage, blend_to_context_id)
	VALUES (600000, 600000, '\1', false, '.*', '', '', 0, true, false, 100, 600001);
INSERT INTO route_to_target(route_id, gateway_id, sort) VALUES (600000, 600000, 100);


-- blending gateway
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(600006, 'GatewayBlending600001', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 600006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 600006);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 600006);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(600006, 600006, '90.0.0.201', 5057, 'sip', '90.0.0.201'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (600006, 600000, 10);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(600001, 600006);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (600000, 600006);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (600006, CURRENT_DATE, 600006);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(600006, 600006, 'Flat'::timeband, 0.03,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 600006);

--GO


-- Route Test: TestBlendingRoute2

--Context 70000 -> Route 70001 -> Gateway 70002
--                 -> Gateway 70003
--                 -> Context 70004 -> Route 70005 -> Context (Blending) 70006 -> Gateway 70007
--                                     -> Gateway 70008

INSERT INTO node (id, name) VALUES (700000, 'Yate700000');
INSERT INTO node_ip (id, address, node_id, port, network) VALUES (700000, '70.0.0.1/32'::inet, 700000, 10000, 'Public');
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (700000, 'Context700000', false, 10000, 1, 1085);

INSERT INTO customer (id, company_id, name, context_id, fake_ringing, prefix, qos_group_id)
	VALUES (700000, 1, 'Customer700000', 700000, false, '', 1);
INSERT INTO customer_ip (id, customer_id, address) VALUES (700000, 700000, '71.0.0.1/32'::inet);
INSERT INTO customer_pricelist (id, date, customer_id)
	VALUES (700000, CURRENT_DATE,  700000);
INSERT INTO customer_price (id, customer_id, valid_from, valid_to, price, number, customer_pricelist_id)
	VALUES (700000, 700000, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', 30, 1111101, 700000);

-- target gateway
INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(700002, 'Gateway700002', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 700002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 700002);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 700002);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(700002, 700002, '90.0.0.101', 5057, 'sip', '90.0.0.101'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (700002, 700000, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (700000, 700002);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (700002, CURRENT_DATE, 700002);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(700002, 700002, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 700002);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(700003, 'Gateway700003', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 700003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 700003);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 700003);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(700003, 700003, '90.0.0.104', 5057, 'sip', '90.0.0.104'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (700003, 700000, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (700000, 700003);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (700003, CURRENT_DATE, 700003);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(700003, 700003, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 700003);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(700007, 'Gateway700007', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 700007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 700007);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 700007);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(700007, 700007, '90.0.0.103', 5057, 'sip', '90.0.0.103'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (700007, 700000, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (700000, 700007);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (700007, CURRENT_DATE, 700007);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(700007, 700007, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 700007);

INSERT INTO gateway (id, name, type, company_id, format_id, prefix, remove_country_code,
	concurrent_lines_limit, number_modification_group_id, qos_group_id)
VALUES(700008, 'Gateway700008', 'IP'::gatewaytype, 2, 1, '', false, null, null, 2);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (1, 700008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (2, 700008);
INSERT INTO format_gateway(format_id, gateway_id) VALUES (3, 700008);
INSERT INTO gateway_ip (id, gateway_id, address, port, protocol, rtp_address, rtp_port, rtp_forward, sip_p_asserted_identity)
	VALUES(700008, 700008, '90.0.0.102', 5057, 'sip', '90.0.0.102'::inet, 6057, true, '');
INSERT INTO gateway_ip_statistic (gateway_ip_id, node_id, billtime)
	VALUES (700008, 700000, 5);
INSERT INTO gateway_ip_node (node_id, gateway_ip_id) VALUES (700000, 700008);
INSERT INTO gateway_pricelist (id, date, gateway_id) VALUES (700008, CURRENT_DATE, 700008);
INSERT INTO gateway_price (id, gateway_id, timeband, price, valid_from, valid_to, number, gateway_pricelist_id)
	VALUES(700008, 700008, 'Flat'::timeband, 0.006,  CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', '1111101', 700008);

-- target context
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (700004, 'Context700004', false, 10000, 1, 1085);
INSERT INTO context (id, name, least_cost_routing, fork_connect_behavior_timeout, fork_connect_behavior, timeout)
	VALUES (700006, 'ContextBlending700006', true, 10000, 1, 1085);
INSERT INTO context_gateway(context_id, gateway_id) VALUES(700006, 700007);
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr, blend_percentage, blend_to_context_id)
	VALUES (700005, 700004, '\1', false, '.*', '', '', 0, true, false, 100, 700006);
INSERT INTO route_to_target(route_id, gateway_id, sort) VALUES (700005, 700008, 100);

-- route for gateways, context above
INSERT INTO route (id, context_id, action, did, pattern, caller, callername, sort, ignore_missing_rate, fallback_to_lcr)
	VALUES (700001, 700000, '\1', false, '.*', '', '', 0, true, false);
INSERT INTO route_to_target(route_id, gateway_id, sort) VALUES (700001, 700002, 98);
INSERT INTO route_to_target(route_id, gateway_id, sort) VALUES (700001, 700003, 99);
INSERT INTO route_to_target(route_id, context_id, sort) VALUES (700001, 700004, 100);

--GO





--######################################
--######################################
--######################################
--######################################

------ REFRESH VIEWS

REFRESH MATERIALIZED VIEW cache_customer_price;
REFRESH MATERIALIZED VIEW cache_gateway_price;
REFRESH MATERIALIZED VIEW cache_number_gateway_statistics;

