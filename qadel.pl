#!/usr/bin/env perl

# checking num of input args

$argsize = scalar @ARGV;

if($argsize eq "1")
{
	$statline = `qstatus | grep @ARGV[0]-`;
	chomp($statline);
	@statlines = split(/\n/,$statline);

	foreach $line (@statlines)
	{
		@splitline = split(/\s/,$line);

		print "qdel $splitline[2]\n";
		$output = `qdel $splitline[2]`;
		print $output;		
	}
	system("rm ~/.qarray-pid/*@ARGV[0]*.log");
	system("rm ~/.qarray-pid/scripts/*@ARGV[0]*");
}
else
{
	&usage;
}

sub usage
{
	print "#################################################################\n";
	print "# qadel : deletes all SGE jobs, logs, and                       #\n";
	print "# scripts associated with the array job id                      #\n";
	print "#################################################################\n\n";
	print "\n\n";
	print 'Usage: qadel 17266'."\n\n";
}
