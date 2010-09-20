#!/usr/bin/env perl
@arglist = @ARGV;
$arglistsize = scalar @arglist;

if($arglistsize eq "0")
{
	&usage;
}
elsif($arglistsize eq "1")
{
	$command = @ARGV[0];
	$mat = "0";

	@comwrap = ($command);
	$commlistref = \@comwrap;
	$arglistref = \@arglist;

	&pidDir();

	$scriptToCall = writeShellScript($commlistref,"X",$mat);

	print "qsub $scriptToCall\n";
	$qsubout = `qsub $scriptToCall`;
	print "$qsubout\n";

	&writeLog($arglistref,"single",$mat);

}
elsif(($arglistsize eq "2") && (@ARGV[0] =~ /-/))
{
	if(@ARGV[0] eq "-m")
	{
		$command = @ARGV[1];
		$mat = "1";

		@comwrap = ($command);
		$commlistref = \@comwrap;
		$arglistref = \@arglist;

		&pidDir();


		writeMatlabScript($commlistref,"X");
		$scriptToCall = writeShellScript($commlistref,"X",$mat);

		print "qsub $scriptToCall\n";
		#$qsubout = `qsub -l h_cpu=72:00:00 -l mem_free=500M $scriptToCall`;
		$qsubout = `qsub $scriptToCall`;
		print "$qsubout\n";
		&writeLog($arglistref,"single",$mat);

	}
	else
	{
		&usage;
	}
}
else
{



################# Parse Input ################################################################

$mat = 0;
$rec = 0;
$numproc = 0;

$argnum = 0;

# determine if recursive or matlab 

$arglistref = \@arglist;

if (@ARGV[0] =~ /-/){

	if(@ARGV[0] =~ /m/){
		$mat = 1;		
	}
	if(@ARGV[0] =~ /r/){
		$rec = 1;
	}
	$argnum++;


}

$command = @ARGV[$argnum];
$argnum++;

if ($rec eq 1){
	$dir = @ARGV[$argnum];
	$argnum++;
}

$fpattern = @ARGV[$argnum];
$argnum++;

# determine if num proc set 

if(@ARGV[$argnum] =~ /-n/)
{
	$numproc = 1;
	$argnum++;
}

if ($numproc eq 1){
	$numproc = @ARGV[$argnum] ;
	$argnum++;
}

#print "matlab : $mat \n";
#print "recursive : $rec \n";
#print "number of processors : $numproc \n";

################################################################################




#### the "main"



# getting the @filelist

if($rec eq 1)
{
	$findit = "find $dir -name ".'"'."$fpattern".'"';
#	print "$findit\n";
	$fileblob = `$findit`;
	@filelist = split(/\n/,$fileblob); 
}
else
{
	@filelist = glob($fpattern);	
}




# parse file list and store literal command in process array

$numOfFiles = @filelist;
#print "num of files : $numOfFiles";

if($numOfFiles eq 0)
{
	print "No Files Matched Pattern !!!\n\n";
	exit;
}

if ($numproc eq 0) 
{
	$np = $numOfFiles;
}
else
{
	$np = $numproc;
}





#create empty list for each proc

for($i=0;$i<$np;$i++)
{
#	print "Creating ref array num : $i \n";	
	push(@proclist,[]);
}

print @proclist."\n";
$fileNumber = 0;

foreach $file (@filelist)
{
	$procOn = $fileNumber % $np;
	$listref = $proclist[$procOn];
	@list = @$listref;
	$comcopy = $command;
	my $com = cmdliteral($comcopy,$file);
#	print "Pushing command : $com : onto proc num : $procOn\n";
	push(@list,$com);
	$proclist[$procOn] = [@list];
	$fileNumber++;
}





# just to test ########

#$psize = 0;

#foreach $p (@proclist)
#{
	
#print "List $psize\n\n";
#@l = @$p;
#foreach $f (@l)
#{
#	print "command :'' $f \n";
#}
#
#$psize++;
#	
#}
#########################





### make sure PID directories exist ####
&pidDir();

###
### looping through process list

for($i=0;$i<$np;$i++)
{
	$commlistref = $proclist[$i];
	
	if($mat eq 0)
	{
		$scriptToCall = &writeShellScript($commlistref,$i,"0");
	}
	else
	{	
		$matlabScript = &writeMatlabScript($commlistref,$i);
		$scriptToCall = &writeShellScript($commlistref,$i,"1");
	}

	print "qsub $scriptToCall\n";
	$qsubout = `qsub -l h_cpu=72:00:00 $scriptToCall`;
	print "$qsubout\n";
}

&writeLog($arglistref,$np,$mat);





}
#end of non-single else loop

