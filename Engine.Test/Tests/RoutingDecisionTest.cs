namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Mocking;
    using Workers;

    /// <summary>
    /// This class tests route functionality focusing on <see cref="Caching.Model.RoutingDecision"/> class.
    /// </summary>
    [TestClass]
    public class RoutingDecisionTest : AbstractTest
    {
        #region Tests

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrFtlLElwr()
        {
            var node = new MockNode(30000);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9000",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90000",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.0%z5060",
                    "billid=12345-900000",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9000:true:call.route::error=:reason=:"
            + "location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=30000:clcustomerid=50000:clcustomeripid=51000:cltrackingid=12345-900000:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53000:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z100015464165@6.1.0.0%z5055:callto.1.called=100015464165:callto.1.caller=496655885522:callto.1.callername=496655885522"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity="
             + ":callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:callto.1.rtp_addr=6.1.0.0:callto.1.rtp_forward=false:callto.1.rtp_port=6055"
             + ":callto.1.oconnection_id=general:callto.1.clgatewayid=60000:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=61000"
             + ":callto.1.cltechcalled=sip/sip%z100015464165@6.1.0.0%z5055:callto.1.clgatewaypriceid=63000"
             + ":callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1001"
             + ":callto.2=|next=10001"
             + ":callto.3=sip/sip%z100015464165@6.1.0.100%z5055:callto.3.called=100015464165:callto.3.caller=496655885522:callto.3.callername=496655885522"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity="
             + ":callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:callto.3.rtp_addr=6.1.0.100:callto.3.rtp_forward=false:callto.3.rtp_port=6055"
             + ":callto.3.oconnection_id=general:callto.3.clgatewayid=600001:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=610001"
             + ":callto.3.cltechcalled=sip/sip%z100015464165@6.1.0.100%z5055:callto.3.clgatewaypriceid=630001"
             + ":callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrFtlL()
        {
            var node = new MockNode(30001);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9001",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90001",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.1%z5060",
                    "billid=12345-900001",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9001:true:call.route::error=:reason=:"
            + "location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=30001:clcustomerid=50001:clcustomeripid=51001:cltrackingid=12345-900001:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53001:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z100015464165@6.1.0.1%z5055:callto.1.called=100015464165:callto.1.caller=496655885522:callto.1.callername=496655885522"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity="
             + ":callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:callto.1.rtp_addr=6.1.0.1:callto.1.rtp_forward=false:callto.1.rtp_port=6055"
             + ":callto.1.oconnection_id=general:callto.1.clgatewayid=60001:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=61001"
             + ":callto.1.cltechcalled=sip/sip%z100015464165@6.1.0.1%z5055:callto.1.clgatewaypriceid=63001"
             + ":callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1001"
             + ":callto.2=|next=10000"
             + ":callto.3=sip/sip%z100015464165@6.1.0.101%z5055:callto.3.called=100015464165:callto.3.caller=496655885522:callto.3.callername=496655885522"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity="
             + ":callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:callto.3.rtp_addr=6.1.0.101:callto.3.rtp_forward=false:callto.3.rtp_port=6055"
             + ":callto.3.oconnection_id=general:callto.3.clgatewayid=600011:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=610011"
             + ":callto.3.cltechcalled=sip/sip%z100015464165@6.1.0.101%z5055:callto.3.clgatewaypriceid=630011"
             + ":callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrFtlElwr()
        {
            var node = new MockNode(30002);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9002",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90002",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.2%z5060",
                    "billid=12345-900002",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9002:true:call.route::error=:"
            + "reason=:clnodeid=30002:clcustomerid=50002:clcustomeripid=51002:cltrackingid=12345-900002:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53002:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.2%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.2:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60002:clgatewayaccountid=:clgatewayipid=61002"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.2%z5055:clgatewaypriceid=63002:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrFtl()
        {
            var node = new MockNode(30003);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9003",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90003",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.3%z5060",
                    "billid=12345-900003",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9003:true:call.route::error=:"
            + "reason=:clnodeid=30003:clcustomerid=50003:clcustomeripid=51003:cltrackingid=12345-900003:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53003:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.3%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.3:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60003:clgatewayaccountid=:clgatewayipid=61003"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.3%z5055:clgatewaypriceid=63003:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrLElwr()
        {
            var node = new MockNode(30004);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9004",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90004",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.4%z5060",
                    "billid=12345-900004",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9004:true:call.route::error=:"
            + "reason=:clnodeid=30004:clcustomerid=50004:clcustomeripid=51004:cltrackingid=12345-900004:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53004:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.4%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.4:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60004:clgatewayaccountid=:clgatewayipid=61004"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.4%z5055:clgatewaypriceid=63004:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrL()
        {
            var node = new MockNode(30005);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9005",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90005",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.5%z5060",
                    "billid=12345-900005",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9005:true:call.route::error=:"
            + "reason=:clnodeid=30005:clcustomerid=50005:clcustomeripid=51005:cltrackingid=12345-900005:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53005:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.5%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.5:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60005:clgatewayaccountid=:clgatewayipid=61005"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.5%z5055:clgatewaypriceid=63005:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImrElwr()
        {
            var node = new MockNode(30006);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9006",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90006",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.6%z5060",
                    "billid=12345-900006",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9006:true:call.route::error=:"
            + "reason=:clnodeid=30006:clcustomerid=50006:clcustomeripid=51006:cltrackingid=12345-900006:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53006:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.6%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.6:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60006:clgatewayaccountid=:clgatewayipid=61006"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.6%z5055:clgatewaypriceid=63006:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoImr()
        {
            var node = new MockNode(30007);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9007",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90007",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.7%z5060",
                    "billid=12345-900007",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9007:true:call.route::error=:"
            + "reason=:clnodeid=30007:clcustomerid=50007:clcustomeripid=51007:cltrackingid=12345-900007:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53007:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.7%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.7:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60007:clgatewayaccountid=:clgatewayipid=61007"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.7%z5055:clgatewaypriceid=63007:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoFtlLElwr()
        {
            var node = new MockNode(30008);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9008",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90008",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.8%z5060",
                    "billid=12345-900008",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9008:true:call.route::error=:reason=:"
            + "location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=30008:clcustomerid=50008:clcustomeripid=51008:cltrackingid=12345-900008:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53008:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z100015464165@6.1.0.8%z5055:callto.1.called=100015464165:callto.1.caller=496655885522:callto.1.callername=496655885522"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity="
             + ":callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:callto.1.rtp_addr=6.1.0.8:callto.1.rtp_forward=false:callto.1.rtp_port=6055"
             + ":callto.1.oconnection_id=general:callto.1.clgatewayid=60008:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=61008"
             + ":callto.1.cltechcalled=sip/sip%z100015464165@6.1.0.8%z5055"
             + ":callto.1.clgatewaypriceid=63008:callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1001"
             + ":callto.2=|next=10002"
             + ":callto.3=sip/sip%z100015464165@6.1.0.108%z5055:callto.3.called=100015464165:callto.3.caller=496655885522:callto.3.callername=496655885522"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity="
             + ":callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:callto.3.rtp_addr=6.1.0.108:callto.3.rtp_forward=false:callto.3.rtp_port=6055"
             + ":callto.3.oconnection_id=general:callto.3.clgatewayid=600088:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=610088"
             + ":callto.3.cltechcalled=sip/sip%z100015464165@6.1.0.108%z5055"
             + ":callto.3.clgatewaypriceid=630088:callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoFtlL()
        {
            var node = new MockNode(30009);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9009",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90009",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.9%z5060",
                    "billid=12345-900009",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9009:true:call.route::error=:reason=:"
            + "location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=30009:clcustomerid=50009:clcustomeripid=51009:cltrackingid=12345-900009:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53009:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z100015464165@6.1.0.9%z5055:callto.1.called=100015464165:callto.1.caller=496655885522:callto.1.callername=496655885522"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity="
             + ":callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:callto.1.rtp_addr=6.1.0.9:callto.1.rtp_forward=false:callto.1.rtp_port=6055"
             + ":callto.1.oconnection_id=general:callto.1.clgatewayid=60009:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=61009"
             + ":callto.1.cltechcalled=sip/sip%z100015464165@6.1.0.9%z5055"
             + ":callto.1.clgatewaypriceid=63009:callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1001"
             + ":callto.2=|next=10000"
             + ":callto.3=sip/sip%z100015464165@6.1.0.109%z5055:callto.3.called=100015464165:callto.3.caller=496655885522:callto.3.callername=496655885522"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity="
             + ":callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:callto.3.rtp_addr=6.1.0.109:callto.3.rtp_forward=false:callto.3.rtp_port=6055"
             + ":callto.3.oconnection_id=general:callto.3.clgatewayid=600099:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=610099"
             + ":callto.3.cltechcalled=sip/sip%z100015464165@6.1.0.109%z5055"
             + ":callto.3.clgatewaypriceid=630099:callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoFtlElwr()
        {
            var node = new MockNode(30010);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9010",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90010",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.10%z5060",
                    "billid=12345-900010",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9010:true:call.route::error=:"
            + "reason=:clnodeid=30010:clcustomerid=50010:clcustomeripid=51010:cltrackingid=12345-900010:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53010:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.10%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.10:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60010:clgatewayaccountid=:clgatewayipid=61010"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.10%z5055:clgatewaypriceid=63010:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoFtl()
        {
            var node = new MockNode(30011);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9011",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90011",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.11%z5060",
                    "billid=12345-900011",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9011:true:call.route::error=:"
            + "reason=:clnodeid=30011:clcustomerid=50011:clcustomeripid=51011:cltrackingid=12345-900011:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53011:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.11%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.11:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60011:clgatewayaccountid=:clgatewayipid=61011"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.11%z5055:clgatewaypriceid=63011:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoLElwr()
        {
            var node = new MockNode(30012);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9012",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90012",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.12%z5060",
                    "billid=12345-900012",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9012:true:call.route::error=:"
            + "reason=:clnodeid=30012:clcustomerid=50012:clcustomeripid=51012:cltrackingid=12345-900012:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53012:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.12%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.12:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60012:clgatewayaccountid=:clgatewayipid=61012"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.12%z5055:clgatewaypriceid=63012:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoL()
        {
            var node = new MockNode(30013);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9013",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90013",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.13%z5060",
                    "billid=12345-900013",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9013:true:call.route::error=:"
            + "reason=:clnodeid=30013:clcustomerid=50013:clcustomeripid=51013:cltrackingid=12345-900013:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53013:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.13%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.13:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60013:clgatewayaccountid=:clgatewayipid=61013"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.13%z5055:clgatewaypriceid=63013:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRoElwr()
        {
            var node = new MockNode(30014);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9014",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90014",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.14%z5060",
                    "billid=12345-900014",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9014:true:call.route::error=:"
            + "reason=:clnodeid=30014:clcustomerid=50014:clcustomeripid=51014:cltrackingid=12345-900014:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53014:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.14%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.14:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60014:clgatewayaccountid=:clgatewayipid=61014"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.14%z5055:clgatewaypriceid=63014:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaRo()
        {
            var node = new MockNode(30015);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9015",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90015",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.15%z5060",
                    "billid=12345-900015",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9015:true:call.route::error=:"
            + "reason=:clnodeid=30015:clcustomerid=50015:clcustomeripid=51015:cltrackingid=12345-900015:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53015:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.15%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.15:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60015:clgatewayaccountid=:clgatewayipid=61015"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.15%z5055:clgatewaypriceid=63015:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrFtlLElwr()
        {
            var node = new MockNode(30016);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9016",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90016",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.16%z5060",
                    "billid=12345-900016",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100016464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9016:true:call.route::error=:"
            + "reason=:clnodeid=30016:clcustomerid=50016:clcustomeripid=51016:cltrackingid=12345-900016:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53016:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100016464165@6.1.0.116%z5055:called=100016464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.116:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000160:clgatewayaccountid=:clgatewayipid=6100160"
             + ":cltechcalled=sip/sip%z100016464165@6.1.0.116%z5055:clgatewaypriceid=6300160:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrFtlL()
        {
            var node = new MockNode(30017);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9017",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90017",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.17%z5060",
                    "billid=12345-900017",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100017464175"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9017:true:call.route::error=:"
            + "reason=:clnodeid=30017:clcustomerid=50017:clcustomeripid=51017:cltrackingid=12345-900017:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53017:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100017464175@6.1.0.117%z5055:called=100017464175:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.117:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000170:clgatewayaccountid=:clgatewayipid=6100170"
             + ":cltechcalled=sip/sip%z100017464175@6.1.0.117%z5055:clgatewaypriceid=6300170:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrFtlElwr()
        {
            var node = new MockNode(30018);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9018",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90018",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.18%z5060",
                    "billid=12345-900018",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100018464185"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9018:true:call.route::error=403:"
            + "reason=:clnodeid=30018:clcustomerid=50018:clcustomeripid=51018:cltrackingid=12345-900018:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53018:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrFtl()
        {
            var node = new MockNode(30019);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9019",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90019",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.19%z5060",
                    "billid=12345-900019",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100019464195"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9019:true:call.route::error=403:"
            + "reason=:clnodeid=30019:clcustomerid=50019:clcustomeripid=51019:cltrackingid=12345-900019:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53019:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrLElwt()
        {
            var node = new MockNode(30020);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9020",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90020",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.20%z5060",
                    "billid=12345-900020",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100020464205"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9020:true:call.route::error=:"
            + "reason=:clnodeid=30020:clcustomerid=50020:clcustomeripid=51020:cltrackingid=12345-900020:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53020:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100020464205@6.1.0.120%z5055:called=100020464205:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.120:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000200:clgatewayaccountid=:clgatewayipid=6100200"
             + ":cltechcalled=sip/sip%z100020464205@6.1.0.120%z5055:clgatewaypriceid=6300200:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrL()
        {
            var node = new MockNode(30021);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9021",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90021",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.21%z5060",
                    "billid=12345-900021",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100021464215"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9021:true:call.route::error=:"
            + "reason=:clnodeid=30021:clcustomerid=50021:clcustomeripid=51021:cltrackingid=12345-900021:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53021:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100021464215@6.1.0.121%z5055:called=100021464215:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.121:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000210:clgatewayaccountid=:clgatewayipid=6100210"
             + ":cltechcalled=sip/sip%z100021464215@6.1.0.121%z5055:clgatewaypriceid=6300210:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImrElwr()
        {
            var node = new MockNode(30022);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9022",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90022",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.22%z5060",
                    "billid=12345-900022",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100022464225"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9022:true:call.route::error=403:"
            + "reason=:clnodeid=30022:clcustomerid=50022:clcustomeripid=51022:cltrackingid=12345-900022:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53022:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaImr()
        {
            var node = new MockNode(30023);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9023",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90023",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.23%z5060",
                    "billid=12345-900023",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9023:true:call.route::error=403:"
            + "reason=:clnodeid=30023:clcustomerid=50023:clcustomeripid=51023:cltrackingid=12345-900023:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53023:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaFtlLElwr()
        {
            var node = new MockNode(30024);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9024",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90024",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.24%z5060",
                    "billid=12345-900024",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885524",
                    "callername=496655885524",
                    "called=100024464245"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9024:true:call.route::error=:"
            + "reason=:clnodeid=30024:clcustomerid=50024:clcustomeripid=51024:cltrackingid=12345-900024:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53024:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100024464245@6.1.0.124%z5055:called=100024464245:caller=496655885524:callername=496655885524:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.124:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000240:clgatewayaccountid=:clgatewayipid=6100240"
             + ":cltechcalled=sip/sip%z100024464245@6.1.0.124%z5055:clgatewaypriceid=6300240:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaFtlL()
        {
            var node = new MockNode(30025);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9025",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90025",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.25%z5060",
                    "billid=12345-900025",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885524",
                    "callername=496655885524",
                    "called=100024464245"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9025:true:call.route::error=:"
            + "reason=:clnodeid=30025:clcustomerid=50025:clcustomeripid=51025:cltrackingid=12345-900025:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53025:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100024464245@6.1.0.125%z5055:called=100024464245:caller=496655885524:callername=496655885524:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.125:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000250:clgatewayaccountid=:clgatewayipid=6100250"
             + ":cltechcalled=sip/sip%z100024464245@6.1.0.125%z5055:clgatewaypriceid=6300250:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaFtlElwr()
        {
            var node = new MockNode(30026);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9026",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90026",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.26%z5060",
                    "billid=12345-900026",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9026:true:call.route::error=403:"
            + "reason=:clnodeid=30026:clcustomerid=50026:clcustomeripid=51026:cltrackingid=12345-900026:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53026:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaFtl()
        {
            var node = new MockNode(30027);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9027",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90027",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.27%z5060",
                    "billid=12345-900027",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9027:true:call.route::error=403:"
            + "reason=:clnodeid=30027:clcustomerid=50027:clcustomeripid=51027:cltrackingid=12345-900027:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53027:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaLElwr()
        {
            var node = new MockNode(30028);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9028",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90028",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.28%z5060",
                    "billid=12345-900028",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885524",
                    "callername=496655885524",
                    "called=100024464245"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9028:true:call.route::error=:"
            + "reason=:clnodeid=30028:clcustomerid=50028:clcustomeripid=51028:cltrackingid=12345-900028:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53028:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100024464245@6.1.0.128%z5055:called=100024464245:caller=496655885524:callername=496655885524:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.128:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000280:clgatewayaccountid=:clgatewayipid=6100280"
             + ":cltechcalled=sip/sip%z100024464245@6.1.0.128%z5055:clgatewaypriceid=6300280:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRaL()
        {
            var node = new MockNode(30029);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9029",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90029",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.29%z5060",
                    "billid=12345-900029",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885524",
                    "callername=496655885524",
                    "called=100024464245"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9029:true:call.route::error=:"
            + "reason=:clnodeid=30029:clcustomerid=50029:clcustomeripid=51029:cltrackingid=12345-900029:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53029:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100024464245@6.1.0.129%z5055:called=100024464245:caller=496655885524:callername=496655885524:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.129:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=6000290:clgatewayaccountid=:clgatewayipid=6100290"
             + ":cltechcalled=sip/sip%z100024464245@6.1.0.129%z5055:clgatewaypriceid=6300290:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRaElwr()
        {
            var node = new MockNode(30030);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9030",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90030",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.30%z5060",
                    "billid=12345-900030",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9030:true:call.route::error=403:"
            + "reason=:clnodeid=30030:clcustomerid=50030:clcustomeripid=51030:cltrackingid=12345-900030:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53030:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRa()
        {
            var node = new MockNode(31031);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9031",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90031",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.31%z5060",
                    "billid=12345-900031",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9031:true:call.route::error=403:"
            + "reason=:clnodeid=31031:clcustomerid=50031:clcustomeripid=51031:cltrackingid=12345-900031:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=53131:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrFtlLElwr()
        {
            var node = new MockNode(30032);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9032",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90032",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.32%z5060",
                    "billid=12345-900032",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9032:true:call.route::error=:reason=:"
            + "location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=30032:clcustomerid=50032:clcustomeripid=51032:cltrackingid=12345-900032:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z100015464165@6.1.0.32%z5055:callto.1.called=100015464165:callto.1.caller=496655885522:callto.1.callername=496655885522"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity="
             + ":callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:callto.1.rtp_addr=6.1.0.32:callto.1.rtp_forward=false:callto.1.rtp_port=6055"
             + ":callto.1.oconnection_id=general:callto.1.clgatewayid=60032:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=61032"
             + ":callto.1.cltechcalled=sip/sip%z100015464165@6.1.0.32%z5055:callto.1.clgatewaypriceid=63032"
             + ":callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1001"
             + ":callto.2=|next=10000"
             + ":callto.3=sip/sip%z100015464165@6.1.0.132%z5055:callto.3.called=100015464165:callto.3.caller=496655885522:callto.3.callername=496655885522"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity="
             + ":callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:callto.3.rtp_addr=6.1.0.132:callto.3.rtp_forward=false:callto.3.rtp_port=6055"
             + ":callto.3.oconnection_id=general:callto.3.clgatewayid=600320:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=6100320"
             + ":callto.3.cltechcalled=sip/sip%z100015464165@6.1.0.132%z5055:callto.3.clgatewaypriceid=6300320"
             + ":callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrFtlL()
        {
            var node = new MockNode(30033);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9033",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90033",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.33%z5060",
                    "billid=12345-900033",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9033:true:call.route::error=:"
            + "reason=:clnodeid=30033:clcustomerid=50033:clcustomeripid=51033:cltrackingid=12345-900033:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.33%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.33:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60033:clgatewayaccountid=:clgatewayipid=61033"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.33%z5055:clgatewaypriceid=63033:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrFtlElw()
        {
            var node = new MockNode(30034);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9034",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90034",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.34%z5060",
                    "billid=12345-900034",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9034:true:call.route::error=:"
            + "reason=:clnodeid=30034:clcustomerid=50034:clcustomeripid=51034:cltrackingid=12345-900034:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.34%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.34:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60034:clgatewayaccountid=:clgatewayipid=61034"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.34%z5055:clgatewaypriceid=63034:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrFtl()
        {
            var node = new MockNode(30035);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9035",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90035",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.35%z5060",
                    "billid=12345-900035",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9035:true:call.route::error=:"
            + "reason=:clnodeid=30035:clcustomerid=50035:clcustomeripid=51035:cltrackingid=12345-900035:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.35%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.35:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60035:clgatewayaccountid=:clgatewayipid=61035"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.35%z5055:clgatewaypriceid=63035:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrLElwr()
        {
            var node = new MockNode(30036);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9036",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90036",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.36%z5060",
                    "billid=12345-900036",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9036:true:call.route::error=:"
            + "reason=:clnodeid=30036:clcustomerid=50036:clcustomeripid=51036:cltrackingid=12345-900036:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.36%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.36:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60036:clgatewayaccountid=:clgatewayipid=61036"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.36%z5055:clgatewaypriceid=63036:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrL()
        {
            var node = new MockNode(30037);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9037",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90037",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.37%z5060",
                    "billid=12345-900037",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9037:true:call.route::error=:"
            + "reason=:clnodeid=30037:clcustomerid=50037:clcustomeripid=51037:cltrackingid=12345-900037:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.37%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.37:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60037:clgatewayaccountid=:clgatewayipid=61037"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.37%z5055:clgatewaypriceid=63037:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImrElwr()
        {
            var node = new MockNode(30038);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9038",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90038",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.38%z5060",
                    "billid=12345-900038",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9038:true:call.route::error=:"
            + "reason=:clnodeid=30038:clcustomerid=50038:clcustomeripid=51038:cltrackingid=12345-900038:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.38%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.38:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60038:clgatewayaccountid=:clgatewayipid=61038"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.38%z5055:clgatewaypriceid=63038:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoImr()
        {
            var node = new MockNode(30039);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9039",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90039",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.39%z5060",
                    "billid=12345-900039",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9039:true:call.route::error=:"
            + "reason=:clnodeid=30039:clcustomerid=50039:clcustomeripid=51039:cltrackingid=12345-900039:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.39%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.39:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=60039:clgatewayaccountid=:clgatewayipid=61039"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.39%z5055:clgatewaypriceid=63039:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionRoFtlLElwr()
        {
            var node = new MockNode(30040);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9040",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90040",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.40%z5060",
                    "billid=12345-900040",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9040:true:call.route::error=:"
            + "reason=:clnodeid=30040:clcustomerid=50040:clcustomeripid=51040:cltrackingid=12345-900040:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.140%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.140:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=600400:clgatewayaccountid=:clgatewayipid=6100400"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.140%z5055:clgatewaypriceid=6300400:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoFtlL()
        {
            var node = new MockNode(30041);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9041",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90041",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.41%z5060",
                    "billid=12345-900041",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9041:true:call.route::error=403:"
            + "reason=:clnodeid=30041:clcustomerid=50041:clcustomeripid=51041:cltrackingid=12345-900041:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoFtlElwr()
        {
            var node = new MockNode(30042);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9042",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90042",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.42%z5060",
                    "billid=12345-900042",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464235"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9042:true:call.route::error=403:"
            + "reason=:clnodeid=30042:clcustomerid=50042:clcustomeripid=51042:cltrackingid=12345-900042:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoFtl()
        {
            var node = new MockNode(30043);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9043",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90043",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.43%z5060",
                    "billid=12345-900043",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9043:true:call.route::error=403:"
            + "reason=:clnodeid=30043:clcustomerid=50043:clcustomeripid=51043:cltrackingid=12345-900043:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoLElwr()
        {
            var node = new MockNode(30044);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9044",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90044",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.44%z5060",
                    "billid=12345-900044",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9044:true:call.route::error=403:"
            + "reason=:clnodeid=30044:clcustomerid=50044:clcustomeripid=51044:cltrackingid=12345-900044:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoL()
        {
            var node = new MockNode(30045);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9045",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90045",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.45%z5060",
                    "billid=12345-900045",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9045:true:call.route::error=403:"
            + "reason=:clnodeid=30045:clcustomerid=50045:clcustomeripid=51045:cltrackingid=12345-900045:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRoElwr()
        {
            var node = new MockNode(30046);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9046",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90046",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.46%z5060",
                    "billid=12346-900046",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023464335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9046:true:call.route::error=403:"
            + "reason=:clnodeid=30046:clcustomerid=50046:clcustomeripid=51046:cltrackingid=12346-900046:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionRo()
        {
            var node = new MockNode(30047);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9047",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90047",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.47%z5060",
                    "billid=12345-900047",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023484335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9047:true:call.route::error=403:"
            + "reason=:clnodeid=30047:clcustomerid=50047:clcustomeripid=51047:cltrackingid=12345-900047:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionImrFtlLElwr()
        {
            var node = new MockNode(30048);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9048",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90048",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.48%z5060",
                    "billid=12345-900048",
                    "answered=false",
                    "direction=incoming",
                    "caller=486655885523",
                    "callername=486655885523",
                    "called=100023474335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9048:true:call.route::error=:"
            + "reason=:clnodeid=30048:clcustomerid=50048:clcustomeripid=51048:cltrackingid=12345-900048:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100023474335@6.1.0.148%z5055:called=100023474335:caller=486655885523:callername=486655885523:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.148:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=600480:clgatewayaccountid=:clgatewayipid=6100480"
             + ":cltechcalled=sip/sip%z100023474335@6.1.0.148%z5055:clgatewaypriceid=6300480:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionImrFtlL()
        {
            var node = new MockNode(30049);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9049",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90049",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.49%z5060",
                    "billid=12349-900049",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885523",
                    "callername=496655885523",
                    "called=100023494335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9049:true:call.route::error=403:"
            + "reason=:clnodeid=30049:clcustomerid=50049:clcustomeripid=51049:cltrackingid=12349-900049:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionImrFtlElwr()
        {
            var node = new MockNode(30050);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9050",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90050",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.50%z5060",
                    "billid=12345-900050",
                    "answered=false",
                    "direction=incoming",
                    "caller=506655885523",
                    "callername=506655885523",
                    "called=100023504335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9050:true:call.route::error=403:"
            + "reason=:clnodeid=30050:clcustomerid=50050:clcustomeripid=51050:cltrackingid=12345-900050:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionImrFtl()
        {
            var node = new MockNode(30051);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9051",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90051",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.51%z5160",
                    "billid=12345-900051",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9051:true:call.route::error=403:"
            + "reason=:clnodeid=30051:clcustomerid=51051:clcustomeripid=51051:cltrackingid=12345-900051:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionImrLElwr()
        {
            var node = new MockNode(30052);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9052",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90052",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.52%z5060",
                    "billid=12345-900052",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9052:true:call.route::error=:"
            + "reason=:clnodeid=30052:clcustomerid=50052:clcustomeripid=51052:cltrackingid=12345-900052:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.152%z5055:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.152:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=600520:clgatewayaccountid=:clgatewayipid=6100520"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.152%z5055:clgatewaypriceid=6300520:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionImrL()
        {
            var node = new MockNode(30053);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9053",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90053",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.53%z5360",
                    "billid=12345-900053",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9053:true:call.route::error=403:"
            + "reason=:clnodeid=30053:clcustomerid=50053:clcustomeripid=51053:cltrackingid=12345-900053:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionImrElwr()
        {
            var node = new MockNode(30054);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9054",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90054",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.54%z5460",
                    "billid=12345-900054",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9054:true:call.route::error=403:"
            + "reason=:clnodeid=30054:clcustomerid=50054:clcustomeripid=51054:cltrackingid=12345-900054:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionImr()
        {
            var node = new MockNode(30055);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9055",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90055",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.55%z5560",
                    "billid=12345-900055",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9055:true:call.route::error=403:"
            + "reason=:clnodeid=30055:clcustomerid=50055:clcustomeripid=51055:cltrackingid=12345-900055:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionFtlLElwr()
        {
            var node = new MockNode(30056);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9056",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90056",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.56%z5060",
                    "billid=12345-900056",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9056:true:call.route::error=:"
            + "reason=:clnodeid=30056:clcustomerid=50056:clcustomeripid=51056:cltrackingid=12345-900056:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.156%z5056:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.156:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=600560:clgatewayaccountid=:clgatewayipid=6100560"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.156%z5056:clgatewaypriceid=6300560:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionFtlL()
        {
            var node = new MockNode(30057);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9057",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90057",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.57%z5560",
                    "billid=12345-900057",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9057:true:call.route::error=403:"
            + "reason=:clnodeid=30057:clcustomerid=50057:clcustomeripid=51057:cltrackingid=12345-900057:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionFtlElwr()
        {
            var node = new MockNode(30058);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9058",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90058",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.58%z5560",
                    "billid=12345-900058",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9058:true:call.route::error=403:"
            + "reason=:clnodeid=30058:clcustomerid=50058:clcustomeripid=51058:cltrackingid=12345-900058:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionFtl()
        {
            var node = new MockNode(30059);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9059",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90059",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.59%z5560",
                    "billid=12345-900059",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9059:true:call.route::error=403:"
            + "reason=:clnodeid=30059:clcustomerid=50059:clcustomeripid=51059:cltrackingid=12345-900059:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true
        /// </summary>
        [TestMethod]
        public void TestDecisionLElwr()
        {
            var node = new MockNode(30060);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9060",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90060",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.60%z5060",
                    "billid=12345-900060",
                    "answered=false",
                    "direction=incoming",
                    "caller=496655885522",
                    "callername=496655885522",
                    "called=100015464165"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9060:true:call.route::error=:"
            + "reason=:clnodeid=30060:clcustomerid=50060:clcustomeripid=51060:cltrackingid=12345-900060:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z100015464165@6.1.0.160%z5056:called=100015464165:caller=496655885522:callername=496655885522:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=6.1.0.160:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=600600:clgatewayaccountid=:clgatewayipid=6100600"
             + ":cltechcalled=sip/sip%z100015464165@6.1.0.160%z5056:clgatewaypriceid=6300600:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=1001\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionL()
        {
            var node = new MockNode(30061);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9061",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90061",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.61%z5560",
                    "billid=12345-900061",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9061:true:call.route::error=403:"
            + "reason=:clnodeid=30061:clcustomerid=50061:clcustomeripid=51061:cltrackingid=12345-900061:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecisionElwr()
        {
            var node = new MockNode(30062);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9062",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90062",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.62%z5560",
                    "billid=12345-900062",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9062:true:call.route::error=403:"
            + "reason=:clnodeid=30062:clcustomerid=50062:clcustomeripid=51062:cltrackingid=12345-900062:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        /// <summary>
        /// hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false
        /// </summary>
        [TestMethod]
        public void TestDecision()
        {
            var node = new MockNode(30063);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "9063",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/90063",
                    "module=sip",
                    "status=incoming",
                    "address=5.1.0.63%z5560",
                    "billid=12345-900063",
                    "answered=false",
                    "direction=incoming",
                    "caller=516655885523",
                    "callername=516655885523",
                    "called=100023514335"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:9063:true:call.route::error=403:"
            + "reason=:clnodeid=30063:clcustomerid=50063:clcustomeripid=51063:cltrackingid=12345-900063:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=20000:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));
        }

        #endregion
    }
}
