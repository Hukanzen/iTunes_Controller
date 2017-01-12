use strict;
use warnings;
use utf8;

use Net::SSL;
use Net::Twitter::Lite::WithAPIv1_1;
use Encode;

use Win32::OLE;
use Win32::Clipboard;

use DateTime;

my $clip=Win32::Clipboard();
my $itunes =Win32::OLE->new("iTunes.Application") or die "iTunesオブジェクトを作成できません。";

my $old_track="";

&proxy;

while(1){
	my $track = $itunes->CurrentTrack;
	
	if($track eq ''){
		printf "not playing";
		exit 1;
	} 
	
	my $text=sprintf("#nowplaying \n
	Title: \"%s\"\n 
	Album: \"%s\"\n 
	Artist: \"%s\"\n",$track->Name ,$track->Album,$track->Artist);

	$text=decode('Shift_JIS', $text)."#bot開発試験運用中 \n";

	$text=$text." ".&juhuku;
	
	if($old_track ne $track->Name){
		&tweet_func($text);	
		$old_track=$track->Name;

		#for(my $i=0;$i<4;$i++){
			sleep(60*4);
		#}
	}else{
		print "Passing !\n";
		sleep(30);
	}
}

sub proxy{
	my $proxy_url = "http://192.168.3.1:8080";
	$ENV{HTTPS_PROXY} = $proxy_url;  
}

sub tweet_func{
	my ($string)=@_;

	$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

	my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
	    consumer_key => 'Tx427H6hqif3CXT13zBzJhyFU',
	    consumer_secret => 'iST1kW3XuWXrVeLJQSNuoYlscdW6zOvcC3qy4YlXy5lU9JH1Tv',
	    access_token_secret => 'LUWPfVC292mIXT0tYaTZl2cjooqqcvnRffnbABwWAnIAm',
	    access_token => '466465919-wpwPbl6Yd4q44tXjqc5BwQLu0FRPCkeml8pCM9iT',
	    ssl => 1,
	);
	
	while(1){
		my $result = eval{
			$nt->update($string);
		};

		if(!$@){
			print "Success Tweet !"."\n";
			last;
		}else{
			print "Failed Tweet ... \n";
		}
	}


}

sub juhuku{
    	my $today = DateTime->now;
    	$today->set_time_zone( 'Asia/Tokyo' );
    	#my $today_ymd = $today->ymd; # ex 2010-08-22
    	my $today_hms = $today->hms; # ex 10:22:33

	print $today_hms."\n";

	return $today_hms;

}