###### subroutines #########

sub cmdliteral
{
	$_[0] =~ s/%%/$_[1]/;
	$cmdlit = $_[0];
}

sub pidDir
{
	if (-d "/home/$ENV{'LOGNAME'}/.qarray-pid")
	{
		if (-d "/home/$ENV{'LOGNAME'}/.qarray-pid/scripts")
		{
			return(1);
		}
		else
		{
			print "Creating directory ~/.qarray-pid/scripts\n";
			system("mkdir ~/.qarray-pid/scripts");
		}
	}
	else
	{
		system("mkdir ~/.qarray-pid");
		print "Creating directory ~/.qarray-pid\n";

		system("mkdir ~/.qarray-pid/scripts");
		print "Creating directory ~/.qarray-pid/scripts\n";
	}
	return(0);
}

# writeShellScript($commlistref,$procNumber,$mat)
sub writeShellScript
{

	$note = "q";
	if($_[2] eq 1)
	{
		$note = "m";
	}

	$commlistref = $_[0];
	$tempscriptname = "$note$$-$_[1]";
	$tempscriptpath = "/home/$ENV{'LOGNAME'}/.qarray-pid/scripts/$tempscriptname.sh";

	system("cp /home/lcoelho/user/scripts/blank.sh $tempscriptpath");
	
	open($tempScript,"+>>$tempscriptpath");

	print $tempScript '#$ -o '."$note$$-$_[1].stdout\n";
	print $tempScript '#$ -e '."$note$$-$_[1].stderr\n";
	#print $tempScript '#$ -cwd '."\n";

	print $tempScript "echo\n";
	print $tempScript "echo\n";
	print $tempScript 'echo "HOSTNAME:$HOSTNAME"'."\n";
	print $tempScript "echo\n";
	print $tempScript "echo\n";
	print $tempScript "\ncd ";
	system("pwd >> $tempscriptpath");
	print $tempScript "\n";

	if($_[2] eq 0)
	{
		@commlist = @$commlistref;
	
		foreach $com (@commlist)
		{
			print $tempScript "$com\n";
		}
		print $tempScript "rm $tempscriptpath\n";
	}
	else
	{
		print $tempScript "cp ~/.qarray-pid/scripts/temp$$"."$_[1].m .\n";
		print $tempScript "matlab -nodisplay -r ".'"'."temp$$"."$_[1]".'"'."\n";
		print $tempScript "rm ./temp$$"."$_[1].m\n";
	}

	
	close(tempscript);

	return $tempscriptpath;
}

# writeMatlabScript($commlistref,$procNumber)
sub writeMatlabScript
{
	$commlistref = $_[0];
	$tempscriptname = "temp$$"."$_[1]";
	$tempscriptpath = "/home/$ENV{'LOGNAME'}/.qarray-pid/scripts/$tempscriptname.m";


	open($tempScript,">$tempscriptpath");

	@commlist = @$commlistref;
	foreach $com (@commlist)
	{
		$comtemp = $com;
		$comtemp =~ s/'/''/g;
		print $tempScript "fprintf('>> $comtemp\\n\\n');\n";
		print $tempScript "$com\n";
	}
	
	print $tempScript "unix('rm $tempscriptpath');\n";
	print $tempScript "unix('rm /home/$ENV{'LOGNAME'}/.qarray-pid/scripts/m$$-$_[1].sh');\n";
	print $tempScript "quit;\n";
	
	close(tempScript);

	return $tempscriptpath;

	
}

