#!/usr/bin/perl
use strict;
use warnings;

sub download_tarball{
	system("wget https://aur.archlinux.org/packages/`echo $_|cut -c1-2`/$_/$_.tar.gz&&rm -rf $_");
	system("tar xvf $_.tar.gz");
	system("rm -rf $_.tar.gz");
}

sub git_message{
	system("git add .&&git commit -m 'upgpkg: $_'");
}

foreach (@ARGV){
	download_tarball($_);
	git_message($_);
}