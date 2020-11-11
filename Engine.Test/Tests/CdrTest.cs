namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Caching;
    using Database.PgSQL;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Mocking;
    using System.Threading.Tasks;
    using Workers;

    /// <summary>
    /// This class tests cdr-writing functionality
    /// </summary>
    [TestClass]
    public class CdrTest : AbstractTest
    {
        #region Tests

        [TestMethod]
        public void TestCdrError484AndRoutingTree()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "chan=sip/852978",
                    "operation=initialize",
                    "duration=0",
                    "ringtime=0",
                    "billtime=0",
                    "module=sip",
                    "error=484",
                    "reason=",
                    "status=incoming",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-1",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=355871111111",
                    "callername=00012521339915",
                    "clcustomerid=12",
                    "clcustomeripid=13",
                    "clprocessingtime=52",
                    "clwaitingtime=13",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-1",
                    "format=g729",
                    "formats=g729,alaw,mulaw"
                    ));

            // Routing tree to retrieve
            Utilities.RoutingTree.Root rtRoot = new Utilities.RoutingTree.Root();
            rtRoot.Context = new Utilities.RoutingTree.Context();
            rtRoot.Context.AddReason(Utilities.RoutingTree.Reason.OK);
            rtRoot.Context.AddRoutingAction(Utilities.RoutingTree.ContextAction.Fixed);
            rtRoot.Context.SetId(1);
            Utilities.RoutingTree.Route rtRoute = new Utilities.RoutingTree.Route(1);
            rtRoot.Context.SetRoute(rtRoute);
            Utilities.RoutingTree.Gateway rtGateway = new Utilities.RoutingTree.Gateway();
            rtGateway.SetId(3);
            rtGateway.AddReason(Utilities.RoutingTree.Reason.OK);
            rtRoute.Targets.Add(rtGateway);
            rtRoot.AddGatewayId(rtGateway.Id.Value);

            LiveCache.AddOrReplace($"routingTree-{node.Id}-1418778188-1", rtRoot);

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-1", "sip/852978");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsTrue(cdr.Chan == "sip/852978");
            Assert.IsTrue(cdr.Duration == 0);
            Assert.IsTrue(cdr.Ringtime == 0);
            Assert.IsTrue(cdr.BillTime == 0);
            Assert.IsTrue(cdr.Error == "484");
            Assert.IsTrue(cdr.Reason == "");
            Assert.IsTrue(cdr.Status == "incoming");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-1");
            Assert.IsTrue(cdr.Direction == "incoming");
            Assert.IsTrue(cdr.Caller == "00012521339915");
            Assert.IsTrue(cdr.Called == "355871111111");
            Assert.IsTrue(cdr.Callername == "00012521339915");
            Assert.IsTrue(cdr.TrackingId == "1418778188-1");
            Assert.IsNull(cdr.GatewayId);
            Assert.IsTrue(cdr.CustomerId == 12);
            Assert.IsTrue(cdr.CustomerIpId == 13);
            Assert.IsTrue(cdr.RoutingProcessingTime == 52);
            Assert.IsTrue(cdr.RoutingWaitingTime == 13);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsNull(cdr.CustomerPriceId);
            Assert.IsNull(cdr.CustomerPricePerMin);
            Assert.IsNull(cdr.CustomerPriceTotal);
            Assert.IsNull(cdr.CustomerCurrency);
            Assert.IsNull(cdr.GatewayPriceId);
            Assert.IsNull(cdr.GatewayPricePerMin);
            Assert.IsNull(cdr.GatewayPriceTotal);
            Assert.IsNull(cdr.GatewayCurrency);
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsFalse(cdr.RTPForward.Value);
            Assert.IsNotNull(cdr.RoutingTree);
            Assert.AreEqual(cdr.RoutingTree, @"{""Context"": {""Id"": 1, ""Route"": {""Id"": 1, ""Targets"": [{""Id"": 3, ""Via"": null, ""Endpoint"": ""Gateway"", ""TargetReason"": ""OK""}], ""BlendingContext"": [], ""IsFallbackToLCR"": false}, ""Endpoint"": ""Context"", ""LCRGateways"": [], ""TargetReason"": ""OK"", ""RoutingAction"": ""Fixed"", ""BlendingContext"": null, ""InternalRoutedGateway"": null}, ""GatewayOrder"": [3]}");
        }

        #region Incoming

        [TestMethod]
        public void TestCdrIncomingInitialize()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479209",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=false",
                    "chan=sip/1556",
                    "operation=initialize",
                    "duration=10,8",
                    "ringtime=5,7",
                    "billtime=5,6",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=incoming",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=51",
                    "clcustomeripid=451",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clcustomerpriceid=351",
                    "clcustomerpricepermin=0,03",
                    "clcustomercurrency=USD",
                    "rtp_forward=false"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479209:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1556");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsFalse(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1556");
            Assert.IsTrue(cdr.Duration == 10800);
            Assert.IsTrue(cdr.Ringtime == 5700);
            Assert.IsTrue(cdr.BillTime == 5600);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "incoming");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "incoming");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.CustomerId == 51);
            Assert.IsTrue(cdr.CustomerIpId == 451);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsTrue(cdr.CustomerPriceId == 351);
            Assert.IsTrue(cdr.CustomerPricePerMin == 0.03M);
            Assert.IsTrue(cdr.CustomerPriceTotal == 0.03M / 60000 * cdr.BillTime);
            Assert.IsTrue(cdr.CustomerCurrency == "USD");
            Assert.IsNull(cdr.GatewayId);
            Assert.IsNull(cdr.GatewayIpId);
            Assert.IsNull(cdr.GatewayAccountId);
            Assert.IsNull(cdr.GatewayPriceId);
            Assert.IsNull(cdr.GatewayPricePerMin);
            Assert.IsNull(cdr.GatewayPriceTotal);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.GatewayCurrency));
            Assert.IsNull(cdr.RTPAddress);
            Assert.IsNull(cdr.RTPPort);
            Assert.IsFalse(cdr.RTPForward.Value);
        }

        [TestMethod]
        public void TestCdrIncomingUpdate1()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479210",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=false",
                    "chan=sip/1556",
                    "operation=initialize",
                    "duration=20",
                    "ringtime=5",
                    "billtime=15",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=incoming",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=51",
                    "clcustomeripid=451",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clcustomerpriceid=351",
                    "clcustomerpricepermin=0,03",
                    "clcustomercurrency=USD",
                    "rtp_forward=true"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479210:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1556");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsFalse(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1556");
            Assert.IsTrue(cdr.Duration == 20000);
            Assert.IsTrue(cdr.Ringtime == 5000);
            Assert.IsTrue(cdr.BillTime == 15000);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "incoming");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "incoming");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.CustomerId == 51);
            Assert.IsTrue(cdr.CustomerIpId == 451);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsTrue(cdr.CustomerPriceId == 351);
            Assert.IsTrue(cdr.CustomerPricePerMin == 0.03M);
            Assert.IsTrue(cdr.CustomerPriceTotal == 0.03M / 60000 * cdr.BillTime);
            Assert.IsTrue(cdr.CustomerCurrency == "USD");
            Assert.IsNull(cdr.GatewayId);
            Assert.IsNull(cdr.GatewayIpId);
            Assert.IsNull(cdr.GatewayAccountId);
            Assert.IsNull(cdr.GatewayPriceId);
            Assert.IsNull(cdr.GatewayPricePerMin);
            Assert.IsNull(cdr.GatewayPriceTotal);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.GatewayCurrency));
            Assert.IsNull(cdr.RTPAddress);
            Assert.IsNull(cdr.RTPPort);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        [TestMethod]
        public void TestCdrIncomingFinalize()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479211",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=true",
                    "chan=sip/1556",
                    "operation=initialize",
                    "duration=60",
                    "ringtime=5",
                    "billtime=55",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=incoming",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=51",
                    "clcustomeripid=451",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clcustomerpriceid=351",
                    "clcustomerpricepermin=0,03",
                    "clcustomercurrency=USD",
                    "rtp_forward=true"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479211:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1556");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsTrue(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1556");
            Assert.IsTrue(cdr.Duration == 60000);
            Assert.IsTrue(cdr.Ringtime == 5000);
            Assert.IsTrue(cdr.BillTime == 55000);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "incoming");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "incoming");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.CustomerId == 51);
            Assert.IsTrue(cdr.CustomerIpId == 451);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsTrue(cdr.CustomerPriceId == 351);
            Assert.IsTrue(cdr.CustomerPricePerMin == 0.03M);
            Assert.IsTrue(cdr.CustomerPriceTotal == 0.03M / 60000 * cdr.BillTime);
            Assert.IsTrue(cdr.CustomerCurrency == "USD");
            Assert.IsNull(cdr.GatewayId);
            Assert.IsNull(cdr.GatewayIpId);
            Assert.IsNull(cdr.GatewayAccountId);
            Assert.IsNull(cdr.GatewayPriceId);
            Assert.IsNull(cdr.GatewayPricePerMin);
            Assert.IsNull(cdr.GatewayPriceTotal);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.GatewayCurrency));
            Assert.IsNull(cdr.RTPAddress);
            Assert.IsNull(cdr.RTPPort);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        [TestMethod]
        public void TestCdrIncomingUpdate2()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479212",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=false",
                    "chan=sip/1556",
                    "operation=initialize",
                    "duration=55",
                    "ringtime=5",
                    "billtime=50",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=incoming",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=51",
                    "clcustomeripid=451",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clcustomerpriceid=351",
                    "clcustomerpricepermin=0,03",
                    "clcustomercurrency=USD",
                    "rtp_forward=true"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479212:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1556");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsTrue(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1556");
            Assert.IsTrue(cdr.Duration == 60000);
            Assert.IsTrue(cdr.Ringtime == 5000);
            Assert.IsTrue(cdr.BillTime == 55000);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "incoming");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "incoming");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.CustomerId == 51);
            Assert.IsTrue(cdr.CustomerIpId == 451);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsTrue(cdr.CustomerPriceId == 351);
            Assert.IsTrue(cdr.CustomerPricePerMin == 0.03M);
            Assert.IsTrue(cdr.CustomerPriceTotal == 0.03M / 60000 * cdr.BillTime);
            Assert.IsTrue(cdr.CustomerCurrency == "USD");
            Assert.IsNull(cdr.GatewayId);
            Assert.IsNull(cdr.GatewayIpId);
            Assert.IsNull(cdr.GatewayAccountId);
            Assert.IsNull(cdr.GatewayPriceId);
            Assert.IsNull(cdr.GatewayPricePerMin);
            Assert.IsNull(cdr.GatewayPriceTotal);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.GatewayCurrency));
            Assert.IsNull(cdr.RTPAddress);
            Assert.IsNull(cdr.RTPPort);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        #endregion

        #region Outgoing

        [TestMethod]
        public void TestCdrOutgoingInitialize()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479220",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=false",
                    "chan=sip/1557",
                    "operation=initialize",
                    "duration=10,8",
                    "ringtime=5,7",
                    "billtime=5,6",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=outgoing",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=outgoing",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=",
                    "clcustomeripid=",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clgatewayid=51033",
                    "clgatewayipid=6103",
                    "clgatewayaccountid=780",
                    "clgatewaypriceid=44",
                    "clgatewaypricepermin=0,035",
                    "clgatewaycurrency=USD",
                    "rtp_addr=11.10.20.104",
                    "rtp_forward=true",
                    "rtp_port=6057"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479220:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1557");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsFalse(cdr.Ended);
            Assert.AreEqual<string>(cdr.Chan, "sip/1557");
            Assert.IsTrue(cdr.Duration.HasValue);
            Assert.AreEqual<long>(cdr.Duration.Value, 10800);
            Assert.IsTrue(cdr.Ringtime.HasValue);
            Assert.AreEqual<long>(cdr.Ringtime.Value, 5700);
            Assert.IsTrue(cdr.BillTime.HasValue);
            Assert.AreEqual<long>(cdr.BillTime.Value, 5600);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.AreEqual<string>(cdr.Status, "outgoing");
            Assert.AreEqual<string>(cdr.Address, "10.10.15.28");
            Assert.AreEqual<string>(cdr.BillId, "1418778188-2");
            Assert.AreEqual<string>(cdr.Direction, "outgoing");
            Assert.AreEqual<string>(cdr.Caller, "0001252133996");
            Assert.AreEqual<string>(cdr.Called, "355871111122");
            Assert.AreEqual<string>(cdr.Callername, "0001252133993");
            Assert.AreEqual<string>(cdr.TrackingId, "1418778188-2");
            Assert.IsNull(cdr.CustomerId);
            Assert.IsNull(cdr.CustomerIpId);
            Assert.IsTrue(cdr.RoutingProcessingTime.HasValue);
            Assert.AreEqual<int>(cdr.RoutingProcessingTime.Value, 40);
            Assert.IsTrue(cdr.RoutingWaitingTime.HasValue);
            Assert.AreEqual<int>(cdr.RoutingWaitingTime.Value, 42);
            Assert.IsTrue(cdr.DialcodeMasterId.HasValue);
            Assert.AreEqual<int>(cdr.DialcodeMasterId.Value, 4);
            Assert.AreEqual<string>(cdr.TrackingId, "1418778188-2");
            Assert.AreEqual<string>(cdr.Format, "g729");
            Assert.AreEqual<string>(cdr.Formats, "g729,alaw,mulaw");
            Assert.AreEqual<string>(cdr.TechCalled, "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsNull(cdr.CustomerPriceId);
            Assert.IsNull(cdr.CustomerPricePerMin);
            Assert.IsNull(cdr.CustomerPriceTotal);
            Assert.IsNull(cdr.CustomerCurrency);
            Assert.IsTrue(cdr.GatewayId.HasValue);
            Assert.AreEqual<int>(cdr.GatewayId.Value, 51033);
            Assert.IsTrue(cdr.GatewayIpId.HasValue);
            Assert.AreEqual<int>(cdr.GatewayIpId.Value, 6103);
            Assert.IsTrue(cdr.GatewayAccountId.HasValue);
            Assert.AreEqual<int>(cdr.GatewayAccountId.Value, 780);
            Assert.IsTrue(cdr.GatewayPriceId.HasValue);
            Assert.AreEqual<long>(cdr.GatewayPriceId.Value, 44);
            Assert.IsTrue(cdr.GatewayPricePerMin.HasValue);
            Assert.AreEqual<decimal>(cdr.GatewayPricePerMin.Value, 0.0350M);
            Assert.IsTrue(cdr.GatewayPriceTotal.HasValue);
            Assert.AreEqual<decimal>(cdr.GatewayPriceTotal.Value, 0.0032666666666666666666666667M);
            Assert.AreEqual(cdr.GatewayCurrency, "USD");
            Assert.AreEqual<string>(cdr.RTPAddress, "11.10.20.104");
            Assert.IsTrue(cdr.RTPPort.HasValue);
            Assert.AreEqual<int>(cdr.RTPPort.Value, 6057);
            Assert.IsTrue(cdr.RTPForward.HasValue);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        [TestMethod]
        public void TestCdrOutgoingUpdate1()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479221",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=false",
                    "chan=sip/1557",
                    "operation=initialize",
                    "duration=20",
                    "ringtime=6",
                    "billtime=15",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=outgoing",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=outgoing",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=",
                    "clcustomeripid=",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clgatewayid=51033",
                    "clgatewayipid=6103",
                    "clgatewayaccountid=780",
                    "clgatewaypriceid=44",
                    "clgatewaypricepermin=0,035",
                    "clgatewaycurrency=USD",
                    "rtp_addr=11.10.20.104",
                    "rtp_forward=true",
                    "rtp_port=6057"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479221:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1557");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsFalse(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1557");
            Assert.IsTrue(cdr.Duration == 20000);
            Assert.IsTrue(cdr.Ringtime == 6000);
            Assert.IsTrue(cdr.BillTime == 15000);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "outgoing");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "outgoing");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsNull(cdr.CustomerId);
            Assert.IsNull(cdr.CustomerIpId);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsNull(cdr.CustomerPriceId);
            Assert.IsNull(cdr.CustomerPricePerMin);
            Assert.IsNull(cdr.CustomerPriceTotal);
            Assert.IsNull(cdr.CustomerCurrency);
            Assert.IsTrue(cdr.GatewayId == 51033);
            Assert.IsTrue(cdr.GatewayIpId == 6103);
            Assert.IsTrue(cdr.GatewayAccountId == 780);
            Assert.IsTrue(cdr.GatewayPriceId == 44);
            Assert.IsTrue(cdr.GatewayPricePerMin == 0.035M);
            Assert.IsTrue(cdr.GatewayPriceTotal.Value == 0.00875M);
            Assert.IsTrue(cdr.GatewayCurrency == "USD");
            Assert.IsTrue(cdr.RTPAddress == "11.10.20.104");
            Assert.IsTrue(cdr.RTPPort == 6057);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        [TestMethod]
        public void TestCdrOutgoingFinalize()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479222",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=true",
                    "chan=sip/1557",
                    "operation=initialize",
                    "duration=30",
                    "ringtime=6",
                    "billtime=21",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=outgoing",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=outgoing",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=",
                    "clcustomeripid=",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clgatewayid=51033",
                    "clgatewayipid=6103",
                    "clgatewayaccountid=780",
                    "clgatewaypriceid=44",
                    "clgatewaypricepermin=0,035",
                    "clgatewaycurrency=USD",
                    "rtp_addr=11.10.20.104",
                    "rtp_forward=true",
                    "rtp_port=6057"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479222:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1557");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsTrue(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1557");
            Assert.IsTrue(cdr.Duration == 30000);
            Assert.IsTrue(cdr.Ringtime == 6000);
            Assert.IsTrue(cdr.BillTime == 21000);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "outgoing");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "outgoing");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsNull(cdr.CustomerId);
            Assert.IsNull(cdr.CustomerIpId);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsNull(cdr.CustomerPriceId);
            Assert.IsNull(cdr.CustomerPricePerMin);
            Assert.IsNull(cdr.CustomerPriceTotal);
            Assert.IsNull(cdr.CustomerCurrency);
            Assert.IsTrue(cdr.GatewayId == 51033);
            Assert.IsTrue(cdr.GatewayIpId == 6103);
            Assert.IsTrue(cdr.GatewayAccountId == 780);
            Assert.IsTrue(cdr.GatewayPriceId == 44);
            Assert.IsTrue(cdr.GatewayPricePerMin == 0.035M);
            Assert.IsTrue(cdr.GatewayPriceTotal.Value == 0.01225M);
            Assert.IsTrue(cdr.GatewayCurrency == "USD");
            Assert.IsTrue(cdr.RTPAddress == "11.10.20.104");
            Assert.IsTrue(cdr.RTPPort == 6057);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        [TestMethod]
        public void TestCdrOutgoingUpdate2()
        {
            var currentTimestamp = UnixTimestamp.ToString();
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479223",
                    currentTimestamp,
                    "call.cdr",
                    "time=" + currentTimestamp,
                    "ended=false",
                    "chan=sip/1557",
                    "operation=initialize",
                    "duration=31",
                    "ringtime=7",
                    "billtime=5",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=outgoing",
                    "address=10.10.15.28%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=outgoing",
                    "caller=0001252133996",
                    "called=355871111122",
                    "callername=0001252133993",
                    "clcustomerid=",
                    "clcustomeripid=",
                    "clprocessingtime=40",
                    "clwaitingtime=42",
                    "cldialcodemasterid=4",
                    "cltrackingid=1418778188-2",
                    "format=g729",
                    "formats=g729,alaw,mulaw",
                    "cltechcalled=sip/sip%z1111101@11.10.10.103%z5057",
                    "clgatewayid=51033",
                    "clgatewayipid=6103",
                    "clgatewayaccountid=780",
                    "clgatewaypriceid=44",
                    "clgatewaypricepermin=0,035",
                    "clgatewaycurrency=USD",
                    "rtp_addr=11.10.20.104",
                    "rtp_forward=true",
                    "rtp_port=6057"
                    ));

            Dispatcher.Process(incomingMessage).Wait();
            var result = node.RetrieveMessage();

            // Assert that message was handled           
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479223:true:call.cdr::"));

            // Check database record
            var database = new DatabaseCheck();
            var cdr = database.GetRecord(node.Id, "1418778188-2", "sip/1557");

            Assert.IsNotNull(cdr);

            Assert.IsTrue(cdr.NodeId == 1);
            Assert.IsTrue(cdr.Ended);
            Assert.IsTrue(cdr.Chan == "sip/1557");
            Assert.IsTrue(cdr.Duration == 30000);
            Assert.IsTrue(cdr.Ringtime == 6000);
            Assert.IsTrue(cdr.BillTime == 21000);
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Error));
            Assert.IsTrue(string.IsNullOrEmpty(cdr.Reason));
            Assert.IsTrue(cdr.Status == "outgoing");
            Assert.IsTrue(cdr.Address == "10.10.15.28");
            Assert.IsTrue(cdr.BillId == "1418778188-2");
            Assert.IsTrue(cdr.Direction == "outgoing");
            Assert.IsTrue(cdr.Caller == "0001252133996");
            Assert.IsTrue(cdr.Called == "355871111122");
            Assert.IsTrue(cdr.Callername == "0001252133993");
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsNull(cdr.CustomerId);
            Assert.IsNull(cdr.CustomerIpId);
            Assert.IsTrue(cdr.RoutingProcessingTime == 40);
            Assert.IsTrue(cdr.RoutingWaitingTime == 42);
            Assert.IsTrue(cdr.DialcodeMasterId == 4);
            Assert.IsTrue(cdr.TrackingId == "1418778188-2");
            Assert.IsTrue(cdr.Format == "g729");
            Assert.IsTrue(cdr.Formats == "g729,alaw,mulaw");
            Assert.IsTrue(cdr.TechCalled == "sip/sip:1111101@11.10.10.103:5057");
            Assert.IsNull(cdr.CustomerPriceId);
            Assert.IsNull(cdr.CustomerPricePerMin);
            Assert.IsNull(cdr.CustomerPriceTotal);
            Assert.IsNull(cdr.CustomerCurrency);
            Assert.IsTrue(cdr.GatewayId == 51033);
            Assert.IsTrue(cdr.GatewayIpId == 6103);
            Assert.IsTrue(cdr.GatewayAccountId == 780);
            Assert.IsTrue(cdr.GatewayPriceId == 44);
            Assert.IsTrue(cdr.GatewayPricePerMin == 0.035M);
            Assert.IsTrue(cdr.GatewayPriceTotal.Value == 0.01225M);
            Assert.IsTrue(cdr.GatewayCurrency == "USD");
            Assert.IsTrue(cdr.RTPAddress == "11.10.20.104");
            Assert.IsTrue(cdr.RTPPort == 6057);
            Assert.IsTrue(cdr.RTPForward.Value);
        }

        #endregion

        #endregion
    }
}
