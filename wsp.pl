#!/usr/bin/perl

<<<<<<< HEAD
###############################################
# Windows Store Parser v1.6                   #
# igroykt (c)04.09.2014-23.09.2014	      #
###############################################
=======
#################################################
# Windows Store Parser v1.4 	   		#
# igroykt (c)04.09.2014-18.09.2014		#
#################################################
>>>>>>> origin/master

use strict;
use XML::LibXML qw( );
use File::Copy qw(move);
use File::Copy qw(copy);
use Tie::File;
use MIME::Lite;
use MIME::Base64 ();
use Time::Piece;
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
my $ru_url="";

#EN SETTINGS
my $en_current=$pwd."/en_current.txt";
my $en_previous=$pwd."/en_previous.txt";
my $en_tmp=$pwd."/en_tmp.xml";
my $en_mail=$pwd."/en_mail.txt";
my $en_url="";

#MAIL SETTINGS
<<<<<<< HEAD
my $to='';
my $from='';
=======
my $to='mail1@example.com mail2@example.com';
my $from='robot@example.com';
>>>>>>> origin/master
my $ru_subject='Windows Store Reviews [RU]';
my $en_subject='Windows Store Reviews [EN]';

sub trimDate{
        my($string)=@_;
        $string=substr($string,0,-18);
        return $string;
}

sub parseReviews{
        my $num_args=scalar(@_);
        my $getXML=`lynx -dump -source '$_[2]' > $_[1]`;
        my $parser=XML::LibXML->new();
        my $root=$parser->parse_file($_[1]);
        my @current=();
        for my $review ($root->findnodes('Reviews/Review')){
                my $review_author=$review->find('Author/OrderedBasicName');
                my $review_rating=$review->find('Rating');
                my $review_comment=$review->find('Comment');
                my $review_date=$review->find('LastUpdatedDate');
                push(@current,trimDate($review_date)." Автор: ".$review_author." Рейтинг: ".$review_rating." Комментарий: ".$review_comment."\n");
        }
        my %seen=();
        my @unique=grep{ ! $seen{ $_ }++ } @current;
        my $date=localtime->strftime('%Y-%m-%d');
        @unique=grep(/$date/, @unique);
        open (CFILE,">>:utf8",$_[0]);
        foreach(@unique){print CFILE $_;}
        close(CFILE);
        unlink $_[1];
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
        close $fileHandler;
}

sub makeUniq {
        my $num_args=scalar(@_);
        tie my @lines,'Tie::File',$_[0];
        my %seen=();
        @lines=grep { ! $seen{$_}++ } @lines;
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
                        Type    => 'text/plain; charset=UTF-8',
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
                &parseReviews($ru_current,$ru_tmp,$ru_url);
                &parseReviews($en_current,$en_tmp,$en_url);
        }
        case "send"{
                &sendMail($ru_subject,$ru_mail,$ru_current,$ru_previous);
                &sendMail($en_subject,$en_mail,$en_current,$en_previous);
        }
        else{
                print "USAGE: ./wsp.pl [option]\nOPTIONS:\n     parse - get reviews\n   send - send reviews via email (need smtp relay)\n";
        }
}
