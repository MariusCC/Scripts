#!/usr/bin/perl
# fdb_phonebook.pl
#
# DESC: A flatfile database phone book by Matt 'QX' Melton
# HTTP: http://blacksun.box.sk
# DATE: 25/10/01
# LNCE: You may not use this on your own site without pior permission
@validation = ('NUM', 'TEXT', 'TEXT', 'TEXT', 'TELEPHONE');
$db_file = "database.txt";
$sep = "\t";
&load_database;
&main_menu;
exit;
# ------------------
##
## Display the main menu, and prompts for input
##
sub main_menu {
my $main_screen = <<END;
The Phone book - by Matt
--------------------------
What you you like to do:
1) Add a new entry
2) Display an entry
3) Search for an entry
x) Exit
END
# 1st timers...
print $main_screen;
print "\t=";

while ($choice = <STDIN>) {
chomp $choice;
exit if ($choice eq 'x');
&add_entry if ($choice eq '1');
&show_entry if ($choice eq '2');
&search_entry if ($choice eq '3');
# Returns WIN32 usually, but you can never be
# too sure with NT and 2K :)
if ($^O =~ /WIN/i) {
system('cls'); 
} else {
system('clear');
}
print $main_screen;
print "\t=";
}
}
# 
# Prompts for new data input and validates, then runs write_entry
#
sub add_entry {
my @newrecord;
print "Forename: ";
my $forename = <STDIN>; chomp $forename; 
print "Surname: ";
my $surname = <STDIN>; chomp $surname; 
print "City: ";
my $city = <STDIN>; chomp $city;
print "Telephone number: ";
my $telephone = <STDIN>; chomp $telephone;
if (&chk_validation(0, $forename, $surname, $city, $telephone) == 1) {
print "Data entered was not valid. Please try again\n\n";
print "\n Entry NOT added.\n\nHit any key to continue...\n";
my $null = <STDIN>;
return;
}
&write_entry($forename, $surname, $city, $telephone);
print "\n Added entry.\n\nHit any key to continue...\n";
my $null = <STDIN>;
return;
}
#
# Prompts for key, then runs display_entry
#
sub show_entry {
print "Entry key number: ";
my $key = <STDIN>; chomp $key;
print "\n";
&display_entry($key);
print "\nHit any key to continue\n";
my $null = <STDIN>;
}
#
# Retrieves records, checks for existance, then displays
#
sub display_entry {
my ($key) = @_;
my $record = $database{$key};
if ($record == undef) {
print "That record does not exist\n";
return;
}
print "ID........... $key\n";
print "Name......... $$record[0]\n";
print "Surname...... $$record[1]\n";
print "City......... $$record[2]\n";
print "Telephone.... $$record[3]\n";
}
#
# Prompts for search term, runs the search sub, display entry if only 1, or displays
# entry keys if more
#
sub search_entry {
print "Please type the search phrase [Name, partial number]: ";
my $term = <STDIN>;
chomp $term;
print "\n";
my ($matches) = &search($term);
if (@$matches == undef) {
print "Sorry, no matches found\n\nHit any key to continue...\n";
my $null = <STDIN>;
return;
}
if ($#$matches == 1) {
print "Found one matching entry:\n";
&display_entry($$matches[1]);
print "\nHit any key to continue.\n";
my $null = <STDIN>;
return;
} 
print "Found " . $#$matches . " matching entries: " . substr(join(', ', @$matches), 2) . "\n\nHit any key to continue...\n";
my $null = <STDIN>;
}
#
# If the db file exists, it will read it and split the lines into records, and then
# fields. The adds to $database hash
#
sub load_database {
if (-e $db_file) {
open(hDB, $db_file) or die "Sorry, we couldn't open the file specified: $_";
@db_lines = <hDB>;
close(hDB);
foreach $db_line (@db_lines) {
chomp $db_line;
next if $db_line eq "";
my @record = split(/$sep/, $db_line);
my $i = 0;
my $value;
foreach $value (@record) {
@record[$i] = $value if (s/__BAR__/$sep/ig);
$i++;
}
if (&chk_validation(@record) == 1) {
die "Sorry, there was an error parsing the database input :(";
}
$database{$record[0]} = [@record[1..$#record]]; 
}
}
}
#
# Concurrently parses the records with the array @validation
# returns 1 if there is a validation error
#
sub chk_validation {
my @arraytocheck = @_;
my $pos = 0;
foreach $value (@arraytocheck) {
if ($validation[$pos] eq 'NUM') {
return 1 if ($value !~ /^\d+$/); # returns the value 1
} 

if ($validation[$pos] eq 'TELEPHONE') {
return 1 if ($value =~ /[^\d|\+| |\(|\)]/);
}
# We don't care about text :) 
$pos++;
}
return 0;
}

#
# Parses, replaces, the $sep character in a string and prints to the end of the db file
#
sub write_entry {
my $i = 0;
my $value; 
# my apologies if there is an easier way of doing this
foreach $value (@_) {
@_[$i] = $value if (s/$sep/__BAR__/ig);
$i++;
}
my ($forename, $surname, $city, $telephone) = @_;
my $cid = (scalar keys %database) + 1;
open(OUT, '>>' . $db_file) or die "Sorry, we could not open the database for writing, $!";
print OUT $cid . $sep . $forename . $sep . $surname . $sep . $city . $sep . $telephone . "\n";
close(OUT); 
&load_database; # reload the db, but we could do it straight to the array, but it'd be
# an active memory db and not a flat file one :)
}
#
# Cycles each key/value pair and sees if they match the term, if so, adds to array and
# returns list of matches
#
sub search {
my ($term) = @_;
my @found = undef;
while (($key, $value) = each(%database)) { 
foreach $field (@{$value}) {
push (@found, $key) if ($field =~ /$term/i);
}
}
return undef if ($#found == 0);
# else
return \@found;
}
