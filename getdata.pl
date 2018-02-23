#!/usr/bin/perl -w
# Used to grab data automatically
use strict;
use warnings;
use LWP::Simple;
use utf8;

my($LogLocation) = "LOGLOCATION";
my($logfilelocation) = "/tmp/result.txt";
my($LOG) = \*STDOUT;
my($time) = "";
my($housechecknum) = 0;
my($homechecknum) = 0;
my($housesignnum) = 0;
my($homesignnum) = 0;

my ($debugflag) = "true";

sub debuglog {
    print @_ if(defined($debugflag));
}

sub errorlog{
    print @_;
}

sub GetFirstNumberFromStr {
    my ($str) = "";
    my ($anker) = "";
    my ($result) = 0;
    my ($substr) = "";
    ($str, $anker) = split(@_);
    
    my ($location) = index($str, $anker);


}

sub OpenResultFile {
    my ($LOGF);
    if(!open(LOGF, "+>> $logfilelocation")){
        errorlog("Failed to open $logfilelocation, $?\n");
        return 1;
    }
    $LOG = \*LOGF;
    return 0;
}

sub CloseResultFile {
    close $LOG;
}

sub Log {
    printf $LOG @_;
}


sub GetTime {
    my($str) = @_;
    my ($delim) = "核验房源";
    my ($index) = index($str, $delim);
    if ($index eq -1){
        errorlog("Failed to find $delim in GetTime");
        return 1;
    }
    $index = $index - 10;
    $time = substr($str, $index, 10);
    return 0;
}

sub GetHouseCheckNum{
    my($str) = @_;
    my($delim) = "核验房源套数";
    my($index) = index($str, $delim);
    if($index eq -1){
        errorlog("Failed to get HouseCheckNum\n");
        return 1;
    }
    my($localstr) = substr($str, $index, 100);
    $localstr =~ /(\d+)/;
    $housechecknum = $1;

    $delim = "核验住宅套数";
    $index = index($str, $delim);
    if($index eq -1){
        errorlog("Failed to get HomeCheckNum\n");
        return 1;
    }
    $localstr = substr($str, $index, 100);
    $localstr =~ /(\d+)/;
    $homechecknum = $1;

    return 0;
}

sub GetHouseSignNum {
    my($str) = @_;
    my($delim) = "${time}存量房网上签约";
    my($index) = index($str, $delim);
    $str = substr($str, $index);

    $delim = "网上签约套数";
    $index = index($str, $delim);
    if($index eq -1){
        errorlog("Failed to get HouseSignNum\n");
        return 1;
    }
    my($localstr) = substr($str, $index, 100);
    $localstr =~ /(\d+)/;
    $housesignnum = $1;

    $delim = "住宅签约套数";
    $index = index($str, $delim);
    if($index eq -1){
        errorlog("Failed to get HomeSignNum\n");
        return 1;
    }
    $localstr = substr($str, $index, 100);
    $localstr =~ /(\d+)/;
    $homesignnum = $1;

    return 0;
}

sub WriteToLogFile {
    Log("$time  核验房源套数:$housechecknum 核验住宅套数:$homechecknum 网上签约套数:$housesignnum 住宅签约套数:$homesignnum\n");
    return 0;
}

sub GetHouseInfo {
    my ($info) = "";
    my ($url) = "http://210.75.213.188/shh/portal/bjjs2016/index.aspx";
    my ($page) = get($url);
    my ($length) = length($page);
    my ($delim1) = "存量房网上签约统计";
    my ($index) = index($page, "$delim1");
    my ($substr) = substr($page, $index);
    return 1 if  (&GetTime($substr) != 0);
    return 1 if (&GetHouseCheckNum($substr) != 0);
    return 1 if (&GetHouseSignNum($substr) != 0);
    return 1 if (&WriteToLogFile != 0);
    return 0;
}

##############  MAIN FUNCTION ###################
if(&OpenResultFile() != 0){
    errorlog("Main::Failed to open logfile $logfilelocation\n");
    return 1;
}
GetHouseInfo();
&CloseResultFile();
