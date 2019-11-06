#!/usr/bin/perl

use lib '/home/www/cgi-bin';
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use strict;
use Data::Dumper;
use DBI;
use Licence;
use JSON;
use utf8;
use Convert::Cyrillic;
use Encode;



print "Content-type: text/html\n\n";


my $dbh=undef;

my %act=(
	"activating"=>\&Activate,
	"checkLicense"=>\&Check_lic,	
	"add"=>\&Add,
	"block_form"=>\&Block_form,
	"block"=>\&Block,	
	"unblock_form"=>\&Unblock_form,
	"unblock"=>\&Unblock,
	"edit_form"=>\&Edit_form,
	"update_form"=>\&Update_form,
	"update"=>\&Update,
	"del_form"=>\&Del_form,
	"delete"=>\&Delete,	
	"view"=>\&View	
	);


my $q = CGI->new;
my $keywords = $q->param('POSTDATA');
# print Dumper($keywords);

my $input=decode_json $q->param('POSTDATA');

my $action=$input->{'request_type'};



if ((!defined($action))||(!exists($act{$action})))
{
	print "Неверный код команды!";
	exit 0;
}
else
{
	$dbh=&Licence::Connect;
	$dbh->do("use $config{'dbname'}");
	&{$act{$action}}($dbh,$input);
	$dbh->disconnect;
}




sub Check_lic
{
	my ($dbh,$input)=@_;	
	
	
	my	$sth = $dbh->prepare(  qq{UPDATE License SET LicStatus=-1 WHERE end_lic<NOW()});
	$sth->execute;
	
	
	$sth = $dbh->prepare( qq|SELECT id,LicStatus  FROM License where LicNUM=?|);
	$sth->execute($input->{licenseNumber});
		
	my $ref;

	if ($ref = $sth->fetchrow_hashref) 
	{			
		print $ref->{LicStatus};
	}
	else { print "-2" }
			
}




sub Activate
{
	my ($dbh,$input)=@_;	
	
	
	my $sth = $dbh->prepare(  qq{SELECT CompanyName,LicNUM,uuid, WelcomingText,Comment,LicStatus,psw1,psw2,psw3,DeviceLimit FROM License where uuid=?} );
	$sth->execute($input->{UUID});	
	
	if (my $ref = $sth->fetchrow_hashref) 
	{		
		if ($ref->{LicStatus}==0)
		{
			$ref->{LicStatus}=1;			
			my $sth2 = $dbh->prepare(  qq{UPDATE License SET LicStatus=1, DeviceInfo=? WHERE uuid=?});
	
			$sth2->execute($input->{DeviceInfo},$input->{UUID});			
			
			my $json= JSON->new->latin1->encode($ref);	
			
			my $octets = encode("latin1", $json);		
			my $src = 'win';
			my $dst = 'UTF-8';

			$octets= Convert::Cyrillic::cstocs ($src, $dst, $octets);
			
			print "$octets";
		}
		else { print $ref->{LicStatus} }		
	}
	else { print "-2" }
}