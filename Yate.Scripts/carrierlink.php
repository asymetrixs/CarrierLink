#!/usr/bin/env php

<?php

/**
 *
 *
 *	DO NOT EDIT HIS FILE ON WINDOWS!
 *	JUST DON'T!
 *	USE nano ON *NIX!
 *
 *
 */

// load depending files
require_once("libyate.php");
require_once("carrierlink_performance.php");

// connect
Yate::Init(true, "127.0.0.1", 10000, "");

// install handler
Yate::Install("cali.node", 80);

// auto restart script if fails
Yate::SetLocal("restart", true);

// Signal loading complete
Yate::Debug("CarrierLink loaded");


// main loop to perform actual work
// run forever
for (;;)
{

	// receive event
	$ev = Yate::GetEvent();

	if ($ev === false)
	{
		break;
	}

	if ($ev === true)
	{
		continue;
	}

	if ($ev->type == "incoming" && $ev->params["name"] == "performance")
	{
		// collect data
		$node = CollectPerformanceData();

		// add data
		$ev->params["ccount"] = $node->CpuCount;
		$ev->params["cuser"] = $node->CpuUser;
		$ev->params["cnice"] = $node->CpuNice;
		$ev->params["csystem"] = $node->CpuSystem;
		$ev->params["cidle"] = $node->CpuIdle;
		$ev->params["ciowait"] = $node->CpuIoWait;
		$ev->params["chardirq"] = $node->CpuHardIrq;
		$ev->params["csoftirq"] = $node->CpuSoftIrq;
		$ev->params["mtotal"] = $node->MemoryTotal;
		$ev->params["mused"] = $node->MemoryUsed;
		$ev->params["mfree"] = $node->MemoryFree;
		$ev->params["stotal"] = $node->SwapTotal;
		$ev->params["sused"] = $node->SwapUsed;
		$ev->params["sfree"] = $node->SwapFree;

		// signal handled
		$ev->handled = true;

		// answer
		$ev->Acknowledge();
	}
}

?>
