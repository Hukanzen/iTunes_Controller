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

my $slp_min=3;

my $old_text=" ";

&proxy;

while(1){
	my $track = $itunes->CurrentTrack;
	
	if($track eq ''){
		printf "not playing";
		exit 1;
	} 
	
	#my $text=sprintf("#nowplaying \n	Title: \"%s\"\n 	Album: \"%s\"\n 	Artist: \"%s\"\n	Count:\"%d\"\n",$track->Name ,$track->Album,$track->Artist,$track->PlayedCount);
	my $text=sprintf("#nowplaying \n	Title: \"%s\"\n		Count: \"%d\"\n",$track->Name,$track->PlayedCount );

	$text=decode('Shift_JIS', $text)."#bot開発試験運用中 \n";

	#$text=$text." ".&juhuku;

	if($old_text ne $text){
		printf("%s - ",$track->Name);
		my $result=&tweet_func($text);

		if($result != 0){
			$itunes =Win32::OLE->new("iTunes.Application") or die "iTunesオブジェクトを作成できません。";
			printf("Create iTunes Object\n");
		}else{
			$old_text=$text;
 	
			for(my $i=0;$i<$slp_min*6;$i++){
				sleep(10);
			}
			#printf("\n");
			#sleep(60*3);
		}

		#for(my $i=0;$i<4;$i++){

			#sleep(10);
		#}
	}else{
		print "Passing !\n";
		#sleep(5);
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

	#my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
	#    consumer_key => 'Tx427H6hqif3CXT13zBzJhyFU',
	#    consumer_secret => 'iST1kW3XuWXrVeLJQSNuoYlscdW6zOvcC3qy4YlXy5lU9JH1Tv',
	#    access_token_secret => 'LUWPfVC292mIXT0tYaTZl2cjooqqcvnRffnbABwWAnIAm',
	#    access_token => '466465919-wpwPbl6Yd4q44tXjqc5BwQLu0FRPCkeml8pCM9iT',
	#    ssl => 1,
	#);
	my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
	    consumer_key => 'cW78cARBkuW1viDABIpM6z0TR',
	    consumer_secret => '33rH8FnSixH4g7pqPe4xcPwv5vwGuLMYy1BLQPqn1Qs9U1w12t',
	    access_token_secret => 'kbWpio4jfHkgeFdr8GwXSqoID7oyUncelL7DlLLt39kkP',
	    access_token => '819218123450519552-AAXFtODfUCTkuHnWIc9SMj0dqMpcz8Q',
	    ssl => 1,
	);
	my $i=0;
	while(1){
		my $result = eval{
			$nt->update($string);
		};
		
		if(!$@){
			print "Success Tweet !"."\n";
			last;
		}elsif($i==10){
			print "Failed Tweet ... \n";
			last;
		}
		print "$@\n";
		$i++;
		#print "Failed Tweet ... \n";
	}

	return $i;
}

sub juhuku{
    	my $today = DateTime->now;
    	$today->set_time_zone( 'Asia/Tokyo' );
    	#my $today_ymd = $today->ymd; # ex 2010-08-22
    	my $today_hms = $today->hms; # ex 10:22:33

	print $today_hms."\n";

	return $today_hms;

}