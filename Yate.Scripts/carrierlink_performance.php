<?php

/**
 *
 *
 *      DO NOT EDIT HIS FILE ON WINDOWS!
 *      JUST DON'T!
 *      USE nano ON *NIX!
 *
 *
 */

class Node
{
	public $CpuCount = -1;
	public $CpuUser = -1;
	public $CpuNice = -1;
	public $CpuSystem = -1;
	public $CpuIdle = -1;
	public $CpuIoWait = -1;
	public $CpuHardIrq = -1;
	public $CpuSoftIrq = -1;

	public $MemoryTotal = -1;
	public $MemoryUsed = -1;
	public $MemoryFree = -1;

	public $SwapTotal = -1;
	public $SwapUsed = -1;
	public $SwapFree = -1;
}

function CollectPerformanceData()
{

	$node = new Node();

	/*
	 *
	 * MEMORY + SWAP
	 *
	 */

	// Memory
	exec("free -m | awk 'NR==2{printf \"%s %s %s\", $2, $3, $4}'", $memory);
	$memory = explode(" ", $memory[0]);
	$node->MemoryTotal = $memory[0];
	$node->MemoryUsed = $memory[1];
	$node->MemoryFree = $memory[2];

	// Swap
	exec ("free -m | awk 'NR==4{printf \"%s %s %s\", $2, $3, $4}'", $swap);
	$swap = explode(" ", $swap[0]);
	$node->SwapTotal = $swap[0];
	$node->SwapUsed = $swap[1];
	$node->SwapFree = $swap[2];

	/*
	 *
	 * CPU COUNT
	 *
	 */
	// collect data
	exec("cat /proc/cpuinfo", $cpuinfo);
	$node->CpuCount = 0;
	// iterate and count
	foreach ($cpuinfo as $ci)
	{
		if(0 === strpos($ci, "processor"))
		{
			$node->CpuCount += 1;
		}
	}

	/*
	 *
	 * CPU USAGE
	 *
	 */
	// collect data in interval of 1 second
	exec("cat /proc/stat", $prev_proc_stat);
	sleep(1);
	exec("cat /proc/stat", $curr_proc_stat);

	// extract necessary information
	$prev_cpu_info = explode(" ", substr($prev_proc_stat[0], 5));
	$curr_cpu_info = explode(" ", substr($curr_proc_stat[0], 5));

	// calculate totals
	$prev_total = 0;
	$curr_total = 0;
	foreach ($prev_cpu_info as $val)
	{
		$prev_total += $val;
	}
	foreach ($curr_cpu_info as $val)
	{
		$curr_total += $val;
	}

	// calculate diffs
	$diff_total = $curr_total - $prev_total;
	$diff_user = $curr_cpu_info[0] - $prev_cpu_info[0];
	$diff_nice = $curr_cpu_info[1] - $prev_cpu_info[1];
	$diff_system = $curr_cpu_info[2] - $prev_cpu_info[2];
	$diff_idle = $curr_cpu_info[3] - $prev_cpu_info[3];
	$diff_iowait = $curr_cpu_info[4] - $prev_cpu_info[4];
	$diff_hardirq = $curr_cpu_info[5] - $prev_cpu_info[5];
	$diff_softirq = $curr_cpu_info[6] - $prev_cpu_info[6];

	$node->CpuUser = round($diff_user / $diff_total * 100, 1);
	$node->CpuNice = round($diff_nice / $diff_total * 100, 1);
	$node->CpuSystem = round($diff_system / $diff_total * 100, 1);
	$node->CpuIdle = round($diff_idle / $diff_total * 100, 1);
	$node->CpuIoWait = round($diff_iowait / $diff_total * 100, 1);
	$node->CpuHardIrq = round($diff_hardirq / $diff_total * 100, 1);
	$node->CpuSoftIrq = round($diff_softirq / $diff_total * 100, 1);

	return $node;
}


/*
 *
 *	DEBUGGING
 *
 * 	Uncomment 'print_r...' (see below) for debugging, then run directly:
 *	# php5 -f carrierlink_performance.php
 *
 */
// print_r(CollectPerformanceData());

?>
