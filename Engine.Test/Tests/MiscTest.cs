namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Caching;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Mocking;
    using System;
    using System.Collections.Generic;
    using Workers;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class tests various different parts
    /// </summary>
    [TestClass]
    public class MiscTest : AbstractTest
    {
        #region Tests

        [TestMethod]
        public void TestPhonenumber()
        {
            var testNumbers = new List<Tuple<string, string>>();

            testNumbers.Add(new Tuple<string, string>("49201929202", "49201929202"));
            testNumbers.Add(new Tuple<string, string>("abc49201929203", "49201929203"));
            testNumbers.Add(new Tuple<string, string>("4920192924abc", "4920192924"));
            testNumbers.Add(new Tuple<string, string>("#49201929205", "49201929205"));
            testNumbers.Add(new Tuple<string, string>("5847839#49201abc929206", "49201"));
            testNumbers.Add(new Tuple<string, string>("+49201929207", "49201929207"));
            testNumbers.Add(new Tuple<string, string>("00049201929208", "49201929208"));
            testNumbers.Add(new Tuple<string, string>("+049201929209", "49201929209"));
            testNumbers.Add(new Tuple<string, string>("+03#49201929210", "49201929210"));
            testNumbers.Add(new Tuple<string, string>("#+049201929211", "49201929211"));
            testNumbers.Add(new Tuple<string, string>("+#049201929212", "49201929212"));
            testNumbers.Add(new Tuple<string, string>("dka49201929213dka", "49201929213"));
            testNumbers.Add(new Tuple<string, string>("#dka49201929214dka", "49201929214"));
            testNumbers.Add(new Tuple<string, string>("0#dka49201929215dka", "49201929215"));
            testNumbers.Add(new Tuple<string, string>("00+#0+dka49201929216dka", "49201929216"));

            var worker = Pool.RouteMessageWorkers.Get();

            string normalized;
            foreach (var testNumber in testNumbers)
            {
                normalized = worker.NormalizePhoneNumber(testNumber.Item1);
                Assert.AreEqual(normalized, testNumber.Item2);
            }

            Pool.RouteMessageWorkers.Put(worker);
            worker = null;
        }

        [TestMethod]
        public void TestSplitNumber()
        {
            var number = "4921155769983";

            var result = Cache.SplitNumber(number);

            Assert.AreEqual<string>(result[0], "4921155769983");
            Assert.AreEqual<string>(result[1], "492115576998");
            Assert.AreEqual<string>(result[2], "49211557699");
            Assert.AreEqual<string>(result[3], "4921155769");
            Assert.AreEqual<string>(result[4], "492115576");
            Assert.AreEqual<string>(result[5], "49211557");
            Assert.AreEqual<string>(result[6], "4921155");
            Assert.AreEqual<string>(result[7], "492115");
            Assert.AreEqual<string>(result[8], "49211");
            Assert.AreEqual<string>(result[9], "4921");
            Assert.AreEqual<string>(result[10], "492");
            Assert.AreEqual<string>(result[11], "49");
            Assert.AreEqual<string>(result[12], "4");
        }

        [TestMethod]
        public void TestEngineTimer()
        {
            var node = new MockNode(1);
            var incomingMessage = new MockMessage();
            incomingMessage.SetIncoming(node, string.Join(":",
                    "%%>message",
                    "051EFE60.1969150591",
                    UnixTimestamp.ToString(),
                    "engine.timer",
                    "",
                    "time=1468577974",
                    "nodename=WIN-E2OH1TVPT5C"
                    ));

            Dispatcher.Process(incomingMessage).Wait();

            var result = node.RetrieveMessage();

            // Assert - split because MS are measured for 'clwaitingtime,clprocessingtime' and change between runs
            Assert.AreEqual<string>(result.OutgoingMessage, "%%<message:051EFE60.1969150591:false:engine.timer::time=1468577974\n");
        }

        [TestMethod]
        public void TestMonitorQuery()
        {
            var node = new MockNode(100000);
            SetupTest.RegisteredNodes.TryAdd(100000, node);

            var task = Core.QueryParameterAsync(100000, MonitorParameter.UserLoad);

            var message = node.RetrieveMessage();

            Assert.IsTrue(message.OutgoingMessage.StartsWith("%%>message:cl"));
            //cl{time}:{time} ignored
            Assert.IsTrue(message.OutgoingMessage.EndsWith(":monitor.query::name=userLoad\n"));

            message.SetIncoming(node, "%%<message:cl1468859743:true:monitor.query::name=userLoad:handlers=cpuload%z100:value=2");
            Dispatcher.Process(message).Wait();

            task.Wait();

            var result = task.Result;

            Assert.IsTrue(result.Success);
            Assert.AreEqual<MonitorParameter>((MonitorParameter)result.Parameter, MonitorParameter.UserLoad);
            Assert.AreEqual<string>(result.Result, "2");
        }

        [TestMethod]
        public void TestEngineParameterQuery()
        {
            var node = new MockNode(100001);
            SetupTest.RegisteredNodes.TryAdd(100001, node);

            var task = Core.QueryParameterAsync(100001, EngineParameter.NodeName);

            var message = node.RetrieveMessage();

            Assert.AreEqual<string>(message.OutgoingMessage, "%%>setlocal:engine.nodename:\n");

            message.SetIncoming(node, "%%<setlocal:engine.nodename:ubuntuyate:true");
            Dispatcher.Process(message).Wait();

            task.Wait();

            var result = task.Result;

            Assert.IsTrue(result.Success);
            Assert.AreEqual<EngineParameter>((EngineParameter)result.Parameter, EngineParameter.NodeName);
            Assert.AreEqual<string>(result.Result, "ubuntuyate");
        }

        [TestMethod]
        public void TestEngineConfigurationQuery()
        {
            var node = new MockNode(100002);
            SetupTest.RegisteredNodes.TryAdd(100002, node);

            var task = Core.QueryEngineConfigurationAsync(100002, "localsym", "h323chan.yate");
            var message = node.RetrieveMessage();

            Assert.AreEqual<string>(message.OutgoingMessage, "%%>setlocal:config.localsym.h323chan.yate:\n");

            message.SetIncoming(node, "%%<setlocal:config.localsym.h323chan.yate:yes:true");
            Dispatcher.Process(message).Wait();

            task.Wait();

            var result = task.Result;

            Assert.IsTrue(result.Success);
            Assert.AreEqual<string>(result.Result, "yes");
        }

        [TestMethod]
        public void TestMessageIncoming()
        {
            // Setup
            var node = new MockNode(100004);
            var incomingMessage = new Message();

            // Test
            incomingMessage.SetIncoming(node, "%%>message:546456885:85422269:call.route:id=sip/1:module=sip:status=incoming:address=2.2.2.2%z5060:billid=123456789-9631:" +
                            $"answered=false:direction=incoming:caller=anonymous:called=494045699884:callername=anonymous");

            // Assert
            Assert.AreEqual<MessageDirection>(incomingMessage.MessageDirection, MessageDirection.IncomingRequest);
            Assert.AreEqual<string>(incomingMessage.MessageId, "546456885");
            Assert.AreSame(incomingMessage.Node, node);
            Assert.AreEqual<string>(incomingMessage.ChannelId, "sip/1");
            Assert.AreEqual<int>(incomingMessage.IncomingSplittedMessage.Length, 14);
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[0], "%%>message");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[1], "546456885");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[2], "85422269");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[3], "call.route");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[4], "id=sip/1");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[5], "module=sip");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[6], "status=incoming");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[7], "address=2.2.2.2%z5060");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[8], "billid=123456789-9631");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[9], "answered=false");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[10], "direction=incoming");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[11], "caller=anonymous");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[12], "called=494045699884");
            Assert.AreEqual<string>(incomingMessage.IncomingSplittedMessage[13], "callername=anonymous");

            // GetValue()
            Assert.AreEqual<string>(incomingMessage.GetValue("id"), "sip/1");
            Assert.AreEqual<string>(incomingMessage.GetValue("module"), "sip");
            Assert.AreEqual<string>(incomingMessage.GetValue("status"), "incoming");
            Assert.AreEqual<string>(incomingMessage.GetValue("address"), "2.2.2.2:5060");
            Assert.AreEqual<string>(incomingMessage.GetValue("billid"), "123456789-9631");
            Assert.AreEqual<string>(incomingMessage.GetValue("answered"), "false");
            Assert.AreEqual<string>(incomingMessage.GetValue("direction"), "incoming");
            Assert.AreEqual<string>(incomingMessage.GetValue("caller"), "anonymous");
            Assert.AreEqual<string>(incomingMessage.GetValue("called"), "494045699884");
            Assert.AreEqual<string>(incomingMessage.GetValue("callername"), "anonymous");
        }

        [TestMethod]
        public void TestMessageOutgoing()
        {
            //Setup
            var node = new MockNode(100005);
            var outgoingMessage = new Message();

            // Test
            outgoingMessage.SetOutgoing(node, MessageDirection.OutgoingAnswer, "message:10000002:true:call.route::error=480:reason=:clnodeid=30:clcustomerid=7:clcustomeripid=15:cltrackingid=14689195707185549-2:clprocessingtime=556:clcustomerpriceid=6066276:clcustomerpricepermin=0,4033:clcustomercurrency=USD:cldialcodemasterid=53103:clwaitingtime=0:cldecision=12>8;32:copyparams=clgatewayid,cltechcalled,clgatewayipid,clgatewayaccountid,cltrackingid,clwaitingtime,clprocessingtime,clcustomerid,cldialcodemasterid,clgatewaypriceid,clgatewaypricepermin,clgatewaycurrency,clcustomerpriceid,clcustomerpricepermin,clcustomercurrency,clnodeid,clcustomeripid");

            // Assert
            Assert.AreEqual<MessageDirection>(outgoingMessage.MessageDirection, MessageDirection.OutgoingAnswer);
            Assert.AreEqual<string>(outgoingMessage.MessageId, "10000002");
            Assert.AreSame(outgoingMessage.Node, node);
            Assert.AreEqual<string>(outgoingMessage.OutgoingMessage, "%%<message:10000002:true:call.route::error=480:reason=:clnodeid=30:clcustomerid=7:clcustomeripid=15:cltrackingid=14689195707185549-2:clprocessingtime=556:clcustomerpriceid=6066276:clcustomerpricepermin=0,4033:clcustomercurrency=USD:cldialcodemasterid=53103:clwaitingtime=0:cldecision=12>8;32:copyparams=clgatewayid,cltechcalled,clgatewayipid,clgatewayaccountid,cltrackingid,clwaitingtime,clprocessingtime,clcustomerid,cldialcodemasterid,clgatewaypriceid,clgatewaypricepermin,clgatewaycurrency,clcustomerpriceid,clcustomerpricepermin,clcustomercurrency,clnodeid,clcustomeripid\n");
        }

        [TestMethod]
        public void TestMessageCancelMessageSuccessful()
        {
            var node = new MockNode(100006);
            var incomingMessage = new Message();
            incomingMessage.SetIncoming(node, "%%>message:546456888:85422270:call.route:id=sip/1:module=sip:status=incoming:address=2.2.2.2%z5060:billid=123456789-9631:" +
                            $"answered=false:direction=incoming:caller=anonymous:called=494045699884:callername=anonymous");

            // Test
            bool success = incomingMessage.CancelCallRouteMessage();

            Assert.IsTrue(success);
            Assert.AreEqual<MessageDirection>(incomingMessage.MessageDirection, MessageDirection.OutgoingAnswer);
            Assert.AreEqual<string>(incomingMessage.MessageId, "546456888");
            Assert.AreEqual(incomingMessage.OutgoingMessage, "%%<message:546456888:false:call.route::id=sip/1\n");
        }

        [TestMethod]
        public void TestMessageCancelMessageUnSuccessful1()
        {
            var node = new MockNode(100007);
            var incomingMessage = new Message();
            incomingMessage.SetIncoming(node, "%%<message:546456888:85422270:call.route:id=sip/1:module=sip:status=incoming:address=2.2.2.2%z5060:billid=123456789-9631:" +
                            $"answered=false:direction=incoming:caller=anonymous:called=494045699884:callername=anonymous");

            // Test
            bool success = incomingMessage.CancelCallRouteMessage();

            Assert.IsFalse(success);
            Assert.AreEqual<MessageDirection>(incomingMessage.MessageDirection, MessageDirection.IncomingAnswer);
            Assert.AreEqual<string>(incomingMessage.MessageId, "546456888");
            Assert.IsTrue(string.IsNullOrEmpty(incomingMessage.OutgoingMessage));
        }

        [TestMethod]
        public void TestMessageCancelMessageUnSuccessful2()
        {
            var node = new MockNode(100008);
            var incomingMessage = new Message();
            incomingMessage.SetIncoming(node, "%%<setlocal:engine.nodename:ubuntuyate:true");

            // Test
            bool success = incomingMessage.CancelCallRouteMessage();

            Assert.IsFalse(success);
            Assert.AreEqual<MessageDirection>(incomingMessage.MessageDirection, MessageDirection.IncomingAnswer);
            Assert.IsTrue(string.IsNullOrEmpty(incomingMessage.MessageId));
            Assert.IsTrue(string.IsNullOrEmpty(incomingMessage.OutgoingMessage));
        }

        #endregion
    }
}
