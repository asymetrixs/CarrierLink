namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Mocking;
    using Workers;

    /// <summary>
    /// This class tests preroute functionality
    /// </summary>
    [TestClass]
    public class PrerouteTest : AbstractTest
    {
        #region Tests

        [TestMethod]
        public void TestCustomerAddressIncomplete()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=218.213.210.201%z5060",
                        "billid=1418778188-70",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=35587",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-70", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=484:reason=:"
                                                + "clnodeid=1:clcustomerid=101:clcustomeripid=4101:cltrackingid=1418778188-70:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.CalledIsIncomplete);
        }

        [TestMethod]
        public void TestCustomerUnknown()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=255.213.210.201%z5060",
                        "billid=1418778188-71",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=0069#355874821173",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-71", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:reason=:"
                                                + "clnodeid=1:clcustomerid=:clcustomeripid=:cltrackingid=1418778188-71:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.UnknownSender);
        }

        [TestMethod]
        public void TestCustomerWithoutPrefix()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=218.213.210.207%z5060",
                        "billid=1418778188-72",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=355874821173",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-72", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:reason=:"
                                                + "clnodeid=1:clcustomerid=1:clcustomeripid=3:cltrackingid=1418778188-72:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=4:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 2);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
        }

        [TestMethod]
        public void TestCustomerWithPrefix()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=218.213.210.207%z5060",
                        "billid=1418778188-73",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=0069#355874821173",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-73", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:reason=:"
                                                + "clnodeid=1:clcustomerid=4:clcustomeripid=6:cltrackingid=1418778188-73:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=4:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.AreEqual(routingTree.Context.Id, 5);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
        }

        [TestMethod]
        public void TestCustomerLimitExceeded()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=218.213.210.202%z5060",
                        "billid=1418778188-74",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=355874821173",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-74", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=480:reason=:"
                                                + "clnodeid=1:clcustomerid=7:clcustomeripid=9:cltrackingid=1418778188-74:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.LimitExceeded);
        }

        [TestMethod]
        public void TestNodeSends()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=10.0.0.1%z5060",
                        "billid=1418778188-75",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=355874821173",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-75", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=503:reason=:"
                                                + "clnodeid=1:clcustomerid=:clcustomeripid=:cltrackingid=1418778188-75:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=4:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNotNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.InternalRoutedGateway.Endpoint, Utilities.RoutingTree.TargetType.Gateway);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway.Id);
            Assert.AreEqual(routingTree.Context.InternalRoutedGateway.TargetReason, Utilities.RoutingTree.Reason.GatewayIdNotTransmitted);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Internal | Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.OK);
        }

        [TestMethod]
        public void TestEmptyAddress()
        {
            var incomingMessage = new MockMessage();
            var node = new MockNode(1);
            incomingMessage.SetIncoming(node, string.Join(":",
                        "%%>message",
                        "234479208",
                        UnixTimestamp,
                        "call.route",
                        "id=sip/852978",
                        "module=sip",
                        "status=incoming",
                        "address=",
                        "billid=1418778188-76",
                        "answered=false",
                        "direction=incoming",
                        "caller=00012521339915",
                        "called=",
                        "callername=00012521339915"));


            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();
            var routingTree = getRoutingTree(node, "1418778188-76", false);
            var routingTree1 = getRoutingTree(node, "1418778188-76", true);
            var routingTree2 = getRoutingTree(node, "1418778188-76", false);
            var routingTree3 = getRoutingTree(node, "1418778188-76", true);

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.IsTrue(result.OutgoingMessage.StartsWith("%%<message:234479208:true:call.route::error=403:reason=:"
                                                + "clnodeid=1:clcustomerid=:clcustomeripid=:cltrackingid=1418778188-76:clprocessingtime="));

            Assert.IsTrue(result.OutgoingMessage.Contains(":clcustomerpriceid=:clcustomerpricepermin=:clcustomercurrency=:cldialcodemasterid=:clwaitingtime="));
            Assert.IsTrue(result.OutgoingMessage.EndsWith(CopyParams + "\n"));

            Assert.IsNotNull(routingTree);
            Assert.AreEqual(routingTree.Context.Endpoint, Utilities.RoutingTree.TargetType.Context);
            Assert.IsNull(routingTree.Context.Id);
            Assert.IsNull(routingTree.Context.InternalRoutedGateway);
            Assert.AreEqual(routingTree.Context.LCRGateways.Count, 0);
            Assert.IsNull(routingTree.Context.Route);
            Assert.AreEqual(routingTree.Context.RoutingAction, Utilities.RoutingTree.ContextAction.Cancelled);
            Assert.AreEqual(routingTree.Context.TargetReason, Utilities.RoutingTree.Reason.AddressIsEmpty);

            // test removing
            Assert.IsNotNull(routingTree1);
            Assert.AreSame(routingTree, routingTree1);
            Assert.IsNull(routingTree2);
            Assert.IsNull(routingTree3);
        }

        #endregion Tests
    }
}