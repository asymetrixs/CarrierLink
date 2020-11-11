namespace CarrierLink.Controller.Engine.Test.Database.PgSQL
{
    using CheckModel;
    using Npgsql;
    using NpgsqlTypes;

    /// <summary>
    /// This class queries the database for data inserted by a test
    /// </summary>
    internal class DatabaseCheck : IDatabaseCheck
    {
        #region Methods

        /// <summary>
        /// Returns a record from the CDR table
        /// </summary>
        /// <param name="nodeId">Id of Node</param>
        /// <param name="billId">Id for Billing</param>
        /// <param name="chanId">Id of Channel</param>
        /// <returns>CDR data record</returns>
        public Cdr GetRecord(int nodeId, string billId, string chanId)
        {
            var cdr = new Cdr();

            using (var connection = new NpgsqlConnection(Setup.ConnectionStringVoipTest))
            {
                using (var command = new NpgsqlCommand())
                {
                    command.CommandText = "SELECT id, sqltime, yatetime, billid, chan, host(address), port, caller, callername, called, status, reason, ended," +
                        "gateway_account_id, gateway_ip_id, customer_ip_id, gateway_price_per_min, gateway_price_total, gateway_currency::TEXT, gateway_price_id," +
                        "customer_price_per_min, customer_price_total, customer_currency::TEXT, customer_price_id, dialcode_master_id, node_id, billed_on," +
                        "gateway_id, customer_id, format, formats, rtp_address, sqltime_end, tech_called, rtp_port, trackingid, billtime, ringtime, duration," +
                        "direction::TEXT, cause_q931, routing_waiting_time, routing_processing_time, error, cause_sip, sip_user_agent, sip_x_asterisk_hangupcause," +
                        "sip_x_asterisk_hangupcausecode, responsetime, rtp_packets_sent, rtp_octets_sent, rtp_packets_received, rtp_octets_received," +
                        "rtp_packet_loss, rtp_forward, routing_tree FROM cdr WHERE node_id = @nodeid AND billid = @billid AND chan = @chan;";

                    command.Connection = connection;
                    command.CommandType = System.Data.CommandType.Text;

                    command.Parameters.Add("nodeid", NpgsqlDbType.Integer).Value = nodeId;
                    command.Parameters.Add("billid", NpgsqlDbType.Text).Value = billId;
                    command.Parameters.Add("chan", NpgsqlDbType.Text).Value = chanId;
                    
                    try
                    {
                        connection.Open();

                        command.Prepare();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                int i = -1;
                                reader.Read();

                                cdr.Id = reader.GetInt64(++i);
                                cdr.SqlTime = reader.GetTimeStamp(++i).ToDateTime();
                                cdr.YateTime = reader.GetDecimal(++i);
                                cdr.BillId = reader.GetString(++i);
                                cdr.Chan = reader.GetString(++i);
                                cdr.Address = reader.GetString(++i);
                                cdr.Port = reader.GetInt32(++i);
                                cdr.Caller = reader.GetString(++i);
                                cdr.Callername = reader.GetString(++i);
                                cdr.Called = reader.GetString(++i);
                                cdr.Status = reader.GetString(++i);
                                cdr.Reason = reader.GetString(++i);
                                cdr.Ended = reader.GetBoolean(++i);
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayAccountId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayIpId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerIpId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayPricePerMin = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayPriceTotal = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayCurrency = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayPriceId = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerPricePerMin = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerPriceTotal = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerCurrency = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerPriceId = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.DialcodeMasterId = reader.GetInt32(i);
                                }
                                cdr.NodeId = reader.GetInt32(++i);

                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.BilledOn = reader.GetTimeStamp(i).ToDateTime();
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Format = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Formats = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPAddress = reader.GetValue(i).ToString();
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SqlTimeEnd = reader.GetTimeStamp(i).ToDateTime();
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.TechCalled = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPort = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.TrackingId = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.BillTime = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Ringtime = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Duration = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Direction = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CauseQ931 = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RoutingWaitingTime = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RoutingProcessingTime = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Error = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CauseSIP = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SIPUserAgent = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SIPXAsteriskHangupCause = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SIPXAsteriskHangupCauseCode = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.ResponseTime = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPacketsSent = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPOctetsSent = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPacketsReceived = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPOctetsReceived = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPacketLoss = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPForward = reader.GetBoolean(i);
                                }
                                if(!reader.IsDBNull(++i))
                                {
                                    cdr.RoutingTree = reader.GetString(i);
                                }
                            }
                        }
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        connection.Close();
                    }
                }
            }

            return cdr;
        }

        /// <summary>
        /// Returns a record from the CDR table
        /// </summary>
        /// <param name="nodeId">Id of Node</param>
        /// <param name="chanId">Id of Channel</param>
        /// <returns>CDR data record</returns>
        public Cdr GetRecord(int nodeId, string chanId)
        {
            var cdr = new Cdr();

            using (var connection = new NpgsqlConnection(Setup.ConnectionStringVoipTest))
            {
                using (var command = new NpgsqlCommand())
                {
                    command.CommandText = @"SELECT id, sqltime, yatetime, billid, chan, host(address), port, caller, callername, called, status,
                        reason, ended, gateway_account_id, gateway_ip_id, customer_ip_id, gateway_price_per_min, gateway_price_total,
                        gateway_currency::TEXT, gateway_price_id, customer_price_per_min, customer_price_total, customer_currency::TEXT,
                        customer_price_id, dialcode_master_id, node_id, billed_on, gateway_id, customer_id, format, formats, rtp_address, sqltime_end,
                        tech_called, rtp_port, trackingid, billtime, ringtime, duration, direction::TEXT, cause_q931, routing_waiting_time,
                        routing_processing_time, error, cause_sip, sip_user_agent, sip_x_asterisk_hangupcause, sip_x_asterisk_hangupcausecode,
                        responsetime, rtp_packets_sent, rtp_octets_sent, rtp_packets_received, rtp_octets_received, rtp_packet_loss, rtp_forward
                        FROM cdr WHERE node_id = @nodeid AND chan = @chan AND sqltime > NOW() - INTERVAL '3 hours';";
                    command.Connection = connection;
                    command.CommandType = System.Data.CommandType.Text;

                    command.Parameters.Add("nodeid", NpgsqlDbType.Integer).Value = nodeId;
                    command.Parameters.Add("chan", NpgsqlDbType.Text).Value = chanId;

                    try
                    {
                        connection.Open();

                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                int i = -1;
                                reader.Read();

                                cdr.Id = reader.GetInt64(++i);
                                cdr.SqlTime = reader.GetTimeStamp(++i).ToDateTime();
                                cdr.YateTime = reader.GetDecimal(++i);
                                cdr.BillId = reader.GetString(++i);
                                cdr.Chan = reader.GetString(++i);
                                cdr.Address = reader.GetString(++i);
                                cdr.Port = reader.GetInt32(++i);
                                cdr.Caller = reader.GetString(++i);
                                cdr.Callername = reader.GetString(++i);
                                cdr.Called = reader.GetString(++i);
                                cdr.Status = reader.GetString(++i);
                                cdr.Reason = reader.GetString(++i);
                                cdr.Ended = reader.GetBoolean(++i);
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayAccountId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayIpId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerIpId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayPricePerMin = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayPriceTotal = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayCurrency = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayPriceId = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerPricePerMin = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerPriceTotal = reader.GetDecimal(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerCurrency = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerPriceId = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.DialcodeMasterId = reader.GetInt32(i);
                                }
                                cdr.NodeId = reader.GetInt32(++i);

                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.BilledOn = reader.GetTimeStamp(i).ToDateTime();
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.GatewayId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CustomerId = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Format = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Formats = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPAddress = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SqlTimeEnd = reader.GetTimeStamp(i).ToDateTime();
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.TechCalled = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPort = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.TrackingId = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.BillTime = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Ringtime = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Duration = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Direction = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CauseQ931 = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RoutingWaitingTime = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RoutingProcessingTime = reader.GetInt32(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.Error = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.CauseSIP = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SIPUserAgent = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SIPXAsteriskHangupCause = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.SIPXAsteriskHangupCauseCode = reader.GetString(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.ResponseTime = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPacketsSent = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPOctetsSent = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPacketsReceived = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPOctetsReceived = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPPacketLoss = reader.GetInt64(i);
                                }
                                if (!reader.IsDBNull(++i))
                                {
                                    cdr.RTPForward = reader.GetBoolean(i);
                                }
                            }
                        }
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        connection.Close();
                    }
                }
            }

            return cdr;
        }

        #endregion
    }
}
