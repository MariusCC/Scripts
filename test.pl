#!/usr/bin/env perl

use XML::Simple;
use Net::SMTP;

$smtp = Net::SMTP->new('localhost');
$smtp->auth();

die if !$smtp;
