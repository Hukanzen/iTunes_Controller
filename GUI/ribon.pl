use strict;
use warnings;
use Encode qw(decode);

use Win32::Clipboard;
use Win32::OLE;
use Tk;

#=== グローバル変数 ===#
my $ENCODE='cp932';
my $itunes =Win32::OLE->new("iTunes.Application") or die "iTunesオブジェクトを作成できません。";
my $playlistName;
if(!defined($playlistName=$itunes->Currentplaylist)){
	$playlistName='local';
}else{
	$playlistName=$itunes->Currentplaylist->Name;
}	

my $track_list = $itunes->LibrarySource->Playlists->ItemByName($playlistName);

my $top; #Main Window
#=== グローバル変数 ===#

#=== 以下,作り直し ===#
&main();
sub main(){

	$top=MainWindow->new(-title=>'iTunes Control');
	$top->minsize(250,200);

	
	my $tk_nowPlaying=decode($ENCODE,$itunes->CurrentTrack->Name);
	my $Playing_name=$top->Label(-fg=>'black',-textvariable=>\$tk_nowPlaying);

#	$top->Label(-fg=>'black',-text=>'iTunes Control')->pack();
	$Playing_name->pack();

	$top->Button(-text=>'Pause',-command=>[\&ctrl,'0'])->pack();
	$top->Button(-text=>'Play' ,-command=>[\&ctrl,'1'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'BackTrack' ,-command=>[\&ctrl,'2'])->pack();
	$top->Button(-text=>'NextTrack' ,-command=>[\&ctrl,'3'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'Copy' ,-command=>[\&ctrl,'4'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'VolumeUP' ,-command=>[\&ctrl,'5'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'list' ,-command=>[\&ctrl,'7'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'HELP' ,-command=>\&HELP)->pack();
	$top->Button(-text=>'EXIT' ,-command=>\&exit)->pack();
	
	MainLoop();
}

sub ctrl(){
	my $value=$_[0];

	printf $value."-";
	if($value==0){
		$itunes->pause();
	}elsif($value==1){
		$itunes->play();
	}elsif($value==2){
		$itunes->backTrack();
	}elsif($value==3){
		$itunes->nextTrack();
	}elsif($value==4){
		&copy;
	}elsif($value==5){
	#	$itunes->{SoundVolume}-=&Volume();
		my $vlm=$top->Toplevel();

		$vlm->Label(-fg=>'black',-text=>'Volume UP')->pack();

		MainLoop();
	}elsif($value==6){
		$itunes->{SoundVolume}+=&Volume();
	}elsif($value==7){
		&list;
	}
	
	printf($itunes->CurrentTrack->Name."\n");
	return 0;
}

sub HELP(){
	if($itunes->CurrentTrack){
		printf("Title: %s\n",($itunes->CurrentTrack->Name));
		printf("Artist: %s\n",($itunes->CurrentTrack->Artist));
		printf("Playlist: %s\n",($itunes->CurrentPlaylist->Name));
		printf("Time: %s\n",($itunes->CurrentTrack->Time));
#		printf("status: %s\n",($itunes->GetPlayerButtonsState));
		printf("\n");
	}
	printf("0-pause()\n");
	printf("1-play()\n");
	printf("2-backTrack()\n");
	printf("3-nexttrack()\n");
	printf("4-COPY\n");
	printf("5-VolumeDown\n");
	printf("6-VolumeUp\n");
	printf("7-List\n");
	
	return 0;
#	exit 1;
}

sub Volume(){
	printf("Volume:");
	my $vlm=<STDIN>;
	if($vlm!~m!^\d+$!){
		exit 2;
	}

	return $vlm*10;
}

sub copy(){

	my $clip=Win32::Clipboard();
	my $track = $itunes->CurrentTrack;

	if(!$track){
		printf "not playing";
		exit 3;
	} 

	my $text=sprintf("
		#nowplaying \n 
		Title \"%s\"\n 
		Album \"%s\"\n 
		Artist \"%s\"",$track->Name ,$track->Album,$track->Artist);
	
	$clip->Set($text);
	
	print "Copyed to Clipboard !\n";
}

sub list(){
#	printf ("Playlist name : %s\n",$playlistName);
	my $tracks=$track_list->Tracks;

	my $tk_playlistName=decode($ENCODE,$playlistName);
	my $list_win=$top->Toplevel(-title=>$tk_playlistName,-width=>50,-height=>50);
	#$list_win->maxsize(50,50);

	my $lb=$list_win->Listbox(-width=>50,-height=>50);
	my $sb=$list_win->Scrollbar(-orient=>'v',-command=>['yview',$lb]);

	$lb->configure(-yscrollcommand=>['set',$sb]);
	$lb->grid(-row=>1,-column=>0,-sticky=>'nsew');

	$sb->grid(-row=>1,-column=>1,-sticky=>'ns');

	for(my $i=1;$i<=($tracks->Count);$i++){
		my $list_Item=$tracks->item($i);
		my $Name=$list_Item->Name;

		my $tk_Name=decode($ENCODE,$Name);
		
		$lb->insert('end',$tk_Name);
	}
#	$lb->see('start');
	MainLoop();
	

#	my $msg=sprintf("番号を入力することで、曲選択ができます。\n");
#	print decode($ENCODE,$msg);

	
#	my $cic=<STDIN>;

#	if($cic=~m!^\d+$!){
#		$tracks->item($cic)->Play();
#		printf("%s\n",$tracks->item($cic)->Name);
#	}

}