#writeLog($arglistref,$np,$mat)
sub writeLog
{

$arglistref = $_[0];
$np = $_[1];
$mat = $_[2];

	$note = "q";
	if($_[2] eq 1)
	{
		$note = "m";
	}


	@alist = @$arglistref;
	$alistsize = scalar @alist;

	$date = `date`;

	$logfilename = "$$.log";
	
	if($mat eq 1)
	{
		$logfilename = "m$logfilename";
	}

	$logfilepath = "/home/$ENV{'LOGNAME'}/.qarray-pid/$logfilename";
	$masterlogfilepath = "/home/$ENV{'LOGNAME'}/.qarray-pid/qmaster.log";

	$rebuiltCmdLit = "qarray";

	for($i=0;$i<$alistsize;$i++)
	{
		$arg = @alist[$i];

		if($arg =~ /-/){}
		else
		{
			$arg = '"'."$arg".'"';
		}

		$rebuiltCmdLit = $rebuiltCmdLit." $arg";		
	}

#### open master log
	
	open($masterlogfp,"+>>$masterlogfilepath");

#### open log

	open($logfp,"+>>$logfilepath");
	
#### write to log

	print $logfp "$$::$date::$rebuiltCmdLit\n";

	if($np eq "single")
	{
		print $logfp "$note$$-X.sh\n";
		if($mat eq 1)
		{
			print $logfp "temp$$"."X.m\n";
		}
	}
	else
	{
		for($i=0;$i<$np;$i++)
		{
			print $logfp "$note$$-$i.sh\n";
			if($mat eq 1)
			{
				print $logfp "temp$$"."$i.m\n";
			}
		}
	}
#### close log

	close($logfp);

#### write to master log

	print $masterlogfp "$$:$date:$np:$rebuiltCmdLit\n\n";

#### close master log

	close($masterlogfp);
}


sub rangeParser
{

	$initialCom = $_[0];
	@rcom = [$initialCom];

@rcomnew = [];
	
foreach $rcomMemb (@rcom)
{

		if(($rcomMemb =~ /<</) || ($rcomMemb =~ />>/))
		{
			unless($initialCom =~ /<</)
			{
				die("::: range symbol syntax error :::\n");
			}
	
			@splitcoml = split(/<</,$rcomMemb);
	
			unless($splitcoml[1] =~ />>/)
			{
				die("::: range symbol syntax error :::\n");
			}
	
			@splitcomr = split(/>>/,$splitcoml[1]);
			@rcomnewpart = &range($splitcomr[0]);
			
			foreach $rcomnewpartmemb (@rcomnewpart)
			{
				$temp = 
				push(@rcomnew,)
			}

			#$splitcomr[0] = $rcomnewref;
			#$splitcoml[$i] = join "" @splitcomr;
		}

}


}

sub usage
{
print"\n\n";
print"--------------------------------------------------------------------------------\n";
print"Usage : qarray -[r|m] command regexpr [(r)dir] -n [(n) number or submit scripts]\n\n\n";
print"--------------------------------------------------------------------------------\n";
print"\n\n";
print"EXAMPLES : \n\n";
print"Single Command : qarray \"cmd\" (non-matlab command)\n";
print"		       qarray -m \"matlabcmd\" (matlab command)\n";
print"\n";			
print"[Command on multiple files :]\n";
print"\n";
print"Using glob :\n";
print"\n";
print"qarray \"cmd(%%)\" \"*.tif\" \n(non-matlab command on every tif file in pwd )\n\n";
print"qarray \"cmd(%%)\" \"*/*.tif\" \n(non-matlab command on every tif file one level down frompwd)\n\n";
print"qarray \"cmd(%%)\" \"*/*/*.tif\" \n(non-matlab command on every tif file two levels down from pwd)\n\n";
print"\n";		
print"qarray -m \"matlabcmd(%%)\" \"*/*/*.tif\" \n(matlab command on every tif file two levels down from pwd)\n\n";
print"\n";
print"Using find D1 -name E1 :\n";
print"\n";
print"qarray -rm \"matlabcmd(%%)\" \".\" \"*.tif\"\n(matlab command on every tif file in every subdirectory of .)\n\n";
print"\n";
print"qarray -rm \"matlabcmd(%%)\" \".\" \"*.tif\" -n 10 \n(matlab command on every tif file in every subdirectory of . , dividing into 10 qsubs)\n\n";


}
