use Win32::OLE;

my $task=sprintf("iTunes.exe");
my $app="iTunes.Application";

#my $cmd=sprintf("taskkill /fi %s",$task);
#if(!system($cmd)){
#	print "$cmd\n";
#	exit 0;
#}

my $cmd=sprintf("taskkill /IM %s",$task);
if(!system($cmd)){
	print "$cmd\n";
	exit 1;
}

my $cmd=sprintf("taskkill /IM %s /F",$task);
if(!system($cmd)){
	print "$cmd\n";
	exit 2;
}

print $cmd;

#my $OLE=Win32::OLE->GetObject($app);
#my $OLE=Win32::OLE->GetActiveObject($app);
#my $OLE=Win32::OLE->new($app);
#exit 2;
