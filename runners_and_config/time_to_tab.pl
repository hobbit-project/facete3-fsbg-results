use strict;
use warnings;
use Hash::Util 'lock_hash';

sub uniq {
    my %seen;
    grep { !$seen{$_}++ } @_
}

my @lines = map { s/\r?\n//; [ split ',' ] }  <> ;

my $header = shift @lines;

my %H = do { my $i = 0; map { ( $_ => $i++ ) } @{ $header } };
lock_hash %H;

sub _ { $_[1][ $H{ $_[0] } ] }

my @out;
my @sys = uniq map { _(system => $_) } @lines;
my %sys = do { my $i = 1; map { ( $_ => $i++ ) } @sys };
lock_hash %sys;

sub _sys : lvalue { $_[1][ $sys{ $_[0] } ] }

for (my $sc = 1; ; $sc++) {
    my @scenario = grep { _(scenarioId => $_) == $sc } @lines;
    last unless @scenario;

    push @out, [ "Scenario $sc", @sys ];
    my @tt = uniq map { _(transitionId => $_) . '-' . _(transitionType => $_) } @scenario;
    my @total = 'Total';
    for my $tt (@tt) {
	my @it = ($tt);
	for my $l (grep { $tt eq _(transitionId => $_) . '-' . _(transitionType => $_) } @scenario) {
	    my $sr = _(system => $l);
	    my $t = _(tTime => $l);
	    _sys( $sr => \@it ) = $t;
	    _sys( $sr => \@total ) += $t;
	}
	push @out, \@it;
    }
    #push @out, [ @total ];
    push @out, [];
}


for (@out) {
    print join ',', @{ $_ };
    print "\n";
}
