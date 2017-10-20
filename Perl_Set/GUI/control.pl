#===2017/01/15 22:37===#
#nextTrack.prevTrackは扱いとしては、割り込みなっている(?)
#早急に修正すべし、
#また、プレイリスト選択機能


use strict;
use warnings;

use Data::Dumper;

use Win32::Clipboard;
use Win32::OLE;

#=== グローバル変数 ===#
my $itunes =Win32::OLE->new("iTunes.Application") or die "iTunesオブジェクトを作成できません。";
my $playlistName;
if(!defined($itunes->Currentplaylist)){
	$playlistName='like56';
}else{
	$playlistName=$itunes->Currentplaylist->Name;
}	
#$playlistName;

my $track_list = $itunes->LibrarySource->Playlists->ItemByName($playlistName);

#=== グローバル変数 ===#

#while(1){
	&main();
#}

sub main(){
	if(@ARGV != 1){
		&HELP;
		exit 1;
	}
	
	#&HELP;
	
	my $value=$ARGV[0];
	#my $value=<STDIN>;

	#$value=chomp($value);
	
	if($value!~m!^\d+$!){
		print "please number";
		#&HELP;
		exit 1;
	}elsif($value eq '\n'){
	#	print "please number";
		next;
	}


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
		$itunes->{SoundVolume}-=&Volume();
	}elsif($value==6){
		$itunes->{SoundVolume}+=&Volume();
	}elsif($value==7){
		&list;
	}elsif($value==8){
		&set_playlist;
	}elsif($value==100){
		exit(0);
	}else{
		&HELP;
	}
	#printf("Title: %s\n",($itunes->CurrentTrack->Name));
	
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
	printf("8-set_playlist\n");
	
	#exit 1;
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
	printf ("Playlist name : %s\n",$playlistName);
	my $tracks=$track_list->Tracks;
	#my @list_Item;

	for(my $i=1;$i<=($tracks->Count);$i++){
		#@list_Item[$i-1]=$tracks->item($i);
		my $list_Item=$tracks->item($i);
		my $Name=$list_Item->Name;
		printf ("%d:%s\n",$i,$Name);
		if(!($i%20)){
			my $cut=<STDIN>;
		}
	}
	printf("番号を入力することで、曲選択ができます。\n");
	my $cic=<STDIN>;

	if($cic=~m!^\d+$!){
		$tracks->item($cic)->Play();
	#	@list_Item[$cic-1]->Play();
	#	printf("%s\n",$tracks->item($cic)->Name);
	}elsif($cic eq "q"){
		exit 2;
	}

}
sub set_playlist{
	$track_list->PlayFirstTrack();
}
