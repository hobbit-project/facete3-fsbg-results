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

sub label {
    _(transitionId => $_[0]) . '-' . _(transitionType => $_[0]) #. '(rs:'. _(resSize => $_[0]) .')'
}

my @allsc = sort { $a <=> $b } uniq map { _(scenarioId => $_) } @lines;
for (my $sc = 1; ; $sc++) {
    my @scenario = grep { _(scenarioId => $_) == $sc } @lines;
    last unless @scenario;

    push @out, "%%% Scenario $sc";
    my @tt = uniq map { label($_) } @scenario;
    {
	local $" = ',';
	push @out, "
\\begin{tikzpicture}
\\begin{axis}[
width=12cm,height=3cm,
xlabel={Scenario $sc},
x tick label style={
/pgf/number format/1000 sep=},
ylabel=time(seconds),
enlargelimits=0.05,
symbolic x coords={@tt,x},
legend style={at={(0.5,-0.8)},
anchor=north,legend columns=-1},
ybar interval=0.7,
]";
    }
    my %sysm;
    for my $tt (@tt) {
	my @it = ($tt);
	for my $l (grep { $tt eq label($_) } @scenario) {
	    my $sr = _(system => $l);
	    my $t = _(tTime => $l);
	    push @{ $sysm{ $sr } }, "($tt,$t)";
	}
    }
    for my $s (@sys) {
	push @out, "\\addplot coordinates { @{ $sysm{ $s }  || [] } (x,0) };\n";
    }
    { local $" = ','; push @out, ($sc == $allsc[-1] ? "" : "% " ) . "\\legend{ @sys }"; }
    push @out, "
\\end{axis}
\\end{tikzpicture}
";
}


for (@out) {
    print $_;
    print "\n";
}
