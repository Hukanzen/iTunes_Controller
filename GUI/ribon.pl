use strict;
use warnings;
use Encode qw(decode);

use Win32::Clipboard;
use Win32::OLE;
use Tk;
use Tk::Pane;

#=== グローバル変数 ===#
my $ENCODE='cp932';
my $itunes =Win32::OLE->new("iTunes.Application") or die "iTunesオブジェクトを作成できません。";
my $playlistName;
if(!defined($playlistName=$itunes->Currentplaylist)){
	$playlistName='like56';
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
	$top->minsize(150,200);
		
	my $tk_nowPlaying=decode($ENCODE,$playlistName);

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
	$top->Button(-text=>'VolumeDown' ,-command=>[\&ctrl,'6'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'list' ,-command=>[\&ctrl,'7'])->pack();
	$top->Button(-text=>'select' ,-command=>[\&ctrl,'8'])->pack();
	$top->Label(-fg=>'black',-text=>"\n")->pack();

	$top->Button(-text=>'update' ,-command=>[\&update])->pack();
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
		#my $vlm=$top->Toplevel();

		#$vlm->Label(-fg=>'black',-text=>'Volume UP')->pack();

		#MainLoop();
		$itunes->{SoundVolume}+=&Volume();
	}elsif($value==6){
		$itunes->{SoundVolume}-=&Volume();
	}elsif($value==7){
		&list;
	}elsif($value==8){
		&select;
	}
#	elsif($value==9){
#		&update($_[1]);
#	}
	
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
	#printf("Volume:");
	#my $vlm=<STDIN>;
	#if($vlm!~m!^\d+$!){
	#	exit 2;
	#}

	#return $vlm*10;
	return 2;
}

sub copy(){

	my $clip=Win32::Clipboard();
	my $track = $itunes->CurrentTrack;

	if(!$track){
		printf "not playing";
		exit 3;
	} 

	my $text=sprintf("#nowplaying \nTitle \"%s\"\nAlbum \"%s\"\nArtist \"%s\"",$track->Name ,$track->Album,$track->Artist);
	
	$clip->Set($text);
	
	print "Copyed to Clipboard !\n";
}

sub list(){
#	printf ("Playlist name : %s\n",$playlistName);
	my $tk_playlistName=decode($ENCODE,$playlistName);

	my $mytop=MainWindow->new(-title=>$tk_playlistName,-width=>150);
	#my $mytop=MainWindow->new(-title=>$tk_playlistName);
	#$mytop->minsize(150,200);
	$mytop=$mytop->Scrolled('Frame',-scrollbars=>'e',-height=>800)->pack();
	#my $mytop=MainWindow->new(-title=>$tk_playlistName,-width=>150,-height=>50);
	my $tracks=$track_list->Tracks;


	for(my $i=1;$i<=($tracks->Count);$i++){
		my $list_Item=$tracks->item($i);
		my $Name=$list_Item->Name;
		my $tk_Name=decode($ENCODE,$Name);

		$mytop->Button(-text=>$tk_Name ,-command=>[\&cic_Play,$i,$tracks])->pack();
		
	}
	#=== ListBox ===#
	#my $lb=$list_win->Listbox(-width=>50,-height=>50);
	#my $sb=$list_win->Scrollbar(-orient=>'v',-command=>['yview',$lb]);

	#$lb->configure(-yscrollcommand=>['set',$sb]);
	#$lb->grid(-row=>1,-column=>0,-sticky=>'nsew');

	#$sb->grid(-row=>1,-column=>1,-sticky=>'ns');

	#for(my $i=1;$i<=($tracks->Count);$i++){
	#	my $list_Item=$tracks->item($i);
	#	my $Name=$list_Item->Name;

	#	my $tk_Name=decode($ENCODE,$Name);
	#	
	#	$lb->insert('end',$i."-".$tk_Name);
	#}
	#=== ListBox ===#
#	$list_win->bind("<Double-1>",\&get_music($tracks,$lb));
#	$lb->see('start');
	MainLoop();
	


}
sub cic_Play{
	my ($cic,$tracks)=@_;
	my $item=$tracks->item($cic);
	$item->Play();
}

sub select{
#	my $list_win=$top->Toplevel(-title=>$tk_playlistName,-width=>50,-height=>50);
	my $tracks=$track_list->Tracks;
	#my $msg=sprintf("番号を入力することで、曲選択ができます。\n");
	#printf(decode($ENCODE,$msg));
	print "type number in list,selection music.";
   
	my $cic=<STDIN>;

	if($cic=~m!^\d+$!){
		$tracks->item($cic)->Play();
		#printf("%s\n",$tracks->item($cic)->Name);
		printf("Title: %s\n",($itunes->CurrentTrack->Name));
	}	
}


sub get_music{
	my ($tracks,$lb)=@_;
	my $cic=$lb->get('anchor');
	print $cic;
#
#print $cic;
#	print "aaa";
	#$tracks->item($cic)->Play();
}

sub update{
	my $top=MainWindow->new(-title=>'update');

	my	$tk_nowPlaying=decode($ENCODE,$itunes->CurrentTrack->Name);
	my	$Playing_name=$top->Label(-fg=>'black',-textvariable=>\$tk_nowPlaying);

#	$top->Label(-fg=>'black',-text=>'iTunes Control')->pack();
	$Playing_name->pack();
	print "Now Playing: ";
	printf($itunes->CurrentTrack->Name);
	print "\n";
	
	MainLoop();
	return ;
}
