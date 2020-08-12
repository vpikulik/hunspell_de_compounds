#!/usr/bin/perl -w

# (C) 2006,2007 Weißhuhn & Weißhuhn Kommunikationsmanagement GmbH Berlin
# http://www.weisshuhn.de/
# May be freely modified and distributed as long as this copyright notice is kept in place

# (very short) documentation:
# to use the geneated dictionary file you have to edit/add following lines to
# your affix file:
#
# compoundwords controlled _
#
# flag ~x:
#    E    > N
#    .    > S
# flag ~y:
#    .    > ES
# flag ~z:
#    .    > EN

use strict;
use Getopt::Std;
use IO::File;
use Data::Dumper;
use POSIX;

$ENV{'PATH'} = '/bin:/usr/bin';
delete $ENV{'ENV'};
delete $ENV{'BASH_ENV'};

# import options
my %opts;
getopts('i:o:b:h',\%opts);

my $MINLEN = 3;
my $MAXLEN = 10;

if ($opts{'h'}) {
  print
"Options:
  -i    Input file
  -o    Output file
  -b    Badwords file
";
  exit;
}
my $INFILE  = $opts{'i'} || undef;
my $OUTFILE = $opts{'o'} || undef;
unless ($INFILE and $OUTFILE) {
  print "provide option: -i <infile>\n" unless ($INFILE);
  print "provide option: -o <outfile>\n" unless ($OUTFILE);
  exit 1;
}
my $BADWORDS = $opts{'b'} || undef;

# open files

# schon jetzt, damit ein evtl. auftretender Fehler nicht erst nach X Stunden
# sichtbar wird
my $out = new IO::File;
$out->open("> $OUTFILE") || die("Error while opening output file: $!\n");

# main
$|=1;

# bad words
my $badwords;
if ($BADWORDS) {
  my $bfile = new IO::File;
  $bfile->open("< $BADWORDS") || die("Error while opening badwords file: $!\n");
  while (my $line = <$bfile>) {
    $line =~ m/^([^\/]+)\/?.*$/;
    my $word = $1;
    $word =~ s/\s+$//;
    $badwords->{lc($word)} = defined;
  }
}

# read words
my $in  = new IO::File;
$in->open("< $INFILE") || die("Error while opening input file: $!\n");
my $words;
while (my $line = <$in>) {
#  next unless ($line =~ m/^[A-Z]/); # muss mit Großbuchstaben beginnen
  next if ($line =~ m/^.[A-Z]/); # Wahrscheinlich Abkürzung
  
  $line =~ m/^([^\/]+)\/?(.*)$/;
  my $word = $1;
  $word =~ s/\s+$//;
  next unless (length($word) > 2); # Wort muss mind. 3 Buchstaben haben
  next if (exists($badwords->{lc($word)})); # keine Badwords bearbeiten
  my @attribs = split(//, ($2 || ''));
  next if (
    exists($words->{lc($word)}) and $words->{lc($word)}->{'orig'} =~ m/^[A-Z]/
  ); # Nomen haben Vorrang
  foreach my $attrib (@attribs) {
    $words->{lc($word)}->{$attrib} = $attrib;
  }
  $words->{lc($word)}->{'orig'} = $word;
}
$in->close;
my $wordnum = scalar(keys %$words);

# Arrays mit Wortlängen bilden
my @class;
my $maxlength = 0;
foreach my $word (sort keys %$words) {
  my $length = length $word;
  $maxlength = $length if ($length > $maxlength);
  $class[$length] = () unless (defined $class[$length]);
  push (@{$class[$length]}, $word);
}

# über Wörter iterieren
my $curnum = 0;
my $start = time();
foreach my $word (sort keys %$words) {
  $curnum++;
#  next unless ($words->{$word}->{'orig'} =~ m/^[A-Z]/); # Nur Nomen berücksichtigen
  my $length = length($word);
  next unless ($length > 6);

  # Restzeit-Kristallkugel
  my $eta = ($wordnum * (time() - $start) / $curnum) - (time() - $start);
  my $eta_h = floor($eta/60/60); my $eta_m = floor(($eta - $eta_h * 60 * 60)/60); $eta = ($eta - $eta_h * 60 * 60 - $eta_m * 60);
  printf "(%.3f%% - ETA:%dh %02.dm %02.ds) $words->{$word}->{'orig'}: ", ($curnum * 100 / $wordnum), $eta_h, $eta_m, $eta;
  
  for (my $fwcl = $length - 3; $fwcl >= 3; $fwcl--) {
    next unless (defined $class[$fwcl]);
    
    foreach my $firstword (grep {$word =~ m/^$_/} @{$class[$fwcl]}) {
      my $firstlength = length($firstword);

      my $swcl = $length - $fwcl;
      if (defined $class[$swcl]) {
        foreach my $secondword (@{$class[$swcl]}) {

          if ($word eq $firstword.$secondword) {
            $words->{$firstword}->{'_'}   = '_';
            $words->{$secondword}->{'_'}  = '_';
            print "($firstword|$secondword) ";
          }

        }
      }
      next unless($word =~ /[sn]/);
      $swcl--;
      if (defined $class[$swcl]) {
        foreach my $secondword (@{$class[$swcl]}) {

          if ($word eq $firstword.'s'.$secondword) {
            $words->{$firstword}->{'_'}   = '_';
            $words->{$firstword}->{'x'}   = 'x';
            $words->{$secondword}->{'_'}  = '_';
            print "($firstword|$secondword) ";
          }
          elsif ($word eq $firstword.'n'.$secondword) {
            next unless ($firstword =~ m/e$/);
            $words->{$firstword}->{'_'}   = '_';
            $words->{$firstword}->{'x'}   = 'x';
            $words->{$secondword}->{'_'}  = '_';
            print "($firstword|$secondword) ";
          }

        }
      }
      $swcl--;
      if (defined $class[$swcl]) {
        foreach my $secondword (@{$class[$swcl]}) {

          if ($word eq $firstword.'es'.$secondword) {
            $words->{$firstword}->{'_'}   = '_';
            $words->{$firstword}->{'y'}   = 'y';
            $words->{$secondword}->{'_'}  = '_';
            print "($firstword|$secondword) ";
          }
          elsif ($word eq $firstword.'en'.$secondword) {
            next unless (exists $words->{$firstword}->{'P'});
            $words->{$firstword}->{'_'}   = '_';
            $words->{$firstword}->{'z'}   = 'z';
            $words->{$secondword}->{'_'}  = '_';
            print "($firstword|$secondword) ";
          }

        }
      }
    }
  }
  print "\n";
}

# Neues Wörterbuch schreiben
$in->open("< $INFILE") || die("Error while opening input file: $!\n");
while (my $line = <$in>) {
  $line =~ m/^([^\/]+)\/?(.*)$/;

  # habe ich das Wort
  my $word = lc($1);
  $word =~ s/\s+$//;
  if (exists($words->{$word})) {
    my $realword = $words->{$word}->{'orig'};
    delete $words->{$word}->{'orig'};
    my $attribs = join("", sort keys %{$words->{$word}});
    $attribs = "/$attribs" if (length($attribs) > 0);
    printf $out "%s%s\n", $realword, $attribs;
  }
  else {
    print $out $line;
  }
}

$in->close;
$out->close;
