#!/usr/bin/perl

#################################################
# Windows Store Parser v1.4 	   		#
# igroykt (c)04.09.2014-18.09.2014		#
#################################################

use strict;
#use warnings;
use XML::LibXML qw( );
use File::Copy qw(move);
use File::Copy qw(copy);
use List::MoreUtils qw(uniq);
use MIME::Lite;
use MIME::Base64 ();
use utf8;
use Switch;
binmode(STDOUT,':utf8');

#ENV
my $pwd="/root/bin/wsp";

#RU SETTINGS
my $ru_current=$pwd."/ru_current.txt";
my $ru_previous=$pwd."/ru_previous.txt";
my $ru_tmp=$pwd."/ru_tmp.xml";
my $ru_mail=$pwd."/ru_mail.txt";
my $ru_url="https://next-services.apps.microsoft.com/4R/6.3.9600-0/788/ru-RU/m/RU/Apps/a85640c3-05bd-400f-8e05-8782ae082b37/Reviews/all/s/date/1/pn/1/ri/62417f04-c1d7-4d04-a4b2-114aeba73951/vf/all";

#EN SETTINGS
my $en_current=$pwd."/en_current.txt";
my $en_previous=$pwd."/en_previous.txt";
my $en_tmp=$pwd."/en_tmp.xml";
my $en_mail=$pwd."/en_mail.txt";
my $en_url="https://next-services.apps.microsoft.com/4R/6.3.9600-0/788/ru-RU/m/US/Apps/a85640c3-05bd-400f-8e05-8782ae082b37/Reviews/all/s/date/1/pn/1/ri/62417f04-c1d7-4d04-a4b2-114aeba73951/vf/all";

#MAIL SETTINGS
my $to='tss_team@mytona.com admin@mytona.com';
#my $to='admin@mytona.com';
my $from='robot@mytona.com';
my $ru_subject='Windows Store Reviews [RU]';
my $en_subject='Windows Store Reviews [EN]';

sub parseReviews{
	my $num_args=scalar(@_);
	my $getXML=`lynx -source $_[3] > $_[2]`;
	my $parser=XML::LibXML->new();
	my $root=$parser->parse_file($_[2]);
	my @current=();
	for my $review ($root->findnodes('Reviews/Review')){
		my $review_id=$review->find('ReviewID');
		my $review_author=$review->find('Author/OrderedBasicName');
		my $review_rating=$review->find('Rating');
		my $review_comment=$review->find('Comment');
		push(@current,$review_id." Автор: ".$review_author." Рейтинг: ".$review_rating." Комментарий: ".$review_comment."\n");
	}
	my %seen=();
	my @unique=grep{ ! $seen{ $_ }++ } @current;
	open (CFILE,">>:utf8",$_[0]);
	foreach(@unique){print CFILE $_;}
	close(CFILE);
	unlink $_[2];
}

sub normalizeText {
	my $num_args=scalar(@_);
	my $fileHandler;
	my @text=();
	open $fileHandler,'<:utf8',$_[0];
	while(my $line=<$fileHandler>){
		substr($line,0,9)='';
		$line=~ s/Автор:  /Автор: Не указан /;
		$line=~ s/Рейтинг:  /Рейтинг: Не указан /;
		$line=~ s/Комментарий:  /Комментарий: Не указан /;
		$line=~ s/Автор/\nАвтор/;
		$line=~ s/Рейтинг/\nРейтинг/;
		$line=~ s/Комментарий/\nКомментарий/;
		push(@text,$line);
	}
	close $fileHandler;
	open $fileHandler,'>:utf8',$_[0];
	print {$fileHandler} @text;
}

sub makeUniq {
        my $num_args=scalar(@_);
        my $fileHandler;
        open $fileHandler,'<',$_[0];
        my @unique=uniq(<$fileHandler>);
        close $fileHandler;
        open $fileHandler,'>',$_[0];
        print {$fileHandler} @unique;
        close $fileHandler;
}

sub sendMail {
	my $num_args=scalar(@_);
	if (-s $_[3]){
		my $DIFF=`diff -u $_[2] $_[3] |grep '-'|sed '1,3d'|sed 's/-//g'|grep -v '+'|sed '/Комментарий/G' > $_[1]`;
		makeUniq($_[1]);
		normalizeText($_[1]);
	}
	if (-z $_[1]){
		unlink $_[1];
	}
	if (-s $_[1]){
		open my $fileHandler,'<',$_[1] or die "Couldn't open $_[1]: $!";
		my $text=do {
			local $/;
			<$fileHandler>
		};
		close $fileHandler;
		my $mail=MIME::Lite->new(
			Encoding=> '8bit',
			Type	=> 'text/plain; charset=UTF-8',
			From    => $from,
			To      => $to,
			Subject => $_[0],
			Data    => $text
		);
		$mail->send;
		unlink $_[1];
	}
	move $_[2],$_[3];
}

switch($ARGV[0]){
	case "parse"{
        	&parseReviews($ru_current,$ru_previous,$ru_tmp,$ru_url,$ru_mail);
        	&parseReviews($en_current,$en_previous,$en_tmp,$en_url,$en_mail);
	}
	case "send"{
		&sendMail($ru_subject,$ru_mail,$ru_current,$ru_previous);
		&sendMail($en_subject,$en_mail,$en_current,$en_previous);
	}
	else{
		print "USAGE: ./wsp.pl [option]\nOPTIONS:\n	parse - get reviews\n	send - send reviews via email (need smtp relay)\n";
	}
}
