namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Mocking;
    using Workers;

    /// <summary>
    /// This class tests the blending functionality
    /// </summary>
    [TestClass]
    public class BlendingTest : AbstractTest
    {
        #region Tests

        [TestMethod]
        public void TestBlendingLCR()
        {
            var node = new MockNode(500000);
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
                    "address=51.0.0.1%z5060",
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
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=500000:"
            + "clcustomerid=500000:clcustomeripid=500000:cltrackingid=1418778188-53:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=500000:clcustomerpricepermin=30:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z1111101@30.0.0.103%z5057:callto.1.called=1111101:callto.1.caller=00012521339915:callto.1.callername=00012521339915:callto.1.format=g729:"
             + "callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:"
             + "callto.1.rtp_addr=50.0.0.103:callto.1.rtp_forward=true:callto.1.rtp_port=6057:callto.1.oconnection_id=general:callto.1.clgatewayid=500002:callto.1.clgatewayaccountid=:"
             + "callto.1.clgatewayipid=500002:callto.1.cltechcalled=sip/sip%z1111101@30.0.0.103%z5057:"
             + "callto.1.clgatewaypriceid=500002:callto.1.clgatewaypricepermin=0,035:callto.1.clgatewaycurrency=USD:callto.1.cldecision=8:callto.1.timeout=1085:"
             + "callto.2=|next=10000:"
             + "callto.3=sip/sip%z1111101@30.0.0.102%z5057:callto.3.called=1111101:callto.3.caller=00012521339915:callto.3.callername=00012521339915:callto.3.format=g729:"
             + "callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:"
             + "callto.3.rtp_addr=50.0.0.102:callto.3.rtp_forward=true:callto.3.rtp_port=6057:callto.3.oconnection_id=general:callto.3.clgatewayid=500001:callto.3.clgatewayaccountid=:"
             + "callto.3.clgatewayipid=500001:callto.3.cltechcalled=sip/sip%z1111101@30.0.0.102%z5057:"
             + "callto.3.clgatewaypriceid=500001:callto.3.clgatewaypricepermin=0,03:callto.3.clgatewaycurrency=USD:callto.3.cldecision=8:callto.3.timeout=1085:"
             + "callto.4=|next=10000:"
             + "callto.5=sip/sip%z1111101@30.0.0.101%z5057:callto.5.called=1111101:callto.5.caller=00012521339915:callto.5.callername=00012521339915:callto.5.format=g729:"
             + "callto.5.formats=g729,alaw,mulaw:callto.5.line=:callto.5.maxcall=65000:callto.5.osip_P-Asserted-Identity=:callto.5.osip_Gateway-ID=:callto.5.osip_Tracking-ID=:"
             + "callto.5.rtp_addr=50.0.0.101:callto.5.rtp_forward=true:callto.5.rtp_port=6057:callto.5.oconnection_id=general:callto.5.clgatewayid=500000:callto.5.clgatewayaccountid=:"
             + "callto.5.clgatewayipid=500000:callto.5.cltechcalled=sip/sip%z1111101@30.0.0.101%z5057:"
             + "callto.5.clgatewaypriceid=500000:callto.5.clgatewaypricepermin=0,006:callto.5.clgatewaycurrency=USD:callto.5.cldecision=8:callto.5.timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 500000);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.IsNotNull(routingTree.Context.BlendingContext);
            Assert.IsNull(routingTree.Context.BlendingContext.BlendingContext);
            Assert.AreEqual(routingTree.Context.BlendingContext.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.BlendingContext.Id, 500001);
            Assert.IsNull(routingTree.Context.BlendingContext.InternalRoutedGateway);
            Assert.IsNull(routingTree.Context.BlendingContext.Route);
            Assert.AreEqual(routingTree.Context.BlendingContext.LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.BlendingContext.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.BlendingContext.LCRGateways[0].Id, 500002);
            Assert.AreEqual(routingTree.Context.BlendingContext.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.Blending);
            Assert.IsNull(routingTree.Context.BlendingContext.LCRGateways[0].Via);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 2);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].Id, 500001);
            Assert.AreEqual(routingTree.Context.LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[0] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.Context.LCRGateways[1].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.LCRGateways[1].Id, 500000);
            Assert.AreEqual(routingTree.Context.LCRGateways[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.LCRGateways[1] as Utilities.RoutingTree.Gateway).Via);
            Assert.AreEqual(routingTree.GatewayOrder[0], 500002);
            Assert.AreEqual(routingTree.GatewayOrder[1], 500001);
            Assert.AreEqual(routingTree.GatewayOrder[2], 500000);
        }

        [TestMethod]
        public void TestBlendingRoute()
        {
            var node = new MockNode(600000);
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
                    "address=61.0.0.1%z5060",
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
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=600000:"
            + "clcustomerid=600000:clcustomeripid=600000:cltrackingid=1418778188-53:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=600000:clcustomerpricepermin=30:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z1111101@90.0.0.201%z5057:callto.1.called=1111101:callto.1.caller=00012521339915:callto.1.callername=00012521339915:callto.1.format=g729:"
             + "callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:"
             + "callto.1.rtp_addr=90.0.0.201:callto.1.rtp_forward=true:callto.1.rtp_port=6057:callto.1.oconnection_id=general:callto.1.clgatewayid=600006:callto.1.clgatewayaccountid=:"
             + "callto.1.clgatewayipid=600006:callto.1.cltechcalled=sip/sip%z1111101@90.0.0.201%z5057:"
             + "callto.1.clgatewaypriceid=600006:callto.1.clgatewaypricepermin=0,03:callto.1.clgatewaycurrency=USD:callto.1.cldecision=8:callto.1.timeout=1085:"
             + "callto.2=|next=10000:"
             + "callto.3=sip/sip%z1111101@90.0.0.101%z5057:callto.3.called=1111101:callto.3.caller=00012521339915:callto.3.callername=00012521339915:callto.3.format=g729:"
             + "callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:"
             + "callto.3.rtp_addr=90.0.0.101:callto.3.rtp_forward=true:callto.3.rtp_port=6057:callto.3.oconnection_id=general:callto.3.clgatewayid=600000:callto.3.clgatewayaccountid=:"
             + "callto.3.clgatewayipid=600000:callto.3.cltechcalled=sip/sip%z1111101@90.0.0.101%z5057:"
             + "callto.3.clgatewaypriceid=600000:callto.3.clgatewaypricepermin=0,006:callto.3.clgatewaycurrency=USD:callto.3.cldecision=4:callto.3.timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 600000);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.IsNull(routingTree.Context.BlendingContext);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 600000);
            Assert.AreEqual(routingTree.Context.Route.IsFallbackToLCR, false);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext.Count, 1);
            Assert.IsNull(routingTree.Context.Route.BlendingContext[0].BlendingContext);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].Id, 600001);
            Assert.IsNull(routingTree.Context.Route.BlendingContext[0].InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].LCRGateways.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].LCRGateways[0].Id, 600006);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.Blending);
            Assert.IsNull(routingTree.Context.Route.BlendingContext[0].LCRGateways[0].Via);
            Assert.IsNull(routingTree.Context.Route.BlendingContext[0].Route);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].RoutingAction, Utilities.RoutingTree.ContextAction.LCR);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 1);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 600000);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.GatewayOrder.Count, 2);
            Assert.AreEqual(routingTree.GatewayOrder[0], 600006);
            Assert.AreEqual(routingTree.GatewayOrder[1], 600000);
        }
        
        [TestMethod]
        public void TestBlendingRoute2()
        {
            var node = new MockNode(700000);
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
                    "address=71.0.0.1%z5060",
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
            + "reason=:location=fork:fork.calltype=:fork.autoring=:fork.automessage=:fork.ringer=:clnodeid=700000:"
            + "clcustomerid=700000:clcustomeripid=700000:cltrackingid=1418778188-53:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=700000:clcustomerpricepermin=30:clcustomercurrency=USD:cldialcodemasterid=3:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams
             + ":callto.1=sip/sip%z1111101@90.0.0.103%z5057:callto.1.called=1111101:callto.1.caller=00012521339915:callto.1.callername=00012521339915:callto.1.format=g729:"
             + "callto.1.formats=g729,alaw,mulaw:callto.1.line=:callto.1.maxcall=65000:callto.1.osip_P-Asserted-Identity=:callto.1.osip_Gateway-ID=:callto.1.osip_Tracking-ID=:"
             + "callto.1.rtp_addr=90.0.0.103:callto.1.rtp_forward=true:callto.1.rtp_port=6057:callto.1.oconnection_id=general:callto.1.clgatewayid=700007:callto.1.clgatewayaccountid=:"
             + "callto.1.clgatewayipid=700007:callto.1.cltechcalled=sip/sip%z1111101@90.0.0.103%z5057:"
             + "callto.1.clgatewaypriceid=700007:callto.1.clgatewaypricepermin=0,006:callto.1.clgatewaycurrency=USD:callto.1.cldecision=8:callto.1.timeout=1085:"
             + "callto.2=|next=10000:"
             + "callto.3=sip/sip%z1111101@90.0.0.101%z5057:callto.3.called=1111101:callto.3.caller=00012521339915:callto.3.callername=00012521339915:callto.3.format=g729:"
             + "callto.3.formats=g729,alaw,mulaw:callto.3.line=:callto.3.maxcall=65000:callto.3.osip_P-Asserted-Identity=:callto.3.osip_Gateway-ID=:callto.3.osip_Tracking-ID=:"
             + "callto.3.rtp_addr=90.0.0.101:callto.3.rtp_forward=true:callto.3.rtp_port=6057:callto.3.oconnection_id=general:callto.3.clgatewayid=700002:callto.3.clgatewayaccountid=:"
             + "callto.3.clgatewayipid=700002:callto.3.cltechcalled=sip/sip%z1111101@90.0.0.101%z5057:"
             + "callto.3.clgatewaypriceid=700002:callto.3.clgatewaypricepermin=0,006:callto.3.clgatewaycurrency=USD:callto.3.cldecision=4:callto.3.timeout=1085:"
             + "callto.4=|next=10000:"
             + "callto.5=sip/sip%z1111101@90.0.0.104%z5057:callto.5.called=1111101:callto.5.caller=00012521339915:callto.5.callername=00012521339915:callto.5.format=g729:"
             + "callto.5.formats=g729,alaw,mulaw:callto.5.line=:callto.5.maxcall=65000:callto.5.osip_P-Asserted-Identity=:callto.5.osip_Gateway-ID=:callto.5.osip_Tracking-ID=:"
             + "callto.5.rtp_addr=90.0.0.104:callto.5.rtp_forward=true:callto.5.rtp_port=6057:callto.5.oconnection_id=general:callto.5.clgatewayid=700003:callto.5.clgatewayaccountid=:"
             + "callto.5.clgatewayipid=700003:callto.5.cltechcalled=sip/sip%z1111101@90.0.0.104%z5057:"
             + "callto.5.clgatewaypriceid=700003:callto.5.clgatewaypricepermin=0,006:callto.5.clgatewaycurrency=USD:callto.5.cldecision=4:callto.5.timeout=1085:"
             + "callto.6=|next=10000:"
             + "callto.7=sip/sip%z1111101@90.0.0.102%z5057:callto.7.called=1111101:callto.7.caller=00012521339915:callto.7.callername=00012521339915:callto.7.format=g729:"
             + "callto.7.formats=g729,alaw,mulaw:callto.7.line=:callto.7.maxcall=65000:callto.7.osip_P-Asserted-Identity=:callto.7.osip_Gateway-ID=:callto.7.osip_Tracking-ID=:"
             + "callto.7.rtp_addr=90.0.0.102:callto.7.rtp_forward=true:callto.7.rtp_port=6057:callto.7.oconnection_id=general:callto.7.clgatewayid=700008:callto.7.clgatewayaccountid=:"
             + "callto.7.clgatewayipid=700008:callto.7.cltechcalled=sip/sip%z1111101@90.0.0.102%z5057:"
             + "callto.7.clgatewaypriceid=700008:callto.7.clgatewaypricepermin=0,006:callto.7.clgatewaycurrency=USD:callto.7.cldecision=4:callto.7.timeout=1085\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 700000);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.IsNull(routingTree.Context.BlendingContext);
            Assert.IsNotNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.Route.Id, 700001);
            Assert.AreEqual(routingTree.Context.Route.IsFallbackToLCR, false);
            Assert.AreEqual(routingTree.Context.Route.BlendingContext.Count, 0);            
            Assert.AreEqual(routingTree.Context.Route.Targets.Count, 3);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].Id, 700002);
            Assert.AreEqual(routingTree.Context.Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].Id, 700003);
            Assert.AreEqual(routingTree.Context.Route.Targets[1].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual(routingTree.Context.Route.Targets[2].Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Route.Targets[2].Id, 700004);
            Assert.AreEqual(routingTree.Context.Route.Targets[2].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.IsNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).BlendingContext);
            Assert.IsNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).LCRGateways.Count, 0);
            Assert.IsNotNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Id, 700005);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext.Count, 1);
            Assert.IsNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].BlendingContext);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].Id, 700006);
            Assert.IsNull((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].InternalRoutedGateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].LCRGateways.Count, 1);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].LCRGateways[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].LCRGateways[0].Id, 700007);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.BlendingContext[0].LCRGateways[0].TargetReason, Utilities.RoutingTree.Reason.Blending);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.IsFallbackToLCR, false);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets.Count, 1);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0].Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0].Id, 700008);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).Route.Targets[0].TargetReason, Utilities.RoutingTree.Reason.OK);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).RoutingAction, Utilities.RoutingTree.ContextAction.Fixed);
            Assert.AreEqual((routingTree.Context.Route.Targets[2] as Utilities.RoutingTree.Context).TargetReason, Utilities.RoutingTree.Reason.OK);            
            Assert.AreEqual(routingTree.GatewayOrder.Count, 4);
            Assert.AreEqual(routingTree.GatewayOrder[0], 700007);
            Assert.AreEqual(routingTree.GatewayOrder[1], 700002);
            Assert.AreEqual(routingTree.GatewayOrder[2], 700003);
            Assert.AreEqual(routingTree.GatewayOrder[3], 700008);
        }

        #endregion
    }
}
