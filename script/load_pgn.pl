#!/usr/bin/perl
#
use strict;
use Chess::PGN::Parse;
use Data::Dumper;
use DBI;

my $pgnfile;
my $game_in_jsonb;

sub parse_game {
  my $game = shift(@_);
  my @move;

  while ( $game =~ m/(\d+)\.(\w+)\ (\w+)/g ) {
	  push @move, "\"$1\": [\"$2\", \"$3\"]";
  }
  return "{".join(', ', @move)."}";
}

if ( $ARGV[0] eq "" ) {
exit 1;
}

if ( ! -f $ARGV[0] ) {
exit 1;
}

my $dbh = DBI->connect("dbi:Pg:dbname=pgn;host=/tmp;port=5410", 'thomas', '',
  {
	RaiseError => 1,
	PrintError => 1,
  }) || die "Can't connect : $!\n";

if ( $dbh->{pg_server_version} < 90400 ) {
  die "Please use against PostgreSQL 9.4 or later !\n";
}

my $insert = "INSERT INTO pgn_game (white, black, result, game, eco) VALUES (?, ?, ?, ?, ?)";


$pgnfile = $ARGV[0];

my $pgn = new Chess::PGN::Parse $pgnfile;
my $sth = $dbh->prepare($insert);

while ($pgn->read_game()) {
#	print Data::Dumper::Dumper($pgn->{'gamedescr'});

	# parse game into jsonb string
	$game_in_jsonb = parse_game($pgn->game());
print $game_in_jsonb . '\n';

	# insert data
	$sth->execute(
		$pgn->white(),
		$pgn->black(),
		$pgn->result(),
		$game_in_jsonb,
		$pgn->eco()
	);
}


