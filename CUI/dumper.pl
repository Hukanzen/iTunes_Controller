use strict;
use warnings;

use Data::Dumper;
#use Class::Inspector;
use Win32::OLE;

#open(OUT,">dumper.log");
#open(OUT,">Inspec.log");

my $itunes =Win32::OLE->new("iTunes.Application") or die "iTunesオブジェクトを作成できません。";

#print OUT Dumper($itunes);
my $track = $itunes->CurrentTrack;
print $track->PlayedCount;
#print OUT Dumper(Class::Inspector->functions($itunes));
#print OUT Dumper(Class::Inspector->methods($itunes));

#close(OUT);
