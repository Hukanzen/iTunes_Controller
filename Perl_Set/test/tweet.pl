use strict;
use warnings;
use utf8;

use Net::SSL;
use Net::Twitter::Lite::WithAPIv1_1;
use Encode;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $proxy_url = "http://192.168.3.1:8080";
$ENV{HTTPS_PROXY} = $proxy_url;  


my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key => 'Tx427H6hqif3CXT13zBzJhyFU',
    consumer_secret => 'iST1kW3XuWXrVeLJQSNuoYlscdW6zOvcC3qy4YlXy5lU9JH1Tv',
    access_token_secret => 'LUWPfVC292mIXT0tYaTZl2cjooqqcvnRffnbABwWAnIAm',
    access_token => '466465919-wpwPbl6Yd4q44tXjqc5BwQLu0FRPCkeml8pCM9iT',
    ssl => 1,
);

my $result = $nt->update('日本語');