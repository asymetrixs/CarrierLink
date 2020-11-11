namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Mocking;
    using Workers;

    /// <summary>
    /// This class tests route functionality
    /// </summary>
    [TestClass]
    public class RouteTest : AbstractTest
    {
        #region Tests

        [TestMethod]
        public void TestRouteCausedError()
        {
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
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
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));

            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-1", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=484:"
            + "reason=:clnodeid=1:clcustomerid=12:clcustomeripid=13:cltrackingid=1418778188-1:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.PrerouteFailed);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNumberBlacklistedDirect()
        {
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=10.10.15.13%z5060",
                    "billid=1418778188-2",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=9698559",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-2", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=1:clcustomerid=10:clcustomeripid=11:cltrackingid=1418778188-2:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.Blacklisted);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNumberBlacklistedPattern()
        {
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=218.213.210.5%z5060",
                    "billid=1418778188-3",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=9123123123",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-3", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=1:clcustomerid=201:clcustomeripid=4201:cltrackingid=1418778188-3:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.Blacklisted);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestWithPrefix()
        {
            var node = new MockNode(70);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.70%z5060",
                    "billid=1418778188-4",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=00#111170",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-4", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=70:clcustomerid=70:clcustomeripid=470:cltrackingid=1418778188-4:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=370:clcustomerpricepermin=370:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111170@11.1.1.70%z5056:called=111170:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.70:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=570:clgatewayaccountid="
             + ":clgatewayipid=670:cltechcalled=sip/sip%z111170@11.1.1.70%z5056"
             + ":clgatewaypriceid=40:clgatewaypricepermin=0,037:clgatewaycurrency=USD:timeout=1083\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 270);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 170);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 570);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 570);
        }

        [TestMethod]
        public void TestGatewayPriceHigher()
        {
            var node = new MockNode(16001);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=16.0.0.5%z5060",
                    "billid=1418778188-5",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111170",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-5", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:"
            + "reason=:clnodeid=16001:clcustomerid=16004:clcustomeripid=16005:cltrackingid=1418778188-5:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=16010:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 16003);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 16008);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 16006);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.SameCompany);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestFakeRinging()
        {
            var node = new MockNode(71);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.71%z5060",
                    "billid=1418778188-6",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111171",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-6", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:location=fork:fork.calltype=persistent:fork.autoring=true:fork.automessage=call.progress:fork.ringer=true:clnodeid=71:"
            + "clcustomerid=71:clcustomeripid=471:cltrackingid=1418778188-6:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=371:clcustomerpricepermin=371:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=tone/ring"
             + ":callto.2=sip/sip%z111171@11.1.1.71%z5056:callto.2.called=111171:callto.2.caller=00012521339915:callto.2.callername=00012521339915:callto.2.format=g729"
             + ":callto.2.formats=g729,alaw,mulaw:callto.2.line=:callto.2.maxcall=65000:callto.2.osip_P-Asserted-Identity="
             + ":callto.2.osip_Gateway-ID=:callto.2.osip_Tracking-ID=:callto.2.rtp_addr=11.1.2.71:callto.2.rtp_forward=false"
             + ":callto.2.rtp_port=6056:callto.2.oconnection_id=general:callto.2.clgatewayid=571:callto.2.clgatewayaccountid="
             + ":callto.2.clgatewayipid=671:callto.2.cltechcalled=sip/sip%z111171@11.1.1.71%z5056"
             + ":callto.2.clgatewaypriceid=14:callto.2.clgatewaypricepermin=0,033:callto.2.clgatewaycurrency=USD:callto.2.cldecision=4:callto.2.timeout=1083\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 271);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 171);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 571);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 571);
        }

        [TestMethod]
        public void TestDID()
        {
            var node = new MockNode(72);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.72%z5060",
                    "billid=1418778188-7",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111172",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-7", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=72:clcustomerid=72:clcustomeripid=472:cltrackingid=1418778188-7:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=372:clcustomerpricepermin=372:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z99999999@11.1.1.72%z5056:called=99999999:caller=00012521339915:callername=00012521339915:format=g729:"
             + "formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.72:rtp_forward=false:"
             + "rtp_port=6056:oconnection_id=general:clgatewayid=572:clgatewayaccountid=:"
             + "clgatewayipid=672:cltechcalled=sip/sip%z99999999@11.1.1.72%z5056:"
             + "clgatewaypriceid=13:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1083\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 272);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 172);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 572);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 572);
        }

        [TestMethod]
        public void TestGatewayLimitExceeded()
        {
            var node = new MockNode(73);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.73%z5060",
                    "billid=1418778188-8",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111173",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-8", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:"
            + "reason=:clnodeid=73:clcustomerid=73:clcustomeripid=473:cltrackingid=1418778188-8:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=373:clcustomerpricepermin=373:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 273);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 173);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 573);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.LimitExceeded);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestCorrectCallerBracket()
        {
            var node = new MockNode(74);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.74%z5060",
                    "billid=1418778188-9",
                    "answered=false",
                    "direction=incoming",
                    "caller=[2k1n3n12o3",
                    "called=111174",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-9", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=74:clcustomerid=74:clcustomeripid=474:cltrackingid=1418778188-9:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=374:clcustomerpricepermin=374:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111174@11.1.1.74%z5056:called=111174:caller=anonymous:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.74:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=574:clgatewayaccountid="
             + ":clgatewayipid=674:cltechcalled=sip/sip%z111174@11.1.1.74%z5056"
             + ":clgatewaypriceid=7:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1083\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 274);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 174);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 574);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 574);
        }

        [TestMethod]
        public void TestCorrectCallernameBracket()
        {
            var node = new MockNode(75);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.75%z5060",
                    "billid=1418778188-10",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111175",
                    "callername=[2k1n3n12o3",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-10", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=75:clcustomerid=75:clcustomeripid=475:cltrackingid=1418778188-10:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=375:clcustomerpricepermin=375:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111175@11.1.1.75%z5056:called=111175:caller=00012521339915:callername=anonymous:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.75:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=575:clgatewayaccountid="
             + ":clgatewayipid=675:cltechcalled=sip/sip%z111175@11.1.1.75%z5056"
             + ":clgatewaypriceid=9:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 275);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 175);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 575);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 575);
        }

        [TestMethod]
        public void TestCorrectCallerWhitespace()
        {
            var node = new MockNode(76);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.76%z5060",
                    "billid=1418778188-11",
                    "answered=false",
                    "direction=incoming",
                    "caller= ",
                    "called=111176",
                    "callername=00012521339915",
                    "sip_Tracking-ID=1418778188-300",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-11", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=76:clcustomerid=76:clcustomeripid=476:cltrackingid=1418778188-300:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=376:clcustomerpricepermin=376:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111176@11.1.1.76%z5056:called=111176:caller=anonymous:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.76:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=576:clgatewayaccountid="
             + ":clgatewayipid=676:cltechcalled=sip/sip%z111176@11.1.1.76%z5056"
             + ":clgatewaypriceid=12:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1083\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 276);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 176);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 576);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 576);
        }

        [TestMethod]
        public void TestCorrectCallernameWhitespace()
        {
            var node = new MockNode(77);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.77%z5060",
                    "billid=1418778188-12",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111177",
                    "callername=  ",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-12", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=77:clcustomerid=77:clcustomeripid=477:cltrackingid=1418778188-12:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=377:clcustomerpricepermin=377:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111177@11.1.1.77%z5056:called=111177:caller=00012521339915:callername=anonymous:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.77:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=577:clgatewayaccountid="
             + ":clgatewayipid=677:cltechcalled=sip/sip%z111177@11.1.1.77%z5056"
             + ":clgatewaypriceid=11:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 277);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 177);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 577);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 577);
        }

        [TestMethod]
        public void TestCorrectCallerIncorrect()
        {
            var node = new MockNode(78);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.78%z5060",
                    "billid=1418778188-13",
                    "answered=false",
                    "direction=incoming",
                    "caller=abc",
                    "called=111178",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-13", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=78:clcustomerid=78:clcustomeripid=478:cltrackingid=1418778188-13:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=378:clcustomerpricepermin=378:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111178@11.1.1.78%z5056:called=111178:caller=anonymous:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.78:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=578:clgatewayaccountid="
             + ":clgatewayipid=678:cltechcalled=sip/sip%z111178@11.1.1.78%z5056"
             + ":clgatewaypriceid=8:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1083\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 278);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 178);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 578);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 578);
        }

        [TestMethod]
        public void TestCorrectCallernameIncorrect()
        {
            var node = new MockNode(79);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.79%z5060",
                    "billid=1418778188-14",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111179",
                    "callername=009911111",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-14", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=79:clcustomerid=79:clcustomeripid=479:cltrackingid=1418778188-14:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=379:clcustomerpricepermin=379:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111179@11.1.1.79%z5056:called=111179:caller=00012521339915:callername=009911112:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.79:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=579:clgatewayaccountid="
             + ":clgatewayipid=679:cltechcalled=sip/sip%z111179@11.1.1.79%z5056"
             + ":clgatewaypriceid=10:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 279);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 179);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 579);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 579);
        }

        [TestMethod]
        public void TestGatewayAccount()
        {
            var node = new MockNode(80);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.80%z5060",
                    "billid=1418778188-15",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111180",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-15", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:reason=:"
            + "clnodeid=80:clcustomerid=80:clcustomeripid=480:cltrackingid=1418778188-15:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=380:clcustomerpricepermin=380:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111180:called=111180:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=acc80:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=580:clgatewayaccountid=780"
             + ":clgatewayipid=:cltechcalled=sip/sip%z111180"
             + ":clgatewaypriceid=6:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 280);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 180);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 580);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 580);
        }

        [TestMethod]
        public void TestGatewayAccountNewCaller()
        {
            var node = new MockNode(81);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.81%z5060",
                    "billid=1418778188-16",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111181",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-16", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=81:clcustomerid=81:clcustomeripid=481:cltrackingid=1418778188-16:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=381:clcustomerpricepermin=381:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111181:called=111181:caller=002299:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=acc81:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=581:clgatewayaccountid=781"
             + ":clgatewayipid=:cltechcalled=sip/sip%z111181"
             + ":clgatewaypriceid=19:clgatewaypricepermin=0,034:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 281);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 181);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 581);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 581);
        }

        [TestMethod]
        public void TestGatewayAccountNewCallername()
        {
            var node = new MockNode(82);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.82%z5060",
                    "billid=1418778188-17",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111182",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-17", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=82:clcustomerid=82:clcustomeripid=482:cltrackingid=1418778188-17:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=382:clcustomerpricepermin=382:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111182:called=111182:caller=00012521339915:callername=002299:format=g729"
             + ":formats=g729,alaw,mulaw:line=acc82:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=582:clgatewayaccountid=782"
             + ":clgatewayipid=:cltechcalled=sip/sip%z111182"
             + ":clgatewaypriceid=20:clgatewaypricepermin=0,034:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 282);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 182);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 582);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 582);
        }

        [TestMethod]
        public void TestNumberModificationGroupBoth()
        {
            var node = new MockNode(83);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.83%z5060",
                    "billid=1418778188-18",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77811111",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-18", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=83:clcustomerid=83:clcustomeripid=483:cltrackingid=1418778188-18:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=383:clcustomerpricepermin=383:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z00811111@11.1.1.83%z5056:called=00811111:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.83:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=583:clgatewayaccountid="
             + ":clgatewayipid=683:cltechcalled=sip/sip%z00811111@11.1.1.83%z5056"
             + ":clgatewaypriceid=34:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 283);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 183);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 583);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 583);
        }

        [TestMethod]
        public void TestNumberModificationGroupRemovePrefix()
        {
            var node = new MockNode(84);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.84%z5060",
                    "billid=1418778188-19",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77811112",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-19", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=84:clcustomerid=84:clcustomeripid=484:cltrackingid=1418778188-19:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=384:clcustomerpricepermin=384:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z811112@11.1.1.84%z5056:called=811112:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.84:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=584:clgatewayaccountid="
             + ":clgatewayipid=684:cltechcalled=sip/sip%z811112@11.1.1.84%z5056"
             + ":clgatewaypriceid=39:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 284);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 184);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 584);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 584);
        }

        [TestMethod]
        public void TestNumberModificationGroupAddPrefix()
        {
            var node = new MockNode(85);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.85%z5060",
                    "billid=1418778188-20",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77811113",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-20", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=85:clcustomerid=85:clcustomeripid=485:cltrackingid=1418778188-20:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=385:clcustomerpricepermin=385:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z0077811113@11.1.1.85%z5056:called=0077811113:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.85:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=585:clgatewayaccountid="
             + ":clgatewayipid=685:cltechcalled=sip/sip%z0077811113@11.1.1.85%z5056"
             + ":clgatewaypriceid=33:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 285);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 185);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 585);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 585);
        }

        [TestMethod]
        public void TestNumberModificationGroupBoth2()
        {
            var node = new MockNode(86);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.86%z5060",
                    "billid=1418778188-21",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77811114",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-21", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=86:clcustomerid=86:clcustomeripid=486:cltrackingid=1418778188-21:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=386:clcustomerpricepermin=386:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z005511114@11.1.1.86%z5056:called=005511114:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.86:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=586:clgatewayaccountid="
             + ":clgatewayipid=686:cltechcalled=sip/sip%z005511114@11.1.1.86%z5056"
             + ":clgatewaypriceid=35:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 286);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 186);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 586);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 586);
        }

        [TestMethod]
        public void TestNumberModificationGroupNotMatching()
        {
            var node = new MockNode(87);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.87%z5060",
                    "billid=1418778188-22",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77811115",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-22", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=87:clcustomerid=87:clcustomeripid=487:cltrackingid=1418778188-22:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=387:clcustomerpricepermin=387:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z77811115@11.1.1.87%z5056:called=77811115:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.87:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=587:clgatewayaccountid="
             + ":clgatewayipid=687:cltechcalled=sip/sip%z77811115@11.1.1.87%z5056"
             + ":clgatewaypriceid=38:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 287);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 187);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 587);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 587);
        }

        [TestMethod]
        public void TestNumberModificationGroupMultiplePolicies()
        {
            var node = new MockNode(88);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.88%z5060",
                    "billid=1418778188-23",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77801116",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-23", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=88:clcustomerid=88:clcustomeripid=488:cltrackingid=1418778188-23:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=388:clcustomerpricepermin=388:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z0083801116@11.1.1.88%z5056:called=0083801116:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.88:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=588:clgatewayaccountid="
             + ":clgatewayipid=688:cltechcalled=sip/sip%z0083801116@11.1.1.88%z5056"
             + ":clgatewaypriceid=36:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 288);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 188);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 588);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 588);
        }

        [TestMethod]
        public void TestNumberModificationGroupMultiplePoliciesNotMatching()
        {
            var node = new MockNode(89);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.89%z5060",
                    "billid=1418778188-24",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=77801117",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-24", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=89:clcustomerid=89:clcustomeripid=489:cltrackingid=1418778188-24:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=389:clcustomerpricepermin=389:clcustomercurrency=USD:cldialcodemasterid=7:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z77801117@11.1.1.89%z5056:called=77801117:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.89:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=589:clgatewayaccountid="
             + ":clgatewayipid=689:cltechcalled=sip/sip%z77801117@11.1.1.89%z5056"
             + ":clgatewaypriceid=37:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 289);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 189);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 589);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 589);
        }

        [TestMethod]
        public void TestGatewayIPThreeIPsOnlyConnectToOneDestination()
        {
            var node = new MockNode(90);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.90%z5060",
                    "billid=1418778188-25",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111190",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-25", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=90:clcustomerid=90:clcustomeripid=490:cltrackingid=1418778188-25:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=390:clcustomerpricepermin=390:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111190@11.1.1.90%z5056:called=111190:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.90:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=590:clgatewayaccountid="
             + ":clgatewayipid=690:cltechcalled=sip/sip%z111190@11.1.1.90%z5056"
             + ":clgatewaypriceid=25:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 290);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 590);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 590);
        }

        [TestMethod]
        public void TestGatewayAccountTwoAccOnlyConnectToOneDestination()
        {
            var node = new MockNode(91);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.91%z5060",
                    "billid=1418778188-26",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111191",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-26", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=91:clcustomerid=91:clcustomeripid=491:cltrackingid=1418778188-26:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=391:clcustomerpricepermin=391:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111191:called=111191:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=acc911:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=591:clgatewayaccountid=7911"
             + ":clgatewayipid=:cltechcalled=sip/sip%z111191"
             + ":clgatewaypriceid=22:clgatewaypricepermin=0,034:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 291);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 191);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 591);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 591);
        }

        [TestMethod]
        public void TestGatewayIPThreeIPsConnectLowestBilltime()
        {
            var node = new MockNode(92);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.92%z5060",
                    "billid=1418778188-27",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111192",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-27", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=92:clcustomerid=92:clcustomeripid=492:cltrackingid=1418778188-27:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=392:clcustomerpricepermin=392:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111192@11.1.1.92%z5056:called=111192:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID="
             + ":rtp_addr=11.1.2.92:rtp_forward=false:rtp_port=6056:oconnection_id=general:clgatewayid=592:clgatewayaccountid="
             + ":clgatewayipid=692:cltechcalled=sip/sip%z111192@11.1.1.92%z5056:clgatewaypriceid=26:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 292);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 192);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 592);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 592);
        }

        [TestMethod]
        public void TestGatewayAccountThreeAccOnlyConnectLowestBilltime()
        {
            var node = new MockNode(93);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.93%z5060",
                    "billid=1418778188-28",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111193",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-28", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=93:clcustomerid=93:clcustomeripid=493:cltrackingid=1418778188-28:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=393:clcustomerpricepermin=393:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111193:called=111193:caller=00012521339915:callername=00012521339915:format=g729:formats=g729,alaw,mulaw"
             + ":line=acc931:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=593:clgatewayaccountid=7931:clgatewayipid=:cltechcalled=sip/sip%z111193"
             + ":clgatewaypriceid=21:clgatewaypricepermin=0,034:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 293);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 193);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 593);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 593);
        }

        [TestMethod]
        public void TestGatewayAccountIPMixedDrop()
        {
            var node = new MockNode(94);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.94%z5060",
                    "billid=1418778188-29",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111194",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-29", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=94:"
            + "clcustomerid=94:clcustomeripid=494:cltrackingid=1418778188-29:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=394:clcustomerpricepermin=394:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z111194:callto.1.called=111194:callto.1.caller=00012521339915:callto.1.callername=00012521339915:callto.1.format=g729"
             + ":callto.1.formats=g729,alaw,mulaw:callto.1.line=acc94:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity="
             + ":callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:callto.1.rtp_addr=:callto.1.rtp_forward=false"
             + ":callto.1.rtp_port=:callto.1.oconnection_id=general:callto.1.clgatewayid=5941:callto.1.clgatewayaccountid=794"
             + ":callto.1.clgatewayipid=:callto.1.cltechcalled=sip/sip%z111194"
             + ":callto.1.clgatewaypriceid=15:callto.1.clgatewaypricepermin=0,034:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1085"
             + ":callto.2=|drop=10000"
             + ":callto.3=sip/sip%z111194@11.1.1.94%z5056:callto.3.called=111194:callto.3.caller=00012521339915:callto.3.callername=00012521339915:callto.3.format=g729"
             + ":callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity="
             + ":callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:callto.3.rtp_addr=11.1.2.94:callto.3.rtp_forward=false"
             + ":callto.3.rtp_port=6056:callto.3.oconnection_id=general:callto.3.clgatewayid=5942:callto.3.clgatewayaccountid="
             + ":callto.3.clgatewayipid=694:callto.3.cltechcalled=sip/sip%z111194@11.1.1.94%z5056"
             + ":callto.3.clgatewaypriceid=16:callto.3.clgatewaypricepermin=0,035:callto.3.clgatewaycurrency=USD:callto.3.cldecision=4:callto.3.timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 294);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 194);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 2);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 5941);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].Id, 5942);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 2);
            Assert.AreEqual(routingTree.GatewayOrder[0], 5941);
            Assert.AreEqual(routingTree.GatewayOrder[1], 5942);
        }

        [TestMethod]
        public void TestGatewayAccountSufficientNodes()
        {
            var node = new MockNode(95);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.95%z5060",
                    "billid=1418778188-30",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111195",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-30", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=95:clcustomerid=95:clcustomeripid=495:cltrackingid=1418778188-30:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=395:clcustomerpricepermin=395:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111195:called=111195:caller=00012521339915:callername=00012521339915:format=g729:formats=g729,alaw,mulaw"
             + ":line=acc953:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=595:clgatewayaccountid=7953:clgatewayipid=:cltechcalled=sip/sip%z111195"
             + ":clgatewaypriceid=18:clgatewaypricepermin=0,034:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 295);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 195);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 595);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 595);
        }

        [TestMethod]
        public void TestGatewayAccountInsufficientNodes()
        {
            var node = new MockNode(96);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.96%z5060",
                    "billid=1418778188-31",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111196",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-31", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=96:clcustomerid=96:clcustomeripid=496:cltrackingid=1418778188-31:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=396:clcustomerpricepermin=396:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111196:called=111196:caller=00012521339915:callername=00012521339915:format=g729:formats=g729,alaw,mulaw"
             + ":line=acc962:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=general:clgatewayid=596:clgatewayaccountid=7962:clgatewayipid=:cltechcalled=sip/sip%z111196"
             + ":clgatewaypriceid=17:clgatewaypricepermin=0,034:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 296);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 196);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 596);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 596);
        }

        [TestMethod]
        public void TestGatewayIPSufficientNodes()
        {
            var node = new MockNode(97);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.97%z5060",
                    "billid=1418778188-32",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111197",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-32", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=97:clcustomerid=97:clcustomeripid=497:cltrackingid=1418778188-32:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=397:clcustomerpricepermin=397:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111197@11.1.7.97%z5056:called=111197:caller=00012521339915:callername=00012521339915:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.6.97:rtp_forward=false:rtp_port=6056"
             + ":oconnection_id=general:clgatewayid=597:clgatewayaccountid=:clgatewayipid=6972:cltechcalled=sip/sip%z111197@11.1.7.97%z5056"
             + ":clgatewaypriceid=24:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 297);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 197);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 597);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 597);
        }

        [TestMethod]
        public void TestGatewayIPInsufficientNodes()
        {
            var node = new MockNode(98);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.98%z5060",
                    "billid=1418778188-33",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111198",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-33", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=98:clcustomerid=98:clcustomeripid=498:cltrackingid=1418778188-33:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=398:clcustomerpricepermin=398:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111198@11.1.8.92%z5056:called=111198:caller=00012521339915:callername=00012521339915:format=g729:formats=g729,alaw,mulaw"
             + ":line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.5.92:rtp_forward=false:rtp_port=6056"
             + ":oconnection_id=general:clgatewayid=598:clgatewayaccountid=:clgatewayipid=6982:cltechcalled=sip/sip%z111198@11.1.8.92%z5056"
             + ":clgatewaypriceid=23:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 298);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 198);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 598);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 598);
        }

        [TestMethod]
        public void TestRTPEnabled()
        {
            var node = new MockNode(99);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.99%z5060",
                    "billid=1418778188-34",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111199",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-34", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=99:clcustomerid=99:clcustomeripid=499:cltrackingid=1418778188-34:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=399:clcustomerpricepermin=399:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111199@11.1.1.99%z5057:called=111199:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.99:rtp_forward=true"
             + ":rtp_port=6057:oconnection_id=general:clgatewayid=599:clgatewayaccountid="
             + ":clgatewayipid=699:cltechcalled=sip/sip%z111199@11.1.1.99%z5057"
             + ":clgatewaypriceid=32:clgatewaypricepermin=0,036:clgatewaycurrency=EUR:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 299);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 199);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 599);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 599);
        }

        [TestMethod]
        public void TestRouteToNode()
        {
            var node = new MockNode(100);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.100%z5060",
                    "billid=1418778188-35",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=1111100",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-35", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=100:clcustomerid=100:clcustomeripid=4100:cltrackingid=1418778188-35:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=3100:clcustomerpricepermin=310:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z1111100@10.0.1.100%z5221:called=:caller=:callername=:format=g729"
             + ":formats=g729:line=:maxcall=:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=5100:osip_Tracking-ID=1418778188-35:rtp_addr=:rtp_forward=false"
             + ":rtp_port=:oconnection_id=intern:clgatewayid=:clgatewayaccountid="
             + ":clgatewayipid=:cltechcalled=sip/sip%z1111100@10.0.1.100%z5221"
             + ":clgatewaypriceid=:clgatewaypricepermin=:clgatewaycurrency=:timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 2100);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 1100);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 5100);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNotNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via.Id, 1000);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 5100);
        }

        [TestMethod]
        public void TestRouteFromNode()
        {
            var node = new MockNode(1001);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.2.100%z5060",
                    "billid=1418778188-36",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=1111100",
                    "callername=00012521339915",
                    "sip_Tracking-ID=234479208-1",
                    "sip_Gateway-ID=5101"
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-36", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=1001:clcustomerid=:clcustomeripid=:cltrackingid=234479208-1:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z1111100@11.1.1.101%z5057:called=1111100:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.101:rtp_forward=true"
             + ":rtp_port=6057:oconnection_id=general:clgatewayid=5101:clgatewayaccountid="
             + ":clgatewayipid=6101:cltechcalled=sip/sip%z1111100@11.1.1.101%z5057"
             + ":clgatewaypriceid=:clgatewaypricepermin=:clgatewaycurrency=:timeout=7200000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNotNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.InternalRoutedGateway.Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.InternalRoutedGateway.Id, 5101);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway.Via);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Internal);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 5101);
        }

        [TestMethod]
        public void TestHasPriceHasRouteHasLCRHasAD()
        {
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.50%z5060",
                    "billid=1418778188-37",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111150",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-37", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=1:clcustomerid=50:clcustomeripid=450:cltrackingid=1418778188-37:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=350:clcustomerpricepermin=350:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111150@11.1.1.50%z5055:called=111150:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.50:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=550:clgatewayaccountid="
             + ":clgatewayipid=650:cltechcalled=sip/sip%z111150@11.1.1.50%z5055"
             + ":clgatewaypriceid=27:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1001\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 250);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 150);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 550);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 550);
        }

        [TestMethod]
        public void TestHasPriceHasRouteHasLCRNoAD()
        {
            var node = new MockNode(2);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.51%z5060",
                    "billid=1418778188-38",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111151",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-38", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=2:clcustomerid=51:clcustomeripid=451:cltrackingid=1418778188-38:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=351:clcustomerpricepermin=351:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111151@11.1.1.51%z5055:called=111151:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.51:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=551:clgatewayaccountid="
             + ":clgatewayipid=651:cltechcalled=sip/sip%z111151@11.1.1.51%z5055"
             + ":clgatewaypriceid=3:clgatewaypricepermin=0,003:clgatewaycurrency=USD:timeout=1003\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 251);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 151);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 551);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 551);
        }

        [TestMethod]
        public void TestHasPriceHasRouteNoLCRHasAD()
        {
            var node = new MockNode(3);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.52%z5060",
                    "billid=1418778188-39",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111152",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-39", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=3:clcustomerid=52:clcustomeripid=452:cltrackingid=1418778188-39:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=352:clcustomerpricepermin=352:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111152@11.1.1.52%z5055:called=111152:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.52:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=552:clgatewayaccountid="
             + ":clgatewayipid=652:cltechcalled=sip/sip%z111152@11.1.1.52%z5055"
             + ":clgatewaypriceid=28:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 252);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 152);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 552);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 552);
        }

        [TestMethod]
        public void TestHasPriceHasRouteNoLCRNoAD()
        {
            var node = new MockNode(4);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.53%z5060",
                    "billid=1418778188-40",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111153",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-40", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=4:clcustomerid=53:clcustomeripid=453:cltrackingid=1418778188-40:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=353:clcustomerpricepermin=353:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111153@11.1.1.53%z5055:called=111153:caller=00012521339915:callername=00012521339915"
             + ":format=g729:formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity=:osip_Gateway-ID="
             + ":osip_Tracking-ID=:rtp_addr=11.1.2.53:rtp_forward=false:rtp_port=6055:oconnection_id=general:clgatewayid=553:clgatewayaccountid="
             + ":clgatewayipid=653:cltechcalled=sip/sip%z111153@11.1.1.53%z5055:clgatewaypriceid=3000"
             + ":clgatewaypricepermin=0,003:clgatewaycurrency=USD:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 253);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 153);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 553);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 553);
        }

        [TestMethod]
        public void TestHasPriceNoRouteHasLCRHasAD()
        {
            var node = new MockNode(5);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.54%z5060",
                    "billid=1418778188-41",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111154",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-41", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=5:clcustomerid=54:clcustomeripid=454:cltrackingid=1418778188-41:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=354:clcustomerpricepermin=354:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111154@11.1.1.55%z5055:called=111154:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.55:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=555:clgatewayaccountid="
             + ":clgatewayipid=655:cltechcalled=sip/sip%z111154@11.1.1.55%z5055"
             + ":clgatewaypriceid=5:clgatewaypricepermin=0,033:clgatewaycurrency=EUR:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 254);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 555);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 555);
        }

        [TestMethod]
        public void TestHasPriceNoRouteHasLCRNoAD()
        {
            var node = new MockNode(6);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.55%z5060",
                    "billid=1418778188-42",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111155",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-42", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=6:clcustomerid=55:clcustomeripid=455:cltrackingid=1418778188-42:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=355:clcustomerpricepermin=355:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111155@11.1.1.56%z5055:called=111155:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.56:rtp_forward=false"
             + ":rtp_port=6055:oconnection_id=general:clgatewayid=556:clgatewayaccountid="
             + ":clgatewayipid=656:cltechcalled=sip/sip%z111155@11.1.1.56%z5055"
             + ":clgatewaypriceid=4:clgatewaypricepermin=0,06051:clgatewaycurrency=EUR:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 255);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 556);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 556);
        }

        [TestMethod]
        public void TestHasPriceNoRouteNoLCRHasAD()
        {
            var node = new MockNode(7);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.56%z5060",
                    "billid=1418778188-43",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111156",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-43", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=7:clcustomerid=56:clcustomeripid=456:cltrackingid=1418778188-43:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=356:clcustomerpricepermin=356:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 256);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestHasPriceNoRouteNoLCRNoAD()
        {
            var node = new MockNode(8);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.57%z5060",
                    "billid=1418778188-44",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111157",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-44", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=8:clcustomerid=57:clcustomeripid=457:cltrackingid=1418778188-44:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=357:clcustomerpricepermin=357:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 257);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNoPriceHasRouteHasLCRHasAD()
        {
            var node = new MockNode(9);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.58%z5060",
                    "billid=1418778188-45",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111158",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-45", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=9:clcustomerid=58:clcustomeripid=458:cltrackingid=1418778188-45:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111158@11.1.1.57%z5055:called=111158:caller=00012521339915:callername=00012521339915:"
             + "format=g729:formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity=:"
             + "osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.57:rtp_forward=false:rtp_port=6055:"
             + "oconnection_id=general:clgatewayid=557:clgatewayaccountid=:clgatewayipid=657:"
             + "cltechcalled=sip/sip%z111158@11.1.1.57%z5055:"
             + "clgatewaypriceid=29:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 258);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 154);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 557);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 557);
        }

        [TestMethod]
        public void TestNoPriceHasRouteHasLCRNoAD()
        {
            var node = new MockNode(10);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.59%z5060",
                    "billid=1418778188-46",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111159",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-46", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=10:clcustomerid=59:clcustomeripid=459:cltrackingid=1418778188-46:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 259);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNoPriceHasRouteNoLCRHasAD()
        {
            var node = new MockNode(11);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.60%z5060",
                    "billid=1418778188-47",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111160",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-47", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=11:clcustomerid=60:clcustomeripid=460:cltrackingid=1418778188-47:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111160@11.1.1.60%z5056:called=111160:caller=00012521339915:callername=00012521339915:"
             + "format=g729:formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity=:"
             + "osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.60:rtp_forward=false:rtp_port=6056:"
             + "oconnection_id=general:clgatewayid=559:clgatewayaccountid=:clgatewayipid=658:"
             + "cltechcalled=sip/sip%z111160@11.1.1.60%z5056:"
             + "clgatewaypriceid=30:clgatewaypricepermin=0,035:clgatewaycurrency=EUR:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 260);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 156);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 559);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 559);
        }

        [TestMethod]
        public void TestNoPriceHasRouteNoLCRNoAD()
        {
            var node = new MockNode(12);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=8.8.2.61%z5060",
                    "billid=1418778188-48",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111161",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-48", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=12:clcustomerid=100000:clcustomeripid=100461:cltrackingid=1418778188-48:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 262);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNoPriceNoRouteHasLCRHasAD()
        {
            var node = new MockNode(13);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.62%z5060",
                    "billid=1418778188-49",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111162",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-49", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=13:clcustomerid=62:clcustomeripid=462:cltrackingid=1418778188-49:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z111162@11.1.1.62%z5056:called=111162:caller=00012521339915:callername=00012521339915:"
             + "format=g729:formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity=:"
             + "osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=11.1.2.62:rtp_forward=false:rtp_port=6056:"
             + "oconnection_id=general:clgatewayid=561:clgatewayaccountid=:clgatewayipid=660:"
             + "cltechcalled=sip/sip%z111162@11.1.1.62%z5056:"
             + "clgatewaypriceid=1:clgatewaypricepermin=1,02:clgatewaycurrency=EUR:timeout=1002\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 222);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 561);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 561);
        }

        [TestMethod]
        public void TestNoPriceNoRouteHasLCRNoAD()
        {
            var node = new MockNode(14);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.63%z5060",
                    "billid=1418778188-50",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111163",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-50", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=14:clcustomerid=63:clcustomeripid=463:cltrackingid=1418778188-50:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 263);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNoPriceNoRouteNoLCRHasAD()
        {
            var node = new MockNode(15);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.64%z5060",
                    "billid=1418778188-51",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111164",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-51", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=15:clcustomerid=64:clcustomeripid=464:cltrackingid=1418778188-51:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 264);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestNoPriceNoRouteNoLCRNoAD()
        {
            var node = new MockNode(16);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=1.1.1.65%z5060",
                    "billid=1418778188-52",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=111165",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-52", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:"
            + "reason=:clnodeid=16:clcustomerid=65:clcustomeripid=465:cltrackingid=1418778188-52:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 265);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestGatewayLCRWith3Routes()
        {
            var node = new MockNode(1002);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=10.10.10.10%z5060",
                    "billid=1418778188-53",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=1111101",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-53", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=1002:"
            + "clcustomerid=102:clcustomeripid=4102:cltrackingid=1418778188-53:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=3102:clcustomerpricepermin=312:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z1111101@11.10.10.103%z5057:callto.1.called=1111101:callto.1.caller=00012521339915:callto.1.callername=00012521339915:callto.1.format=g729:"
             + "callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:"
             + "callto.1.rtp_addr=11.10.20.103:callto.1.rtp_forward=true:callto.1.rtp_port=6057:callto.1.oconnection_id=general:callto.1.clgatewayid=51032:callto.1.clgatewayaccountid=:"
             + "callto.1.clgatewayipid=6104:callto.1.cltechcalled=sip/sip%z1111101@11.10.10.103%z5057:"
             + "callto.1.clgatewaypriceid=43:callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=8:callto.1.timeout=1085:"
             + "callto.2=|next=10000:"
             + "callto.3=sip/sip%z1111101@11.10.10.104%z5057:callto.3.called=1111101:callto.3.caller=00012521339915:callto.3.callername=00012521339915:callto.3.format=g729:"
             + "callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:"
             + "callto.3.rtp_addr=11.10.20.104:callto.3.rtp_forward=true:callto.3.rtp_port=6057:callto.3.oconnection_id=general:callto.3.clgatewayid=51033:callto.3.clgatewayaccountid=:"
             + "callto.3.clgatewayipid=6105:callto.3.cltechcalled=sip/sip%z1111101@11.10.10.104%z5057:"
             + "callto.3.clgatewaypriceid=44:callto.3.clgatewaypricepermin=0,035:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1085:"
             + "callto.4=|next=10000:"
             + "callto.5=sip/sip%z1111101@11.10.10.102%z5057:callto.5.called=1111101:callto.5.caller=00012521339915:callto.5.callername=00012521339915:callto.5.format=g729:"
             + "callto.5.formats=g729,alaw,mulaw:callto.5.line=:callto.5.maxcall=65000:callto.5.osip_P-Asserted-Identity=:callto.5.osip_Gateway-ID=:callto.5.osip_Tracking-ID=:"
             + "callto.5.rtp_addr=11.10.20.102:callto.5.rtp_forward=true:callto.5.rtp_port=6057:callto.5.oconnection_id=general:callto.5.clgatewayid=51031:callto.5.clgatewayaccountid=:"
             + "callto.5.clgatewayipid=6103:callto.5.cltechcalled=sip/sip%z1111101@11.10.10.102%z5057:"
             + "callto.5.clgatewaypriceid=42:callto.5.clgatewaypricepermin=0,006:callto.5.clgatewaycurrency=USD:callto.5.cldecision=8:callto.5.timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 2102);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 3);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 51032);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.LCRGateways[1].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[1].Id, 51033);
            Assert.AreEqual(routingTree.Context.LCRGateways[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[1] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.LCRGateways[2].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[2].Id, 51031);
            Assert.AreEqual(routingTree.Context.LCRGateways[2].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[2] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 3);
            Assert.AreEqual(routingTree.GatewayOrder[0], 51032);
            Assert.AreEqual(routingTree.GatewayOrder[1], 51033);
            Assert.AreEqual(routingTree.GatewayOrder[2], 51031);
        }

        [TestMethod]
        public void TestSameQoSDifferentCompanyLCR()
        {
            var node = new MockNode(40001);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.1%z5060",
                    "billid=1418778188-54",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001111",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-54", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=40001:clcustomerid=43001:clcustomeripid=44001:cltrackingid=1418778188-54:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46001:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z80001111@4.7.1.1%z5056:called=80001111:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=4.7.1.101:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=47001:clgatewayaccountid="
             + ":clgatewayipid=47101:cltechcalled=sip/sip%z80001111@4.7.1.1%z5056"
             + ":clgatewaypriceid=49001:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42001);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 47001);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 47001);
        }

        [TestMethod]
        public void TestDifferentQoSSameCompanyLCR()
        {
            var node = new MockNode(40002);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.2%z5060",
                    "billid=1418778188-55",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001112",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-55", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:"
            + "reason=:clnodeid=40002:clcustomerid=43002:clcustomeripid=44002:cltrackingid=1418778188-55:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46002:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42002);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 47002);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.SameCompany);
            Assert.IsNull(routingTree.Context.LCRGateways[0].Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestSameQoSSameCompanyLCR()
        {
            var node = new MockNode(40003);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.3%z5060",
                    "billid=1418778188-56",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001113",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-56", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:"
            + "reason=:clnodeid=40003:clcustomerid=43003:clcustomeripid=44003:cltrackingid=1418778188-56:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46003:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42003);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 47003);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.SameCompany);
            Assert.IsNull(routingTree.Context.LCRGateways[0].Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestDifferentQoSDifferentCompanyLCR()
        {
            var node = new MockNode(40004);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.4%z5060",
                    "billid=1418778188-57",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001114",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-57", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=40004:clcustomerid=43004:clcustomeripid=44004:cltrackingid=1418778188-57:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46004:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z80001114@4.7.1.4%z5056:called=80001114:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=4.7.1.104:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=47004:clgatewayaccountid="
             + ":clgatewayipid=47104:cltechcalled=sip/sip%z80001114@4.7.1.4%z5056"
             + ":clgatewaypriceid=49004:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42004);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 47004);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 47004);
        }

        [TestMethod]
        public void TestSameQoSDifferentCompanyStandard()
        {
            var node = new MockNode(40005);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.5%z5060",
                    "billid=1418778188-58",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001115",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-58", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=40005:clcustomerid=43005:clcustomeripid=44005:cltrackingid=1418778188-58:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46005:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z80001115@4.7.1.5%z5056:called=80001115:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=4.7.1.105:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=47005:clgatewayaccountid="
             + ":clgatewayipid=47105:cltechcalled=sip/sip%z80001115@4.7.1.5%z5056"
             + ":clgatewaypriceid=49005:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42005);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49505);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 47005);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 47005);
        }

        [TestMethod]
        public void TestDifferentQoSSameCompanyStandard()
        {
            var node = new MockNode(40006);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.6%z5060",
                    "billid=1418778188-59",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001116",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-59", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:"
            + "reason=:clnodeid=40006:clcustomerid=43006:clcustomeripid=44006:cltrackingid=1418778188-59:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46006:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42006);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49506);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 47006);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.SameCompany);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestSameQoSSameCompanyStandard()
        {
            var node = new MockNode(40007);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.7%z5060",
                    "billid=1418778188-60",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001117",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-60", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:"
            + "reason=:clnodeid=40007:clcustomerid=43007:clcustomeripid=44007:cltrackingid=1418778188-60:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46007:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42007);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49507);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 47007);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.SameCompany);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 0);
        }

        [TestMethod]
        public void TestDifferentQoSDifferentCompanyStandard()
        {
            var node = new MockNode(40008);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=4.4.0.8%z5060",
                    "billid=1418778188-61",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001118",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-61", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=40008:clcustomerid=43008:clcustomeripid=44008:cltrackingid=1418778188-61:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=46008:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z80001118@4.7.1.8%z5056:called=80001118:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=4.7.1.108:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=47008:clgatewayaccountid="
             + ":clgatewayipid=47108:cltechcalled=sip/sip%z80001118@4.7.1.8%z5056"
             + ":clgatewaypriceid=49008:clgatewaypricepermin=0,03:clgatewaycurrency=USD:timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 42008);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49508);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 47008);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 47008);
        }

        [TestMethod]
        public void TestRouteFixedGatewayToContextFixedGateway()
        {
            var node = new MockNode(41000);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=45.0.0.1%z5060",
                    "billid=1418778188-62",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001118",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-62", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=41000:clcustomerid=44000:"
            + "clcustomeripid=45000:cltrackingid=1418778188-62:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=47000:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z80001118@48.1.0.1%z5056:callto.1.called=80001118:callto.1.caller=00012521339915:callto.1.callername=00012521339915"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000"
             + ":callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID="
             + ":callto.1.rtp_addr=48.2.0.1:callto.1.rtp_forward=false:callto.1.rtp_port=6056:callto.1.oconnection_id=general"
             + ":callto.1.clgatewayid=48000:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=48100"
             + ":callto.1.cltechcalled=sip/sip%z80001118@48.1.0.1%z5056:callto.1.clgatewaypriceid=49100:callto.1.clgatewaypricepermin=0,03"
             + ":callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=10000"
             + ":callto.2=|next=10000"
             + ":callto.3=sip/sip%z80001118@48.6.0.1%z5056:callto.3.called=80001118:callto.3.caller=00012521339915:callto.3.callername=00012521339915"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000"
             + ":callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID="
             + ":callto.3.rtp_addr=48.7.0.1:callto.3.rtp_forward=false:callto.3.rtp_port=6056:callto.3.oconnection_id=general"
             + ":callto.3.clgatewayid=48500:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=48600"
             + ":callto.3.cltechcalled=sip/sip%z80001118@48.6.0.1%z5056:callto.3.clgatewaypriceid=49600:callto.3.clgatewaypricepermin=0,03"
             + ":callto.3.clgatewaycurrency=USD:callto.3.cldecision=4:callto.3.timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 43000);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49500);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext.Count, 0);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 2);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 48000);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Id, 43500);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways.Count, 0);
            Assert.IsNotNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.Id, 49501);
            Assert.IsFalse((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.IsFallbackToLCR);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets.Count, 1);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0].Id, 48500);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull(((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 2);
            Assert.AreEqual(routingTree.GatewayOrder[0], 48000);
            Assert.AreEqual(routingTree.GatewayOrder[1], 48500);
        }

        [TestMethod]
        public void TestMultiRoutes()
        {
            var node = new MockNode(41001);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=45.0.0.2%z5060",
                    "billid=1418778188-63",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=49280001118",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-63", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:clnodeid=41001:clcustomerid=44001:clcustomeripid=45001:cltrackingid=1418778188-63:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=47001:clcustomerpricepermin=0,06:clcustomercurrency=USD:cldialcodemasterid=2:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":location=sip/sip%z49280001118@48.1.0.2%z5056:called=49280001118:caller=00012521339915:callername=00012521339915:format=g729"
             + ":formats=g729,alaw,mulaw:line=:maxcall=65000:osip_P-Asserted-Identity="
             + ":osip_Gateway-ID=:osip_Tracking-ID=:rtp_addr=48.2.0.2:rtp_forward=false"
             + ":rtp_port=6056:oconnection_id=general:clgatewayid=48001:clgatewayaccountid="
             + ":clgatewayipid=48101:cltechcalled=sip/sip%z49280001118@48.1.0.2%z5056"
             + ":clgatewaypriceid=49102:clgatewaypricepermin=0,04:clgatewaycurrency=USD:timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 43001);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49706);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 48001);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 1);
            Assert.AreEqual(routingTree.GatewayOrder[0], 48001);
        }

        [TestMethod]
        public void TestRouteGatewayToContextLCR()
        {
            var node = new MockNode(41002);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479208",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=45.0.0.22%z5060",
                    "billid=1418778188-64",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001118",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-64", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=:"
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=41002:clcustomerid=44002:"
            + "clcustomeripid=45002:cltrackingid=1418778188-64:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=47002:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z80001118@48.1.8.2%z5056:callto.1.called=80001118:callto.1.caller=00012521339915:callto.1.callername=00012521339915"
             + ":callto.1.format=g729:callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000"
             + ":callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID="
             + ":callto.1.rtp_addr=:callto.1.rtp_forward=false:callto.1.rtp_port=6056:callto.1.oconnection_id=general"
             + ":callto.1.clgatewayid=48042:callto.1.clgatewayaccountid=:callto.1.clgatewayipid=48182"
             + ":callto.1.cltechcalled=sip/sip%z80001118@48.1.8.2%z5056:callto.1.clgatewaypriceid=49643:callto.1.clgatewaypricepermin=0,01"
             + ":callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=10000"
             + ":callto.2=|next=10000"
             + ":callto.3=sip/sip%z80001118@48.1.0.2%z5056:callto.3.called=80001118:callto.3.caller=00012521339915:callto.3.callername=00012521339915"
             + ":callto.3.format=g729:callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000"
             + ":callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID="
             + ":callto.3.rtp_addr=:callto.3.rtp_forward=false:callto.3.rtp_port=6056:callto.3.oconnection_id=general"
             + ":callto.3.clgatewayid=48002:callto.3.clgatewayaccountid=:callto.3.clgatewayipid=48102"
             + ":callto.3.cltechcalled=sip/sip%z80001118@48.1.0.2%z5056:callto.3.clgatewaypriceid=49603:callto.3.clgatewaypricepermin=0,02"
             + ":callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1005"
             + ":callto.4=|next=10000"
             + ":callto.5=sip/sip%z80001118@48.6.3.1%z5056:callto.5.called=80001118:callto.5.caller=00012521339915:callto.5.callername=00012521339915"
             + ":callto.5.format=g729:callto.5.formats=g729,alaw,mulaw:callto.5.line=:callto.5.maxcall=65000"
             + ":callto.5.osip_P-Asserted-Identity=:callto.5.osip_Gateway-ID=:callto.5.osip_Tracking-ID="
             + ":callto.5.rtp_addr=48.7.3.1:callto.5.rtp_forward=false:callto.5.rtp_port=6056:callto.5.oconnection_id=general"
             + ":callto.5.clgatewayid=48504:callto.5.clgatewayaccountid=:callto.5.clgatewayipid=48604"
             + ":callto.5.cltechcalled=sip/sip%z80001118@48.6.3.1%z5056:callto.5.clgatewaypriceid=49604:callto.5.clgatewaypricepermin=0,03"
             + ":callto.5.clgatewaycurrency=USD:callto.5.cldecision=8:callto.5.timeout=1005\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 43002);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 49502);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 2);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 48042);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Gateway).Via);            
            Assert.AreEqual(routingTree.Context.Route.Targets[1].Id, 43503);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways.Count, 2);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Id, 48002);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Via);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[1].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[1].Id, 48504);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[1].Via);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext.Count, 0);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 3);
            Assert.AreEqual(routingTree.GatewayOrder[0], 48042);
            Assert.AreEqual(routingTree.GatewayOrder[1], 48002);
            Assert.AreEqual(routingTree.GatewayOrder[2], 48504);
        }

        [TestMethod]
        public void TestMultiRoutesContextsGateways()
        {
            var node = new MockNode(60000);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "234479209",
                    UnixTimestamp.ToString(),
                    "call.route",
                    "id=sip/852978",
                    "module=sip",
                    "error=",
                    "reason=",
                    "status=incoming",
                    "address=45.0.20.2%z5060",
                    "billid=1418778188-65",
                    "answered=false",
                    "direction=incoming",
                    "caller=00012521339915",
                    "called=80001118",
                    "callername=00012521339915",
                    "sip_Tracking-ID=",
                    "sip_Gateway-ID="
                    ));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-65", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479209:true:call.route::error="
            + ":reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=60000:clcustomerid=60003"
            + ":clcustomeripid=60004:cltrackingid=1418778188-65:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=60004:clcustomerpricepermin=0,05:clcustomercurrency=USD:cldialcodemasterid=8:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
                + ":callto.1=sip/sip%z80001118@6.0.0.17%z5056:callto.1.called=80001118:callto.1.caller=00012521339915"
                + ":callto.1.callername=00012521339915:callto.1.format=g729:callto.1.formats=g729,alaw,mulaw"
                + ":callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID="
                + ":callto.1.osip_Tracking-ID=:callto.1.rtp_addr=6.0.1.17:callto.1.rtp_forward=false:callto.1.rtp_port=6056"
                + ":callto.1.oconnection_id=general:callto.1.clgatewayid=60016:callto.1.clgatewayaccountid="
                + ":callto.1.clgatewayipid=60017:callto.1.cltechcalled=sip/sip%z80001118@6.0.0.17%z5056:callto.1.clgatewaypriceid=60019"
                + ":callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=4:callto.1.timeout=1005"
                + ":callto.2=|next=10000"
                + ":callto.3=sip/sip%z80001118@6.0.0.22%z5056:callto.3.called=80001118:callto.3.caller=00012521339915"
                + ":callto.3.callername=00012521339915:callto.3.format=g729:callto.3.formats=g729,alaw,mulaw"
                + ":callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID="
                + ":callto.3.osip_Tracking-ID=:callto.3.rtp_addr=6.0.1.22:callto.3.rtp_forward=false:callto.3.rtp_port=6056"
                + ":callto.3.oconnection_id=general:callto.3.clgatewayid=60021:callto.3.clgatewayaccountid="
                + ":callto.3.clgatewayipid=60022:callto.3.cltechcalled=sip/sip%z80001118@6.0.0.22%z5056:callto.3.clgatewaypriceid=60024"
                + ":callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=4:callto.3.timeout=1005"
                + ":callto.4=|next=10000"
                + ":callto.5=sip/sip%z80001118@6.0.0.26%z5056:callto.5.called=80001118:callto.5.caller=00012521339915"
                + ":callto.5.callername=00012521339915:callto.5.format=g729:callto.5.formats=g729,alaw,mulaw"
                + ":callto.5.line=:callto.5.maxcall=65000:callto.5.osip_P-Asserted-Identity=:callto.5.osip_Gateway-ID="
                + ":callto.5.osip_Tracking-ID=:callto.5.rtp_addr=6.0.1.26:callto.5.rtp_forward=false:callto.5.rtp_port=6056"
                + ":callto.5.oconnection_id=general:callto.5.clgatewayid=60025:callto.5.clgatewayaccountid="
                + ":callto.5.clgatewayipid=60026:callto.5.cltechcalled=sip/sip%z80001118@6.0.0.26%z5056:callto.5.clgatewaypriceid=60028"
                + ":callto.5.clgatewaypricepermin=0,03:callto.5.clgatewaycurrency=USD:callto.5.cldecision=8:callto.5.timeout=1005"
                + ":callto.6=|next=10000"
                + ":callto.7=sip/sip%z80001118@6.0.0.30%z5056:callto.7.called=80001118:callto.7.caller=00012521339915"
                + ":callto.7.callername=00012521339915:callto.7.format=g729:callto.7.formats=g729,alaw,mulaw"
                + ":callto.7.line=:callto.7.maxcall=65000:callto.7.osip_P-Asserted-Identity=:callto.7.osip_Gateway-ID="
                + ":callto.7.osip_Tracking-ID=:callto.7.rtp_addr=6.0.1.30:callto.7.rtp_forward=false:callto.7.rtp_port=6056"
                + ":callto.7.oconnection_id=general:callto.7.clgatewayid=60029:callto.7.clgatewayaccountid="
                + ":callto.7.clgatewayipid=60030:callto.7.cltechcalled=sip/sip%z80001118@6.0.0.30%z5056:callto.7.clgatewaypriceid=60032"
                + ":callto.7.clgatewaypricepermin=0,03:callto.7.clgatewaycurrency=USD:callto.7.cldecision=8:callto.7.timeout=1005"
                + ":callto.8=|next=10000"
                + ":callto.9=sip/sip%z80001118@6.0.0.36%z5056:callto.9.called=80001118:callto.9.caller=00012521339915"
                + ":callto.9.callername=00012521339915:callto.9.format=g729:callto.9.formats=g729,alaw,mulaw"
                + ":callto.9.line=:callto.9.maxcall=65000:callto.9.osip_P-Asserted-Identity=:callto.9.osip_Gateway-ID="
                + ":callto.9.osip_Tracking-ID=:callto.9.rtp_addr=6.0.1.36:callto.9.rtp_forward=false:callto.9.rtp_port=6056"
                + ":callto.9.oconnection_id=general:callto.9.clgatewayid=60050:callto.9.clgatewayaccountid="
                + ":callto.9.clgatewayipid=60036:callto.9.cltechcalled=sip/sip%z80001118@6.0.0.36%z5056:callto.9.clgatewaypriceid=60038"
                + ":callto.9.clgatewaypricepermin=0,03:callto.9.clgatewaycurrency=USD:callto.9.cldecision=8:callto.9.timeout=1005"
                + ":callto.10=|next=10000"
                + ":callto.11=sip/sip%z80001118@6.0.0.40%z5056:callto.11.called=80001118:callto.11.caller=00012521339915"
                + ":callto.11.callername=00012521339915:callto.11.format=g729:callto.11.formats=g729,alaw,mulaw"
                + ":callto.11.line=:callto.11.maxcall=65000:callto.11.osip_P-Asserted-Identity=:callto.11.osip_Gateway-ID="
                + ":callto.11.osip_Tracking-ID=:callto.11.rtp_addr=6.0.1.40:callto.11.rtp_forward=false:callto.11.rtp_port=6056"
                + ":callto.11.oconnection_id=general:callto.11.clgatewayid=60051:callto.11.clgatewayaccountid="
                + ":callto.11.clgatewayipid=60040:callto.11.cltechcalled=sip/sip%z80001118@6.0.0.40%z5056:callto.11.clgatewaypriceid=60042"
                + ":callto.11.clgatewaypricepermin=0,03:callto.11.clgatewaycurrency=USD:callto.11.cldecision=8:callto.11.timeout=1005"
                + ":callto.12=|next=10000"
                + ":callto.13=sip/sip%z80001118@6.0.0.46%z5056:callto.13.called=80001118:callto.13.caller=00012521339915"
                + ":callto.13.callername=00012521339915:callto.13.format=g729:callto.13.formats=g729,alaw,mulaw"
                + ":callto.13.line=:callto.13.maxcall=65000:callto.13.osip_P-Asserted-Identity=:callto.13.osip_Gateway-ID="
                + ":callto.13.osip_Tracking-ID=:callto.13.rtp_addr=6.0.1.46:callto.13.rtp_forward=false:callto.13.rtp_port=6056"
                + ":callto.13.oconnection_id=general:callto.13.clgatewayid=60052:callto.13.clgatewayaccountid="
                + ":callto.13.clgatewayipid=60046:callto.13.cltechcalled=sip/sip%z80001118@6.0.0.46%z5056:callto.13.clgatewaypriceid=60048"
                + ":callto.13.clgatewaypricepermin=0,03:callto.13.clgatewaycurrency=USD:callto.13.cldecision=4:callto.13.timeout=10000\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 60002);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 60006);
            Assert.IsFalse(routingTree.Context.Route.IsFallbackToLCR);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 5);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Id, 60007);
            Assert.IsNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).LCRGateways.Count, 0);
            Assert.IsNotNull((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.BlendingContext.Count, 0);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets.Count, 2);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[0].Id, 60016);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Id, 60016);
            Assert.IsNull(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways.Count, 1);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Id, 60025);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Via);
            Assert.IsNotNull(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.BlendingContext.Count, 0);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.Id, 60020);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.IsFallbackToLCR, true);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets.Count, 1);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0].Id, 60021);
            Assert.AreEqual(((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Targets[1] as Utilities.RoutingTree.Context).Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.Id, 60015);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).Route.IsFallbackToLCR, false);
            
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual((routingTree.Context.Route.Targets[0] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Id, 60008);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways.Count, 1);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].Id, 60029);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual((routingTree.Context.Route.Targets[1] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Id, 60009);
            Assert.IsNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).LCRGateways.Count, 0);
            Assert.IsNotNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext.Count, 0);            
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Id, 60033);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.IsFallbackToLCR, false);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets.Count, 1);
            Assert.IsNull(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.AreEqual(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).Id, 60016);
            Assert.IsNull(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).LCRGateways.Count, 0);
            Assert.IsNull(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.None);
            Assert.AreEqual(((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.AlreadyTargeted);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Id, 60010);
            Assert.IsNull((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways.Count, 2);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways[0].Id, 60050);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways[1].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways[1].Id, 60051);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).LCRGateways[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNotNull((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.BlendingContext.Count, 0);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.Id, 60034);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.IsFallbackToLCR, true);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.Targets.Count, 1);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.Targets[0].Id, 60016);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.AlreadyTargeted);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.Fixed | Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual((routingTree.Context.Route.Targets[3] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.Context.Route.Targets[4].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[4].Id, 60052);
            Assert.AreEqual(routingTree.Context.Route.Targets[4].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[4] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext.Count, 0);
            Assert.AreEqual(routingTree.Context.Route.Id, 60006);
            Assert.AreEqual(routingTree.Context.Route.IsFallbackToLCR, false);            
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);            
            Assert.AreEqual(routingTree.GatewayOrder.Count, 7);
            Assert.AreEqual(routingTree.GatewayOrder[0], 60016);
            Assert.AreEqual(routingTree.GatewayOrder[1], 60021);
            Assert.AreEqual(routingTree.GatewayOrder[2], 60025);
            Assert.AreEqual(routingTree.GatewayOrder[3], 60029);
            Assert.AreEqual(routingTree.GatewayOrder[4], 60050);
            Assert.AreEqual(routingTree.GatewayOrder[5], 60051);
            Assert.AreEqual(routingTree.GatewayOrder[6], 60052);
        }

        #endregion Tests
    }
}